-- Adjust genre
-----------Stored procedure----------------
CREATE OR ALTER PROCEDURE SP_adjustGenre (
@old_genre_name VARCHAR(50),
@new_genre_name VARCHAR(50)
)
AS
BEGIN

    DECLARE @tranCount INT = @@TRANCOUNT

    BEGIN TRY

          BEGIN TRANSACTION

          SAVE TRANSACTION adjustGenre

		  -- check if new genre already exists
		  IF EXISTS(SELECT 1 FROM GENRE WHERE genre_naam = @new_genre_name)
			THROW 50000, 'genre already exists', 1

		 -- check if old genre already exists
		  IF NOT EXISTS(SELECT 1 FROM GENRE WHERE genre_naam = @old_genre_name)
			THROW 50000, 'genre doesnt exist', 1

		 -- update the genre name
		  UPDATE GENRE SET genre_naam = @new_genre_name WHERE genre_naam = @old_genre_name 		

          COMMIT TRANSACTION

     END TRY

     BEGIN CATCH

           IF XACT_STATE() = -1 AND @tranCount = 0
              ROLLBACK TRANSACTION

           ELSE IF XACT_STATE() = 1
               BEGIN
                   ROLLBACK TRANSACTION adjustGenre

                   COMMIT TRANSACTION
               END    
             ;THROW
                                                  
     END CATCH
END

GO
-----------Test----------------------------
EXEC tSQLt.NewTestClass 'TEST_SP_adjustGenre';
go
CREATE OR ALTER PROCEDURE [TEST_SP_adjustGenre].[test change existing genre to already existing genre (failure)]
AS
BEGIN

	EXEC tSQLt.FakeTable 'dbo', 'genre'

	insert into genre(genre_naam, hoofd_genre)
	values ('rock', NULL),('prog rock', 'rock'), ('experimentele rock', 'rock'), ('psychedelische rock', 'experimentele rock'), ('house', NULL)

	EXEC tSQLt.ExpectException 

	EXEC SP_adjustGenre @old_genre_name = 'rock', @new_genre_name = 'house'

END
go

CREATE OR ALTER PROCEDURE [TEST_SP_adjustGenre].[test change non existing genre (failure)]
AS
BEGIN

	EXEC tSQLt.FakeTable 'dbo', 'genre'

	insert into genre(genre_naam, hoofd_genre)
	values ('rock', NULL),('prog rock', 'rock'), ('experimentele rock', 'rock'), ('psychedelische rock', 'experimentele rock'), ('house', NULL)

	EXEC tSQLt.ExpectException 

	EXEC SP_adjustGenre @old_genre_name = 'techno', @new_genre_name = 'jazz'

END
go

CREATE OR ALTER PROCEDURE [TEST_SP_adjustGenre].[test change rock to jazz (succes)]
AS
BEGIN

	EXEC tSQLt.FakeTable 'dbo', 'genre'

	insert into genre(genre_naam, hoofd_genre)
	values ('rock', NULL),('prog rock', 'rock'), ('experimentele rock', 'rock'), ('psychedelische rock', 'experimentele rock'), ('house', NULL)

	EXEC tSQLt.ExpectNoException 

	EXEC SP_adjustGenre @old_genre_name = 'rock', @new_genre_name = 'jazz'

END
go