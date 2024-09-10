--Stored Procedures for SSRS Reports

--Report No. 1

CREATE PROCEDURE GetStudentsByDepartment
    @DepartmentID INT
AS
BEGIN
    SELECT 
        p.SSN,
        p.Fname AS FirstName,
        p.Lname AS LastName,
        p.City AS City,
        p.Graduation_Year,
        ph.Phone,
        a.Faculty,
        e.Enrol_Date,
        t.Trc_Name,
        d.Dep_Name
    FROM 
        Person_Phone ph
    JOIN 
        Person p ON ph.SSN = p.SSN
    JOIN 
        Applicant a ON p.SSN = a.App_SSN
    JOIN 
        Student s ON a.App_SSN = s.Std_SSN
    JOIN 
        Enrolment e ON s.Std_SSN = e.Std_SSN
    JOIN 
        Track t ON e.Trc_ID = t.Trc_ID
    JOIN 
        Department d ON t.Dep_ID = d.Dep_ID
    WHERE 
        d.Dep_ID = @DepartmentID;
END;
---------------------------------------------------------------------------------------------
-- Report No. 2
CREATE PROC get_total_grades @s_ssn BIGINT
AS
	SELECT 
	[First_Name] + ' ' + [Last_Name] AS [Student Name],
	CAST (final_total_grade / 5 AS varchar(4)) + '%'  AS [Total Grades]
	FROM dbo.Student_Final_Grades_View
	WHERE Std_SSN = @s_ssn
------------------------------------------------------------------------------------------------
-- Report No. 3
CREATE PROC get_inst_courses_and_students @ins_snn BIGINT
AS
BEGIN
BEGIN TRY
	IF LEN(CAST(@ins_snn AS VARCHAR(14))) <> 14
        BEGIN
            select 'Student id must be a 14-digit number.'
            RETURN
        END
	BEGIN
		
		SELECT 
		Fname + ' ' + Lname AS [Instructor Name],
		Course_Name AS [Course Name],
		COUNT(S.Std_SSN) AS [Number of Students]
		FROM Person P
		JOIN Instructor I 
			ON SSN = I.Ins_SSN
		JOIN Instructor_Course IC
			ON I.Ins_SSN = IC.Ins_SSN
		JOIN Course C
			ON C.Crs_ID = IC.Crs_ID
		JOIN Course_study CS
			ON C.Crs_ID = CS.Crs_ID
		JOIN Student S
			ON S.Std_SSN = CS.Std_SSN
		WHERE I.Ins_SSN = @ins_snn
		GROUP BY C.Course_Name, SSN, Fname, Lname

	END
	END TRY
	BEGIN CATCH 
		SELECT 'Error'
	END CATCH
END

--------------------------------------------------------------------------------------------------
--Report No. 4

CREATE PROCEDURE GetTopicsNameReport2
    @Crs_ID INT
AS
BEGIN
    BEGIN TRY
        
        IF NOT EXISTS (SELECT 1 FROM [PowerBIGP].[dbo].[Course] WHERE Crs_ID = @Crs_ID)
        BEGIN
           
            SELECT 
                NULL AS Crs_ID, 
                NULL AS Course_Name, 
                NULL AS TopicID, 
                NULL AS Topic_Name;
            RETURN;
        END
        ELSE
        BEGIN
            
            SELECT 
                T.Crs_ID, 
                C.Course_Name, 
                T.TopicID, 
                T.Topic_Name
            FROM 
                [PowerBIGP].[dbo].[Topic] T
            INNER JOIN 
                [PowerBIGP].[dbo].[Course] C 
            ON 
                T.Crs_ID = C.Crs_ID
            WHERE 
                T.Crs_ID = @Crs_ID;
            RETURN;
        END
    END TRY
    BEGIN CATCH
        
        SELECT 
            NULL AS Crs_ID, 
            NULL AS Course_Name, 
            NULL AS TopicID, 
            NULL AS Topic_Name;
    END CATCH;
END
-----------------------------------------------------------------------------------------------------------
--Report No. 5

CREATE PROCEDURE GetExamQuestionsandChoices
    @EX_ID INT
AS
BEGIN
    BEGIN TRY
        
        IF NOT EXISTS (SELECT 1 FROM [PowerBIGP].[dbo].[Exam_Questions] WHERE EX_ID = @EX_ID)
        BEGIN
            
            SELECT 
                NULL AS Q_ID, 
                NULL AS Question, 
                NULL AS Choice;
            RETURN;
        END
        ELSE
        BEGIN
            
            SELECT 
                Q.Q_ID, 
                Q.Question, 
                QC.Choice
            FROM 
                [PowerBIGP].[dbo].[Exam_Questions] EQ
            INNER JOIN 
                [PowerBIGP].[dbo].[Questions] Q 
            ON 
                EQ.Q_ID = Q.Q_ID
            LEFT JOIN 
                [PowerBIGP].[dbo].[Question_Choices] QC 
            ON 
                Q.Q_ID = QC.Q_ID
            WHERE 
                EQ.EX_ID = @EX_ID
            ORDER BY 
                Q.Q_ID;
            RETURN;
        END
    END TRY
    BEGIN CATCH
        
        SELECT 
            NULL AS Q_ID, 
            NULL AS Question, 
            NULL AS Choice;
    END CATCH;
