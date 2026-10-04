/*
Name: Nguyễn Thị Mai Anh
Student ID: 23070612
Assignment: Homework 4 - University Course Registration System
Date: 2026-10-04
*/
-- Remove the old homework database if it exists.
DROP DATABASE IF EXISTS university_db;

-- Create the database with support for Vietnamese text.
CREATE DATABASE university_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Select the database for the following commands.
USE university_db;
-- Departments: stores academic departments.
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    -- Unique ID generated automatically for each department.
    department_id INT AUTO_INCREMENT PRIMARY KEY,

    -- Department name is required and must not be duplicated.
    department_name VARCHAR(100) NOT NULL UNIQUE,

    -- Department code is required and must not be duplicated.
    department_code VARCHAR(10) NOT NULL UNIQUE,

    -- Optional description of the department.
    description TEXT,

    -- Automatically record the creation time.
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
-- Semesters: stores semester names and date ranges.
DROP TABLE IF EXISTS semesters;

CREATE TABLE semesters (
    -- Unique ID generated automatically for each semester.
    semester_id INT AUTO_INCREMENT PRIMARY KEY,

    -- Semester name is required and must be unique.
    semester_name VARCHAR(50) NOT NULL UNIQUE,

    -- Both start date and end date are required.
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,

    -- The semester must end after it starts.
    CONSTRAINT chk_semesters_dates
        CHECK (end_date > start_date)
) ENGINE=InnoDB;
-- Instructors: stores instructors and their departments.
DROP TABLE IF EXISTS instructors;

