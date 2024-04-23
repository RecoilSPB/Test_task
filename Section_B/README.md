## Решение Б1:

Для вывода значений `x` и `y` функции `y = cos(x)` в диапазоне от 0 до 50 можно использовать следующий запрос:
```sql
SELECT x
      ,cos(x) AS y
  FROM (SELECT x
          FROM generate_series(0, 50, 1) AS x) AS t;
```
Этот запрос использует функцию `generate_series()` для генерации последовательности чисел от 0 до 50 и применяет 
функцию `cos()` к этой последовательности, чтобы получить значения `y`.

## Решение Б2:

Не решено

## Решение Б3. 
Поиск экстремумов функции:
Для поиска экстремумов функции `cos(x)` в заданном диапазоне, можно воспользоваться следующим SQL запросом:
```sql
WITH extrema AS
 (SELECT x
        ,cos(x) AS y
        ,CASE
           WHEN cos(x) > cos(x - 1)
                AND cos(x) > cos(x + 1) THEN
            'Maximum'
           WHEN cos(x) < cos(x - 1)
                AND cos(x) < cos(x + 1) THEN
            'Minimum'
           ELSE
            'Not an Extremum'
         END AS extremum_type
    FROM (SELECT x
                ,cos(x)
            FROM (SELECT generate_series(1, 49, 1) AS x) AS t) AS cos_values)
SELECT x
      ,y
  FROM extrema
 WHERE extremum_type != 'Not an Extremum';
```
Этот запрос вычисляет значения `cos(x)` в диапазоне от 1 до 49, 
затем определяет экстремумы (минимумы и максимумы) на основе значений соседних точек. 
Результирующий набор будет содержать значения `x` и `y` для всех экстремумов функции в указанном диапазоне.