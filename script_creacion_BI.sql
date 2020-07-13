USE GD1C2020;

--=========================Creacion del schema por si no existe==================================================================================================

IF NOT EXISTS(SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'EQUIPO_RAYO')
BEGIN
		EXEC sp_executesql N'CREATE SCHEMA EQUIPO_RAYO'
END
GO


--=============Creacion de tablas, si ya existen no hace nada

--Dimension Clientes
IF OBJECT_ID('EQUIPO_RAYO.Dim_Clientes') IS NULL
	CREATE TABLE EQUIPO_RAYO.Dim_Clientes
	(
		cliente_id INT PRIMARY KEY,
		cliente_dni DECIMAL(18,0),
		cliente_nombre NVARCHAR(255),
		cliente_apellido NVARCHAR(255),
		cliente_fecha_nac DATETIME2(3),
		cliente_edad INT,
		cliente_mail NVARCHAR(255),
		cliente_telefono INT
	)
GO

--Dimension Rutas
IF OBJECT_ID('EQUIPO_RAYO.Dim_Rutas') IS NULL
	CREATE TABLE EQUIPO_RAYO.Dim_Rutas 
	(
		ruta_id INT PRIMARY KEY,
		ruta_origen NVARCHAR(255),
		ruta_destino NVARCHAR(255)
	)

--Dimension Ciudades (es el destino de un vuelo)
IF OBJECT_ID('EQUIPO_RAYO.Dim_Ciudades') IS NULL 
	CREATE TABLE EQUIPO_RAYO.Dim_Ciudades 
	(
		ciudad_id INT IDENTITY PRIMARY KEY,
		ciudad_nombre NVARCHAR(255)
	)

--Dimension Proveedores
IF OBJECT_ID('EQUIPO_RAYO.Dim_Proveedores') IS NULL
	CREATE TABLE EQUIPO_RAYO.Dim_Proveedores
	(
		proveedor_id INT PRIMARY KEY,
		proveedor_razon_social NVARCHAR(255)
	)

--Dimension Sucursales
IF OBJECT_ID('EQUIPO_RAYO.Dim_Sucursales') IS NULL
	CREATE TABLE EQUIPO_RAYO.Dim_Sucursales
	(
		sucursal_id INT PRIMARY KEY,
		sucursal_direccion NVARCHAR(255),
		sucursal_mail NVARCHAR(255),
		sucursal_telefono DECIMAL(18,0)
	)

--Dimension Aviones
IF OBJECT_ID('EQUIPO_RAYO.Dim_Aviones') IS NULL
	CREATE TABLE EQUIPO_RAYO.Dim_Aviones
	(
		avion_id INT PRIMARY KEY,
		avion_identificador NVARCHAR(50),
		avion_modelo NVARCHAR(50)
	)

--Dimension tipo de pasajes
IF OBJECT_ID('EQUIPO_RAYO.Dim_Tipo_Pasajes') IS NULL
	CREATE TABLE EQUIPO_RAYO.Dim_Tipo_Pasajes
	(
		tipo_pasaje_id INT IDENTITY PRIMARY KEY,
		tipo_pasaje_costo DECIMAL(18,2),
		tipo_pasaje_precio DECIMAL(18,2),
		tipo_pasaje_tipo NVARCHAR(255)
	)

--Dimension habitacion tipos
IF OBJECT_ID('EQUIPO_RAYO.Dim_Hab_Tipos') IS NULL
	CREATE TABLE EQUIPO_RAYO.Dim_Hab_Tipos
	(
		hab_tipo_id INT PRIMARY KEY,
		hab_tipo_hotel NVARCHAR(255),
		hab_tipo_direc NVARCHAR(255),
		hab_tipo_estrellas DECIMAL(18,0),
		hab_tipo_cant_camas INT,
		hab_tipo_costo DECIMAL(18,2),
		hab_tipo_precio DECIMAL(18,2)
	)

