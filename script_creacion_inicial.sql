USE GD1C2020;


--=========================Creacion del schema por si no existe==================================================================================================

IF NOT EXISTS(SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'EQUIPO_RAYO')
BEGIN
		EXEC sp_executesql N'CREATE SCHEMA EQUIPO_RAYO'
END
GO


--=========================Creacion de las tablas. Si ya existe no las vuelve a crear===============================================================================

--Tabla de Clientes
IF OBJECT_ID('EQUIPO_RAYO.Clientes') IS NULL
	CREATE TABLE EQUIPO_RAYO.Clientes
	(
		cliente_id INT IDENTITY PRIMARY KEY,
		cliente_dni DECIMAL(18,0),
		cliente_nombre NVARCHAR(255),
		cliente_apellido NVARCHAR(255),
		cliente_fecha_nac DATETIME2(3),
		cliente_mail NVARCHAR(255),
		cliente_telefono INT
	)
GO

--Tabla de Empresas
IF OBJECT_ID('EQUIPO_RAYO.Empresas') IS NULL
	CREATE TABLE EQUIPO_RAYO.Empresas
	(
		empresa_id INT IDENTITY PRIMARY KEY,
		empresa_razon_social  NVARCHAR(255) NOT NULL
	)
GO

--Tabla de Aviones
IF OBJECT_ID('EQUIPO_RAYO.Aviones') IS NULL
	CREATE TABLE EQUIPO_RAYO.Aviones
	(
		avion_id INT IDENTITY PRIMARY KEY,
		avion_identificador NVARCHAR(50) NOT NULL,
		empresa_id INT FOREIGN KEY (empresa_id) REFERENCES EQUIPO_RAYO.Empresas(empresa_id),
		avion_modelo NVARCHAR(50) NOT NULL
	)
GO


--Tabla de Butacas
IF OBJECT_ID('EQUIPO_RAYO.Butacas') IS NULL
	CREATE TABLE EQUIPO_RAYO.Butacas
	(
		butaca_id INT IDENTITY PRIMARY KEY,
		avion_id INT FOREIGN KEY (avion_id) REFERENCES EQUIPO_RAYO.Aviones(avion_id) NOT NULL,
		butaca_numero DECIMAL(18,0) NOT NULL,
		butaca_tipo NVARCHAR(255) NOT NULL
	)
GO

--Tabla de Rutas
IF OBJECT_ID('EQUIPO_RAYO.Rutas') IS NULL
	CREATE TABLE EQUIPO_RAYO.Rutas
	(
		ruta_id INT IDENTITY PRIMARY KEY,
		ruta_codigo DECIMAL,
		ruta_ciudad_origen NVARCHAR(255),
		ruta_ciudad_destino NVARCHAR(255)
	)
GO

--Tabla Sucursales
IF OBJECT_ID('EQUIPO_RAYO.Sucursales') IS NULL
	CREATE TABLE EQUIPO_RAYO.Sucursales
	(
		sucursal_id INT IDENTITY PRIMARY KEY,
		sucursal_direccion NVARCHAR(255),
		sucursal_mail NVARCHAR(255),
		sucursal_telefono DECIMAL(18,0)
	)
GO	

--=========================Migracion==============================================================================================================================


--Migracion tabla clientes
INSERT INTO EQUIPO_RAYO.Clientes(cliente_dni,cliente_nombre,cliente_apellido,cliente_fecha_nac,cliente_mail,cliente_telefono)
SELECT C.CLIENTE_DNI,
	   C.CLIENTE_NOMBRE,
	   C.CLIENTE_APELLIDO,
	   C.CLIENTE_FECHA_NAC,
	   C.CLIENTE_MAIL,
	   C.CLIENTE_TELEFONO 
FROM gd_esquema.Maestra C
GROUP BY C.CLIENTE_DNI,C.CLIENTE_NOMBRE,C.CLIENTE_APELLIDO,C.CLIENTE_FECHA_NAC,C.CLIENTE_MAIL,C.CLIENTE_TELEFONO 


--Migracion tabla empresas
INSERT INTO EQUIPO_RAYO.Empresas(empresa_razon_social)
SELECT E.EMPRESA_RAZON_SOCIAL FROM gd_esquema.Maestra E
GROUP BY E.EMPRESA_RAZON_SOCIAL


--Migracion tabla aviones
INSERT INTO EQUIPO_RAYO.Aviones(empresa_id,avion_identificador,avion_modelo)
SELECT E.empresa_id,A.AVION_IDENTIFICADOR,A.AVION_MODELO FROM gd_esquema.Maestra A
	INNER JOIN EQUIPO_RAYO.Empresas E ON E.empresa_razon_social=A.EMPRESA_RAZON_SOCIAL
	WHERE AVION_IDENTIFICADOR IS NOT NULL
GROUP BY E.empresa_id,A.AVION_IDENTIFICADOR,A.AVION_MODELO


--Migracion tabla Butacas  --Averiguar que onda el inner 
INSERT INTO EQUIPO_RAYO.Butacas(avion_id,butaca_numero,butaca_tipo)
SELECT A.avion_id,B.BUTACA_NUMERO,B.BUTACA_TIPO FROM gd_esquema.Maestra B 
	INNER JOIN EQUIPO_RAYO.Aviones A ON A.avion_identificador = B.AVION_IDENTIFICADOR WHERE B.AVION_IDENTIFICADOR IS NOT NULL
GROUP BY A.avion_id,B.BUTACA_NUMERO,B.BUTACA_TIPO


--Migracion tabla Rutas
INSERT INTO EQUIPO_RAYO.Rutas(ruta_codigo,ruta_ciudad_origen,ruta_ciudad_destino)
SELECT R.RUTA_AEREA_CODIGO,R.RUTA_AEREA_CIU_ORIG,R.RUTA_AEREA_CIU_DEST FROM gd_esquema.Maestra R
GROUP BY R.RUTA_AEREA_CODIGO,R.RUTA_AEREA_CIU_ORIG,R.RUTA_AEREA_CIU_DEST


--Migracion tabla Sucursales
INSERT INTO EQUIPO_RAYO.Sucursales(sucursal_direccion,sucursal_mail,sucursal_telefono)
SELECT S.SUCURSAL_DIR,S.SUCURSAL_MAIL,S.SUCURSAL_TELEFONO FROM gd_esquema.Maestra S
GROUP BY S.SUCURSAL_DIR,S.SUCURSAL_MAIL,S.SUCURSAL_TELEFONO




--Drop Zone-- Despues hay que hacer un script aparte para esto
DROP TABLE EQUIPO_RAYO.Clientes
DROP TABLE EQUIPO_RAYO.Empresas
DROP TABLE EQUIPO_RAYO.Aviones
DROP TABLE EQUIPO_RAYO.Butacas
DROP TABLE EQUIPO_RAYO.Rutas


--Para probar si migro bien 

SELECT * FROM EQUIPO_RAYO.Aviones

SELECT * FROM EQUIPO_RAYO.Empresas

SELECT * FROM EQUIPO_RAYO.Butacas
ORDER BY butaca_numero,avion_id

SELECT * FROM EQUIPO_RAYO.Rutas


SELECT * FROM EQUIPO_RAYO.Sucursales
SELECT DISTINCT SUCURSAL_MAIL FROM gd_esquema.Maestra