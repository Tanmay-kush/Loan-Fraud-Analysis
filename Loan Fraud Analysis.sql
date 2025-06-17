CREATE DATABASE Loan_fraud;

CREATE TABLE loan_applications (
   application_id VARCHAR(50) PRIMARY KEY,
   customer_id VARCHAR(50),
    application_date DATE,
    loan_type VARCHAR(100),
    loan_amount_requested NUMERIC(12,2),
    loan_tenure_months INT,
    interest_rate_offered FLOAT,
    purpose_of_loan TEXT,
    employment_status VARCHAR(100),
    monthly_income NUMERIC(12,2),
    cibil_score INT,
    existing_emis_monthly NUMERIC(12,2),
    debt_to_income_ratio FLOAT,
    property_ownership_status VARCHAR(100),
    applicant_age INT,
    gender VARCHAR(20),
    number_of_dependents INT,
    loan_status VARCHAR(50),
    fraud_flag BOOLEAN,
    fraud_type VARCHAR(100)
);

SELECT*FROM loan_applications

SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'C:/Users/manor/OneDrive/Desktop/JIM/BA/my personal projects data/loan appliaction and transaction fraud/loan_applications.csv'
INTO TABLE loan_applications
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE TABLE loan_applications;


LOAD DATA LOCAL INFILE 'C:/Users/manor/OneDrive/Desktop/JIM/BA/my personal projects data/loan appliaction and transaction fraud/loan_applications.csv'
INTO TABLE loan_applications
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * 
FROM loan_applications
ORDER BY application_date ASC;

