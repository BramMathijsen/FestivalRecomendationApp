EXEC tSQLt.NewTestClass 'SP_addGenre';
go
CREATE OR ALTER PROCEDURE [SP_addGenre].[]
AS
BEGIN

	EXEC tSQLt.FakeTable 'dbo', 'genre'

	insert into genre(genre_naam, hoofd_genre)
	values ('rock', NULL),('prog rock', 'rock'), ('experimentele rock', 'rock'), ('psychedelische rock', 'experimentele rock')

	EXEC tSQLt.ExpectException 

	EXEC SP_addGenre @genreName = 'rock'

END
go

CREATE OR ALTER PROCEDURE [SP_addGenre].[]
AS
BEGIN

	EXEC tSQLt.FakeTable 'dbo', 'genre'

	insert into genre(genre_naam, hoofd_genre)
	values ('rock', NULL),('prog rock', 'rock'), ('experimentele rock', 'rock'), ('psychedelische rock', 'experimentele rock')

	EXEC tSQLt.ExpectException 

	EXEC SP_addGenre @genreName = 'rock', @parentGenreName = 'rock'

END
go

CREATE OR ALTER PROCEDURE [SP_addGenre].[]
AS
BEGIN

	EXEC tSQLt.FakeTable 'dbo', 'genre'

	insert into genre(genre_naam, hoofd_genre)
	values ('rock', NULL),('prog rock', 'rock'), ('experimentele rock', 'rock'), ('psychedelische rock', 'experimentele rock')

	EXEC tSQLt.ExpectException 

	EXEC SP_addGenre @genreName = 'techno', @parentGenreName = 'house'

END
go

CREATE OR ALTER PROCEDURE [SP_addGenre].[]
AS
BEGIN

	EXEC tSQLt.FakeTable 'dbo', 'genre'

	insert into genre(genre_naam, hoofd_genre)
	values ('rock', NULL),('prog rock', 'rock'), ('experimentele rock', 'rock'), ('psychedelische rock', 'experimentele rock')

	EXEC tSQLt.ExpectNoException 

	EXEC SP_addGenre @genreName = 'melodische rock', @parentGenreName = 'rock'

END
go

CREATE OR ALTER PROCEDURE [SP_addGenre].[]
AS
BEGIN

	EXEC tSQLt.FakeTable 'dbo', 'genre'

	insert into genre(genre_naam, hoofd_genre)
	values ('rock', NULL),('prog rock', 'rock'), ('experimentele rock', 'rock'), ('psychedelische rock', 'experimentele rock')

	EXEC tSQLt.ExpectNoException 

	EXEC SP_addGenre @genreName = 'techno', @parentGenreName = NULL

END
go


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


EXEC tSQLt.NewTestClass 'SP_delGenre';
go
CREATE OR ALTER PROCEDURE [SP_delGenre].[]
AS
BEGIN

	EXEC tSQLt.FakeTable 'dbo', 'genre'

	insert into genre(genre_naam, hoofd_genre)
	values ('rock', NULL),('prog rock', 'rock'), ('experimentele rock', 'rock'), ('psychedelische rock', 'experimentele rock'), ('house', NULL)

	EXEC tSQLt.ExpectException 

	EXEC SP_delGenre @genreName = 'rock', @change_contents_to = 'house'

END
go

CREATE OR ALTER PROCEDURE [SP_delGenre].[]
AS
BEGIN

	EXEC tSQLt.FakeTable 'dbo', 'genre'
	EXEC tSQLt.FakeTable 'dbo', 'Artiest_heeft_genre'
	EXEC tSQLt.FakeTable 'dbo', 'Act_heeft_genre'
	EXEC tSQLt.FakeTable 'dbo', 'Gebruiker_vindt_genre_leuk'

	insert into genre(genre_naam, hoofd_genre)
	values ('rock', NULL),('prog rock', 'rock'), ('experimentele rock', 'rock'), ('psychedelische rock', 'experimentele rock'), ('house', NULL)

	insert into Artiest_heeft_genre(genre_naam) VALUES ('rock'),('rock'), ('experimentele rock'), ('house')
	insert into Act_heeft_genre(genre_naam) VALUES ('rock'),('rock'), ('experimentele rock'), ('house')
	insert into Gebruiker_vindt_genre_leuk(genre_naam) VALUES ('rock'),('rock'), ('experimentele rock'), ('house'),('rock'),('rock'),('rock'),('rock')

	EXEC tSQLt.ExpectException 

	EXEC SP_delGenre @genreName = 'psychedelische rock', @change_contents_to = 'techno'

END
go

CREATE OR ALTER PROCEDURE [SP_delGenre].[]
AS
BEGIN

	EXEC tSQLt.FakeTable 'dbo', 'genre'
	EXEC tSQLt.FakeTable 'dbo', 'Artiest_heeft_genre'
	EXEC tSQLt.FakeTable 'dbo', 'Act_heeft_genre'
	EXEC tSQLt.FakeTable 'dbo', 'Gebruiker_vindt_genre_leuk'

	insert into genre(genre_naam, hoofd_genre)
	values ('rock', NULL),('prog rock', 'rock'), ('experimentele rock', 'rock'), ('psychedelische rock', 'experimentele rock'), ('house', NULL)

	insert into Artiest_heeft_genre(genre_naam) VALUES ('rock'),('rock'), ('experimentele rock'), ('house')
	insert into Act_heeft_genre(genre_naam) VALUES ('rock'),('rock'), ('experimentele rock'), ('house')
	insert into Gebruiker_vindt_genre_leuk(genre_naam) VALUES ('rock'),('rock'), ('experimentele rock'), ('house'),('rock'),('rock'),('rock'),('rock')

	EXEC tSQLt.ExpectNoException 

	EXEC SP_delGenre @genreName = 'psychedelische rock', @change_contents_to = 'experimentele rock'

END
go

