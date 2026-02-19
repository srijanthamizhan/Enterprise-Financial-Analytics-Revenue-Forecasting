
-- ==========================================
-- BigQuery Setup Script
-- Enterprise Financial Analytics Project
-- ==========================================

-- Create Dataset (Run once in your project)
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

-- Generate 5,000 Synthetic Transactions
INSERT INTO `enterprise_finance.financial_transactions`
SELECT
    GENERATE_UUID() AS transaction_id,
    DATE_ADD(DATE '2023-01-01', INTERVAL CAST(RAND()*730 AS INT64) DAY),
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
