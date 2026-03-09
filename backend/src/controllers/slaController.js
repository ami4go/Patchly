const pool = require('../config/db');

const getSLAs = async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT s.*, p.PriorityLevel FROM SLA s JOIN Priority p ON s.PriorityID = p.PriorityID'
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const getPenalties = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT p.*, b.Title as BugTitle, s.MaxResolutionHours
       FROM Penalty p
       JOIN Bug b ON p.BugID = b.BugID
       JOIN SLA s ON p.SLAID = s.SLAID
       ORDER BY p.CreatedAt DESC`
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const createPenalty = async (req, res) => {
  try {
    const { bugId, slaId, amount, reason } = req.body;
    if (!bugId || !slaId || !amount) {
      return res.status(400).json({ success: false, message: 'bugId, slaId, amount are required' });
    }
    const [result] = await pool.query(
      'INSERT INTO Penalty (BugID, SLAID, Amount, Reason, CreatedAt) VALUES (?, ?, ?, ?, NOW())',
      [bugId, slaId, amount, reason || null]
    );
    res.status(201).json({ success: true, data: { penaltyId: result.insertId } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = { getSLAs, getPenalties, createPenalty };
