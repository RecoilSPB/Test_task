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