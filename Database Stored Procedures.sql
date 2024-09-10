/*Stored Procedures 
Power BI GP
23/08/2024*/

-- Create a Stored Procedure to handle SELECT statment on the Person Table.
-- The Search will be either by SSN or First Name and Last Name together. 

Alter PROC GetPerson @ID BIGINT= NULL, @First_Name VARCHAR(50)= NULL, @Last_Name VARCHAR(50)= NULL
WITH ENCRYPTION
AS 
BEGIN
	IF @ID IS NOT NULL
	BEGIN
		IF LEN(CAST(@ID AS VARCHAR(14))) = 14 -- check if the id is 14 digits number as the SSN should be
		BEGIN
			SELECT *
			FROM dbo.Person
			WHERE SSN = @ID;
		END
		ELSE
		BEGIN
			SELECT'ID must be 14-digits number.'
		END
	END
		
	ELSE 
		IF @First_Name IS NOT NULL AND @Last_Name IS NOT NULL  --IF SSN is not provided
	BEGIN
		SELECT *
		FROM dbo.Person
		WHERE Fname = @First_Name AND Lname = @Last_Name
	END
	ELSE
	BEGIN
		SELECT	'Error'
	END
END;

--Calling the select SP on person table
GetPerson @ID=26701177496944;

GetPerson @First_Name='Ahmed', @Last_Name='Ali';

-----------------------------------------------------------------------------------------------------
--Create a Stored Procedure to handle the INSERT on the Person table.

CREATE PROC InsertPerson
    @ID BIGINT,
    @First_Name VARCHAR(50),
    @Last_Name VARCHAR(50),
    @City VARCHAR(50),
    @Street VARCHAR(100),
    @Gender CHAR(1),
    @Graduation_Year INT,
    @Email NVARCHAR(255),
    @Birth_Date DATE
WITH ENCRYPTION 
AS
BEGIN

    BEGIN TRY
        IF LEN(CAST(@ID AS varchar(14))) <> 14 --check if the id is 14 digits
        BEGIN
            SELECT 'ID must be 14-digits number.'
        END

        IF @Gender NOT IN ( 'M', 'F' ) --check gender input
        BEGIN
            SELECT 'Gender Must be M or F'
        END

        IF @Graduation_Year < YEAR(@Birth_Date) + 22
           OR @Graduation_Year > YEAR(@Birth_Date) + 27 -- check for graduation year
        BEGIN
            SELECT 'Graduation year should be within 22 to 27 years after the Birth Date'
        END

		IF NOT EXISTS (SELECT 1 FROM Person WHERE SSN = @ID AND Email = @Email)
		BEGIN
			INSERT INTO Person (SSN, Fname, Lname, City, Street, Gender, Graduation_Year, Email, Birth_Date)
			VALUES (@ID, @First_Name, @Last_Name, @City, @Street, @Gender, @Graduation_Year, @Email, @Birth_Date);

			SELECT 'Person data has been inserted successfully.'
		END
        ELSE
		BEGIN
			SELECT 'ID or Email Already Exist'
		END 
	END TRY
    BEGIN CATCH	
		SELECT 'Insertion Failed'
	END CATCH
 END;


 -- calling the SP
 InsertPerson @ID=29711120200359, @First_Name= 'AbdEl-Rhman', @Last_Name= 'Ashraf', @City = 'Alexandria', @Street = 'El-Agamy', @Gender= 'M',
 @Graduation_Year = 2020, @Email= 'a.a.mohamad@hotmail.com', @Birth_Date = '1997-11-12'
 ----------------------------------------------------------------------------------

 -- create a stored procedure that handle the UPDATE on Person table.

CREATE PROC UpdatePerson
    @ID BIGINT,
    @First_Name VARCHAR(50),
    @Last_Name VARCHAR(50),
    @City VARCHAR(50),
    @Street VARCHAR(100),
    @Gender CHAR(1),
    @Graduation_Year INT,
    @Email NVARCHAR(255),
    @Birth_Date DATE
WITH ENCRYPTION 
AS
BEGIN

    BEGIN TRY
        IF LEN(CAST(@ID AS varchar(14))) <> 14 --check if the id is 14 digits
        BEGIN
            SELECT 'ID must be 14-digits number.'
        END

        IF @Gender NOT IN ( 'M', 'F' ) --check gender input
        BEGIN
            SELECT 'Gender Must be M or F'
        END

        IF @Graduation_Year < YEAR(@Birth_Date) + 22
           OR @Graduation_Year > YEAR(@Birth_Date) + 27 -- check for graduation year
        BEGIN
            SELECT 'Graduation year should be within 22 to 27 years after the Birth Date'
        END

		-- Check relationship with other tables
		IF NOT EXISTS (SELECT 1 FROM Applicant WHERE App_SSN = @ID)
						AND NOT EXISTS (SELECT 1 FROM Person_Phone WHERE SSN = @ID)
						AND NOT EXISTS (SELECT 1 FROM Instructor WHERE Ins_SSn = @ID)
		BEGIN 
			UPDATE Person
				SET
					Fname = @First_Name,
					Lname = @Last_Name,
					City = @City,
					Street = @Street,
					Gender = @Gender,
					Graduation_Year = @Graduation_Year,
					Email = @Email,
					Birth_Date = @Birth_Date
					WHERE SSN = @ID;

			SELECT 'Person data has been updated successfully.'
		END 
		ELSE
		BEGIN
			SELECT 'Table has relationships'
		END 
	END TRY
    BEGIN CATCH
		SELECT 'Update Failed'
	END catch
 END;

 -- calling the SP
 UpdatePerson @ID=29711120200359, @First_Name= 'AbdEl-Rhman', @Last_Name= 'Mohamad', @City = 'Alexandria', @Street = 'El-Agamy', @Gender= 'M',
 @Graduation_Year = 2020, @Email= 'a.a.mohamad@hotmail.com', @Birth_Date = '1997-11-12'
  ----------------------------------------------------------------------------------

 -- create a stored procedure that handle the DELETE on Person Table

CREATE PROC DeletePerson @ID BIGINT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        IF LEN(CAST(@ID AS varchar(14))) <> 14 --check if the id is 14 digits
        BEGIN
            SELECT 'ID must be 14-digits number.'
        END

        -- Check relationship with other tables
		IF NOT EXISTS (SELECT 1 FROM Applicant WHERE App_SSN = @ID)
						AND NOT EXISTS (SELECT 1 FROM Person_Phone WHERE SSN = @ID)
						AND NOT EXISTS (SELECT 1 FROM Instructor WHERE Ins_SSn = @ID)
        BEGIN
            DELETE FROM Person
            WHERE SSN = @ID

            SELECT 'Person has been deleted'
        END
        ELSE
        BEGIN
            SELECT 'Table has relationships'
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error'
    END CATCH
END;

 -- calling the SP
 DeletePerson @ID=29711120200359


 -------------------------------------------------------------------------------------

 -- Creating SP for the Person_Phone Table

 -- Create SP to handle SELECT on Petson_Number table

ALTER PROC GetPhoneNumber
    @ID BIGINT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        IF LEN(CAST(@ID AS VARCHAR(14))) <> 14 -- Check if the SSN is 14 digits
        BEGIN
            SELECT 'ID must be a 14-digit number.'
			RETURN 
        END

		IF NOT exists (SELECT 1 FROM Person_Phone WHERE SSN = @ID)  -- Check if the person has a phone number 
        BEGIN
			SELECT 'This Person does not have a phone number'
			RETURN 
		END
        
		-- Select phone records for the given SSN
        SELECT *
        FROM Person_Phone
        WHERE SSN = @ID;

    END TRY
    BEGIN CATCH
        SELECT 'Error';
		RETURN 
    END CATCH
END;


--Call the SP

GetPhoneNumber 29711120200359

--------------------------------------------------------------------------------------------------------------------

--Create a SP for the INSEART on the Person_Phone table 

alter PROC InsertPhoneNumber
    @ID BIGINT,
    @Phone VARCHAR(11)
WITH ENCRYPTION 
AS
BEGIN
    BEGIN TRY
        
        IF LEN(CAST(@ID AS VARCHAR(14))) <> 14 -- Check if the SSN is 14 digits
        BEGIN
            SELECT 'ID must be a 14-digit number.'
			RETURN 
        END

		-- Check if the new phone number is 11 digits
        IF LEN(@Phone) <> 11
        BEGIN
            select 'New phone number must be 11 digits In quotation marks.'
			RETURN 
        END

		IF NOT EXISTS (SELECT 1 FROM Person WHERE SSN=@ID) -- Check if the person exists in the Person table
		BEGIN
			SELECT 'This Person Does Not Exist.'
			RETURN 
		END
        
		--check if the person has this phone numebr before or not
		IF NOT EXISTS (SELECT 1 FROM Person_Phone WHERE SSN = @ID AND Phone = @Phone)
		BEGIN
			INSERT INTO Person_Phone (SSN, Phone)
			VALUES (@ID, @Phone);
       
			SELECT 'Phone number inserted successfully.'
			RETURN 
		END
        ELSE
        BEGIN
			SELECT 'Phone Number already exists for this person'
			RETURN 
		END
    END TRY
		BEGIN CATCH
            SELECT 'Error'
			RETURN 
		END CATCH
END;

-- call the SP
InsertPhoneNumber 29711120200359, '01210234321'


--------------------------------------------------------------------------------------------------------------------

--Create a SP for the UPDATE on the Person_Phone table 

Create PROC UpdatePersonPhone
    @ID BIGINT,
    @OldPhone VARCHAR(11),
    @NewPhone VARCHAR(11)
WITH ENCRYPTION 
AS
BEGIN
    BEGIN TRY
        -- Check if the SSN is 14 digits
        IF LEN(CAST(@ID AS VARCHAR(14))) <> 14
        BEGIN
            select 'ID must be a 14-digit number.'
			RETURN
        END

        -- Check if the old phone number is 11 digits
        IF LEN(@OldPhone) <> 11
        BEGIN
            select 'Old phone number must be 11 digits In quotation marks.'
			RETURN 
        END

        -- Check if the new phone number is 11 digits
        IF LEN(@NewPhone) <> 11
        BEGIN
            select 'New phone number must be 11 digits In quotation marks.'
			RETURN 
        END

        -- Check if the SSN exists in the Person_Phone table
        IF NOT EXISTS (SELECT 1 FROM Person_Phone WHERE SSN = @ID AND Phone = @OldPhone)
        BEGIN
            select 'The phone number does not exist for this person.'
			RETURN 
        END
		       -- Make sure the new number is not the same as the old number
        IF @OldPhone = @NewPhone
        BEGIN
            SELECT 'The new phone number is the same as the old one.';
            RETURN;
        END
		        -- Check if the new phone number already exists for this person
        IF EXISTS (SELECT 1 FROM Person_Phone WHERE SSN = @ID AND Phone = @NewPhone)
        BEGIN
            SELECT 'The new phone number already exists for this person.';
            RETURN;
        END
        -- Update the phone number
        UPDATE Person_Phone
        SET Phone = @NewPhone
        WHERE SSN = @ID AND Phone = @OldPhone;

        PRINT 'Phone number has been updated successfully.'

    END TRY
    BEGIN CATCH
        select 'Error occurred while updating phone record';
    END CATCH
END;
            
-- call the SP

UpdatePersonPhone @ID=29711120200359, @OldPhone='01210234321', @NewPhone='01210234322'



--------------------------------------------------------------------------------------------------------------------

--Create a SP for the DELETE on the Person_Phone table 

alter PROC DeletePhoneNumber
    @ID BIGINT,
    @Phone VARCHAR(11)
