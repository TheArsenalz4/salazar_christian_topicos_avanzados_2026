-- 1) Explica la diferencia entre un procedimiento almacenado y una función 
-- almacenada en PL/SQL. Da un ejemplo de cuándo usarías cada uno en el 
-- contexto de la base de datos de la prueba.

-- R: La principal diferencia es que una función almacenada está obligada a retornar un valor si o si
-- mediante la palabra RETURN, y por lo mismo la podemos meter directo en consultas SQL comunes (como en un SELECT).
-- Un procedimiento almacenado ejecuta una serie de acciones pero no retorna un valor 
-- directamente (a no ser que use parámetros de salida), y se tiene que llamar desde un bloque PL/SQL o con 
-- la instrucción EXECUTE.

-- ejemplo: en la base de datos de la prueba, usaría un procedimiento almacenado para la acción completa de registrar
-- una asignación nueva, ya que utiliza INSERT, UPDATE, etc, y usaría una función para
-- obtener el total de horas que tiene asignadas un agente en especifico, de modo que podamos usar ese cálculo directo
-- dentro de un SELECT normal con los datos del agente.



-- 2) Describe cómo usarías un parámetro IN OUT en un procedimiento almacenado.
--  Escribe un ejemplo de un procedimiento que use un parámetro IN OUT para 
-- actualizar y devolver las horas de una asignación después de un ajuste.

-- R: Un parámetro IN OUT funciona como entrada y salida al mismo tiempo. Lo usamos cuando queremos pasarle una 
-- variable al procedimiento con un valor inicial, para que el procedimiento haga sus cálculos trabajando con 
-- ese valor y luego sobreescriba esa misma variable con el resultado final. De este modo, al terminar de 
-- ejecutarse, nos quedamos con el valor actualizado.

-- ejemplo:
-- para la implementación de un parámetro IN OUT en el contexto de la base de datos actual para actualizar y devolver 
-- las horas de una asignación luego de un ajuste, se podría hacer así:

-- CREATE OR REPLACE PROCEDURE ajustar_horas_asignacion (
--     v_asignacion_id IN NUMBER,
--     v_horas_ajuste IN NUMBER,
--     v_horas_actuales IN OUT NUMBER
-- ) IS
-- BEGIN
--     -- se suma el ajuste a las horas actuales recibidas
--     v_horas_actuales := v_horas_actuales + v_horas_ajuste;
    
--     -- se actualizan las horas en la tabla asignaciones
--     UPDATE Asignaciones
--     SET Horas = v_horas_actuales
--     WHERE AsignacionID = v_asignacion_id;
    
--     COMMIT;
-- END;
-- /



-- 3) ¿Cómo se puede usar una función almacenada dentro de una consulta SQL? 
-- Escribe un ejemplo de una función que calcule el total de horas asignadas 
-- a un incidente y úsala en una consulta para listar los incidentes con su 
-- total de horas.

-- R: Para usarla, se llama directamente dentro de un SELECT un WHERE o HAVING de la consulta, 
-- tal como si fuera una columna más o una de las funciones que estan por defecto. 
-- Lo único importante es que la función no puede hacer cambios en la base de datos 
-- (no puede tener INSERT, UPDATE ni DELETE), solo debe procesar los datos y retornar un valor.

-- ejemplo:
-- CREATE OR REPLACE FUNCTION fun_total_horas_incidente (
--     v_id_incidente IN NUMBER
-- ) RETURN NUMBER IS
--     var_total_horas NUMBER;
-- BEGIN
--     -- se calcula la suma de las horas para el incidente
--     SELECT SUM(Horas)
--     INTO var_total_horas
--     FROM Asignaciones
--     WHERE IncidenteID = v_id_incidente;

--     -- si no tiene asignaciones, devolvemos 0 en vez de null para evitar errores de null
--     RETURN NVL(var_total_horas, 0); -- para evitar errores de null
-- END;
-- /

-- SELECT 
--     Incidentes.IncidenteID,
--     Incidentes.Descripcion,
--     Incidentes.Severidad,
--     fun_total_horas_incidente(Incidentes.IncidenteID) AS horas_totales
-- FROM Incidentes;



-- 4) Explica qué es un trigger y menciona dos tipos de eventos que pueden 
-- dispararlo. Da un ejemplo de un trigger que se dispare después de insertar 
-- una asignación en la tabla Asignaciones y actualice el estado del incidente
-- a 'En Proceso' si estaba en 'Abierto'.

-- R: Un trigger es un bloque de código PL/SQL que se ejecuta solo de forma automática
-- en la base de datos, como reacción a un evento específico que ocurra en una tabla. Dos tipos de eventos
-- que pueden dispararlo son los eventos de INSERT (al agregar una fila nueva) o UPDATE (al modificar datos).

-- ejemplo:
-- CREATE OR REPLACE TRIGGER trg_actualizar_estado_incidente
-- AFTER INSERT ON Asignaciones
-- FOR EACH ROW
-- DECLARE
--     var_estado_actual VARCHAR2(20);
-- BEGIN
--     -- se busca el estado actual del incidente
--     SELECT Estado
--     INTO var_estado_actual
--     FROM Incidentes
--     WHERE IncidenteID = :NEW.IncidenteID;

