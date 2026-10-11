/*
 * Name: Nguyễn Thị Mai Anh
 * Student ID: 23070612
 * Assignment: Homework 5 - Introduction to SQL
 * Date: 2026-10-11
 * Database: university_db from Homework 4
 * Expected outputs below use the original Homework 4 sample data.
 */

USE university_db;

/*
 * Query 1: Basic SELECT: All Semesters
 * Description: Retrieves every column from semesters to show the available academic terms.
 * Expected Output: Five semesters, including their IDs, names, start dates and end dates, ordered by ID.
 */

SELECT *
FROM semesters
ORDER BY semester_id;

/*
 * +-------------+---------------+------------+------------+
 * | semester_id | semester_name | start_date | end_date   |
 * +-------------+---------------+------------+------------+
 * | 1           | Fall 2024     | 2024-09-01 | 2024-12-31 |
 * | 2           | Spring 2025   | 2025-01-06 | 2025-05-25 |
 * | 3           | Summer 2025   | 2025-06-02 | 2025-08-15 |
 * | 4           | Fall 2025     | 2025-09-01 | 2025-12-31 |
 * | 5           | Spring 2026   | 2026-01-05 | 2026-05-24 |
 * +-------------+---------------+------------+------------+
 * (5 rows)
 */

/*
 * Query 2: WHERE with Comparison: Grades Above 3.50
 * Description: Filters enrollments to completed results with a grade greater than 3.50.
 * NULL grades do not satisfy this comparison.
 * Expected Output: Four enrollments with grades 3.70, 3.80, 3.60 and 4.00, ordered by enrollment ID.
 */

SELECT enrollment_id, student_id, course_id, grade
FROM enrollments
WHERE grade > 3.50
ORDER BY enrollment_id;

/*
 * +---------------+------------+-----------+-------+
 * | enrollment_id | student_id | course_id | grade |
 * +---------------+------------+-----------+-------+
 * | 2             | 1          | 2         | 3.70  |
 * | 5             | 3          | 3         | 3.80  |
 * | 6             | 3          | 5         | 3.60  |
 * | 9             | 5          | 5         | 4.00  |
 * +---------------+------------+-----------+-------+
 * (4 rows)
 */

/*
 * Query 3: WHERE with AND: Information Systems Courses
 * Description: Finds courses in department 1 (Information Systems) that carry at least 3 credits.
 * Both conditions must be true.
 * Expected Output: One course: IS301, Database Management Systems, with 3 credits in department 1.
 */

SELECT course_code, course_title, credits, department_id
FROM courses
WHERE department_id = 1 AND credits >= 3
ORDER BY course_code;

/*
 * +-------------+-----------------------------+---------+---------------+
 * | course_code | course_title                | credits | department_id |
 * +-------------+-----------------------------+---------+---------------+
 * | IS301       | Database Management Systems | 3       | 1             |
 * +-------------+-----------------------------+---------+---------------+
 * (1 rows)
 */

/*
 * Query 4: ORDER BY: Students in Descending Code Order
 * Description: Lists students sorted by student_code in descending order.
 * Expected Output: Five students, from STU005 down to STU001.
 */

SELECT student_code, full_name
FROM students
ORDER BY student_code DESC;

/*
 * +--------------+--------------------+
 * | student_code | full_name          |
 * +--------------+--------------------+
 * | STU005       | Hoàng Ngọc Linh    |
 * | STU004       | Phạm Quốc Bảo      |
 * | STU003       | Lê Thu Trang       |
 * | STU002       | Trần Minh Đức      |
 * | STU001       | Nguyễn Thị Mai Anh |
 * +--------------+--------------------+
 * (5 rows)
 */

/*
 * Query 5: LIMIT: Top Three Graded Enrollments
 * Description: Excludes ungraded enrollments, sorts by grade from highest to lowest,
 * and returns only the first three rows. Enrollment ID breaks any grade ties.
 * Expected Output: Enrollment IDs 9, 5 and 2 with grades 4.00, 3.80 and 3.70 respectively.
 */

SELECT enrollment_id, student_id, course_id, grade
FROM enrollments
WHERE grade IS NOT NULL
ORDER BY grade DESC, enrollment_id ASC
LIMIT 3;

/*
 * +---------------+------------+-----------+-------+
 * | enrollment_id | student_id | course_id | grade |
 * +---------------+------------+-----------+-------+
 * | 9             | 5          | 5         | 4.00  |
 * | 5             | 3          | 3         | 3.80  |
 * | 2             | 1          | 2         | 3.70  |
 * +---------------+------------+-----------+-------+
 * (3 rows)
 */

/*
 * Query 6: LIKE: Introductory Courses
 * Description: Searches for course titles containing Introduction anywhere in the text.
 * The percent signs match any sequence of characters.
 * Expected Output: One course: CS101, Introduction to Programming, with 3 credits.
 */

SELECT course_code, course_title, credits
FROM courses
WHERE course_title LIKE '%Introduction%'
ORDER BY course_code;

