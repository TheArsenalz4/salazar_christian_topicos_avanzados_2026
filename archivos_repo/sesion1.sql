-- sesion1.sql: Script para la Sesión 1

-- Detener la ejecución si ocurre un error
WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- Cambiar al PDB XEPDB1
ALTER SESSION SET CONTAINER = XEPDB1;

-- Crear un nuevo usuario (esquema) para el curso en el PDB
CREATE USER curso_topicos IDENTIFIED BY curso2025;

-- Otorgar privilegios necesarios al usuario
GRANT CONNECT, RESOURCE, CREATE SESSION TO curso_topicos;
GRANT CREATE TABLE, CREATE TYPE, CREATE PROCEDURE TO curso_topicos;
GRANT UNLIMITED TABLESPACE TO curso_topicos;

-- Confirmar creación
SELECT username FROM dba_users WHERE username = 'CURSO_TOPICOS';

-- Cambiar al esquema curso_topicos
ALTER SESSION SET CURRENT_SCHEMA = curso_topicos;

-- Habilitar salida de mensajes para PL/SQL
SET SERVEROUTPUT ON;

-- Crear tabla Clientes
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla Clientes...');
    EXECUTE IMMEDIATE 'CREATE TABLE Clientes (
        ClienteID NUMBER PRIMARY KEY,
        Nombre VARCHAR2(50),
        Ciudad VARCHAR2(50),
        FechaNacimiento DATE
    )';
    DBMS_OUTPUT.PUT_LINE('Tabla Clientes creada.');
END;
/

-- Crear tabla Pedidos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla Pedidos...');
    EXECUTE IMMEDIATE 'CREATE TABLE Pedidos (
        PedidoID NUMBER PRIMARY KEY,
        ClienteID NUMBER,
        Total NUMBER,
        FechaPedido DATE,
        CONSTRAINT fk_pedido_cliente FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
    )';
    DBMS_OUTPUT.PUT_LINE('Tabla Pedidos creada.');
END;
/

-- Crear tabla Productos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla Productos...');
    EXECUTE IMMEDIATE 'CREATE TABLE Productos (
        ProductoID NUMBER PRIMARY KEY,
        Nombre VARCHAR2(50),
        Precio NUMBER
    )';
    DBMS_OUTPUT.PUT_LINE('Tabla Productos creada.');
END;
/

