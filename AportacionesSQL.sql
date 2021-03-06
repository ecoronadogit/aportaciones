CREATE DATABASE APORTACIONES
--
CREATE TABLE LOGIN_ACCESO(
USUARIO NVARCHAR(127) NOT NULL,
CONTRASENA NVARCHAR(127) NOT NULL
)
-- 
INSERT INTO LOGIN_ACCESO VALUES('ADMIN','123456'),('OPERADOR','12345')
GO
--
CREATE TABLE SOCIO(
CODIGO_SOCIO INT IDENTITY(1,1) NOT NULL,
TIPO_DOCUMENTO NVARCHAR(127) NOT NULL,
NUMERO_DOCUMENTO NVARCHAR(127) UNIQUE NOT NULL,
NOMBRE NVARCHAR(127) NOT NULL,
DIRECCION NVARCHAR(127) NOT NULL,
DEPARTAMENTO NVARCHAR(127) NOT NULL,
PROVINCIA NVARCHAR(127) NOT NULL,
DISTRITO NVARCHAR(127) NOT NULL,
TELEFONO NVARCHAR(127) NOT NULL,
CORREO NVARCHAR(127) NOT NULL
CONSTRAINT PK_SOCIO PRIMARY KEY CLUSTERED (CODIGO_SOCIO)
)
--
CREATE TABLE CUENTA_CORRIENTE(
CODIGO_SOCIO INT NOT NULL,
FECHA DATE NOT NULL,
CONCEPTO NVARCHAR(127) NOT NULL,
CARGO DECIMAL(10,2) NULL,
ABONO DECIMAL(10,2) NULL,
TIPO_ABONO NVARCHAR(127) NULL,
ENTIDAD_FINANCIERA NVARCHAR(127) NULL,
NUMERO_OPERACION NVARCHAR(127) NULL
CONSTRAINT FK_SOCIO FOREIGN KEY(CODIGO_SOCIO) REFERENCES SOCIO(CODIGO_SOCIO)
)
GO
-- ------------------------------------------------------------------------------------------------
CREATE PROCEDURE sp_verificar_login   
    @Usuario NVARCHAR(127),   
    @Contrasena NVARCHAR(127),
	@Valido INT OUTPUT   
AS   
BEGIN    
    SELECT @Valido=COUNT(*) FROM LOGIN_ACCESO WHERE USUARIO=@Usuario AND CONTRASENA=@Contrasena     
END
GO
-- ------------------------------------------------------------------------------------------------
CREATE PROCEDURE sp_verificar_socio   
    @NumeroDocumento NVARCHAR(127),       
	@CodigoSocio INT OUTPUT   
AS   
BEGIN    
    SELECT @CodigoSocio=CODIGO_SOCIO FROM SOCIO WHERE NUMERO_DOCUMENTO=@NumeroDocumento
END
GO
--
CREATE PROCEDURE sp_registrar_socio   
    @TipoDocumento NVARCHAR(127),@NumeroDocumento NVARCHAR(127),@Nombre NVARCHAR(127),@Direccion NVARCHAR(127),      
	@Departamento NVARCHAR(127),@Provincia NVARCHAR(127),@Distrito NVARCHAR(127),@Telefono NVARCHAR(127),@Correo NVARCHAR(127)  
AS   
BEGIN    
	INSERT INTO SOCIO ([TIPO_DOCUMENTO],[NUMERO_DOCUMENTO],[NOMBRE],[DIRECCION],[DEPARTAMENTO],[PROVINCIA],[DISTRITO],[TELEFONO],[CORREO])
	VALUES (@TipoDocumento,@NumeroDocumento,@Nombre,@Direccion,@Departamento,@Provincia,@Distrito,@Telefono,@Correo)    
END
GO
--
CREATE PROCEDURE sp_buscar_socios_todos       
AS   
BEGIN    
    SELECT [CODIGO_SOCIO],[TIPO_DOCUMENTO],[NUMERO_DOCUMENTO],[NOMBRE],[DIRECCION],[DEPARTAMENTO],[PROVINCIA],[DISTRITO],[TELEFONO],[CORREO] FROM SOCIO
END
GO
--
CREATE PROCEDURE sp_buscar_socios_departamento  
	@Departamento NVARCHAR(127)   
