---Analyze Sales performance Over Time ...

Select 
Year (order_date) as order_year, 
MONTH(order_date) as order_month,
Sum(sales_amount) as total_sales,
count(distinct customer_key) as Total_cumstomers,
sum(quantity) as Total_quantity
From gold.fact_sales
where order_date is not null
group by Year(order_date) , month(order_date)
order by Year(order_date) , MONTH(order_date)




Select 
DATETRUNC(month , order_date) as Order_date , 
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers, 
sum(quantity) as total_quantity 
from gold.fact_sales
where order_date is not null
group by DATETRUNC(month , order_date)
order by DATETRUNC(month , order_date)