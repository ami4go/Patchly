const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const { getAllReviews, createReview } = require('../controllers/reviewController');

router.get('/', authenticate, getAllReviews);
router.post('/', authenticate, createReview);

module.exports = router;
