from flask import Flask, render_template, jsonify, request, session, redirect, url_for
from db_config import query_db
import random
from datetime import datetime, timedelta
import os
from dotenv import load_dotenv
from google import genai
from google.genai import types

load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

app = Flask(__name__)
app.secret_key = 'patchly-secret-key-2026'

# ─────────────────────────────────────────────
# PAGES
# ─────────────────────────────────────────────

@app.route('/')
def login():
    if 'user' in session:
        if session['role'] == 'admin':
            return redirect('/admin')
        else:
            return redirect('/engineer')
    return render_template('login.html')

@app.route('/admin')
def admin_dashboard():
    if 'user' not in session or session.get('role') != 'admin':
        return redirect('/')
    return render_template('admin.html')

@app.route('/api/login', methods=['POST'])
def api_login():
    data = request.json
    username = data.get('username', '')
    password = data.get('password', '')
    role = data.get('role', '')
    
    # Authenticate against SystemUser table using SHA-256 hash
    user = query_db(
        "SELECT su.UserID, su.Username, su.Role, su.EngineerID, e.Name as EngineerName "
        "FROM SystemUser su "
        "LEFT JOIN Engineer e ON su.EngineerID = e.EngineerID "
        "WHERE su.Username = %s AND su.PasswordHash = SHA2(%s, 256) AND su.Role = %s",
        (username, password, role),
        fetchone=True
    )
    
    if not user:
        return jsonify({'success': False, 'error': 'Invalid username or password'})
    
    session['user'] = user['Username']
    session['role'] = user['Role']
    session['name'] = user.get('EngineerName') or 'Admin'
    session['user_id'] = user['UserID']
    if user['EngineerID']:
        session['engineer_id'] = user['EngineerID']
    
    redirect_url = '/admin' if role == 'admin' else '/engineer'
    return jsonify({'success': True, 'redirect': redirect_url})

@app.route('/api/change-password', methods=['POST'])
def change_password():
    if 'user' not in session:
        return jsonify({'success': False, 'error': 'Not logged in'}), 401
    
    data = request.json
    old_password = data.get('old_password', '')
    new_password = data.get('new_password', '')
    
    if len(new_password) < 4:
        return jsonify({'success': False, 'error': 'New password must be at least 4 characters'})
    
    # Verify old password
    check = query_db(
        "SELECT UserID FROM SystemUser WHERE Username = %s AND PasswordHash = SHA2(%s, 256)",
        (session['user'], old_password),
        fetchone=True
    )
    if not check:
        return jsonify({'success': False, 'error': 'Current password is incorrect'})
    
    # Update to new password
    query_db(
        "UPDATE SystemUser SET PasswordHash = SHA2(%s, 256) WHERE Username = %s",
        (new_password, session['user'])
    )
    return jsonify({'success': True, 'message': 'Password updated successfully'})

@app.route('/logout')
def logout():
    session.clear()
    return redirect('/')

# ─────────────────────────────────────────────
# ADMIN API ENDPOINTS (Task 4 Queries)
# ─────────────────────────────────────────────

@app.route('/api/dashboard-stats')
def dashboard_stats():
    """KPI cards: total bugs, open bugs, SLA breaches, total engineers."""
    stats = {}
    stats['total_bugs'] = query_db("SELECT COUNT(*) as c FROM Bug", fetchone=True)['c']
    stats['open_bugs'] = query_db("""
        SELECT COUNT(*) as c FROM Bug b
        JOIN Status s ON b.StatusID = s.StatusID
        WHERE s.StatusName NOT IN ('Resolved', 'Closed')
    """, fetchone=True)['c']
    stats['sla_breaches'] = query_db("SELECT COUNT(*) as c FROM Penalty", fetchone=True)['c']
    stats['total_engineers'] = query_db("SELECT COUNT(*) as c FROM Engineer", fetchone=True)['c']
    stats['total_reviews'] = query_db("SELECT COUNT(*) as c FROM Review", fetchone=True)['c']
    stats['critical_bugs'] = query_db("""
        SELECT COUNT(*) as c FROM Bug b
        JOIN Priority p ON b.PriorityID = p.PriorityID
        WHERE p.PriorityLevel = 'Critical'
    """, fetchone=True)['c']
    return jsonify(stats)