WITH ENCRYPTION 
AS
BEGIN
    BEGIN TRY
        -- Check if the SSN is 14 digits
        IF LEN(CAST(@ID AS VARCHAR(14))) <> 14
        BEGIN
            SELECt 'ID must be a 14-digit number.'
            RETURN
        END

        -- Check if the phone number is 11 digits
        IF LEN(@Phone) <> 11
        BEGIN
            select 'Phone number must be 11 digits In quotation marks.'
            RETURN
        END

        -- Check if the SSN and Phone combination exists in the Person_Phone table
        IF NOT EXISTS (SELECT 1 FROM Person_Phone WHERE SSN = @ID AND Phone = @Phone)
        BEGIN
            select 'The phone number does not exist for this person.'
            RETURN
        END

        -- Delete the phone number
        DELETE FROM Person_Phone
        WHERE SSN = @ID AND Phone = @Phone;

        select 'Phone number has been deleted successfully.'
		RETURN 

    END TRY
    BEGIN CATCH
        select 'Error occurred while deleting phone record';
		RETURN 
    END CATCH
END;


--call SP
DeletePhoneNumber 29711120200359, '01210234322'


--------------------------------------------------------------------------------------------------------------------
--create SPs for the Gradute Company Table

-- create SP for SELECT on Gradute Company table

CREATE PROC GetGraduateCompany
    @Grad_ID BIGINT = NULL,  -- Optional parameter
    @Com_ID INT = NULL     -- Optional parameter
WITH ENCRYPTION 
AS
BEGIN
    BEGIN TRY
        -- Check if both parameters are NULL
        IF @Grad_ID IS NULL AND @Com_ID IS NULL
        BEGIN
            select 'Please provide either a graduate id, company id, or both.'
            RETURN
        END

        -- Check if G_SSN is a 14-digit number
        IF LEN(CAST(@Grad_ID AS VARCHAR(14))) <> 14
        BEGIN
            select 'Graduate id must be a 14-digit number.'
            RETURN
        END

        -- Check if any records match the criteria
        IF EXISTS (SELECT 1 
                   FROM Graduate_Company 
                   WHERE (@Grad_ID IS NULL OR G_SSN = @Grad_ID)
                     AND (@Com_ID IS NULL OR Com_ID = @Com_ID))
        BEGIN
            -- If records exist
            SELECT G_SSN, Com_ID
            FROM Graduate_Company
            WHERE (@Grad_ID IS NULL OR G_SSN = @Grad_ID)
              AND (@Com_ID IS NULL OR Com_ID = @Com_ID);
        END
        ELSE
        BEGIN
            -- If no records exist
            select 'No records found for the given criteria.'
			RETURN 
        END
    END TRY
    BEGIN CATCH
        select 'ERROR'
    END CATCH
END;

--  call SP
GetGraduateCompany @Grad_ID = 29711120200359


--------------------------------------------------------------------------------------------------------------------

-- create SP for INSERT on Gradute Company table

create PROC InsertGraduateCompany
    @Grad_ID BIGINT,
    @Com_ID INT
WITH ENCRYPTION 
AS
BEGIN
    BEGIN TRY

        -- Check if Grad_ID is a 14-digit number
        IF LEN(CAST(@Grad_ID AS VARCHAR(14))) <> 14
        BEGIN
            SELECT 'Graduate ID must be a 14-digit number.';
            RETURN;
        END
        
        -- Check if the Grad_ID exists in the graduate table
        IF NOT EXISTS (SELECT 1 FROM Graduate WHERE G_SSN = @Grad_ID)
        BEGIN
            SELECT 'The Person is not a graduate with the given ID does not exist.';
            RETURN;
        END

        -- Check if the Com_ID exists in the Company table
        IF NOT EXISTS (SELECT 1 FROM Company WHERE Com_ID = @Com_ID)
        BEGIN
            SELECT 'Company with the given ID does not exist.';
            RETURN;
        END

        -- Check if the record already exists in the Graduate_Company table
        IF EXISTS (SELECT 1 FROM Graduate_Company WHERE G_SSN = @Grad_ID AND Com_ID = @Com_ID)
        BEGIN
            SELECT 'The record already exists in the Graduate_Company table.';
            RETURN;
        END

        BEGIN
            -- Insert into Graduate_Company table
			INSERT INTO Graduate_Company (G_SSN, Com_ID)
			VALUES (@Grad_ID, @Com_ID);
            
			SELECT 'Graduate Company record has been inserted successfully.';
        END
    END TRY
    BEGIN CATCH
        -- Rollback the transaction in case of any error
        ROLLBACK TRANSACTION;
        SELECT 'ERROR';
    END CATCH
END;
-- call SP

InsertGraduateCompany 29711120200359, 510


--------------------------------------------------------------------------------------------------------------------

-- create SP for UPDATE on Gradute Company table

CREATE PROC UpdateGraduateCompany
    @Grad_ID BIGINT,
    @New_Com_ID INT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
	
		-- Check if G_SSN is a 14-digit number
        IF LEN(CAST(@Grad_ID AS VARCHAR(14))) <> 14
        BEGIN
            select 'Graduate id must be a 14-digit number.'
            RETURN
        END
        
        -- Check if the G_SSN exists in the Graduate_Company table
        IF NOT EXISTS (SELECT 1 FROM Graduate_Company WHERE G_SSN = @Grad_ID)
        BEGIN
            SELECT 'Graduate id does not exist in this table.';
            RETURN;
        END

        -- Check if the new Com_ID exists in the Company table
        IF NOT EXISTS (SELECT 1 FROM Company WHERE Com_ID = @New_Com_ID)
        BEGIN
            SELECT 'Company with the given ID does not exist.';
            RETURN;
        END
		
		 -- Check if the new record already exists in the Graduate_Company table
        IF EXISTS (SELECT 1 FROM Graduate_Company WHERE G_SSN = @Grad_ID AND Com_ID = @New_Com_ID)
        BEGIN
            SELECT 'The record already exists in the table.';
            RETURN;
        END

        -- Update the Graduate_Company record
        BEGIN
            UPDATE Graduate_Company
            SET Com_ID = @New_Com_ID
            WHERE G_SSN = @Grad_ID;

            SELECT 'Graduate_Company record has been updated successfully.'
			RETURN
        END 
    END TRY
    BEGIN CATCH
        SELECT 'ERROR';
    END CATCH
END;

-- CALL SP

UpdateGraduateCompany 29711120200359, 510

------------------------------------------------------------------------------
-- create SP for DELETE on Gradute Company table

CREATE PROC DeleteGraduateCompany
    @Grad_ID BIGINT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
	
		-- Check if G_SSN is a 14-digit number
        IF LEN(CAST(@Grad_ID AS VARCHAR(14))) <> 14
        BEGIN
            select 'Graduate id must be a 14-digit number.'
            RETURN
        END
        
        -- Check if the G_SSN exists in the Graduate_Company table
        IF NOT EXISTS (SELECT 1 FROM Graduate_Company WHERE G_SSN = @Grad_ID)
        BEGIN
            SELECT 'The person with the given id does not exist in the table.';
            RETURN;
        END

        -- Delete the Graduate_Company record
        DELETE FROM Graduate_Company
        WHERE G_SSN = @Grad_ID;

        SELECT 'Graduate Company record has been deleted successfully.';
		RETURN 
    END TRY
    BEGIN CATCH
        SELECT 'ERROR';
    END CATCH
END;

-- CALL SP
DeleteGraduateCompany 29711120200359



--------------------------------------------------------------------------------------------------------------------
--create SPs for the Student Freelance Table

--Create SP for SELECT on Student Freelance Table

CREATE PROC GetStudentFreelance
    @Std_ID BIGINT = NULL
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
	-- Check if parameters is NULL
        IF @Std_ID IS NULL
        BEGIN
            select 'Please provide student id.'
            RETURN
        END

        -- Check if @Std_ID is a 14-digit number
        IF LEN(CAST(@Std_ID AS VARCHAR(14))) <> 14
        BEGIN
            select 'Student id must be a 14-digit number.'
            RETURN
        END

		IF EXISTS (SELECT 1 FROM Student_Freelance WHERE Std_SSN = @Std_ID)
		BEGIN
			SELECT * 
			FROM Student_Freelance
			WHERE Std_SSN = @Std_ID;
		END
        BEGIN
			SELECT 'This Student does not have a freelance job'
			RETURN	
		END
    END TRY
    BEGIN CATCH
        SELECT 'Error';
    END CATCH
END;

-- call sp
GetStudentFreelance 29711120200359


--------------------------------------------------------------------------------------------------------------------

-- create SP for INSERT on Student Freelance table

CREATE PROC InsertStudentFreelance
    @FJ_ID INT,
    @Std_ID BIGINT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        -- Check if Std_SSN is a 14-digit number
        IF LEN(CAST(@Std_ID AS VARCHAR(14))) <> 14
        BEGIN
            SELECT 'Student id must be a 14-digit number.';
            RETURN;
        END

        -- Check if the Std_SSN exists in the Student table
        IF NOT EXISTS (SELECT 1 FROM Student WHERE Std_SSN = @Std_ID)
        BEGIN
            SELECT 'Student with the given id does not exist.';
            RETURN;
        END

        -- Check if the F_ID exists in the Freelance table
        IF NOT EXISTS (SELECT 1 FROM Freelance WHERE F_ID = @FJ_ID)
        BEGIN
            SELECT 'Freelance with the given ID does not exist.';
            RETURN;
        END

        -- Check if the record already exists in the Student_Freelance table
        IF NOT EXISTS (SELECT 1 FROM Student_Freelance WHERE F_ID = @FJ_ID AND Std_SSN = @Std_ID)
        BEGIN
            -- Insert into Student_Freelance table
            INSERT INTO Student_Freelance (F_ID, Std_SSN)
            VALUES (@FJ_ID, @Std_ID);

            SELECT 'Student_Freelance record has been inserted successfully.';
        END
        ELSE
        BEGIN
            SELECT 'The record already exists in the Student_Freelance table.';
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error';
    END CATCH
END;

--------------------------------------------------------------------------------------------------------------------

-- create SP for UPDATE on Student Freelance table

alter PROC UpdateStudentFreelance
    @Std_ID BIGINT = NULL ,
    @Old_F_ID INT = NULL,
    @New_F_ID INT = NULL
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
		-- Check if all parameters are provided
        IF @Std_ID IS NULL OR @Old_F_ID IS NULL OR @New_F_ID IS NULL
        BEGIN
            SELECT 'Please provide the student id, old freelance job id, and new freelance id.';
            RETURN;
        END

		-- Check if Std_SSN is a 14-digit number
        IF LEN(CAST(@Std_ID AS VARCHAR(14))) <> 14
        BEGIN
            SELECT 'Student id must be a 14-digit number.';
            RETURN;
        END

        -- Check if the Std_SSN exists in the Student_Freelance table with the Old_F_ID
        IF NOT EXISTS (SELECT 1 FROM Student_Freelance WHERE Std_SSN = @Std_ID AND F_ID = @Old_F_ID)
        BEGIN
            SELECT 'The specified student and freelance ID combination does not exist.';
            RETURN;
        END

        -- Check if the New_F_ID exists in the Freelance table
        IF NOT EXISTS (SELECT 1 FROM Freelance WHERE F_ID = @New_F_ID)
        BEGIN
            SELECT 'Freelance with the given new ID does not exist.';
            RETURN;
        END

        -- Check if the new record already exists in the Student_Freelance table
        IF EXISTS (SELECT 1 FROM Student_Freelance WHERE Std_SSN = @Std_ID AND F_ID = @New_F_ID)
        BEGIN
            SELECT 'The new freelance ID already exists for this student.';
            RETURN;
        END

        -- Update the Student_Freelance record
        BEGIN
            UPDATE Student_Freelance
            SET F_ID = @New_F_ID
            WHERE Std_SSN = @Std_ID AND F_ID = @Old_F_ID;

            SELECT 'Student_Freelance record has been updated successfully.';
			RETURN 
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error';
		RETURN 
    END CATCH
END;

-- call sp

UpdateStudentFreelance 29711120200359

----------------------------------------------------------------------------
-- create SP for DELETE on Student Freelance tabl

