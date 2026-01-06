                            -- 1

-- TASK: Building Database For Variance BI and Bulk Inserting Generated data.

-- STRUCTURE: The Database Has 8 DIM & 3 FACT. 
--            In the Following Code We are Only Generating 2 Facts [Budgets, Actuals] 
--            Variance Generated Later.

-- STEP - 1 :  Building Dim & Fact Tables 

-- DIMENTIONS [8]

-- 1 
CREATE TABLE Dim_Region (
    Region_ID INT PRIMARY KEY,
    Region NVARCHAR(100)
);
GO

-- 2
CREATE TABLE Dim_Client (
    Client_ID INT PRIMARY KEY,
    Client_Name NVARCHAR(200)
);
GO

-- 3
CREATE TABLE Dim_Manager (
    Manager_ID INT PRIMARY KEY,
    Manager NVARCHAR(200)
);
GO

-- 4
CREATE TABLE Dim_Phase (
    Phase_ID INT PRIMARY KEY,
    Phase_Name NVARCHAR(100)
);
GO

-- 5
CREATE TABLE Dim_Department (
    Department_ID INT PRIMARY KEY,
    Department_Name NVARCHAR(100)
);
GO

-- 6
CREATE TABLE Dim_CostType (
    CostType_ID INT PRIMARY KEY,
    Cost_Type NVARCHAR(100)
);
GO

-- 7 
CREATE TABLE Dim_Time (
    Time_ID INT PRIMARY KEY,
    YYYY_MM CHAR(7),
    Year INT,
    Month INT,
    Month_Name CHAR(10)
);
GO

-- 8
CREATE TABLE Dim_Project (
    Project_ID NVARCHAR(20) PRIMARY KEY,
    Project_Name NVARCHAR(200),
    Region_ID INT,
    Client_ID INT,
    Manager_ID INT,
    Project_Status NVARCHAR(50),
    Start_Date DATE,
    End_Date DATE,
    Contract_Value DECIMAL(18,2),
    Project_Size NVARCHAR(50),

    FOREIGN KEY (Region_ID) REFERENCES Dim_Region(Region_ID),
    FOREIGN KEY (Client_ID) REFERENCES Dim_Client(Client_ID),
    FOREIGN KEY (Manager_ID) REFERENCES Dim_Manager(Manager_ID)
);
GO

-- FACTS [2]

-- 1 
CREATE TABLE Fact_Budget (
    Project_ID NVARCHAR(20),
    Time_ID INT,
    Phase_ID INT,
    Department_ID INT,
    CostType_ID INT,
    Budget_Cost DECIMAL(18,2),
    Project_Status NVARCHAR(50),

    FOREIGN KEY (Project_ID) REFERENCES Dim_Project(Project_ID),
    FOREIGN KEY (Time_ID) REFERENCES Dim_Time(Time_ID),
    FOREIGN KEY (Phase_ID) REFERENCES Dim_Phase(Phase_ID),
    FOREIGN KEY (Department_ID) REFERENCES Dim_Department(Department_ID),
    FOREIGN KEY (CostType_ID) REFERENCES Dim_CostType(CostType_ID)
);
GO

-- 2
CREATE TABLE Fact_Actual (
    Project_ID NVARCHAR(20),
    Time_ID INT,
    Phase_ID INT,
    Department_ID INT,
    CostType_ID INT,
    Actual_Cost DECIMAL(18,2),
    Project_Status NVARCHAR(50),

    FOREIGN KEY (Project_ID) REFERENCES Dim_Project(Project_ID),
    FOREIGN KEY (Time_ID) REFERENCES Dim_Time(Time_ID),
    FOREIGN KEY (Phase_ID) REFERENCES Dim_Phase(Phase_ID),
    FOREIGN KEY (Department_ID) REFERENCES Dim_Department(Department_ID),
    FOREIGN KEY (CostType_ID) REFERENCES Dim_CostType(CostType_ID)
);
GO

-- Dim & Fact Generted Without Errors

-- STEP - 2 : BULK INSERT INTO TABLES

-- 1
BULK INSERT Dim_Region
FROM 'F:\Project\Variance\Variance_0\Split_Output\Dim_Region.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001'
);
GO

-- 2 
BULK INSERT Dim_Client
FROM 'F:\Project\Variance\Variance_0\Split_Output\Dim_Client.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001'
);
GO

-- 3 
BULK INSERT Dim_Manager
FROM 'F:\Project\Variance\Variance_0\Split_Output\Dim_Manager.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001'
);
GO

-- 4 
BULK INSERT Dim_Phase
FROM 'F:\Project\Variance\Variance_0\Split_Output\Dim_Phase.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001'
);
GO

-- 5 
BULK INSERT Dim_Department
FROM 'F:\Project\Variance\Variance_0\Split_Output\Dim_Department.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001'
);
GO

-- 6
BULK INSERT Dim_CostType
FROM 'F:\Project\Variance\Variance_0\Split_Output\Dim_CostType.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001'
);
GO

-- 7
BULK INSERT Dim_Time
FROM 'F:\Project\Variance\Variance_0\Split_Output\Dim_Time.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001'
);
GO

-- 8 
BULK INSERT Dim_Project
FROM 'F:\Project\Variance\Variance_0\Split_Output\Dim_Project.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001'
);
GO

-- 9 
BULK INSERT Fact_Budget
FROM 'F:\Project\Variance\Variance_0\Split_Output\Fact_Budget.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001'
);
GO

-- 10
BULK INSERT Fact_Actual
FROM 'F:\Project\Variance\Variance_0\Split_Output\Fact_Actual.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001'
);
GO

-- TASK COMPLETE : All Tables are Created and Loaded Except Variance

