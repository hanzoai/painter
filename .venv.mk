# Virtual environment setup using uv
.PHONY: install-uv venv-setup venv-deps venv-clean

PYTHON_VERSION := 3.11
VENV_DIR := .venv

install-uv: ## Install uv if not present
	@if ! command -v uv &> /dev/null; then \
		echo "$(CYAN)Installing uv...$(NC)"; \
		curl -LsSf https://astral.sh/uv/install.sh | sh; \
	else \
		echo "$(GREEN)✓ uv already installed$(NC)"; \
	fi

venv-setup: install-uv ## Create virtual environment with uv
	@echo "$(CYAN)Creating virtual environment...$(NC)"
	@uv python install $(PYTHON_VERSION)
	@uv venv $(VENV_DIR) --python $(PYTHON_VERSION)
	@echo "$(GREEN)✓ Virtual environment created at $(VENV_DIR)$(NC)"
	@echo "$(YELLOW)Activate with: source $(VENV_DIR)/bin/activate$(NC)"

venv-deps: ## Install Studio dependencies in venv
	@echo "$(CYAN)Installing Studio dependencies...$(NC)"
	@if [ ! -d "$(VENV_DIR)" ]; then \
		echo "$(RED)Error: Virtual environment not found. Run 'make venv-setup' first.$(NC)"; \
		exit 1; \
	fi
	@source $(VENV_DIR)/bin/activate && \
		cd Studio && \
		uv pip install pyyaml pillow typing_extensions && \
		grep -v "segment-anything" requirements.txt > /tmp/requirements-filtered.txt && \
		uv pip install -r /tmp/requirements-filtered.txt && \
		uv pip install -e . && \
		rm -f /tmp/requirements-filtered.txt
	@echo "$(GREEN)✓ Dependencies installed$(NC)"

venv-clean: ## Remove virtual environment
	@echo "$(CYAN)Removing virtual environment...$(NC)"
	@rm -rf $(VENV_DIR)
	@echo "$(GREEN)✓ Virtual environment removed$(NC)"
