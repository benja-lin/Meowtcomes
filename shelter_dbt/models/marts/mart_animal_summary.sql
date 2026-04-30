 WITH first_visit AS (
    SELECT animal_id,
        category,
        type,
        breed,
        is_spayed AS is_spayed_intake,
        sex,
        color,
        dob,
        total_visits,
        location AS first_intake_location,
        age AS first_intake_age,
        intake_date AS first_intake_date,
        health AS first_intake_health
    FROM {{ ref('int_animals_joined') }}
    WHERE visit_number = 1
),
aggregated AS (
    SELECT animal_id,
        MAX(CASE WHEN outcome_type LIKE '%dopt%' THEN true ELSE false END) as ever_adopted,
        MAX(CASE WHEN visit_number = total_visits THEN outcome_date END) AS last_outcome_date,
        MAX (CASE WHEN visit_number = total_visits THEN outcome_type END) AS last_outcome_type,
        MAX (CASE WHEN visit_number = total_visits THEN outcome_subtype END) AS last_outcome_subtype,
        SUM(days_in_shelter) AS total_days_in_shelter,
        CASE WHEN MAX (CASE WHEN is_spayed = 'no' AND is_spayed_outcome = 'yes' THEN 1 END) = 1 THEN 'true'
            WHEN MAX(CASE WHEN is_spayed = 'unknown' OR is_spayed_outcome = 'unknown' THEN 1 END) = 1 THEN 'unknown'
            ELSE 'false'
        END AS spayed_neutered_in_shelter
    FROM {{ ref('int_animals_joined') }}
    GROUP BY animal_id
)
SELECT f.animal_id,
    f.category,
    f.type,
    f.breed,
    f.is_spayed_intake,
    f.sex,
    f.color,
    f.dob,
    f.first_intake_location,
    f.first_intake_date,
    f.first_intake_health,
    f.first_intake_age,
    f.total_visits,
    a.last_outcome_date,
    a.last_outcome_type,
    a.last_outcome_subtype,
    a.total_days_in_shelter,
    a.spayed_neutered_in_shelter
FROM first_visit f
LEFT JOIN aggregated a ON f.animal_id = a.animal_id