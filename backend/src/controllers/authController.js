const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../config/db');

const register = async (req, res) => {
  try {
    const { name, email, phone, role, password } = req.body;
    if (!name || !email || !password) {
      return res.status(400).json({ success: false, message: 'Name, email and password are required' });
    }
    const [existing] = await pool.query('SELECT UserID FROM User WHERE Email = ?', [email]);
    if (existing.length > 0) {
      return res.status(409).json({ success: false, message: 'Email already registered' });
    }
    const hash = await bcrypt.hash(password, 10);
    const userRole = role || 'company';
    const [result] = await pool.query(
      'INSERT INTO User (Name, Email, Phone, Role, PasswordHash) VALUES (?, ?, ?, ?, ?)',
      [name, email, phone || null, userRole, hash]
    );
    const token = jwt.sign(
      { userId: result.insertId, email, role: userRole },
      process.env.JWT_SECRET || 'secret',
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );
    res.status(201).json({ success: true, token, user: { id: result.insertId, name, email, role: userRole } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email and password are required' });
    }
    const [rows] = await pool.query('SELECT * FROM User WHERE Email = ?', [email]);
    if (rows.length === 0) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
    const user = rows[0];
    const match = await bcrypt.compare(password, user.PasswordHash);
    if (!match) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
    const token = jwt.sign(
      { userId: user.UserID, email: user.Email, role: user.Role },
      process.env.JWT_SECRET || 'secret',
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );
    res.json({ success: true, token, user: { id: user.UserID, name: user.Name, email: user.Email, role: user.Role } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const me = async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT UserID, Name, Email, Phone, Role, CreatedAt FROM User WHERE UserID = ?', [req.user.userId]);
    if (rows.length === 0) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, data: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = { register, login, me };
