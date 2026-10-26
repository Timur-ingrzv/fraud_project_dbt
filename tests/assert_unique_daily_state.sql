SELECT
    transaction_date,
    state,
    COUNT(*) AS row_count
FROM {{ ref('mart_daily_state_metrics') }}
GROUP BY
    transaction_date,
    state
HAVING COUNT(*) > 1