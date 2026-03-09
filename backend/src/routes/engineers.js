const router = require('express').Router();
const { authenticate, authorize } = require('../middleware/auth');
const {
  getAllEngineers, getEngineerById, createEngineer, updateEngineer, deleteEngineer, assignBug
} = require('../controllers/engineerController');

router.get('/', authenticate, getAllEngineers);
router.get('/:id', authenticate, getEngineerById);
router.post('/', authenticate, authorize('admin', 'developer'), createEngineer);
router.put('/:id', authenticate, authorize('admin', 'developer'), updateEngineer);
router.delete('/:id', authenticate, authorize('admin'), deleteEngineer);
router.post('/:id/assign', authenticate, authorize('admin', 'developer'), assignBug);

module.exports = router;
