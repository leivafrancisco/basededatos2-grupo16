-- Ejercicio 6: Tabla Empleados_baja y triggers de eliminación

-- Creamos la tabla Empleados_baja para mantener el histórico
CREATE TABLE Empleados_baja (
    DNI_Empleado INT,
    Legajo INT,
    Cargo INT,
    Usuario VARCHAR(100),
    Fecha DATE
);
GO

-- Trigger Empleado_eliminado: Guarda el histórico cuando se borra un empleado.
-- Utilizamos SYSTEM_USER y GETDATE() que son las equivalentes en SQL Server a USER y SYSDATE.
CREATE TRIGGER Empleado_eliminado
ON Empleados
AFTER DELETE
AS
BEGIN
    INSERT INTO Empleados_baja (DNI_Empleado, Legajo, Cargo, Usuario, Fecha)
    SELECT 
        d.DNI_Empleado, 
        d.Legajo, 
        d.Cargo, 
        SYSTEM_USER, 
        GETDATE()    
    FROM deleted d;
END;
GO

-- Trigger Baja_usuario: Elimina el registro asociado en la tabla Usuarios (por DNI)
-- Se asume que la tabla Usuarios existe y tiene un campo DNI.
CREATE TRIGGER Baja_usuario
ON Empleados
AFTER DELETE
AS
BEGIN
    DELETE u
    FROM Usuarios u
    JOIN deleted d ON u.DNI = d.DNI_Empleado;
END;
GO
