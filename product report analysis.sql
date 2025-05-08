/*
========================================================================================================================================
product report 
========================================================================================================================================
purpose= 
		this report consolidates key product metrics and behaviors.

highlights:
	1. gather essential fields such as product name , category , subcategory  and cost.
	2. segments products by revenue to udentify high-performers , mid-range , or low-performers.
	3.aggregates product-level metrics:
		-total order
		-total sales 
		-total quantity sold
		-total customers (unique)
		-lifespan (in months)

	4. calculate valuable kpi's:
		-recency (months since last sales)
		-average order revene
		-average monthly revenue

===========================================================================================================================================

--1) base query = retrieves core coumns from fact_sales and dim_products*/

create view gold.product_report  as
with base_query as(
select 
	f.order_number,
	f.order_date,
	f.customer_key,
	f.quantity,
	f.sales_amount,
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost
	from gold.fact_sales f
	left join gold.dim_products p 
	on f.product_key = p.product_key
	where order_date is not null
),

--2)= product Aggregation : summarizes key metrics at the product level
product_aggregation as (
	select
		product_key ,
		product_name,
		category,
		subcategory, 
		cost,
		datediff (month , min(order_date) , max(order_date)) as lifespan,
		max(order_date) as last_sales_date,
		count(distinct order_number) as total_order,
		count(distinct customer_key) as total_customers,
		sum(sales_amount) as total_sales, 
		sum(quantity) as total_quantity,
		round(avg(cast(sales_amount as float) / nullif(quantity , 0 )), 1) as avg_selling_price
	from base_query

	group by
	product_key, 
	product_name, 
	category,
	subcategory, 
	cost
)

--3) final Quert= combine all products results into one output

select 
	product_key, 
	product_name, 
	category,
	subcategory, 
	cost,
	last_sales_date,
	DATEDIFF(month, last_sales_date, getdate())as recency_in_months,
	case
		when total_sales >50000 then 'hing performance'
		when total_sales >= 10000 then 'mid-range'
		else 'low performance'
	end as product_segment,
	lifespan,
	total_order,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	--average order revenue
	case 
		when total_order = 0 then 0
		else total_sales / total_order
	end as avg_order_revenue,

	--average monthly revenue
	case
		when lifespan = 0 then total_sales
		else total_sales / lifespan
	end as avg_monthly_revenue

from product_aggregation