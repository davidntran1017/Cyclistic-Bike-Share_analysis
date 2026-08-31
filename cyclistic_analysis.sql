-- =========================================
-- Cyclistic Bike Share Case Study
-- Author: David Tran
-- Purpose: Analyze differences between
-- casual riders and annual members
-- =========================================

-- =========================================
-- STEP 0: Create raw table structure
-- Purpose:
-- Create a table matching the Divvy CSV schema
-- before importing data.
-- =========================================

CREATE TABLE bike_trips (
ride_id TEXT,
rideable_type TEXT,
started_at TIMESTAMP,
ended_at TIMESTAMP,
start_station_name TEXT,
start_station_id TEXT,
end_station_name TEXT,
end_station_id TEXT,
start_lat DOUBLE PRECISION,
start_lng DOUBLE PRECISION,
end_lat DOUBLE PRECISION,
end_lng DOUBLE PRECISION,
member_casual TEXT
);

-- =========================================
-- STEP 1: Verify data import
-- Purpose:
-- Confirm all rows imported successfully.
-- Expected result:
-- ~5.6 million rows.
-- =========================================

SELECT COUNT(*)
FROM bike_trips;

-- =========================================
-- STEP 2: Verify rider types
-- Purpose:
-- Confirm only two rider categories exist
-- and understand dataset composition.
-- =========================================

SELECT
member_casual,
COUNT(*)
FROM bike_trips
GROUP BY member_casual;

-- Result:
-- casual = 2,064,286
-- member = 3,564,561

-- =========================================
-- STEP 3: Inspect bike types
-- Purpose:
-- Understand available bike categories.
-- Useful later for rider preference analysis.
-- =========================================

SELECT
rideable_type,
COUNT(*)
FROM bike_trips
GROUP BY rideable_type;

-- =========================================
-- STEP 4: Inspect imported records
-- Purpose:
-- Verify data loaded correctly and
-- identify potential null values.
-- =========================================

SELECT *
FROM bike_trips
LIMIT 10;

-- =========================================
-- STEP 5: Create cleaned analytical dataset
-- Purpose:
-- Preserve raw data and create derived
-- features needed for analysis.
-- =========================================

CREATE TABLE bike_trips_clean AS
SELECT
*,
EXTRACT(EPOCH FROM (ended_at - started_at))/60 AS ride_length_minutes,
TRIM(TO_CHAR(started_at, 'Day')) AS day_of_week,
TRIM(TO_CHAR(started_at, 'Month')) AS month_name,
EXTRACT(MONTH FROM started_at) AS month_num,
EXTRACT(YEAR FROM started_at) AS year
FROM bike_trips;

-- =========================================
-- STEP 6: Verify cleaned table
-- Purpose:
-- Confirm all records copied successfully.
-- =========================================

SELECT COUNT(*)
FROM bike_trips_clean;

-- =========================================
-- STEP 7: Data quality checks
-- Purpose:
-- Examine ride duration distribution and
-- identify invalid rides.
-- =========================================

SELECT
MIN(ride_length_minutes),
MAX(ride_length_minutes),
ROUND(AVG(ride_length_minutes),2)
FROM bike_trips_clean;

SELECT COUNT(*)
FROM bike_trips_clean
WHERE ride_length_minutes <= 0;

-- Results:
-- Min ride length: -56.02 minutes
-- Max ride length: 1559.92 minutes
-- Average ride length: 16.63 minutes
-- Invalid rides <= 0 minutes: 43

-- =========================================
-- STEP 8: Create analysis table
-- Purpose:
-- Remove invalid rides with non-positive
-- ride durations.
-- =========================================

CREATE TABLE bike_trips_analysis AS
SELECT *
FROM bike_trips_clean
WHERE ride_length_minutes > 0;

-- =========================================
-- STEP 9: Overall Rider Type Comparison
-- Purpose:
-- Find total rides each group takes
-- Find average ride duration in minutes for each group
-- =========================================

SELECT
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(AVG(ride_length_minutes),2) AS avg_ride_minutes
FROM bike_trips_analysis
GROUP BY member_casual;

-- Results:
-- casual: 2,064,263 rides, 24.11 avg minutes
-- member: 3,564,541 rides, 12.30 avg minutes


-- =========================================
-- STEP 10: Weekday Ride Volume Analysis
-- Purpose:
-- Compare the number of rides taken by
-- annual members and casual riders across
-- each day of the week
-- =========================================

SELECT
    day_of_week,
    member_casual,
    COUNT(*) AS total_rides
FROM bike_trips_analysis
GROUP BY day_of_week, member_casual
ORDER BY
    CASE day_of_week
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END,
    member_casual;

-- Results:
-- Members ride most frequently during weekdays,
-- peaking on Wednesday (565,906 rides).

-- Casual riders ride most frequently on weekends,
-- especially Saturday (425,623 rides).

-- =========================================
-- STEP 11: SWeekday Ride Duration Analysis
-- Purpose:
-- Compare average ride length for annual
-- members and casual riders across each
-- day of the week
-- =========================================

SELECT
    day_of_week,
    member_casual,
    ROUND(AVG(ride_length_minutes),2) AS avg_ride_minutes
FROM bike_trips_analysis
GROUP BY day_of_week, member_casual
ORDER BY
    CASE day_of_week
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END,
    member_casual;

-- Results:
-- Member ride times stayed consistent
-- peaking on Sunday (13.75)
-- bottoming on Monday (11.69)

-- Casual rider times are longer on weekends
-- peaking on Sunday (28.20)
-- bottoming on Tuesday (20.50)

-- =========================================
-- STEP 12: Monthly Usage Analysis
-- Purpose:
-- Determine how ride volume changes throughout the year for 
-- annual members and casual riders
-- Identify seasonal trends and peak riding months
-- =========================================

SELECT
    month_num,
    month_name,
    member_casual,
    COUNT(*) AS total_rides
FROM bike_trips_analysis
GROUP BY month_num, month_name, member_casual
ORDER BY month_num;

-- Results:
-- Peak month for both rider groups: September
-- Members peak: 474,373 rides
-- Casual peak: 346,494 rides
--
-- Casual riders exhibit much stronger seasonality,
-- with usage increasing significantly during warmer
-- months and declining sharply during winter.
--
-- Members maintain more consistent usage
-- throughout the year.

-- =========================================
-- STEP 13: Bike Type Preference Analysis
-- Purpose:
-- Compare bike type usage between annual members 
-- and casual riders to identify rider preferences and 
-- differences in equipment utilization.
-- =========================================

SELECT
    rideable_type,
    member_casual,
    COUNT(*) AS total_rides
FROM bike_trips_analysis
GROUP BY rideable_type, member_casual
ORDER BY rideable_type, member_casual;

-- =========================================
-- STEP 14: Business Recommendations
-- Purpose:
-- Turn analytical findings into
-- actionable recommendations to increase
-- annual memberships among casual riders.
-- =========================================