--Dimension Hechos Ventas Pasajes
IF OBJECT_ID('EQUIPO_RAYO.Hechos_Ventas_Pasajes') IS NULL
	CREATE TABLE EQUIPO_RAYO.Hechos_Ventas_Pasajes
	(
		anio CHAR(4),
		mes CHAR(2),
		cliente_id INT FOREIGN KEY (cliente_id) REFERENCES EQUIPO_RAYO.Dim_Clientes(cliente_id),
		proveedor_id INT FOREIGN KEY (proveedor_id) REFERENCES EQUIPO_RAYO.Dim_Proveedores(proveedor_id),
		sucursal_id INT FOREIGN KEY (sucursal_id) REFERENCES EQUIPO_RAYO.Dim_Sucursales(sucursal_id),
		avion_id INT FOREIGN KEY (avion_id) REFERENCES EQUIPO_RAYO.Dim_Aviones(avion_id),
		tipo_pasaje_id INT FOREIGN KEY (tipo_pasaje_id) REFERENCES EQUIPO_RAYO.Dim_Tipo_Pasajes(tipo_pasaje_id),
		ruta_id INT FOREIGN KEY (ruta_id) REFERENCES EQUIPO_RAYO.Dim_Rutas(ruta_id),
		ciudad_id INT FOREIGN KEY (ciudad_id) REFERENCES EQUIPO_RAYO.Dim_Ciudades(ciudad_id),
		prom_compra DECIMAL(18,2),
		prom_venta DECIMAL(18,2),
		ganacias_pasajes DECIMAL(18,2),
		CONSTRAINT PK_Hechos_Pasajes
		PRIMARY KEY(anio,mes,cliente_id,proveedor_id,sucursal_id,avion_id,tipo_pasaje_id,ruta_id,ciudad_id)
	)

--Dimension Hechos Ventas Estadias
IF OBJECT_ID('EQUIPO_RAYO.Hechos_Ventas_Estadias') IS NULL
	CREATE TABLE EQUIPO_RAYO.Hechos_Ventas_Estadias
	(
		anio CHAR(4),
		mes CHAR(2),
		cliente_id INT FOREIGN KEY (cliente_id) REFERENCES EQUIPO_RAYO.Dim_Clientes(cliente_id),
		proveedor_id INT FOREIGN KEY (proveedor_id) REFERENCES EQUIPO_RAYO.Dim_Proveedores(proveedor_id),
		sucursal_id INT FOREIGN KEY (sucursal_id) REFERENCES EQUIPO_RAYO.Dim_Sucursales(sucursal_id),
		hab_tipo_id INT FOREIGN KEY (hab_tipo_id) REFERENCES EQUIPO_RAYO.Dim_Hab_Tipos(hab_tipo_id),
		prom_compra DECIMAL(18,2),
		prom_venta DECIMAL(18,2),
		cant_camas INT,
		ganacias_estadias DECIMAL(18,2),
		CONSTRAINT PK_Hechos_Estadias
		PRIMARY KEY(anio,mes,cliente_id,proveedor_id,sucursal_id,hab_tipo_id)
	) 


---==Funciones

--Devuelve la cantidad de camas que tiene una habitacion segun su tipo
GO
CREATE FUNCTION cantCamas(@habitacion INT) RETURNS INT
AS
BEGIN
	DECLARE @cant INT
	DECLARE @tipo INT

	SET @tipo=(SELECT T.tipo_codigo FROM EQUIPO_RAYO.Habitaciones H
	           JOIN EQUIPO_RAYO.Tipos T ON T.tipo_id=H.tipo_id
	           WHERE habitacion_id=@habitacion)
	IF(@tipo=1005) SET @cant=1
	IF(@tipo=1002) SET @cant=2
	IF(@tipo=1001) SET @cant=1
	IF(@tipo=1003) SET @cant=3
	IF(@tipo=1004) SET @cant=4

	RETURN @cant

END
GO


--=========Migracion a BI


---Dimension Clientes
INSERT INTO EQUIPO_RAYO.Dim_Clientes(cliente_id,cliente_dni,cliente_nombre,cliente_apellido,cliente_fecha_nac,cliente_edad,cliente_mail,cliente_telefono)
SELECT cliente_id,
       cliente_dni,
	   cliente_nombre,
	   cliente_apellido,
	   cliente_fecha_nac,
	   (SELECT FLOOR(DATEDIFF(DAY, cliente_fecha_nac , GETDATE()) / 365.25)), --Me devuelve la edad del cliente
	   cliente_mail,
	   cliente_telefono 
FROM EQUIPO_RAYO.Clientes


--Dimension Proveedores
INSERT INTO EQUIPO_RAYO.Dim_Proveedores(proveedor_id,proveedor_razon_social)
SELECT empresa_id,empresa_razon_social FROM EQUIPO_RAYO.Empresas


---Dimension Sucursales
INSERT INTO EQUIPO_RAYO.Dim_Sucursales(sucursal_id,sucursal_direccion,sucursal_mail,sucursal_telefono)
SELECT sucursal_id,sucursal_direccion,sucursal_mail,sucursal_telefono FROM EQUIPO_RAYO.Sucursales


