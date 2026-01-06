                       -- 3

-- TASK: Checking and Building the Foreign Key Constrains on 1 Dim & 3 Facts
--       Also Verified Sanity Check

-- STEP - 1 : Check FK constraints on Fact_Budget

SELECT
    f.name AS ForeignKey,
    OBJECT_NAME(f.parent_object_id) AS TableName,
    c.name AS ColumnName,
    ref.name AS RefTable,
    refc.name AS RefColumn
FROM
    sys.foreign_key_columns AS fkc
INNER JOIN
    sys.foreign_keys AS f ON f.object_id = fkc.constraint_object_id
INNER JOIN
    sys.columns AS c ON c.column_id = fkc.parent_column_id
    AND c.object_id = fkc.parent_object_id
INNER JOIN
    sys.tables AS ref ON ref.object_id = fkc.referenced_object_id
INNER JOIN
    sys.columns AS refc ON refc.column_id = fkc.referenced_column_id
    AND refc.object_id = fkc.referenced_object_id
WHERE
    f.parent_object_id = OBJECT_ID('dbo.Fact_Budget');

-- STEP - 2 : Check FK constraints On Fact_Actual

SELECT
    f.name AS ForeignKey,
    OBJECT_NAME(f.parent_object_id) AS TableName,
    c.name AS ColumnName,
    ref.name AS RefTable,
    refc.name AS RefColumn
FROM sys.foreign_key_columns fkc
JOIN sys.foreign_keys f ON f.object_id = fkc.constraint_object_id
JOIN sys.columns c 
  ON c.column_id = fkc.parent_column_id
 AND c.object_id = fkc.parent_object_id
JOIN sys.tables ref 
  ON ref.object_id = fkc.referenced_object_id
JOIN sys.columns refc 
  ON refc.column_id = fkc.referenced_column_id
 AND refc.object_id = fkc.referenced_object_id
WHERE f.parent_object_id = OBJECT_ID('dbo.Fact_Actual');
-- FK exists for Both Budget and Actual

-- For Variance we Creating it.

-- STEP - 3 : Creating FK constraints for Variance
ALTER TABLE Fact_Variance
ADD CONSTRAINT FK_FactVariance_Project
FOREIGN KEY (Project_ID)
REFERENCES Dim_Project(Project_ID);

ALTER TABLE Fact_Variance
ADD CONSTRAINT FK_FactVariance_Time
FOREIGN KEY (Time_ID)
REFERENCES Dim_Time(Time_ID);

ALTER TABLE Fact_Variance
ADD CONSTRAINT FK_FactVariance_Phase
FOREIGN KEY (Phase_ID)
REFERENCES Dim_Phase(Phase_ID);

ALTER TABLE Fact_Variance
ADD CONSTRAINT FK_FactVariance_Department
FOREIGN KEY (Department_ID)
REFERENCES Dim_Department(Department_ID);

-- STEP - 4 : Cross Check Variance
SELECT
    f.name AS ForeignKey,
    OBJECT_NAME(f.parent_object_id) AS TableName,
    c.name AS ColumnName,
    ref.name AS RefTable,
    refc.name AS RefColumn
FROM sys.foreign_key_columns fkc
JOIN sys.foreign_keys f ON f.object_id = fkc.constraint_object_id
JOIN sys.columns c 
  ON c.column_id = fkc.parent_column_id
 AND c.object_id = fkc.parent_object_id
JOIN sys.tables ref 
  ON ref.object_id = fkc.referenced_object_id
JOIN sys.columns refc 
  ON refc.column_id = fkc.referenced_column_id
 AND refc.object_id = fkc.referenced_object_id
WHERE f.parent_object_id = OBJECT_ID('dbo.Fact_Variance');

-- SANITY CHECK

-- STEP - 5 :Checking the totals and Variance
SELECT
    SUM(Budget_Cost) AS Total_Budget,
    SUM(Actual_Cost) AS Total_Actual,
    SUM(Actual_Cost - Budget_Cost) AS Net_Variance
FROM Fact_Variance;

-- STEP - 6 : Checking Any Orphan Facts are there.
SELECT COUNT(*) AS Orphan_Facts
FROM Fact_Variance fv
LEFT JOIN Dim_Project dp ON fv.Project_ID = dp.Project_ID
WHERE dp.Project_ID IS NULL;

-- TASK COMPLETE: All Foreign Keys are Added and Sanity Verified



