# PatchlyDB - Software Bug Tracking System
## Complete Database Schema Documentation

---

## 🗄️ **Database Creation**

First, let's create the database:

```sql
-- Create the PatchlyDB database
CREATE DATABASE IF NOT EXISTS PatchlyDB;
USE PatchlyDB;
```

---

# SECTION 1: CORE ENTITIES

These tables have no foreign key dependencies, so we create them first.

---

## 📋 **Table 1: User**

This is a core entity with no foreign key dependencies, so we start here.

```sql
-- Table: User (Core Entity)
-- Stores information about users who submit reviews

CREATE TABLE User (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(20)
);
```

**Key Points:**
- `UserID` is the primary key with auto-increment
- `Email` has a UNIQUE constraint to prevent duplicate accounts
- `Phone` is optional (nullable)

---

## 📋 **Table 2: App**

Another core entity with no foreign key dependencies.

```sql
-- Table: App (Core Entity)
-- Stores information about applications being tracked for bugs

CREATE TABLE App (
    AppID INT PRIMARY KEY AUTO_INCREMENT,
    AppName VARCHAR(150) NOT NULL,
    Description TEXT
);
```

**Key Points:**
- `AppID` is the primary key with auto-increment
- `AppName` is required (NOT NULL)
- `Description` uses TEXT type for longer descriptions (optional field)

---

## 📋 **Table 3: Platform**

Another independent core entity - represents platforms where apps run (iOS, Android, Web, etc.).

```sql
-- Table: Platform (Core Entity)
-- Stores different platforms where applications can run

CREATE TABLE Platform (
    PlatformID INT PRIMARY KEY AUTO_INCREMENT,
    PlatformName VARCHAR(50) NOT NULL
);
```

**Key Points:**
- `PlatformID` is the primary key with auto-increment
- `PlatformName` stores values like "iOS", "Android", "Windows", "Web", etc.
- Simple lookup table for the many-to-many relationship with App

---

## 📋 **Table 4: Sentiment**

A lookup table for sentiment analysis results on reviews.

```sql
-- Table: Sentiment (Lookup Table)
-- Stores sentiment types for classifying review emotions

CREATE TABLE Sentiment (
    SentimentID INT PRIMARY KEY AUTO_INCREMENT,
    SentimentType VARCHAR(50) NOT NULL
);
```

**Key Points:**
- `SentimentID` is the primary key with auto-increment
- `SentimentType` stores values like "Positive", "Negative", "Neutral", "Frustrated", "Happy", etc.
- Used to tag reviews with detected sentiment from analysis

---

## 📋 **Table 5: BugCategory**

A lookup table for categorizing bugs by type.

```sql
-- Table: BugCategory (Lookup Table)
-- Stores categories for classifying bugs

CREATE TABLE BugCategory (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
);
```

**Key Points:**
- `CategoryID` is the primary key with auto-increment
- `CategoryName` is UNIQUE to prevent duplicate categories
- Stores values like "UI/UX", "Performance", "Crash", "Security", "Data Loss", "Functionality", etc.

---

## 📋 **Table 6: Priority**

A lookup table for bug priority levels.

```sql
-- Table: Priority (Lookup Table)
-- Stores priority levels for bugs

CREATE TABLE Priority (
    PriorityID INT PRIMARY KEY AUTO_INCREMENT,
    PriorityLevel VARCHAR(50) NOT NULL
);
```

**Key Points:**
- `PriorityID` is the primary key with auto-increment
- `PriorityLevel` stores values like "Critical", "High", "Medium", "Low"
- This table is also referenced by the SLA table (for defining resolution times per priority)

---

## 📋 **Table 7: Status**

A lookup table for bug status tracking.

```sql
-- Table: Status (Lookup Table)
-- Stores status states for bug lifecycle tracking

CREATE TABLE Status (
    StatusID INT PRIMARY KEY AUTO_INCREMENT,
    StatusName VARCHAR(50) NOT NULL
);
```

**Key Points:**
- `StatusID` is the primary key with auto-increment
- `StatusName` stores values like "Open", "In Progress", "Under Review", "Resolved", "Closed", "Reopened"
- Tracks the current state of a bug in its lifecycle

---

## 📋 **Table 8: Department**

A lookup table for engineering departments.

```sql
-- Table: Department (Lookup Table)
-- Stores engineering departments in the organization

CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY AUTO_INCREMENT,
    DepartmentName VARCHAR(100) NOT NULL UNIQUE
);
```

