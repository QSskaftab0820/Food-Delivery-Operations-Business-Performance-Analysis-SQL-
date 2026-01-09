-- Add a new column to store cleaned order date
-- Purpose: Prepare the dataset for time-based analysis (daily, monthly trends)
-- Why needed: Raw order_date is stored as text (DD-MM-YYYY) and cannot be used for date functions

ALTER TABLE raw_orders
ADD clean_order_date DATE;



-- Add a primary key to uniquely identify each order
-- This allows MySQL safe update mode to permit controlled updates

ALTER TABLE raw_orders
ADD PRIMARY KEY (order_id);

-- Disable MySQL safe update mode for the current session
-- This allows controlled bulk UPDATE operations during data cleaning

SET SQL_SAFE_UPDATES = 0;
-- You should see:(Query OK, 0 rows affected) This confirms Safe Updates is OFF.


-- Convert order_date from text format (DD-MM-YYYY) to DATE
-- clean_order_date is a derived column used for time-based analysis
UPDATE raw_orders
SET clean_order_date = STR_TO_DATE(order_date, '%d-%m-%Y')
WHERE clean_order_date IS NULL;


-- Validate date conversion
-- Purpose: Confirm that the transformation worked correctly
-- Why needed: Ensures no incorrect or NULL date conversions occurred

SELECT order_date, clean_order_date
FROM raw_orders
LIMIT 10;


-- CONVERT time_taken_min from text to integer
-- Add a new column to store delivery duration as a numeric value
-- Purpose: Enable mathematical operations such as averages and SLA checks
-- Why needed: Raw delivery time is stored as text (e.g., '(min) 30')

ALTER TABLE raw_orders
ADD delivery_duration INT;


-- Clean and convert delivery time from text to integer
-- Purpose: Remove '(min)' text and cast the remaining value to an integer
-- Why needed: Required for KPI calculations like average delivery time and SLA breaches

UPDATE raw_orders
SET delivery_duration =
    CAST(REPLACE(time_taken_min, '(min) ', '') AS UNSIGNED);
    