-- Insertar datos en Clientes
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en Clientes...');
    INSERT INTO Clientes VALUES (1, 'Juan Perez', 'Santiago', TO_DATE('1990-05-15', 'YYYY-MM-DD'));
    INSERT INTO Clientes VALUES (2, 'María Gomez', 'Valparaiso', TO_DATE('1985-10-20', 'YYYY-MM-DD'));
    INSERT INTO Clientes VALUES (3, 'Ana Lopez', 'Santiago', TO_DATE('1995-03-10', 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Datos insertados en Clientes.');
END;
/

-- Insertar datos en Pedidos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en Pedidos...');
    INSERT INTO Pedidos VALUES (101, 1, 600, TO_DATE('2025-03-01', 'YYYY-MM-DD'));
    INSERT INTO Pedidos VALUES (102, 1, 300, TO_DATE('2025-03-02', 'YYYY-MM-DD'));
    INSERT INTO Pedidos VALUES (103, 2, 800, TO_DATE('2025-03-03', 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Datos insertados en Pedidos.');
END;
/

-- Insertar datos en Productos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en Productos...');
    INSERT INTO Productos VALUES (1, 'Laptop', 1200);
    INSERT INTO Productos VALUES (2, 'Mouse', 25);
    DBMS_OUTPUT.PUT_LINE('Datos insertados en Productos.');
END;
/

-- Confirmar los datos insertados antes de continuar
COMMIT;

-- Confirmar creación e inserción de datos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Tablas creadas y datos insertados correctamente.');
END;
/

-- Verificar datos
SELECT * FROM Clientes;
SELECT * FROM Pedidos;
SELECT * FROM Productos;

-- Crear tabla DetallesPedidos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla DetallesPedidos...');
    EXECUTE IMMEDIATE 'CREATE TABLE DetallesPedidos (
        DetalleID NUMBER PRIMARY KEY,
        PedidoID NUMBER,
        ProductoID NUMBER,
        Cantidad NUMBER,
        CONSTRAINT fk_detalle_pedido FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
        CONSTRAINT fk_detalle_producto FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
    )';
    DBMS_OUTPUT.PUT_LINE('Tabla DetallesPedidos creada.');
END;
/

-- Insertar datos en DetallesPedidos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en DetallesPedidos...');
    INSERT INTO DetallesPedidos VALUES (1, 101, 1, 2); -- Pedido 101: 2 Laptops
    INSERT INTO DetallesPedidos VALUES (2, 101, 2, 5); -- Pedido 101: 5 Mouse

    -- Ejercicio práctico sesion 1.1 (Insertar al menos 2 registros)
    INSERT INTO DetallesPedidos VALUES (3, 102, 2, 4); -- Creo registro: id 3, pedido 102, compra 4 mouse
    INSERT INTO DetallesPedidos VALUES (4, 102, 1, 4); -- Creo registro: id 4, pedido 102 (mismo de antes), compra 4 laptops
    INSERT INTO DetallesPedidos VALUES (5, 103, 1, 1); -- Pedido 103: 1 Laptop
    DBMS_OUTPUT.PUT_LINE('Datos insertados en DetallesPedidos.');
END;
/

-- Verificar datos
SELECT * FROM DetallesPedidos;

-- SESION 2 (los comandos fueron probados directamente por la terminal SQL>)

-- Realice 2 sentencias SELECT simples
select * from curso_topicos.pedidos where total >= 600;
select * from curso_topicos.clientes where Ciudad = 'Santiago';

-- Realice 2 sentencias SELECT utilizando funciones agregadas sobre su base de datos.
select AVG(Total) as promedio_total from curso_topicos.pedidos;
select count(*) from curso_topicos.clientes;

-- Realice 2 sentencias SELECT utilizando expresiones regulares.
select nombre from curso_topicos.productos where REGEXP_LIKE(Nombre, '^L');
select nombre, ciudad from curso_topicos.clientes where REGEXP_LIKE(Nombre, 'z$');

-- Cree 2 vistas.
create view historial_de_compras as 
  select clientes.nombre, clientes.ciudad, clientes.clienteid, pedidos.pedidoid, pedidos.total, pedidos.FechaPedido 
  from curso_topicos.clientes 
  inner join curso_topicos.pedidos on curso_topicos.clientes.clienteid = curso_topicos.pedidos.clienteid;

create view veces_productos_comprados as 
  select productos.productoid, productos.nombre, productos.precio, SUM(DetallesPedidos.cantidad) as veces_vendido 
  from curso_topicos.productos 
  inner join curso_topicos.detallespedidos on curso_topicos.productos.productoid = curso_topicos.detallespedidos.productoid 
  GROUP BY curso_topicos.productos.productoid, curso_topicos.productos.nombre, curso_topicos.productos.precio;


-- Sesion 3 avance

-- Estandar de altura de edificios
DECLARE
    var_altura_metros_edificios NUMBER := 20; -- Edificio a evaluar de 20 metros
BEGIN
    IF var_altura_metros_edificios > 18 THEN -- Si es mayor a 18 metros se considera Alto
    DBMS_OUTPUT.PUT_LINE('Edificio Alto:' || var_altura_metros_edificios);
    ELSIF var_altura_metros_edificios < 10 THEN -- SI es menor a 10 metros se considera Bajo
    DBMS_OUTPUT.PUT_LINE('Edificio Bajo: '|| var_altura_metros_edificios);
    ELSE
    -- Si esta entre los rangos de 10 - 18 es Mediano
    DBMS_OUTPUT.PUT_LINE('Edificio Mediano: ' || var_altura_metros_edificios);
    END IF;
END;
/


-- Sesion 4

-- 1)
-- Escribe un bloque PL/SQL que verifique el valor numérico de una tabla. 
-- Si el valor es menor a algún bias, lanza una excepción personalizada.
-- a) Maneja también NO_DATA_FOUND

DECLARE 
    cantidad_comprada NUMBER;
    cantidad_baja EXCEPTION;
BEGIN
    select Cantidad INTO cantidad_comprada from DetallesPedidos where DetalleID = 15;
    if cantidad_comprada < 3 THEN RAISE cantidad_baja;
    END IF;
EXCEPTION
    WHEN cantidad_baja then
    DBMS_OUTPUT.PUT_LINE('La cantidad comprada para este detalle de pedido es baja');
    WHEN NO_DATA_FOUND then 
    DBMS_OUTPUT.PUT_LINE('Error: Producto no encontrado');
END;
/

-- 2)
-- Escribe un bloque PL/SQL que intente insertar una tupla con ID duplicado
-- a) Verifique la excepción lanzada
-- b) Maneje la excepción

-- Uso DUP_VAL_ON_INDEX de oracle para reconocer el error de id duplicado
DECLARE
    
