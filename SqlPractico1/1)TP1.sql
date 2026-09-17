-- Ejercicio 1: Creación de tabla Empleados y triggers Control_sueldo y Adicional_cargo

-- Se crea la tabla Importes_basicos para almacenar el importe base según el cargo.
CREATE TABLE Importes_basicos (
    cargo INT PRIMARY KEY,
    importe_basico DECIMAL(10,2)
);
GO

-- Se crea la tabla Empleados con sus respectivas restricciones: DNI positivo, legajo único, y límites para cargo y sueldo.
CREATE TABLE Empleados (
    DNI_Empleado INT PRIMARY KEY CHECK (DNI_Empleado > 0),
    Legajo INT UNIQUE,
    Apellido_Nombres VARCHAR(100),
    Cargo INT CHECK (Cargo BETWEEN 50 AND 120),
    Sueldo DECIMAL(10,2) CHECK (Sueldo <= 450000)
);
GO

-- Este trigger evita que, al modificar el sueldo de un empleado, el nuevo monto supere en más de un 20% al sueldo anterior.
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

-- Este trigger detecta si a un empleado se le asigna o actualiza su cargo al valor 90. 
-- De ser así, le asigna automáticamente como sueldo el importe básico de ese cargo + 15%.
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
