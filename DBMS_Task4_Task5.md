# PatchlyDB: DBMS Academic Submission Guide

This document answers the specific grading criteria for **Task 4** (SQL Queries) and **Task 5** (Embedded SQL and Database Triggers) for the PatchlyDB Spotify Bug Tracking System.

---

## 📌 TASK 5: Triggers & Embedded SQL Operations

As requested, the Python Web Application (`app.py`) utilizes Embedded SQL executed via the `mysql.connector` library to interact with the database in real-time. 

Alongside the application-level logic, we have defined **six strict Database-Level Triggers** inside `PatchlyDB_Schema.sql`. These triggers act as physical safeguards to ensure data integrity during Assignment events.

### 1. The Workload Capacity Check Trigger (`TRG_CheckEngineerWorkload_BeforeAssign`)
* **When it runs:** `BEFORE INSERT ON BugAssignment`
* **What it does:** Before a bug can be assigned to an engineer, this trigger physically checks the `CurrentWorkload` and `MaxWorkload` columns inside the `Engineer` table. 
* **How it works:** If the assignment would push the engineer over their allowed capacity, the database intercepts the `INSERT` operation and forces it to fail, raising a custom `45000` SQL Error ("Assignment Failed: Engineer is already at maximum capacity."). This ensures no engineer is ever overloaded, defending the integrity of the data even if the frontend GUI bypasses a check.

### 2. The Auto-Workload Decrement Trigger (`TRG_FreeEngineerWorkload_AfterComplete`)
* **When it runs:** `AFTER UPDATE ON BugAssignment`
* **What it does:** Whenever an Engineer resolves a bug, this trigger automatically reduces their active workload count by 1.
* **How it works:** It listens for an `UPDATE` command on a bug assignment where `CompletedAt` changes from `NULL` to a valid timestamp. As soon as that happens, the trigger fires an `UPDATE` on the `Engineer` table, safely reducing `CurrentWorkload` by 1 (preventing it from dropping below 0). This eliminates the need for the Python backend to manually manage workload decrements, keeping the logic centralized at the DB level.

*Note: The frontend interactions like resolving tickets in the Engineer Dashboard heavily rely on these triggers working seamlessly in the background!*

### 3. The Data Integrity Trigger (`TRG_EnforceValidRating_BeforeInsert`)
* **When it runs:** `BEFORE INSERT ON Review`
* **What it does:** Ensures that no junk data (e.g., negative numbers, or numbers over 5) can ever be inserted into the `Rating` column of a review.
* **How it works:** Throws a `45000` SQL Error ("Invalid Data: Review Rating must be strictly between 1 and 5") if the condition is breached.

### 4. The SLA Protection Trigger (`TRG_PreventPastDeadline_BeforeAssign`)
* **When it runs:** `BEFORE INSERT ON BugAssignment`
* **What it does:** Prevents an Engineer from maliciously or accidentally being assigned a deadline (`DueBy`) that has already passed before they even get the ticket.
* **How it works:** Compares `NEW.DueBy <= NEW.AssignedAt`. If the deadline is in the past, it aborts the assignment to protect the Engineer's SLA score.

### 5. The Security Trigger (`TRG_ProtectAdmin_BeforeDelete`)
* **When it runs:** `BEFORE DELETE ON SystemUser`
* **What it does:** Completely blocks the deletion of any account holding the `admin` role, preventing accidental lockouts of the entire system.
* **How it works:** Throws a Security Violation error if `OLD.Role = 'admin'` during a `DELETE` operation.

### 6. The Silent Assistance Trigger (`TRG_AutoSetReviewDate_BeforeInsert`)
* **When it runs:** `BEFORE INSERT ON Review`
* **What it does:** Automatically assigns the precise system time to a Review log if the API or user submitting it forgot to include a timestamp.
* **How it works:** Identifies `IF NEW.Timestamp IS NULL` and intelligently rectifies it by silently modifying `NEW.Timestamp = NOW()` right before the row hits the database.

---

## 📌 TASK 4: The 15 Relational SQL Queries Explained

The system utilizes exactly 15 complex queries located in `PatchlyDB_Task4_Queries.sql` to populate analytics for the Dashboards. These encompass complex aggregations, joins, date-time mathematics, and subqueries.

### Query Summary Breakdown:

1. **Engineer Overview:** Returns all engineers with a concatenated string of their active skills (`GROUP_CONCAT`) and calculates if they are "At Capacity" or "Normal". (Joins `Engineer` with `Department` and `Skill` tables).
2. **Pending Bugs by Platform:** Counts all open Apple, Windows, and Android bugs using `SUM(CASE WHEN...)` logic across 5 tables to detect where the most critical Spotify problems currently exist.
3. **SLA Breach Report:** Checks the `Penalty` table against the `Engineer` assignments, calculating the total financial cost of breaches per Developer dynamically.
4. **Sentiment Conversion Rate:** Uses sub-aggregations to show how many reviews with "Frustrated" or "Angry" sentiments strictly converted into system Bugs versus generic complaints.
5. **Engineer Dashboard Task List:** Runs Date Math (`TIMESTAMPDIFF`) against `NOW()` and the `DueBy` SLA timestamp to dynamically flag open bugs as "ON TRACK", "URGENT", or "OVERDUE" for the logged-in engineer.
6. **Smart Assignment Algorithm:** A massive subquery `IN` statement that scans all engineers for specific skillset strings (like "iOS/Swift" or "React Native") AND matches them against `(MaxWorkload - CurrentWorkload)` metrics to find the absolute best person to assign a bug to.
7. **Unlogged Target Reviews:** Utilizes an `OUTER JOIN` and an `IS NULL` check to find 1-Star or 2-Star Spotify reviews that inexplicably did not trigger the AI Bug Logger, acting as a manual QA safety net.
8. **QA Resolution Average:** Performs `AVG(TIMESTAMPDIFF(HOUR...))` logic across all historical assignments to map precisely how many hours it takes to fix "Critical" vs "Low" priority issues.
9. **Platform Sentiment Analysis:** Groups the `Review`, `Platform`, and `Bug` tables to dynamically calculate the average AI Sentiment Score across different devices (iOS vs Android) and correlated bug generation rates.
10. **Department KPI Aggregation:** Uses complex `SUM(CASE WHEN...)` conditional logic across the `BugAssignment` and `Bug` tables to dynamically group all bug lifecycles (Open, Resolved On-Time, Deadline Breached) by their parent system Department.
11. **Financial Penalty by Department:** Aggregates all Engineer penalties and groups them by their parent `Department` (e.g., "Mobile Engineering") to isolate which department is costing the company the most SLA money.
12. **High Performers:** Joins the Penalty, Engineer, and BugAssignment tables, filtering strictly for negative penalty amounts (`p.Amount < 0`) to isolate engineers who resolved bugs so fast they earned bonus performance points.
13. **Release Stability Check:** Inspects the `Release` and `Rollback` tables. If a version update caused a rollback within 24 hours, it isolates the reasons why.
14. **Cross-Platform Bugs:** Uses `HAVING COUNT(DISTINCT...) > 1` logic to find singular bugs that are explicitly reported as occurring on both iOS *and* Windows simultaneously.
15. **Engineer Success Rate:** A complex conditional aggregation that compares an individual engineer's number of "On-Time" bug completions against their personal total assigned pool to output a percentage-based Success Score.
