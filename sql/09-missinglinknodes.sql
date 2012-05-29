DROP TABLE IF EXISTS linkways;

CREATE TABLE linkways AS 
select * FROM  ways 
WHERE position('_link' IN tags->'highway') > 0;

DROP TABLE IF EXISTS unconnectedlinknodes;

CREATE TABLE unconnectedlinknodes AS 
WITH counts AS (
	SELECT count(1) AS cnt, node_id 
	FROM way_nodes 
	GROUP BY node_id
) SELECT w.nodes[array_length(w.nodes,1)] AS node_id, w.tags->'highway' as linktype, n.geom 
FROM linkways w 
INNER JOIN counts c ON c.node_id = w.nodes[array_length(w.nodes,1)] 
INNER JOIN nodes n ON n.id = w.nodes[array_length(w.nodes,1)] 
WHERE c.cnt = 1; 

INSERT INTO unconnectedlinknodes 
WITH counts AS (
	SELECT count(1) AS cnt, node_id 
	FROM way_nodes 
	GROUP BY node_id
) SELECT w.nodes[array_length(w.nodes,1)] AS node_id, w.tags->'highway' as linktype, n.geom 
FROM linkways w 
INNER JOIN counts c ON c.node_id = w.nodes[array_length(w.nodes,1)] 
INNER JOIN nodes n ON n.id = w.nodes[array_length(w.nodes,1)] 
WHERE c.cnt = 1;
