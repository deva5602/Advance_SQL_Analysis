/*
------------------------------------------------------------------------------------------------------------------------------------------------------------
Customer report
============================================================================================================================================================
purpose : this report consolidates key customer metrics and behaviours 

highlights:
		1. gathers essential fields such as names, ages and transaction details. 
		2. segments customers into categories (vip ,regular ,  new ) and age grp.
		3. aggregate customer- level metrices:
			-total order
			-total sales
			-total quamtity purchased 
			-total products 
			-lifespan (in months)
		4. calculate valuable kpi's 
			-recency (months since last order)
			-average order value
			-average monthly spend
============================================================================================================================================================
*/

--1) base query = retrieves core columns from tables 

Create view gold.report_customers as 
with base_query as(
	select 
	f.order_number,
	f.product_key,
	f.order_date,
	f.sales_amount,
	f.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name , ' ' , c.last_name) as customer_name,
	DATEDIFF(year , c.birthdate , getdate()) as age 
	from gold.fact_sales f
	left join gold.dim_customers c
	on c.customer_key = f.customer_key
	where order_date is not null
)

, Customer_aggregation as(
--2) customer aggregation= summarize key metrics at the customer level 
	select 
		customer_key,
		customer_number,
		customer_name,
		age ,
		count(distinct order_number) as total_order, 
		sum(sales_amount) as total_sales,
		sum(quantity ) as total_quantity,
		count(distinct product_key) as total_products,
		max(order_date) as last_order_date,
		DATEDIFF(month , min(order_date) , max(order_date)) as lifespan
	from base_query
	group by 
		customer_key,
		customer_number,
		customer_name,
		age
)
select 
customer_key,
customer_number,
customer_name,
age,
Case 
	 when age<20 then 'under20'
	 when age between 20 and 29 then '20 to 29'
	 when age between 30 and 39 then  '30 to 39'
	 when age between 40 and 49 then '40 to 49'
	 else '50 and above'
end age_group,

case 
	 when lifespan>12 and total_sales >5000 then 'VIP' 
	 when lifespan >= 12 and total_sales <=5000 then 'Regular'
	 else 'new'
end customer_segment,
last_order_date,
DATEDIFF(month , last_order_date, getdate()) as recency,
total_order, 
total_sales,
total_quantity,
total_products,
lifespan,
--compute avg order value = total sales/ total no of orders
case when total_sales = 0 then 0  --coz if a person have zero sales it will sho error
	 else total_sales / total_order
end as avg_order_value ,

--compute avg monthly spend = total sales / no of months 
case when lifespan = 0 then total_sales 
	 else total_sales / lifespan
end as avg_monthly_spend
from Customer_aggregation