CREATE PROC DeleteStudentFreelance
    @Std_ID BIGINT,
    @F_ID INT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
		-- Check if Std_SSN is a 14-digit number
        IF LEN(CAST(@Std_ID AS VARCHAR(14))) <> 14
        BEGIN
            SELECT 'Student id must be a 14-digit number.';
            RETURN;
        END

        -- Check if the combination of Std_ID and F_ID exists in the Student_Freelance table
        IF NOT EXISTS (SELECT 1 FROM Student_Freelance WHERE Std_SSN = @Std_ID AND F_ID = @F_ID)
        BEGIN
            SELECT 'The specified student and freelance ID combination does not exist.';
            RETURN;
        END

        -- Delete the Student_Freelance record
        DELETE FROM Student_Freelance
        WHERE Std_SSN = @Std_ID AND F_ID = @F_ID;

        SELECT 'Student_Freelance record has been deleted successfully.';
    END TRY
    BEGIN CATCH
        SELECT 'Error';
    END CATCH
END;


-- call sp

DeleteStudentFreelance 29711120200359, 550


--------------------------------------------------------------------------------------------------------------------
--create SPs for the Student Certificate Table

-- Create SP for SELECT on Student Certificate Table

CREATE PROC GetStudentCertificate
    @Std_ID BIGINT = NULL
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
		-- Check if parameters is NULL
        IF @Std_ID IS NULL
        BEGIN
            select 'Please provide student id.'
            RETURN
        END

        -- Check if @Std_ID is a 14-digit number
        IF LEN(CAST(@Std_ID AS VARCHAR(14))) <> 14
        BEGIN
            select 'Student id must be a 14-digit number.'
            RETURN
        END

		IF EXISTS (SELECT 1 FROM Student_Certificate WHERE Std_SSN = @Std_ID)
		BEGIN
			SELECT * 
			FROM Student_Certificate
			WHERE Std_SSN = @Std_ID;
		END
        BEGIN
			SELECT 'This Student does not have a certificate'
			RETURN	
		END
    END TRY
    BEGIN CATCH
        SELECT 'Error';
    END CATCH
END;


--------------------------------------------------------------------------------------
-- create SP for INSERT on Student Certificate table

CREATE PROC InsertStudentCertificate
    @Cert_ID INT,
    @Std_ID BIGINT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        -- Check if Std_SSN is a 14-digit number
        IF LEN(CAST(@Std_ID AS VARCHAR(14))) <> 14
        BEGIN
            SELECT 'Student id must be a 14-digit number.';
            RETURN;
        END

        -- Check if the Std_SSN exists in the Student table
        IF NOT EXISTS (SELECT 1 FROM Student WHERE Std_SSN = @Std_ID)
        BEGIN
            SELECT 'Student with the given id does not exist.';
            RETURN;
        END

        -- Check if the Cert_ID exists in the Freelance table
        IF NOT EXISTS (SELECT 1 FROM Student_Certificate WHERE Verif_ID = @Cert_ID)
        BEGIN
            SELECT 'Certificate with the given ID does not exist.';
            RETURN;
        END

        -- Check if the record already exists in the Student_Certificate table
        IF NOT EXISTS (SELECT 1 FROM Student_Certificate WHERE Verif_ID = @Cert_ID AND Std_SSN = @Std_ID)
        BEGIN
            -- Insert into Student_Freelance table
            INSERT INTO Student_Certificate (Verif_ID, Std_SSN)
            VALUES (@Cert_ID, @Std_ID);

            SELECT 'Student Certificate record has been inserted successfully.';
        END
        ELSE
        BEGIN
            SELECT 'The record already exists in the Student Certificate table.';
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error';
    END CATCH
END;

--------------------------------------------------------------------------------------------------------------------

-- create SP for Update on Student Certificate table

create PROC UpdateStudentCertificate
    @Std_ID BIGINT = NULL ,
    @Old_Cert_ID INT = NULL,
    @New_Cert_ID INT = NULL
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
		-- Check if all parameters are provided
        IF @Std_ID IS NULL OR @Old_Cert_ID IS NULL OR @New_Cert_ID IS NULL
        BEGIN
            SELECT 'Please provide the student id, old Certificate id, and new Certificate id.';
            RETURN;
        END

		-- Check if Std_SSN is a 14-digit number
        IF LEN(CAST(@Std_ID AS VARCHAR(14))) <> 14
        BEGIN
            SELECT 'Student id must be a 14-digit number.';
            RETURN;
        END

        -- Check if the Std_SSN exists in the Student Certificate table with the Old_F_ID
        IF NOT EXISTS (SELECT 1 FROM Student_Certificate WHERE Std_SSN = @Std_ID AND Verif_ID = @Old_Cert_ID)
        BEGIN
            SELECT 'The specified student and freelance ID combination does not exist.';
            RETURN;
        END

        -- Check if the New_Cert_ID exists in the Certificate table
        IF NOT EXISTS (SELECT 1 FROM Student_Certificate WHERE Verif_ID = @New_Cert_ID)
        BEGIN
            SELECT 'Certificate with the given new ID does not exist.';
            RETURN;
        END

        -- Check if the new record already exists in the Student Certificate table
        IF EXISTS (SELECT 1 FROM Student_Certificate WHERE Std_SSN = @Std_ID AND Verif_ID = @New_Cert_ID)
        BEGIN
            SELECT 'The new Certificate ID already exists for this student.';
            RETURN;
        END

        -- Update the Student Certificate record
        BEGIN
            UPDATE Student_Certificate
            SET Verif_ID = @New_Cert_ID
            WHERE Std_SSN = @Std_ID AND Verif_ID = @Old_Cert_ID;

            SELECT 'Student Certificate record has been updated successfully.';
			RETURN 
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error';
		RETURN 
    END CATCH
END;

----------------------------------------------------------------------------
-- create SP for DELETE on Student Certificate tabl

CREATE PROC DeleteStudentCertificate
    @Std_ID BIGINT,
    @Cert_ID INT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
		-- Check if Std_SSN is a 14-digit number
        IF LEN(CAST(@Std_ID AS VARCHAR(14))) <> 14
        BEGIN
            SELECT 'Student id must be a 14-digit number.';
            RETURN;
        END

        -- Check if the combination of Std_ID and Cert_ID exists in the Student_Certificate table
        IF NOT EXISTS (SELECT 1 FROM Student_Certificate WHERE Std_SSN = @Std_ID AND Verif_ID = @Cert_ID)
        BEGIN
            SELECT 'The specified student and Certificate ID combination does not exist.';
            RETURN;
        END

        -- Delete the Student_Certificate record
        DELETE FROM Student_Certificate
        WHERE Std_SSN = @Std_ID AND Verif_ID = @Cert_ID;

        SELECT 'Student Certificate record has been deleted successfully.';
    END TRY
    BEGIN CATCH
        SELECT 'Error';
    END CATCH
END;


-----------------------------------------------------------------------------------------------
--Create SPs for the Application table

-- Create a SP for the SELECT on the Application tbale

CREATE PROC GetApplication
	@Applicant_ID BIGINT = NULL
AS
BEGIN
    BEGIN TRY
		-- Check if parameters is NULL
        IF  @Applicant_ID IS NULL
        BEGIN
            select 'Please provide applicant id.'
            RETURN
        END

        -- Check if @Applicant_ID is a 14-digit number
        IF LEN(CAST(@Applicant_ID AS VARCHAR(14))) <> 14
        BEGIN
            select 'Applicant id must be a 14-digit number.'
            RETURN
        END

		IF EXISTS (SELECT 1 FROM Application where APP_SSN = @Applicant_ID)
			begin
				  SELECT * 
                  FROM Application
                  WHERE APP_SSN = @Applicant_ID
			END
            BEGIN	
				SELECT 'Applicant does not exist'
			end
    END TRY
    BEGIN CATCH
        SELECT 'Error';
    END CATCH
END;

-- call SP

GetApplication 29711120200359


--------------------------------------------------------------------------------------
-- create SP for INSERT on Application table

CREATE PROC InsertApplication
    @Applicant_ID BIGINT,
    @Brn_ID INT,
    @Trc_ID INT,
    @Int_ID INT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
		-- Check if @Applicant_ID is a 14-digit number
        IF LEN(CAST(@Applicant_ID AS VARCHAR(14))) <> 14
        BEGIN
            select 'Applicant id must be a 14-digit number.'
            RETURN
        END

        -- Check if App_SSN exists in the Person table
        IF NOT EXISTS (SELECT 1 FROM Person WHERE SSN = @Applicant_ID)
        BEGIN
            SELECT 'The Person with the given id does not exist.';
            RETURN;
        END
        
        -- Check if Brn_ID exists in the Branch table
        IF NOT EXISTS (SELECT 1 FROM Branch WHERE Brn_ID = @Brn_ID)
        BEGIN
            SELECT 'The Branch with the given ID does not exist.';
            RETURN;
        END

        -- Check if Trc_ID exists in the Track table
        IF NOT EXISTS (SELECT 1 FROM Track WHERE Trc_ID = @Trc_ID)
        BEGIN
            SELECT 'The Track with the given ID does not exist.';
            RETURN;
        END

        -- Check if Int_ID exists in the Intake table
        IF NOT EXISTS (SELECT 1 FROM Intake WHERE Int_ID = @Int_ID)
        BEGIN
            SELECT 'The Intake with the given ID does not exist.';
            RETURN;
        END

        -- Check if the combination of @Applicant_ID, and Int_ID already exists
        IF EXISTS (SELECT 1 FROM Application 
                   WHERE App_SSN = @Applicant_ID AND Int_ID = @Int_ID)
        BEGIN
            SELECT 'This applicant has already applied for this intake.';
            RETURN;
        END

        -- Insert into Application table
        BEGIN
            INSERT INTO Application (App_SSN, Brn_ID, Trc_ID, Int_ID)
            VALUES (@Applicant_ID, @Brn_ID, @Trc_ID, @Int_ID);

            SELECT 'Application record has been inserted successfully.';
			RETURN 
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error';
    END CATCH
END;

--------------------------------------------------------------------------------------

-- create SP for UPDATE on Application table


CREATE PROC UpdateApplication
    @APP_ID INT,
    @Applicant_ID BIGINT,
    @Brn_ID INT,
    @Trc_ID INT,
    @Int_ID INT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
		-- Check if @Applicant_ID is a 14-digit number
        IF LEN(CAST(@Applicant_ID AS VARCHAR(14))) <> 14
        BEGIN
            select 'Applicant id must be a 14-digit number.'
            RETURN
        END

		-- Check if @Applicant_ID exists in the Person table
        IF NOT EXISTS (SELECT 1 FROM Person WHERE SSN = @Applicant_ID)
        BEGIN
            SELECT 'The Person with the given ID does not exist.';
            RETURN;
        END
        
        -- Check if Brn_ID exists in the Branch table
        IF NOT EXISTS (SELECT 1 FROM Branch WHERE Brn_ID = @Brn_ID)
        BEGIN
            SELECT 'The Branch with the given ID does not exist.';
            RETURN;
        END

        -- Check if Trc_ID exists in the Track table
        IF NOT EXISTS (SELECT 1 FROM Track WHERE Trc_ID = @Trc_ID)
        BEGIN
            SELECT 'The Track with the given ID does not exist.';
            RETURN;
        END

        -- Check if Int_ID exists in the Intake table
        IF NOT EXISTS (SELECT 1 FROM Intake WHERE Int_ID = @Int_ID)
        BEGIN
            SELECT 'The Intake with the given ID does not exist.';
            RETURN;
        END

		-- Check if the combination of Applicant_ID, Brn_ID, Trc_ID, and Int_ID already exists
        IF EXISTS (SELECT 1 FROM Application 
                   WHERE App_SSN = @Applicant_ID 
                   AND Brn_ID = @Brn_ID 
                   AND Trc_ID = @Trc_ID 
                   AND Int_ID = @Int_ID)
		BEGIN
			-- Update the Application record
			UPDATE APPLICATION
				SET App_SSN = @Applicant_ID, Brn_ID = @Brn_ID, Trc_ID = @Trc_ID, Int_ID = @Int_ID
			WHERE APP_ID = @APP_ID;
		
			SELECT 'Application record has been updated successfully.';
		END
    END TRY
    BEGIN CATCH
        SELECT 'Error.';
    END CATCH
END;


--------------------------------------------------------------------------------------
-- create SP for DELETE on Application table

