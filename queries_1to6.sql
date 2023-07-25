USE olympics_data;


/*=================== STORED PROCEDURES FOR ALL ANSWERS ================================= */ 
DELIMITER //  

DROP PROCEDURE IF EXISTS participation//
CREATE PROCEDURE participation()
BEGIN
	SELECT
		CONCAT(g.season, ' Olympics, ', g.year, ' - ', g.host) AS games, 
        COUNT(DISTINCT r.committee_code) AS Participants
    FROM results r
    JOIN games g
    ON r.games_id = g.games_id
    GROUP BY g.year, g.season, g.host;
END //

DROP PROCEDURE IF EXISTS participation_range//
CREATE PROCEDURE participation_range()
BEGIN
	WITH cte AS (
		SELECT
			CONCAT(g.season, ' Olympics, ', g.year, ' - ', g.host) AS games, 
			COUNT(DISTINCT r.committee_code) AS Participants
		FROM results r
		JOIN games g
		ON r.games_id = g.games_id
		GROUP BY g.year, g.season, g.host
    )
    
    SELECT 'Minimum' AS "range", cte.*
    FROM cte
    WHERE Participants = (SELECT MIN(Participants) FROM cte)
    UNION
    SELECT 'Maximum' AS "range", cte.* 
    FROM cte
    WHERE Participants = (SELECT MAX(Participants) FROM cte);
END //

DROP PROCEDURE IF EXISTS prolific_participant//
CREATE PROCEDURE prolific_participant()
BEGIN
	WITH cte AS (
		SELECT
			committee_code,
			COUNT(DISTINCT games_id) AS olympic_games
        FROM results
        GROUP BY committee_code
    )
    
    SELECT c.committee_code, c.region, cte.olympic_games
    FROM cte
    JOIN committees c
    ON cte.committee_code = c.committee_code
    WHERE cte.olympic_games = (SELECT COUNT(*) FROM games);
END //

DROP PROCEDURE IF EXISTS popular_sport//
CREATE PROCEDURE popular_sport()
BEGIN
	WITH cte AS (
		SELECT
			e.sport,
			g.season,
            COUNT(DISTINCT g.games_id) AS olympic_games
        FROM results r
        JOIN events e
        ON r.event_id = e.event_id
        JOIN games g
        ON r.games_id = g.games_id
        WHERE g.season = 'Summer'
        GROUP BY e.sport, g.season
    )
    
    SELECT *
    FROM cte
    WHERE olympic_games = (SELECT COUNT(*) FROM games WHERE season = 'Summer');
END //

/*================================= CALLS TO PROCEDURES ================================= */
CALL popular_sport();