/*
 * +-------------+-----------------------------+---------+
 * | course_code | course_title                | credits |
 * +-------------+-----------------------------+---------+
 * | CS101       | Introduction to Programming | 3       |
 * +-------------+-----------------------------+---------+
 * (1 rows)
 */

/*
 * Query 7: COUNT and SUM: Course Totals
 * Description: Counts all courses and sums their credits. Meaningful column aliases
 * make the two summary values easy to read.
 * Expected Output: One summary row: total_courses = 5 and total_credits = 14.
 */

SELECT COUNT(*) AS total_courses,
       SUM(credits) AS total_credits
FROM courses;

/*
 * +---------------+---------------+
 * | total_courses | total_credits |
 * +---------------+---------------+
 * | 5             | 14            |
 * +---------------+---------------+
 * (1 rows)
 */

/*
 * Query 8: GROUP BY and HAVING: Students with More Than Two Enrollments
 * Description: Groups enrollment records by student and retains groups with more than two rows.
 * COUNT(*) includes enrollments whose grade has not been entered yet.
 * Expected Output: Student IDs 1 and 2, each with enrollment_count = 3.
 */

SELECT student_id, COUNT(*) AS enrollment_count
FROM enrollments
GROUP BY student_id
HAVING COUNT(*) > 2
ORDER BY student_id;

/*
 * +------------+------------------+
 * | student_id | enrollment_count |
 * +------------+------------------+
 * | 1          | 3                |
 * | 2          | 3                |
 * +------------+------------------+
 * (2 rows)
 */

/*
 * Query 9: Two-Table JOIN: Courses and Instructors
 * Description: Joins courses to instructors using the instructor_id foreign key
 * to display the instructor assigned to each course.
 * Expected Output: Five courses with their instructor names, ordered by course ID.
 */

SELECT c.course_code,
       c.course_title,
       i.full_name AS instructor_name
FROM courses AS c
JOIN instructors AS i ON c.instructor_id = i.instructor_id
ORDER BY c.course_id;

/*
 * +-------------+-----------------------------+-----------------+
 * | course_code | course_title                | instructor_name |
 * +-------------+-----------------------------+-----------------+
 * | IS301       | Database Management Systems | Nguyễn Văn Hùng |
 * | CS101       | Introduction to Programming | Trần Thị Lan    |
 * | BA201       | Principles of Management    | Lê Minh Tuấn    |
 * | AF101       | Financial Accounting        | Phạm Thu Hà     |
 * | ENG101      | Academic English            | Hoàng Thị Hương |
 * +-------------+-----------------------------+-----------------+
 * (5 rows)
 */

/*
 * Query 10: Four-Table JOIN: Enrollment Details
 * Description: Joins enrollments, students, courses and semesters through their foreign keys.
 * Each row shows one registration with the student, course, semester and grade.
 * NULL means that the grade is not available yet.
 * Expected Output: Twelve enrollment rows in enrollment ID order; the last two grades are NULL.
 */

SELECT e.enrollment_id,
       s.full_name AS student_name,
       c.course_title,
       sem.semester_name,
       e.grade
FROM enrollments AS e
JOIN students AS s ON e.student_id = s.student_id
JOIN courses AS c ON e.course_id = c.course_id
JOIN semesters AS sem ON e.semester_id = sem.semester_id
ORDER BY e.enrollment_id;

/*
 * +---------------+--------------------+-----------------------------+---------------+-------+
 * | enrollment_id | student_name       | course_title                | semester_name | grade |
 * +---------------+--------------------+-----------------------------+---------------+-------+
 * | 1             | Nguyễn Thị Mai Anh | Database Management Systems | Fall 2024     | 3.50  |
 * | 2             | Nguyễn Thị Mai Anh | Introduction to Programming | Fall 2024     | 3.70  |
 * | 3             | Trần Minh Đức      | Introduction to Programming | Fall 2024     | 3.20  |
 * | 4             | Trần Minh Đức      | Database Management Systems | Spring 2025   | 3.40  |
 * | 5             | Lê Thu Trang       | Principles of Management    | Fall 2024     | 3.80  |
 * | 6             | Lê Thu Trang       | Academic English            | Spring 2025   | 3.60  |
 * | 7             | Phạm Quốc Bảo      | Financial Accounting        | Spring 2025   | 3.00  |
 * | 8             | Phạm Quốc Bảo      | Principles of Management    | Summer 2025   | 3.30  |
 * | 9             | Hoàng Ngọc Linh    | Academic English            | Fall 2024     | 4.00  |
 * | 10            | Hoàng Ngọc Linh    | Principles of Management    | Fall 2025     | 3.50  |
 * | 11            | Nguyễn Thị Mai Anh | Financial Accounting        | Spring 2026   | NULL  |
 * | 12            | Trần Minh Đức      | Academic English            | Spring 2026   | NULL  |
 * +---------------+--------------------+-----------------------------+---------------+-------+
 * (12 rows)
 */

