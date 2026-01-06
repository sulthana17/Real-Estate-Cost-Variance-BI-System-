                        -- 4    

--	TASK: Adding an Controllable or Uncontrollable on department for their cost type for Ref Purpose

-- STEP - 1 : Checking the Schema of Department 

SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'Dim_Department';

--  STEP - 2 : Adding Controllability Flag 

ALTER TABLE dbo.Dim_Department
ADD Is_Controllable BIT NOT NULL
    CONSTRAINT DF_Dim_Department_Is_Controllable DEFAULT 1;

-- STEP - 3 : Altering it based on Business Logic [3]

UPDATE dbo.Dim_Department
SET Is_Controllable = 1
WHERE Department_Name IN
('Labor', 'Materials', 'Equipment', 'Logistics'); -- Operation Control

UPDATE dbo.Dim_Department
SET Is_Controllable = 0
WHERE Department_Name IN
('Overheads', 'Safety');  -- Gov Policy/ Complience

-- This Didn't run Due to an Error in Data We Correccted it. 

-- STEP - 4 : There You Can Find the Steps & Code [Error Correction.SQL]

-- STEP - 5 : Re Run Code 3 Again 

-- STEP - 6 : Cross Check the Table

SELECT * 
FROM dbo.Dim_Department; -- Confirmed

-- TASK COMPLETE: We added the column [ It is Used to Understand Whether the Cost is Controllable or Not.
