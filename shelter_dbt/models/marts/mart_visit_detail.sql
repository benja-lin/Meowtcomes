WITH source AS (
    SELECT *
    FROM {{ ref('int_animals_joined') }}
)
SELECT *,
    CASE WHEN is_spayed = 'no' AND is_spayed_outcome = 'yes' THEN 'true'
        WHEN is_spayed = 'unknown' OR is_spayed_outcome = 'unknown' THEN 'unknown'
        ELSE 'false'
        END AS spayed_neutered_in_shelter,
    DATEDIFF('day', CAST(LAG(outcome_date) OVER (PARTITION BY animal_id ORDER BY visit_number) AS DATE), CAST(intake_date AS DATE)) AS days_since_last_visit
FROM source