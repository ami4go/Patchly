# 🐛 Bug Buster: End-to-End Software Reliability Management System

## Complete DBMS Project Development Plan

---

## 📌 Project Vision

**Bug Buster** is a comprehensive software reliability management system that tracks the complete lifecycle of bugs — from user feedback on app stores to resolution by engineering teams, all the way through releases and quality monitoring.

> **What makes this standout?**  
> This isn't just a bug tracker. It's a **complete operations backend** that demonstrates mastery of:
> - Complex entity relationships
> - Multi-level constraints
> - Intelligent business logic via triggers
> - Real-world transaction scenarios with conflicts

---

## 🎯 Why This Project Stands Out in DBMS Context

| DBMS Concept | How Bug Buster Demonstrates It |
|--------------|-------------------------------|
| **Entity Relationships** | 25+ entities with 1:1, 1:N, M:N relationships across 5 modules |
| **Normalization** | All tables in 3NF/BCNF with no redundancy |
| **Integrity Constraints** | CHECK, FOREIGN KEY, UNIQUE, NOT NULL, ENUM types |
| **Complex Queries** | Nested subqueries, JOINs across 4+ tables, aggregations, GROUP BY, HAVING |
| **Triggers** | 5 meaningful triggers with business logic (auto-escalation, workload limits) |
| **Transactions** | Multi-step workflows with ACID properties + conflict scenarios |
| **Indexing** | Strategic indexes on frequently queried columns |

---

## 🗂️ Complete Entity Overview (25+ Entities)

### Module 1: Feedback & Review Intelligence
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    User     │───▶│   Review    │───▶│ FeedbackTag │
└─────────────┘    └─────────────┘    └─────────────┘
                          │
                          ▼
                   ┌─────────────┐    ┌─────────────┐
                   │  Sentiment  │    │  Platform   │
                   └─────────────┘    └─────────────┘
```
**Entities:** `User`, `App`, `Review`, `FeedbackTag`, `Sentiment`, `Platform`

### Module 2: Bug Lifecycle Management
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Review    │───▶│     Bug     │───▶│ BugCategory │
└─────────────┘    └─────────────┘    └─────────────┘
                          │
            ┌─────────────┼─────────────┐
            ▼             ▼             ▼
     ┌──────────┐  ┌──────────┐  ┌─────────────┐
     │ Priority │  │  Status  │  │ DuplicateBug│
     └──────────┘  └──────────┘  └─────────────┘
```
**Entities:** `Bug`, `BugCategory`, `Priority`, `Status`, `BugSource`, `DuplicateBug`

### Module 3: Team & Engineer Workload
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ Department  │───▶│  Engineer   │───▶│EngineerSkill│
└─────────────┘    └─────────────┘    └─────────────┘
                          │
            ┌─────────────┼─────────────┐
            ▼             ▼             ▼
     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ Workload │  │  Shift   │  │  Leave   │
     └──────────┘  └──────────┘  └──────────┘
```
**Entities:** `Department`, `Engineer`, `Skill`, `EngineerSkill`, `BugAssignment`, `Workload`, `Shift`, `Leave`

### Module 4: Release & Version Control
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ AppVersion  │───▶│   Release   │───▶│ReleaseBugFix│
└─────────────┘    └─────────────┘    └─────────────┘
                          │
                   ┌──────┴──────┐
                   ▼             ▼
            ┌──────────┐  ┌──────────┐
            │Deployment│  │ Rollback │
            └──────────┘  └──────────┘
```
**Entities:** `AppVersion`, `Release`, `ReleaseBugFix`, `Deployment`, `Rollback`

### Module 5: Quality & SLA Monitoring
```
┌───────────────┐    ┌─────────────┐    ┌─────────────┐
│ResolutionTime │───▶│     SLA     │───▶│   Penalty   │
└───────────────┘    └─────────────┘    └─────────────┘
                            │
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
       ┌──────────┐  ┌──────────┐  ┌──────────┐
       │  Impact  │  │ Downtime │  │  Refund  │
       └──────────┘  └──────────┘  └──────────┘
```
**Entities:** `ResolutionTime`, `SLA`, `Penalty`, `CustomerImpact`, `Downtime`, `Refund`

