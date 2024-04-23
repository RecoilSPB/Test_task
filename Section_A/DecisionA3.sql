SELECT *
  FROM people
 WHERE levenshtein(last_name, 'Битков') <= 1
    OR levenshtein(last_name, 'Бетков') <= 1
    OR levenshtein(last_name, 'Бидков') <= 1
    OR levenshtein(last_name, 'Биткоф') <= 1;