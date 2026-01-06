                        -- 5

-- TASK: We Found Extra space Found While Trying to add a new Column.

-- STEP - 1 : Show Real Value 

SELECT
    Department_ID,
    Department_Name,
    LEN(Department_Name)      AS Len_Normal,
    DATALENGTH(Department_Name) AS Len_Bytes,
    ASCII(SUBSTRING(Department_Name, 1, 1)) AS FirstCharCode
FROM dbo.Dim_Department;   -- Found the Len Issue 

-- STEP - 2 :Alter & Correct Error 

UPDATE dbo.Dim_Department
SET Department_Name =
    LTRIM(RTRIM(
        REPLACE(
            REPLACE(Department_Name, CHAR(160), ' '),  -- non-breaking space
            CHAR(9), ' '                                -- tab
        )
    ));

-- STEP - 3 : Crosschecked and still found the error so I Looked into lastcharacter 

SELECT
    Department_ID,
    Department_Name,
    LEN(Department_Name)            AS Len_Normal,
    DATALENGTH(Department_Name)     AS Len_Bytes,
    UNICODE(RIGHT(Department_Name,1)) AS LastCharCode
FROM dbo.Dim_Department;  

-- Found lastcharcode as 13 for all the data there, which is carriage return

-- STEP - 4 : Remove Carriage Return 

UPDATE dbo.Dim_Department
SET Department_Name = 
    TRIM(
        REPLACE(Department_Name, CHAR(13), --Explicitly Removes
    '')
        );

-- STEP - 5 : Check Again [Execute Code 3 Again] 

-- STEP - 6 : Confirm Again

SELECT * 
FROM dbo.Dim_Department
WHERE Department_Name = 'Labor';

--  TASK COMPLETE: Dim_Department is ready to add Controllable VS Uncontrollable Column.