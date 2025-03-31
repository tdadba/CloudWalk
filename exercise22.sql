CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'replicator';
ALTER SYSTEM SET wal_level = 'replica';
ALTER SYSTEM SET max_wal_senders = 10;
ALTER SYSTEM SET hot_standby = on;

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

