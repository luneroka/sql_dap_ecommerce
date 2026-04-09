/ * --------------------------------------------------------
-- ANALYTICS LAYER - DIMENSION TABLES
--------------------------------------------------------
-- Purpose:
-- This script creates dimension tables used for analytical queries.
-- Dimension tables contain descriptive and relatively stable attributes.
--------------------------------------------------------
*/

-- =========================================================
-- Table: analytics.dim_products
-- Purpose:
-- This dimension table stores product-level descriptive attributes.
-- Grain: 1 row per unique product_sku.
--
-- Notes:
-- - Data is sourced from analytics.product_catalog_clean (already cleaned).
-- - Exact duplicates are removed using DISTINCT.
-- - stock_quantity is intentionally excluded because it is a volatile metric
--   and does not belong in a dimension table (better suited for fact/snapshot tables).
-- =========================================================
create table analytics.dim_products as
select distinct
    product_sku,
    design_number,
    category,
    size,
    color
from analytics.product_catalog_clean;

-- Add primary key to enforce uniqueness at the product level
alter table analytics.dim_products
add primary key (product_sku);


-- =========================================================
-- Table: analytics.fact_sales
-- Purpose:
-- This fact table stores sales transactions at the product level.
-- Grain: 1 row per unique sales transaction.
--
-- Notes:
-- - Data is sourced from analytics.amazon_sales (already cleaned).
-- - Exact duplicates are removed using DISTINCT.
-- - stock_quantity is intentionally excluded because it is a volatile metric
--   and does not belong in a dimension table (better suited for fact/snapshot tables).
-- =========================================================
create table analytics.fact_sales as
with source as (
	-- 1. Starting with source
    select *
    from analytics.amazon_sales_clean
),
deduplicated as (
	-- 2. Remove remaining duplicates
	-- Observation: 1 order_id/product_sku had 2 rows: 1 cancelled by carrier (qty=0) and 1 shipped (qty=1)
	-- Action: Keep the shipped row with non-zero quantity; remove the cancelled placeholder
    select *
    from (
        select 
        	*,
            row_number() over (
                partition by order_id, product_sku
                order by case when courier_status = 'Cancelled' then 2 else 1 end
            ) as rn
        from source
    )t
    where rn = 1
)
select 
	order_id,
	product_sku,
	order_date,
	ship_state,
	fulfillment_type,
	quantity,
	line_amount,
	ship_service_level,
	order_status,
	courier_status,	
	is_b2b
from deduplicated

-- Add primary key to enforce uniqueness at the sales transaction level
alter table analytics.fact_sales
add primary key (order_id, product_sku);

-- Add foreign key to link sales to products
alter table analytics.fact_sales
add constraint fk_fact_product
foreign key (product_sku) 
references analytics.dim_products(product_sku);

/*
-- Observation: 790 product_sku values in fact_sales were not present in dim_products
-- Cause: These SKUs were filtered out during product_catalog_clean (e.g., #REF!, zero stock)
-- Action: Inserted these missing SKUs into dim_products with available attributes
-- Notes: Other attributes (design_number, color, stock_quantity) are left NULL
-- Reasoning: Preserves referential integrity so FK can be enforced on fact_sales
*/
insert into analytics.dim_products(product_sku, category, size)
select distinct
	product_sku,
	initcap(trim(product_category)) as category,
	upper(trim(product_size)) as size
from analytics.amazon_sales_clean t 
where not exists (
	select 1 from analytics.dim_products dp 
	where dp.product_sku = t.product_sku 
);