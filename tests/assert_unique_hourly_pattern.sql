SELECT
    day_of_week,
    transaction_hour,
    COUNT(*) AS row_count
FROM {{ ref('mart_hourly_fraud_pattern') }}
GROUP BY
    day_of_week,
    transaction_hour
HAVING COUNT(*) > 1