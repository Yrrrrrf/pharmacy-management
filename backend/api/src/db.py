from forge import APIForge, DBForge, DBConfig
from forge.gen.metadata import get_metadata_router
from fastapi import APIRouter
import os


db_manager: DBForge = DBForge(config=DBConfig(
    # * Set the database type and driver type
    db_type='postgresql',  # 'postgresql', 'mysql', 'sqlite'
    driver_type='sync',  # 'async', 'sync'
    #  * Set the database connection parameters (& default values)
    database=os.environ.get('DB_NAME') or 'pharmacy_management',
    user=os.environ.get('DB_OWNER_ADMIN') or 'pharmacy_management_owner',
    password=os.environ.get('DB_OWNER_PWORD') or 'secure_pharmacy_pwd',
    host=os.environ.get('DB_HOST') or 'localhost',
))

metadata: APIRouter = get_metadata_router(db_manager.metadata)

# Set the schemas to be generated...
# todo: Add some other way to define the schemas to be generated

# todo: Like... All the schemas available for some user
# todo: This way, the app can be used as a multi-tenant app
# todo: And the user can only see the schemas they have access to

schemas = [
    "pharma",
    "management",
]

# I think this method belongs to the forge module (it's a helper method)
def gen_schema_routes(schema: str, db_manager: DBForge, router: APIRouter) -> APIRouter:
    api_forge: APIForge = APIForge(
        db_manager=db_manager,
        router=router,
        include_schemas=[schema],
        # exclude_tables=["some-table"],
    )
    api_forge.genr_crud()  # * Generate the CRUD routes (for the schema)
    api_forge.p_schemas(schemas=[schema])
    return router

# todo: Also, add a way to define the schemas to be generated
schema_routers: list[APIRouter] = [gen_schema_routes(schema, db_manager, APIRouter(prefix=f"/{schema}", tags=[schema.upper()])) for schema in schemas]

print("\nTotal Routes:")
for schema, router in zip(schemas, schema_routers):
    print(f"\033[92m{len(router.routes):>8}\033[0m \033[1m{schema}\033[0m \033[90m`{router.prefix}`\033[0m") 


# print the total count of routes generated depending on the schemas
print(f"\033[94m{sum([len(router.routes) for router in schema_routers]):>8}\033[0m\n")
