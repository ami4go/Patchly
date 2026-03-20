# Patchly: Spotify Bug Tracking & Engineering Dashboard

This is a comprehensive, full-stack web application designed for a theoretical **Spotify Bug Tracking System**. It intelligently categorizes user reviews based on Sentiment via a localized LLM, converts negative sentiments into pending unassigned **Bugs**, and tracks SLA rules, engineer workloads, and financial/performance penalties.

---

## 🛠️ Tech Stack
* **Frontend:** HTML5, CSS3, JavaScript (Vanilla), Chart.js
* **Backend:** Python (Flask), Google Gemini LLM API
* **Database:** MySQL
* **Connector Driver:** `mysql-connector-python`

---

## 🚀 Step 1: Database Setup Instructions
To successfully initialize this project on a new machine, you **must run the three SQL scripts inside your MySQL Workbench in the exact order below:**

1. **`PatchlyDB_Schema.sql`**
   * *What it does:* Drops any existing `PatchlyDB` database, creates a fresh database structure, defines all the relational tables, sets foreign key constraints, and injects **physical Database Triggers** to ensure data integrity during bug assignments.
2. **`PatchlyDB_Spotify_SampleData.sql`**
   * *What it does:* Seeds the database with all primary lookup data (Platforms, Sentiments, Priority Levels, SLA rules, Engineering Skills, Department configurations, and System User Authentications). It also includes the first 5 base Spotify bug reports.
3. **`PatchlyDB_Spotify_20_Reviews.sql`**
   * *What it does:* Injects the bulk of the test data (Users, 20 extensive Spotify Reviews, generated Bugs, Engineers, and historical Assignments) so your dashboard has a large dataset of analytical information.

---

## 💻 Step 2: Python Environment Setup

1. **Ensure you have Python 3 installed.** 
   * A recent version like Python 3.10+ is recommended.
2. **Install Required Extensions via Pip:**
   Open your terminal in this project's base directory and run:
   ```bash
   pip install Flask mysql-connector-python google-generativeai python-dotenv
   ```
3. **Configure the Database Credentials:**
   * Open **`db_config.py`** in the project directory.
   * Edit the credentials inside the `DB_CONFIG` dictionary so they match your local MySQL root password exactly. For example:
     ```python
     DB_CONFIG = {
         'host': 'localhost',
         'user': 'root',
         'password': 'YourLocalPasswordHere',
         'database': 'PatchlyDB'
     }
     ```

*(Note: There is an `.env` file utilized by the application for safely storing your Google Gemini API Key. Since the API key handles Sentiment generation securely, test it cautiously so you do not burn your API tokens!).*

---

## ▶️ Step 3: Running the Application

Once your database is fully seeded and your Python environment is ready:
1. Open your terminal in the root directory.
2. Start the back-end application by running:
   ```bash
   python app.py
   ```
3. Open a browser of your choice (Chrome, Firefox, Safari) and navigate to **[http://localhost:5000](http://localhost:5000)** relative to your system.

---

## 🔐 Default Sandbox Logins
You can freely navigate the dual dashboards using the predefined credentials embedded in the Database Script:

**Admin Dashboard Access:**
* **Username:** `admin1`
* **Password:** `India@123`

**Engineer Dashboard Access (Examples):**
* **Username:** `alice`
* **Password:** `alice123`
* **Username:** `bob`
* **Password:** `bob123`

---
