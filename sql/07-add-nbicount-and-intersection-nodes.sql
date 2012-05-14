ALTER TABLE 
     intersections 
ADD COLUMN 
     closenbicount smallint,
ADD COLUMN 
     hasnode boolean;

UPDATE intersections SET (closenbicount, hasnode) = (0, false);

WITH 
     counts 
AS 
(
     SELECT 
          COUNT(1) AS nbicount, 
          intersections.otherway_osmid, 
          intersections.motorway_osmid 
     FROM 
          nbi_all_viaducts,
          intersections 
     WHERE 
			(ST_X(nbi_all_viaducts.the_geom) BETWEEN -180.0 AND 180.0 AND ST_Y(nbi_all_viaducts.the_geom) BETWEEN -90.0 AND 90.0)
			AND
			ST_Distance(intersections.intersection,ST_Transform(nbi_all_viaducts.the_geom,3785)) < 100 
     GROUP BY 
          nbi_all_viaducts.structure_n, 
          intersections.motorway_osmid, 
          intersections.otherway_osmid
) 
UPDATE 
     intersections 
SET 
     closenbicount = counts.nbicount 
FROM 
     counts 
WHERE 
     intersections.otherway_osmid = counts.otherway_osmid 
     AND 
     intersections.motorway_osmid = counts.motorway_osmid;

UPDATE 
     intersections 
SET 
     hasnode = true 
FROM 
     nodes 
WHERE 
    ST_Transform(intersections.intersection,4326) && nodes.geom;