@app.route('/api/bug-stats')
def get_bug_stats():
    """For the pie chart: count bugs by priority."""
    sql = """
        SELECT p.PriorityLevel, COUNT(b.BugID) as Count
        FROM Bug b
        JOIN Priority p ON b.PriorityID = p.PriorityID
        GROUP BY p.PriorityLevel
    """
    return jsonify(query_db(sql))


@app.route('/api/recent-bugs')
def recent_bugs():
    """For the home dashboard: get recent bugs, filtered by status and search."""
    search = request.args.get('search', '').strip()
    status_filter = request.args.get('status', '').strip() # e.g. "Resolved", "Open"
    
    where_clauses = []
    params = []
    
    if search:
        where_clauses.append("(r.Content LIKE %s OR b.Title LIKE %s OR b.Description LIKE %s)")
        params.extend([f"%{search}%", f"%{search}%", f"%{search}%"])
        
    if status_filter == 'Resolved':
        where_clauses.append("s.StatusName = 'Resolved'")
    elif status_filter == 'Open':
        where_clauses.append("s.StatusName NOT IN ('Resolved', 'Closed')")
        
    where_sql = ""
    if where_clauses:
        where_sql = "WHERE " + " AND ".join(where_clauses)
        
    # If filtered heavily on Resolved, order by completion (if we had it joined, else CreatedAt). Let's stick to CreatedAt to be safe unless joined.
    order_sql = "ORDER BY b.CreatedAt DESC"

    sql = f"""
        SELECT 
            b.BugID, 
            DATE_FORMAT(b.CreatedAt, '%Y-%m-%d %H:%i') as CreatedAt,
            p.PlatformName,
            LEFT(r.Content, 60) as Snippet,
            r.Content as FullReview,
            pr.PriorityLevel,
            s.StatusName
        FROM Bug b
        JOIN Review r ON b.ReviewID = r.ReviewID
        JOIN Platform p ON r.PlatformID = p.PlatformID
        JOIN Priority pr ON b.PriorityID = pr.PriorityID
        JOIN Status s ON b.StatusID = s.StatusID
        {where_sql}
        {order_sql}
        LIMIT 20
    """
    return jsonify(query_db(sql, tuple(params)))


@app.route('/api/bugs-list')
def bugs_list():
    """Paginated and filtered bug list for platform views."""
    platform_id = request.args.get('platform_id')
    category_id = request.args.get('category_id')
    page = int(request.args.get('page', 1))
    limit = 5
    offset = (page - 1) * limit

    where_clauses = []
    params = []

    if platform_id:
        where_clauses.append("r.PlatformID = %s")
        params.append(int(platform_id))
    if category_id:
        where_clauses.append("b.CategoryID = %s")
        params.append(int(category_id))

    where_sql = ""
    if where_clauses:
        where_sql = "WHERE " + " AND ".join(where_clauses)

    sql = f"""
        SELECT 
            b.BugID,
            c.CategoryName,
            pr.PriorityLevel,
            LEFT(r.Content, 80) as Snippet,
            COALESCE(e.Name, 'Unassigned') as AssignedTo,
            s.StatusName as Status
        FROM Bug b
        JOIN Review r ON b.ReviewID = r.ReviewID
        JOIN BugCategory c ON b.CategoryID = c.CategoryID
        JOIN Priority pr ON b.PriorityID = pr.PriorityID
        LEFT JOIN BugAssignment ba ON b.BugID = ba.BugID
        LEFT JOIN Engineer e ON ba.EngineerID = e.EngineerID
        JOIN Status s ON b.StatusID = s.StatusID
        {where_sql}
        ORDER BY b.CreatedAt DESC
        LIMIT %s OFFSET %s
    """
    
    # Needs to be a mutable list to append limit/offset
    safe_params = list(params)
    safe_params.extend([limit, offset])
    
    bugs = query_db(sql, tuple(safe_params))

    # Get total count for pagination
    count_sql = f"""
        SELECT COUNT(b.BugID) as Total
        FROM Bug b
        JOIN Review r ON b.ReviewID = r.ReviewID
        {where_sql}
    """
    total_res = query_db(count_sql, tuple(params))
    total_count = total_res[0]['Total'] if total_res else 0

    return jsonify({
        'bugs': bugs,
        'total': total_count,
        'page': page,
        'has_more': total_count > (page * limit)
    })

    
