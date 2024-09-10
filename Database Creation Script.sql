/* Creating the database for the ITI System

AbdEl-Rhman Ashraf
18/08/2024
*/

-- Create Power BI GP Database

CREATE DATABASE [PowerBIGP]
ON (
    NAME = 'PowerBIGP',
    FILENAME = 'Your_Path\PowerBIGP.mdf'
	)
LOG ON (
    NAME = N'PowerBIGP_Log',
    FILENAME = N'Your_Path\PowerBIGP.log'
);

USE PowerBIGP;

-- Create Person Table

CREATE TABLE Person (
    SSN BIGINT PRIMARY KEY,  
    Fname VARCHAR(50) NOT NULL,
    Lname VARCHAR(50) NOT NULL,
    City VARCHAR(50) NOT NULL,
    Street VARCHAR(100) NOT NULL,
    Gender CHAR(1) CHECK (Gender IN ('M', 'F')),
    Graduation_Year INT NOT NULL,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    Birth_Date DATE NOT NULL,
    Age AS DATEDIFF(YEAR, Birth_Date, GETDATE()),
    CONSTRAINT chk_SSN CHECK (LEN(CAST(SSN AS VARCHAR(14))) = 14),  -- Constraint to ensure SSN is 14 digits
    CONSTRAINT chk_GraduationYear CHECK (Graduation_Year >= YEAR(Birth_Date) + 22 AND Graduation_Year <= YEAR(Birth_Date) + 27)  -- Constraint for Graduation_Year
);


-- Create Person Phone Table

CREATE TABLE Person_Phone (
    SSN BIGINT,               
    Phone VARCHAR(11),
    PRIMARY KEY (SSN, Phone),
    FOREIGN KEY (SSN) REFERENCES Person(SSN),
);

-- Create Gradute Company Table

CREATE TABLE Graduate_Company (
    G_SSN BIGINT PRIMARY KEY, 
    Com_ID INT,
	FOREIGN KEY (G_SSN) REFERENCES Graduate(G_SSN),
	FOREIGN KEY (Com_ID) REFERENCES Company(Com_ID),
);

-- Create Student Freelance Table

CREATE TABLE Student_Freelance (
    F_ID INT PRIMARY KEY, 
    Std_SSN BIGINT,
	FOREIGN KEY (Std_SSN) REFERENCES Student(Std_SSN),
	FOREIGN KEY (F_ID) REFERENCES Freelance(F_ID),
);


-- Create Student Certificate Table

CREATE TABLE Student_Certificate (
    Verif_ID VARCHAR(100) PRIMARY KEY, 
    Std_SSN BIGINT,
	FOREIGN KEY (Verif_ID) REFERENCES Certificate(Verif_ID),
	FOREIGN KEY (Std_SSN) REFERENCES Student(Std_SSN),
);

-- Create Application Table

CREATE TABLE Application (
    APP_ID INT IDENTITY(1,1) PRIMARY KEY,
    App_SSN BIGINT,
    Brn_ID INT,
    Trc_ID INT,
	Int_ID INT,
    Date DATE DEFAULT GETDATE(),
    FOREIGN KEY (App_SSN) REFERENCES Person(SSN), 
    FOREIGN KEY (Brn_ID) REFERENCES Branch(Brn_ID), 
    FOREIGN KEY (Trc_ID) REFERENCES Track(Trc_ID),
	FOREIGN KEY (Int_ID) REFERENCES Intake(Int_ID)
);

-- Create Course Study Table

CREATE TABLE Course_study (
    Std_SSN BIGINT,
    Crs_ID INT,
	Total_Grades INT,
    PRIMARY KEY (Std_SSN, Crs_ID),  -- Composite primary key
    FOREIGN KEY (Std_SSN) REFERENCES Student(Std_SSN), 
    FOREIGN KEY (Crs_ID) REFERENCES Course(Crs_ID)
);

-- Create Exam Questions Table

CREATE TABLE Exam_Questions (
	EX_ID INT,
	Q_ID int
	PRIMARY KEY (Ex_ID, Q_ID), 
    FOREIGN KEY (Ex_ID) REFERENCES Exam (Ex_ID), 
    FOREIGN KEY (Q_ID) REFERENCES Questions (Q_ID), 
);
----------------------------------------------------------------------

/*Ahmed Elkhouly
18/08/2024 */

-- Create Applicant Table

Create Table Applicant (
  App_SSN BIGINT primary key, 
  University varchar(100) not null, 
  Faculty varchar(100) not null,  
  GPA decimal(3, 2) not null, 
  Score Decimal, 
  FOREIGN KEY (App_SSN) REFERENCES Person (SSN)
);

-- Create Instructor Table

Create Table Instructor (
  Ins_SSN BIGINT primary key, 
  Hiring_Date Date DEFAULT GETDATE(), 
  Salary MONEY not null, 
  Degree CHAR(10) NOT NULL, 
  FOREIGN KEY (Ins_SSN) REFERENCES Person (SSN)
);

-- Create Instructor_Course Table

