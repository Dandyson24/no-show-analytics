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
Potential Intervention Areas ```

Technology Stack
Tool	Purpose
PostgreSQL	Data cleaning and SQL analytics
SQL	Transformation, segmentation and KPI development
Power BI	Interactive visualization and dashboard development
Excel/CSV	Data inspection and exchange
GitHub	Version control and portfolio documentation


Data Preparation
Key data-quality activities included:
- Checking appointment-level records
- Assessing missing values
- Reviewing duplicate appointment identifiers
- Validating appointment dates
- Calculating appointment waiting time
- Excluding records with invalid negative waiting periods
- Standardising categorical values such as Yes/No
- Creating waiting-time categories
- Creating appointment-level no-show indicators
- Developing historical patient behaviour features

The analytical grain was maintained as:
1 row = 1 appointment

This was important to prevent double counting and ensure that appointment-level KPIs remained accurate.
Key Metrics
Total Appointments
110,521
The number of valid appointments included in the analysis.
No-Shows
22,314
Appointments recorded as not attended.
No-Show Rate
20.19%
Approximately one in five scheduled appointments resulted in a no-show.
Average Lead Time
10.18 days
Average time between scheduling and the appointment.
Potential Capacity Impact
~11,157 hours
Scenario estimate based on:
22,314 no-shows × 30 minutes
--------------------------------
60
≈ 11,157 hours

This is an operational scenario rather than a measured loss of productivity.

### Key Insights
#### 1. No-shows represent a substantial operational burden
The overall no-show rate was 20.19%, meaning approximately one in five appointments was not attended.
This provides the baseline against which potential interventions can be evaluated.

#### 2. Longer appointment lead times are associated with higher no-show rates
The dashboard shows a clear increase in observed no-show rates across longer waiting-time categories.
The highest waiting-time groups had substantially higher observed non-attendance than same-day appointments.
Business implication
Long appointment lead times may represent an important operational opportunity for:
- Appointment confirmation
- Reminder timing
- Rescheduling
- Waiting-list management
- Targeted patient engagement
#### 3. Previous non-attendance identifies a higher-risk segment
Patients with previous no-show history demonstrated higher subsequent observed no-show rates.
The strongest combination was:
Previous No-show + Long Wait
with an observed no-show rate of approximately:
48.7%
compared with approximately:
14.6%
among patients with no previous no-show and shorter waiting periods.
Business implication
Appointment management could potentially move from a blanket approach toward risk-based segmentation.
#### 4. SMS results require contextual interpretation
The overall SMS comparison initially appears counterintuitive because the SMS group has a higher crude no-show rate.
However, when waiting time is examined simultaneously, the relationship changes across waiting-time categories.
This demonstrates an important analytics principle:
A crude association can be misleading when another operational variable influences both groups.

The analysis therefore does not claim that SMS causes or prevents no-shows.
Further investigation would be required, ideally using more detailed intervention data or an experimental design.
#### 5. Age patterns show meaningful differences
Younger age groups displayed higher observed no-show rates than older groups in this dataset.
Business implication
This may justify further investigation into:
- Communication preferences
- Appointment accessibility
- Work/school schedules
- Reminder timing
- Patient engagement strategies
The results should be treated as associations rather than explanations of behaviour.
#### 6. Day of appointment matters
Saturday had the highest observed no-show rate in the analysis.
The pattern across appointment days suggests that scheduling behaviour may contribute to operational variation.
Business implication
Healthcare managers could examine:
- Clinic scheduling patterns
- Weekend appointments
- Staffing
- Appointment timing
- Patient demand by day
#### 7. Rate and volume are not the same thing
A group with the highest no-show rate is not necessarily the group generating the greatest number of missed appointments.
This distinction is important for resource allocation.
Healthcare managers should consider both:
Risk Rate
+
Absolute No-show Volume

before prioritising an intervention.

#### 8. Geographic variation exists
Neighbourhood-level analysis identified substantial differences in observed no-show rates.
However, small-volume areas can produce unstable percentages.


- Appointment volume
- No-show count
- No-show rate
rather than ranking areas by percentage alone.

#### Advanced Analytics
Behavioural History
Patient appointment history was analysed using SQL window functions.
The historical calculation excluded the current appointment outcome to prevent target leakage.
Conceptually:
``` ROWS BETWEEN UNBOUNDED PRECEDING
AND 1 PRECEDING ```

#### Operational Risk Segmentation
The project also explored an operational risk framework using:
- Previous no-show behaviour
- Appointment waiting time

#### Segment	Interpretation
Previous No-show + Long Wait	--> Priority investigation
Previous No-show + Short Wait	--> Elevated behavioural risk
No Previous No-show + Long Wait -->	Operational risk
No Previous No-show + Short Wait	--> Lower observed risk

#### Power BI  Dashboard
The dashboard was designed for healthcare managers and business stakeholders rather than purely technical users.
Executive KPIs
- Total appointments
- Total no-shows
- No-show rate
- Average appointment lead time
- Potential capacity affected
#### Visual Analytics
- No-show rate by lead time
- No-show rate by previous attendance history
- SMS status by waiting time
- No-show rate by age group
- No-show rate by appointment day
- Neighbourhood variation
- Gender comparison
- Risk-tier analysis

#### Business Recommendations
Based on the observed patterns, healthcare organisations could investigate:
1. Targeted appointment management
Prioritise patients with previous non-attendance and long appointment lead times for additional confirmation or engagement.
2. Review long waiting periods
Investigate why longer appointment lead times are associated with higher observed no-show rates.
3. Optimise reminder strategies
Evaluate SMS effectiveness within comparable waiting-time groups rather than relying on crude overall comparisons.
4. Review high-volume problem areas
Prioritise neighbourhoods or service areas based on both no-show rate and absolute no-show volume.
5. Review appointment-day patterns
Investigate whether staffing, clinic schedules, or patient availability contribute to day-specific variation.
Important Analytical Limitations
This analysis is observational.
Therefore:
- Associations should not be interpreted as causation.
- SMS receipt does not prove that SMS caused a change in attendance.
- Capacity impact is scenario-based.
- Small geographic groups may have unstable rates.
- Risk tiers are analytical classifications, not validated clinical prediction models.
- Additional operational variables would be required for a predictive model.
Potential Next Steps
Future development could include:
- Predictive modelling of no-show probability
- Appointment-level risk scoring
- Survival/time-to-event analysis
- Cost-of-no-show modelling
- Intervention effectiveness analysis
- A/B testing of reminder strategies
- Patient segmentation
- Automated appointment-risk alerts
- Integration with hospital scheduling systems
Skills Demonstrated
SQL
- CTEs
- Window functions
- Conditional aggregation
- CASE statements
- FILTER
- Data-quality checks
- Feature engineering
- Patient-history calculations
- Operational KPI development
Power BI dashboard
- DAX
- KPI cards
- Heatmaps
- Bar charts
- Trend analysis
- Interactive filters
- Dashboard design
- Business storytelling
Healthcare Analytics
- Appointment utilisation
- Patient behaviour
- Operational risk segmentation
- Capacity analysis
- Healthcare KPI development
- Decision-support analytics

Author
Andrew Okebugwu
Healthcare & Public Health Professional | Healthcare Data Analyst | Business Intelligence
Skills: SQL | PostgreSQL | Tableau | Power BI | Python | Healthcare Analytics | Public Health Data
#HealthcareAnalytics #HealthInformatics #BusinessIntelligence #DataAnalytics #SQL #Tableau #HealthcareData
