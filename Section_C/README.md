## Решение В1. 
Создание таблицы:
Для создания таблицы с историей изменения параметров человека в базе данных Postgres 
мы используем следующий запрос с объяснением выбора типов данных для колонок:
```sql
CREATE TABLE parameter_history (
    person_id INT,
    parameter_id INT,
    parameter_value TEXT,
    change_datetime TIMESTAMP
);
```
- `person_id`: INT, чтобы хранить идентификатор человека.
- `parameter_id`: INT, для идентификатора параметра человека.
- `parameter_value`: TEXT, так как это строка/текст максимальной длины, которая может варьироваться.
- `change_datetime`: TIMESTAMP, чтобы хранить дату и время изменения значения параметра.

## Решение В2. 
Заполнение таблицы данными:
```sql
-- Генерация временных рядов для 10 уникальных значений даты и времени
WITH datetimes AS
 (SELECT generate_series('2024-04-23 00:00:00' ::TIMESTAMP, '2024-04-23 23:59:59' ::TIMESTAMP, INTERVAL '1 hour') AS change_datetime)

-- Заполнение таблицы данными
INSERT INTO parameter_history
 (person_id, parameter_id, parameter_value, change_datetime)
SELECT person_id
      ,parameter_id
      ,md5(random() ::text)
      , -- Генерация случайного значения параметра через хэш
       change_datetime
  FROM (SELECT generate_series(1, 1000) AS person_id) persons
      ,(SELECT generate_series(1, 100) AS parameter_id) PARAMETERS
      ,datetimes
 ORDER BY random() LIMIT 10000; -- Общее число строк: 1000 человек * 100 параметров * 10 уникальных дат
```
Этот скрипт сначала генерирует 10 уникальных значений даты и времени для каждого часа 23 апреля 2024 года и, затем, 
вставляет случайные данные в таблицу parameter_history, соответствующие заданным условиям:
- Идентификаторы человека от 1 до 1000
- Идентификаторы параметров от 1 до 100
- Значение параметра генерируется случайным образом с использованием хэш-функции md5(random()::text)
- Дата и время изменения значения параметра берутся из заранее сгенерированных уникальных значений

## Решение В3.
Предложенные индексы:

а) Индекс для быстрого отображения истории изменений для заданного диапазона идентификаторов людей.
```sql 
CREATE INDEX idx_person_id ON parameter_history(person_id);
```

б) Индекс для отображения истории изменений для заданного диапазона идентификаторов людей и даты/времени 
изменения значения.
```sql
CREATE INDEX idx_person_date ON parameter_history(person_id, change_datetime);
```

в) Индекс для отображения актуального (последнего по времени изменения) значения
каждого параметра для заданного диапазона идентификаторов людей;
```sql
CREATE INDEX idx_person_date_parametrs ON parameter_history(person_id, change_datetime, parameter_id);
```

г) Индекс для отображения самого изменяемого параметра;
```sql
CREATE INDEX idx_parametrs_id ON parameter_history(parameter_id);
```

д) Индекс для отображения изменений, выполненных в определенный день
```sql
CREATE INDEX idx_date ON parameter_history(change_datetime);
```

## Решение В4.
Запросы для каждого пункта из В3:

- a) 
```sql 
SELECT * 
  FROM parameter_history 
 WHERE person_id BETWEEN 121 AND 151;
```
- б) 
```sql
SELECT *
  FROM parameter_history
 WHERE person_id BETWEEN 1 AND 100 -- Заданный диапазон идентификаторов людей
   AND change_datetime BETWEEN :P_FROM_DATE AND :P_TO_DATE;
```
- в) 
```sql
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
```
- г) 
```sql
SELECT parameter_id, 
       COUNT(*) as change_count 
  FROM parameter_history 
GROUP BY parameter_id 
ORDER BY change_count DESC LIMIT 1;
```
- д) 
```sql
SELECT * 
  FROM parameter_history 
 WHERE change_datetime = :P_DATE;
```

## Решение В5.
```sql
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

```
Оптимальным запросом для отображения последнего значения каждого параметра для заданного диапазона идентификаторов 
людей может быть запрос с использованием оконных функций, который обеспечит эффективное извлечение актуальных 
данных из таблицы.

## Решение В6.
Пример SQL-запроса для получения данных в формате JSON:
```sql
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
```