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

IF OBJECT_ID('EQUIPO_RAYO.Dim_Ciudades') IS NULL
	CREATE TABLE EQUIPO_RAYO.Dim_Ciudades 
	(
		ciudad_id INT IDENTITY PRIMARY KEY


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
		hab_tipo_cant_camas INT,
		--hab_tipo_ingreso DATETIME2(3),
		--hab_tipo_cant_noches DECIMAL(18,0), --Si tengo que poner estos dos me complica un monton CONSULTAR
		hab_tipo_costo DECIMAL(18,2),
		hab_tipo_precio DECIMAL(18,2)
	)


IF OBJECT_ID('EQUIPO_RAYO.Hechos_Ventas') IS NULL
	CREATE TABLE EQUIPO_RAYO.Hechos_Ventas
	(
		cliente_id INT FOREIGN KEY (cliente_id) REFERENCES EQUIPO_RAYO.Dim_Clientes(cliente_id) NOT NULL,
		tiempo_id INT FOREIGN KEY (tiempo_id) REFERENCES EQUIPO_RAYO.Dim_Tiempo(tiempo_id) NOT NULL,
		proveedor_id INT FOREIGN KEY (proveedor_id) REFERENCES EQUIPO_RAYO.Dim_Proveedores(proveedor_id) NOT NULL,
		hab_tipo_id INT FOREIGN KEY (hab_tipo_id) REFERENCES EQUIPO_RAYO.Dim_Hab_Tipos(hab_tipo_id),
		avion_id INT FOREIGN KEY (avion_id) REFERENCES EQUIPO_RAYO.Dim_Aviones(avion_id),
		tipo_pasaje_id INT FOREIGN KEY (tipo_pasaje_id) REFERENCES EQUIPO_RAYO.Dim_Tipo_Pasajes(tipo_pasaje_id),
		precio DECIMAL(18,2)
		PRIMARY KEY(cliente_id,tiempo_id,proveedor_id,hab_tipo_id,avion_id,tipo_pasaje_id)
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


--Dimension tipo habitaciones
INSERT INTO EQUIPO_RAYO.Dim_Hab_Tipos(hab_tipo_hotel,hab_tipo_direc,hab_tipo_estrellas,hab_tipo_cant_camas,hab_tipo_costo,hab_tipo_precio)
SELECT E.empresa_razon_social,
       CONCAT(H.hotel_calle,' ',H.hotel_nro_calle),
	   H.hotel_estrellas,
	   dbo.cantCamas(Hab.habitacion_id),
	   Hab.habitacion_costo,
	   Hab.habitacion_precio
FROM EQUIPO_RAYO.Empresas E
	JOIN EQUIPO_RAYO.Hoteles H ON H.empresa_id=E.empresa_id
	JOIN EQUIPO_RAYO.Habitaciones Hab ON Hab.hotel_id=H.hotel_id


--Hechos
INSERT INTO EQUIPO_RAYO.Hechos_Ventas()

--Funciones
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


---Pruebas

SELECT * FROM EQUIPO_RAYO.Dim_Clientes
SELECT * FROM EQUIPO_RAYO.Dim_Tipo_Pasajes

SELECT * FROM EQUIPO_RAYO.Dim_Tiempo ORDER BY tiempo_fecha
SELECT DISTINCT(tiempo_fecha) FROM EQUIPO_RAYO.Dim_Tiempo
DROP TABLE EQUIPO_RAYO.Dim_Tiempo

SELECT hotel_id,CONCAT(hotel_calle,' ',hotel_nro_calle) FROM EQUIPO_RAYO.Hoteles

SELECT dbo.cantCamas('314')

SELECT * FROM EQUIPO_RAYO.Habitaciones --La 1 tiene tipo 1,King OK / La 184 tiene 3,Simple OK / La 314 tiene 4,Cuadruple OK