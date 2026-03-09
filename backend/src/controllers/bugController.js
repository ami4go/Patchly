const pool = require('../config/db');

// ── BUGS ──────────────────────────────────────────────────────────────────────

const getAllBugs = async (req, res) => {
  try {
    const { status, priority, category, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;
    let where = [];
    let params = [];
    if (status) { where.push('s.StatusName = ?'); params.push(status); }
    if (priority) { where.push('p.PriorityLevel = ?'); params.push(priority); }
    if (category) { where.push('c.CategoryName = ?'); params.push(category); }
    const whereClause = where.length ? 'WHERE ' + where.join(' AND ') : '';
    const sql = `
      SELECT b.*, p.PriorityLevel, s.StatusName, c.CategoryName
      FROM Bug b
      LEFT JOIN Priority p ON b.PriorityID = p.PriorityID
      LEFT JOIN Status s ON b.StatusID = s.StatusID
      LEFT JOIN BugCategory c ON b.CategoryID = c.CategoryID
      ${whereClause}
      ORDER BY b.CreatedAt DESC
      LIMIT ? OFFSET ?`;
    params.push(parseInt(limit), parseInt(offset));
    const [rows] = await pool.query(sql, params);
    const [[{ total }]] = await pool.query(
      `SELECT COUNT(*) as total FROM Bug b LEFT JOIN Priority p ON b.PriorityID=p.PriorityID LEFT JOIN Status s ON b.StatusID=s.StatusID LEFT JOIN BugCategory c ON b.CategoryID=c.CategoryID ${whereClause}`,
      params.slice(0, -2)
    );
    res.json({ success: true, data: rows, total, page: parseInt(page), limit: parseInt(limit) });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const getBugById = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT b.*, p.PriorityLevel, s.StatusName, c.CategoryName
       FROM Bug b
       LEFT JOIN Priority p ON b.PriorityID = p.PriorityID
       LEFT JOIN Status s ON b.StatusID = s.StatusID
       LEFT JOIN BugCategory c ON b.CategoryID = c.CategoryID
       WHERE b.BugID = ?`,
      [req.params.id]
    );
    if (!rows.length) return res.status(404).json({ success: false, message: 'Bug not found' });
    res.json({ success: true, data: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const createBug = async (req, res) => {
  try {
    const { title, description, sourceType, reviewId, categoryId, priorityId, statusId } = req.body;
    if (!title || !priorityId || !statusId) {
      return res.status(400).json({ success: false, message: 'Title, priorityId, statusId are required' });
    }
    const [result] = await pool.query(
      'INSERT INTO Bug (Title, Description, CreatedAt, SourceType, ReviewID, CategoryID, PriorityID, StatusID) VALUES (?, ?, NOW(), ?, ?, ?, ?, ?)',
      [title, description || null, sourceType || null, reviewId || null, categoryId || null, priorityId, statusId]
    );
    res.status(201).json({ success: true, data: { bugId: result.insertId } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const updateBug = async (req, res) => {
  try {
    const { title, description, categoryId, priorityId, statusId } = req.body;
    await pool.query(
      'UPDATE Bug SET Title=IFNULL(?,Title), Description=IFNULL(?,Description), CategoryID=IFNULL(?,CategoryID), PriorityID=IFNULL(?,PriorityID), StatusID=IFNULL(?,StatusID) WHERE BugID=?',
      [title || null, description || null, categoryId || null, priorityId || null, statusId || null, req.params.id]
    );
    res.json({ success: true, message: 'Bug updated' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const deleteBug = async (req, res) => {
  try {
    await pool.query('DELETE FROM Bug WHERE BugID = ?', [req.params.id]);
    res.json({ success: true, message: 'Bug deleted' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ── DASHBOARD STATS ───────────────────────────────────────────────────────────

const getDashboardStats = async (req, res) => {
  try {
    const [bugsByStatus] = await pool.query(
      'SELECT s.StatusName as name, COUNT(*) as value FROM Bug b JOIN Status s ON b.StatusID=s.StatusID GROUP BY s.StatusName'
    );
    const [bugsByPriority] = await pool.query(
      'SELECT p.PriorityLevel as name, COUNT(*) as value FROM Bug b JOIN Priority p ON b.PriorityID=p.PriorityID GROUP BY p.PriorityLevel'
    );
    const [recentBugs] = await pool.query(
      'SELECT DATE(CreatedAt) as date, COUNT(*) as count FROM Bug WHERE CreatedAt >= DATE_SUB(NOW(), INTERVAL 30 DAY) GROUP BY DATE(CreatedAt) ORDER BY date'
    );
    const [totalsRows] = await pool.query(
      `SELECT
        (SELECT COUNT(*) FROM Bug) as totalBugs,
        (SELECT COUNT(*) FROM Bug b JOIN Status s ON b.StatusID=s.StatusID WHERE s.StatusName='OPEN') as openBugs,
        (SELECT COUNT(*) FROM Engineer) as totalEngineers,
        (SELECT COUNT(*) FROM \`Release\`) as totalReleases,
        (SELECT COUNT(*) FROM Penalty) as totalPenalties,
        (SELECT COALESCE(SUM(Amount),0) FROM Penalty) as totalPenaltyAmount`
    );

    res.json({
      success: true,
      data: {
        totals: totalsRows[0],
        bugsByStatus,
        bugsByPriority,
        recentBugs,
      }
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = { getAllBugs, getBugById, createBug, updateBug, deleteBug, getDashboardStats };
