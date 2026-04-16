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

-- AVANCE A MODIFICAR 
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

