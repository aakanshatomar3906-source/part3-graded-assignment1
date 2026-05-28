
-- ---------------------------------------------------------------------
-- SECTION 1: System-Wide Row Counts & Primary Key Distinctiveness
-- ---------------------------------------------------------------------
-- This section cross-examines total record counts against distinct key sets
-- to verify that no duplicate rows or key collisions occurred during import.

SELECT 'students' AS table_name, COUNT(*) AS row_count, COUNT(DISTINCT student_id) AS distinct_pk_count FROM students
UNION ALL
SELECT 'courses', COUNT(*), COUNT(DISTINCT course_id) FROM courses
UNION ALL
SELECT 'enrollments', COUNT(*), COUNT(DISTINCT enrollment_id) FROM enrollments
UNION ALL
SELECT 'problems', COUNT(*), COUNT(DISTINCT problem_id) FROM problems
UNION ALL
SELECT 'test_cases', COUNT(*), COUNT(DISTINCT test_case_id) FROM test_cases
UNION ALL
SELECT 'submissions', COUNT(*), COUNT(DISTINCT submission_id) FROM submissions
UNION ALL
SELECT 'test_results', COUNT(*), COUNT(DISTINCT result_id) FROM test_results
UNION ALL
SELECT 'operation_requests', COUNT(*), COUNT(DISTINCT operation_id) FROM operation_requests
UNION ALL
SELECT 'contests', COUNT(*), COUNT(DISTINCT contest_id) FROM contests
UNION ALL
SELECT 'contest_problems', COUNT(*), COUNT(DISTINCT (contest_id || '_' || problem_id)) FROM contest_problems
UNION ALL
SELECT 'plagiarism_flags', COUNT(*), COUNT(DISTINCT flag_id) FROM plagiarism_flags
UNION ALL
SELECT 'regrade_requests', COUNT(*), COUNT(DISTINCT request_id) FROM regrade_requests;

-- ---------------------------------------------------------------------
-- SECTION 2: Structural Null and Blank Matrix Audit
-- ---------------------------------------------------------------------
-- This checks critical tracking and foreign identity columns for blank strings or NULLs.

SELECT 
    'students' AS target_table,
    SUM(CASE WHEN student_id IS NULL OR student_id = '' THEN 1 ELSE 0 END) AS missing_pk,
    SUM(CASE WHEN roll_number IS NULL OR roll_number = '' THEN 1 ELSE 0 END) AS missing_critical_attr,
    SUM(CASE WHEN email IS NULL OR email = '' THEN 1 ELSE 0 END) AS missing_nullable_attr
FROM students
UNION ALL
SELECT 
    'courses',
    SUM(CASE WHEN course_id IS NULL OR course_id = '' THEN 1 ELSE 0 END),
    SUM(CASE WHEN course_code IS NULL OR course_code = '' THEN 1 ELSE 0 END),
    0 -- Placeholder padding for union structural alignment
FROM courses
UNION ALL
SELECT 
    'submissions',
    SUM(CASE WHEN submission_id IS NULL OR submission_id = '' THEN 1 ELSE 0 END),
    SUM(CASE WHEN student_id IS NULL OR student_id = '' THEN 1 ELSE 0 END),
    SUM(CASE WHEN contest_id IS NULL OR contest_id = '' THEN 1 ELSE 0 END)
FROM submissions;
