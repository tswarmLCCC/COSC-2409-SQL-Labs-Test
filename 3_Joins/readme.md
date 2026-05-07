Automated Data Load

This week, the data setup is automated. Follow these steps to prepare your environment:

Open your terminal in Codespaces.

Ensure you are in the correct directory:
cd units/01-store-data/

Run the setup script:
bash setup_automated.sh

This script will:

Create the relational schema.

Download the 51,000+ row Global Superstore CSV.

Bulk load the data into a staging table.

Populate the dim_customers, dim_products, dim_locations, and fact_orders tables.
