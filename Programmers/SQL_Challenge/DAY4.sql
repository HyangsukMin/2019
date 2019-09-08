-- 고양이와 개는 몇 마리 있을까
SELECT ANIMAL_TYPE, COUNT(ANIMAL_TYPE) as "count" from ANIMAL_INS
GROUP BY ANIMAL_TYPE

-- 동명 동물 수 찾기
SELECT NAME, count(NAME) as "count" from ANIMAL_INS
GROUP BY NAME
HAVING count(NAME) >= 2
ORDER BY NAME
