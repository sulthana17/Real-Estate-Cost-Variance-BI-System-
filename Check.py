# validate_project_data_2025.py
# Validate Master, Budget, and Actual tables for 2025

import pandas as pd
import numpy as np

# -------------------------
# CONFIG
# -------------------------
MASTER_FILE = "Master_Data.csv"
BUDGET_FILE = "Budget.csv"
ACTUAL_FILE = "Actual.csv"
REPORT_FILE = "Validation_Report_2025.txt"

ANALYSIS_YEAR = 2025

report_lines = []
def log(msg):
    print(msg)
    report_lines.append(str(msg))

# -------------------------
# 1. LOAD FILES
# -------------------------
log("===== DATA VALIDATION REPORT =====\n")
try:
    master = pd.read_csv(MASTER_FILE)
    budget = pd.read_csv(BUDGET_FILE)
    actual = pd.read_csv(ACTUAL_FILE)
    log("Files loaded successfully.\n")
except Exception as e:
    log(f"File loading ERROR: {e}")
    raise SystemExit()

# -------------------------
# 2. MASTER TABLE VALIDATION
# -------------------------
log("---- MASTER DATA VALIDATION ----")
master['Start_Date'] = pd.to_datetime(master['Start_Date'])
master['End_Date'] = pd.to_datetime(master['End_Date'])

log(f"Total Projects: {len(master)}")
log(f"Unique Project IDs: {master['Project_ID'].nunique()}")

# Date check
invalid_dates = master[master['Start_Date'] > master['End_Date']]
if invalid_dates.empty:
    log("✓ All project dates are valid.")
else:
    log("⚠ Invalid Start/End Dates found:")
    log(invalid_dates.to_string())

# Status check
def validate_status(row):
    if row['End_Date'].year <= ANALYSIS_YEAR:
        return row['Project_Status'] in ['Completed', 'Delayed', 'On Hold']
    else:
        return row['Project_Status'] in ['Active', 'On Hold']

master['Status_Valid'] = master.apply(validate_status, axis=1)
invalid_status = master[master['Status_Valid'] == False]
if invalid_status.empty:
    log("✓ All project statuses follow logic.\n")
else:
    log("⚠ Incorrect project statuses detected:")
    log(invalid_status.to_string())

# -------------------------
# 3. BUDGET & ACTUAL TIMELINE VALIDATION
# -------------------------
log("---- BUDGET + ACTUAL VALIDATION ----")
budget['Month'] = pd.to_datetime(budget['Month'], format="%Y-%m")
actual['Month'] = pd.to_datetime(actual['Month'], format="%Y-%m")

def timeline_check(df_fact, df_master, fact_name):
    merged = df_fact.merge(master[['Project_ID', 'Start_Date', 'End_Date']], on='Project_ID', how='left')
    invalid_months = merged[(merged['Month'] < merged['Start_Date']) | (merged['Month'] > merged['End_Date'])]
    if invalid_months.empty:
        log(f"✓ All {fact_name} months fall within project timeline.")
    else:
        log(f"⚠ {fact_name} months outside timeline detected. Count: {len(invalid_months)}")

timeline_check(budget, master, "Budget")
timeline_check(actual, master, "Actual")

# -------------------------
# 4. VARIANCE VALIDATION
# -------------------------
log("\n---- VARIANCE VALIDATION ----")
merged = budget.merge(
    actual,
    on=['Project_ID','Month','Phase_Name','Department_Name','Cost_Type'],
    suffixes=('_Budget','_Actual'),
    how='inner'
)

merged['Variance'] = merged['Actual_Cost'] - merged['Budget_Cost']
merged['Variance_Pct'] = (merged['Variance'] / merged['Budget_Cost']) * 100

# Merge project status
merged = merged.merge(master[['Project_ID','Project_Status']], on='Project_ID', how='left')

# Rule check: Normal ±20%, Delayed ±30%
merged['Rule_Breached'] = np.where(
    ((merged['Project_Status'] != 'Delayed') & (merged['Variance_Pct'].abs() > 20)) |
    ((merged['Project_Status'] == 'Delayed') & (merged['Variance_Pct'].abs() > 30)),
    True, False
)

breach_count = merged['Rule_Breached'].sum()
if breach_count == 0:
    log("✓ All variance rules followed.")
else:
    log(f"⚠ Variance rule breaches detected. Count: {breach_count}")

# -------------------------
# 5. FINAL SUMMARY
# -------------------------
log("\n===== SUMMARY =====")
log(f"Master Records: {len(master)}")
log(f"Budget Records: {len(budget)}")
log(f"Actual Records: {len(actual)}")
log(f"Variance Rule Breaches: {breach_count}")
log("Validation Completed.\n")

# -------------------------
# 6. SAVE REPORT
# -------------------------
try:
    with open(REPORT_FILE, "w", encoding="utf-8") as f:
        f.write("\n".join(report_lines))
    log(f"Report saved -> {REPORT_FILE}")
except Exception as e:
    log(f"Error writing report: {e}")
