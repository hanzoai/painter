"""
Tests for RunPod deployment scripts and configuration.
"""
import stat
from pathlib import Path

import pytest


@pytest.mark.unit
@pytest.mark.runpod
class TestRunPodStartScript:
    """Test runpod-start.sh script."""

    @pytest.fixture
    def runpod_script(self) -> Path:
        """Get runpod-start.sh path."""
        return Path("runpod-start.sh")

    def test_runpod_script_exists(self, runpod_script: Path):
        """Test that runpod-start.sh exists."""
        assert runpod_script.exists(), "runpod-start.sh should exist"

    def test_runpod_script_is_executable(self, runpod_script: Path):
        """Test that runpod-start.sh is executable."""
        mode = runpod_script.stat().st_mode
        is_executable = bool(mode & stat.S_IXUSR)
        assert is_executable, "runpod-start.sh should be executable"

    def test_runpod_script_has_shebang(self, runpod_script: Path):
        """Test that runpod-start.sh has proper shebang."""
        content = runpod_script.read_text()
        first_line = content.split("\n")[0]
        assert first_line.startswith("#!"), "runpod-start.sh should have shebang"
        assert "bash" in first_line, "runpod-start.sh should use bash"

    def test_runpod_script_has_error_handling(self, runpod_script: Path):
        """Test that runpod-start.sh has error handling."""
        content = runpod_script.read_text()
        assert "set -e" in content, "runpod-start.sh should have 'set -e'"

    def test_runpod_script_clones_studio(self, runpod_script: Path):
        """Test that script clones Hanzo Studio."""
        content = runpod_script.read_text()
        assert "git clone" in content, "Should clone repository"
        assert "hanzoai/studio" in content, "Should clone hanzoai/studio"

    def test_runpod_script_installs_nodes(self, runpod_script: Path):
        """Test that script installs custom nodes."""
        content = runpod_script.read_text()
        assert "install-nodes.sh" in content or "custom_nodes" in content, \
            "Should install custom nodes"

    def test_runpod_script_downloads_models(self, runpod_script: Path):
        """Test that script downloads models."""
        content = runpod_script.read_text()
        assert "sam2" in content.lower(), "Should download SAM2 models"
        assert "wget" in content or "curl" in content, "Should download files"

    def test_runpod_script_starts_server(self, runpod_script: Path):
        """Test that script starts the server."""
        content = runpod_script.read_text()
        assert "main.py" in content, "Should start server with main.py"
        assert "0.0.0.0" in content, "Should listen on all interfaces"
        assert "8188" in content, "Should use port 8188"


@pytest.mark.unit
@pytest.mark.runpod
class TestInstallNodesScript:
    """Test install-nodes.sh script."""

    @pytest.fixture
    def install_script(self) -> Path:
        """Get install-nodes.sh path."""
        return Path("install-nodes.sh")

    def test_install_script_exists(self, install_script: Path):
        """Test that install-nodes.sh exists."""
        assert install_script.exists(), "install-nodes.sh should exist"

    def test_install_script_is_executable(self, install_script: Path):
        """Test that install-nodes.sh is executable."""
        mode = install_script.stat().st_mode
        is_executable = bool(mode & stat.S_IXUSR)
        assert is_executable, "install-nodes.sh should be executable"

    def test_install_script_installs_required_nodes(self, install_script: Path):
        """Test that all required nodes are installed."""
        content = install_script.read_text()

        required_nodes = [
            "Hanzo-DiffuEraser",
            "Hanzo-VideoHelper",
            "Hanzo-EasyUse",
            "Hanzo-KJNodes",
            "Hanzo-LayerStyle",
        ]

        for node in required_nodes:
            assert node in content, f"Should install {node}"

    def test_install_script_installs_requirements(self, install_script: Path):
        """Test that script installs requirements for each node."""
        content = install_script.read_text()
        # Check if it installs requirements (pip or pip3)
        has_pip_install = "pip" in content and "install" in content
        assert has_pip_install, "Should install node requirements with pip"


