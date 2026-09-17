-- Ejercicio 3: Creación de tabla Pedidos y trigger Control_pedido

-- Se asume que ya existen las tablas Clientes y Stock_productos.

-- Se crea la tabla Pedidos con clave primaria compuesta, clave foránea, valor por defecto y comprobaciones.
CREATE TABLE Pedidos (
    Nro_orden_pedido INT UNIQUE,
    Fecha_orden_pedido DATE DEFAULT GETDATE(),
    CUIT_cliente VARCHAR(20) FOREIGN KEY REFERENCES Clientes(Cuit),
    CUIT_proveedor VARCHAR(20),
    nro_producto INT,
    tipo_pedido CHAR(1) CHECK (tipo_pedido IN ('M', 'C', 'G', 'H', 'N')),
    Cantidad_pedida INT CHECK (Cantidad_pedida > 0),
    
    -- Clave primaria compuesta por CUIT del cliente y Nro de orden
    PRIMARY KEY (CUIT_cliente, Nro_orden_pedido)
);
GO

-- Dado que SQL Server no tiene triggers "BEFORE", utilizamos un trigger "AFTER INSERT".
-- Validaremos el stock: si no alcanza, revertimos la transacción (simulando un BEFORE).
-- Si el stock alcanza, procedemos a descontarlo.
CREATE TRIGGER Control_pedido
ON Pedidos
AFTER INSERT
AS
BEGIN
    -- 1. Verificamos si alguna fila insertada intenta pedir más del stock disponible.
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Stock_productos sp ON i.nro_producto = sp.numero_producto
        WHERE i.Cantidad_pedida > sp.stock_actual
    )
    BEGIN
        -- Si excede el stock, lanzamos un error y deshacemos la operación (el pedido no se guarda).
        RAISERROR ('Error: La cantidad pedida supera el stock actual disponible.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN; -- Salimos del trigger
    END

    -- 2. Si pasamos la validación anterior, significa que hay stock suficiente.
    -- Procedemos a restar la cantidad pedida del stock actual.
    UPDATE sp
    SET sp.stock_actual = sp.stock_actual - i.Cantidad_pedida
    FROM Stock_productos sp
    JOIN inserted i ON sp.numero_producto = i.nro_producto;
END;
GO
