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
