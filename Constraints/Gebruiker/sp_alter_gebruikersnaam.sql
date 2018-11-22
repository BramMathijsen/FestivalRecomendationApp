CREATE PROC pr_alter_gebruikersnaam 
	@gebruikersnaam_oud VARCHAR(50), 
	@gebruikersnaam_nieuw VARCHAR(50)
AS
BEGIN
	BEGIN TRY
		UPDATE gebruikersnaam
		SET gebruikersnaam = @gebruikersnaam_nieuw
		WHERE gebruikersnaam = @gebruikersnaam_oud
	END TRY
	BEGIN CATCH
	THROW;
	END CATCH
END