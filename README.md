
# Part 3 — Data Integrity Audit, Debugging & Repair Plan

## Overview
This repository contains a comprehensive data integrity audit for the Student Course Submission Database, including validation checks, issue detection, and safe repair plans.

## Repository Structure

| File | Purpose |
|------|---------|
| `README.md` | This file |
| `import_validation.sql` | Row count and import validation queries |
| `integrity_audit.sql` | Primary key, uniqueness, and foreign key audits |
| `domain_rule_checks.sql` | Domain and business rule validation |
| `repair_plan.md` | Detailed repair plan with examples |
| `staging_repair_scripts.sql` | Safe repair scripts using staging tables |
| `before_after_evidence.md` | Before/after evidence of repairs |

## Database Tables Audited

- `students`, `batches`, `courses`, `enrollments`
- `problems`, `submissions`, `test_cases`, `test_results`
- `contests`, `contest_problems`, `sessions`, `attendance`
- `regrade_requests`, `plagiarism_flags`

## Audit Categories

1. **Import Validation** - Row counts, NULL checks, empty tables
2. **Primary Key Audit** - Duplicate detection
3. **Foreign Key Audit** - Orphaned records, broken relationships
4. **Domain Validation** - Invalid values, rule violations
5. **Repair Plan** - Corrective actions with examples
6. **Safe Repairs** - Staging table scripts with before/after evidence

## How to Run

```bash
# MySQL
mysql -u username -p database_name < import_validation.sql
mysql -u username -p database_name < integrity_audit.sql
mysql -u username -p database_name < domain_rule_checks.sql
mysql -u username -p database_name < staging_repair_scripts.sql
```

## Marks Breakdown Alignment

| Component | Marks | File |
|-----------|-------|------|
| Import validation | 3 | `import_validation.sql` |
| Primary key audit | 4 | `integrity_audit.sql` |
| Foreign key audit | 5 | `integrity_audit.sql` |
| Domain validation | 4 | `domain_rule_checks.sql` |
| Repair plan | 5 | `repair_plan.md` |
| Staging scripts | 4 | `staging_repair_scripts.sql`, `before_after_evidence.md` |

## Author
AAKANSHA TOMAR 
May 2026
