"""
test_api.py

This module contains automated tests for the Academic Hub API endpoints.
It reads test cases from an HTTP file and executes them using pytest.

The module uses the requests library to make HTTP calls and pytest for the test framework.
It's designed to test the specific endpoints defined in the 'get_specific.http' file.

Usage:
    Run this file directly using Python, or use pytest to execute the tests.
    Make sure your API server is running before executing the tests.

    ```
    python test_api.py
    pytest test_api.py
    ```

Dependencies:
    - pytest
    - requests

Author: Reza Campos Fernando Bryan
Date: 12th August, 2024
"""

import pytest
import requests
import re
import os
import ast

# Base URL for the API. Modify this if your API is hosted elsewhere.
BASE_URL = "http://localhost:8000"

# Get the directory of the current script
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

def parse_http_file(file_path):
    """
    Parse the given HTTP file and extract request information.

    This function reads an HTTP file and extracts the method, URL, and expected
    response for each request defined in the file.

    Args:
        file_path (str): Relative path to the HTTP file from the script directory.

    Returns:
        list: A list of tuples, each containing (method, url, expected_response)
              for a single request.

    Raises:
        FileNotFoundError: If the specified HTTP file is not found.
    """
    full_path = os.path.join(SCRIPT_DIR, file_path)
    
    with open(full_path, 'r') as file:
        content = file.read()
    
    # Split the content into individual requests
    requests = re.split(r'\n###', content)
    
    parsed_requests = []
    for req in requests:
        if not req.strip():
            continue
        
        # Extract method and URL
        match = re.search(r'(GET|POST|PUT|DELETE) (.*) HTTP', req)
        if match:
            method, url = match.groups()
            
            # Remove any leading/trailing whitespace from the URL
            url = url.strip()
            
            # Extract expected response if present
            expected_response = None
            response_match = re.search(r'Expected Response:\n#(.*?)(?=\n###|\Z)', req, re.DOTALL)
            if response_match:
                response_str = response_match.group(1).replace('#', '').strip()
                try:
                    expected_response = ast.literal_eval(response_str)
                except (SyntaxError, ValueError) as e:
                    print(f"Error parsing expected response: {e}")
                    print(f"Problematic response string: {response_str}")
            
            parsed_requests.append((method, url, expected_response))
    
    return parsed_requests

parsed_requests = parse_http_file("http/get_specific.http")

@pytest.mark.parametrize("method,url,expected_response", parsed_requests)
def test_api_endpoints(method, url, expected_response):
    """
    Test individual API endpoints.

    This function is used as a test case for each request defined in the HTTP file.
    It sends a request to the specified endpoint and checks the response.

    Args:
        method (str): The HTTP method (GET, POST, etc.) for the request.
        url (str): The URL path for the request.
        expected_response (dict): The expected JSON response from the API.

    Raises:
        AssertionError: If the response status code is not 200 or if the
                        response doesn't match the expected response.
    """
    # Remove the base URL if it's already present in the url
    if url.startswith(BASE_URL):
        full_url = url
    else:
        full_url = f"{BASE_URL}{url}"
    
    print(f"Sending request to: {full_url}")  # Debug print
    response = requests.request(method, full_url)
    
    assert response.status_code == 200, f"Request to {full_url} failed with status code {response.status_code}"
    
    if expected_response is not None:
        assert response.json() == expected_response, f"Response does not match expected for {full_url}"
    else:
        print(f"No expected response provided for {full_url}. Actual response: {response.json()}")


if __name__ == "__main__":
    parsed_requests = parse_http_file("http/get_specific.http")
    for method, url, expected_response in parsed_requests:
        print(f"Parsed request: Method: {method}, URL: {url}")
        print(f"Expected Response: {expected_response}")
        print("---")
    pytest.main([__file__])
    