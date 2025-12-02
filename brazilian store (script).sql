CREATE DATABASE brazilianstr;
USE brazilianstr;

-- number of customers in each city and state


SELECT customer_city, customer_state, COUNT(customer_id)
FROM brazilianstr.olist_customers_dataset
GROUP BY customer_city, customer_state
ORDER BY 3 DESC;

-- number of total orders

SELECT COUNT(*)
FROM brazilianstr.olist_orders_dataset;

-- number of total orders each day


SELECT CAST(order_purchase_timestamp AS DATE) AS DATE, COUNT(*) AS 'COUNT OF ORDERS'
FROM brazilianstr.olist_orders_dataset
GROUP BY CAST(order_purchase_timestamp AS DATE)
ORDER BY 1 ASC;

-- Most popular categories 

SELECT T.product_category_name_english, COUNT(*) AS TOTAL_ORDERS_PER
FROM brazilianstr.olist_products_dataset P
INNER JOIN brazilianstr.olist_order_items_dataset I 
ON P.product_id = I.product_id
INNER JOIN brazilianstr.product_category_name_translation T 
ON P.product_category_name = T.product_category_name
GROUP BY T.product_category_name_english
ORDER BY 2 DESC;


-- differences between estimated and accomplished delivery timelines in days/hours per year/month

SELECT 
YEAR(order_purchase_timestamp) AS purchase_year,
MONTH(order_purchase_timestamp) AS purchase_month,
AVG(DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)) AS avg_diff_in_days,
AVG(TIMESTAMPDIFF(HOUR, order_estimated_delivery_date, order_delivered_customer_date)) AS avg_diff_in_hours
FROM brazilianstr.olist_orders_dataset
WHERE order_status = 'delivered' AND order_delivered_customer_date !=''
GROUP BY purchase_year, purchase_month
ORDER BY YEAR(order_purchase_timestamp),MONTH(order_purchase_timestamp) ;

-- per delivery timeline of differences in planned and accomplished delivery dates as well as average differences in days/hours per month

SELECT 
order_id,
order_status,
order_delivered_customer_date,
order_estimated_delivery_date,
YEAR(order_purchase_timestamp) AS purchase_year,
MONTH(order_purchase_timestamp) AS purchase_month,
DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) AS diff_in_days,
TIMESTAMPDIFF(HOUR, order_estimated_delivery_date, order_delivered_customer_date) AS diff_in_hours,
AVG(DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date))
OVER(PARTITION BY YEAR(order_purchase_timestamp),MONTH(order_purchase_timestamp)) as avg_month_diff_days,
AVG(TIMESTAMPDIFF(HOUR, order_estimated_delivery_date, order_delivered_customer_date))
OVER(PARTITION BY YEAR(order_purchase_timestamp),MONTH(order_purchase_timestamp)) as avg_month_diff_hours
FROM brazilianstr.olist_orders_dataset
WHERE order_status = 'delivered' AND order_delivered_customer_date !=''
ORDER BY YEAR(order_purchase_timestamp),MONTH(order_purchase_timestamp);

-- per delivery timeline of differences in planned and accomplished delivery dates as well as average differences in days/hours per month
-- plus differences between average delays (days/hour) per delivery


WITH T1 AS (
SELECT 
order_id,
order_status,
order_delivered_customer_date,
order_estimated_delivery_date,
YEAR(order_purchase_timestamp) AS purchase_year,
MONTH(order_purchase_timestamp) AS purchase_month,
DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) AS diff_in_days,
TIMESTAMPDIFF(HOUR, order_estimated_delivery_date, order_delivered_customer_date) AS diff_in_hours,
AVG(DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date))
OVER(PARTITION BY YEAR(order_purchase_timestamp),MONTH(order_purchase_timestamp)) as avg_month_diff_days,
AVG(TIMESTAMPDIFF(HOUR, order_estimated_delivery_date, order_delivered_customer_date))
OVER(PARTITION BY YEAR(order_purchase_timestamp),MONTH(order_purchase_timestamp)) as avg_month_diff_hours
FROM brazilianstr.olist_orders_dataset
WHERE order_status = 'delivered' AND order_delivered_customer_date !=''
ORDER BY YEAR(order_purchase_timestamp),MONTH(order_purchase_timestamp))
SELECT 
order_id,
order_status,
order_delivered_customer_date,
order_estimated_delivery_date,
purchase_year,
purchase_month,
diff_in_days - avg_month_diff_days AS difference_from_month_avg_days,
diff_in_hours - avg_month_diff_hours AS difference_from_month_avg_hours
FROM T1;
