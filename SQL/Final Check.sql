							-- 9

-- TASK : Final Check Before BI

-- STEP 1 : Grain Test

SELECT 
	COUNT(*) AS 'RowCount',
	COUNT(DISTINCT CONCAT(Project_ID,
	Time_ID,Phase_ID,Department_ID,
	CostType_ID)) AS DistinctKeyCount
	FROM vw_Project_Variance_BI;              -- Row Count Matches, Grain Done Correctly
--                                                  RowCount	DistinctKeyCount
--                                                   1704	            1704  

-- STEP 2 : Orphan Check

SELECT *
FROM vw_Project_Variance_BI
WHERE 
	Project_ID IS NULL
	OR Time_ID IS NULL
	OR Phase_ID IS NULL
	OR Department_ID IS NULL
	OR CostType_ID IS NULL;  -- Orphan Check Complete
--								0 Rows Returned

-- STEP 3 : Business Logic Spot Check

SELECT TOP 10
	Project_Name,
	Department_Name,
	Budget_Cost,
	Actual_Cost,
	Variance,
	Variance_Pct,
	Variance_Flag,
	Rule_Breached
FROM vw_Project_Variance_BI
ORDER BY ABS(Variance) DESC;  -- Unfavorable And Favorable Looks Logical.

-- TASK COMPLETED : All Checks Complete