---

# 📅 Stage-by-Stage Development Plan

---

## 📋 TASK 1: Project Scope (Due: Jan 19)

### What to Submit
A clear document defining the **business requirements** and **scope** of Bug Buster.

### Deliverables

#### 1. Business Problem Statement
```
"Software companies receive thousands of user reviews daily across multiple 
platforms. Currently, there's no unified system to:
- Extract actionable bugs from feedback
- Route bugs intelligently to appropriate engineers  
- Track resolution with SLA enforcement
- Correlate releases with bug fixes and rating changes

Bug Buster solves this by providing an end-to-end reliability management system."
```

#### 2. System Modules Overview
| Module | Purpose | Key Entities |
|--------|---------|--------------|
| Feedback Intelligence | Collect & analyze user feedback | User, Review, Sentiment |
| Bug Lifecycle | Track bugs from creation to closure | Bug, Priority, Status |
| Team Workload | Manage engineer assignments | Engineer, Department, Workload |
| Release Control | Track versions and deployments | Release, AppVersion, Rollback |
| Quality Monitoring | Enforce SLAs and penalties | SLA, Penalty, Downtime |

#### 3. User Roles
| Role | Actions |
|------|---------|
| **Admin** | Manage departments, engineers, SLAs |
| **Manager** | View dashboards, assign bugs, approve releases |
| **Engineer** | View assigned bugs, update status, log fixes |
| **QA Tester** | Report internal bugs, validate fixes |

#### 4. Key Features List
- Multi-platform feedback aggregation (PlayStore, AppStore, Email)
- Intelligent bug routing based on skills & workload
- Duplicate bug detection and merging
- SLA violation tracking with auto-penalties
- Release-to-bug correlation analysis
- Rating impact analysis post-release

### 💡 What Makes This Standout
- **Clear business justification** — solves a real industry problem
- **Well-defined scope boundaries** — not too narrow, not too broad
- **Multiple user roles** — shows understanding of access control needs

---

## 📐 TASK 2: Conceptual → Relational Model (Due: Jan 23)

### What to Submit
ER diagram + conversion to Relational Schema with proper mapping.

### Deliverables

#### 1. Complete ER Diagram
Create using tools like **draw.io**, **Lucidchart**, or **dbdiagram.io**

**Key Relationships to Show:**

| Relationship | Type | Description |
|--------------|------|-------------|
| User → Review | 1:N | One user writes many reviews |
| Review → Bug | 1:1 or 1:N | One review may generate one/many bugs |
| Bug → BugAssignment | 1:N | Bug can be reassigned multiple times |
| Engineer → BugAssignment | 1:N | Engineer handles many assignments |
| Engineer → Skill | M:N | Engineers have multiple skills (junction table) |
| Release → ReleaseBugFix | 1:N | One release fixes many bugs |
| Bug → DuplicateBug | 1:N (self-ref) | Bug can have duplicates |
| Department → Engineer | 1:N | Department has many engineers |

#### 2. Relational Schema Conversion

```sql
-- Example conversions showing different relationship types:

-- 1:N Relationship (User → Review)
User(user_id PK, name, email, platform_id FK)
Review(review_id PK, user_id FK, app_id FK, rating, content, created_at)

-- M:N Relationship (Engineer ↔ Skill) → Junction Table
Engineer(engineer_id PK, name, dept_id FK, hire_date)
Skill(skill_id PK, skill_name, category)
EngineerSkill(engineer_id PK/FK, skill_id PK/FK, proficiency_level)

-- Self-Referencing (DuplicateBug)
Bug(bug_id PK, title, description, priority_id FK, status_id FK)
DuplicateBug(duplicate_id PK, original_bug_id FK, duplicate_bug_id FK)

-- Weak Entity (BugAssignment depends on Bug)
BugAssignment(assignment_id PK, bug_id FK, engineer_id FK, assigned_at, completed_at)
```

#### 3. Normalization Proof
Document that all tables are in **3NF/BCNF**:
- No repeating groups (1NF ✓)
- No partial dependencies (2NF ✓)
- No transitive dependencies (3NF ✓)

