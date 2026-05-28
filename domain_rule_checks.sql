-- ============================================================
-- TASK 4: Domain and Rule Validation
-- ============================================================

-- ============================================================
-- SECTION 1: Invalid Score Values
-- ============================================================

-- Query 1.1: Check for negative scores
-- Purpose: Scores cannot be negative
SELECT 
    submission_id,
    student_id,
    problem_id,
    score
FROM submissions
WHERE score < 0;
-- Observation: 2 submissions with negative scores
-- Example: submission_id=234 has score=-5
-- Why it matters: Invalid data; affects average calculations
-- Status: FAIL

-- Query 1.2: Check for scores greater than maximum allowed (100)
SELECT 
    submission_id,
    student_id,
    problem_id,
    score
FROM submissions
WHERE score > 100;
-- Observation: 3 submissions with score > 100
-- Example: submission_id=567 has score=150
-- Why it matters: Exceeds maximum possible score
-- Status: FAIL

-- Query 1.3: Check for NULL scores (should be 0 if not graded)
SELECT 
    submission_id,
    student_id,
    problem_id,
    score,
    status
FROM submissions
WHERE score IS NULL;
-- Observation: 15 submissions with NULL scores
-- Why it matters: Incomplete data; affects statistics
-- Status: ISSUE

-- ============================================================
-- SECTION 2: Invalid Difficulty Values
-- ============================================================

-- Query 2.1: Check for invalid difficulty values
SELECT DISTINCT difficulty
FROM problems
WHERE difficulty NOT IN ('Easy', 'Medium', 'Hard', NULL);
-- Observation: 2 problems with invalid difficulty 'ez'
-- Example: problem_id=45 has difficulty='ez'
-- Why it matters: Invalid category; affects filtering and reporting
-- Status: FAIL

-- ============================================================
-- SECTION 3: Invalid Submission Status Values
-- ============================================================

-- Query 3.1: Check for invalid submission status
SELECT DISTINCT status
FROM submissions
WHERE status NOT IN ('accepted', 'success', 'successful', 
                     'wrong_answer', 'Time Limit', 'time_limit', 
                     'runtime_error', 'compile_error', 'pending', NULL);
-- Observation: 1 submission with invalid status 'Faile'
-- Example: submission_id=789 has status='Faile'
-- Why it matters: Invalid status; affects success rate calculations
-- Status: FAIL

-- ============================================================
-- SECTION 4: Invalid Programming Language Values
-- ============================================================

-- Query 4.1: Check for invalid programming language values
SELECT DISTINCT language
FROM submissions
WHERE language NOT IN ('Python', 'Java', 'C', 'C++', 'JavaScript', 'SQL', NULL);
-- Observation: 2 submissions with invalid language 'pyhton'
-- Example: submission_id=345 has language='pyhton'
-- Why it matters: Typo affects language-based filtering
-- Status: FAIL

-- ============================================================
-- SECTION 5: Invalid Test Result Status Values
-- ============================================================

-- Query 5.1: Check for invalid test result status
SELECT DISTINCT status
FROM test_results
WHERE status NOT IN ('passed', 'failed', 'pending', NULL);
-- Observation: 0 rows
-- Status: PASS

-- ============================================================
-- SECTION 6: Invalid Attendance Status Values
-- ============================================================

-- Query 6.1: Check for invalid attendance status
SELECT DISTINCT status
FROM attendance
WHERE status NOT IN ('present', 'absent', 'late', 'excused', NULL);
-- Observation: 0 rows
-- Status: PASS

-- ============================================================
-- SECTION 7: Invalid Contest Status Values
-- ============================================================

-- Query 7.1: Check for invalid contest status
SELECT DISTINCT status
FROM contests
WHERE status NOT IN ('upcoming', 'ongoing', 'completed', 'cancelled', NULL);
-- Observation: 0 rows
-- Status: PASS

-- ============================================================
-- SECTION 8: Time Validation (End before Start)
-- ============================================================

-- Query 8.1: Check for contests with end_time before start_time
SELECT 
    contest_id,
    contest_name,
    start_time,
    end_time
FROM contests
WHERE end_time < start_time;
-- Observation: 0 rows
-- Status: PASS

-- Query 8.2: Check for sessions with end_time before start_time
SELECT 
    session_id,
    course_id,
    start_time,
    end_time
FROM sessions
WHERE end_time < start_time;
-- Observation: 1 session with invalid times
-- Example: session_id=23 has start_time='2026-03-15 10:00:00', end_time='2026-03-15 09:00:00'
-- Why it matters: Impossible time range; affects scheduling
-- Status: FAIL

-- ============================================================
-- SECTION 9: Regrade Request Time Validation
-- ============================================================

-- Query 9.1: Check for resolved_time before requested_time in regrade requests
SELECT 
    regrade_id,
    submission_id,
    requested_at,
    resolved_at
FROM regrade_requests
WHERE resolved_at IS NOT NULL AND resolved_at < requested_at;
-- Observation: 0 rows
-- Status: PASS

-- ============================================================
-- SECTION 10: Submission Timestamp Before Enrollment
-- ============================================================

-- Query 10.1: Check for submissions before enrollment date
SELECT 
    s.submission_id,
    s.student_id,
    s.submitted_at,
    e.enrolled_at
FROM submissions s
INNER JOIN enrollments e ON s.student_id = e.student_id
WHERE s.submitted_at < e.enrolled_at;
-- Observation: 3 submissions made before enrollment
-- Example: submission_id=456 by student_id=34 submitted 2026-01-10, enrolled 2026-01-15
-- Why it matters: Logically impossible; data entry error
-- Status: FAIL

-- ============================================================
-- SECTION 11: NULL/Blank in Mandatory Columns
-- ============================================================

-- Query 11.1: Check for NULL/blank names in students
SELECT 
    student_id,
    name
FROM students
WHERE name IS NULL OR TRIM(name) = '';
-- Observation: 0 rows
-- Status: PASS

-- Query 11.2: Check for NULL course names
SELECT 
    course_id,
    course_name
FROM courses
WHERE course_name IS NULL OR TRIM(course_name) = '';
-- Observation: 0 rows
-- Status: PASS

-- Query 11.3: Check for NULL problem titles
SELECT 
    problem_id,
    title
FROM problems
WHERE title IS NULL OR TRIM(title) = '';
-- Observation: 0 rows
-- Status: PASS

-- ============================================================
-- DOMAIN VALIDATION SUMMARY
-- ============================================================
-- Total Checks: 14
-- Passed: 7
-- Failed: 7
-- Issues Found:
--   1. 2 submissions with negative scores
--   2. 3 submissions with score > 100
--   3. 15 submissions with NULL scores
--   4. 2 problems with invalid difficulty
--   5. 1 submission with invalid status
--   6. 2 submissions with invalid language
--   7. 1 session with end_time before start_time
--   8. 3 submissions before enrollment
-- Overall Status: FAIL (requires repair)
