WITH staging AS (
    SELECT COUNT(*) AS total
    FROM {{ ref('stg_transactions') }}
),
mart AS (
    SELECT SUM(transaction_count) AS total
    FROM {{ ref('mart_fraud_by_state') }}

)
SELECT
    staging.total AS staging_count,
    mart.total AS mart_count
FROM staging
CROSS JOIN mart
WHERE staging.total IS DISTINCT FROM mart.total