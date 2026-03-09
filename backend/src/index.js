require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const app = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate limiting for auth routes (prevent brute force)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 20,
  message: { success: false, message: 'Too many requests, please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// General API rate limiter
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 500,
  message: { success: false, message: 'Too many requests, please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Routes
app.use('/api/auth', authLimiter, require('./routes/auth'));
app.use('/api/bugs', apiLimiter, require('./routes/bugs'));
app.use('/api/engineers', apiLimiter, require('./routes/engineers'));
app.use('/api/reviews', apiLimiter, require('./routes/reviews'));
app.use('/api/releases', apiLimiter, require('./routes/releases'));
app.use('/api/sla', apiLimiter, require('./routes/sla'));
app.use('/api', apiLimiter, require('./routes/common'));

// Health check
app.get('/api/health', (req, res) => {
  res.json({ success: true, message: 'Patchly API is running', timestamp: new Date().toISOString() });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ success: false, message: 'Internal server error' });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Patchly API running on port ${PORT}`);
});

module.exports = app;
