{{ config(
    materialized='table'
) }}

WITH transactions AS (
    SELECT
        transaction_date,
        state,
        amount,
        amount_segment
    FROM {{ ref('stg_transactions') }}
),

daily_metrics AS (
    SELECT
        transaction_date,
        state,
        COUNT(*) AS transaction_count,
        SUM(amount) AS total_amount,
        ROUND(AVG(amount), 2) AS avg_amount,
        ROUND(
            QUANTILE_CONT(amount, 0.95),
            2
        ) AS p95_amount,
        COUNT(*) FILTER (WHERE amount_segment IN ('HIGH', 'VERY_HIGH'))
            AS large_transaction_count
    FROM transactions
    GROUP BY
        transaction_date,
        state
)

SELECT
    *,
    ROUND(100.0 * large_transaction_count / NULLIF(transaction_count, 0), 2)
        AS large_transaction_share
FROM daily_metrics
