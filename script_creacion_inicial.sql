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

--Tabla de Tipos
IF OBJECT_ID('EQUIPO_RAYO.Tipos') IS NULL
	CREATE TABLE EQUIPO_RAYO.Tipos
	(
		tipo_id INT IDENTITY PRIMARY KEY,
		tipo_codigo DECIMAL(18,0),
		tipo_descripcion NVARCHAR(50)
	)


--Tabla de Compras
IF OBJECT_ID('EQUIPO_RAYO.Compras') IS NULL
	CREATE TABLE EQUIPO_RAYO.Compras
	(
		compra_id INT IDENTITY PRIMARY KEY,
		compra_numero DECIMAL(18,0),
		compra_fecha DATETIME2(3)
	)


--Tabla de Vuelos
IF OBJECT_ID('EQUIPO_RAYO.Vuelos') IS NULL
	CREATE TABLE EQUIPO_RAYO.Vuelos
	(
		vuelo_id INT IDENTITY PRIMARY KEY,
		ruta_id INT FOREIGN KEY (ruta_id) REFERENCES EQUIPO_RAYO.Rutas(ruta_id) NOT NULL,
		avion_id INT FOREIGN KEY (avion_id) REFERENCES EQUIPO_RAYO.Aviones(avion_id) NOT NULL,
		vuelo_codigo DECIMAL(19,0),
		vuelo_salida DATETIME2(3),
		vuelo_llegada DATETIME2(3)
	)

IF OBJECT_ID('EQUIPO_RAYO.Pasajes') IS NULL
	CREATE TABLE EQUIPO_RAYO.Pasajes
	(
		pasaje_id INT IDENTITY PRIMARY KEY,
		vuelo_id INT FOREIGN KEY (vuelo_id) REFERENCES EQUIPO_RAYO.Vuelos(vuelo_id) NOT NULL,
		compra_id INT FOREIGN KEY (compra_id) REFERENCES EQUIPO_RAYO.Compras(compra_id) NOT NULL,
		butaca_id INT FOREIGN KEY (butaca_id) REFERENCES EQUIPO_RAYO.Butacas(butaca_id) NOT NULL,
		pasaje_codigo DECIMAL(18,0),
		pasaje_costo DECIMAL(18,2),
		pasaje_precio DECIMAL(18,2)
	)


IF OBJECT_ID('EQUIPO_RAYO.Hoteles') IS NULL
	CREATE TABLE EQUIPO_RAYO.Hoteles
	(
		hotel_id INT IDENTITY PRIMARY KEY,
		empresa_id INT FOREIGN KEY (empresa_id) REFERENCES EQUIPO_RAYO.Empresas(empresa_id) NOT NULL,
		hotel_calle NVARCHAR(50),
		hotel_nro_calle DECIMAL(18,0),
		hotel_estrellas DECIMAL(18,0)
	)


IF OBJECT_ID('EQUIPO_RAYO.Habitaciones') IS NULL
	CREATE TABLE EQUIPO_RAYO.Habitaciones
	(
		habitacion_id INT IDENTITY PRIMARY KEY,
		tipo_id INT FOREIGN KEY (tipo_id) REFERENCES EQUIPO_RAYO.Tipos(tipo_id) NOT NULL,
		hotel_id INT FOREIGN KEY (hotel_id) REFERENCES EQUIPO_RAYO.Hoteles(hotel_id) NOT NULL,
		habitacion_numero DECIMAL(18,0),
		habitacion_piso DECIMAL(18,0),
		habitacion_frente NVARCHAR(50),
		habitacion_costo DECIMAL(18,2),
		habitacion_precio DECIMAL(18,2)
	)


IF OBJECT_ID('EQUIPO_RAYO.Estadias') IS NULL
	CREATE TABLE EQUIPO_RAYO.Estadias
	(
		estadia_id INT IDENTITY PRIMARY KEY,
		hotel_id INT FOREIGN KEY (hotel_id) REFERENCES EQUIPO_RAYO.Hoteles(hotel_id) NOT NULL,
		compra_id INT FOREIGN KEY (compra_id) REFERENCES EQUIPO_RAYO.Compras(compra_id) NOT NULL,
		estadia_fecha_ingreso DATETIME2(3),
		estadia_cant_noches DECIMAL(18,0),
		estadia_codigo DECIMAL(18,0)
	)


