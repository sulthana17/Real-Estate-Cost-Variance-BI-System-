# Real Estate Cost Variance BI System

![Python](https://img.shields.io/badge/Python-Data%20Generation-gold)
![SQL](https://img.shields.io/badge/SQL-Analytics-gold)
![Power%20BI](https://img.shields.io/badge/Power%20BI-Dashboard-gold)
![Status](https://img.shields.io/badge/Status-Completed-success)

An end-to-end **Business Intelligence system** built to analyze, monitor, and explain **cost variance across real estate projects**, using a realistic finance and governance lens.

---

## Project Presentation

A full analytics deck explaining **system design, methodology, and insights** is available here:

**📊 Analytics Deck:**  
[Real Estate Cost Variance – Analytics System](Deck/Real-Estate-Cost-Variance-Analytics-System.pdf)

> This deck is intended to complement the dashboard by explaining *what was built, how it was built, and what the insights mean for decision-making*.

---

## Overview

This project simulates a **real-world enterprise analytics workflow**:

- Synthetic data generation using Python  
- Star-schema modeling and analytics in SQL  
- Executive dashboards in Power BI  
- Insight storytelling through an analytics deck  

The focus is not just reporting, but **decision support and cost governance**.

---

## Data Disclaimer

> All data used in this project is **synthetically generated using Python** to replicate realistic business scenarios.  
> No real company, client, or confidential data is used.

---

## Problem Statement

Real estate organizations often struggle to:

- Track **budget vs actual** cost deviations at scale  
- Identify **controllable vs uncontrollable** overruns  
- Apply **cost governance policies** consistently  
- Convert variance numbers into **clear management actions**

This system was designed to close those gaps using an **analytics-first approach**.

---

## System Architecture

**Python → SQL Server → Power BI → Decision Support**

| Layer | Description |
|-----|-------------|
| Python | Synthetic data generation & business rule simulation |
| SQL Server | Data modeling, variance logic, validation, indexing |
| Power BI | Executive dashboards & analytical views |
| Presentation | Insight communication & storytelling |

---

## Data Generation (Python)

- Generated realistic datasets for:
  - Projects, phases, departments, regions, managers
  - Budgeted and actual costs
- Simulated:
  - Cost overruns and savings
  - Project delays
  - Policy breach scenarios
  - Controllable vs uncontrollable cost behavior
- Ensured repeatability and scalability of the dataset

---

## Data Modeling & Analytics (SQL)

- Designed a **star schema** with fact and dimension tables
- Implemented:
  - Cost variance calculations
  - Policy breach logic
  - Sanity and integrity checks
  - Indexing for performance
- Created SQL views optimized for BI consumption

---

## Business Intelligence (Power BI)

The dashboard is structured into three analytical layers:

### 1. Executive Cost Variance Overview
- Portfolio-level cost health
- Net variance and variance %
- Regional and departmental risk visibility

### 2. Project Deep Dive
- Phase-wise and department-wise variance drivers
- Project size and timeline impact analysis
- Identification of controllable cost issues

### 3. Variance Control & Intervention
- Policy breach detection
- Controllable vs uncontrollable split
- Action prioritization for management

---

## Analytics Approach

| Type | Question Answered |
|----|------------------|
| Descriptive | What happened? |
| Diagnostic | Why did it happen? |
| Prescriptive | What should be done next? |

---

## Key Findings

- 13 projects recorded unfavorable variance  
- Only 2 projects breached company cost policy thresholds  
- ~67% of unfavorable variance was **controllable**  
- Smaller projects showed higher relative cost risk  
- Q3 emerged as the highest risk period, driven by labor and logistics  
- Persistent favorable variance in some departments suggests estimation or quality risks  

---


## Repository Structure

```text
├── python/        # Data generation scripts
├── sql/           # Schema, views, validation, variance logic
├── power-bi/      # Power BI report (.pbix)
├── deck/          # Analytics presentation (PDF)
├── docs/          # ER diagrams 
└── README.md

---

## .Project Outcome

- This repository demonstrates:
- End-to-end BI system design
- Strong understanding of cost variance and governance
- Ability to move from data → analysis → decision support
- Practical application of finance-focused analytics
