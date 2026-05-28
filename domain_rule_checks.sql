
-- ---------------------------------------------------------------------
-- RULE 1: Score & Point Bound Violations
-- ---------------------------------------------------------------------
-- Audits scores that fall below zero or exceed the maximum allowed points defined for the assignment.
SELECT 
    'submissions' AS target_table,
    s.submission_id AS record_id,
    'Score boundary breach' AS anomaly_type,
    'Score: ' || s.score || ' | Max Allowed: ' || p.max_score AS metrics_logged
FROM submissions s
JOIN problems p ON s.problem_id = p.problem_id
WHERE s.score < 0 OR s.score > p.max_score

UNION ALL

SELECT 
    'test_results' AS target_table,
    tr.result_id AS record_id,
    'Awarded points boundary breach' AS anomaly_type,
    'Awarded: ' || tr.awarded_points || ' | Max Allowed: ' || tc.points AS metrics_logged
FROM test_results tr
JOIN test_cases tc ON tr.test_case_id = tc.test_case_id
WHERE tr.awarded_points < 0 OR tr.awarded_points > tc.points;


-- ---------------------------------------------------------------------
-- RULE 2: Domain Enum Value Invalidation Checks
-- ---------------------------------------------------------------------
-- Verifies that categorical variables conform strictly to expected lookups.
SELECT 
    'problems' AS target_table,
    problem_id AS record_id,
    'Invalid difficulty configuration' AS anomaly_type,
    difficulty AS invalid_value
FROM problems
WHERE difficulty NOT IN ('Easy', 'Medium', 'Hard')

UNION ALL

SELECT 
    'submissions' AS target_table,
    submission_id AS record_id,
    'Invalid submission status verdict' AS anomaly_type,
    status AS invalid_value
FROM submissions
WHERE status NOT IN ('Accepted', 'Wrong Answer', 'Runtime Error', 'Compilation Error', 'Time Limit Exceeded', 'Memory Limit Exceeded')

UNION ALL

SELECT 
    'submissions' AS target_table,
    submission_id AS record_id,
    'Unsupported execution language' AS anomaly_type,
    language AS invalid_value
FROM submissions
WHERE language NOT IN ('Python', 'Java', 'C++', 'C', 'JavaScript', 'Go')

UNION ALL

SELECT 
    'test_results' AS target_table,
    result_id AS record_id,
    'Invalid sandbox case status' AS anomaly_type,
    result_status AS invalid_value
FROM test_results
WHERE result_status NOT IN ('Passed', 'Failed', 'Runtime Error', 'Compilation Error', 'Time Limit Exceeded')

UNION ALL

SELECT 
    'contests' AS target_table,
    contest_id AS record_id,
    'Invalid contest timeline status' AS anomaly_type,
    contest_status AS invalid_value
FROM contests
WHERE contest_status NOT IN ('draft', 'published', 'completed')

UNION ALL

SELECT 
    'operation_requests' AS target_table,
    operation_id AS record_id,
    'Invalid operation workflow status' AS anomaly_type,
    approval_status AS invalid_value
FROM operation_requests
WHERE approval_status NOT IN ('pending', 'approved', 'rejected')

UNION ALL

SELECT 
    'sessions' AS target_table,
    session_id AS record_id,
    'Invalid session instructional type' AS anomaly_type,
    session_type AS invalid_value
FROM sessions
WHERE session_type NOT IN ('lecture', 'lab', 'tutorial', 'workshop');


-- ---------------------------------------------------------------------
-- RULE 3: Chronological & Timeline Contradictions
-- ---------------------------------------------------------------------
-- Catches temporal paradoxes where an outcome event logs prior to its cause.
SELECT 
    'contests' AS target_table,
    contest_id AS record_id,
    'Contest closed before start time' AS anomaly_type,
    'Start: ' || start_time || ' | End: ' || end_time AS metrics_logged
FROM contests
WHERE end_time <= start_time

UNION ALL

SELECT 
    'regrade_requests' AS target_table,
    request_id AS record_id,
    'Regrade resolution before request generation' AS anomaly_type,
    'Requested: ' || requested_at || ' | Resolved: ' || resolved_at AS metrics_logged
FROM regrade_requests
WHERE resolved_at IS NOT NULL AND resolved_at < requested_at

UNION ALL

SELECT 
    'operation_requests' AS target_table,
    operation_id AS record_id,
    'Administrative execution before submission request' AS anomaly_type,
    'Requested: ' || requested_at || ' | Executed: ' || executed_at AS metrics_logged
FROM operation_requests
WHERE executed_at IS NOT NULL AND executed_at < requested_at

UNION ALL

SELECT 
    'submissions' AS target_table,
    s.submission_id AS record_id,
    'Sandbox attempt before academic student enrollment' AS anomaly_type,
    'Enrolled: ' || e.enrolled_on || ' | Submitted: ' || s.submitted_at AS metrics_logged
FROM submissions s
JOIN problems p ON s.problem_id = p.problem_id
JOIN enrollments e ON s.student_id = e.student_id AND p.course_id = e.course_id
WHERE s.submitted_at < e.enrolled_on;


-- ---------------------------------------------------------------------
-- RULE 4: Mandatory Column Emptiness Verification
-- ---------------------------------------------------------------------
-- Enforces strict structural NOT NULL / NOT BLANK constraints across system tables.
SELECT 
    'students' AS target_table, 
    student_id AS record_id, 
    'Blank structural roll_number identity' AS anomaly_type 
FROM students WHERE roll_number IS NULL OR roll_number = ''
UNION ALL
SELECT 
    'students', student_id, 'Blank profile full_name' 
FROM students WHERE full_name IS NULL OR full_name = ''
UNION ALL
SELECT 
    'courses', course_id, 'Blank course code label' 
FROM courses WHERE course_code IS NULL OR course_code = ''
UNION ALL
SELECT 
    'problems', problem_id, 'Missing foreign course alignment pointer' 
FROM problems WHERE course_id IS NULL OR course_id = '';
