-- FINAL DATA VALIDATION
-- (Confirm dataset is analysis-ready)
-- Final sanity check on cleaned and derived data
-- Purpose: Validate order count, SLA breaches, and peak hour volume
-- Why needed: Ensures all business logic was applied correctly
SELECT
    COUNT(*) AS total_orders,
    SUM(sla_breach_flag) AS sla_breaches,
    SUM(peak_hour_flag) AS peak_orders
FROM raw_orders;

-- View a sample of the cleaned and enriched dataset
-- Purpose: Visually confirm that raw, cleaned, and derived columns exist together

SELECT
    order_id,
    order_date,
    clean_order_date,
    time_ordered,
    delivery_duration,
    sla_breach_flag,
    peak_hour_flag,
    city
FROM raw_orders
LIMIT 20 ;


-- Ensure no critical NULLs remain in analytical columns
-- Purpose: Confirm dataset is safe for KPI calculations

SELECT
    COUNT(*) AS total_orders,
    SUM(clean_order_date IS NULL) AS null_dates,
    SUM(delivery_duration IS NULL) AS null_delivery_time,
    SUM(sla_breach_flag IS NULL) AS null_sla_flags
FROM raw_orders;


-- Re-enable safe update mode after completing data cleaning
SET SQL_SAFE_UPDATES = 1;


-- High-level business metrics
-- Purpose: Get a first sense of delivery performance

SELECT
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_duration)<2) AS avg_delivery_time,
    SUM(sla_breach_flag) AS total_sla_breaches,
    ROUND(SUM(sla_breach_flag)*100.0/COUNT(*), 2) AS sla_breach_percentage
FROM raw_orders;