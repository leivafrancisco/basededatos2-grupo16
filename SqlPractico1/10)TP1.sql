-- Ejercicio 10: Tabla Cursadas y trigger Condicion_alumno

-- Asumimos que la tabla Plan_Carreras ya existe.

-- Creamos la tabla Cursadas con sus atributos y comprobaciones
CREATE TABLE Cursadas (
    DNI INT PRIMARY KEY,
    Cod_carrera INT,
    Cod_materia INT,
    Ano_cursado INT NOT NULL,
    Condicion CHAR(1) CHECK (Condicion IN ('R', 'P', 'D')),
    -- Utilizamos tipo INT para notas exactas según el texto (6, 7, etc)
    Nota_final INT CHECK (Nota_final BETWEEN 0 AND 10),
    
    -- Restricción de clave foránea compuesta
    CONSTRAINT Control_Materia FOREIGN KEY (Cod_carrera, Cod_materia) 
    REFERENCES Plan_Carreras(Cod_carrera, Cod_materia)
);
GO

-- Creamos el trigger Condicion_alumno para calcular la condición automáticamente
CREATE TRIGGER Condicion_alumno
ON Cursadas
AFTER INSERT, UPDATE
AS
BEGIN
    -- Prevenimos recursividad ya que actualizaremos la propia tabla Cursadas
    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    -- Procesamos solo si la nota final ha sido insertada o modificada
    IF UPDATE(Nota_final)
    BEGIN
        UPDATE c
        SET c.Condicion = 
            CASE 
                WHEN i.Nota_final >= 7 THEN 'P'  -- Promocionó
                WHEN i.Nota_final = 6 THEN 'R'   -- Regularizó
                WHEN i.Nota_final < 6 THEN 'D'   -- Desaprobó
            END
        FROM Cursadas c
        JOIN inserted i ON c.DNI = i.DNI;
    END
END;
GO
