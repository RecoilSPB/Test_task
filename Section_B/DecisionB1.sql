SELECT x
      ,cos(x) AS y
  FROM (SELECT x
          FROM generate_series(0, 50, 1) AS x) AS t;