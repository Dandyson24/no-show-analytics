/** NO SHOW ANALYSIS **/

--a) Examining the data
SELECT * 
FROM no_shows ns
LIMIT 10;

--b) -- Data cleaning
 -- Correcting column headers

ALTER TABLE "Appt".no_shows RENAME COLUMN handcap TO disability_count;
ALTER TABLE "Appt".no_shows RENAME COLUMN "No-show"  TO no_show;

-- Data Quality assessment
--a) Age column contains an invalid value (age <0)

CASE 
	WHEN age < 0 THEN NULL
	ELSE age
END AS age_clean;
END

SELECT
	MIN(age),
    MAX(age)
FROM no_shows ns ;
-- Minimum age is -1 and maximum age is 115. There is need to delete negative age

DELETE FROM no_shows
WHERE age = -1;

-- Adding analytic variables

CREATE TABLE 
	appointment_analysis AS
SELECT
	*,
	appointmentday - scheduledday 
		AS waiting_days,
	EXTRACT(
		DOW FROM appointmentday
	) AS appointment_dow,
TO_CHAR(
	appointmentday,
	'Day'
) AS appointment_day,
EXTRACT(
	MONTH FROM appointmentday
) AS appointment_month,
CASE
	WHEN age IS NULL THEN 'Unknown'
	WHEN age <=12 THEN 'Child'
	WHEN age BETWEEN 13 AND 17 THEN 'Adolescent'
	WHEN age BETWEEN 18 AND 34 THEN 'Young Adult'
	WHEN age BETWEEN 35 AND 54 THEN 'Middle Adult'
	WHEN age BETWEEN 55 AND 64 THEN 'Older Adult'
	ELSE '65+'	
END AS age_group,
CASE 
	WHEN appointmentday - scheduledday :: DATE <0 THEN 'Invalid'
	WHEN appointmentday - scheduledday :: DATE  =0 THEN 'Same Day'
	WHEN appointmentday - scheduledday :: DATE BETWEEN 1 AND 3 THEN '1-3 Days'
	WHEN appointmentday - scheduledday :: DATE BETWEEN 4 AND 7 THEN '4-7 Days'
	WHEN appointmentday - scheduledday :: DATE BETWEEN 8 AND 14 THEN '8-14 Days'
	WHEN appointmentday - scheduledday :: DATE BETWEEN 15 AND 30 THEN '15-30 Days'
	WHEN appointmentday - scheduledday :: DATE BETWEEN 31 AND 60 THEN '31-60 Days'
	ELSE '61+ Days'
END AS waiting_band
FROM no_shows;

SELECT *
FROM appointment_analysis aa;

--Examining for missing values
SELECT
	COUNT(*) AS total_records,
	COUNT(*) FILTER (WHERE patientid IS NULL) AS missing_patient_id,
	COUNT(*) FILTER (WHERE appointmentid IS NULL) AS missing_appointment_id,
	COUNT(*) FILTER (WHERE age IS NULL) AS missing_age
FROM appointment_analysis;
--There are 110,526 total records while there were no null values in the columns. hence this dataset is sufficient for operational decision making.
 --Examining for duplicate appointments

SELECT 
	appointmentid,
	COUNT(*) AS record_count
FROM appointment_analysis
GROUP BY appointmentid
HAVING COUNT(*) >1;

--there is no duplicate appointment since the data set has unique appointment IDs
--- Examining for invalid waiting/lead times

SELECT 	
	COUNT(*) AS invalid_waiting_records
FROM appointment_analysis
WHERE waiting_days <0; /** There are 5 records with waiting days <0 and requires investigation.**/

SELECT 	
	patientid,
	appointmentid,
	scheduledday,
	appointmentday,
	waiting_days
FROM appointment_analysis
WHERE waiting_days <0
ORDER BY waiting_days;

-- To check table
SELECT
	MIN(waiting_days),
    MAX(waiting_days)
FROM appointment_analysis;
-- Shows a minimum of  minus 6 days and a maximum of 179 days. This needs to be examined

-- Delete the records with waiting_days less than 0
DELETE FROM appointment_analysis
WHERE waiting_days < 0;


--- ANALYSIS PROPER

--1) OVERALL NO SHOW BURDEN

