SELECT SUM(CAST(TRIM(NUMBER) AS INTEGER))
FROM regexp_split_to_table(regexp_replace('     Тридцать три коpовы,    Тридцать 3   коpовы, 30 три коpовы, /    Свежая стpока. /  33 коpовы, / Стих pодился новый, /    Как стакан паpного молока.    '
                               ,'[^0-9 ]'
                               ,''
                               ,'g')
         ,' ') AS t(NUMBER)
WHERE TRIM(NUMBER) '^[0-9]+$';