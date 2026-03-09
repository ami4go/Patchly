const pool = require('../config/db');

const getAllReleases = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT r.*, av.VersionNumber, a.AppName
       FROM \`Release\` r
       JOIN AppVersion av ON r.VersionID = av.VersionID
       JOIN App a ON av.AppID = a.AppID
       ORDER BY r.ReleaseDate DESC`
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const createRelease = async (req, res) => {
  try {
    const { versionId, releaseDate, deploymentStatus, notes } = req.body;
    if (!versionId) return res.status(400).json({ success: false, message: 'versionId is required' });
    const [result] = await pool.query(
      'INSERT INTO `Release` (VersionID, ReleaseDate, DeploymentStatus, Notes) VALUES (?, ?, ?, ?)',
      [versionId, releaseDate || null, deploymentStatus || 'PENDING', notes || null]
    );
    res.status(201).json({ success: true, data: { releaseId: result.insertId } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const updateReleaseStatus = async (req, res) => {
  try {
    const { deploymentStatus } = req.body;
    await pool.query('UPDATE `Release` SET DeploymentStatus = ? WHERE ReleaseID = ?', [deploymentStatus, req.params.id]);
    res.json({ success: true, message: 'Release status updated' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const rollback = async (req, res) => {
  try {
    const { reason } = req.body;
    const releaseId = req.params.id;
    await pool.query("UPDATE `Release` SET DeploymentStatus = 'ROLLED BACK' WHERE ReleaseID = ?", [releaseId]);
    const [result] = await pool.query(
      'INSERT INTO Rollback (ReleaseID, RollbackDate, Reason) VALUES (?, NOW(), ?)',
      [releaseId, reason || null]
    );
    // Reopen bugs fixed in this release
    await pool.query(
      `UPDATE Bug SET StatusID = (SELECT StatusID FROM Status WHERE StatusName = 'REOPENED' LIMIT 1)
       WHERE BugID IN (SELECT BugID FROM ReleaseBugFix WHERE ReleaseID = ?)`,
      [releaseId]
    );
    res.json({ success: true, data: { rollbackId: result.insertId } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = { getAllReleases, createRelease, updateReleaseStatus, rollback };
