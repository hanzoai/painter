"""
Pytest configuration and fixtures for Hanzo Painter tests.
"""
import json
import os
import subprocess
import tempfile
from pathlib import Path
from typing import Any, Dict

import pytest


@pytest.fixture
def project_root() -> Path:
    """Return the project root directory."""
    return Path(__file__).parent.parent


@pytest.fixture
def makefile_path(project_root: Path) -> Path:
    """Return path to Makefile."""
    return project_root / "Makefile"


@pytest.fixture
def workflow_path(project_root: Path) -> Path:
    """Return path to workflow JSON."""
    return project_root / "inpainting-workflow.json"


@pytest.fixture
def requirements_path(project_root: Path) -> Path:
    """Return path to requirements.txt."""
    return project_root / "requirements.txt"


@pytest.fixture
def setup_script_path(project_root: Path) -> Path:
    """Return path to setup.sh."""
    return project_root / "setup.sh"


@pytest.fixture
def temp_comfyui_dir(tmp_path: Path) -> Path:
    """Create a temporary Studio directory structure."""
    comfyui_dir = tmp_path / "Studio"
    comfyui_dir.mkdir()

    # Create required subdirectories
    (comfyui_dir / "custom_nodes").mkdir()
    (comfyui_dir / "models" / "sam2").mkdir(parents=True)
    (comfyui_dir / "models" / "checkpoints").mkdir(parents=True)
    (comfyui_dir / "models" / "diffusers").mkdir(parents=True)
    (comfyui_dir / "workflows").mkdir()
    (comfyui_dir / "input").mkdir()
    (comfyui_dir / "output").mkdir()

    return comfyui_dir


@pytest.fixture
def workflow_json(workflow_path: Path) -> Dict[str, Any]:
    """Load and return workflow JSON."""
    with open(workflow_path) as f:
        return json.load(f)


@pytest.fixture
def mock_environment(monkeypatch, temp_comfyui_dir: Path):
    """Set up mock environment variables for testing."""
    monkeypatch.setenv("COMFYUI_DIR", str(temp_comfyui_dir))
    monkeypatch.setenv("PYTHON", "python3")
    monkeypatch.setenv("PIP", "pip3")
    return temp_comfyui_dir


def run_command(cmd: str, cwd: Path = None, check: bool = True) -> subprocess.CompletedProcess:
    """Helper to run shell commands."""
    return subprocess.run(
        cmd,
        shell=True,
        cwd=cwd,
        capture_output=True,
        text=True,
        check=check
    )