END;
--------------------------------------------------------------------------------------------------
-- Report No. 6


ALTER PROC GetExamQuestionsWithAnswers
    @Exam_ID INT,
    @Student_ID BIGINT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
		-- Check if Student id is a 14-digit number
        IF LEN(CAST(@Student_ID AS VARCHAR(14))) <> 14
        BEGIN
            select 'Student id must be a 14-digit number.'
            RETURN
        END

        -- Check if the Exam ID exists
        IF NOT EXISTS (SELECT 1 FROM Student_Answer WHERE Ex_ID = @Exam_ID)
        BEGIN
            SELECT 'The specified Exam ID does not exist.';
            RETURN;
        END

        -- Check if the Student ID exists
        IF NOT EXISTS (SELECT 1 FROM Student_Answer WHERE Std_SSN = @Student_ID)
        BEGIN
            SELECT 'The specified Student ID does not exist.';
            RETURN;
        END

        -- get the questions and the student's answers
        SELECT 
            Q.Question AS Question,
            SA.Answer AS Student_Answer
        FROM 
            Student_Answer SA
        JOIN 
            Questions Q ON SA.Q_ID = Q.Q_ID
        WHERE 
            SA.Ex_ID = @Exam_ID AND SA.Std_SSN = @Student_ID;
    END TRY
    BEGIN CATCH
        SELECT 'Error';
    END CATCH
END;
-----------------------------------------------------------------------------------------------------
-- For Exam Generation as a Report
create proc GenrateRandomExam @stdssn bigint,@CrsName varchar(100) 
 with encryption
	as
		Begin Try
			Declare @eid int
			insert into exam (Crs_ID,Start_Date_Time,End_Date_Time,No_Question)
			values ((select c.Crs_ID from Course c where c.Course_Name=@CrsName)
						,GETDATE(),DATEADD(HOUR, 1,GETDATE() ),10)
			set @eid =SCOPE_IDENTITY()
			insert into Exam_Questions 
			select @eid,Q_ID
			from ( select top(7) q.Q_ID from Questions q, Exam E
				where q.Type='MCQ'and e.Ex_ID=@eid and E.Crs_ID=Q.Crs_ID order by NEWID()) as MCQTable
			union all
			select @eid,Q_ID
			from ( select top(3) q.Q_ID from Questions q, Exam E
				where q.Type='TF'and e.Ex_ID=@eid and E.Crs_ID=Q.Crs_ID order by NEWID()) as TFTable
		
			SELECT q.Q_ID, q.Question, q.Type, qc.Choice 
				FROM Exam_Questions eq
				JOIN Questions q ON eq.Q_ID = q.Q_ID
				LEFT JOIN Question_Choices qc ON q.Q_ID = qc.Q_ID
				WHERE eq.Ex_ID = @eid;
		End Try
		Begin catch
			select 'Generation Error'
        End catch


-----------------------------------------------------------------------
Create PROCEDURE [dbo].[SubmitExamAnswer]
    @Std_SSN BIGINT,
    @Ex_ID INT,
	@Q_ID INT,
    @Answer  NVARCHAR(100)
AS
BEGIN
    -- Start a transaction to ensure data integrity
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Insert the student's answers into the Student_Answer table
        INSERT INTO Student_Answer (Std_SSN, Ex_ID, Q_ID, Answer, Std_Grade)
        SELECT @Std_SSN, @Ex_ID, @Q_ID, @Answer, 0
        

        -- Commit the transaction after successful insertion
        COMMIT TRANSACTION;

        SELECT 'Answers submitted successfully' AS Message;
		select sa.Std_SSN,sa.Ex_ID,sa.Q_ID,sa.Answer,sa.Std_Grade from Student_Answer sa
		where sa.Ex_ID=@Ex_ID and sa.Q_ID=@Q_ID and sa.Answer=@Answer and
				sa.Std_SSN=@Std_SSN
				

    END TRY
    BEGIN CATCH
        -- Rollback the transaction in case of an error
        ROLLBACK TRANSACTION;

        --SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END;

-----------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[GetUniqueQuestions]
    @Ex_ID INT
AS
BEGIN
    SELECT DISTINCT
        eq.Q_ID,
        q.Question
    FROM 
        Exam_Questions eq
    INNER JOIN 
        Questions q ON eq.Q_ID = q.Q_ID
    WHERE 
        eq.Ex_ID = @Ex_ID
    ORDER BY 
        q.Question;
END;

-------------------------------------------------------------------------------------
CREATE PROCEDURE GetChoicesForQuestion
    @Q_ID INT
AS
BEGIN
    SELECT
        qc.Choice
    FROM 
        Question_Choices qc
    WHERE 
        qc.Q_ID = @Q_ID
    ORDER BY 
        qc.Choice;
END;


--------------------------------------------------------------------------------------------------------
CREATE TRIGGER CorrectExam
ON Student_Answer
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE sa
    SET sa.Std_Grade = 
        CASE 
            WHEN sa.Answer = q.Correct_Answer THEN q.Point
            ELSE 0
        END
    FROM Student_Answer sa
    JOIN Questions q ON sa.Q_ID = q.Q_ID
    WHERE sa.Std_Grade = 0;  -- Only correct answers that haven't been graded yet

    -- Additional logic to calculate total grade if needed
END;