BEGIN
    INSERT INTO Productos (ProductoID, Nombre, Precio) 
    VALUES (1, 'Teclado', 100);
    DBMS_OUTPUT.PUT_LINE('Teclado insertado en Productos');
    
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('El ID insertado ya existe en la tabla de Productos');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error Inesperado: ' || SQLERRM);
END;
/

-- Sesion 5 avance

-- Escribe un bloque anónimo que use un cursor explícito para listar 2 atributos de alguna clase, ordenados por uno de los atributos (numerico, alfabetico).

DECLARE
    cursor pedido_detalle IS -- cursor es un puntero que procesa filas devueltas por una consulta sql
        SELECT ProductoID, Cantidad
        FROM DetallesPedidos
        ORDER BY Cantidad DESC; -- ordeno numericamente
        
    var_producto_id NUMBER; -- variables para guardar valores del cursor
    var_cantidad NUMBER;
BEGIN
    OPEN pedido_detalle; -- llamo al cursor
    LOOP -- se hace un loop hasta que no se encuentren mas filas en DetallesPedidos
        FETCH pedido_detalle INTO var_producto_id, var_cantidad; -- se procesan las filas con fetch
        EXIT WHEN pedido_detalle%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Producto ID: '|| var_producto_id ||', Cantidad: '|| var_cantidad);
    END LOOP;
    CLOSE pedido_detalle;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrió un error leyendo el cursor: '|| SQLERRM);
        IF pedido_detalle%ISOPEN THEN
            CLOSE pedido_detalle;
        END IF;
END;
/

-- Escribe un bloque anónimo que use un cursor explícito con parámetro para aumentar 
-- un 10% el total de la suma de algún atributo numérico de un elemento de una tabla 
-- y muestre los valores originales y actualizados. Usa FOR UPDATE.

DECLARE
    
    CURSOR cursor_producto_actualizar(p_id NUMBER) IS  -- cursor explícito con parámetro
        SELECT ProductoID, Nombre, Precio
        FROM Productos
        WHERE ProductoID = p_id
        FOR UPDATE; -- Update actua como candado temporal

    v_id Productos.ProductoID%TYPE; -- %TYPE me permite usar el tipo de dato original de la variable
    v_nombre Productos.Nombre%TYPE;
    v_precio_original Productos.Precio%TYPE;
    v_precio_nuevo Productos.Precio%TYPE;
BEGIN
    OPEN cursor_producto_actualizar(2);
    LOOP
        FETCH cursor_producto_actualizar INTO v_id, v_nombre, v_precio_original;
        EXIT WHEN cursor_producto_actualizar%NOTFOUND;
        
        -- se aumenta en 10% el precio origianl
        v_precio_nuevo := v_precio_original * 1.10;
        
        -- se ejecuta el update
        UPDATE Productos
        SET Precio = v_precio_nuevo
        WHERE CURRENT OF cursor_producto_actualizar; -- le digo que en la fila actual haga el cambio en vez de pasar el id de manera manual
        
        -- Mostramos resultados
        DBMS_OUTPUT.PUT_LINE('Precio actualizado para producto: ' || v_nombre);
        DBMS_OUTPUT.PUT_LINE('Precio original: $' || v_precio_original);
        DBMS_OUTPUT.PUT_LINE('Precio nuevo: $' || v_precio_nuevo);
    END LOOP;
    CLOSE cursor_producto_actualizar;
END;
/

-- Sesion 6

-- creo el tipo objeto producto con sus atributos y una funcion
CREATE OR REPLACE TYPE producto_obj AS OBJECT (
    producto_id NUMBER,
    nombre VARCHAR2(50),
    precio NUMBER,
    MEMBER FUNCTION get_info RETURN VARCHAR2 -- funcion que retorna info del producto
);
/

-- cuerpo de la funcion del objeto
CREATE OR REPLACE TYPE BODY producto_obj AS
    MEMBER FUNCTION get_info RETURN VARCHAR2 IS
    BEGIN
        RETURN 'ID: ' || producto_id || ', Nombre: ' || nombre;
    END;
END;
/

-- tabla basada en el objeto
CREATE TABLE productos_obj OF producto_obj (producto_id PRIMARY KEY);
INSERT INTO productos_obj VALUES (1, 'Televisor', 400);
INSERT INTO productos_obj VALUES (2, 'Audifonos', 50);
COMMIT;

-- Escribe un bloque anónimo que use un cursor explícito basado en un objeto 
-- para listar 2 atributos de alguna clase, ordenados por uno de los atributos.

DECLARE
    CURSOR cursor_productos IS
        SELECT VALUE(p) FROM productos_obj p ORDER BY p.nombre ASC; -- ordeno alfabeticamente
    v_producto producto_obj; -- variable del tipo objeto que cree arriba
