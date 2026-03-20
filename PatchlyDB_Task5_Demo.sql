-- ---------------------------------------------------------
-- PatchlyDB - Task 5 Live TA Demonstration Script
-- ---------------------------------------------------------
-- Instructions: Run these queries exactly as written below
-- in your MySQL Workbench. Some are specifically designed
-- to FAIL and throw an obvious red error message to 
-- prove to the TA that the Triggers are working perfectly.
-- ---------------------------------------------------------

USE PatchlyDB;

-- ========================================================
-- DEMO 1: The Workload Capacity Trigger (TRG_CheckEngineerWorkload_BeforeAssign)
-- ========================================================
-- Engineer 'Bob Smith' (EngineerID = 2) has a MaxWorkload of 4.
-- Let's force his CurrentWorkload to his maximum.
UPDATE Engineer SET CurrentWorkload = 4 WHERE EngineerID = 2;

-- Now, watch the Trigger STOP this assignment from happening 
-- because Bob is already at maximum capacity!
-- (EXPECTED RESULT: RED ERROR - "Assignment Failed: Engineer is already at maximum capacity.")
INSERT INTO BugAssignment (BugID, EngineerID, AssignedAt, DueBy) 
VALUES (103, 2, NOW(), DATE_ADD(NOW(), INTERVAL 24 HOUR));


-- ========================================================
-- DEMO 2: The Data Integrity Trigger (TRG_EnforceValidRating_BeforeInsert)
-- ========================================================
-- Let's try to pass a chaotic 10-star rating into our 5-star system.
-- (EXPECTED RESULT: RED ERROR - "Invalid Data: Review Rating must be strictly between 1 and 5.")
INSERT INTO Review (UserID, AppID, Content, Rating, Timestamp, SentimentScore) 
VALUES (1, 1, 'This app is so good I give it 10 stars!', 10, NOW(), 0.9);


-- ========================================================
-- DEMO 3: The SLA Protection Trigger (TRG_PreventPastDeadline_BeforeAssign)
-- ========================================================
-- Let's try to assign a Bug, but manually set the Deadline (DueBy) 
-- to yesterday, meaning it's already breached before it's assigned.
-- (EXPECTED RESULT: RED ERROR - "Invalid SLA: The Deadline (DueBy) cannot be earlier than the assignment time.")
INSERT INTO BugAssignment (BugID, EngineerID, AssignedAt, DueBy) 
VALUES (102, 3, NOW(), DATE_SUB(NOW(), INTERVAL 24 HOUR));


-- ========================================================
-- DEMO 4: The Security Trigger (TRG_ProtectAdmin_BeforeDelete)
-- ========================================================
-- Let's try to delete the main administrator account!
-- (EXPECTED RESULT: RED ERROR - "Security Violation: Cannot delete users with the core Admin role.")
DELETE FROM SystemUser WHERE Username = 'admin1';


-- ========================================================
-- DEMO 5: The Silent Assistance Trigger (TRG_AutoSetReviewDate_BeforeInsert)
-- ========================================================
-- Let's insert a valid review but intentionally FORGET to pass the Timestamp.
INSERT INTO Review (UserID, AppID, Content, Rating, Timestamp, SentimentScore) 
VALUES (2, 1, 'Great app, fixing things nicely.', 5, NULL, 0.8);

-- Now, SELECT it. The Trigger silently filled in the exact NOW() date!
SELECT ReviewID, Content, Rating, Timestamp 
FROM Review 
WHERE Content = 'Great app, fixing things nicely.';


-- ========================================================
-- DEMO 6: The Free Workload Trigger (TRG_FreeEngineerWorkload_AfterComplete)
-- ========================================================
-- 'Charlie Davis' (EngineerID = 3) currently has a workload of 2.
SELECT Name, CurrentWorkload FROM Engineer WHERE EngineerID = 3;

-- Let's mark his BugAssignment (AssignmentID = 4) as Completed right now.
UPDATE BugAssignment SET CompletedAt = NOW() WHERE AssignmentID = 4;

-- Check Charlie's workload again. The trigger automatically subtracted 1!
SELECT Name, CurrentWorkload FROM Engineer WHERE EngineerID = 3;
