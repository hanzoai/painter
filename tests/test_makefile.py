"""
Tests for Makefile targets and functionality.
"""
import re
import subprocess
from pathlib import Path

import pytest


@pytest.mark.unit
@pytest.mark.makefile
class TestMakefileStructure:
    """Test Makefile structure and syntax."""

    def test_makefile_exists(self, makefile_path: Path):
        """Test that Makefile exists."""
        assert makefile_path.exists(), "Makefile should exist"

    def test_makefile_not_empty(self, makefile_path: Path):
        """Test that Makefile is not empty."""
        assert makefile_path.stat().st_size > 0, "Makefile should not be empty"

    def test_makefile_has_phony_declaration(self, makefile_path: Path):
        """Test that Makefile declares PHONY targets."""
        content = makefile_path.read_text()
        assert ".PHONY:" in content, "Makefile should declare .PHONY targets"

    def test_makefile_has_help_target(self, makefile_path: Path):
        """Test that Makefile has help target."""
        content = makefile_path.read_text()
        assert re.search(r'^help:', content, re.MULTILINE), "Makefile should have help target"


@pytest.mark.unit
@pytest.mark.makefile
class TestMakefileTargets:
    """Test that required Makefile targets exist."""

    REQUIRED_TARGETS = [
        "help",
        "check-deps",
        "setup",
        "install-comfyui",
        "install-nodes",
        "download-models",
        "install-workflow",
        "run",
        "clean",
        "test",
        "info",
    ]

    def test_required_targets_exist(self, makefile_path: Path):
        """Test that all required targets are defined."""
        content = makefile_path.read_text()

        for target in self.REQUIRED_TARGETS:
            # Match target definition (target:)
            pattern = rf'^{re.escape(target)}:.*?##'
            assert re.search(pattern, content, re.MULTILINE), \
                f"Makefile should define target: {target}"

    def test_targets_have_documentation(self, makefile_path: Path):
        """Test that main targets have ## documentation."""
        content = makefile_path.read_text()

        # Find all targets with ## documentation
        documented_targets = re.findall(r'^(\w+):.*?## (.+)$', content, re.MULTILINE)

        assert len(documented_targets) > 0, "Makefile should have documented targets"

        # Check that critical targets are documented
        critical_targets = ["help", "setup", "run", "test"]
        documented_target_names = {name for name, _ in documented_targets}

        for target in critical_targets:
            assert target in documented_target_names, \
                f"Target '{target}' should have ## documentation"


@pytest.mark.unit
@pytest.mark.makefile
class TestMakefileConfiguration:
    """Test Makefile configuration variables."""

    def test_makefile_has_configuration_vars(self, makefile_path: Path):
        """Test that Makefile defines configuration variables."""
        content = makefile_path.read_text()

        required_vars = [
            "COMFYUI_DIR",
            "PYTHON",
            "PORT",
        ]

        for var in required_vars:
            # Match variable definition
            pattern = rf'^{re.escape(var)}\s*[?:]?='
            assert re.search(pattern, content, re.MULTILINE), \
                f"Makefile should define {var} variable"

    def test_default_port_is_8188(self, makefile_path: Path):
        """Test that default port is 8188 (Studio standard)."""
        content = makefile_path.read_text()
        # Match PORT ?= 8188
        assert re.search(r'PORT\s*\?=\s*8188', content), \
            "Default PORT should be 8188"


@pytest.mark.integration
@pytest.mark.makefile
@pytest.mark.slow
class TestMakefileExecution:
    """Test Makefile target execution (integration tests)."""

    def test_make_help_runs(self, project_root: Path):
        """Test that 'make help' runs successfully."""
        result = subprocess.run(
            ["make", "help"],
            cwd=project_root,
            capture_output=True,
            text=True
        )
        assert result.returncode == 0, f"make help failed: {result.stderr}"
        assert "Hanzo Painter" in result.stdout, "Help should mention Hanzo Painter"

    def test_make_check_deps_runs(self, project_root: Path):
        """Test that 'make check-deps' runs."""
        result = subprocess.run(
            ["make", "check-deps"],
            cwd=project_root,
            capture_output=True,
            text=True
        )
        # Should either pass or fail with clear error
        assert "Checking dependencies" in result.stdout or result.returncode != 0

    def test_make_info_runs(self, project_root: Path):
        """Test that 'make info' runs successfully."""
        result = subprocess.run(
            ["make", "info"],
            cwd=project_root,
            capture_output=True,
            text=True
        )
        assert result.returncode == 0, f"make info failed: {result.stderr}"
        assert "Studio Directory" in result.stdout or "Installation Info" in result.stdout

    def test_make_clean_runs(self, project_root: Path):
        """Test that 'make clean' runs successfully."""
        result = subprocess.run(
            ["make", "clean"],
            cwd=project_root,
            capture_output=True,
            text=True
        )
        assert result.returncode == 0, f"make clean failed: {result.stderr}"

    @pytest.mark.skipif(
        not Path("./Studio").exists(),
        reason="Studio not installed"
    )
    def test_make_test_runs_with_comfyui(self, project_root: Path):
        """Test that 'make test' runs when Studio is installed."""
        result = subprocess.run(
            ["make", "test"],
            cwd=project_root,
            capture_output=True,
            text=True
        )
        # Should show PyTorch info or fail gracefully
        assert "PyTorch" in result.stdout or result.returncode != 0


@pytest.mark.unit
@pytest.mark.makefile
class TestMakefileModelURLs:
    """Test that model URLs in Makefile are correct."""

    def test_sam2_urls_defined(self, makefile_path: Path):
        """Test that SAM2 model URLs are defined."""
        content = makefile_path.read_text()

        # Check for SAM2 URLs
        assert "segment_anything_2" in content or "sam2" in content.lower(), \
            "Makefile should define SAM2 model URLs"

        # Check for specific model files
        assert "sam2_hiera_large" in content, "Should have SAM2 large model URL"
        assert "sam2_hiera_base" in content, "Should have SAM2 base model URL"

    def test_model_urls_use_https(self, makefile_path: Path):
        """Test that model URLs use HTTPS."""
        content = makefile_path.read_text()

        # Find all URLs
        urls = re.findall(r'https?://[^\s]+', content)

        for url in urls:
            if "dl.fbaipublicfiles.com" in url:
                assert url.startswith("https://"), \
                    f"Model URL should use HTTPS: {url}"
