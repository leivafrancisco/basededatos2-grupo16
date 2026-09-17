-- Ejercicio 9: Trigger Importe_recargo

-- Este trigger se dispara cuando se actualiza la columna intereses de la tabla Facturas.
-- Toma el importe original de la factura y le suma el recargo correspondiente a los intereses.
CREATE TRIGGER Importe_recargo
ON Facturas
AFTER UPDATE
AS
BEGIN
    -- Evitamos recursividad infinita (ya que actualizaremos la misma tabla)
    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    -- Solo procesamos si la columna que se actualizó fue efectivamente 'intereses'
    IF UPDATE(intereses)
    BEGIN
        UPDATE f
        -- Importe de la factura = Importe de la factura + (Importe de la factura * intereses / 100)
        SET f.importe_factura = f.importe_factura + (f.importe_factura * i.intereses / 100.0)
        FROM Facturas f
        JOIN inserted i ON f.nro_factura = i.nro_factura
        WHERE i.intereses > 0;
    END
END;
GO
