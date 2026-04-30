#!/bin/bash
set -e

export PGPASSWORD=password123
export PGHOST=localhost
export PGUSER=postgres
export PGDATABASE=classroom

# 1. Define Variables
CSV_URL="https://raw.githubusercontent.com/karanjadavid/Global-SuperStore-Sales-Analysis/master/Global_Superstore.csv"
CSV_FILE="$(pwd)/superstore.csv"

echo "--- Starting Automated Superstore Load ---"

# 2. Run the SQL Schema Setup
echo "Creating tables and schema..."
psql -f load_data.sql

# 3. Download the Data
if [ ! -f "$CSV_FILE" ]; then
    echo "Downloading Global Superstore dataset..."
    curl -L -o "$CSV_FILE" "$CSV_URL"
fi

# Verify we got actual data, delete and exit if too small
LINES=$(wc -l < "$CSV_FILE")
if [ "$LINES" -lt 100 ]; then
    echo "ERROR: CSV too small ($LINES lines). Deleting and exiting."
    rm "$CSV_FILE"
    exit 1
fi
echo "CSV looks good: $LINES rows"

# 4. Bulk Load into Staging
echo "Bulk loading CSV into staging table..."
psql -c "\copy staging_superstore FROM '$CSV_FILE' WITH (FORMAT csv, HEADER true, ENCODING 'latin1');"

# 5. Distribute Data to Relational Schema
echo "Transforming staging data into Star Schema..."
psql <<EOF
INSERT INTO dim_customers (customer_id, customer_name, segment)
SELECT DISTINCT customer_id, customer_name, segment FROM staging_superstore
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO dim_products (product_id, product_name, category, sub_category)
SELECT DISTINCT product_id, product_name, category, sub_category FROM staging_superstore
ON CONFLICT (product_id) DO NOTHING;

INSERT INTO dim_locations (city, state, country, region, market)
SELECT DISTINCT city, state, country, region, market FROM staging_superstore;

INSERT INTO fact_orders (order_uuid, order_date, ship_date, ship_mode, customer_id, product_id, city, sales, quantity, discount, profit, shipping_cost, order_priority)
SELECT 
    order_id,
    TO_DATE(order_date, 'DD-MM-YYYY'),
    TO_DATE(ship_date, 'DD-MM-YYYY'),
    ship_mode, customer_id, product_id, city,
    sales::NUMERIC,
    quantity::INTEGER,
    discount::NUMERIC,
    profit::NUMERIC,
    shipping_cost::NUMERIC,
    order_priority
FROM staging_superstore;
EOF

echo "--- Setup Complete! ---"
psql -c "SELECT COUNT(*) AS fact_rows FROM fact_orders;"
<<<<<<< HEAD

=======
>>>>>>> 36f144a (	modified:   .devcontainer/devcontainer.json)
