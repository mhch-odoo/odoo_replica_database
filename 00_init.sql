CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replicator_password';
CREATE USER odoo ENCRYPTED PASSWORD 'odoo' SUPERUSER;
SELECT pg_create_physical_replication_slot('replication_slot');
