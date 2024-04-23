/* Оптимальным запросом для отображения последнего значения каждого параметра для заданного диапазона идентификаторов
людей может быть запрос с использованием оконных функций, который обеспечит эффективное извлечение актуальных
данных из таблицы. */
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