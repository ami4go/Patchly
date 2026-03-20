-- ---------------------------------------------------------
-- PatchlyDB - Real Spotify Sample Data (5 Initial Entries)
-- Purpose: To evaluate Task 4 SQL Queries and System Flow
-- Data: 5 real-world style reviews across 4 platforms
-- ---------------------------------------------------------

USE PatchlyDB;

-- Disable Foreign Key checks temporarily to allow clean reset
SET FOREIGN_KEY_CHECKS = 0;

-- Clear out any existing dummy data
TRUNCATE TABLE Penalty;
TRUNCATE TABLE ReleaseBugFix;
TRUNCATE TABLE Rollback;
TRUNCATE TABLE `Release`;
TRUNCATE TABLE AppVersion;
TRUNCATE TABLE BugAssignment;
TRUNCATE TABLE DuplicateBug;
TRUNCATE TABLE CustomerImpact;
TRUNCATE TABLE Downtime;
TRUNCATE TABLE Bug;
TRUNCATE TABLE EngineerSkill;
TRUNCATE TABLE Engineer;
TRUNCATE TABLE ReviewSentiment;
TRUNCATE TABLE AppPlatform;
TRUNCATE TABLE Review;
TRUNCATE TABLE Skill;
TRUNCATE TABLE Department;
TRUNCATE TABLE Status;
TRUNCATE TABLE SLA;
TRUNCATE TABLE Priority;
TRUNCATE TABLE BugCategory;
TRUNCATE TABLE Sentiment;
TRUNCATE TABLE Platform;
TRUNCATE TABLE App;
TRUNCATE TABLE User;

-- Add SystemUser here so it clears properly if rerunning
TRUNCATE TABLE SystemUser;

SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------
-- 1. BASE CONFIGURATION DATA
-- ---------------------------------------------------------

-- Insert Platforms (The 4 you specified)
INSERT INTO Platform (PlatformID, PlatformName) VALUES 
(1, 'Apple Phone'),
(2, 'Apple Laptop'),
(3, 'Windows'),
(4, 'Android');

-- Insert Sentiments
INSERT INTO Sentiment (SentimentID, SentimentType) VALUES 
(1, 'Positive'), (2, 'Neutral'), (3, 'Negative'), (4, 'Frustrated'), (5, 'Angry');

-- Insert Bug Categories
INSERT INTO BugCategory (CategoryID, CategoryName) VALUES 
(1, 'UI/UX'), (2, 'Audio Playback'), (3, 'App Crash'), (4, 'Connectivity'), (5, 'Account/Billing');

-- Insert Priorities & SLAs
INSERT INTO Priority (PriorityID, PriorityLevel) VALUES 
(1, 'Critical'), (2, 'High'), (3, 'Medium'), (4, 'Low');

INSERT INTO SLA (PriorityID, MaxResolutionHours, PenaltyCost) VALUES 
(1, 4, 5000.00),   -- Critical: 4 hours, $5000 penalty
(2, 24, 2000.00),  -- High: 24 hours, $2000 penalty
(3, 72, 500.00),   -- Medium: 72 hours, $500 penalty
(4, 168, 0.00);    -- Low: 1 week, no penalty

-- Insert Statuses
INSERT INTO Status (StatusID, StatusName) VALUES 
(1, 'Open'), (2, 'In Progress'), (3, 'Under Review'), (4, 'Resolved'), (5, 'Closed');

-- Insert App
INSERT INTO App (AppID, AppName, Description) VALUES 
(1, 'Spotify', 'Digital music, podcast, and video service');

-- Link App to Platforms
INSERT INTO AppPlatform (AppID, PlatformID) VALUES 
(1, 1), (1, 2), (1, 3), (1, 4);

-- ---------------------------------------------------------
-- 2. ENGINEERING TEAM CONFIGURATION
-- ---------------------------------------------------------

-- Insert Departments
INSERT INTO Department (DepartmentID, DepartmentName) VALUES 
(1, 'Mobile Engineering'), (2, 'Desktop Engineering'), (3, 'Backend API'), (4, 'UI/UX Design');