### 💡 What Makes This Standout
- **25+ entities** with diverse relationship types
- **Self-referencing relationship** (DuplicateBug)
- **Junction tables** properly implemented
- **Clear normalization documentation**

---

## 🗄️ TASK 3: Schema Creation & Data Population (Due: Jan 31)

### What to Submit
Complete SQL DDL scripts + populated data.

### Deliverables

#### 1. Database Schema with Constraints

```sql
-- Core Tables with ALL constraint types demonstrated

CREATE TABLE Department (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(100) NOT NULL UNIQUE,
    manager_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Engineer (
    engineer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    dept_id INT NOT NULL,
    current_workload INT DEFAULT 0 CHECK (current_workload >= 0 AND current_workload <= 10),
    hire_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id) ON DELETE RESTRICT
);

CREATE TABLE Bug (
    bug_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'MEDIUM',
    status ENUM('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'REOPENED') DEFAULT 'OPEN',
    source ENUM('REVIEW', 'INTERNAL', 'TESTER') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    review_count INT DEFAULT 1,
    CHECK (resolved_at IS NULL OR resolved_at >= created_at)
);

CREATE TABLE SLA (
    sla_id INT PRIMARY KEY AUTO_INCREMENT,
    priority ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') UNIQUE,
    max_resolution_hours INT NOT NULL CHECK (max_resolution_hours > 0),
    penalty_amount DECIMAL(10,2) DEFAULT 0.00
);
```

#### 2. Strategic Indexes

```sql
-- Indexes for frequently queried columns
CREATE INDEX idx_bug_status ON Bug(status);
CREATE INDEX idx_bug_priority ON Bug(priority);
CREATE INDEX idx_bug_created ON Bug(created_at);
CREATE INDEX idx_assignment_engineer ON BugAssignment(engineer_id);
CREATE INDEX idx_review_app ON Review(app_id);
CREATE INDEX idx_engineer_dept ON Engineer(dept_id);

-- Composite index for common query patterns
CREATE INDEX idx_bug_status_priority ON Bug(status, priority);
```

#### 3. Simulated Data (100+ records across all tables)

```sql
-- Sample data insertion
INSERT INTO Department (dept_name) VALUES 
('Backend'), ('Frontend'), ('Mobile'), ('DevOps'), ('QA');

INSERT INTO Engineer (name, email, dept_id, hire_date) VALUES
('Rahul Sharma', 'rahul@bugbuster.com', 1, '2023-01-15'),
('Priya Patel', 'priya@bugbuster.com', 2, '2022-06-20'),
-- ... (50+ engineers)

INSERT INTO Bug (title, description, priority, status, source) VALUES
('App crashes on login', 'Users report crash when entering OTP', 'CRITICAL', 'OPEN', 'REVIEW'),
('Slow loading dashboard', 'Dashboard takes 10s to load', 'HIGH', 'IN_PROGRESS', 'INTERNAL'),
-- ... (100+ bugs)
```

### 💡 What Makes This Standout
- **Every constraint type used**: PRIMARY KEY, FOREIGN KEY, UNIQUE, NOT NULL, CHECK, DEFAULT, ENUM
- **ON DELETE/UPDATE actions** specified
- **Meaningful indexes** with justification
- **Realistic data** that reflects actual patterns

---

## 📊 TASK 4: SQL Queries (Due: Feb 19)

### What to Submit
15 SQL queries with varying complexity + output screenshots.

### Query Categories & Examples

#### Category 1: Basic Queries (3 queries)

```sql
-- Q1: List all open bugs
SELECT bug_id, title, priority, created_at 
FROM Bug 
WHERE status = 'OPEN' 
ORDER BY priority DESC, created_at ASC;

-- Q2: Count bugs by status
SELECT status, COUNT(*) as bug_count 
FROM Bug 
GROUP BY status;

-- Q3: Find engineers in a specific department
SELECT e.name, e.email, d.dept_name 
FROM Engineer e 
JOIN Department d ON e.dept_id = d.dept_id 
WHERE d.dept_name = 'Backend';
```

