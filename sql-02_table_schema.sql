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
