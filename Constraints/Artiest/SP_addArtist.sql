-- Add artist
-----------Stored procedure----------------
CREATE OR ALTER PROCEDURE SP_addArtist (
@artistName VARCHAR(50)
)
AS
BEGIN

    DECLARE @tranCount INT = @@TRANCOUNT

    BEGIN TRY

          BEGIN TRANSACTION

          SAVE TRANSACTION addArtist

		  -- check if artist with this name doesnt exist already
		  IF EXISTS (SELECT 1 FROM Artiest WHERE artiest_naam = @artistName)
				THROW 50000, 'Artiest bestaat al', 1

		  -- check if artist has at least 1 record in bezetting
		  IF (SELECT COUNT(*) FROM bezetting_van_artiest WHERE artiest_naam = @artistName GROUP BY artiest_naam) < 1
				THROW 50000, 'Artiest moet minstens 1 bezetting hebben', 1

		  -- check if artist has at least 1 record in genre van artiest
		  IF (SELECT COUNT(*) FROM Artiest_heeft_genre WHERE artiest_naam = @artistName GROUP BY artiest_naam) < 1
				THROW 50000, 'Artiest moet minstens 1 genre hebben', 1


		  INSERT INTO Artiest VALUES (@artistName)

          COMMIT TRANSACTION

     END TRY

     BEGIN CATCH

           IF XACT_STATE() = -1 AND @tranCount = 0
              ROLLBACK TRANSACTION

           ELSE IF XACT_STATE() = 1
               BEGIN
                   ROLLBACK TRANSACTION addArtist

                   COMMIT TRANSACTION
               END    
             ;THROW
                                                  
     END CATCH
END

GO