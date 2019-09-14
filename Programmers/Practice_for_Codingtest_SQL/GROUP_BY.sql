--GROUP_BY 1)
SELECT animal_type, count(animal_type) as "count" from animal_ins
group by animal_type

--GROUP_BY 2)
SELECT name, count(name) as "count" from animal_ins
group by name
having count(name)>=2
order by name

--GROUP_BY 3)
SELECT hour(datetime) as 'HOUR', count(animal_id) as 'COUNT' from animal_outs
where hour(datetime) between 9 and 19
group by HOUR

--GROUP_BY 4) x
