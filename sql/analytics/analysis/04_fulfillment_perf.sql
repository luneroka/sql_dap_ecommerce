/* =======================================================
-- FULFILLMENT PERFORMANCE ANALYSIS
-- Business questions : 
  -- How does fulfillment method impact sales performance and order outcomes ?
========================================================== */

-- Average Order Value by Fulfillment Type
with order_totals as (
	select
		order_id,
		fulfillment_type,
		sum(line_amount_usd) as order_value
	from analytics.v_fact_sales_usd
	group by order_id, fulfillment_type
)
select 
	round(avg(order_value) filter (where fulfillment_type = 'Amazon'), 2) as aov_amazon,
	round(avg(order_value) filter (where fulfillment_type = 'Merchant'), 2) as aov_merchant
from order_totals

-- Cancellation Rate by Fulfillment Type
select
	round(
		count(distinct order_id) filter (where order_status = 'Cancelled' and fulfillment_type = 'Amazon')::numeric
		/ count(distinct order_id) filter (where fulfillment_type = 'Amazon') * 100,
	2) as amazon_cancellation_rate,
	round(
		count(distinct order_id) filter (where order_status = 'Cancelled' and fulfillment_type = 'Merchant')::numeric
		/ count(distinct order_id) filter (where fulfillment_type = 'Merchant') * 100,
	2) as merchant_cancellation_rate
from analytics.v_fact_sales_usd_with_cancellations