SELECT
    transaction_date,
    us_state,
    COUNT(*) AS row_count
FROM {{ ref('mart_daily_state_metrics') }}
GROUP BY
    transaction_date,
    us_state
HAVING COUNT(*) > 1