--Performance Analysis 
--comparing the current value to a target value. helps measure success and compare performance. 
-- formula = current {measure} - Target{measure} example = current sales-average sales ; current year sales-previous year sales ; current sales - lowest sales

--task
--analyse the yearly performance of products by comparing each product's sales to both its average sales performance and the previous year' sales .

with yearly_product_sales as(
select 
year(f.order_date) as order_year,
p.product_name,
sum(f.sales_amount) as current_sales
from gold.fact_sales f
left join gold.dim_products p
on f.product_key = p.product_key
where order_date is not null
group by 
year(f.order_date), 
p.product_name
)

select 
order_year,
product_name,
current_sales,
avg(current_sales) over ( partition by product_name) as avg_sales,
current_sales - avg(current_sales) over ( partition by product_name) as diff_avg ,
--now to make a indicator as we are above , below or at the average for that we use case when statement 
CASE when current_sales - avg(current_sales) over ( partition by product_name) > 0 then 'above avg'
	 when current_sales - avg(current_sales) over ( partition by product_name) < 0 then 'Below avg'
	 else 'avg'
END avg_change ,
--year over year analysis 
--Lag function allows you to create a new column that access a previous row from another column 
lag(current_sales) over (partition by product_name order by order_year) as py_sales,
current_sales  -  lag(current_sales) over (partition by product_name order by order_year) as diff_py,
CASE when current_sales - lag(current_sales) over ( partition by product_name order by order_year) > 0 then 'Increase'
	 when current_sales - lag(current_sales) over ( partition by product_name order by order_year) < 0 then 'Decrease'
	 else 'no change'
END py_change 
from yearly_product_sales
order by product_name , order_year