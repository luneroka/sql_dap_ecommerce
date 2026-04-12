/* =======================================================
-- CANCELLED ORDERS ANALYSIS
-- Business questions : 
  -- What is the revenue impact of cancelled orders ?
  -- Where are the losses concentrated ?
========================================================== */
-- Revenue Impact
with cancelled_revenue as (
	select
		sum(line_amount_usd) filter (where order_status = 'Cancelled') as cancelled_revenue,
		round(
			sum(line_amount_usd) filter (where order_status = 'Cancelled') / sum(line_amount_usd) * 100
		,2 ) as cancelled_revenue_share
	from analytics.v_fact_sales_usd_with_cancellations
)
select 
	to_char(cancelled_revenue, 'FM$9,999,999') as cancelled_revenue,
	concat(cancelled_revenue_share, '%') as cancelled_revenue_share
from cancelled_revenue

-- Loss Driversselect
    fulfillment_type,
    to_char(sum(line_amount_usd), '$9,999,999') as lost_revenue
from analytics.v_fact_sales_usd_with_cancellations
where order_status = 'Cancelled'
group by fulfillment_type;