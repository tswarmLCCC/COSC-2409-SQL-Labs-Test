#!/bin/bash

# 1. Define Variables
CSV_URL="https://raw.githubusercontent.com/pg-shakti/superstore-analysis/master/superstore_dataset.csv"
CSV_FILE="superstore.csv"
DB_NAME="postgres"

echo "--- Starting Automated Superstore Load ---"

# 2. Run the SQL Schema Setup
echo "Creating tables and schema..."
psql -d $DB_NAME -f load_data.sql

# 3. Download the Data
if [ ! -f "$CSV_FILE" ]; then
    echo "Downloading Global Superstore dataset (51k rows)..."
    curl -L -o $CSV_FILE $CSV_URL
else
    echo "Dataset already exists, skipping download."
fi

# 4. Bulk Load into Staging
echo "Bulk loading CSV into staging table..."
psql -d $DB_NAME -c "\copy staging_superstore FROM '$CSV_FILE' WITH (FORMAT csv, HEADER true, ENCODING 'latin1');"

# 5. Distribute Data to Relational Schema
echo "Transforming staging data into Star Schema..."
psql -d $DB_NAME <<EOF
-- Populate Customers
INSERT INTO dim_customers (customer_id, customer_name, segment)
SELECT DISTINCT customer_id, customer_name, segment FROM staging_superstore
ON CONFLICT (customer_id) DO NOTHING;

-- Populate Products
INSERT INTO dim_products (product_id, product_name, category, sub_category)
SELECT DISTINCT product_id, product_name, category, sub_category FROM staging_superstore
ON CONFLICT (product_id) DO NOTHING;

-- Populate Locations
INSERT INTO dim_locations (city, state, country, region, market)
SELECT DISTINCT city, state, country, region, market FROM staging_superstore;

-- Populate Fact Table
-- Note: This joins staging back to dimensions to get the Primary Keys (PKs)
INSERT INTO fact_orders (order_uuid, order_date, ship_date, ship_mode, customer_id, product_id, city, sales, quantity, discount, profit, shipping_cost, order_priority)
SELECT 
    order_id, order_date, ship_date, ship_mode, customer_id, product_id, city, 
    sales, quantity, discount, profit, shipping_cost, order_priority 
FROM staging_superstore;

-- Clean up staging if desired
-- DROP TABLE staging_superstore;
EOF

echo "--- Setup Complete! 51,000+ rows loaded. ---"

