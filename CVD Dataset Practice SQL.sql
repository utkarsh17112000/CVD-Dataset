/*
1. Demographic & Risk Exposure (SQL Foundations)
1. Age-band Risk Concentration
Create age bands (25–35, 36–45, 46–55, 56–65, 66+) and calculate the percentage of High CVD Risk patients and the average CVD Risk Score per age band. Which age group shows the highest risk concentration?

2. Gender-based Risk Comparison
Compare average CVD Risk Score and percentage of High Risk patients between males and females.

3. Smoking x Gender x Risk Level
Create a cross-tab of Sex x Smoking Status x CVD Risk Level. Which demographic segment is most vulnerable?

4. Comorbidity-driven High-Risk Cohort
Among patients aged over 50 with diabetes and Hypertension Stage 1 or Stage 2, what percentage are classified as High CVD Risk?

2. Anthropometric & Obesity Analytics
5. BMI Category vs Risk
Classify BMI into Underweight, Normal, Overweight, and Obese. Calculate risk level distribution and average CVD Risk Score per BMI category. Does obesity strongly correlate with risk?

6. Waist-to-Height Ratio Quartiles
Create quartiles (Q1–Q4) of Waist-to-Height Ratio and compare average LDL and average CVD Risk Score across quartiles. Does central obesity outperform BMI in predicting risk?

7. Correlation Strength Comparison
Compare correlation between BMI and CVD Risk Score versus Abdominal Circumference and CVD Risk Score. Which anthropometric measure is stronger?

3. Blood Pressure & Clinical Risk
8. Normal BMI but High Risk
Identify patients with Normal BMI but High CVD Risk. Which factors (BP category, LDL, Diabetes, Fasting Blood Sugar) explain their elevated risk?

9. BP Category vs High Risk
What percentage of patients with Hypertension Stage 2 fall into the High CVD Risk category?

10. BP Severity vs Risk Score
Calculate the average CVD Risk Score for Normal, Elevated, Hypertension Stage 1, and Hypertension Stage 2 blood pressure categories. Is risk increasing linearly with severity?

4. Lipids, Diabetes & Metabolic Risk
11. Lipid-driven High Risk
Among patients with Normal BP, identify those with High LDL and High CVD Risk. What percentage of total High Risk patients fall into this group?

12. Cholesterol Segmentation
Segment Total Cholesterol into <150, 150–180, and >180 mg/dL. How does average CVD Risk Score vary across these groups?

13. LDL/HDL Ratio Effectiveness
Compare the predictive strength of LDL alone versus LDL/HDL ratio for identifying High CVD Risk patients.

14. Diabetes vs Non-diabetes Impact
Compare diabetic and non-diabetic patients based on average fasting blood sugar and average CVD Risk Score. What is the incremental risk due to diabetes?

5. Advanced / Senior-Level Analytics
15. Clinically Normal but High Risk Investigation
Identify patients with Normal BP, Normal BMI, Normal Cholesterol, but High CVD Risk. Is Family History or Diabetes the dominant contributing factor?
*/
SELECT * FROM `cvd dataset`.`cvd dataset`;

#1. Age-band Risk Concentration
#Create age bands (25–35, 36–45, 46–55, 56–65, 66+) and calculate the percentage of High CVD Risk patients and the average CVD Risk Score per age band. Which age group shows the highest risk concentration?
select
case 
when Age>=25 and Age<=35 then "25-35"
when Age>=36 and Age<=45 then "36-45"
when Age>=46 and Age<=55 then "46-55"
when Age>=56 and Age<=65 then "56-65"
else "66+" end as age_bands,
round(sum(case when `CVD Risk Level`="HIGH" then 1 else 0 end)*100.0/count(*),2) as pct_cvd_high_risk_patients,
round(avg(`CVD Risk Score`),2) as avg_cvd_risk_score
from `cvd dataset`.`cvd dataset`
group by age_bands
order by pct_cvd_high_risk_patients desc;



#2. Gender-based Risk Comparison
#Compare average CVD Risk Score and percentage of High Risk patients between males and females.
select Sex,
round(sum(case when `CVD Risk Level`="HIGH" then 1 else 0 end)*100.0/count(*),2) as pct_cvd_high_risk_patients,
round(avg(`CVD Risk Score`),2) as avg_cvd_risk_score
from `cvd dataset`.`cvd dataset`
group by Sex
order by pct_cvd_high_risk_patients desc;


# 3. Smoking x Gender x Risk Level
#Create a cross-tab of Sex x Smoking Status x CVD Risk Level. Which demographic segment is most vulnerable?
select Sex,`Smoking Status`,
round(sum(case when `CVD Risk Level`="HIGH" then 1 else 0 end)*100.0/count(*),2) as pct_cvd_high_risk_patients,
round(avg(`CVD Risk Score`),2) as avg_cvd_risk_score
from `cvd dataset`.`cvd dataset`
group by Sex,`Smoking Status`
order by pct_cvd_high_risk_patients desc;


