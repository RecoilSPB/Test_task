SELECT last_name
      ,first_name
      ,middle_name
  FROM people
 GROUP BY last_name
         ,first_name
         ,middle_name
HAVING COUNT(*) > 1;
