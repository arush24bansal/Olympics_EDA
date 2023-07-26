USE olympics_data;

/*=================== VIEWS ================================= */

CREATE OR REPLACE VIEW games_participation AS 
SELECT
	CONCAT(g.season, ' Olympics, ', g.year, ' - ', g.host) AS games, 
	COUNT(DISTINCT r.committee_code) AS Participants
FROM results r
JOIN games g
ON r.games_id = g.games_id
GROUP BY g.year, g.season, g.host;

/*=================== STORED PROCEDURES FOR ANSWERS 1 to 6 ================================= */ 
DELIMITER //  

DROP PROCEDURE IF EXISTS participation//
CREATE PROCEDURE participation()
BEGIN
	SELECT * FROM games_participation;
END //


DROP PROCEDURE IF EXISTS participation_range//
CREATE PROCEDURE participation_range()
BEGIN
    SELECT 'Minimum' AS "range", gp.*
    FROM games_participation gp
    WHERE Participants = (SELECT MIN(Participants) FROM games_participation)
    UNION
    SELECT 'Maximum' AS "range", gp.* 
    FROM games_participation gp
    WHERE Participants = (SELECT MAX(Participants) FROM games_participation);
END //


DROP PROCEDURE IF EXISTS prolific_participant//
CREATE PROCEDURE prolific_participant()
BEGIN
    
    SELECT c.committee_code, c.region, cte.olympic_games
    FROM (
		SELECT
			committee_code,
			COUNT(DISTINCT games_id) AS olympic_games
        FROM results
        GROUP BY committee_code
    ) cte
    JOIN committees c
    ON cte.committee_code = c.committee_code
    WHERE cte.olympic_games = (SELECT COUNT(*) FROM games);
END //


DROP PROCEDURE IF EXISTS popular_sport//
CREATE PROCEDURE popular_sport()
BEGIN
    SELECT *
    FROM (
		SELECT
			e.sport,
			COUNT(DISTINCT g.games_id) AS olympic_games
		FROM results r
		JOIN events e
		ON r.event_id = e.event_id
		JOIN games g
		ON r.games_id = g.games_id
        WHERE g.season = 'Summer'
		GROUP BY e.sport
    ) cte
    WHERE olympic_games = (SELECT COUNT(*) FROM games WHERE season = 'Summer');
END //


DROP PROCEDURE IF EXISTS unpopular_sport//
CREATE PROCEDURE unpopular_sport()
BEGIN
    SELECT *
    FROM (
		SELECT
			e.sport,
			COUNT(DISTINCT g.games_id) AS olympic_games
		FROM results r
		JOIN events e
		ON r.event_id = e.event_id
		JOIN games g
		ON r.games_id = g.games_id
		GROUP BY e.sport
    ) cte
    WHERE olympic_games = 1;
END //

DROP PROCEDURE IF EXISTS sports_count//
CREATE PROCEDURE sports_count()
BEGIN
    SELECT
		CONCAT(g.season, 'Olympics, ', g.year, " - ", g.host) AS games,
        COUNT(DISTINCT e.sport) AS sports
    FROM results r
    JOIN events e
    ON r.event_id = e.event_id
    JOIN games g
    ON r.games_id = g.games_id
    GROUP BY g.games_id
    ORDER BY sports DESC;
END //

/*================================= CALLS TO PROCEDURES ================================= */

-- 1. Mention the total no of committees who participated in each olympics game?
-- CALL partcipation();

-- 2. Which olympic games saw the highest and lowest no of participation?
-- CALL participation_range();

-- 3. Which committees have participated in all of the olympic games?
-- CALL prolific_partcipant();

-- 4. Identify the sports played in all summer olympics.
-- CALL popular_sport();

-- 5. Which Sports were played only once in the olympics?
-- CALL unpopular_sport();

-- 6. Fetch the total no of sports played in each olympic games.
-- CALL sports_count();