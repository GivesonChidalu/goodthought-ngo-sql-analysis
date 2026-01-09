-- ============================================================
-- Query 1: Highest Donation Assignments
-- ============================================================
-- Objective:
-- List the top five assignments based on the total value of
-- donations received, categorized by donor type.
--
-- Output Columns:
-- 1. assignment_name
-- 2. region
-- 3. rounded_total_donation_amount (rounded to 2 decimal places)
-- 4. donor_type
--
-- Result Name:
-- highest_donation_assignments
-- ============================================================

SELECT
    a.assignment_name,
    a.region,
    ROUND(SUM(d.amount), 2) AS rounded_total_donation_amount,
    don.donor_type
FROM assignments AS a
JOIN donations AS d
    ON a.assignment_id = d.assignment_id
JOIN donors AS don
    ON don.donor_id = d.donor_id
GROUP BY
    a.assignment_name,
    a.region,
    don.donor_type
ORDER BY
    rounded_total_donation_amount DESC
LIMIT 5;



-- ============================================================
-- Query 2: Top Regional Impact Assignments
-- ============================================================
-- Objective:
-- Identify the assignment with the highest impact score in
-- each region, ensuring the assignment has received at least
-- one donation.
--
-- Output Columns:
-- 1. assignment_name
-- 2. region
-- 3. impact_score
-- 4. num_total_donations
--
-- Result Name:
-- top_regional_impact_assignments
-- ============================================================

-- Step 1: Aggregate total donations per assignment
WITH total_donations AS (
    SELECT
        a.assignment_name,
        a.region,
        a.impact_score,
        COUNT(d.donation_id) AS num_total_donations
    FROM donations AS d
    JOIN assignments AS a
        ON d.assignment_id = a.assignment_id
    GROUP BY
        a.assignment_name,
        a.region,
        a.impact_score
),

-- Step 2: Rank assignments within each region by impact score
rankings AS (
    SELECT
        assignment_name,
        region,
        impact_score,
        num_total_donations,
        ROW_NUMBER() OVER (
            PARTITION BY region
            ORDER BY impact_score DESC
        ) AS ranking
    FROM total_donations
)

-- Step 3: Select the top-ranked assignment per region
SELECT
    assignment_name,
    region,
    impact_score,
    num_total_donations
FROM rankings
WHERE ranking = 1
ORDER BY region ASC;
