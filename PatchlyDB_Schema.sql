CREATE DATABASE IF NOT EXISTS PatchlyDB;
USE PatchlyDB;

CREATE TABLE User (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(20)
);

CREATE TABLE App (
    AppID INT PRIMARY KEY AUTO_INCREMENT,
    AppName VARCHAR(150) NOT NULL,
    Description TEXT
);

CREATE TABLE Platform (
    PlatformID INT PRIMARY KEY AUTO_INCREMENT,
    PlatformName VARCHAR(50) NOT NULL
);

CREATE TABLE Sentiment (
    SentimentID INT PRIMARY KEY AUTO_INCREMENT,
    SentimentType VARCHAR(50) NOT NULL
);

CREATE TABLE BugCategory (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Priority (
    PriorityID INT PRIMARY KEY AUTO_INCREMENT,
    PriorityLevel VARCHAR(50) NOT NULL
);

CREATE TABLE Status (
    StatusID INT PRIMARY KEY AUTO_INCREMENT,
    StatusName VARCHAR(50) NOT NULL
);

CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY AUTO_INCREMENT,
    DepartmentName VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Skill (
    SkillID INT PRIMARY KEY AUTO_INCREMENT,
    SkillName VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Review (
    ReviewID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    AppID INT NOT NULL,
    Content TEXT,
    Rating INT NOT NULL,
    Timestamp DATETIME NOT NULL,
    SentimentScore FLOAT,
    
    CONSTRAINT FK_Review_User FOREIGN KEY (UserID) REFERENCES User(UserID),
    CONSTRAINT FK_Review_App FOREIGN KEY (AppID) REFERENCES App(AppID)
);

CREATE TABLE AppPlatform (
    AppID INT NOT NULL,
    PlatformID INT NOT NULL,
    
    PRIMARY KEY (AppID, PlatformID),
    CONSTRAINT FK_AppPlatform_App FOREIGN KEY (AppID) REFERENCES App(AppID),
    CONSTRAINT FK_AppPlatform_Platform FOREIGN KEY (PlatformID) REFERENCES Platform(PlatformID)
);

CREATE TABLE ReviewSentiment (
    ReviewID INT NOT NULL,
    SentimentID INT NOT NULL,
    
    PRIMARY KEY (ReviewID, SentimentID),
    CONSTRAINT FK_ReviewSentiment_Review FOREIGN KEY (ReviewID) REFERENCES Review(ReviewID),
    CONSTRAINT FK_ReviewSentiment_Sentiment FOREIGN KEY (SentimentID) REFERENCES Sentiment(SentimentID)
);

CREATE TABLE Engineer (
    EngineerID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    DepartmentID INT NOT NULL,
    CurrentWorkload INT DEFAULT 0,
    MaxWorkload INT DEFAULT 10,
    IsOnLeave BOOLEAN DEFAULT FALSE,
    
    CONSTRAINT FK_Engineer_Department FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

CREATE TABLE EngineerSkill (
    EngineerID INT NOT NULL,
    SkillID INT NOT NULL,
    
    PRIMARY KEY (EngineerID, SkillID),
    CONSTRAINT FK_EngineerSkill_Engineer FOREIGN KEY (EngineerID) REFERENCES Engineer(EngineerID),
    CONSTRAINT FK_EngineerSkill_Skill FOREIGN KEY (SkillID) REFERENCES Skill(SkillID)
);

CREATE TABLE Bug (
    BugID INT PRIMARY KEY AUTO_INCREMENT,
    Title VARCHAR(255) NOT NULL,
    Description TEXT,
    CreatedAt DATETIME NOT NULL,
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

CREATE TABLE DuplicateBug (
    DuplicateID INT PRIMARY KEY AUTO_INCREMENT,
    OriginalBugID INT NOT NULL,
    DuplicateBugID INT NOT NULL,
    LinkedAt DATETIME NOT NULL,
    
    CONSTRAINT FK_DuplicateBug_Original FOREIGN KEY (OriginalBugID) REFERENCES Bug(BugID),
    CONSTRAINT FK_DuplicateBug_Duplicate FOREIGN KEY (DuplicateBugID) REFERENCES Bug(BugID)
);

CREATE TABLE BugAssignment (
    AssignmentID INT PRIMARY KEY AUTO_INCREMENT,
    BugID INT NOT NULL,
    EngineerID INT NOT NULL,
    AssignedAt DATETIME NOT NULL,
    DueBy DATETIME,
    CompletedAt DATETIME,
    
    CONSTRAINT FK_BugAssignment_Bug FOREIGN KEY (BugID) REFERENCES Bug(BugID),
    CONSTRAINT FK_BugAssignment_Engineer FOREIGN KEY (EngineerID) REFERENCES Engineer(EngineerID)
);


CREATE TABLE AppVersion (
    VersionID INT PRIMARY KEY AUTO_INCREMENT,
    AppID INT NOT NULL,
    VersionNumber VARCHAR(50) NOT NULL,
    ReleaseNotes TEXT,
    
    CONSTRAINT FK_AppVersion_App FOREIGN KEY (AppID) REFERENCES App(AppID)
);

CREATE TABLE `Release` (
    ReleaseID INT PRIMARY KEY AUTO_INCREMENT,
    VersionID INT NOT NULL,
    ReleaseDate DATETIME,
    DeploymentStatus VARCHAR(50) NOT NULL,
    Notes TEXT,
    
    CONSTRAINT FK_Release_Version FOREIGN KEY (VersionID) REFERENCES AppVersion(VersionID)
);

CREATE TABLE Rollback (
    RollbackID INT PRIMARY KEY AUTO_INCREMENT,
    ReleaseID INT NOT NULL,
    RollbackDate DATETIME NOT NULL,
    Reason TEXT,
    
    CONSTRAINT FK_Rollback_Release FOREIGN KEY (ReleaseID) REFERENCES `Release`(ReleaseID)
);

CREATE TABLE ReleaseBugFix (
    ReleaseID INT NOT NULL,
    BugID INT NOT NULL,
    
    PRIMARY KEY (ReleaseID, BugID),
    CONSTRAINT FK_ReleaseBugFix_Release FOREIGN KEY (ReleaseID) REFERENCES `Release`(ReleaseID),
    CONSTRAINT FK_ReleaseBugFix_Bug FOREIGN KEY (BugID) REFERENCES Bug(BugID)
);


CREATE TABLE SLA (
    SLAID INT PRIMARY KEY AUTO_INCREMENT,
    PriorityID INT NOT NULL,
    MaxResolutionHours INT NOT NULL,
    PenaltyCost FLOAT,
    
    CONSTRAINT FK_SLA_Priority FOREIGN KEY (PriorityID) REFERENCES Priority(PriorityID)
);

CREATE TABLE Penalty (
    PenaltyID INT PRIMARY KEY AUTO_INCREMENT,
    BugID INT NOT NULL,
    SLAID INT NOT NULL,
    Amount FLOAT NOT NULL,
    Reason TEXT,
    CreatedAt DATETIME NOT NULL,
    
    CONSTRAINT FK_Penalty_Bug FOREIGN KEY (BugID) REFERENCES Bug(BugID),
    CONSTRAINT FK_Penalty_SLA FOREIGN KEY (SLAID) REFERENCES SLA(SLAID)
);


CREATE TABLE Downtime (
    DowntimeID INT PRIMARY KEY AUTO_INCREMENT,
    AppID INT NOT NULL,
    StartTime DATETIME NOT NULL,
    EndTime DATETIME,
    Reason TEXT,
    
    CONSTRAINT FK_Downtime_App FOREIGN KEY (AppID) REFERENCES App(AppID)
);

CREATE TABLE CustomerImpact (
    ImpactID INT PRIMARY KEY AUTO_INCREMENT,
    BugID INT NOT NULL,
    AffectedUserCount INT,
    SeverityScore FLOAT,
    
    CONSTRAINT FK_CustomerImpact_Bug FOREIGN KEY (BugID) REFERENCES Bug(BugID)
);


-- ---------------------------------------------------------
-- Authentication Tables
-- ---------------------------------------------------------

CREATE TABLE IF NOT EXISTS SystemUser (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Username VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    Role ENUM('admin', 'engineer') NOT NULL,
    EngineerID INT NULL,
    CreatedAt DATETIME DEFAULT NOW(),
    
    CONSTRAINT FK_SystemUser_Engineer FOREIGN KEY (EngineerID) REFERENCES Engineer(EngineerID)
);


-- ---------------------------------------------------------
-- TASK 5: DATABASE TRIGGERS
-- ---------------------------------------------------------

DELIMITER //

-- TRIGGER 1: Prevent Bug Assignment if Engineer is at Max Capacity
CREATE TRIGGER TRG_CheckEngineerWorkload_BeforeAssign
BEFORE INSERT ON BugAssignment
FOR EACH ROW
BEGIN
    DECLARE current_load INT;
    DECLARE max_load INT;
    
    SELECT CurrentWorkload, MaxWorkload INTO current_load, max_load 
    FROM Engineer WHERE EngineerID = NEW.EngineerID;
    
    IF current_load >= max_load THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Assignment Failed: Engineer is already at maximum capacity.';
    END IF;
END //

-- TRIGGER 2: Free up capacity when an Engineer completes a bug
CREATE TRIGGER TRG_FreeEngineerWorkload_AfterComplete
AFTER UPDATE ON BugAssignment
FOR EACH ROW
BEGIN
    IF OLD.CompletedAt IS NULL AND NEW.CompletedAt IS NOT NULL THEN
        UPDATE Engineer 
        SET CurrentWorkload = IF(CurrentWorkload > 0, CurrentWorkload - 1, 0)
        WHERE EngineerID = NEW.EngineerID;
    END IF;
END //

-- TRIGGER 3: Enforce Valid Ratings on Reviews (1 to 5 only)
CREATE TRIGGER TRG_EnforceValidRating_BeforeInsert
BEFORE INSERT ON Review
FOR EACH ROW
BEGIN
    IF NEW.Rating < 1 OR NEW.Rating > 5 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid Data: Review Rating must be strictly between 1 and 5.';
    END IF;
END //

-- TRIGGER 4: Prevent SLA Deadlines From Being Set in the Past
CREATE TRIGGER TRG_PreventPastDeadline_BeforeAssign
BEFORE INSERT ON BugAssignment
FOR EACH ROW
BEGIN
    IF NEW.DueBy <= NEW.AssignedAt THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid SLA: The Deadline (DueBy) cannot be earlier than the assignment time.';
    END IF;
END //

-- TRIGGER 5: Protect Admin Users From Accidental Deletion
CREATE TRIGGER TRG_ProtectAdmin_BeforeDelete
BEFORE DELETE ON SystemUser
FOR EACH ROW
BEGIN
    IF OLD.Role = 'admin' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Security Violation: Cannot delete users with the core Admin role.';
    END IF;
END //

-- TRIGGER 6: Automatically set Review Timestamp if left empty
CREATE TRIGGER TRG_AutoSetReviewDate_BeforeInsert
BEFORE INSERT ON Review
FOR EACH ROW
BEGIN
    IF NEW.Timestamp IS NULL THEN
        SET NEW.Timestamp = NOW();
    END IF;
END //

DELIMITER ;
