/* =======================================================
- TRENDS ANALYSIS
-- Business questions : 
  -- How do sales evolve over time (daily/monthly) ?
  -- Are there identifiable seasonal patterns or trends ?
========================================================== */

-- Check sales by month (March exluded -only 1 day of data)
select
	month,
	month_name,
	sum(line_amount_usd) as total_sales,
	count(distinct order_id) as total_orders,
	sum(quantity) as total_quantity
from analytics.v_fact_sales_usd
where month != 3
group by month, month_name
order by month;

-- Daily time series	
select
	order_date,
	sum(line_amount_usd) as daily_sales
from analytics.v_fact_sales_usd 
group by order_date
order by order_date;

-- Total sales per day, running total and moving average
select
	order_date,
	total_sales,
	sum(total_sales) over(order by order_date) as running_total,
	round(avg(total_sales) over(
		order by order_date
		rows between 6 preceding and current row
	), 2) as moving_avg_7d
from (
	select
		order_date,
		sum(line_amount_usd) as total_sales
	from analytics.v_fact_sales_usd
	group by order_date
)t
order by order_date;

-- Consolidated query for short-term trends analysis
with order_totals as (
    select
        order_id,
        order_date,
        sum(line_amount_usd) as order_amount
    from analytics.v_fact_sales_usd
    group by order_id, order_date
),
daily_metrics as (
	select     
		order_date,
	    sum(line_amount_usd) as daily_sales,
	    sum(quantity) as daily_quantity,
	    count(order_id) as daily_orders
	from analytics.v_fact_sales_usd
	group by order_date
)
select
    dm.order_date,
    dm.daily_sales,
    dm.daily_quantity,
    dm.daily_orders,
    round(avg(ot.order_amount), 2) as avg_order_value,
    sum(dm.daily_sales) over(order by dm.order_date) as running_total,
    round(avg(dm.daily_sales) over(
        order by dm.order_date
        rows between 6 preceding and current row
    ), 2) as moving_avg_7d
from daily_metrics dm
join order_totals ot
	on dm.order_date = ot.order_date
group by 
	dm.order_date,
	dm.daily_sales,
    dm.daily_quantity,
    dm.daily_orders
order by dm.order_date;