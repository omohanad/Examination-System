-- Exam Generation

create PROCEDURE GenerateExamForStudent
    @Std_SSN BIGINT,
    @CourseName VARCHAR(100)
AS
BEGIN
    DECLARE @Crs_ID INT;
    DECLARE @Ex_ID INT;
    DECLARE @Start_Date_Time DATETIME;
    DECLARE @End_Date_Time DATETIME;

    -- Start a transaction to ensure data integrity
    BEGIN TRANSACTION;

    BEGIN TRY
        IF LEN(CAST(@Std_SSN AS varchar(14))) <> 14 --check if the @Std_SSN is 14 digits
        BEGIN
            SELECT 'Student id must be 14-digits number.'
        END

        -- Get the Course ID based on the Course Name
        SELECT @Crs_ID = Crs_ID FROM Course WHERE Course_Name = @CourseName;
        
        IF @Crs_ID IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 'Invalid Course Name';
            RETURN;
        END

        -- Insert the exam details into the Exam table
        SET @Start_Date_Time = GETDATE();

        INSERT INTO Exam (Crs_ID, Start_Date_Time, End_Date_Time, No_Question)
        VALUES (@Crs_ID, @Start_Date_Time, @End_Date_Time, 10);

        -- Get the Exam ID of the newly created exam
        SET @Ex_ID = SCOPE_IDENTITY();

        -- Randomly select 5 MCQ and 5 TF questions
        INSERT INTO Exam_Questions (Ex_ID, Q_ID)
        SELECT @Ex_ID, Q_ID
        FROM Questions
        WHERE Crs_ID = @Crs_ID AND Type = 'MCQ'
        ORDER BY NEWID()
        OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

        INSERT INTO Exam_Questions (Ex_ID, Q_ID)
        SELECT @Ex_ID, Q_ID
        FROM Questions
        WHERE Crs_ID = @Crs_ID AND Type = 'TF'
        ORDER BY NEWID()
        OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

        -- Display the exam questions to the student
        SELECT eq.Ex_ID, q.Q_ID, q.Question, q.Type, qc.Choice
        FROM Exam_Questions eq
        JOIN Questions q ON eq.Q_ID = q.Q_ID
        LEFT JOIN Question_Choices qc ON q.Q_ID = qc.Q_ID
        WHERE eq.Ex_ID = @Ex_ID;

        -- Commit the transaction after successful exam generation
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        -- Rollback the transaction in case of an error
        ROLLBACK TRANSACTION;

        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END;


--Testing SP sp

GenerateExamForStudent 26782108967695, 'Power BI'

---------------------------------------------------------------------------------------------------------

-- Answer Submission
CREATE PROC SubmitExamAnswers
    @Std_SSN BIGINT,
    @Ex_ID INT,
    @Q_ID INT,
    @Answers NVARCHAR(100)
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        IF NOT EXISTS (SELECT Std_SSN, Ex_Id, Q_Id 
                       FROM Student_Answer
                       WHERE Std_SSN = @Std_SSN
                         AND Ex_Id = @Ex_Id
                         AND Q_ID = @Q_Id)
        BEGIN
            -- Begin Transaction
            BEGIN TRANSACTION;

            INSERT INTO Student_Answer
            (Std_SSN, Ex_ID, Q_ID, Answer, Std_Grade)
            SELECT @Std_SSN, @Ex_ID, @Q_ID, @Answers,
                   CASE
                       WHEN @Answers = q.Correct_Answer THEN q.Point
                       ELSE 0
                   END AS grade
            FROM Questions q
            WHERE q.Q_ID = @Q_Id;

            -- Update the Exam end date
            UPDATE Exam
            SET End_Date_Time = GETDATE()
            WHERE Ex_ID = @Ex_ID;

            -- Commit Transaction
            COMMIT TRANSACTION;

            SELECT 'Answers submitted successfully';
        END
        ELSE
        BEGIN
            SELECT 'Duplicate';
        END
    END TRY
    BEGIN CATCH
        -- Rollback the transaction in case of an error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Return error message
        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END;
-- Testing SP
SubmitExamAnswers @Std_SSN= 26782108967695, @Ex_ID= 'Enter Exam id generated to you', @Q_ID = 'Enter Question ID generated to you', @Answers = 'Enter your answer';
go
SubmitExamAnswers @Std_SSN= 26782108967695, @Ex_ID= 'Enter Exam id generated to you', @Q_ID = 'Enter Question ID generated to you', @Answers = 'Enter your answer';
go
SubmitExamAnswers @Std_SSN= 26782108967695, @Ex_ID= 'Enter Exam id generated to you', @Q_ID = 'Enter Question ID generated to you', @Answers = 'Enter your answer';
go
SubmitExamAnswers @Std_SSN= 26782108967695, @Ex_ID= 'Enter Exam id generated to you', @Q_ID = 'Enter Question ID generated to you', @Answers = 'Enter your answer';


---------------------------------------------------------------------------------
-- Helper SPs for the desktop app

CREATE PROCEDURE GetMostRecentExamID
    @CourseName NVARCHAR(100),
    @Std_SSN bigint
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1 e.Ex_ID 
    FROM Exam e
    JOIN Course c ON e.Crs_ID = c.Crs_ID
	JOIN dbo.Course_study cs ON cs.Crs_ID = e.Crs_ID
    WHERE c.Course_Name = @CourseName AND cs.Std_SSN = @Std_SSN
    ORDER BY e.Ex_ID DESC
END

GetMostRecentExamID 'Power BI', 26782108967695
-----------------------------
create PROCEDURE GetQuestionsByCourseName
    @Ex_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT eq.Ex_ID, q.Q_ID, q.Question, q.Type, qc.Choice
        FROM Exam_Questions eq
        JOIN Questions q ON eq.Q_ID = q.Q_ID
        LEFT JOIN Question_Choices qc ON q.Q_ID = qc.Q_ID
        WHERE eq.Ex_ID = @Ex_ID;
END;

GetQuestionsByCourseName 2094
--------------------------------------------------------------------------------
CREATE PROC GetChoices
	@Q_ID int
AS
BEGIN
	SELECT Choice FROM Question_Choices WHERE Q_ID = @Q_ID;
END;