@pytest.mark.unit
@pytest.mark.runpod
class TestDockerfile:
    """Test Dockerfile configuration."""

    @pytest.fixture
    def dockerfile(self) -> Path:
        """Get Dockerfile path."""
        return Path("Dockerfile")

    def test_dockerfile_exists(self, dockerfile: Path):
        """Test that Dockerfile exists."""
        assert dockerfile.exists(), "Dockerfile should exist"

    def test_dockerfile_uses_cuda(self, dockerfile: Path):
        """Test that Dockerfile uses CUDA base image."""
        content = dockerfile.read_text()
        assert "FROM nvidia/cuda" in content or "FROM nvcr.io" in content, \
            "Dockerfile should use CUDA base image"

    def test_dockerfile_installs_python(self, dockerfile: Path):
        """Test that Dockerfile installs Python."""
        content = dockerfile.read_text()
        assert "python3" in content.lower(), "Should install Python"

    def test_dockerfile_clones_studio(self, dockerfile: Path):
        """Test that Dockerfile clones Hanzo Studio."""
        content = dockerfile.read_text()
        assert "git clone" in content, "Should clone repository"
        assert "hanzoai/studio" in content, "Should clone hanzoai/studio"

    def test_dockerfile_exposes_port(self, dockerfile: Path):
        """Test that Dockerfile exposes port 8188."""
        content = dockerfile.read_text()
        assert "EXPOSE 8188" in content, "Should expose port 8188"

    def test_dockerfile_has_healthcheck(self, dockerfile: Path):
        """Test that Dockerfile has health check."""
        content = dockerfile.read_text()
        assert "HEALTHCHECK" in content, "Should have health check"

    def test_dockerfile_sets_workdir(self, dockerfile: Path):
        """Test that Dockerfile sets working directory."""
        content = dockerfile.read_text()
        assert "WORKDIR" in content, "Should set working directory"


@pytest.mark.unit
@pytest.mark.runpod
class TestRunPodDocumentation:
    """Test RunPod documentation."""

    @pytest.fixture
    def runpod_docs(self) -> Path:
        """Get RUNPOD.md path."""
        return Path("RUNPOD.md")

    def test_runpod_docs_exist(self, runpod_docs: Path):
        """Test that RUNPOD.md exists."""
        assert runpod_docs.exists(), "RUNPOD.md should exist"

    def test_runpod_docs_has_quick_deploy(self, runpod_docs: Path):
        """Test that docs have quick deploy instructions."""
        content = runpod_docs.read_text()
        assert "Quick Deploy" in content or "One Command" in content, \
            "Should have quick deploy section"

    def test_runpod_docs_has_requirements(self, runpod_docs: Path):
        """Test that docs list GPU requirements."""
        content = runpod_docs.read_text()
        assert "GPU" in content, "Should mention GPU requirements"
        assert "RTX" in content or "A100" in content, "Should list specific GPUs"

    def test_runpod_docs_has_cost_info(self, runpod_docs: Path):
        """Test that docs include cost information."""
        content = runpod_docs.read_text()
        assert "$" in content and "hour" in content, \
            "Should include cost per hour information"

    def test_runpod_docs_has_troubleshooting(self, runpod_docs: Path):
        """Test that docs have troubleshooting section."""
        content = runpod_docs.read_text()
        assert "Troubleshooting" in content or "trouble" in content.lower(), \
            "Should have troubleshooting section"


@pytest.mark.integration
@pytest.mark.runpod
class TestRunPodIntegration:
    """Integration tests for RunPod deployment."""

    def test_docker_compose_updated(self):
        """Test that docker-compose.yml has correct configuration."""
        compose_file = Path("docker-compose.yml")
        assert compose_file.exists(), "docker-compose.yml should exist"

        content = compose_file.read_text()
        assert "STUDIO_PORT" in content, "Should use STUDIO_PORT"
        assert "hanzo-studio" in content, "Should reference hanzo-studio"
        assert "8188" in content, "Should expose port 8188"

    def test_makefile_has_runpod_commands(self):
        """Test that Makefile has RunPod-related commands."""
        makefile = Path("Makefile")
        assert makefile.exists(), "Makefile should exist"

        content = makefile.read_text()
        assert "runpod" in content, "Should have runpod target"
        assert "docker-build" in content, "Should have docker-build target"

    def test_readme_mentions_runpod(self):
        """Test that README mentions RunPod."""
        readme = Path("README.md")
        assert readme.exists(), "README.md should exist"

        content = readme.read_text()
        assert "RunPod" in content, "Should mention RunPod deployment"
        assert "runpod-start.sh" in content, "Should reference startup script"
