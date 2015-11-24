USE WildcardSearches;
GO

----------------------------------------------------------------------------------------
-- Basic Searches
----------------------------------------------------------------------------------------
--A) Return all rows when the name starts by B    
SELECT * FROM dbo.LIKETest WHERE Name LIKE 'B%';
--B) Return all rows when the phone starts by 917
SELECT * FROM dbo.LIKETest WHERE phone LIKE '917%';
--C) Return all rows when the name starts by any character between A and L
SELECT * FROM dbo.LIKETest WHERE Name LIKE '[A-D]%';
--D) Return all rows when the name starts by the characters C, D or W
SELECT * FROM dbo.LIKETest WHERE Name LIKE N'[CDW]%';
--E) Return all rows when the last_movie_release starts by 2015
SELECT * FROM dbo.LIKETest WHERE last_movie_release LIKE '2015%';

--F) Ends with ‘some string’
SELECT * FROM dbo.LIKETest WHERE Name LIKE '%Parker';

--G) Contains ‘some string’
SELECT * FROM dbo.LIKETest WHERE Name LIKE '%Richard%';

--H) Contains ‘exact word’
SELECT * FROM dbo.LIKETest WHERE Name LIKE '% Richard %';
SELECT * FROM dbo.LIKETest WHERE ' ' + Name + ' ' LIKE '%[^A-Za-z]Richard[^A-Za-z]%';

--I) The N character is ‘some character’
SELECT * FROM dbo.LIKETest WHERE Name LIKE REPLICATE('_', 3) + 'n%';
SELECT * FROM dbo.LIKETest WHERE Name LIKE '%n' + REPLICATE('_', 3);

--J) Only valid strings
SELECT *
FROM dbo.LIKETest
WHERE amount NOT LIKE '%[^-0-9.]%' --Only digits, decimal points and minus signs
AND amount NOT LIKE '%[.]%[.]%' --Only one decimal point allowed
AND amount NOT LIKE '_%[-]%'; --Minus sign should only appear at the beginning of the string
--Or invalid strings
SELECT *
FROM dbo.LIKETest
WHERE amount  LIKE '%[^-0-9.]%' --Only digits, decimal points and minus signs
OR amount  LIKE '%[.]%[.]%' --Only one decimal point allowed
OR amount  LIKE '_%[-]%'; --Minus sign should only appear at the beginning of the string

----------------------------------------------------------------------------------------
-- Common problems
----------------------------------------------------------------------------------------
--K) Not returning all the results
SELECT * FROM dbo.LIKETest WHERE comments LIKE '%';

--L) Need to include characters used as wildcards
SELECT * FROM dbo.LIKETest WHERE comments LIKE '%[0-9]~%%' ESCAPE '~';
SELECT * FROM dbo.LIKETest WHERE comments LIKE '%[0-9][%]%';

--M) Ignoring trailing (or leading) spaces
DECLARE @Name char(50) = 'Bruce';

SET @Name = RTRIM( @Name) + '%';

SELECT @Name;

SELECT * FROM dbo.LIKETest WHERE Name LIKE @Name;

--N) Thinking that because something complies with a rule, it won’t bring invalid values
SELECT *
FROM dbo.LIKETest
WHERE comments LIKE '%[A-Za-z0-9.+_]@[A-Za-z0-9.+_]%.[A-Za-z][A-Za-z]%';


GO