@app.route('/api/engineers')
def get_engineers():
    """Query 1: All engineers with departments, skills, workload."""
    dept_filter = request.args.get('department', '')
    sql = """
        SELECT 
            e.EngineerID,
            e.Name AS EngineerName,
            d.DepartmentName,
            GROUP_CONCAT(DISTINCT s.SkillName ORDER BY s.SkillName SEPARATOR ', ') AS Skills,
            e.CurrentWorkload,
            e.MaxWorkload,
            e.IsOnLeave,
            CASE 
                WHEN e.CurrentWorkload >= e.MaxWorkload THEN 'AT CAPACITY'
                WHEN e.CurrentWorkload >= e.MaxWorkload * 0.8 THEN 'HEAVY'
                ELSE 'NORMAL'
            END AS WorkloadStatus
        FROM Engineer e
        JOIN Department d ON e.DepartmentID = d.DepartmentID
        LEFT JOIN EngineerSkill es ON e.EngineerID = es.EngineerID
        LEFT JOIN Skill s ON es.SkillID = s.SkillID
    """
    params = ()
    if dept_filter:
        sql += " WHERE d.DepartmentName = %s"
        params = (dept_filter,)
    sql += " GROUP BY e.EngineerID, e.Name, d.DepartmentName, e.CurrentWorkload, e.MaxWorkload, e.IsOnLeave"
    sql += " ORDER BY e.CurrentWorkload DESC"
    return jsonify(query_db(sql, params))


@app.route('/api/admin/unassigned-bugs')
def unassigned_bugs():
    sql = """
        SELECT 
            b.BugID,
            b.Title,
            pr.PriorityLevel,
            c.CategoryName,
            b.CreatedAt
        FROM Bug b
        JOIN Priority pr ON b.PriorityID = pr.PriorityID
        LEFT JOIN BugCategory c ON b.CategoryID = c.CategoryID
        WHERE b.StatusID = 1 AND b.BugID NOT IN (SELECT BugID FROM BugAssignment)
        ORDER BY b.CreatedAt DESC
    """
    return jsonify(query_db(sql))


@app.route('/api/admin/triage-info/<int:bug_id>')
def triage_info(bug_id):
    """Returns modal data: can we auto-assign? + List of ALL engineers."""
    bug = query_db("SELECT CategoryID FROM Bug WHERE BugID = %s", (bug_id,), fetchone=True)
    if not bug:
        return jsonify({'error': 'Bug not found'}), 404
    
    category_id = bug['CategoryID']
    
    # Category to Skill mapping (approximate for Patchly)
    cat_skills = {
        1: [3, 4, 5], # UI/UX -> React, Swift, Kotlin
        2: [1, 2, 6], # Performance -> Java, Python, SQL
        3: [1, 4, 5], # Crash -> Java, Swift, Kotlin
        4: [2, 8],    # Security -> Python, AWS
        6: [6, 8]     # Data Loss -> SQL, AWS
    }
    
    req_skills = cat_skills.get(category_id, [])
    
    # Are there capable engineers?
    capable = False
    if req_skills:
        placeholders = ','.join(['%s']*len(req_skills))
        sc_query = f"""
            SELECT e.EngineerID
            FROM Engineer e
            JOIN EngineerSkill es ON e.EngineerID = es.EngineerID
            WHERE e.IsOnLeave = FALSE AND e.CurrentWorkload < e.MaxWorkload
            AND es.SkillID IN ({placeholders})
            LIMIT 1
        """
        if query_db(sc_query, tuple(req_skills)):
            capable = True
    else:
        # If no specific skills required or mapping missed, anyone with space is technically capable of auto
        any_space = query_db("SELECT EngineerID FROM Engineer WHERE CurrentWorkload < MaxWorkload LIMIT 1")
        if any_space:
            capable = True

    # ALL Engineers for Manual Dropdown
    all_engineers = query_db("SELECT EngineerID, Name, CurrentWorkload, MaxWorkload FROM Engineer")
    
    return jsonify({
        'auto_available': capable,
        'all_engineers': all_engineers
    })


