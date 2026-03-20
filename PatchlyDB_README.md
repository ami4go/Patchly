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
| `PatchlyDB_Schema.sql` | CREATE TABLE statements for all 25 tables |
| `PatchlyDB_SampleData.sql` | INSERT statements for sample data |
| `PatchlyDB_README.md` | This documentation file |

---

# 📊 SAMPLE DATA DOCUMENTATION

This section documents all the sample data populated in PatchlyDB.

---

## 📈 Data Summary

| Table | Records | Description |
|-------|---------|-------------|
| User | 4 | App users who submit reviews |
| App | 4 | Patchly applications |
| Platform | 5 | iOS, Android, Web, Windows, macOS |
| Sentiment | 5 | Positive, Negative, Neutral, Frustrated, Satisfied |
| BugCategory | 6 | UI/UX, Performance, Crash, Security, Functionality, Data Loss |
| Priority | 4 | Critical, High, Medium, Low |
| Status | 6 | Open, In Progress, Under Review, Resolved, Closed, Reopened |
| Department | 5 | Backend, Frontend, Mobile, QA, DevOps |
| Skill | 8 | Java, Python, React, Swift, Kotlin, SQL, Node.js, AWS |
| Review | 4 | User reviews with ratings and sentiment scores |
| AppPlatform | 6 | App-Platform mappings |
| ReviewSentiment | 7 | Review-Sentiment mappings |
| Engineer | 5 | Engineering team members |
| EngineerSkill | 10 | Engineer-Skill mappings |
| Bug | 5 | Bug reports from various sources |
| DuplicateBug | 1 | Duplicate bug linkages |
| BugAssignment | 5 | Bug assignments to engineers |
| AppVersion | 6 | App version history |
| Release | 6 | Deployment releases |
| Rollback | 1 | Rollback events |
| ReleaseBugFix | 3 | Release-Bug fix mappings |
| SLA | 4 | SLA rules per priority |
| Penalty | 2 | SLA breach penalties |
| Downtime | 4 | App downtime events |
| CustomerImpact | 5 | Bug impact metrics |

**Total Records: 106**

---

## 🗄️ Sample Data Details

### Table 1: User
```sql
INSERT INTO User (Name, Email, Phone) VALUES
('Amit Kumar', 'amit.kumar@email.com', '+91-9876543210'),
('Priya Sharma', 'priya.sharma@email.com', '+91-9876543211'),
('Rahul Verma', 'rahul.verma@email.com', '+91-9876543212'),
('Sneha Patel', 'sneha.patel@email.com', NULL);
```

| UserID | Name | Email | Phone |
|--------|------|-------|-------|
| 1 | Amit Kumar | amit.kumar@email.com | +91-9876543210 |
| 2 | Priya Sharma | priya.sharma@email.com | +91-9876543211 |
| 3 | Rahul Verma | rahul.verma@email.com | +91-9876543212 |
| 4 | Sneha Patel | sneha.patel@email.com | NULL |

---

### Table 2: App
```sql
INSERT INTO App (AppName, Description) VALUES
('Patchly Mobile', 'Mobile bug tracking application for iOS and Android'),
('Patchly Web', 'Web-based dashboard for bug management and analytics'),
('Patchly API', 'RESTful API service for third-party integrations'),
('Patchly Desktop', 'Desktop application for Windows and macOS');
```

| AppID | AppName | Description |
|-------|---------|-------------|
| 1 | Patchly Mobile | Mobile bug tracking application for iOS and Android |
| 2 | Patchly Web | Web-based dashboard for bug management and analytics |
| 3 | Patchly API | RESTful API service for third-party integrations |
| 4 | Patchly Desktop | Desktop application for Windows and macOS |

---

### Table 3: Platform
```sql
INSERT INTO Platform (PlatformName) VALUES
('iOS'), ('Android'), ('Web'), ('Windows'), ('macOS');
```

| PlatformID | PlatformName |
|------------|--------------|
| 1 | iOS |
| 2 | Android |
| 3 | Web |
| 4 | Windows |
| 5 | macOS |

---

### Table 4: Sentiment
```sql
INSERT INTO Sentiment (SentimentType) VALUES
('Positive'), ('Negative'), ('Neutral'), ('Frustrated'), ('Satisfied');
```