CREATE PROC DeleteApplication
    @APP_ID INT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        -- Check if the Application record exists
        IF NOT EXISTS (SELECT 1 FROM Application WHERE APP_ID = @APP_ID)
        BEGIN
            SELECT 'Application record with the given ID does not exist.';
            RETURN;
        END

		BEGIN
			-- Delete the Application record
			DELETE FROM Application
			WHERE APP_ID = @APP_ID;

			SELECT 'Application record has been deleted successfully.';
			RETURN
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error';
    END CATCH
END;

-------------------------------------------------------------------------------------

-- Create SPs for the Course Study Table.

-- create a SP for SELECt on Course Study Table.

CREATE PROC GetCourseStudy
    @Std_ID BIGINT = NULL,
    @Crs_ID INT = NULL
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
		-- Check if Student id is a 14-digit number
        IF LEN(CAST(@Std_ID AS VARCHAR(14))) <> 14
        BEGIN
            select 'Student id must be a 14-digit number.'
            RETURN
        END

		-- Check if at least one parameter is provided
        IF @Std_ID IS NULL AND @Crs_ID IS NULL
        BEGIN
            SELECT 'Please provide student id or course ID.';
            RETURN;
        END

		-- Check if the combination of Std_SSN and Crs_ID exists in the Course_study table
        IF @Std_ID IS NOT NULL AND @Crs_ID IS NOT NULL 
			AND NOT EXISTS (SELECT 1 FROM Course_study WHERE Std_SSN = @Std_ID AND Crs_ID = @Crs_ID)
        BEGIN
            SELECT 'The provided student id and course ID combination does not exist in the Course study table.';
            RETURN;
		END
        
		BEGIN
			-- Select records based on provided parameters
			SELECT Std_SSN, Crs_ID, Total_Grades
			FROM Course_study
			WHERE (@Std_ID IS NULL OR Std_SSN = @Std_ID)
					AND (@Crs_ID IS NULL OR Crs_ID = @Crs_ID);
		END 
	END TRY
    BEGIN CATCH
		SELECT	'Error.'
	END CATCH
END;

-------------------------------------------------------------------------------------

-- create a SP for INSERT on Course Study Table.

CREATE PROC InsertCourseStudy
    @Std_ID BIGINT,
    @Crs_ID INT,
    @Total_Grades INT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
		-- Check if Student id is a 14-digit number
        IF LEN(CAST(@Std_ID AS VARCHAR(14))) <> 14
        BEGIN
            select 'Student id must be a 14-digit number.'
            RETURN
        END

		-- Check if all parameters are provided
        IF @Std_ID IS NULL OR @Crs_ID IS NULL OR @Total_Grades IS NULL
        BEGIN
            SELECT 'Please provide the student SSN, course ID, and total grades.';
            RETURN;
        END

		-- Check if the @Std_ID exists in the Student table
        IF NOT EXISTS (SELECT 1 FROM Student WHERE Std_SSN = @Std_ID)
        BEGIN
            SELECT 'Student id does not exist.';
            RETURN;
        END

		-- Check if the Crs_ID exists in the Course table
        IF NOT EXISTS (SELECT 1 FROM Course WHERE Crs_ID = @Crs_ID)
        BEGIN
            SELECT 'Course ID does not exist.';
            RETURN;
        END

		IF EXISTS (SELECT 1 FROM Course_Study WHERE Std_SSN = @Std_ID AND Crs_ID = @Crs_ID)
        BEGIN
			SELECT 'This recordes already exist'
			RETURN
        END
        
		BEGIN
			-- Insert the new record
			INSERT INTO Course_study (Std_SSN, Crs_ID, Total_Grades)
			VALUES (@Std_ID, @Crs_ID, @Total_Grades);

			SELECT	'Course Study record has been inserted successfully'
			RETURN 
        END
    END TRY
    BEGIN CATCH
        SELECT 'Error';
    END CATCH
END;


-------------------------------------------------------------------------------------

-- create a SP for UPDATE on Course Study Table.

CREATE PROC UpdateCourseStudy
    @Std_ID BIGINT,
    @Crs_ID INT,
    @Total_Grades INT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
		-- Check if Student id is a 14-digit number
        IF LEN(CAST(@Std_ID AS VARCHAR(14))) <> 14
        BEGIN
            select 'Student id must be a 14-digit number.'
            RETURN
        END

		-- Check if all parameters are provided
        IF @Std_ID IS NULL OR @Crs_ID IS NULL OR @Total_Grades IS NULL
        BEGIN
            SELECT 'Please provide the student id, course id, and total grades.';
            RETURN;
        END

		-- Check if the combination of Std_SSN and Crs_ID exists in the Course_study table
        IF NOT EXISTS (SELECT 1 FROM Course_study WHERE Std_SSN = @Std_ID AND Crs_ID = @Crs_ID)
        BEGIN
            SELECT 'The specified student and course id combination does not exist.';
            RETURN;
        END

		BEGIN
			--update records
			UPDATE Course_study
				SET Total_Grades = @Total_Grades
			WHERE Std_SSN = @Std_ID AND Crs_ID = @Crs_ID;

			SELECT 'Course study records has been updated successfully';
			RETURN 
		END
    END TRY
	BEGIN CATCH
		SELECT 'Error'
	END CATCH
END;
   

-------------------------------------------------------------------------------------

-- create a SP for DELETE on Course Study Table.

CREATE PROC DeleteCourseStudy
    @Std_ID BIGINT,
    @Crs_ID INT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
		
		-- Check if Student id is a 14-digit number
        IF LEN(CAST(@Std_ID AS VARCHAR(14))) <> 14
        BEGIN
            select 'Student id must be a 14-digit number.'
            RETURN
        END

		-- Check if all parameters are provided
        IF @Std_ID IS NULL OR @Crs_ID IS NULL
        BEGIN
            SELECT 'Please provide the student id and course id.';
            RETURN;
        END

		-- Check if the combination of Std_SSN and Crs_ID exists in the Course_study table
        IF NOT EXISTS (SELECT 1 FROM Course_study WHERE Std_SSN = @Std_ID AND Crs_ID = @Crs_ID)
        BEGIN
            SELECT 'The specified student and course ID combination does not exist.';
            RETURN;
        END

		BEGIN
			--Delete records
			DELETE FROM Course_study
			WHERE Std_SSN = @Std_ID AND Crs_ID = @Crs_ID;

			SELECT 'Record has been deleted successfully'
			RETURN
        END
    END TRY
	BEGIN CATCH
		SELECT 'Error'
	END CATCH
END;

-------------------------------------------------------------------------
                            -- Applicnat--
create  proc AllApplicants 
	with encryption
	as
		select a.* , p.Fname,p.Lname,p.Gender,p.Graduation_Year,
				p.City,p.Age,p.Email ,pp.Phone 
		from Applicant a ,person p ,Person_Phone pp
		where a.App_SSN=p.SSN  and a.App_SSN=pp.SSN
Go		
create  proc GetApplicants @ssn bigint
	with encryption
	as
		select a.* , p.Fname,p.Lname,p.Gender,p.Graduation_Year,
				p.City,p.Age,p.Email,pp.Phone
		from  Applicant a, Person p,Person_Phone pp
		where  App_SSN=@ssn and App_SSN =p.SSN and a.App_SSN=pp.SSN    
--GetApplicants 26708118276305
GO
                                -- Instructor--
create  proc AllInstructors 
	with encryption
	as
		select ins.* , p.Fname,p.Lname,p.Gender,p.Graduation_Year,
				p.City,p.Age,p.Email,pp.Phone 
		from Instructor ins ,person p ,Person_Phone pp
		where ins.Ins_SSN=p.SSN and ins.Ins_SSN=pp.SSN
Go		
create  proc GetInstructor @ssn bigint
	with encryption
	as
		select ins.* , p.Fname,p.Lname,p.Gender,p.Graduation_Year,
				p.City,p.Age,p.Email,pp.Phone 
		from Instructor ins ,person p ,Person_Phone pp 
		where Ins_SSN =@ssn and ins.Ins_SSN=p.SSN and ins.Ins_SSN=pp.SSN
--GetInstructor 27241473848447
GO
                            -- instructor  Course--
create  proc AllInstructorCourses 
	with encryption
	as
		select  ins.Ins_SSN,p.Fname+' '+p.Lname as Instructorname,c.Course_Name 
		from Instructor Ins, Course C ,person p,Instructor_Course insc
		where ins.Ins_SSN=p.SSN and ins.Ins_SSN=insc.Ins_SSN 
		and c.Crs_ID=insc.Crs_ID
--AllInstructorCourses 
Go

create  proc Getcourseinstractors @crsid int -- by crs id
	with encryption
	as
		select Distinct  p.Fname+' '+p.Lname as Instructorname,c.Course_Name 
		from Instructor Ins, Course C ,person p,Instructor_Course insc
		where ins.Ins_SSN=p.SSN and ins.Ins_SSN=insc.Ins_SSN 
		and c.Crs_ID=@crsid
--Getcourseinstractors  18
GO
create  proc GetInstructorCoursesbyinsid @insid bigint -- by ins id
	with encryption
	as
		select Distinct p.Fname+' '+p.Lname as Instructorname, c.Course_Name 
		from Instructor Ins, Course C ,person p,Instructor_Course insc
		where ins.Ins_SSN=p.SSN and ins.Ins_SSN=@insid 
		and c.Crs_ID=insc.Crs_ID
--GetInstructorCoursesbyinsid  27241473848447
GO
                              -- Question Choices--
							  
create  proc GetQuestionChoices @qid int
	with encryption
	as
		select q.Question,q.Type,qc.Choice  from Questions q,Question_Choices qc
		where q.Q_ID=qc.Q_ID and q.Q_ID=@qid
--GetQuestionChoices 2
GO
                           -- Student Answer--		
create  proc GetStudentAnswers @st_ssn bigint
	with encryption
	as
		select p.Fname+' '+p.Lname [Student Name] ,sa.Answer,sa.Std_Grade
		from Student_Answer sa,Student s,Applicant ap,Person p
		where s.Std_SSN=ap.App_SSN and ap.App_SSN=p.SSN and s.Std_SSN=@st_ssn
--GetStudentAnswers 26719824015907
GO
-------------------------------------Insert SP----------------------------------------
                                   --Applicant--
create  proc InsertApplicants  @ssn bigint,@uni varchar(100),
@faculty varchar(100),@gpa decimal(3,2) ,@score decimal 
	with encryption
	as
		Begin Try
			if exists(select ssn from person)
			insert into Applicant
			values(@ssn,@uni,@faculty,@gpa,@score)
		end try
		begin catch
			select 'Duplicate id'
        end catch
--InsertApplicants  26703709283082,'Benha University','Computer Science',3.77,99
GO
                                -- Instructor--
create  proc InsertInstructors  @ssn bigint,@hiringdate date,@salary money ,@degree varchar(10) 
	with encryption
	as
		Begin Try
			if exists(select ssn from person)
			insert into Instructor
			values(@ssn,@hiringdate,@salary,@degree)
		end try
		begin catch
			select 'Duplicate id'
        end catch
GO
								-- InstructorCourse--
create  proc InsertInstructor_Courses  @ssn bigint,@cid int
	with encryption
	as
		Begin Try
			if exists(select ins.Ins_SSN,c.Crs_ID from Instructor ins,course c)
			insert into Instructor_Course
			values(@ssn,@cid)
		end try
		begin catch
			select 'Duplicate id'
        end catch
GO
                              --Question Choice--
create  proc InsertIQuestion_Choices  @Qid int,@choice varchar(255)
	with encryption
	as
		Begin Try
			if exists(select Q_ID from Questions)
			insert into Question_Choices
			values(@Qid,@choice)
		end try
		begin catch
			select 'Duplicate id'
        end catch
GO
                       --Student Answer--
create  proc InsertStudentAnswers  @std_ssn bigint,@eid int,@qid int,@answer nvarchar(100)
,@grade Decimal(5,2)
	with encryption
	as
		Begin Try
			if exists(select Q_ID,s.Std_SSN,e.Ex_ID from Questions ,student s,exam e)
			insert into Student_Answer
			values(@std_ssn,@eid,@qid,@answer,@grade)
		end try
		begin catch
			select 'Duplicate id'
        end catch
