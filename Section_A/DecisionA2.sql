DELETE FROM people
 WHERE id NOT IN (SELECT MAX(id)
                    FROM people
                   GROUP BY last_name
                           ,first_name
                           ,middle_name);