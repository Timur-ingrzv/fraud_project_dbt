{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by=['merchant_name']
) }}

WITH merchant_metrics AS (
    SELECT
        merchant_name,
        count() AS transaction_count,
        uniqExact(customer_key) AS unique_customers,
        sum(amount) AS total_amount,
        round(avg(amount), 2) AS avg_amount,
        sum(is_fraud) AS fraud_count,
        sumIf(amount, is_fraud = 1) AS fraud_amount
    FROM {{ ref('stg_transactions') }}
    GROUP BY merchant_name
),

fraud_metrics AS (
    SELECT
        *,
        round(
            100.0 * fraud_count
            / nullIf(transaction_count, 0),
            2
        ) AS fraud_rate
    FROM merchant_metrics
)

SELECT
    *,
    if(
        transaction_count >= 20
        AND fraud_count >= 2
        AND fraud_rate >= 5,
        1,
        0
    ) AS is_suspicious
FROM fraud_metrics
