{{ config(
    materialized='table'
) }}

WITH transactions AS (
    SELECT
        category,
        amount,
        is_fraud
    FROM {{ ref('stg_transactions') }}
),

category_metrics AS (
    SELECT
        category,
        COUNT(*) AS transaction_count,
        SUM(is_fraud) AS fraud_count,
        SUM(amount) AS total_amount,
        SUM(amount) FILTER (
            WHERE is_fraud = 1
        ) AS fraud_amount
    FROM transactions
    GROUP BY category
),

final AS (
    SELECT
        category,
        transaction_count,
        fraud_count,
        total_amount,
        COALESCE(fraud_amount, 0) AS fraud_amount,
        ROUND(100.0 * fraud_count / NULLIF(transaction_count, 0), 2) AS fraud_rate
    FROM category_metrics
)

SELECT *
FROM final
