CREATE DATABASE wb_education;
USE wb_education;

CREATE TABLE education_data (
    District VARCHAR(50),
    Year INT,
    Government INT,
    Private INT,
    Total INT,
    Retention_Rate FLOAT,
    Madhyamik_Pass_Percentage FLOAT,
    HS_Pass_Percentage FLOAT,
    Literacy_Rate FLOAT,
    Girls_Percentage FLOAT,
    Performance_Index FLOAT,
    Calculated_Total INT,
    Total_Difference INT,
    Other_Institutions INT,
    ID VARCHAR(100),
    Madhyamik_Growth FLOAT,
    HS_Growth FLOAT,
    HS_Madhyamik_Gap FLOAT,
    Literacy_Madhyamik_Gap FLOAT,
    Performance_per_Student FLOAT,
    Gender_Deviation FLOAT,
    Composite_Score FLOAT
);

SELECT * FROM education_data LIMIT 10;

SELECT COUNT(*) FROM education_data;

SELECT * 
FROM education_data
WHERE District IS NULL;

-- show all data --
SELECT * FROM education_data;

-- List all districts --
SELECT DISTINCT District FROM education_data;

-- Show data for year 2020 --
SELECT * 
FROM education_data
WHERE Year = 2020;

-- Districts with high performance (>85) --
SELECT District, Performance_Index
FROM education_data
WHERE Performance_Index > 85;

-- Sort districts by performance --
SELECT District, Performance_Index
FROM education_data
ORDER BY Performance_Index DESC;

-- Average performance per district --
SELECT District, ROUND(AVG(Performance_Index),2) AS Avg_Performance
FROM education_data
GROUP BY District;

-- Top 5 districts by average performance --
SELECT District, ROUND(AVG(Performance_Index),2) AS Avg_Performance
FROM education_data
GROUP BY District
ORDER BY Avg_Performance DESC
LIMIT 5;

-- Lowest 5 districts --
SELECT District, ROUND(AVG(Performance_Index),2) AS Avg_Performance
FROM education_data
GROUP BY District
ORDER BY Avg_Performance ASC
LIMIT 5;

-- Year-wise average performance --
SELECT Year, ROUND(AVG(Performance_Index),2) AS Avg_Performance
FROM education_data
GROUP BY Year
ORDER BY Year;

-- Retention category analysis --
SELECT 
    CASE 
        WHEN Retention_Rate < 0.3 THEN 'Low'
        WHEN Retention_Rate BETWEEN 0.3 AND 0.4 THEN 'Medium'
        ELSE 'High'
    END AS Retention_Level,
    ROUND(AVG(Performance_Index),2) AS Avg_Performance
FROM education_data
GROUP BY Retention_Level;

-- Rank districts within each year --
SELECT District, Year, Performance_Index,
       RANK() OVER (PARTITION BY Year ORDER BY Performance_Index DESC) AS Rank_Pos
FROM education_data;

-- Top district per year --
SELECT *
FROM (
    SELECT District, Year, Performance_Index,
           RANK() OVER (PARTITION BY Year ORDER BY Performance_Index DESC) AS rnk
    FROM education_data
) t
WHERE rnk = 1;

-- Most improved districts --
SELECT District,
       MAX(Performance_Index) - MIN(Performance_Index) AS Improvement
FROM education_data
GROUP BY District
ORDER BY Improvement DESC
LIMIT 5;

-- High performance + high retention --
SELECT District, Year, Performance_Index, Retention_Rate
FROM education_data
WHERE Performance_Index > 85
AND Retention_Rate > 0.35;

-- Low literacy but high performance --
SELECT District, Year, Literacy_Rate, Performance_Index
FROM education_data
WHERE Literacy_Rate < 70
AND Performance_Index > 80;

-- Gender impact grouping --
SELECT 
    CASE 
        WHEN Girls_Percentage < 49 THEN 'Low'
        WHEN Girls_Percentage BETWEEN 49 AND 51 THEN 'Balanced'
        ELSE 'High'
    END AS Gender_Group,
    ROUND(AVG(Performance_Index),2) AS Avg_Performance
FROM education_data
GROUP BY Gender_Group;

-- Composite score ranking --
SELECT District,
       ROUND(AVG(Composite_Score),2) AS Score
FROM education_data
GROUP BY District
ORDER BY Score DESC;

-- Find districts where HS performance is always higher than Madhyamik--
SELECT District
FROM education_data
GROUP BY District
HAVING MIN(HS_Pass_Percentage - Madhyamik_Pass_Percentage) > 0;

-- Find districts with consistent improvement --
SELECT District
FROM education_data
GROUP BY District
HAVING MIN(Madhyamik_Growth) > 0;

-- Which year had highest improvement overall? --
SELECT Year,
       AVG(Madhyamik_Growth) AS Avg_Growth
FROM education_data
GROUP BY Year
ORDER BY Avg_Growth DESC;