IF OBJECT_ID('EQUIPO_RAYO.Estadias_Habitaciones') IS NULL
	CREATE TABLE EQUIPO_RAYO.Estadias_Habitaciones
	(
		estadia_id INT FOREIGN KEY (estadia_id) REFERENCES EQUIPO_RAYO.Estadias(estadia_id) NOT NULL,
		habitacion_id INT FOREIGN KEY (habitacion_id) REFERENCES EQUIPO_RAYO.Habitaciones(habitacion_id) NOT NULL,
		PRIMARY KEY(estadia_id,habitacion_id)
	)


IF OBJECT_ID('EQUIPO_RAYO.Facturas') IS NULL
	CREATE TABLE EQUIPO_RAYO.Facturas
	(
		factura_id INT IDENTITY PRIMARY KEY,
		cliente_id INT FOREIGN KEY (cliente_id) REFERENCES EQUIPO_RAYO.Clientes(cliente_id) NOT NULL,
		sucursal_id INT FOREIGN KEY (sucursal_id) REFERENCES EQUIPO_RAYO.Sucursales(sucursal_id) NOT NULL,
		factura_fecha DATETIME2(3),
		factura_numero DECIMAL(18,0),
		factura_total DECIMAL(18,2)
	) --Elegi DECIMAL(18,2) como tipo de dato del total por ser el tipo que usan los precios en las otras tablas



IF OBJECT_ID('EQUIPO_RAYO.ItemFacturas') IS NULL
	CREATE TABLE EQUIPO_RAYO.ItemFacturas
	(
		item_factura_id INT IDENTITY PRIMARY KEY,
		estadia_id INT FOREIGN KEY (estadia_id) REFERENCES EQUIPO_RAYO.Estadias(estadia_id),
		pasaje_id INT FOREIGN KEY (pasaje_id) REFERENCES EQUIPO_RAYO.Pasajes(pasaje_id),
		factura_id INT FOREIGN KEY (factura_id) REFERENCES EQUIPO_RAYO.Facturas(factura_id) NOT NULL
	) --esto ultimo cambio el der


--=========================Migracion==============================================================================================================================


--Clientes
INSERT INTO EQUIPO_RAYO.Clientes(cliente_dni,cliente_nombre,cliente_apellido,cliente_fecha_nac,cliente_mail,cliente_telefono)
SELECT C.CLIENTE_DNI,
	   C.CLIENTE_NOMBRE,
	   C.CLIENTE_APELLIDO,
	   C.CLIENTE_FECHA_NAC,
	   C.CLIENTE_MAIL,
	   C.CLIENTE_TELEFONO 
FROM gd_esquema.Maestra C
WHERE C.CLIENTE_DNI IS NOT NULL
GROUP BY C.CLIENTE_DNI,C.CLIENTE_NOMBRE,C.CLIENTE_APELLIDO,C.CLIENTE_FECHA_NAC,C.CLIENTE_MAIL,C.CLIENTE_TELEFONO 


--Empresas
INSERT INTO EQUIPO_RAYO.Empresas(empresa_razon_social)
SELECT E.EMPRESA_RAZON_SOCIAL FROM gd_esquema.Maestra E
GROUP BY E.EMPRESA_RAZON_SOCIAL


--Aviones
INSERT INTO EQUIPO_RAYO.Aviones(empresa_id,avion_identificador,avion_modelo)
SELECT E.empresa_id,A.AVION_IDENTIFICADOR,A.AVION_MODELO FROM gd_esquema.Maestra A
	INNER JOIN EQUIPO_RAYO.Empresas E ON E.empresa_razon_social=A.EMPRESA_RAZON_SOCIAL
	WHERE AVION_IDENTIFICADOR IS NOT NULL
