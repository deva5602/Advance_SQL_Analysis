--Part to whole analysis 
--analyze how an individual part is performing compared to the overall , allowing us to understand which category has the gratest impact on the business
--formula ([measure]/total[measure])*100 by [dimension] example = (sales/total sales)*100 by category 
-- Task 
--which categories contribute the most to overall sales 

with category_sales as (
select 
category,
sum(sales_amount) as total_sales
from gold.fact_sales f
left join gold.dim_products p 
on p.product_key = f.product_key
group by category
)
select 
category , 
total_sales ,
sum(total_sales) over() overall_sales ,
concat(round((cast(total_sales as float)/ sum(total_sales) over())*100,2) , '%') as percentage_of_total
from category_sales
order by total_sales desc