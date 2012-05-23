ALTER TABLE candidates
DROP COLUMN IF EXISTS closenbi;
        
ALTER TABLE candidates
ADD COLUMN closenbi boolean;
        
UPDATE candidates
SET closenbi = tmp.closenbi 
FROM 
(SELECT 
SUM(intersections.closenbicount) > 0 as closenbi, otherway_osmid 
FROM intersections
GROUP BY otherway_osmid) tmp
WHERE tmp.otherway_osmid = candidates.id;
