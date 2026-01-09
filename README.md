# Food-Delivery-Operations-Business-Performance-Analysis-SQL-

This project analyzes food delivery operations data to evaluate delivery performance, SLA adherence, peak-hour impact, and operational bottlenecks using SQL. The goal is to simulate how a data analyst works end-to-end—from raw data ingestion to business insights.

📦 Food Delivery Operations & Business Performance Analysis (SQL)

📌 Project Overview

This project analyzes food delivery operations data to evaluate delivery performance, SLA adherence, peak-hour impact, and operational bottlenecks using SQL. The goal is to simulate how a data analyst works end-to-end—from raw data ingestion to business insights.

📊 Business Objectives

Analyze average delivery time and SLA breaches

Identify peak-hour delivery performance issues

Understand the impact of traffic and weather on delivery time

Provide actionable insights to improve operational efficiency

🗂️ Dataset

Source: Public Kaggle food delivery dataset

Original Size: ~45,000 rows

Imported Records: ~1,400 rows

⚠️ Note on Data Limitation
During ingestion, the dataset contained malformed values (e.g., NaN in numeric fields), which caused CSV parsing issues in MySQL Workbench. A clean subset of the data was successfully ingested and used for analysis. All KPIs and insights are directionally valid and focused on analytical methodology rather than data volume.

🛠️ Tools & Technologies

MySQL

MySQL Workbench

SQL

GitHub

🔄 Project Workflow

Created a staging (raw_orders) table to store raw data

Performed data inspection and validation

Cleaned and transformed raw fields into analysis-ready columns

Defined business logic (SLA breach, peak hours)

Conducted KPI-based analysis using SQL

Interpreted results into business insights

📈 Key KPIs Analyzed

Total orders & average delivery time

SLA breach rate

City-wise delivery performance

Peak vs non-peak hour comparison

Impact of traffic and weather conditions

🔍 Key Insights

Peak hours (7–9 PM) show consistently higher delivery times and SLA breaches

High traffic density significantly increases delivery duration

Certain cities contribute disproportionately to delivery delays

✅ Conclusion

This project demonstrates a real-world SQL analytics workflow, including handling messy data, documenting limitations, and extracting actionable business insights. The focus is on analytical thinking and methodology, aligning with real data analyst responsibilities.
