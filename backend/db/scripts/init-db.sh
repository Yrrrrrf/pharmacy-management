#!/bin/bash

# init-db.sh
# Purpose: Initialize the PostgreSQL database for the Pharmacy Management System
# This script executes all SQL files in the /init directory to set up the database schema and initial data

# Exit immediately if a command exits with a non-zero status
set -e

# Enable command echoing for debugging purposes
set -x

echo "Starting database initialization process..."

# Function to execute SQL file with variable substitution and error handling
execute_sql_file() {
    local file=$1
    echo "Executing $file..."
    
    # Display the content of the SQL file for debugging
    echo "Content of $file:"
    cat "$file"
    
    # Execute the SQL file
    if psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$file"; then
        echo "Successfully executed $file."
    else
        echo "Error executing $file. Check the PostgreSQL logs for more details."
        exit 1
    fi
}

# Execute schema setup script first
echo "Setting up database schema..."
execute_sql_file "/init/01-setup.sql"

# Execute all other SQL files in the /init directory
echo "Executing additional initialization scripts..."
for file in /init/*.sql; do
    if [ "$file" != "/init/01-setup.sql" ]; then
        execute_sql_file "$file"
    fi
done

# Verify database setup
echo "Verifying database setup..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- List all non-system schemas
    SELECT schema_name FROM information_schema.schemata 
    WHERE schema_name NOT IN ('pg_catalog', 'information_schema');

    -- List all tables in non-system schemas
    SELECT schemaname, tablename 
    FROM pg_tables 
    WHERE schemaname NOT IN ('pg_catalog', 'information_schema');
EOSQL

echo "Database initialization completed successfully."

# Final check for any errors
if [ $? -ne 0 ]; then
    echo "An error occurred during database initialization. Please check the logs."
    exit 1
fi

echo "Pharmacy Management System database is now ready for use."
