DROP TABLE IF EXISTS tmp_results;
CREATE TABLE
	tmp_results
AS 
	SELECT 
		candidates.id, 
		SUM(intersections.closenbicount) > 0 AS hasclosenbi,
		SUM(intersections.hasnode::integer) AS sharednodecnt
	FROM
		candidates, 
		intersections 
	WHERE 
		intersections.otherway_osmid = candidates.id 
	GROUP BY candidates.id;

ALTER TABLE
	candidates
DROP COLUMN IF EXISTS
	closenbi,
DROP COLUMN IF EXISTS
	sharednodecnt;
	
ALTER TABLE 
	candidates
ADD COLUMN
	closenbi boolean,
ADD COLUMN 
	sharednodecnt smallint;
	
UPDATE
	candidates
SET
	(closenbi, sharednodecnt) = (tmp_results.hasclosenbi, tmp_results.sharednodecnt)
FROM
	tmp_results
WHERE
	tmp_results.id = candidates.id;