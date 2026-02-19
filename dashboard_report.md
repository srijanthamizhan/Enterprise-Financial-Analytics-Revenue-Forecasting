# Enterprise Financial Performance Dashboard

## Overview

This project analyzes 5,000+ enterprise financial transactions using
Google BigQuery.\
The analysis includes revenue trends, profitability metrics, regional
performance, and forecasting.

------------------------------------------------------------------------

## Executive KPIs

  Metric          Value
  --------------- --------
  Total Revenue   \$8.2M
  Total Profit    \$2.4M
  Profit Margin   29.3%
  Transactions    5,000+

------------------------------------------------------------------------

## Revenue by Region

  Region    Revenue (\$)
  --------- --------------
  West      2,200,000
  East      2,100,000
  Central   1,900,000
  South     2,000,000

------------------------------------------------------------------------

## Monthly Revenue Trend

Revenue demonstrates consistent growth throughout the year with seasonal
fluctuations.\
Month-over-Month growth calculated using SQL window functions (`LAG()`).

------------------------------------------------------------------------

## Forecasting

A 6-month revenue forecast was generated using BigQuery ML (ARIMA_PLUS),
enabling predictive financial planning.

------------------------------------------------------------------------

## Technologies Used

-   Google BigQuery (Standard SQL)
-   Partitioned & Clustered Tables
-   Window Functions
-   BigQuery ML
-   Chart.js (HTML Dashboard)

------------------------------------------------------------------------

## How to Run

1.  Run `bigquery_setup.sql`
2.  Run `financial_analysis.sql`
3.  Open `index.html` for interactive dashboard
