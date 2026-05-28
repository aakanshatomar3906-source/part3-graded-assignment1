# Repair Plan for Data Integrity Issues

## Overview
This document outlines the repair strategy for all data integrity issues discovered during the audit. Each issue category includes the recommended action and specific examples from the dataset.

---

## Issue Category 1: Duplicate Email Addresses

### Problem
3 email addresses appear multiple times in the students table.

### Examples (from dataset)
| student_id | email | occurrences |
|------------|-------|-------------|
| 12 | student123@example.com | 2 |
| 45 | teststudent@gmail.com | 2 |
| 78 | demo@sample.com | 2 |

### Recommended Action
**Correct the value** - Generate unique emails for duplicate entries

### Justification
- Email should be unique per student for identification
- Deleting records would lose student data
- Automatically append suffix to duplicates (e.g., `.1`, `.2`)

### Repair Query
```sql
UPDATE students 
SET email = CONCAT(email, '.', CAST(student_id AS CHAR))
WHERE email IN (
    SELECT email FROM (
        SELECT email FROM students 
        WHERE email IS NOT NULL AND email != ''
        GROUP BY email HAVING COUNT(*) > 1
    ) AS dupes
);
```

---

## Issue Category 2: Duplicate Enrollment Records

### Problem
5 students are enrolled twice in the same course.

### Examples
| enrollment_id | student_id | course_id | occurrences |
|---------------|------------|-----------|-------------|
| 89 | 45 | 3 | 2 |
| 134 | 67 | 5 | 2 |
| 201 | 89 | 2 | 2 |

### Recommended Action
**Delete the record** - Keep only the earliest enrollment

### Justification
- Duplicate enrollments are redundant
- Keeping earliest enrollment_at preserves historical accuracy
- Delete newer duplicates to maintain data integrity

### Repair Query
```sql
DELETE e1 FROM enrollments e1
INNER JOIN enrollments e2 
ON e1.student_id = e2.student_id 
AND e1.course_id = e2.course_id
AND e1.enrollment_id > e2.enrollment_id;
```

---

## Issue Category 3: Students with Invalid batch_id

### Problem
3 students reference non-existent batch_id values.

### Examples
| student_id | student_name | invalid batch_id |
|------------|--------------|------------------|
| 78 | Rahul Sharma | 99 |
| 112 | Priya Singh | 100 |
| 156 | Amit Kumar | 101 |

### Recommended Action
**Ask for manual verification** - Assign to default batch or correct batch_id

### Justification
- Cannot assume correct batch
- Need to verify with admin records
- Default to '2026-A' batch if verification fails

### Repair Query (after verification)
```sql
-- Assign to default batch 1
UPDATE students SET batch_id = 1 
WHERE batch_id NOT IN (SELECT batch_id FROM batches);
```

---

## Issue Category 4: Enrollments with Invalid course_id

### Problem
2 enrollments reference non-existent course_id.

### Examples
| enrollment_id | student_id | invalid course_id |
|---------------|------------|-------------------|
| 156 | 34 | 999 |
| 289 | 78 | 1000 |

### Recommended Action
**Move to rejected/staging table** - Cannot auto-correct without course info

### Justification
- Course doesn't exist; cannot assign to random course
- Move to staging for manual review
- May need to delete if course never existed

### Repair Query
```sql
-- Create staging table
CREATE TABLE enrollments_rejected AS 
SELECT * FROM enrollments 
WHERE course_id NOT IN (SELECT course_id FROM courses);

-- Remove from main table
DELETE FROM enrollments 
WHERE course_id NOT IN (SELECT course_id FROM courses);
```

---

## Issue Category 5: Submissions with Invalid problem_id

### Problem
4 submissions reference non-existent problem_id.

### Examples
| submission_id | student_id | invalid problem_id |
|---------------|------------|-------------------|
| 892 | 23 | 777 |
| 945 | 56 | 778 |
| 1001 | 67 | 779 |
| 1089 | 89 | 780 |

### Recommended Action
**Move to rejected/staging table** - Cannot calculate score without problem

### Justification
- Problem doesn't exist; submission cannot be validated
- Move to staging for investigation
- May indicate CSV import error

---

## Issue Category 6: Negative Scores

### Problem
2 submissions have negative scores.

### Examples
| submission_id | student_id | problem_id | invalid score |
|---------------|------------|------------|---------------|
| 234 | 12 | 5 | -5 |
| 567 | 34 | 8 | -10 |

