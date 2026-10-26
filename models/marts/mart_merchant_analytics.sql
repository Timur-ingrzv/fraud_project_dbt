{{ config(
    materialized='table'
) }}

WITH transactions AS (
    SELECT
        merchant_name,
        customer_key,
        amount,
        is_fraud
    FROM {{ ref('stg_transactions') }}
),

merchant_metrics AS (
    SELECT
        merchant_name,
        COUNT(*) AS transaction_count,
        COUNT(DISTINCT customer_key)
            AS unique_customers,
        SUM(amount) AS total_amount,
        ROUND(AVG(amount), 2) AS avg_amount,
        SUM(is_fraud) AS fraud_count,
        COALESCE(
            SUM(amount) FILTER (WHERE is_fraud = 1),
            0
        ) AS fraud_amount
    FROM transactions
    GROUP BY merchant_name
),

fraud_metrics AS (
    SELECT
        *,
        ROUND(100.0 * fraud_count / NULLIF(transaction_count, 0), 2)
            AS fraud_rate
    FROM merchant_metrics
)

SELECT
    *,
    CASE
        WHEN
            transaction_count >= 20
            AND fraud_count >= 2
            AND fraud_rate >= 5
            THEN 1
        ELSE 0
    END AS is_suspicious
FROM fraud_metrics
