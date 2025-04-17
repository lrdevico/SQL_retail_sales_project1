CREATE TABLE IF NOT EXISTS vendas_retail(
    transactions_id INTEGER PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INTEGER,
    gender VARCHAR(10),
    age INTEGER,
    category VARCHAR(25),
    quantity INTEGER,
    price_per_unit NUMERIC(10,2),
    cogs NUMERIC(10,2),
    total_sale NUMERIC(10,2)
);
-- Exploring the table

SELECT * FROM vendas_retail;

SELECT * FROM vendas_retail
WHERE
    transactions_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    OR age IS NULL
    OR category IS NULL
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;

SELECT * FROM vendas_retail 
WHERE customer_id IN(77, 94, 116, 101, 64, 42, 137)
AND quantity IS NOT NULL
AND price_per_unit IS NOT NULL
AND cogs IS NOT NULL
AND total_sale IS NOT NULL;

-- Cleaning the data

DELETE FROM vendas_retail
WHERE transactions_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    OR age IS NULL
    OR category IS NULL
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;

SELECT * FROM vendas_retail;

-- Exploring the Data 

-- Q1. How many sales are there in each category?
SELECT category, COUNT(*)AS total_sales FROM vendas_retail
GROUP BY category
ORDER BY total_sales DESC;

-- Q2. How many unique customers do we have?
SELECT COUNT(DISTINCT customer_id) AS total_unique_customers
FROM vendas_retail;

-- Q3. Retrieve all sales that were made from 2022-06-15 to 2022-10-15
SELECT * FROM vendas_retail
WHERE sale_date BETWEEN '2022-06-15' AND '2022-10-15'
ORDER BY sale_date;

-- Q4. Retrieve all transactions that happened in August
SELECT * FROM vendas_retail 
WHERE TO_CHAR(sale_date, 'MM') = '08'
ORDER BY EXTRACT(YEAR FROM sale_date), EXTRACT(DAY FROM sale_date);

-- Q5. Find all transactions where the total sale is greater than 1000.
SELECT * FROM vendas_retail
WHERE total_sale>1000;

-- Q6. Count all transactions where the total sale is greater than 1000 and group them by their category
SELECT category, COUNT (*) AS total_sales FROM vendas_retail
WHERE total_sale>1000
GROUP BY category
UNION ALL
SELECT 'Total', COUNT(*)
FROM vendas_retail
WHERE total_sale>1000;

-- Q7. Now add a percentage to the total sales from each category
SELECT category, COUNT(*) AS total_sales, 
	CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM vendas_retail WHERE total_sale > 1000) AS DECIMAL(5,2)) AS percentage
FROM vendas_retail
WHERE total_sale > 1000
GROUP BY category
UNION ALL
SELECT 'Total',
       COUNT(*), 100
FROM vendas_retail
WHERE total_sale > 1000;


-- Q8. What's the total number of transactions made by each gender in each category?
SELECT category, gender, COUNT (*) AS total_transactions
FROM vendas_retail
GROUP BY category, gender
ORDER BY category;

-- Q9. Adding a percentage to the total transactions for each category and gender:
SELECT category, gender, COUNT (*) AS total_transactions, 
	CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM vendas_retail) AS DECIMAL(5,2)) AS percentage
FROM vendas_retail
GROUP BY category, gender
ORDER BY category;

-- Q10. Calculate the average sales for each month and find the best month of each year
SELECT year, month, ROUND(avg_sale, 3) AS avg_sale
FROM (
	SELECT
		EXTRACT(MONTH FROM sale_date) AS month,
		EXTRACT(YEAR FROM sale_date) AS year,
		AVG(total_sale) AS avg_sale,
		RANK() OVER (
			PARTITION BY EXTRACT(YEAR FROM sale_date)
			ORDER BY AVG(total_sale) DESC
		) AS rank
	FROM vendas_retail
	GROUP BY EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date)
) AS ranked_months
WHERE rank = 1;