--data segmentation 
--group the data based on a specific range. helps understand the correlation between two measures.
--formula [measure ] by [measure] example total product by sales range or total custimers by age 
--task
-- segment products into cost ranges and count how many products fall into each segment 
with product_segment as (
select 
product_key, 
product_name,
cost,
Case when cost<100 then 'Below 100'
	 when cost between 100 and 500 then '100 - 500'
	 when cost between 500 and 1000 then '500 - 1000'
	 else 'above 1000'
end cost_range 
from gold.dim_products
)
select 
cost_range , 
count(product_key) as total_products
from product_segment
group by cost_range
order by total_products desc



--task 2 
-- group customers into 3 segments based on their spending behavior 
---vip = at least 12 months of history and spending more than $5000
---regular= at least 12 months of history but spending $5000 or less 
--- new= lifespan less than 12 months and find total no of customers by each grp 


with customer_spending as (
select c.customer_key, 
sum(f.sales_amount) as total_spending,
min(order_date) as first_order,
max(order_date) as last_order,
datediff ( month , min(order_date) , max(order_date)) as lifespan
from gold.fact_sales f
left join gold.dim_customers c
on f.customer_key = c.customer_key
group by c.customer_key
)

select 
customer_segment, 
count(customer_key) as total_customers
from(
	select 
	customer_key ,
	total_spending, 
	lifespan,
	case when lifespan>12 and total_spending >5000 then 'VIP' 
		 when lifespan >= 12 and total_spending <=5000 then 'Regular'
		 else 'new'
	end customer_segment
	from customer_spending) t
group by customer_segment
order by total_customers desc
