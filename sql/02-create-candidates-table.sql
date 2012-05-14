DROP TABLE IF EXISTS candidates;
CREATE TABLE 
	candidates 
AS 
SELECT 
	a.id,
	a.version,
	a.user_id,
	a.tstamp,
	a.changeset_id,
	a.tags,
	a.nodes,
	a.linestring,
	COUNT(1) AS intersects 
FROM 
	otherways a, 
	motorways b 
WHERE 
	ST_Intersects(a.linestring, b.linestring) 
	AND
	(
		(NOT a.tags?'bridge' OR a.tags->'bridge' NOT IN ('yes','y','1','true'))
		AND
		(NOT b.tags?'bridge' OR b.tags->'bridge' NOT IN ('yes','y','1','true'))
		AND
		(NOT a.tags?'tunnel' OR a.tags->'tunnel' NOT IN ('yes','y','1','true'))
		AND
		(NOT b.tags?'tunnel' OR b.tags->'tunnel' NOT IN ('yes','y','1','true'))
		AND
		(NOT a.tags?'access' OR a.tags->'access' NOT IN ('private','official','no'))
	)
GROUP BY 
	a.id,
	a.version,
	a.user_id,
	a.tstamp,
	a.changeset_id,
	a.tags,
	a.nodes,
	a.linestring;