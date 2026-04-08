/*
===============================================================================
DDL Script: Create Raw Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'raw' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'raw' Tables
===============================================================================
*/

-- =================
-- amazon_sales table
-- =================

-- Drop existing tables if they exist
drop table if exists raw.amazon_sales cascade;

-- Create the amazon_sales table
create table raw.amazon_sales (
  order_id VARCHAR(50),
  order_date DATE,
  order_status VARCHAR(50),
  fulfillment_type VARCHAR(50),
  sales_channel VARCHAR(50),
  ship_service_level VARCHAR(50),
  product_style VARCHAR(50),
  product_sku VARCHAR(50),
  product_category VARCHAR(50),
  product_size VARCHAR(50),
  product_asin VARCHAR(50),
  courier_status VARCHAR(50),
  quantity INT,
  currency VARCHAR(10),
  line_amount DECIMAL(12, 2),
  ship_city VARCHAR(50),
  ship_state VARCHAR(50),
  ship_postal_code VARCHAR(20),
  ship_country VARCHAR(50),
  promotion_ids TEXT,
  is_b2b BOOLEAN,
  fulfillment_service VARCHAR(50)
);


-- =================
-- product_catalog table
-- =================

-- Drop existing tables if they exist
drop table if exists raw.product_catalog cascade;

-- Create the product_catalog table
create table raw.product_catalog (
  product_sku VARCHAR(50),
  design_number VARCHAR(50),
  stock_quantity INT,
  category VARCHAR(50),
  size VARCHAR(20),
  color VARCHAR(50)
);


-- Optional comments for traceability
comment on table raw.amazon_sales is 'Source: Amazon Sale Report.csv';
comment on table raw.product_catalog is 'Source: Sale Report.csv';