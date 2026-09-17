-- Ejercicio 8: Alterar tabla Facturas y crear trigger Recargo_factura

-- Incorporamos las nuevas columnas a la tabla Facturas del ejercicio 5
ALTER TABLE Facturas
ADD 
    Fecha_vto DATE,
    Fecha_pago DATE,
    intereses INT;
GO

-- Creamos el trigger Recargo_factura que detecta pagos fuera de término.
-- Se dispara al hacer un UPDATE en la tabla Facturas.
CREATE TRIGGER Recargo_factura
ON Facturas
AFTER UPDATE
AS
BEGIN
    -- Verificamos si la columna que se actualizó específicamente fue la fecha de pago
    IF UPDATE(Fecha_pago)
    BEGIN
        -- Actualizamos el interés a 5 si pagó después del vencimiento
        UPDATE f
        SET f.intereses = 5
        FROM Facturas f
        JOIN inserted i ON f.nro_factura = i.nro_factura
        WHERE i.Fecha_pago > i.Fecha_vto;
    END
END;
GO
