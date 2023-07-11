CREATE DATABASE PROJECT;
USE PROJECT;
SET sql_safe_updates=0;
SELECT * FROM HR;

#CHANGING THE NAME OF THE FIRST COLUMN
ALTER TABLE HR
CHANGE COLUMN ï»¿id emp_id VARCHAR(20);

start transaction;

#UPDATING THE TYPE AND FORMATE OF DATE VALUES FOR THE COLUMN BIRTHDATE(1ST METHOD)
UPDATE HR
SET birthdate= CASE
WHEN birthdate like"%/%" THEN DATE_FORMAT(str_to_date(birthdate, '%m/%d/%Y'),'%Y-%m-%d')
WHEN birthdate like "%-%" THEN DATE_FORMAT(str_to_date(birthdate, '%m-%d-%Y'),'%Y-%m-%d')
ELSE NULL
END;

#ALTERING THE DATATYPE OF THE COLUMN BIRTDATE
ALTER TABLE HR
MODIFY COLUMN BIRTHDATE DATE;
commit;

start transaction;

#UPDATING THE TYPE AND FORMATE OF DATE VALUES FOR THE COLUMN HIREDATE(2ND METHOD)
update HR
set hire_date= DATE_FORMAT(str_to_date(hire_date, '%m-%d-%Y'),'%Y-%m-%d')
where hire_date like "%-%" and hire_date!="1984-06-29" ;

update HR
set hire_date= DATE_FORMAT(str_to_date(hire_date, '%m/%d/%Y'),'%Y-%m-%d')
where hire_date like "%/%" and hire_date!="1984-06-29" ;

#ALTERING THE DATATYPE OF THE COLUMN HIREDATE
ALTER TABLE HR
MODIFY COLUMN hire_date DATE;
commit;

start transaction;
SET SQL_MODE = ' ';

#UPDATING THE DATATYPE AND EXTRACT OF DATE FROM THE COLUMN TERMDATE ALSO DEAL WITH THE NULL VALUES
UPDATE HR
SET termdate=date(str_to_date(termdate,'%Y-%m-%d %H:%i:%S UTC'))
where termdate is not null and termdate!=" ";

#ALTERING THE DATATYPE OF THE COLUMN TERMDATE
ALTER TABLE HR
MODIFY COLUMN termdate DATE;
commit;

start transaction;

#CREATING TABLE NAME AGE
ALTER TABLE HR
ADD COLUMN AGE INT;

#UPDATING THE VALUES TO AGE COLUMN USING BIRTHDATE AND COLUMN DATE
UPDATE HR
SET AGE= TIMESTAMPDIFF(YEAR, BIRTHDATE, NOW());
SELECT AGE FROM HR;
COMMIT;

#CHECKING IF THERE IS DUMMY DATA FOR AGE COLUMN
SELECT COUNT(AGE) FROM HR
WHERE AGE<18;
#WE NEED TO AVOID THESE VALUES DURING OUR CASE STUDY

SELECT * FROM HR;

#QUESTIONS
#Q1.FIND THE GENDER RATIO FOR THE COMPANY

SELECT GENDER, COUNT(GENDER) AS COUNT FROM HR
WHERE AGE>=18 AND TERMDATE="0000-00-00"
GROUP BY GENDER;

#SAVE THE BELOW TABLE BY USING EXPORT OPTION AVAILABLE AT THE RIGHT OF THE TABLE, WE WILL USE THIS LATER ON VISUALIZATION IN POWER BI

#Q2. FIND THE RACE/ETHNICITY BREAKDOWN OF THE EMPLOYEES OF THE COMPANY

SELECT RACE, COUNT(RACE) AS COUNT FROM HR
WHERE AGE>=18 AND TERMDATE="0000-00-00"
GROUP BY RACE
ORDER BY COUNT DESC;

#SAVE THE BELOW TABLE BY USING EXPORT OPTION AVAILABLE AT THE RIGHT OF THE TABLE, WE WILL USE THIS LATER ON VISUALIZATION IN POWER BI

#Q3. AGE DISTRIBUTION OF THE COMPANY

SELECT MIN(AGE), MAX(AGE) FROM HR
WHERE AGE>=18 AND TERMDATE="0000-00-00";

set sql_safe_updates=0;
select * from hr;
SELECT 
CASE
  WHEN AGE>=18 AND AGE<=30 THEN "18-30"
  WHEN AGE>30 AND AGE<=40 THEN "30-40"
  WHEN AGE>40 AND AGE<=50 THEN "40-50"
  ELSE "50+"