SELECT
    COUNT(*) AS total_appointments,
	SUM(
        CASE
            WHEN TRIM(no_show) = 'Yes' THEN 1
            ELSE 0
        END
    ) AS total_no_shows,
	ROUND(
        100.0 * SUM(
            CASE
                WHEN TRIM(no_show) = 'Yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS no_show_rate
FROM appointment_analysis
WHERE waiting_days >= 0;

--Total no shows =22314 which is 20.19% no_show_rate.
--Business implication: Roughly 1 IN EVERY 5 schecduled appointments IS lost ton attendance


-- Insight #2
SELECT 
	waiting_band,
	COUNT(*) AS total_appointments,
	SUM(
        CASE
            WHEN TRIM(no_show) = 'Yes' THEN 1
            ELSE 0
        END
    ) AS total_no_shows,
	ROUND(
        100.0 * SUM(
            CASE
                WHEN TRIM(no_show) = 'Yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS no_show_rate
FROM appointment_analysis
WHERE waiting_days >= 0
GROUP BY waiting_band 
ORDER BY 
	MIN(waiting_days);
--Longer appointment lead times create a progressivly larger operational risk window.

--Insight #3	
SELECT
    COUNT(*) AS long_wait_appointments,
    ROUND(
        100.0 * COUNT(*) /
        (
            SELECT COUNT(*)
            FROM appointment_analysis
            WHERE waiting_days >= 0
        ),
        2
    ) AS share_of_appointments,
    COUNT(*) FILTER (
        WHERE TRIM(no_show) = 'Yes'
    ) AS total_no_shows,
 	ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE TRIM(no_show) = 'Yes'
        ) /
        (
            SELECT COUNT(*)
            FROM appointment_analysis
            WHERE waiting_days >= 0
              AND TRIM(no_show) = 'Yes'
        ),
        2
    ) AS share_of_all_no_shows
FROM appointment_analysis
WHERE waiting_days > 7;
--36% of appointments have >7 days waiting time and also contribute approx 57% of missed appointments. 
-- A relatively sma;; operational segment of appointments generate a disproportionate share of the misse appointments.

-- Insight #4 - Age

SELECT
    age_group,
    COUNT(*) AS appointments,
    COUNT(*) FILTER (WHERE TRIM(no_show) = 'Yes') AS total_no_shows,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE TRIM(no_show) = 'Yes')
        / COUNT(*),
        2
    ) AS no_show_rate
FROM appointment_analysis
WHERE waiting_days >= 0
GROUP BY age_group
ORDER BY no_show_rate DESC;
--Adolescents had the highest appointments and also the highest show rate. They will benefit more from a tailored reminder strategy.

--- Insight #5 Gender differentiation
SELECT
    gender,
    COUNT(*) AS appointments,
    COUNT(*) FILTER (WHERE TRIM(no_show) = 'Yes') AS total_no_shows,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE TRIM(no_show) = 'Yes') / COUNT(*),
        2
    ) AS no_show_rate
FROM appointment_analysis
WHERE waiting_days >= 0
GROUP BY gender
ORDER BY no_show_rate DESC;
--Gender is not a major differentiator as it did not providr much discriminatory value in the dataset


-- Insight #6 SMS

SELECT
    sms_received,
    COUNT(*) AS appointments,
     COUNT(*) FILTER (WHERE TRIM(no_show) = 'Yes') AS total_no_shows,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE TRIM(no_show) = 'Yes') / COUNT(*),
        2
    ) AS no_show_rate
FROM appointment_analysis
GROUP BY sms_received;
-- It appears that SMS did not have any effect or even worsened the no_show rate and this requires further drill down.

SELECT
    waiting_band,
    COUNT(*) FILTER (WHERE sms_received = 0) AS no_sms_appointments,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE sms_received = 0
            AND TRIM(no_show) = 'Yes'
        )
        / NULLIF(COUNT(*) FILTER (WHERE sms_received = 0), 0),
        2
    ) AS no_sms_no_show_rate,
    COUNT(*) FILTER (WHERE sms_received = 1) AS sms_appointments,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE sms_received = 1
            AND TRIM(no_show) = 'Yes'
        )
        / NULLIF(COUNT(*) FILTER (WHERE sms_received = 1), 0),
        2
    ) AS sms_no_show_rate
FROM appointment_analysis
WHERE waiting_days >= 0
GROUP BY waiting_band
ORDER BY MIN(waiting_days);

--This is the SMS paradox and has demystified the initially observed no-show rate among sms recipients. This was confounded by the lead_time hence an aparent adverse association.

--Insight #7 --Socioeconomic factors (Scholarship)

SELECT
    scholarship,
    COUNT(*) AS appointments,
    COUNT(*) FILTER (WHERE scholarship = 0) AS no_scholarships,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE TRIM(no_show) = 'Yes') / COUNT(*),
        2
    ) AS no_show_rate
FROM appointment_analysis
GROUP BY scholarship;
--There is an associtaion between this factor and higher observed non-attendance which will further require further investigation on trancportation, ownership of phones, competing priorities etc.

--Insight # 8 Clinical conditions
SELECT
    'Hypertension' AS factor,
    hypertension AS factor_value,
    COUNT(*) AS appointments,
    COUNT(*) FILTER (
        WHERE TRIM(no_show) = 'Yes'
    ) AS total_no_shows,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE TRIM(no_show) = 'Yes'
        ) / COUNT(*),
        2
    ) AS no_show_rate