GO
-------------------------------------Update SP----------------------------------------
                                   --Applicant--
create  proc UpdateApplicants_SSN  @oldssn bigint,@newssn bigint
	with encryption
	as
		Begin Try
			update Applicant
			set App_SSN=@newssn
			where App_SSN=@oldssn
		end try
		begin catch
			select 'Wrong input'
        end catch
GO
create  proc UpdateApplicants_Name  @ssn bigint,@fname varchar(100),@lname varchar(100)
	with encryption
	as
		Begin Try
			update Person
			set Fname=@fname,Lname=@lname
			from Applicant a, Person p
			where a.App_SSN=p.SSN and a.App_SSN=@ssn
			
		end try
		begin catch
			select 'Wrong Input'
        end catch
GO
--UpdateApplicants_Name 28078250974920,'Alia','Hassan'
create proc UpdateApplicants_Education  @ssn bigint,@uni varchar(200),@faculty varchar(200) 
	with encryption
	as
		Begin Try
			update Applicant
			set University=@uni,Faculty=@faculty
			where App_SSN=@ssn
			
		end try
		begin catch
			select 'Wrong Input'
        end catch
GO
--UpdateApplicants_Eduaction 28078250974920,'Benha University','Computer Science'
                               --instructor--
create  proc UpdateInstructor_SSN  @oldssn bigint,@newssn bigint
	with encryption
	as
		Begin Try
			update Instructor
			set Ins_SSN=@newssn
			where Ins_SSN=@oldssn
		end try
		begin catch
			select 'Wrong input'
        end catch
GO
create  proc UpdateInstructors_Name  @ssn bigint,@fname varchar(100),@lname varchar(100)
	with encryption
	as
		Begin Try
			update Person
			set Fname=@fname,Lname=@lname
			from Instructor ins, Person p
			where Ins_SSN=p.SSN and Ins_SSN=@ssn
			
		end try
		begin catch
			select 'Wrong Input'
        end catch
GO
create  proc UpdateInstructors_Address  @ssn bigint,@city varchar(100),@street varchar(400)
	with encryption
	as
		Begin Try
			update Person
			set City=@city,Street=@street
			from Instructor ins, Person p
			where Ins_SSN=p.SSN and Ins_SSN=@ssn
			
		end try
		begin catch
			select 'Wrong Input'
        end catch
GO
create proc UpdateInstructor_Degree  @ssn bigint,@deg varchar(20)
	with encryption
	as
		Begin Try
			update Instructor
			set Degree=@deg
			where Ins_SSN=@ssn
			
		end try
		begin catch
			select 'Wrong Input'
        end catch
GO
                             -- instructor Course--
create  proc UpdateInstructorCourse  @ssn bigint,@newcid int ,@oldcid int 
	with encryption
	as
		Begin Try
			update Instructor_Course
			set Crs_ID=@newcid
			where  Crs_ID=@oldcid and Ins_SSN=@ssn 
		end try
		begin catch
			select 'Wrong input'
        end catch
GO
--UpdateInstructorCourse 27241473848447,3,1
                           -- Question Choice--
create  proc UpdateQuestionsChoices  @qid int,@newchoice varchar(200) , @oldchoice varchar(200)
	with encryption
	as
		Begin Try
			update Question_Choices
			set Choice=@newchoice
			where  Choice=@oldchoice and Q_ID=@qid
		end try
		begin catch
			select 'Wrong input'
        end catch
GO
                           -- Student Answer --
create  proc UpdateStudentAnswer  @qid int,@newanswer varchar(200) , @oldanswer varchar(200)
, @ssn bigint,@eid int
	with encryption
	as
		Begin Try
			update Student_Answer
			set Answer=@newanswer
			where  Answer=@oldanswer and Q_ID=@qid and Ex_ID=@eid and Std_SSN=@ssn
		end try
		begin catch
			select 'Wrong input'
        end catch
GO
----------------------------------------Delete Sps----------------------------------------------------
                                      --Applicant--    
create  proc DeleteApplicant  @ssn bigint
	with encryption
	as
		
		    if not exists (select s.Std_SSN,r.R_SSN,g.G_SSN 
			from student s,Rejected r ,Graduate g)
			delete  from Applicant
			where App_SSN=@ssn
			else
				select 'has realtionship'
GO        
--DeleteApplicant 26703050045531
                                  --Instructor--    
create proc DeleteInstructor  @ssn bigint
	with encryption
	as
		
			if not exists (select Ins_SSN from Instructor_Course )
			   delete  from Instructor
			   where Ins_SSN=@ssn
            else	
				select 'has realtionship'
        
GO
--DeleteInstructor 26771453883139

                                  --Instructor Course--    
create  proc DeleteInstructorCourse  @ssn bigint
	with encryption
	as
	    Begin Try
			delete  from Instructor_Course
			where Ins_SSN=@ssn
		end try
		begin catch
			select 'has realtionship'
        end catch
GO                                  --Question Choice--    
create  proc DeleteQuestionChoice  @qid int
	with encryption
	as
	    Begin Try
			delete  from Question_Choices
			where Q_ID=@qid
		end try
		begin catch
			select 'has realtionship'
        end catch
GO
                                  --Student Answer--    
create  proc DeleteStudentAnswer  @qid int,@eid int,@ssn bigint
	with encryption
	as
	    Begin Try
			delete  from Student_Answer
			where Q_ID=@qid  and Ex_ID=@eid and Std_SSN=@ssn
		end try
		begin catch
			select 'has realtionship'
        end catch
GO
;
---------------------------------------------------------------------------------------------------------
--Track Procedures
--Select
CREATE PROCEDURE GetTrack
    @Trc_id INT = NULL,
    @Trc_name NVARCHAR(50) = NULL
AS
BEGIN
    SELECT *
    FROM Track
    WHERE (
              Trc_ID = @Trc_id
              OR @Trc_id IS NULL
          )
          AND (
                  Trc_name = @Trc_name
                  OR @Trc_name IS NULL
              );
END;
 


--Insert
CREATE PROCEDURE InsertTrack
    @Trc_Name NVARCHAR(50),
    @Sup_hire_date Date,
    @Sup_SSN BIGINT,
    @Dep_id INT
AS
BEGIN TRY
    IF NOT EXISTS (SELECT Trc_Name FROM Track WHERE Trc_Name = @Trc_Name)
        INSERT INTO Track
        (
            Trc_Name,
            Sup_hire_date,
            Sup_SSN,
            Dep_id
        )
        VALUES
        (@Trc_Name, @Sup_hire_date, @Sup_SSN, @Dep_id);
    ELSE
        SELECT 'Duplicate Name'
END TRY
BEGIN CATCH
    Select 'Wrong Input'
END CATCH;


 
--Update
CREATE PROCEDURE UpdateTrack
    @Trc_ID INT,
    @Trc_Name NVARCHAR(50),
    @Sup_hire_date Date,
    @Sup_SSN bigint,
    @Dep_id INT
AS
BEGIN TRY
    IF NOT EXISTS (SELECT Trc_Name FROM Track WHERE Trc_Name = @Trc_Name)
        UPDATE Track
        SET Trc_Name = @Trc_Name,
            Sup_hire_date = @Sup_hire_date,
            Sup_SSN = @Sup_SSN,
            Dep_id = @Dep_id
        WHERE Trc_ID = @Trc_ID;
    ELSE
        SELECT 'Duplicate Name'
END TRY
BEGIN CATCH
    Select 'Wrong Input'
END CATCH;

--Delete
CREATE PROCEDURE DeleteTrack @Trc_ID INT
AS
BEGIN TRY
    DELETE FROM Track
    WHERE Trc_ID = @Trc_ID;
END TRY
BEGIN CATCH
    Select 'Has Relation'
END CATCH;


--Branch Procedures
--Select
CREATE PROCEDURE GetBranch
    @Brn_id INT = NULL,
    @Brn_name NVARCHAR(50) = NULL
AS
BEGIN
    SELECT *
    FROM Branch
    WHERE (
              Brn_ID = @Brn_id
              OR @Brn_id IS NULL
          )
          AND (
                  Brn_Name = @Brn_name
                  OR @Brn_name IS NULL
              );
END;

--Insert
CREATE PROCEDURE InsertBranch
    @Brn_Name NVARCHAR(50),
    @Brn_loc NVARCHAR(50),
    @Mgr_hire_date DATE,
    @Mgr_SSN BIGINT
AS
BEGIN TRY
    IF NOT EXISTS (SELECT Brn_Name from Branch where Brn_Name = @Brn_Name)
        INSERT INTO Branch
        (
            Brn_Name,
            Brn_loc,
            Mgr_hire_date,
            Mgr_SSN
        )
        VALUES
        (@Brn_Name, @Brn_loc, @Mgr_hire_date, @Mgr_SSN);
    ELSE
        SELECT 'Duplicate Name'
END TRY
BEGIN CATCH
    Select 'Wrong Input'
END CATCH;


--Update
CREATE PROCEDURE UpdateBranch
    @Brn_ID INT,
    @Brn_Name NVARCHAR(50),
    @Brn_loc NVARCHAR(50),
    @Mgr_hire_date DATE,
    @Mgr_SSN BIGINT
AS
BEGIN TRY
    IF NOT EXISTS (SELECT Brn_Name from Branch where Brn_Name = @Brn_Name)
        UPDATE Branch
        SET Brn_Name = @Brn_Name,
            Brn_loc = @Brn_loc,
            Mgr_hire_date = @Mgr_hire_date,
            Mgr_SSN = @Mgr_SSN
        WHERE Brn_ID = @Brn_ID;
    ELSE
        SELECT 'Duplicate Name'
END TRY
BEGIN CATCH
    Select 'Wrong Input'
END CATCH;

--Delete
CREATE PROCEDURE DeleteBranch @Brn_ID INT
AS
BEGIN TRY
    DELETE FROM Branch
    WHERE Brn_ID = @Brn_ID;
END TRY
BEGIN CATCH
    Select 'Has Relation'
END CATCH;


--Intake Procedures
--Select
CREATE PROCEDURE GetIntake
    @Int_id INT = NULL,
    @Int_name NVARCHAR(50) = NULL
AS
BEGIN
    SELECT *
    FROM Intake
    WHERE (
              Int_ID = @Int_id
              OR @Int_id IS NULL
          )
          AND (
                  Int_Name = @Int_name
                  OR @Int_name IS NULL
              );
END;


--Insert
CREATE PROCEDURE InsertIntake @Int_Name NVARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT Int_Name from Intake where Int_Name = @Int_Name)
        INSERT INTO Intake
        (
            Int_Name
        )
        VALUES (@Int_Name);
    ELSE
        SELECT 'Duplicate Name'
END;


--Update
CREATE PROCEDURE UpdateIntake
    @Int_ID INT,
    @Int_Name NVARCHAR(50)
AS
BEGIN 
    IF NOT EXISTS (SELECT Int_Name from Intake where Int_Name = @Int_Name)
        UPDATE Intake
        SET Int_Name = @Int_Name
        WHERE Int_ID = @Int_ID;
    ELSE
        SELECT 'Duplicate Name'
END;

--Delete
CREATE PROCEDURE DeleteIntake @Int_ID INT
AS
BEGIN TRY
    DELETE FROM Intake
    WHERE Int_ID = @Int_ID;
END TRY
BEGIN CATCH
    Select 'Has Realtion'
END CATCH;

--Department Procedures
--Select
CREATE PROCEDURE GetDeapartment
    @Dep_id INT = NULL,
    @Dep_name NVARCHAR(50) = NULL
AS
BEGIN
    SELECT *
    FROM Department
    WHERE (
              Dep_ID = @Dep_id
              OR @Dep_id IS NULL
          )
          AND (
                  Dep_Name = @Dep_name
                  OR @Dep_name IS NULL
              );
END;


--Insert
CREATE PROCEDURE InsertDepartment @Dep_Name NVARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT @Dep_Name from Department where Dep_Name = @Dep_Name)
        INSERT INTO Department
        (
            Dep_Name
        )
        VALUES (@Dep_Name);
    ELSE
        SELECT 'Duplicate Name'
END;