BEGIN
    OPEN cursor_productos;
    LOOP
        FETCH cursor_productos INTO v_producto;
        EXIT WHEN cursor_productos%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_producto.get_info()); -- llamo a la funcion del objeto
    END LOOP;
    CLOSE cursor_productos;
END;
/

-- Escribe un bloque anónimo que use un cursor explícito con parámetro basado en un objeto 
-- para aumentar un 10% el total de la suma de algún atributo numérico de un elemento de una tabla 
-- y muestre los valores originales y actualizados. Usa FOR UPDATE o usa función dentro del objeto

DECLARE
    CURSOR cursor_productos_upd(p_id NUMBER) IS
        SELECT VALUE(p) FROM productos_obj p
        WHERE p.producto_id = p_id
        FOR UPDATE;
    v_producto producto_obj;
    v_precio_anterior NUMBER;
BEGIN
    OPEN cursor_productos_upd(1);
    LOOP
        FETCH cursor_productos_upd INTO v_producto;
        EXIT WHEN cursor_productos_upd%NOTFOUND;

        v_precio_anterior := v_producto.precio; -- guardo el precio antes de cambiarlo
        v_producto.precio := v_producto.precio * 1.10; -- le sumo el 10%

        -- actualizo la fila con el objeto ya modificado
        UPDATE productos_obj p
        SET p = v_producto
        WHERE CURRENT OF cursor_productos_upd;

        DBMS_OUTPUT.PUT_LINE('Precio anterior: $' || v_precio_anterior);
        DBMS_OUTPUT.PUT_LINE('Precio nuevo: $' || v_producto.precio);
    END LOOP;
    CLOSE cursor_productos_upd;
END;
/

-- Sesion 7

-- Crea un procedimiento aumentar_precio_producto que reciba un ProductoID y un 
-- porcentaje de aumento (como parámetros IN), y aumente el precio del producto en ese porcentaje. 
-- Maneja la excepción si el producto no existe.

CREATE OR REPLACE PROCEDURE aumentar_precio_producto(
    p_producto_id IN NUMBER,
    p_porcentaje  IN NUMBER
) AS
    v_filas_afectadas NUMBER;
BEGIN
    -- si llega un 10, multiplicará por 1.10
    UPDATE Productos
    SET Precio = Precio * (1 + (p_porcentaje / 100))
    WHERE ProductoID = p_producto_id;
    
    v_filas_afectadas := SQL%ROWCOUNT;
    
    IF v_filas_afectadas = 0 THEN
        RAISE NO_DATA_FOUND;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Precio actualizado correctamente. Producto ID: ' || p_producto_id);
    END IF;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error : El producto ID ' || p_producto_id || ' no existe.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END aumentar_precio_producto;
/

-- comando sql usado en git bash para comprobar procedimiento
-- EXEC aumentar_precio_producto(1, 15);


-- Crea un procedimiento contar_pedidos_cliente que reciba un ClienteID (parámetro IN) 
-- y devuelva la cantidad de pedidos de ese cliente (parámetro OUT). 
-- Si el cliente no tiene pedidos, devuelve 0.

CREATE OR REPLACE PROCEDURE contar_pedidos_cliente(
    p_cliente_id       IN NUMBER,
    p_cantidad_pedidos OUT NUMBER
) IS
BEGIN
   
    SELECT COUNT(*)
    INTO p_cantidad_pedidos
    FROM Pedidos
    WHERE ClienteID = p_cliente_id;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado validando cliente: ' || SQLERRM);
END contar_pedidos_cliente;
/

-- test
DECLARE
    v_resultado NUMBER;
BEGIN
    contar_pedidos_cliente(1, v_resultado);
    DBMS_OUTPUT.PUT_LINE('El cliente revisado tiene ' || v_resultado || ' pedidos en el sistema.');
END;
/


--- Ejercicios clase 16-04 sesion 8

-- Ejercicio 1: Escribe un cursor explícito que liste los pedidos con total mayor a 500 
-- y muestre el nombre del cliente asociado, usando un JOIN.

DECLARE CURSOR cursor_mayor_500 IS select clientes.nombre, pedidos.total 
    FROM Pedidos INNER JOIN Clientes ON Clientes.clienteid = Pedidos.clienteid
    WHERE total > 500;

    v_nombre_cliente clientes.nombre%TYPE;
    v_total_cliente pedidos.total%TYPE;

BEGIN
    OPEN cursor_mayor_500;
    LOOP
        FETCH
            cursor_mayor_500 INTO v_nombre_cliente, v_total_cliente;
            EXIT WHEN cursor_mayor_500%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_nombre_cliente || '- Pedido total: $' || v_total_cliente);
    END LOOP;
    CLOSE cursor_mayor_500;

