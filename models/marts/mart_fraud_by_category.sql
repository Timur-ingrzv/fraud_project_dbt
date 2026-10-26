{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by=['category']
) }}

WITH category_metrics AS (
    SELECT
        category,
        count() AS transaction_count,
        sum(is_fraud) AS fraud_count,
        sum(amount) AS total_amount,
        sumIf(amount, is_fraud = 1)
            AS fraud_amount
    FROM {{ ref('stg_transactions') }}
    GROUP BY category
)

SELECT
    *,
    round(
        100.0 * fraud_count
        / nullIf(transaction_count, 0),
        2
    ) AS fraud_rate
FROM category_metrics
