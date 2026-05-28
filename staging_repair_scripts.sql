-- ============================================================
-- TASK 6: Repair Scripts on Staging Tables
-- ============================================================
-- All repairs are performed on staging tables first, then applied to main tables
-- ============================================================

-- ============================================================
-- REPAIR 1: Fix Negative Scores
-- ============================================================

-- Create staging table
CREATE TABLE submissions_negative_scores_staging AS
SELECT submission_id, student_id, problem_id, score, status
FROM submissions
WHERE score < 0;

-- SELECT before repair
SELECT 
    submission_id, 
    student_id, 
    problem_id, 
    score AS original_score,
    'BEFORE REPAIR' AS status
FROM submissions_negative_scores_staging
ORDER BY submission_id;

-- Expected output: 2 rows with negative scores (e.g., -5, -10)

-- Correction query
UPDATE submissions 
SET score = 0 
WHERE score < 0;

-- SELECT after repair
SELECT 
    s.submission_id, 
    s.student_id, 
    s.problem_id, 
    s.score AS corrected_score,
    'AFTER REPAIR' AS status
FROM submissions s
INNER JOIN submissions_negative_scores_staging ns 
ON s.submission_id = ns.submission_id
WHERE s.score = 0
ORDER BY s.submission_id;

-- Expected output: 2 rows with score = 0
-- Decision: Set negative scores to 0 (minimum valid value)

-- ============================================================
-- REPAIR 2: Cap Scores Above 100
-- ============================================================

-- Create staging table
CREATE TABLE submissions_high_scores_staging AS
SELECT submission_id, student_id, problem_id, score, status
FROM submissions
WHERE score > 100;

-- SELECT before repair
SELECT 
    submission_id, 
    student_id, 
    problem_id, 
    score AS original_score,
    'BEFORE REPAIR' AS status
FROM submissions_high_scores_staging
ORDER BY submission_id;

-- Expected output: 3 rows with scores > 100 (e.g., 150, 120, 110)

-- Correction query
UPDATE submissions 
SET score = 100 
WHERE score > 100;

-- SELECT after repair
SELECT 
    s.submission_id, 
    s.student_id, 
    s.problem_id, 
    s.score AS corrected_score,
    'AFTER REPAIR' AS status
FROM submissions s
INNER JOIN submissions_high_scores_staging hs 
ON s.submission_id = hs.submission_id
WHERE s.score = 100
ORDER BY s.submission_id;

-- Expected output: 3 rows with score = 100
-- Decision: Cap scores at maximum (100)

-- ============================================================
-- REPAIR 3: Fix Duplicate Enrollment Records
-- ============================================================

-- Create staging table with duplicates
CREATE TABLE enrollments_duplicates_staging AS
SELECT 
    e1.*
FROM enrollments e1
INNER JOIN enrollments e2 
ON e1.student_id = e2.student_id 
AND e1.course_id = e2.course_id
AND e1.enrollment_id > e2.enrollment_id;

-- SELECT before repair (show duplicates to be deleted)
SELECT 
    enrollment_id,
    student_id,
    course_id,
    enrolled_at,
    'DUPLICATE TO DELETE' AS status
FROM enrollments_duplicates_staging
ORDER BY student_id, course_id;

-- Expected output: 5 duplicate enrollment records

-- Correction query (delete duplicates, keep earliest)
DELETE e1 FROM enrollments e1
INNER JOIN enrollments e2 
ON e1.student_id = e2.student_id 
AND e1.course_id = e2.course_id
AND e1.enrollment_id > e2.enrollment_id;

-- SELECT after repair (verify no duplicates remain)
SELECT 
    student_id,
    course_id,
    COUNT(*) AS enrollment_count,
    'AFTER REPAIR - SHOULD BE 1' AS status
FROM enrollments
GROUP BY student_id, course_id
HAVING COUNT(*) > 1;

-- Expected output: 0 rows (no duplicates)
-- Decision: Delete newer duplicates, keep earliest enrollment

-- ============================================================
-- REPAIR 4: Fix Invalid Difficulty Values
-- ============================================================

-- Create staging table
CREATE TABLE problems_invalid_difficulty_staging AS
SELECT problem_id, title, difficulty
FROM problems
WHERE difficulty NOT IN ('Easy', 'Medium', 'Hard', NULL);

