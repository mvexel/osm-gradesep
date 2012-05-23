DROP TABLE IF EXISTS otherways;
CREATE TABLE 
    otherways
AS
    SELECT 
        * 
    FROM 
        ways 
    WHERE 
        tags->'highway' NOT IN ('motorway','motorway_link', 'proposed');


DROP TABLE IF EXISTS motorways;
CREATE TABLE 
    motorways 
AS 
    SELECT 
        * 
    FROM 
        ways 
    WHERE 
        tags->'highway' IN ('motorway');

