DROP TABLE IF EXISTS nbi_tmp;

CREATE TABLE nbi_tmp 
AS 
SELECT * 
FROM nbi_all_viaducts 
WHERE the_geom && ST_Estimated_Extent('ways', 'linestring');

ALTER TABLE intersections 
DROP COLUMN IF EXISTS closenbicount,
DROP COLUMN IF EXISTS osmnodes;

ALTER TABLE intersections 
ADD COLUMN closenbicount smallint,
ADD COLUMN osmnodes bigint[];
    
UPDATE intersections SET (closenbicount, osmnodes) = (0, ARRAY[]::bigint[]);

WITH counts 
AS 
(
    SELECT 
        COUNT(1) AS nbicount, 
        intersections.otherway_osmid, 
        intersections.motorway_osmid 
    FROM 
        nbi_tmp,
        intersections 
    WHERE 
        ST_Distance
        (
            ST_Transform
            (
                intersections.intersection,
                3785
            ),
            ST_Transform
            (
                nbi_tmp.the_geom,
                3785
            )
        ) < 100
    GROUP BY 
        nbi_tmp.structure_n, 
        intersections.motorway_osmid, 
        intersections.otherway_osmid
) 
UPDATE intersections 
SET closenbicount = counts.nbicount 
FROM counts 
WHERE intersections.otherway_osmid = counts.otherway_osmid 
AND intersections.motorway_osmid = counts.motorway_osmid;

UPDATE 
    intersections 
SET 
    osmnodes = 
        array(
            SELECT id 
            FROM osm_intersect
            WHERE ST_Transform(intersections.intersection,4326) && osm_intersect.geom
            AND osm_intersect.nodecnt > 1
        )
;
