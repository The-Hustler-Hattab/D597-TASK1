-- WGU D597 Task 1 

BEGIN;

-- 1. Load medical CSV into a staging table (all TEXT to preserve source values).
CREATE TABLE IF NOT EXISTS staging_medical_records (
    patient_id TEXT,
    name TEXT,
    date_of_birth TEXT,
    gender TEXT,
    medical_conditions TEXT,
    medications TEXT,
    allergies TEXT,
    last_appointment_date TEXT,
    tracker TEXT
);

TRUNCATE TABLE staging_medical_records;

COPY staging_medical_records (
    patient_id, name, date_of_birth, gender, medical_conditions,
    medications, allergies, last_appointment_date, tracker
)
FROM '/tmp/3_medical_records.csv'
WITH (FORMAT CSV, HEADER TRUE);

-- 2. Load fitness tracker CSV into its own staging table.
CREATE TABLE IF NOT EXISTS staging_fitness_trackers (
    brand_name TEXT,
    device_type TEXT,
    model_name TEXT,
    color TEXT,
    selling_price TEXT,
    original_price TEXT,
    display TEXT,
    rating TEXT,
    strap_material TEXT,
    average_battery_life_days TEXT,
    reviews TEXT
);

TRUNCATE TABLE staging_fitness_trackers;

COPY staging_fitness_trackers (
    brand_name, device_type, model_name, color, selling_price,
    original_price, display, rating, strap_material,
    average_battery_life_days, reviews
)
FROM '/tmp/1_Fitness_trackers.csv'
WITH (FORMAT CSV, HEADER TRUE);

-- 3. Insert unique tracker names from the patient dataset.
-- Patients references tracker_models, so load this table first.
INSERT INTO tracker_models (tracker_name)
SELECT DISTINCT BTRIM(tracker)
FROM staging_medical_records
WHERE NULLIF(BTRIM(tracker), '') IS NOT NULL
ON CONFLICT (tracker_name) DO NOTHING;

-- 4. Insert/update patient records.
INSERT INTO patients (
    patient_id, name, date_of_birth, gender, last_appointment_date, tracker_id
)
SELECT
    BTRIM(s.patient_id)::INTEGER,
    BTRIM(s.name),
    TO_DATE(BTRIM(s.date_of_birth), 'MM/DD/YYYY'),
    NULLIF(BTRIM(s.gender), ''),
    TO_DATE(BTRIM(s.last_appointment_date), 'MM/DD/YYYY'),
    t.tracker_id
FROM staging_medical_records AS s
LEFT JOIN tracker_models AS t ON t.tracker_name = BTRIM(s.tracker)
ON CONFLICT (patient_id) DO UPDATE SET
    name = EXCLUDED.name,
    date_of_birth = EXCLUDED.date_of_birth,
    gender = EXCLUDED.gender,
    last_appointment_date = EXCLUDED.last_appointment_date,
    tracker_id = EXCLUDED.tracker_id;

-- 5. Insert/update medical profiles.
INSERT INTO medical_profiles (patient_id, medical_conditions, medications, allergies)
SELECT
    BTRIM(patient_id)::INTEGER,
    NULLIF(BTRIM(medical_conditions), ''),
    NULLIF(BTRIM(medications), ''),
    NULLIF(BTRIM(allergies), '')
FROM staging_medical_records
ON CONFLICT (patient_id) DO UPDATE SET
    medical_conditions = EXCLUDED.medical_conditions,
    medications = EXCLUDED.medications,
    allergies = EXCLUDED.allergies;

-- 6. Refresh catalog records from the second dataset.
TRUNCATE TABLE fitness_tracker_catalog RESTART IDENTITY;
INSERT INTO fitness_tracker_catalog (
    tracker_id, brand_name, device_type, model_name, color,
    selling_price, original_price, display, rating, strap_material,
    average_battery_life_days, reviews
)
SELECT
    t.tracker_id,
    NULLIF(BTRIM(s.brand_name), ''),
    NULLIF(BTRIM(s.device_type), ''),
    NULLIF(BTRIM(s.model_name), ''),
    NULLIF(BTRIM(s.color), ''),
    NULLIF(REPLACE(BTRIM(s.selling_price), ',', ''), '')::NUMERIC(12,2),
    NULLIF(REPLACE(BTRIM(s.original_price), ',', ''), '')::NUMERIC(12,2),
    NULLIF(BTRIM(s.display), ''),
    NULLIF(BTRIM(s.rating), '')::NUMERIC(3,1),
    NULLIF(BTRIM(s.strap_material), ''),
    NULLIF(BTRIM(s.average_battery_life_days), '')::INTEGER,
    NULLIF(BTRIM(s.reviews), '')
FROM staging_fitness_trackers AS s
LEFT JOIN tracker_models AS t
    ON LOWER(BTRIM(s.model_name)) = LOWER(BTRIM(t.tracker_name));

COMMIT;


----------------------verification queries----------------------
SELECT
    p.patient_id,
    p.name,
    p.date_of_birth,
    m.medical_conditions,
    m.medications,
    m.allergies,
    t.tracker_name
FROM patients p
JOIN medical_profiles m
    ON p.patient_id = m.patient_id
LEFT JOIN tracker_models t
    ON p.tracker_id = t.tracker_id
ORDER BY p.patient_id
LIMIT 20;



SELECT 'patients' AS table_name, COUNT(*) AS total
FROM patients
UNION ALL
SELECT 'medical_profiles', COUNT(*)
FROM medical_profiles
UNION ALL
SELECT 'tracker_models', COUNT(*)
FROM tracker_models
UNION ALL
SELECT 'fitness_tracker_catalog', COUNT(*)
FROM fitness_tracker_catalog;

