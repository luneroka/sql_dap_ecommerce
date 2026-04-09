-- =========================================================
-- ANALYTICS OVERVIEW

-- Purpose: High-level KPI overview of the ecommerce dataset
-- Source: analytics.v_fact_sales_usd (USD-converted, date-enriched fact view)
-- Notes:
--   - Returns a single result set with KPI name/value pairs
--   - Values are aggregated over the full dataset
--   - Monetary values are in USD
-- =========================================================

-- Total revenue (USD)
select 'Total Sales' as measure_name, sum(line_amount_usd) as measure_value from analytics.v_fact_sales_usd
union all
-- Total quantity sold
select 'Total Quantity', sum(quantity) from analytics.v_fact_sales_usd
union all
-- Average selling price per item (USD)
select 'Avg Price Per Item', round(sum(line_amount_usd) / sum(quantity), 2) from analytics.v_fact_sales_usd
union all
-- Total number of orders
select 'Total Orders', count(distinct order_id) from analytics.v_fact_sales_usd
union all
-- Average number of items per order
select 'Avg Item Per Order', round(sum(quantity)::numeric / count(distinct order_id), 2) from analytics.v_fact_sales_usd
union all
-- Average order value (USD) computed from order-level totals
select 'Avg Order Amount', round(avg(order_total), 2) 
from (
	select 
		order_id,
		sum(line_amount_usd) as order_total 
	from analytics.v_fact_sales_usd
	group by order_id
)t
union all
-- Number of distinct products sold
select 'Distinct Products', count(distinct product_sku) from analytics.v_fact_sales_usd
union all
-- Cancellation rate (share of rows with order_status = 'Cancelled')
select 'Cancellation Rate', round(count(*) filter (where order_status = 'Cancelled')::numeric / count(*), 2) from analytics.v_fact_sales_usd;