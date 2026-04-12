/* =======================================================
-- PRODUCT MIX & CONCENTRATION ANALYSIS
-- Business questions : 
  -- How stable is the product mix over time, and are sales driven by a consistent set of products or shifting demand?
  -- Are sales concentrated in a small subset of products?
========================================================== */

-- 1. Concentration Overview
  -- Is revenue dominated by a few products or spread across many?
with revenue_by_product as (
	select 
		product_sku,
		sum(line_amount_usd) as product_revenue
	from analytics.v_fact_sales_usd
	group by product_sku
),
ranked as (
	select
		product_sku,
		product_revenue,
		sum(product_revenue) over() as total_revenue,
		row_number() over(order by product_revenue desc) as rn
	from revenue_by_product
)
select
	rn as rank,
	product_sku,
	product_revenue,
	sum(product_revenue) over(order by product_revenue desc) as cumulative_revenue,
	round(sum(product_revenue) over(order by product_revenue desc) / sum(product_revenue) over() * 100, 2) as cumulative_share_pct
from ranked
order by rn;

-- 2. Long Tail Contribution
  -- How much revenue comes from the "long tail" of less popular products?
  with revenue_by_product as (
	select 
		product_sku,
		sum(line_amount_usd) as product_revenue
	from analytics.v_fact_sales_usd
	group by product_sku
),
with_share as (
	select
		product_sku,
		product_revenue,
		product_revenue / sum(product_revenue) over() as revenue_share
	from revenue_by_product
)
select
	count(*) as total_products,
	count(*) filter (where revenue_share < 0.001) as low_performers,
	round(count(*) filter (where revenue_share < 0.001)::numeric / count(*) * 100, 2) as low_performer_pct
from with_share

-- 3. Product Mix Stability
  -- Are the top-selling products consistent over time, or does the mix shift?
  with monthly_revenue as (
	select 
		month,
		month_name,
		product_sku,
		sum(line_amount_usd) as product_revenue
	from analytics.v_fact_sales_usd
	group by month, month_name, product_sku
),
ranked as (
	select 
		row_number() over(partition by month order by product_revenue desc) as rank,
		month,
		month_name,
		product_sku,
		product_revenue
	from monthly_revenue
),
top_twenty as (
	select 
		*
	from ranked
	where rank <= 20
),
overlap as (
	select
		curr.month as current_month,
		curr.month_name as current_month_name,
		prev.month as previous_month,
		curr.product_sku,
		prev.month_name as previous_month_name
	from top_twenty curr
	join top_twenty prev
		on curr.product_sku = prev.product_sku
		and curr.month = prev.month + 1
)
select
	current_month_name,
	count(*) as overlap_count
from overlap
group by current_month, current_month_name
order by current_month

-- 4. Churn in Top Products
  -- How many products enter or exit the top 20 each month?
  with monthly_revenue as (
	select 
		month,
		month_name,
		product_sku,
		sum(line_amount_usd) as product_revenue
	from analytics.v_fact_sales_usd
	group by month, month_name, product_sku
),
ranked as (
	select 
		row_number() over(partition by month order by product_revenue desc) as rank,
		month,
		month_name,
		product_sku,
		product_revenue
	from monthly_revenue
),
top_twenty as (
	select 
		*
	from ranked
	where rank <= 20
),
churn as (
	select
		prev.month as previous_month,
		curr.month as current_month,
		prev.product_sku
	from top_twenty prev
	left join top_twenty curr
		on prev.product_sku = curr.product_sku
		and curr.month = prev.month + 1
	where curr.product_sku is null
)
select
    previous_month,
    count(*) as churned_products
from churn
group by previous_month
order by previous_month;