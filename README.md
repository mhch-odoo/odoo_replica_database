# Odoo with Primary and Replica Databases

This guide explains how to set up an Odoo instance with a primary database and a replica database. This is only supported on odoo 18 and onwards

## Prerequisites

- Odoo installed
- PostgreSQL installed

## Configuration

1. **Configure PostgreSQL for Replication**

    Ensure that your PostgreSQL primary and replica databases are correctly configured for replication. Refer to the PostgreSQL documentation for detailed instructions.

    https://www.postgresql.org/docs/current/runtime-config-replication.html

    > Example

    <ins>Note: This example requires docker to be installed</ins>

    - For this example we use 2 containerized instances of Postgres 17. The config is defined in [docker-compose.yml](./docker-compose.yml). `postgres_primary` is the primary database and `postgres_replica` is the replica server.

        <ins>**Primary**</ins>

        - First, we setup the db and add **replicator** with Replication rights and other users to access the db as defined in [00_init.sql](./00_init.sql).
        - `POSTGRES_HOST_AUTH_METHOD` is required to have replication rule to allow access.
        - Configure `WAL (Write-Ahead Logging)` on the primary server according to your requirements. This allows the primary database to stream all the changes to the replica/standby databases.

        <ins>**Replica**</ins>
        - Replica can be setup with `pg_basebackup` of the primary. The user should have access to the primary database and must have replication rights.
        - For details check `pg_basebackup` documentation.

    - To start the setup in the example install docker and run the following.
        ```bash
        docker compose up
        ```
    - You should have no errors and both databases should be up.


2. **Odoo Configuration**

    Edit the `odoo.conf` file to include the primary and replica databases.

    ```ini
    [options]
    db_name = primary_db_name
    db_user = db_user
    db_password = db_password
    db_host = primary_db_host
    db_port = primary_db_port
    db_replica_host = replica_db_host
    db_replica_port = replica_db_port
    ```

3. **Start Odoo**

    Start your Odoo instance with the updated configuration.

    ```bash
    ./odoo-bin -c /path/to/odoo.conf
    ```

    >To test the example here. Run the following from odoo community directory

    ```bash
    ./odoo-bin -d tests --addons-path=./addons,../enterprise --db_user=odoo --db_password=odoo --db_host=localhost --db_port=5434 --db_replica_host=localhost --db_replica_port=5433

    ```

## Verifying the Setup

1. **Check Databases**

    Ensure that the primary database is running and accessible. `pg_activity` can be used to view the activity on both database servers.

    ```bash
    psql -h primary_db_host -U db_user -d primary_db_name
    ```
    ```bash
    pg_activity postgresql://odoo:odoo@localhost:5434/tests
    ```

    Ensure that the replica database is running and accessible.

    ```bash
    psql -h replica_db_host -U replica_db_user -d primary_db_name
    ```
    ```bash
    pg_activity postgresql://odoo:odoo@localhost:5433/tests
    ```

3. **Odoo Logs**

    Check the Odoo logs to ensure that it is connecting to both the primary and replica databases without issues. The logs should mention 2 databases.

    ```log
    2024-11-22 06:54:51,544 543334 INFO ? odoo: database: odoo@localhost:5434
    2024-11-22 06:54:51,544 543334 INFO ? odoo: replica database: odoo@localhost:5433
    ```

    And you can confirm the with **rw** and **ro** at the end of each query to indicate read-write and read-only respectively.

    ```log
    2024-11-22 06:56:03,403 543334 INFO tests werkzeug: ... 200 - 3 0.001 0.005 rw
    2024-11-22 06:56:03,436 543334 INFO tests werkzeug: ... 304 - 2 0.003 0.008 ro
    ```

## Conclusion

Your Odoo instance should now be running with a primary database and a replica database. This setup helps in load balancing of database queries for your odoo appication.

For more detailed information, refer to the official Odoo and PostgreSQL documentation.
