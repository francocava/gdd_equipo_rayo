USE GD1C2020;

--======Test======--

--Equipo Rayo 

SELECT * FROM EQUIPO_RAYO.Clientes --OK 

SELECT * FROM EQUIPO_RAYO.Aviones ORDER BY empresa_id --OK

SELECT * FROM EQUIPO_RAYO.Empresas --OK

SELECT * FROM EQUIPO_RAYO.Butacas --OK 
ORDER BY avion_id

SELECT ruta_id,ruta_codigo,ruta_ciudad_origen,ruta_ciudad_destino FROM EQUIPO_RAYO.Rutas --OK
ORDER BY ruta_codigo

SELECT * FROM EQUIPO_RAYO.Tipos --OK

SELECT * FROM EQUIPO_RAYO.Compras --OK

SELECT * FROM EQUIPO_RAYO.Sucursales --OK

SELECT DISTINCT vuelo_codigo FROM EQUIPO_RAYO.Vuelos -- OK!!!
SELECT vuelo_codigo,vuelo_salida,ruta_id FROM EQUIPO_RAYO.Vuelos WHERE vuelo_codigo = '7039' --OK

SELECT * FROM EQUIPO_RAYO.Pasajes --OK!!
SELECT * FROM EQUIPO_RAYO.Hoteles -- OK

SELECT * FROM EQUIPO_RAYO.Habitaciones --OK
ORDER BY hotel_id

SELECT * FROM EQUIPO_RAYO.Estadias --OK

SELECT * FROM EQUIPO_RAYO.Estadias_Habitaciones
ORDER BY estadia_id

SELECT * FROM EQUIPO_RAYO.Facturas --OK 

--====Tabla maestra

SELECT DISTINCT CLIENTE_DNI,CLIENTE_MAIL FROM gd_esquema.Maestra WHERE CLIENTE_DNI IS NOT NULL --237522 clientes diferentes

SELECT DISTINCT EMPRESA_RAZON_SOCIAL FROM gd_esquema.Maestra --22 empresas diferentes

SELECT DISTINCT AVION_IDENTIFICADOR,AVION_MODELO FROM gd_esquema.Maestra WHERE AVION_IDENTIFICADOR IS NOT NULL --33 Aviones diferentes

SELECT DISTINCT BUTACA_NUMERO,BUTACA_TIPO,AVION_IDENTIFICADOR FROM gd_esquema.Maestra WHERE AVION_IDENTIFICADOR IS NOT NULL --2034 butacas totales
ORDER BY AVION_IDENTIFICADOR,BUTACA_NUMERO

SELECT DISTINCT RUTA_AEREA_CODIGO,RUTA_AEREA_CIU_DEST,RUTA_AEREA_CIU_ORIG FROM gd_esquema.Maestra WHERE RUTA_AEREA_CIU_ORIG IS NOT NULL --74 Rutas diferentes hay rutas que tienen el mismo codigo pero diferentes lugares 
ORDER BY RUTA_AEREA_CODIGO																												-- Puede que sea uno de los errores

SELECT DISTINCT TIPO_HABITACION_CODIGO,TIPO_HABITACION_DESC FROM gd_esquema.Maestra --5 Tipos diferentes

SELECT DISTINCT COMPRA_NUMERO FROM gd_esquema.Maestra --Hay 20438 compras diferentes

SELECT DISTINCT SUCURSAL_DIR,SUCURSAL_MAIL FROM gd_esquema.Maestra --6 Sucursales diferentes (hay un null)

SELECT DISTINCT VUELO_CODIGO,RUTA_AEREA_CIU_ORIG,RUTA_AEREA_CIU_DEST FROM gd_esquema.Maestra WHERE VUELO_CODIGO IS NOT NULL --4750 Vuelos diferentes
SELECT VUELO_CODIGO,VUELO_FECHA_SALUDA , AVION_IDENTIFICADOR,RUTA_AEREA_CODIGO,CLIENTE_DNI FROM gd_esquema.Maestra WHERE VUELO_CODIGO='7039' AND CLIENTE_DNI IS NOT NULL
 --Devuelve 63 veces el mismo vuelo, cada entrada es un cliente diferente. 

SELECT DISTINCT PASAJE_CODIGO FROM gd_esquema.Maestra WHERE PASAJE_CODIGO IS NOT NULL --Pasajes 282403 diferentes (el pasaje existe aunque no haya sido vendido)
																					  --tendra null el cliente 

SELECT VUELO_CODIGO FROM gd_esquema.Maestra WHERE VUELO_CODIGO IS NOT NULL --504237 operaciones con vuelos
SELECT HOTEL_CALLE,HOTEL_NRO_CALLE FROM gd_esquema.Maestra WHERE HOTEL_CALLE IS NOT NULL --31376 operaciones con hoteles
SELECT * FROM gd_esquema.Maestra --535613 total de operaciones entre los dos

SELECT count(*) FROM gd_esquema.Maestra WHERE HABITACION_FRENTE IS NOT NULL -- devuelve 31376 Estadias_Habitaciones tiene que devolver este numero tambien

SELECT DISTINCT HABITACION_FRENTE,HABITACION_NUMERO,HABITACION_PISO,HOTEL_NRO_CALLE,HOTEL_CALLE FROM gd_esquema.Maestra
WHERE HOTEL_CALLE IS NOT NULL
ORDER BY HOTEL_CALLE --Hay 424 habitaciones diferentes en total 

SELECT DISTINCT HOTEL_CALLE,HOTEL_NRO_CALLE FROM gd_esquema.Maestra WHERE HOTEL_CALLE IS NOT NULL --Hay 20 hoteles diferentes

SELECT DISTINCT ESTADIA_CODIGO,ESTADIA_CANTIDAD_NOCHES,ESTADIA_FECHA_INI FROM gd_esquema.Maestra WHERE ESTADIA_CODIGO IS NOT NULL -- Hay 15688 estadias diferentes



SELECT DISTINCT COMPRA_NUMERO FROM gd_esquema.Maestra WHERE HOTEL_CALLE IS NOT NULL --15688 Compras que son estadias diferentes
SELECT DISTINCT COMPRA_NUMERO FROM gd_esquema.Maestra WHERE VUELO_CODIGO IS NOT NULL --4750 Compras que son pasajes 

SELECT FACTURA_NRO,CLIENTE_DNI,CLIENTE_APELLIDO FROM gd_esquema.Maestra WHERE CLIENTE_APELLIDO IS NOT NULL --237522
SELECT DISTINCT FACTURA_NRO,CLIENTE_DNI,CLIENTE_APELLIDO FROM gd_esquema.Maestra WHERE CLIENTE_APELLIDO IS NOT NULL --Da lo mismo que arriba por lo tanto 
																													--una factura tiene 1 solo item 