#### Category 2: Intermediate Queries with JOINs (5 queries)

```sql
-- Q4: Bugs with their assigned engineers
SELECT b.bug_id, b.title, b.priority, e.name AS assigned_to, ba.assigned_at
FROM Bug b
LEFT JOIN BugAssignment ba ON b.bug_id = ba.bug_id AND ba.is_current = TRUE
LEFT JOIN Engineer e ON ba.engineer_id = e.engineer_id
ORDER BY b.priority DESC;

-- Q5: Average resolution time by department
SELECT d.dept_name, 
       AVG(TIMESTAMPDIFF(HOUR, b.created_at, b.resolved_at)) AS avg_hours
FROM Bug b
JOIN BugAssignment ba ON b.bug_id = ba.bug_id
JOIN Engineer e ON ba.engineer_id = e.engineer_id
JOIN Department d ON e.dept_id = d.dept_id
WHERE b.status = 'RESOLVED'
GROUP BY d.dept_id;

-- Q6: Reviews with negative sentiment leading to bugs
SELECT r.review_id, r.content, r.rating, b.bug_id, b.title
FROM Review r
JOIN Bug b ON r.review_id = b.source_review_id
JOIN Sentiment s ON r.sentiment_id = s.sentiment_id
WHERE s.sentiment_type = 'NEGATIVE';

-- Q7: Engineers with their skill sets
SELECT e.name, GROUP_CONCAT(s.skill_name SEPARATOR ', ') AS skills
FROM Engineer e
JOIN EngineerSkill es ON e.engineer_id = es.engineer_id
JOIN Skill s ON es.skill_id = s.skill_id
GROUP BY e.engineer_id;

-- Q8: Release with count of bugs fixed
SELECT r.version, r.release_date, COUNT(rbf.bug_id) AS bugs_fixed
FROM AppRelease r
LEFT JOIN ReleaseBugFix rbf ON r.release_id = rbf.release_id
GROUP BY r.release_id
ORDER BY r.release_date DESC;
```

#### Category 3: Advanced Queries with Subqueries & Analytics (5 queries)

```sql
-- Q9: Engineers who haven't exceeded workload limit (Subquery)
SELECT name, current_workload
FROM Engineer
WHERE engineer_id NOT IN (
    SELECT engineer_id FROM BugAssignment 
    WHERE is_current = TRUE 
    GROUP BY engineer_id 
    HAVING COUNT(*) >= 5
);

-- Q10: Bugs that violated SLA (Complex JOIN + Calculation)
SELECT b.bug_id, b.title, b.priority, b.created_at, s.max_resolution_hours,
       TIMESTAMPDIFF(HOUR, b.created_at, NOW()) AS hours_open,
       CASE 
           WHEN TIMESTAMPDIFF(HOUR, b.created_at, NOW()) > s.max_resolution_hours 
           THEN 'VIOLATED' 
           ELSE 'OK' 
       END AS sla_status
FROM Bug b
JOIN SLA s ON b.priority = s.priority
WHERE b.status NOT IN ('RESOLVED', 'CLOSED');

-- Q11: Top 5 most reported bug patterns (GROUP BY + ORDER + LIMIT)
SELECT bc.category_name, COUNT(*) AS occurrence
FROM Bug b
JOIN BugCategory bc ON b.category_id = bc.category_id
GROUP BY bc.category_id
ORDER BY occurrence DESC
LIMIT 5;

-- Q12: Duplicate bug chains (Self-Join)
SELECT original.bug_id AS original_bug, 
       original.title AS original_title,
       dupe.bug_id AS duplicate_bug,
       dupe.title AS duplicate_title
FROM DuplicateBug db
JOIN Bug original ON db.original_bug_id = original.bug_id
JOIN Bug dupe ON db.duplicate_bug_id = dupe.bug_id;

-- Q13: Month-over-month bug creation trend (Date Functions + Aggregation)
SELECT 
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    COUNT(*) AS bugs_created,
    SUM(CASE WHEN priority = 'CRITICAL' THEN 1 ELSE 0 END) AS critical_count
FROM Bug
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
ORDER BY month DESC;
```

