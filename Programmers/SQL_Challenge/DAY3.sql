-- 최솟값 구하기
SELECT min(datetime) as "시간" from animal_ins

-- 이름이 없는 동물의 아이디
SELECT animal_id from animal_ins
where isnull(name)
