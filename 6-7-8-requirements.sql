-- ******************6.	скрипты характерных выборок (включающие группировки, JOIN'ы, вложенные таблицы);
-- ******************7.	представления (минимум 2);

-- список всех клубов в которых есть бассейн с контактами и сортировкой по городам (3 таблицы)
 
CREATE OR REPLACE VIEW all_aqua AS
SELECT 
	cl.id AS id,
	cl.city AS city,
	cp.postal_address AS address,
	cp.phone AS phone,
	cp.pool AS pool,
	cs.status_name 
FROM clubs_list cl 
	JOIN club_profile cp ON cp.club_id = cl.id
	JOIN club_status cs ON cl.club_status_id = cs.id 
WHERE 
	cs.status_name = 'SPORTLAND Aqua'
ORDER BY 
	cl.city;

SELECT * FROM all_aqua;

-- список персональных тренировок по тренеру с указанием типа и времени занятия (4 таблицы)

CREATE OR REPLACE VIEW trainers_pt AS
SELECT
	pt.staff_id, 
	concat(staff.first_name, ' ', staff.last_name) AS trainer,
	tr.traning_name,
	tt.type_name,
	pt.week_day,
	pt.start_time,
	tr.duration_minutes 
FROM personal_trainings pt
	JOIN staff ON staff.id = pt.staff_id
	JOIN training tr ON tr.id = pt.training_id 
	JOIN training_type tt ON tt.id = tr.training_type_id 
WHERE 
	pt.staff_id = '180' OR pt.staff_id = '203'
ORDER BY 
	pt.staff_id 

SELECT * FROM trainers_pt;

-- выборка графика отдельного вида тренировок из общего расписания с указанием тренера (3 таблицы)

CREATE OR REPLACE VIEW training_shedule AS
SELECT 
	week_day, 
	start_time,
	(SELECT concat(first_name, ' ', last_name) FROM staff WHERE staff.id = tt.staff_id) AS trainer,
	(SELECT traning_name FROM training WHERE training.id = tt.training_id) AS training
FROM timetable tt
WHERE training_id = '4';

SELECT * FROM training_shedule;


-- ******************8.	хранимые процедуры / триггеры;

-- процедура выдает информацию о имени и городе клиента по его id

DROP PROCEDURE IF EXISTS client_data_by_id;
DELIMITER //
CREATE PROCEDURE client_data_by_id (IN client INT)
BEGIN
	SELECT 
		(SELECT city FROM clients_profile WHERE client_id = client) AS city,
		(SELECT concat(first_name, ' ', last_name) FROM client WHERE id = client) AS client;
END//
DELIMITER ;

CALL client_data_by_id(16);

-- функция возвращает инфо, сколько было продано абонементов в определенном клубе по его id

DROP FUNCTION IF EXISTS cards_qty;
DELIMITER //
CREATE FUNCTION cards_qty (club INT)
RETURNS text DETERMINISTIC
BEGIN
	DECLARE total int;
	IF club <= (SELECT count(*) FROM clubs_list) THEN 
		SELECT count(*) INTO total FROM  member_card WHERE club_id = club;
  		RETURN CONCAT("В клубе № ", club, " продано ", total, " абонементов");
  	ELSE 
  		RETURN "Такого клуба не существует";
  	END IF;
END//
DELIMITER ;

SELECT cards_qty(20);
SELECT cards_qty(6);

-- триггер не самый удачный, т.к id клуба и card_priority_id не заполнить автоматом, 
-- но я больше ничего не придлумала и в любом случае это работает - абонемент генерируется при создании профиля клиента

DROP TRIGGER IF EXISTS new_member_card;
delimiter //
CREATE TRIGGER new_member_card AFTER INSERT ON client
FOR EACH ROW
BEGIN
	INSERT INTO member_card (club_id, client_id, card_priority_id)
	VALUES (1, NEW.id, 1);
END //
delimiter ;

INSERT INTO client VALUES ('202','Isabell','Schaden');

SELECT * FROM member_card WHERE client_id = '202';

