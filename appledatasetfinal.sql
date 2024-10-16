- Apple project-- 1M rows sales datasets

SELECT * FROM category;
SELECT * FROM products;
SELECT * FROM sales;
SELECT * FROM warranty;
SELECT * FROM stores;

 -- Simple analysis
 
 Select distinct repair_status -- checking different kind of repair status
 from warranty;
 select count(*)
 from sales; -- the are 1M data in sales table

Select *
from sales;

-- Improving Query Performance

Explain analyze
Select *
from sales where product_id = 'P-44'
-- Execution time: 66.241
-- Planning time: 0.125
-- Execution time after index: 5.833ms
-- Planning time: 0.099ms
Create INDEX sales_product_id ON sales(product_id);

Explain analyze
Select *
from sales where store_id = 'ST-31'

-- Execution time: 60.549ms
-- Planning time: 0.232ms
-- Execution time after index: 7.851
-- Planning time: 0.563

Create INDEX sales_store_id on sales(store_id);
CREATE INDEX sales_sale_date on sales(sale_date);

-- Business Problems
--1. Find the number of stores in each country.
SELECT country, count(store_id) as total_stores
from stores
group by country
order by total_stores DESC;

--2. Calculate the total number of units sold by each store.
Select
st.store_id,
st.store_name,
sum(quantity)
from sales as s
join stores as st
on st.store_id = s.store_id
group by st.store_id, st.store_name;

--3. Identify how many sales occur in december 2023
SELECT
COUNT(sale_id) as total_sale
FROM sales
where  TO_CHAR(sale_date,'MM-YYYY') = '12-2023'

--4. Determine how many stores have never had a warranty claim filed.
SELECT COUNT(*)FROM stores
WHERE store_id NOT IN
(SELECT 
 distinct store_id
FROM sales as s
RIGHT JOIN warranty as w
on s.sale_id = w.sale_id);

--5. Calculate the percentage of warranty claims marked as 'Warranty void'
SELECT count(claim_id) / (SELECT count(*) FROM warranty) :: numeric 
*100 as warranty_void_percentage
FROM warranty
where repair_status = 'Warranty Void'

--6. Identify which store had the highest total units sold in the last year.

SELECT s.store_id, 
SUM(s.quantity), st.store_name
FROM sales as s
join stores as st
on st.store_id = s.store_id
WHERE sale_date >= (CURRENT_DATE - INTERVAL '1 year')
group by s.store_id, st.store_name
order by SUM(quantity) desc

--7. Count the number of unique products sold in the last year
Select count(distinct product_id)
FROM sales
WHERE sale_date >= (CURRENT_DATE - INTERVAL '1 year')

--8. Find the average price of products in each categoey
select ct.category_name, avg(p.price), p.category_id 
from category as ct
join products as p
on ct.category_id = p.category_id
group by ct.category_name,p.category_id;

--9. How many warranty claims were filed in 2020?
select
    COUNT(*) AS warranty_claim
from warranty
WHERE EXTRACT(YEAR FROM claim_date) = 2020

-- 10. For each store, identify the best-selling day based on highest quantity sold.
SELECT *
FROM
( SELECT
  store_id,
  TO_CHAR(sale_date,'DAY') as day_name,
  sum(quantity) as total_unit_sold,
  RANK() OVER(PARTITION BY store_id ORDER BY SUM(quantity)DESC) as rank
  FROM sales
  GROUP BY store_id,TO_CHAR(sale_date,'DAY')
 )as t1
 WHERE RANK=1

 -- Medium to Hard 
 -- 11 Identify the least selling product in each country for each year based on total units sold.
WITH product_rank
as
(Select 
 st.country,
 p.product_name,
 SUM(s.quantity) as total_qty_sold,
 RANK()OVER(PARTITION BY st.country ORDER BY SUM(s.quantity)) as rank
 FROM sales as s
 JOIN
 stores as st
 ON s.store_id = st.store_id
 JOIN 
 products as p 
 ON s.product_id = p.product_id
 group by st.country, p.product_name
 )
 Select *
 FROM product_rank
 WHERE rank = 1
 
 -- 12 Calculate how many warranty claims were filled within 180 days of a product sale

 SELECT count(*)
 FROM warranty as w
 LEFT JOIN sales as s
 on s.sale_id = w.sale_id
 WHERE w.claim_date - s.sale_date <= 180

 --13 Determine how many warranty claims were filed for products launched in the last two years.
SELECT
p.product_name,
COUNT(w.claim_id) as no_claim,
COUNT(s.sale_id)
FROM warranty as w
RIGHT JOIN
sales as s
on s.sale_id = w.sale_id
JOIN products as p
on p.product_id = s.product_id
WHERE p.launch_date >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY p.product_name