--Dimension Aviones
INSERT INTO EQUIPO_RAYO.Dim_Aviones(avion_id,avion_identificador,avion_modelo)
SELECT avion_id,avion_identificador,avion_modelo FROM EQUIPO_RAYO.Aviones


--Dimension tipo pasaje
INSERT INTO EQUIPO_RAYO.Dim_Tipo_Pasajes(tipo_pasaje_costo,tipo_pasaje_precio,tipo_pasaje_tipo)
SELECT DISTINCT P.pasaje_costo,P.pasaje_precio,B.butaca_tipo
FROM EQUIPO_RAYO.Butacas B
	JOIN EQUIPO_RAYO.Pasajes P ON P.butaca_id = B.butaca_id
	JOIN EQUIPO_RAYO.ItemFacturas it ON it.pasaje_id=P.pasaje_id


--Dimension tipo habitaciones
INSERT INTO EQUIPO_RAYO.Dim_Hab_Tipos(hab_tipo_id,hab_tipo_hotel,hab_tipo_direc,hab_tipo_estrellas,hab_tipo_cant_camas,hab_tipo_costo,hab_tipo_precio)
SELECT Hab.habitacion_id,
       E.empresa_razon_social,
       CONCAT(H.hotel_calle,' ',H.hotel_nro_calle),
	   H.hotel_estrellas,
	   dbo.cantCamas(Hab.habitacion_id),
	   Hab.habitacion_costo,
	   Hab.habitacion_precio
FROM EQUIPO_RAYO.Empresas E
	JOIN EQUIPO_RAYO.Hoteles H ON H.empresa_id=E.empresa_id
	JOIN EQUIPO_RAYO.Habitaciones Hab ON Hab.hotel_id=H.hotel_id

--Rutas
INSERT INTO EQUIPO_RAYO.Dim_Rutas(ruta_id,ruta_origen,ruta_destino)
SELECT ruta_id,ruta_ciudad_origen,ruta_ciudad_destino FROM EQUIPO_RAYO.Rutas


--Ciudades
INSERT INTO EQUIPO_RAYO.Dim_Ciudades(ciudad_nombre)
SELECT DISTINCT ruta_ciudad_destino FROM EQUIPO_RAYO.Rutas
UNION
SELECT DISTINCT ruta_ciudad_origen FROM EQUIPO_RAYO.Rutas


--Hechos Ventas Pasajes, hay dos tablas de hechos
INSERT INTO EQUIPO_RAYO.Hechos_Ventas_Pasajes(anio,mes,cliente_id,proveedor_id,sucursal_id,avion_id,tipo_pasaje_id,ruta_id,ciudad_id,prom_compra,prom_venta,ganacias_pasajes)
SELECT 
       YEAR(F.factura_fecha),
	   MONTH(F.factura_fecha),
       F.cliente_id,
	   A.empresa_id,
	   F.sucursal_id,
	   V.avion_id,
	   TP.tipo_pasaje_id,
	   V.ruta_id,
	   Ci.ciudad_id,
	   AVG(Pa.pasaje_costo),
	   AVG(Pa.pasaje_precio),
	   SUM(Pa.pasaje_precio-Pa.pasaje_costo)
FROM EQUIPO_RAYO.Facturas F
	JOIN EQUIPO_RAYO.ItemFacturas it ON it.item_factura_id=F.factura_id
	JOIN EQUIPO_RAYO.Pasajes Pa ON Pa.pasaje_id=it.pasaje_id
	JOIN EQUIPO_RAYO.Vuelos V ON V.vuelo_id=Pa.vuelo_id
	JOIN EQUIPO_RAYO.Aviones A ON A.avion_id=V.avion_id
	JOIN EQUIPO_RAYO.Rutas Ru ON Ru.ruta_id=V.ruta_id
	JOIN EQUIPO_RAYO.Dim_Ciudades Ci ON Ci.ciudad_nombre LIKE Ru.ruta_ciudad_destino
	JOIN EQUIPO_RAYO.Dim_Tipo_Pasajes TP ON TP.tipo_pasaje_costo=Pa.pasaje_costo AND TP.tipo_pasaje_precio=Pa.pasaje_precio
WHERE it.estadia_id IS NULL
GROUP BY YEAR(F.factura_fecha),MONTH(F.factura_fecha),F.cliente_id,A.empresa_id,F.sucursal_id,V.avion_id,TP.tipo_pasaje_id,V.ruta_id,Ci.ciudad_id