GROUP BY E.empresa_id,A.AVION_IDENTIFICADOR,A.AVION_MODELO


--Butacas  --Averiguar que onda el inner 
INSERT INTO EQUIPO_RAYO.Butacas(avion_id,butaca_numero,butaca_tipo)
SELECT A.avion_id,B.BUTACA_NUMERO,B.BUTACA_TIPO FROM gd_esquema.Maestra B 
	INNER JOIN EQUIPO_RAYO.Aviones A ON A.avion_identificador = B.AVION_IDENTIFICADOR WHERE B.AVION_IDENTIFICADOR IS NOT NULL
GROUP BY A.avion_id,B.BUTACA_NUMERO,B.BUTACA_TIPO


--Rutas
INSERT INTO EQUIPO_RAYO.Rutas(ruta_codigo,ruta_ciudad_origen,ruta_ciudad_destino)
SELECT R.RUTA_AEREA_CODIGO,R.RUTA_AEREA_CIU_ORIG,R.RUTA_AEREA_CIU_DEST FROM gd_esquema.Maestra R WHERE R.AVION_IDENTIFICADOR IS NOT NULL
GROUP BY R.RUTA_AEREA_CODIGO,R.RUTA_AEREA_CIU_ORIG,R.RUTA_AEREA_CIU_DEST


--Sucursales
INSERT INTO EQUIPO_RAYO.Sucursales(sucursal_direccion,sucursal_mail,sucursal_telefono)
SELECT S.SUCURSAL_DIR,S.SUCURSAL_MAIL,S.SUCURSAL_TELEFONO FROM gd_esquema.Maestra S WHERE S.SUCURSAL_DIR IS NOT NULL
GROUP BY S.SUCURSAL_DIR,S.SUCURSAL_MAIL,S.SUCURSAL_TELEFONO


--Tipos (de habitaciones)
INSERT INTO EQUIPO_RAYO.Tipos(tipo_codigo,tipo_descripcion)
SELECT T.TIPO_HABITACION_CODIGO,T.TIPO_HABITACION_DESC FROM gd_esquema.Maestra T WHERE HOTEL_CALLE IS NOT NULL
GROUP BY T.TIPO_HABITACION_CODIGO,T.TIPO_HABITACION_DESC


--Compras
INSERT INTO EQUIPO_RAYO.Compras(compra_numero,compra_fecha)
SELECT C.COMPRA_NUMERO,C.COMPRA_FECHA FROM gd_esquema.Maestra C
GROUP BY C.COMPRA_NUMERO,C.COMPRA_FECHA


--Vuelos
INSERT INTO EQUIPO_RAYO.Vuelos(ruta_id,avion_id,vuelo_codigo,vuelo_salida,vuelo_llegada)
SELECT R.ruta_id,A.avion_id, V.VUELO_CODIGO,V.VUELO_FECHA_SALUDA,V.VUELO_FECHA_LLEGADA FROM gd_esquema.Maestra V
	INNER JOIN EQUIPO_RAYO.Rutas R ON R.ruta_codigo = V.RUTA_AEREA_CODIGO AND R.ruta_ciudad_origen = V.RUTA_AEREA_CIU_ORIG AND R.ruta_ciudad_destino=V.RUTA_AEREA_CIU_DEST
	INNER JOIN EQUIPO_RAYO.Aviones A ON A.avion_identificador = V.AVION_IDENTIFICADOR WHERE V.AVION_IDENTIFICADOR IS NOT NULL
GROUP BY R.ruta_id,A.avion_id, V.VUELO_CODIGO,V.VUELO_FECHA_SALUDA,V.VUELO_FECHA_LLEGADA


