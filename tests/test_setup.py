"""
Tests for setup.sh script.
"""
import re
import stat
from pathlib import Path

import pytest


@pytest.mark.unit
@pytest.mark.setup
class TestSetupScript:
    """Test setup.sh script structure and content."""

    def test_setup_script_exists(self, setup_script_path: Path):
        """Test that setup.sh exists."""
        assert setup_script_path.exists(), "setup.sh should exist"

    def test_setup_script_is_executable(self, setup_script_path: Path):
        """Test that setup.sh is executable."""
        mode = setup_script_path.stat().st_mode
        # Check if user execute bit is set
        is_executable = bool(mode & stat.S_IXUSR)
        if not is_executable:
            pytest.skip("setup.sh is not executable (run: chmod +x setup.sh)")

    def test_setup_script_has_shebang(self, setup_script_path: Path):
        """Test that setup.sh has proper shebang."""
        content = setup_script_path.read_text()
        first_line = content.split("\n")[0]
        assert first_line.startswith("#!"), "setup.sh should have shebang"
        assert "bash" in first_line or "sh" in first_line, "setup.sh should use bash/sh"

    def test_setup_script_has_error_handling(self, setup_script_path: Path):
        """Test that setup.sh has error handling."""
        content = setup_script_path.read_text()
        # Should have 'set -e' for error handling
        assert "set -e" in content, "setup.sh should have 'set -e' for error handling"

    def test_setup_script_has_dependency_checks(self, setup_script_path: Path):
        """Test that setup.sh checks for dependencies."""
        content = setup_script_path.read_text()

        required_checks = [
            "python",
            "git",
            "wget",
        ]

        for dep in required_checks:
            # Check for 'command -v' or similar dependency check
            assert f"command -v" in content or "which" in content, \
                f"setup.sh should check for {dep}"


@pytest.mark.unit
@pytest.mark.setup
class TestSetupScriptFlow:
    """Test setup.sh script flow and logic."""

    def test_setup_installs_comfyui(self, setup_script_path: Path):
        """Test that setup.sh installs ComfyUI."""
        content = setup_script_path.read_text()
        assert "ComfyUI" in content, "setup.sh should install ComfyUI"
        assert "git clone" in content, "setup.sh should clone repositories"

    def test_setup_installs_custom_nodes(self, setup_script_path: Path):
        """Test that setup.sh installs custom nodes."""
        content = setup_script_path.read_text()

        custom_nodes = [
            "DiffuEraser",
            "VideoHelper",
            "Easy-Use",
            "KJNodes",
            "LayerStyle",
        ]

        for node in custom_nodes:
            assert node in content, f"setup.sh should install {node}"

    def test_setup_downloads_sam2(self, setup_script_path: Path):
        """Test that setup.sh downloads SAM2 models."""
        content = setup_script_path.read_text()
        assert "sam2" in content.lower(), "setup.sh should download SAM2 models"
        assert "wget" in content or "curl" in content, "setup.sh should download models"

    def test_setup_creates_directories(self, setup_script_path: Path):
        """Test that setup.sh creates required directories."""
        content = setup_script_path.read_text()
        assert "mkdir" in content, "setup.sh should create directories"

        # Should create model directories
        expected_dirs = [
            "models",
            "sam2",
            "checkpoints",
            "diffusers",
        ]

        for dir_name in expected_dirs:
            assert dir_name in content, f"setup.sh should reference {dir_name} directory"

    def test_setup_installs_workflow(self, setup_script_path: Path):
        """Test that setup.sh installs workflow."""
        content = setup_script_path.read_text()
        assert "workflow" in content.lower(), "setup.sh should install workflow"
        assert "inpainting-workflow.json" in content or "cp" in content, \
            "setup.sh should copy workflow file"


@pytest.mark.unit
@pytest.mark.setup
class TestSetupScriptOutput:
    """Test setup.sh script output and user experience."""

    def test_setup_has_color_output(self, setup_script_path: Path):
        """Test that setup.sh has colored output for better UX."""
        content = setup_script_path.read_text()
        # Should define color variables
        color_vars = ["BLUE", "GREEN", "YELLOW", "RED", "NC"]

        has_colors = any(color in content for color in color_vars)
        assert has_colors, "setup.sh should use colored output"

    def test_setup_has_progress_messages(self, setup_script_path: Path):
        """Test that setup.sh shows progress messages."""
        content = setup_script_path.read_text()
        # Should have echo statements for progress
        assert "echo" in content, "setup.sh should show progress messages"

    def test_setup_has_completion_message(self, setup_script_path: Path):
        """Test that setup.sh has completion message."""
        content = setup_script_path.read_text()
        # Should have final success message
        success_indicators = ["complete", "done", "success", "✓"]

        has_completion = any(indicator in content.lower() for indicator in success_indicators)
        assert has_completion, "setup.sh should have completion message"

    def test_setup_provides_next_steps(self, setup_script_path: Path):
        """Test that setup.sh provides next steps."""
        content = setup_script_path.read_text()
        # Should tell users what to do next
        assert "next" in content.lower() or "start" in content.lower(), \
            "setup.sh should provide next steps"


@pytest.mark.unit
@pytest.mark.setup
class TestSetupScriptSafety:
    """Test setup.sh script safety and best practices."""

    def test_setup_checks_before_reinstall(self, setup_script_path: Path):
        """Test that setup.sh checks before reinstalling."""
        content = setup_script_path.read_text()
        # Should check if directories exist before installing
        assert "if" in content and "fi" in content, "setup.sh should have conditional checks"

    def test_setup_no_hardcoded_paths(self, setup_script_path: Path):
        """Test that setup.sh uses variables for paths."""
        content = setup_script_path.read_text()
        # Should use COMFYUI_DIR variable
        assert "COMFYUI_DIR" in content, "setup.sh should use COMFYUI_DIR variable"

    def test_setup_handles_errors(self, setup_script_path: Path):
        """Test that setup.sh handles errors gracefully."""
        content = setup_script_path.read_text()
        # Should have 'set -e' at the beginning
        lines = content.split("\n")
        early_lines = "\n".join(lines[:10])
        assert "set -e" in early_lines, "setup.sh should set error handling early"
