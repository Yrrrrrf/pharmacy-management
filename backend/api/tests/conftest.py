"""
This file contains pytest fixtures that can be used across multiple test files.
Fixtures defined here are automatically available to all test functions in the project.
"""
from fastapi.testclient import TestClient
# from sqlalchemy.orm import sessionmaker
# from sqlalchemy import create_engine
import pytest

# * Own packages
# from src.database import get_db, Base
from src.main import app


@pytest.fixture(scope="module")
def test_client():
    return TestClient(app)


# # Test database URL
# SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"

# @pytest.fixture(scope="session")
# def test_db_engine():
#     """
#     Create a test database engine.
#     This fixture has session scope, meaning it's created once per test session.
#     """
#     engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
#     Base.metadata.create_all(bind=engine)
#     yield engine
#     Base.metadata.drop_all(bind=engine)

# @pytest.fixture(scope="function")
# def db_session(test_db_engine):
#     """
#     Create a new database session for a test.
#     This fixture has function scope, meaning it's created once per test function.
#     """
#     TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_db_engine)
#     db = TestingSessionLocal()
#     try:
#         yield db
#     finally:
#         db.close()

# @pytest.fixture(scope="function")
# def client(db_session):
#     """
#     Create a new FastAPI TestClient.
#     This fixture has function scope and depends on the db_session fixture.
#     """
#     def override_get_db():
#         try:
#             yield db_session
#         finally:
#             db_session.close()
    
#     app.dependency_overrides[get_db] = override_get_db
#     return TestClient(app)

# @pytest.fixture(scope="function")
# def test_user(client):
#     """
#     Create a test user.
#     This fixture has function scope and depends on the client fixture.
#     """
#     user_data = {"username": "testuser", "email": "test@example.com", "password": "testpassword"}
#     response = client.post("/users/", json=user_data)
#     assert response.status_code == 201
#     return response.json()