--Pasajes 
INSERT INTO EQUIPO_RAYO.Pasajes(vuelo_id,compra_id,butaca_id,pasaje_codigo,pasaje_costo,pasaje_precio)
SELECT V.vuelo_id,C.compra_id,B.butaca_id,P.PASAJE_CODIGO,P.PASAJE_COSTO,P.PASAJE_PRECIO FROM gd_esquema.Maestra P
	INNER JOIN EQUIPO_RAYO.Vuelos V ON V.vuelo_codigo = P.VUELO_CODIGO 
	INNER JOIN EQUIPO_RAYO.Compras C ON C.compra_numero = P.COMPRA_NUMERO 
	INNER JOIN EQUIPO_RAYO.Butacas B ON B.butaca_numero = P.BUTACA_NUMERO AND B.butaca_tipo=P.BUTACA_TIPO 
	INNER JOIN EQUIPO_RAYO.Aviones A ON A.avion_id = B.avion_id AND A.avion_identificador = P.AVION_IDENTIFICADOR
		WHERE P.VUELO_CODIGO IS NOT NULL AND P.COMPRA_NUMERO IS NOT NULL AND P.BUTACA_NUMERO IS NOT NULL 
GROUP BY V.vuelo_id,C.compra_id,B.butaca_id,P.PASAJE_CODIGO,P.PASAJE_COSTO,P.PASAJE_PRECIO


--Hoteles
INSERT INTO EQUIPO_RAYO.Hoteles(empresa_id,hotel_calle,hotel_nro_calle,hotel_estrellas)
SELECT E.empresa_id,H.HOTEL_CALLE,H.HOTEL_NRO_CALLE,H.HOTEL_CANTIDAD_ESTRELLAS FROM gd_esquema.Maestra H
	INNER JOIN EQUIPO_RAYO.Empresas E ON E.empresa_razon_social = H.EMPRESA_RAZON_SOCIAL WHERE H.EMPRESA_RAZON_SOCIAL IS NOT NULL AND H.HOTEL_CALLE IS NOT NULL
GROUP BY E.empresa_id,H.HOTEL_CALLE,H.HOTEL_NRO_CALLE,H.HOTEL_CANTIDAD_ESTRELLAS

--Habitaciones
INSERT INTO EQUIPO_RAYO.Habitaciones(tipo_id,hotel_id,habitacion_numero,habitacion_piso,habitacion_frente,habitacion_costo,habitacion_precio)
SELECT T.tipo_id,
       H.hotel_id,
       Hab.HABITACION_NUMERO,
       Hab.HABITACION_PISO,
	   Hab.HABITACION_FRENTE,
	   Hab.HABITACION_COSTO,
	   Hab.HABITACION_PRECIO
 FROM gd_esquema.Maestra Hab
	INNER JOIN EQUIPO_RAYO.Tipos T ON T.tipo_codigo=Hab.TIPO_HABITACION_CODIGO AND T.tipo_descripcion=Hab.TIPO_HABITACION_DESC
	INNER JOIN EQUIPO_RAYO.Hoteles H ON H.hotel_calle = Hab.HOTEL_CALLE AND H.hotel_nro_calle=Hab.HOTEL_NRO_CALLE WHERE Hab.HOTEL_CALLE IS NOT NULL
GROUP BY T.tipo_id,H.hotel_id,Hab.HABITACION_NUMERO,hab.HABITACION_PISO,hab.HABITACION_FRENTE,hab.HABITACION_COSTO,hab.HABITACION_PRECIO

--Estadias
INSERT INTO EQUIPO_RAYO.Estadias(hotel_id,compra_id,estadia_codigo,estadia_fecha_ingreso,estadia_cant_noches)
SELECT H.hotel_id,
       C.compra_id,
       E.ESTADIA_CODIGO,
	   E.ESTADIA_FECHA_INI,
	   E.ESTADIA_CANTIDAD_NOCHES
 FROM gd_esquema.Maestra E
	INNER JOIN EQUIPO_RAYO.Compras C ON C.compra_numero = E.COMPRA_NUMERO
	INNER JOIN EQUIPO_RAYO.Hoteles H ON H.hotel_calle = E.HOTEL_CALLE AND H.hotel_nro_calle=E.HOTEL_NRO_CALLE WHERE E.HOTEL_CALLE IS NOT NULL
