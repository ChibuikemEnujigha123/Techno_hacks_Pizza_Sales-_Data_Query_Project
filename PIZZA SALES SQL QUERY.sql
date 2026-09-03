create database pizzahut;

-- creating table "orders" as it has large number of records 
 CREATE TABLE Orders
(
 order_id int NOT NULL,
 order_date date NOT NULL,
 order_time time NOT NULL,
 PRIMARY KEY(order_id)
 );
 -- Inserting the table orders to now make it functional
BULK INSERT Orders
FROM "C:\Users\HP\Downloads\PIZZA_SALES_SQL_DATAANALYSIS_PROJECT-main\PIZZA_SALES_SQL_DATAANALYSIS_PROJECT-main\orders.csv"  -- <-- change to .csv
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\r\n',
    FIRSTROW = 2,
    CODEPAGE = '65001'
);

-- creating table "order_details" as it has large number of records 
 
CREATE TABLE ORDER_DETAILS
(
 order_details_id int NOT NULL,
 order_id int NOT NULL,
 pizza_id text NOT NULL,
 quantity int NOT NULL,
 PRIMARY KEY(order_details_id)
 );

TRUNCATE TABLE ORDER_DETAILS;

BULK INSERT ORDER_DETAILS
FROM "C:\Users\HP\Downloads\PIZZA_SALES_SQL_DATAANALYSIS_PROJECT-main\PIZZA_SALES_SQL_DATAANALYSIS_PROJECT-main\order_details.csv"
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',   -- Unix line endings (works for your file)
    FIRSTROW = 2,
    CODEPAGE = '65001'
);

 SELECT TOP 1 * FROM ORDER_DETAILS; -- If it partially loaded, or use a staging table with VARCHAR(MAX) for all columns to inspect.
 

CREATE TABLE PIZZAS
(
    pizza_id varchar(50) NOT NULL,
    pizza_type_id varchar(50) NOT NULL,
    size varchar(5) NOT NULL,
    price decimal(10,2) NOT NULL,
    PRIMARY KEY (pizza_id)
);

BULK INSERT PIZZAS
FROM "C:\Users\HP\Downloads\PIZZA_SALES_SQL_DATAANALYSIS_PROJECT-main\PIZZA_SALES_SQL_DATAANALYSIS_PROJECT-main\pizzas.csv"
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',   -- Unix line endings (works for your file)
    FIRSTROW = 2,
    CODEPAGE = '65001'
);
-- Create the table for pizza typew which will be in ther qu
CREATE TABLE PIZZA_TYPES
(
    pizza_type_id varchar(50) NOT NULL,
    name varchar(100) NOT NULL,
    category varchar(50) NOT NULL,
    ingredients varchar(max) NOT NULL,
    PRIMARY KEY (pizza_type_id)
);

-- 3. Truncate (just in case)
TRUNCATE TABLE PIZZA_TYPES;

-- Bulk Insert pizza types to ensure pizza types is ready for querying section
BULK INSERT PIZZA_TYPES
FROM  "C:\Users\HP\Downloads\PIZZA_SALES_SQL_DATAANALYSIS_PROJECT-main\PIZZA_SALES_SQL_DATAANALYSIS_PROJECT-main\pizza_types.csv"
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    FIRSTROW = 2,
    CODEPAGE = '1252',   -- <-- Changed from 65001
    FORMAT = 'CSV'
);

 -- QUERIES 
 -- Q-1)Retrieve the total number of orders placed.
 SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
  SELECT COUNT(*) AS total_orders FROM orders;

	-- Q-2)Calculate the total revenue generated from pizza sales.
	-- Fix the table so future joins work without casting
ALTER TABLE ORDER_DETAILS ALTER COLUMN pizza_id varchar(50) NOT NULL;
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;

	 -- Q-3)Identify the highest-priced pizza.
  SELECT TOP 1
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC

	-- Q-4)Identify the most common pizza size ordered.
SELECT TOP 1
    p.size, 
    COUNT(od.order_details_id) AS orders
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY orders DESC;

-- Q-5) List the top 5 most ordered pizza types along with their quantities.(multiple joins)
SELECT TOP 5
    pt.name, 
    SUM(od.quantity) AS quantity
FROM
    pizza_types pt
    JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC;

-- Q-6) Join the necessary table to find the total quantity of each pizza category ordered
SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;


--Q7) Determine the distribution of orders by hour of he day
 SELECT 
    DATEPART(hour, order_time) AS Hours, 
    COUNT(order_id) AS order_count
FROM orders
GROUP BY Hours

SELECT 
    DATEPART(hour, order_time) AS Hours, 
    COUNT(order_id) AS order_count
FROM orders
GROUP BY DATEPART(hour, order_time); 

 
--Q8) How much pizzas are there for each category.
SELECT
category, COUNT(name ) as pizzas
FROM
PIZZA_TYPES
Group by category



-- Q9) Determine the top 3 most ordered pizza based on revenue 
SELECT TOP 3
    pt.name, SUM((od.quantity * p.price)) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC;

--Q10) Calculate the percentage contribution of each pizza_type to total revenueSELECT 
    WITH TotalRevenue AS (
    SELECT SUM(od2.quantity * p2.price) * 1.0 AS total
    FROM order_details od2
    JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id
)
SELECT 
    pt.category,
    ROUND((SUM(od.quantity * p.price) / (SELECT total FROM TotalRevenue)) * 100, 2) AS revenue_percent
FROM
    pizza_types pt
    JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY revenue_percent DESC;

--Q11.) Deteremine the top 3 most ordered type based on revenue for each pizza category
     select category,name,total_revenue from
(select category ,name,total_revenue,
rank() over(partition by category order by total_revenue desc )as ran from 
(SELECT 
    pt.category,pt.name, SUM((od.quantity * p.price)) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category,pt.name) as A) as B where ran<=3;
