-- Ejercicio 1: Creación de tabla Empleados y triggers Control_sueldo y Adicional_cargo

CREATE TABLE Empleados (
    DNI_Empleado INT PRIMARY KEY CHECK (DNI_Empleado > 0),
    Legajo INT UNIQUE,
    Apellido_Nombres VARCHAR(100),
    Cargo INT CHECK (Cargo BETWEEN 50 AND 120),
    Sueldo DECIMAL(10,2) CHECK (Sueldo <= 450000)
);
GO

CREATE TRIGGER Control_sueldo
ON Empleados
FOR UPDATE
AS
BEGIN
    IF UPDATE(Sueldo)
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM inserted i
            JOIN deleted d ON i.DNI_Empleado = d.DNI_Empleado
            WHERE i.Sueldo > (d.Sueldo * 1.20)
        )
        BEGIN
            RAISERROR ('Error: No se permite incrementar el sueldo en más de un 20%.', 16, 1);
            ROLLBACK TRANSACTION;
        END
    END
END;
GO

CREATE TRIGGER Adicional_cargo
ON Empleados
AFTER INSERT, UPDATE
AS
BEGIN
    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    IF UPDATE(Cargo)
    BEGIN
        UPDATE e
        SET e.Sueldo = ib.importe_basico * 1.15
        FROM Empleados e
        JOIN inserted i ON e.DNI_Empleado = i.DNI_Empleado
        JOIN Importes_basicos ib ON ib.cargo = i.cargo
        WHERE i.Cargo = 90;
    END
END;
GO
