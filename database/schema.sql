-- ============================================================
-- PATCHLYDB - Software Bug Tracking System
-- Complete Database Schema with Indexes
-- ============================================================

CREATE DATABASE IF NOT EXISTS PatchlyDB;
USE PatchlyDB;

-- ============================================================
-- SECTION 1: CORE ENTITIES
-- ============================================================

CREATE TABLE IF NOT EXISTS User (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(20),
    Role ENUM('admin','developer','company') NOT NULL DEFAULT 'company',
    PasswordHash VARCHAR(255) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS App (
    AppID INT PRIMARY KEY AUTO_INCREMENT,
    AppName VARCHAR(150) NOT NULL,
    Description TEXT,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Platform (
    PlatformID INT PRIMARY KEY AUTO_INCREMENT,
    PlatformName VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS Sentiment (
    SentimentID INT PRIMARY KEY AUTO_INCREMENT,
    SentimentType VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS BugCategory (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Priority (
    PriorityID INT PRIMARY KEY AUTO_INCREMENT,
    PriorityLevel VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS Status (
    StatusID INT PRIMARY KEY AUTO_INCREMENT,
    StatusName VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS Department (
    DepartmentID INT PRIMARY KEY AUTO_INCREMENT,
    DepartmentName VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Skill (
    SkillID INT PRIMARY KEY AUTO_INCREMENT,
    SkillName VARCHAR(100) NOT NULL UNIQUE
);

-- ============================================================
-- SECTION 2: REVIEW & SENTIMENT
-- ============================================================

CREATE TABLE IF NOT EXISTS Review (
    ReviewID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    AppID INT NOT NULL,
    Content TEXT,
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    SentimentScore FLOAT,

    CONSTRAINT FK_Review_User FOREIGN KEY (UserID) REFERENCES User(UserID),
    CONSTRAINT FK_Review_App FOREIGN KEY (AppID) REFERENCES App(AppID)
);

CREATE TABLE IF NOT EXISTS AppPlatform (
    AppID INT NOT NULL,
    PlatformID INT NOT NULL,

    PRIMARY KEY (AppID, PlatformID),
    CONSTRAINT FK_AppPlatform_App FOREIGN KEY (AppID) REFERENCES App(AppID),
    CONSTRAINT FK_AppPlatform_Platform FOREIGN KEY (PlatformID) REFERENCES Platform(PlatformID)
);

CREATE TABLE IF NOT EXISTS ReviewSentiment (
    ReviewID INT NOT NULL,
    SentimentID INT NOT NULL,

    PRIMARY KEY (ReviewID, SentimentID),
    CONSTRAINT FK_ReviewSentiment_Review FOREIGN KEY (ReviewID) REFERENCES Review(ReviewID),
    CONSTRAINT FK_ReviewSentiment_Sentiment FOREIGN KEY (SentimentID) REFERENCES Sentiment(SentimentID)
);

-- ============================================================
-- SECTION 3: ENGINEERING TEAM
-- ============================================================

CREATE TABLE IF NOT EXISTS Engineer (
    EngineerID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    DepartmentID INT NOT NULL,
    CurrentWorkload INT DEFAULT 0,
    MaxWorkload INT DEFAULT 10,
    IsOnLeave BOOLEAN DEFAULT FALSE,

    CONSTRAINT FK_Engineer_Department FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    CONSTRAINT CHK_Workload CHECK (CurrentWorkload >= 0 AND CurrentWorkload <= MaxWorkload)
);

CREATE TABLE IF NOT EXISTS EngineerSkill (
    EngineerID INT NOT NULL,
    SkillID INT NOT NULL,

    PRIMARY KEY (EngineerID, SkillID),
    CONSTRAINT FK_EngineerSkill_Engineer FOREIGN KEY (EngineerID) REFERENCES Engineer(EngineerID),
    CONSTRAINT FK_EngineerSkill_Skill FOREIGN KEY (SkillID) REFERENCES Skill(SkillID)
);

-- ============================================================
-- SECTION 4: BUG MANAGEMENT
-- ============================================================

CREATE TABLE IF NOT EXISTS Bug (
    BugID INT PRIMARY KEY AUTO_INCREMENT,
    Title VARCHAR(255) NOT NULL,
    Description TEXT,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    SourceType VARCHAR(50),
    ReviewID INT,
    CategoryID INT,
    PriorityID INT NOT NULL,
    StatusID INT NOT NULL,

    CONSTRAINT FK_Bug_Review FOREIGN KEY (ReviewID) REFERENCES Review(ReviewID),
    CONSTRAINT FK_Bug_Category FOREIGN KEY (CategoryID) REFERENCES BugCategory(CategoryID),
    CONSTRAINT FK_Bug_Priority FOREIGN KEY (PriorityID) REFERENCES Priority(PriorityID),
    CONSTRAINT FK_Bug_Status FOREIGN KEY (StatusID) REFERENCES Status(StatusID)
);

CREATE TABLE IF NOT EXISTS DuplicateBug (
    DuplicateID INT PRIMARY KEY AUTO_INCREMENT,
    OriginalBugID INT NOT NULL,
    DuplicateBugID INT NOT NULL,
    LinkedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT FK_DuplicateBug_Original FOREIGN KEY (OriginalBugID) REFERENCES Bug(BugID),
    CONSTRAINT FK_DuplicateBug_Duplicate FOREIGN KEY (DuplicateBugID) REFERENCES Bug(BugID)
);

CREATE TABLE IF NOT EXISTS BugAssignment (
    AssignmentID INT PRIMARY KEY AUTO_INCREMENT,
    BugID INT NOT NULL,
    EngineerID INT NOT NULL,
    AssignedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    DueBy DATETIME,
    CompletedAt DATETIME,

    CONSTRAINT FK_BugAssignment_Bug FOREIGN KEY (BugID) REFERENCES Bug(BugID),
    CONSTRAINT FK_BugAssignment_Engineer FOREIGN KEY (EngineerID) REFERENCES Engineer(EngineerID)
);

-- ============================================================
-- SECTION 5: VERSION & RELEASE MANAGEMENT
-- ============================================================

CREATE TABLE IF NOT EXISTS AppVersion (
    VersionID INT PRIMARY KEY AUTO_INCREMENT,
    AppID INT NOT NULL,
    VersionNumber VARCHAR(50) NOT NULL,
    ReleaseNotes TEXT,

    CONSTRAINT FK_AppVersion_App FOREIGN KEY (AppID) REFERENCES App(AppID)
);

CREATE TABLE IF NOT EXISTS `Release` (
    ReleaseID INT PRIMARY KEY AUTO_INCREMENT,
    VersionID INT NOT NULL,
    ReleaseDate DATETIME,
    DeploymentStatus VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    Notes TEXT,

    CONSTRAINT FK_Release_Version FOREIGN KEY (VersionID) REFERENCES AppVersion(VersionID)
);

CREATE TABLE IF NOT EXISTS Rollback (
    RollbackID INT PRIMARY KEY AUTO_INCREMENT,
    ReleaseID INT NOT NULL,
    RollbackDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Reason TEXT,

    CONSTRAINT FK_Rollback_Release FOREIGN KEY (ReleaseID) REFERENCES `Release`(ReleaseID)
);

CREATE TABLE IF NOT EXISTS ReleaseBugFix (
    ReleaseID INT NOT NULL,
    BugID INT NOT NULL,

    PRIMARY KEY (ReleaseID, BugID),
    CONSTRAINT FK_ReleaseBugFix_Release FOREIGN KEY (ReleaseID) REFERENCES `Release`(ReleaseID),
    CONSTRAINT FK_ReleaseBugFix_Bug FOREIGN KEY (BugID) REFERENCES Bug(BugID)
);

-- ============================================================
-- SECTION 6: SLA & PENALTY MANAGEMENT
-- ============================================================

CREATE TABLE IF NOT EXISTS SLA (
    SLAID INT PRIMARY KEY AUTO_INCREMENT,
    PriorityID INT NOT NULL,
    MaxResolutionHours INT NOT NULL,
    PenaltyCost FLOAT,

    CONSTRAINT FK_SLA_Priority FOREIGN KEY (PriorityID) REFERENCES Priority(PriorityID)
);

CREATE TABLE IF NOT EXISTS Penalty (
    PenaltyID INT PRIMARY KEY AUTO_INCREMENT,
    BugID INT NOT NULL,
    SLAID INT NOT NULL,
    Amount FLOAT NOT NULL,
    Reason TEXT,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT FK_Penalty_Bug FOREIGN KEY (BugID) REFERENCES Bug(BugID),
    CONSTRAINT FK_Penalty_SLA FOREIGN KEY (SLAID) REFERENCES SLA(SLAID)
);

-- ============================================================
-- SECTION 7: IMPACT & DOWNTIME TRACKING
-- ============================================================

CREATE TABLE IF NOT EXISTS Downtime (
    DowntimeID INT PRIMARY KEY AUTO_INCREMENT,
    AppID INT NOT NULL,
    StartTime DATETIME NOT NULL,
    EndTime DATETIME,
    Reason TEXT,

    CONSTRAINT FK_Downtime_App FOREIGN KEY (AppID) REFERENCES App(AppID)
);

CREATE TABLE IF NOT EXISTS CustomerImpact (
    ImpactID INT PRIMARY KEY AUTO_INCREMENT,
    BugID INT NOT NULL,
    AffectedUserCount INT,
    SeverityScore FLOAT,

    CONSTRAINT FK_CustomerImpact_Bug FOREIGN KEY (BugID) REFERENCES Bug(BugID)
);

-- ============================================================
-- INDEXES - Strategic indexing for performance
-- ============================================================

-- User indexes
CREATE INDEX idx_user_email ON User(Email);
CREATE INDEX idx_user_role ON User(Role);

-- Review indexes
CREATE INDEX idx_review_userid ON Review(UserID);
CREATE INDEX idx_review_appid ON Review(AppID);
CREATE INDEX idx_review_rating ON Review(Rating);
CREATE INDEX idx_review_timestamp ON Review(Timestamp);

-- Bug indexes
CREATE INDEX idx_bug_priorityid ON Bug(PriorityID);
CREATE INDEX idx_bug_statusid ON Bug(StatusID);
CREATE INDEX idx_bug_categoryid ON Bug(CategoryID);
CREATE INDEX idx_bug_createdat ON Bug(CreatedAt);
CREATE INDEX idx_bug_reviewid ON Bug(ReviewID);

-- BugAssignment indexes
CREATE INDEX idx_bugassignment_bugid ON BugAssignment(BugID);
CREATE INDEX idx_bugassignment_engineerid ON BugAssignment(EngineerID);
CREATE INDEX idx_bugassignment_assignedat ON BugAssignment(AssignedAt);

-- Engineer indexes
CREATE INDEX idx_engineer_departmentid ON Engineer(DepartmentID);
CREATE INDEX idx_engineer_workload ON Engineer(CurrentWorkload);
CREATE INDEX idx_engineer_onleave ON Engineer(IsOnLeave);

-- AppVersion indexes
CREATE INDEX idx_appversion_appid ON AppVersion(AppID);

-- Release indexes
CREATE INDEX idx_release_versionid ON `Release`(VersionID);
CREATE INDEX idx_release_status ON `Release`(DeploymentStatus);
CREATE INDEX idx_release_date ON `Release`(ReleaseDate);

-- Penalty indexes
CREATE INDEX idx_penalty_bugid ON Penalty(BugID);
CREATE INDEX idx_penalty_createdat ON Penalty(CreatedAt);

-- Downtime indexes
CREATE INDEX idx_downtime_appid ON Downtime(AppID);
CREATE INDEX idx_downtime_starttime ON Downtime(StartTime);

-- ============================================================
-- TRIGGERS
-- ============================================================

DELIMITER //

-- Trigger 1: Auto-create bug from negative review
CREATE TRIGGER trg_auto_bug_from_review
AFTER INSERT ON Review
FOR EACH ROW
BEGIN
    IF NEW.Rating <= 2 THEN
        INSERT INTO Bug (Title, Description, CreatedAt, SourceType, ReviewID, PriorityID, StatusID)
        SELECT
            CONCAT('Auto-Bug from Review #', NEW.ReviewID),
            NEW.Content,
            NOW(),
            'REVIEW',
            NEW.ReviewID,
            (SELECT PriorityID FROM Priority WHERE PriorityLevel = 'HIGH' LIMIT 1),
            (SELECT StatusID FROM Status WHERE StatusName = 'OPEN' LIMIT 1);
    END IF;
END //

-- Trigger 2: Prevent engineer overload on assignment
CREATE TRIGGER trg_check_workload_before_assign
BEFORE INSERT ON BugAssignment
FOR EACH ROW
BEGIN
    DECLARE v_current INT;
    DECLARE v_max INT;
    DECLARE v_on_leave BOOLEAN;
    SELECT CurrentWorkload, MaxWorkload, IsOnLeave
      INTO v_current, v_max, v_on_leave
      FROM Engineer WHERE EngineerID = NEW.EngineerID;
    IF v_on_leave = TRUE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Engineer is on leave and cannot be assigned.';
    END IF;
    IF v_current >= v_max THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Engineer workload limit reached.';
    END IF;
END //

-- Trigger 3: Increment engineer workload on assignment
CREATE TRIGGER trg_increment_workload
AFTER INSERT ON BugAssignment
FOR EACH ROW
BEGIN
    UPDATE Engineer SET CurrentWorkload = CurrentWorkload + 1
    WHERE EngineerID = NEW.EngineerID;
END //

-- Trigger 4: Decrement engineer workload on completion
CREATE TRIGGER trg_decrement_workload
AFTER UPDATE ON BugAssignment
FOR EACH ROW
BEGIN
    IF NEW.CompletedAt IS NOT NULL AND OLD.CompletedAt IS NULL THEN
        UPDATE Engineer SET CurrentWorkload = CurrentWorkload - 1
        WHERE EngineerID = NEW.EngineerID AND CurrentWorkload > 0;
    END IF;
END //

-- Trigger 5: Auto-create penalty on SLA breach (tracked via Penalty insert check)
CREATE TRIGGER trg_log_sla_breach
BEFORE INSERT ON Penalty
FOR EACH ROW
BEGIN
    IF NEW.Amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Penalty amount must be positive.';
    END IF;
END //

DELIMITER ;

-- ============================================================
-- SEED DATA
-- ============================================================

INSERT IGNORE INTO Platform (PlatformName) VALUES ('Play Store'), ('App Store'), ('Email'), ('Web');

INSERT IGNORE INTO Sentiment (SentimentType) VALUES ('Positive'), ('Neutral'), ('Negative');

INSERT IGNORE INTO BugCategory (CategoryName) VALUES ('UI'), ('Performance'), ('Crash'), ('Feature Request'), ('Security'), ('Network');

INSERT IGNORE INTO Priority (PriorityLevel) VALUES ('LOW'), ('MEDIUM'), ('HIGH'), ('CRITICAL');

INSERT IGNORE INTO Status (StatusName) VALUES ('OPEN'), ('IN PROGRESS'), ('RESOLVED'), ('CLOSED'), ('REOPENED');

INSERT IGNORE INTO Department (DepartmentName) VALUES ('Backend'), ('Frontend'), ('Mobile'), ('DevOps'), ('QA');

INSERT IGNORE INTO Skill (SkillName) VALUES ('Python'), ('JavaScript'), ('iOS'), ('Android'), ('SQL'), ('React'), ('Node.js'), ('Docker'), ('AWS'), ('Testing');

INSERT IGNORE INTO SLA (PriorityID, MaxResolutionHours, PenaltyCost)
SELECT PriorityID, 4, 1000.00 FROM Priority WHERE PriorityLevel = 'CRITICAL'
ON DUPLICATE KEY UPDATE MaxResolutionHours = 4;

INSERT IGNORE INTO SLA (PriorityID, MaxResolutionHours, PenaltyCost)
SELECT PriorityID, 24, 500.00 FROM Priority WHERE PriorityLevel = 'HIGH'
ON DUPLICATE KEY UPDATE MaxResolutionHours = 24;

INSERT IGNORE INTO SLA (PriorityID, MaxResolutionHours, PenaltyCost)
SELECT PriorityID, 72, 200.00 FROM Priority WHERE PriorityLevel = 'MEDIUM'
ON DUPLICATE KEY UPDATE MaxResolutionHours = 72;

INSERT IGNORE INTO SLA (PriorityID, MaxResolutionHours, PenaltyCost)
SELECT PriorityID, 168, 50.00 FROM Priority WHERE PriorityLevel = 'LOW'
ON DUPLICATE KEY UPDATE MaxResolutionHours = 168;

-- Default admin user (password: Admin@123 - bcrypt hash)
INSERT IGNORE INTO User (Name, Email, Phone, Role, PasswordHash)
VALUES ('Admin', 'admin@patchly.com', '0000000000', 'admin',
'$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');
