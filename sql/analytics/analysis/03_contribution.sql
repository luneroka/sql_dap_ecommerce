/* =======================================================
-- CONTRIBUTION ANALYSIS
-- Business questions : 
  -- Which categories and fulfillment methods contribute the most to overall revenue ?
========================================================== */

-- Category Contribution
with sales_by_category as (
	select 
		dp.category,
		count(fs.product_sku) as total_volume,
		sum(fs.line_amount_usd) as total_revenue
	from analytics.v_fact_sales_usd fs
	left join analytics.dim_products  dp
		on fs.product_sku = dp.product_sku
	group by dp.category 
),
sales_by_share as (
	select 
		category,
		total_volume,
		total_revenue,
		total_volume / sum(total_volume) over() as volume_share,
		total_revenue / sum(total_revenue) over() as revenue_share
	from sales_by_category
),
cumulative_shares as (
	select
		category,
		total_volume,
		round(volume_share * 100, 2) as volume_share_pct,
		round(sum(volume_share) over(order by total_revenue desc) * 100, 2) as cumulative_volume_share_pct,
		total_revenue,
		round(revenue_share * 100, 2) as revenue_share_pct,
		round(sum(revenue_share) over(order by total_revenue desc) * 100, 2) as cumulative_revenue_pct
	from sales_by_share
	order by total_revenue desc
)
select
	category,
	to_char(total_volume, 'FM9,999,999') as total_volume,
	concat(volume_share_pct, '%') as volume_share,
	concat(cumulative_volume_share_pct, '%') as cumulative_volume_share,
	to_char(total_revenue, 'FM$9,999,999') as total_revenue,
	concat(revenue_share_pct, '%') as revenue_share,
	concat(cumulative_revenue_pct, '%') as cumulative_revenue_share
from cumulative_shares

-- Fulfillment Method Contribution
with sales_by_fulfillment as (
	select 
		fulfillment_type,
		count(product_sku) as total_volume,
		sum(line_amount_usd) as total_revenue
	from analytics.v_fact_sales_usd
	group by fulfillment_type 
),
sales_by_share as (
	select 
		fulfillment_type,
		total_volume,
		total_revenue,
		round(total_volume / sum(total_volume) over() * 100) as volume_share,
		round(total_revenue / sum(total_revenue) over() * 100) as revenue_share
	from sales_by_fulfillment
)
select
	fulfillment_type,
	to_char(total_volume, 'FM9,999,999') as total_volume,
	to_char(total_revenue, 'FM$9,999,999') as total_revenue,
	concat(volume_share, '%') as volume_share,
	concat(revenue_share, '%') as revenue_share
from sales_by_share