-- B. Consider the following schema for OrderDatabase:
-- SALESMAN (Salesman_id, Name, City, Commission) 
-- CUSTOMER (Customer_id, Cust_Name, City, Grade,Salesman_id)
-- ORDERS (Ord_No, Purchase_Amt, Ord_Date, Customer_id, Salesman_id) 
-- Write SQL queries to
-- 1. Count the customers with grades above Bangalore’saverage.
-- 2. Find the name and numbers of all salesmen who had more than onecustomer.
-- 3. List all salesmen and indicate those who have and don’t have customers in
-- their cities (Use UNIONoperation.)
-- 4. Create a view that finds the salesman who has the customer with the highest
-- order of a day.
-- 5. Demonstrate the DELETE operation by removing salesman with id 1000. All his
-- orders must also bedeleted.

-- Create SALESMAN table
CREATE TABLE SALESMAN (
    SALESMAN_ID INT(4) PRIMARY KEY,
    NAME VARCHAR(20),
    CITY VARCHAR(20),
    COMMISSION VARCHAR(20)
);

-- Create CUSTOMER1 table
CREATE TABLE CUSTOMER1 (
    CUSTOMER_ID INT(4) PRIMARY KEY,
    CUST_NAME VARCHAR(20),
    CITY VARCHAR(20),
    GRADE INT(3),
    SALESMAN_ID INT(4),
    FOREIGN KEY (SALESMAN_ID) REFERENCES SALESMAN(SALESMAN_ID) ON DELETE SET NULL
);

-- Create ORDERS table
CREATE TABLE ORDERS (
    ORD_NO INT(5) PRIMARY KEY,
    PURCHASE_AMT DECIMAL(10,2),
    ORD_DATE DATE,
    CUSTOMER_ID INT(4),
    SALESMAN_ID INT(4),
    FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMER1(CUSTOMER_ID) ON DELETE CASCADE,
    FOREIGN KEY (SALESMAN_ID) REFERENCES SALESMAN(SALESMAN_ID) ON DELETE CASCADE
);

-- Insert data into SALESMAN
INSERT INTO SALESMAN VALUES (1000, 'JOHN', 'BANGALORE', '25%');
INSERT INTO SALESMAN VALUES (2000, 'RAVI', 'BANGALORE', '20%');
INSERT INTO SALESMAN VALUES (3000, 'KUMAR', 'MYSORE', '15%');
INSERT INTO SALESMAN VALUES (4000, 'SMITH', 'DELHI', '30%');
INSERT INTO SALESMAN VALUES (5000, 'HARSHA', 'HYDERABAD', '15%');

-- Insert data into CUSTOMER1
INSERT INTO CUSTOMER1 VALUES (10, 'PREETHI', 'BANGALORE', 100, 1000);
INSERT INTO CUSTOMER1 VALUES (11, 'VIVEK', 'MANGALORE', 300, 1000);
INSERT INTO CUSTOMER1 VALUES (12, 'BHASKAR', 'CHENNAI', 400, 2000);
INSERT INTO CUSTOMER1 VALUES (13, 'CHETHAN', 'BANGALORE', 200, 2000);
INSERT INTO CUSTOMER1 VALUES (14, 'MAMATHA', 'BANGALORE', 400, 3000);

-- Insert data into ORDERS
INSERT INTO ORDERS VALUES (50, 5000, '2017-05-04', 10, 1000);
INSERT INTO ORDERS VALUES (51, 450, '2017-01-20', 10, 2000);
INSERT INTO ORDERS VALUES (52, 1000, '2017-02-24', 13, 2000);
INSERT INTO ORDERS VALUES (53, 3500, '2017-04-13', 14, 3000);
INSERT INTO ORDERS VALUES (54, 550, '2017-03-09', 12, 2000);

-- 1. Count the customers with grades above Bangalore’saverage.
SELECT GRADE, COUNT(DISTINCT CUSTOMER_ID) 
FROM CUSTOMER1
GROUP BY GRADE
HAVING GRADE > (
    SELECT AVG(GRADE) 
    FROM CUSTOMER1 
    WHERE CITY = 'BANGALORE'
);

-- 2. Find the name and numbers of all salesmen who had more than onecustomer.
SELECT SALESMAN_ID, NAME 
FROM SALESMAN A
WHERE 1 < (
    SELECT COUNT(*)
    FROM CUSTOMER1
    WHERE SALESMAN_ID = A.SALESMAN_ID
);
-- can also write like this using join
SELECT S.SALESMAN_ID, S.NAME 
FROM SALESMAN S
JOIN CUSTOMER1 C ON S.SALESMAN_ID = C.SALESMAN_ID
GROUP BY S.SALESMAN_ID, S.NAME
HAVING COUNT(C.CUSTOMER_ID) > 1;


-- 3. List all salesmen and indicate those who have and don’t have customers in
-- their cities (Use UNIONoperation.)
-- First part: Match salesmen and customers from the same city
SELECT S.SALESMAN_ID, S.NAME, C.CUST_NAME, S.COMMISSION
FROM SALESMAN S
INNER JOIN CUSTOMER1 C ON S.CITY = C.CITY

UNION

-- Second part: Salesmen with no matching customers
SELECT S.SALESMAN_ID, S.NAME, 'NO MATCH' AS CUST_NAME, S.COMMISSION
FROM SALESMAN S
WHERE S.CITY NOT IN (SELECT C.CITY FROM CUSTOMER1 C)

ORDER BY NAME DESC;

-- 4. Create a view that finds the salesman who has the customer with the highest
-- order of a day.
CREATE VIEW ELITSALESMAN AS
SELECT B.ORD_DATE, A.SALESMAN_ID, A.NAME 
FROM SALESMAN A
JOIN ORDERS B ON A.SALESMAN_ID = B.SALESMAN_ID
WHERE B.PURCHASE_AMT = (
    SELECT MAX(PURCHASE_AMT) 
    FROM ORDERS C 
    WHERE C.ORD_DATE = B.ORD_DATE
);

-- 5. Demonstrate the DELETE operation by removing salesman with id 1000. All his
-- orders must also bedeleted.
DELETE FROM SALESMAN WHERE SALESMAN_ID = 1000;
