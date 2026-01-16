DROP DATABASE IF EXISTS pizza_runner;
CREATE SCHEMA pizza_runner;

USE pizza_runners;

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
  
-- Cleaninng The Table
-- View the runner_orders table
SELECT *
FROM runner_orders;
  
-- Show the distance column with non-null values
SELECT distance
FROM runner_orders
WHERE distance REGEXP '[^0-9.]';

-- Remove the units in the distance column to obtain a consistent record
UPDATE runner_orders
SET distance = REPLACE(distance, 'km', '')
WHERE distance REGEXP '^[0-9]';

-- Add an extra column for the updated distance column
ALTER TABLE runner_orders
ADD COLUMN Distance_km DECIMAL (10,2);

-- Input values into the new distance column
UPDATE runner_orders
SET distance_km =
  CAST(
    REPLACE(
      REPLACE(
        LOWER(distance),
        'km', ''
      ),
      ' ', ''
    ) AS DECIMAL(10,2)
  )
WHERE distance REGEXP '^[0-9]';

-- Add a new duration column
ALTER TABLE runner_orders
ADD COLUMN Duration_in_min INT;

-- Input values into the new duration column
UPDATE runner_orders
SET Duration_in_min = 
	CASE 
		WHEN duration like '%mins%' THEN
			CAST(REPLACE(duration, 'mins', '') AS DECIMAL(10,2))
		WHEN duration like '%minutes%' THEN
			CAST(REPLACE(duration, 'minutes', '') AS DECIMAL(10,2))
            WHEN duration like '%minute%' THEN
			CAST(REPLACE(duration, 'minute', '') AS DECIMAL(10,2))
	ELSE
		CAST(duration AS DECIMAL(10,2))
	END
    WHERE duration REGEXP '^[0-9]';

-- Delete duration column    
ALTER TABLE runner_orders
DROP COLUMN distance;

SELECT *
FROM customer_orders
WHERE exclusions = '';

UPDATE customer_orders
SET exclusions = 'N/A'
WHERE exclusions = 'NULL';


-- A. Pizza Metrics
SELECT *
FROM customer_orders;

-- How many pizzas were ordered
SELECT COUNT(customer_id) AS no_of_pizzaz 
FROM customer_orders;

-- How many unique customer orders were made?
SELECT  COUNT(DISTINCT customer_id) AS no_of_pizzaz 
FROM customer_orders;

-- How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(pickup_time) as No_of_orders
FROM runner_orders
WHERE pickup_time <> 'N/A'
GROUP BY runner_id;

-- How many of each type of pizza was delivered?
SELECT pizza_name, COUNT(co.pizza_id) as Amt_of_pizzas
FROM customer_orders co
JOIN pizza_names pn
ON co.pizza_id = pn.pizza_id
GROUP BY pizza_name;

-- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id, pizza_name, COUNT(co.pizza_id) as Amt_of_pizzas
FROM customer_orders co
JOIN pizza_names pn
ON co.pizza_id = pn.pizza_id
GROUP BY customer_id, pizza_name;

-- What was the maximum number of pizzas delivered in a single order?
SELECT order_id, COUNT(order_id) as No_of_pizzas
FROM customer_orders
GROUP BY order_id 
ORDER BY No_of_pizzas DESC
LIMIT 1;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- Had no changes
SELECT customer_id, COUNT(pizza_id) as No_of_pizzas
FROM customer_orders
WHERE exclusions = 'N/A'
AND extras = 'N/A'
GROUP BY customer_id;

-- Had at least 1 change
SELECT customer_id, COUNT(pizza_id) as No_of_pizzas
FROM customer_orders
WHERE exclusions <> 'N/A'
OR extras <> 'N/A'
GROUP BY customer_id;

-- How many pizzas were delivered that had both exclusions and extras?
SELECT customer_id, COUNT(pizza_id) as No_of_pizzas
FROM customer_orders
WHERE exclusions <> 'N/A'
AND extras <> 'N/A'
GROUP BY customer_id;

-- What was the total volume of pizzas ordered for each hour of the day?
SELECT hour(order_time) as Time_of_day, COUNT(pizza_id) as No_of_pizzas
FROM customer_orders
GROUP BY Time_of_day
ORDER BY Time_of_day ASC;

-- What was the volume of orders for each day of the week?
SELECT dayname(order_time) as Day_of_week, COUNT(pizza_id) as No_of_pizzas
FROM customer_orders
GROUP BY Day_of_week
ORDER BY Day_of_week;

-- B. Runner and Customer Experience
-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)?
SELECT COUNT(runner_id) as No_of_runners; 

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT TIME(FLOOR(AVG(timediff(ro.pickup_time, co.order_time)))) as Avg_time_to_pickup
FROM customer_orders co
LEFT JOIN runner_orders ro
ON co.order_id = ro.order_id
WHERE pickup_time <> 'N/A';

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- The number of pizzas ordered is directly proportional to the length of time it took to prepare

WITH Pizza_count AS(
	SELECT co.order_id, COUNT(co.order_id) as No_of_pizzas, pickup_time, order_time
	FROM customer_orders co
	JOIN runner_orders ro
	ON co.order_id = ro.order_id
	WHERE pickup_time <> 'N/A'
	GROUP BY co.order_id, pickup_time, order_time
)
SELECT No_of_pizzas, TIME(FLOOR(AVG(timediff(pickup_time, order_time)))) AS Avg_prep_time
FROM Pizza_count
GROUP BY No_of_pizzas;

-- What was the average distance travelled for each customer?
SELECT customer_id, ROUND(AVG(Distance_km), 2) AS Avg_dist_covered
FROM runner_orders ro
JOIN customer_orders co
ON ro.order_id = co.order_id
GROUP BY customer_id;