**Key Points:**
- `DepartmentID` is the primary key with auto-increment
- `DepartmentName` is UNIQUE to prevent duplicate departments
- Stores values like "Backend", "Frontend", "Mobile", "QA", "DevOps", "Security", etc.

---

## 📋 **Table 9: Skill**

A lookup table for engineer skills.

```sql
-- Table: Skill (Lookup Table)
-- Stores skills that engineers can possess

CREATE TABLE Skill (
    SkillID INT PRIMARY KEY AUTO_INCREMENT,
    SkillName VARCHAR(100) NOT NULL UNIQUE
);
```

**Key Points:**
- `SkillID` is the primary key with auto-increment
- `SkillName` is UNIQUE to prevent duplicate skills
- Stores values like "Java", "Python", "React", "Database", "API Design", "Security", "Performance Optimization", etc.

---

# SECTION 2: REVIEW & SENTIMENT

---

## 📋 **Table 10: Review**

First table with foreign key dependencies - references User and App.

```sql
-- Table: Review (Review & Sentiment Section)
-- Stores user reviews for applications

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
```

**Key Points:**
- `ReviewID` is the primary key with auto-increment
- `UserID` and `AppID` are foreign keys (NOT NULL - every review must have a user and app)
- `Rating` is required (typically 1-5 stars)
- `SentimentScore` is optional (populated by sentiment analysis)
- `Timestamp` records when the review was submitted

---

## 📋 **Table 11: AppPlatform**

Junction table for the many-to-many relationship between App and Platform.

```sql
-- Table: AppPlatform (Junction Table)
-- Links apps to the platforms they support (Many-to-Many)

CREATE TABLE AppPlatform (
    AppID INT NOT NULL,
    PlatformID INT NOT NULL,
    
    PRIMARY KEY (AppID, PlatformID),
    CONSTRAINT FK_AppPlatform_App FOREIGN KEY (AppID) REFERENCES App(AppID),
    CONSTRAINT FK_AppPlatform_Platform FOREIGN KEY (PlatformID) REFERENCES Platform(PlatformID)
);
```

**Key Points:**
- **Composite Primary Key** - combination of `AppID` and `PlatformID`
- Both columns are foreign keys referencing their parent tables
- Allows one app to run on multiple platforms (iOS, Android, Web, etc.)
- Allows one platform to host multiple apps

---

## 📋 **Table 12: ReviewSentiment**

Junction table for the many-to-many relationship between Review and Sentiment.

```sql
-- Table: ReviewSentiment (Junction Table)
-- Links reviews to detected sentiments (Many-to-Many)

CREATE TABLE ReviewSentiment (
    ReviewID INT NOT NULL,
    SentimentID INT NOT NULL,
    
    PRIMARY KEY (ReviewID, SentimentID),
    CONSTRAINT FK_ReviewSentiment_Review FOREIGN KEY (ReviewID) REFERENCES Review(ReviewID),
    CONSTRAINT FK_ReviewSentiment_Sentiment FOREIGN KEY (SentimentID) REFERENCES Sentiment(SentimentID)
);
```

**Key Points:**
- **Composite Primary Key** - combination of `ReviewID` and `SentimentID`
- Both columns are foreign keys referencing their parent tables
- A review can have multiple sentiments (e.g., both "Frustrated" and "Hopeful")
- A sentiment type can be associated with multiple reviews

---

# SECTION 3: ENGINEERING TEAM

---

## 📋 **Table 13: Engineer**

Stores engineering team members - references Department.

```sql
-- Table: Engineer (Engineering Team Section)
-- Stores engineers who work on bug fixes

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
```

**Key Points:**
- `EngineerID` is the primary key with auto-increment
- `Email` is UNIQUE to prevent duplicate engineer accounts
- `DepartmentID` is a foreign key (NOT NULL - every engineer must belong to a department)
- `CurrentWorkload` tracks active bug assignments (default 0)
- `MaxWorkload` defines capacity limit (default 10)
- `IsOnLeave` flag for availability tracking (default FALSE)

---

### Understanding Engineer Relationships

The relationships work as follows:

```
Department (1) ──────> (N) Engineer (N) <────── (M) Skill
                            │                        │
                            └──── EngineerSkill ─────┘
                               (Junction Table)
```

### Explanation:

