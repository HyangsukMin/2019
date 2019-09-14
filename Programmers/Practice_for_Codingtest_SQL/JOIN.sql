--JOIN 1)
SELECT animal_id, name from animal_outs
where animal_id not in (select animal_id from animal_ins)

--JOIN 2)
SELECT a.animal_id, a.name from animal_ins as a INNER join animal_outs as b on a.animal_id = b.animal_id
where a.datetime > b.datetime
order by a.datetime

--JOIN 3)
SELECT a.name, a.datetime from animal_ins as a left join animal_outs as b on a.animal_id = b.animal_id
where b.animal_id is NULL 
order by datetime limit 3

--JOIN 4)
SELECT a.animal_id, a.animal_type, a.name from animal_ins as a inner join animal_outs as b on a.animal_id = b.animal_id
where sex_upon_intake like "Intact %" and sex_upon_outcome regexp "Spayed|Neutered"
