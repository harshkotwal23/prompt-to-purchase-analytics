-- 1. Load Data --
.mode csv
    .import <filepath>/queries.csv
    .import <filepath>/products.csv
    .import <filepath>/match_events.csv;

-- 2. Join Tables --
SELECT * 
FROM match_events ME -- junction table
JOIN queries Q ON ME.query_id = Q.query_id -- first join 
JOIN products P ON ME.product_id = P.product_id; -- second table joined

-- 3. View CTR by Rank --
SELECT 
	match_rank AS Rank, -- Our 1st output column will be Rank
	SUM(CASE WHEN ME.clicked = 'True' THEN 1 ELSE 0 END) AS Clicks, -- 2nd column calculates the number of clicks by counting and adding a 1 every time the 'clicked' field displays a 'True'
	COUNT(*) as Impressions, -- 3rd column counts total 'impressions' or simply, all the rows in our dataset
	(SUM(CASE WHEN ME.clicked = 'True' THEN 1 ELSE 0 END)*100)/COUNT(*) AS CTR -- 4th column calculates the CTR by dividing Clicks by Impressions and multiplying the decimal value by 100 to get a percentage
FROM match_events ME
JOIN queries Q ON ME.query_id = Q.query_id
JOIN products P ON ME.product_id = P.product_id
GROUP BY match_rank -- Splits and groups previously calculated Clicks, Impressions, and CTRs by the Rank for further analysis
ORDER BY match_rank ASC; -- Orders our output by ascending Rank

-- 4. View Average TS by Rank --
SELECT 
	match_rank AS Rank, -- first output is rank
	ROUND(AVG(time_spent_on_page_cleaned),0) AS AverageTimeSpent -- second output is rounded average time spent on the clicked website
FROM match_events_cleaned MEC
	JOIN products P ON MEC.product_id = P.product_id
	JOIN queries Q ON MEC.query_id = Q.query_id
WHERE MEC.clicked = 'TRUE' -- returns only clicked event times since non-clicked events will have a time spent of 0, skewing the average 
GROUP BY Rank
ORDER BY Rank ASC;