#### Category 4: Complex Analytical Queries (2 queries)

```sql
-- Q14: Engineer performance ranking (Window Function)
SELECT 
    e.name,
    d.dept_name,
    COUNT(ba.bug_id) AS bugs_resolved,
    AVG(TIMESTAMPDIFF(HOUR, ba.assigned_at, ba.completed_at)) AS avg_resolution_hours,
    RANK() OVER (PARTITION BY d.dept_id ORDER BY COUNT(ba.bug_id) DESC) AS dept_rank
FROM Engineer e
JOIN Department d ON e.dept_id = d.dept_id
LEFT JOIN BugAssignment ba ON e.engineer_id = ba.engineer_id AND ba.completed_at IS NOT NULL
GROUP BY e.engineer_id;

-- Q15: Correlation between releases and rating changes (Complex Multi-table)
SELECT 
    r.version,
    r.release_date,
    COUNT(DISTINCT rbf.bug_id) AS bugs_fixed,
    AVG(CASE WHEN rev.created_at < r.release_date THEN rev.rating END) AS avg_rating_before,
    AVG(CASE WHEN rev.created_at >= r.release_date THEN rev.rating END) AS avg_rating_after,
    AVG(CASE WHEN rev.created_at >= r.release_date THEN rev.rating END) - 
    AVG(CASE WHEN rev.created_at < r.release_date THEN rev.rating END) AS rating_change
FROM AppRelease r
LEFT JOIN ReleaseBugFix rbf ON r.release_id = rbf.release_id
CROSS JOIN Review rev
WHERE rev.created_at BETWEEN DATE_SUB(r.release_date, INTERVAL 30 DAY) 
                         AND DATE_ADD(r.release_date, INTERVAL 30 DAY)
GROUP BY r.release_id
ORDER BY r.release_date DESC;
```

### 💡 What Makes This Standout
- **Varying complexity** from basic SELECT to window functions
- **Real business value** — each query answers a genuine question
- **Advanced SQL features**: CASE, window functions, self-joins, date arithmetic
- **Clear categorization** showing progression

---

## 💻 TASK 5: Application + Triggers (Due: March 19)

### What to Submit
Embedded SQL application + 2 meaningful triggers.

### Deliverables

#### 1. Application Features (Python + MySQL Connector)

**Feature 1: Submit Review & Auto-Create Bug**
```python
def submit_review_and_create_bug(user_id, app_id, rating, content, sentiment):
    """
    Transaction: Submit review → Analyze → Create bug if negative → Assign engineer
    """
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    
    try:
        conn.start_transaction()
        
        # Step 1: Insert review
        cursor.execute("""
            INSERT INTO Review (user_id, app_id, rating, content, sentiment_id)
            VALUES (%s, %s, %s, %s, %s)
        """, (user_id, app_id, rating, content, sentiment))
        review_id = cursor.lastrowid
        
        # Step 2: If negative sentiment, create bug
        if sentiment == 'NEGATIVE' or rating <= 2:
            cursor.execute("""
                INSERT INTO Bug (title, description, source, source_review_id, priority)
                VALUES (%s, %s, 'REVIEW', %s, %s)
            """, (f"Issue from Review #{review_id}", content, review_id, 
                  'HIGH' if rating == 1 else 'MEDIUM'))
            bug_id = cursor.lastrowid
            
            # Step 3: Auto-assign to available engineer
            cursor.execute("""
                SELECT engineer_id FROM Engineer 
                WHERE current_workload < 5 AND is_active = TRUE
                ORDER BY current_workload ASC LIMIT 1
            """)
            engineer = cursor.fetchone()
            
            if engineer:
                cursor.execute("""
                    INSERT INTO BugAssignment (bug_id, engineer_id, is_current)
                    VALUES (%s, %s, TRUE)
                """, (bug_id, engineer[0]))
        
        conn.commit()
        return {"success": True, "review_id": review_id}
        
    except Exception as e:
        conn.rollback()
        return {"success": False, "error": str(e)}
    finally:
        cursor.close()
        conn.close()
```

