-- Script para crear y poblar la base de datos para la Prueba 3
-- Ejecutar en Oracle SQL Developer en el esquema del estudiante

SET SERVEROUTPUT ON;

-- Eliminar tablas si ya existen
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Asignaciones CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Incidentes CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Agentes CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Crear tabla Agentes
CREATE TABLE Agentes (
    AgenteID     NUMBER PRIMARY KEY,
    Nombre       VARCHAR2(50),
    Especialidad VARCHAR2(50),
    FechaIngreso DATE
);

-- Crear tabla Incidentes
CREATE TABLE Incidentes (
    IncidenteID    NUMBER PRIMARY KEY,
    Descripcion    VARCHAR2(100),
    Severidad      VARCHAR2(20),
    Estado         VARCHAR2(20),
    FechaDeteccion DATE
);

-- Crear tabla Asignaciones
CREATE TABLE Asignaciones (
    AsignacionID NUMBER PRIMARY KEY,
    AgenteID     NUMBER,
    IncidenteID  NUMBER,
    Horas        NUMBER,
    Rol          VARCHAR2(30),
    CONSTRAINT fk_asig_agente    FOREIGN KEY (AgenteID)    REFERENCES Agentes(AgenteID),
    CONSTRAINT fk_asig_incidente FOREIGN KEY (IncidenteID) REFERENCES Incidentes(IncidenteID)
);