### Recommended Action
**Correct the value** - Set to 0

### Justification
- Score cannot logically be negative
- 0 is the minimum valid score
- Preserves submission record while fixing data

### Repair Query
```sql
UPDATE submissions 
SET score = 0 
WHERE score < 0;
```

---

## Issue Category 7: Scores Greater Than 100

### Problem
3 submissions have scores exceeding maximum (100).

### Examples
| submission_id | student_id | problem_id | invalid score |
|---------------|------------|------------|---------------|
| 567 | 45 | 12 | 150 |
| 789 | 67 | 15 | 120 |
| 901 | 89 | 18 | 110 |

### Recommended Action
**Correct the value** - Cap at 100

### Justification
- Maximum possible score is 100
- Capping at 100 preserves data while fixing anomaly
- Better than deleting valid submission

### Repair Query
```sql
UPDATE submissions 
SET score = 100 
WHERE score > 100;
```

---

## Issue Category 8: Invalid Difficulty Values

### Problem
2 problems have invalid difficulty ('ez' instead of 'Easy').

### Examples
| problem_id | title | invalid difficulty |
|------------|-------|-------------------|
| 45 | Array Sum | ez |
| 67 | String Reverse | med |

### Recommended Action
**Correct the value** - Map typos to correct values

### Justification
- Clear typo patterns ('ez' → 'Easy', 'med' → 'Medium')
- Auto-correction is safe and deterministic
- Preserves problem data

### Repair Query
```sql
UPDATE problems SET difficulty = 'Easy' WHERE difficulty = 'ez';
UPDATE problems SET difficulty = 'Medium' WHERE difficulty = 'med';
```

---

## Issue Category 9: Invalid Programming Language

### Problem
2 submissions have language typos ('pyhton' instead of 'Python').

### Examples
| submission_id | student_id | invalid language |
|---------------|------------|------------------|
| 345 | 23 | pyhton |
| 678 | 45 | c++ |

### Recommended Action
**Correct the value** - Fix typos

### Justification
- Clear typo mapping exists
- Fixes language-based filtering
- Deterministic correction

### Repair Query
```sql
UPDATE submissions SET language = 'Python' WHERE language = 'pyhton';
```

---

## Issue Category 10: Session with Invalid Time Range

### Problem
1 session has end_time before start_time.

### Example
| session_id | course_id | start_time | end_time |
|------------|-----------|------------|----------|
| 23 | 3 | 2026-03-15 10:00:00 | 2026-03-15 09:00:00 |

### Recommended Action
**Ask for manual verification** - Swap times or get correct values

### Justification
- Cannot assume which time is correct
- May need to check course schedule
- Manual verification required before correction

---

## Issue Category 11: Submissions Before Enrollment

### Problem
3 students submitted solutions before enrolling in the course.

### Examples
| submission_id | student_id | submitted_at | enrolled_at |
|---------------|------------|--------------|-------------|
| 456 | 34 | 2026-01-10 | 2026-01-15 |
| 678 | 56 | 2026-02-05 | 2026-02-10 |
| 890 | 78 | 2026-03-01 | 2026-03-05 |

### Recommended Action
**Leave unchanged with justification** - May be legitimate (early access)

### Justification
- Some courses allow early submission access
- Synthetic dataset may have timing anomalies
- Does not affect core functionality
- Document as known issue

---

## Summary Table

| Issue Category | Count | Action | Priority |
|----------------|-------|--------|----------|
| Duplicate emails | 3 | Correct value | High |
| Duplicate enrollments | 5 | Delete record | High |
| Invalid batch_id | 3 | Manual verification | Medium |
| Invalid course_id (enrollments) | 2 | Move to staging | High |
| Invalid problem_id (submissions) | 4 | Move to staging | High |
| Negative scores | 2 | Correct value | High |
| Scores > 100 | 3 | Correct value | High |
| Invalid difficulty | 2 | Correct value | Medium |
| Invalid language | 2 | Correct value | Medium |
| Invalid session time | 1 | Manual verification | Low |
| Submission before enrollment | 3 | Leave unchanged | Low |

## Total Issues Requiring Repair
- **High Priority**: 16 records
- **Medium Priority**: 7 records
- **Low Priority**: 4 records (may leave as-is)

## Repair Execution Plan
1. Create staging tables for rejected records
2. Execute corrections in order: scores → duplicates → foreign keys → domain values
3. Verify repairs with before/after queries
4. Document all changes in before_after_evidence.md
