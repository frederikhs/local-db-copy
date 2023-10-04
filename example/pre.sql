-- this file contains sql that runs before the database has been dumped.
CREATE ROLE my_role LOGIN SUPERUSER PASSWORD 'my_role';
CREATE DATABASE my_db OWNER eat_score ENCODING 'UTF-8' TEMPLATE template0;
