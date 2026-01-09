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