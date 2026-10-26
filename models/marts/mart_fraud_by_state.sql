{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by=['us_state']
) }}

WITH state_metrics AS (
    SELECT
        us_state,
        count() AS transaction_count,
        sum(is_fraud) AS fraud_count,
        uniqExact(customer_key) AS unique_customers,
        uniqExact(merchant_name) AS unique_merchants,
        sum(amount) AS total_amount,
        sumIf(amount, is_fraud = 1)
            AS fraud_amount
    FROM {{ ref('stg_transactions') }}
    GROUP BY us_state
)

SELECT
    *,
    round(
        100.0 * fraud_count
        / nullIf(transaction_count, 0),
        2
    ) AS fraud_rate
FROM state_metrics
