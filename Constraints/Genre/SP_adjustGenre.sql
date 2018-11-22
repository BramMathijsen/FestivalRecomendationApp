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
-----------Test----------------------------