| Relationship | Type | How It's Stored |
|--------------|------|-----------------|
| Engineer → Department | **One-to-Many** | `DepartmentID` is directly in the `Engineer` table |
| Engineer ↔ Skill | **Many-to-Many** | Uses `EngineerSkill` junction table |

### Why this design?
- **One engineer** can only belong to **one department** → Direct FK in Engineer table
- **One engineer** can have **many skills** AND **one skill** can belong to **many engineers** → Needs junction table

So in the schema:
- `Engineer.DepartmentID` → references `Department.DepartmentID`
- `EngineerSkill.EngineerID` → references `Engineer.EngineerID`
- `EngineerSkill.SkillID` → references `Skill.SkillID`

**Skill and Department are independent** - they don't have a direct relationship in the current schema.

---

## 📋 **Table 14: EngineerSkill**

Junction table for the many-to-many relationship between Engineer and Skill.

```sql
-- Table: EngineerSkill (Junction Table)
-- Links engineers to their skills (Many-to-Many)

CREATE TABLE EngineerSkill (
    EngineerID INT NOT NULL,
    SkillID INT NOT NULL,
    
    PRIMARY KEY (EngineerID, SkillID),
    CONSTRAINT FK_EngineerSkill_Engineer FOREIGN KEY (EngineerID) REFERENCES Engineer(EngineerID),
    CONSTRAINT FK_EngineerSkill_Skill FOREIGN KEY (SkillID) REFERENCES Skill(SkillID)
);
```

**Key Points:**
- **Composite Primary Key** - combination of `EngineerID` and `SkillID`
- Both columns are foreign keys referencing their parent tables
- One engineer can have multiple skills (Java, Python, React, etc.)
- One skill can be possessed by multiple engineers
- This helps in smart bug assignment based on required skills

---

# SECTION 4: BUG MANAGEMENT

---

## 📋 **Table 15: Bug**

The central table for bug management - has multiple foreign key relationships.

```sql
-- Table: Bug (Bug Management Section)
-- Stores bug reports - central entity of the system

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
```

**Key Points:**
- `BugID` is the primary key with auto-increment
- `Title` is required (NOT NULL)
- `SourceType` indicates origin - "Review", "Internal", "Customer Support", etc.
- `ReviewID` is **nullable** - only set if bug was extracted from a user review
- `CategoryID` is **nullable** - can be categorized later
- `PriorityID` is **NOT NULL** - every bug must have a priority
- `StatusID` is **NOT NULL** - every bug must have a status

### Foreign Key Summary:
| Column | References | Required? |
|--------|------------|-----------|
| ReviewID | Review(ReviewID) | Optional |
| CategoryID | BugCategory(CategoryID) | Optional |
| PriorityID | Priority(PriorityID) | ✅ Required |
| StatusID | Status(StatusID) | ✅ Required |

---

## 📋 **Table 16: DuplicateBug**

Tracks duplicate bug relationships - self-referencing through Bug table.

```sql
-- Table: DuplicateBug (Bug Management Section)
-- Links duplicate bugs to their original bug reports

CREATE TABLE DuplicateBug (
    DuplicateID INT PRIMARY KEY AUTO_INCREMENT,
    OriginalBugID INT NOT NULL,
    DuplicateBugID INT NOT NULL,
    LinkedAt DATETIME NOT NULL,
    
    CONSTRAINT FK_DuplicateBug_Original FOREIGN KEY (OriginalBugID) REFERENCES Bug(BugID),
    CONSTRAINT FK_DuplicateBug_Duplicate FOREIGN KEY (DuplicateBugID) REFERENCES Bug(BugID)
);
```

**Key Points:**
- `DuplicateID` is the primary key with auto-increment
- `OriginalBugID` references the **original/master** bug report
- `DuplicateBugID` references the bug that was identified as a **duplicate**
- `LinkedAt` records when the duplicate was identified
- Both foreign keys reference the **same table** (Bug) - this is a **self-referencing relationship**

### Example:
| DuplicateID | OriginalBugID | DuplicateBugID | LinkedAt |
|-------------|---------------|----------------|----------|
| 1 | 101 | 105 | 2026-02-04 10:30:00 |
| 2 | 101 | 112 | 2026-02-04 14:15:00 |

*Bug 105 and Bug 112 are duplicates of Bug 101*

---

## 📋 **Table 17: BugAssignment**

Links bugs to engineers with assignment tracking details.