END AS age_group,
COUNT(*) AS COUNT FROM HR
WHERE AGE>=18 AND TERMDATE="0000-00-00"
GROUP BY age_group
ORDER BY age_group;

SELECT 
CASE
  WHEN AGE>=18 AND AGE<=30 THEN "18-30"
  WHEN AGE>30 AND AGE<=40 THEN "30-40"
  WHEN AGE>40 AND AGE<=50 THEN "40-50"
  ELSE "50+"
END AS age_group,
Gender, COUNT(*) AS COUNT FROM HR
WHERE AGE>=18 AND TERMDATE="0000-00-00"
GROUP BY age_group, Gender
ORDER BY age_group, Gender;

#Q4. HOW MANY EMPLOYEES WORK AT HEADQUARTER VERSUS REMOTE LOCATION

SELECT location, count(location) AS count from HR
WHERE AGE>=18 AND TERMDATE="0000-00-00"
GROUP BY LOCATION;

#Q5. WHAT IS THE AVG EMPLOYEMENT LENGTH FOR EMPLOYEES WHO HAVE BEEN TERMINATED?

SELECT round(avg(timestampdiff(YEAR,hire_date,termdate)),0) AS employment_length 
FROM HR
WHERE age>=18 AND termdate!="0000-00-00" AND termdate<= curdate();

#OR

SELECT round(avg(datediff(termdate,hire_date)/365),0) AS employment_length 
FROM HR
WHERE age>=18 AND termdate!="0000-00-00" AND termdate<= curdate();

#DATEDIFF will be more accurate in case you are considering decimal into the AVG value, since DATEDIFF is taking into consideration month and date also.

#Q6 HOW DOES THE GENDER DISTRIBUTION VARY ACROSS DEPARTMENTS AND JOB TITLES

SELECT department, gender, count(*) FROM HR
WHERE AGE>=18 AND TERMDATE="0000-00-00"
GROUP BY department, gender
ORDER BY department, gender;

#Q7. WHAT IS THE DISTRIBUTION OF DEPARTMENT AND JOBTITLES ACROSS THE COMPANY?

SELECT department, COUNT(*) AS count FROM HR
WHERE AGE>=18 AND TERMDATE="0000-00-00"
GROUP BY department
ORDER BY count DESC;

SELECT jobtitle, COUNT(*) AS count FROM HR
WHERE AGE>=18 AND TERMDATE="0000-00-00"
GROUP BY jobtitle
ORDER BY count DESC;

#Q8. WHICH DEPT HAS THE HIGHEST TURNOVER RATE(% of employees that quit during a given time period)?

SELECT 
    DEPARTMENT,
    TOTAL_COUNT,
    TERMINATED_COUNT,
    TERMINATED_COUNT / TOTAL_COUNT AS TERMINATION_RATE
FROM (
    SELECT 
        DEPARTMENT, 
        COUNT(*) AS TOTAL_COUNT,
        SUM(CASE WHEN TERMDATE != "0000-00-00" AND TERMDATE <= CURDATE() THEN 1 ELSE 0 END) AS TERMINATED_COUNT
    FROM HR
    WHERE AGE >= 18
    GROUP BY DEPARTMENT
) AS SUBQUERY
ORDER BY TERMINATION_RATE DESC;

#Q9. WHAT IS THE DISTIBUTION OF EMPLOYEES ACROSS LOCATIONS BY STATE

SELECT location_state, count(*) as count from HR
WHERE AGE>=18 AND TERMDATE="0000-00-00"
GROUP BY location_state
ORDER BY count desc;

#Q10. HOW HAS THE COMPANY'S EMPLOYEE COUNT CHANGED OVER TIME BASED ON HIRE AND TERM DATE?

SELECT 
      year,
      hires,
      terminations,
      hires-terminations AS net_change,
      round((hires-terminations)/hires*100,2) AS net_change_percentage
FROM(
     SELECT 
         YEAR(hire_date) AS year,
		 count(*) as hires,
         sum(CASE WHEN TERMDATE!="0000-00-00" AND TERMDATE<=CURDATE() THEN 1 ELSE 0 END) AS terminations
	FROM HR
    WHERE age>=18
    GROUP BY YEAR(hire_date)
    ) AS subquery
ORDER BY year;

#Q11. WHAT IS THE TENURE DISTRIBUTION FOR EACH DEPARTMENT?

SELECT DEPARTMENT, ROUND(AVG(DATEDIFF(TERMDATE, HIRE_DATE)/365),0) AS AVG_TENURE FROM HR
WHERE TERMDATE!="0000-00-00" AND TERMDATE<=CURDATE() AND AGE>=18
GROUP BY DEPARTMENT;
