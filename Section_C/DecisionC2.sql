WITH datetimes AS
 (SELECT generate_series('2024-04-23 00:00:00' ::TIMESTAMP, '2024-04-23 23:59:59' ::TIMESTAMP, INTERVAL '1 hour') AS change_datetime)
INSERT INTO parameter_history
 (person_id, parameter_id, parameter_value, change_datetime)
SELECT person_id
      ,parameter_id
      ,md5(random() ::text)
      ,change_datetime
  FROM (SELECT generate_series(1, 1000) AS person_id) persons
      ,(SELECT generate_series(1, 100) AS parameter_id) PARAMETERS
      ,datetimes
 ORDER BY random() LIMIT 10000;