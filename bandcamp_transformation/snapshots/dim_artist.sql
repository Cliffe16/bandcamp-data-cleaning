{% snapshot dim_artist_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='artist_key',
        strategy='check', --for lack of a date column
        check_cols=['country']
        )
}}

WITH staging AS(
    SELECT * FROM {{ ref('stg_bandcamp_sales') }}
),
--Deduplicate the data so there is one row per artist_key
unique_artists AS(
    SELECT
        artist_key,
        artist_name,
        country,
        ROW_NUMBER() OVER (PARTITION BY artist_key ORDER BY utc_date DESC) AS rn
    FROM staging
)

SELECT * FROM unique_artists WHERE rn=1

{% endsnapshot %}
