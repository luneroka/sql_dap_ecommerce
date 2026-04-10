# Ecommerce Analysis Report

## 0. Dataset Overview

### 0.1. Overview KPIs

| measure_name       | measure_value |
| ------------------ | ------------- |
| Total Sales        | $1,034,076    |
| Total Quantity     | 116,646       |
| Avg Price Per Item | $8.87         |
| Total Orders       | 120,378       |
| Avg Item Per Order | 1.08          |
| Avg Order Amount   | $8.59         |
| Distinct Products  | 7,195         |
| Cancellation Rate  | 14%           |

## 1. Q2 Trend Analysis

The chart below shows daily sales with a 7-day moving average to highlight underlying trends:

![Daily Sales](../assets/daily_sales.png)

### 1.1. Daily Sales Trend

- Sales slowly increased throughout April, reaching a peak at the end of the month
- Sales increased by 42% between April 29th and May 3rd, peaking at $15,649
- Sales dropped below April's average right after the peak and stabilized around a $10,924 daily average through the end of Q2

### 1.2. Trend Drivers

- The increase in sales is primarily driven by higher order volume
- Average order value remains stable (~$8.3–$8.5)
- This indicates no significant pricing or basket size change

### 1.3 Monthly Summary

| month_name | total_sales | total_orders | total_quantity |
| ---------- | ----------- | ------------ | -------------- |
| April      | $379,469    | 45,858       | 44,206         |
| May        | $345,057    | 39,221       | 38,009         |
| June       | $308,211    | 35,141       | 34,275         |

- Sales declined month-over-month from April to June
- The consistent decline across all metrics suggests a demand-driven decrease rather than operational constraints

### 1.4. Sample Data (first 5 days)

| order_date | daily_sales | daily_quantity | daily_orders | avg_order_value | running_total | moving_avg_7d |
| ---------- | ----------- | -------------- | ------------ | --------------- | ------------- | ------------- |
| 2022-04-01 | 11387.98    | 1319           | 1470         | 8.36            | 11387.98      | 11387.98      |
| 2022-04-02 | 12014.39    | 1408           | 1555         | 8.27            | 23402.37      | 11701.19      |
| 2022-04-03 | 13312.63    | 1544           | 1691         | 8.51            | 36715.00      | 12238.33      |
| 2022-04-04 | 11606.09    | 1331           | 1465         | 8.43            | 48321.09      | 12080.27      |
| 2022-04-05 | 12507.21    | 1486           | 1616         | 8.31            | 60828.30      | 12165.66      |

### 1.5. Summary

Overall, the dataset shows a short-term growth phase followed by a steady decline, with no evidence of strong seasonality due to the limited time range.

## 2. Product Performance
