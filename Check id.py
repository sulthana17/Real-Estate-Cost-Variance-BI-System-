import pandas as pd

print("Checking ID mappings...")

# Load dimensions
dim_region = pd.read_csv("Split_Output/Dim_Region.csv")
dim_client = pd.read_csv("Split_Output/Dim_Client.csv")
dim_manager = pd.read_csv("Split_Output/Dim_Manager.csv")
dim_phase = pd.read_csv("Split_Output/Dim_Phase.csv")
dim_department = pd.read_csv("Split_Output/Dim_Department.csv")
dim_costtype = pd.read_csv("Split_Output/Dim_CostType.csv")

# Load facts
fact_budget = pd.read_csv("Split_Output/Fact_Budget.csv")
fact_actual = pd.read_csv("Split_Output/Fact_Actual.csv")

# Load original raw files
budget = pd.read_csv("Budget.csv")
actual = pd.read_csv("Actual.csv")
master = pd.read_csv("Master_Data.csv")

# -------------------------
# 1. Check Phase Mapping
# -------------------------
phase_check = (
    budget[["Phase_Name"]]
    .drop_duplicates()
    .merge(dim_phase, on="Phase_Name", how="left")
)

missing_phase = phase_check[phase_check["Phase_ID"].isna()]

# -------------------------
# 2. Check Department Mapping
# -------------------------
dept_check = (
    budget[["Department_Name"]]
    .drop_duplicates()
    .merge(dim_department, on="Department_Name", how="left")
)

missing_dept = dept_check[dept_check["Department_ID"].isna()]

# -------------------------
# 3. Check CostType Mapping
# -------------------------
cost_check = (
    budget[["Cost_Type"]]
    .drop_duplicates()
    .merge(dim_costtype, on="Cost_Type", how="left")
)

missing_cost = cost_check[cost_check["CostType_ID"].isna()]

# -------------------------
# 4. Check Project Dim FK Mapping
# -------------------------
project_check = (
    master[["Region", "Client_Name", "Manager"]]
    .drop_duplicates()
    .merge(dim_region, on="Region", how="left")
    .merge(dim_client, on="Client_Name", how="left")
    .merge(dim_manager, on="Manager", how="left")
)

missing_proj_fk = project_check[
    project_check[["Region_ID", "Client_ID", "Manager_ID"]].isna().any(axis=1)
]

# -------------------------------------------
# FINAL RESULTS
# -------------------------------------------

print("\n--- PHASE MISMATCHES ---")
print(missing_phase if len(missing_phase) else "OK! All Phase IDs matched.")

print("\n--- DEPARTMENT MISMATCHES ---")
print(missing_dept if len(missing_dept) else "OK! All Department IDs matched.")

print("\n--- COST TYPE MISMATCHES ---")
print(missing_cost if len(missing_cost) else "OK! All CostType IDs matched.")

print("\n--- PROJECT DIM FOREIGN KEY MISMATCHES ---")
print(missing_proj_fk if len(missing_proj_fk) else "OK! All Project FK IDs matched.")

print("\nID Mapping Check Completed.")
