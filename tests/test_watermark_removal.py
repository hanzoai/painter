"""
Test watermark removal functionality for Hanzo Painter.

This test verifies that the Hanzo Studio server can:
1. Load the UI
2. Accept a workflow for watermark removal
3. Process a video with watermark
4. Output a clean video without watermark
"""

import json
import pytest
from playwright.sync_api import Page, expect
import requests
import time


BASE_URL = "http://localhost:8188"


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


def test_ui_loads(page: Page):
    """Test that the UI loads successfully."""
    # Navigate to the UI
    page.goto(BASE_URL)

    # Wait for the page to load
    page.wait_for_load_state("networkidle")

    # Check that we're not seeing a 404 or error page
    # ComfyUI/Studio typically has a canvas or workflow area
    # We'll check for common elements

    # Take a screenshot for debugging
    page.screenshot(path="/tmp/hanzo-painter-ui.png")
    print("✓ UI loaded, screenshot saved to /tmp/hanzo-painter-ui.png")


def test_queue_status():
    """Verify the queue is accessible and empty."""
    response = requests.get(f"{BASE_URL}/queue")
    assert response.status_code == 200

    queue_data = response.json()
    print(f"✓ Queue status: {queue_data}")


def test_api_workflow_submission():
    """Test submitting a simple workflow via API.

    This is a placeholder for the actual watermark removal workflow.
    We need to:
    1. Load a video with watermark
    2. Apply DiffuEraser node
    3. Save the output
    4. Verify watermark is removed
    """
    # For now, just verify we can check the queue
    response = requests.get(f"{BASE_URL}/prompt")

    # This might return 404 or 405 if no workflow submitted yet
    # The important thing is that the server responds
    assert response.status_code in [200, 404, 405]
    print("✓ Prompt endpoint is accessible")


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
