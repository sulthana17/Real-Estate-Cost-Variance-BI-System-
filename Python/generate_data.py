# generate_master_budget_actual_2025.py
# Generates master project table + budget & actual fact tables for analysis year 2025
# Status rule: reference_date = 2026-01-01 (Option B)
# Run in PyCharm or any Python environment. Requires pandas, numpy.

import pandas as pd
import numpy as np
from datetime import datetime
import math

# -------------------------
# CONFIG
# -------------------------
RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)

ANALYSIS_YEAR = 2025
REFERENCE_DATE = pd.Timestamp("2026-01-01")   # option B uses this
MASTER_FILE = "Master_Data.csv"
BUDGET_FILE = f"Budget.csv"
ACTUAL_FILE = f"Actual.csv"

# -------------------------
# Helper functions
# -------------------------
def months_between(start_ts, end_ts):
    """Return list of pandas.Timestamp (first-of-month) between start and end inclusive."""
    start = pd.Timestamp(start_ts).replace(day=1)
    end = pd.Timestamp(end_ts).replace(day=1)
    months = []
    cur = start
    while cur <= end:
        months.append(cur)
        # increment month
        year = cur.year + (cur.month // 12)
        month = cur.month % 12 + 1
        cur = pd.Timestamp(year=year, month=month, day=1)
    return months

def allocate_phase_durations(total_months, phase_minmax):
    """
    Allocate integer months to phases sequentially respecting min/max.
    phase_minmax: list of (phase_name, min_m, max_m)
    Returns dict phase_name -> months_allocated (could be 0 if not enough months)
    """
    # start with mins
    allocation = {p: m for p, (m, M) in phase_minmax.items()}
    mins_sum = sum(allocation.values())
    if total_months <= mins_sum:
        # We have to trim from the end if not enough months: give months to earliest phases
        # Start by allocating min to each until we hit total_months, otherwise reduce later phases to 0.
        allocation = {}
        remaining = total_months
        for p, (mn, mx) in phase_minmax.items():
            take = min(mn, remaining)
            allocation[p] = take
            remaining -= take
            if remaining <= 0:
                # remaining phases get 0
                for p2 in list(phase_minmax.keys()):
                    if p2 not in allocation:
                        allocation[p2] = 0
                break
        return allocation
    # distribute remaining up to capacities
    remaining = total_months - mins_sum
    capacities = {p: (phase_minmax[p][1] - phase_minmax[p][0]) for p in phase_minmax}
    # Random distribution: while remaining > 0, choose a phase with capacity >0
    phase_list = list(phase_minmax.keys())
    while remaining > 0:
        candidates = [p for p in phase_list if capacities[p] > 0]
        if not candidates:
            # no capacity left; break (remaining months will effectively be added to the largest phase later)
            break
        p = np.random.choice(candidates)
        allocation[p] += 1
        capacities[p] -= 1
        remaining -= 1
    # If still remaining (no capacities), add to Structural if exists, else to last phase
    if remaining > 0:
        if 'Structural' in allocation:
            allocation['Structural'] += remaining
        else:
            last = phase_list[-1]
            allocation[last] += remaining
    return allocation

def phase_department_weights(phase_name):
    """Return dept weight dict for a given phase. Weights sum to 1."""
    weights = {
        "Planning":     {"Labor": 0.30, "Materials": 0.20, "Equipment": 0.10, "Overheads": 0.25, "Logistics": 0.10, "Safety": 0.05},
        "Excavation":   {"Labor": 0.35, "Materials": 0.20, "Equipment": 0.25, "Overheads": 0.10, "Logistics": 0.05, "Safety": 0.05},
        "Foundation":   {"Labor": 0.30, "Materials": 0.35, "Equipment": 0.20, "Overheads": 0.05, "Logistics": 0.05, "Safety": 0.05},
        "Structural":   {"Labor": 0.35, "Materials": 0.35, "Equipment": 0.15, "Overheads": 0.05, "Logistics": 0.05, "Safety": 0.05},
        "Finishing":    {"Labor": 0.30, "Materials": 0.40, "Equipment": 0.10, "Overheads": 0.10, "Logistics": 0.05, "Safety": 0.05},
        "Handover":     {"Labor": 0.10, "Materials": 0.20, "Equipment": 0.05, "Overheads": 0.55, "Logistics": 0.05, "Safety": 0.05}
    }
    return weights[phase_name]

# -------------------------
# Phase definitions (min,max months)
# -------------------------
PHASES_MINMAX = {
    "Planning":  (1, 2),
    "Excavation":(1, 3),
    "Foundation":(1, 3),
    "Structural":(2, 6),
    "Finishing": (1, 3),
    "Handover":  (1, 1)
}
PHASE_ORDER = list(PHASES_MINMAX.keys())

# -------------------------
# Departments & cost types
# -------------------------
DEPARTMENTS = ["Labor", "Materials", "Equipment", "Overheads", "Logistics", "Safety"]
COST_TYPES = ["Fixed", "Variable", "Subcontracted"]

# -------------------------
# Master table generation parameters
# -------------------------
regions = ['Dubai', 'Abu Dhabi', 'Sharjah', 'Al Ain', 'Ras Al Khaimah']
clients = ['XYZ Builders', 'ABC Constructions', 'LMN Developments', 'PQR Infra', 'UrbanEdge', 'Nexa Build']
managers = ['Ali Khan', 'Imran Qureshi', 'Khalid Saeed', 'Omar Malik', 'Sara Ahmed',
            'Huda Farooq', 'Fatima Noor', 'Ayesha Rahman']

n_small, n_medium, n_big = 15, 20, 15  # total 50
project_rows = []

# Start window: choose reasonable starts so projects cover 2024-2026 possibilities
for i, size in enumerate(['Small'] * n_small + ['Medium'] * n_medium + ['Big'] * n_big, start=1):
    pid = f"PJ{i:03d}"
    pname = f"Project {chr(64 + i)}0"
    region = np.random.choice(regions)
    client = np.random.choice(clients)

    # Start date between 2023-01-01 and 2025-12-01 to allow variety
    start_date = pd.to_datetime(np.random.choice(pd.date_range('2023-01-01', '2025-12-01', freq='MS')))

    # realistic durations based on size
    if size == 'Small':
        duration_months = np.random.randint(6, 16)   # 6-15 months
    elif size == 'Medium':
        duration_months = np.random.randint(12, 25)  # 12-24 months
    else:
        duration_months = np.random.randint(18, 36)  # 18-35 months

    end_date = start_date + pd.DateOffset(months=duration_months - 1)  # inclusive months

    # Status assignment using Option B (reference date = 2026-01-01):
    # If End_Date <= 2025-12-31 => Completed/Delayed/On Hold
    # If End_Date >= 2026-01-01 => Active / On Hold
    if end_date <= pd.Timestamp(f"{ANALYSIS_YEAR}-12-31"):
        status = np.random.choice(['Completed', 'Delayed', 'On Hold'], p=[0.6, 0.2, 0.2])
    else:
        status = np.random.choice(['Active', 'On Hold'], p=[0.8, 0.2])

    manager = np.random.choice(managers)

    # Contract value realistic by size (AED)
    if size == 'Small':
        contract_value = int(np.random.uniform(400_000, 1_500_000))
    elif size == 'Medium':
        contract_value = int(np.random.uniform(1_500_000, 4_000_000))
    else:
        contract_value = int(np.random.uniform(4_000_000, 10_000_000))

    project_rows.append({
        "Project_ID": pid,
        "Project_Name": pname,
        "Region": region,
        "Client_Name": client,
        "Project_Status": status,
        "Start_Date": start_date.strftime("%Y-%m-%d"),
        "End_Date": end_date.strftime("%Y-%m-%d"),
        "Manager": manager,
        "Contract_Value": contract_value,
        "Project_Size": size
    })

df_master = pd.DataFrame(project_rows)
df_master.to_csv(MASTER_FILE, index=False)
print(f"Master saved -> {MASTER_FILE} (rows: {len(df_master)})")

# -------------------------
# Generate Budget & Actual for ANALYSIS_YEAR
# -------------------------
budget_rows = []
actual_rows = []

for _, proj in df_master.iterrows():
    pid = proj["Project_ID"]
    start = pd.Timestamp(proj["Start_Date"])
    end = pd.Timestamp(proj["End_Date"])
    contract_value = float(proj["Contract_Value"])
    size = proj["Project_Size"]
    status = proj["Project_Status"]

    # full project months (inclusive)
    full_months = months_between(start, end)
    total_project_months = len(full_months)
    if total_project_months == 0:
        continue

    # allocate phase durations across full project timeline
    phase_alloc = allocate_phase_durations(total_project_months, PHASES_MINMAX)

    # build phase calendar: map month -> phase
    phase_calendar = {}  # month_ts -> phase_name
    idx = 0
    for p in PHASE_ORDER:
        dur = phase_alloc.get(p, 0)
        for k in range(dur):
            if idx >= total_project_months:
                break
            m_ts = full_months[idx]
            phase_calendar[m_ts] = p
            idx += 1

    # monthly budget baseline = contract_value / total_project_months
    monthly_baseline = contract_value / max(1, total_project_months)

    # iterate months in ANALYSIS_YEAR only
    for month_ts in months_between(f"{ANALYSIS_YEAR}-01-01", f"{ANALYSIS_YEAR}-12-01"):
        # include this month only if within project timeline
        if month_ts < start.replace(day=1) or month_ts > end.replace(day=1):
            continue
        # find phase for this month (may be missing if phase allocation shorter than timeline)
        phase = phase_calendar.get(month_ts, None)
        if phase is None:
            # if no phase mapping (project has months left but phases ended) — skip
            continue

        # Distribute monthly_baseline across departments using phase weights
        weights = phase_department_weights(phase)
        # ensure weights sum to 1
        # For realism, add small noise (±5%) then normalize
        noise = {d: np.random.uniform(-0.03, 0.03) for d in DEPARTMENTS}
        raw_weights = {d: max(0.0, weights[d] + noise[d]) for d in DEPARTMENTS}
        s = sum(raw_weights.values())
        dept_weights = {d: raw_weights[d] / s for d in DEPARTMENTS}

        # For each department create budget row and actual row (cost types randomly assigned)
        for dept in DEPARTMENTS:
            cost_type = np.random.choice(COST_TYPES, p=[0.4, 0.45, 0.15])
            budget_cost = round(monthly_baseline * dept_weights[dept], 2)

            # Actual variation rules:
            #   If project status is Delayed -> variation in [-5%, +30%]
            #   Else -> uniform [-20%, +20%]
            if status == "Delayed":
                var = np.random.uniform(-0.05, 0.30)
            else:
                var = np.random.uniform(-0.20, 0.20)

            actual_cost = round(budget_cost * (1 + var), 2)
            if actual_cost < 0:
                actual_cost = 0.0

            budget_rows.append({
                "Project_ID": pid,
                "Month": month_ts.strftime("%Y-%m"),
                "Phase_Name": phase,
                "Department_Name": dept,
                "Cost_Type": cost_type,
                "Budget_Cost": budget_cost,
                "Project_Status": status
            })
            actual_rows.append({
                "Project_ID": pid,
                "Month": month_ts.strftime("%Y-%m"),
                "Phase_Name": phase,
                "Department_Name": dept,
                "Cost_Type": cost_type,
                "Actual_Cost": actual_cost,
                "Project_Status": status
            })

# convert to dataframes & save
df_budget = pd.DataFrame(budget_rows)
df_actual = pd.DataFrame(actual_rows)

df_budget.to_csv(BUDGET_FILE, index=False)
df_actual.to_csv(ACTUAL_FILE, index=False)

print(f"Budget saved -> {BUDGET_FILE} (rows: {len(df_budget)})")
print(f"Actual saved -> {ACTUAL_FILE} (rows: {len(df_actual)})")

# Quick sanity prints
print("\nSanity checks:")
print("Total master projects:", len(df_master))
print("Budget rows:", len(df_budget))
print("Actual rows:", len(df_actual))

# basic checks: no budget months outside timeline
def check_outside(df_fact, df_master):
    df = df_fact.copy()
    df['Month_dt'] = pd.to_datetime(df['Month'], format="%Y-%m")
    merged = df.merge(df_master[['Project_ID', 'Start_Date', 'End_Date']], on='Project_ID', how='left')
    merged['Start_m'] = pd.to_datetime(merged['Start_Date']).dt.to_period('M').dt.to_timestamp()
    merged['End_m'] = pd.to_datetime(merged['End_Date']).dt.to_period('M').dt.to_timestamp()
    outside = merged[(merged['Month_dt'] < merged['Start_m']) | (merged['Month_dt'] > merged['End_m'])]
    return len(outside)

outside_budget = check_outside(df_budget, df_master)
outside_actual = check_outside(df_actual, df_master)
print("Budget rows outside project timeline (should be 0):", outside_budget)
print("Actual rows outside project timeline (should be 0):", outside_actual)

# Done
