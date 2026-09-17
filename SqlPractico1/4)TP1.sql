-- Ejercicio 4: Agregar restricciones a las tablas Pedidos y Stock_productos del ejercicio 3

-- Agrega restricción de Clave Foránea (ClaveProducto) referenciando a la tabla Productos
ALTER TABLE Pedidos
ADD CONSTRAINT ClaveProducto FOREIGN KEY (nro_producto, tipo_pedido)
REFERENCES Productos (nro_producto, tipo_pedido);
GO

-- Agrega restricción (CantidadPermitida) para que la cantidad pedida solo acepte valores entre 10 y 2000
ALTER TABLE Pedidos
ADD CONSTRAINT CantidadPermitida CHECK (Cantidad_pedida BETWEEN 10 AND 2000);
GO

-- Agrega restricción (ControlCUIT) para evitar que el CUIT del cliente y proveedor sean iguales. 
-- El comando "WITH NOCHECK" se utiliza para deshabilitar la comprobación en los registros ya existentes.
ALTER TABLE Pedidos WITH NOCHECK
ADD CONSTRAINT ControlCUIT CHECK (CUIT_cliente <> CUIT_proveedor);
GO

-- Agrega restricción (ControlStock) a Stock_productos para que el stock actual nunca sea inferior al mínimo
ALTER TABLE Stock_productos
ADD CONSTRAINT ControlStock CHECK (stock_actual >= stock_minimo);
GO
