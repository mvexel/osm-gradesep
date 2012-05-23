DROP TABLE IF EXISTS osm_intersect;

CREATE TABLE osm_intersect 
AS 
SELECT COUNT(1) AS nodecnt, b.id, b.geom 
FROM way_nodes a, nodes b 
WHERE b.id = a.node_id GROUP BY a.node_id, b.id;

CREATE INDEX idx_osm_intersect_geom ON osm_intersect USING GIST(geom);
