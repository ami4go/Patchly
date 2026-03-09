const router = require('express').Router();
const { authenticate, authorize } = require('../middleware/auth');
const { getSLAs, getPenalties, createPenalty } = require('../controllers/slaController');

router.get('/slas', authenticate, getSLAs);
router.get('/penalties', authenticate, getPenalties);
router.post('/penalties', authenticate, authorize('admin'), createPenalty);

module.exports = router;
