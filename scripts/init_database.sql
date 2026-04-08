-- ============================================
-- Data Analysis - E-Commerce (Amazon) 
-- Initialization Script
-- ============================================
--
-- Purpose : 
-- This script initializes the 'dap_amazon' database for the E-Commerce (Amazon) data analysis project. 
-- It drops existing database (if any), recreates it and sets up the core schema : raw and analytics
--
-- Warning:
-- This script is DESTRUCTIVE.
-- Running it will permanently delete the existing 'dap_amazon' database
-- and all its data. Ensure you have backups if needed before execution.

-- Execution Notes:
-- - Must be run from a connection to a different database (e.g., 'postgres')
-- - The '\c dap_amazon' command only works in psql (not all SQL editors like DBeaver)
-- - In DBeaver, execute database creation and schema creation in separate steps
-- ============================================

-- Step 1 : Drop existing database (if it exists) and create a new one
drop database if exists dap_amazon;
create database dap_amazon;

-- Step 2 : Connect to the new DB (Note: This command is for psql, not all SQL editors support it)
\c dap_amazon

-- Step 3 : Create schemas for raw and analytics data
create schema if not exists raw;
create schema if not exists analytics;

-- Step 4 - Verification (optional)
select schema_name
from information_schema.schemata
where schema_name in ('raw', 'analytics');