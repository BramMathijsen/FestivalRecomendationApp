CREATE PROC sp_delete_artiest
	@artiest_naam	VARCHAR(50)
AS
	DECLARE @savepoint varchar(128) = CAST(OBJECT_NAME(@@PROCID) as varchar(125)) + CAST(@@NESTLEVEL AS varchar(3))
	DECLARE @startTrancount int = @@TRANCOUNT;
BEGIN
	BEGIN TRY
		DELETE Artiest
		WHERE artiest_naam = @artiest_naam

		DELETE Bezetting
		WHERE bezetting_id IN (SELECT bezetting_id FROM Bezetting_van_artiest WHERE @artiest_naam) 
	END TRY
	BEGIN CATCH
	THROW;
	END CATCH
END