-- What was the difference between the longest and shortest delivery times for all orders?
SELECT Max(Duration_in_min) - Min(Duration_in_min) as Range_of_time
FROM runner_orders ro
JOIN customer_orders co
ON ro.order_id = co.order_id
WHERE pickup_time <> 'N/A';

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- Runner 2 is the fastest rider
SELECT co.order_id, ro.runner_id, COUNT(co.order_id) AS No_of_pizzas,
ROUND(Avg(Distance_km/(Duration_in_min/60)), 2) AS Avg_delivery_speed
FROM runner_orders ro
JOIN customer_orders co
ON ro.order_id = co.order_id
WHERE pickup_time <> 'N/A'
GROUP BY co.order_id, ro.runner_id;

-- What is the successful delivery percentage for each runner?
SELECT runner_id, COUNT(*) AS No_of_orders,
SUM(CASE WHEN cancellation = 'N/A' THEN 1 ELSE 0 END) AS No_of_successful_ord,
(100 * (SUM(CASE WHEN cancellation = 'N/A' THEN 1 ELSE 0 END))/COUNT(*)) AS Succesful_ord_percent
FROM runner_orders
GROUP BY runner_id;

-- What are the standard ingredients for each pizza?
SELECT *
FROM pizza_recipes;

-- What was the most commonly added extra?
SELECT extras, COUNT(extras) AS Amt_of_extras
FROM customer_orders
WHERE extras <> 'N/A'
GROUP BY extras
LIMIT 1;

-- What was the most common exclusion?
SELECT exclusions, COUNT(exclusions) AS Amt_of_exclusions
FROM customer_orders
WHERE exclusions <> 'N/A'
GROUP BY exclusions
LIMIT 1;

-- Generate an alphabetically ordered comma separated ingredient list for each pizza order 
-- from the customer_orders table and add a 2x in front of any relevant ingredients.
SELECT order_id, customer_id, co.pizza_id, exclusions, extras, toppings 
FROM customer_orders co
JOIN pizza_recipes pr
ON co.pizza_id = pr.pizza_id;

WITH base_toppings AS (
    SELECT
        co.order_id,
        CAST(jt.topping_id AS UNSIGNED) AS topping_id,
        co.exclusions,
        co.extras
    FROM customer_orders co
    JOIN pizza_recipes pr
        ON co.pizza_id = pr.pizza_id
    JOIN JSON_TABLE(
        CONCAT('["', REPLACE(pr.toppings, ',', '","'), '"]'),
        '$[*]' COLUMNS (topping_id VARCHAR(10) PATH '$')
    ) jt
) ,
filtered_toppings AS (
    SELECT
        bt.order_id,
        bt.topping_id,
        CASE
            WHEN bt.extras IS NOT NULL
             AND FIND_IN_SET(bt.topping_id, bt.extras) > 0
            THEN '2x'
            ELSE ''
        END AS multiplier
    FROM base_toppings bt
    WHERE bt.exclusions IS NULL
       OR FIND_IN_SET(bt.topping_id, bt.exclusions) = 0
)
SELECT
    ft.order_id,
    GROUP_CONCAT(
        CONCAT(ft.multiplier, pt.topping_name)
        ORDER BY pt.topping_name
        SEPARATOR ', '
    ) AS ingredient_list
FROM filtered_toppings ft
JOIN pizza_toppings pt
    ON ft.topping_id = pt.topping_id
GROUP BY ft.order_id
ORDER BY ft.order_id;

# Generate an order item for each record in the customers_orders table in the format of one of the following:
# Meat Lovers
# Meat Lovers - Exclude Beef
# Meat Lovers - Extra Bacon
# Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers 
WITH exclusions_cte AS (
    SELECT
        co.order_id,
        GROUP_CONCAT(pt.topping_name ORDER BY pt.topping_name SEPARATOR ', ') AS excluded_items
    FROM customer_orders co
    JOIN JSON_TABLE(
        CONCAT('["', REPLACE(co.exclusions, ',', '","'), '"]'),
        '$[*]' COLUMNS (topping_id INT PATH '$')
    ) ex
    JOIN pizza_toppings pt
        ON pt.topping_id = ex.topping_id
    WHERE co.exclusions IS NOT NULL
    GROUP BY co.order_id
),
extras_cte AS (
    SELECT
        co.order_id,
        GROUP_CONCAT(pt.topping_name ORDER BY pt.topping_name SEPARATOR ', ') AS extra_items
    FROM customer_orders co
    JOIN JSON_TABLE(
        CONCAT('["', REPLACE(co.extras, ',', '","'), '"]'),
        '$[*]' COLUMNS (topping_id INT PATH '$')
    ) ex
    JOIN pizza_toppings pt
        ON pt.topping_id = ex.topping_id
    WHERE co.extras IS NOT NULL
    GROUP BY co.order_id
)
SELECT
    co.order_id,
    CONCAT(
        pn.pizza_name, 
        CASE
            WHEN e.excluded_items IS NOT NULL
            THEN CONCAT(' - Exclude ', e.excluded_items)
            ELSE ''
        END,
        CASE
            WHEN x.extra_items IS NOT NULL
            THEN CONCAT(' - Extra ', x.extra_items)
            ELSE ''
        END
    ) AS order_item
FROM customer_orders co
JOIN pizza_names pn
    ON co.pizza_id = pn.pizza_id
LEFT JOIN exclusions_cte e
    ON co.order_id = e.order_id
LEFT JOIN extras_cte x
    ON co.order_id = x.order_id
ORDER BY co.order_id;

SET SQL_SAFE_UPDATES = 0;