-- -----------------------------------------------------
-- Setup For Loading Data
-- -----------------------------------------------------
USE olympics_data;
SET GLOBAL local_infile = 'ON';

-- -----------------------------------------------------
-- CHANGES MADE
-- Added OPT_LOCAL_INFILE=1 in Connection Settings
-- Increased Max_allowed_packets to 512m from 67m in my.ini file
-- Increased connection keep alive interval in workbench from 60 to 86400 
-- -----------------------------------------------------

-- Load Games Table
LOAD DATA LOCAL INFILE 'D:/Courses/Olympics Data EDA/modelled_data/games.csv'
INTO TABLE games
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Load Events Table
LOAD DATA LOCAL INFILE 'D:/Courses/Olympics Data EDA/modelled_data/events.csv'
INTO TABLE `events`
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Load Committees Table
LOAD DATA LOCAL INFILE 'D:/Courses/Olympics Data EDA/modelled_data/committees.csv'
INTO TABLE committees
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Load athletes Table
LOAD DATA LOCAL INFILE 'D:/Courses/Olympics Data EDA/modelled_data/athletes.csv'
INTO TABLE athletes
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


-- Load results Table
LOAD DATA LOCAL INFILE 'D:/Courses/Olympics Data EDA/modelled_data/results.csv'
INTO TABLE results
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(athlete_id, games_id, event_id, age, committee_code, medal);