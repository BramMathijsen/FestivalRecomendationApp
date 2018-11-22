-- Delete genre
-----------Stored procedure----------------
CREATE OR ALTER PROCEDURE SP_delGenre (
@genre_name VARCHAR(50),
@change_contents_to VARCHAR(50)
)
AS
BEGIN

    DECLARE @tranCount INT = @@TRANCOUNT

    BEGIN TRY

          BEGIN TRANSACTION

          SAVE TRANSACTION delGenre

		  --check if the to be deleted genre has no childs
		  IF EXISTS(SELECT 1 FROM GENRE AS G1 WHERE genre_naam = @genre_name AND
												 EXISTS (SELECT 1 FROM GENRE AS G2 WHERE G2.hoofd_genre = G1.genre_naam))
				THROW 50000, 'Een genre die genres onder hem heeft kan niet verwijderd worden', 1								  
			
		
		  -- check if @change_genre_to is an existing genre
		  IF NOT EXISTS(SELECT 1 FROM GENRE WHERE genre_naam = @change_contents_to)
				THROW 50000, 'De genre kan niet veranderd worden omdat het alternatief niet bestaat', 1

		
		  -- Delete user likes
		  DELETE FROM Gebruiker_vindt_genre_leuk WHERE genre_naam = @genre_name
		  UPDATE Artiest_heeft_genre SET genre_naam = @change_contents_to WHERE genre_naam = @genre_name
		  UPDATE Act_heeft_genre SET genre_naam = @change_contents_to WHERE genre_naam = @genre_name
		  DELETE FROM Genre WHERE genre_naam = @genre_name

          COMMIT TRANSACTION

     END TRY

     BEGIN CATCH

           IF XACT_STATE() = -1 AND @tranCount = 0
              ROLLBACK TRANSACTION

           ELSE IF XACT_STATE() = 1
               BEGIN
                   ROLLBACK TRANSACTION delGenre

                   COMMIT TRANSACTION
               END    
             ;THROW
                                                  
     END CATCH
END

GO
-----------Test----------------------------
EXEC tSQLt.NewTestClass 'TEST_SP_delGenre';
go
CREATE OR ALTER PROCEDURE [TEST_SP_delGenre].[test deleting a genre that has child genres (failure)]
AS
BEGIN

	EXEC tSQLt.FakeTable 'dbo', 'genre'

	insert into genre(genre_naam, hoofd_genre)
	values ('rock', NULL),('prog rock', 'rock'), ('experimentele rock', 'rock'), ('psychedelische rock', 'experimentele rock'), ('house', NULL)

	EXEC tSQLt.ExpectException 

	EXEC SP_delGenre @genre_name = 'rock', @change_contents_to = 'house'

END
go

CREATE OR ALTER PROCEDURE [TEST_SP_delGenre].[test deleing a genre with a not existing genre as alternative (failure)]
AS
BEGIN

	EXEC tSQLt.FakeTable 'dbo', 'genre'
	EXEC tSQLt.FakeTable 'dbo', 'Artiest_heeft_genre'
	EXEC tSQLt.FakeTable 'dbo', 'Act_heeft_genre'
	EXEC tSQLt.FakeTable 'dbo', 'Gebruiker_vindt_genre_leuk'

	insert into genre(genre_naam, hoofd_genre)
	values ('rock', NULL),('prog rock', 'rock'), ('experimentele rock', 'rock'), ('psychedelische rock', 'experimentele rock'), ('house', NULL)

	insert into Artiest_heeft_genre(genre_naam) VALUES ('rock'),('rock'), ('experimentele rock'), ('house')
	insert into Act_heeft_genre(genre_naam) VALUES ('rock'),('rock'), ('experimentele rock'), ('house')
	insert into Gebruiker_vindt_genre_leuk(genre_naam) VALUES ('rock'),('rock'), ('experimentele rock'), ('house'),('rock'),('rock'),('rock'),('rock')

	EXEC tSQLt.ExpectException 

	EXEC SP_delGenre @genre_name = 'psychedelische rock', @change_contents_to = 'techno'

END
go

CREATE OR ALTER PROCEDURE [TEST_SP_delGenre].[test deleting a genre (succes)]
AS
BEGIN

	EXEC tSQLt.FakeTable 'dbo', 'genre'
	EXEC tSQLt.FakeTable 'dbo', 'Artiest_heeft_genre'
	EXEC tSQLt.FakeTable 'dbo', 'Act_heeft_genre'
	EXEC tSQLt.FakeTable 'dbo', 'Gebruiker_vindt_genre_leuk'

	insert into genre(genre_naam, hoofd_genre)
	values ('rock', NULL),('prog rock', 'rock'), ('experimentele rock', 'rock'), ('psychedelische rock', 'experimentele rock'), ('house', NULL)

	insert into Artiest_heeft_genre(genre_naam) VALUES ('rock'),('rock'), ('experimentele rock'), ('house')
	insert into Act_heeft_genre(genre_naam) VALUES ('rock'),('rock'), ('experimentele rock'), ('house')
	insert into Gebruiker_vindt_genre_leuk(genre_naam) VALUES ('rock'),('rock'), ('experimentele rock'), ('house'),('rock'),('rock'),('rock'),('rock')

	EXEC tSQLt.ExpectNoException 

	EXEC SP_delGenre @genre_name = 'psychedelische rock', @change_contents_to = 'experimentele rock'

END
go