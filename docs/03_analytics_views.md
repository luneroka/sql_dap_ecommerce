# Analytics View: `v_fact_sales_date`

## Purpose

The `v_fact_sales_date` view combines sales facts with detailed date information, enabling easier time-based analysis of sales data. It enriches the sales records with calendar attributes such as year, month, quarter, and weekday names.

## Description

This view joins the `fact_sales` table with the `dim_date` dimension table on the order date. It provides a comprehensive dataset that includes both sales metrics and date attributes, facilitating analysis by various time periods and calendar segments.

## Columns Included

- **From `fact_sales` (`fs`):**
  - All columns representing sales facts (e.g., sales amount, order details).
- **From `dim_date` (`dd`):**
  - `year`: Calendar year of the order date.
  - `month`: Numeric month.
  - `day_of_month`: Day of the month.
  - `quarter`: Fiscal quarter.
  - `month_name`: Name of the month.
  - `weekday_name`: Name of the weekday.
  - `is_weekend`: Boolean indicating if the day is a weekend.

## Join Details

- Left join on `fs.order_date = dd.order_date` to attach date attributes to each sales record.

## Example SQL Query

```sql
CREATE VIEW analytics.v_fact_sales_date AS
SELECT
    fs.*,
    dd.year,
    dd.month,
    dd.day_of_month,
    dd.quarter,
    dd.month_name,
    dd.weekday_name,
    dd.is_weekend
FROM analytics.fact_sales fs
LEFT JOIN analytics.dim_date dd
    ON fs.order_date = dd.order_date;
```
