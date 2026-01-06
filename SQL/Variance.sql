                    -- 2

-- TASK : Creating and Calculating Variance.

-- STRUCTURE : Variance is Built First and Data's are Calculated with Budget & Actual.

-- STEP - 1 : Building Variance Table Structure 

CREATE TABLE Fact_Variance (
    Variance_ID INT IDENTITY(1,1) PRIMARY KEY,

    Project_ID NVARCHAR(20) NOT NULL,
    Time_ID INT NOT NULL,
    Phase_ID INT NOT NULL,
    Department_ID INT NOT NULL,
    CostType_ID INT NOT NULL,

    Budget_Cost DECIMAL(18,2) NOT NULL,
    Actual_Cost DECIMAL(18,2) NOT NULL,
    Variance DECIMAL(18,2) NOT NULL,
    Variance_Pct DECIMAL(18,4) NULL,

    Project_Status NVARCHAR(50),
    Rule_Breached BIT NOT NULL
);

-- STEP - 2 : Populate Variance 

INSERT INTO Fact_Variance (
    Project_ID,
    Time_ID,
    Phase_ID,
    Department_ID,
    CostType_ID,
    Budget_Cost,
    Actual_Cost,
    Variance,
    Variance_Pct,
    Project_Status,
    Rule_Breached
)
SELECT
    b.Project_ID,
    b.Time_ID,
    b.Phase_ID,
    b.Department_ID,
    b.CostType_ID,

    b.Budget_Cost,
    a.Actual_Cost,

    (a.Actual_Cost - b.Budget_Cost) AS Variance,

    CASE
        WHEN b.Budget_Cost = 0 THEN NULL
        ELSE ((a.Actual_Cost - b.Budget_Cost) * 100.0 / b.Budget_Cost)
    END AS Variance_Pct,

    COALESCE(b.Project_Status, a.Project_Status) AS Project_Status,

    CASE
        WHEN COALESCE(b.Project_Status, a.Project_Status) = 'Delayed'
             AND ABS(
                 CASE
                     WHEN b.Budget_Cost = 0 THEN 0
                     ELSE ((a.Actual_Cost - b.Budget_Cost) * 100.0 / b.Budget_Cost)
                 END
             ) > 30 THEN 1
        WHEN COALESCE(b.Project_Status, a.Project_Status) <> 'Delayed'
             AND ABS(
                 CASE
                     WHEN b.Budget_Cost = 0 THEN 0
                     ELSE ((a.Actual_Cost - b.Budget_Cost) * 100.0 / b.Budget_Cost)
                 END
             ) > 20 THEN 1
        ELSE 0
    END AS Rule_Breached
FROM Fact_Budget b
JOIN Fact_Actual a
  ON b.Project_ID    = a.Project_ID
 AND b.Time_ID       = a.Time_ID
 AND b.Phase_ID      = a.Phase_ID
 AND b.Department_ID = a.Department_ID
 AND b.CostType_ID   = a.CostType_ID;

 -- STEP - 3 : Validate Variance [3]
 
 -- 1
 SELECT COUNT(*) AS Variance_Rows FROM Fact_Variance; -- Correct 1704 Rows
 
 -- 2
 SELECT
    MIN(Variance_Pct) AS Min_Pct,
    MAX(Variance_Pct) AS Max_Pct
   FROM Fact_Variance;     -- Correct Min: -19.9946 Max: 29.6677

 -- 3
SELECT Rule_Breached, COUNT(*) 
FROM Fact_Variance
GROUP BY Rule_Breached;  -- Correct Rule_Breached	(No column name)
                         --             0	              1675
                         --             1	                29

-- TASK COMPLETE: Variance Built and Populated.
















