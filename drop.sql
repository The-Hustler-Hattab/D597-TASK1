
-- WGU D597 Task 1
-- HealthFit Innovations
-- Drop all project tables

BEGIN;

-- Drop staging tables
DROP TABLE IF EXISTS staging_medical_records;
DROP TABLE IF EXISTS staging_fitness_trackers;

-- Drop tables in foreign-key dependency order
DROP TABLE IF EXISTS fitness_tracker_catalog;
DROP TABLE IF EXISTS medical_profiles;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS tracker_models;

COMMIT;