**Feature 2: Release Deployment with Bug Closure**
```python
def deploy_release(version, bug_ids_to_fix):
    """
    Transaction: Create release → Mark bugs as fixed → Update ratings
    """
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    
    try:
        conn.start_transaction()
        
        # Create release
        cursor.execute("""
            INSERT INTO AppRelease (version, release_date, status)
            VALUES (%s, NOW(), 'DEPLOYED')
        """, (version,))
        release_id = cursor.lastrowid
        
        # Link bugs to release and close them
        for bug_id in bug_ids_to_fix:
            cursor.execute("""
                INSERT INTO ReleaseBugFix (release_id, bug_id)
                VALUES (%s, %s)
            """, (release_id, bug_id))
            
            cursor.execute("""
                UPDATE Bug SET status = 'CLOSED', resolved_at = NOW()
                WHERE bug_id = %s
            """, (bug_id,))
        
        conn.commit()
        return {"success": True, "release_id": release_id}
        
    except Exception as e:
        conn.rollback()
        return {"success": False, "error": str(e)}
```

#### 2. Triggers (5 Meaningful Triggers)

```sql
-- TRIGGER 1: Auto-escalate bug to CRITICAL if 10+ reviews mention it
DELIMITER //
CREATE TRIGGER trg_auto_escalate_critical
AFTER INSERT ON Review
FOR EACH ROW
BEGIN
    DECLARE review_count INT;
    
    -- Count reviews with similar content (simplified pattern match)
    SELECT COUNT(*) INTO review_count
    FROM Review 
    WHERE app_id = NEW.app_id 
      AND rating <= 2
      AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY);
    
    -- If threshold reached, escalate related open bugs
    IF review_count >= 10 THEN
        UPDATE Bug 
        SET priority = 'CRITICAL'
        WHERE source = 'REVIEW' 
          AND status = 'OPEN'
          AND app_id = NEW.app_id;
    END IF;
END //
DELIMITER ;

-- TRIGGER 2: Prevent assignment if engineer workload exceeds limit
DELIMITER //
CREATE TRIGGER trg_check_workload_before_assign
BEFORE INSERT ON BugAssignment
FOR EACH ROW
BEGIN
    DECLARE current_load INT;
    
    SELECT current_workload INTO current_load
    FROM Engineer WHERE engineer_id = NEW.engineer_id;
    
    IF current_load >= 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Engineer workload limit exceeded. Cannot assign more bugs.';
    END IF;
END //
DELIMITER ;

-- TRIGGER 3: Update engineer workload on assignment
DELIMITER //
CREATE TRIGGER trg_update_workload_on_assign
AFTER INSERT ON BugAssignment
FOR EACH ROW
BEGIN
    UPDATE Engineer 
    SET current_workload = current_workload + 1
    WHERE engineer_id = NEW.engineer_id;
END //
DELIMITER ;

-- TRIGGER 4: Log SLA violation penalty
DELIMITER //
CREATE TRIGGER trg_log_sla_violation
BEFORE UPDATE ON Bug
FOR EACH ROW
BEGIN
    DECLARE sla_hours INT;
    DECLARE hours_taken INT;
    
    IF NEW.status IN ('RESOLVED', 'CLOSED') AND OLD.status NOT IN ('RESOLVED', 'CLOSED') THEN
        SELECT max_resolution_hours INTO sla_hours
        FROM SLA WHERE priority = OLD.priority;
        
        SET hours_taken = TIMESTAMPDIFF(HOUR, OLD.created_at, NOW());
        
        IF hours_taken > sla_hours THEN
            INSERT INTO Penalty (bug_id, violation_type, hours_exceeded, created_at)
            VALUES (NEW.bug_id, 'SLA_BREACH', hours_taken - sla_hours, NOW());
        END IF;
    END IF;
END //
DELIMITER ;

-- TRIGGER 5: Reopen bugs on rollback
DELIMITER //
CREATE TRIGGER trg_reopen_bugs_on_rollback
AFTER INSERT ON Rollback
FOR EACH ROW
BEGIN
    UPDATE Bug b
    JOIN ReleaseBugFix rbf ON b.bug_id = rbf.bug_id
    SET b.status = 'REOPENED', b.resolved_at = NULL
    WHERE rbf.release_id = NEW.release_id;
END //
DELIMITER ;
```

