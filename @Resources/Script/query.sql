-- query.sql
SELECT DISTINCT 
    json_extract(GamePieces.value, '$.title') as title,
    PlayTasks.gameReleaseKey,
    WebCacheResources.filename,
    Users.id,
    Users.id || '/' || 
    SUBSTR(PlayTasks.gameReleaseKey, 1, INSTR(PlayTasks.gameReleaseKey, '_') - 1) || '/' || 
    REPLACE(PlayTasks.gameReleaseKey, SUBSTR(PlayTasks.gameReleaseKey, 1, INSTR(PlayTasks.gameReleaseKey, '_') - 1) || '_', '') || '/' || 
    WebCacheResources.filename as path,
    PlayTaskLaunchParameters.executablePath
FROM PlayTasks
JOIN WebCache ON WebCache.releaseKey = PlayTasks.gameReleaseKey
JOIN WebCacheResources ON WebCacheResources.webCacheId = WebCache.id AND WebCacheResources.WebCacheResourceTypeId = 3
JOIN GamePieces ON GamePieces.releaseKey = PlayTasks.gameReleaseKey AND GamePieces.gamePieceTypeId = 156
JOIN Users ON 1=1 -- Assuming there is only one entry in the Users table
LEFT JOIN PlayTaskLaunchParameters ON PlayTaskLaunchParameters.playTaskId = PlayTasks.id
ORDER BY title;
