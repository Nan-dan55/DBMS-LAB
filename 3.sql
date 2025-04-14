-- C. Consider the schema for MovieDatabase:
-- ACTOR (Act_id, Act_Name, Act_Gender) 
-- DIRECTOR (Dir_id, Dir_Name,Dir_Phone)
-- MOVIES (Mov_id, Mov_Title, Mov_Year, Mov_Lang, Dir_id) 
-- MOVIE_CAST (Act_id, Mov_id, Role) 
-- RATING (Mov_id,Rev_Stars) 
-- Write SQL queries to
-- 1. List the titles of all movies directed by‘Hitchcock’.
-- 2. Find the movie names where one or more actors acted in two or moremovies.
-- 3. List all actors who acted in a movie before 2000 and also in a
-- movieafter 2015 (use JOINoperation).
-- 4. Find the title of movies and number of stars for each movie that has at
-- least one rating and find the highest number of stars that movie received.
-- Sort the result by movie title.
-- 5. Update rating of all movies directed by ‘Steven Spielberg’ to5.

CREATE TABLE ACTOR (
    ACT_ID INT(3) PRIMARY KEY,
    ACT_NAME VARCHAR(20) NOT NULL,
    ACT_GENDER CHAR(1) NOT NULL
);

CREATE TABLE DIRECTOR (
    DIR_ID INT(3) PRIMARY KEY,
    DIR_NAME VARCHAR(20) NOT NULL,
    DIR_PHONE BIGINT(10) NOT NULL
);

CREATE TABLE MOVIES (
    MOV_ID INT(4) PRIMARY KEY,
    MOV_TITLE VARCHAR(25) NOT NULL,
    MOV_YEAR INT(4) NOT NULL,
    MOV_LANG VARCHAR(12) NOT NULL,
    DIR_ID INT(3),
    FOREIGN KEY (DIR_ID) REFERENCES DIRECTOR(DIR_ID) ON DELETE SET NULL
);

CREATE TABLE MOVIE_CAST (
    ACT_ID INT(3),
    MOV_ID INT(4),
    ROLE VARCHAR(10) NOT NULL,
    PRIMARY KEY (ACT_ID, MOV_ID),
    FOREIGN KEY (ACT_ID) REFERENCES ACTOR(ACT_ID) ON DELETE CASCADE,
    FOREIGN KEY (MOV_ID) REFERENCES MOVIES(MOV_ID) ON DELETE CASCADE
);

CREATE TABLE RATING (
    MOV_ID INT(4) PRIMARY KEY,
    REV_STARS DECIMAL(3,1) NOT NULL,
    FOREIGN KEY (MOV_ID) REFERENCES MOVIES(MOV_ID) ON DELETE CASCADE
);

INSERT INTO ACTOR VALUES (301, 'ANUSHKA', 'F');
INSERT INTO ACTOR VALUES (302, 'PRABHAS', 'M');
INSERT INTO ACTOR VALUES (303, 'PUNITH', 'M');
INSERT INTO ACTOR VALUES (304, 'JERMY', 'M');

INSERT INTO DIRECTOR VALUES (60, 'RAJAMOULI', 8751611001);
INSERT INTO DIRECTOR VALUES (61, 'HITCHCOCK', 7766138911);
INSERT INTO DIRECTOR VALUES (62, 'FARAN', 9986776531);
INSERT INTO DIRECTOR VALUES (63, 'STEVEN SPIELBERG', 8989776530);

INSERT INTO MOVIES VALUES (1001, 'BAHUBALI-2', 2017, 'TELUGU', 60);
INSERT INTO MOVIES VALUES (1002, 'BAHUBALI-1', 2015, 'TELUGU', 60);
INSERT INTO MOVIES VALUES (1003, 'AKASH', 2008, 'KANNADA', 61);
INSERT INTO MOVIES VALUES (1004, 'WAR HORSE', 2011, 'ENGLISH', 63);

INSERT INTO MOVIE_CAST VALUES (301, 1002, 'HEROINE');
INSERT INTO MOVIE_CAST VALUES (301, 1001, 'HEROINE');
INSERT INTO MOVIE_CAST VALUES (303, 1003, 'HERO');
INSERT INTO MOVIE_CAST VALUES (303, 1002, 'GUEST');
INSERT INTO MOVIE_CAST VALUES (304, 1004, 'HERO');

INSERT INTO RATING VALUES (1001, 4.0);
INSERT INTO RATING VALUES (1002, 2.0);
INSERT INTO RATING VALUES (1003, 5.0);
INSERT INTO RATING VALUES (1004, 4.0);


-- 1. List the titles of all movies directed by‘Hitchcock’.

SELECT M.MOV_TITLE  
FROM MOVIES M  
INNER JOIN DIRECTOR D ON M.DIR_ID = D.DIR_ID  
WHERE D.DIR_NAME = 'HITCHCOCK';

-- 2. Find the movie names where one or more actors acted in two or moremovies.

SELECT M.MOV_TITLE  
FROM MOVIES M  
JOIN MOVIE_CAST MV ON M.MOV_ID = MV.MOV_ID  
WHERE MV.ACT_ID IN (  
    SELECT ACT_ID  
    FROM MOVIE_CAST  
    GROUP BY ACT_ID  
    HAVING COUNT(ACT_ID) > 1  
)  

-- 3. List all actors who acted in a movie before 2000 and also in a movie after 2015 (use JOINoperation).

SELECT A.ACT_NAME, M.MOV_TITLE, M.MOV_YEAR  
FROM ACTOR A  
JOIN MOVIE_CAST C ON A.ACT_ID = C.ACT_ID  
JOIN MOVIES M ON C.MOV_ID = M.MOV_ID  
WHERE M.MOV_YEAR NOT BETWEEN 2000 AND 2015;

-- 4. Find the title of movies and number of stars for each movie that has at least one rating and find the highest number of stars that movie received. Sort the result by movie title.

SELECT M.MOV_TITLE, MAX(R.REV_STARS) AS MAX_RATING  
FROM MOVIES M  
INNER JOIN RATING R USING (MOV_ID)  
GROUP BY M.MOV_TITLE  
HAVING MAX(R.REV_STARS) > 0  
ORDER BY M.MOV_TITLE;

-- 5. Update rating of all movies directed by ‘Steven Spielberg’ to5

UPDATE RATING  
SET REV_STARS = 5  
WHERE MOV_ID IN (  
    SELECT M.MOV_ID  
    FROM MOVIES M  
    INNER JOIN DIRECTOR D ON M.DIR_ID = D.DIR_ID  
    WHERE D.DIR_NAME = 'STEVEN SPIELBERG'  
);