--     -- si estaba abierto se cambia a en proceso
--     IF var_estado_actual = 'Abierto' THEN
--         UPDATE Incidentes
--         SET Estado = 'En Proceso'
--         WHERE IncidenteID = :NEW.IncidenteID;
--     END IF;
-- END;
-- /

-- Preguntas prácticas

-- 1) Escribe un procedimiento registrar_asignacion que reciba un AgenteID, IncidenteID, Horas y Rol (parámetros IN). El procedimiento debe:
-- Insertar una nueva asignación en la tabla Asignaciones (usa el próximo AsignacionID disponible).
-- Actualizar el estado del incidente a 'En Proceso' si estaba en 'Abierto'.
-- Manejar excepciones si el agente o incidente no existen, o si el agente ya está asignado a ese incidente.

CREATE OR REPLACE PROCEDURE registrar_asignacion (
    v_agente_id IN NUMBER,
    v_incidente_id IN NUMBER,
    v_horas IN NUMBER,
    v_rol IN VARCHAR2
) IS
BEGIN
    var_next_id NUMBER;
    var_estado_incidente VARCHAR2(20);
    -- busco el siguiente id
    SELECT NVL(MAX(AsignacionID)) + 1 INTO var_next_id FROM Asignaciones;

    -- se hace la insercion 
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
    VALUES (var_next_id, v_agente_id, v_incidente_id, v_horas, v_rol);

    -- se cambia el estado si es que estaba en Abierto
    SELECT Estado INTO var_estado_incidente FROM Incidentes WHERE IncidenteID = v_incidente_id;
    IF var_estado_incidente = 'Abierto' THEN
        UPDATE Incidentes
        SET Estado = 'En Proceso'
        WHERE IncidenteID = v_incidente_id;
    END IF;

    -- se guardan los cambios definitivos
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Asignacion registrada. ID: ' || var_next_id);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- deshace si ocurre otro error
        DBMS_OUTPUT.PUT_LINE('Error en registrar_asignacion: ' || SQLERRM);
        RAISE;
END;
/



-- 2) Escribe una función calcular_horas_agente que reciba un AgenteID (parámetro IN) y devuelva el total de horas asignadas 
-- a ese agente en todos los incidentes. Luego, usa la función en un procedimiento mostrar_carga_agentes que 
-- muestre el total de horas por agente para todos los agentes, indicando su nombre y especialidad.

CREATE OR REPLACE FUNCTION calcular_horas_agente (
    v_agente_id IN NUMBER
) RETURN NUMBER IS
    var_total_horas NUMBER;
BEGIN
    -- se saca la suma de las horas del agente en sus asignaciones
    select SUM(Horas) into var_total_horas
    from Asignaciones
    where AgenteID = v_agente_id;

    -- si no tiene ninguna hora asignada devuekve 0 (NVL)
    RETURN NVL(var_total_horas, 0);
END;
/

CREATE OR REPLACE PROCEDURE mostrar_carga_agentes IS
    -- uso un cursor para recorrer todos los agentes de la tabla
    CURSOR c_agentes IS
        SELECT AgenteID, Nombre, Especialidad FROM Agentes;
    var_horas NUMBER;
BEGIN
    FOR agente IN c_agentes LOOP
        -- se llama a la funcion creada anteriormente para calcular las horas
        var_horas := calcular_horas_agente(agente.AgenteID);
        DBMS_OUTPUT.PUT_LINE('Agente: ' || agente.Nombre || ' - Especialidad: ' || agente.Especialidad || ' - Horas Asignadas: ' || var_horas);
    END LOOP;
END;
/


-- 3) Implementa un sistema de auditoría manual usando un trigger. Para esto, primero crea una tabla llamada AuditoriaAsignaciones 
-- con las columnas necesarias. Luego, crea un trigger auditar_asignaciones que se dispare después de insertar o eliminar 
-- una asignación en la tabla Asignaciones. El trigger debe registrar en la tabla de auditoría el 
-- AsignacionID, AgenteID, IncidenteID, Horas, la acción realizada ('INSERT' o 'DELETE') y la fecha del registro.

-- se crea la tabla de auditoria para registrar las acciones
CREATE TABLE AuditoriaAsignaciones (
    AuditoriaID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    AsignacionID NUMBER,
    AgenteID NUMBER,
    IncidenteID NUMBER,
    Horas NUMBER,
    Accion VARCHAR2(10),
    Fecha DATE
);

-- se crea el trigger para auditar despues de insertar o borrar registros
CREATE OR REPLACE TRIGGER auditar_asignaciones
AFTER INSERT OR DELETE ON Asignaciones
FOR EACH ROW
BEGIN
    CONNECT sys AS sysdba;
    ALTER SYSTEM SET audit_trail=DB SCOPE=SPFILE;

    -- auditar acciones de asignaciones
    AUDIT SELECT ON AuditoriaAsignaciones BY user_analista;

    -- ver registros de auditoría
    SELECT username, action_name, timestamp
    FROM dba_audit_trail
    WHERE username = 'USER_AUDITORIA';
END;
/