END;
/


-- Ejercicio 2

-- Ejercicio 2: Escribe un cursor explícito que aumente un 15% los precios de productos con precio inferior a 1000 
-- y maneje una excepción si falla.

DECLARE CURSOR cursor_aumentar_15 IS 
    SELECT productos.nombre, productos.precio
    FROM Productos
    WHERE precio < 1000
    FOR UPDATE;

    var_nombre productos.nombre%TYPE;
    var_precio productos.precio%TYPE;
    var_precio_nuevo productos.precio%TYPE;

BEGIN
    OPEN cursor_aumentar_15;
    LOOP
        FETCH
            cursor_aumentar_15 INTO var_nombre, var_precio;
            EXIT WHEN cursor_aumentar_15%NOTFOUND;

            var_precio_nuevo := var_precio * 1.15;

            UPDATE Productos SET
            precio = var_precio_nuevo
            WHERE CURRENT OF cursor_aumentar_15; 

            DBMS_OUTPUT.PUT_LINE('Precio antiguo de ' || var_nombre || ': ' || var_precio);
            DBMS_OUTPUT.PUT_LINE('Precio nuevo de ' || var_nombre || ': ' || var_precio_nuevo);
    END LOOP;
    CLOSE cursor_aumentar_15;
END;
/
COMMIT;

-- Ejercicio 3: Escribe un bloque PL/SQL con un cursor explícito que liste los clientes 
-- cuyo total de pedidos (suma de los valores de Total en la tabla Pedidos) sea mayor a 1000
-- mostrando el nombre del cliente y el total acumulado. Usa un JOIN entre Clientes y Pedidos
-- y agrupa los resultados con GROUP BY.

DECLARE
    cursor cursor_clientes_top is
        select c.nombre, SUM(p.total) as total_acumulado
        from clientes c
        inner join pedidos p on c.clienteid = p.clienteid
        GROUP BY c.ClienteID, c.Nombre
        HAVING SUM(p.Total) > 1000;
        
    v_nombre Clientes.Nombre%TYPE;
    v_total_acumulado NUMBER;
begin
    open cursor_clientes_top;
    loop
        fetch cursor_clientes_top into v_nombre, v_total_acumulado;
        exit when cursor_clientes_top%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_nombre || ' - Total Acumulado: $' || v_total_acumulado);
    end loop;
    close cursor_clientes_top;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        IF cursor_clientes_top%ISOPEN THEN
            close cursor_clientes_top;
        end IF;
END;
/


-- Ejercicio 4: Escribe un bloque PL/SQL con un cursor explícito que aumente en 1 la cantidad de
-- los detalles de pedidos (DetallesPedidos) asociados a pedidos con
-- fecha anterior al 2 de marzo de 2025 (FechaPedido en la tabla Pedidos).
-- Usa FOR UPDATE para bloquear las filas y maneja excepciones.

declare
    cursor cursor_detalles is
        SELECT dp.detalleid, dp.cantidad, p.fechapedido
        FROM detallespedidos dp
        INNER JOIN pedidos p on dp.pedidoid = p.pedidoid
        WHERE p.fechapedido < TO_DATE('2025-03-02', 'YYYY-MM-DD')
        FOR UPDATE of dp.cantidad;
        
    var_detalle_id detallespedidos.detalleid%TYPE;
    var_cantidad detallespedidos.cantidad%TYPE;
    var_fecha_pedido pedidos.fechapedido%TYPE;
    var_nueva_cantidad NUMBER;
BEGIN
    OPEN cursor_detalles;
    LOOP
        fetch cursor_detalles into var_detalle_id, var_cantidad, var_fecha_pedido;
        exit when cursor_detalles%NOTFOUND;
        
        var_nueva_cantidad := var_cantidad + 1;
        
        update detallespedidos
        set cantidad = var_nueva_cantidad
        WHERE CURRENT OF cursor_detalles;
        
        DBMS_OUTPUT.PUT_LINE('Detalle ID: ' || var_detalle_id || ' | Cantidad anterior: ' || var_cantidad || ' | Nueva: ' || var_nueva_cantidad);
    END LOOP;
    CLOSE cursor_detalles;
    
    COMMIT;
exception
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        if cursor_detalles%ISOPEN THEN
            close cursor_detalles;
        END if;
END;
/

-- Ejercicio 5: Crea un tipo de objeto cliente_obj con los atributos cliente_id, nombre, 
-- y un método get_info que devuelva una cadena con la información del cliente. 
-- Crea una tabla basada en ese tipo, transfiere los datos de la tabla Clientes a esa tabla, 
-- y escribe un bloque PL/SQL con un cursor explícito que liste la información de los clientes 
-- usando el método get_info.