-- --> KEY FRAUD METRICS <--
-- /*1.Overall Fraud Rate*/
SELECT 
    ROUND(SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_percentage               -- Fraud Rate (%)= (Fraud cases/total applications)*100 
FROM loan_applications;


-- Fraud Rate by Gender
SELECT 
    gender,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_cases,
    ROUND(SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM loan_applications
GROUP BY gender
ORDER BY fraud_rate_percentage DESC;

-- Fraud by Age Bucket
SELECT 
    CASE 
        WHEN applicant_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN applicant_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN applicant_age BETWEEN 36 AND 45 THEN '36-45'
        WHEN applicant_age BETWEEN 46 AND 60 THEN '46-60'
        WHEN applicant_age > 60 THEN '60+'
        ELSE 'Unknown'
    END AS age_bucket,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_cases,
    ROUND(SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM loan_applications
GROUP BY age_bucket
ORDER BY age_bucket;

-- Fraud Rate by Number of Dependents
SELECT 
    number_of_dependents,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_cases,
    ROUND(SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM loan_applications
GROUP BY number_of_dependents
ORDER BY number_of_dependents;


-- /*2. Fraud Rate by Loan Status*/
SELECT 
    loan_status,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_count,
    ROUND(SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM loan_applications
GROUP BY loan_status
ORDER BY fraud_rate_percentage DESC;


-- /*3. Monthly Fraud Trend*/
SELECT 
    DATE_FORMAT(application_date, '%Y-%m') AS month,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_cases,
    ROUND(SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM loan_applications
GROUP BY DATE_FORMAT(application_date, '%Y-%m')
ORDER BY month;

-- /*4.Income-Based Fraud Analysis*/
SELECT 
    CASE 
        WHEN monthly_income < 30000 THEN '<30K'
        WHEN monthly_income BETWEEN 30000 AND 59999 THEN '30K-60K'
        WHEN monthly_income BETWEEN 60000 AND 89999 THEN '60K-90K'
        WHEN monthly_income >= 90000 THEN '90K+'
        ELSE 'Unknown'
    END AS income_band,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_cases,
    ROUND(SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*), 2) AS fraud_rate_percentage
FROM loan_applications
GROUP BY income_band
ORDER BY income_band;

-- /*5.CIBIL Score Bucket Fraud Analysis*/
SELECT 
    CASE 
        WHEN cibil_score < 600 THEN 'Poor (<600)'
        WHEN cibil_score BETWEEN 600 AND 699 THEN 'Average (600-699)'
        WHEN cibil_score BETWEEN 700 AND 799 THEN 'Good (700-799)'
        WHEN cibil_score >= 800 THEN 'Excellent (800+)'
        ELSE 'Unknown'
    END AS cibil_band,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_cases,
    ROUND(SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*), 2) AS fraud_rate_percentage
FROM loan_applications
GROUP BY cibil_band
ORDER BY cibil_band;

-- /*5.DTI (Debt-to-Income) Ratio Fraud Analysis*/
-- DTI formula: existing_emis_monthly / monthly_income
SELECT 
    CASE 
        WHEN (existing_emis_monthly / monthly_income) < 0.2 THEN 'Low (<0.2)'
        WHEN (existing_emis_monthly / monthly_income) BETWEEN 0.2 AND 0.4 THEN 'Moderate (0.2-0.4)'
        WHEN (existing_emis_monthly / monthly_income) BETWEEN 0.4 AND 0.6 THEN 'High (0.4-0.6)'
        WHEN (existing_emis_monthly / monthly_income) > 0.6 THEN 'Very High (>0.6)'
        ELSE 'Unknown'
    END AS dti_band,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_cases,
    ROUND(SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*), 2) AS fraud_rate_percentage
FROM loan_applications
WHERE monthly_income > 0 -- to avoid divide-by-zero error
GROUP BY dti_band
ORDER BY dti_band;


-- */6.DTI trend over months*/
-- Monthly Average DTI and Fraud Count
SELECT 
    DATE_FORMAT(application_date, '%Y-%m') AS month,
    ROUND(AVG(existing_emis_monthly / monthly_income), 2) AS avg_dti,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_cases
FROM loan_applications
WHERE monthly_income > 0 -- to avoid division by zero
GROUP BY month
ORDER BY month;

-- /*7.Fraud Rate by Loan Type*/
SELECT 
    loan_type,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_cases,
    ROUND(SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM loan_applications
GROUP BY loan_type
ORDER BY fraud_rate_percentage DESC;


 -- /*8.multi-dimensional fraud analysis*/ --->> MAIN ANALYSIS <<---
 -- Goal: Identify repeat loan takers (same customer_id) WHO ARE DOING FRAUD:
-- How often they take loans
-- What types of loans they take
-- Their fraud status and fraud types

WITH ranked_loans AS (
    SELECT 
        customer_id,
        application_date,
        fraud_flag,
        fraud_type,
        loan_type,
        employment_status,
        loan_tenure_months,
        LAG(application_date) OVER (PARTITION BY customer_id ORDER BY application_date) AS previous_loan_date
    FROM loan_applications
    WHERE fraud_flag = 1 AND fraud_type IS NOT NULL
),
loan_durations AS (
    SELECT 
        customer_id,
        DATEDIFF(application_date, previous_loan_date) AS gap_in_days,
        loan_type,
        employment_status,
        fraud_type
    FROM ranked_loans
    WHERE previous_loan_date IS NOT NULL
),
-- unique loan types - to calculate difference between 2 loans and represent we created this column, 
-- and we'll see in queries below that total loans are 3 and unique loans are 2 so it will show 2 because ,for
-- 1st loan we can't calculate its difference in tenure from previous loan so it calculates for 2nd and 3rd loan-- Reference see CUST100032
summary AS (
    SELECT 
        customer_id,
        COUNT(*) + 1 AS total_loans,
        COUNT(DISTINCT loan_type) AS unique_loan_types,            
        GROUP_CONCAT(DISTINCT employment_status) AS employment_statuses,                  
        GROUP_CONCAT(DISTINCT fraud_type) AS fraud_types,
        GROUP_CONCAT(DISTINCT loan_type) AS loan_types_taken,
        ROUND(AVG(gap_in_days), 1) AS avg_gap_between_loans_days
    FROM loan_durations
    GROUP BY customer_id
)
SELECT *
FROM summary
ORDER BY avg_gap_between_loans_days DESC;


-- Here we segregatted the no. of loans for each customer i'd to see how many loans there is fraud whereas previous code gave us time gap between 2 loans of same customer i'd
SELECT 
    customer_id,
    application_date,
    loan_type,
    employment_status,
    fraud_flag,
    fraud_type
FROM loan_applications
WHERE customer_id IN (
    SELECT customer_id
    FROM loan_applications
    WHERE fraud_flag = 1 AND fraud_type IS NOT NULL
    GROUP BY customer_id
    HAVING COUNT(*) > 1
)
ORDER BY customer_id, application_date;


-- Now this below code will give us more proper segregation of total loans, fraud loans and unique loans of which duration gap is calculated
-- Step 1: Get all loans with gap logic
WITH ranked_loans AS (
    SELECT 
        customer_id,
        application_date,
        loan_type,
        employment_status,
        fraud_flag,
        fraud_type,
        LAG(application_date) OVER (PARTITION BY customer_id ORDER BY application_date) AS previous_loan_date
    FROM loan_applications
),

-- Step 2: Calculate gap in months
loan_gaps AS (
    SELECT 
        customer_id,
        application_date,
        loan_type,
        employment_status,
        fraud_flag,
        fraud_type,
        TIMESTAMPDIFF(MONTH, previous_loan_date, application_date) AS gap_in_months
    FROM ranked_loans
    WHERE previous_loan_date IS NOT NULL
),

-- Step 3: Get final summary
summary AS (
    SELECT 
        r.customer_id,
        -- Total loans including first loan
        COUNT(*) AS total_loans_taken,

        -- Unique loans with measurable gap
        (SELECT COUNT(*) FROM loan_gaps g WHERE g.customer_id = r.customer_id) AS unique_loans_with_gap,

        -- Count of fraud loans
        SUM(CASE WHEN fraud_flag = 1 AND fraud_type IS NOT NULL THEN 1 ELSE 0 END) AS fraud_loans,

        -- Distinct values
        GROUP_CONCAT(DISTINCT loan_type) AS loan_types,
        GROUP_CONCAT(DISTINCT employment_status) AS employment_statuses,
        GROUP_CONCAT(DISTINCT CASE WHEN fraud_flag = 1 AND fraud_type IS NOT NULL THEN fraud_type END) AS fraud_types,

        -- Avg gap
        (SELECT ROUND(AVG(gap_in_months), 1) FROM loan_gaps g WHERE g.customer_id = r.customer_id) AS avg_gap_between_loans_months

    FROM ranked_loans r
    GROUP BY r.customer_id
)

-- Step 4: Show only customers who have more than 1 loan
SELECT *
FROM summary
WHERE total_loans_taken > 1 AND fraud_loans > 0
ORDER BY avg_gap_between_loans_months DESC;



--  -->Loan Product Behavior<--
-- /*1.Fraud by Loan Type*/
SELECT 
    loan_type,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_flag = 1 AND fraud_type IS NOT NULL THEN 1 ELSE 0 END) AS fraud_cases,
    ROUND(SUM(CASE WHEN fraud_flag = 1 AND fraud_type IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM loan_applications
GROUP BY loan_type
ORDER BY fraud_rate_percentage DESC;

-- /*2.Fraud by Loan Amount Band*/
SELECT 
    CASE 
        WHEN loan_amount_requested < 200000 THEN '<2L'
        WHEN loan_amount_requested BETWEEN 200000 AND 500000 THEN '2L–5L'
        WHEN loan_amount_requested BETWEEN 500001 AND 1000000 THEN '5L–10L'
        ELSE '>10L'
    END AS loan_amount_band,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_flag = 1 AND fraud_type IS NOT NULL THEN 1 ELSE 0 END) AS fraud_cases,
    ROUND(SUM(CASE WHEN fraud_flag = 1 AND fraud_type IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM loan_applications
GROUP BY loan_amount_band
ORDER BY fraud_rate_percentage DESC;

-- /*3.Fraud by Interest Rate*/
SELECT 
    CASE 
        WHEN interest_rate_offered < 10 THEN '<10%'
        WHEN interest_rate_offered BETWEEN 10 AND 15 THEN '10–15%'
        WHEN interest_rate_offered BETWEEN 16 AND 20 THEN '16–20%'
        ELSE '>20%'
    END AS interest_rate_band,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_flag = 1 AND fraud_type IS NOT NULL THEN 1 ELSE 0 END) AS fraud_cases,
    ROUND(SUM(CASE WHEN fraud_flag = 1 AND fraud_type IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM loan_applications
GROUP BY interest_rate_band
ORDER BY fraud_rate_percentage DESC;

-- Further segregation of interest rate accordding to type of loan 
SELECT 
    CASE 
        WHEN interest_rate_offered < 10 THEN '<10%'
        WHEN interest_rate_offered BETWEEN 10 AND 15 THEN '10–15%'
        WHEN interest_rate_offered BETWEEN 16 AND 20 THEN '16–20%'
        ELSE '>20%'
    END AS interest_rate_band,
    loan_type,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN fraud_flag = 1 AND fraud_type IS NOT NULL THEN 1 ELSE 0 END) AS fraud_cases,
    ROUND(SUM(CASE WHEN fraud_flag = 1 AND fraud_type IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_percentage
FROM loan_applications
GROUP BY interest_rate_band, loan_type
ORDER BY interest_rate_band, fraud_rate_percentage DESC;



-- /*1.Frequent Fraud Types*/
SELECT 
    fraud_type,
    COUNT(*) AS fraud_count
FROM loan_applications
WHERE fraud_flag = 1 AND fraud_type IS NOT NULL
GROUP BY fraud_type
ORDER BY fraud_count DESC;





