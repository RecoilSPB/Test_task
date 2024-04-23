/* Индекс для быстрого отображения истории изменений для заданного диапазона идентификаторов людей. */
CREATE INDEX idx_person_id ON parameter_history(person_id);

/* Индекс для отображения истории изменений для заданного диапазона идентификаторов людей и даты/времени
 изменения значения. */
CREATE INDEX idx_person_date ON parameter_history(person_id, change_datetime);

/* Индекс для отображения актуального (последнего по времени изменения) значения
каждого параметра для заданного диапазона идентификаторов людей; */
CREATE INDEX idx_person_date_parametrs ON parameter_history(person_id, change_datetime, parameter_id);

/* Индекс для отображения самого изменяемого параметра; */
CREATE INDEX idx_parametrs_id ON parameter_history(parameter_id);

/* Индекс для отображения изменений, выполненных в определенный день */
CREATE INDEX idx_date ON parameter_history(change_datetime);