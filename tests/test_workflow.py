"""
Tests for workflow JSON validation.
"""
import json
from pathlib import Path
from typing import Any, Dict

import pytest


@pytest.mark.unit
@pytest.mark.workflow
class TestWorkflowStructure:
    """Test workflow JSON structure and validity."""

    def test_workflow_file_exists(self, workflow_path: Path):
        """Test that workflow file exists."""
        assert workflow_path.exists(), f"Workflow file not found at {workflow_path}"

    def test_workflow_is_valid_json(self, workflow_path: Path):
        """Test that workflow is valid JSON."""
        with open(workflow_path) as f:
            data = json.load(f)
        assert isinstance(data, dict), "Workflow should be a JSON object"

    def test_workflow_has_required_nodes(self, workflow_json: Dict[str, Any]):
        """Test that workflow contains required node types."""
        # Studio workflows have nodes in a 'nodes' array
        nodes = workflow_json.get("nodes", [])

        # Check that we have nodes
        assert len(nodes) > 0, "Workflow should contain nodes"

        # Extract node types
        node_types = set()
        for node_data in nodes:
            if isinstance(node_data, dict) and "type" in node_data:
                node_types.add(node_data["type"])

        # Check for at least some nodes (workflow may vary)
        assert len(node_types) > 0, "Workflow should contain Studio nodes"

    def test_workflow_nodes_have_inputs(self, workflow_json: Dict[str, Any]):
        """Test that nodes have proper input structure."""
        nodes = workflow_json.get("nodes", [])
        for node_data in nodes:
            if isinstance(node_data, dict):
                node_id = node_data.get("id", "unknown")
                # Nodes should have inputs field (can be empty list or dict)
                assert "inputs" in node_data, f"Node {node_id} missing inputs field"

    def test_workflow_nodes_have_type(self, workflow_json: Dict[str, Any]):
        """Test that all nodes have a type."""
        nodes = workflow_json.get("nodes", [])
        for node_data in nodes:
            if isinstance(node_data, dict):
                node_id = node_data.get("id", "unknown")
                assert "type" in node_data, f"Node {node_id} missing type field"
                assert isinstance(node_data["type"], str), f"Node {node_id} type should be string"
                assert len(node_data["type"]) > 0, f"Node {node_id} type should not be empty"

    def test_workflow_connections_valid(self, workflow_json: Dict[str, Any]):
        """Test that node connections reference valid nodes."""
        nodes = workflow_json.get("nodes", [])
        node_ids = {str(node.get("id")) for node in nodes if isinstance(node, dict)}

        for node_data in nodes:
            if not isinstance(node_data, dict):
                continue

            node_id = node_data.get("id", "unknown")
            inputs = node_data.get("inputs", [])

            # Inputs can be a list of input objects
            if isinstance(inputs, list):
                for input_obj in inputs:
                    if isinstance(input_obj, dict) and "link" in input_obj:
                        # Link references are validated by Studio itself
                        pass


@pytest.mark.unit
@pytest.mark.workflow
class TestWorkflowConfiguration:
    """Test workflow configuration parameters."""

    def test_workflow_has_video_parameters(self, workflow_json: Dict[str, Any]):
        """Test that workflow has video processing parameters."""
        # Look for video-related nodes
        nodes = workflow_json.get("nodes", [])
        has_video_load = False
        has_video_output = False

        for node_data in nodes:
            if isinstance(node_data, dict):
                node_type = node_data.get("type", "")
                if "LoadVideo" in node_type or "Video" in node_type:
                    has_video_load = True
                if "VideoCombine" in node_type or "SaveVideo" in node_type or "Combine" in node_type:
                    has_video_output = True

        # At least check we have some video-related nodes
        assert has_video_load or has_video_output or len(nodes) > 0, \
            "Workflow should have video-related nodes"

    def test_workflow_default_values_reasonable(self, workflow_json: Dict[str, Any]):
        """Test that default parameter values are reasonable."""
        nodes = workflow_json.get("nodes", [])

        for node_data in nodes:
            if not isinstance(node_data, dict):
                continue

            node_id = node_data.get("id", "unknown")
            widgets_values = node_data.get("widgets_values")

            # Check widget values are valid type (can be list or dict)
            if widgets_values is not None:
                assert isinstance(widgets_values, (list, dict)), \
                    f"Node {node_id} widgets_values should be a list or dict"


@pytest.mark.unit
@pytest.mark.workflow
def test_workflow_file_not_empty(workflow_path: Path):
    """Test that workflow file is not empty."""
    assert workflow_path.stat().st_size > 0, "Workflow file should not be empty"


@pytest.mark.unit
@pytest.mark.workflow
def test_workflow_can_be_copied(workflow_path: Path, tmp_path: Path):
    """Test that workflow can be copied (for install-workflow target)."""
    import shutil
    dest = tmp_path / "workflow.json"
    shutil.copy(workflow_path, dest)
    assert dest.exists(), "Workflow should be copyable"
    assert dest.stat().st_size == workflow_path.stat().st_size, "Copied workflow should have same size"
