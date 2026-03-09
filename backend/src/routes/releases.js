const router = require('express').Router();
const { authenticate, authorize } = require('../middleware/auth');
const { getAllReleases, createRelease, updateReleaseStatus, rollback } = require('../controllers/releaseController');

router.get('/', authenticate, getAllReleases);
router.post('/', authenticate, authorize('admin', 'developer'), createRelease);
router.put('/:id/status', authenticate, authorize('admin', 'developer'), updateReleaseStatus);
router.post('/:id/rollback', authenticate, authorize('admin'), rollback);

module.exports = router;
