#!/bin/bash
# CI Test Simulation Script
# Simulates the GitHub Actions CI environment locally

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}CI Test Simulation${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Function to run a test step
run_step() {
    local step_name=$1
    local command=$2

    echo -e "${YELLOW}Running: ${step_name}${NC}"
    if eval "$command"; then
        echo -e "${GREEN}✓ ${step_name} passed${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}✗ ${step_name} failed${NC}"
        echo ""
        return 1
    fi
}

# Track failures
FAILED=0

# Step 1: Check Python version
run_step "Python version check" "python3 --version" || ((FAILED++))

# Step 2: Install dependencies
run_step "Install test dependencies" "pip install -q -r tests/requirements.txt" || ((FAILED++))

# Step 3: Validate workflow JSON
run_step "Validate workflow JSON" "python3 -m json.tool inpainting-workflow.json > /dev/null" || ((FAILED++))

# Step 4: Check setup script syntax
run_step "Validate setup.sh syntax" "bash -n setup.sh" || ((FAILED++))

# Step 5: Run unit tests
run_step "Unit tests" "python3 -m pytest -v -m unit --tb=short" || ((FAILED++))

# Step 6: Run integration tests
run_step "Integration tests" "python3 -m pytest -v -m integration --tb=short" || ((FAILED++))

# Step 7: Test Makefile targets
run_step "Make help" "make help > /dev/null" || ((FAILED++))
run_step "Make check-deps" "make check-deps > /dev/null" || ((FAILED++))
run_step "Make info" "make info > /dev/null" || ((FAILED++))

# Step 8: Full test suite
run_step "Full test suite" "python3 -m pytest -v --tb=short" || ((FAILED++))

# Summary
echo -e "${BLUE}=====================================${NC}"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All CI tests passed!${NC}"
    echo -e "${BLUE}=====================================${NC}"
    exit 0
else
    echo -e "${RED}✗ ${FAILED} test step(s) failed${NC}"
    echo -e "${BLUE}=====================================${NC}"
    exit 1
fi
