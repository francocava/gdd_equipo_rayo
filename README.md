# Migración de datos y modelo BI
Trabajo práctico en **TSQL** para gestion de datos 1C 2020 UTN FRBA.

## Contexto
Se presenta una base de datos de un sitio de venta de pasajes y estadias la cual ya se encuentra poblada de datos.
Estos se encuentran en una tabla maestra. 
El trabajo consiste en realizar una migración a un modelo mas performante el cual separe los datos en diferentes tablas.
Luego se creara utilizando los conceptos de Business Intelligence un modelo STAR para poder procesar los datos a partir de
dimensiones y generar informacion relevante para el usuario. 

## Migración
Se parte de una única tabla maestra que contiene todos los datos y se termina en un modelo con varias tablas separando los
datos según corresponda. 
*Modelo final:*
![DER_TP](https://user-images.githubusercontent.com/43447255/93411708-27728c00-f872-11ea-9bc0-962b232a2695.png)

## Business Intelligence
Creamos un nuevo modelo STAR en el cual todas las dimensiones se relacionan con una tabla de hechos.

*Modelo Star:*
![DER_BI](https://user-images.githubusercontent.com/43447255/93412178-065e6b00-f873-11ea-88cd-248b0548faf3.png)


### Contacto
*francocavallini@hotmail.com*
