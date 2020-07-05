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
		proveedor_razon_social NVARCHAR(255)
	)

IF OBJECT_ID('EQUIPO_RAYO.Dim_Aviones') IS NULL
	CREATE TABLE EQUIPO_RAYO.Dim_Aviones
	(
		avion_id INT PRIMARY KEY,
		avion_identificador NVARCHAR(50),
		avion_modelo NVARCHAR(50)
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
INSERT INTO EQUIPO_RAYO.Dim_Proveedores(proveedor_id,proveedor_razon_social)
SELECT empresa_id,empresa_razon_social FROM EQUIPO_RAYO.Empresas


--Dimension Aviones
INSERT INTO EQUIPO_RAYO.Dim_Aviones(avion_id,avion_identificador,avion_modelo)
SELECT avion_id,avion_identificador,avion_modelo FROM EQUIPO_RAYO.Aviones



---Dimension tiempo, utilizamos los tiempos de las facturas y las compras 
GO
CREATE PROCEDURE llenarDimTiempo
AS
BEGIN
	DECLARE @fecha DATETIME2(3)

	DECLARE C_Fechas CURSOR FOR 
	SELECT DISTINCT(compra_fecha)
           FROM EQUIPO_RAYO.Compras
	UNION
	SELECT DISTINCT(factura_fecha)
           FROM EQUIPO_RAYO.Facturas

	OPEN C_Fechas

	FETCH NEXT FROM C_Fechas INTO @fecha
	WHILE @@FETCH_STATUS=0
	BEGIN
		IF NOT EXISTS (SELECT * FROM EQUIPO_RAYO.Dim_Tiempo WHERE tiempo_fecha=@fecha)
			BEGIN
				INSERT INTO EQUIPO_RAYO.Dim_Tiempo(tiempo_fecha,tiempo_anio,tiempo_mes,tiempo_dia) 
				VALUES(@fecha,YEAR(@fecha),MONTH(@fecha),DAY(@fecha))
			END
	FETCH NEXT FROM C_Fechas INTO @fecha
	END

	CLOSE C_Fechas
	DEALLOCATE C_Fechas
END
GO

exec llenarDimTiempo






---Pruebas
SELECT * FROM EQUIPO_RAYO.Dim_Clientes

SELECT * FROM EQUIPO_RAYO.Dim_Tiempo ORDER BY tiempo_fecha
SELECT DISTINCT(tiempo_fecha) FROM EQUIPO_RAYO.Dim_Tiempo
DROP TABLE EQUIPO_RAYO.Dim_Tiempo
