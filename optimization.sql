
CREATE INDEX IF NOT EXISTS idx_medical_conditions
ON medical_profiles (medical_conditions);

CREATE INDEX IF NOT EXISTS idx_watch_patients
ON medical_profiles (patient_id)
INCLUDE (medications, medical_conditions)
WHERE medical_conditions = 'Watch';

CREATE INDEX IF NOT EXISTS idx_patient_appointment
ON patients (last_appointment_date);

CREATE INDEX IF NOT EXISTS idx_patients_tracker
ON patients (tracker_id);

ANALYZE patients;
ANALYZE medical_profiles;
ANALYZE tracker_models;
ANALYZE fitness_tracker_catalog;
