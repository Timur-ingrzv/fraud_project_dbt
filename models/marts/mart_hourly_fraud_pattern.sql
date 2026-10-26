{{ config(
    materialized='table'
) }}

WITH transactions AS (
    SELECT
        day_of_week,
        transaction_hour,
        amount,
        is_fraud
    FROM {{ ref('stg_transactions') }}
),

hourly_metrics AS (
    SELECT
        day_of_week,
        transaction_hour,
        COUNT(*) AS transaction_count,
        SUM(is_fraud) AS fraud_count,
        SUM(amount) AS total_amount,
        COALESCE(
            SUM(amount) FILTER (WHERE is_fraud = 1),
            0
        ) AS fraud_amount
    FROM transactions
    GROUP BY
        day_of_week,
        transaction_hour
)

SELECT
    *,
    ROUND(100.0 * fraud_count / NULLIF(transaction_count, 0), 2)
        AS fraud_rate
FROM hourly_metrics
