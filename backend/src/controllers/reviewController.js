const pool = require('../config/db');

const getAllReviews = async (req, res) => {
  try {
    const { page = 1, limit = 20, appId } = req.query;
    const offset = (page - 1) * limit;
    let where = appId ? 'WHERE r.AppID = ?' : '';
    let params = appId ? [parseInt(appId)] : [];
    const [rows] = await pool.query(
      `SELECT r.*, u.Name as UserName, a.AppName
       FROM Review r
       LEFT JOIN User u ON r.UserID = u.UserID
       LEFT JOIN App a ON r.AppID = a.AppID
       ${where}
       ORDER BY r.Timestamp DESC
       LIMIT ? OFFSET ?`,
      [...params, parseInt(limit), parseInt(offset)]
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const createReview = async (req, res) => {
  try {
    const { userId, appId, content, rating, sentimentScore } = req.body;
    if (!userId || !appId || !rating) {
      return res.status(400).json({ success: false, message: 'userId, appId, rating are required' });
    }
    const [result] = await pool.query(
      'INSERT INTO Review (UserID, AppID, Content, Rating, Timestamp, SentimentScore) VALUES (?, ?, ?, ?, NOW(), ?)',
      [userId, appId, content || null, rating, sentimentScore || null]
    );
    res.status(201).json({ success: true, data: { reviewId: result.insertId } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = { getAllReviews, createReview };
