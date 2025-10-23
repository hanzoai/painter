"""
Tests for dependency checking and requirements.
"""
import re
from pathlib import Path

import pytest


@pytest.mark.unit
class TestRequirements:
    """Test requirements.txt structure and content."""

    def test_requirements_file_exists(self, requirements_path: Path):
        """Test that requirements.txt exists."""
        assert requirements_path.exists(), "requirements.txt should exist"

    def test_requirements_not_empty(self, requirements_path: Path):
        """Test that requirements.txt is not empty."""
        assert requirements_path.stat().st_size > 0, "requirements.txt should not be empty"

    def test_requirements_has_pytorch(self, requirements_path: Path):
        """Test that requirements includes PyTorch."""
        content = requirements_path.read_text()
        assert "torch" in content.lower(), "requirements.txt should include torch"

    def test_requirements_has_core_dependencies(self, requirements_path: Path):
        """Test that requirements has core dependencies."""
        content = requirements_path.read_text()

        core_deps = [
            "torch",
            "Pillow",
            "numpy",
            "opencv-python",
            "transformers",
            "safetensors",
        ]

        for dep in core_deps:
            assert dep in content, f"requirements.txt should include {dep}"

    def test_requirements_has_video_processing(self, requirements_path: Path):
        """Test that requirements includes video processing libraries."""
        content = requirements_path.read_text()

        video_deps = ["imageio", "av"]

        for dep in video_deps:
            assert dep in content, f"requirements.txt should include {dep} for video processing"

    def test_requirements_format_valid(self, requirements_path: Path):
        """Test that requirements.txt has valid format."""
        content = requirements_path.read_text()
        lines = [line.strip() for line in content.split("\n") if line.strip()]

        for line in lines:
            # Skip comments and empty lines
            if line.startswith("#") or not line:
                continue

            # Should be package name with optional version specifier
            # Examples: package>=1.0.0, package==1.0, package
            assert re.match(r'^[a-zA-Z0-9_-]+([><=!]+[0-9.]+)?', line), \
                f"Invalid requirement format: {line}"

    def test_mlx_mentioned_for_apple_silicon(self, requirements_path: Path):
        """Test that MLX is mentioned for Apple Silicon."""
        content = requirements_path.read_text()
        # MLX should be mentioned in comments or requirements
        assert "mlx" in content.lower() or "apple silicon" in content.lower(), \
            "requirements.txt should mention MLX for Apple Silicon acceleration"


@pytest.mark.unit
class TestSystemDependencies:
    """Test system-level dependencies."""

    def test_python_available(self):
        """Test that Python is available."""
        import subprocess
        result = subprocess.run(
            ["python3", "--version"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0, "Python 3 should be available"
        assert "Python 3" in result.stdout or "Python 3" in result.stderr

    def test_git_available(self):
        """Test that git is available."""
        import subprocess
        result = subprocess.run(
            ["git", "--version"],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0, "Git should be available"
        assert "git version" in result.stdout

    def test_wget_available(self):
        """Test that wget is available (or provide skip message)."""
        import subprocess
        result = subprocess.run(
            ["wget", "--version"],
            capture_output=True,
            text=True
        )
        if result.returncode != 0:
            pytest.skip("wget not installed (required for make download-models)")
        assert "GNU Wget" in result.stdout or "wget" in result.stdout


@pytest.mark.unit
class TestPythonDependencies:
    """Test that required Python packages are importable."""

    def test_can_import_json(self):
        """Test that json module is available."""
        import json
        assert json is not None

    def test_can_import_pathlib(self):
        """Test that pathlib is available."""
        from pathlib import Path
        assert Path is not None

    def test_can_import_subprocess(self):
        """Test that subprocess is available."""
        import subprocess
        assert subprocess is not None


@pytest.mark.integration
class TestOptionalDependencies:
    """Test optional dependencies (skip if not installed)."""

    def test_torch_import(self):
        """Test that PyTorch can be imported if installed."""
        try:
            import torch
            # If torch is installed, check basic functionality
            assert hasattr(torch, "__version__")
            assert hasattr(torch, "cuda")
        except ImportError:
            pytest.skip("PyTorch not installed")

    def test_opencv_import(self):
        """Test that OpenCV can be imported if installed."""
        try:
            import cv2
            assert hasattr(cv2, "__version__")
        except ImportError:
            pytest.skip("opencv-python not installed")

    def test_numpy_import(self):
        """Test that NumPy can be imported if installed."""
        try:
            import numpy as np
            assert hasattr(np, "__version__")
        except ImportError:
            pytest.skip("numpy not installed")

    def test_pillow_import(self):
        """Test that Pillow can be imported if installed."""
        try:
            from PIL import Image
            assert Image is not None
        except ImportError:
            pytest.skip("Pillow not installed")
