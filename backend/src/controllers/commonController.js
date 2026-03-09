const pool = require('../config/db');

// Generic CRUD for lookup tables
const getAll = (table, orderCol) => async (req, res) => {
  try {
    const [rows] = await pool.query(`SELECT * FROM ${table} ORDER BY ${orderCol}`);
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// Apps
const getAllApps = getAll('App', 'AppName');
const createApp = async (req, res) => {
  try {
    const { appName, description } = req.body;
    if (!appName) return res.status(400).json({ success: false, message: 'appName is required' });
    const [result] = await pool.query('INSERT INTO App (AppName, Description) VALUES (?, ?)', [appName, description || null]);
    res.status(201).json({ success: true, data: { appId: result.insertId } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// Departments
const getAllDepartments = getAll('Department', 'DepartmentName');

// Skills
const getAllSkills = getAll('Skill', 'SkillName');

// Platforms
const getAllPlatforms = getAll('Platform', 'PlatformName');

// Priorities
const getAllPriorities = getAll('Priority', 'PriorityID');

// Statuses
const getAllStatuses = getAll('Status', 'StatusID');

// BugCategories
const getAllCategories = getAll('BugCategory', 'CategoryName');

// Users (admin only)
const getAllUsers = async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT UserID, Name, Email, Phone, Role, CreatedAt FROM User ORDER BY CreatedAt DESC');
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// Downtime
const getAllDowntime = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT d.*, a.AppName FROM Downtime d JOIN App a ON d.AppID = a.AppID ORDER BY d.StartTime DESC`
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const createDowntime = async (req, res) => {
  try {
    const { appId, startTime, endTime, reason } = req.body;
    if (!appId || !startTime) return res.status(400).json({ success: false, message: 'appId and startTime are required' });
    const [result] = await pool.query(
      'INSERT INTO Downtime (AppID, StartTime, EndTime, Reason) VALUES (?, ?, ?, ?)',
      [appId, startTime, endTime || null, reason || null]
    );
    res.status(201).json({ success: true, data: { downtimeId: result.insertId } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// Customer Impact
const getAllImpacts = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT ci.*, b.Title as BugTitle FROM CustomerImpact ci JOIN Bug b ON ci.BugID = b.BugID ORDER BY ci.SeverityScore DESC`
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const createImpact = async (req, res) => {
  try {
    const { bugId, affectedUserCount, severityScore } = req.body;
    if (!bugId) return res.status(400).json({ success: false, message: 'bugId is required' });
    const [result] = await pool.query(
      'INSERT INTO CustomerImpact (BugID, AffectedUserCount, SeverityScore) VALUES (?, ?, ?)',
      [bugId, affectedUserCount || null, severityScore || null]
    );
    res.status(201).json({ success: true, data: { impactId: result.insertId } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = {
  getAllApps, createApp,
  getAllDepartments, getAllSkills, getAllPlatforms,
  getAllPriorities, getAllStatuses, getAllCategories,
  getAllUsers, getAllDowntime, createDowntime,
  getAllImpacts, createImpact,
};
