use SQL_Projects;

select * from Walmart_Sales;

select count(*) from walmart_sales;

select  
      payment_method,
	  count(*)
from Walmart_Sales
group by payment_method;

select count(distinct branch) from Walmart_Sales;

select max(quantity),min(quantity) from Walmart_Sales;

-- Business Problems

-- Q1. Find different payment method, and number of transcations, number of quantity sold
select 
        payment_method,
		count(*) as no_of_payments,
		sum(quantity) as quantity_sold
from Walmart_Sales
group by payment_method
order by quantity_sold desc;

-- Q2. Identify the highest-rated category in each branch, displaying the branch,category avg rating
WITH CategoryRatings AS (
    SELECT
        branch,
        category,
        AVG(rating) AS Avg_Rating,
        ROW_NUMBER() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rn
    FROM Walmart_Sales
    GROUP BY branch, category
)
SELECT branch, category, Avg_Rating
FROM CategoryRatings
WHERE rn = 1
ORDER BY branch;


-- Q3. Identify the busiest day for each branch based on the number of transactions
WITH DailyTransactions AS (
    SELECT 
        branch,
        date,
        COUNT(*) AS total_transactions,
        ROW_NUMBER() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rn
    FROM Walmart_Sales
    GROUP BY branch, date
)
SELECT branch, date AS busiest_day, total_transactions
FROM DailyTransactions
WHERE rn = 1
ORDER BY branch;


-- Q4. Calculate the total_quantity of items sold per payment method.List payment_method and total_quantity.

select 
       payment_method,
	   sum(quantity) as total_quantity
from Walmart_Sales
group by payment_method
order by total_quantity desc ;

-- Q5. determine the average, minimum, and maximum ratings of products for each city.
--List the city,average_rating,min_rating,and max_rating.
select 
      city,
	  category,
      max(rating) as MAX_Rating,
	  min(rating) as Min_Rating,
	  AVG(rating) as AVG_Rating
from Walmart_Sales
group by city,category;


-- Q6. Calculate total profit for each category by considering total_profit as (unit_price * quantity * Profit_margin)
-- list category, and total_profit, ordered from highest to lowest profit.
select 
      category,
	  sum(total) as total_revenue,
	  sum(unit_price * quantity * Profit_Margin) as total_profit
from Walmart_Sales
group by category
order by total_profit desc;


-- Q7. Determine the most common payment_method for each Branch.Display branch and the preferred_payment_method.
WITH PaymentCounts AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_transactions,
        ROW_NUMBER() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rn
    FROM Walmart_Sales
    GROUP BY branch, payment_method
)
SELECT 
    branch,
    payment_method AS preferred_payment_method,
    total_transactions
FROM PaymentCounts
WHERE rn = 1
ORDER BY branch;


-- Q8. categorize sales into 3 main groups Morning, Afternoon, Evening
-- Find out which of the shift and number of invoices

SELECT
    branch,
    CASE
        WHEN CAST(time AS TIME) BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
        WHEN CAST(time AS TIME) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(invoice_id) AS total_invoices
FROM Walmart_Sales
GROUP BY 
    branch,
    CASE
        WHEN CAST(time AS TIME) BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
        WHEN CAST(time AS TIME) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END
ORDER BY branch, total_invoices DESC;


-- Q9. Identify 5 branch with highest decrese ratio in revenue
-- campared to last year(current year 2023 and last year 2022)
SELECT TOP 10
    [date],
    TRY_CONVERT(date, [date], 3) AS converted_date  -- 3 = dd/mm/yy
FROM Walmart_Sales;
ALTER TABLE Walmart_Sales
ADD converted_date DATE;

UPDATE Walmart_Sales
SET converted_date = TRY_CONVERT(date, [date], 3);

WITH BranchRevenue AS (
    SELECT
        branch,
        YEAR(converted_date) AS year,
        SUM(total) AS total_revenue
    FROM Walmart_Sales
    GROUP BY branch, YEAR(converted_date)
)
SELECT TOP 5
    curr.branch,
    prev.total_revenue AS revenue_2022,
    curr.total_revenue AS revenue_2023,
    ROUND(
        ((curr.total_revenue - prev.total_revenue) / prev.total_revenue) * 100, 2
    ) AS decrease_percent
FROM BranchRevenue curr
JOIN BranchRevenue prev 
    ON curr.branch = prev.branch
   AND curr.year = 2023
   AND prev.year = 2022
WHERE curr.total_revenue < prev.total_revenue
ORDER BY decrease_percent ASC;













