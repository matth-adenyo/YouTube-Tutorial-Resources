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
  
  
  

-- DATA CLEANING
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
-- A. Pizza Metrics
-- -------------------------------------------

-- 1. How many pizzas were ordered?
SELECT COUNT(*) AS pizzas_ordered
FROM customer_orders;


-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM customer_orders;


-- 3. How many successful orders were delivered by each runner?
SELECT 
	runner_id,
    COUNT(order_id) AS successful_orders
FROM runner_orders
WHERE pickup_time IS NOT NULL
GROUP BY runner_id;


-- 4. How many of each type of pizza was delivered?
SELECT
	pizza_name,
	COUNT(c.order_id) AS delivered_pizzas
FROM
	customer_orders AS c
JOIN pizza_names AS p
	ON c.pizza_id = p.pizza_id
JOIN runner_orders AS r
	ON c.order_id = r.order_id
WHERE pickup_time IS NOT NULL
GROUP BY pizza_name;


-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT
	customer_id,
    pizza_name,
    COUNT(order_id) AS ordered_pizzas
FROM customer_orders AS c
JOIN pizza_names AS p
	ON c.pizza_id = p.pizza_id
GROUP BY pizza_name, customer_id;


-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT
	r.order_id,
    COUNT(c.order_id) AS delivered_pizzas
FROM customer_orders AS c
JOIN runner_orders AS r
	ON c.order_id = r.order_id
WHERE pickup_time IS NOT NULL
GROUP BY r.order_id
ORDER BY COUNT(c.order_id) DESC
LIMIT 1;


-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT
	customer_id,
    COUNT(pizza_id) AS delivered_pizzas,
    SUM(CASE
		WHEN exclusions IS NOT NULL OR extras IS NOT NULL
        THEN 1
        ELSE 0
        END) AS had_atleast_1_change,
	SUM(CASE
		WHEN exclusions IS NULL AND extras IS NULL
        THEN 1
        ELSE 0
        END) AS had_no_change
FROM customer_orders AS c
JOIN runner_orders AS r
	ON r.order_id = c.order_id
WHERE pickup_time IS NOT NULL
GROUP BY customer_id;


-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT
	customer_id,
    SUM(CASE
		WHEN exclusions IS NOT NULL AND extras IS NOT NULL
        THEN 1
        ELSE 0
        END) AS had_both_exclusions_and_extras
FROM customer_orders AS c
JOIN runner_orders AS r
	ON r.order_id = c.order_id
WHERE pickup_time IS NOT NULL
GROUP BY customer_id;


-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT
	HOUR(order_time) AS hour,
    COUNT(*) AS ordered_pizzas
FROM customer_orders
GROUP BY HOUR(order_time);


-- 10. What was the volume of orders for each day of the week?
SELECT
	DAYNAME(order_time) AS day,
    COUNT(*) AS ordered_pizzas
FROM customer_orders
GROUP BY DAYNAME(order_time);



