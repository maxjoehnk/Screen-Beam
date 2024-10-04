UPDATE devices
SET hostname = ?,
    ip = ?,
    version_major = ?,
    version_minor = ?,
    version_patch = ?
WHERE id = ?;
