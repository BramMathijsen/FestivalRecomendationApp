CREATE PROC sp_alter_gebruiker_gegevens
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
	SET @gebruikers_voornaam = gebruikers_voornaam,
		@gebruikers_tussenvoegsel = gebruikers_tussenvoegsel,
		@gebruikers_achternaam = gebruikers_achternaam,
		@geboortedatum = geboortedatum,
		@woonplaats = woonplaats,
		@wachtwoord = wachtwoord,
		@emailadres = emailadres
	WHERE gebruikersnaam = @gebruikersnaam

	END TRY
	BEGIN CATCH
	THROW;
	END CATCH
END

-- ===================================================================
-- Testcase
-- ===================================================================

--Alleen het email adres aanpassen

EXEC sp_alter_gebruiker_gegevens 'hiddeW', @emailadres = 'hdwoudsma@gmail.com'

--alle gegevens aanpassen

EXEC sp_alter_gebruiker_gegevens 'HiddeDubbelD', 'Hidde', NULL, 'Woudsma', 'Ede', 'wachtwoord', 'hdwoudsma@gmail.com'