# 4. Comorbidity-driven High-Risk Cohort
# Among patients aged over 50 with diabetes and Hypertension Stage 1 or Stage 2, what percentage are classified as High CVD Risk?
select round(sum(case when `CVD Risk Level`="High" then 1 else 0 end)*100.0/count(*),2) as pct_cvd_high_risk_patients
from `cvd dataset`.`cvd dataset`
where Age>50 and `Diabetes Status`="Y" and
 `Blood Pressure Category` in ( "Hypertension Stage 1","Hypertension Stage 2")
;

#5. BMI Category vs Risk
#Classify BMI into Underweight, Normal, Overweight, and Obese. Calculate risk level distribution and average CVD Risk Score per BMI category. Does obesity strongly correlate with risk?
select 
case when BMI<18.5 then "Underweight"
when BMI>=18.5 and BMI<=24.9 then "Normal"
when BMI>=25.0 and BMI<=29.9 then "Overweight"
else "Obese" end as BMI_Category,
round(sum(case when `CVD Risk Level`="HIGH" then 1 else 0 end)*100.0/count(*),2) as pct_cvd_high_risk_patients,
round(avg(`CVD Risk Score`),2) as avg_cvd_risk_score
from `cvd dataset`.`cvd dataset`
group by BMI_Category
order by pct_cvd_high_risk_patients desc;



#6. Waist-to-Height Ratio Quartiles
# Create quartiles (Q1–Q4) of Waist-to-Height Ratio and compare average LDL and average CVD Risk Score across quartiles. Does central obesity outperform BMI in predicting risk?
with cte as (select *, ntile(4) over (order by `Waist-to-Height Ratio` asc) as Waist_to_Height_Ratio_quartile
from `cvd dataset`.`cvd dataset`)
select Waist_to_Height_Ratio_quartile,round(avg(`Estimated LDL (mg/dL)`),2) as avg_Estimated_LDL,
round(avg(`CVD Risk Score`),2) as avg_CVD_Risk_Score 
from cte
group by Waist_to_Height_Ratio_quartile ;



#7. Correlation Strength Comparison
#Compare correlation between BMI and CVD Risk Score versus Abdominal Circumference and CVD Risk Score. Which anthropometric measure is stronger?
with cte as (select BMI, avg(BMI) over () avg_BMI,
`CVD Risk Score`as CVD_Risk_Score,avg(`CVD Risk Score`) over() as avg_CVD_Risk_Score,
`Abdominal Circumference (cm)`as Abdominal_Circumference,avg(`Abdominal Circumference (cm)`) over() as avg_Abdominal_Circumference
from `cvd dataset`.`cvd dataset`)
select 
round(
sum((BMI-avg_BMI)*(CVD_Risk_Score-avg_CVD_Risk_Score))/
(sqrt(sum(pow((BMI-avg_BMI),2)))*sqrt(sum(pow((CVD_Risk_Score-avg_CVD_Risk_Score),2))))
,2) as "Correlation Between BMi and CVD Risk Score",
round(
sum((Abdominal_Circumference-avg_Abdominal_Circumference)*(CVD_Risk_Score-avg_CVD_Risk_Score))/
(sqrt(sum(pow((Abdominal_Circumference-avg_Abdominal_Circumference),2)))*sqrt(sum(pow((CVD_Risk_Score-avg_CVD_Risk_Score),2))))
,2) as "Correlation Between BMi and CVD Risk Score"
from cte ; 

#8. Normal BMI but High Risk
#Identify patients with Normal BMI but High CVD Risk. Which factors (BP category, LDL, Diabetes, Fasting Blood Sugar) explain their elevated risk?
with cte as (select *,
case when BMI<18.5 then "Underweight"
when BMI>=18.5 and BMI<=24.9 then "Normal"
when BMI>=25.0 and BMI<=29.9 then "Overweight"
else "Obese" end as BMI_Category
from `cvd dataset`.`cvd dataset`)
select BMI_Category,
`Blood Pressure Category`,sum(case when `CVD Risk Level`="High" then 1 else 0 end) as total_high_risk_patients,
round(avg(`CVD Risk Score`),2) as avg_cvd_risk_score,
round(avg(`Blood Pressure (mmHg)`),2) as "Avg Blood Pressure (mmHg)",
round(avg(`Fasting Blood Sugar (mg/dL)`),2) as "Avg Fasting Blood Sugar (mg/dL)",
round(avg(`Estimated LDL (mg/dL)`),2) as "Avg Estimated LDL (mg/dL)",
round(avg(BMI),2) as "Avg BMI"
from cte
where BMI_Category="Normal" and `CVD Risk Level`="High"
group by BMI_Category,`Blood Pressure Category`;



#9. BP Category vs High Risk
#What percentage of patients with Hypertension Stage 2 fall into the High CVD Risk category?
select `Blood Pressure Category`,sum(case when `CVD Risk Level`="High" then 1 else 0 end) as total_high_risk_patients,
round(sum(case when `CVD Risk Level`="HIGH" then 1 else 0 end)*100.0/count(*),2) as pct_cvd_high_risk_patients,
round(avg(`CVD Risk Score`),2) as avg_cvd_risk_score
from `cvd dataset`.`cvd dataset`
group by `Blood Pressure Category`
order by pct_cvd_high_risk_patients desc , avg_cvd_risk_score desc;