| SentimentID | SentimentType |
|-------------|---------------|
| 1 | Positive |
| 2 | Negative |
| 3 | Neutral |
| 4 | Frustrated |
| 5 | Satisfied |

---

### Table 5: BugCategory
```sql
INSERT INTO BugCategory (CategoryName) VALUES
('UI/UX'), ('Performance'), ('Crash'), ('Security'), ('Functionality'), ('Data Loss');
```

| CategoryID | CategoryName |
|------------|--------------|
| 1 | UI/UX |
| 2 | Performance |
| 3 | Crash |
| 4 | Security |
| 5 | Functionality |
| 6 | Data Loss |

---

### Table 6: Priority
```sql
INSERT INTO Priority (PriorityLevel) VALUES
('Critical'), ('High'), ('Medium'), ('Low');
```

| PriorityID | PriorityLevel |
|------------|---------------|
| 1 | Critical |
| 2 | High |
| 3 | Medium |
| 4 | Low |

---

### Table 7: Status
```sql
INSERT INTO Status (StatusName) VALUES
('Open'), ('In Progress'), ('Under Review'), ('Resolved'), ('Closed'), ('Reopened');
```

| StatusID | StatusName |
|----------|------------|
| 1 | Open |
| 2 | In Progress |
| 3 | Under Review |
| 4 | Resolved |
| 5 | Closed |
| 6 | Reopened |

---

### Table 8: Department
```sql
INSERT INTO Department (DepartmentName) VALUES
('Backend'), ('Frontend'), ('Mobile'), ('QA'), ('DevOps');
```

| DepartmentID | DepartmentName |
|--------------|----------------|
| 1 | Backend |
| 2 | Frontend |
| 3 | Mobile |
| 4 | QA |
| 5 | DevOps |

---

### Table 9: Skill
```sql
INSERT INTO Skill (SkillName) VALUES
('Java'), ('Python'), ('React'), ('Swift'), ('Kotlin'), ('SQL'), ('Node.js'), ('AWS');
```

| SkillID | SkillName |
|---------|-----------|
| 1 | Java |
| 2 | Python |
| 3 | React |
| 4 | Swift |
| 5 | Kotlin |
| 6 | SQL |
| 7 | Node.js |
| 8 | AWS |

---

### Table 10: Review
```sql
INSERT INTO Review (UserID, AppID, Content, Rating, Timestamp, SentimentScore) VALUES
(1, 1, 'Great app but crashes sometimes on my iPhone', 3, '2026-01-15 10:30:00', -0.2),
(2, 2, 'Love the dashboard! Very intuitive and easy to use', 5, '2026-01-16 14:45:00', 0.9),
(3, 1, 'App is too slow, takes forever to load bug reports', 2, '2026-01-17 09:15:00', -0.7),
(4, 3, 'API documentation could be better, but works fine', 4, '2026-01-18 16:20:00', 0.3);
```

| ReviewID | UserID | AppID | Content | Rating | SentimentScore |
|----------|--------|-------|---------|--------|----------------|
| 1 | 1 | 1 | Great app but crashes sometimes... | 3 | -0.2 |
| 2 | 2 | 2 | Love the dashboard!... | 5 | 0.9 |
| 3 | 3 | 1 | App is too slow... | 2 | -0.7 |
| 4 | 4 | 3 | API documentation could be better... | 4 | 0.3 |

---

### Table 11: AppPlatform
```sql
INSERT INTO AppPlatform (AppID, PlatformID) VALUES
(1, 1), (1, 2), (2, 3), (3, 3), (4, 4), (4, 5);
```

| AppID | PlatformID | App Name | Platform |
|-------|------------|----------|----------|
| 1 | 1 | Patchly Mobile | iOS |
| 1 | 2 | Patchly Mobile | Android |
| 2 | 3 | Patchly Web | Web |
| 3 | 3 | Patchly API | Web |
| 4 | 4 | Patchly Desktop | Windows |
| 4 | 5 | Patchly Desktop | macOS |

---

### Table 12: ReviewSentiment
```sql
INSERT INTO ReviewSentiment (ReviewID, SentimentID) VALUES
(1, 3), (1, 4), (2, 1), (2, 5), (3, 2), (3, 4), (4, 3);
```

