-- Creating tables for PH-EmployeeDB
CREATE TABLE departments(
	dept_no VARCHAR (4) NOT NULL,
	dept_name VARCHAR (40) NOT NULL,
	PRIMARY KEY (dept_no),
	UNIQUE (dept_name)
);

CREATE TABLE employees (
	emp_no INT NOT NULL,
	birth_date DATE NOT NULL,
	first_name VARCHAR NOT NULL,
	last_name VARCHAR NOT NULL,
	gender VARCHAR NOT NULL,
	hire_date DATE NOT NULL, 
	PRIMARY KEY(emp_no),
	UNIQUE (emp_no)
);

CREATE TABLE dept_manager (
	dept_no VARCHAR(4) NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (dept_no, emp_no)
);

CREATE TABLE dept_emp (
	emp_no INT NOT NULL,
	dept_no VARCHAR NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY(emp_no, dept_no)
);

CREATE TABLE titles(
emp_no INT NOT NULL,
title VARCHAR NOT NULL,
from_date DATE NOT NULL,
to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no, title, from_date)
);

CREATE TABLE salaries (
	emp_no INT NOT NULL,
	salary INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no)
);

SELECT*FROM dept_manager

-- Retirement elegibility
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Check the table
SELECT * FROM retirement_info;

DROP TABLE retirement_info;

-- Joining departments and dep_manager tables
SELECT d.dept_name,
	dm.emp_no,
	dm.from_date,
	dm.to_date
FROM department as d
INNER JOIN dept_manager as dm
ON d.dept_no = dm.dept_no;

-- Joining retirement_info and dept_emp tables w/ alias
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date
INTO current_emp
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');

-- Employee count by department number
SELECT COUNT(ce.emp_no), de.dept_no
INTO skill_drill
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;


--Emplpoyee information list -verifying salary data
SELECT * FROM salaries
ORDER BY to_date DESC;

--Constructing the emp_info list
SELECT emp_no, first_name, last_name, gender
INTO emp_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Joining emp info and salaries
SELECT e.emp_no,
e.first_name,
e.last_name,
e.gender,
s.salary,
de.to_date
INTO emp_info
FROM employees as e
INNER JOIN salaries as s
ON (e.emp_no = s.emp_no)
INNER JOIN dept_emp as de
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND (de.to_date = '9999-01-01');

-- List of managers per department
SELECT dm.dept_no,
		d.dept_name,
		dm.emp_no,
		ce.last_name,
		ce.first_name,
		dm.from_date,
		dm.to_date
--INTO manager_info
FROM dept_manager AS dm
	INNER JOIN departments AS d
		ON (dm.dept_no = d.dept_no)
	INNER JOIN current_emp AS ce
		ON (dm.emp_no = ce.emp_no);
		
-- List 3 of Department Retirees
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name
--INTO dept_info
FROM current_emp AS ce
INNER JOIN dept_emp AS de
	ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
ON (de.dept_no = d.dept_no);


--Skill drill
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name
FROM current_emp AS ce
INNER JOIN dept_emp AS de
	ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
ON (de.dept_no = d.dept_no)
WHERE d.dept_name = 'Sales';

SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name
FROM current_emp AS ce
INNER JOIN dept_emp AS de
	ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
ON (de.dept_no = d.dept_no)
WHERE d.dept_name IN ('Sales','Development')

--Challenge
SELECT * FROM titles
SELECT * FROM salaries
SELECT * FROM employees
--Technical Analysis Deliverable 1: No of Retiring Employees by Title.
SELECT e.emp_no,
e.first_name,
e.last_name,
ti.title,
ti.from_date,
s.salary
INTO emp_title
FROM employees AS e
INNER JOIN titles AS ti
	ON (e.emp_no = ti.emp_no)
INNER JOIN salaries AS s
	ON (e.emp_no = s.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
ORDER BY from_date DESC;

SELECT * FROM emp_title
--Removing duplicate entries.
-- Partition the data to show only most recent title per employee
SELECT *
INTO emp_ret_list
FROM (
   SELECT *,
          row_number() over (PARTITION BY from_date ORDER BY emp_no) AS row_number
   FROM emp_title
   ) AS rows
WHERE row_number = 1;


-- Remove column
ALTER TABLE emp_ret_list
DROP COLUMN row_number;

--Employee retiring list
SELECT * FROM emp_ret_list

--Employee retiring count
SELECT COUNT(emp_no)
INTO emp_ret_count
FROM emp_ret_list;

SELECT*FROM emp_ret_count

--Position retiring count
SELECT COUNT (emp_no),
title
INTO title_ret_count
FROM emp_ret_list
GROUP BY title;

SELECT*FROM title_ret_count

--Technical Deliverable 2: Mentorship Eligibility
SELECT*FROM titles

SELECT e.emp_no, 
	e.first_name, 
	e.last_name,
	ti.title,
	ti.from_date, 
	ti.to_date
INTO mentorship
FROM employees as e
INNER JOIN titles AS ti
ON (e.emp_no = ti.emp_no)
WHERE (birth_date BETWEEN '1965-01-01' AND '1965-12-31');

--Removing duplicates
SELECT *
INTO mentor_final
FROM (
   SELECT *,
          row_number() over (PARTITION BY from_date ORDER BY emp_no) AS row_number
   FROM mentorship
   ) AS rows
WHERE row_number = 1;

SELECT*FROM mentor_final

-- Remove column
ALTER TABLE mentor_final
DROP COLUMN row_number;

SELECT*FROM mentor_final