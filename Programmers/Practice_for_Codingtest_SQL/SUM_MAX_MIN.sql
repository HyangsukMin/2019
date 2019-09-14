--SUM_MAX_MIN 1)
SELECT max(datetime) '시간' from animal_ins

--SUM_MAX_MIN 2)
SELECT min(datetime) '시간' from animal_ins

--SUM_MAX_MIN 3)
SELECT count(*) from animal_ins

--SUM_MAX_MIN 4)
SELECT count(distinct name) 'count' from animal_ins
