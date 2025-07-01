/*********************************************
 Autor: Landry Duailibe
 
 LIVE #072
 Hands On: Linked Server
**********************************************/
use master
go


/********************************
 Linked Server SQL Server 
*********************************/
EXEC master.dbo.sp_addlinkedserver @server = N'SRVSQL2019', @srvproduct=N'SQL Server'

EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'SRVSQL2019',@useself=N'True'


SELECT * FROM SRVSQL2019.CensoEscolar_DW.dbo.DimAno


SELECT Nacionalidade, count(*) 
FROM SRVSQL2019.CensoEscolar_DW.dbo.DimAluno
GROUP BY Nacionalidade
ORDER BY Nacionalidade

SELECT * FROM OPENQUERY(SRVSQL2019,
'SELECT Nacionalidade, count(*) 
FROM SRVSQL2019.CensoEscolar_DW.dbo.DimAluno
GROUP BY Nacionalidade
ORDER BY Nacionalidade')

SELECT Nacionalidade, count(*) 
FROM SRVSQL2019.CensoEscolar_DW.dbo.DimAluno
GROUP BY Nacionalidade
ORDER BY Nacionalidade

-- Tabela local com remota na mesma consulta
SELECT P.BusinessEntityID, COUNT(*) AS TotalPedidos
FROM AdventureWorks.Person.Person P
JOIN SRVSQL2019.AdventureWorks.Sales.SalesOrderHeader S
ON P.BusinessEntityID = S.SalesPersonID
GROUP BY P.BusinessEntityID
ORDER BY P.BusinessEntityID



/***********************************
 Problema com Tipo de Dado XML
************************************/
SELECT PersonType,Title, FirstName, LastName 
FROM SRVSQL2019.AdventureWorks.Person.Person

SELECT * FROM OPENQUERY(SRVSQL2019,'
SELECT PersonType,Title, FirstName, LastName,
CAST(AdditionalContactInfo AS XML) AdditionalContactInfo
FROM AdventureWorks.Person.Person')
/*
Msg 9514, Level 16, State 1, Line 48
Xml data type is not supported in distributed queries. Remote object 'OPENQUERY' has xml column(s).
*/

-- Para retornar a coluna XML
SELECT PersonType,Title, FirstName, LastName,
CAST(AdditionalContactInfo as XML) AdditionalContactInfo

FROM OPENQUERY(SRVSQL2019,'
SELECT PersonType,Title, FirstName, LastName,
CAST(AdditionalContactInfo as nvarchar(max)) AdditionalContactInfo
FROM AdventureWorks.Person.Person')

--WHERE CAST(AdditionalContactInfo as XML) is not null



/********************************
 Linked Server Access
 https://www.microsoft.com/en-us/download/details.aspx?id=54920
*********************************/
EXEC sp_addlinkedserver 
@server = 'ACCESS_LINK', 
@srvproduct = 'Access', 
@provider = 'Microsoft.ACE.OLEDB.12.0', 
@datasrc = 'C:\_LIVE\Municipios.mdb'

EXEC sp_addlinkedsrvlogin 
@rmtsrvname = 'ACCESS_LINK', 
@useself = 'false'


SELECT * FROM OPENQUERY(ACCESS_LINK, 'SELECT * FROM Municipios')
SELECT * FROM ACCESS_LINK...Municipios

/**********************************************************************
 Linked Server Excel
 - Excel 12.0 = formato .xlsx
 - HDR=YES significa que a primeira linha contém os nomes das colunas
***********************************************************************/

EXEC sp_addlinkedserver 
@server = 'EXCEL_LINK', 
@srvproduct = 'Excel', 
@provider = 'Microsoft.ACE.OLEDB.12.0', 
@datasrc = 'C:\_LIVE\Municipios.xlsx', 
@provstr = 'Excel 12.0;HDR=YES'


SELECT * FROM OPENQUERY(EXCEL_LINK, 'SELECT * FROM [Planilha1$]')
SELECT * FROM EXCEL_LINK...[Planilha1$]
