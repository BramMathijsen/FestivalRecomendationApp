-- Add artist
-----------String split function-----------
CREATE FUNCTION dbo.SplitStrings_Moden
(
   @List NVARCHAR(MAX),
   @Delimiter NVARCHAR(255)
)
RETURNS TABLE
WITH SCHEMABINDING AS
RETURN
  WITH E1(N)        AS ( SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
       E2(N)        AS (SELECT 1 FROM E1 a, E1 b),
       E4(N)        AS (SELECT 1 FROM E2 a, E2 b),
       E42(N)       AS (SELECT 1 FROM E4 a, E2 b),
       cteTally(N)  AS (SELECT 0 UNION ALL SELECT TOP (DATALENGTH(ISNULL(@List,1))) 
                         ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E42),
       cteStart(N1) AS (SELECT t.N+1 FROM cteTally t
                         WHERE (SUBSTRING(@List,t.N,1) = @Delimiter OR t.N = 0))
  SELECT Item = SUBSTRING(@List, s.N1, ISNULL(NULLIF(CHARINDEX(@Delimiter,@List,s.N1),0)-s.N1,8000))
    FROM cteStart s;


go
-----------Stored procedure----------------
CREATE OR ALTER PROCEDURE SP_addArtist (
@artistName VARCHAR(50),
@artistGenresList VARCHAR(MAX),
@artistBezettingenList VARCHAR(MAX),
@Delimiter NVARCHAR(255)

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

		  -- add artist in artiest table
		  INSERT INTO Artiest VALUES (@artistName)

		  -- check of genre's kloppen
		  IF EXISTS (SELECT 1 FROM dbo.SplitStrings_Moden (@artistGenresList, @Delimiter) AS A WHERE NOT EXISTS (SELECT 1 FROM GENRE AS B WHERE A.item = B.Genre_naam))
				THROW 50000, 'Toegevoegde genres kloppen niet', 1

		-- insert genre's into genres van artiest
		INSERT INTO artiest_heeft_genre(artiest_naam, genre_naam)
		SELECT @artistName, item FROM dbo.SplitStrings_Moden (@artistGenresList, @Delimiter)


		  -- check of bezettingen kloppen
		  IF EXISTS (SELECT 1 FROM dbo.SplitStrings_Moden (@artistBezettingenList, @Delimiter) AS A  WHERE NOT EXISTS (SELECT 1 FROM Bezetting AS B WHERE A.item = B.bezetting_id))
				THROW 50000, 'Toegevoegde bezettingen kloppen niet', 1

		-- insert  into bezetting van artiest
		INSERT INTO bezetting_van_artiest(artiest_naam, bezetting_id)
		SELECT @artistName, item FROM dbo.SplitStrings_Moden (@artistBezettingenList, @Delimiter)
		 

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

