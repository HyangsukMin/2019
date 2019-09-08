-- 없어진 기록 찾기
SELECT ANIMAL_ID, NAME FROM ANIMAL_OUTS
WHERE ANIMAL_ID NOT IN (SELECT ANIMAL_ID FROM ANIMAL_INS)

-- 있었는데요 없었습니다
SELECT A.ANIMAL_ID, A.NAME FROM ANIMAL_INS AS A INNER JOIN ANIMAL_OUTS AS B ON A.ANIMAL_ID = B.ANIMAL_ID
WHERE A.DATETIME > B.DATETIME
ORDER BY A.DATETIME
