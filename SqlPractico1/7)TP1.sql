-- Ejercicio 7: Modificar trigger y comandos para desactivar triggers

-- Modificamos el trigger Baja_usuario para que ahora elimine por Legajo en lugar de DNI.
-- NOTA: En SQL Server el comando equivalente a "REPLACE TRIGGER" es "ALTER TRIGGER" 
-- (o "CREATE OR ALTER TRIGGER" en versiones modernas).
ALTER TRIGGER Baja_usuario
ON Empleados
AFTER DELETE
AS
BEGIN
    DELETE FROM Usuarios
    WHERE Legajo IN (SELECT Legajo FROM deleted);
END;
GO

-- Indicar los comandos Sql necesarios para desactivar el trigger Calcular_importe:
-- Como en el Ejercicio 5 creamos dos triggers para manejar esa lógica en SQL Server, 
-- aquí desactivamos ambos indicando en qué tabla se encuentran.
DISABLE TRIGGER Calcular_importe_factura_INSERT ON Facturas;
DISABLE TRIGGER Calcular_importe_factura_UPDATE ON Clientes;
GO

-- Comando para desactivar todos los triggers que estén asociados a la tabla Consumos:
DISABLE TRIGGER ALL ON Consumos;
GO
