#!/bin/bash
set -e

echo ">>> Installing PostgreSQL..."
sudo apt-get update -y -qq
sudo apt-get install -y -qq postgresql postgresql-contrib

echo ">>> Starting PostgreSQL..."
sudo service postgresql start

echo ">>> Configuring user and database..."
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'password123';"
sudo -u postgres createdb classroom

echo ">>> Fixing authentication..."
sudo sed -i 's/local   all             postgres                                peer/local   all             postgres                                md5/' /etc/postgresql/*/main/pg_hba.conf
sudo sed -i 's/host    all             all             127.0.0.1\/32            scram-sha-256/host    all             all             127.0.0.1\/32            md5/' /etc/postgresql/*/main/pg_hba.conf
sudo service postgresql restart

echo ">>> Loading lab seed data..."
for seed in $(find /workspaces -name "seed.sql" | sort); do
  echo "  Loading $seed..."
  PGPASSWORD=password123 psql -U postgres -d classroom -f "$seed"
done

echo ">>> Done! Database is ready."
