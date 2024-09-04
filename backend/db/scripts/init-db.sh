#!/bin/bash
set -e

echo "Executing database initialization scripts..."

# Function to execute SQL file with variable substitution
execute_sql_file() {
    local file=$1
    echo "Executing $file..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
$(sed \
#   Replace :'SCHEMA_AGNOSTIC' with the value of $SCHEMA_AGNOSTIC
#   * the $SCHEMA_AGNOSTIC variable is set in the Dockerfile or docker-compose.yml file
  -e "s|:'SCHEMA_AGNOSTIC'|'$SCHEMA_AGNOSTIC'|g" \
  "$file")
EOSQL
    echo "Completed executing $file."
}

# Execute schema setup script
execute_sql_file "/init/01_schema_setup.sql"

# Execute all SQL files in the /init directory (excluding 01_schema_setup.sql)
for file in /init/*.sql; do
    if [ "$file" != "/init/01_schema_setup.sql" ]; then
        execute_sql_file "$file"
    fi
done

echo "Database initialization completed successfully."