					-- 8 

-- TASK : Creating Indexes

-- STRUCTURE : 3 Category Of Indexes 
--			     1. Safety & Correctness ~ Foreign Key Indexes
--			     2. Performance Engine ~ Composite BI Index
--				 3. UX Polish ~ Few Selective Dimension Indexes

-- STEP - 1 : Safety & Correctness ~ Foreign Key Indexes [3 Facts]

-- Fact Budget
CREATE NONCLUSTERED INDEX IX_Fact_Budget_Project
ON Fact_Budget (Project_ID);

CREATE NONCLUSTERED INDEX IX_Fact_Budget_Time
ON Fact_Budget (Time_ID);

CREATE NONCLUSTERED INDEX IX_Fact_Budget_Phase
ON Fact_Budget (Phase_ID);

CREATE NONCLUSTERED INDEX IX_Fact_Budget_Department
ON Fact_Budget (Department_ID);

CREATE NONCLUSTERED INDEX IX_Fact_Budget_CostType
ON Fact_Budget (CostType_ID);

-- Fact Actual
CREATE NONCLUSTERED INDEX IX_Fact_Actual_Project
ON Fact_Actual (Project_ID);

CREATE NONCLUSTERED INDEX IX_Fact_Actual_Time
ON Fact_Actual (Time_ID);

CREATE NONCLUSTERED INDEX IX_Fact_Actual_Phase
ON Fact_Actual (Phase_ID);

CREATE NONCLUSTERED INDEX IX_Fact_Actual_Department
ON Fact_Actual (Department_ID);

CREATE NONCLUSTERED INDEX IX_Fact_Actual_CostType
ON Fact_Actual (CostType_ID);

-- Fact Variance
CREATE NONCLUSTERED INDEX IX_Fact_Variance_Project
ON Fact_Variance (Project_ID);

CREATE NONCLUSTERED INDEX IX_Fact_Variance_Time
ON Fact_Variance (Time_ID);

CREATE NONCLUSTERED INDEX IX_Fact_Variance_Phase
ON Fact_Variance (Phase_ID);

CREATE NONCLUSTERED INDEX IX_Fact_Variance_Department
ON Fact_Variance (Department_ID);

CREATE NONCLUSTERED INDEX IX_Fact_Variance_CostType
ON Fact_Variance (CostType_ID);

-- STEP - 2 : Performance Engine ~ Composite BI Index

CREATE NONCLUSTERED INDEX
IX_Fact_Variance_BI
ON dbo.Fact_Variance
(
	Time_ID,
	Project_ID,
	Department_ID,
	Phase_ID
)
INCLUDE
(
	Budget_Cost,
	Actual_Cost,
	Variance,
	Variance_Pct,
	Project_Status,
	Rule_Breached
);

-- STEP - 3 : UX Polish ~ Few Selective Dimension Indexes

-- Dim_Time
CREATE NONCLUSTERED INDEX
IX_Dim_Time_YYYY_MM
ON dbo.Dim_Time(YYYY_MM);

-- Dim_Department
CREATE NONCLUSTERED INDEX
IX_Dim_Department_IsControllable
ON dbo.Dim_Department (Is_Controllable);

-- TASK COMPLETE : All Indexes are done
