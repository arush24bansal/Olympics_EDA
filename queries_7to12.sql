USE olympics_data;

/*=================== VIEWS ================================= */

CREATE OR REPLACE VIEW team_accounted_medals AS 
SELECT DISTINCT event_id, games_id, committee_code, medal 
FROM results
WHERE medal > 0;

/*=================== STORED PROCEDURES FOR ANSWERS 1 to 6 ================================= */ 
DELIMITER //  

DROP PROCEDURE IF EXISTS oldest_winners //
CREATE PROCEDURE oldest_winners()
BEGIN
	SELECT a.athlete_name, r.age, r.medal
    FROM results r
    JOIN athletes a
    ON r.athlete_id = a.athlete_id
    AND r.medal = 1
    AND r.age = (SELECT MAX(age) FROM results WHERE medal = 1);
END //

DROP PROCEDURE IF EXISTS gender_ratio//
CREATE PROCEDURE gender_ratio()
BEGIN
	WITH cte AS (
		SELECT
			(CASE WHEN sex = 'Male' THEN COUNT(*) END) AS male,
			(CASE WHEN sex = 'Female' THEN COUNT(*) END) AS female
		FROM athletes
		GROUP BY sex
	)
    
    SELECT CONCAT('1:', ROUND(MAX(male)/MAX(female), 2)) AS 'F:M ratio' 
    FROM cte;
END //

DROP PROCEDURE IF EXISTS top_athletes_gold//
CREATE PROCEDURE top_athletes_gold()
BEGIN
	WITH cte AS (
		SELECT *,
			DENSE_RANK() OVER(ORDER BY gold_medals DESC) as rnk
		FROM (
			SELECT
				athlete_id,
				COUNT(*) as gold_medals
			FROM results
			WHERE medal = 1
			GROUP BY athlete_id
		) a
	)
    
    SELECT a.athlete_name, cte.gold_medals
    FROM cte
    JOIN athletes a
    ON cte.athlete_id = a.athlete_id
    WHERE rnk <= 5;
END //


DROP PROCEDURE IF EXISTS top_athletes_all//
CREATE PROCEDURE top_athletes_all()
BEGIN
	WITH cte AS (
		SELECT *,
			DENSE_RANK() OVER(ORDER BY medals DESC) as rnk
		FROM (
			SELECT
				athlete_id,
				COUNT(*) as medals
			FROM results
			WHERE medal > 0
			GROUP BY athlete_id
		) a
	)
    
    SELECT a.athlete_name, cte.medals
    FROM cte
    JOIN athletes a
    ON cte.athlete_id = a.athlete_id
    WHERE rnk <= 5;
END //


DROP PROCEDURE IF EXISTS top_nations//
CREATE PROCEDURE top_nations()
BEGIN
	WITH cte AS (
		SELECT *,
			DENSE_RANK() OVER(ORDER BY medals DESC) AS rnk
		FROM (
			SELECT c.region, COUNT(*) as medals
			FROM team_accounted_medals tam
            JOIN committees c
            USING(committee_code)
			GROUP BY c.region
		) a
	)
    
    SELECT *
    FROM cte
    WHERE rnk <= 5;
END //

DROP PROCEDURE IF EXISTS nations_tally//
CREATE PROCEDURE nations_tally()
BEGIN
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
    ORDER BY gold DESC, silver DESC, bronze DESC;
END //


DELIMITER ;

/*================================= CALLS TO PROCEDURES ================================= */

-- 7. Fetch details of the oldest athletes to win a gold medal.
-- CALL oldest_winners();

-- 8. Find the Ratio of male and female athletes participated in all olympic games.
-- CALL gender_ratio();

-- 9. Fetch the athletes with the highest gold medal tally (top 5 tallies).
-- CALL top_athletes_gold();

-- 10. Fetch the athletes with the highest podium finishes (top 5 tallies).
-- CALL top_athletes_all();

-- 11. Fetch the top 5 most successful nations in olympics. Success is defined by no of medals won for events.
-- CALL top_nations();

-- 12. List down total gold, silver and broze medals won by each region.
-- CALL nations_tally();