FROM appointment_analysis
WHERE waiting_days >= 0
GROUP BY hypertension
UNION ALL
SELECT
    'Diabetes',
    diabetes,
    COUNT(*),
    COUNT(*) FILTER (
        WHERE TRIM(no_show) = 'Yes'
    ),
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE TRIM(no_show) = 'Yes'
        ) / COUNT(*),
        2
    )
FROM appointment_analysis
WHERE waiting_days >= 0
GROUP BY diabetes
UNION ALL
SELECT
    'Alcoholism',
    alcoholism,
    COUNT(*),
    COUNT(*) FILTER (
        WHERE TRIM(no_show) = 'Yes'
    ),
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE TRIM(no_show) = 'Yes'
        ) / COUNT(*),
        2
    )
FROM appointment_analysis
WHERE waiting_days >= 0
GROUP BY alcoholism
UNION ALL
SELECT
    'disability_count',
    disability_count,
    COUNT(*),
    COUNT(*) FILTER (
        WHERE TRIM(no_show) = 'Yes'
    ),
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE TRIM(no_show) = 'Yes'
        ) / COUNT(*),
        2
    )
FROM appointment_analysis
WHERE waiting_days >= 0
GROUP BY disability_count
ORDER BY factor, factor_value;

SELECT
    'Hypertension' AS factor,
    COUNT(*) FILTER (WHERE hypertension = 0) AS no_clinical_case,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE hypertension = 0
            AND TRIM(no_show) = 'Yes'
        )
        / NULLIF(COUNT(*) FILTER (WHERE hypertension = 0), 0),
        2
    ) AS no_clinical_case_no_show_rate,
    COUNT(*) FILTER (WHERE hypertension = 1) AS clinical_case,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE hypertension = 1
            AND TRIM(no_show) = 'Yes'
        )
        / NULLIF(COUNT(*) FILTER (WHERE hypertension = 1), 0),
        2
    ) AS clinical_case_no_show_rate
FROM appointment_analysis
WHERE waiting_days >= 0
UNION ALL
SELECT
    'Diabetes',
    COUNT(*) FILTER (WHERE diabetes = 0),
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE diabetes = 0
            AND TRIM(no_show) = 'Yes'
        )
        / NULLIF(COUNT(*) FILTER (WHERE diabetes = 0), 0),
        2
    ),
    COUNT(*) FILTER (WHERE diabetes = 1),
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE diabetes = 1
            AND TRIM(no_show) = 'Yes'
        )
        / NULLIF(COUNT(*) FILTER (WHERE diabetes = 1), 0),
        2
    )
FROM appointment_analysis
WHERE waiting_days >= 0
UNION ALL
SELECT
    'Alcoholism',
    COUNT(*) FILTER (WHERE alcoholism = 0),
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE alcoholism = 0
            AND TRIM(no_show) = 'Yes'
        )
        / NULLIF(COUNT(*) FILTER (WHERE alcoholism = 0), 0),
        2
    ),
    COUNT(*) FILTER (WHERE alcoholism = 1),
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE alcoholism = 1
            AND TRIM(no_show) = 'Yes'
        )
        / NULLIF(COUNT(*) FILTER (WHERE alcoholism = 1), 0),
        2
    )
FROM appointment_analysis
WHERE waiting_days >= 0
UNION ALL
SELECT
    'Disability',
    COUNT(*) FILTER (WHERE disability_count = 0),
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE disability_count = 0
            AND TRIM(no_show) = 'Yes'
        )
        / NULLIF(COUNT(*) FILTER (WHERE disability_count = 0), 0),
        2
    ),
    COUNT(*) FILTER (WHERE disability_count > 0),
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE disability_count > 0
            AND TRIM(no_show) = 'Yes'
        )
        / NULLIF(COUNT(*) FILTER (WHERE disability_count > 0), 0),
        2
    )
FROM appointment_analysis
WHERE waiting_days >= 0;

--Clinical cases are weak predictors of no show


--Insight #9 Geography
SELECT
    neighbourhood,
    COUNT(*) AS appointments,
    COUNT(*) FILTER (WHERE TRIM(no_show) = 'Yes') AS total_no_shows,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE TRIM(no_show) = 'Yes') / COUNT(*),
        2
    ) AS no_show_rate
FROM appointment_analysis
GROUP BY neighbourhood
HAVING COUNT(*) >= 500
ORDER BY no_show_rate DESC;

--Using having >=500 was to avoid labelling a neighbourhood as high risk for no show with few appointments. The Santos Dumont neighbourhood had a no show rate of 28.92%.

