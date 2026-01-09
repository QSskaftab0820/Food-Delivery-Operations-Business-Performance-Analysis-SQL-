
-- Validate delivery time conversion
-- Purpose: Ensure raw and cleaned delivery times align correctly
-- Why needed: Prevents incorrect SLA or delivery performance analysis

SELECT time_taken_min, delivery_duration
FROM raw_orders
LIMIT 10;

-- DATA QUALITY CHECKS
-- Check completeness of critical analytical columns
-- Purpose: Verify that cleaned columns contain valid values
-- Why needed: NULLs in key columns can break KPI calculations

SELECT
    COUNT(*) AS total_rows,
    COUNT(delivery_duration) AS valid_delivery_times,
    COUNT(clean_order_date) AS valid_order_dates
FROM raw_orders;


-- Check Delivery Time Range
-- Analyze delivery time distribution
-- Purpose: Identify unreasonable minimum or maximum values
-- Why needed: Detects data errors or extreme outliers

SELECT
    MIN(delivery_duration) AS min_time,
    MAX(delivery_duration) AS max_time,
    AVG(delivery_duration) AS avg_time
FROM raw_orders;



-- Handle Missing Values (Analyst Decision)
-- (Business-driven data imputation)
-- Fill missing delivery person age

-- Replace NULL delivery_person_age values with the average age
-- Purpose: Maintain dataset completeness without dropping records
-- Why needed: NULL values can distort aggregations and segmentation

UPDATE raw_orders
JOIN (
    SELECT ROUND(AVG(delivery_person_age)) AS avg_age
    FROM raw_orders
    WHERE delivery_person_age IS NOT NULL
) AS avg_table
SET raw_orders.delivery_person_age = avg_table.avg_age
WHERE raw_orders.delivery_person_age IS NULL;


-- Fill missing delivery person ratings
-- Replace NULL delivery_person_ratings values with the average rating
-- Purpose: Ensure rating-based analysis is not biased by missing values
-- Why needed: Ratings are often used for performance evaluation

UPDATE raw_orders
JOIN (
    SELECT ROUND(AVG(delivery_person_ratings),2) AS avg_rating
    FROM raw_orders
    WHERE delivery_person_ratings IS NOT NULL
) AS rating_table
SET raw_orders.delivery_person_ratings = rating_table.avg_rating
WHERE raw_orders.delivery_person_ratings IS NULL;

-- Handle missing categorical values
-- Replace missing weather conditions with 'Unknown'
-- Purpose: Preserve records while clearly identifying missing information
-- Why needed: Avoids NULL filtering issues in group-by analysis

UPDATE raw_orders
SET weather_conditions = 'Unknown'
WHERE weather_conditions IS NULL;


-- Replace missing traffic density values with 'Unknown'
-- Purpose: Standardize categorical values for analysis
-- Why needed: Prevents incorrect grouping or filtering

UPDATE raw_orders
SET road_traffic_density = 'Unkown'
WHERE road_traffic_density IS NULL;


-- Replace missing festival flag with 'No'
-- Purpose: Assume non-festival days where information is missing
-- Why needed: Enables festival vs non-festival analysis

UPDATE raw_orders
SET festival = 'No'
WHERE festival IS NULL;

-- BUSINESS LOGIC FLAGS
-- (Translate business rules into data features)
-- SLA Breach Flag (SLA = 40 minutes) SERVICE LEVEL AGREEMENT
-- Add SLA breach flag column
-- Purpose: Identify deliveries that exceeded the service level agreement
-- Why needed: Core KPI for delivery performance analysis

ALTER TABLE raw_orders
ADD sla_breach_flag BOOLEAN;


-- Mark orders where delivery time exceeded SLA
-- Purpose: Create a binary indicator for SLA violations
-- Why needed: Enables SLA breach rate calculation
UPDATE raw_orders
SET sla_breach_flag = delivery_duration > 40;

-- Peak Hour Flag (7–9 PM)
-- Add peak hour indicator column
-- Purpose: Identify high-demand time windows
-- Why needed: Supports peak vs non-peak performance analysis

ALTER TABLE raw_orders
ADD peak_hour_flag BOOLEAN;

-- Flag orders placed during peak hours (7 PM to 9 PM)
-- Purpose: Analyze delivery delays and SLA breaches during high traffic
-- Why needed: Peak-hour performance is critical for operations planning

UPDATE raw_orders
SET peak_hour_flag =
    HOUR(time_ordered) BETWEEN 19 AND 21;