```sql
-- Table: BugAssignment (Engineering Team Section)
-- Tracks which engineers are assigned to which bugs

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
```

**Key Points:**
- `AssignmentID` is the primary key with auto-increment
- `BugID` and `EngineerID` are foreign keys (both NOT NULL)
- `AssignedAt` records when the assignment was made
- `DueBy` is **optional** - deadline for completion (based on SLA)
- `CompletedAt` is **optional** - NULL until bug is resolved

### Assignment Lifecycle:
| State | AssignedAt | DueBy | CompletedAt |
|-------|------------|-------|-------------|
| Newly Assigned | ✅ Set | ✅ Set | NULL |
| In Progress | ✅ Set | ✅ Set | NULL |
| Completed | ✅ Set | ✅ Set | ✅ Set |

---

# SECTION 5: VERSION & RELEASE MANAGEMENT

---

## 📋 **Table 18: AppVersion**

Stores version information for applications.

```sql
-- Table: AppVersion (Version & Release Section)
-- Stores version history for applications

CREATE TABLE AppVersion (
    VersionID INT PRIMARY KEY AUTO_INCREMENT,
    AppID INT NOT NULL,
    VersionNumber VARCHAR(50) NOT NULL,
    ReleaseNotes TEXT,
    
    CONSTRAINT FK_AppVersion_App FOREIGN KEY (AppID) REFERENCES App(AppID)
);
```

**Key Points:**
- `VersionID` is the primary key with auto-increment
- `AppID` is a foreign key (NOT NULL - every version must belong to an app)
- `VersionNumber` stores values like "1.0.0", "2.1.3", "3.0.0-beta"
- `ReleaseNotes` is optional - describes what's new in this version

### Example:
| VersionID | AppID | VersionNumber | ReleaseNotes |
|-----------|-------|---------------|--------------|
| 1 | 1 | 1.0.0 | Initial release |
| 2 | 1 | 1.1.0 | Bug fixes and performance improvements |
| 3 | 1 | 2.0.0 | Major UI redesign |

---

## 📋 **Table 19: Release**

Tracks deployment releases of app versions.

```sql
-- Table: Release (Version & Release Section)
-- Tracks deployment releases for app versions

CREATE TABLE `Release` (
    ReleaseID INT PRIMARY KEY AUTO_INCREMENT,
    VersionID INT NOT NULL,
    ReleaseDate DATETIME,
    DeploymentStatus VARCHAR(50) NOT NULL,
    Notes TEXT,
    
    CONSTRAINT FK_Release_Version FOREIGN KEY (VersionID) REFERENCES AppVersion(VersionID)
);
```

**Key Points:**
- `ReleaseID` is the primary key with auto-increment
- **`Release`** is a reserved keyword in MySQL, so we use backticks around the table name
- `VersionID` is a foreign key (NOT NULL - every release must have a version)
- `ReleaseDate` is **nullable** - can be scheduled for future
- `DeploymentStatus` stores values like "Scheduled", "In Progress", "Deployed", "Failed", "Rolled Back"
- `Notes` is optional - deployment notes or issues

### Why Backticks for Release?

**`Release`** is a **reserved keyword** in MySQL. It's used in the `RELEASE SAVEPOINT` statement for transaction management.

When you use a reserved keyword as a table or column name, MySQL will throw a syntax error unless you wrap it in **backticks** `` ` ` ``.

### Example of what happens without backticks:
```sql
-- ❌ This will ERROR
CREATE TABLE Release (
    ReleaseID INT PRIMARY KEY
);

-- Error: You have an error in your SQL syntax...
```

### With backticks - works fine:
```sql
-- ✅ This works
CREATE TABLE `Release` (
    ReleaseID INT PRIMARY KEY
);
```

### Important:
You'll need to use backticks **every time** you reference this table:
```sql
SELECT * FROM `Release`;
INSERT INTO `Release` (...) VALUES (...);
```

### Alternative Option:
If you want to avoid backticks entirely, you could rename the table to something like:
- `AppRelease`
- `ReleaseInfo`
- `Releases` (plural)

### Release Lifecycle:
| DeploymentStatus | ReleaseDate | Meaning |
|------------------|-------------|---------|
| Scheduled | Future date | Planned release |
| In Progress | Current date | Currently deploying |
| Deployed | Past date | Successfully released |
| Failed | Past date | Deployment failed |
| Rolled Back | Past date | Was deployed but reverted |

---

## 📋 **Table 20: Rollback**

