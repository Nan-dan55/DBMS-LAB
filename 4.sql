-- D. Consider the schema for CollegeDatabase:
-- STUDENT (USN, SName, Address, Phone,Gender) 
-- SEMSEC (SSID, Sem, Sec)
-- CLASS (USN, SSID)
-- SUBJECT (Subcode, Title, Sem, Credits)
-- IAMARKS (USN, Subcode, SSID, Test1, Test2, Test3, FinalIA) 
-- Write SQL queries to
-- 1. List all the student details studying in fourth semester ‘C’section.
-- 2. Compute the total number of male and female students in each semester and in each section.
-- 3. Create a view of Test1 marks of student USN ‘1BI15CS101’ in allsubjects.
-- 4. Calculate the FinalIA (average of best two test update the corresponding table for allstudents.
-- marks) and
-- 5. Categorize students based on the
-- followingcriterion: If FinalIA = 17 to 20 then
-- CAT =‘Outstanding’
-- If FinalIA = 12 to 16 then CAT =
-- ‘Average’ If FinalIA< 12 then CAT =
-- ‘Weak’
-- Give these details only for 8th semester A, B, and C section students.



CREATE TABLE STUDENT (
    USN VARCHAR(20) PRIMARY KEY,
    SName VARCHAR(50),
    Address VARCHAR(100),
    Phone VARCHAR(15),
    Gender VARCHAR(10)
);

CREATE TABLE SEMSEC (
    SSID VARCHAR(10) PRIMARY KEY,
    Sem INT,
    Sec CHAR(1)
);

CREATE TABLE CLASS (
    USN VARCHAR(20),
    SSID VARCHAR(10),
    PRIMARY KEY (USN, SSID),
    FOREIGN KEY (USN) REFERENCES STUDENT(USN) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (SSID) REFERENCES SEMSEC(SSID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE SUBJECT (
    Subcode VARCHAR(10) PRIMARY KEY,
    Title VARCHAR(50),
    Sem INT,
    Credits INT
);

CREATE TABLE IAMARKS (
    USN VARCHAR(20),
    Subcode VARCHAR(10),
    SSID VARCHAR(10),
    Test1 INT,
    Test2 INT,
    Test3 INT,
    FinalIA INT DEFAULT NULL,
    PRIMARY KEY (USN, Subcode, SSID),
    FOREIGN KEY (USN) REFERENCES STUDENT(USN) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Subcode) REFERENCES SUBJECT(Subcode) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (SSID) REFERENCES SEMSEC(SSID) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO STUDENT (USN, SName, Address, Phone, Gender) VALUES
('1BI15CS101', 'Amit Kumar', 'Bangalore, Karnataka', '9876543210', 'Male'),
('1BI15CS102', 'Priya Sharma', 'Chennai, Tamil Nadu', '9988776655', 'Female'),
('1BI15CS103', 'Rahul Reddy', 'Hyderabad, Telangana', '9123456789', 'Male'),
('1BI15CS104', 'Neha Patel', 'Ahmedabad, Gujarat', '9765432100', 'Female'),
('1BI15CS105', 'Vikas Verma', 'Mumbai, Maharashtra', '9876123456', 'Male');

INSERT INTO SEMSEC (SSID, Sem, Sec) VALUES
('SSID001', 4, 'C'),
('SSID002', 4, 'C'),
('SSID003', 8, 'A'),
('SSID004', 8, 'B'),
('SSID005', 8, 'C');

INSERT INTO CLASS (USN, SSID) VALUES
('1BI15CS101', 'SSID001'),
('1BI15CS102', 'SSID001'),
('1BI15CS103', 'SSID002'),
('1BI15CS104', 'SSID003'),
('1BI15CS105', 'SSID004');

INSERT INTO SUBJECT (Subcode, Title, Sem, Credits) VALUES
('CS101', 'Data Structures', 4, 3),
('CS102', 'Database Systems', 4, 3),
('CS103', 'Operating Systems', 8, 4),
('CS104', 'Computer Networks', 8, 4),
('CS105', 'Software Engineering', 8, 3);

INSERT INTO IAMARKS (USN, Subcode, SSID, Test1, Test2, Test3, FinalIA) VALUES
('1BI15CS101', 'CS101', 'SSID001', 18, 16, 14, 16),
('1BI15CS102', 'CS102', 'SSID001', 12, 15, 18, 15),
('1BI15CS103', 'CS103', 'SSID002', 14, 17, 12, 14),
('1BI15CS104', 'CS104', 'SSID003', 20, 18, 19, 19),
('1BI15CS105', 'CS105', 'SSID004', 16, 14, 18, 16);

-- 1. List all the student details studying in fourth semester ‘C’section.

SELECT S.USN, S.SName, S.Address, S.Phone, S.Gender
FROM STUDENT S
JOIN CLASS C ON S.USN = C.USN
JOIN SEMSEC SS ON C.SSID = SS.SSID
WHERE SS.Sem = 4 AND SS.Sec = 'C';
-- 2. Compute the total number of male and female students in each semester and in each section.

SELECT SS.Sem, SS.Sec, S.Gender, COUNT(*) AS Total
FROM STUDENT S
JOIN CLASS C ON S.USN = C.USN
JOIN SEMSEC SS ON C.SSID = SS.SSID
GROUP BY SS.Sem, SS.Sec, S.Gender;

-- 3. Create a view of Test1 marks of student USN ‘1BI15CS101’ in allsubjects.

CREATE VIEW Test1_Marks_View AS
SELECT IAM.USN, IAM.Subcode, IAM.Test1
FROM IAMARKS IAM
WHERE IAM.USN = '1BI15CS101';

-- 4. Calculate the FinalIA (average of best two test update the corresponding table for allstudents.
-- marks) and

UPDATE IAMARKS AS I  
INNER JOIN (  
    SELECT USN, Subcode,  
           AVG(LEAST(GREATEST(Test1, Test2), GREATEST(Test1, Test3), GREATEST(Test2, Test3))) AS AvgBestTest  
    FROM IAMARKS  
    GROUP BY USN, Subcode  
) AS T  
ON I.USN = T.USN  
AND I.Subcode = T.Subcode  
SET I.FinalIA = T.AvgBestTest;


-- 5. Categorize students based on the
-- followingcriterion: If FinalIA = 17 to 20 then
-- CAT =‘Outstanding’
-- If FinalIA = 12 to 16 then CAT =
-- ‘Average’ If FinalIA< 12 then CAT =
-- ‘Weak’
-- Give these details only for 8th semester A, B, and C section students.

SELECT IAM.USN, S.SName, SS.Sem, SS.Sec, IAM.FinalIA,
       CASE 
           WHEN IAM.FinalIA BETWEEN 17 AND 20 THEN 'Outstanding'
           WHEN IAM.FinalIA BETWEEN 12 AND 16 THEN 'Average'
           WHEN IAM.FinalIA < 12 THEN 'Weak'
       END AS Category
FROM IAMARKS IAM
JOIN SEMSEC SS ON IAM.SSID = SS.SSID
JOIN STUDENT S ON IAM.USN = S.USN
WHERE SS.Sem = 8 AND SS.Sec IN ('A', 'B', 'C');
