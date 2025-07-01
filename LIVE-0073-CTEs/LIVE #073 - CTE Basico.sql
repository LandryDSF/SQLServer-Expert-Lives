/*********************************************
 Autor: Landry Duailibe
 
 LIVE #073
 Hands On: CTE (Common Table Expressions)
**********************************************/
use AdventureWorks
go

/*********************************************
 Exemplo 1
 Selecionar os produtos cujo preço de lista é 
 acima da média de todos os produtos.
**********************************************/
set statistics io on

/**********************
 CTE ver 1
***********************/
WITH PrecoMedio AS (
SELECT AVG(ListPrice) AS Media
FROM Production.Product)

SELECT p.[Name] as Produto, p.ListPrice as Preco, pm.Media
FROM Production.Product p
CROSS JOIN PrecoMedio pm
WHERE p.ListPrice > pm.Media
ORDER BY p.ListPrice DESC
-- Table 'Product'. Scan count 2, logical reads 30

/**********************
 CTE ver 2
***********************/
;WITH PrecoMedio AS (
SELECT AVG(ListPrice) AS Media
FROM Production.Product)

SELECT p.[Name] as Produto, p.ListPrice as Preco, (SELECT Media FROM PrecoMedio) as Media
FROM Production.Product p
WHERE p.ListPrice > (SELECT Media FROM PrecoMedio)
ORDER BY p.ListPrice DESC
-- Table 'Product'. Scan count 3, logical reads 45


/**********************
 SubQuery ver 1
***********************/
SELECT [Name] as Produto, ListPrice as Preco,
(SELECT AVG(ListPrice) FROM Production.Product) as Media
FROM Production.Product
WHERE ListPrice > (SELECT AVG(ListPrice) FROM Production.Product)
ORDER BY ListPrice DESC
-- Table 'Product'. Scan count 3, logical reads 45

/**********************
 SubQuery ver 2
***********************/
SELECT [Name] as Produto, ListPrice as Preco, pm.Media
FROM Production.Product p
CROSS JOIN (SELECT AVG(ListPrice) as Media FROM Production.Product) pm
WHERE ListPrice > pm.Media
ORDER BY ListPrice DESC
-- Table 'Product'. Scan count 2, logical reads 30


/*********************************************
 Exemplo 2
 Listar os 5 produtos mais vendidos, junto com 
 o nome da subcategoria e o total vendido 
 (em quantidade).
**********************************************/

-- CTE 1: Soma total vendida por produto
WITH CTE_VendasProduto AS (
SELECT ProductID, SUM(OrderQty) AS TotalVendido
FROM Sales.SalesOrderDetail GROUP BY ProductID),

-- CTE 2: Junta produtos com subcategoria e vendas
CTE_ProdutoComInfo AS (
SELECT p.Name AS NomeProduto, ps.Name AS Subcategoria, vp.TotalVendido
FROM Production.Product p
JOIN CTE_VendasProduto vp ON p.ProductID = vp.ProductID
LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID)

-- Resultado final: Top 5 produtos mais vendidos
SELECT TOP 5 *
FROM CTE_ProdutoComInfo
ORDER BY TotalVendido DESC


/******************************
 Uma Consulta com SubQueries
*******************************/
SELECT TOP 5 *
FROM (
SELECT p.Name AS NomeProduto, ps.Name AS Subcategoria, vp.TotalVendido
FROM Production.Product p
JOIN (
SELECT ProductID, SUM(OrderQty) AS TotalVendido
FROM Sales.SalesOrderDetail GROUP BY ProductID) AS vp ON p.ProductID = vp.ProductID
LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID) AS ProdutoComInfo
ORDER BY TotalVendido DESC


