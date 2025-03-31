Modify master-init.sql to Enable Logical Replication
Update master-init.sql to configure pg_master as a publisher:


CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'replicator';
ALTER SYSTEM SET wal_level = 'logical';
ALTER SYSTEM SET max_replication_slots = 10;
ALTER SYSTEM SET max_wal_senders = 10;

-- Create testDB database
CREATE DATABASE testDB;

\c testDB;

-- Create orders table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    product_name TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    order_date DATE NOT NULL
);

-- Insert sample data
INSERT INTO orders (product_name, quantity, order_date) VALUES
('Smartphone', 10, '2024-04-01'),
('Tablet', 7, '2024-04-02'),
('Headphones', 25, '2024-04-03'),
('Smartwatch', 12, '2024-04-04');

-- Create a publication for the orders table
CREATE PUBLICATION orders_pub FOR TABLE orders;

2. Modify replica-init.sh to Configure pg_replica as a Subscriber
Create a replica-init.sh script to configure pg_replica:


#!/bin/bash
PGDATA="/var/lib/postgresql/data"

if [ ! -s "$PGDATA/PG_VERSION" ]; then
  echo "Initializing replica..."
  PGPASSWORD=admin pg_basebackup -h pg_master -D $PGDATA -U replicator -Fp -Xs -R -P

  echo "Setting up logical replication..."
  echo "host replication replicator pg_master trust" >> $PGDATA/pg_hba.conf
  echo "host all all 0.0.0.0/0 trust" >> $PGDATA/pg_hba.conf

  echo "Restarting PostgreSQL to apply changes..."
  pg_ctl -D $PGDATA -m fast -w restart

  echo "Creating subscription..."
  PGPASSWORD=admin psql -h localhost -U admin -d testDB -c \"
  CREATE SUBSCRIPTION orders_sub CONNECTION 'host=pg_master port=5432 dbname=testDB user=admin password=admin' PUBLICATION orders_pub;
  \"
fi
3. Validate Replication
After running the setup, insert a new row in pg_master:


INSERT INTO orders (product_name, quantity, order_date) VALUES ('Laptop', 5, '2024-04-05');
Then, check if it appears in pg_replica:


SELECT * FROM orders;
This setup ensures that all changes in orders from pg_master are automatically replicated to pg_replica
