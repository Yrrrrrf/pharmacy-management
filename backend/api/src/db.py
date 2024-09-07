from crud_forge.db import DatabaseManager
import os

# * Environment Variables
DB = {
    'NAME': os.environ.get('DB_NAME') or 'pharmacy_management',
    'HOST': os.environ.get('DB_HOST') or 'localhost',  # localhost by default
    # or use DB_HOST='host.docker.internal' to connect to host machine from docker container
    'ADMIN': os.environ.get('DB_OWNER_ADMIN') or 'pharmacy_management_owner',
    'PWORD': os.environ.get('DB_OWNER_PWORD') or 'secure_pharmacy_pwd',
}

# * Database Connection
db_url: str = f"postgresql://{DB['ADMIN']}:{DB['PWORD']}@{DB['HOST']}/{DB['NAME']}"
db_manager: DatabaseManager = DatabaseManager(db_url=db_url)
