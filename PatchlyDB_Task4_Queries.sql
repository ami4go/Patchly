USE PatchlyDB;

-- ---------------------------------------------------------
-- 1. ADMIN DASHBOARD: View all engineers, their departments, skills, and current workload.
-- ---------------------------------------------------------
SELECT 
    e.EngineerID,
    e.Name AS EngineerName,
    d.DepartmentName,
    GROUP_CONCAT(DISTINCT s.SkillName ORDER BY s.SkillName SEPARATOR ', ') AS Skills,
    e.CurrentWorkload,
    e.MaxWorkload,
    CASE 
        WHEN e.CurrentWorkload >= e.MaxWorkload THEN 'AT CAPACITY'
        WHEN e.CurrentWorkload >= e.MaxWorkload * 0.8 THEN 'HEAVY'
        ELSE 'NORMAL'
    END AS WorkloadStatus
FROM Engineer e
JOIN Department d ON e.DepartmentID = d.DepartmentID
LEFT JOIN EngineerSkill es ON e.EngineerID = es.EngineerID
LEFT JOIN Skill s ON es.SkillID = s.SkillID
GROUP BY e.EngineerID, e.Name, d.DepartmentName, e.CurrentWorkload, e.MaxWorkload
ORDER BY e.CurrentWorkload DESC;

-- ---------------------------------------------------------
-- 2. ADMIN DASHBOARD: Total pending bugs by Spotify Platform (Apple Phone, Mac, Windows, Android)
-- ---------------------------------------------------------
SELECT 
    p.PlatformName,
    COUNT(b.BugID) AS TotalOpenBugs,
    SUM(CASE WHEN pr.PriorityLevel = 'Critical' THEN 1 ELSE 0 END) AS CriticalBugs
FROM Bug b
JOIN Status st ON b.StatusID = st.StatusID
JOIN Review r ON b.ReviewID = r.ReviewID
JOIN AppPlatform ap ON r.AppID = ap.AppID
JOIN Platform p ON ap.PlatformID = p.PlatformID
JOIN Priority pr ON b.PriorityID = pr.PriorityID
JOIN App a ON r.AppID = a.AppID
WHERE a.AppName = 'Spotify' 
AND st.StatusName NOT IN ('Resolved', 'Closed')
GROUP BY p.PlatformName
ORDER BY CriticalBugs DESC, TotalOpenBugs DESC;


-- ---------------------------------------------------------
-- 3. ADMIN DASHBOARD: SLA Breach Report & Total Penalties per Engineer
-- ---------------------------------------------------------
SELECT 
    e.Name,
    d.DepartmentName,
    COUNT(p.PenaltyID) AS TotalSlaBreaches,
    COALESCE(SUM(p.Amount), 0) AS TotalPenaltyCost
FROM Engineer e
JOIN Department d ON e.DepartmentID = d.DepartmentID
LEFT JOIN BugAssignment ba ON e.EngineerID = ba.EngineerID
LEFT JOIN Penalty p ON ba.BugID = p.BugID
GROUP BY e.Name, d.DepartmentName
HAVING TotalSlaBreaches > 0
ORDER BY TotalPenaltyCost DESC;


-- ---------------------------------------------------------
-- 4. DASHBOARD METRICS: Most common sentiments causing Bug Reports
-- ---------------------------------------------------------
SELECT 
    snt.SentimentType,
    COUNT(r.ReviewID) as ReviewCount,
    COUNT(b.BugID) as BugsGenerated,
    ROUND((COUNT(b.BugID) / COUNT(r.ReviewID) * 100), 2) as ConversionRatePerc
FROM Sentiment snt
JOIN ReviewSentiment rs ON snt.SentimentID = rs.SentimentID
JOIN Review r ON rs.ReviewID = r.ReviewID
LEFT JOIN Bug b ON r.ReviewID = b.ReviewID
GROUP BY snt.SentimentType
ORDER BY BugsGenerated DESC;


-- ---------------------------------------------------------
-- 5. ENGINEER DASHBOARD: Get my open assigned tasks, sorted by urgency (DueBy)
-- ---------------------------------------------------------
SELECT 
    b.BugID,
    b.Title,
    p.PriorityLevel,
    bc.CategoryName,
    ba.AssignedAt,
    ba.DueBy,
    -- Calculate Hours remaining or overdue
    TIMESTAMPDIFF(HOUR, NOW(), ba.DueBy) AS HoursUntilDeadline,
    CASE 
        WHEN TIMESTAMPDIFF(HOUR, NOW(), ba.DueBy) < 0 THEN 'OVERDUE - BREACHED'
        WHEN TIMESTAMPDIFF(HOUR, NOW(), ba.DueBy) < 4 THEN 'URGENT - AT RISK'
        ELSE 'ON TRACK'
    END as SlaStatus
