CREATE PROC sp_alter_artiest
	@artiest_naam_oud	VARCHAR(50),
	@artiest_naam_nieuw VARCHAR(50)
AS
BEGIN
	BEGIN TRY
		UPDATE Artiest
		SET artiest_naam = @artiest_naam_nieuw
		WHERE artiest_naam = @artiest_naam_oud
	END TRY
	BEGIN CATCH
	THROW;
	END CATCH
END


-- ===================================================================
-- Testcase
-- ===================================================================

EXEC so_alter_artiest 'dodemui5', 'Deadmau5'