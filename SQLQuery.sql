USE customer_analysis;
select top 20 * from customer;

--1. Revenue generated Male vs Female
select gender, sum([purchase_amount_(usd)]) as revenue
from customer group by gender;

--2. Used discount but spent more than the avg purchase amount
select customer_id, [purchase_amount_(usd)] from customer
where discount_applied = 'Yes'and [purchase_amount_(usd)]>=(select avg([purchase_amount_(usd)]) from customer);

--3. Top 5 products with highest avg review rating
select top 5 item_purchased, round(avg(review_rating),2) as "Average product Rating"
from customer group by item_purchased
order by avg(review_rating) desc

--4. Avg purchase amounts between standard and express shipping
select shipping_type, round(avg([purchase_amount_(usd)]),2) from customer
where shipping_type in ('Standard','Express') group by shipping_type

--5. Comparing avg spend and total revenue between subscribers and non-subscribers
select subscription_status, count(customer_id) as total_customers,
round(avg([purchase_amount_(usd)]),2) as avg_spend,
round(sum([purchase_amount_(usd)]),2) as total_revenue
from customer group by subscription_status
order by total_revenue,avg_spend desc

--6. Top 5 products having highest percentage of purchases with discounts applied
select top 5 item_purchased, round(100*sum(case when discount_applied='Yes' then 1 else 0 end)/count(*),2) as discount_rate
from customer group by item_purchased order by discount_rate desc

--7. Segement customers into new, returning, and loyal based on their previous purchases and count of each segment
;with customer_type as(
select customer_id,
case
	when previous_purchases=1 then 'New'
	when previous_purchases between 2 and 10 then 'Returning'
	else 'Loyal'
end as customer_segment
from customer
)
select customer_segment,count(*) as "Number of customers"
from customer_type group by customer_segment

--8. Top 3 most purchased products with each category
;with item_counts as(
select category, item_purchased,
count(customer_id) as total_orders,
row_number() over(partition by category order by count(customer_id)desc) as item_rank
from customer group by category, item_purchased
)
select item_rank,category,item_purchased,total_orders
from item_counts
where item_rank<=3

--9. Customers who are repeat buyers(>5 purchases) also likely to subscribe
select subscription_status, count(customer_id) as repeat_buyers
from customer where previous_purchases>5 group by subscription_status

--10. Revenue by age group
select age_group,sum([purchase_amount_(usd)]) as total_revenue
from customer group by age_group order by total_revenue desc