-- Insertar datos en Agentes
INSERT INTO Agentes VALUES (101, 'Camila Reyes',     'Pentester',       TO_DATE('2023-03-15','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (102, 'Diego Muñoz',      'Analista SOC',    TO_DATE('2022-07-01','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (103, 'Valentina Soto',   'Analista SOC',    TO_DATE('2024-01-10','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (104, 'Matías Fernández', 'Forense Digital', TO_DATE('2021-11-20','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (105, 'Francisca López',  'Pentester',       TO_DATE('2023-08-05','YYYY-MM-DD'));

-- Insertar datos en Incidentes
INSERT INTO Incidentes VALUES (201, 'Ransomware LockBit en servidor de archivos', 'Critical', 'Abierto',  TO_DATE('2026-03-01','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (202, 'Campaña de Phishing dirigida a RRHH',        'High',     'Abierto',  TO_DATE('2026-03-03','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (203, 'DDoS en portal web institucional',            'High',     'Cerrado',  TO_DATE('2026-03-20','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (204, 'SQL Injection en API de pagos',               'Critical', 'Abierto',  TO_DATE('2026-04-05','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (205, 'Exfiltración de datos via DNS tunneling',     'Medium',   'Cerrado',  TO_DATE('2026-04-10','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (206, 'Acceso no autorizado a base de datos',        'Critical', 'Abierto',  TO_DATE('2026-05-02','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (207, 'Malware en estaciones de trabajo',            'Medium',   'Cerrado',  TO_DATE('2026-05-15','YYYY-MM-DD'));

-- Insertar datos en Asignaciones
INSERT INTO Asignaciones VALUES (1,  101, 201, 40, 'Lider');
INSERT INTO Asignaciones VALUES (2,  102, 201, 35, 'Apoyo');
INSERT INTO Asignaciones VALUES (3,  102, 202, 20, 'Lider');
INSERT INTO Asignaciones VALUES (4,  103, 202, 25, 'Apoyo');
INSERT INTO Asignaciones VALUES (5,  103, 203, 30, 'Lider');
INSERT INTO Asignaciones VALUES (6,  104, 204, 45, 'Lider');
INSERT INTO Asignaciones VALUES (7,  101, 204, 35, 'Apoyo');
INSERT INTO Asignaciones VALUES (8,  105, 205, 25, 'Lider');
INSERT INTO Asignaciones VALUES (9,  104, 201, 20, 'Apoyo');
INSERT INTO Asignaciones VALUES (10, 102, 206, 50, 'Lider');
INSERT INTO Asignaciones VALUES (11, 105, 206, 30, 'Apoyo');
INSERT INTO Asignaciones VALUES (12, 103, 207, 15, 'Lider');

COMMIT;

SELECT 'Tablas creadas y datos insertados correctamente.' AS mensaje FROM dual;

SELECT * FROM Agentes;
SELECT * FROM Incidentes;
SELECT * FROM Asignaciones;

/*
================================================================================
PRUEBA 3 - TÓPICOS AVANZADOS DE BASES DE DATOS
================================================================================

INSTRUCCIONES GENERALES:
- Tiempo: 90 minutos
- Puntaje total: 100 puntos
- Parte 1 (teórica): 40 puntos | Parte 2 (práctica): 60 puntos
- Ejecute el script de datos antes de comenzar la parte práctica
- En la parte teórica, la lógica y el concepto son lo que se evalúa;
  errores menores de sintaxis no penalizan si la idea es correcta

================================================================================
PARTE 1 - PREGUNTAS TEÓRICAS (40 puntos, 10 puntos cada una)
================================================================================

PREGUNTA 1 (10 puntos)
Explica qué es una transacción en una base de datos y describe las propiedades
ACID. Luego, muestra a través de un ejemplo cómo usarías múltiples savepoints
para manejar errores parciales en un procedimiento que asigna un agente a un
incidente y actualiza simultáneamente el estado del incidente. ¿Qué ocurre si
falla solo la actualización del estado?

R: Una transacción es un conjunto de operaciones SQL (como INSERTS, UPDATES, DELETES)
que se ejecutan como una unica unidad de trabajo logica. Esto significa que se guardan 
todos los cambios juntos (haciendo un COMMIT) o no se guarda absolutamente nada si es que 
ocurre algun fallo, evitando así que los datos queden a medias o inconsistentes en el sistema.

Las propiedades ACID son cuatro propiedades que aseguran que las transacciones se ejecuten de forma confiable:
entre ellas esta la Atomicidad, que dice que una transacción debe ejecutarse 
completamente o no se ejecuta en absoluto, otra es, la Consitencia, permite 
que la transaccion transforme la base de datos de un estado valido a otro, la Irreversibilidad, 
la cual dice que una vez que una transacción se ha confirmado, sus cambios deben 
persistir incluso si hay fallos en el sistema, y finalmente la Durabilidad, 
que asegura que los cambios realizados por la transacción sean permanentes 
incluso si hay fallos en el sistema. 


CREATE OR REPLACE PROCEDURE registrar_asignacion (
    v_agente_id IN NUMBER,
    v_incidente_id IN NUMBER,
    v_horas IN NUMBER,
    v_rol IN VARCHAR2
) IS
    -- definimos los puntos de control de la transacción
    SAVEPOINT sp_inicio;
    
    -- variables auxiliares
    var_next_id NUMBER;
    var_estado_incidente VARCHAR2(20);
BEGIN
    
    -- se busca el siguiente id
    SELECT NVL(MAX(AsignacionID), 0) + 1 INTO var_next_id FROM Asignaciones;

    -- se hace la insercion en la tabla de asignaciones
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
    VALUES (var_next_id, v_agente_id, v_incidente_id, v_horas, v_rol);

    SAVEPOINT despues_insert;


    -- se busca el estado actual del incidente
    SELECT Estado INTO var_estado_incidente FROM Incidentes WHERE IncidenteID = v_incidente_id;

    -- si estaba abierto se cambia a en proceso
    IF var_estado_incidente = 'Abierto' THEN
        UPDATE Incidentes
        SET Estado = 'En Proceso'
        WHERE IncidenteID = v_incidente_id;
    END IF;

    -- si todo sale bien, se confirma la transacción
    COMMIT;

EXCEPTION
    -- si ocurre cualquier error, se vuelve al estado original
    WHEN OTHERS THEN
        -- en caso de error, se revierte al savepoint inmediatamente anterior (sp_despues_insert)
        ROLLBACK TO despues_insert;
        
        -- se lanza la excepción original para notificar el error
        RAISE;
END;
/ 

Si solamente falla la actualizacion del estado del incidente, la asignacion se guarda igual
pero no se actualiza el estado del incidente, por lo que queda como estaba antes de la transaccion.  


PREGUNTA 2 (10 puntos)
¿Qué es un Data Warehouse y cómo se diferencia de una base de datos
transaccional? Describe cómo diseñarías un modelo dimensional (tabla de hechos
y al menos dos dimensiones) para analizar las horas trabajadas por agente y
por severidad de incidente. ¿Qué ventajas tiene este modelo para consultas
analíticas versus consultar directamente las tablas transaccionales?

R: Un Data Warehouse es una base de datos diseñada para centralizar, consolidar y generar un historial de
información de múltiples fuentes con el fin de realizar análisis complejos y facilitar la toma 
de decisiones de negocio.

Se diferencia de una base de datos transaccional en su propósito, en esta, la transaccional soporta las operaciones rápidas del día a día (INSERT, UPDATE y consultas simples). 
El Data Warehouse está optimizado para consultas analíticas pesadas y agregaciones sobre grandes volúmenes de datos históricos.
la transaccional está altamente normalizada para evitar redundancias. El Data Warehouse utiliza modelos desnormalizados para reducir la cantidad de JOINs y mejorar el rendimiento de los reportes.

Para analizar las horas trabajadas por agente y por severidad de incidente, crearía una tabla de hechos llamada Fact_Asignaciones que almacene las horas trabajadas por agente y por severidad de incidente. 

Las ventajas del modelo dimensional sobre las tablas transaccionales son:

- Optimizado para consultas analíticas
- Menor cantidad de JOINs
- Mayor rendimiento
- Reducción de redundancia
- Mejora en la calidad de los datos 


PREGUNTA 3 (10 puntos)
Explica cómo se implementa la herencia en Oracle usando tipos de objetos.
Da un ejemplo de una jerarquía de dos niveles: Agente → AgenteEspecialista →
AgentePentester, donde cada nivel agrega atributos y sobreescribe un método
calcular_costo(). ¿Qué implicancias tiene declarar un tipo como NOT
INSTANTIABLE?

R: La herencia en Oracle se implementa mediante el modelo objeto-relacional usando tipos de objetos (object Types).
Primero, se define un tipo base (clase padre) agregándole la opción NOT FINAL, lo cual le indica al motor de base de datos que este tipo permite derivaciones.
Posteriormente, se crea un subtipo (clase hija) mediante la palabra clave "UNDER" especificando el tipo padre. Los subtipos heredan de manera automática todos 
los atributos y metodos del padre, y a la vez pueden incorporar nuevos atributos propios o implementar polimorfismo utilizando OVERRIDING MEMBER FUNCTION para 
redefinir el comportamiento de metodos heredados.


CREATE OR REPLACE TYPE agente_obj AS OBJECT (
    nombre VARCHAR2(50),
    categoria CHAR(1)
) NOT FINAL MEMBER FUNCTION calcular_costo RETURN NUMBER;
/

CREATE OR REPLACE TYPE agente_especialista_obj UNDER agente_obj (
    categoria_especializada VARCHAR2(50)
) NOT FINAL;
/

CREATE OR REPLACE TYPE agente_pentester_obj UNDER agente_especialista_obj (
    herramienta VARCHAR2(50)
) FINAL OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER;
/


PREGUNTA 4 (10 puntos)
Describe las ventajas y desventajas de usar índices y particiones en una base
de datos. ¿Cómo usarías un índice compuesto y una partición por rango para
mejorar el rendimiento de consultas en la tabla Incidentes filtradas por
Severidad y FechaDeteccion? Explica qué es el partition pruning y cómo
impacta en el plan de ejecución.

R: Ventajas y desventajas de los Índices: La ventaja es que aceleran enormemente la velocidad de las consultas al permitir búsquedas directas de registros sin tener que leer toda la tabla.
Por otro lado, sus desventajas son que ralentizan las operaciones de escritura (INSERT, UPDATE, DELETE) porque el motor debe actualizar el índice cada vez que se modifican datos, y además consumen espacio físico extra en el disco.

Ventajas y desventajas de las Particiones: La ventaja de las particiones son que dividen una tabla muy grande en partes más pequeñas y manejables según una clave. Al consultar, el motor solo lee la partición requerida, reduciendo el tiempo de respuesta. 
También facilitan el mantenimiento de datos antiguos. Sus desventajas son que requieren una mayor planificación de diseño, y si una consulta no filtra por la clave de partición, el motor tendrá que escanear todas las particiones, perdiendo la ventaja del particionado.


Para mejorar el rendimiento de consultas en la tabla incidentes mediante indice compuesto y una particion por rango se aplicaría lo siguiente:
 
-- se crea el indice compuesto
CREATE INDEX idx_inc_sev_fecha ON Incidentes (Severidad, FechaDeteccion);

-- se crea la particion por rango
CREATE TABLE Incidentes (
    IncidenteID NUMBER,
    Severidad VARCHAR2(20),
    FechaDeteccion DATE,
    Estado VARCHAR2(20)
) 
PARTITION BY RANGE (FechaDeteccion)
(
    PARTITION r1 VALUES LESS THAN (DATE '2026-04-01'),
    PARTITION r2 VALUES LESS THAN (DATE '2026-07-01'),
    PARTITION r3 VALUES LESS THAN (DATE '2026-10-01'),
    PARTITION r4 VALUES LESS THAN (DATE '2027-01-01')
); 

El partition pruning es una técnica de optimización que consiste en eliminar las particiones que no se necesitan para una consulta. 
Esto reduce la cantidad de datos que se necesitan leer de la tabla, lo que mejora el rendimiento de la consulta mejorando el plan de ejecución.

================================================================================
PARTE 2 - EJERCICIOS PRÁCTICOS (60 puntos)
================================================================================

EJERCICIO 1 (20 puntos)
Escribe un procedimiento registrar_asignacion que reciba un AgenteID,
IncidenteID, Horas y Rol (parámetros IN). El procedimiento debe:
  a) Insertar una nueva asignación en Asignaciones (usa el próximo
     AsignacionID disponible).
  b) Validar que el agente no supere 100 horas totales asignadas en
     incidentes con Estado 'Abierto'.
  c) Validar que el incidente no tenga ya 3 o más agentes asignados.
  d) Usar savepoints independientes para cada validación, de modo que un
     fallo en una no deshaga operaciones previas válidas.
  e) Manejar todas las excepciones con mensajes descriptivos.

PROCEDURE registrar_asignacion(
    p_agentid IN NUMBER,
    p_incidenteid IN NUMBER,
    p_horas IN NUMBER,
    p_rol IN VARCHAR2
) IS 
    v_horas_agente NUMBER;
    v_conteo_agentes NUMBER;
    v_proximo_asignacionid NUMBER;

BEGIN 
SAVEPOINT inicio; 

    SELECT MAX(AsignacionID) INTO v_proximo_asignacionid
    FROM Asignaciones;

    v_proximo_asignacionid := v_proximo_asignacionid + 1;

    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
    VALUES (v_proximo_asignacionid, p_agentid, p_incidenteid, p_horas, p_rol);

    COMMIT; 
 
    SELECT SUM(Horas) INTO v_horas_agente
    FROM Asignaciones
    WHERE AgenteID = p_agentid
      AND Estado = 'Abierto';
    
    IF v_horas_agente > 100 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: El agente no puede superar las 100 horas totales asignadas en incidentes con Estado Abierto');
    END IF;


    SELECT COUNT(*) INTO v_conteo_agentes
    FROM Asignaciones
    WHERE IncidenteID = p_incidenteid;
    
    IF v_conteo_agentes >= 3 THEN
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: El incidente ya tiene 3 o más agentes asignados');
    END IF;

    -- manejo de errores con rollback
    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO inicio;
        RAISE;  
END;
/


EJERCICIO 2 (20 puntos)
Diseña las tablas Fact_Asignaciones, Dim_Agente y Dim_Incidente para un
Data Warehouse basado en la base de datos de la prueba. Luego, escribe una
consulta analítica sobre las tablas transaccionales que muestre, para cada
agente, el total de horas trabajadas y el número de incidentes atendidos,
ordenado de mayor a menor por total de horas.

-- Fact_Asignaciones
CREATE TABLE Fact_Asignaciones (
    AgenteID NUMBER,
    IncidenteID NUMBER,
    Horas NUMBER,
    Rol VARCHAR2(20)
);

-- Dim_Agente
CREATE TABLE Dim_Agente (
    AgenteID NUMBER,
    Nombre VARCHAR2(50),
    Categoria VARCHAR2(20)
);

-- Dim_Incidente
CREATE TABLE Dim_Incidente (
    IncidenteID NUMBER,
    Severidad VARCHAR2(20),
    FechaDeteccion DATE,
    Estado VARCHAR2(20)
);

-- Consulta analítica sobre las tablas transaccionales
SELECT 
    a.AgenteID,
    SUM(a.Horas) AS TotalHoras,
    COUNT(*) AS NumeroIncidentes
FROM Asignaciones a
WHERE a.Estado = 'Abierto'
GROUP BY a.AgenteID
ORDER BY TotalHoras DESC; 

EJERCICIO 3 (20 puntos)
Crea un índice compuesto en Incidentes para las columnas Severidad y
FechaDeteccion. Luego, crea la tabla Incidentes particionada por rango de
FechaDeteccion (trimestral para 2026). Escribe una consulta que muestre el
total de horas asignadas por incidente para incidentes 'Critical' detectados
en el primer trimestre de 2026. Finalmente, muestra el plan de ejecución
con EXPLAIN PLAN e indica qué ventaja aporta la partición para esta consulta.

-- se crea el indice compuesto
CREATE INDEX fecha_severidad ON Incidentes (Severidad, FechaDeteccion);

-- se crea la particion por rango
CREATE TABLE Incidentes (
    IncidenteID NUMBER,
    Severidad VARCHAR2(20),
    FechaDeteccion DATE,
    Estado VARCHAR2(20)
) 
PARTITION BY RANGE (FechaDeteccion)
(
    PARTITION r1 VALUES LESS THAN (DATE '2026-04-01'),
    PARTITION r2 VALUES LESS THAN (DATE '2026-07-01'),
    PARTITION r3 VALUES LESS THAN (DATE '2026-10-01'),
    PARTITION r4 VALUES LESS THAN (DATE '2027-01-01')
);

SELECT * FROM Incidentes WHERE Severidad = 'Critical' AND FechaDeteccion BETWEEN '2026-01-01' AND '2026-03-31';

  

================================================================================
*/
