# 🐛 Patchly - Software Bug Tracking & Reliability Management System

A full-stack, production-ready Software Reliability Management System built with **Next.js**, **Node.js/Express**, and **MySQL**. Patchly tracks the complete lifecycle of software bugs — from user reviews and feedback to bug assignment, SLA enforcement, and release management.

---

## 🏗️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Next.js 15 (App Router), TypeScript, Tailwind CSS, Recharts |
| **Backend** | Node.js, Express, JWT Authentication |
| **Database** | MySQL 8.0 (25 tables, indexes, triggers) |
| **Deployment** | Docker Compose |

---

## 🎯 Features

### 📊 Dashboard
- Real-time stats: total bugs, open bugs, engineers, releases, penalty amounts
- Interactive charts: Bugs by Status (Pie), Bugs by Priority (Bar), 30-day trend (Line)

### 🐛 Bug Management
- Full CRUD with filtering by status, priority, category
- Pagination with search
- Auto-bug creation from low-rated reviews (via DB trigger)

### 👷 Engineer Management
- Engineer profiles with department, skills, workload tracking
- Visual workload progress bars
- Workload limit enforcement at database level (trigger)
- Leave management

### 📦 Release Management
- Release lifecycle: PENDING → DEPLOYED → STABLE / ROLLED BACK
- One-click rollback with automatic bug reopening
- Version tracking per app

### 🛡️ SLA & Penalties
- Configurable SLA rules per priority level
- Penalty tracking with amounts and reasons
- Breach logging

### ⭐ Reviews
- Multi-platform user reviews (Play Store, App Store, Email)
- Star ratings, sentiment scores
- Auto-bug detection for low ratings

### 🔐 Authentication & RBAC
- JWT-based authentication
- Three roles: `admin`, `developer`, `company`
- Route-level access control

---

## 🗄️ Database Schema (25 Tables)

```
Module 1 - Feedback & Reviews:
  User, App, Review, Platform, Sentiment, AppPlatform, ReviewSentiment

Module 2 - Bug Management:
  Bug, BugCategory, Priority, Status, DuplicateBug, BugAssignment

Module 3 - Engineering Team:
  Engineer, Department, Skill, EngineerSkill

Module 4 - Release Management:
  AppVersion, Release, Rollback, ReleaseBugFix

Module 5 - SLA & Quality:
  SLA, Penalty, Downtime, CustomerImpact
```

### Database Triggers
| Trigger | Purpose |
|---------|---------|
| `trg_auto_bug_from_review` | Auto-creates a bug when a review has rating ≤ 2 |
| `trg_check_workload_before_assign` | Prevents assignment if engineer is on leave or at max workload |
| `trg_increment_workload` | Increments engineer workload on new assignment |
| `trg_decrement_workload` | Decrements engineer workload when assignment is completed |
| `trg_log_sla_breach` | Validates penalty amounts before insertion |

### Strategic Indexes
- `idx_bug_priorityid`, `idx_bug_statusid`, `idx_bug_categoryid`, `idx_bug_createdat`
- `idx_review_rating`, `idx_review_timestamp`, `idx_review_appid`
- `idx_engineer_workload`, `idx_engineer_onleave`, `idx_engineer_departmentid`
- `idx_release_status`, `idx_release_date`
- `idx_penalty_bugid`, `idx_penalty_createdat`

---

## 🚀 Quick Start

### Option 1: Docker Compose (Recommended)

```bash
git clone <repo-url>
cd patchly1

# Start all services
docker compose up -d

# Access the app
# Frontend: http://localhost:3000
# Backend API: http://localhost:5000
```

### Option 2: Manual Setup

#### Prerequisites
- Node.js 20+
- MySQL 8.0+

#### 1. Database Setup
```bash
mysql -u root -p < database/schema.sql
```

#### 2. Backend Setup
```bash
cd backend
cp .env.example .env
# Edit .env with your database credentials

npm install
npm run dev
# API running on http://localhost:5000
```

