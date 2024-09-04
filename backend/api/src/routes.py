import enum
from functools import partial
from typing import Dict, Tuple
from fastapi import APIRouter
from crud_forge.generators import models, routes, enums
import sqlalchemy
from .db import db_manager

# * Generate enum routes
db_enums: Dict[str, Dict[str, Tuple[type[sqlalchemy.Enum], type[enum.Enum]]]] = enums.from_metadata(db_manager)

enums_router: APIRouter = enums.gen_enum_routes(db_manager.enums, db_manager.get_db)


# * Generate CRUD routes (for each schema in the database)
db_schemas = db_manager.metadata.keys()  # Get all schemas from the database
all_models = models.from_metadata(db_manager)  # Generate Pydantic & SQLAlchemy models for each schema

# Generate CRUD operations for each schema
schema_routers: dict[str, APIRouter] = {
    schema: APIRouter(prefix=f"/{schema}", tags=[schema])  # Remove '_management' from the schema name
    # schema: APIRouter(prefix=f"/{schema.replace('_management', '')}")  # Remove '_management' from the schema name
    for schema in db_schemas}  # * for all schemas in the database


def gen_crud_per_schema(router: APIRouter, models: dict):
    """Generate CRUD operations for a schema's models."""
    [routes.crud.gen_crud(sqlalchemy_model, pydantic_model, router, db_manager.get_db) for sqlalchemy_model, pydantic_model in models.values()]

[gen_crud_per_schema(schema_routers[schema], all_models[schema]) for schema in db_schemas]  # Generate CRUD operations for each schema

# Include each router in the main 'crud_attr' router
crud_attr: APIRouter = APIRouter()
[crud_attr.include_router(router) for router in schema_routers.values()]

# ^ Expose routers globally (for use in the main FastAPI application)
globals().update(schema_routers)  # Update the global namespace with the routers
globals()['crud_attr'] = crud_attr  # Update the global namespace with the main 'crud_attr' router


# * Generate metadata routes
metadata: APIRouter = routes.gen_metadata_routes(db_manager.metadata, db_manager.get_db)

# * Generate test routes
test: APIRouter = APIRouter(tags=["test"])

for method in ["get", "post", "put", "delete"]:
    test.add_api_route(f"/test", partial(lambda method: f"{method.upper()} request to /test route", method=method), methods=[method])


# ^ Expose the metadata and test routers globally (for use in the main FastAPI application)
globals()['metadata'] = metadata  # Update the global namespace with the metadata router
globals()['test'] = test  # Update the global namespace with the test router
