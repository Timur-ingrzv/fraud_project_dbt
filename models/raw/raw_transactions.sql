{{ config(
    materialized='view'
) }}

SELECT
    post_code,
    transaction_time,
    merch,
    cat_id,
    amount,
    name_1,
    name_2,
    gender,
    street,
    one_city,
    us_state,
    lat,
    lon,
    population_city,
    jobs,
    merchant_lat,
    merchant_lon,
    target
FROM READ_CSV('data/train.csv', header = true)
