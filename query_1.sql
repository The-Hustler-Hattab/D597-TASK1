

SELECT
    p.patient_id,
    p.name,
    m.medical_conditions,
    m.medications,
    p.last_appointment_date
FROM patients p
JOIN medical_profiles m
    ON p.patient_id = m.patient_id
WHERE m.medical_conditions = 'Watch'
ORDER BY p.last_appointment_date ASC;
