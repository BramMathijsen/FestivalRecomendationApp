CREATE PROC pr_alter_gebruiker_gegevens
	@gebruikersnaam				varchar(50), 
	@gebruikers_voornaam		varchar(50)	NULL,
	@gebruikers_tussenvoegsel	varchar(10)	NULL, 
	@gebruikers_achternaam		varchar(50)	NULL, 
	@geboortedatum				date		NULL, 
	@woonplaats					varchar(50)	NULL, 
	@wachtwoord					varchar(50)	NULL, 
	@emailadres					varchar(50)	NULL
AS
BEGIN
	BEGIN TRY
	IF(@gebruikers_voornaam IS NULL) SELECT @gebruikers_voornaam = (SELECT gebruikers_voornaam FROM gebruiker WHERE gebruikersnaam = @gebruikersnaam)
	IF(@gebruikers_voornaam IS NULL) SELECT @gebruikers_tussenvoegsel = (SELECT gebruikers_tussenvoegsel FROM gebruiker WHERE gebruikersnaam = @gebruikersnaam)
	IF(@gebruikers_voornaam IS NULL) SELECT @gebruikers_achternaam = (SELECT gebruikers_achternaam FROM gebruiker WHERE gebruikersnaam = @gebruikersnaam)
	IF(@gebruikers_voornaam IS NULL) SELECT @geboortedatum = (SELECT geboortedatum FROM gebruiker WHERE gebruikersnaam = @gebruikersnaam)
	IF(@gebruikers_voornaam IS NULL) SELECT @woonplaats = (SELECT woonplaats FROM gebruiker WHERE gebruikersnaam = @gebruikersnaam)
	IF(@gebruikers_voornaam IS NULL) SELECT @wachtwoord = (SELECT wachtwoord FROM gebruiker WHERE gebruikersnaam = @gebruikersnaam)
	IF(@gebruikers_voornaam IS NULL) SELECT @emailadres = (SELECT emailadres FROM gebruiker WHERE gebruikersnaam = @gebruikersnaam)

	UPDATE gebruiker
	SET @gebruikers_voornaam = gebruikers_voornaam AND
		@gebruikers_tussenvoegsel = ebruikers_tussenvoegsel AND
		@gebruikers_achternaam = gebruikers_achternaam AND
		@geboortedatum = geboortedatum AND
		@woonplaats = woonplaats AND
		@wachtwoord = wachtwoor AND
		@emailadres = emailadres
	WHERE gebruikersnaam = @gebruikersnaam

	END TRY
	BEGIN CATCH
	THROW;
	END CATCH
END

GO
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