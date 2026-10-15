
SELECT
    m.medical_conditions,
    COUNT(*) AS total_patients
FROM medical_profiles m
GROUP BY m.medical_conditions
ORDER BY total_patients DESC;
