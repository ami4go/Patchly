const router = require('express').Router();
const { authenticate, authorize } = require('../middleware/auth');
const {
  getAllApps, createApp,
  getAllDepartments, getAllSkills, getAllPlatforms,
  getAllPriorities, getAllStatuses, getAllCategories,
  getAllUsers, getAllDowntime, createDowntime,
  getAllImpacts, createImpact,
} = require('../controllers/commonController');

router.get('/apps', authenticate, getAllApps);
router.post('/apps', authenticate, authorize('admin'), createApp);
router.get('/departments', authenticate, getAllDepartments);
router.get('/skills', authenticate, getAllSkills);
router.get('/platforms', authenticate, getAllPlatforms);
router.get('/priorities', authenticate, getAllPriorities);
router.get('/statuses', authenticate, getAllStatuses);
router.get('/categories', authenticate, getAllCategories);
router.get('/users', authenticate, authorize('admin'), getAllUsers);
router.get('/downtime', authenticate, getAllDowntime);
router.post('/downtime', authenticate, createDowntime);
router.get('/impacts', authenticate, getAllImpacts);
router.post('/impacts', authenticate, createImpact);

module.exports = router;
