--SELECT 1)
SELECT * from ANIMAL_INS
ORDER BY AniMAL_ID

--SELECT 2)
SELECT NAME, DATETIME from ANIMAL_INS
order by ANIMAL_ID desc

--SELECT 3)
SELECT ANIMAL_ID, NAME from ANIMAL_INS
where INTAKE_CONDITION = "Sick"

--SELECT 4)
SELECT animal_id, name from animal_ins
where not intake_condition = "aged"
order by animal_id

--SELECT 5)
SELECT animal_id, name from animal_ins
order by animal_id

--SELECT 6)
SELECT animal_id, name, datetime from animal_ins
order by name asc, datetime desc

--SELECT 7)
SELECT name from animal_ins
order by datetime limit 1
