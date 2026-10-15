EXPLAIN (ANALYZE, BUFFERS)
SELECT
    p.patient_id,
    p.name,
    t.tracker_name,
    f.brand_name,
    f.model_name,
    f.selling_price,
    f.rating
FROM patients p
JOIN tracker_models t
    ON p.tracker_id = t.tracker_id
LEFT JOIN fitness_tracker_catalog f
    ON t.tracker_id = f.tracker_id
ORDER BY p.patient_id
LIMIT 20;
