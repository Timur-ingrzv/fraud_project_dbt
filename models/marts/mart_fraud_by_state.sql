{{ config(
    materialized='table'
) }}

WITH transactions AS (
    SELECT
        state,
        customer_key,
        merchant_name,
        amount,
        is_fraud
    FROM {{ ref('stg_transactions') }}
),

state_metrics AS (
    SELECT
        state,
        COUNT(*) AS transaction_count,
        SUM(is_fraud) AS fraud_count,
        COUNT(DISTINCT customer_key)
            AS unique_customers,
        COUNT(DISTINCT merchant_name)
            AS unique_merchants,
        SUM(amount) AS total_amount,
        COALESCE(
            SUM(amount) FILTER (WHERE is_fraud = 1),
            0
        ) AS fraud_amount
    FROM transactions
    GROUP BY state
)

SELECT
    *,
    ROUND(100.0 * fraud_count / NULLIF(transaction_count, 0), 2)
        AS fraud_rate
FROM state_metrics
