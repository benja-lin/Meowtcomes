WITH source AS (
    SELECT * FROM main.raw_intakes
)

SELECT strftime(cast(datetime AS DATE), '%Y-%m-%d') as intake_date,
    animal_id,
    CASE WHEN animal_type = 'Dog' THEN 'Dog'
        WHEN animal_type = 'Puppy' THEN 'Dog'
        WHEN animal_type = 'Cat' THEN 'Cat'
        WHEN animal_type = 'Kitten' THEN 'Cat'
        ELSE 'Other' 
        END AS category,
    animal_type AS type,
    CASE WHEN sex_upon_intake LIKE '%Intact%' THEN 'no'
        WHEN sex_upon_intake LIKE '%Spayed%' THEN 'yes'
        WHEN sex_upon_intake LIKE '%Neutered%' THEN 'yes'
        ELSE 'unknown'
        END AS is_spayed,
    CASE WHEN sex_upon_intake LIKE '%Male%' THEN 'Male'
        WHEN sex_upon_intake LIKE '%Female%' THEN 'Female'
        ELSE 'unknown'
        END AS sex,
    breed,
    color,
    strftime(cast(datetime2 AS DATE), '%Y-%m-%d') AS dob,
    age_upon_intake AS age,
    found_location AS location,
    strftime(cast(datetime as timestamp), '%H:%M:%S') as intake_time,
    name,
    intake_condition AS health
FROM source