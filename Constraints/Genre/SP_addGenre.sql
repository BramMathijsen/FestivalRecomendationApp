-- Add genre
-----------Stored procedure----------------
CREATE OR ALTER PROCEDURE SP_addGenre (
@genreName VARCHAR(50),
@parentGenreName VARCHAR(50) = NULL
)
AS
BEGIN

    DECLARE @tranCount INT = @@TRANCOUNT

    BEGIN TRY

          BEGIN TRANSACTION

          SAVE TRANSACTION addGenre


		-- See if record with genre name doesnt exists already
		IF EXISTS(SELECT 1 FROM GENRE WHERE genre_naam = @genreName)
			THROW 50000, 'Genre met deze genrenaam bestaat al', 1

		--See if parent genre record exists
		IF @parentGenreName IS NOT NULL
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM GENRE WHERE hoofd_genre = @parentGenreName)
				THROW 50000, 'ouder genre van toe te voegen genre bestaat niet', 1

			IF @genreName = @parentGenreName
				THROW 50000, 'Ouder genre mag niet hetzelfde zijn als toe te voegen genre', 1
		END

		-- Insert record into database
		INSERT INTO GENRE(genre_naam, hoofd_genre) VALUES (@genreName, @parentGenreName)

          COMMIT TRANSACTION

     END TRY

     BEGIN CATCH

           IF XACT_STATE() = -1 AND @tranCount = 0
              ROLLBACK TRANSACTION

           ELSE IF XACT_STATE() = 1
               BEGIN
                   ROLLBACK TRANSACTION addGenre

                   COMMIT TRANSACTION
               END    
             ;THROW
                                                  
     END CATCH
END

GO
-----------Test----------------------------
EXEC tSQLt.NewTestClass 'TEST_SP_addGenre';
go
CREATE OR ALTER PROCEDURE [TEST_SP_addGenre].[]
AS
BEGIN

	EXEC tSQLt.FakeTable 'dbo', 'genre'

	insert into genre(genre_naam, hoofd_genre)
	values ('rock', NULL),('prog rock', 'rock'), ('experimentele rock', 'rock'), ('psychedelische rock', 'experimentele rock')

	EXEC tSQLt.ExpectException 

	EXEC SP_addGenre @genreName = 'rock'

END
go

CREATE OR ALTER PROCEDURE [TEST_SP_addGenre].[]
AS
BEGIN

	EXEC tSQLt.FakeTable 'dbo', 'genre'

	insert into genre(genre_naam, hoofd_genre)
	values ('rock', NULL),('prog rock', 'rock'), ('experimentele rock', 'rock'), ('psychedelische rock', 'experimentele rock')

	EXEC tSQLt.ExpectException 

	EXEC SP_addGenre @genreName = 'rock', @parentGenreName = 'rock'

END
go

CREATE OR ALTER PROCEDURE [TEST_SP_addGenre].[]
AS
BEGIN

	EXEC tSQLt.FakeTable 'dbo', 'genre'

	insert into genre(genre_naam, hoofd_genre)
	values ('rock', NULL),('prog rock', 'rock'), ('experimentele rock', 'rock'), ('psychedelische rock', 'experimentele rock')

	EXEC tSQLt.ExpectException 

	EXEC SP_addGenre @genreName = 'techno', @parentGenreName = 'house'

END
go

CREATE OR ALTER PROCEDURE [TEST_SP_addGenre].[]
AS
BEGIN

	EXEC tSQLt.FakeTable 'dbo', 'genre'

	insert into genre(genre_naam, hoofd_genre)
	values ('rock', NULL),('prog rock', 'rock'), ('experimentele rock', 'rock'), ('psychedelische rock', 'experimentele rock')

	EXEC tSQLt.ExpectNoException 

	EXEC SP_addGenre @genreName = 'melodische rock', @parentGenreName = 'rock'

END
go

CREATE OR ALTER PROCEDURE [TEST_SP_addGenre].[]
AS
BEGIN

	EXEC tSQLt.FakeTable 'dbo', 'genre'

	insert into genre(genre_naam, hoofd_genre)
	values ('rock', NULL),('prog rock', 'rock'), ('experimentele rock', 'rock'), ('psychedelische rock', 'experimentele rock')

	EXEC tSQLt.ExpectNoException 

	EXEC SP_addGenre @genreName = 'techno', @parentGenreName = NULL

END
go