-- fuse genre
-----------Stored procedure----------------
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
-----------Test----------------------------