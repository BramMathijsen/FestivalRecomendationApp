--Genre
-- add genre (adds a genre to the table to be used as record)
-- delete genre (deletes a genre and changes the genre used by artist to another existing one)
-- fuse genres (fuses two genres into one)
-- adjust genre (changes the name of a genre)

-- Add genre

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

-- Delete genre
-- user can only delete genres that have no child genres

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

-- fuse genre
-- GENRE 1 used as genre position
CREATE OR ALTER PROCEDURE SP_fuseGenre (
@genre_name1 VARCHAR(50),
@genre_name2 VARCHAR(50),
@genre_fusion_name VARCHAR(50)
)
AS
BEGIN

    DECLARE @tranCount INT = @@TRANCOUNT

    BEGIN TRY

          BEGIN TRANSACTION

          SAVE TRANSACTION fuseGenre

		  -- check if fusion genre doenst exist already
		  IF EXISTS(SELECT 1 FROM GENRE WHERE genre_naam = @genre_fusion_name)
			THROW 50000, 'fusion name already exists', 1

		  -- check if genre 1 exists
		  IF NOT EXISTS(SELECT 1 FROM GENRE WHERE genre_naam = @genre_name1)
			THROW 50000, 'genre 1 doesnt exist', 1
			
		  -- check if genre 2 exists
		  IF NOT EXISTS(SELECT 1 FROM GENRE WHERE genre_naam = @genre_name2)
			THROW 50000, 'genre 2 doesnt exist', 1	
		

		  -- insert new genre
		  DECLARE @newParentGenre VARCHAR(50)
		  SET @newParentGenre = (SELECT hoofd_genre FROM GENRE WHERE genre_naam = @genre_name1)
		  INSERT INTO GENRE VALUES (@genre_fusion_name, @newParentGenre)

		  -- change artist has genre
		  UPDATE Artiest_heeft_genre SET genre_naam = @genre_fusion_name WHERE genre_naam = @genre_name1 OR genre_naam = @genre_name2

		  -- change act has genre
		  UPDATE Act_heeft_genre SET genre_naam = @genre_fusion_name WHERE genre_naam = @genre_name1 OR genre_naam = @genre_name2

		  -- change user likes
		  UPDATE Gebruiker_vindt_genre_leuk SET genre_naam = @genre_fusion_name WHERE genre_naam = @genre_name1 OR genre_naam = @genre_name2

		  -- change genre dependency's
		  UPDATE GENRE set hoofd_genre = @genre_fusion_name WHERE hoofd_genre = @genre_name1 OR hoofd_genre = @genre_name2 

		  -- delete genres
		  DELETE FROM GENRE where genre_naam = @genre_name1 OR genre_naam = @genre_name2

          COMMIT TRANSACTION

     END TRY

     BEGIN CATCH

           IF XACT_STATE() = -1 AND @tranCount = 0
              ROLLBACK TRANSACTION

           ELSE IF XACT_STATE() = 1
               BEGIN
                   ROLLBACK TRANSACTION fuseGenre

                   COMMIT TRANSACTION
               END    
             ;THROW
                                                  
     END CATCH
END

GO

-- Adjust genre

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
			THROW 50000, 'genre does already exist', 1

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