Tracks rollback events when a release needs to be reverted.

```sql
-- Table: Rollback (Version & Release Section)
-- Tracks rollback events when releases fail or cause issues

CREATE TABLE Rollback (
    RollbackID INT PRIMARY KEY AUTO_INCREMENT,
    ReleaseID INT NOT NULL,
    RollbackDate DATETIME NOT NULL,
    Reason TEXT,
    
    CONSTRAINT FK_Rollback_Release FOREIGN KEY (ReleaseID) REFERENCES `Release`(ReleaseID)
);
```

**Key Points:**
- `RollbackID` is the primary key with auto-increment
- `ReleaseID` is a foreign key (NOT NULL - every rollback must reference a release)
- Note: We use backticks for `` `Release` `` in the foreign key reference
- `RollbackDate` records when the rollback occurred
- `Reason` documents why the rollback was needed (optional but recommended)

### Example:
| RollbackID | ReleaseID | RollbackDate | Reason |
|------------|-----------|--------------|--------|
| 1 | 15 | 2026-02-04 09:30:00 | Critical payment gateway failure |
| 2 | 18 | 2026-02-05 14:00:00 | Performance degradation in production |

---

## 📋 **Table 21: ReleaseBugFix**

Junction table linking releases to the bugs they fix.

```sql
-- Table: ReleaseBugFix (Junction Table)
-- Links releases to bugs that are fixed in that release (Many-to-Many)

CREATE TABLE ReleaseBugFix (
    ReleaseID INT NOT NULL,
    BugID INT NOT NULL,
    
    PRIMARY KEY (ReleaseID, BugID),
    CONSTRAINT FK_ReleaseBugFix_Release FOREIGN KEY (ReleaseID) REFERENCES `Release`(ReleaseID),
    CONSTRAINT FK_ReleaseBugFix_Bug FOREIGN KEY (BugID) REFERENCES Bug(BugID)
);
```

**Key Points:**
- **Composite Primary Key** - combination of `ReleaseID` and `BugID`
- Both columns are foreign keys
- Note: We use backticks for `` `Release` `` reference
- One release can fix multiple bugs
- One bug can be addressed across multiple releases (partial fixes, patches)

### Example:
| ReleaseID | BugID |
|-----------|-------|
| 5 | 101 |
| 5 | 102 |
| 5 | 103 |
| 6 | 104 |
| 6 | 101 |

*Release 5 fixes bugs 101, 102, 103. Release 6 fixes bug 104 and includes additional fixes for bug 101*

---

# SECTION 6: SLA & PENALTY MANAGEMENT

---

## 📋 **Table 22: SLA**

Defines Service Level Agreements based on bug priority.

```sql
-- Table: SLA (SLA & Penalty Section)
-- Defines Service Level Agreements for bug resolution times

CREATE TABLE SLA (
    SLAID INT PRIMARY KEY AUTO_INCREMENT,
    PriorityID INT NOT NULL,
    MaxResolutionHours INT NOT NULL,
    PenaltyCost FLOAT,
    
    CONSTRAINT FK_SLA_Priority FOREIGN KEY (PriorityID) REFERENCES Priority(PriorityID)
);
```

**Key Points:**
- `SLAID` is the primary key with auto-increment
- `PriorityID` is a foreign key - links SLA rules to priority levels
- `MaxResolutionHours` defines the deadline (e.g., 4 hours for Critical, 72 hours for Low)
- `PenaltyCost` is the penalty amount if SLA is breached (optional)

### Example SLA Configuration:
| SLAID | PriorityID | Priority | MaxResolutionHours | PenaltyCost |
|-------|------------|----------|-------------------|-------------|
| 1 | 1 | Critical | 4 | 5000.00 |
| 2 | 2 | High | 24 | 2000.00 |
| 3 | 3 | Medium | 72 | 500.00 |
| 4 | 4 | Low | 168 | 0.00 |

---

## 📋 **Table 23: Penalty**

Records SLA breach penalties for bugs.

```sql
-- Table: Penalty (SLA & Penalty Section)
-- Records penalties when SLA is breached for a bug

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
```

**Key Points:**
- `PenaltyID` is the primary key with auto-increment
- `BugID` references the bug that breached SLA
- `SLAID` references which SLA agreement was breached
- `Amount` is the penalty cost (NOT NULL - required)
- `Reason` documents why the penalty occurred
- `CreatedAt` records when the penalty was created

