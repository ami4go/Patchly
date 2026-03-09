const pool = require('../config/db');

const getAllEngineers = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT e.*, d.DepartmentName
       FROM Engineer e
       LEFT JOIN Department d ON e.DepartmentID = d.DepartmentID
       ORDER BY e.Name`
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const getEngineerById = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT e.*, d.DepartmentName
       FROM Engineer e
       LEFT JOIN Department d ON e.DepartmentID = d.DepartmentID
       WHERE e.EngineerID = ?`,
      [req.params.id]
    );
    if (!rows.length) return res.status(404).json({ success: false, message: 'Engineer not found' });
    const [skills] = await pool.query(
      `SELECT s.SkillID, s.SkillName FROM EngineerSkill es
       JOIN Skill s ON es.SkillID = s.SkillID
       WHERE es.EngineerID = ?`,
      [req.params.id]
    );
    res.json({ success: true, data: { ...rows[0], skills } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const createEngineer = async (req, res) => {
  try {
    const { name, email, departmentId, maxWorkload, isOnLeave, skillIds } = req.body;
    if (!name || !email || !departmentId) {
      return res.status(400).json({ success: false, message: 'Name, email, departmentId are required' });
    }
    const [result] = await pool.query(
      'INSERT INTO Engineer (Name, Email, DepartmentID, MaxWorkload, IsOnLeave) VALUES (?, ?, ?, ?, ?)',
      [name, email, departmentId, maxWorkload || 10, isOnLeave || false]
    );
    const engineerId = result.insertId;
    if (skillIds && skillIds.length > 0) {
      const values = skillIds.map(sid => [engineerId, sid]);
      await pool.query('INSERT IGNORE INTO EngineerSkill (EngineerID, SkillID) VALUES ?', [values]);
    }
    res.status(201).json({ success: true, data: { engineerId } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const updateEngineer = async (req, res) => {
  try {
    const { name, email, departmentId, maxWorkload, isOnLeave } = req.body;
    await pool.query(
      'UPDATE Engineer SET Name=IFNULL(?,Name), Email=IFNULL(?,Email), DepartmentID=IFNULL(?,DepartmentID), MaxWorkload=IFNULL(?,MaxWorkload), IsOnLeave=IFNULL(?,IsOnLeave) WHERE EngineerID=?',
      [name || null, email || null, departmentId || null, maxWorkload !== undefined ? maxWorkload : null, isOnLeave !== undefined ? isOnLeave : null, req.params.id]
    );
    res.json({ success: true, message: 'Engineer updated' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const deleteEngineer = async (req, res) => {
  try {
    await pool.query('DELETE FROM Engineer WHERE EngineerID = ?', [req.params.id]);
    res.json({ success: true, message: 'Engineer deleted' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const assignBug = async (req, res) => {
  try {
    const { bugId, dueBy } = req.body;
    const engineerId = req.params.id;
    if (!bugId) return res.status(400).json({ success: false, message: 'bugId is required' });
    const [result] = await pool.query(
      'INSERT INTO BugAssignment (BugID, EngineerID, AssignedAt, DueBy) VALUES (?, ?, NOW(), ?)',
      [bugId, engineerId, dueBy || null]
    );
    // Update bug status to IN PROGRESS
    await pool.query(
      'UPDATE Bug SET StatusID = (SELECT StatusID FROM Status WHERE StatusName = "IN PROGRESS" LIMIT 1) WHERE BugID = ?',
      [bugId]
    );
    res.status(201).json({ success: true, data: { assignmentId: result.insertId } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = { getAllEngineers, getEngineerById, createEngineer, updateEngineer, deleteEngineer, assignBug };
