{% snapshot dim_artist_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='artist_key',
        strategy='check', 
        check_cols=['country']
        )
}}

WITH staging AS(
    SELECT * FROM {{ ref('stg_bandcamp_sales') }}
),
--Deduplicate the data so there is one row per artist_key
unique_artists AS(
    SELECT
        {{ dbt_utils.generate_surrogate_key(['artist_name']) }} AS artist_key,
        artist_name,
        country,
        ROW_NUMBER() OVER (PARTITION BY artist_name ORDER BY utc_date DESC) AS rn
    FROM staging
)

SELECT * FROM unique_artists WHERE rn=1

{% endsnapshot %}
