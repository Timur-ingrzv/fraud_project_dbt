{{ config(
    materialized='view'
) }}

WITH source_data AS (
    SELECT *
    FROM {{ ref('raw_transactions') }}
),

cleaned AS (
    SELECT
        CAST(post_code AS VARCHAR) AS post_code,
        TRY_CAST(transaction_time AS TIMESTAMP) AS transaction_timestamp,
        TRIM(merch) AS merchant_name,
        TRIM(cat_id) AS category,

        TRY_CAST(amount AS DECIMAL(18, 2))
            AS amount,
        TRIM(name_1) AS first_name,

        TRIM(name_2) AS last_name,

        UPPER(TRIM(gender)) AS gender,
        TRIM(street) AS street,
        TRIM(one_city) AS city,
        UPPER(TRIM(us_state)) AS state,
        TRY_CAST(lat AS DOUBLE) AS latitude,
        TRY_CAST(lon AS DOUBLE) AS longitude,

        TRY_CAST(population_city AS BIGINT)
            AS city_population,
        TRIM(jobs) AS job,
        TRY_CAST(merchant_lat AS DOUBLE)
            AS merchant_latitude,
        TRY_CAST(merchant_lon AS DOUBLE)
            AS merchant_longitude,
        TRY_CAST(target AS INTEGER) AS is_fraud

    FROM source_data
),

final AS (
    SELECT
        *,
        CAST(transaction_timestamp AS DATE)
            AS transaction_date,
        EXTRACT(HOUR FROM transaction_timestamp)
            AS transaction_hour,
        EXTRACT(DOW FROM transaction_timestamp)
            AS day_of_week,
        {{ amount_bucket('amount') }}
            AS amount_segment,
        SHA256(
            CONCAT_WS(
                '|',
                COALESCE(first_name, ''),
                COALESCE(last_name, ''),
                COALESCE(street, ''),
                COALESCE(city, ''),
                COALESCE(state, ''),
                COALESCE(post_code, '')
            )
        ) AS customer_key

    FROM cleaned
)

SELECT *
FROM final
