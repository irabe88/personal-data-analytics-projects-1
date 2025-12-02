USE restaurant_db;

-- overview

SELECT * FROM menu_items;
SELECT * FROM order_details;

-- menu item quantity 

SELECT COUNT(*) FROM menu_items;

-- list and most expensive items. ranking

SELECT item_name, price
FROM menu_items
ORDER BY price ASC;

SELECT item_name, price
FROM menu_items
ORDER BY price DESC;

SELECT item_name, price, DENSE_RANK() OVER(ORDER BY price Desc) AS price_rank
FROM menu_items
ORDER BY price desc;
 
 -- how many italian dishes are on the menu?
 
 SELECT COUNT(*)
 FROM menu_items 
 WHERE category ='Italian';
 
 -- italian dishes ranked by prices
 
 SELECT item_name, price, DENSE_RANK() OVER(ORDER BY price DESC) AS price_rank
FROM menu_items
WHERE category ='Italian'
ORDER BY price DESC;

-- dishes per category

SELECT category, COUNT(menu_item_id) as num_dishes
FROM menu_items
GROUP BY category;

-- average dish price per category

SELECT category, ROUND(AVG(price),2) as avg_price
FROM menu_items
GROUP BY category;

-- date range of dataset

SELECT MIN(order_date), MAX(order_date)
FROM order_details;

-- total number of orders

SELECT COUNT(DISTINCT order_id)
FROM order_details;

-- how many items where ordered in total?

SELECT COUNT(*) 
FROM order_details;

-- which orders had most items?


SELECT order_id, COUNT(item_id) as number_of_items
FROM order_details
GROUP BY order_id
ORDER BY 2 DESC;

-- How many orders had more then 5 but less then 10 items?

SELECT COUNT(*)
FROM (
SELECT order_id, COUNT(item_id) as number_of_items
FROM order_details
GROUP BY order_id
HAVING number_of_items BETWEEN 5 AND 10
ORDER BY 2 DESC) AS num_orders ;

-- combine the tables and create temp table out of it


SELECT *
FROM order_details od
LEFT JOIN  menu_items mi
ON od.item_id = mi.menu_item_id;

CREATE TEMPORARY TABLE joinedtable
(
order_details_id int,
order_id int,
order_date date,
order_time time,
item_id int,
menu_item_id int,
item_name varchar(255),
category varchar(255),
price float)

SELECT *
FROM order_details od
LEFT JOIN  menu_items mi
ON od.item_id = mi.menu_item_id;

select * from joinedtable;

-- list and most ordered items/categories

SELECT item_name, category, COUNT(order_details_id) AS num_purchases
FROM order_details od
LEFT JOIN  menu_items mi
ON od.item_id = mi.menu_item_id
GROUP BY item_id, category
ORDER BY num_purchases DESC; -- ASC

-- top 5 orders by money spent

with t1 as (
SELECT order_id, SUM(price) AS total_spent, dense_rank() OVER ( ORDER BY SUM(price) DESC) as rnk
FROM order_details od
LEFT JOIN  menu_items mi
ON od.item_id = mi.menu_item_id
GROUP BY order_id
ORDER BY total_spent desc)
SELECT *
FROM t1
where rnk <=5;

-- create a view of top 5 spenders' preferences

CREATE VIEW Top5s_preferences as
SELECT order_id, category, COUNT(item_id) AS num_item
FROM order_details od
LEFT JOIN  menu_items mi
ON od.item_id = mi.menu_item_id
WHERE order_id in ( 440,2075,1957, 330, 2675)
GROUP BY order_id, category
ORDER BY num_item DESC