--Update
CREATE PROCEDURE UpdateDepartment
    @Dep_ID INT,
    @Dep_Name NVARCHAR(50)
AS
BEGIN 
    IF NOT EXISTS (SELECT Dep_Name from Department where Dep_Name = @Dep_Name)
        UPDATE Department
        SET Dep_Name = @Dep_Name
        WHERE Dep_ID = @Dep_ID;
    ELSE
        SELECT 'Duplicate Name'
END;

--Delete
CREATE PROCEDURE DeleteDepartment @Dep_ID INT
AS
BEGIN TRY
    DELETE FROM Department
    WHERE Dep_ID = @Dep_ID;
END TRY
BEGIN CATCH
    Select 'Has Relation'
END CATCH;

--Enrolment Procedures
--Select
CREATE PROCEDURE GetEnrolment @STD_SSN INT
AS
BEGIN
    SELECT *
    FROM Enrolment
    WHERE STD_SSN = @STD_SSN;
END;


--Insert
CREATE PROCEDURE InsertEnrolment
    @Std_SSN BIGINT,
    @Enrol_Date Date,
    @Int_ID INT,
    @Trc_ID INT,
    @Brn_ID INT
AS
BEGIN TRY
    IF NOT EXISTS (SELECT Std_SSN FROM Enrolment WHERE Std_SSN = @Std_SSN)
        INSERT INTO Enrolment
        (
            Std_SSN,
            Enrol_Date,
            Int_ID,
            Trc_ID,
            Brn_ID
        )
        VALUES
        (@Std_SSN, @Enrol_Date, @Int_ID, @Trc_ID, @Brn_ID);
    ELSE
        SELECT 'Duplicate SSN'
END TRY
BEGIN CATCH
    Select 'Wrong Input'
END CATCH;


 
--Update
CREATE PROCEDURE UpdateEnrolment
    @Std_SSN BIGINT,
    @Enrol_Date Date,
    @Int_ID INT,
    @Trc_ID INT,
    @Brn_ID INT
AS
BEGIN TRY
    IF NOT EXISTS (SELECT Std_SSN FROM Enrolment WHERE Std_SSN = @Std_SSN)
        UPDATE Enrolment
        SET Std_SSN = @Std_SSN,
            Enrol_Date = @Enrol_Date,
            Int_ID = @Int_ID,
            Trc_ID = @Trc_ID,
			Brn_ID = @Brn_ID
        WHERE Std_SSN = @Std_SSN;
    ELSE
        SELECT 'Duplicate SSN'
END TRY
BEGIN CATCH
    Select 'Wrong Input'
END CATCH;

--Delete
CREATE PROCEDURE DeleteEnrolment @Std_SSN BIGINT
AS
BEGIN TRY
    DELETE FROM Enrolment
    WHERE Std_SSN = @Std_SSN;
END TRY
BEGIN CATCH
    Select 'Has Relation'
END CATCH;
--------------------------------------------------------------------------------------------
----------------------------Exam---------------------------------
------SELECT------
CREATE PROC get_exam @ex_id INT
AS
	IF EXISTS (SELECT 1 FROM Exam
	WHERE Ex_ID = @ex_id)
	BEGIN
		SELECT * FROM Exam
		WHERE Ex_ID = @ex_id
	END
	ELSE
	BEGIN 
		SELECT 'Error, Exam ID not found.'
	END 

------INSERT------
CREATE PROC insert_exam 
@crs_id INT, 
@start_date_time DATETIME, 
@end_date_time DATETIME,
@no_question INT
AS
	BEGIN TRY
		IF EXISTS (SELECT 1 FROM Exam
		WHERE Crs_ID = @crs_id 
		AND Start_Date_Time = @start_date_time 
		AND No_Question = @no_question)
		BEGIN
			SELECT 'Exam already exists.'
		END
		Else
		BEGIN
			 INSERT INTO Exam
			(Crs_ID, Start_Date_Time,End_Date_Time ,No_Question) VALUES
			(@crs_id, @start_date_time, @start_date_time, @no_question)
			SELECT 'Exam inserted successfully.'
		END
		END TRY
		BEGIN CATCH
			SELECT 'Exam insert error.'
		END CATCH

------UPDATE------
CREATE PROC update_exam @ex_id INT,
@crs_id INT, 
@start_date_time DATETIME, 
@end_date_time DATETIME,
@no_question INT
AS
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Exam
		WHERE Ex_ID = @ex_id)
		BEGIN
			SELECT 'Error, Exam ID not found.'
		END
		ELSE IF EXISTS (SELECT 1 FROM Exam
		WHERE Ex_ID = @ex_id)
		BEGIN 
			UPDATE Exam
			SET Crs_ID = @crs_id,
			Start_Date_Time = @start_date_time,
			End_Date_Time = @end_date_time,
			No_Question = @no_question
			WHERE Ex_ID = @ex_id
			SELECT 'Exam updated successfully.'
		END
	END TRY
	BEGIN CATCH
		SELECT 'Exam update error.'
	END CATCH

------DELETE------
CREATE PROC delete_exam @ex_id INT
AS 
	IF EXISTS (SELECT 1 FROM Exam
	WHERE Ex_ID = @ex_id)
	BEGIN
		DELETE FROM Exam
		WHERE Ex_ID = @ex_id
		SELECT 'Exam deleted successfully.'
	END
	ELSE
	BEGIN
		SELECT 'Error, Exam ID  not found'
	END

----------------------------Question---------------------------------
------SELECT------
CREATE PROC get_question @q_id INT
AS
	IF EXISTS (SELECT 1 FROM Questions
	WHERE Q_ID = @q_id)
	BEGIN
		SELECT * FROM Exam
		WHERE Ex_ID = @q_id
	END
	ELSE
	BEGIN 
		SELECT 'Error, Question ID not found.'
	END 

------INSERT------
CREATE PROC insert_question @question VARCHAR(MAX),
@type CHAR(3),
@correct_answer VARCHAR(255),
@point INT,
@crs_id INT
AS
	BEGIN TRY
		IF EXISTS (SELECT 1 FROM Questions
		WHERE Question = @question)
		BEGIN
			SELECT 'Question already exists.'
		END
		ELSE
		BEGIN
			INSERT INTO Questions
			(Question, [Type], Correct_Answer, Point, Crs_ID) VALUES
			(@question, @type, @correct_answer, @point, @crs_id)
			SELECT 'Question inserted successfully.'
		END
	END TRY
	BEGIN CATCH
		SELECT 'Question Insert error.'
	END CATCH

------UPDATE------
CREATE PROC update_question @q_id INT,
@question VARCHAR(MAX),
@type CHAR(3),
@correct_answer VARCHAR(255),
@point INT,
@crs_id INT
AS
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 from Questions
		Where Q_ID = @q_id)
		BEGIN
			SELECT 'Error, Question ID not found.'
		END
		ELSE IF EXISTS (SELECT 1 from Questions
		Where Q_ID = @q_id)
		BEGIN
			UPDATE Questions
			SET Question = @question,
			[Type] = @type,
			Correct_Answer = @correct_answer,
			Crs_ID = @crs_id
			WHERE Q_ID = @q_id
			SELECT 'Question updated successfully.'
		END
	END TRY
	BEGIN CATCH
		SELECT 'Question update error.'
	END CATCH

------DELETE------
CREATE PROC delete_question @q_id INT
AS
	IF EXISTS (SELECT 1 FROM Questions
	WHERE Q_ID = @q_id)
	BEGIN
		DELETE FROM Questions
		WHERE Q_ID = @q_id
		SELECT 'Question deleted successfully.'
	END
	ELSE
	BEGIN
		SELECT 'Error, Question ID not found.'
	END

----------------------------Track_Course---------------------------------
------SELECT------
CREATE PROC get_track_course @t_id INT, @c_id INT
AS
	IF EXISTS (SELECT 1 FROM Track_Course
		WHERE Trc_ID = @t_id
		AND Crs_ID = @c_id)
	BEGIN
		SELECT * FROM Track_Course
		WHERE Trc_ID = @t_id
		AND Crs_ID = @c_id
	END
	ELSE
	BEGIN
		SELECT 'Error, Track_Course ID not found.'
	END

------INSERT------
CREATE PROC insert_track_course @t_id INT, @c_id INT
AS
	BEGIN TRY
		IF EXISTS (SELECT 1 FROM Track_Course
		WHERE Trc_ID = @t_id
		AND Crs_ID = @c_id)
		BEGIN
			SELECT 'Track_Course already exists.'
		END
		ELSE
		BEGIN
			INSERT INTO Track_Course
			(Trc_ID, Crs_ID) VALUES
			(@t_id, @c_id)
			SELECT 'Track_Course inserted successfully.'
	END
	END TRY
	BEGIN CATCH
		SELECT 'Track_Course insert error.'
	END CATCH

------UPDATE-----
CREATE PROC update_track_course @old_t_id INT,
@old_c_id INT,
@new_t_id INT,
@new_c_id INT
AS
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Track_Course
		WHERE Trc_ID = @old_t_id
		AND Crs_ID = @old_c_id)
		BEGIN
			SELECT 'Error, Track_Course ID not found.'
		END
		ELSE IF EXISTS (SELECT 1 FROM Track_Course
		WHERE Trc_ID = @old_t_id
		AND Crs_ID = @old_c_id)
		BEGIN
			UPDATE Track_Course
			SET Trc_ID = @new_t_id,
			Crs_ID = @new_c_id
			WHERE Trc_ID = @old_t_id
			AND Crs_ID = @old_c_id
			SELECT 'Track_Course updated successfully.'
		END
	END TRY
	BEGIN CATCH
		SELECT 'Track_Course update error.'
	END CATCH


------DELETE------
CREATE PROC delet_track_course @t_id INT, @c_id INT
AS
	IF EXISTS (SELECT 1 FROM Track_Course
	WHERE Trc_ID = @t_id
	AND Crs_ID = @c_id) 
	BEGIN
		DELETE FROM Track_Course
		WHERE Trc_ID = @t_id
		AND Crs_ID = @c_id
		SELECT 'Track_Course deleted successflly.'
	END
	ELSE
	BEGIN
		SELECT 'Error, Track_Course ID not found.'
	END

----------------------------Student---------------------------------
------SELECT------
CREATE PROC get_student @s_ssn BIGINT
AS 
	IF EXISTS (SELECT 1 FROM Student
	WHERE Std_SSN = @s_ssn)
	BEGIN
		SELECT P.SSN AS Student_SSN,
		Fname AS First_Name,
		Lname AS Last_Name,
		City,
		Street,
		Gender,
		Birth_Date,
		Age,
		Email,
		Graduation_Year,
		Phone,
		Lead_SSN,
		Username,
		Password_Hash,
		Total_Grades
		FROM Person P
		JOIN Person_Phone PP
		ON P.SSN = PP.SSN
		JOIN Applicant A
		ON P.SSN = A.App_SSN
		JOIN Student S
		ON A.App_SSN = S.Std_SSN
		WHERE Std_SSN = @s_ssn
	END
	ELSE
		BEGIN
			SELECT 'Error, Student SSN not found.'
		END

------INSERT------
CREATE PROC insert_student @s_ssn BIGINT,
@lead_ssn BIGINT,
@username VARCHAR(30),
@password VARBINARY(32)
AS
	BEGIN TRY
		IF EXISTS (SELECT 1 FROM Student
		WHERE Std_SSN = @s_ssn)
		BEGIN
			SELECT 'Student already exists.'
		END
		ELSE IF EXISTS(SELECT 1 FROM Applicant
		WHERE App_SSN = @s_ssn)
		BEGIN
			DECLARE @salt VARBINARY(16)
			DECLARE @password_hash VARBINARY(32)
			SET @Salt = CONVERT(VARBINARY(16), NEWID())
			SET @password_hash = CONVERT(VARBINARY(32), HASHBYTES('SHA2_256', @password + @salt), 2)
			INSERT INTO Student
			(Std_SSN, Lead_SSN, Username, Salt, Password_Hash) VALUES
			(@s_ssn, @lead_ssn, @username, @salt, @password_hash)
			SELECT 'Student inserted successfully.'
		END
	END TRY
	BEGIN CATCH
		SELECT 'Student insert error.'
	END CATCH

