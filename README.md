Real Estate Cost Variance BI System

An end-to-end Business Intelligence system designed to analyze, monitor, and explain cost variance across real estate projects.

This project simulates a real-world finance + analytics workflow — from synthetic data generation to SQL-based modeling and executive-level dashboards.

> Note: All data used in this project is synthetically generated using Python to replicate realistic real estate cost, timeline, and variance scenarios. No real company data is used.




---

Problem Statement

Real estate organizations often struggle to:

Monitor budget vs actual cost deviations at scale

Distinguish controllable vs uncontrollable cost overruns

Enforce cost governance policies consistently

Translate variance numbers into actionable decisions


This system was built to address those gaps through a structured, analytics-first approach.


---

System Architecture

Python → SQL Server → Power BI → Executive Decision Support

1. Python

Generated realistic project, cost, and time data

Embedded business rules for delays, overruns, and policy breaches

Split data into clean dimension and fact structures



2. SQL Server

Star schema with enforced grain
(Project × Month × Phase × Department × Cost Type)

Variance calculated once in SQL (single source of truth)

Referential integrity, validation checks, and indexing

BI-facing analytical views created for reporting



3. Power BI

Executive cost variance overview

Project-level deep-dive analysis

Variance governance and intervention layer



4. Analytics Framework

Descriptive: What happened?

Diagnostic: Why did it happen?

Prescriptive: What action should be taken?





---

Data Model Overview

Dimensions

Dim_Project

Dim_Time

Dim_Region

Dim_Client

Dim_Manager

Dim_Phase

Dim_Department (with controllable vs uncontrollable flag)

Dim_CostType


Facts

Fact_Budget

Fact_Actual

Fact_Variance (derived in SQL)


All joins are key-based (no string joins), and grain is strictly enforced to avoid aggregation errors.


---

Key Business Insights

13 projects showed unfavorable cost variance

Only 2 projects breached company policy thresholds

67% of unfavorable variance was controllable, indicating opportunity for intervention

Small projects showed disproportionately higher overruns

Q3 was the highest-risk period, driven mainly by Labor and Logistics costs



---

Tools & Technologies Used

Python – Data generation, validation, and preprocessing

SQL Server (T-SQL) – Data modeling, variance logic, views, and performance tuning

Power BI – Interactive dashboards and executive reporting


ChatGPT – Used as a reasoning assistant for logic validation and analytical framing
(final design, modeling, and decisions were user-driven)



---

Repository Structure

├── python/
│   └── data generation, validation, and splitter scripts
├── sql/
│   └── schema, views, variance logic, indexing
├── power-bi/
│   └── Power BI report (.pbix)
├── deck/
│   └── Executive presentation (Gamma / PDF)


---

Presentation Deck

📊 Executive Analytics Deck:



---

Outcome

This project demonstrates:

Business-first analytics thinking

End-to-end BI system design

Strong SQL and data modeling fundamentals

Ability to translate variance into governance and decision support


It reflects how cost variance analysis is built, validated, and explained in real organizations — not just visualized.


---

Author

Rasvi
Aspiring Data Analyst | Business Intelligence
Focus: Finance Analytics, Cost Control, Data Modeling
