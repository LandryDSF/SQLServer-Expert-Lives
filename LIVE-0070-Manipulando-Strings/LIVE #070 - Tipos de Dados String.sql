/*********************************************
 Autor: Landry Duailibe
 
 Hands On: Tipos de Dados Strings
**********************************************/
use Aula 
go

DROP TABLE IF exists dbo.TesteTiposString
go
CREATE TABLE dbo.TesteTiposString (
TextoChar char(20),
TextoVarchar varchar(20),
TextoNChar nchar(20),
TextoNVarchar nvarchar(20),
TextoText text,
TextoNText ntext)
go

INSERT dbo.TesteTiposString
VALUES (
 'João    ',               -- CHAR
 'João    ',               -- VARCHAR
N'João    ',              -- NCHAR
N'João    ',              -- NVARCHAR
 'João    ',               -- TEXT
N'João    '               -- NTEXT
)
go

SELECT 
TextoChar, 
TextoVarchar, 
TextoNChar, 
TextoNVarchar,
TextoText, 
TextoNText
FROM TesteTiposString

-- Isso dá erro com TEXT e NTEXT
SELECT datalength(TextoChar) as [Char], datalength(TextoVarchar) as [Varchar],
datalength(TextoNChar) as [NChar], datalength(TextoNVarchar) as [NVarchar] ,
datalength(TextoText) as [Text], datalength(TextoNText) as [NText] 
FROM TesteTiposString


