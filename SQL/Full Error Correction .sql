				-- 6

-- Task : Checking if the Hidden Character is there in Other Tables.

-- Note : Never Clean Text in Fact, Clear the text in Dim then lock them. 

-- STEP - 1 : Read Only Audit All Dim For Any Hidden Character in Text Columns. 
--			  Skip Dim_Department as we alrerady corrected it.
--			  Looking For the Character Length and Looking or the Same Last Character error.

-- Dimensions Check [7]

-- 1
SELECT
    Department_ID,
    Department_Name,
    LEN(Department_Name)            AS Len_Normal,
    DATALENGTH(Department_Name)     AS Len_Bytes,
    ASCII(SUBSTRING(Department_Name, 1, 1)) AS FirstCharCode,
    UNICODE(RIGHT(Department_Name,1)) AS LastCharCode
FROM dbo.Dim_Department; -- No Issue
-- Corrected Previously.

-- 2
SELECT
    Phase_ID,
    Phase_Name,
    LEN(Phase_Name)            AS Len_Normal,
    DATALENGTH(Phase_Name)     AS Len_Bytes,
    ASCII(SUBSTRING(Phase_Name, 1, 1)) AS FirstCharCode,
    UNICODE(RIGHT(Phase_Name,1)) AS LastCharCode
FROM dbo.Dim_Phase;   -- Found Issue 
-- Found lastcharcode as 13 for all the data there, which is carriage return

-- 3 
SELECT
    Manager_ID,
    Manager,
    LEN(Manager)            AS Len_Normal,
    DATALENGTH(Manager)     AS Len_Bytes,
    ASCII(SUBSTRING(Manager, 1, 1)) AS FirstCharCode,
    UNICODE(RIGHT(Manager,1)) AS LastCharCode
FROM dbo.Dim_Manager;  -- Found Issue 
-- Found lastcharcode as 13 for all the data there, which is carriage return

-- 4
SELECT
    Client_ID,
    Client_Name,
    LEN(Client_Name)            AS Len_Normal,
    DATALENGTH(Client_Name)     AS Len_Bytes,
    ASCII(SUBSTRING(Client_Name, 1, 1)) AS FirstCharCode,
    UNICODE(RIGHT(Client_Name,1)) AS LastCharCode
FROM dbo.Dim_Client;  -- Found Issue 
-- Found lastcharcode as 13 for all the data there, which is carriage return

-- 5 
SELECT
    Region_ID,
    Region,
    LEN(Region)            AS Len_Normal,
    DATALENGTH(Region)     AS Len_Bytes,
    ASCII(SUBSTRING(Region, 1, 1)) AS FirstCharCode,
    UNICODE(RIGHT(Region,1)) AS LastCharCode
FROM dbo.Dim_Region;   -- Found Issue 
-- Found lastcharcode as 13 for all the data there, which is carriage return

-- 6 
SELECT
    Project_ID,
    LEN(Project_ID)            AS Len_Normal,
    DATALENGTH(Project_ID)     AS Len_Bytes,
    ASCII(SUBSTRING(Project_ID, 1, 1)) AS FirstCharCode,
    UNICODE(RIGHT(Project_ID,1)) AS LastCharCode,  -- NO Error

    Project_Name,
    LEN(Project_Name)            AS Len_Normal,
    DATALENGTH(Project_Name)     AS Len_Bytes,
    ASCII(SUBSTRING(Project_Name, 1, 1)) AS FirstCharCode,
    UNICODE(RIGHT(Project_Name,1)) AS LastCharCode, -- NO Error

    Project_Status,
    LEN(Project_Status)            AS Len_Normal,
    DATALENGTH(Project_Status)     AS Len_Bytes,
    ASCII(SUBSTRING(Project_Status, 1, 1)) AS FirstCharCode,
    UNICODE(RIGHT(Project_Status,1)) AS LastCharCode, -- NO Error

    Project_Size,
    LEN(Project_Size)            AS Len_Normal,
    DATALENGTH(Project_Size)     AS Len_Bytes,
    ASCII(SUBSTRING(Project_Size, 1, 1)) AS FirstCharCode,
    UNICODE(RIGHT(Project_Size,1)) AS LastCharCode -- Found Issue 
-- Found lastcharcode as 13 for all the data there, which is carriage return
FROM dbo.Dim_Project;

-- 7
SELECT
    Time_ID,
    LEN(Month_Name)            AS Len_Normal,
    DATALENGTH(Month_Name)     AS Len_Bytes,
    ASCII(SUBSTRING(Month_Name, 1, 1)) AS FirstCharCode,
    UNICODE(RIGHT(Month_Name,1)) AS LastCharCode
FROM dbo.Dim_Time -- Found Issue 
-- Found lastcharcode as 13 for all the data there, which is carriage return


-- STEP - 2 : Remove Carriage Return & Check
--            Done Only For the Columns With Issue. [ Numbers Match Step 1 ] 
--            Re run Step 1 to Check or (b)

-- 2 (a)
UPDATE dbo.Dim_Phase
SET Phase_Name = 
    TRIM(
        REPLACE(Phase_Name, CHAR(13), --Explicitly Removes
    '')
        );

--    (b)
SELECT *
FROM dbo.Dim_Phase
WHERE Phase_Name = 'Foundation';

-- 3 (a)
UPDATE dbo.Dim_Manager
SET Manager = 
    TRIM(
        REPLACE(Manager, CHAR(13), --Explicitly Removes
    '')
        );

--    (b)
SELECT *
FROM dbo.Dim_Manager
WHERE Manager = 'Ayesha Rahman';

-- 4 (a)
UPDATE dbo.Dim_Client
SET Client_Name = 
    TRIM(
        REPLACE(Client_Name, CHAR(13), --Explicitly Removes
    '')
        );

--    (b)
SELECT *
FROM dbo.Dim_Client
WHERE Client_Name = 'PQR Infra';

-- 5 (a)
UPDATE dbo.Dim_Region
SET Region = 
    TRIM(
        REPLACE(Region, CHAR(13), --Explicitly Removes
    '')
        );

--    (b)
SELECT *
FROM dbo.Dim_Region
WHERE Region = 'Abu Dhabi';

-- 6 (a)
UPDATE dbo.Dim_Project
SET Project_Size = 
    TRIM(
        REPLACE(Project_Size, CHAR(13), --Explicitly Removes
    '')
        );

--    (b)
SELECT COUNT (Project_ID)
FROM dbo.Dim_Project
WHERE Project_Size = 'Big';

-- 7 (a)
UPDATE dbo.Dim_Time
SET Month_Name = 
    TRIM(
        REPLACE(Month_Name, CHAR(13), --Explicitly Removes
    '')
        );

--    (b)
SELECT *
FROM dbo.Dim_Time
WHERE Month_Name = 'Aug';

-- TASK COMPLETE: All Errors are Corrected and Verified.
