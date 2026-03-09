const router = require('express').Router();
const { authenticate, authorize } = require('../middleware/auth');
const {
  getAllBugs, getBugById, createBug, updateBug, deleteBug, getDashboardStats
} = require('../controllers/bugController');

router.get('/dashboard', authenticate, getDashboardStats);
router.get('/', authenticate, getAllBugs);
router.get('/:id', authenticate, getBugById);
router.post('/', authenticate, createBug);
router.put('/:id', authenticate, updateBug);
router.delete('/:id', authenticate, authorize('admin'), deleteBug);

module.exports = router;
