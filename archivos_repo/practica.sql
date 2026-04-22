
-- 1)

-- Realice 2 sentencias SELECT simples. 

-- Realice 2 sentencias SELECT utilizando funciones agregadas sobre su base de datos. 

-- Realice 2 sentencias SELECT utilizando subconsultas. 

-- Realice 2 sentencias SELECT utilizando expresiones regulares. 

-- Cree una VISTA (CREATE VIEW) y realice un SELECT sobre ella.



-- 2)

/*
Escribe un bloque anónimo que calcule el total de alguna entidad y lo clasifique en 3 categorías: 
Alto, Medio o Bajo. Las categorías deben estar descritas según criterios propuestos por usted mismo. 
Estos criterios deben estar documentados. 
*/



DECLARE 
    var_nombre varchar(50);
    var_id NUMBER;
    var_total NUMBER;
    var_clasificacion varchar(50);

cursor c_cliente_total is
    select c.nombre, c.ClienteID, sum(p.total) as Gastado from Clientes c
    inner join Pedidos p on c.ClienteID = p.ClienteID
    group by c.ClienteID, c.nombre;
BEGIN
    OPEN c_cliente_total;
    LOOP 
    FETCH c_cliente_total INTO var_nombre, var_id, var_total;
    EXIT WHEN c_cliente_total%NOTFOUND;

    IF var_total > 700 THEN
        var_clasificacion := 'Alto';
    ELSIF var_total < 400 THEN
        var_clasificacion := 'Bajo';
    ELSE
        var_clasificacion := 'Medio';
    END IF;

    DBMS_OUTPUT.PUT_LINE('Nombre: ' || var_nombre || ' | ID: ' || var_id || ' | Gastado: ' || var_total || ' | Clasificacion: ' || var_clasificacion);

    END LOOP;
    CLOSE c_cliente_total;
END;
/
-- 3

/* Escribe un bloque PL/SQL que verifique el valor numérico de una tabla. 
Si el valor es menor a algún bias, lanza una excepción personalizada.
Maneja también NO_DATA_FOUND
*/

declare
    var_precio Productos.Precio%TYPE;
    var_bias NUMBER := 50;
    var_error EXCEPTION;
    BEGIN
        SELECT precio INTO var_precio
        from Productos p
        where p.ProductoID = 2;

        IF var_precio < var_bias THEN
            RAISE var_error;
        END IF;

        DBMS_OUTPUT.PUT_LINE('El Precio del producto es mayor al bias, precio: ' || var_precio);

    EXCEPTION
        WHEN var_error THEN
            DBMS_OUTPUT.PUT_LINE('El precio es menor al bias: ' || var_bias);
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: no se encontro ningun producto con ese ID');
    END;
/




/* Escribe un bloque PL/SQL que intente insertar una tupla con ID duplicado
Verifique la excepción lanzada
Maneje la excepción
*/
declare
    BEGIN
    INSERT INTO Productos(ProductoID, Nombre, Precio)
    VALUES(1, 'pc', 2003);

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('ID DUPLICADO');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);

    END;
/
-- 4)

/*
Escribe un bloque anónimo que use un cursor explícito para listar 2 atributos de alguna clase, 
ordenados por uno de los atributos.
*/
DECLARE
    cursor listar is
    select c.nombre, c.ciudad
    from clientes c
    order by c.nombre desc;

    var_nombre clientes.nombre%TYPE;
    var_ciudad clientes.ciudad%TYPE;

    BEGIN
        open listar;
        loop
            fetch listar into var_nombre, var_ciudad;
            exit when listar%NOTFOUND;
            
            DBMS_OUTPUT.PUT_LINE('Cliente: ' || var_nombre ||' | Ciudad: ' || var_ciudad);
        end loop;
        close listar;

        EXCEPTION
            WHEN OTHERS then
                DBMS_OUTPUT.PUT_LINE('Error al ejecutar el cursor')
            IF listar%ISOPEN then
                CLOSE pedido_detalle;
                END IF;

    END;
    /


/*
Escribe un bloque anónimo que use un cursor explícito con parámetro para aumentar 
un 10% el total de la suma de algún atributo numérico de un elemento de una tabla 
y muestre los valores originales y actualizados. Usa FOR UPDATE.
*/
declare
    cursor aumentarPrecio(id NUMBER) is
    select p.nombre, p.precio, p.productoid
    from productos p
    where p.productoid = id
    for update;

    var_nombre productos.nombre%TYPE;
    var_precio_antiguo productos.precio%TYPE;
    var_id productos.productoid%TYPE;
    var_precio_nuevo NUMBER;


    BEGIN
        open aumentarPrecio(1);
        loop
            fetch aumentarPrecio into var_nombre, var_precio_antiguo, var_id;
            exit when aumentarPrecio%NOTFOUND;

            var_precio_nuevo := var_precio_antiguo * 1.10;

            UPDATE Productos
            SET precio = var_precio_nuevo
            WHERE current of aumentarPrecio;

            DBMS_OUTPUT.PUT_LINE('NOMBRE PRODUCTO: ' || var_nombre);
            DBMS_OUTPUT.PUT_LINE('Precio antiguo: ' || var_precio_antiguo);
            DBMS_OUTPUT.PUT_LINE('Precio nuevo: ' || var_precio_nuevo);

        end loop;
        close aumentarPrecio;

        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
                IF aumentarPrecio%ISOPEN THEN
                    CLOSE aumentarPrecio;
                END IF;
