
 
 
 
 CREATE TABLE WALMART
(

INVOICE INT PRIMARY KEY,
	Branch VARCHAR(50),
	City VARCHAR(90),
	category VARCHAR(100),
	unit_price  FLOAT ,
	quantity INT ,
	date DATE,
    time TIME,
	payment_method VARCHAR(100),
	rating	 FLOAT ,
    profit_margin  FLOAT 
    );
SELECT *FROM WALMART;


--- COUNT 
       SELECT 
	   COUNT(*) WALMART;


      SELECT *FROM WALMART;

	   SELECT 
	 payment_method,
	 COUNT(*)
      FROM walmart
     GROUP BY payment_method;
	 

	  SELECT 
	COUNT(DISTINCT branch) 
     FROM walmart;

    SELECT MAX(quantity) 
	FROM walmart;



	-- Business Problems
--Q.1 Find different payment method and number of transactions, number of qty sold


SELECT 
	 payment_method,
	 COUNT(*) as no_payments,
	 SUM(quantity) as no_sold
FROM walmart
GROUP BY payment_method;



 -- Project Question #2
-- Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING

 SELECT 
	 branch,
	 category,
	 AVG(rating) as avg_rating
	 FROM WALMART
	 GROUP BY 1,2
	 ORDER BY 1,3 DESC;

	 -- ranking

	 SELECT * 
FROM
(	SELECT 
		branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY category ORDER BY AVG(rating) DESC) as rank
	FROM walmart
	GROUP BY 1, 2
)
  WHERE rank = 1

-- Q.3 Identify the busiest day for each branch based on the number of transactions

     SELECT date from WALMART;

	 SELECT 
	 branch,
	 date,
	  TO_CHAR (date, 'DAY')  as day_name
	 FROM WALMART
	 
	  SELECT 
		branch,
		TO_CHAR (date,  'day') as day_name,
		COUNT (*) as no_transactions
	FROM walmart
	GROUP BY 1,2
	ORDER BY 1,3 DESC;

-- FOR RANKING

        SELECT * 
FROM
	(SELECT 
		branch,
		TO_CHAR(date, 'Day') as day_name,
		COUNT(*) as no_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY 1, 2
	)
WHERE rank = 1


-- Q. 4 
-- Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

     SELECT
	 payment_method,
	 SUM (quantity) as  total_sold
	 FROM WALMART
	 GROUP BY 1

-- Q.5
-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.

   SELECT 
   category,
   city,
   AVG(rating) as avg_rating,
   MIN (rating) as min_rating,
   MAX(rating) as MAX_RATING
   from walmart
   GROUP BY 1,2
   -- ORDER BY 1,3 DESC;


 -- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit


     SELECT 
	 category,
	 SUM(  profit_margin) as total_revenue,
	 SUM(unit_price * quantity * profit_margin) as total_profit
	 FROM WALMART
	 GROUP BY 1
	 ORDER BY 1,2 DESC;
	 
  -- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit


     SELECT 
	 category,
	 SUM(  profit_margin) as total_revenue,
	 SUM(unit_price * quantity * profit_margin) as total_profit
	 FROM WALMART
	 GROUP BY 1
	 ORDER BY 1,2 DESC;


	 -- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.


    WITH City
	AS

    (SELECT
     branch,
	 payment_method,
	 city,
	 COUNT(*) as TOTAL_TRANS,
	 RANK() OVER (PARTITION BY branch ORDER BY COUNT (*) DESC) AS RANK
	   FROM WALMART
	   GROUP BY 1,2,3
  
    ) SELECT*
	 FROM City
	 WHERE RANK =1

 -- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices


   -- FOR MAKE SHIFTS
   SELECT
   *,
   CASE 
   WHEN EXTRACT ( HOURS FROM (time::time)) 
	  < 12 THEN 'MORNING'
	  WHEN EXTRACT ( HOURS FROM (time::time)) 
	  BETWEEN 12 AND 16 THEN 'AFTERNOON'
	  ELSE 'EVENING'
	  
	  END  day_time
	  FROM WALMART
	  
	  GROUP BY 1
	  
     --  AFTER PROBLEM SOLVE


      SELECT 
	  invoice,
	  
	  CASE WHEN EXTRACT ( HOURS FROM (time::time)) 
	  < 12 THEN 'MORNING'
	  WHEN EXTRACT ( HOURS FROM (time::time)) 
	  BETWEEN 12 AND 16 THEN 'AFTERNOON'
	  ELSE 'EVENING'
	  
	  END  day_time,
	  COUNT(*)
	  
	  FROM WALMART
	  GROUP BY 1,2
	  
	  ORDER BY 1,2,3;

	  select * from walmart;

	     -- #9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)


-- rdr == last_rev-cr_rev/ls_rev*100

       SELECT
	 branch,
	 SUM (total_revenue) as commpare_rev
	 from walmart
	 group by 1


-- add new column for permanantly 


	 ALTER TABLE WALMART
	 ADD COLUMN total_revenue NUMERIC;
	 UPDATE WALMART
	 SET total_revenue = unit_price * quantity;

  ALTER TABLE WALMART
	 ADD COLUMN total_profit NUMERIC;
	 UPDATE WALMART
	 SET total_profit= unit_price * quantity * profit_margin;


-- problm solve

SELECT *,
EXTRACT(YEAR FROM (date)) as formated_date
FROM walmart

-- 2022 sales
WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total_revenue) as revenue
	FROM walmart
	WHERE EXTRACT (YEAR FROM (date))= 2022 
	-- WHERE YEAR(TO_DATE(date, 'DD/MM/YY')) = 2022 -- mysql
	GROUP BY 1
),

revenue_2023
AS
(

	SELECT 
		branch,
		SUM(total_revenue) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM (date)) = 2023
	GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5


-- end project