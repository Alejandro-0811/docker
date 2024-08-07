CREATE DATABASE IF NOT EXISTS Flask_SF;
USE Flask_SF;

CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(255),
    contraseña VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE especialistas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    especialidad VARCHAR(100),
    direccion VARCHAR(255),
    sobre_mi TEXT,
    contraseña VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE citas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    especialista_id INT NOT NULL,
    fecha_cita DATE NOT NULL,
    hora_cita TIME NOT NULL,
    motivo VARCHAR(255),
    estado ENUM('realizada', 'cancelada', 'pendiente', 'aceptada', 'rechazada') DEFAULT 'pendiente',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (especialista_id) REFERENCES especialistas(id)
);

CREATE TABLE bitacora (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tabla VARCHAR(50),
    operacion VARCHAR(50),
    registro_id INT,
    datos TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE PROCEDURE CrearUsuario (
    IN p_nombre VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_telefono VARCHAR(20),
    IN p_direccion VARCHAR(255),
    IN p_contraseña VARCHAR(255)
)
BEGIN
    INSERT INTO usuarios (nombre, email, telefono, direccion, contraseña)
    VALUES (p_nombre, p_email, p_telefono, p_direccion, p_contraseña);
END //

CREATE PROCEDURE CrearEspecialista (
    IN p_nombre VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_telefono VARCHAR(20),
    IN p_especialidad VARCHAR(100),
    IN p_direccion VARCHAR(255),
    IN p_sobre_mi TEXT,
    IN p_contraseña VARCHAR(255)
)
BEGIN
    INSERT INTO especialistas (nombre, email, telefono, especialidad, direccion, sobre_mi, contraseña)
    VALUES (p_nombre, p_email, p_telefono, p_especialidad, p_direccion, p_sobre_mi, p_contraseña);
END //

CREATE PROCEDURE CrearCita (
    IN p_usuario_id INT,
    IN p_especialista_id INT,
    IN p_fecha_cita DATE,
    IN p_hora_cita TIME,
    IN p_motivo VARCHAR(255)
)
BEGIN
    INSERT INTO citas (usuario_id, especialista_id, fecha_cita, hora_cita, motivo)
    VALUES (p_usuario_id, p_especialista_id, p_fecha_cita, p_hora_cita, p_motivo);
END //

CREATE PROCEDURE ActualizarEstadoCita (
    IN p_cita_id INT,
    IN p_nuevo_estado ENUM('realizada', 'cancelada', 'pendiente', 'aceptada', 'rechazada')
)
BEGIN
    DECLARE estado_actual ENUM('realizada', 'cancelada', 'pendiente', 'aceptada', 'rechazada');

    SELECT estado INTO estado_actual FROM citas WHERE id = p_cita_id;

    -- Verificar si el estado es 'cancelada'
    IF estado_actual = 'cancelada' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cita ya ha sido cancelada y no puede ser modificada.';
    ELSE
        UPDATE citas SET estado = p_nuevo_estado WHERE id = p_cita_id;
    END IF;
END //

-- Triggers para la tabla usuarios
CREATE TRIGGER after_insert_usuarios
AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, registro_id, datos)
    VALUES ('usuarios', 'INSERT', NEW.id, CONCAT('Nombre: ', NEW.nombre, ', Email: ', NEW.email, ', Teléfono: ', NEW.telefono, ', Dirección: ', NEW.direccion));
END //

CREATE TRIGGER after_update_usuarios
AFTER UPDATE ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, registro_id, datos)
    VALUES ('usuarios', 'UPDATE', NEW.id, CONCAT('Nombre: ', NEW.nombre, ', Email: ', NEW.email, ', Teléfono: ', NEW.telefono, ', Dirección: ', NEW.direccion));
END //

CREATE TRIGGER after_delete_usuarios
AFTER DELETE ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, registro_id, datos)
    VALUES ('usuarios', 'DELETE', OLD.id, CONCAT('Nombre: ', OLD.nombre, ', Email: ', OLD.email, ', Teléfono: ', OLD.telefono, ', Dirección: ', OLD.direccion));
END //

-- Triggers para la tabla especialistas
CREATE TRIGGER after_insert_especialistas
AFTER INSERT ON especialistas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, registro_id, datos)
    VALUES ('especialistas', 'INSERT', NEW.id, CONCAT('Nombre: ', NEW.nombre, ', Email: ', NEW.email, ', Teléfono: ', NEW.telefono, ', Especialidad: ', NEW.especialidad, ', Dirección: ', NEW.direccion, ', Sobre mí: ', NEW.sobre_mi));
END //