Create Table Instructor_Course (
  Ins_SSN BIGINT, 
  Crs_ID int, 
  PRIMARY KEY (Ins_SSN, Crs_ID), 
  FOREIGN KEY (Ins_SSN) REFERENCES Instructor (Ins_SSN), 
  FOREIGN KEY (Crs_ID) REFERENCES Course (Crs_ID)
);

-- Create Student_Answer Table

Create Table Student_Answer (
  Std_SSN BIGINT, 
  Ex_ID int, 
  Q_ID int, 
  Answer NVARCHAR(100), 
  Std_Grade INT not null, 
  PRIMARY KEY (Std_SSN, Ex_ID, Q_ID), 
  FOREIGN KEY (Std_SSN) REFERENCES Student (Std_SSN), 
  FOREIGN KEY (Ex_ID) REFERENCES Exam (Ex_ID), 
  FOREIGN KEY (Q_ID) REFERENCES Questions (Q_ID)
);
 
 -- Create Question Choices

 Create Table Question_Choices (
	Q_ID INT,
	Choice VARCHAR(255),
	PRIMARY KEY (Q_ID, Choice), 
	FOREIGN KEY (Q_ID) REFERENCES Questions (Q_ID)
);
 ----------------------------------------------------------------------

/*Hossam
18/08/2024 */

-- Create Rejected Table

CREATE TABLE Rejected (
  R_SSN BIGINT PRIMARY KEY, 
  Reason VARCHAR(10) NOT NULL, 
  FOREIGN KEY (R_SSN) REFERENCES Applicant(App_SSN)
);

-- Create Graduate Table

CREATE TABLE Graduate (
  G_SSN BIGINT PRIMARY KEY, 
  Final_Grades INT NOT NULL, 
  Graduation_Date DATE NOT NULL, 
  FOREIGN KEY (G_SSN) REFERENCES Applicant(App_SSN)
);

-- Create Student Table

CREATE TABLE Student (
  Std_SSN BIGINT PRIMARY KEY,
  Lead_SSN BIGINT,
  Username VARCHAR(30) NOT NULL, 
  Salt VARBINARY(16) NOT NULL,
  PasswordHash VARBINARY(32) NOT NULL 
  FOREIGN KEY (Std_SSN) REFERENCES Applicant(App_SSN),
  FOREIGN KEY (Lead_SSN) REFERENCES Student(Std_SSN)
);

-- Create Exam Table

CREATE TABLE Exam (
  Ex_ID INT IDENTITY(1,1) PRIMARY KEY,
  Crs_ID INT,
  Start_Date_Time DATETIME NOT NULL, 
  End_Date_Time DATETIME, 
  No_Question INT NOT NULL,
  Duration AS CONVERT(TIME, End_Date_Time - Start_Date_Time),
  FOREIGN KEY (Crs_ID) REFERENCES Course(Crs_ID)
);

-- Create Questions Table

CREATE TABLE Questions (
  Q_ID INT IDENTITY(1, 1) PRIMARY KEY, 
  Crs_ID INT NOT NULL,
  Question VARCHAR(255) NOT NULL, 
  Type CHAR(3) CHECK(Type IN ('MCQ', 'TF')) NOT NULL, 
  Correct_Answer VARCHAR(255) NOT NULL, 
  Point INT NOT NULL, 
  FOREIGN KEY (Crs_ID) REFERENCES Course(Crs_ID)
);

-- CREATE Track_Course Table

CREATE TABLE Track_Course(
	Trc_ID INT,
	Crs_ID INT,
	PRIMARY KEY (Trc_ID,Crs_ID),
	FOREIGN KEY (Trc_ID) REFERENCES dbo.Track(Trc_ID),
	FOREIGN KEY (Crs_ID) REFERENCES dbo.Course(Crs_ID)
);
 ----------------------------------------------------------------------

/*Mohanad
18/08/2024 */

-- Create Company Table

CREATE TABLE Company (
  Com_ID INT IDENTITY(1,1) PRIMARY KEY, 
  Company_Name VARCHAR(100) NOT NULL UNIQUE, 
  Location VARCHAR(50) NOT NULL
);

-- Create Freelance Table

CREATE TABLE Freelance (
  F_ID INT IDENTITY(1,1) PRIMARY KEY, 
  Name VARCHAR(100) NOT NULL, 
  Platform VARCHAR(50) NOT NULL, 
  Income MONEY NOT NULL, 
  Date DATE NOT NULL, 
  G_SSN BIGINT FOREIGN KEY (G_SSN) REFERENCES Graduate(G_SSN)
);

-- Create Certificate Table

CREATE TABLE Certificate (
  Verif_ID VARCHAR(100) PRIMARY KEY, 
  Certificate_Name VARCHAR(100) NOT NULL, 
  Provider VARCHAR(100) NOT NULL, 
  Issue_Date DATE NOT NULL, 
  Expiry_Date DATE, 
  G_SSN BIGINT, 
  FOREIGN KEY (G_SSN) REFERENCES Graduate(G_SSN)
);


-- Create Course Table

CREATE TABLE Course (
  Crs_ID INT IDENTITY(1,1) PRIMARY KEY, 
  Course_Name VARCHAR(100) NOT NULL UNIQUE
);


