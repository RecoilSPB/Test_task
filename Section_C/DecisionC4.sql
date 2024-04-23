/* Запросы для каждого пункта из В3: */
-- a)
SELECT *
  FROM parameter_history
 WHERE person_id BETWEEN 121 AND 151;

-- б)
SELECT *
  FROM parameter_history
 WHERE person_id BETWEEN 1 AND 100 -- Заданный диапазон идентификаторов людей
   AND change_datetime BETWEEN :P_FROM_DATE AND :P_TO_DATE;

-- в)
WITH ranked_data AS
 (SELECT person_id
        ,parameter_id
        ,parameter_value
        ,change_datetime
        ,row_number() over(PARTITION BY person_id, parameter_id ORDER BY change_datetime DESC) AS rn
    FROM parameter_history
   WHERE person_id BETWEEN 1 AND 100 -- Заданный диапазон идентификаторов людей
  )
SELECT person_id
      ,parameter_id
      ,parameter_value
      ,change_datetime
  FROM ranked_data
 WHERE rn = 1;

-- г)
SELECT parameter_id,
       COUNT(*) as change_count
  FROM parameter_history
GROUP BY parameter_id
ORDER BY change_count DESC LIMIT 1;

-- д)
SELECT *
  FROM parameter_history
 WHERE change_datetime = :P_DATE;