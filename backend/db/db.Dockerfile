# /backend/db/db.Dockerfile
# Dockerfile for Academic Hub Database
FROM postgres:16

# Set environment variables for database configuration
ENV POSTGRES_DB="pharmacy_management"
ENV POSTGRES_USER="pharmacy_management_owner"
ENV POSTGRES_PASSWORD="secure_pharmacy_pwd"
ENV LANG=en_US.utf8
ENV TZ=Etc/UTC

# Copy the schema setup SQL file
COPY init/01_schema_setup.sql /init/
COPY init/02_tables/*.sql /init/
# COPY init/03_data/*.sql /init/
# COPY init/04_data/*.sql /init/

# Copy the initialization script
COPY scripts/init-db.sh /docker-entrypoint-initdb.d/

# Make sure the script is executable
RUN chmod +x /docker-entrypoint-initdb.d/init-db.sh

# Expose the default PostgreSQL port
EXPOSE 5432
