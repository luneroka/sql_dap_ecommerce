/* --------------------------------------------------------
-- ANALYTICS DATA TRANSFORMATIONS (SILVER LAYER)
--------------------------------------------------------
-- Purpose:
-- This script creates cleaned and standardized tables from raw data.
-- These tables serve as the foundation for downstream data modeling
-- (dimension and fact tables).
--
-- Key principles:
-- - Raw data is never modified
-- - Data is cleaned, filtered, and standardized deterministically
-- - Each table enforces a consistent and reliable structure for analysis
--------------------------------------------------------
*/

-- Purpose:
-- Clean and standardize product catalog data.
-- Grain: 1 row per product record (after filtering and deduplication).
--
-- Key transformations:
-- - Remove invalid SKUs (#REF!, NULL)
-- - Exclude zero stock artifacts
-- - Deduplicate rows
-- - Standardize category, size, and color fields

-- =========================================================
-- Table: analytics.product_catalog_clean
-- =========================================================
create table analytics.product_catalog_clean as
with source as (
	-- 1. Starting from raw	
	select *
	from raw.product_catalog
),
filtered as (
	-- 2. Remove invalid product_sku (#REF! and NULL)
	select *
	from source
	where product_sku is not null
		and product_sku <> '#REF!'
),
deduplicated as (
	-- 3. Remove duplicate product_sku
	select distinct *
	from filtered
	where stock_quantity <> 0
),
standardized as (
	-- 4. Clean & Standardize columns
	select
		product_sku,
		design_number,
		stock_quantity,
		initcap(trim(replace(category, 'AN : ', ''))) as category,
		upper(trim(size)) as size,
		case
			when trim(upper(color)) = 'NO REFERENCE' then null
			else initcap(trim(color))
		end as color
	from deduplicated
)
-- 5. Final select
select *
from standardized


-- Purpose:
-- Clean and standardize transactional sales data.
-- Grain: 1 row per order line (order_id + product_sku).
--
-- Key transformations:
-- - Remove invalid order_id (NULL)
-- - Deduplicate exact duplicate rows
-- - Standardize text fields (status, location, fulfillment, etc.)
-- - Normalize postal codes and handle empty values

-- =========================================================
-- Table: analytics.amazon_sales_clean
-- =========================================================
create table analytics.amazon_sales_clean as
with source as (
	-- 1. Starting from raw
	select *
	from raw.amazon_sales
),
filtered as (
	-- 2. Remove invalid order_id (NULL)
	select *
	from source
	where order_id is not null
),
deduplicated as (
	-- 3. Remove exact duplicate rows (full row deduplication)
	select distinct
		order_id,
		order_date,
		order_status,
		fulfillment_type,
		sales_channel,
		ship_service_level,
		product_style,
		product_sku,
		product_category,
		product_size,
		product_asin,
		courier_status,
		quantity,
		currency,
		line_amount,
		ship_city,
		ship_state,
		ship_postal_code,
		ship_country,
		promotion_ids,
		is_b2b,
		fulfillment_service
	from filtered
),
standardized as (
	-- 4. Clean & Standardize columns
	select
		order_id,
		order_date,
		initcap(trim(order_status)) as order_status,
		initcap(trim(fulfillment_type)) as fulfillment_type,
		initcap(trim(sales_channel)) as sales_channel,
		initcap(trim(ship_service_level)) as ship_service_level,
		product_style,
		product_sku,
		initcap(trim(product_category)) as product_category,
		upper(trim(product_size)) as product_size,
		product_asin,
		initcap(trim(courier_status)) as courier_status,
		quantity,
		currency,
		line_amount,
		nullif(initcap(trim(ship_city)), '') as ship_city,
		initcap(trim(ship_state)) as ship_state,
		REGEXP_REPLACE(ship_postal_code, '\.0$', '') as ship_postal_code,
		upper(trim(ship_country)) as ship_country,
		promotion_ids,
		is_b2b,
		initcap(trim(fulfillment_service)) as fulfillment_service
	from deduplicated
)
-- 5. Final select
select *
from standardized