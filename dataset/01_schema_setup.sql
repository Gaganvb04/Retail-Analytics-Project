-- ============================================================
-- 01_schema_setup.sql
-- Retail Operations & Customer Analytics Project
-- PostgreSQL Schema Creation + Data Load Instructions
-- ============================================================

-- STEP 1: Create a dedicated database (run this once, from psql or pgAdmin)
-- ------------------------------------------------------------
-- CREATE DATABASE retail_analytics;
-- Then connect to it: \c retail_analytics   (in psql)

-- STEP 2: Create tables
-- ------------------------------------------------------------

DROP TABLE IF EXISTS logistics;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id       VARCHAR(15) PRIMARY KEY,
    age               SMALLINT NOT NULL CHECK (age BETWEEN 0 AND 120),
    gender            VARCHAR(10),
    income            INTEGER,
    city              VARCHAR(50),
    region            VARCHAR(20),
    email             VARCHAR(100),
    phone             VARCHAR(15),
    signup_date       DATE,
    customer_segment  VARCHAR(20)
);

CREATE TABLE inventory (
    product_id            VARCHAR(15) PRIMARY KEY,
    product_name          VARCHAR(100),
    category              VARCHAR(50),
    stock                 INTEGER,
    reorder_level         INTEGER,
    warehouse             VARCHAR(50),
    unit_price            NUMERIC(10,2),
    supplier              VARCHAR(100),
    last_restocked_date   DATE
);

CREATE TABLE employees (
    employee_id          VARCHAR(15) PRIMARY KEY,
    employee_name        VARCHAR(100),
    region               VARCHAR(20),
    team                 VARCHAR(30),
    sales_target         INTEGER,
    hire_date            DATE,
    email                VARCHAR(100),
    performance_rating   NUMERIC(2,1)
);

CREATE TABLE logistics (
    shipment_id       VARCHAR(15) PRIMARY KEY,
    customer_id       VARCHAR(15) REFERENCES customers(customer_id),
    product_id        VARCHAR(15) REFERENCES inventory(product_id),
    shipment_date     DATE,
    delivery_days     SMALLINT,
    carrier           VARCHAR(30),
    cost              NUMERIC(10,2),
    status            VARCHAR(20),
    quantity          SMALLINT,
    discount_applied  NUMERIC(3,2),
    payment_mode      VARCHAR(30)
);

-- Helpful indexes for join/filter performance (good talking point: "I indexed FK columns")
CREATE INDEX idx_logistics_customer ON logistics(customer_id);
CREATE INDEX idx_logistics_product  ON logistics(product_id);
CREATE INDEX idx_logistics_carrier  ON logistics(carrier);
CREATE INDEX idx_logistics_date     ON logistics(shipment_date);
CREATE INDEX idx_customers_city     ON customers(city);
CREATE INDEX idx_customers_region   ON customers(region);
CREATE INDEX idx_customers_segment  ON customers(customer_segment);
CREATE INDEX idx_logistics_payment  ON logistics(payment_mode);

-- ============================================================
-- STEP 3: Load CSV data
-- ============================================================
-- OPTION A — psql command line (fastest, run from a terminal where psql is installed):
--
--   psql -U your_username -d retail_analytics -c "\COPY customers FROM 'Customers.csv' DELIMITER ',' CSV HEADER;"
--   psql -U your_username -d retail_analytics -c "\COPY inventory FROM 'Inventory.csv' DELIMITER ',' CSV HEADER;"
--   psql -U your_username -d retail_analytics -c "\COPY employees FROM 'Employees.csv' DELIMITER ',' CSV HEADER;"
--   psql -U your_username -d retail_analytics -c "\COPY logistics FROM 'Logistics.csv' DELIMITER ',' CSV HEADER;"
--
-- IMPORTANT: load customers and inventory BEFORE logistics (foreign key dependency).
--
-- OPTION B — pgAdmin GUI:
--   Right-click each table -> Import/Export Data -> choose the matching CSV -> Format: csv -> Header: Yes
--
-- OPTION C — psql interactive shell (paste after connecting with \c retail_analytics):
--   \copy customers FROM '/full/path/to/Customers.csv' DELIMITER ',' CSV HEADER;
--   \copy inventory FROM '/full/path/to/Inventory.csv' DELIMITER ',' CSV HEADER;
--   \copy employees FROM '/full/path/to/Employees.csv' DELIMITER ',' CSV HEADER;
--   \copy logistics FROM '/full/path/to/Logistics.csv' DELIMITER ',' CSV HEADER;

-- STEP 4: Verify row counts after loading
-- ------------------------------------------------------------
SELECT 'customers' AS table_name, COUNT(*) FROM customers
UNION ALL
SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL
SELECT 'employees', COUNT(*) FROM employees
UNION ALL
SELECT 'logistics', COUNT(*) FROM logistics;

-- Expected: customers=100000, inventory=2000, employees=200, logistics=150000
