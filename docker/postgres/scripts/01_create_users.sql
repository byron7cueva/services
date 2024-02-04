CREATE USER admin WITH PASSWORD 'admin';
/* User for develop */
CREATE USER "develop"
WITH PASSWORD 'develop';
ALTER USER develop WITH NOSUPERUSER;