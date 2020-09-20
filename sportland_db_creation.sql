/*База данных sportland реализует структуру хранения данных сети одноименных спортивных клубов.
 * Всего для курсовой запланировала 10 клубов в нескольких городах с разным статусом в зависимости от наполнения и функционала.
 * Все как обычно - персонал, абонементы, клиенты, расписание занятий и персональные тренировки*/

DROP DATABASE IF EXISTS sportland;
CREATE DATABASE sportland;
USE sportland;

DROP TABLE IF EXISTS clubs_list;
CREATE TABLE clubs_list (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	club_status_id BIGINT UNSIGNED NOT NULL,
	city VARCHAR(50),
	created_at DATETIME DEFAULT NOW(),
	INDEX city_idx(city)
);

DROP TABLE IF EXISTS club_status;
CREATE TABLE club_status (
	id SERIAL,
	status_name VARCHAR(100)
);

ALTER TABLE clubs_list ADD CONSTRAINT fk_club_status
    FOREIGN KEY (club_status_id) REFERENCES club_status(id)
   		ON UPDATE CASCADE
	    ON DELETE restrict;
 
   
DROP TABLE IF EXISTS club_profile;
CREATE TABLE club_profile (
	club_id BIGINT UNSIGNED NOT NULL UNIQUE,
	phone BIGINT UNSIGNED NOT NULL UNIQUE,
	email VARCHAR(100) NOT NULL UNIQUE,
	postal_address VARCHAR(250),
	square INT UNSIGNED NOT NULL,
	works_from_time TIME DEFAULT '08:00:00', 
	works_till_time TIME DEFAULT '23:00:00',
	gym CHAR(1) DEFAULT '0',
	martial_arts CHAR(1) DEFAULT '0',
	kids_club CHAR(1) DEFAULT '0',
	pool CHAR(1) DEFAULT '0',
	SPA CHAR(1) DEFAULT '0',
	termo CHAR(1) DEFAULT '0',
	rehabilitation CHAR(1) DEFAULT '0',
	cafeteria CHAR(1) DEFAULT '0',
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT NOW(),
	
	FOREIGN KEY (club_id) REFERENCES clubs_list(id)
	    ON UPDATE CASCADE
	    ON DELETE restrict
);


DROP TABLE IF EXISTS staff;
CREATE TABLE staff (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	club_id BIGINT UNSIGNED NOT NULL,
	title_id BIGINT UNSIGNED NOT NULL,
	INDEX staff_firstname_lastname_idx(first_name, last_name),
	
	FOREIGN KEY (club_id) REFERENCES clubs_list(id)
);

DROP TABLE IF EXISTS staff_title;
CREATE TABLE staff_title (
	id SERIAL,
	title VARCHAR(50),
	priority_level VARCHAR(50)
);

ALTER TABLE staff ADD CONSTRAINT fk_staff_title
    FOREIGN KEY (title_id) REFERENCES staff_title(id);

DROP TABLE IF EXISTS staff_profile;
CREATE TABLE staff_profile (
	staff_id BIGINT UNSIGNED NOT NULL UNIQUE,
	birthday DATE,
	gender CHAR(1),
	phone BIGINT UNSIGNED UNIQUE,
	speciality VARCHAR(50),
	hire_date DATE,
	leaving_date DATE,
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT NOW(),
	
	FOREIGN KEY (staff_id) REFERENCES staff(id)
);

DROP TABLE IF EXISTS client;
CREATE TABLE client (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	INDEX client_firstname_lastname_idx(first_name, last_name)
);

DROP TABLE IF EXISTS clients_profile;
CREATE TABLE clients_profile (
	client_id BIGINT UNSIGNED NOT NULL UNIQUE,
	birthday DATE,
	gender CHAR(1),
	city VARCHAR(50),
	phone BIGINT UNSIGNED UNIQUE,
	email VARCHAR(100) UNIQUE,
	notices VARCHAR(255),
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT NOW(),
	INDEX city_idx(city),
	
	FOREIGN KEY (client_id) REFERENCES client(id)
);

DROP TABLE IF EXISTS member_card;
CREATE TABLE member_card (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	club_id BIGINT UNSIGNED NOT NULL,
	client_id BIGINT UNSIGNED NOT NULL UNIQUE,
	card_priority_id BIGINT UNSIGNED NOT NULL,
	
	FOREIGN KEY (club_id) REFERENCES clubs_list(id),
	FOREIGN KEY (client_id) REFERENCES client(id)
);

DROP TABLE IF EXISTS card_priority;
CREATE TABLE card_priority (
	id SERIAL,
	priority_status VARCHAR(50),
	card_month_price DEC(7,2) 
);

ALTER TABLE member_card ADD CONSTRAINT fk_card_priority
    FOREIGN KEY (card_priority_id) REFERENCES card_priority(id)
   		ON UPDATE CASCADE
	    ON DELETE restrict;

DROP TABLE IF EXISTS training;
CREATE TABLE training (
	id SERIAL,
	traning_name VARCHAR(50),
	training_type_id BIGINT UNSIGNED NOT NULL,
	description VARCHAR(255) DEFAULT 'Call to our office to gt full info',
	duration_minutes INT UNSIGNED NOT NULL DEFAULT '45',
	INDEX traning_name_idx(traning_name)
);

DROP TABLE IF EXISTS training_type;
CREATE TABLE training_type (
	id SERIAL,
	type_name VARCHAR(50)
);

ALTER TABLE training ADD CONSTRAINT fk_training_type
    FOREIGN KEY (training_type_id) REFERENCES training_type(id)
   		ON UPDATE CASCADE
	    ON DELETE restrict;
	   
DROP TABLE IF EXISTS personal_trainings;
CREATE TABLE personal_trainings (
	id SERIAL,
	club_id BIGINT UNSIGNED NOT NULL,		
	staff_id BIGINT UNSIGNED NOT NULL,
	client_id BIGINT UNSIGNED NOT NULL,
	training_id BIGINT UNSIGNED NOT NULL,
	pt_price DEC(7,2) DEFAULT '1500,00',
	week_day VARCHAR(50),
	start_time TIME,
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT NOW(),
	
	-- INDEX week_day_idx(week_day),
	
	FOREIGN KEY (club_id) REFERENCES clubs_list(id),
	FOREIGN KEY (client_id) REFERENCES client(id),
	FOREIGN KEY (staff_id) REFERENCES staff(id),
	FOREIGN KEY (training_id) REFERENCES training(id)
);

DROP TABLE IF EXISTS timetable;
CREATE TABLE timetable (
	id SERIAL,
	week_day VARCHAR(50),
	start_time TIME,
	training_id BIGINT UNSIGNED NOT NULL,
	staff_id BIGINT UNSIGNED NOT NULL,
	club_id BIGINT UNSIGNED NOT NULL,
		
	INDEX week_day_idx(week_day),
	
	FOREIGN KEY (staff_id) REFERENCES staff(id),
	FOREIGN KEY (club_id) REFERENCES clubs_list(id),
	FOREIGN KEY (training_id) REFERENCES training(id)
);