--Migracion de la 2da tabla de hechos, Hechos Ventas Estadias
INSERT INTO EQUIPO_RAYO.Hechos_Ventas_Estadias(anio,mes,cliente_id,proveedor_id,sucursal_id,hab_tipo_id,prom_compra,prom_venta,cant_camas,ganacias_estadias)
SELECT 
       YEAR(F.factura_fecha),
	   MONTH(F.factura_fecha),
       F.cliente_id,
	   Ho.empresa_id,
	   F.sucursal_id,
	   EH.habitacion_id,
	   AVG(H.habitacion_costo),
	   AVG(H.habitacion_precio),
	   dbo.cantCamas(EH.habitacion_id),
	   SUM(H.habitacion_precio-H.habitacion_costo)
FROM EQUIPO_RAYO.Facturas F
	JOIN EQUIPO_RAYO.ItemFacturas it ON it.item_factura_id=F.factura_id
	JOIN EQUIPO_RAYO.Estadias_Habitaciones EH ON EH.estadia_id=it.estadia_id
	JOIN EQUIPO_RAYO.Habitaciones H on H.habitacion_id=EH.habitacion_id
	JOIN EQUIPO_RAYO.Hoteles Ho ON Ho.hotel_id=H.hotel_id
WHERE it.pasaje_id IS NULL
GROUP BY YEAR(F.factura_fecha),MONTH(F.factura_fecha),F.cliente_id,Ho.empresa_id,F.sucursal_id,EH.habitacion_id


--Vistas a modo de ejemplo--

--Resultados sobre las ventas de pasajes separado por anio y mes. Pedido por los requisitos minimos de la entrega
GO
CREATE VIEW [Resultados Pasajes] AS
SELECT anio,mes,AVG(prom_compra) as Prom_Compra,
       AVG(prom_venta) as Prom_Venta,
	   COUNT(*) as Pasajes_Vendidos,
	   SUM(ganacias_pasajes)as Ganancias 
FROM EQUIPO_RAYO.Hechos_Ventas_Pasajes
GROUP BY anio,mes
GO


--Resultados sobre las ventas de estadias separado por anio y mes. Pedido por los requisitos minimos de la entrega
GO
CREATE VIEW [Resultados Estadias] AS
SELECT anio,mes,AVG(prom_compra) as Prom_Compra,
       AVG(prom_venta) as Prom_Venta,
	   COUNT(*) as Habitaciones_Vendidas,
	   SUM(cant_camas) as Cantidad_Camas,
	   SUM(ganacias_estadias) as Ganacias
FROM EQUIPO_RAYO.Hechos_Ventas_Estadias
GROUP BY anio,mes
GO

--Una view extra con infomracion sobre la cantidad de ventas por sucursal y la edad promedio del comprador en PASAJES lo mismo se puede hacer con estadias
GO
CREATE VIEW [Ventas por sucursal] AS
SELECT anio,mes,
       DS.sucursal_mail,
	   COUNT(*) as VENTAS,
	   AVG(DC.cliente_edad) as Edad_Prom
FROM EQUIPO_RAYO.Hechos_Ventas_Pasajes VP
JOIN EQUIPO_RAYO.Dim_Sucursales DS ON DS.sucursal_id=VP.sucursal_id
JOIN EQUIPO_RAYO.Dim_Clientes DC ON DC.cliente_id=VP.cliente_id
GROUP BY anio,mes,DS.sucursal_mail
GO


SELECT * FROM [Resultados Pasajes]
SELECT * FROM [Resultados Estadias]


/*
---Para dropear todo

DROP TABLE EQUIPO_RAYO.Hechos_Ventas_Pasajes
DROP TABLE EQUIPO_RAYO.Hechos_Ventas_Estadias
DROP TABLE EQUIPO_RAYO.Dim_Sucursales
DROP TABLE EQUIPO_RAYO.Dim_Aviones
DROP TABLE EQUIPO_RAYO.Dim_Ciudades
DROP TABLE EQUIPO_RAYO.Dim_Clientes
DROP TABLE EQUIPO_RAYO.Dim_Proveedores
DROP TABLE EQUIPO_RAYO.Dim_Hab_Tipos
DROP TABLE EQUIPO_RAYO.Dim_Rutas
DROP TABLE EQUIPO_RAYO.Dim_Tipo_Pasajes
DROP FUNCTION cantCamas
DROP VIEW [Resultados Pasajes]
DROP VIEW [Resultados Estadias]
DROP VIEW [Ventas por sucursal]
*/