-- Create Topic Table

CREATE TABLE Topic (
  TopicID INT IDENTITY(1,1) PRIMARY KEY, 
  Topic_Name VARCHAR(100) NOT NULL, 
  Crs_ID INT, 
  FOREIGN KEY (Crs_ID) REFERENCES Course(Crs_ID)
);

 ----------------------------------------------------------------------

/*Fatma
18/08/2024 */

-- Create Track Table

Create Table Track (
  Trc_ID INT IDENTITY(1,1) primary key, 
  Trc_Name VARCHAR(100) NOT NULL UNIQUE, 
  Sup_hire_date DATE DEFAULT GETDATE(), 
  Sup_SSN BIGINT, 
  Dep_id INT,
  FOREIGN KEY (Dep_id) REFERENCES Department(Dep_id), 
  FOREIGN KEY (Sup_SSN) REFERENCES Instructor(Ins_SSN)
);


-- Create Branch Table

Create Table Branch (
  Brn_ID INT IDENTITY(1,1) primary key, 
  Brn_Name Varchar(50) NOT NULL UNIQUE,
  Brn_loc Varchar(50) NOT NULL,
  Mgr_hire_date Date DEFAULT GETDATE(), 
  Mgr_SSN BIGINT,
  FOREIGN KEY (Mgr_SSN) REFERENCES Instructor(Ins_SSN)
);

-- Create Intake Table

Create Table Intake (
  Int_ID INT IDENTITY(1,1) primary key, 
  Int_Name Varchar(50) NOT NULL UNIQUE
);


-- Create Department Table

Create Table Department (
  Dep_ID INT IDENTITY(1,1) primary key, 
  Dep_Name Varchar(50) NOT NULL UNIQUE
);

Create Table Enrolment (
  Std_SSN BIGINT primary key, 
  Enrol_Date Date DEFAULT GETDATE(),
  Int_ID INT,
  Trc_ID INT, 
  Brn_ID INT,
  FOREIGN KEY (Std_SSN) REFERENCES Student(Std_SSN),
  FOREIGN KEY (Int_ID) REFERENCES Intake(Int_ID),
  FOREIGN KEY (Trc_ID) REFERENCES Track(Trc_ID),
  FOREIGN KEY (Brn_ID) REFERENCES Branch(Brn_ID)
);

------------------------------------------------------------------------------------

--VIEWs

--Student Total Grades

ALTER VIEW Student_Grades_View AS 
select 
  S.Std_SSN as 'Student SSN', 
  P.Fname as 'First Name', 
  p.Lname as 'Last Name', 
  (SUM(CS.Total_Grades) + Sum(SA.Std_Grade)) as [Student_Total_Grades] 
FROM 
  Student as S 
  left join Course_study as CS ON S.Std_SSN = CS.Std_SSN 
  left join Student_Answer as SA ON S.Std_SSN = SA.Std_Grade 
  LEFT JOIN Applicant as A ON S.Std_SSN = A.App_SSN 
  LEFT JOIN Person as P ON A.App_SSN = P.SSN 
GROUP BY 
  S.Std_SSN, 
  P.Fname, 
  P.Lname


CREATE VIEW Student_Final_Grades_View 
WITH encryption
AS
WITH LastStudentAnswer AS (
    SELECT 
        sa.Std_SSN,
        q.Crs_ID,
        sa.Std_Grade,
        ROW_NUMBER() OVER (PARTITION BY sa.Std_SSN, q.Crs_ID ORDER BY sa.Ex_ID DESC) AS rn
    FROM 
        dbo.Student_Answer sa
    INNER JOIN 
        dbo.Questions q
        ON q.Q_ID = sa.Q_ID
),
CourseStudy AS (
    SELECT 
        cs.Std_SSN,
        cs.Crs_ID,
        cs.Total_Grades
    FROM 
        dbo.Course_study cs
)
SELECT 
    p.SSN AS Std_SSN,
    p.Fname AS First_Name,
    p.Lname AS Last_Name,
    t.Trc_Name AS Track_Name,
    SUM(ISNULL(lsa.Std_Grade, 0) + ISNULL(cs.Total_Grades, 0)) AS final_total_grade
FROM 
    CourseStudy cs
LEFT JOIN 
    LastStudentAnswer lsa 
    ON cs.Std_SSN = lsa.Std_SSN AND cs.Crs_ID = lsa.Crs_ID AND lsa.rn = 1
LEFT JOIN 
    dbo.Student s
    ON cs.Std_SSN = s.Std_SSN
LEFT JOIN 
    dbo.Applicant a
    ON s.Std_SSN = a.App_SSN
LEFT JOIN 
    dbo.Person p
    ON a.App_SSN = p.SSN
LEFT JOIN 
    dbo.Enrolment e
    ON s.Std_SSN = e.Std_SSN
LEFT JOIN 
    dbo.Track t
    ON e.Trc_ID = t.Trc_ID
GROUP BY 
    p.SSN,
    p.Fname,
    p.Lname,
    t.Trc_Name;