END;
/




-- 5)

/*
Escribe un bloque anónimo que use un cursor explícito basado en un objeto para listar 2 atributos 
de alguna clase, ordenados por uno de los atributos.
*/

-- Paso 1 crear la plantilla del objeto con sus atributos y funciones
create or replace type cliente_obj as OBJECT (
    nombre VARCHAR2(50),
    ciudad VARCHAR2(50),
    cliente_id NUMBER,

    MEMBER FUNCTION listar_2_atributos return VARCHAR2
);
/
-- Paso 2 crear la logica de la funcion "listar_2_atributos"
create or replace type BODY cliente_obj as 
    MEMBER FUNCTION listar_2_atributos return VARCHAR2 IS
    BEGIN  
        RETURN 'Nombre: ' || nombre || '- Ciudad: ' || ciudad;
    END;
END;
/
-- Paso 3 crear la tabla basada en el objeto creado
create table clientes_obj_table of cliente_obj (
    cliente_id PRIMARY KEY
);

-- extra: agregar datos
DELETE FROM clientes_obj_table;

INSERT INTO clientes_obj_table (nombre, ciudad, cliente_id)
    select nombre, ciudad, clienteid
    from clientes;

commit; 
-- Paso 4 leer objeto con cursores
DECLARE
    var_cliente_obj cliente_obj;

    cursor cliente_cursor_obj IS
        select VALUE(c_table) from clientes_obj_table c_table
        ORDER BY c_table.nombre; -- Es obligatorio usar VALUE con eso extraigo el objeto y lo guarda en mi variable
    
    BEGIN
        OPEN cliente_cursor_obj;
        LOOP
            FETCH cliente_cursor_obj into var_cliente_obj;
            EXIT WHEN cliente_cursor_obj%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(var_cliente_obj.listar_2_atributos());
        END LOOP;
        CLOSE cliente_cursor_obj;
    END;
/
/*
Escribe un bloque anónimo que use un cursor explícito con parámetro basado en un objeto para 
aumentar un 10% el total de la suma de algún atributo numérico de un elemento de una tabla y 
muestre los valores originales y actualizados. Usa FOR UPDATE o usa función dentro del objeto
*/
create or replace TYPE precio_productos as OBJECT (
    v_id NUMBER,
    nombre VARCHAR2(50),
    precio NUMBER
);
/

create table tabla_precios_obj of precio_productos (
    v_id PRIMARY KEY
);
/

INSERT INTO tabla_precios_obj VALUES (1, 'Teclado Gamer', 100);
COMMIT;

declare
    precios_obj precio_productos;
    v_precio_nuevo NUMBER;

    cursor aumentar_precio(p_id NUMBER) is
    select value(t) from tabla_precios_obj t
    where t.v_id = p_id
    for update;

    BEGIN
        open aumentar_precio(1);
        LOOP
            FETCH aumentar_precio into precios_obj;
            EXIT WHEN aumentar_precio%NOTFOUND;

            DBMS_OUTPUT.PUT_LINE('Precio anterior: $' || precios_obj.precio);

            v_precio_nuevo := precios_obj.precio * 1.10;

            UPDATE tabla_precios_obj
            SET precio = v_precio_nuevo
            WHERE current of aumentar_precio;
            DBMS_OUTPUT.PUT_LINE('Precio nuevo: $' || v_precio_nuevo);
        END LOOP;
        CLOSE aumentar_precio;
        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
            IF aumentar_precio%ISOPEN then
                close aumentar_precio;
            END IF;
END;
/


-- 6)

/*
Crea un procedimiento aumentar_precio_producto que reciba un ProductoID y un porcentaje de aumento 
(como parámetros IN), y aumente el precio del producto en ese porcentaje. 
Maneja la excepción si el producto no existe.
*/




/*
Crea un procedimiento contar_pedidos_cliente que reciba un ClienteID (parámetro IN) y devuelva 
la cantidad de pedidos de ese cliente (parámetro OUT). Si el cliente no tiene pedidos, devuelve 0.
*/



-- 7)

/*
Ejercicio 1: Escribe un cursor explícito que liste los pedidos con total mayor a 500 y 
muestre el nombre del cliente asociado, usando un JOIN.
*/


/*
Ejercicio 2: Escribe un cursor explícito que aumente un 15% los precios de productos con precio 
inferior a 1000 y maneje una excepción si falla.
*/

/*
Ejercicio 3: Escribe un bloque PL/SQL con un cursor explícito que liste los clientes cuyo 
total de pedidos (suma de los valores de Total en la tabla Pedidos) 
sea mayor a 1000, mostrando el nombre del cliente y el total acumulado. 
Usa un JOIN entre Clientes y Pedidos, y agrupa los resultados con GROUP BY.
*/

/*
Ejercicio 4: Escribe un bloque PL/SQL con un cursor explícito que aumente en 1 la cantidad de los 
detalles de pedidos (DetallesPedidos) asociados a pedidos con fecha anterior al 2 de marzo de 2025 
(FechaPedido en la tabla Pedidos). Usa FOR UPDATE para bloquear las filas y maneja excepciones.
*/


