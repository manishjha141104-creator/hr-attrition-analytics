select count(*)from hr_employee_attrition where MonthlyIncome is null;
SELECT DISTINCT Attrition FROM hr_employee_attrition;
SELECT DISTINCT OverTime FROM hr_employee_attrition;
-- overall attrition rate
SELECT 
  Attrition, 
  COUNT(*) AS employee_count,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM hr_employee_attrition), 2) AS pct
FROM hr_employee_attrition
GROUP BY Attrition;
-- Attrition rate by department
SELECT 
  Department,
  COUNT(*) AS total,
  SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
  ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM hr_employee_attrition
GROUP BY Department
ORDER BY attrition_rate DESC;
-- Attrition by job role
SELECT 
  JobRole,
  COUNT(*) AS total,
  ROUND(100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM hr_employee_attrition
GROUP BY JobRole
ORDER BY attrition_rate DESC;
-- Salary band vs attrition
SELECT 
  CASE 
    WHEN MonthlyIncome < 3000 THEN 'Low'
    WHEN MonthlyIncome BETWEEN 3000 AND 7000 THEN 'Medium'
    ELSE 'High'
  END AS salary_band,
  COUNT(*) AS total,
  ROUND(100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM hr_employee_attrition
GROUP BY salary_band
ORDER BY attrition_rate DESC;
-- Overtime impact
SELECT 
  OverTime,
  COUNT(*) AS total,
  ROUND(100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM hr_employee_attrition
GROUP BY OverTime;
-- Average tenure: left vs stayed
SELECT 
  Attrition,
  ROUND(AVG(YearsAtCompany), 2) AS avg_tenure,
  ROUND(AVG(YearsSinceLastPromotion), 2) AS avg_years_since_promo
FROM hr_employee_attrition
GROUP BY Attrition;
-- Window function: rank departments by attrition rate
SELECT 
  Department,
  attrition_rate,
  RANK() OVER (ORDER BY attrition_rate DESC) AS attrition_rank
FROM (
  SELECT Department,
    ROUND(100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
  FROM hr_employee_attrition
  GROUP BY Department
) sub;
-- Compound high-risk segment
SELECT 
  JobRole,
  OverTime,
  CASE WHEN JobSatisfaction <= 2 THEN 'Low Satisfaction' ELSE 'OK Satisfaction' END AS satisfaction_flag,
  COUNT(*) AS total,
  ROUND(100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM hr_employee_attrition
GROUP BY JobRole, OverTime, satisfaction_flag
HAVING COUNT(*) > 10
ORDER BY attrition_rate DESC
LIMIT 10;




