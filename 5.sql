-- E. Consider the schema for CompanyDatabase:
-- EMPLOYEE (SSN, Name, Address, Sex, Salary, SuperSSN, DNo) 
-- DEPARTMENT (DNo, DName, MgrSSN, MgrStartDate) 
-- DLOCATION (DNo,DLoc)
-- PROJECT (PNo, PName, PLocation,DNo) 
-- WORKS_ON (SSN, PNo, Hours)

CREATE TABLE EMPLOYEE (
    SSN INT PRIMARY KEY,
    Name VARCHAR(50),
    Address VARCHAR(100),
    Sex CHAR(1),
    Salary DECIMAL(10,2),
    SuperSSN INT,
    DNo INT
);

CREATE TABLE DEPARTMENT (
    DNo INT PRIMARY KEY,
    DName VARCHAR(50),
    MgrSSN INT,
    MgrStartDate DATE
);

CREATE TABLE DLOCATION (
    DNo INT,
    DLoc VARCHAR(100),
    PRIMARY KEY (DNo, DLoc)
);

CREATE TABLE PROJECT (
    PNo INT PRIMARY KEY,
    PName VARCHAR(50),
    PLocation VARCHAR(100),
    DNo INT
);

CREATE TABLE WORKS_ON (
    SSN INT,
    PNo INT,
    Hours DECIMAL(5,2),
    PRIMARY KEY (SSN, PNo)
);

Insert Sample Data
EMPLOYEE Table
sql
INSERT INTO EMPLOYEE VALUES
(101, 'Rahul Sharma', 'Delhi', 'M', 750000, NULL, 1),
(102, 'Ananya Iyer', 'Mumbai', 'F', 600000, 101, 2),
(103, 'Scott Wilson', 'Chennai', 'M', 800000, 101, 3),
(104, 'Meera Rao', 'Bengaluru', 'F', 500000, 103, 3),
(105, 'Vikas Roy', 'Hyderabad', 'M', 650000, 101, 1);
DEPARTMENT Table
sql
INSERT INTO DEPARTMENT VALUES
(1, 'IT', 101, '2022-01-15'),
(2, 'HR', 102, '2022-02-20'),
(3, 'Accounts', 103, '2023-03-10'),
(4, 'Marketing', 104, '2024-04-05'),
(5, 'Finance', 105, '2021-05-12');
DLOCATION Table
sql
INSERT INTO DLOCATION VALUES
(1, 'Delhi'),
(2, 'Mumbai'),
(3, 'Chennai'),
(4, 'Bengaluru'),
(5, 'Hyderabad');
PROJECT Table
sql
INSERT INTO PROJECT VALUES
(11, 'IoT', 'Delhi', 1),
(12, 'AI', 'Mumbai', 2),
(13, 'Blockchain', 'Chennai', 3),
(14, 'Analytics', 'Bengaluru', 4),
(15, 'Cybersecurity', 'Hyderabad', 5);
WORKS_ON Table
sql
INSERT INTO WORKS_ON VALUES
(101, 11, 40),
(102, 12, 30),
(103, 13, 20),
(104, 11, 35),
(105, 15, 25);

-- Here's the corrected query for Question 1:
-- 1. Make a list of all project numbers for projects that involve an employee whose 
-- last name is ‘Scott’, either as a worker or as a manager of the 
-- department that controlsthe project.

-- sql
SELECT DISTINCT P.PNo
FROM PROJECT P
JOIN WORKS_ON W ON P.PNo = W.PNo
JOIN EMPLOYEE E1 ON W.SSN = E1.SSN
WHERE E1.Name LIKE '%Scott%'
OR 
P.DNo IN (
    SELECT D.DNo
    FROM DEPARTMENT D
    JOIN EMPLOYEE E2 ON D.MgrSSN = E2.SSN
    WHERE E2.Name LIKE '%Scott%'
);
-- can be written like this as well
SELECT DISTINCT P.PNo
FROM PROJECT P
JOIN WORKS_ON W ON P.PNo = W.PNo
JOIN EMPLOYEE E1 ON W.SSN = E1.SSN
LEFT JOIN DEPARTMENT D ON P.DNo = D.DNo
LEFT JOIN EMPLOYEE E2 ON D.MgrSSN = E2.SSN
WHERE E1.Name LIKE '%Scott%'
   OR E2.Name LIKE '%Scott%';


-- 2. Updated Salaries for 'IoT' Project Employees
-- sql
SELECT E.Name, 
       E.Salary * 1.10 AS NewSalary
FROM EMPLOYEE E
JOIN WORKS_ON W ON E.SSN = W.SSN
JOIN PROJECT P ON W.PNo = P.PNo
WHERE P.PName = 'IoT';

-- This query lists the names of employees 
-- and their adjusted salaries after a 10% 
-- raise, specifically for those working on 
-- the "IoT" project.

-- 3. Salaries Statistics for 'Accounts' Department
-- sql
SELECT SUM(E.Salary) AS TotalSalary,
       MAX(E.Salary) AS MaxSalary,
       MIN(E.Salary) AS MinSalary,
       AVG(E.Salary) AS AvgSalary
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DNo = D.DNo
WHERE D.DName = 'Accounts';
-- This query provides the total, maximum, 
-- minimum, and average salaries for employees 
-- working in the "Accounts" department.

-- 4. Employees Working on All Projects of Department 5
-- sql
SELECT E.Name
FROM EMPLOYEE E
WHERE NOT EXISTS (
    SELECT P.PNo
    FROM PROJECT P
    WHERE P.DNo = 5
    AND P.PNo NOT IN (
        SELECT W.PNo
        FROM WORKS_ON W
        WHERE W.SSN = E.SSN
    )
);
-- This query retrieves the names of employees 
-- who work on all projects controlled by
-- department number 5. It uses the 
-- NOT EXISTS operator to check for completeness.

-- 5. Departments with More Than 5 Employees and Salaries Over Rs. 6,00,000
-- sql
SELECT E.DNo, 
       COUNT(*) AS NumEmployees
FROM EMPLOYEE E
WHERE E.Salary > 600000
GROUP BY E.DNo
HAVING COUNT(*) > 5;

-- This query retrieves departments with more 
-- than five employees making salaries exceeding 
-- ₹6,00,000, showing the department number and
--  count of such employees.
