WITH ranked_data AS
 (SELECT person_id
        ,parameter_id
        ,parameter_value
        ,change_datetime
        ,row_number() over(PARTITION BY person_id, parameter_id ORDER BY change_datetime DESC) AS rn
    FROM parameter_history
   WHERE person_id BETWEEN 1 AND 100 -- Заданный диапазон идентификаторов людей
  )
SELECT json_agg(json_build_object('person', person_id, 'parameters', PARAMETERS))
  FROM (SELECT person_id
              ,json_agg(json_build_object('parameter' ,parameter_id
                                         ,'modf_time' ,change_datetime
                                         ,'value' ,parameter_value)) AS PARAMETERS
          FROM ranked_data
         WHERE rn = 1
         GROUP BY person_id) subquery;