
-- ---------------------------------------------------------------------
-- AUDIT 1: Primary Key Uniqueness Check (e.g., submissions table anomaly)
-- ---------------------------------------------------------------------
SELECT 
    submission_id, 
    COUNT(*) AS instance_count
FROM submissions
GROUP BY submission_id
HAVING COUNT(*) > 1;

-- ---------------------------------------------------------------------
-- AUDIT 2: Candidate Key Uniqueness Check (e.g., student roll_number)
-- ---------------------------------------------------------------------
SELECT 
    roll_number, 
    COUNT(*) AS instance_count
FROM students
GROUP BY roll_number
HAVING COUNT(*) > 1;

-- ---------------------------------------------------------------------
-- AUDIT 3: Email Identity Uniqueness Check
-- ---------------------------------------------------------------------
SELECT 
    email, 
    COUNT(*) AS instance_count
FROM students
WHERE email IS NOT NULL AND email != ''
GROUP BY email
HAVING COUNT(*) > 1;

-- ---------------------------------------------------------------------
-- AUDIT 4: Many-to-Many Enrollment Composite Uniqueness Check
-- ---------------------------------------------------------------------
SELECT 
    student_id, 
    course_id, 
    COUNT(*) AS instance_count
FROM enrollments
GROUP BY student_id, course_id
HAVING COUNT(*) > 1;

-- ---------------------------------------------------------------------
-- AUDIT 5: Contest-Problem Mapping Composite Uniqueness Check
-- ---------------------------------------------------------------------
SELECT 
    contest_id, 
    problem_id, 
    COUNT(*) AS instance_count
FROM contest_problems
GROUP BY contest_id, problem_id
HAVING COUNT(*) > 1;

-- ---------------------------------------------------------------------
-- AUDIT 6A: Test Case Sequence Composite Uniqueness Check
-- ---------------------------------------------------------------------
SELECT 
    problem_id, 
    case_no, 
    COUNT(*) AS instance_count
FROM test_cases
GROUP BY problem_id, case_no
HAVING COUNT(*) > 1;

-- ---------------------------------------------------------------------
-- AUDIT 6B: Sandbox Execution Result Composite Uniqueness Check
-- ---------------------------------------------------------------------
SELECT 
    submission_id, 
    test_case_id, 
    COUNT(*) AS instance_count
FROM test_results
GROUP BY submission_id, test_case_id
HAVING COUNT(*) > 1;

-- ---------------------------------------------------------------------
-- AUDIT 7: Session Log Uniqueness Check
-- ---------------------------------------------------------------------
SELECT 
    session_id, 
    COUNT(*) AS instance_count
FROM sessions
GROUP BY session_id
HAVING COUNT(*) > 1;
