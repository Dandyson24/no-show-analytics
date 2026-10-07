# No-show-analytics
Missed appointments create significant healthcare costs through lost revenue and wasted provider capacity. Analysis identified patient and operational patterns linked to no-shows using day, neighbourhood, gender and lead time, supporting targeted reminders and better scheduling to reduce avoidable capacity loss

# Clinic Appointment No-Show Analytics

## From Appointment Data to Operational Decision Support

A healthcare analytics project using **PostgreSQL/ and Power Bi** to investigate appointment non-attendance, identify behavioural and operational patterns, and translate missed appointments into potential clinical-capacity implications.

The project moves beyond simply reporting a no-show rate to answer four business questions:

1. How large is the no-show problem?
2. Where is non-attendance concentrated?
3. Which patient and operational characteristics are associated with higher observed no-show rates?
4. Where could healthcare managers investigate targeted interventions?


# Executive Summary

The analysis covered:

- **110,521 appointments**
- **22,314 no-shows**
- **20.19% overall no-show rate**
- **10.18 days average appointment lead time**
- Approximately **11,157 scheduled capacity hours potentially affected**, assuming an average appointment duration of 30 minutes.
> The capacity estimate is a scenario calculation based on an assumed 30-minute appointment duration and should not be interpreted as measured clinical productivity loss.
>
- - In addition, interventions that can return 10% of the no show population will translate to over 2,000 patients and this can be used to measure return on investments for those interventions.


---

# Business Problem

Appointment non-attendance creates operational challenges for healthcare organisations.

When a patient does not attend a scheduled appointment, the organisation may experience:

- Unused clinical capacity
- Disrupted clinic schedules
- Increased waiting lists
- Inefficient staff utilisation
- Additional rescheduling workload
- Potential delays in patient care

The objective of this project was therefore not simply to calculate:

> "What percentage of appointments were missed?"

Instead, the analysis focused on:

> **"What patterns can help healthcare managers understand and potentially reduce appointment non-attendance?"**

---

# Data Analytics Lifecycle

The project followed an end-to-end analytics workflow:

```text
Raw Appointment Data
        ↓
Data Quality Assessment
        ↓
Data Cleaning
        ↓
Feature Engineering
        ↓
Behavioural Analysis
        ↓
SQL Business Analysis
        ↓
Tableau Visualization
        ↓
Operational Insights
        ↓
Potential Intervention Areas


Author
Andrew Okebugwu
Healthcare & Public Health Professional | Healthcare Data Analyst | Business Intelligence
Skills: SQL | PostgreSQL | Tableau | Power BI | Python | Healthcare Analytics | Public Health Data
#HealthcareAnalytics #HealthInformatics #BusinessIntelligence #DataAnalytics #SQL #Tableau #HealthcareData
