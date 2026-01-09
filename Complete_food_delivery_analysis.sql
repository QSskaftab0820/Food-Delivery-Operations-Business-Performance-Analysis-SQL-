-- Display all existing databases on the MySQL server
-- Used to verify whether the project database already exists
show databases;


-- Create a new dedicated database for the food delivery analytics project
-- This keeps project data isolated and avoids interference with other databases
create database food_delivery_analytics;



-- Set the newly created database as the active working database
-- All subsequent tables and queries will be executed within this database
use food_delivery_analytics;



-- Create a staging (raw) table to store food delivery order data
-- This table holds the data exactly as received from the source CSV
-- No cleaning or transformations are applied directly to this table
-- It serves as the single source of truth for all downstream analysis

CREATE TABLE raw_orders (
    -- Unique identifier for each order (from source data)
    order_id VARCHAR(20),

    -- Unique identifier for the delivery person handling the order
    delivery_person_id VARCHAR(30),

    -- Age of the delivery person (may contain NULLs in raw data)
    delivery_person_age INT,

    -- Customer rating of the delivery person
    delivery_person_ratings FLOAT,

    -- Latitude of the restaurant location
    restaurant_latitude FLOAT,

    -- Longitude of the restaurant location
    restaurant_longitude FLOAT,

    -- Latitude of the delivery destination
    delivery_location_latitude FLOAT,

    -- Longitude of the delivery destination
    delivery_location_longitude FLOAT,

    -- Date when the order was placed
    order_date VARCHAR(10),

    -- Time when the order was placed by the customer
    time_ordered TIME,

    -- Time when the order was picked up by the delivery person
    time_order_picked TIME,

    -- Weather conditions at the time of delivery
    weather_conditions VARCHAR(50),

    -- Traffic density during delivery (e.g., Low, Medium, High, Jam)
    road_traffic_density VARCHAR(30),

    -- Condition of the delivery vehicle (rating scale)
    vehicle_condition INT,

    -- Type of order (e.g., Snack, Meal, Drinks)
    type_of_order VARCHAR(30),

    -- Type of vehicle used for delivery (e.g., Bike, Scooter)
    type_of_vehicle VARCHAR(30),

    -- Number of multiple deliveries handled in a single trip
    multiple_deliveries INT,

    -- Indicates whether the order was placed during a festival
    festival VARCHAR(10),

    -- City where the order was delivered
    city VARCHAR(30),

    -- Delivery time stored as text in the source (e.g., '(min) 30')
    -- This will be cleaned and converted to a numeric field later
    time_taken_min VARCHAR(20)
);


-- Count total number of rows in the raw_orders table
-- Purpose: Verify that the CSV file was fully imported into the database
-- Why needed: Confirms data ingestion is successful and no rows are missing

SELECT COUNT(*) AS total_rows
FROM raw_orders;


-- Preview a small sample of the raw data
-- Purpose: Visually inspect the structure and values of the dataset
-- Why needed: Helps understand what one row represents and spot obvious issues

SELECT *
FROM raw_orders
LIMIT 10;


-- Display column names and data types of the raw_orders table
-- Purpose: Understand how MySQL interpreted the CSV columns
-- Why needed: Identifies columns stored as VARCHAR that may need cleaning

DESCRIBE raw_orders;


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

-- Create an ANALYTICS TABLE (Optional but Professional)
-- Why?
    -- Faster queries
    -- Cleaner logic
    -- Separation of concerns
    
CREATE TABLE orders_analytics AS
SELECT
	order_id,
	clean_order_date,
	time_ordered,
	delivery_duration,
	sla_breach_flag,
	peak_hour_flag,
	city,
	weather_conditions,
	road_traffic_density
FROM raw_orders;



-- Start KPI Analysis (CORE ANALYST WORK)
-- These are the first real questions analysts answer:
-- 1. Average delivery time by city
-- 2. SLA breach rate by city
-- 3. Peak vs non-peak performance
-- 4. Delivery time trend by day
-- 5. Impact of traffic & weather

-- KPI ANALYSIS (Using raw_orders)
-- Goal: Measure delivery performance, identify problem areas, and generate business insights.

-- KPI 1: Total Orders & Overall Delivery Performance
-- High-level operational KPIs
-- Purpose: Understand overall business volume and delivery efficiency
-- Why needed: Establishes a baseline before deep-dive analysis