CREATE TRIGGER after_update_especialistas
AFTER UPDATE ON especialistas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, registro_id, datos)
    VALUES ('especialistas', 'UPDATE', NEW.id, CONCAT('Nombre: ', NEW.nombre, ', Email: ', NEW.email, ', Teléfono: ', NEW.telefono, ', Especialidad: ', NEW.especialidad, ', Dirección: ', NEW.direccion, ', Sobre mí: ', NEW.sobre_mi));
END //

CREATE TRIGGER after_delete_especialistas
AFTER DELETE ON especialistas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, registro_id, datos)
    VALUES ('especialistas', 'DELETE', OLD.id, CONCAT('Nombre: ', OLD.nombre, ', Email: ', OLD.email, ', Teléfono: ', OLD.telefono, ', Especialidad: ', OLD.especialidad, ', Dirección: ', OLD.direccion, ', Sobre mí: ', OLD.sobre_mi));
END //

-- Triggers para la tabla citas
CREATE TRIGGER after_insert_citas
AFTER INSERT ON citas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, registro_id, datos)
    VALUES ('citas', 'INSERT', NEW.id, CONCAT('Usuario ID: ', NEW.usuario_id, ', Especialista ID: ', NEW.especialista_id, ', Fecha Cita: ', NEW.fecha_cita, ', Hora Cita: ', NEW.hora_cita, ', Motivo: ', NEW.motivo, ', Estado: ', NEW.estado));
END //

CREATE TRIGGER after_update_citas
AFTER UPDATE ON citas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, registro_id, datos)
    VALUES ('citas', 'UPDATE', NEW.id, CONCAT('Usuario ID: ', NEW.usuario_id, ', Especialista ID: ', NEW.especialista_id, ', Fecha Cita: ', NEW.fecha_cita, ', Hora Cita: ', NEW.hora_cita, ', Motivo: ', NEW.motivo, ', Estado: ', NEW.estado));
END //

CREATE TRIGGER after_delete_citas
AFTER DELETE ON citas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, registro_id, datos)
    VALUES ('citas', 'DELETE', OLD.id, CONCAT('Usuario ID: ', OLD.usuario_id, ', Especialista ID: ', OLD.especialista_id, ', Fecha Cita: ', OLD.fecha_cita, ', Hora Cita: ', OLD.hora_cita, ', Motivo: ', OLD.motivo, ', Estado: ', OLD.estado));
END //

DELIMITER ;

CREATE DATABASE IF NOT EXISTS Flask_SF;
USE Flask_SF;

CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(255),
    contraseña VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE especialistas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    especialidad VARCHAR(100),
    direccion VARCHAR(255),
    sobre_mi TEXT,
    contraseña VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE citas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    especialista_id INT NOT NULL,
    fecha_cita DATE NOT NULL,
    hora_cita TIME NOT NULL,
    motivo VARCHAR(255),
    estado ENUM('realizada', 'cancelada', 'pendiente', 'aceptada', 'rechazada') DEFAULT 'pendiente',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (especialista_id) REFERENCES especialistas(id)
);

CREATE TABLE bitacora (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tabla VARCHAR(50),
    operacion VARCHAR(50),
    registro_id INT,
    datos TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE PROCEDURE CrearUsuario (
    IN p_nombre VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_telefono VARCHAR(20),
    IN p_direccion VARCHAR(255),
    IN p_contraseña VARCHAR(255)
)
BEGIN
    INSERT INTO usuarios (nombre, email, telefono, direccion, contraseña)
    VALUES (p_nombre, p_email, p_telefono, p_direccion, p_contraseña);
END //

CREATE PROCEDURE CrearEspecialista (
    IN p_nombre VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_telefono VARCHAR(20),
    IN p_especialidad VARCHAR(100),
    IN p_direccion VARCHAR(255),
    IN p_sobre_mi TEXT,
    IN p_contraseña VARCHAR(255)
)
BEGIN
    INSERT INTO especialistas (nombre, email, telefono, especialidad, direccion, sobre_mi, contraseña)
    VALUES (p_nombre, p_email, p_telefono, p_especialidad, p_direccion, p_sobre_mi, p_contraseña);
END //

CREATE PROCEDURE CrearCita (
    IN p_usuario_id INT,
    IN p_especialista_id INT,
    IN p_fecha_cita DATE,
    IN p_hora_cita TIME,
    IN p_motivo VARCHAR(255)
)
BEGIN
    INSERT INTO citas (usuario_id, especialista_id, fecha_cita, hora_cita, motivo)
    VALUES (p_usuario_id, p_especialista_id, p_fecha_cita, p_hora_cita, p_motivo);
END //

CREATE PROCEDURE ActualizarEstadoCita (
    IN p_cita_id INT,
    IN p_nuevo_estado ENUM('realizada', 'cancelada', 'pendiente', 'aceptada', 'rechazada')
)
BEGIN
    DECLARE estado_actual ENUM('realizada', 'cancelada', 'pendiente', 'aceptada', 'rechazada');

    SELECT estado INTO estado_actual FROM citas WHERE id = p_cita_id;

    -- Verificar si el estado es 'cancelada'
    IF estado_actual = 'cancelada' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cita ya ha sido cancelada y no puede ser modificada.';
    ELSE
        UPDATE citas SET estado = p_nuevo_estado WHERE id = p_cita_id;
    END IF;
END //

-- Triggers para la tabla usuarios
CREATE TRIGGER after_insert_usuarios
AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, registro_id, datos)
    VALUES ('usuarios', 'INSERT', NEW.id, CONCAT('Nombre: ', NEW.nombre, ', Email: ', NEW.email, ', Teléfono: ', NEW.telefono, ', Dirección: ', NEW.direccion));
