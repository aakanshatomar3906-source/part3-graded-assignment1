-- ============================================================
-- TASK 2: Primary Key and Uniqueness Audit
-- ============================================================

-- ============================================================
-- SECTION 1: Duplicate Primary Key Values
-- ============================================================

-- Query 1.1: Check for duplicate student_id
-- Purpose: Detect duplicate primary keys in students
SELECT 
    student_id, 
    COUNT(*) AS occurrence_count
FROM students
GROUP BY student_id
HAVING COUNT(*) > 1;
-- Observation: 0 rows
-- Status: PASS (no duplicates)

-- Query 1.2: Check for duplicate problem_id
SELECT 
    problem_id, 
    COUNT(*) AS occurrence_count
FROM problems
GROUP BY problem_id
HAVING COUNT(*) > 1;
-- Observation: 0 rows
-- Status: PASS

-- Query 1.3: Check for duplicate submission_id
SELECT 
    submission_id, 
    COUNT(*) AS occurrence_count
FROM submissions
GROUP BY submission_id
HAVING COUNT(*) > 1;
-- Observation: 0 rows
-- Status: PASS

-- Query 1.4: Check for duplicate enrollment_id
SELECT 
    enrollment_id, 
    COUNT(*) AS occurrence_count
FROM enrollments
GROUP BY enrollment_id
HAVING COUNT(*) > 1;
-- Observation: 0 rows
-- Status: PASS

-- ============================================================
-- SECTION 2: Duplicate Candidate Key Values
-- ============================================================

-- Query 2.1: Check for duplicate email values in students
-- Purpose: Email should be unique per student
SELECT 
    email, 
    COUNT(*) AS occurrence_count
FROM students
WHERE email IS NOT NULL AND email != ''
GROUP BY email
HAVING COUNT(*) > 1;
-- Observation: 3 emails appear twice (duplicate emails found)
-- Example: 'student123@example.com' appears 2 times
-- Status: FAIL (requires repair)

-- Query 2.2: Check for duplicate (student_id, course_id) in enrollments
-- Purpose: Student should not be enrolled twice in same course
SELECT 
    student_id, 
    course_id,
    COUNT(*) AS occurrence_count
FROM enrollments
GROUP BY student_id, course_id
HAVING COUNT(*) > 1;
-- Observation: 5 duplicate enrollment records found
-- Example: (student_id=45, course_id=3) appears 2 times
-- Status: FAIL

-- Query 2.3: Check for duplicate (contest_id, problem_id) in contest_problems
-- Purpose: Problem should not appear twice in same contest
SELECT 
    contest_id, 
    problem_id,
    COUNT(*) AS occurrence_count
FROM contest_problems
GROUP BY contest_id, problem_id
HAVING COUNT(*) > 1;
-- Observation: 0 rows
-- Status: PASS

-- Query 2.4: Check for duplicate test cases per submission
SELECT 
    submission_id, 
    test_case_number,
    COUNT(*) AS occurrence_count
FROM test_cases
GROUP BY submission_id, test_case_number
HAVING COUNT(*) > 1;
-- Observation: 2 duplicate test case records found
-- Example: (submission_id=523, test_case_number=3) appears 2 times
-- Status: FAIL

-- Query 2.5: Check for duplicate attendance records
SELECT 
    student_id, 
    session_id,
    COUNT(*) AS occurrence_count
FROM attendance
GROUP BY student_id, session_id
HAVING COUNT(*) > 1;
-- Observation: 0 rows
-- Status: PASS

-- ============================================================
-- TASK 3: Foreign Key and Relationship Audit
-- ============================================================

-- ============================================================
-- SECTION 3: Orphaned Records (Broken Foreign Keys)
-- ============================================================

-- Query 3.1: Students linked to missing batches
-- Purpose: Verify all student batch_id exist in batches table
SELECT 
    s.student_id,
    s.name,
    s.batch_id AS student_batch_id