FROM BugAssignment ba
JOIN Bug b ON ba.BugID = b.BugID
JOIN Priority p ON b.PriorityID = p.PriorityID
LEFT JOIN BugCategory bc ON b.CategoryID = bc.CategoryID
JOIN Status st ON b.StatusID = st.StatusID
WHERE ba.EngineerID = 1 
AND ba.CompletedAt IS NULL 
AND st.StatusName != 'Resolved'
ORDER BY ba.DueBy ASC;


-- ---------------------------------------------------------
-- 6. SMART ASSIGNMENT ALGORITHM: Find available engineers with required skills for a bug category
--Finding an engineer for a 'UI/UX' bug.
-- ---------------------------------------------------------
SELECT 
    e.EngineerID,
    e.Name,
    d.DepartmentName,
    (e.MaxWorkload - e.CurrentWorkload) as AvailableCapacity
FROM Engineer e
JOIN Department d ON e.DepartmentID = d.DepartmentID
WHERE e.IsOnLeave = FALSE 
AND e.CurrentWorkload < e.MaxWorkload
AND e.EngineerID IN (
    -- Subquery: Find engineers who have Mobile/Frontend skills
    SELECT es.EngineerID 
    FROM EngineerSkill es
    JOIN Skill s ON es.SkillID = s.SkillID
    WHERE s.SkillName IN ('iOS / Swift', 'React Native', 'Android / Kotlin')
)
ORDER BY AvailableCapacity DESC
LIMIT 5;


-- ---------------------------------------------------------
-- 7. REVIEW EXTRACTION: Find critical reviews (1-2 stars) for Spotify that haven't been logged as bugs yet
-- ---------------------------------------------------------
SELECT 
    r.ReviewID,
    u.Name AS UserName,
    r.Rating,
    r.Content,
    p.PlatformName
FROM Review r
JOIN User u ON r.UserID = u.UserID
JOIN App a ON r.AppID = a.AppID
JOIN AppPlatform ap ON a.AppID = ap.AppID
JOIN Platform p ON ap.PlatformID = p.PlatformID
LEFT JOIN Bug b ON r.ReviewID = b.ReviewID
WHERE a.AppName = 'Spotify' 
AND r.Rating <= 2
AND b.BugID IS NULL -- Ensure it hasn't been logged as a bug yet
ORDER BY r.Timestamp DESC;


-- ---------------------------------------------------------
-- 8. QA ANALYSIS: Average time to resolve bugs by Priority level
-- ---------------------------------------------------------
SELECT 
    p.PriorityLevel,
    COUNT(ba.AssignmentID) as TotalResolved,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, ba.AssignedAt, ba.CompletedAt)), 1) as AvgResolutionTimeHours,
    MAX(sla.MaxResolutionHours) as TargetSLA
FROM BugAssignment ba
JOIN Bug b ON ba.BugID = b.BugID
JOIN Priority p ON b.PriorityID = p.PriorityID
JOIN SLA sla ON p.PriorityID = sla.PriorityID
WHERE ba.CompletedAt IS NOT NULL
GROUP BY p.PriorityLevel
ORDER BY TargetSLA ASC;


-- ---------------------------------------------------------
-- 9. USER EXPERIENCE: Average Sentiment Score and Bug Generation per Platform
-- ---------------------------------------------------------
SELECT 
    p.PlatformName,
    COUNT(r.ReviewID) as TotalReviewsAnalyzed,
    ROUND(AVG(r.SentimentScore), 2) as AverageSentiment,
    COUNT(b.BugID) as ResultingBugs
FROM Platform p
JOIN Review r ON p.PlatformID = r.PlatformID
LEFT JOIN Bug b ON r.ReviewID = b.ReviewID
GROUP BY p.PlatformName
ORDER BY AverageSentiment ASC;


-- ---------------------------------------------------------
-- 10. DEPARTMENT KPI: Total Bugs handled, currently open, resolved on-time, and deadlined breached
-- ---------------------------------------------------------
SELECT 
    d.DepartmentName,
    COUNT(b.BugID) as TotalBugs,
    SUM(CASE WHEN ba.CompletedAt IS NOT NULL THEN 1 ELSE 0 END) as ResolvedBugs,
    SUM(CASE WHEN ba.CompletedAt IS NULL THEN 1 ELSE 0 END) as OpenBugs,
    SUM(CASE WHEN ba.CompletedAt IS NULL AND ba.DueBy < NOW() THEN 1 ELSE 0 END) as ActiveDeadlineBreaches,
    SUM(CASE WHEN ba.CompletedAt IS NOT NULL AND ba.CompletedAt <= ba.DueBy THEN 1 ELSE 0 END) as ResolvedOnTime
