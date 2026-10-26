{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by=['day_of_week', 'transaction_hour']
) }}

WITH hourly_metrics AS (
    SELECT
        day_of_week,
        transaction_hour,
        count() AS transaction_count,
        sum(is_fraud) AS fraud_count,
        sum(amount) AS total_amount,
        sumIf(amount, is_fraud = 1) AS fraud_amount
    FROM {{ ref('stg_transactions') }}
    GROUP BY
        day_of_week,
        transaction_hour
)

SELECT
    *,
    round(
        100.0 * fraud_count
        / nullIf(transaction_count, 0),
        2
    ) AS fraud_rate
FROM hourly_metrics
