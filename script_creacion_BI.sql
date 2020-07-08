USE GD1C2020;

--=========================Creacion del schema por si no existe==================================================================================================

IF NOT EXISTS(SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'EQUIPO_RAYO')
BEGIN
		EXEC sp_executesql N'CREATE SCHEMA EQUIPO_RAYO'
END
GO


--=============Creacion de tablas, si ya existen no hace nada

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

IF OBJECT_ID('EQUIPO_RAYO.Dim_Tiempo') IS NULL
	CREATE TABLE EQUIPO_RAYO.Dim_Tiempo
	(
		tiempo_id INT IDENTITY PRIMARY KEY,
		tiempo_fecha DATETIME2(3),
		tiempo_anio INT,
		tiempo_mes INT,
		tiempo_dia INT
	)


IF OBJECT_ID('EQUIPO_RAYO.Dim_Rutas') IS NULL
	CREATE TABLE EQUIPO_RAYO.Dim_Rutas 
	(
		ruta_id INT PRIMARY KEY,
		ruta_origen NVARCHAR(255),
		ruta_destino NVARCHAR(255)
	)


IF OBJECT_ID('EQUIPO_RAYO.Dim_Ciudades') IS NULL --Sigo con dudas sobre esta dim 
	CREATE TABLE EQUIPO_RAYO.Dim_Ciudades 
	(
		ciudad_id INT IDENTITY PRIMARY KEY,
		ciudad_nombre NVARCHAR(255)
	)



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

--Aca solo consideramos los pasajes que fueron vendidos por lo tanto se pueden vincular a un cliente
IF OBJECT_ID('EQUIPO_RAYO.Dim_Tipo_Pasajes') IS NULL
	CREATE TABLE EQUIPO_RAYO.Dim_Tipo_Pasajes
	(
		tipo_pasaje_id INT PRIMARY KEY,
		tipo_pasaje_costo DECIMAL(18,2),
		tipo_pasaje_precio DECIMAL(18,2),
		tipo_pasaje_tipo NVARCHAR(255)
	)

IF OBJECT_ID('EQUIPO_RAYO.Dim_Hab_Tipos') IS NULL
	CREATE TABLE EQUIPO_RAYO.Dim_Hab_Tipos
	(
		hab_tipo_id INT PRIMARY KEY,
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
		ruta_id INT FOREIGN KEY (ruta_id) REFERENCES EQUIPO_RAYO.Dim_Rutas(ruta_id),
		ciudad_id INT FOREIGN KEY (ciudad_id) REFERENCES EQUIPO_RAYO.Dim_Ciudades(ciudad_id),
		costo DECIMAL(18,2),
		precio_venta DECIMAL(18,2),
		PRIMARY KEY(cliente_id,tiempo_id,proveedor_id,hab_tipo_id,avion_id,tipo_pasaje_id,ruta_id,ciudad_id)
	)

---==Funciones

--Devuelve la cantidad de camas que tiene una habitacion
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
INSERT INTO EQUIPO_RAYO.Dim_Tipo_Pasajes(tipo_pasaje_id,tipo_pasaje_costo,tipo_pasaje_precio,tipo_pasaje_tipo)
SELECT P.pasaje_id,P.pasaje_costo,P.pasaje_precio,B.butaca_tipo
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


--Agrego IDs 0 para evitar NULLS en Hechos_Ventas. Si un cliente compro una estadia => en hechos_ventas va a tener 0 en las dimensiones de pasajes

INSERT INTO EQUIPO_RAYO.Dim_Hab_Tipos VALUES(0,' ',' ',0,0,0,0) --Si me jode con los promedios o algo asi meto todo NULL

SET IDENTITY_INSERT EQUIPO_RAYO.Dim_Ciudades ON
INSERT INTO EQUIPO_RAYO.Dim_Ciudades(ciudad_id,ciudad_nombre) VALUES(0,' ')
SET IDENTITY_INSERT EQUIPO_RAYO.Dim_Ciudades OFF

INSERT INTO EQUIPO_RAYO.Dim_Aviones VALUES (0,'','')

INSERT INTO EQUIPO_RAYO.Dim_Tipo_Pasajes VALUES (0,0,0,'')

INSERT INTO EQUIPO_RAYO.Dim_Rutas VALUES (0,'','')


--Hechos Ventas para pasajes
INSERT INTO EQUIPO_RAYO.Hechos_Ventas(cliente_id,tiempo_id,proveedor_id,hab_tipo_id,avion_id,tipo_pasaje_id,ruta_id,ciudad_id,costo,precio_venta)
SELECT C.cliente_id,
       T.tiempo_id,
	   F.sucursal_id,
	   0,
	   V.avion_id,
	   Pa.pasaje_id,
	   V.ruta_id,
	   (SELECT ciudad_id FROM EQUIPO_RAYO.Dim_Ciudades WHERE ciudad_nombre LIKE ruta_ciudad_destino),
	   Pa.pasaje_costo,
	   F.factura_total
