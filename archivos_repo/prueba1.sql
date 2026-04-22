/* Ejercicio 1

Pregunta 1)
Relación Muchos a Muchos (10 pts): Explica qué es una relación muchos a muchos y cómo se implementa en una base de datos relacional. 
Usa un ejemplo basado en las tablas del esquema creado para la prueba.
*/

-- En bases de datos, cuando formulamos inicialmente el problema, tenemos que crear las relaciones entre las tablas, la relación muchos a muchos, se da 
-- cuando en ambas partes de la tabla pueden contener muchos elementos entre ambas partes, para un correcto manejo de esta situación no se puede dejar la relación de muchos a muchos
-- como tal, para ello se utiliza una tabla intermediaria que actúa como puente entre las tablas que poseían la relacion muchos a muchos, convirtiendola en relaciones de 1 a n.

-- Ejemplo: 

/*
Vistas (10 pts): Describe qué es una vista y cómo la usarías para mostrar el total de horas dedicadas por incidente, incluyendo la descripción del incidente y su severidad. 
Escribe la consulta SQL para crear la vista (no es necesario ejecutarla).

-- una vista es la manera de simplificar una consulta sql de modo que creamos la tabla nueva con los requerimientos que deseamos, de esa manera es más fácil buscar información
-- y crear nuevas consultas en base a la nueva informacion agrupada y recopilada

*/


/*
Excepciones Predefinidas (10 pts): ¿Qué es una excepción predefinida en PL/SQL y cómo se maneja? Da un ejemplo de cómo manejarías la excepción NO_DATA_FOUND en un bloque PL/SQL.

-- Son las excepciones que trae oracle por defecto, estas no son creadas por el usuario, se pueden manejar a través de sentencias IF, 
por ejemplo al verificar que no hayan filas en una tabla

-- IF v_filas_afectadas = 0 THEN
--        RAISE NO_DATA_FOUND;
--   ELSE
--       DBMS_OUTPUT.PUT_LINE('Precio actualizado correctamente. Producto ID: ' || p_producto_id);
--   END IF;

*/




/*
Cursores Explícitos (10 pts): Explica qué es un cursor explícito y cómo se usa en PL/SQL. Menciona al menos dos atributos de cursor (como %NOTFOUND) y su propósito.

-- Un cursor explícito es un puntero que se usa en PL/SQL de modo que es creado y programado por el usuario, este recorre las filas de una tabla uno por uno, con un objetivo
-- personalizable según lo que se requiera como por ejemplo listar un promedio de alumnos. 

-- Un atributo clave es %NOTFOUND que se utiliza como una condición de salida
-- cuando usamos FETCH para buscar, cuando no quedan más filas para buscar (%NOTFOUND) se termina el bucle.

-- Otro atributo usado es %ISOPEN cuyo objetivo es verificar si el cursor sigue abierto, es usado como buena practica para verificar que el cursor esté bien cerrado y evitar
-- alguna fuga de memoria, es decir nos aseguramos que el programa termine de ejecutar el cursor correctamente, se usa en las EXCEPTIONS.
*/



-- Parte 2

-- Escribe un bloque PL/SQL con un cursor explícito que liste las especialidades de agentes cuyo promedio de horas 
-- asignadas a incidentes sea mayor a 30, mostrando la especialidad y el promedio de horas. 
-- Usa un JOIN entre Agentes y Asignaciones.
declare 
    cursor especialidades is
    select agentes.especialidad, AVG(asignaciones.horas) as prom_horas.
    from agentes
    join asignaciones on asignaciones.agenteid =  agentes.agenteid
    where AVG(asignaciones.horas) > 30;


    v_especialidad varchar2(50);
    v_promedio NUMBER;

    BEGIN
        open especialidades;
        loop
            fetch especialidades into v_especialidad, v_promedio
            exit when especialidades%NOTFOUND;

            DBMS_OUTPUT.PUT_LINE('Especialidad: ' || v_especialidad || '- Promedio horas: ' || v_promedio);
        end loop
        close especialidades;
    END;
/

-- Escribe un bloque PL/SQL con un cursor explícito que aumente en 10 las horas de todas las asignaciones asociadas a incidentes 
-- con severidad 'Critical'. Usa FOR UPDATE y maneja excepciones.
declare 
    cursor aumentar_h is
    select asignaciones.horas, incidentes.severidad
    from asignaciones join incidentes on incidentes.incidenteid = asignaciones.incidenteid
    where incidentes.severidad = 'critical'
    for update;

    BEGIN
        open especialidades;
        loop
            fetch especialidades into v_especialidad, v_promedio
            exit when especialidades%NOTFOUND;

            DBMS_OUTPUT.PUT_LINE('Especialidad: ' || v_especialidad || '- Promedio horas: ' || v_promedio);
        end loop
        close especialidades;
    END;
/

-- Tipo de Objeto (20 pts) Crea un tipo de objeto incidente_obj con atributos incidente_id, descripcion, 
-- y un método get_reporte. Luego, crea una tabla basada en ese tipo y transfiere los datos de Incidentes a esa tabla. 
-- Finalmente, escribe un cursor explícito que liste la información de los incidentes usando el método get_reporte.

CREATE OR REPLACE TYPE incidente_obj AS OBJECT (
    incidenteid NUMBER,
    descripcion varchar2(50),
    MEMBER FUNCTION get_reporte RETURN varchar(50);
);
/


CREATE OR REPLACE TYPE BODY incidente_obj AS
    MEMBER FUNCTION get_reporte RETURN varchar IS
    begin
        return 'Incidente id: ' || TO_CHAR(incidenteid) || '- Descripcion: ' || descripcion;
    end;
END;
/

-- 3. La Tabla del Objeto
CREATE TABLE tabla_incidente OF incidente_obj as (
    t_incidente_id PRIMARY KEY;
);

insert into tabla_incidente (incidenteid, descripcion)
    select incidenteid, descripcion
    from incidentes;

commit;

declare 
    var_incidente_obj incidente_obj;

    cursor incidente_cursor is
        select value(i_tabla) from tabla_incidente i_tabla
        
    begin
        open incidente_cursor
        loop 
            fetch incidente_cursor into var_incidente_obj;
            exit when incidente_cursor%NOTFOUND;
            var_incidente_obj.get_reporte();
        end loop;
        close incidente_cursor:
    end;
/
