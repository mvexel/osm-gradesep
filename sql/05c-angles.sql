DROP TABLE IF EXISTS angles;
CREATE TABLE angles AS SELECT
    points.point1,
    points.point2,
    points.extring,
    points.otherway_geom,
    points.motorway_geom,
    abs
    (
        round
        (
            degrees
            (
                    ST_Azimuth
                    (
                        points.point2,
                        points.intersection
                    )
                    -
                    ST_Azimuth
                    (
                        points.point1,
                        points.intersection
                    )
            )::decimal % 180.0
            ,2
        )
    )
    AS angle,
    points.otherway_osmid AS otherway_id,
    points.motorway_osmid AS motorway_id
FROM
    points;
