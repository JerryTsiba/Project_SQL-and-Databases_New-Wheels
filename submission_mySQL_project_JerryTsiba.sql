/*

-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
  
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/

SELECT
      state,
      COUNT(customer_id) as numb_of_customer
FROM customer_t
GROUP BY state
ORDER BY numb_of_customer DESC;
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. 

Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/


WITH feedback_notes AS (
SELECT 	
      quarter_number,
      CASE WHEN customer_feedback = 'Very Good' THEN 5
      WHEN customer_feedback='Good' THEN 4
      WHEN customer_feedback='Okay' THEN 3
      WHEN customer_feedback='Bad' THEN 2
      ELSE 1
      END note
	FROM order_t)
SELECT quarter_number, 
       AVG(note) AS av_rating 
FROM feedback_notes
GROUP BY quarter_number
ORDER BY quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.
      
Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/
      
WITH feedback_table AS (
    SELECT quarter_number,
           SUM(CASE WHEN customer_feedback = 'Very Good' THEN 1 ELSE 0 END) AS very_good_feedback,
           SUM(CASE WHEN customer_feedback = 'Good' THEN 1 ELSE 0 END) AS good_feedback,
           SUM(CASE WHEN customer_feedback = 'Okay' THEN 1 ELSE 0 END) AS okay_feedback,
           SUM(CASE WHEN customer_feedback = 'Bad' THEN 1 ELSE 0 END) AS bad_feedback,
           SUM(CASE WHEN customer_feedback = 'Very Bad' THEN 1 ELSE 0 END) AS very_bad_feedback,
           COUNT(*) AS total_feedback
    FROM order_t
    GROUP BY quarter_number
)
SELECT quarter_number, very_good_feedback, good_feedback, okay_feedback, bad_feedback, very_bad_feedback,
       100 * (very_good_feedback) / total_feedback AS positive_percentage
FROM feedback_table
ORDER BY quarter_Number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/

SELECT vehicle_maker, COUNT(DISTINCT customer_t.customer_id) AS numb_of_customer
FROM customer_t
JOIN order_t ON customer_t.customer_id = order_t.customer_id
JOIN product_t ON order_t.product_id = product_t.product_id
GROUP BY vehicle_maker
ORDER BY numb_of_customer DESC
LIMIT 5;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/

WITH ranked_table AS 
(
    SELECT state, vehicle_maker, COUNT(DISTINCT customer_t.customer_id) AS numb_of_customer,
           RANK() OVER (PARTITION BY state ORDER BY COUNT(DISTINCT customer_t.customer_id) DESC) AS rank_n
    FROM customer_t
    JOIN order_t ON customer_t.customer_id = order_t.customer_id
    JOIN product_t ON order_t.product_id = product_t.product_id
    GROUP BY state, vehicle_maker
)
SELECT state, vehicle_maker, numb_of_customer
FROM ranked_table
WHERE rank_n = 1
ORDER BY numb_of_customer DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/

SELECT
      quarter_number,
      COUNT(order_id)  as total_orders
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.
*/
  WITH quarterly_revenue AS 
(
    SELECT quarter_number, SUM(order_t.vehicle_price * quantity) AS revenue
    FROM order_t
    JOIN product_t ON order_t.product_id = product_t.product_id
    GROUP BY quarter_number
), 
quarterly_revenue_lag AS 
(
    SELECT quarter_number, revenue,
           LAG(revenue) OVER (ORDER BY quarter_number) AS previous_quarter_revenue
    FROM quarterly_revenue
)
SELECT qr1.quarter_number, qr1.revenue AS current_quarter_revenue,
       qr2.previous_quarter_revenue AS previous_quarter_revenue,
       100 * (qr1.revenue - qr2.previous_quarter_revenue) / qr2.previous_quarter_revenue AS qoq_percentage_change
FROM quarterly_revenue_lag qr1
JOIN quarterly_revenue_lag qr2 ON qr1.quarter_number = qr2.quarter_number + 1
ORDER BY quarter_number;
      
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

SELECT quarter_number, SUM(vehicle_price * quantity) AS revenue, COUNT(order_id) AS orders
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;
-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/

SELECT credit_card_type, AVG(discount) AS avg_discount
FROM customer_t
JOIN order_t ON customer_t.customer_id = order_t.customer_id
GROUP BY credit_card_type;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/

SELECT quarter_number, AVG(DATEDIFF(ship_date, order_date)) AS avg_time_taken_to_ship
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;


-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



