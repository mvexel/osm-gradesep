ALTER TABLE 
	candidates 
ADD COLUMN 
	touches smallint,
ADD COLUMN 
	angle decimal,
ADD COLUMN 
	gradesep boolean;



UPDATE 
	candidates 
SET 
	(touches, angle, gradesep) = (0, 0, false);

UPDATE 
	candidates 
SET 
	touches = touches.touches 
FROM 
	touches 
WHERE 
	touches.way_id = id;


UPDATE
	candidates 
SET
	angle = angles.angle 
FROM 
	angles 
WHERE 
	angles.otherway_id = candidates.id;

UPDATE 
	candidates 
SET 
	gradesep = true 
WHERE 
	touches = 0 
	-- AND 
	-- intersects = 2 
	AND angle > 30 
	AND angle < 150;
