{{ config(
    materialized='incremental',
    unique_key='sale_key'
    )
}}

WITH staging AS (
    SELECT * FROM {{ ref('stg_bandcamp_sales') }}
    -- Compare incoming date against max date in the target table
    {% if is_incremental() %}
    WHERE utc_date >= (SELECT dateadd(day, -3, max(sale_date) FROM {{ this }})
    {% endif %}

),

fact_sales AS (
    SELECT 
        sale_key,        
        id AS transaction_id,
        utc_date AS sale_date,
        country,
        -- Foreign Keys 
        {{ dbt_utils.generate_surrogate_key(['artist_name']) }} AS artist_key,
        {{ dbt_utils.generate_surrogate_key(['album_title', 'item_type', 'song_medium']) }} AS item_key,
        item_price_usd,
        discount_usd,
        amount_over_usd,
        amount_paid_usd

    FROM staging
)

SELECT * FROM fact_sales

