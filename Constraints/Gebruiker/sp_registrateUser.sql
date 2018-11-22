CREATE OR ALTER PROCEDURE SP_registrateUser (
@employeId NUMERIC(4)
)
AS
BEGIN

	DECLARE @tranCount INT = @@TRANCOUNT

	BEGIN TRY

      	BEGIN TRANSACTION

      	SAVE TRANSACTION employeIsActive

	-- Logica hier

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

-- Test forbidden word
create or alter procedure test_SP_registrateUser.[test 1 Username contains forbidden word, the user registration should fail.]
as
begin

		exec tSQLt.FakeTable 'dbo', 'Gebruiker';
		exec tSQLt.FakeTable 'dbo', 'FilterWoorden'

		insert into dbo.FilterWoorden values ('Forbidden word')

		exec tSQLt.ExpectException 
		exec SP_registrateUser	@username = 'Forbidden word', 
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

		exec tSQLt.ExpectNoException 
		exec SP_registrateUser	@username = 'Forbidden word', 
								@firstname = 'Test_firstname', 
								@middlename = null,
								@surname = 'Test_surname',
								@birthdate = '10-10-1996',
								@residence = 'Test_residence',
								@password = 'Test_password',
								@email = 'Test_email'
end
go