-- Insight #10 Appointment day and volume
SELECT
    appointment_day,
    COUNT(*) AS appointments,
    COUNT(*) FILTER (WHERE TRIM(no_show) = 'Yes') AS total_no_shows,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE TRIM(no_show) = 'Yes') / COUNT(*),
        2
    ) AS no_show_rate
FROM appointment_analysis
WHERE waiting_days >= 0
GROUP BY appointment_day
ORDER BY no_show_rate DESC;
--While Friday appears to have the highest no show rate. Thursday accounted for the highest in absolute terms of missed appointments.
-- It is therefore important to consider both no show rate and volume of appointment.

-- insight #11-- Previous patient behaviour;
    
    WITH patient_history AS (
    SELECT
        patientid,
        appointmentid,
        appointmentday,
        no_show,
        COUNT(*) OVER (
            PARTITION BY patientid
            ORDER BY appointmentday, appointmentid
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prior_appointments,
        COALESCE(
            SUM(
                CASE
                    WHEN TRIM(no_show) = 'Yes' THEN 1
                    ELSE 0
                END
            ) OVER (
                PARTITION BY patientid
                ORDER BY appointmentday, appointmentid
                ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS prior_no_shows
    FROM appointment_analysis
    WHERE waiting_days >= 0
),
classified AS (
    SELECT
        *,  
        CASE
            WHEN prior_appointments = 0
                THEN 'New/No History'
            WHEN prior_no_shows = 0
                THEN 'No Previous No-show'
            WHEN prior_no_shows::NUMERIC / NULLIF(prior_appointments, 0) < 0.50
                THEN 'Moderate Historical Risk'
            ELSE 'High Historical Risk'
        END AS patient_risk_group
    FROM patient_history
),
final_results AS (
    SELECT
        patient_risk_group,
        COUNT(*) AS appointments,
        SUM(prior_no_shows) AS previous_no_shows,
        ROUND(
            100.0 * SUM(prior_no_shows)
            / NULLIF(SUM(prior_appointments), 0),
            2
        ) AS historical_no_show_rate,
        COUNT(*) FILTER (
            WHERE TRIM(no_show) = 'Yes'
        ) AS current_no_shows,
        ROUND(
            100.0 * COUNT(*) FILTER (
                WHERE TRIM(no_show) = 'Yes'
            ) / COUNT(*),
            2
        ) AS current_no_show_rate
    FROM classified
    GROUP BY patient_risk_group
)
SELECT *
FROM final_results
ORDER BY
    CASE patient_risk_group
        WHEN 'New/No History' THEN 1
        WHEN 'No Previous No-show' THEN 2
        WHEN 'Moderate Historical Risk' THEN 3
        WHEN 'High Historical Risk' THEN 4
        ELSE 5
    END;
    -- Patients (32%) with past history of no show were seen to also be at a higher risk of missing appointments. This cohort of clients need to be targeted for reminders etc.
    --I constructed historical patient behaviour using SQL window functions while excluding the current appointment outcome to prevent target leakage.”
 
    -- Insight 12-- Examining intersection of risk factors when compared with individual factors.
    WITH history AS (
    SELECT
        *,  
        COUNT(*) OVER (
            PARTITION BY patientid
            ORDER BY appointmentday, appointmentid
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prior_appointments,
        COALESCE(
            SUM(
                CASE
                    WHEN TRIM(no_show) = 'Yes' THEN 1
                    ELSE 0
                END
            ) OVER (
                PARTITION BY patientid
                ORDER BY appointmentday, appointmentid
                ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS prior_no_shows
    FROM appointment_analysis
    WHERE waiting_days >= 0
)
SELECT
    CASE
        WHEN prior_no_shows > 0
            THEN 'Previous No-show'
        ELSE 'No Previous No-show'
    END AS behavioural_history,
    CASE
        WHEN waiting_days >= 15
            THEN 'Long Wait'
        ELSE 'Short Wait'
    END AS waiting_category,
    COUNT(*) AS appointments,
    COUNT(*) FILTER (
        WHERE TRIM(no_show) = 'Yes'
    ) AS total_no_shows,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE TRIM(no_show) = 'Yes'
        ) / COUNT(*),
        2
    ) AS no_show_rate
FROM history
WHERE prior_appointments > 0
GROUP BY
    behavioural_history,
    waiting_category
ORDER BY
    no_show_rate DESC;

/** Patients with a previous history of non-attendance and a long waiting time had the highest observed no-show rate at 48.7%, compared with 14.2% among patients with no previous no-show and a short waiting time. This suggests that previous attendance behaviour and appointment lead time jointly identify higher-risk groups, supporting targeted appointment-management interventions**/


--If a scenario of 20 minutes per clinical appointment is created, then 7,438 hours were lost. This is a scenario since time spent on appointment was not given.
/** Lost capacity is a scenario estimate based on an assumed average appointment duration of 20 minutes; actual capacity loss should be recalculated using facility-specific appointment duration.**/