@app.route('/api/admin/assign-bug', methods=['POST'])
def admin_assign_bug():
    if 'user' not in session or session.get('role') != 'admin':
        return jsonify({'success': False, 'error': 'Not authorized'}), 403
        
    data = request.json
    bug_id = data.get('bug_id')
    sla_hours = int(data.get('sla_hours', 24))
    is_auto = data.get('is_auto', False)
    engineer_id = data.get('engineer_id') # only if is_auto is False
    
    if not bug_id:
        return jsonify({'success': False, 'error': 'Missing Bug ID'}), 400
        
    try:
        if is_auto:
            # Re-run selection logic to find the BEST engineer
            bug = query_db("SELECT CategoryID FROM Bug WHERE BugID = %s", (bug_id,), fetchone=True)
            cat_id = bug['CategoryID'] if bug else 1
            cat_skills = {1:[3,4,5], 2:[1,2,6], 3:[1,4,5], 4:[2,8], 6:[6,8]}
            req_skills = cat_skills.get(cat_id, [])
            
            sel_sql = """
                SELECT e.EngineerID 
                FROM Engineer e
            """
            params = []
            if req_skills:
                sel_sql += " JOIN EngineerSkill es ON e.EngineerID = es.EngineerID "
                placeholders = ','.join(['%s']*len(req_skills))
                sel_sql += f" WHERE es.SkillID IN ({placeholders}) AND "
                params = list(req_skills)
            else:
                sel_sql += " WHERE "
                
            sel_sql += " e.IsOnLeave = FALSE AND e.CurrentWorkload < e.MaxWorkload ORDER BY (e.MaxWorkload - e.CurrentWorkload) DESC LIMIT 1"
            
            best = query_db(sel_sql, tuple(params), fetchone=True)
            if not best:
                # Fallback to any engineer with space
                best = query_db("SELECT EngineerID FROM Engineer WHERE IsOnLeave = FALSE AND CurrentWorkload < MaxWorkload ORDER BY CurrentWorkload ASC LIMIT 1", fetchone=True)
                if not best:
                    return jsonify({'success': False, 'error': 'No engineers available for auto assignment.'}), 400
            
            engineer_id = best['EngineerID']
            
        if not engineer_id:
            return jsonify({'success': False, 'error': 'Engineer selection required.'}), 400

        now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        due_by = (datetime.now() + timedelta(hours=sla_hours)).strftime('%Y-%m-%d %H:%M:%S')
        
        query_db(
            "INSERT INTO BugAssignment (BugID, EngineerID, AssignedAt, DueBy) VALUES (%s, %s, %s, %s)",
            (bug_id, engineer_id, now, due_by)
        )
        query_db("UPDATE Engineer SET CurrentWorkload = CurrentWorkload + 1 WHERE EngineerID = %s", (engineer_id,))
        query_db("UPDATE Bug SET StatusID = 2 WHERE BugID = %s", (bug_id,))
        
        assigned_eng = query_db("SELECT Name FROM Engineer WHERE EngineerID = %s", (engineer_id,), fetchone=True)
        return jsonify({'success': True, 'assigned_to': assigned_eng['Name']})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/bugs-by-platform')
def bugs_by_platform():
    """Query 2: Bugs grouped by Spotify Platform (using Review.PlatformID)."""
    sql = """
        SELECT 
            p.PlatformName,
            COUNT(b.BugID) AS TotalOpenBugs,
            SUM(CASE WHEN pr.PriorityLevel = 'Critical' THEN 1 ELSE 0 END) AS CriticalBugs,
            SUM(CASE WHEN pr.PriorityLevel = 'High' THEN 1 ELSE 0 END) AS HighBugs,
            SUM(CASE WHEN pr.PriorityLevel = 'Medium' THEN 1 ELSE 0 END) AS MediumBugs
        FROM Bug b
        JOIN Review r ON b.ReviewID = r.ReviewID
        JOIN Platform p ON r.PlatformID = p.PlatformID
        JOIN Priority pr ON b.PriorityID = pr.PriorityID
        GROUP BY p.PlatformName
        ORDER BY CriticalBugs DESC, TotalOpenBugs DESC
    """
    return jsonify(query_db(sql))


