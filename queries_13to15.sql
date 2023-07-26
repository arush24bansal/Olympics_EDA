USE olympics_data;

/*=================== VIEWS ================================= */

CREATE OR REPLACE VIEW team_accounted_medals AS 
SELECT DISTINCT event_id, games_id, committee_code, medal 
FROM results
WHERE medal > 0;

/*=================== STORED PROCEDURES FOR ANSWERS 1 to 6 ================================= */ 
DELIMITER //  

DROP PROCEDURE IF EXISTS games_leaderboard//
CREATE PROCEDURE games_leaderboard()
BEGIN
	WITH cte AS (
		SELECT *,
			RANK() OVER(PARTITION BY games ORDER BY gold DESC, region ASC) AS gld_rnk,
			RANK() OVER(PARTITION BY games ORDER BY silver DESC, region ASC) AS slvr_rnk,
			RANK() OVER(PARTITION BY games ORDER BY bronze DESC, region ASC) AS brnz_rnk
		FROM (
			SELECT
				c.region,
				CONCAT(g.season, " Olympics ", g.year, ", ", g.host) AS games,
				(CASE WHEN tam.medal = 1 THEN COUNT(*) ELSE 0 END) AS gold,
				(CASE WHEN tam.medal = 2 THEN COUNT(*) ELSE 0 END) AS silver,
				(CASE WHEN tam.medal = 3 THEN COUNT(*) ELSE 0 END) AS bronze
			FROM team_accounted_medals tam
			JOIN committees c
			USING(committee_code)
            JOIN games g
            USING(games_id)
			GROUP BY c.region, g.season, g.year, g.host, tam.medal
		) a
	), cte2 AS (
		SELECT
			games,
			(CASE WHEN gld_rnk = 1 THEN CONCAT(region, " - ", gold)END) AS gold,
			(CASE WHEN slvr_rnk = 1 THEN CONCAT(region, " - ", silver) END) AS silver,
			(CASE WHEN brnz_rnk = 1 THEN CONCAT(region, " - ", bronze) END) AS bronze
		FROM cte
    )
    
    SELECT games, MAX(gold) AS "most gold", MAX(silver) AS "most silver", MAX(bronze) AS "most bronze"
    FROM cte2
    GROUP BY games;
END //

DROP PROCEDURE IF EXISTS elusive_gold//
CREATE PROCEDURE elusive_gold()
BEGIN
	WITH cte AS (
		SELECT region, MAX(gold) AS gold, MAX(silver) AS silver, MAX(bronze) AS bronze
		FROM (
			SELECT
				c.region,
				(CASE WHEN tam.medal = 1 THEN COUNT(*) ELSE 0 END) AS gold,
				(CASE WHEN tam.medal = 2 THEN COUNT(*) ELSE 0 END) AS silver,
				(CASE WHEN tam.medal = 3 THEN COUNT(*) ELSE 0 END) AS bronze
			FROM team_accounted_medals tam
			JOIN committees c
			USING(committee_code)
			GROUP BY c.region, tam.medal
		) a
		GROUP BY region
	)
    
    SELECT * FROM cte WHERE gold = 0 AND (silver <> 0 OR bronze <> 0)
    ORDER BY bronze DESC, silver DESC;
END //


DROP PROCEDURE IF EXISTS india//
CREATE PROCEDURE india()
BEGIN
	SELECT e.sport, COUNT(*) AS medals
    FROM team_accounted_medals tam
    JOIN committees c
    ON tam.committee_code = c.committee_code
    AND c.region = 'India'
    JOIN events e
    ON tam.event_id = e.event_id
    GROUP BY e.sport
    ORDER BY medals DESC
    LIMIT 1;
END //

DELIMITER ;

/*================================= CALLS TO PROCEDURES ================================= */

-- 13. Identify which committee won the most gold, most silver and most bronze medals in each olympic games.
-- CALL games_leaderboard();

-- 14. Which nations have never won gold medal but have won silver/bronze medals?
-- CALL elusive_gold()

-- 15. In which Sport has India won the highest number of medals.
-- CALL india()