GROUP BY H.hotel_id,C.compra_id,E.ESTADIA_CODIGO,E.ESTADIA_FECHA_INI,E.ESTADIA_CANTIDAD_NOCHES


--Habitaciones por estadia (tabla intermedia) v1
INSERT INTO EQUIPO_RAYO.Estadias_Habitaciones(estadia_id,habitacion_id)
SELECT E.estadia_id,Hab.habitacion_id FROM gd_esquema.Maestra U
	INNER JOIN EQUIPO_RAYO.Compras C ON C.compra_numero = U.COMPRA_NUMERO
	INNER JOIN EQUIPO_RAYO.Estadias E ON E.estadia_codigo = U.ESTADIA_CODIGO AND E.compra_id = C.compra_id
	INNER JOIN EQUIPO_RAYO.Habitaciones Hab on Hab.hotel_id = E.hotel_id AND Hab.habitacion_numero = U.HABITACION_NUMERO AND Hab.habitacion_piso = U.HABITACION_PISO
	WHERE U.ESTADIA_CODIGO IS NOT NULL
GROUP BY E.estadia_id,Hab.habitacion_id

--v2 Ninguna de las dos funciona
INSERT INTO EQUIPO_RAYO.Estadias_Habitaciones(estadia_id,habitacion_id)
SELECT E.estadia_id,Hab.habitacion_id FROM EQUIPO_RAYO.Estadias E
	INNER JOIN EQUIPO_RAYO.Hoteles H ON H.hotel_id=E.hotel_id
	INNER JOIN EQUIPO_RAYO.Habitaciones Hab ON Hab.hotel_id=H.hotel_id AND Hab.hotel_id = E.hotel_id
GROUP BY E.estadia_id,Hab.habitacion_id


--Facturas
INSERT INTO EQUIPO_RAYO.Facturas(cliente_id,sucursal_id,factura_fecha,factura_numero,factura_total)
SELECT 
	   C.cliente_id,
	   S.sucursal_id,
	   F.FACTURA_FECHA,
	   F.FACTURA_NRO,
	   CASE
		WHEN
			F.HABITACION_PREC
			IO IS NULL
			THEN 
				F.PASAJE_PRECIO
		WHEN
			F.PASAJE_PRECIO IS NULL
			THEN
				F.HABITACION_PRECIO
	   END
FROM gd_esquema.Maestra F
	INNER JOIN EQUIPO_RAYO.Clientes C ON C.cliente_dni=F.CLIENTE_DNI AND C.cliente_apellido=F.CLIENTE_APELLIDO and C.cliente_mail=F.CLIENTE_MAIL
	INNER JOIN EQUIPO_RAYO.Sucursales S ON S.sucursal_direccion=F.SUCURSAL_DIR
	WHERE F.CLIENTE_APELLIDO IS NOT NULL AND F.SUCURSAL_MAIL IS NOT NULL



--ItemFacturas que son Estadias
INSERT INTO EQUIPO_RAYO.ItemFacturas(estadia_id,pasaje_id,factura_id)
SELECT E.estadia_id,NULL,F.factura_id FROM gd_esquema.Maestra U
	INNER JOIN EQUIPO_RAYO.Facturas F ON F.factura_numero=U.FACTURA_NRO
	INNER JOIN EQUIPO_RAYO.Estadias E ON E.estadia_codigo=U.ESTADIA_CODIGO
	WHERE U.FACTURA_NRO IS NOT NULL
GROUP BY E.estadia_id,F.factura_id

--Que son pasajes
INSERT INTO EQUIPO_RAYO.ItemFacturas(estadia_id,pasaje_id,factura_id)
SELECT NULL,P.pasaje_id,F.factura_id FROM gd_esquema.Maestra U
	INNER JOIN EQUIPO_RAYO.Facturas F ON F.factura_numero=U.FACTURA_NRO
	INNER JOIN EQUIPO_RAYO.Pasajes P ON P.pasaje_codigo=U.PASAJE_CODIGO
	WHERE U.FACTURA_NRO IS NOT NULL
GROUP BY P.pasaje_id,F.factura_id

