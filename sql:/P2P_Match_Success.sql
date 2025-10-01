-- 1. Load Data --
.mode csv
    .import <filepath>/queries.csv
    .import <filepath>/products.csv
    .import <filepath>/match_events.csv

-- 2. Join Tables --
SELECT * 
FROM match_events ME -- junction table
JOIN queries Q ON ME.query_id = Q.query_id -- first join 
JOIN products P ON ME.product_id = P.product_id; -- second table joined

-- 3. Data Normalization --
SELECT 
	ME.event_id AS pair_id, -- temporarily changing match events row ids label to pair ids
	ME.query_id, 
	ME.product_id,
	REPLACE(LOWER(Q.mapped_intent),' ','') AS mapped_norm, -- removing spaces, converting to lower case
	',' || REPLACE(LOWER(COALESCE(P.matched_intents,'')) ,' ','') || ',' AS matched_norm -- removing spaces, converting to lower case, adding commas
FROM match_events ME
JOIN queries Q ON Q.query_id = ME.query_id
JOIN products P ON P.product_id = ME.product_id

-- 4. Measure Match Success -- 
WITH normalized AS ( -- creating a temporary table
SELECT 
	ME.event_id AS pair_id, 
	ME.query_id, 
	ME.product_id,
	REPLACE(LOWER(Q.mapped_intent),' ','') AS mapped_norm,
	',' || REPLACE(LOWER(COALESCE(P.matched_intents,'')) ,' ','') || ',' AS matched_norm
FROM match_events ME
JOIN queries Q ON Q.query_id = ME.query_id
JOIN   products P ON P.product_id = ME.product_id)

SELECT 
	pair_id, query_id, product_id,
	mapped_norm AS mapped, -- temporarily renaming normalized intent columns 
	matched_norm AS matched, -- temporarily renaming normalized intent columns 
	CASE
		WHEN matched_norm LIKE '%,' || mapped_norm || ',%' THEN 1 
		ELSE 0 -- -- LIKE check for match success, outputting a boolean value
	END AS match_success
FROM normalized;

-- 5. Match Success Rate -- 
SELECT ROUND(AVG(match_success)*100,1) AS match_success_rate
FROM discrete_match_success; -- temporary view storing initial query

-- 6. Match Success by CTR --
SELECT dms.match_success,
       SUM(CASE WHEN me.clicked='True' THEN 1 ELSE 0 END) AS clicks, -- Converting clicks to boolean
       COUNT(*) AS impressions, -- calculating impressions as our total rows
       ROUND(100.0*SUM(CASE WHEN me.clicked='True' THEN 1 ELSE 0 END)/COUNT(*),1) AS CTR -- calculating CTR from clicks and impressions
FROM discrete_match_success dms -- referencing view
JOIN match_events me ON me.event_id = dms.pair_id
GROUP BY dms.match_success
ORDER BY dms.match_success DESC;