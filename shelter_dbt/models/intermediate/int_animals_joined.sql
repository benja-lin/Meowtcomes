WITH intakes AS (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY animal_id ORDER BY intake_date) as visit_number
    FROM {{ ref('stg_intakes') }}
),
outcomes AS (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY animal_id ORDER BY outcome_date) as visit_number
    FROM {{ ref('stg_outcomes')}}
)

SELECT i.intake_date,
    o.outcome_date,
    i.animal_id,
    i.category,
    i.type,
    i.is_spayed,
    i.sex,
    i.breed,
    i.color,
    i.dob,
    i.age,
    i.location,
    i.intake_time,
    i.visit_number,
    o.outcome_time,
    COALESCE(i.name, o.name) AS name,
    i.health,
    o.outcome_type,
    o.outcome_subtype,
    o.is_spayed AS is_spayed_outcome,
    MAX(i.visit_number) OVER (PARTITION BY i.animal_id) as total_visits,
    DATEDIFF('day', CAST(i.intake_date AS DATE), CAST(COALESCE(o.outcome_date, CAST(CURRENT_DATE AS VARCHAR)) AS DATE)) as days_in_shelter,
    MAX(i.visit_number) OVER (PARTITION BY i.animal_id) > 1 AS is_repeat_visitor
    FROM intakes i
    LEFT JOIN outcomes o ON i.animal_id = o.animal_id
        AND i.visit_number = o.visit_number