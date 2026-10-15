SET LOCAL enable_seqscan = off;

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    m.medical_conditions,
    COUNT(*) AS total_patients
FROM medical_profiles m
GROUP BY m.medical_conditions
ORDER BY total_patients DESC;

SET LOCAL enable_seqscan = on;