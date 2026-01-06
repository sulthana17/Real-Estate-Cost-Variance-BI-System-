                -- 7

-- TASK : Building Views 

-- STRUCTURE : 4 Views With Different Grain Discipline and SQl-first Business Logic.

-- STEP - 1 : Building Views

-- VIEW 1 : Project_Level Variance 
       
-- Info -   Grain : Project
--          Category : Validation View

CREATE OR ALTER VIEW vw_Project_Variance
AS
SELECT
    p.Project_ID,
    p.Project_Name,
    p.Project_Status,
    r.Region,
    c.Client_Name,
    m.Manager,

    SUM(ISNULL(b.Budget_Cost, 0)) AS Total_Budget,
    SUM(ISNULL(a.Actual_Cost, 0)) AS Total_Actual,

    SUM(ISNULL(a.Actual_Cost, 0)) - SUM(ISNULL(b.Budget_Cost, 0)) AS Net_Variance,

    CASE 
        WHEN SUM(ISNULL(b.Budget_Cost, 0)) = 0 THEN 0
        ELSE
            (SUM(ISNULL(a.Actual_Cost, 0)) - SUM(ISNULL(b.Budget_Cost, 0)))
            / SUM(ISNULL(b.Budget_Cost, 0)) * 100
    END AS Variance_Pct

FROM Dim_Project p
LEFT JOIN Fact_Budget b
    ON p.Project_ID = b.Project_ID
LEFT JOIN Fact_Actual a
    ON p.Project_ID = a.Project_ID
   AND b.Time_ID = a.Time_ID
   AND b.Phase_ID = a.Phase_ID
   AND b.Department_ID = a.Department_ID
   AND b.CostType_ID = a.CostType_ID

JOIN Dim_Region  r ON p.Region_ID  = r.Region_ID
JOIN Dim_Client  c ON p.Client_ID  = c.Client_ID
JOIN Dim_Manager m ON p.Manager_ID = m.Manager_ID

GROUP BY
    p.Project_ID,
    p.Project_Name,
    p.Project_Status,
    r.Region,
    c.Client_Name,
    m.Manager;

-- VIEW 2 : Monthly Budget vs Actual 

-- Info -   Grain : Month / Time
--          Category : Time Series / Trend Analysis View 

CREATE OR ALTER VIEW vw_Monthly_Budget_Actual
AS
SELECT
    t.Year,
    t.Month,
    t.Month_Name,
    t.YYYY_MM,
    SUM(b.Budget_Cost) AS Total_Budget,
    SUM(a.Actual_Cost) AS Total_Actual,
    SUM(a.Actual_Cost) - SUM(b.Budget_Cost) AS Net_Variance,
    CASE 
        WHEN SUM(b.Budget_Cost) = 0 THEN 0
        ELSE ((SUM(a.Actual_Cost) - SUM(b.Budget_Cost)) / SUM(b.Budget_Cost)) * 100
    END AS Variance_Pct
FROM Fact_Budget b
JOIN Fact_Actual a
    ON b.Project_ID = a.Project_ID
   AND b.Time_ID    = a.Time_ID
   AND b.Phase_ID   = a.Phase_ID
   AND b.Department_ID = a.Department_ID
   AND b.CostType_ID   = a.CostType_ID
JOIN Dim_Time t
    ON b.Time_ID = t.Time_ID
GROUP BY
    t.Year, t.Month, t.Month_Name, t.YYYY_MM;

-- VIEW 3 : Phase and Department Variance 

-- Info -   Grain : Phase * Department
--          Category : Root Cause Analysis


CREATE OR ALTER VIEW vw_Phase_Department_Variance
AS
SELECT
    ph.Phase_Name,
    d.Department_Name,
    SUM(b.Budget_Cost) AS Total_Budget,
    SUM(a.Actual_Cost) AS Total_Actual,
    SUM(a.Actual_Cost) - SUM(b.Budget_Cost) AS Net_Variance,
    CASE 
        WHEN SUM(b.Budget_Cost) = 0 THEN 0
        ELSE ((SUM(a.Actual_Cost) - SUM(b.Budget_Cost)) / SUM(b.Budget_Cost)) * 100
    END AS Variance_Pct
FROM Fact_Budget b
JOIN Fact_Actual a
    ON b.Project_ID = a.Project_ID
   AND b.Time_ID    = a.Time_ID
   AND b.Phase_ID   = a.Phase_ID
   AND b.Department_ID = a.Department_ID
   AND b.CostType_ID   = a.CostType_ID
JOIN Dim_Phase ph       ON b.Phase_ID = ph.Phase_ID
JOIN Dim_Department d   ON b.Department_ID = d.Department_ID
GROUP BY
    ph.Phase_Name, d.Department_Name;

-- VIEW 4 : Project Variance BI 

-- Info -   Grain : Project * Month * Phase * Department * CostType
--          Category : BI Semantic Layer 

CREATE OR ALTER VIEW dbo.vw_Project_Variance_BI
AS
SELECT
    fv.Variance_ID,
    fv.Project_ID,
    fv.Time_ID,
    fv.Phase_ID,
    fv.Department_ID,
    fv.CostType_ID,
    p.Project_Name,
    p.Project_Status,
    p.Project_Size,
    p.Contract_Value,
    p.Start_Date,
    p.End_Date,
    r.Region,
    c.Client_Name,
    m.Manager,
    t.YYYY_MM,
    t.Year,
    t.Month,
    t.Month_Name,
    ph.Phase_Name,
    d.Department_Name,
    d.Is_Controllable,
    ct.Cost_Type,
    fv.Budget_Cost,
    fv.Actual_Cost,
    fv.Variance,
    fv.Variance_Pct,
    CASE
        WHEN fv.Variance > 0 THEN 'Unfavorable'
        WHEN fv.Variance < 0 THEN 'Favorable'
        ELSE 'Neutral'
    END AS Variance_Flag,
    fv.Rule_Breached
FROM dbo.Fact_Variance fv

JOIN dbo.Dim_Project     p  ON fv.Project_ID    = p.Project_ID
JOIN dbo.Dim_Region      r  ON p.Region_ID      = r.Region_ID
JOIN dbo.Dim_Client      c  ON p.Client_ID      = c.Client_ID
JOIN dbo.Dim_Manager     m  ON p.Manager_ID     = m.Manager_ID
JOIN dbo.Dim_Time        t  ON fv.Time_ID       = t.Time_ID
JOIN dbo.Dim_Phase       ph ON fv.Phase_ID      = ph.Phase_ID
JOIN dbo.Dim_Department  d  ON fv.Department_ID = d.Department_ID
JOIN dbo.Dim_CostType    ct ON fv.CostType_ID   = ct.CostType_ID;


-- TASK COMPLETE : All Views are Created.
