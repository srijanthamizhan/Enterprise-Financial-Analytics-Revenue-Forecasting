
-- ==========================================
-- Enterprise Financial Analytics Project
-- Google BigQuery Standard SQL
-- ==========================================

-- Create Dataset
CREATE SCHEMA IF NOT EXISTS `enterprise_finance`;

-- Create Partitioned & Clustered Table
CREATE OR REPLACE TABLE `enterprise_finance.financial_transactions`
(
    transaction_id STRING,
    transaction_date DATE,
    region STRING,
    customer_segment STRING,
    product_category STRING,
    revenue NUMERIC,
    cost NUMERIC
)
PARTITION BY transaction_date
CLUSTER BY region, product_category;

-- Generate Synthetic Data (5,000 Transactions)
INSERT INTO `enterprise_finance.financial_transactions`
SELECT
    GENERATE_UUID() AS transaction_id,
    DATE_ADD('2023-01-01', INTERVAL CAST(RAND()*730 AS INT64) DAY) AS transaction_date,
    region,
    segment,
    category,
    ROUND(500 + RAND() * 5000, 2) AS revenue,
    ROUND((500 + RAND() * 5000) * (0.6 + RAND() * 0.2), 2) AS cost
FROM UNNEST(GENERATE_ARRAY(1, 5000)) AS x
CROSS JOIN UNNEST(['West','East','Central','South']) AS region
CROSS JOIN UNNEST(['Enterprise','SMB','Consumer']) AS segment
CROSS JOIN UNNEST(['Technology','Furniture','Office Supplies']) AS category
LIMIT 5000;

-- ==========================================
-- ANALYSIS QUERIES
-- ==========================================

-- Revenue & Profit by Region
SELECT 
    region,
    SUM(revenue) AS total_revenue,
    SUM(revenue - cost) AS total_profit,
    ROUND(SAFE_DIVIDE(SUM(revenue - cost), SUM(revenue)) * 100, 2) AS profit_margin_pct
FROM `enterprise_finance.financial_transactions`
GROUP BY region
ORDER BY total_revenue DESC;

-- Monthly Revenue Trend
SELECT 
    DATE_TRUNC(transaction_date, MONTH) AS month,
    SUM(revenue) AS monthly_revenue
FROM `enterprise_finance.financial_transactions`
GROUP BY month
ORDER BY month;

-- Month-over-Month Growth
WITH monthly_data AS (
    SELECT 
        DATE_TRUNC(transaction_date, MONTH) AS month,
        SUM(revenue) AS monthly_revenue
    FROM `enterprise_finance.financial_transactions`
    GROUP BY month
)
SELECT
    month,
    monthly_revenue,
    ROUND(
        SAFE_DIVIDE(
            monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY month),
            LAG(monthly_revenue) OVER (ORDER BY month)
        ) * 100, 2
    ) AS growth_rate_pct
FROM monthly_data
ORDER BY month;

-- Executive Summary View
CREATE OR REPLACE VIEW `enterprise_finance.executive_summary` AS
SELECT
    COUNT(*) AS total_transactions,
    SUM(revenue) AS total_revenue,
    SUM(revenue - cost) AS total_profit,
    ROUND(SAFE_DIVIDE(SUM(revenue - cost), SUM(revenue)) * 100, 2) AS overall_profit_margin
FROM `enterprise_finance.financial_transactions`;

-- ==========================================
-- BigQuery ML Revenue Forecast Model
-- ==========================================

CREATE OR REPLACE MODEL `enterprise_finance.revenue_forecast_model`
OPTIONS(
    model_type='ARIMA_PLUS',
    time_series_timestamp_col='month',
    time_series_data_col='monthly_revenue'
) AS
SELECT 
    DATE_TRUNC(transaction_date, MONTH) AS month,
    SUM(revenue) AS monthly_revenue
FROM `enterprise_finance.financial_transactions`
GROUP BY month;

-- Forecast Next 6 Months
SELECT *
FROM ML.FORECAST(
    MODEL `enterprise_finance.revenue_forecast_model`,
    STRUCT(6 AS horizon, 0.8 AS confidence_level)
);
