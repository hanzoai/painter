# Hanzo Studio Testing Guide

This document provides a comprehensive guide to the test suite for Hanzo Studio.

## Quick Start

```bash
# Install test dependencies
pip install -r tests/requirements.txt

# Run all tests
make test

# Run only unit tests (fast)
make test-unit

# Run integration tests
make test-integration

# Generate coverage report
make test-coverage
```

## Test Suite Overview

The Hanzo Studio test suite includes **72 tests** covering:

- ✅ Workflow JSON validation
- ✅ Makefile target verification
- ✅ Setup script validation
- ✅ Dependency checking
- ✅ Project structure verification
- ✅ Integration with Hanzo Studio
- ✅ Documentation consistency

### Test Results

```
======================== 71 passed, 1 skipped in 2.04s ========================
```

## Test Organization

### By Category

```
tests/
├── test_workflow.py        # 10 tests - Workflow JSON validation
├── test_makefile.py        # 15 tests - Makefile functionality
├── test_setup.py          # 17 tests - Setup script validation
├── test_dependencies.py    # 17 tests - Dependency verification
└── test_integration.py     # 13 tests - Integration tests
```

### By Markers

- `@pytest.mark.unit` - 50 fast unit tests
- `@pytest.mark.integration` - 22 integration tests
- `@pytest.mark.slow` - 5 slow-running tests
- `@pytest.mark.workflow` - Workflow-specific tests
- `@pytest.mark.makefile` - Makefile tests
- `@pytest.mark.setup` - Setup script tests

## Running Tests

### All Tests

```bash
# Using Make
make test

# Using pytest directly
pytest -v

# Parallel execution (faster)
pytest -n auto
```

### Selective Testing

```bash
# Unit tests only (fast - 50 tests in ~0.1s)
make test-unit
pytest -m unit

# Integration tests (22 tests in ~2s)
make test-integration
pytest -m integration

# Exclude slow tests
pytest -m "not slow"

# Run specific test file
pytest tests/test_workflow.py -v

# Run specific test
pytest tests/test_workflow.py::TestWorkflowStructure::test_workflow_file_exists -v
```

### Coverage Reports

```bash
# Generate HTML coverage report
make test-coverage

# View in browser
open htmlcov/index.html

# Terminal coverage report
pytest --cov=. --cov-report=term
```

## Test Details

### Workflow Tests (10 tests)

Validates `inpainting-workflow.json`:

- ✅ File exists and is valid JSON
- ✅ Contains required nodes
- ✅ Nodes have proper structure (type, inputs, outputs)
- ✅ Node connections are valid
- ✅ Video processing parameters present
- ✅ Default values are reasonable
- ✅ File is copyable for installation

### Makefile Tests (15 tests)

Verifies Makefile functionality:

- ✅ File structure and syntax
- ✅ Required targets exist (help, setup, run, test, clean, etc.)
- ✅ Targets have documentation
- ✅ Configuration variables defined
- ✅ Model URLs are correct and use HTTPS
- ✅ Targets execute successfully

### Setup Script Tests (17 tests)

Validates `setup.sh`:

- ✅ Script exists and is executable
- ✅ Has proper shebang and error handling
- ✅ Checks for dependencies (python, git, wget)
- ✅ Installs Hanzo Studio
- ✅ Installs custom nodes
- ✅ Downloads SAM2 models
- ✅ Creates required directories
- ✅ Installs workflow
- ✅ Has colored output for better UX
- ✅ Provides next steps
- ✅ Handles errors gracefully

### Dependency Tests (17 tests)

Checks requirements and dependencies:

- ✅ requirements.txt exists and is valid
- ✅ Contains core dependencies (torch, Pillow, numpy, opencv, etc.)
- ✅ Includes video processing libraries (imageio, av)
- ✅ Mentions MLX for Apple Silicon
- ✅ System dependencies available (python, git, wget)
- ✅ Python modules importable

### Integration Tests (13 tests)

End-to-end validation:

- ✅ Project structure complete
- ✅ Documentation files present
- ✅ Workflow integrates with project
- ✅ Makefile and setup.sh aligned
- ✅ Hanzo Studio directory structure valid
- ✅ Custom nodes installed
- ✅ Workflow copied to Hanzo Studio
- ✅ Documentation consistent

## Continuous Integration

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      
      - name: Install test dependencies
        run: pip install -r tests/requirements.txt
      
      - name: Run tests
        run: make test
      
      - name: Generate coverage
        run: make test-coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

## Writing New Tests

### Test Template

```python
import pytest

@pytest.mark.unit
@pytest.mark.workflow
def test_something(workflow_json):
    """Test description following Given-When-Then pattern."""
    # Given: Setup
    nodes = workflow_json.get("nodes", [])
    
    # When: Action
    node_count = len(nodes)
    
    # Then: Assert
    assert node_count > 0, "Workflow should have nodes"
```

### Available Fixtures

From `tests/conftest.py`:

- `project_root` - Path to project root
- `makefile_path` - Path to Makefile
- `workflow_path` - Path to workflow JSON
- `workflow_json` - Loaded workflow data
- `requirements_path` - Path to requirements.txt
- `setup_script_path` - Path to setup.sh
- `temp_comfyui_dir` - Temporary test directory

### Best Practices

1. **One assertion per test** - Each test should verify one behavior
2. **Descriptive names** - Test names should explain what they test
3. **Use markers** - Tag tests with appropriate markers
4. **Fast tests** - Mock external dependencies
5. **Independent tests** - Tests should not depend on each other
6. **Clear assertions** - Use descriptive assertion messages

## Troubleshooting

### Common Issues

**Tests fail with import errors:**
```bash
# Install test dependencies
pip install -r tests/requirements.txt
```

**Tests skip due to missing Hanzo Studio:**
```bash
# Some integration tests require Hanzo Studio
make setup  # Install Hanzo Studio
```

**setup.sh not executable:**
```bash
chmod +x setup.sh
```

**Tests run slowly:**
```bash
# Run only fast unit tests
make test-unit

# Use parallel execution
pytest -n auto
```

### Viewing Test Details

```bash
# Verbose output
pytest -v

# Show print statements
pytest -s

# Show local variables on failure
pytest -l

# Stop on first failure
pytest -x

# Run last failed tests
pytest --lf
```

## Test Coverage Goals

Current coverage focuses on:

- ✅ Project configuration files
- ✅ Workflow validation
- ✅ Setup automation
- ✅ Integration points

Future coverage plans:

- [ ] Runtime behavior tests (requires Hanzo Studio running)
- [ ] Model loading tests
- [ ] Video processing tests
- [ ] Error handling scenarios

## Contributing

When adding new features:

1. Write tests first (TDD approach)
2. Ensure all tests pass: `make test`
3. Maintain coverage: `make test-coverage`
4. Update this documentation
5. Add new test categories if needed

## Resources

- [Pytest Documentation](https://docs.pytest.org/)
- [Test README](tests/README.md) - Detailed testing documentation
- [Makefile](Makefile) - Test targets and commands

---

**Test Suite Status:** ✅ All tests passing (71/72 passed, 1 skipped)
**Last Updated:** 2025-01-23
