DROP TABLE IF EXISTS tmp_hasclosenbi;
CREATE TABLE
	tmp_hasclosenbi 
AS 
	SELECT 
		candidates.id, 
		SUM(intersections.closenbicount) > 0 AS hasclosenbi 
FROM
	candidates, 
	intersections 
WHERE 
	intersections.otherway_osmid = candidates.id 
GROUP BY candidates.id;

ALTER TABLE 
	candidates
ADD COLUMN
	closenbi boolean;
	
UPDATE
	candidates
SET
	closenbi = tmp_hasclosenbi.hasclosenbi
FROM
	tmp_hasclosenbi
WHERE
	tmp_hasclosenbi.id = candidates.id;