| ReviewID | SentimentID | Review Summary | Sentiment |
|----------|-------------|----------------|-----------|
| 1 | 3 | crashes sometimes | Neutral |
| 1 | 4 | crashes sometimes | Frustrated |
| 2 | 1 | Love the dashboard | Positive |
| 2 | 5 | Love the dashboard | Satisfied |
| 3 | 2 | App is too slow | Negative |
| 3 | 4 | App is too slow | Frustrated |
| 4 | 3 | documentation could be better | Neutral |

---

### Table 13: Engineer
```sql
INSERT INTO Engineer (Name, Email, DepartmentID, CurrentWorkload, MaxWorkload, IsOnLeave) VALUES
('Vikram Singh', 'vikram.singh@patchly.com', 1, 3, 10, FALSE),
('Ananya Reddy', 'ananya.reddy@patchly.com', 2, 5, 8, FALSE),
('Karthik Nair', 'karthik.nair@patchly.com', 3, 2, 10, FALSE),
('Meera Joshi', 'meera.joshi@patchly.com', 4, 0, 10, TRUE),
('Arjun Menon', 'arjun.menon@patchly.com', 5, 4, 10, FALSE);
```

| EngineerID | Name | Department | CurrentWorkload | MaxWorkload | IsOnLeave |
|------------|------|------------|-----------------|-------------|-----------|
| 1 | Vikram Singh | Backend | 3 | 10 | FALSE |
| 2 | Ananya Reddy | Frontend | 5 | 8 | FALSE |
| 3 | Karthik Nair | Mobile | 2 | 10 | FALSE |
| 4 | Meera Joshi | QA | 0 | 10 | TRUE ⛱️ |
| 5 | Arjun Menon | DevOps | 4 | 10 | FALSE |

---

### Table 14: EngineerSkill
```sql
INSERT INTO EngineerSkill (EngineerID, SkillID) VALUES
(1, 1), (1, 2), (1, 6), (2, 3), (2, 7), (3, 4), (3, 5), (4, 6), (5, 2), (5, 8);
```

| EngineerID | Engineer | Skills |
|------------|----------|--------|
| 1 | Vikram Singh | Java, Python, SQL |
| 2 | Ananya Reddy | React, Node.js |
| 3 | Karthik Nair | Swift, Kotlin |
| 4 | Meera Joshi | SQL |
| 5 | Arjun Menon | Python, AWS |

---

### Table 15: Bug
```sql
INSERT INTO Bug (Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES
('App crashes on iPhone 14', 'App crashes when loading bug list on iPhone 14 Pro Max', '2026-01-15 11:00:00', 'Review', 1, 3, 1, 2),
('Slow loading of reports', 'Bug reports take more than 10 seconds to load', '2026-01-17 10:00:00', 'Review', 3, 2, 2, 1),
('Login button not visible on dark mode', 'Login button disappears when dark mode is enabled', '2026-01-18 09:30:00', 'Internal', NULL, 1, 3, 4),
('API rate limiting not working', 'Rate limiting returns 500 instead of 429', '2026-01-19 14:00:00', 'Internal', NULL, 5, 2, 2),
('Data not syncing across devices', 'User data does not sync between mobile and web', '2026-01-20 08:45:00', 'Customer Support', NULL, 6, 1, 1);
```

| BugID | Title | Category | Priority | Status |
|-------|-------|----------|----------|--------|
| 1 | App crashes on iPhone 14 | Crash | 🔴 Critical | In Progress |
| 2 | Slow loading of reports | Performance | 🟠 High | Open |
| 3 | Login button not visible on dark mode | UI/UX | 🟡 Medium | Resolved ✅ |
| 4 | API rate limiting not working | Functionality | 🟠 High | In Progress |
| 5 | Data not syncing across devices | Data Loss | 🔴 Critical | Open |

---

### Table 16: DuplicateBug
```sql
INSERT INTO DuplicateBug (OriginalBugID, DuplicateBugID, LinkedAt) VALUES
(1, 2, '2026-01-20 15:30:00');
```

| DuplicateID | OriginalBugID | DuplicateBugID | LinkedAt |
|-------------|---------------|----------------|----------|
| 1 | 1 | 2 | 2026-01-20 15:30:00 |

*Bug 2 (slow loading) is potentially a duplicate of Bug 1 (crash)*

---