@app.route('/api/sla-breaches')
def sla_breaches():
    """Query 3: SLA Breach Report per Engineer."""
    order = request.args.get('order', 'desc')
    order_clause = "DESC" if order == "desc" else "ASC"
    sql = f"""
        SELECT 
            e.Name,
            d.DepartmentName,
            COUNT(p.PenaltyID) AS TotalSlaBreaches,
            COALESCE(SUM(p.Amount), 0) AS TotalPenaltyCost
        FROM Engineer e
        JOIN Department d ON e.DepartmentID = d.DepartmentID
        LEFT JOIN BugAssignment ba ON e.EngineerID = ba.EngineerID
        LEFT JOIN Penalty p ON ba.BugID = p.BugID
        GROUP BY e.EngineerID, e.Name, d.DepartmentName
        ORDER BY TotalPenaltyCost {order_clause}
    """
    return jsonify(query_db(sql))


@app.route('/api/sentiments')
def sentiments():
    """Query 4: Sentiment-to-Bug conversion stats."""
    sql = """
        SELECT 
            snt.SentimentType,
            COUNT(r.ReviewID) as ReviewCount,
            COUNT(b.BugID) as BugsGenerated,
            ROUND((COUNT(b.BugID) / COUNT(r.ReviewID) * 100), 2) as ConversionRate
        FROM Sentiment snt
        JOIN ReviewSentiment rs ON snt.SentimentID = rs.SentimentID
        JOIN Review r ON rs.ReviewID = r.ReviewID
        LEFT JOIN Bug b ON r.ReviewID = b.ReviewID
        GROUP BY snt.SentimentType
        ORDER BY BugsGenerated DESC
    """
    return jsonify(query_db(sql))


@app.route('/api/resolution-stats')
def resolution_stats():
    """Query 8: Average resolution time by priority."""
    sql = """
        SELECT 
            p.PriorityLevel,
            COUNT(ba.AssignmentID) as TotalResolved,
            ROUND(AVG(TIMESTAMPDIFF(HOUR, ba.AssignedAt, ba.CompletedAt)), 1) as AvgResolutionHours,
            MAX(sla.MaxResolutionHours) as TargetSLA
        FROM BugAssignment ba
        JOIN Bug b ON ba.BugID = b.BugID
        JOIN Priority p ON b.PriorityID = p.PriorityID
        JOIN SLA sla ON p.PriorityID = sla.PriorityID
        WHERE ba.CompletedAt IS NOT NULL
        GROUP BY p.PriorityLevel, p.PriorityID
        ORDER BY p.PriorityID ASC
    """
    return jsonify(query_db(sql))


@app.route('/api/penalties-by-dept')
def penalties_by_dept():
    """Query 11: Penalty cost by department."""
    sql = """
        SELECT 
            d.DepartmentName,
            COUNT(p.PenaltyID) as NumberOfPenalties,
            COALESCE(SUM(p.Amount), 0) as TotalFinancialCost
        FROM Department d
        JOIN Engineer e ON d.DepartmentID = e.DepartmentID
        LEFT JOIN BugAssignment ba ON e.EngineerID = ba.EngineerID
        LEFT JOIN Penalty p ON ba.BugID = p.BugID
        GROUP BY d.DepartmentName
        ORDER BY TotalFinancialCost DESC
    """
    return jsonify(query_db(sql))


@app.route('/api/departments')
def get_departments():
    return jsonify(query_db("SELECT * FROM Department ORDER BY DepartmentName"))


@app.route('/api/skills')
def get_skills():
    return jsonify(query_db("SELECT * FROM Skill ORDER BY SkillName"))


@app.route('/api/engineers', methods=['POST'])
def add_engineer():
    """Admin: Add a new engineer."""
    data = request.json
    name = data.get('name')
    email = data.get('email')
    dept_id = data.get('department_id')
    max_workload = data.get('max_workload', 10)
    skill_ids = data.get('skill_ids', [])

    if not all([name, email, dept_id]):
        return jsonify({'error': 'Name, email, and department are required'}), 400

    try:
        eng_id = query_db(
            "INSERT INTO Engineer (Name, Email, DepartmentID, CurrentWorkload, MaxWorkload) VALUES (%s, %s, %s, 0, %s)",
            (name, email, int(dept_id), int(max_workload))
        )
        for sid in skill_ids:
            query_db("INSERT INTO EngineerSkill (EngineerID, SkillID) VALUES (%s, %s)", (eng_id, int(sid)))
        return jsonify({'success': True, 'engineer_id': eng_id})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ─────────────────────────────────────────────