AS   
BEGIN    
    SELECT [CODIGO_SOCIO],[TIPO_DOCUMENTO],[NUMERO_DOCUMENTO],[NOMBRE],[DIRECCION],[DEPARTAMENTO],[PROVINCIA],[DISTRITO],[TELEFONO],[CORREO] FROM SOCIO
	WHERE [DEPARTAMENTO]=@Departamento
END
GO
--
CREATE PROCEDURE sp_buscar_socios_provincia 
	@Provincia NVARCHAR(127)   
AS   
BEGIN    
    SELECT [CODIGO_SOCIO],[TIPO_DOCUMENTO],[NUMERO_DOCUMENTO],[NOMBRE],[DIRECCION],[DEPARTAMENTO],[PROVINCIA],[DISTRITO],[TELEFONO],[CORREO] FROM SOCIO
	WHERE [PROVINCIA]=@Provincia
END
GO
--
CREATE PROCEDURE sp_buscar_socios_distrito 
	@Distrito NVARCHAR(127)   
AS   
BEGIN    
    SELECT [CODIGO_SOCIO],[TIPO_DOCUMENTO],[NUMERO_DOCUMENTO],[NOMBRE],[DIRECCION],[DEPARTAMENTO],[PROVINCIA],[DISTRITO],[TELEFONO],[CORREO] FROM SOCIO
	WHERE [DISTRITO]=@Distrito
END
GO
--
CREATE PROCEDURE sp_existe_socio   
    @CodigoSocio INT,  
	@Valido INT OUTPUT   
AS   
BEGIN    
    SELECT @Valido=COUNT(*) FROM SOCIO WHERE CODIGO_SOCIO=@CodigoSocio
END
GO
-- ------------------------------------------------------------------------------------------------
CREATE PROCEDURE sp_registrar_abono   
    @CodigoSocio INT,@Fecha DATE,@Concepto NVARCHAR(127),@Abono DECIMAL(10,2),      
	@TipoAbono NVARCHAR(127),@EntidadFinanciera NVARCHAR(127),@NumeroOperacion NVARCHAR(127)
AS   
BEGIN    
	INSERT INTO CUENTA_CORRIENTE([CODIGO_SOCIO],[FECHA],[CONCEPTO],[ABONO],[TIPO_ABONO],[ENTIDAD_FINANCIERA],[NUMERO_OPERACION])
	VALUES (@CodigoSocio,@Fecha,@Concepto,@Abono,@TipoAbono,@EntidadFinanciera,@NumeroOperacion)    
END
GO
--
CREATE PROCEDURE sp_registrar_cargo   
    @CodigoSocio INT,@Fecha DATE,@Concepto NVARCHAR(127),@Cargo DECIMAL(10,2)
AS   
BEGIN    
	INSERT INTO CUENTA_CORRIENTE([CODIGO_SOCIO],[FECHA],[CONCEPTO],[CARGO])
	VALUES (@CodigoSocio,@Fecha,@Concepto,@Cargo)    
END
GO
-- 
CREATE PROCEDURE sp_detalle_cuenta   
    @CodigoSocio INT 
AS   
BEGIN    
    SELECT FECHA,CONCEPTO,
	(CASE WHEN CARGO IS NULL THEN '' ELSE CONVERT(NVARCHAR(127),CARGO) END) AS 'CARGO',
	(CASE WHEN ABONO IS NULL THEN '' ELSE CONVERT(NVARCHAR(127),ABONO) END) AS 'ABONO',
	SUM(ISNULL(ABONO,0)-ISNULL(CARGO,0)) OVER(ORDER BY FECHA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 'SALDO'
	FROM CUENTA_CORRIENTE WHERE CODIGO_SOCIO=@CodigoSocio
END
GO
-- 
CREATE PROCEDURE sp_saldo_cuenta   
    @CodigoSocio INT 
AS   
BEGIN    
    SELECT CONVERT(NVARCHAR(127),SUM(ISNULL(ABONO,0)-ISNULL(CARGO,0))) AS 'SALDO' 
	FROM CUENTA_CORRIENTE WHERE CODIGO_SOCIO=@CodigoSocio GROUP BY CODIGO_SOCIO
END
GO
-- 
CREATE PROCEDURE sp_nombre_socio   
    @CodigoSocio INT 
AS   
BEGIN    
    SELECT NOMBRE FROM SOCIO WHERE CODIGO_SOCIO=@CodigoSocio
END
GO
-- ------------------------------------------------------------------------------------------------