### Table 17: BugAssignment
```sql
INSERT INTO BugAssignment (BugID, EngineerID, AssignedAt, DueBy, CompletedAt) VALUES
(1, 3, '2026-01-15 12:00:00', '2026-01-15 16:00:00', NULL),
(2, 1, '2026-01-17 11:00:00', '2026-01-18 11:00:00', NULL),
(3, 2, '2026-01-18 10:00:00', '2026-01-21 10:00:00', '2026-01-19 14:30:00'),
(4, 1, '2026-01-19 15:00:00', '2026-01-20 15:00:00', NULL),
(5, 3, '2026-01-20 09:00:00', '2026-01-20 13:00:00', NULL);
```

| AssignmentID | Bug | Engineer | Status |
|--------------|-----|----------|--------|
| 1 | App crashes on iPhone 14 | Karthik Nair | 🔄 In Progress |
| 2 | Slow loading of reports | Vikram Singh | 🔄 In Progress |
| 3 | Login button not visible | Ananya Reddy | ✅ Completed |
| 4 | API rate limiting | Vikram Singh | 🔄 In Progress |
| 5 | Data not syncing | Karthik Nair | 🔄 In Progress |

---

### Table 18: AppVersion
```sql
INSERT INTO AppVersion (AppID, VersionNumber, ReleaseNotes) VALUES
(1, '1.0.0', 'Initial release of Patchly Mobile'),
(1, '1.1.0', 'Bug fixes and performance improvements'),
(1, '1.2.0', 'Added dark mode support'),
(2, '2.0.0', 'Complete dashboard redesign'),
(3, '1.0.0', 'Initial API release'),
(4, '1.0.0', 'Initial desktop release');
```

| VersionID | App | VersionNumber | ReleaseNotes |
|-----------|-----|---------------|--------------|
| 1 | Patchly Mobile | 1.0.0 | Initial release |
| 2 | Patchly Mobile | 1.1.0 | Bug fixes and performance improvements |
| 3 | Patchly Mobile | 1.2.0 | Added dark mode support |
| 4 | Patchly Web | 2.0.0 | Complete dashboard redesign |
| 5 | Patchly API | 1.0.0 | Initial API release |
| 6 | Patchly Desktop | 1.0.0 | Initial desktop release |

---

### Table 19: Release
```sql
INSERT INTO `Release` (VersionID, ReleaseDate, DeploymentStatus, Notes) VALUES
(1, '2025-12-01 10:00:00', 'Deployed', 'Successful initial launch'),
(2, '2026-01-10 14:00:00', 'Deployed', 'Hotfix deployment'),
(3, '2026-01-25 09:00:00', 'Deployed', 'Dark mode release'),
(4, '2026-01-20 11:00:00', 'Deployed', 'Major UI update'),
(5, '2025-12-15 16:00:00', 'Deployed', 'API v1 launch'),
(6, NULL, 'Scheduled', 'Pending QA approval');
```

| ReleaseID | Version | DeploymentStatus | ReleaseDate |
|-----------|---------|------------------|-------------|
| 1 | 1.0.0 | ✅ Deployed | 2025-12-01 |
| 2 | 1.1.0 | ✅ Deployed | 2026-01-10 |
| 3 | 1.2.0 | ✅ Deployed | 2026-01-25 |
| 4 | 2.0.0 | ✅ Deployed | 2026-01-20 |
| 5 | 1.0.0 | ✅ Deployed | 2025-12-15 |
| 6 | 1.0.0 | 📅 Scheduled | Pending |

---

### Table 20: Rollback
```sql
INSERT INTO Rollback (ReleaseID, RollbackDate, Reason) VALUES
(3, '2026-01-25 12:00:00', 'Dark mode caused login button visibility issue - Bug #3');
```

| RollbackID | ReleaseID | Version | RollbackDate | Reason |
|------------|-----------|---------|--------------|--------|
| 1 | 3 | 1.2.0 | 2026-01-25 12:00 | Dark mode caused login button visibility issue |

---

### Table 21: ReleaseBugFix
```sql
INSERT INTO ReleaseBugFix (ReleaseID, BugID) VALUES
(2, 1), (2, 2), (3, 3);
```

| ReleaseID | Version | BugID | Bug Fixed |
|-----------|---------|-------|-----------|
| 2 | 1.1.0 | 1 | App crashes on iPhone 14 |
| 2 | 1.1.0 | 2 | Slow loading of reports |
| 3 | 1.2.0 | 3 | Login button not visible on dark mode |

