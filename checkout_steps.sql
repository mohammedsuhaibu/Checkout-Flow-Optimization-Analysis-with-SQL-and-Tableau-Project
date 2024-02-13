-- Using a CTE to gather all carts created.
with 
total_carts_created as 
(
SELECT 
	user_id, action_date
FROM 
	checkout_carts
),
-- A CTE that extracts all checkout attempts made by users.
total_checkout_attempts as
(
	SELECT
		tc.user_id,
        a.action_name,
        a.action_date
       FROM 
       total_carts_created as tc
-- Joining with the actions to get detailed checkout attempts by the users
       LEFT JOIN 
       checkout_actions as a on a.user_id = tc.user_id
-- Focusing on actions related to completing payment
	WHERE
		a.action_name like '%completepayment.click%'
    AND a.action_date BETWEEN '2022-07-01' AND '2023-01-31'
	GROUP BY tc.user_id
),
-- A CTE that lists only the successful checkout attempts.
total_successful_attempts as
(
	SELECT
		a.user_id,
        a.action_name,
        a.action_date
       FROM 
       total_checkout_attempts as a
-- Identifying successful attempts with keyword 'success' in action_name
	WHERE
		a.action_name like '%success%'
	GROUP BY a.user_id
),
-- Counting the total number of carts created on each day.
count_total_carts as
(
	SELECT
		action_date,
        COUNT(*) as count_total_carts
	FROM total_carts_created 
    GROUP BY action_date
),
-- Counting the total number of carts created on each day.
count_total_checkout_attempts as
(
	SELECT
		action_date,
        COUNT(*) as count_total_checkout_attempts
	FROM total_checkout_attempts 
    GROUP BY action_date
),
-- Counting the total number of successful checkout attempts on each day.
count_successful_checkout_attempts as
(
	SELECT
		action_date,
        COUNT(*) as count_successful_checkout_attempts
	FROM total_successful_attempts 
    GROUP BY action_date
)
-- Final query combines the counts of cart creation, checkout attempts, and successful checkouts for each day.
SELECT
c.action_date,
c.count_total_carts,
-- Using IFNULL to handle cases where there might be no checkout attempts on a given day.
IFNULL(a.count_total_checkout_attempts, 0) as count_total_checkout_attempts,
IFNULL(s.count_successful_checkout_attempts, 0) as count_successful_checkout_attempts
FROM
count_total_carts c
LEFT JOIN 
count_total_checkout_attempts a on a.action_date = c.action_date
LEFT JOIN 
count_successful_checkout_attempts s on s.action_date = a.action_date
WHERE
c.action_date BETWEEN '2022-07-01' AND '2023-01-31'
ORDER BY c.action_date
