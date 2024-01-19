select * from pizza_sales;

-- A.KPI's

-- 1. Totoal Revenue
select sum(total_price) as Total_revenue from pizza_sales;

-- 2.Average Order Value
select sum(total_price)/count(distinct order_id) as Average_Order_Value from pizza_sales;

-- 3.Total Pizza Sold
select sum(quantity) as Total_pizza_sold from pizza_sales;

-- Total Orders
select count(distinct order_id) as Total_orders from pizza_sales;

-- Average Pizzas Per Order
select sum(quantity)/count(distinct order_id) as Average_pizzas_per_order from pizza_sales;

-- B. Hourly Trend for Total Pizzas Sold
select hour(order_time) as order_hour, sum(quantity) 
from pizza_sales
group by order_hour
order by order_hour;

-- C. Month Trends for Orders
SELECT 
  YEAR(STR_TO_DATE(order_date, '%m-%d-%Y')) AS order_year,
  MONTH(STR_TO_DATE(order_date, '%m-%d-%Y')) AS order_month,
  SUM(quantity) AS total_quantity
FROM 
  pizza_sales
WHERE 
  order_date IS NOT NULL AND STR_TO_DATE(order_date, '%m-%d-%Y') IS NOT NULL
GROUP BY 
  order_year, 
  order_month
ORDER BY 
  order_year, 
  order_month;
  
-- C2. Weekly Trends for Orders
select year(str_to_date(order_date, '%m-%d-%Y')) as order_year, week(str_to_date(order_date, '%m-%d-%y'),1) as order_week,sum(quantity)
FROM 
  pizza_sales
WHERE 
  order_date IS NOT NULL AND STR_TO_DATE(order_date, '%m-%d-%Y') IS NOT NULL
GROUP BY 
  order_year, 
  order_week
ORDER BY 
  order_year, 
  order_week;
  
-- D. % of Sales by Pizza Category
select pizza_category, sum(total_price) as category_revenue,
  (SUM(total_price) / (SELECT SUM(total_price) FROM pizza_sales)) * 100 AS revenue_percentage
from pizza_sales
group by pizza_category;

  
-- E. % of Sales by Pizza Size
select pizza_size, sum(total_price) as category_revenue,(SUM(total_price) / (SELECT SUM(total_price) FROM pizza_sales)) * 100 AS revenue_percentage
from pizza_sales
group by pizza_size;

-- F. Total Pizzas Sold by Pizza Category
select pizza_category, sum(quantity)
from pizza_sales
group by pizza_category;


-- G. Top 5 Pizzas by Revenue
select pizza_name_id, sum(total_price) as Pizza_revenue
from pizza_sales
group by pizza_name_id
order by Pizza_revenue desc
limit 5;

-- H. Bottom 5 Pizzas by Revenue
select pizza_name_id, sum(total_price) as Pizza_revenue
from pizza_sales
group by pizza_name_id
order by Pizza_revenue asc
limit 5;


-- I. Top 5 Pizzas by Quantity
select pizza_name_id, sum(quantity) as Pizza_quantity
from pizza_sales
group by pizza_name_id
order by  Pizza_quantity desc
limit 5;

-- J. Bottom 5 Pizzas by Quantity
select pizza_name_id, sum(quantity) as Pizza_quantity
from pizza_sales
group by pizza_name_id
order by  Pizza_quantity asc
limit 5;

-- K. Top 5 Pizzas by Total Orders
select pizza_name_id, sum(distinct order_id) as total_orders
from pizza_sales
group by pizza_name_id
order by  total_orders desc
limit 5;


-- L. Borrom 5 Pizzas by Total Orders
select pizza_name_id, sum(distinct order_id) as total_orders
from pizza_sales
group by pizza_name_id
order by  total_orders asc
limit 5;



  


        








