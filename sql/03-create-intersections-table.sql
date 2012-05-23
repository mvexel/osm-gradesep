DROP TABLE IF EXISTS intersections;
CREATE TABLE
    intersections 
AS
(
    SELECT
        (
            ST_DumpPoints
            (
                ST_Intersection
                (
                    a.linestring, 
                    b.linestring
                )
            )
        ).geom
        AS intersection,
        a.linestring as otherway_geom,
        b.linestring as motorway_geom,
        a.id as otherway_osmid,
        b.id as motorway_osmid
    FROM 
        candidates a, 
        motorways b
    WHERE
        ST_Intersects
        (
            a.linestring,
            b.linestring
        )
);
ALTER TABLE intersections ADD COLUMN id serial;


