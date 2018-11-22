CREATE PROC sp_alter_genre 
	@genre_naam_oud		VARCHAR(50), 
	@genre_naam_nieuw	VARCHAR(50)
AS
BEGIN
	BEGIN TRY
		UPDATE Genre
		SET genre_naam = @genre_naam_nieuw
		WHERE genre_naam = @genre_naam_oud
	END TRY
	BEGIN CATCH
	THROW;
	END CATCH
END


GO
CREATE PROC sp_alter_subgenre
	@genre_naam		VARCHAR(50),
	@hoofd_genre	VARCHAR(50)
AS
BEGIN
	BEGIN TRY
		UPDATE Genre
		SET hoofd_genre = @hoofd_genre
		WHERE genre_naam = @genre_naam
	END TRY
	BEGIN CATCH
	THROW;
	END CATCH
END
