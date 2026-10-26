{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by=['transaction_date', 'us_state']
) }}

WITH daily_metrics AS (
    SELECT
        transaction_date,
        us_state,
        count() AS transaction_count,
        sum(amount) AS total_amount,
        round(avg(amount), 2) AS avg_amount,
        round(
            quantileExact(0.95) (amount),
            2
        ) AS p95_amount,
        countIf(
            amount_segment IN ('HIGH', 'VERY_HIGH')
        ) AS large_transaction_count
    FROM {{ ref('stg_transactions') }}
    GROUP BY
        transaction_date,
        us_state
)

SELECT
    *,
    round(
        100.0 * large_transaction_count
        / nullIf(transaction_count, 0),
        2
    ) AS large_transaction_share
FROM daily_metrics
