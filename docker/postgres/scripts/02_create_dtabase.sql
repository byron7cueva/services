/* Creacte database */
SET TIME ZONE 'America/Guayaquil';
ALTER DATABASE postgres SET timezone TO 'America/Guayaquil';

CREATE DATABASE localdb
WITH OWNER "admin"
ENCODING "UTF8";

ALTER DATABASE localdb SET timezone TO 'America/Guayaquil';