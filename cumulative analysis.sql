--Cumulative Analysis 
---Calculate the total sales per month
-- and the running total of sales ober time 


select 
order_date,
total_sales,
sum(total_sales) over(order by order_date) as running_total_sales
from
(
select
DATETRUNC(month , order_date ) as order_date ,
sum(sales_amount) as total_sales 
from gold.fact_sales
where order_date is not null
group by DATETRUNC(month , order_date)
)c









--partion the data for each year so that every new year

select 
order_date,
total_sales,
sum(total_sales) over(partition by order_date order by order_date) as running_total_sales
from
(
select
DATETRUNC(month , order_date ) as order_date ,
sum(sales_amount) as total_sales 
from gold.fact_sales
where order_date is not null
group by DATETRUNC(month , order_date)
)c


--by years not by months 
select 
order_date,
total_sales,
sum(total_sales) over(order by order_date) as running_total_sales
from
(
select
DATETRUNC(YEAR , order_date ) as order_date ,
sum(sales_amount) as total_sales 
from gold.fact_sales
where order_date is not null
group by DATETRUNC(YEAR , order_date)
)c



--now we can do moving average insted running total 
select 
order_date,
total_sales,
sum(total_sales) over(order by order_date) as running_total_sales,
avg (total_sales) over(order by order_date) as moving_average_price

from
(
select
DATETRUNC(year , order_date ) as order_date ,
sum(sales_amount) as total_sales ,
avg(price) as avg_price
from gold.fact_sales
where order_date is not null
group by DATETRUNC(year , order_date)
)c