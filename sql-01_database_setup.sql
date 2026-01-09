-- Display all existing databases on the MySQL server
-- Used to verify whether the project database already exists
show databases;


-- Create a new dedicated database for the food delivery analytics project
-- This keeps project data isolated and avoids interference with other databases
create database food_delivery_analytics;



-- Set the newly created database as the active working database
-- All subsequent tables and queries will be executed within this database
use food_delivery_analytics;