DROP TABLE IF EXISTS buffers;
CREATE TABLE buffers AS
(
	SELECT
		intersections.intersection,
		ST_ExteriorRing
		(
			ST_Buffer
			(
				intersections.intersection
				, 10
			)
		)
		AS extring,
		ST_Transform(intersections.otherway_geom,3785) AS otherway_geom,
		ST_Transform(intersections.motorway_geom,3785) AS motorway_geom,
		intersections.otherway_osmid,
		intersections.motorway_osmid
	FROM
		intersections
);
