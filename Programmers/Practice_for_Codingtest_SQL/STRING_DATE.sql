--STRING_DATE 1)
SELECT animal_id, name, sex_upon_intake from animal_ins
where name in ("Lucy","Ella","Pickle","Rogan","Sabrina","Mitty")
order by animal_id

--STRING_DATE 2)
SELECT animal_id, name from animal_ins
where name like "%el%" and animal_type = "Dog"
order by name

--STRING_DATE 3)
SELECT animal_id,name, (case when sex_upon_intake regexp('Neutered|Spayed') then 'O' else 'X' end) as '중성화' from animal_ins

--STRING_DATE 4)
SELECT a.animal_id, a.name from animal_ins as a inner join animal_outs as b on a.animal_id = b.animal_id
order by b.datetime - a.datetime desc limit 2

--STRING_DATE 5)
SELECT animal_id, name, date_format(datetime,'%Y-%m-%d') '날짜' from animal_ins
