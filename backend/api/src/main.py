"""Main file for the FastAPI application"""
from fastapi import FastAPI
from forge.utils import Config, allow_all_middleware

from .db import schema_routers, metadata


app: FastAPI = FastAPI()
allow_all_middleware(app)  # Allow all middleware

config: Config = Config(  # * Set the configuration
    PROJECT_NAME= "Pharmacy Management System",
    VERSION = "v0.0.2",
    DESCRIPTION = "Comprehensive solution designed to streamline and modernize pharmacy operations",
    AUTHOR = "Yrrrrrf",
    EMAIL = "fernandorezacampos@gmail.com",
)
config.set_app_data(app)  # Set the app metadata
config.setup_logging()  # Setup logging (add some color to the logs)

# * Add the routes to the FastAPI application
[app.include_router(route) for route in [
    # enums_router,  # ^ Enum routes (for getting the enums in the database)
    metadata,  # Metadata routes (for getting metadata about the database)
    *schema_routers  # ^ unpack the routers
]]  # Include the routes in the FastAPI application

# * Startup event
def on_startup(): print("\n\n\033[92m" + f"Startup completed successfully!\n\n")

on_startup()  # Run the startup event
