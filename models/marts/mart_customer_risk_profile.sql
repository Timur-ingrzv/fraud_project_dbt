{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by=['customer_key']
) }}

WITH customer_metrics AS (

    SELECT
        customer_key,
        count() AS transaction_count,
        sum(is_fraud) AS fraud_count,
        round(avg(amount), 2) AS avg_amount,
        sum(amount) AS total_amount,
        min(transaction_timestamp)
            AS first_transaction,
        max(transaction_timestamp)
            AS last_transaction
    FROM {{ ref('stg_transactions') }}
    GROUP BY customer_key
),

risk_metrics AS (
    SELECT
        *,
        round(
            100.0 * fraud_count
            / nullIf(transaction_count, 0),
            2
        ) AS fraud_rate

    FROM customer_metrics

)

SELECT
    *,
    multiIf(
        fraud_rate >= 10, 'HIGH',
        fraud_rate >= 1, 'MEDIUM',
        'LOW'
    ) AS risk_level
FROM risk_metrics
