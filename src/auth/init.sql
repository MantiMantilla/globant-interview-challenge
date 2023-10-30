DROP DATABASE IF EXISTS auth;

DROP DATABASE IF EXISTS employment;

DROP USER IF EXISTS 'auth_user'@'%';
DROP USER IF EXISTS 'auth_user'@'localhost';
DROP USER IF EXISTS 'auth_user'@'host.minikube.internal';
DROP USER IF EXISTS 'auth_user'@'0.0.0.0';

CREATE USER 'auth_user'@'%' IDENTIFIED BY 'Admin123';
CREATE USER 'auth_user'@'localhost' IDENTIFIED BY 'Admin123';
CREATE USER 'auth_user'@'host.minikube.internal' IDENTIFIED BY 'Admin123';
CREATE USER 'auth_user'@'0.0.0.0' IDENTIFIED BY 'Admin123';

CREATE DATABASE auth;
USE auth;

GRANT ALL PRIVILEGES ON auth.* TO 'auth_user'@'%';
-- GRANT ALL PRIVILEGES ON auth.* TO 'auth_user'@'localhost';
-- GRANT ALL PRIVILEGES ON auth.* TO 'auth_user'@'host.minikube.internal';
-- GRANT ALL PRIVILEGES ON auth.* TO 'auth_user'@'0.0.0.0';

CREATE TABLE user (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL
);

INSERT INTO user (email, password) VALUES ('alejoman@email.com', 'Admin123');

CREATE DATABASE employment;

GRANT ALL PRIVILEGES ON employment.* TO 'auth_user'@'%';
GRANT ALL PRIVILEGES ON employment.* TO 'auth_user'@'localhost';
GRANT ALL PRIVILEGES ON employment.* TO 'auth_user'@'host.minikube.internal';
GRANT ALL PRIVILEGES ON employment.* TO 'auth_user'@'0.0.0.0';

USE employment;

CREATE TABLE hired_employees (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    datetime VARCHAR(255),
    department_id INT NOT NULL,
    job_id INT NOT NULL
);

CREATE TABLE departments (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    department VARCHAR(255) NOT NULL
);

CREATE TABLE jobs (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    job VARCHAR(255) NOT NULL
);
