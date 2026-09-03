# Techno_hacks_Pizza_Sales-_Data_Query_Projects

#  PIZZA SALES SQL DATA PROJECT 

#  Section A: Project Overview

This project performs a comprehensive data analysis and visualization of  sales  that occurred in the Electrosoft Pizzeria. The analysis explores the company across sales, orders  ,sizes amongst other factors in the situation

# Section B:  Dataset Description

The datasets involved in the analysis were Pizzas.csv, pizza_types.csv, orders.csv, order_details.csv
The columns involved were :
A. pizzas
I .pizza_id
ii. pizza_type
iii. size
iv .price

B. Pizza_types
V.name
VI. Category
VII. Ingredients

C. Orders
VIII. Order_id
IX. date
X .time

D. Order_details
XI. order_details_id
XII. order_id
XIII. pizza_id
XIV. quantity

# Section C : Methodology
DATA CLEANING
The data cleaning has basically been done before the project was done so the data goes straight to SQL for querying.


# Section D : QUERYING WITH SQL

# 1.Total Number of Orders Placed

  SELECT COUNT(*) AS total_orders FROM orders;

# 2. TOTAL REVENUE GENERATED FROM PIZZA SALES 

SELECT   ROUND(SUM(od.quantity * p.price), 2) AS total_revenue

FROM order_details od

JOIN  pizzas p ON od.pizza_id = p.pizza_id;

# 3.IDENTIFY THE HIGHEST PRICED PIZZA

 SELECT TOP 1  pt.name, p.price FROM pizza_types pt
 
 JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
 
ORDER BY p.price DESC

#4. Identify the most common pizza size ordered

SELECT TOP 1  p.size,   COUNT(od.order_details_id) AS order 

FROM pizzas p

 JOIN order_details od ON p.pizza_id = od.pizza_id
 
GROUP BY p.size

ORDER BY orders DESC;

#5 .List the top 5 most ordered pizza types along with their quantities.(multiple joins)

SELECT TOP 5 pt.name, SUM(od.quantity) AS quantity

FROM pizza_types pt

 JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
 
 JOIN order_details od ON p.pizza_id = od.pizza_id
 
GROUP BY pt. name

ORDER BY quantity DESC;

#6.TOTAL QUANTITY OF EACH CATEGORY EXPLAINED

SELECT   pt.category, SUM(od.quantity) AS total_quantity

FROM order_details od

JOIN pizzas p ON od.pizza_id = p.pizza_id

 JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
 
GROUP BY pt.category

ORDER BY total_quantity DESC;

#7.DETERMINE THE DISTRIBUTION OF ORDERS BY HOUR OF THE DAY

SELECT  DATEPART(hour, order_time) AS Hours, COUNT(order_id) AS order_count

FROM orders

GROUP BY Hours

SELECT   DATEPART(hour, order_time) AS Hours, COUNT(order_id) AS order_count

FROM orders

GROUP BY DATEPART(hour, order_time); 

#8.HOW MUCH PIZZAS ARE THERE FOR EACH CATEGORY?

SELECT category, COUNT(name ) as pizzas

FROM PIZZA_TYPES

Group by category

#9.DETERMINE THE TOP 3 MOST ORDERED PIZZA BASED ON REVENUE

SELECT TOP 3 pt.name, SUM((od.quantity * p.price)) AS total_revenue

FROM  order_details od

JOIN  pizzas p ON od.pizza_id = p.pizza__

JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id

GROUP BY pt.name

ORDER BY total_revenue DESC;

#10.DETERMINE THREE MOST ORDERED TYPE BASED ON REVENUE FOR EACH CATEGORY.

select category, name ,total_revenue from

(select category ,name, total_revenue,

rank() over(partition by category order by total_revenue desc )as ran from 

(SELECT   pt.category, pt.name, SUM((od.quantity * p.price)) AS total_revenue

FROM order_details od

        JOIN pizzas p ON od.pizza_id = p.pizza_id
        
        JOIN  pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
        
GROUP BY pt.category, pt.name) as A) as B where ran<=3;



#SECTION E: PROJECT INSIGHTS

# 1.  The Greek Pizza is the highest-priced pizza

# 2.  Classic, Supreme, Veggie, Chicken are the pizza categories in ascending order of quantity

#3.The Thai Chicken, The Barbeque Chicken and The California Chicken are the three most ordered pizza types at Electrosoft pizzeria .

#4.The total revenue made by the pizzeria in this time period is approximately 817860

