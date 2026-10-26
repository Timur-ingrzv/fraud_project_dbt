{{ config(
    materialized='table'
) }}

WITH transactions AS (
    SELECT
        customer_key,
        transaction_timestamp,
        amount,
        is_fraud
    FROM {{ ref('stg_transactions') }}
),

customer_metrics AS (
    SELECT
        customer_key,
        COUNT(*) AS transaction_count,
        SUM(is_fraud) AS fraud_count,
        ROUND(AVG(amount), 2) AS avg_amount,
        SUM(amount) AS total_amount,
        MIN(transaction_timestamp)
            AS first_transaction,
        MAX(transaction_timestamp)
            AS last_transaction
    FROM transactions
    GROUP BY customer_key

),

risk_metrics AS (
    SELECT
        *,
        ROUND(100.0 * fraud_count / NULLIF(transaction_count, 0), 2)
            AS fraud_rate
    FROM customer_metrics
)

SELECT
    *,
    CASE
        WHEN fraud_rate >= 10 THEN 'HIGH'
        WHEN fraud_rate >= 1 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS risk_level
FROM risk_metrics
