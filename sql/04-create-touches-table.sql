DROP TABLE IF EXISTS touches;
CREATE TABLE 
    touches 
AS 
SELECT 
    a.id AS way_id, 
    COUNT(1) AS touches 
FROM 
    candidates a, 
    motorways b 
WHERE 
    ST_Touches(a.linestring, b.linestring) 
GROUP BY 
    a.id;

