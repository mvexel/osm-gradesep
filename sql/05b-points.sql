DROP TABLE IF EXISTS points;
CREATE TABLE points AS
(
	SELECT
		ST_GeometryN
		(
			ST_Intersection
			(
				buffers.extring,
				buffers.otherway_geom
			)
			, 1
		)
		AS point1,
		ST_GeometryN
		(
			ST_Intersection
			(
				buffers.extring,
				buffers.motorway_geom
			)
			, 1
		)
		AS point2,
		buffers.intersection,
		buffers.extring,
		buffers.otherway_geom,
		buffers.motorway_geom,
		buffers.otherway_osmid,
		buffers.motorway_osmid
	FROM
		buffers
);