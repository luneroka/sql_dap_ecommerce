# Analytics Views Documentation

## 1. View: `v_fact_sales_date`

### Purpose

To enrich sales data with detailed date attributes for easier time-based analysis.

### Description

This view combines the sales facts from `fact_sales` with calendar information from the `dim_date` table by joining on the order date. It provides sales metrics alongside useful date components such as year, month, quarter, and weekday details.

### Key Columns

- Sales facts (all columns from `fact_sales`)
- Date attributes from `dim_date`:
  - `year`
  - `month`
  - `day_of_month`
  - `quarter`
  - `month_name`
  - `weekday_name`
  - `is_weekend`

### SQL Example

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

---

## 2. View: `v_fact_sales_usd`

### Purpose

To provide sales data with amounts converted to USD for standardized currency reporting.

### Description

This view builds on `v_fact_sales_date` by converting the sales line amount from the local currency to USD using a fixed exchange rate. It includes key sales and date fields along with the converted USD amount.

### Key Columns

- Sales details:
  - `order_id`
  - `product_sku`
  - `order_date`
  - `ship_state`
  - `fulfillment_type`
  - `quantity`
  - `line_amount`
  - `line_amount_usd` (converted)
  - `ship_service_level`
  - `order_status`
  - `courier_status`
  - `is_b2b`
- Date attributes:
  - `year`
  - `month`
  - `day_of_month`
  - `quarter`
  - `month_name`
  - `weekday_name`
  - `is_weekend`

### SQL Example

```sql
CREATE VIEW analytics.v_fact_sales_usd AS
SELECT
    order_id,
    product_sku,
    order_date,
    ship_state,
    fulfillment_type,
    quantity,
    line_amount,
    ROUND(line_amount / 76.0, 2) AS line_amount_usd,
    ship_service_level,
    order_status,
    courier_status,
    is_b2b,
    year,
    month,
    day_of_month,
    quarter,
    month_name,
    weekday_name,
    is_weekend
FROM analytics.v_fact_sales_date
WHERE order_status != 'Cancelled';
```

---

### Note on Currency Conversion

The USD conversion uses a fixed exchange rate of 76.0. For dynamic or updated rates, consider integrating a currency exchange rate table or API.

## 3. View: `v_fact_sales_usd_with_cancellations`

### Purpose

Add cancelled orders to v_fact_sales_usd.

### Description

This view builds on `v_fact_sales_usd` and simply removes the order_status = 'Cancelled' filter for cancellation rate and dive deep analysis.
