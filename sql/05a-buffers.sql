DROP TABLE IF EXISTS buffers;
CREATE TABLE buffers AS
(
    SELECT
        intersections.intersection,
        ST_Transform(
            ST_ExteriorRing
            (
                ST_Buffer
                (
                    ST_Transform
                    (
                        intersections.intersection,
                        3785
                    )
                    , 10
                )
            ),
            4326
        )
        AS extring,
        intersections.otherway_geom AS otherway_geom,
        intersections.motorway_geom AS motorway_geom,
        intersections.otherway_osmid,
        intersections.motorway_osmid
    FROM
        intersections
);