END //

CREATE TRIGGER after_update_usuarios
AFTER UPDATE ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, registro_id, datos)
    VALUES ('usuarios', 'UPDATE', NEW.id, CONCAT('Nombre: ', NEW.nombre, ', Email: ', NEW.email, ', Teléfono: ', NEW.telefono, ', Dirección: ', NEW.direccion));
END //

CREATE TRIGGER after_delete_usuarios
AFTER DELETE ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, registro_id, datos)
    VALUES ('usuarios', 'DELETE', OLD.id, CONCAT('Nombre: ', OLD.nombre, ', Email: ', OLD.email, ', Teléfono: ', OLD.telefono, ', Dirección: ', OLD.direccion));
END //

-- Triggers para la tabla especialistas
CREATE TRIGGER after_insert_especialistas
AFTER INSERT ON especialistas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, registro_id, datos)
    VALUES ('especialistas', 'INSERT', NEW.id, CONCAT('Nombre: ', NEW.nombre, ', Email: ', NEW.email, ', Teléfono: ', NEW.telefono, ', Especialidad: ', NEW.especialidad, ', Dirección: ', NEW.direccion, ', Sobre mí: ', NEW.sobre_mi));
END //

CREATE TRIGGER after_update_especialistas
AFTER UPDATE ON especialistas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, registro_id, datos)
    VALUES ('especialistas', 'UPDATE', NEW.id, CONCAT('Nombre: ', NEW.nombre, ', Email: ', NEW.email, ', Teléfono: ', NEW.telefono, ', Especialidad: ', NEW.especialidad, ', Dirección: ', NEW.direccion, ', Sobre mí: ', NEW.sobre_mi));
END //

CREATE TRIGGER after_delete_especialistas
AFTER DELETE ON especialistas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, registro_id, datos)
    VALUES ('especialistas', 'DELETE', OLD.id, CONCAT('Nombre: ', OLD.nombre, ', Email: ', OLD.email, ', Teléfono: ', OLD.telefono, ', Especialidad: ', OLD.especialidad, ', Dirección: ', OLD.direccion, ', Sobre mí: ', OLD.sobre_mi));
END //

-- Triggers para la tabla citas
CREATE TRIGGER after_insert_citas
AFTER INSERT ON citas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, registro_id, datos)
    VALUES ('citas', 'INSERT', NEW.id, CONCAT('Usuario ID: ', NEW.usuario_id, ', Especialista ID: ', NEW.especialista_id, ', Fecha Cita: ', NEW.fecha_cita, ', Hora Cita: ', NEW.hora_cita, ', Motivo: ', NEW.motivo, ', Estado: ', NEW.estado));
END //

CREATE TRIGGER after_update_citas
AFTER UPDATE ON citas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, registro_id, datos)
    VALUES ('citas', 'UPDATE', NEW.id, CONCAT('Usuario ID: ', NEW.usuario_id, ', Especialista ID: ', NEW.especialista_id, ', Fecha Cita: ', NEW.fecha_cita, ', Hora Cita: ', NEW.hora_cita, ', Motivo: ', NEW.motivo, ', Estado: ', NEW.estado));
END //

CREATE TRIGGER after_delete_citas
AFTER DELETE ON citas
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, registro_id, datos)
    VALUES ('citas', 'DELETE', OLD.id, CONCAT('Usuario ID: ', OLD.usuario_id, ', Especialista ID: ', OLD.especialista_id, ', Fecha Cita: ', OLD.fecha_cita, ', Hora Cita: ', OLD.hora_cita, ', Motivo: ', OLD.motivo, ', Estado: ', OLD.estado));
END //

DELIMITER ;

SELECT * FROM usuarios;
SELECT * FROM especialistas;
SELECT * FROM citas;
SELECT * FROM administradores;
SELECT * FROM bitacora;
SELECT * FROM vista_especialistas;