------UPDATE------
CREATE PROC update_student @s_ssn BIGINT,
@lead_ssn BIGINT,
@username VARCHAR(30),
@password VARBINARY(32)
AS
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Student
		WHERE Std_SSN = @s_ssn)
		BEGIN
			SELECT 'Student SSN not found.'
		END
		ELSE IF EXISTS (SELECT 1 FROM Student
		WHERE Std_SSN = @s_ssn)
		BEGIN
			DECLARE @salt VARBINARY(16)
			DECLARE @password_hash VARBINARY(32)
			SET @Salt = CONVERT(VARBINARY(16), NEWID())
			SET @password_hash = CONVERT(VARBINARY(32), HASHBYTES('SHA2_256', @password + @salt), 2)
			UPDATE Student
			SET Lead_SSN = @lead_ssn,
			Username = @username,
			Password_Hash = @password_hash,
			Salt = @salt
			WHERE Std_SSN = @s_ssn
			SELECT 'Student updated successfully.'
		END
	END TRY
	BEGIN CATCH
		SELECT 'Student update error.'
	END CATCH



------DELETE------
CREATE PROC delete_student @s_ssn BIGINT
AS
	IF EXISTS (SELECT 1 FROM Student
	WHERE Std_SSN = @s_ssn)
	BEGIN
		DELETE FROM Student
		WHERE Std_SSN = @s_ssn
		SELECT 'Student deleted successfully.'
	END
	ELSE
	BEGIN
		SELECT 'Error, Student SSN not found.'
	END

----------------------------Rejected---------------------------------
------SELECT------
CREATE PROC get_recjected @r_ssn BIGINT
 AS
 	IF EXISTS (SELECT 1 FROM Rejected
	WHERE R_SSN = @r_ssn)
	BEGIN
		SELECT P.SSN AS Rejected_SSN,
		Fname AS First_Name,
		Lname AS Last_Name,
		City,
		Street,
		Gender,
		Birth_Date,
		Age,
		Email,
		Graduation_Year,
		Phone,
		Reason
		FROM Person P
		JOIN Person_Phone PP
		ON P.SSN = PP.SSN
		JOIN Applicant A
		ON P.SSN = A.App_SSN
		JOIN Rejected R
		ON A.App_SSN = R.R_SSN
		WHERE R_SSN = @r_ssn
	END
	ELSE
		BEGIN
			SELECT 'Error, Rejected SSN not found.'
		END

------INSERT------
CREATE PROC insert_rejected @r_ssn BIGINT,
@reason VARCHAR(10)
AS
	BEGIN TRY
		IF EXISTS (SELECT 1 FROM Rejected
		WHERE R_SSN = @r_ssn)
		BEGIN
			SELECT 'Rejected already exists.'
		END
		ELSE IF EXISTS (SELECT 1 FROM Applicant
		WHERE App_SSN = @r_ssn)
		BEGIN
		INSERT INTO Rejected
		(Reason) VALUES (@reason)
		SELECT 'Rejected  inserted successfully.'
		END
		END TRY
		BEGIN CATCH
			SELECT 'Rejected insert error.'
		END CATCH

------UPDATE------
CREATE PROC update_rejected @r_ssn BIGINT,
@reason VARCHAR(10)
AS
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Rejected
		WHERE R_SSN = @r_ssn)
		BEGIN
			SELECT 'Error, Rejected SSN not found.'
		END
		IF EXISTS (SELECT 1 FROM Rejected
		WHERE R_SSN = @r_ssn)
		BEGIN
			UPDATE Rejected
			SET Reason = @reason
			WHERE R_SSN = @r_ssn
			SELECT 'Rejected updated successfully.'
		END
	END TRY
	BEGIN CATCH
		SELECT 'Rejected update error.'
	END CATCH

------DELETE------
CREATE PROC delete_rejected @r_ssn BIGINT
AS
	IF EXISTS (SELECT 1 FROM Rejected
	Where R_SSN = @r_ssn)
	BEGIN
		DElETE FROM Rejected
		WHERE R_SSN = @r_ssn
		SELECT 'Rejected deleted successfully.'
	END
	ELSE
	BEGIN
		SELECT 'Error, Rejected SSN not found.'
	END

----------------------------Graduate---------------------------------
------SELECT------
CREATE PROC get_graduate @g_ssn BIGINT
AS
 	IF EXISTS (SELECT 1 FROM Graduate
	WHERE G_SSN = @g_ssn)
	BEGIN
		SELECT P.SSN AS Graduate_SSN,
		Fname AS First_Name,
		Lname AS Last_Name,
		City,
		Street,
		Gender,
		Birth_Date,
		Age,
		Email,
		Graduation_Year,
		Phone,
		Final_Grades,
		Graduation_Date
		FROM Person P
		JOIN Person_Phone PP
		ON P.SSN = PP.SSN
		JOIN Applicant A
		ON P.SSN = A.App_SSN
		JOIN Graduate G
		ON A.App_SSN = G.G_SSN
		WHERE  g.G_SSN= @g_ssn
	END
	ELSE
		BEGIN
			SELECT 'Error, Graduate SSN not found.'
		END

------INSERT------
CREATE PROC insert_graduate @g_ssn BIGINT,
@final_grades INT,
@grad_date DATE
AS
	BEGIN TRY
		IF EXISTS (SELECT 1 FROM Graduate
		WHERE G_SSN = @g_ssn)
		BEGIN
			SELECT 'Grduate SSN already exists.'
		END
		ELSE IF EXISTS (SELECT 1 FROM Applicant
		WHERE App_SSN = @g_ssn)
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION
				INSERT INTO Graduate
				(Final_Grades, Graduation_Date)
				VALUES (@final_grades, @grad_date)
				DELETE FROM Student
				WHERE Std_SSN = @g_ssn
				COMMIT TRANSACTION
				SELECT 'Graduate inserted successfully.'
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				SELECT 'Graduate insert error.'
			END CATCH
		END
	END TRY
	BEGIN CATCH
		SELECT 'Graduate insert error.'
	END CATCH

------UPDATE------
CREATE PROC update_graduate @g_ssn BIGINT,
@final_grades INT,
@grad_date DATE
AS
	BEGIN TRY 
		IF NOT EXISTS (SELECT 1 FROM Graduate
		WHERE G_SSN = @g_ssn)
		BEGIN
			SELECT 'Error, Graduate SSN not found.'
		END
		ELSE
		BEGIN
			UPDATE Graduate
			SET Final_Grades = @final_grades,
			Graduation_Date = @grad_date
			WHERE G_SSN = @g_ssn
			SELECT 'Graduate updated successfully.'
		END
		END TRY
		BEGIN CATCH
			SELECT 'Graduate update error.'
		END CATCH

------DELETE------
CREATE PROC delete_graduate @g_ssn BIGINT
AS
	IF EXISTS (SELECT 1 FROM Graduate
	WHERE G_SSN = @g_ssn)
	BEGIN
		DELETE FROM Graduate
		WHERE G_SSN = @g_ssn
		SELECT 'Graduate deleted successfully.'
	END
	ELSE
	BEGIN
		SELECT 'Error, Graduate SSN not found.'
	END
-------------------------------------------------------------------------------------------
----------------------
--Select  Company Proc With Name:
CREATE PROCEDURE GETCompanyName 
    @Company_Name VARCHAR(100)
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        -- Directly select the results
        IF EXISTS (SELECT 1 FROM dbo.Company WHERE Company_Name = @Company_Name)
        BEGIN
            SELECT [Com_ID], [Company_Name], [Location]
            FROM dbo.Company
            WHERE Company_Name = @Company_Name;
        END
        ELSE
        BEGIN
           
            SELECT 'The company name cannot be found.' AS Message;
        END
    END TRY
    BEGIN CATCH
        
        PRINT 'An error occurred while retrieving the company information.';

        
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;




-------------------
-- UPDATE Procuder

----------------------------------

CREATE PROCEDURE UpdateCompany
    @Com_ID INT,
    @Company_Name NVARCHAR(100),
    @Location NVARCHAR(100)
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        
        UPDATE [PowerBIGP].[dbo].[Company]
        SET [Company_Name] = @Company_Name, 
            [Location] = @Location
        WHERE [Com_ID] = @Com_ID;

        
        IF @@ROWCOUNT > 0
        BEGIN
           
            PRINT 'The table has been updated successfully.';
            SELECT [Com_ID], [Company_Name], [Location]
            FROM [PowerBIGP].[dbo].[Company]
            WHERE [Com_ID] = @Com_ID;
        END
        ELSE
        BEGIN
       
            PRINT 'No rows were updated. Please check the Com_ID.';
        END
    END TRY
    BEGIN CATCH
        
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

      
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        
        PRINT 'An error occurred during the update operation.';

        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;


-----------------------------------
--DELETE PROC

CREATE PROCEDURE DELETECompany
    @Com_ID INT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        -- Perform the delete operation
        DELETE FROM dbo.Company
        WHERE Com_ID = @Com_ID;

        -- Check if any rows were affected
        IF @@ROWCOUNT > 0
        BEGIN
            -- If rows were deleted, print a success message
            PRINT 'The record has been deleted successfully.';
        END
        ELSE
        BEGIN
            -- If no rows were deleted, print a message indicating no deletion occurred
            PRINT 'No rows were deleted. Please check the Com_ID.';
        END
    END TRY
    BEGIN CATCH
        -- Handle any errors that occurred during the delete operation
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        -- Capture error details
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Print a generic error message
        PRINT 'An error occurred during the delete operation.';

        -- Re-raise the original error with captured details
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;


-----------------------------
--Insert Procedure
CREATE PROCEDURE InsertCompany
    @Company_Name NVARCHAR(100),
    @Location NVARCHAR(100)
AS
BEGIN
    BEGIN TRY
        -- Insert the new record into the Company table
        INSERT INTO [PowerBIGP].[dbo].[Company] ([Company_Name], [Location])
        VALUES (@Company_Name, @Location);

        
        SELECT 
            SCOPE_IDENTITY() AS NewCom_ID,
            @Company_Name AS Company_Name,
            @Location AS Location;
    END TRY
    BEGIN CATCH
        
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        -- Capture error details
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

    
        PRINT 'An error occurred during the insert operation.';

        -- Re-raise the original error with captured details
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;




------------------------------------
---Freelance Procuder By Platform Name
 CREATE PROCEDURE GETFreeLanceName
    @Platform VARCHAR(50)
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        -- Check if there are any records with the given Platform
        IF EXISTS (SELECT 1 FROM dbo.Freelance WHERE Platform = @Platform)
        BEGIN
            -- If records exist, select and return the relevant data
            SELECT F_ID, Name, Platform, Income, [Date], G_SSN
            FROM dbo.Freelance
            WHERE Platform = @Platform;
        END
        ELSE
        BEGIN
            -- If no records found, return a custom message
            SELECT 'The Platform cannot be found.' AS Message;
        END
    END TRY
    BEGIN CATCH
        -- Handle any errors that occurred during the operation
        PRINT 'An error occurred while retrieving the freelance information.';

        -- Capture and re-raise the original error with detailed information
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
----------------------------------------------------------------------------
--Update Freelance
CREATE PROCEDURE UpdateFreelance
    @F_ID INT,
    @Freelance_name VARCHAR(100),
    @Platform VARCHAR(50),
    @Income MONEY,
    @Date DATE,
    @G_SSN BIGINT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
       
        UPDATE dbo.Freelance
        SET 
            Name = @Freelance_name,
            Platform = @Platform,
            Income = @Income,
            Date = @Date,
            G_SSN = @G_SSN
        WHERE F_ID = @F_ID;

      
        IF @@ROWCOUNT > 0
        BEGIN
           
            PRINT 'The table has been updated successfully.';
            SELECT F_ID, Name, Platform, Income, Date, G_SSN
            FROM dbo.Freelance
            WHERE F_ID = @F_ID;
        END
        ELSE
        BEGIN
            
            PRINT 'No rows were updated. Please check the F_ID.';
        END
    END TRY
    BEGIN CATCH
        
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        PRINT 'An error occurred during the update operation.';

        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