#10. BP Severity vs Risk Score
#Calculate the average CVD Risk Score for Normal, Elevated, Hypertension Stage 1, and Hypertension Stage 2 blood pressure categories. Is risk increasing linearly with severity?
select `Blood Pressure Category`,
round(avg(`CVD Risk Score`),2) as avg_cvd_risk_score
from `cvd dataset`.`cvd dataset`
group by `Blood Pressure Category`
order by `Blood Pressure Category` desc;


# 11. Lipid-driven High Risk
# Among patients with Normal BP, identify those with High LDL and High CVD Risk. What percentage of total High Risk patients fall into this group?
select round(sum(case when `CVD Risk Level`="HIGH" then 1 else 0 end)*100.0/
(select sum(case when `CVD Risk Level`="HIGH" then 1 else 0 end) from `cvd dataset`.`cvd dataset`),2) as pct_cvd_high_risk_patients
from `cvd dataset`.`cvd dataset`
where `Blood Pressure Category` ="Normal" and `Estimated LDL (mg/dL)`>=130;
 
#12. Cholesterol Segmentation
#Segment Total Cholesterol into <150, 150–180, and >180 mg/dL. How does average CVD Risk Score vary across these groups?
select
case 
when `Total Cholesterol (mg/dL)`<150 then "<150"
when `Total Cholesterol (mg/dL)`>=150 and `Total Cholesterol (mg/dL)`<=180 then "150-180"
else ">180" end as Total_Cholesterol_Category,
round(avg(`CVD Risk Score`),2) as avg_CVD_Risk_Score
from `cvd dataset`.`cvd dataset`
group by Total_Cholesterol_Category
order by avg_CVD_Risk_Score desc;


#13. LDL/HDL Ratio Effectiveness
# Compare the predictive strength of LDL alone versus LDL/HDL ratio for identifying High CVD Risk patients.
WITH base AS (
  SELECT
    `Estimated LDL (mg/dL)` AS ldl,
    `HDL (mg/dL)`,
    (`Estimated LDL (mg/dL)` / NULLIF(`HDL (mg/dL)`, 0)) AS ldl_hdl_ratio,
    CASE 
      WHEN `CVD Risk Level` = 'High' THEN 1 
      ELSE 0 
    END AS high_risk
  from `cvd dataset`.`cvd dataset`
),
stats AS (
  SELECT
    ldl,
    ldl_hdl_ratio,
    high_risk,
    AVG(ldl) OVER () AS avg_ldl,
    AVG(ldl_hdl_ratio) OVER () AS avg_ldl_hdl,
    AVG(high_risk) OVER () AS avg_high_risk
  FROM base
)
SELECT
  ROUND(
    SUM((ldl - avg_ldl) * (high_risk - avg_high_risk)) /
    (SQRT(SUM(POW(ldl - avg_ldl, 2))) * SQRT(SUM(POW(high_risk - avg_high_risk, 2)))),
  3) AS corr_ldl_vs_high_risk,

  ROUND(
    SUM((ldl_hdl_ratio - avg_ldl_hdl) * (high_risk - avg_high_risk)) /
    (SQRT(SUM(POW(ldl_hdl_ratio - avg_ldl_hdl, 2))) * SQRT(SUM(POW(high_risk - avg_high_risk, 2)))),
  3) AS corr_ldl_hdl_vs_high_risk
FROM stats;

#14. Diabetes vs Non-diabetes Impact
#Compare diabetic and non-diabetic patients based on average fasting blood sugar and average CVD Risk Score. What is the incremental risk due to diabetes?
SELECT
  `Diabetes Status`,
  ROUND(AVG(`Fasting Blood Sugar (mg/dL)`), 2) AS avg_fasting_blood_sugar,
  ROUND(AVG(`CVD Risk Score`), 2) AS avg_cvd_risk_score,
  COUNT(*) AS patient_count
FROM  `cvd dataset`.`cvd dataset`
GROUP BY `Diabetes Status`;


#15. Clinically Normal but High Risk Investigation
#Identify patients with Normal BP, Normal BMI, Normal Cholesterol, but High CVD Risk. Is Family History or Diabetes the dominant contributing factor?

WITH clinically_normal_high_risk AS (
  SELECT
    `Family History of CVD`,
    `Diabetes Status`
  FROM  `cvd dataset`.`cvd dataset`
  WHERE
    `Blood Pressure Category` = 'Normal'
    AND BMI BETWEEN 18.5 AND 24.9
    AND `Total Cholesterol (mg/dL)` < 180
    AND `CVD Risk Level` = 'High'
)
SELECT
  `Family History of CVD`,
  `Diabetes Status`,
  COUNT(*) AS patient_count,
  ROUND(
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
  2) AS pct_within_clinically_normal_high_risk
FROM clinically_normal_high_risk
GROUP BY
  `Family History of CVD`,
  `Diabetes Status`
ORDER BY patient_count DESC;



