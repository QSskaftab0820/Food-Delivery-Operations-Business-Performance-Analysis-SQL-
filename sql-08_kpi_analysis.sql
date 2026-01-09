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

