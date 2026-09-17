-- Ejercicio 2: Creación de tabla Seguros_autos y trigger Facturas_mensuales

-- Se asume que las tablas Clientes, Vehículos y Cuotas_Seguros ya existen o se crearán aparte.

-- Se crea la tabla Seguros_autos con sus claves, valores por defecto y comprobaciones.
CREATE TABLE Seguros_autos (
    Nro_Poliza INT PRIMARY KEY,
    DNI_Cliente INT FOREIGN KEY REFERENCES Clientes(DNI),
    Marca_vehiculo VARCHAR(50) CHECK (Marca_vehiculo IN ('Ford', 'Renault', 'Fiat', 'Peugeot', 'VW', 'Toyota', 'Nissan')),
    Ano_modelo INT DEFAULT 2022,
    Nro_patente VARCHAR(20),
    Nro_motor VARCHAR(50),
    Periodo INT, -- Ejemplo: 202401
    Importe_pagar DECIMAL(10,2) NOT NULL,
    
    -- Clave foránea compuesta hacia Vehículos
    FOREIGN KEY (Marca_vehiculo, Ano_modelo) REFERENCES Vehiculos(marca, ano_modelo)
);
GO

-- Este trigger se dispara al insertar un nuevo seguro de auto. 
-- Su objetivo es generar automáticamente las 3 cuotas mensuales del primer trimestre.
CREATE TRIGGER Facturas_mensuales
ON Seguros_autos
AFTER INSERT
AS
BEGIN
    -- Cuota 1 (Mes 01 - Enero)
    INSERT INTO Cuotas_Seguros (Nro_comprobante, Monto_facturado, Fecha_pago)
    SELECT 
        CAST(Nro_Poliza AS VARCHAR) + CAST(Periodo AS VARCHAR) + '01',
        Importe_pagar / 3.0,
        '2024-01-15' -- Formato de fecha YYYY-MM-DD estándar en SQL
    FROM inserted;

    -- Cuota 2 (Mes 02 - Febrero)
    INSERT INTO Cuotas_Seguros (Nro_comprobante, Monto_facturado, Fecha_pago)
    SELECT 
        CAST(Nro_Poliza AS VARCHAR) + CAST(Periodo AS VARCHAR) + '02',
        Importe_pagar / 3.0,
        '2024-02-15'
    FROM inserted;

    -- Cuota 3 (Mes 03 - Marzo)
    INSERT INTO Cuotas_Seguros (Nro_comprobante, Monto_facturado, Fecha_pago)
    SELECT 
        CAST(Nro_Poliza AS VARCHAR) + CAST(Periodo AS VARCHAR) + '03',
        Importe_pagar / 3.0,
        '2024-03-15'
    FROM inserted;
END;
GO