### Example:
| PenaltyID | BugID | SLAID | Amount | Reason | CreatedAt |
|-----------|-------|-------|--------|--------|-----------|
| 1 | 101 | 1 | 5000.00 | Critical bug exceeded 4-hour SLA | 2026-02-04 16:00:00 |
| 2 | 205 | 2 | 2000.00 | High priority bug resolved after 30 hours | 2026-02-05 10:30:00 |

---

# SECTION 7: IMPACT & DOWNTIME TRACKING

---

## 📋 **Table 24: Downtime**

Tracks application downtime events.

```sql
-- Table: Downtime (Impact & Downtime Section)
-- Tracks downtime periods for applications

CREATE TABLE Downtime (
    DowntimeID INT PRIMARY KEY AUTO_INCREMENT,
    AppID INT NOT NULL,
    StartTime DATETIME NOT NULL,
    EndTime DATETIME,
    Reason TEXT,
    
    CONSTRAINT FK_Downtime_App FOREIGN KEY (AppID) REFERENCES App(AppID)
);
```

**Key Points:**
- `DowntimeID` is the primary key with auto-increment
- `AppID` is a foreign key (NOT NULL - every downtime event must belong to an app)
- `StartTime` records when downtime began (required)
- `EndTime` is **nullable** - NULL while downtime is ongoing, set when resolved
- `Reason` documents the cause of downtime

### Downtime Status:
| State | StartTime | EndTime |
|-------|-----------|---------|
| Ongoing | ✅ Set | NULL |
| Resolved | ✅ Set | ✅ Set |

### Example:
| DowntimeID | AppID | StartTime | EndTime | Reason |
|------------|-------|-----------|---------|--------|
| 1 | 1 | 2026-02-04 08:00:00 | 2026-02-04 08:45:00 | Database connection failure |
| 2 | 2 | 2026-02-04 15:30:00 | NULL | Investigating server issues |

---

## 📋 **Table 25: CustomerImpact**

Tracks the impact of bugs on customers.

```sql
-- Table: CustomerImpact (Impact & Downtime Section)
-- Tracks the customer impact of bugs

CREATE TABLE CustomerImpact (
    ImpactID INT PRIMARY KEY AUTO_INCREMENT,
    BugID INT NOT NULL,
    AffectedUserCount INT,
    SeverityScore FLOAT,
    
    CONSTRAINT FK_CustomerImpact_Bug FOREIGN KEY (BugID) REFERENCES Bug(BugID)
);
```

**Key Points:**
- `ImpactID` is the primary key with auto-increment
- `BugID` is a foreign key (NOT NULL - every impact record must link to a bug)
- `AffectedUserCount` estimates how many users are impacted (optional)
- `SeverityScore` is a calculated metric for prioritization (e.g., 0.0 to 10.0)

### Example:
| ImpactID | BugID | AffectedUserCount | SeverityScore |
|----------|-------|-------------------|---------------|
| 1 | 101 | 50000 | 9.5 |
| 2 | 102 | 500 | 4.2 |
| 3 | 103 | 10 | 1.5 |

---

# 📊 COMPLETE SCHEMA SUMMARY

## Tables by Section:

| Section | Tables |
|---------|--------|
| **Core Entities** | User, App, Platform, Sentiment, BugCategory, Priority, Status, Department, Skill |
| **Review & Sentiment** | Review, AppPlatform, ReviewSentiment |
| **Engineering Team** | Engineer, EngineerSkill |
| **Bug Management** | Bug, DuplicateBug, BugAssignment |
| **Version & Release** | AppVersion, Release, Rollback, ReleaseBugFix |
| **SLA & Penalty** | SLA, Penalty |
| **Impact & Downtime** | Downtime, CustomerImpact |

**Total: 25 Tables** ✅

---

## 🚀 How to Run in SQL Workbench:

1. Open MySQL Workbench
2. Connect to your MySQL server
3. Open the file: `File` → `Open SQL Script` → Select `PatchlyDB_Schema.sql`
4. Click the **⚡ Execute** button (or press `Ctrl+Shift+Enter`)

---

## Files Generated:

| File | Description |
|------|-------------|
| `PatchlyDB_Schema.sql` | Complete SQL script with all 25 tables |
| `PatchlyDB_README.md` | This documentation file |

---

*Generated: 2026-02-04*
*Database: PatchlyDB - Software Bug Tracking System*
