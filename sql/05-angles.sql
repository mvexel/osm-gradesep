DROP TABLE IF EXISTS angletmp;
CREATE TABLE angletmp AS
WITH
buffers AS
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
),
points AS
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
)
SELECT
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
     points
;
ALTER TABLE angletmp ADD COLUMN id serial;