CREATE OR REPLACE TYPE cliente_obj2 AS OBJECT (
    cliente_id NUMBER,
    nombre VARCHAR2(50),
    MEMBER FUNCTION get_info RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY cliente_obj2 AS
    MEMBER FUNCTION get_info RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Cliente ID: ' || cliente_id || ' | Nombre: ' || nombre;
    END;
END;
/

CREATE TABLE clientes_obj2 OF cliente_obj2 (cliente_id PRIMARY KEY);

INSERT INTO clientes_obj2 (cliente_id, nombre)
SELECT ClienteID, Nombre FROM Clientes;
COMMIT;

DECLARE
    CURSOR cursor_clientes_obj IS
        SELECT VALUE(c) FROM clientes_obj2 c;
        
    v_cliente cliente_obj2;
BEGIN
    OPEN cursor_clientes_obj;
    LOOP
        FETCH cursor_clientes_obj INTO v_cliente;
        EXIT WHEN cursor_clientes_obj%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(v_cliente.get_info());
    END LOOP;
    CLOSE cursor_clientes_obj;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        IF cursor_clientes_obj%ISOPEN THEN
            CLOSE cursor_clientes_obj;
        END IF;
END;
/

-- Sesion 10

-- Crea un procedimiento actualizar_total_pedidos que reciba un ClienteID (parámetro IN) y 
-- un porcentaje de aumento (parámetro IN con valor por defecto 10%). 
-- Aumenta el total de todos los pedidos del cliente en el porcentaje especificado. 
-- Usa un bucle para iterar sobre los pedidos.

CREATE OR REPLACE PROCEDURE actualizar_total_pedidos(p_cliente_id IN NUMBER, p_porcentaje IN NUMBER DEFAULT 10) AS
    v_nuevo_total NUMBER;
    
    CURSOR c_pedidos IS
        SELECT pedidoid, total 
        FROM pedidos 
        WHERE clienteid = p_cliente_id
        FOR UPDATE; 
BEGIN
    FOR pedido_actual IN c_pedidos LOOP
        
        v_nuevo_total := pedido_actual.total * (1 + (p_porcentaje / 100));
        
        UPDATE Pedidos 
        SET total = v_nuevo_total
        WHERE CURRENT OF c_pedidos;
        
        DBMS_OUTPUT.PUT_LINE('Pedido ID ' || pedido_actual.pedidoid || ' actualizado. - Nuevo total: $' || v_nuevo_total);
        
    END LOOP;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrió un error: ' || SQLERRM);
        ROLLBACK; -- deshacer si ocurrio algun problema, aquí no pasó nada
END;
/

EXEC actualizar_total_pedidos(1);

-- ej 2

-- Crea un procedimiento calcular_costo_detalle que reciba un DetalleID (parámetro IN) y 
-- devuelva el costo total del detalle (parámetro IN OUT). El costo se calcula 
-- como Precio * Cantidad (usando las tablas DetallesPedidos y Productos). 
-- Maneja excepciones si el detalle no existe.

CREATE OR REPLACE PROCEDURE calcular_costo_detalle(p_detalle_id IN NUMBER, p_costo_total IN OUT NUMBER) AS
    var_precio NUMBER;
    var_cantidad NUMBER;
BEGIN
    -- consulta con el inner join para traer precio y cantidad
    SELECT p.Precio, dpedido.Cantidad
    INTO var_precio, var_cantidad
    FROM detallesPedidos dpedido
    INNER JOIN productos p ON dpedido.ProductoID = p.ProductoID
    WHERE dpedido.DetalleID = p_detalle_id;
    
    -- hago el calculo y lo guardo en el parametro de salida in out
    p_costo_total := var_precio * var_cantidad;
    
    DBMS_OUTPUT.PUT_LINE('Costo calculado para detalle ' || p_detalle_id || ': $' || p_costo_total);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Detalle con id: ' || p_detalle_id || ' no se encontró');        
END;
/

DECLARE
    v_resultado NUMBER := 0; -- variable para recibir el parámetro de salida
BEGIN

    calcular_costo_detalle(1, v_resultado);
    calcular_costo_detalle(1234, v_resultado);
END;
/


-- Sesion 11

-- Una funcion siempre debe devolver un valor, a diferencia de los procedimientos almacenados
-- usa return (tipo dato), dentro de la funcion usar return valor.

-- Crea una función calcular_edad_cliente que reciba un ClienteID (parámetro IN) y 
-- devuelva la edad del cliente en años (basado en FechaNacimiento). 
-- Maneja excepciones si el cliente no existe.

CREATE OR REPLACE FUNCTION calcular_edad_cliente(p_cliente_id IN NUMBER) 
RETURN NUMBER AS
    var_fecha_nac DATE; -- declaro variable para guardar la fecha traida de la bd
    var_edad NUMBER; -- declaro variable para guardar el calculo
BEGIN
    -- implemento la consulta para obtener la fecha de nacimiento del cliente
    SELECT FechaNacimiento 
    INTO var_fecha_nac
    FROM Clientes
    WHERE ClienteID = p_cliente_id;
    
    -- hago el calculo (MONTHS_BETWEEN saca los meses, dividido en 12 nos da los años, y TRUNC le quita los decimales)
    var_edad := TRUNC(MONTHS_BETWEEN(SYSDATE, var_fecha_nac) / 12);
    
    -- obligatorio devolver el resultado
    RETURN var_edad;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Cliente con ID ' || p_cliente_id || ' no encontrado.');

END;
/

-- probando codigo
DECLARE 
    var_edad NUMBER;
BEGIN
    var_edad := calcular_edad_cliente(1);
    DBMS_OUTPUT.PUT_LINE('Edad del cliente 1: ' || var_edad);
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/

-- Crea una función obtener_precio_promedio que devuelva el precio promedio de todos 
-- los productos. Úsala en una consulta SQL para listar los productos cuyo precio 
-- está por encima del promedio.

CREATE OR REPLACE FUNCTION obtener_precio_promedio 
RETURN NUMBER AS
    var_promedio NUMBER; -- declaro variable para guardar el calculo
BEGIN
    -- implemento la consulta usando la funcion de agregacion AVG
    SELECT AVG(Precio) INTO var_promedio
    FROM productos;
    
    -- retorno el resultado
    RETURN var_promedio;
END;
/

-- implemento la consulta SQL usando la funcion en la condicion WHERE mas la funcion creada
SELECT productoid, nombre, precio 
FROM productos 
WHERE precio > obtener_precio_promedio();

-- SESION 12

-- Crea una función calcular_total_con_descuento que reciba un PedidoID (parámetro IN) 
-- y devuelva el total del pedido con un descuento del 10% si el total supera 1000. 
-- Usa la función en un procedimiento aplicar_descuento_pedido que actualice el total del pedido.

-- funcion encargada del calculo
CREATE OR REPLACE FUNCTION calcular_total_con_descuento(p_pedido_id IN NUMBER) 
RETURN NUMBER AS
    var_total_actual NUMBER; 
BEGIN
    -- implemento la consulta para traer el total actual
    SELECT Total 
    INTO var_total_actual
    FROM pedidos 
    WHERE pedidoid = p_pedido_id;
    
    
    IF var_total_actual > 1000 THEN
        var_total_actual := var_total_actual * 0.90; -- descuento
    END IF;
    
    RETURN var_total_actual;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20004, 'Pedido con ID ' || p_pedido_id || ' no encontrado.');