SELECT
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_duration),2) AS avg_delivery_time,
    SUM(sla_breach_flag) AS total_sla_breaches,
    ROUND(SUM(sla_breach_flag) * 100.0/ COUNT(*),2) AS sla_breach_percentage
FROM raw_orders;

-- KPI 2: City-wise Delivery Performance
-- City-level delivery performance
-- Purpose: Identify cities with poor delivery efficiency
-- Why needed: Operations and staffing decisions are made city-wise

SELECT
    city,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_duration),2) AS avg_delivery_time,
    ROUND(SUM(sla_breach_flag) * 100.0 / COUNT(*),2) AS sla_breach_percentage
FROM raw_orders
GROUP BY city
ORDER BY sla_breach_percentage DESC;

-- Insight We are looking for
   -- 1)Is average delivery time above SLA?
   -- 2)What % of orders are failing SLA?
   
-- KPI 2: City-wise Delivery Performance

SELECT
    city,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_duration),2) AS avg_delivery_time,
    ROUND(SUM(sla_breach_flag) * 100.0/COUNT(*),2) AS sla_breach_percentage
FROM raw_orders
GROUP BY city
ORDER BY sla_breach_percentage DESC;

-- Business question answered
   -- Which cities contribute most to delivery delays?

-- KPI 3: Peak Hour vs Non-Peak Hour Performance

-- Peak vs non-peak hour comparison
-- Purpose: Measure operational strain during high-demand periods
-- Why needed: Peak-hour optimization is critical for food delivery platforms

SELECT
    peak_hour_flag,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_duration), 2) AS avg_delivery_time,
    ROUND(SUM(sla_breach_flag) * 100.0 / COUNT(*), 2) AS sla_breach_percentage
FROM raw_orders
GROUP BY peak_hour_flag;

-- How to interpret
   -- peak_hour_flag = 1 → Peak hours (7–9 PM)
   -- Compare delivery time & SLA breaches vs non-peak

-- KPI 4: Delivery Time Trend Over Time (Daily)
-- Daily delivery performance trend
-- Purpose: Identify days with abnormal delivery delays
-- Why needed: Helps detect operational issues or external factors

SELECT
    clean_order_date,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_duration), 2) AS avg_delivery_time
FROM raw_orders
GROUP BY clean_order_date
ORDER BY clean_order_date;

-- Insight
      -- Spikes indicate incidents, demand surges, or staffing issues
  

-- KPI 5: Impact of Traffic Conditions
-- Delivery performance by traffic condition
-- Purpose: Quantify how traffic congestion affects delivery time
-- Why needed: Supports routing and ETA adjustment decisions

SELECT
    road_traffic_density,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_duration), 2) AS avg_delivery_time,
    ROUND(SUM(sla_breach_flag) * 100.0 / COUNT(*), 2) AS sla_breach_percentage
FROM raw_orders
GROUP BY road_traffic_density
ORDER BY avg_delivery_time DESC;

-- Business insight
      -- High traffic → higher delivery time → higher SLA breaches


-- KPI 6: Impact of Weather Conditions
-- Delivery performance by weather condition
-- Purpose: Understand weather-related delivery risks
-- Why needed: Helps set realistic ETAs during adverse conditions

SELECT
    weather_conditions,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_duration), 2) AS avg_delivery_time,
    ROUND(SUM(sla_breach_flag) * 100.0 / COUNT(*), 2) AS sla_breach_percentage
FROM raw_orders
GROUP BY weather_conditions
ORDER BY avg_delivery_time DESC;

-- KPI 7: Delivery Partner Performance (Optional but Strong)
-- Delivery partner performance analysis
-- Purpose: Identify delivery partners with consistently slow deliveries
-- Why needed: Supports training, incentives, or corrective actions

SELECT
    delivery_person_id,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_duration), 2) AS avg_delivery_time,
    ROUND(SUM(sla_breach_flag) * 100.0 / COUNT(*), 2) AS sla_breach_percentage
FROM raw_orders
GROUP BY delivery_person_id
HAVING COUNT(*) >= 30
ORDER BY avg_delivery_time DESC;


-- Check how many orders each delivery person has handled
-- Purpose: Understand order distribution per delivery partner

SELECT
    delivery_person_id,
    COUNT(*) AS total_orders
FROM raw_orders
GROUP BY delivery_person_id
ORDER BY total_orders DESC
LIMIT 10;