--14 List the months in the last three years where sales exceded 5000 units in the USA
SELECT 
SUM(s.quantity) as total_unit_sold,
TO_CHAR(sale_date,'MM-YYYY')
FROM sales as s
join stores as st
on s.store_id = st.store_id
WHERE st.country = 'USA'
AND s.sale_date >= CURRENT_DATE - INTERVAL '3 year'
group by 2
HAVING SUM(s.quantity)>5000

--15 Identify the product category with the most warranty claims filed in the last two years.
SELECT 
c.category_name,
COUNT(w.claim_id) as total_claims
FROM warranty as w
LEFT JOIN
sales as s
ON w.sale_id = s.sale_id
JOIN products as p
ON p.product_id = s.product_id
JOIN
category as c
ON c.category_id = p.category_id
WHERE w.claim_date >= CURRENT_DATE - INTERVAL '2 year'
GROUP BY 1

-- super complex
-- 16 Determine the percentage chance of receiving warranty claims after each purcahse for each country.
SELECT
 country,
 total_unit_sold,
 total_claim,
COALESCE(total_claim::numeric/total_unit_sold::numeric*100,0) AS risk
 FROM
(SELECT 
st.country,
SUM(s.quantity) as total_unit_sold,
COUNT(w.claim_id) as total_claim
FROM sales as s
JOIN stores as st
on s.store_id = st.store_id
LEFT JOIN
warranty as w
ON w.sale_id = s.sale_id
GROUP BY st.country) as t1
ORDER BY risk DESC

-- 17. Analyze the year by year growth ratio for each stores

-- each store and their yearly sale
WITH yearly_sales
AS
(
SELECT
s.store_id,
st.store_name,
EXTRACT(YEAR FROM sale_date) as year,
SUM(s.quantity * p.price) as total_sale 
FROM sales as s 
JOIN products as p 
ON s.product_id = p.product_id
JOIN stores as st
ON st.store_id = s.store_id
GROUP BY s.store_id,EXTRACT(YEAR FROM sale_date),st.store_name
ORDER BY st.store_name,EXTRACT(YEAR FROM sale_date)
),
growth_ratio
as
(SELECT 
store_name,
year,
LAG(total_sale,1) OVER(PARTITION BY store_name ORDER BY year) as last_year_sale,
total_sale as current_year_sale
FROM yearly_sales)
SELECT 
store_name,
year,
last_year_sale,
current_year_sale,
ROUND(
(current_year_sale - last_year_sale)::numeric/last_year_sale::numeric * 100
,3) AS GROW_RATIO FROM growth_ratio
WHERE 
     last_year_sale IS NOT NULL
	 AND
	 YEAR <> EXTRACT(YEAR FROM CURRENT_DATE)

-- 18 Calculate the coorelation betweeen product price and 
--warraty claims for products sold in the last five years,segmented by price range

SELECT 
	 CASE
	     WHEN p.price < 500 THEN 'Less Expenses Product'
		 WHEN p.price BETWEEN 500 AND 1000 THEN 'Mid Range Product'
		 ELSE 'Expensive Product'
	 END as price_segment,
	 COUNT(w.claim_id) as total_Claim
FROM warranty as w
LEFT JOIN
sales as s
ON w.sale_id = s.sale_id
JOIN
products as p
ON p.product_id = s.product_id
WHERE claim_date>= CURRENT_DATE - INTERVAL'5 YEAR'
GROUP BY 1

-- 19 Identify the store with the highest percentage of
-- 'Paid Repaired' claims relative to total claims filed.
WITH paid_repair AS (
    SELECT 
        s.store_id,
        COUNT(w.claim_id) AS paid_repaired
    FROM sales AS s
    RIGHT JOIN warranty AS w
        ON w.sale_id = s.sale_id
    WHERE w.repair_status = 'Paid Repaired'
    GROUP BY s.store_id
),
total_repaired AS (
    SELECT 
        s.store_id,
        COUNT(w.claim_id) AS total_repaired 
    FROM sales AS s
    RIGHT JOIN warranty AS w
        ON w.sale_id = s.sale_id
    GROUP BY s.store_id
)
SELECT
    st.store_name,
    tr.store_id,
    pr.paid_repaired,
    tr.total_repaired,
    ROUND((pr.paid_repaired::numeric / tr.total_repaired::numeric) * 100, 2) AS percentage_paid_repaired
FROM paid_repair AS pr
JOIN total_repaired AS tr
    ON pr.store_id = tr.store_id
JOIN stores AS st
    ON tr.store_id = st.store_id;
