/* 
	This stored procedure is used to registrate a user.
*/

CREATE OR ALTER PROCEDURE SP_registrateUser 
	@username GEBRUIKERSNAAM,	
	@residence PLAATSNAAM,
	@country LAND,
	@firstname VOORNAAM,
	@middlename TUSSENVOEGSEL = null,
	@surname ACHTERNAAM,
	@birthdate	DATUM,
	@password WACHTWOORD,
	@email EMAIL
AS
BEGIN
	DECLARE @tranCount INT = @@TRANCOUNT

	BEGIN TRY

      	BEGIN TRANSACTION

      	SAVE TRANSACTION employeIsActive

		-- Check if (user)name doesn't contains a word that isn't allowed.
		if exists ( select '' from Filter_Woorden where FILTER_WOORD = @username )
			begin
				THROW 50000, 'The username contains a forbidden word! Please change the username', 1
			end

		-- Insert user into table
		insert into gebruiker (gebruikersnaam, plaatsnaam, land, gebruikers_voornaam, gebruikers_tussenvoegsel, gebruikers_achternaam, geboortedatum, wachtwoord, emailadres)
			values (@username, @residence, @country, @firstname, @middlename, @surname, @birthdate, @password, @email)


		-- Logic here

      	COMMIT TRANSACTION

 	END TRY

 	BEGIN CATCH

       	IF XACT_STATE() = -1 AND @tranCount = 0
          	ROLLBACK TRANSACTION

       	ELSE IF XACT_STATE() = 1
           	BEGIN
               	ROLLBACK TRANSACTION employeIsActive

               	COMMIT TRANSACTION
           	END    
   		  ;THROW
   		                                  	 
 	END CATCH
END

GO

-- Tests ------------
EXEC tSQLt.NewTestClass 'TEST_SP_registrateUser';


-- Test forbidden word
create or alter procedure test_SP_registrateUser.[test 1 Username contains forbidden word, the user registration should fail.]
as
begin

		exec tSQLt.FakeTable 'dbo', 'Gebruiker';
		exec tSQLt.FakeTable 'dbo', 'Filter_Woorden'

		insert into dbo.Filter_Woorden values ('Forbidden')

		exec tSQLt.ExpectException 
			@ExpectedMessage = 'The username contains a forbidden word! Please change the username'
		exec SP_registrateUser	@username = 'Forbidden', 
								@country = 'Test_country',
								@firstname = 'Test_firstname', 
								@middlename = null,
								@surname = 'Test_surname',
								@birthdate = '10-10-1996',
								@residence = 'Test_residence',
								@password = 'Test_password',
								@email = 'Test_email'
end
go


-- Test succesful registration.
create or alter procedure test_SP_registrateUser.[test 2 User registrates without any problems, the registration should succeed]
as
begin

		exec tSQLt.FakeTable 'dbo', 'Gebruiker';

		if OBJECT_ID('[TEST_SP_registrateUser].[verwacht]','Table') IS NOT NULL
				drop table TEST_SP_registrateUser.expected 

		select top 0 * 
			into TEST_SP_registrateUser.expected 
			from dbo.Gebruiker;

		insert into TEST_SP_registrateUser.expected  (gebruikersnaam, plaatsnaam, land, gebruikers_voornaam, gebruikers_tussenvoegsel, gebruikers_achternaam, geboortedatum, wachtwoord, emailadres)
			values ('Test_user', 'Test_residence', 'Test_country', 'Test_firstname', null, 'Test_surname', '10-10-1996', 'Test_password', 'Test_email')

		exec SP_registrateUser	@username = 'Test_user', 
								@country = 'Test_country',
								@firstname = 'Test_firstname', 
								@middlename = null,
								@surname = 'Test_surname',
								@birthdate = '10-10-1996',
								@residence = 'Test_residence',
								@password = 'Test_password',
								@email = 'Test_email'

		exec [tSQLt].[AssertEqualsTable] 'TEST_SP_registrateUser.expected ', 'dbo.Gebruiker'
end
go