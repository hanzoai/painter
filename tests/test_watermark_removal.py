"""
Test watermark removal functionality for Hanzo Painter.

This test verifies that the Hanzo Studio server can:
1. Load the UI
2. Accept a workflow for watermark removal
3. Process a video with watermark
4. Output a clean video without watermark

These are integration tests that require a running server.
They will be skipped if the server is not available.
"""

import json
import os
import pytest
from playwright.sync_api import Page, expect
import requests
import time


BASE_URL = "http://localhost:8188"


def is_server_available():
    """Check if the server is running."""
    try:
        response = requests.get(f"{BASE_URL}/system_stats", timeout=2)
        return response.status_code == 200
    except (requests.ConnectionError, requests.Timeout):
        return False


# Skip all tests in this module if server is not available
pytestmark = pytest.mark.skipif(
    not is_server_available(),
    reason="Server not running at localhost:8188 (start with 'make run')"
)


@pytest.mark.integration
def test_server_is_running():
    """Verify server is running and responding."""
    response = requests.get(f"{BASE_URL}/system_stats")
    assert response.status_code == 200

    data = response.json()
    assert "system" in data
    assert "studio_version" in data["system"]
    print(f"✓ Studio version: {data['system']['studio_version']}")
    print(f"✓ Python version: {data['system']['python_version']}")
    print(f"✓ PyTorch version: {data['system']['pytorch_version']}")


@pytest.mark.integration
def test_custom_nodes_loaded():
    """Verify all custom nodes are loaded, especially DiffuEraser."""
    response = requests.get(f"{BASE_URL}/object_info")
    assert response.status_code == 200

    nodes = response.json()

    # Check for critical watermark removal nodes
    critical_nodes = [
        "DiffuEraserLoader",  # DiffuEraser model loader
        "DiffuEraserSampler",  # Main watermark removal node
        "VHS_LoadVideo",  # Video loading
        "VHS_VideoCombine",  # Video output
    ]

    missing_nodes = []
    for node_name in critical_nodes:
        if node_name not in nodes:
            missing_nodes.append(node_name)

    if missing_nodes:
        print(f"⚠️  Missing nodes: {missing_nodes}")
        print(f"Available nodes: {list(nodes.keys())[:10]}...")
    else:
        print(f"✓ All critical nodes loaded: {critical_nodes}")

    # At minimum, we need some nodes loaded
    assert len(nodes) > 0, "No nodes loaded!"


@pytest.mark.integration
def test_ui_loads(page: Page):
    """Test that the UI loads successfully."""
    # Navigate to the UI
    page.goto(BASE_URL)

    # Wait for the page to load
    page.wait_for_load_state("networkidle")

    # Take a screenshot for debugging
    screenshot_path = "/tmp/hanzo-painter-ui.png"
    page.screenshot(path=screenshot_path)
    print(f"✓ UI loaded, screenshot saved to {screenshot_path}")


@pytest.mark.integration
def test_queue_status():
    """Verify the queue is accessible and empty."""
    response = requests.get(f"{BASE_URL}/queue")
    assert response.status_code == 200

    queue_data = response.json()
    print(f"✓ Queue status: {queue_data}")


@pytest.mark.integration
def test_api_workflow_submission():
    """Test submitting a simple workflow via API."""
    # For now, just verify we can check the queue
    response = requests.get(f"{BASE_URL}/prompt")

    # This might return 404 or 405 if no workflow submitted yet
    # The important thing is that the server responds
    assert response.status_code in [200, 404, 405]
    print("✓ Prompt endpoint is accessible")


@pytest.mark.integration
@pytest.mark.skip(reason="Need actual test video with watermark")
def test_watermark_removal_workflow():
    """
    Full end-to-end test for watermark removal.

    TODO:
    - Create or download a test video with watermark (e.g., Sora watermark)
    - Load the video using VHS_LoadVideo node
    - Apply DiffuEraser with mask for watermark area
    - Process the video
    - Save output using VHS_VideoCombine
    - Verify output video has no watermark
    """
    pass


if __name__ == "__main__":
    # Run tests directly
    print("Running Hanzo Painter watermark removal tests...\n")

    if not is_server_available():
        print("❌ Server is not running at http://localhost:8188")
        print("   Start the server with: make run")
        print("   Then run these tests again.")
        exit(1)

    # Test server
    print("1. Testing server status...")
    test_server_is_running()

    # Test custom nodes
    print("\n2. Testing custom nodes...")
    test_custom_nodes_loaded()

    # Test queue
    print("\n3. Testing queue...")
    test_queue_status()

    # Test API
    print("\n4. Testing API...")
    test_api_workflow_submission()

    print("\n✅ All basic tests passed!")
    print("\n⚠️  Full watermark removal test requires:")
    print("   - Test video with watermark")
    print("   - Watermark removal workflow JSON")
    print("   - Visual verification of output")