END;
/

-- paso 2 procedimiento que actualiza la base de datos usando la funcion
CREATE OR REPLACE PROCEDURE aplicar_descuento(p_pedido_id IN NUMBER) AS
    var_nuevo_total NUMBER; -- declaro variable para atrapar el return de la funcion
BEGIN
    var_nuevo_total := calcular_total_con_descuento(p_pedido_id);
    
    -- actualizo la base de datos
    UPDATE Pedidos 
    SET Total = var_nuevo_total
    WHERE PedidoID = p_pedido_id;
    
    DBMS_OUTPUT.PUT_LINE('Pedido ' || p_pedido_id || ' actualizado - Total final: $' || var_nuevo_total);
    COMMIT; 
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/

EXEC aplicar_descuento(101)

-- Crea un trigger validar_cantidad_detalle que se dispare antes de insertar o actualizar 
-- en DetallesPedidos y verifique que la Cantidad sea mayor a 0. Si no, lanza un error.

CREATE OR REPLACE TRIGGER validar_cantidad_detalle
BEFORE INSERT OR UPDATE ON DetallesPedidos
FOR EACH ROW
BEGIN
    -- :NEW se usa para acceder y evaluar el dato nuevo o entrante ANTES de que se guarde oficialmente en la tabla
    IF :NEW.Cantidad <= 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Error de validación: La cantidad debe ser mayor a 0. Valor ingresado: ' || :NEW.Cantidad);
    END IF;
END;
/
-- error
INSERT INTO DetallesPedidos (DetalleID, PedidoID, ProductoID, Cantidad) VALUES (342, 101, 1, 0);
-- no error
INSERT INTO DetallesPedidos (DetalleID, PedidoID, ProductoID, Cantidad) VALUES (1245, 101, 1, 2);