# SUBMIT REVIEW (Simulated LLM Processing)
# ─────────────────────────────────────────────

@app.route('/api/submit-review', methods=['POST'])
def submit_review():
    """Admin submits a review -> Real Gemini LLM analyzes -> creates Bug (Pending Assignment)."""
    data = request.json
    review_text = data.get('content', '')
    rating = int(data.get('rating', 2))
    platform_id = int(data.get('platform_id', 1))
    reviewer_name = data.get('reviewer_name', 'TestUser')
    
    if not review_text or len(review_text) < 5:
        return jsonify({'error': 'Review text too short'}), 400
    
    # -- STEP 1: Real LLM Analysis using Gemini 2.5 Flash --
    try:
        client = genai.Client(api_key=GEMINI_API_KEY)
        
        prompt = f"""
        Analyze this app review for a music streaming app.
        Review: "{review_text}"
        User Rating: {rating} stars out of 5.
        
        CRITICAL RULE: Focus STRICTLY on the Review TEXT to determine sentiment, category, priority, and is_bug. DO NOT assume a low star rating means a bug or negative sentiment if the text is clearly positive (e.g., users often mistakenly give 2 stars but say "App is phenomenal").
        
        You must classify this review into exactly one option for each field.
        IMPORTANT: 'is_bug' should be true ONLY if the text explicitly describes a defect, crash, or failing feature.
        
        Sentiment Options: "Positive", "Neutral", "Negative", "Frustrated", "Angry"
        Category Options: "UI/UX", "Audio Playback", "App Crash", "Connectivity", "Account/Billing", "General"
        Priority Options: "Critical", "High", "Medium", "Low"
        Sentiment Score: A float from 0.0 to 1.0 representing how negative it is (1.0 = extremely negative, 0.0 = completely positive).
        
        Respond ONLY with a valid JSON object matching this schema:
        {{
            "is_bug": Boolean,
            "sentiment": "String",
            "category": "String",
            "priority": "String",
            "sentiment_score": Float
        }}
        """
        
        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
            )
        )
        
        import json
        llm_data = json.loads(response.text)
        
        # Safe Mapping
        is_bug = llm_data.get('is_bug', True)
        sentiment_name = llm_data.get('sentiment', 'Negative')
        category_name = llm_data.get('category', 'UI/UX')
        priority_name = llm_data.get('priority', 'Medium')
        sentiment_score = float(llm_data.get('sentiment_score', 0.5))
        
        # ID Maps (defaults if not found)
        sent_map = {'Positive': 1, 'Neutral': 3, 'Negative': 2, 'Frustrated': 4, 'Angry': 5}
        cat_map = {'UI/UX': 1, 'Performance': 2, 'Crash': 3, 'Security': 4, 'Functionality': 5, 'Data Loss': 6, 'General': 1}
        # In sample data Category map points to: 1: UI/UX, 2: Performance, 3: Crash, 4: Security, 5: Functionality, 6: Data Loss.
        prio_map = {'Critical': 1, 'High': 2, 'Medium': 3, 'Low': 4}
        
        sentiment_id = sent_map.get(sentiment_name, 2)
        category_id = cat_map.get(category_name, 1)
        priority_id = prio_map.get(priority_name, 3)
        
    except Exception as e:
        print("LLM Error:", str(e))
        # Fallback to defaults if LLM fails
        is_bug = True
        sentiment_id, sentiment_name = 2, 'Negative'
        category_id, category_name = 1, 'UI/UX'
        priority_id, priority_name = 3, 'Medium'
        sentiment_score = 0.5

    try:
        # -- STEP 2: Insert into database --
        user_id = query_db(
            "INSERT INTO User (Name, Email) VALUES (%s, %s)",
            (reviewer_name, f"{reviewer_name.lower().replace(' ','.')}@review.test")
        )
        
        now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        review_id = query_db(
            "INSERT INTO Review (UserID, AppID, Content, Rating, Timestamp, SentimentScore, PlatformID) VALUES (%s, 1, %s, %s, %s, %s, %s)",
            (user_id, review_text, rating, now, sentiment_score, platform_id)
        )
        
        query_db("INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES (%s, %s)", (review_id, sentiment_id))
        
        bug_id = None
        if is_bug:
            bug_title = review_text[:40] + '...' if len(review_text) > 40 else review_text
            # StatusID 1 = Open
            bug_id = query_db(
                "INSERT INTO Bug (Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (%s, 'LLM Auto-Extracted Bug from Review.', %s, 'Review', %s, %s, %s, 1)",
                (bug_title, now, review_id, category_id, priority_id)
            )
            # We NO LONGER assign it. The admin will do it from the triage dashboard!
        
        return jsonify({
            'success': True,
            'analysis': {
                'is_bug': is_bug,
                'sentiment': sentiment_name,
                'sentiment_score': sentiment_score,
                'category': category_name,
                'priority': priority_name,
                'bug_id': bug_id,
                'message': 'Logged as Bug pending Assignment.' if is_bug else 'Review logged. Not classified as a Bug.'
            }
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/engineer')
def engineer_dashboard():
    if 'user' not in session or session.get('role') != 'engineer':
        return redirect('/')
    return render_template('engineer.html', engineer_name=session.get('name', 'Engineer'))

# ─────────────────────────────────────────────
# ENGINEER API ENDPOINTS
# ─────────────────────────────────────────────

@app.route('/api/engineer/stats')
def engineer_stats():
    """Personal KPI stats for logged-in engineer."""
    eid = session.get('engineer_id')
    if not eid:
        return jsonify({'error': 'Not an engineer'}), 403
    
    stats = {}
    stats['total_assigned'] = query_db(
        "SELECT COUNT(*) as c FROM BugAssignment WHERE EngineerID = %s", (eid,), fetchone=True
    )['c']
    stats['open_tasks'] = query_db(
        "SELECT COUNT(*) as c FROM BugAssignment WHERE EngineerID = %s AND CompletedAt IS NULL", (eid,), fetchone=True
    )['c']
    stats['completed'] = query_db(
        "SELECT COUNT(*) as c FROM BugAssignment WHERE EngineerID = %s AND CompletedAt IS NOT NULL", (eid,), fetchone=True
    )['c']
    stats['overdue'] = query_db(
        "SELECT COUNT(*) as c FROM BugAssignment WHERE EngineerID = %s AND CompletedAt IS NULL AND DueBy < NOW()", (eid,), fetchone=True
    )['c']
    
    eng = query_db(
        "SELECT CurrentWorkload, MaxWorkload FROM Engineer WHERE EngineerID = %s", (eid,), fetchone=True
    )
    stats['current_workload'] = eng['CurrentWorkload']
    stats['max_workload'] = eng['MaxWorkload']
    
    penalties = query_db(
        "SELECT Amount FROM Penalty p JOIN BugAssignment ba ON p.BugID = ba.BugID WHERE ba.EngineerID = %s",
        (eid,)
    )
    
    tot_penalty = 0.0
    tot_bonus = 0.0
    for p in penalties:
        amt = float(p['Amount'])
        if amt > 0:
            tot_penalty += amt
        else:
            tot_bonus += abs(amt)
            
    stats['total_penalty'] = tot_penalty
    stats['total_bonus'] = tot_bonus
    stats['net_impact'] = tot_penalty - tot_bonus
    
    return jsonify(stats)


@app.route('/api/engineer/tasks')
def engineer_tasks():
    """Query 5: All assigned bug tasks for logged-in engineer, sorted by urgency."""
    eid = session.get('engineer_id')
    if not eid:
        return jsonify({'error': 'Not an engineer'}), 403
    
    sql = """
        SELECT 
            b.BugID,
            b.Title,
            p.PriorityLevel,
            bc.CategoryName,
            s.StatusName,
            ba.AssignedAt,
            ba.DueBy,
            ba.CompletedAt,
            ba.AssignmentID,
            TIMESTAMPDIFF(HOUR, NOW(), ba.DueBy) AS HoursUntilDeadline,
            CASE 
                WHEN ba.CompletedAt IS NOT NULL THEN 'COMPLETED'
                WHEN TIMESTAMPDIFF(HOUR, NOW(), ba.DueBy) < 0 THEN 'OVERDUE'
                WHEN TIMESTAMPDIFF(HOUR, NOW(), ba.DueBy) < 4 THEN 'URGENT'
                ELSE 'ON TRACK'
            END as SlaStatus
        FROM BugAssignment ba
        JOIN Bug b ON ba.BugID = b.BugID
        JOIN Priority p ON b.PriorityID = p.PriorityID
        LEFT JOIN BugCategory bc ON b.CategoryID = bc.CategoryID
        JOIN Status s ON b.StatusID = s.StatusID
        WHERE ba.EngineerID = %s
        ORDER BY 
            CASE WHEN ba.CompletedAt IS NOT NULL THEN 1 ELSE 0 END ASC,
            ba.DueBy ASC
    """
    return jsonify(query_db(sql, (eid,)))


@app.route('/api/engineer/penalties')
def engineer_penalties():
    """Personal penalty track record for logged-in engineer."""
    eid = session.get('engineer_id')
    if not eid:
        return jsonify({'error': 'Not an engineer'}), 403
    
    sql = """
        SELECT 
            p.PenaltyID,
            b.BugID,
            b.Title as BugTitle,
            p.Amount,
            p.Reason,
            p.CreatedAt,
            pr.PriorityLevel
        FROM Penalty p
        JOIN Bug b ON p.BugID = b.BugID
        JOIN BugAssignment ba ON p.BugID = ba.BugID AND ba.EngineerID = %s
        JOIN Priority pr ON b.PriorityID = pr.PriorityID
        ORDER BY p.CreatedAt DESC
    """
    return jsonify(query_db(sql, (eid,)))


@app.route('/api/engineer/resolve', methods=['POST'])
def resolve_bug():
    """Engineer marks a bug as resolved, applying SLA Penalties or Bonuses."""
    eid = session.get('engineer_id')
    if not eid:
        return jsonify({'error': 'Not an engineer'}), 403
    
    data = request.json
    assignment_id = data.get('assignment_id')
    
    try:
        ba_details = query_db(
            "SELECT b.BugID, ba.DueBy, p.PriorityLevel "
            "FROM BugAssignment ba "
            "JOIN Bug b ON ba.BugID = b.BugID "
            "JOIN Priority p ON b.PriorityID = p.PriorityID "
            "WHERE ba.AssignmentID = %s", (assignment_id,), fetchone=True
        )
        
        if ba_details:
            bug_id = ba_details['BugID']
            due_by = ba_details['DueBy']
            priority = ba_details['PriorityLevel']
            
            # Mark completion time
            now = datetime.now()
            
            # Calculate penalty / bonus
            if now > due_by:
                # LATE Penalty
                amount = 50.0 if priority == 'Critical' else (20.0 if priority == 'High' else 10.0)
                reason = f"Late Resolution Penalty ({priority})"
            else:
                # EARLY Bonus
                amount = -30.0 if priority == 'Critical' else (-20.0 if priority == 'High' else -10.0)
                reason = f"Early Resolution Bonus ({priority})"
            
            slaid_map = {'Critical': 1, 'High': 2, 'Medium': 3, 'Low': 4}
            slaid = slaid_map.get(priority, 3)
            
            # Insert the financial record
            query_db(
                "INSERT INTO Penalty (BugID, SLAID, Amount, Reason, CreatedAt) VALUES (%s, %s, %s, %s, %s)",
                (bug_id, slaid, amount, reason, now.strftime('%Y-%m-%d %H:%M:%S'))
            )
            
            query_db("UPDATE Bug SET StatusID = 4 WHERE BugID = %s", (bug_id,))
            query_db("UPDATE Engineer SET CurrentWorkload = GREATEST(CurrentWorkload - 1, 0) WHERE EngineerID = %s", (eid,))

        query_db(
            "UPDATE BugAssignment SET CompletedAt = NOW() WHERE AssignmentID = %s AND EngineerID = %s",
            (assignment_id, eid)
        )
        
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True, port=5000)