-- Insert Skills
INSERT INTO Skill (SkillID, SkillName) VALUES 
(1, 'iOS / Swift'), (2, 'Android / Kotlin'), (3, 'React Native'), 
(4, 'C++ (Windows Framework)'), (5, 'macOS / Objective-C');

-- Insert Engineers
INSERT INTO Engineer (EngineerID, Name, Email, DepartmentID, CurrentWorkload, MaxWorkload) VALUES 
(1, 'Alice Chen', 'alice.chen@patchly.local', 1, 1, 5),   -- Mobile Engineer
(2, 'Bob Smith', 'bob.smith@patchly.local', 2, 0, 4),    -- Desktop Engineer
(3, 'Charlie Davis','charlie.d@patchly.local', 1, 2, 5),    -- Mobile Engineer
(4, 'Diana Prince', 'diana.p@patchly.local', 3, 1, 8),    -- Backend 
(5, 'Evan Wright', 'evan.w@patchly.local', 3, 0, 10);     -- Adding Evan so logic matches the SystemUser auth table below

-- Link Engineers to Skills
INSERT INTO EngineerSkill (EngineerID, SkillID) VALUES 
(1, 1), (1, 3), -- Alice knows iOS and React Native
(2, 4), (2, 5), -- Bob knows Windows UI and macOS
(3, 2),         -- Charlie knows Android
(4, 3),         -- Diana knows React Native
(5, 4);         -- Evan knows C++

-- ---------------------------------------------------------
-- 3. THE 5 REAL-WORLD REVIEWS
-- ---------------------------------------------------------

-- Insert Users
INSERT INTO User (UserID, Name, Email) VALUES 
(1, 'Sarah Jenkins', 'sarah.j@email.com'),
(2, 'Mike Ross', 'mike.ross@email.com'),
(3, 'Elena Rodriguez', 'elena.r@email.com'),
(4, 'David Kim', 'dkim99@email.com'),
(5, 'Jessica Taylor', 'jtaylor@email.com');

-- Insert Reviews (1 for each platform, +1 extra Android, +2 unlogged)
INSERT INTO Review (ReviewID, UserID, AppID, Content, Rating, Timestamp, SentimentScore) VALUES 
(1, 1, 1, 'App keeps crashing on my iPhone 15 when I try to open downloaded podcasts while offline.', 1, DATE_SUB(NOW(), INTERVAL 2 DAY), 0.1),
(2, 2, 1, 'The new UI update on the Mac app is terrible. The sidebar is completely unresponsive.', 2, DATE_SUB(NOW(), INTERVAL 5 DAY), 0.3),
(3, 3, 1, 'Audio stutters and pauses randomly on my Windows 11 PC even with a perfect ethernet connection.', 1, DATE_SUB(NOW(), INTERVAL 3 DAY), 0.2),
(4, 4, 1, 'Android Auto integration is broken. Skips songs twice whenever I press next on my steering wheel.', 2, DATE_SUB(NOW(), INTERVAL 1 DAY), 0.4),
(5, 5, 1, 'The Android app is draining my battery even when running in the background. It used 40% in 2 hours!', 1, NOW(), 0.1),
(6, 1, 1, 'Family mix playlist disappeared from my Apple Phone completely. Extremely frustrated!', 1, NOW(), 0.1),
(7, 3, 1, 'Lyrics are out of sync on Windows 11 app since yesterday update.', 2, NOW(), 0.4);

-- Link Reviews to Sentiments (LLM Output Simulation)
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES 
(1, 4), -- Frustrated (Offline Crash)
(2, 3), -- Negative (Bad UI)
(3, 4), -- Frustrated (Audio Stutter)
(4, 3), -- Negative (Android Auto skip bug)
(5, 5), -- Angry (Battery Drain)
(6, 5), -- Angry (Family mix missing)
(7, 3); -- Negative (Lyrics sync)

-- ---------------------------------------------------------
-- 4. BUGS GENERATED FROM REVIEWS (The LLM output)
-- ---------------------------------------------------------

