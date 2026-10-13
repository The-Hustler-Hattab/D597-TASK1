
-- WGU D597 Task 1
-- HealthFit Innovations
-- Scenario 1: Medical Records and Fitness Trackers

-- 1. Tracker Models
CREATE TABLE IF NOT EXISTS tracker_models (
    tracker_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tracker_name VARCHAR(150) NOT NULL UNIQUE
);

-- 2. Patients
CREATE TABLE IF NOT EXISTS patients (
    patient_id INTEGER PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(10),
    last_appointment_date DATE,
    tracker_id INTEGER,

    CONSTRAINT fk_patient_tracker
        FOREIGN KEY (tracker_id)
        REFERENCES tracker_models(tracker_id)
);

-- 3. Medical Profiles
CREATE TABLE IF NOT EXISTS medical_profiles (
    patient_id INTEGER PRIMARY KEY,
    medical_conditions VARCHAR(100),
    medications VARCHAR(10),
    allergies VARCHAR(255),

    CONSTRAINT fk_medical_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE CASCADE
);

-- 4. Fitness Tracker Catalog
CREATE TABLE IF NOT EXISTS fitness_tracker_catalog (
    catalog_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tracker_id INTEGER,
    brand_name VARCHAR(150),
    device_type VARCHAR(100),
    model_name VARCHAR(255),
    color VARCHAR(255),
    selling_price NUMERIC(12,2),
    original_price NUMERIC(12,2),
    display VARCHAR(150),
    rating NUMERIC(3,1),
    strap_material VARCHAR(150),
    average_battery_life_days INTEGER,
    reviews TEXT,

    CONSTRAINT fk_catalog_tracker
        FOREIGN KEY (tracker_id)
        REFERENCES tracker_models(tracker_id)
);

-- Index for catalog lookups by tracker
CREATE INDEX IF NOT EXISTS idx_catalog_tracker_id
ON fitness_tracker_catalog(tracker_id);
