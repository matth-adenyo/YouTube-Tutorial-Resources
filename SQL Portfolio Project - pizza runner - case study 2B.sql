DROP DATABASE IF EXISTS pizza_runner;
CREATE DATABASE pizza_runner;
USE pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  
  
  
-- -------------------------------------------------------
-- DATA CLEANING
-- -------------------------------------------------------
-- -------------------------------------------------------

SET SQL_SAFE_UPDATES = 0; -- Disable Safe Update Mode
-- safe update mode is a safety feature in MySQL Workbench to prevent accidental updates or deletions

-- Change all blank entries and null to NULL in the customer orders table
UPDATE customer_orders
SET exclusions = NULL
WHERE exclusions IN ('null', '');
  
UPDATE customer_orders
SET extras = NULL
WHERE extras IN ('null', '');


-- Change blank entries, null and data type in the runner orders table
UPDATE runner_orders
SET cancellation = NULL
WHERE cancellation IN ('null', '');

-- Remove 'km' and spaces
UPDATE runner_orders
SET distance = TRIM(REPLACE(REPLACE(distance, 'km', ''), ' ', ''));

-- Set blank entries and null to NULL
UPDATE runner_orders
SET distance = NULL
WHERE distance IN ('null', '');

-- Convert column to FLOAT
ALTER TABLE runner_orders
MODIFY COLUMN distance FLOAT;

-- set null to NULL in pickup time
UPDATE runner_orders
SET pickup_time = NULL
WHERE pickup_time = 'null';


-- Remove text variants and spaces
UPDATE runner_orders
-- SET duration = TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(duration, 'minutes', ''), 'minute', ''), 'mins', ''), 'min', ''), ' ', ''));
SET duration = TRIM(REGEXP_REPLACE(duration, 'minutes|minute|mins|min|\\s', ''));

-- Set null to NULL
UPDATE runner_orders
SET duration = NULL
WHERE duration = 'null';

-- Convert column to integer data type
ALTER TABLE runner_orders
MODIFY COLUMN duration INT;

SET SQL_SAFE_UPDATES = 1; -- Enable Safe Update Mode

DESCRIBE customer_orders; -- Check data types



-- -------------------------------------------
-- ANALYSIS: 
-- -------------------------------------------
-- -------------------------------------------
-- B. Runner and Customer Experience
-- -------------------------------------------


-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 
  DATE_ADD('2021-01-01', INTERVAL FLOOR(DATEDIFF(registration_date, '2021-01-01') / 7) * 7 DAY) AS start_of_week,
  COUNT(runner_id) AS signups
FROM runners
GROUP BY start_of_week
ORDER BY start_of_week;


-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT
	r.runner_id,
    AVG(TIMESTAMPDIFF(MINUTE, order_time, pickup_time)) AS avg_minutes_to_pickup
FROM runner_orders AS r
JOIN customer_orders AS c
	ON r.order_id = c.order_id
WHERE pickup_time IS NOT NULL
GROUP BY r.runner_id;


-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH CTE AS (
  SELECT 
	r.order_id,
    COUNT(c.pizza_id) AS number_of_pizzas,
    MAX(TIMESTAMPDIFF(MINUTE, order_time, pickup_time)) AS order_prep_time
  FROM runner_orders AS r
  JOIN customer_orders AS c
		ON r.order_id = c.order_id
  WHERE pickup_time IS NOT NULL
  GROUP BY r.order_id
)
SELECT
	number_of_pizzas,
    AVG(order_prep_time) AS avg_order_prep_time
FROM CTE
GROUP BY number_of_pizzas;


-- 4. What was the average distance travelled for each customer?
SELECT 
	customer_id,
    ROUND(AVG(distance), 2) AS avg_distance_travelled_km
FROM customer_orders AS c
JOIN runner_orders AS r
	ON c.order_id = r.order_id
WHERE distance IS NOT NULL
GROUP BY customer_id;


-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT
	MAX(duration) - MIN(duration) AS delivery_time_difference_min
FROM runner_orders
WHERE duration IS NOT NULL;


-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT
	runner_id,
    order_id,
    ROUND(distance / (duration / 60), 2) AS speed_km_per_hr
FROM runner_orders
WHERE duration IS NOT NULL
ORDER BY runner_id;


-- 7. What is the successful delivery percentage for each runner?
SELECT
	runner_id,
    COUNT(order_id) AS orders,
    FLOOR(SUM(CASE
			WHEN pickup_time IS NULL
			THEN 0
			ELSE 1
        END) / COUNT(order_id) * 100) AS delivery_percentage 
FROM runner_orders 
GROUP BY runner_id;
