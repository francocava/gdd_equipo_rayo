USE GD1C2020;

--=============Creacion de tablas

IF OBJECT_ID('EQUIPO_RAYO.Dim_Clientes') IS NULL
	CREATE TABLE EQUIPO_RAYO.Dim_Clientes
	(
		cliente_id INT PRIMARY KEY,
		cliente_dni DECIMAL(18,0),
		cliente_nombre NVARCHAR(255),
		cliente_apellido NVARCHAR(255),
		cliente_fecha_nac DATETIME2(3),
		cliente_mail NVARCHAR(255),
		cliente_telefono INT
	)
GO

IF OBJECT_ID('EQUIPO_RAYO.Dim_Tiempo') IS NULL
	CREATE TABLE EQUIPO_RAYO.Dim_Tiempo
	(
		tiempo_id INT IDENTITY PRIMARY KEY,
		tiempo_fecha DATETIME2(3),
		tiempo_anio INT,
		tiempo_mes INT,
		tiempo_dia INT
	)

/* 
IF OBJECT_ID('EQUIPO_RAYO.Dim_Rutas') IS NULL ---------- No es al pedo esta tabla si
	CREATE TABLE EQUIPO_RAYO.Dim_Rutas ----------------- tenemos la dim_ciudades??
	(
		ruta_id INT IDENTITY PRIMARY KEY


	)
*/


IF OBJECT_ID('EQUIPO_RAYO.Dim_Proveedores') IS NULL
	CREATE TABLE EQUIPO_RAYO.Dim_Proveedores
	(
		proveedor_id INT PRIMARY KEY,
		proveedor_direccion NVARCHAR(255),
		proveedor_mail NVARCHAR(255),
		proveedor_telefono DECIMAL(18,0)
	)

IF OBJECT_ID('EQUIPO_RAYO.Dim_Aviones') IS NULL
	CREATE TABLE EQUIPO_RAYO.Dim_Aviones
	(
		avion_id INT PRIMARY KEY,
		avion_identificador NVARCHAR(50),
		avion_modelo NVARCHAR(50)
	)

IF OBJECT_ID('EQUIPO_RAYO.Dim_Tipo_Pasajes') IS NULL
	CREATE TABLE EQUIPO_RAYO.Dim_Tipo_Pasajes
	(
		tipo_pasaje_id INT IDENTITY PRIMARY KEY,
		tipo_pasaje_costo DECIMAL(18,2),
		tipo_pasaje_precio DECIMAL(18,2),
		tipo_pasaje_tipo NVARCHAR(255)
	)

IF OBJECT_ID('EQUIPO_RAYO.Dim_Hab_Tipos') IS NULL
	CREATE TABLE EQUIPO_RAYO.Dim_Hab_Tipos
	(
		hab_tipo_id INT IDENTITY PRIMARY KEY,
		hab_tipo_hotel NVARCHAR(255),
		hab_tipo_direc NVARCHAR(255),
		hab_tipo_estrellas DECIMAL(18,0),
		hab_tipo_cant_camas INT
	)




--=========Migracion a BI


---Dimension Clientes
INSERT INTO EQUIPO_RAYO.Dim_Clientes(cliente_id,cliente_dni,cliente_nombre,cliente_apellido,cliente_fecha_nac,cliente_mail,cliente_telefono)
SELECT cliente_id,
       cliente_dni,
	   cliente_nombre,
	   cliente_apellido,
	   cliente_fecha_nac,
	   cliente_mail,
	   cliente_telefono 
FROM EQUIPO_RAYO.Clientes


---Dimension Proveedores
INSERT INTO EQUIPO_RAYO.Dim_Proveedores(proveedor_id,proveedor_direccion,proveedor_mail,proveedor_telefono)
SELECT sucursal_id,sucursal_direccion,sucursal_mail,sucursal_telefono FROM EQUIPO_RAYO.Sucursales


--Dimension Aviones
INSERT INTO EQUIPO_RAYO.Dim_Aviones(avion_id,avion_identificador,avion_modelo)
SELECT avion_id,avion_identificador,avion_modelo FROM EQUIPO_RAYO.Aviones


--Dimension Tiempo
INSERT INTO EQUIPO_RAYO.Dim_Tiempo(tiempo_fecha,tiempo_anio,tiempo_mes,tiempo_dia)
SELECT DISTINCT(factura_fecha),
	   YEAR(factura_fecha),
	   MONTH(factura_fecha),
	   DAY(factura_fecha)
FROM EQUIPO_RAYO.Facturas


--Dimension tipo pasaje
INSERT INTO EQUIPO_RAYO.Dim_Tipo_Pasajes(tipo_pasaje_costo,tipo_pasaje_precio,tipo_pasaje_tipo)
SELECT P.pasaje_costo,P.pasaje_precio,B.butaca_tipo
FROM EQUIPO_RAYO.Butacas B
	JOIN EQUIPO_RAYO.Pasajes P ON P.butaca_id = B.butaca_id

---Pruebas

SELECT * FROM EQUIPO_RAYO.Dim_Clientes
SELECT * FROM EQUIPO_RAYO.Dim_Tipo_Pasajes

SELECT * FROM EQUIPO_RAYO.Dim_Tiempo ORDER BY tiempo_fecha
SELECT DISTINCT(tiempo_fecha) FROM EQUIPO_RAYO.Dim_Tiempo
DROP TABLE EQUIPO_RAYO.Dim_Tiempo