FROM EQUIPO_RAYO.Dim_Clientes C 
	JOIN EQUIPO_RAYO.Facturas F ON F.cliente_id=C.cliente_id
	JOIN EQUIPO_RAYO.Dim_Tiempo T ON T.tiempo_fecha=F.factura_fecha
	JOIN EQUIPO_RAYO.ItemFacturas it ON it.item_factura_id=F.factura_id
	JOIN EQUIPO_RAYO.Pasajes Pa ON Pa.pasaje_id=it.pasaje_id
	JOIN EQUIPO_RAYO.Vuelos V ON V.vuelo_id=Pa.vuelo_id
	JOIN EQUIPO_RAYO.Rutas Ru ON Ru.ruta_id=V.ruta_id
WHERE it.estadia_id IS NULL


--Hechos Ventas para hoteles
INSERT INTO EQUIPO_RAYO.Hechos_Ventas(cliente_id,tiempo_id,proveedor_id,hab_tipo_id,avion_id,tipo_pasaje_id,ruta_id,ciudad_id,costo,precio_venta)
SELECT C.cliente_id,
       T.tiempo_id,
	   F.sucursal_id,
	   EH.habitacion_id,
	   0,
	   0,
	   0,
	   0,
	   (SELECT h1.habitacion_costo FROM EQUIPO_RAYO.Habitaciones h1 WHERE h1.habitacion_id=EH.habitacion_id), --Subquery que devuelve el costo de una habitacion en particular
	   F.factura_total
FROM EQUIPO_RAYO.Dim_Clientes C 
	JOIN EQUIPO_RAYO.Facturas F ON F.cliente_id=C.cliente_id
	JOIN EQUIPO_RAYO.Dim_Tiempo T ON T.tiempo_fecha=F.factura_fecha
	JOIN EQUIPO_RAYO.ItemFacturas it ON it.item_factura_id=F.factura_id
	JOIN EQUIPO_RAYO.Estadias_Habitaciones EH ON EH.estadia_id=it.estadia_id
WHERE it.pasaje_id IS NULL



/*
---Pruebas

SELECT * FROM EQUIPO_RAYO.Hechos_Ventas

SELECT T.tiempo_anio,T.tiempo_mes,AVG(HV.precio) FROM EQUIPO_RAYO.Hechos_Ventas HV
JOIN EQUIPO_RAYO.Dim_Tiempo T ON T.tiempo_id= HV.tiempo_id
GROUP BY T.tiempo_anio,T.tiempo_mes

SELECT TOP(1) ciudad_id as Destino_Mas_Frecuente FROM EQUIPO_RAYO.Hechos_Ventas
GROUP BY ciudad_id
ORDER BY COUNT(ciudad_id) desc

SELECT * FROM EQUIPO_RAYO.Dim_Ciudades

SELECT * FROM EQUIPO_RAYO.Dim_Clientes
SELECT * FROM EQUIPO_RAYO.Dim_Tipo_Pasajes
SELECT * FROM EQUIPO_RAYO.Pasajes



SELECT * FROM EQUIPO_RAYO.Dim_Tiempo ORDER BY tiempo_fecha
SELECT DISTINCT(tiempo_fecha) FROM EQUIPO_RAYO.Dim_Tiempo


SELECT hotel_id,CONCAT(hotel_calle,' ',hotel_nro_calle) FROM EQUIPO_RAYO.Hoteles

SELECT dbo.cantCamas('314')

SELECT * FROM EQUIPO_RAYO.Habitaciones --La 1 tiene tipo 1,King OK / La 184 tiene 3,Simple OK / La 314 tiene 4,Cuadruple OK

SELECT * FROM EQUIPO_RAYO.Dim_Hab_Tipos

drop table EQUIPO_RAYO.Dim_Hab_Tipos

SELECT * FROM EQUIPO_RAYO.Dim_Tipo_Pasajes



--221834
SELECT * FROM EQUIPO_RAYO.Pasajes P
	JOIN EQUIPO_RAYO.ItemFacturas it ON it.pasaje_id=P.pasaje_id





DROP TABLE EQUIPO_RAYO.Hechos_Ventas
DROP TABLE EQUIPO_RAYO.Dim_Aviones
DROP TABLE EQUIPO_RAYO.Dim_Ciudades
DROP TABLE EQUIPO_RAYO.Dim_Clientes
DROP TABLE EQUIPO_RAYO.Dim_Proveedores
DROP TABLE EQUIPO_RAYO.Dim_Hab_Tipos
DROP TABLE EQUIPO_RAYO.Dim_Rutas
DROP TABLE EQUIPO_RAYO.Dim_Tiempo
DROP TABLE EQUIPO_RAYO.Dim_Tipo_Pasajes
DROP FUNCTION cantCamas

*/