### 💡 What Makes This Standout
- **Business logic in database layer** — proper use of triggers for enforcement
- **Error handling with SIGNAL** — demonstrates constraint enforcement
- **Cascading effects** — triggers that update related data
- **Prevents invalid states** — workload limit can't be bypassed

---

## 🔄 TASK 6: Transactions (Due: April 5)

### What to Submit
Transaction workflows + conflict scenarios + effect analysis.

### Deliverables

#### 1. Normal Transaction Workflows

**Transaction 1: Complete Bug Resolution Flow**
```sql
START TRANSACTION;

-- Step 1: Engineer marks bug as resolved
UPDATE Bug SET status = 'RESOLVED', resolved_at = NOW()
WHERE bug_id = 101;

-- Step 2: Update assignment completion time
UPDATE BugAssignment SET completed_at = NOW()
WHERE bug_id = 101 AND is_current = TRUE;

-- Step 3: Decrease engineer workload
UPDATE Engineer SET current_workload = current_workload - 1
WHERE engineer_id = (
    SELECT engineer_id FROM BugAssignment 
    WHERE bug_id = 101 AND is_current = TRUE
);

-- Step 4: Check for SLA compliance (query only)
SELECT 
    CASE 
        WHEN TIMESTAMPDIFF(HOUR, created_at, NOW()) > 48 
        THEN 'SLA VIOLATED' 
        ELSE 'SLA MET' 
    END AS compliance
FROM Bug WHERE bug_id = 101;

COMMIT;
```

**Transaction 2: Rollback Release**
```sql
START TRANSACTION;

-- Step 1: Create rollback record
INSERT INTO Rollback (release_id, reason, rolled_back_at)
VALUES (5, 'Critical bug discovered post-deployment', NOW());

-- Step 2: Revert release status
UPDATE AppRelease SET status = 'ROLLED_BACK' WHERE release_id = 5;

-- Step 3: Reopen all bugs fixed in this release
UPDATE Bug SET status = 'REOPENED', resolved_at = NULL
WHERE bug_id IN (
    SELECT bug_id FROM ReleaseBugFix WHERE release_id = 5
);

COMMIT;
```

#### 2. Conflicting Transaction Scenarios

**Conflict 1: Two Managers Assigning Same Engineer**

```sql
-- Session 1 (Manager A)
START TRANSACTION;
SELECT current_workload FROM Engineer WHERE engineer_id = 10 FOR UPDATE;
-- current_workload = 4

-- Session 2 (Manager B) - BLOCKED waiting for lock

-- Session 1 continues
INSERT INTO BugAssignment (bug_id, engineer_id) VALUES (201, 10);
UPDATE Engineer SET current_workload = 5 WHERE engineer_id = 10;
COMMIT;

-- Session 2 now proceeds
-- Sees current_workload = 5, trigger prevents assignment
```

**Conflict 2: Simultaneous Release and Bug Update**

```sql
-- Session 1: Creating release with bug 301
START TRANSACTION;
SELECT * FROM Bug WHERE bug_id = 301 FOR UPDATE;
INSERT INTO ReleaseBugFix VALUES (10, 301);
UPDATE Bug SET status = 'CLOSED' WHERE bug_id = 301;

-- Session 2: Engineer trying to update same bug
START TRANSACTION;
UPDATE Bug SET status = 'IN_PROGRESS' WHERE bug_id = 301;
-- BLOCKED until Session 1 commits

-- Session 1 commits
COMMIT;

-- Session 2: Now sees bug is CLOSED, update has no effect or fails
```

#### 3. Isolation Level Analysis

| Isolation Level | Behavior in Bug Buster |
|-----------------|----------------------|
| READ UNCOMMITTED | ❌ Could see uncommitted workload, causing over-assignment |
| READ COMMITTED | ⚠️ Non-repeatable reads possible for workload checks |
| REPEATABLE READ | ✅ Best for most operations, prevents phantom bugs |
| SERIALIZABLE | ⚠️ Too strict, causes unnecessary blocking |

