# dim_date Table Documentation

The `dim_date` table is a date dimension used for analytics and reporting. It provides detailed date attributes for each day in a specified range, making it easy to join with fact tables and perform time-based analysis.

## Purpose

Use `dim_date` to:

- Join with fact tables on date columns
- Filter or group by year, month, quarter, weekday, or weekend
- Support time-based aggregations and reporting

## Example: Determine Date Range in Sales Data

```sql
SELECT
  MIN(order_date) AS start_date,
  MAX(order_date) AS end_date
FROM analytics.fact_sales;
```

## Example: Create the dim_date Table

This example creates the `dim_date` table for dates between March 31, 2022, and June 29, 2022.

```sql
CREATE TABLE analytics.dim_date AS
WITH time_series AS (
  SELECT generate_series(
    '2022-03-31'::date,
    '2022-06-29'::date,
    INTERVAL '1 day'
  )::date AS order_date
)
SELECT
  order_date,
  EXTRACT(year FROM order_date) AS year,
  EXTRACT(month FROM order_date) AS month,
  EXTRACT(day FROM order_date) AS day_of_month,
  EXTRACT(quarter FROM order_date) AS quarter,
  TO_CHAR(order_date, 'FMMonth') AS month_name,
  TO_CHAR(order_date, 'FMDay') AS weekday_name,
  CASE
    WHEN EXTRACT(dow FROM order_date) IN (0, 6) THEN TRUE
    ELSE FALSE
  END AS is_weekend
FROM time_series
ORDER BY order_date;
```

## Column Descriptions

- **order_date**: The calendar date.
- **year**: Year number (e.g., 2022).
- **month**: Month number (1-12).
- **day_of_month**: Day of the month (1-31).
- **quarter**: Quarter number (1-4).
- **month_name**: Full month name (e.g., 'April').
- **weekday_name**: Day of the week (e.g., 'Monday').
- **is_weekend**: Boolean indicating if the date falls on a weekend.

---

Use this table as a reference for building and querying the `dim_date` dimension in your analytics projects.
