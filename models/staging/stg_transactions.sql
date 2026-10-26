{{ config(
    materialized='view'
) }}

WITH source_data AS (
    SELECT *
    FROM {{ source('transactions_db', 'transactions') }}
),

cleaned AS (
    SELECT
        transaction_time AS transaction_timestamp,
        trimBoth(merch) AS merchant_name,
        trimBoth(cat_id) AS category,
        toDecimal64(amount, 2) AS amount,
        trimBoth(name_1) AS first_name,
        trimBoth(name_2) AS last_name,
        upper(trimBoth(gender)) AS gender,
        trimBoth(street) AS street,
        trimBoth(one_city) AS city,
        upper(trimBoth(us_state)) AS us_state,
        post_code,
        lat AS latitude,
        lon AS longitude,
        population_city AS city_population,
        trimBoth(jobs) AS job,
        merchant_lat AS merchant_latitude,
        merchant_lon AS merchant_longitude,
        toUInt8(target) AS is_fraud
    FROM source_data
),

final AS (
    SELECT
        *,
        toDate(transaction_timestamp)
            AS transaction_date,
        toHour(transaction_timestamp)
            AS transaction_hour,
        toDayOfWeek(transaction_timestamp) % 7
            AS day_of_week,
        {{ amount_bucket('amount') }}
            AS amount_segment,
        hex(
            SHA256(
                concat(
                    lowerUTF8(first_name),
                    '|',
                    lowerUTF8(last_name)
                )
            )
        ) AS customer_key
    FROM cleaned
)

SELECT *
FROM final