-- SESION 13

-- Crea un procedimiento actualizar_inventario_pedido que reciba un PedidoID (parámetro IN) y 
-- reduzca la cantidad de productos en una tabla Inventario (crea la tabla si no existe) según los detalles del pedido. 
-- Usa savepoints para manejar errores si no hay suficiente inventario.

-- 1. crear la tabla
CREATE TABLE Inventario (
    ProductoID NUMBER PRIMARY KEY,
    CantidadDisponible NUMBER,
    CONSTRAINT fk_inv_producto FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);
    

INSERT INTO Inventario (ProductoID, CantidadDisponible) VALUES (1, 10); -- 10 laptops
INSERT INTO Inventario (ProductoID, CantidadDisponible) VALUES (2, 50); -- 50 mouses


-- 2. procedimiento
CREATE OR REPLACE PROCEDURE actualizar_inventario_pedido(p_pedido_id IN NUMBER) AS
    v_cantidad_disponible NUMBER;
    v_nueva_cantidad NUMBER;
    
    CURSOR c_detalles IS
        SELECT ProductoID, Cantidad 
        FROM DetallesPedidos 
        WHERE PedidoID = p_pedido_id;
        
BEGIN

    FOR detalle IN c_detalles LOOP
        SELECT CantidadDisponible 
        INTO v_cantidad_disponible
        FROM Inventario 
        WHERE ProductoID = detalle.ProductoID
        FOR UPDATE;
        
        SAVEPOINT antes_de_actualizar;
        
        v_nueva_cantidad := v_cantidad_disponible - detalle.Cantidad;
        
        -- validar si hay suficiente inventario
        IF v_nueva_cantidad < 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No hay suficiente inventario para el Producto ID: ' || detalle.ProductoID);
        END IF;
        
        UPDATE Inventario 
        SET CantidadDisponible = v_nueva_cantidad
        WHERE ProductoID = detalle.ProductoID;
        
        DBMS_OUTPUT.PUT_LINE('Producto ID ' || detalle.ProductoID || ' actualizado - Nueva cantidad disponible: ' || v_nueva_cantidad);
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Inventario actualizado exitosamente para el pedido: ' || p_pedido_id);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Producto solicitado no encontrado en el inventario.');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK TO antes_de_actualizar;
        COMMIT; -- El profe guarda los cambios de los productos exitosos antes del error
END;
/

-- EXEC actualizar_inventario_pedido(101);

-- Diseña una tabla de hechos Fact_Pedidos y una dimensión Dim_Ciudad para un Data Warehouse 
-- basado en curso_topicos. Escribe una consulta analítica que muestre el total de ventas por 
-- ciudad y año.

CREATE TABLE Dim_Ciudad (
	CiudadID NUMBER PRIMARY KEY,
	Ciudad VARCHAR2(50)
);
INSERT INTO Dim_Ciudad (CiudadID, Ciudad)
SELECT ROWNUM, Ciudad
FROM (SELECT DISTINCT Ciudad FROM Clientes);

CREATE TABLE Fact_Pedidos (
	PedidoID NUMBER,
	ClienteID NUMBER,
	CiudadID NUMBER,
	FechaID NUMBER,
	Total NUMBER,
	CONSTRAINT fk_pedido_cliente FOREIGN KEY (ClienteID) REFERENCES Dim_Cliente(ClienteID),
	CONSTRAINT fk_pedido_ciudad FOREIGN KEY (CiudadID) REFERENCES Dim_Ciudad(CiudadID),
	CONSTRAINT fk_pedido_tiempo FOREIGN KEY (FechaID) REFERENCES Dim_Tiempo(FechaID)
);
INSERT INTO Fact_Pedidos (PedidoID, ClienteID, CiudadID, FechaID, Total)
SELECT p.PedidoID, p.ClienteID, dc.CiudadID, dt.FechaID, p.Total
FROM Pedidos p
JOIN Clientes c ON p.ClienteID = c.ClienteID
JOIN Dim_Ciudad dc ON c.Ciudad = dc.Ciudad
JOIN Dim_Tiempo dt ON p.FechaPedido = dt.Fecha;

SELECT dc.Ciudad, dt.Año, SUM(fp.Total) AS TotalVentas
FROM Fact_Pedidos fp
JOIN Dim_Ciudad dc ON fp.CiudadID = dc.CiudadID
JOIN Dim_Tiempo dt ON fp.FechaID = dt.FechaID
GROUP BY dc.Ciudad, dt.Año;
