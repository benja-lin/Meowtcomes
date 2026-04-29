WITH source AS (
    SELECT * FROM main.raw_outcomes
)

SELECT strftime(cast(datetime AS DATE), '%Y-%m-%d') as outcome_date,
    animal_id,
    CASE WHEN animal_type = 'Dog' THEN 'Dog'
        WHEN animal_type = 'Puppy' THEN 'Dog'
        WHEN animal_type = 'Cat' THEN 'Cat'
        WHEN animal_type = 'Kitten' THEN 'Cat'
        ELSE 'Other' 
        END AS category,
    animal_type AS type,
    outcome_type,
    outcome_subtype,
    CASE WHEN sex_upon_outcome LIKE '%Intact%' THEN 'no'
        WHEN sex_upon_outcome LIKE '%Spayed%' THEN 'yes'
        WHEN sex_upon_outcome LIKE '%Neutered%' THEN 'yes'
        ELSE 'unknown'
        END AS is_spayed,
    CASE WHEN sex_upon_outcome LIKE '%Male%' THEN 'Male'
        WHEN sex_upon_outcome LIKE '%Female%' THEN 'Female'
        ELSE 'unknown'
        END AS sex,
    breed,
    color,
    strftime(cast(date_of_birth AS DATE), '%Y-%m-%d') AS dob,
    age_upon_outcome AS age,
    strftime(cast(datetime as timestamp), '%H:%M:%S') as outcome_time,
    name,
FROM source