-- Insert Bugs based on the reviews
INSERT INTO Bug (BugID, Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES 
-- Bug 1: Apple Phone offline crash (Critical)
(101, 'Offline Podcast Crash - iPhone 15', 'App crashes immediately when attempting to access downloaded podcasts in offline mode.', DATE_SUB(NOW(), INTERVAL 2 DAY), 'Review', 1, 3, 1, 2),

-- Bug 2: Apple Laptop Sidebar UI (Medium)
(102, 'Sidebar Unresponsive on macOS', 'Users reporting the left navigation sidebar becomes completely unclickable after the latest UI update.', DATE_SUB(NOW(), INTERVAL 5 DAY), 'Review', 2, 1, 3, 1),

-- Bug 3: Windows Audio Stutter (High)
(103, 'Windows 11 Audio Stuttering', 'Constant audio drops and stutters on stable wired connections. Suspect buffer underrun.', DATE_SUB(NOW(), INTERVAL 3 DAY), 'Review', 3, 2, 2, 1),

-- Bug 4: Android Auto Double Skip (Medium)
(104, 'Android Auto Next Track Skips Twice', 'Pressing next track physical button on steering wheel results in skipping two songs.', DATE_SUB(NOW(), INTERVAL 1 DAY), 'Review', 4, 1, 3, 4),

-- Bug 5: Android Battery Drain (Critical)
(105, 'Extreme Battery Drain on Android GPS/Background', 'App is consuming excessive background battery (40% in 2 hours) on Android.', NOW(), 'Review', 5, 3, 1, 2);

-- ---------------------------------------------------------
-- 5. ASSIGNMENTS AND PENALTIES (To trigger SLA logic in Task 4)
-- ---------------------------------------------------------

-- Assign Bugs to Engineers
INSERT INTO BugAssignment (AssignmentID, BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES 
-- Bug 1 (Critical) assigned to Alice (Mobile). Assigned 2 days ago. SLA is 4 hours. It is NOT done yet. (SLA BREACHED)
(1, 101, 1, DATE_SUB(NOW(), INTERVAL 48 HOUR), DATE_SUB(NOW(), INTERVAL 44 HOUR), NULL),

-- Bug 2 (Medium) assigned to Bob (Desktop). Assigned 5 days ago. SLA is 72 hours. He finished it in 1 day. (ON TIME)
(2, 102, 2, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY)),

-- Bug 4 (Medium) assigned to Charlie (Mobile). Assigned 1 day ago. Finished it today. (ON TIME)
(3, 104, 3, DATE_SUB(NOW(), INTERVAL 24 HOUR), DATE_ADD(NOW(), INTERVAL 48 HOUR), NOW()),

-- Bug 5 (Critical) assigned to Charlie (Mobile). Assigned just now. Due in 4 hours. (URGENT)
(4, 105, 3, NOW(), DATE_ADD(NOW(), INTERVAL 4 HOUR), NULL);

-- Generate one manual penalty for Alice because she breached Bug 1's 4-hour SLA by a massive margin
INSERT INTO Penalty (PenaltyID, BugID, SLAID, Amount, Reason, CreatedAt) VALUES 
(1, 101, 1, 5000.00, 'Critical SLA breached by 44 hours. Severe impact to Apple Phone users in offline mode.', DATE_SUB(NOW(), INTERVAL 40 HOUR));

-- Record Customer Impact for the BottleNeck Query
INSERT INTO CustomerImpact (ImpactID, BugID, AffectedUserCount, SeverityScore) VALUES 
(1, 101, 150000, 9.5),  -- Hugely impactful offline bug
(2, 105, 85000, 8.8);   -- High impact Android battery issue

-- ---------------------------------------------------------
-- 6. AUTHENTICATION & DEFAULT USERS
-- ---------------------------------------------------------

-- Admin account
INSERT INTO SystemUser (Username, PasswordHash, Role, EngineerID) VALUES 
('admin1', SHA2('India@123', 256), 'admin', NULL);

-- Engineer accounts (linked to their Engineer records)
INSERT INTO SystemUser (Username, PasswordHash, Role, EngineerID) VALUES 
('alice', SHA2('alice123', 256), 'engineer', 1),
('bob', SHA2('bob123', 256), 'engineer', 2),
('charlie', SHA2('charlie123', 256), 'engineer', 3),
('diana', SHA2('diana123', 256), 'engineer', 4),
('evan', SHA2('evan123', 256), 'engineer', 5);

-- ---------------------------------------------------------
-- END OF SEED SCRIPT
-- ---------------------------------------------------------