--------------------------------------------------------------
-----Freelance Delete Proc

CREATE PROCEDURE DELETEFreelance
    @F_ID INT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        
        DELETE FROM dbo.Freelance
        WHERE F_ID = @F_ID;

        
        IF @@ROWCOUNT > 0
        BEGIN
            
            PRINT 'The record has been deleted successfully.';
        END
        ELSE
        BEGIN
            
            PRINT 'No rows were deleted. Please check the F_ID.';
        END
    END TRY
    BEGIN CATCH
        
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

     
        PRINT 'An error occurred during the delete operation.';

        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
-----------------------------------------------------------------
--Insert Proc Freelance
CREATE PROCEDURE InsertFreelance
    @Name NVARCHAR(100),
    @Platform NVARCHAR(50),
    @Income MONEY,
    @Date DATE,
    @G_SSN BIGINT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
       
        INSERT INTO dbo.Freelance ([Name], [Platform], [Income], [Date], [G_SSN])
        VALUES (@Name, @Platform, @Income, @Date, @G_SSN);

        
        SELECT SCOPE_IDENTITY() AS NewF_ID,
		@Name AS Name,
		@Platform AS Platform,
		@Income AS Income,
		@Date AS Date ,
		@G_SSN AS G_SSN;

    END TRY
    BEGIN CATCH
       
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

      
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        
        PRINT 'An error occurred during the insert operation.';

       
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

--------------------------------------------------------------
--- Certificate Procuder
------------------------
-- Select Certifice Proc By Name:
-----------------------
CREATE PROCEDURE GetCertificateByName
    @Certificate_Name VARCHAR(100)
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        -- Check if any records match the provided Certificate_Name
        IF EXISTS (SELECT 1 FROM [PowerBIGP].[dbo].[Certificate] WHERE [Certificate_Name] = @Certificate_Name)
        BEGIN
            -- Select the top 1000 records that match the Certificate_Name
            SELECT TOP (1000) 
                [Verif_ID], 
                [Certificate_Name], 
                [Provider], 
                [Issue_Date], 
                [Expiry_Date], 
                [G_SSN]
            FROM [PowerBIGP].[dbo].[Certificate]
            WHERE [Certificate_Name] = @Certificate_Name;
        END
        ELSE
        BEGIN
            
            SELECT 'The Certificate name cannot be found.' AS Message;
        END
    END TRY
    BEGIN CATCH
        
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        
        PRINT 'An error occurred during the select operation.';

       
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

-------------------------------------------------------------
--Certificate UpdateProc
-----------
CREATE PROCEDURE UpdateCertificate
    @Verif_ID VARCHAR(100),
    @Certificate_Name VARCHAR(100),
    @Provider VARCHAR(100),
    @Issue_Date DATE,
    @Expiry_Date DATE,
    @G_SSN BIGINT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        -- Perform the update operation
        UPDATE [PowerBIGP].[dbo].[Certificate]
        SET [Certificate_Name] = @Certificate_Name, 
            [Provider] = @Provider, 
            [Issue_Date] = @Issue_Date, 
            [Expiry_Date] = @Expiry_Date,
            [G_SSN] = @G_SSN
        WHERE [Verif_ID] = @Verif_ID;

      
        IF @@ROWCOUNT > 0
        BEGIN
           
            PRINT 'The record has been updated successfully.';
            SELECT [Verif_ID], [Certificate_Name], [Provider], [Issue_Date], [Expiry_Date], [G_SSN]
            FROM [PowerBIGP].[dbo].[Certificate]
            WHERE [Verif_ID] = @Verif_ID;
        END
        ELSE
        BEGIN
            
            PRINT 'No rows were updated. Please check the Verif_ID.';
        END
    END TRY
    BEGIN CATCH
       
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

       
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        
        PRINT 'An error occurred during the update operation.';

        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

----------------------------------------------------
-- Certificate Delete proc
CREATE  PROCEDURE DeleteCertificate
    @Verif_ID VARCHAR(100)
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        -- Perform the delete operation
        DELETE FROM [PowerBIGP].[dbo].[Certificate]
        WHERE Verif_ID = @Verif_ID;

        -- Check if any rows were affected
        IF @@ROWCOUNT > 0
        BEGIN
            -- If rows were deleted, print a success message
            PRINT 'The certificate record has been deleted successfully.';
        END
        ELSE
        BEGIN
            -- If no rows were deleted, print a message indicating no deletion occurred
            PRINT 'No rows were deleted. Please check the Verif_ID.';
        END
    END TRY
    BEGIN CATCH
        
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

       
        PRINT 'An error occurred during the delete operation.';

        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
-----------------------------------------------------------------
-- Certificate  INSERT proc
CREATE PROCEDURE InsertCertificate
    @Verif_ID VARCHAR(100),
    @Certificate_Name VARCHAR(100),
    @Provider VARCHAR(100),
    @Issue_Date DATE,
    @Expiry_Date DATE,
    @G_SSN BIGINT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        -- Insert the new record into the Certificate table
        INSERT INTO [PowerBIGP].[dbo].[Certificate] 
        (
            Verif_ID, 
            Certificate_Name, 
            Provider, 
            Issue_Date, 
            Expiry_Date, 
            G_SSN
        )
        VALUES 
        (
            @Verif_ID, 
            @Certificate_Name, 
            @Provider, 
            @Issue_Date, 
            @Expiry_Date, 
            @G_SSN
        );

        PRINT 'The certificate record has been inserted successfully.';
    END TRY
    BEGIN CATCH
        
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        
        PRINT 'An error occurred during the insert operation.';

       
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;


--------------------------------------------------------------
---Courses Procuder Name  
-- Courses Select Proc by:
CREATE PROCEDURE GetCourseByName
    @Course_Name VARCHAR(100)
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        -- Check if the course name exists
        IF EXISTS (SELECT 1 FROM [PowerBIGP].[dbo].[Course] WHERE Course_Name = @Course_Name)
        BEGIN
            -- Select the course record(s) by name
            SELECT TOP (1000) [Crs_ID], [Course_Name]
            FROM [PowerBIGP].[dbo].[Course]
            WHERE Course_Name = @Course_Name;
        END
        ELSE
        BEGIN
            
            SELECT 'The course name cannot be found.' AS Message;
        END
    END TRY
    BEGIN CATCH
       
        PRINT 'An error occurred while retrieving the course information.';

      
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
-------------------------------------
---- Courses Update Proc:
CREATE PROCEDURE UpdateCourse
    @Crs_ID INT,
    @Course_Name VARCHAR(100)
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
       
        UPDATE [PowerBIGP].[dbo].[Course]
        SET [Course_Name] = @Course_Name
        WHERE [Crs_ID] = @Crs_ID;

      
        IF @@ROWCOUNT > 0
        BEGIN
            
            PRINT 'The course has been updated successfully.';
            SELECT [Crs_ID], [Course_Name]
            FROM [PowerBIGP].[dbo].[Course]
            WHERE [Crs_ID] = @Crs_ID;
        END
        ELSE
        BEGIN
           
            PRINT 'No rows were updated. Please check the Crs_ID.';
        END
    END TRY
    BEGIN CATCH
        
        PRINT 'An error occurred during the update operation.';

        -- Capture error details
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;



---------------------------------------------------------------
---- Courses Delete Proc :

CREATE PROCEDURE DeleteCourse
    @Crs_ID INT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        -- Perform the delete operation
        DELETE FROM [PowerBIGP].[dbo].[Course]
        WHERE [Crs_ID] = @Crs_ID;

        
        IF @@ROWCOUNT > 0
        BEGIN
           
            PRINT 'The course has been deleted successfully.';
        END
        ELSE
        BEGIN
           
            PRINT 'No rows were deleted. Please check the Crs_ID.';
        END
    END TRY
    BEGIN CATCH
        
        PRINT 'An error occurred during the delete operation.';

        
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
-----------------------------------------------------------
--- Courses Insert Proc:
CREATE PROCEDURE InsertCourse
    @Course_Name VARCHAR(100)
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        -- Insert the new record into the Course table
        INSERT INTO [PowerBIGP].[dbo].[Course] ([Course_Name])
        VALUES (@Course_Name);

        -- Retrieve the newly generated Crs_ID
        SELECT SCOPE_IDENTITY() AS NewCrs_ID,
		@course_Name AS Course_Name;
    END TRY
    BEGIN CATCH
        -- Handle any errors that occurred during the insert operation
        PRINT 'An error occurred during the insert operation.';

        -- Capture error details
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Re-raise the original error with captured details
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
--------------------------------------------------------------------------
---Topics Procuder
--Select Topic  Proc By name:

CREATE PROCEDURE GetTopicByName
    @Topic_Name VARCHAR(100)
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        -- Select records matching the specified Topic_Name
        SELECT TOP (1000) [TopicID], [Topic_Name], [Crs_ID]
        FROM [PowerBIGP].[dbo].[Topic]
        WHERE [Topic_Name] = @Topic_Name;
    END TRY
    BEGIN CATCH
        -- Handle any errors that occurred during the select operation
        PRINT 'An error occurred while retrieving the topic information.';

        -- Capture error details
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Re-raise the original error with captured details
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
---------------------------------------------------------------
--Update Topic  Proc
CREATE PROCEDURE UpdateTopic
    @TopicID INT,
    @Topic_Name VARCHAR(100),
    @Crs_ID INT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
       
        UPDATE [PowerBIGP].[dbo].[Topic]
        SET [Topic_Name] = @Topic_Name,
            [Crs_ID] = @Crs_ID
        WHERE [TopicID] = @TopicID;

        -- Check if any rows were affected
        IF @@ROWCOUNT > 0
        BEGIN
            -- If rows were updated, print a success message and return the updated record
            PRINT 'The topic has been updated successfully.';
            SELECT [TopicID], [Topic_Name], [Crs_ID]
            FROM [PowerBIGP].[dbo].[Topic]
            WHERE [TopicID] = @TopicID;
        END
        ELSE
        BEGIN
            -- If no rows were updated, print a message indicating no update occurred
            PRINT 'No rows were updated. Please check the TopicID.';
        END
    END TRY
    BEGIN CATCH
        -- Handle any errors that occurred during the update operation
        PRINT 'An error occurred during the update operation.';

        -- Capture error details
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Re-raise the original error with captured details
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

----------------------------------------------------------------
--Delete Topic  Proc:
CREATE PROCEDURE DeleteTopic
    @TopicID INT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        -- Perform the delete operation
        DELETE FROM [PowerBIGP].[dbo].[Topic]
        WHERE [TopicID] = @TopicID;

        -- Check if any rows were affected
        IF @@ROWCOUNT > 0
        BEGIN
            -- If rows were deleted, print a success message
            PRINT 'The topic has been deleted successfully.';
        END
        ELSE
        BEGIN
            -- If no rows were deleted, print a message indicating no deletion occurred
            PRINT 'No rows were deleted. Please check the TopicID.';
        END
    END TRY
    BEGIN CATCH
        -- Handle any errors that occurred during the delete operation
        PRINT 'An error occurred during the delete operation.';

        -- Capture error details
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Re-raise the original error with captured details
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

-------------------------------------------------------------
--Insert Topic  Proc:
Create PROCEDURE InsertTopic
    @Topic_Name VARCHAR(100),
    @Crs_ID INT
WITH ENCRYPTION
AS
BEGIN
    BEGIN TRY
        -- Insert the new record into the Topic table
        INSERT INTO [PowerBIGP].[dbo].[Topic] ([Topic_Name], [Crs_ID])
        VALUES (@Topic_Name, @Crs_ID);

        -- Retrieve the newly generated TopicID and the inserted values
        SELECT 
            SCOPE_IDENTITY() AS NewTopicID,
            @Topic_Name AS Topic_Name,
            @Crs_ID AS Crs_ID;
    END TRY
    BEGIN CATCH
        -- Handle any errors that occurred during the insert operation
        PRINT 'An error occurred during the insert operation.';

        -- Capture error details
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Re-raise the original error with captured details
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
--------------------------------------------------------------------------------------------------------------
