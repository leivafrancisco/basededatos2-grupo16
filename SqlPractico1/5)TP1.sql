-- Ejercicio 5: Creación de tablas Clientes y Facturas y trigger Calcular_importe_factura

-- Se asume que la tabla CodPostales ya existe.

-- Creación de la tabla Clientes. 
-- El "dominio" de entero de 9 dígitos > 0 se simula con un CHECK (muy común en SQL Server)
CREATE TABLE Clientes (
    codigo_cliente INT PRIMARY KEY CHECK (codigo_cliente > 0 AND codigo_cliente <= 999999999),
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(150) NOT NULL,
    codigo_postal INT FOREIGN KEY REFERENCES CodPostales(cod_postal),
    importe_base DECIMAL(12,2) NOT NULL
);
GO

-- Creación de la tabla Facturas
CREATE TABLE Facturas (
    nro_factura INT PRIMARY KEY,
    fecha_factura DATE,
    codigo_cliente INT FOREIGN KEY REFERENCES Clientes(codigo_cliente),
    tipo_descuento INT CHECK (tipo_descuento BETWEEN 5 AND 20),
    valor_iva INT CHECK (valor_iva IN (15, 21)),
    importe_factura DECIMAL(12,2) NOT NULL
);
GO

-- NOTA SOBRE EL TRIGGER: 
-- El enunciado pide que se dispare ante un INSERT de una tupla (aparentemente de Facturas) 
-- o ante un UPDATE del importe base en la tabla Clientes. 
-- Dado que en SQL Server un trigger solo puede pertenecer a UNA tabla, 
-- crearemos dos triggers separados para cubrir ambos eventos de manera correcta.

-- Trigger 1: Se dispara al insertar una nueva Factura. 
-- Calcula el importe basado en el cliente asignado.
CREATE TRIGGER Calcular_importe_factura_INSERT
ON Facturas
AFTER INSERT
AS
BEGIN
    UPDATE f
    SET f.importe_factura = 
        (c.importe_base - (c.importe_base * i.tipo_descuento / 100.0)) -- Se aplica el descuento
        * (1.0 + (i.valor_iva / 100.0))                                -- Se aplica el IVA al resultado
    FROM Facturas f
    JOIN inserted i ON f.nro_factura = i.nro_factura
    JOIN Clientes c ON i.codigo_cliente = c.codigo_cliente;
END;
GO

-- Trigger 2: Se dispara al actualizar el importe base de un Cliente.
-- Recalcula los importes de todas sus facturas existentes.
CREATE TRIGGER Calcular_importe_factura_UPDATE
ON Clientes
AFTER UPDATE
AS
BEGIN
    -- Solo procesamos si se modificó el importe base
    IF UPDATE(importe_base)
    BEGIN
        UPDATE f
        SET f.importe_factura = 
            (i.importe_base - (i.importe_base * f.tipo_descuento / 100.0)) 
            * (1.0 + (f.valor_iva / 100.0))
        FROM Facturas f
        JOIN inserted i ON f.codigo_cliente = i.codigo_cliente;
    END
END;
GO
