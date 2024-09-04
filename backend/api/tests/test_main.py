# * Import the TestClient class from fastapi.testclient
from fastapi.testclient import TestClient
import pytest

# * Import the FastAPI application from the main module
from src.main import app  # Replace 'your_app_module' with the actual module where your FastAPI app is defined


# Create a test client
client = TestClient(app)

def test_robots_txt():
    """
    Test the /test/robots.txt endpoint.
    
    This test checks if:
    1. The endpoint returns a 200 status code
    2. The content type is text/plain
    3. The response contains expected directives
    4. The response doesn't contain any HTML (ensuring it's plain text)
    """
    response = client.get("/test/robots.txt")
    
    # Check status code
    assert response.status_code == 200, "Should return 200 OK"
    
    # Check content type
    assert response.headers["content-type"] == "text/plain; charset=utf-8", "Should return plain text"
    
    # * Check content
    content = response.text
    # todo: Uncomment the following lines after implementing the robots.txt endpoint
    # todo: Replace the expected_content with the actual content of your robots.txt file
    # todo: You can also add more specific checks for the content of the robots.txt file
    # assert "User-agent: *" in content, "Should specify User-agent"
    # assert "Disallow: /admin/" in content, "Should disallow /admin/"
    # assert "Disallow: /private/" in content, "Should disallow /private/"
    # assert "Allow: /" in content, "Should allow /"
    # assert "Sitemap:" in content, "Should include Sitemap"
    
    # Ensure it's not HTML
    assert "<html>" not in content, "Should not contain HTML"
    assert "<body>" not in content, "Should not contain HTML"

    # Optional: Check for exact content match
    expected_content = """
User-agent: *
Disallow: /admin/
Disallow: /private/
Allow: /

Sitemap: 'still working on it...'
    """.strip()
    assert content == expected_content, "Content should exactly match expected robots.txt"

def test_robots_txt_no_trailing_slash():
    """
    Test that the /test/robots.txt endpoint works without a trailing slash.
    """
    response = client.get("/test/robots.txt")
    assert response.status_code == 200, "Should return 200 OK even without trailing slash"

@pytest.mark.parametrize("invalid_path", [
    "/test/robots",
    "/test/ROBOTS.TXT",
    "/robots.txt",
])
def test_invalid_robots_txt_paths(invalid_path):
    """
    Test that invalid variations of the robots.txt path return 404.
    """
    response = client.get(invalid_path)
    assert response.status_code == 404, f"Should return 404 for invalid path: {invalid_path}"
