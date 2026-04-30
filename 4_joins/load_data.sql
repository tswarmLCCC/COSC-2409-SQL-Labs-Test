-- Drop tables if they exist (for clean reruns)
DROP TABLE IF EXISTS fact_orders;
DROP TABLE IF EXISTS dim_locations;
DROP TABLE IF EXISTS dim_products;
DROP TABLE IF EXISTS dim_customers;
DROP TABLE IF EXISTS staging_superstore;

-- Staging table (raw CSV dump, all text to avoid type errors on load)
CREATE TABLE staging_superstore (
    row_id          TEXT,
    order_id        TEXT,
    order_date      TEXT,
    ship_date       TEXT,
    ship_mode       TEXT,
    customer_id     TEXT,
    customer_name   TEXT,
    segment         TEXT,
    city            TEXT,
    state           TEXT,
    country         TEXT,
    postal_code     TEXT,
    market          TEXT,
    region          TEXT,
    product_id      TEXT,
    category        TEXT,
    sub_category    TEXT,
    product_name    TEXT,
    sales           TEXT,
    quantity        TEXT,
    discount        TEXT,
    profit          TEXT,
    shipping_cost   TEXT,
    order_priority  TEXT
);

-- Dimension: Customers
CREATE TABLE dim_customers (
    customer_id     TEXT PRIMARY KEY,
    customer_name   TEXT,
    segment         TEXT
);

-- Dimension: Products
CREATE TABLE dim_products (
    product_id      TEXT PRIMARY KEY,
    product_name    TEXT,
    category        TEXT,
    sub_category    TEXT
);

-- Dimension: Locations
CREATE TABLE dim_locations (
    location_id     SERIAL PRIMARY KEY,
    city            TEXT,
    state           TEXT,
    country         TEXT,
    region          TEXT,
    market          TEXT
);

-- Fact: Orders
CREATE TABLE fact_orders (
    order_uuid      TEXT,
    order_date      DATE,
    ship_date       DATE,
    ship_mode       TEXT,
    customer_id     TEXT REFERENCES dim_customers(customer_id),
    product_id      TEXT REFERENCES dim_products(product_id),
    city            TEXT,
    sales           NUMERIC(10,2),
    quantity        INTEGER,
    discount        NUMERIC(5,4),
    profit          NUMERIC(10,2),
    shipping_cost   NUMERIC(10,2),
    order_priority  TEXT
);
<<<<<<< HEAD

=======
>>>>>>> 36f144a (	modified:   .devcontainer/devcontainer.json)
