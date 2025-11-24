# Hanzo Studio Tests

Comprehensive test suite for the Hanzo Studio project.

## Test Structure

```
tests/
├── conftest.py              # Pytest configuration and fixtures
├── test_workflow.py         # Workflow JSON validation tests
├── test_makefile.py         # Makefile target and functionality tests
├── test_dependencies.py     # Dependency and requirements tests
├── test_setup.py           # Setup script tests
├── test_integration.py     # Integration tests
├── requirements.txt        # Test dependencies
└── README.md              # This file
```

## Running Tests

### Quick Start

```bash
# Install test dependencies
pip install -r tests/requirements.txt

# Run all tests
pytest

# Run with verbose output
pytest -v

# Run specific test file
pytest tests/test_workflow.py

# Run specific test
pytest tests/test_workflow.py::TestWorkflowStructure::test_workflow_file_exists
```

### Test Categories

Tests are organized by markers:

```bash
# Unit tests only (fast)
pytest -m unit

# Integration tests (requires ComfyUI)
pytest -m integration

# Workflow validation tests
pytest -m workflow

# Makefile tests
pytest -m makefile

# Setup script tests
pytest -m setup

# Exclude slow tests
pytest -m "not slow"
```

### Coverage

```bash
# Run tests with coverage
pytest --cov=. --cov-report=html

# Open coverage report
open htmlcov/index.html
```

### Parallel Execution

```bash
# Run tests in parallel (faster)
pytest -n auto
```

## Test Categories

### Unit Tests (`-m unit`)

Fast tests that don't require external dependencies:

- **test_workflow.py**: Validates workflow JSON structure
- **test_makefile.py**: Checks Makefile syntax and targets
- **test_dependencies.py**: Validates requirements.txt
- **test_setup.py**: Validates setup.sh script

### Integration Tests (`-m integration`)

Tests that verify component interactions:

- **test_integration.py**: End-to-end workflow tests
- May require ComfyUI to be installed

### Slow Tests (`-m slow`)

Tests that take more than a few seconds:

- Makefile execution tests
- Setup script execution
- Model download verification

## Writing Tests

### Test Structure

```python
import pytest

@pytest.mark.unit
@pytest.mark.workflow
def test_something(workflow_json):
    """Test description."""
    assert workflow_json is not None
```

### Available Fixtures

From `conftest.py`:

- `project_root`: Path to project root directory
- `makefile_path`: Path to Makefile
- `workflow_path`: Path to inpainting-workflow.json
- `workflow_json`: Loaded workflow JSON
- `requirements_path`: Path to requirements.txt
- `setup_script_path`: Path to setup.sh
- `temp_comfyui_dir`: Temporary ComfyUI directory for testing

### Markers

Available pytest markers:

- `@pytest.mark.unit`: Unit tests
- `@pytest.mark.integration`: Integration tests
- `@pytest.mark.slow`: Slow-running tests
- `@pytest.mark.workflow`: Workflow-related tests
- `@pytest.mark.makefile`: Makefile tests
- `@pytest.mark.setup`: Setup script tests

## Test Coverage

Current test coverage:

- ✅ Workflow JSON validation
- ✅ Makefile syntax and targets
- ✅ Requirements.txt validation
- ✅ Setup script validation
- ✅ Project structure
- ✅ Documentation consistency
- ✅ Dependency checking
- ✅ Integration with ComfyUI

## CI/CD Integration

### GitHub Actions

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
      - name: Install dependencies
        run: |
          pip install -r tests/requirements.txt
      - name: Run tests
        run: pytest -v --cov=. --cov-report=xml
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

## Troubleshooting

### Tests Failing

1. **Import errors**: Install test dependencies
   ```bash
   pip install -r tests/requirements.txt
   ```

2. **ComfyUI not found**: Some integration tests require ComfyUI
   ```bash
   make setup  # Install ComfyUI
   ```

3. **Permission errors**: Make setup.sh executable
   ```bash
   chmod +x setup.sh
   ```

### Skipped Tests

Tests may be skipped if:

- ComfyUI is not installed (integration tests)
- Optional dependencies are missing
- System commands are unavailable (wget, git)

Run with `-v` to see why tests are skipped:

```bash
pytest -v
```

## Best Practices

1. **Keep tests fast**: Use mocks for external dependencies
2. **Test one thing**: Each test should verify one behavior
3. **Use descriptive names**: Test names should explain what they test
4. **Add markers**: Tag tests appropriately (`@pytest.mark.unit`, etc.)
5. **Document fixtures**: Explain what fixtures provide
6. **Update tests**: When code changes, update tests accordingly

## Contributing

When adding new features:

1. Write tests first (TDD)
2. Ensure tests pass: `pytest`
3. Check coverage: `pytest --cov`
4. Update this README if adding new test categories

## Resources

- [Pytest Documentation](https://docs.pytest.org/)
- [Pytest Markers](https://docs.pytest.org/en/stable/how-to/mark.html)
- [Pytest Fixtures](https://docs.pytest.org/en/stable/how-to/fixtures.html)