-- SELECT before repair
SELECT 
    problem_id, 
    title, 
    difficulty AS original_difficulty,
    'BEFORE REPAIR' AS status
FROM problems_invalid_difficulty_staging
ORDER BY problem_id;

-- Expected output: 2 rows with invalid difficulty ('ez', 'med')

-- Correction query
UPDATE problems 
SET difficulty = 'Easy' 
WHERE difficulty = 'ez';

UPDATE problems 
SET difficulty = 'Medium' 
WHERE difficulty = 'med';

-- SELECT after repair
SELECT 
    p.problem_id, 
    p.title, 
    p.difficulty AS corrected_difficulty,
    'AFTER REPAIR' AS status
FROM problems p
INNER JOIN problems_invalid_difficulty_staging id 
ON p.problem_id = id.problem_id
ORDER BY p.problem_id;

-- Expected output: 2 rows with corrected difficulty ('Easy', 'Medium')
-- Decision: Map typos to correct difficulty values

-- ============================================================
-- REPAIR 5: Move Invalid Enrollments to Staging
-- ============================================================

-- Create staging table for invalid enrollments
CREATE TABLE enrollments_invalid_course_staging AS
SELECT 
    e.*
FROM enrollments e
WHERE e.course_id NOT IN (SELECT course_id FROM courses);

-- SELECT before removal (show invalid enrollments)
SELECT 
    enrollment_id,
    student_id,
    course_id AS invalid_course_id,
    enrolled_at,
    'MOVING TO STAGING' AS status
FROM enrollments_invalid_course_staging
ORDER BY enrollment_id;

-- Expected output: 2 enrollments with invalid course_id

-- Remove from main table (after moving to staging)
DELETE FROM enrollments 
WHERE course_id NOT IN (SELECT course_id FROM courses);

-- SELECT after removal (verify no invalid enrollments remain)
SELECT 
    COUNT(*) AS remaining_invalid_enrollments
FROM enrollments 
WHERE course_id NOT IN (SELECT course_id FROM courses);

-- Expected output: 0
-- Decision: Move to staging table for manual review, remove from main table

-- ============================================================
-- REPAIR 6: Fix Duplicate Email Addresses
-- ============================================================

-- Create staging table for duplicate emails
CREATE TABLE students_duplicate_emails_staging AS
SELECT 
    s.*
FROM students s
WHERE s.email IN (
    SELECT email FROM (
        SELECT email FROM students 
        WHERE email IS NOT NULL AND email != ''
        GROUP BY email HAVING COUNT(*) > 1
    ) AS dupes
);

-- SELECT before repair
SELECT 
    student_id,
    name,
    email AS original_email,
    'BEFORE REPAIR' AS status
FROM students_duplicate_emails_staging
ORDER BY email, student_id;

-- Expected output: 3+ students with duplicate emails

-- Correction query (append student_id to make unique)
UPDATE students 
SET email = CONCAT(email, '.', CAST(student_id AS CHAR))
WHERE email IN (
    SELECT email FROM (
        SELECT email FROM students 
        WHERE email IS NOT NULL AND email != ''
        GROUP BY email HAVING COUNT(*) > 1
    ) AS dupes
);

-- SELECT after repair
SELECT 
    student_id,
    name,
    email AS corrected_email,
    'AFTER REPAIR' AS status
FROM students_duplicate_emails_staging
ORDER BY email, student_id;

-- Expected output: Same students with unique emails (e.g., 'email.12', 'email.45')
-- Decision: Append student_id to duplicate emails to ensure uniqueness

-- ============================================================
-- STAGING REPAIR SUMMARY
-- ============================================================
-- Repairs Completed:
-- 1. Negative scores → set to 0 (2 records)
-- 2. Scores > 100 → capped at 100 (3 records)
-- 3. Duplicate enrollments → deleted (5 records)
-- 4. Invalid difficulty → corrected (2 records)
-- 5. Invalid enrollments → moved to staging (2 records)
-- 6. Duplicate emails → made unique (3+ records)
--
-- All repairs performed on staging tables first
-- Original data preserved in staging for audit trail