CREATE TABLE instructors (
    -- Unique ID generated automatically for each instructor.
    instructor_id INT AUTO_INCREMENT PRIMARY KEY,

    -- Instructor code is required and must be unique.
    instructor_code VARCHAR(20) NOT NULL UNIQUE,

    -- Instructor name is required.
    full_name VARCHAR(100) NOT NULL,

    -- Email is required and must be unique.
    email VARCHAR(100) NOT NULL UNIQUE,

    -- Optional phone number; text preserves leading zeros.
    phone VARCHAR(20),

    -- Every instructor must belong to a department.
    department_id INT NOT NULL,

    -- Automatically record the creation time.
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Department must exist; block its deletion while referenced.
    -- If its ID changes, update the instructor's department_id.
    CONSTRAINT fk_instructors_department
        FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;
-- Students: stores students and their major departments.
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    -- Unique ID generated automatically for each student.
    student_id INT AUTO_INCREMENT PRIMARY KEY,

    -- Student code is required and must be unique.
    student_code VARCHAR(20) NOT NULL UNIQUE,

    -- Student name is required.
    full_name VARCHAR(100) NOT NULL,

    -- Email is required and must be unique.
    email VARCHAR(100) NOT NULL UNIQUE,

    -- Optional date of birth.
    date_of_birth DATE,

    -- Fixed gender choices; unspecified is the default.
    gender ENUM('female', 'male', 'other', 'unspecified')
        NOT NULL DEFAULT 'unspecified',

    -- Fixed student statuses; new students are active by default.
    status ENUM('active', 'graduated', 'inactive')
        NOT NULL DEFAULT 'active',

    -- Every student must belong to a department.
    department_id INT NOT NULL,

    -- Automatically record the creation time.
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Department must exist; block its deletion while referenced.
    -- If its ID changes, update the student's department_id.
    CONSTRAINT fk_students_department
        FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;
-- Courses: stores courses, their departments and instructors.
DROP TABLE IF EXISTS courses;

CREATE TABLE courses (
    -- Unique ID generated automatically for each course.
    course_id INT AUTO_INCREMENT PRIMARY KEY,

    -- Course code is required and must be unique.
    course_code VARCHAR(20) NOT NULL UNIQUE,

    -- Course title is required.
    course_title VARCHAR(150) NOT NULL,

    -- Credits are required; the default is 3.
    credits INT NOT NULL DEFAULT 3,

    -- Optional detailed course description.
    description TEXT,

    -- Every course must have a department and an instructor.
    department_id INT NOT NULL,
    instructor_id INT NOT NULL,

    -- This system allows courses with 1 to 6 credits.
    CONSTRAINT chk_courses_credits
        CHECK (credits BETWEEN 1 AND 6),

    -- Department must exist; prevent deletion while referenced.
    -- Propagate changes to the department ID.
    CONSTRAINT fk_courses_department
        FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    -- Instructor must exist; prevent deletion while assigned.
    -- Propagate changes to the instructor ID.
    CONSTRAINT fk_courses_instructor
        FOREIGN KEY (instructor_id)
        REFERENCES instructors (instructor_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;
-- Enrollments: links students to courses in specific semesters.
DROP TABLE IF EXISTS enrollments;

CREATE TABLE enrollments (
    -- Unique ID generated automatically for each enrollment.
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,

    -- Student, course and semester are required.
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    semester_id INT NOT NULL,

    -- Automatically record enrollment time if omitted.
    enrolled_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Optional grade; NULL means the result is not available yet.
    grade DECIMAL(3,2) DEFAULT NULL,

    -- Prevent duplicate enrollment in the same course and semester.
    CONSTRAINT uq_enrollments_student_course_semester
        UNIQUE (student_id, course_id, semester_id),

    -- A grade must be NULL or between 0.00 and 4.00.
    CONSTRAINT chk_enrollments_grade
        CHECK (grade IS NULL OR grade BETWEEN 0.00 AND 4.00),

    -- Student must exist; preserve records by restricting deletion.
    -- Propagate changes to the student ID.
    CONSTRAINT fk_enrollments_student
        FOREIGN KEY (student_id)
        REFERENCES students (student_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    -- Course must exist; preserve records by restricting deletion.
    -- Propagate changes to the course ID.
    CONSTRAINT fk_enrollments_course
        FOREIGN KEY (course_id)
        REFERENCES courses (course_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    -- Semester must exist; preserve records by restricting deletion.
    -- Propagate changes to the semester ID.
    CONSTRAINT fk_enrollments_semester
        FOREIGN KEY (semester_id)
        REFERENCES semesters (semester_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;
-- Insert five sample academic departments.
INSERT INTO departments
    (department_id, department_name, department_code, description)
VALUES
    (1, 'Information Systems', 'IS',
        'Information systems and business technology.'),
    (2, 'Computer Science', 'CS',
        'Programming, algorithms and computing.'),
    (3, 'Business Administration', 'BA',
        'Business management and organizational operations.'),
    (4, 'Accounting and Finance', 'AF',
        'Accounting and financial management.'),
    (5, 'English Studies', 'ENG',
        'English language and academic communication.');
        -- Insert five sample semesters.
INSERT INTO semesters
    (semester_id, semester_name, start_date, end_date)
VALUES
    (1, 'Fall 2024',   '2024-09-01', '2024-12-31'),
    (2, 'Spring 2025', '2025-01-06', '2025-05-25'),
    (3, 'Summer 2025', '2025-06-02', '2025-08-15'),
    (4, 'Fall 2025',   '2025-09-01', '2025-12-31'),
    (5, 'Spring 2026', '2026-01-05', '2026-05-24');
    -- Insert five instructors linked to existing departments.
INSERT INTO instructors
    (instructor_id, instructor_code, full_name,
     email, phone, department_id)
VALUES
    (1, 'INS001', 'Nguyễn Văn Hùng',
        'hung.nguyen@example.com', '0901234561', 1),
    (2, 'INS002', 'Trần Thị Lan',
        'lan.tran@example.com', '0901234562', 2),
    (3, 'INS003', 'Lê Minh Tuấn',
        'tuan.le@example.com', '0901234563', 3),
    (4, 'INS004', 'Phạm Thu Hà',
        'ha.pham@example.com', '0901234564', 4),
    (5, 'INS005', 'Hoàng Thị Hương',
        'huong.hoang@example.com', '0901234565', 5);
        -- Insert five students linked to existing departments.
-- status and created_at use their default values.
INSERT INTO students
    (student_id, student_code, full_name, email,
     department_id, date_of_birth, gender)
VALUES
    (1, 'STU001', 'Nguyễn Thị Mai Anh',
        'maianh.student@example.com', 1, '2004-05-15', 'female'),
    (2, 'STU002', 'Trần Minh Đức',
        'duc.student@example.com', 2, '2004-08-20', 'male'),
    (3, 'STU003', 'Lê Thu Trang',
        'trang.student@example.com', 3, '2004-03-12', 'female'),
    (4, 'STU004', 'Phạm Quốc Bảo',
        'bao.student@example.com', 4, '2003-11-09', 'male'),
    (5, 'STU005', 'Hoàng Ngọc Linh',
        'linh.student@example.com', 5, '2004-07-25', 'female');
        -- Insert five courses linked to existing departments and instructors.
INSERT INTO courses
    (course_id, course_code, course_title, credits,
     department_id, instructor_id, description)
VALUES
    (1, 'IS301', 'Database Management Systems', 3, 1, 1,
        'Relational database design and SQL.'),
    (2, 'CS101', 'Introduction to Programming', 3, 2, 2,
        'Programming fundamentals and problem solving.'),
    (3, 'BA201', 'Principles of Management', 3, 3, 3,
        'Planning, organizing, leading and controlling.'),
    (4, 'AF101', 'Financial Accounting', 3, 4, 4,
        'Accounting principles and financial statements.'),
    (5, 'ENG101', 'Academic English', 2, 5, 5,
        'Academic reading, writing and presentation skills.');
        -- Insert twelve enrollments using existing student, course and semester IDs.
-- NULL grades represent results that have not been entered yet.
INSERT INTO enrollments
    (student_id, course_id, semester_id, enrolled_at, grade)
VALUES
    (1, 1, 1, '2024-08-20 09:00:00', 3.50),
    (1, 2, 1, '2024-08-20 09:10:00', 3.70),
    (2, 2, 1, '2024-08-21 10:00:00', 3.20),
    (2, 1, 2, '2024-12-20 08:30:00', 3.40),
    (3, 3, 1, '2024-08-22 14:00:00', 3.80),
    (3, 5, 2, '2024-12-21 09:00:00', 3.60),
    (4, 4, 2, '2024-12-22 10:00:00', 3.00),
    (4, 3, 3, '2025-05-20 11:00:00', 3.30),
    (5, 5, 1, '2024-08-23 08:00:00', 4.00),
    (5, 3, 4, '2025-08-20 09:00:00', 3.50),
    (1, 4, 5, '2025-12-20 13:00:00', NULL),
    (2, 5, 5, '2025-12-21 14:00:00', NULL);