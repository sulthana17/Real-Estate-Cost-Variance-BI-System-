# split_and_prepare_for_sql.py
import pandas as pd
import numpy as np
import os

MASTER_FILE = "Master_Data.csv"
BUDGET_FILE = "Budget.csv"
ACTUAL_FILE = "Actual.csv"
OUTPUT_DIR = "Split_Output"
ENCODING = "utf-8-sig"

os.makedirs(OUTPUT_DIR, exist_ok=True)

print("Loading source files...")
master = pd.read_csv(MASTER_FILE, encoding=ENCODING)
budget = pd.read_csv(BUDGET_FILE, encoding=ENCODING)
actual = pd.read_csv(ACTUAL_FILE, encoding=ENCODING)
print("Files loaded.")

# ----------------------------
# DIMENSIONS
# ----------------------------

# Dim_Region
dim_region = master[["Region"]].drop_duplicates().reset_index(drop=True)
dim_region["Region_ID"] = dim_region.index + 1
dim_region = dim_region[["Region_ID", "Region"]]

# Dim_Client
dim_client = master[["Client_Name"]].drop_duplicates().reset_index(drop=True)
dim_client["Client_ID"] = dim_client.index + 1
dim_client = dim_client[["Client_ID", "Client_Name"]]

# Dim_Manager
dim_manager = master[["Manager"]].drop_duplicates().reset_index(drop=True)
dim_manager["Manager_ID"] = dim_manager.index + 1
dim_manager = dim_manager[["Manager_ID", "Manager"]]

# Dim_Phase
dim_phase = budget[["Phase_Name"]].drop_duplicates().reset_index(drop=True)
dim_phase["Phase_ID"] = dim_phase.index + 1
dim_phase = dim_phase[["Phase_ID", "Phase_Name"]]

# Dim_Department
dim_department = budget[["Department_Name"]].drop_duplicates().reset_index(drop=True)
dim_department["Department_ID"] = dim_department.index + 1
dim_department = dim_department[["Department_ID", "Department_Name"]]

# Dim_CostType
dim_costtype = budget[["Cost_Type"]].drop_duplicates().reset_index(drop=True)
dim_costtype["CostType_ID"] = dim_costtype.index + 1
dim_costtype = dim_costtype[["CostType_ID", "Cost_Type"]]

# Dim_Project
dim_project = master[[
    "Project_ID", "Project_Name", "Region", "Client_Name", "Manager",
    "Project_Status", "Start_Date", "End_Date", "Contract_Value", "Project_Size"
]].drop_duplicates()

dim_project = (
    dim_project
    .merge(dim_region, on="Region")
    .merge(dim_client, on="Client_Name")
    .merge(dim_manager, on="Manager")
)

dim_project = dim_project[[
    "Project_ID", "Project_Name", "Region_ID", "Client_ID", "Manager_ID",
    "Project_Status", "Start_Date", "End_Date", "Contract_Value", "Project_Size"
]]

# ----------------------------
# Dim_Time
# ----------------------------
months = pd.to_datetime(
    pd.concat([budget["Month"], actual["Month"]]).unique(),
    format="%Y-%m"
)

dim_time = pd.DataFrame({"Month_Date": months})
dim_time["Time_ID"] = range(1, len(dim_time) + 1)
dim_time["YYYY_MM"] = dim_time["Month_Date"].dt.strftime("%Y-%m")
dim_time["Year"] = dim_time["Month_Date"].dt.year
dim_time["Month_Num"] = dim_time["Month_Date"].dt.month
dim_time["Month_Name"] = dim_time["Month_Date"].dt.strftime("%b")

dim_time = dim_time[[
    "Time_ID", "YYYY_MM", "Year", "Month_Num", "Month_Name"
]]

# ----------------------------
# FACT_BUDGET
# ----------------------------
fact_budget = (
    budget
    .merge(dim_phase, on="Phase_Name")
    .merge(dim_department, on="Department_Name")
    .merge(dim_costtype, on="Cost_Type")
    .merge(dim_time, left_on="Month", right_on="YYYY_MM")
)

fact_budget = fact_budget[[
    "Project_ID",
    "Time_ID",
    "Phase_ID",
    "Department_ID",
    "CostType_ID",
    "Budget_Cost",
    "Project_Status"
]]

# ----------------------------
# FACT_ACTUAL
# ----------------------------
fact_actual = (
    actual
    .merge(dim_phase, on="Phase_Name")
    .merge(dim_department, on="Department_Name")
    .merge(dim_costtype, on="Cost_Type")
    .merge(dim_time, left_on="Month", right_on="YYYY_MM")
)

fact_actual = fact_actual[[
    "Project_ID",
    "Time_ID",
    "Phase_ID",
    "Department_ID",
    "CostType_ID",
    "Actual_Cost",
    "Project_Status"
]]

# ----------------------------
# FACT_VARIANCE
# ----------------------------
fv = fact_budget.merge(
    fact_actual,
    on=["Project_ID", "Time_ID", "Phase_ID", "Department_ID", "CostType_ID"],
    suffixes=("_Budget", "_Actual")
)

fv["Variance"] = fv["Actual_Cost"] - fv["Budget_Cost"]
fv["Variance_Pct"] = np.where(
    fv["Budget_Cost"] == 0, 0,
    (fv["Variance"] / fv["Budget_Cost"]) * 100
)

fact_variance = fv[[
    "Project_ID", "Time_ID", "Phase_ID", "Department_ID", "CostType_ID",
    "Budget_Cost", "Actual_Cost", "Variance", "Variance_Pct", "Project_Status_Budget"
]].rename(columns={"Project_Status_Budget": "Project_Status"})

# ----------------------------
# SAVE
# ----------------------------
def save(df, name):
    df.to_csv(os.path.join(OUTPUT_DIR, name), index=False, encoding=ENCODING)
    print(f"Saved {name}")

save(dim_region, "Dim_Region.csv")
save(dim_client, "Dim_Client.csv")
save(dim_manager, "Dim_Manager.csv")
save(dim_phase, "Dim_Phase.csv")
save(dim_department, "Dim_Department.csv")
save(dim_costtype, "Dim_CostType.csv")
save(dim_project, "Dim_Project.csv")
save(dim_time, "Dim_Time.csv")
save(fact_budget, "Fact_Budget.csv")
save(fact_actual, "Fact_Actual.csv")
save(fact_variance, "Fact_Variance.csv")

print("Splitter completed successfully.")