---

### Table 22: SLA
```sql
INSERT INTO SLA (PriorityID, MaxResolutionHours, PenaltyCost) VALUES
(1, 4, 5000.00),
(2, 24, 2000.00),
(3, 72, 500.00),
(4, 168, 0.00);
```

| SLAID | Priority | MaxResolutionHours | PenaltyCost |
|-------|----------|-------------------|-------------|
| 1 | 🔴 Critical | 4 hours | ₹5,000 |
| 2 | 🟠 High | 24 hours | ₹2,000 |
| 3 | 🟡 Medium | 72 hours (3 days) | ₹500 |
| 4 | 🟢 Low | 168 hours (7 days) | ₹0 |

---

### Table 23: Penalty
```sql
INSERT INTO Penalty (BugID, SLAID, Amount, Reason, CreatedAt) VALUES
(1, 1, 5000.00, 'Critical bug exceeded 4-hour SLA deadline', '2026-01-15 17:00:00'),
(5, 1, 5000.00, 'Data sync issue not resolved within 4 hours', '2026-01-20 14:00:00');
```

| PenaltyID | BugID | Bug | Amount | Reason |
|-----------|-------|-----|--------|--------|
| 1 | 1 | App crashes on iPhone 14 | ₹5,000 | Exceeded 4-hour SLA |
| 2 | 5 | Data not syncing | ₹5,000 | Not resolved within 4 hours |

**Total Penalties: ₹10,000**

---

### Table 24: Downtime
```sql
INSERT INTO Downtime (AppID, StartTime, EndTime, Reason) VALUES
(1, '2026-01-15 10:30:00', '2026-01-15 11:45:00', 'App crash affecting iOS users'),
(2, '2026-01-20 08:00:00', '2026-01-20 08:30:00', 'Dashboard server maintenance'),
(3, '2026-01-19 14:00:00', '2026-01-19 15:00:00', 'API rate limiting issue causing 500 errors'),
(1, '2026-01-25 09:30:00', NULL, 'Dark mode release causing issues - investigating');
```

| DowntimeID | App | Duration | Status | Reason |
|------------|-----|----------|--------|--------|
| 1 | Patchly Mobile | 1h 15m | ✅ Resolved | App crash affecting iOS users |
| 2 | Patchly Web | 30m | ✅ Resolved | Server maintenance |
| 3 | Patchly API | 1h | ✅ Resolved | API rate limiting issue |
| 4 | Patchly Mobile | Ongoing | 🔴 Active | Dark mode release issues |

---

### Table 25: CustomerImpact
```sql
INSERT INTO CustomerImpact (BugID, AffectedUserCount, SeverityScore) VALUES
(1, 15000, 8.5),
(2, 8000, 6.0),
(3, 500, 3.0),
(4, 2000, 5.5),
(5, 25000, 9.5);
```

| ImpactID | Bug | AffectedUserCount | SeverityScore | Impact Level |
|----------|-----|-------------------|---------------|--------------|
| 1 | App crashes on iPhone 14 | 15,000 | 8.5 | 🔴 High |
| 2 | Slow loading of reports | 8,000 | 6.0 | 🟡 Medium |
| 3 | Login button not visible | 500 | 3.0 | 🟢 Low |
| 4 | API rate limiting | 2,000 | 5.5 | 🟡 Medium |
| 5 | Data not syncing | 25,000 | 9.5 | 🔴 Critical |

**Total Affected Users: 50,500**

---

## 🚀 How to Execute

### Step 1: Create Tables
```bash
# In MySQL Workbench, run:
File → Open SQL Script → PatchlyDB_Schema.sql → Execute (⚡)
```

### Step 2: Populate Data
```bash
# After tables are created, run:
File → Open SQL Script → PatchlyDB_SampleData.sql → Execute (⚡)
```

### Step 3: Verify Data
```sql
-- Run this query to verify record counts:
SELECT 'Users' AS TableName, COUNT(*) AS RecordCount FROM User
UNION ALL SELECT 'Apps', COUNT(*) FROM App
UNION ALL SELECT 'Bugs', COUNT(*) FROM Bug
UNION ALL SELECT 'Engineers', COUNT(*) FROM Engineer;
```

---

*Generated: 2026-02-04*
*Database: PatchlyDB - Software Bug Tracking System*