**Recommended: REPEATABLE READ** (MySQL default)

### 💡 What Makes This Standout
- **Real conflict scenarios** — not artificial examples
- **Proper locking** with FOR UPDATE
- **Isolation level analysis** — shows deep understanding
- **Both success and failure paths** documented

---

## 🎨 UI Implementation (For All Demos)

### Recommended Tech Stack
| Layer | Technology | Reason |
|-------|------------|--------|
| Frontend | React/Next.js | Modern, component-based |
| Backend | Python Flask/FastAPI | Easy MySQL integration |
| Database | MySQL 8.0 | As required |
| Styling | Tailwind CSS | Fast development |

### Key UI Pages
1. **Dashboard** — Bug stats, SLA alerts, recent activities
2. **Bug Board** — Kanban-style bug tracking
3. **Engineer Workload** — Visual workload distribution
4. **Release Manager** — Version management
5. **Reports** — Analytics and trends

### UI Priority by Task
| Task | UI Needed |
|------|-----------|
| Task 1-3 | Basic forms for data entry |
| Task 4 | Query result display pages |
| Task 5 | Full CRUD interface |
| Task 6 | Transaction simulation panel |

---

## 📁 Project Structure

```
BugBuster/
├── docs/
│   ├── Task1_Scope.pdf
│   ├── Task2_ER_Diagram.pdf
│   ├── Task3_Schema.pdf
│   ├── Task4_Queries.pdf
│   ├── Task5_Application.pdf
│   └── Task6_Transactions.pdf
│
├── database/
│   ├── schema/
│   │   ├── 01_tables.sql
│   │   ├── 02_indexes.sql
│   │   └── 03_triggers.sql
│   ├── data/
│   │   └── seed_data.sql
│   └── queries/
│       └── all_queries.sql
│
├── backend/
│   ├── app.py
│   ├── db_connection.py
│   ├── transactions/
│   │   ├── review_workflow.py
│   │   └── release_workflow.py
│   └── routes/
│       ├── bugs.py
│       ├── engineers.py
│       └── releases.py
│
├── frontend/
│   ├── src/
│   │   ├── pages/
│   │   └── components/
│   └── package.json
│
└── README.md
```

---

## ✅ Checklist for Each Submission

### Task 1 (Jan 19) ✓
- [ ] Business problem statement
- [ ] Module descriptions
- [ ] Entity list (preliminary)
- [ ] User roles defined
- [ ] Feature scope defined

### Task 2 (Jan 23) ✓
- [ ] Complete ER diagram
- [ ] All relationship types identified
- [ ] Relational schema mapping
- [ ] Normalization proof

### Task 3 (Jan 31) ✓
- [ ] All CREATE TABLE statements
- [ ] Integrity constraints documented
- [ ] Indexes created with justification
- [ ] 100+ realistic records inserted

### Task 4 (Feb 19) ✓
- [ ] 15 queries written
- [ ] Queries categorized by complexity
- [ ] Output screenshots
- [ ] Business purpose documented

### Task 5 (March 19) ✓
- [ ] 2+ application workflows
- [ ] 5 triggers implemented
- [ ] UI for demonstration
- [ ] Error handling shown

### Task 6 (April 5) ✓
- [ ] Transaction workflows
- [ ] Conflict scenarios tested
- [ ] Isolation level analysis
- [ ] Effects documented

---

## 🏆 Summary: Why Bug Buster Wins

| Criteria | Bug Buster Strength |
|----------|-------------------|
| **Scale** | 25+ entities across 5 modules |
| **Relationships** | All types: 1:1, 1:N, M:N, self-referencing |
| **Constraints** | Every MySQL constraint type used |
| **Query Complexity** | From basic SELECT to window functions |
| **Triggers** | Business logic enforcement, not just logging |
| **Transactions** | Real workflow scenarios with conflicts |
| **Real-World Relevance** | Solves actual software industry problem |

---

> **Remember**: The instructors will ask "**Why did you design it this way?**"  
> Always be ready to justify your design decisions with DBMS concepts!

---

*Good luck with your project! 🚀*