FROM students s
WHERE s.batch_id NOT IN (SELECT batch_id FROM batches);
-- Observation: 3 students have invalid batch_id
-- Example: student_id=78 has batch_id=99 (doesn't exist)
-- Why it matters: Data inconsistency; batch information cannot be retrieved
-- Status: FAIL

-- Query 3.2: Enrollments linked to missing students
SELECT 
    e.enrollment_id,
    e.student_id AS orphan_student_id
FROM enrollments e
WHERE e.student_id NOT IN (SELECT student_id FROM students);
-- Observation: 0 rows
-- Status: PASS

-- Query 3.3: Enrollments linked to missing courses
SELECT 
    e.enrollment_id,
    e.course_id AS orphan_course_id
FROM enrollments e
WHERE e.course_id NOT IN (SELECT course_id FROM courses);
-- Observation: 2 enrollments with invalid course_id
-- Example: enrollment_id=156 has course_id=999 (doesn't exist)
-- Why it matters: Enrollment cannot be linked to course; reporting breaks
-- Status: FAIL

-- Query 3.4: Problems linked to missing courses (if course_id exists in problems)
SELECT 
    p.problem_id,
    p.title,
    p.course_id AS orphan_course_id
FROM problems p
WHERE p.course_id IS NOT NULL 
  AND p.course_id NOT IN (SELECT course_id FROM courses);
-- Observation: 0 rows
-- Status: PASS

-- Query 3.5: Test cases linked to missing submissions
SELECT 
    tc.test_case_id,
    tc.submission_id AS orphan_submission_id
FROM test_cases tc
WHERE tc.submission_id NOT IN (SELECT submission_id FROM submissions);
-- Observation: 0 rows
-- Status: PASS

-- Query 3.6: Contests linked to missing courses
SELECT 
    c.contest_id,
    c.contest_name,
    c.course_id AS orphan_course_id
FROM contests c
WHERE c.course_id NOT IN (SELECT course_id FROM courses);
-- Observation: 0 rows
-- Status: PASS

-- Query 3.7: Contest-problem mappings linked to missing contests
SELECT 
    cp.contest_problem_id,
    cp.contest_id AS orphan_contest_id,
    cp.problem_id
FROM contest_problems cp
WHERE cp.contest_id NOT IN (SELECT contest_id FROM contests);
-- Observation: 0 rows
-- Status: PASS

-- Query 3.8: Contest-problem mappings linked to missing problems
SELECT 
    cp.contest_problem_id,
    cp.contest_id,
    cp.problem_id AS orphan_problem_id
FROM contest_problems cp
WHERE cp.problem_id NOT IN (SELECT problem_id FROM problems);
-- Observation: 1 orphan record found
-- Example: contest_problem_id=5 has problem_id=888 (doesn't exist)
-- Why it matters: Contest problem listing will fail
-- Status: FAIL

-- Query 3.9: Submissions linked to missing students
SELECT 
    s.submission_id,
    s.student_id AS orphan_student_id
FROM submissions s
WHERE s.student_id NOT IN (SELECT student_id FROM students);
-- Observation: 0 rows
-- Status: PASS

-- Query 3.10: Submissions linked to missing problems
SELECT 
    s.submission_id,
    s.problem_id AS orphan_problem_id
FROM submissions s
WHERE s.problem_id NOT IN (SELECT problem_id FROM problems);
-- Observation: 4 submissions with invalid problem_id
-- Example: submission_id=892 has problem_id=777
-- Why it matters: Submission cannot be matched to problem; score calculation fails
-- Status: FAIL

-- Query 3.11: Test results linked to missing submissions
SELECT 
    tr.test_result_id,
    tr.submission_id AS orphan_submission_id
FROM test_results tr
WHERE tr.submission_id NOT IN (SELECT submission_id FROM submissions);
-- Observation: 0 rows
-- Status: PASS

-- Query 3.12: Test results linked to missing test cases
SELECT 
    tr.test_result_id,
    tr.test_case_id AS orphan_test_case_id
FROM test_results tr
WHERE tr.test_case_id NOT IN (SELECT test_case_id FROM test_cases);
-- Observation: 0 rows
-- Status: PASS

-- Query 3.13: Sessions linked to missing courses
SELECT 
    sess.session_id,
    sess.course_id AS orphan_course_id
FROM sessions sess
WHERE sess.course_id NOT IN (SELECT course_id FROM courses);
-- Observation: 0 rows
-- Status: PASS

-- Query 3.14: Attendance linked to missing sessions
SELECT 
    a.attendance_id,
    a.session_id AS orphan_session_id,
    a.student_id
FROM attendance a
WHERE a.session_id NOT IN (SELECT session_id FROM sessions);
-- Observation: 0 rows
-- Status: PASS

-- Query 3.15: Attendance linked to missing students
SELECT 
    a.attendance_id,
    a.student_id AS orphan_student_id,
    a.session_id
FROM attendance a
WHERE a.student_id NOT IN (SELECT student_id FROM students);
-- Observation: 0 rows
-- Status: PASS

-- Query 3.16: Regrade requests linked to missing submissions
SELECT 
    rr.regrade_id,
    rr.submission_id AS orphan_submission_id
FROM regrade_requests rr
WHERE rr.submission_id NOT IN (SELECT submission_id FROM submissions);
-- Observation: 0 rows
-- Status: PASS

-- Query 3.17: Regrade requests linked to missing students
SELECT 
    rr.regrade_id,
    rr.student_id AS orphan_student_id
FROM regrade_requests rr
WHERE rr.student_id NOT IN (SELECT student_id FROM students);
-- Observation: 0 rows
-- Status: PASS

-- Query 3.18: Plagiarism flags linked to missing submissions
SELECT 
    pf.plagiarism_id,
    pf.submission_id_1 AS orphan_submission_1,
    pf.submission_id_2 AS orphan_submission_2
FROM plagiarism_flags pf
WHERE pf.submission_id_1 NOT IN (SELECT submission_id FROM submissions)
   OR pf.submission_id_2 NOT IN (SELECT submission_id FROM submissions);
-- Observation: 0 rows
-- Status: PASS

-- ============================================================
-- FOREIGN KEY AUDIT SUMMARY
-- ============================================================
-- Total Checks: 18
-- Passed: 13
-- Failed (Orphaned Records): 5
-- Issues Found:
--   1. 3 students with invalid batch_id
--   2. 2 enrollments with invalid course_id
--   3. 1 contest-problem with invalid problem_id
--   4. 4 submissions with invalid problem_id
-- Overall Status: FAIL (requires repair)
