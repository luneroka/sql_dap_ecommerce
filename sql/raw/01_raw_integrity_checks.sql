/* --------------------------------------------------------
-- RAW DATA INTEGRITY CHECKS
--------------------------------------------------------
*/

-- =========================================================
-- Table: raw.product_catalog
-- =========================================================

-- product_sku : check for NULLs and duplicates
select 
	product_sku,
	count(product_sku)
from raw.product_catalog
group by product_sku
having count(product_sku) > 1 or product_sku is null;
-- Observation : Found duplicates and #REF! -> Investigation below

		-- Investigate duplicates and #REF! values found
		select
			*
		from raw.product_catalog
		where product_sku in ('#REF!');
		
		-- Verify these are not referenced in amazon_sales before filtering out
		select
			*
		from raw.amazon_sales 
		where product_sku in (
			select 
				product_sku
			from raw.product_catalog
			group by product_sku
			having count(*) > 1 or product_sku is null
		);
-- Action : All anomalies will be filtered out in analytics.product_catalog_clean
   -- Duplicates filtered on quantity = 0
   -- #REF! filter all

-- stock_quantity : check for NULLs or negative numbers
select
	stock_quantity
from raw.product_catalog
where stock_quantity < 0 or stock_quantity is null;
-- Observation : no anomaly.

-- category : check distinct category anomalies
select
	distinct category,
	count(*)
from raw.product_catalog
group by category;
-- Observation : found one category with irregular naming 'AN : LEGGINGS' + all capitalized
-- Action : remove prefix + format to pascal case

-- color : check data consistency
select 
	distinct color,
	count(*)
from raw.product_catalog
group by color;
-- Observation : found many duplicates due to unwanted spaces and irregular casing + 'NO REFERENCE' value
-- Action : must trim and standardize casing, and replace 'NO REFERENCE' with NULL.


-- =========================================================
-- Table: raw.amazon_sales
-- =========================================================

-- order_id : 
    -- check for NULLs (duplicates expected on this column)
	select 
		order_id
	from raw.amazon_sales
	where order_id is null;
	-- Observation : No NULLs.

	-- check for duplicates
	select 
	    order_id,
	    product_sku,
	    order_date,
	    count(*)
	from raw.amazon_sales
	group by order_id, product_sku, order_date
	having count(*) > 1;
	-- Observation:
	-- Found 6 duplicated rows at full row level (all columns identical).
	-- Also observed multiple rows per order_id due to:
	--   - multiple SKUs per order (expected)
	--   - cancelled vs shipped line items (valid business behavior)
	
	-- Action:
	-- Only exact duplicate rows will be removed using DISTINCT in analytics layer.
	-- All other rows are preserved as they represent valid order line data.
	
-- order_date : sanity check
select min(order_date), max(order_date) from raw.amazon_sales;
-- Observation : correct format and relevant range
	
-- product_sku : check consistency with catalog
select distinct product_sku
from raw.amazon_sales
where product_sku not in (
    select product_sku from raw.product_catalog
);
-- Observation : no orphan sales

-- product_category : check data standardization and consistency with raw.product_catalog
select
	distinct product_category
from raw.amazon_sales;
-- Observation : found 1 category fully lowercase
-- Action : align with pascal-case convention

-- product_size : check data consistency
select distinct product_size from raw.amazon_sales;
-- Observation : 'Free' size is pascal-case
-- Action : standardize casing across both tables (UPPER or PascalCase)

-- quantity & line_amount : check for NULLs or negative numbers
select
	line_amount
from raw.amazon_sales
where line_amount < 0 or line_amount is null;
-- Observation : no anomaly.

-- ship city : check for duplicates and data consistency
select
	ship_city,
	count(*)
from raw.amazon_sales
group by ship_city
order by ship_city;
-- Observation : trim and align all to pascal-case

-- ship_postal_code
-- Observation: postal codes stored as floats (e.g., '591237.0')
-- Action: will be cleaned in analytics layer using regex -> REGEXP_REPLACE(ship_postal_code, '\.0$', '')