#### 3. Frontend Setup
```bash
cd frontend
cp .env.local.example .env.local
# NEXT_PUBLIC_API_URL=http://localhost:5000/api

npm install
npm run dev
# App running on http://localhost:3000
```

---

## 🔑 Default Credentials

| Email | Password | Role |
|-------|---------|------|
| admin@patchly.com | password | admin |

> ⚠️ Change the default password in production!

---

## 📡 API Reference

### Authentication
```
POST /api/auth/register   - Register new user
POST /api/auth/login      - Login (returns JWT)
GET  /api/auth/me         - Get current user
```

### Bugs
```
GET    /api/bugs           - List bugs (with filters: status, priority, category, page, limit)
GET    /api/bugs/:id       - Get bug details
POST   /api/bugs           - Create bug
PUT    /api/bugs/:id       - Update bug
DELETE /api/bugs/:id       - Delete bug (admin only)
GET    /api/bugs/dashboard - Dashboard statistics
```

### Engineers
```
GET    /api/engineers          - List engineers
GET    /api/engineers/:id      - Get engineer + skills
POST   /api/engineers          - Create engineer
PUT    /api/engineers/:id      - Update engineer
DELETE /api/engineers/:id      - Delete engineer (admin only)
POST   /api/engineers/:id/assign - Assign bug to engineer
```

### Releases
```
GET  /api/releases              - List releases
POST /api/releases              - Create release
PUT  /api/releases/:id/status   - Update deployment status
POST /api/releases/:id/rollback - Rollback release
```

### SLA & Penalties
```
GET  /api/sla/slas        - List SLA definitions
GET  /api/sla/penalties   - List penalty records
POST /api/sla/penalties   - Create penalty (admin only)
```

### Lookup Data
```
GET /api/apps           GET /api/priorities
GET /api/departments    GET /api/statuses
GET /api/skills         GET /api/categories
GET /api/platforms      GET /api/users (admin)
GET /api/downtime       GET /api/impacts
```

---

## 📁 Project Structure

```
patchly1/
├── database/
│   └── schema.sql          # Complete MySQL schema with indexes & triggers
├── backend/
│   ├── src/
│   │   ├── config/db.js    # MySQL connection pool
│   │   ├── controllers/    # Business logic
│   │   ├── middleware/     # JWT auth, RBAC
│   │   ├── routes/         # Express routers
│   │   └── index.js        # App entry point
│   ├── Dockerfile
│   └── package.json
├── frontend/
│   ├── src/
│   │   ├── app/            # Next.js App Router pages
│   │   │   ├── dashboard/  # Stats & charts
│   │   │   ├── bugs/       # Bug tracker
│   │   │   ├── engineers/  # Team management
│   │   │   ├── releases/   # Release management
│   │   │   ├── sla/        # SLA & penalties
│   │   │   ├── reviews/    # User reviews
│   │   │   └── login/      # Authentication
│   │   ├── components/     # Reusable UI components
│   │   └── lib/            # API client, auth context
│   ├── Dockerfile
│   └── package.json
├── docker-compose.yml
└── Readme.md
```

---

## 🛡️ Security

- Passwords hashed with **bcrypt** (10 rounds)
- **JWT** tokens with configurable expiry
- **Helmet.js** for HTTP security headers
- **CORS** protection
- Role-based access control on all sensitive endpoints
- Database-level constraints prevent data integrity violations

---

## 📊 DBMS Features Demonstrated

| Feature | Implementation |
|---------|---------------|
| **25+ Entity Tables** | Covers all 5 modules |
| **3NF Normalization** | No redundancy, proper FK relationships |
| **Integrity Constraints** | CHECK (Rating 1-5, Workload limits), UNIQUE, NOT NULL, FK |
| **Indexes** | 20+ strategic indexes on query-heavy columns |
| **Triggers** | 5 business-logic triggers |
| **Transactions** | Rollback triggers multi-step status changes |
| **Complex Joins** | Dashboard queries span 4+ tables |
| **Aggregations** | GROUP BY, COUNT, SUM across modules |