FROM Department d
JOIN Engineer e ON d.DepartmentID = e.DepartmentID
JOIN BugAssignment ba ON e.EngineerID = ba.EngineerID
JOIN Bug b ON ba.BugID = b.BugID
GROUP BY d.DepartmentName
ORDER BY TotalBugs DESC;


-- ---------------------------------------------------------
-- 11. FINANCE DASHBOARD: Total penalty cost organized by Department
-- ---------------------------------------------------------
SELECT 
    d.DepartmentName,
    COUNT(p.PenaltyID) as NumberOfPenalties,
    SUM(p.Amount) as TotalFinancialCost
FROM Department d
JOIN Engineer e ON d.DepartmentID = e.DepartmentID
JOIN BugAssignment ba ON e.EngineerID = ba.EngineerID
JOIN Penalty p ON ba.BugID = p.BugID
GROUP BY d.DepartmentName
ORDER BY TotalFinancialCost DESC;

-- ---------------------------------------------------------
-- 12. HIGH PERFORMERS: Engineers who earned Performance Bonuses (Negative Penalty amounts) by finishing early
-- ---------------------------------------------------------
SELECT 
    e.Name as EngineerName,
    b.BugID,
    b.Title as FastResolvedBug,
    p.Amount as BonusPointsEarned,
    ba.CompletedAt,
    ba.DueBy
FROM Engineer e
JOIN BugAssignment ba ON e.EngineerID = ba.EngineerID
JOIN Penalty p ON ba.BugID = p.BugID
JOIN Bug b ON ba.BugID = b.BugID
WHERE p.Amount < 0
ORDER BY p.Amount ASC, ba.CompletedAt DESC;

-- ---------------------------------------------------------
-- 13. RELATIONAL ALGEBRA - SET OPERATION (UNION): 
-- ---------------------------------------------------------
SELECT b.BugID, b.Title, p.PlatformName, pr.PriorityLevel
FROM Bug b
JOIN Review r ON b.ReviewID = r.ReviewID
JOIN AppPlatform ap ON r.AppID = ap.AppID
JOIN Platform p ON ap.PlatformID = p.PlatformID
JOIN Priority pr ON b.PriorityID = pr.PriorityID
WHERE pr.PriorityLevel = 'High' AND p.PlatformName IN ('Android', 'Google Pixel')

UNION

SELECT b.BugID, b.Title, p.PlatformName, pr.PriorityLevel
FROM Bug b
JOIN Review r ON b.ReviewID = r.ReviewID
JOIN AppPlatform ap ON r.AppID = ap.AppID
JOIN Platform p ON ap.PlatformID = p.PlatformID
JOIN Priority pr ON b.PriorityID = pr.PriorityID
WHERE pr.PriorityLevel = 'Critical' AND p.PlatformName IN ('Mac Laptop', 'Apple Laptop');


-- ---------------------------------------------------------
-- 14. RELATIONAL ALGEBRA - SET OPERATION (EXCEPT/NOT IN): 
-- ---------------------------------------------------------
SELECT 
    e.EngineerID, 
    e.Name, 
    e.Email
FROM Engineer e
WHERE e.EngineerID NOT IN (
    SELECT DISTINCT ba.EngineerID 
    FROM BugAssignment ba 
    JOIN Penalty p ON ba.BugID = p.BugID
);

-- ---------------------------------------------------------
-- 15. COMPLEX ANALYTICS: Ranking Engineers by resolution speed within their department using Window Functions
-- ---------------------------------------------------------
SELECT 
    DepartmentName,
    EngineerName,
    TotalResolvedBugs,
    AvgResolutionTimeHours,
    RANK() OVER(PARTITION BY DepartmentName ORDER BY AvgResolutionTimeHours ASC) as DepartmentRank
FROM (
    SELECT 
        d.DepartmentName,
        e.Name as EngineerName,
        COUNT(ba.AssignmentID) as TotalResolvedBugs,
        AVG(TIMESTAMPDIFF(HOUR, ba.AssignedAt, ba.CompletedAt)) as AvgResolutionTimeHours
    FROM Department d
    JOIN Engineer e ON d.DepartmentID = e.DepartmentID
    JOIN BugAssignment ba ON e.EngineerID = ba.EngineerID
    WHERE ba.CompletedAt IS NOT NULL
    GROUP BY d.DepartmentName, e.Name
    HAVING TotalResolvedBugs >= 1
) AS EngineerStats;
