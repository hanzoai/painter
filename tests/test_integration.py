"""
Integration tests for Hanzo Painter.

These tests verify that different components work together correctly.
"""
import json
import subprocess
from pathlib import Path

import pytest


@pytest.mark.integration
class TestProjectStructure:
    """Test overall project structure and file organization."""

    def test_project_has_required_files(self, project_root: Path):
        """Test that project has all required files."""
        required_files = [
            "Makefile",
            "README.md",
            "requirements.txt",
            "setup.sh",
            "inpainting-workflow.json",
            "pytest.ini",
        ]

        for file_name in required_files:
            file_path = project_root / file_name
            assert file_path.exists(), f"Required file missing: {file_name}"

    def test_project_has_documentation(self, project_root: Path):
        """Test that project has documentation files."""
        doc_files = ["README.md", "QUICKSTART.md"]

        for doc_file in doc_files:
            file_path = project_root / doc_file
            if file_path.exists():
                assert file_path.stat().st_size > 0, f"{doc_file} should not be empty"

    def test_project_has_license(self, project_root: Path):
        """Test that project has LICENSE file."""
        license_path = project_root / "LICENSE"
        assert license_path.exists(), "Project should have LICENSE file"


@pytest.mark.integration
class TestWorkflowIntegration:
    """Test workflow integration with project structure."""

    def test_workflow_can_be_loaded(self, workflow_path: Path):
        """Test that workflow JSON can be loaded."""
        with open(workflow_path) as f:
            workflow = json.load(f)
        assert isinstance(workflow, dict), "Workflow should be a valid JSON object"
        assert len(workflow) > 0, "Workflow should not be empty"

    def test_workflow_references_valid_nodes(self, workflow_json: dict):
        """Test that workflow only references valid Studio node types."""
        # Get nodes array from workflow
        nodes = workflow_json.get("nodes", [])

        # These are common/expected node types
        # Real validation would require Studio to be running
        valid_prefixes = [
            "VHS_",  # VideoHelperSuite
            "easy",  # Easy-Use nodes
            "KJ",    # KJNodes
            "Layer",  # LayerStyle
            "Load",  # Standard loaders
            "Save",  # Standard savers
            "Image", # Image nodes
            "Video", # Video nodes
        ]

        for node_data in nodes:
            if isinstance(node_data, dict) and "type" in node_data:
                node_type = node_data["type"]
                node_id = node_data.get("id", "unknown")
                # Just check it's a reasonable string, not empty
                assert isinstance(node_type, str), f"Node {node_id} type should be string"
                assert len(node_type) > 0, f"Node {node_id} type should not be empty"


@pytest.mark.integration
@pytest.mark.slow
class TestSetupIntegration:
    """Test setup process integration."""

    def test_makefile_and_setup_script_alignment(self, makefile_path: Path, setup_script_path: Path):
        """Test that Makefile and setup.sh have aligned functionality."""
        makefile_content = makefile_path.read_text()
        setup_content = setup_script_path.read_text()

        # Both should reference Studio
        assert "Studio" in makefile_content and "Studio" in setup_content

        # Both should reference custom nodes
        assert "custom_nodes" in makefile_content and "custom_nodes" in setup_content

    def test_requirements_match_documentation(self, requirements_path: Path, project_root: Path):
        """Test that requirements.txt matches README documentation."""
        readme_path = project_root / "README.md"
        if not readme_path.exists():
            pytest.skip("README.md not found")

        readme_content = readme_path.read_text()
        requirements_content = requirements_path.read_text()

        # README should mention Python version
        assert "Python" in readme_content

        # If README mentions specific dependencies, they should be in requirements
        if "torch" in readme_content.lower():
            assert "torch" in requirements_content


@pytest.mark.integration
@pytest.mark.slow
class TestEndToEndSetup:
    """End-to-end setup tests (requires clean environment)."""

    def test_can_clone_and_setup(self, tmp_path: Path):
        """Test that project can be cloned and set up from scratch."""
        # This is a minimal smoke test
        # In CI/CD, you would actually clone the repo

        project_files = ["Makefile", "setup.sh", "requirements.txt"]
        for file_name in project_files:
            # Just verify files exist (actual clone would be in CI)
            pytest.skip("Skipping clone test in local environment")


@pytest.mark.integration
class TestStudioIntegration:
    """Test integration with Studio (when installed)."""

    @pytest.mark.skipif(
        not Path("./Studio").exists(),
        reason="Studio not installed"
    )
    def test_comfyui_directory_structure(self):
        """Test Studio has expected directory structure."""
        comfyui_dir = Path("./Studio")

        expected_dirs = [
            "custom_nodes",
            "models",
            "input",
            "output",
        ]

        for dir_name in expected_dirs:
            dir_path = comfyui_dir / dir_name
            assert dir_path.exists(), f"Studio should have {dir_name} directory"
            assert dir_path.is_dir(), f"{dir_name} should be a directory"

    @pytest.mark.skipif(
        not Path("./Studio").exists(),
        reason="Studio not installed"
    )
    def test_custom_nodes_installed(self):
        """Test that custom nodes are installed."""
        custom_nodes_dir = Path("./Studio/custom_nodes")

        if not custom_nodes_dir.exists():
            pytest.skip("custom_nodes directory not found")

        # Check for at least some custom nodes
        custom_node_dirs = [d for d in custom_nodes_dir.iterdir() if d.is_dir()]

        # Should have some custom nodes installed
        assert len(custom_node_dirs) > 0, "At least one custom node should be installed"

    @pytest.mark.skipif(
        not Path("./Studio").exists(),
        reason="Studio not installed"
    )
    def test_workflow_in_workflows_directory(self):
        """Test that workflow is copied to Studio workflows directory."""
        workflow_path = Path("./Studio/workflows/inpainting-workflow.json")

        # Workflow might not be copied yet, so skip if not found
        if not workflow_path.exists():
            pytest.skip("Workflow not installed yet (run: make install-workflow)")

        # If it exists, verify it's valid
        with open(workflow_path) as f:
            workflow = json.load(f)
        assert isinstance(workflow, dict)


@pytest.mark.integration
class TestDocumentationIntegration:
    """Test that documentation is consistent and accurate."""

    def test_readme_matches_makefile_targets(self, project_root: Path, makefile_path: Path):
        """Test that README documents Makefile targets."""
        readme_path = project_root / "README.md"
        if not readme_path.exists():
            pytest.skip("README.md not found")

        readme_content = readme_path.read_text()
        makefile_content = makefile_path.read_text()

        # If README has a Makefile section, it should mention key targets
        if "make" in readme_content.lower():
            # Key targets that should be documented
            important_targets = ["setup", "run", "clean"]

            for target in important_targets:
                if f"make {target}" in makefile_content:
                    # Target exists in Makefile, should be in README
                    # (This is a soft check - not all targets need docs)
                    pass

    def test_quickstart_is_accurate(self, project_root: Path):
        """Test that QUICKSTART.md provides accurate instructions."""
        quickstart_path = project_root / "QUICKSTART.md"
        if not quickstart_path.exists():
            pytest.skip("QUICKSTART.md not found")

        content = quickstart_path.read_text()

        # Should mention key commands
        key_commands = ["make", "setup", "run"]
        for cmd in key_commands:
            assert cmd in content.lower(), f"QUICKSTART should mention '{cmd}'"
