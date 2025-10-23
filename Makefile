.PHONY: help setup install-comfyui install-nodes download-models run clean test check-deps

# Configuration
COMFYUI_DIR ?= ./ComfyUI
PYTHON ?= python3
PIP ?= pip3
VENV ?= .venv
PORT ?= 8188
HOST ?= 0.0.0.0

# Model URLs
SAM2_LARGE_URL = https://dl.fbaipublicfiles.com/segment_anything_2/072824/sam2_hiera_large.pt
SAM2_BASE_URL = https://dl.fbaipublicfiles.com/segment_anything_2/072824/sam2_hiera_base_plus.pt

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)Hanzo Painter - AI Video Inpainting$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

check-deps: ## Check if required dependencies are installed
	@echo "$(YELLOW)Checking dependencies...$(NC)"
	@command -v $(PYTHON) >/dev/null 2>&1 || { echo "Python 3 is required but not installed. Aborting." >&2; exit 1; }
	@command -v git >/dev/null 2>&1 || { echo "Git is required but not installed. Aborting." >&2; exit 1; }
	@command -v wget >/dev/null 2>&1 || { echo "wget is required but not installed. Aborting." >&2; exit 1; }
	@echo "$(GREEN)✓ All dependencies found$(NC)"

setup: check-deps install-comfyui install-nodes ## Complete setup (install ComfyUI and nodes)
	@echo "$(GREEN)✓ Setup complete! Run 'make download-models' to get required models$(NC)"

install-comfyui: check-deps ## Install ComfyUI
	@if [ ! -d "$(COMFYUI_DIR)" ]; then \
		echo "$(YELLOW)Installing ComfyUI...$(NC)"; \
		git clone git@github.com:comfyanonymous/ComfyUI.git $(COMFYUI_DIR); \
		cd $(COMFYUI_DIR) && $(PIP) install -r requirements.txt; \
		echo "$(GREEN)✓ ComfyUI installed$(NC)"; \
	else \
		echo "$(YELLOW)ComfyUI already installed at $(COMFYUI_DIR)$(NC)"; \
	fi

install-nodes: ## Install required custom nodes
	@echo "$(YELLOW)Installing Hanzo custom nodes...$(NC)"
	@cd $(COMFYUI_DIR)/custom_nodes && \
		if [ ! -d "Hanzo-DiffuEraser" ]; then \
			git clone git@github.com:hanzoai/Hanzo-DiffuEraser.git && \
			echo "$(GREEN)✓ Hanzo-DiffuEraser installed$(NC)"; \
		fi
	@cd $(COMFYUI_DIR)/custom_nodes && \
		if [ ! -d "Hanzo-VideoHelper" ]; then \
			git clone git@github.com:hanzoai/Hanzo-VideoHelper.git && \
			cd Hanzo-VideoHelper && $(PIP) install -r requirements.txt && \
			echo "$(GREEN)✓ Hanzo-VideoHelper installed$(NC)"; \
		fi
	@cd $(COMFYUI_DIR)/custom_nodes && \
		if [ ! -d "Hanzo-EasyUse" ]; then \
			git clone git@github.com:hanzoai/Hanzo-EasyUse.git && \
			echo "$(GREEN)✓ Hanzo-EasyUse installed$(NC)"; \
		fi
	@cd $(COMFYUI_DIR)/custom_nodes && \
		if [ ! -d "Hanzo-KJNodes" ]; then \
			git clone git@github.com:hanzoai/Hanzo-KJNodes.git && \
			cd Hanzo-KJNodes && $(PIP) install -r requirements.txt && \
			echo "$(GREEN)✓ Hanzo-KJNodes installed$(NC)"; \
		fi
	@cd $(COMFYUI_DIR)/custom_nodes && \
		if [ ! -d "Hanzo-LayerStyle" ]; then \
			git clone git@github.com:hanzoai/Hanzo-LayerStyle.git && \
			echo "$(GREEN)✓ Hanzo-LayerStyle installed$(NC)"; \
		fi
	@echo "$(GREEN)✓ All Hanzo custom nodes installed$(NC)"

install-sam2: ## Install SAM2 (optional advanced segmentation)
	@echo "$(YELLOW)Installing SAM2...$(NC)"
	@cd $(COMFYUI_DIR)/custom_nodes && \
		if [ ! -d "ComfyUI-SAM2" ]; then \
			git clone git@github.com:cubiq/ComfyUI-SAM2.git && \
			cd ComfyUI-SAM2 && $(PIP) install -r requirements.txt && \
			echo "$(GREEN)✓ SAM2 installed$(NC)"; \
		else \
			echo "$(YELLOW)SAM2 already installed$(NC)"; \
		fi

install-mlx: ## Install MLX support for Apple Silicon acceleration
	@echo "$(YELLOW)Installing Hanzo-MLX for Apple Silicon...$(NC)"
	@cd $(COMFYUI_DIR)/custom_nodes && \
		if [ ! -d "Hanzo-MLX" ]; then \
			git clone git@github.com:hanzoai/Hanzo-MLX.git && \
			cd Hanzo-MLX && $(PYTHON) -m pip install --break-system-packages -r requirements.txt && \
			echo "$(GREEN)✓ Hanzo-MLX installed$(NC)"; \
		else \
			echo "$(YELLOW)Hanzo-MLX already installed$(NC)"; \
		fi
	@echo "$(GREEN)MLX Performance: Up to 70% faster model loading, 35% faster inference$(NC)"
	@echo "$(YELLOW)Note: Currently optimized for Flux models. SD 1.5 support coming soon.$(NC)"

download-models: ## Download required models
	@echo "$(YELLOW)Downloading models...$(NC)"
	@mkdir -p $(COMFYUI_DIR)/models/sam2
	@if [ ! -f "$(COMFYUI_DIR)/models/sam2/sam2_hiera_large.pt" ]; then \
		echo "$(YELLOW)Downloading SAM2 Large model...$(NC)"; \
		wget -O $(COMFYUI_DIR)/models/sam2/sam2_hiera_large.pt $(SAM2_LARGE_URL); \
		echo "$(GREEN)✓ SAM2 Large downloaded$(NC)"; \
	else \
		echo "$(YELLOW)SAM2 Large already downloaded$(NC)"; \
	fi
	@if [ ! -f "$(COMFYUI_DIR)/models/sam2/sam2_hiera_base_plus.pt" ]; then \
		echo "$(YELLOW)Downloading SAM2 Base Plus model...$(NC)"; \
		wget -O $(COMFYUI_DIR)/models/sam2/sam2_hiera_base_plus.pt $(SAM2_BASE_URL); \
		echo "$(GREEN)✓ SAM2 Base Plus downloaded$(NC)"; \
	else \
		echo "$(YELLOW)SAM2 Base Plus already downloaded$(NC)"; \
	fi
	@echo "$(GREEN)✓ Models downloaded$(NC)"
	@echo "$(YELLOW)Note: You need to manually download these models:$(NC)"
	@echo "  - realisticVisionV51_v51VAE.safetensors → $(COMFYUI_DIR)/models/checkpoints/"
	@echo "  - pcm_sd15_smallcfg_2step_converted.safetensors → $(COMFYUI_DIR)/models/diffusers/"

install-workflow: ## Copy workflow to ComfyUI
	@echo "$(YELLOW)Installing workflow...$(NC)"
	@mkdir -p $(COMFYUI_DIR)/workflows
	@cp inpainting-workflow.json $(COMFYUI_DIR)/workflows/
	@echo "$(GREEN)✓ Workflow installed to $(COMFYUI_DIR)/workflows/$(NC)"

run: ## Run ComfyUI server
	@echo "$(BLUE)Starting ComfyUI on $(HOST):$(PORT)...$(NC)"
	@cd $(COMFYUI_DIR) && $(PYTHON) main.py --listen $(HOST) --port $(PORT)

run-cpu: ## Run ComfyUI in CPU mode (slower)
	@echo "$(BLUE)Starting ComfyUI in CPU mode...$(NC)"
	@cd $(COMFYUI_DIR) && $(PYTHON) main.py --listen $(HOST) --port $(PORT) --cpu

run-lowvram: ## Run ComfyUI with low VRAM optimizations
	@echo "$(BLUE)Starting ComfyUI with low VRAM mode...$(NC)"
	@cd $(COMFYUI_DIR) && $(PYTHON) main.py --listen $(HOST) --port $(PORT) --lowvram

run-mlx: ## Run ComfyUI with MLX acceleration (Apple Silicon only)
	@echo "$(BLUE)Starting ComfyUI with MLX acceleration for Apple Silicon...$(NC)"
	@echo "$(YELLOW)MLX provides up to 70% faster model loading & 35% faster inference$(NC)"
	@cd $(COMFYUI_DIR) && $(PYTHON) main.py --listen $(HOST) --port $(PORT)

dev: run ## Alias for run

update: ## Update ComfyUI and custom nodes
	@echo "$(YELLOW)Updating ComfyUI...$(NC)"
	@cd $(COMFYUI_DIR) && git pull
	@echo "$(YELLOW)Updating custom nodes...$(NC)"
	@cd $(COMFYUI_DIR)/custom_nodes && \
		for dir in */; do \
			if [ -d "$$dir/.git" ]; then \
				echo "Updating $$dir..."; \
				cd "$$dir" && git pull && cd ..; \
			fi \
		done
	@echo "$(GREEN)✓ Updates complete$(NC)"

clean: ## Remove generated files and caches
	@echo "$(YELLOW)Cleaning up...$(NC)"
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type f -name "*.pyo" -delete 2>/dev/null || true
	@find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

clean-output: ## Remove output videos
	@echo "$(YELLOW)Cleaning output directory...$(NC)"
	@rm -rf $(COMFYUI_DIR)/output/*
	@echo "$(GREEN)✓ Output cleaned$(NC)"

test: ## Run test suite
	@echo "$(YELLOW)Running Hanzo Painter tests...$(NC)"
	@$(PYTHON) -m pytest -v
	@echo "$(GREEN)✓ Tests complete$(NC)"

test-unit: ## Run unit tests only
	@echo "$(YELLOW)Running unit tests...$(NC)"
	@$(PYTHON) -m pytest -v -m unit
	@echo "$(GREEN)✓ Unit tests complete$(NC)"

test-integration: ## Run integration tests
	@echo "$(YELLOW)Running integration tests...$(NC)"
	@$(PYTHON) -m pytest -v -m integration
	@echo "$(GREEN)✓ Integration tests complete$(NC)"

test-coverage: ## Run tests with coverage report
	@echo "$(YELLOW)Running tests with coverage...$(NC)"
	@$(PYTHON) -m pytest --cov=. --cov-report=html --cov-report=term
	@echo "$(GREEN)✓ Coverage report generated in htmlcov/$(NC)"

test-comfyui: ## Test ComfyUI installation
	@echo "$(YELLOW)Testing ComfyUI installation...$(NC)"
	@cd $(COMFYUI_DIR) && $(PYTHON) -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda if torch.cuda.is_available() else \"N/A\"}')"
	@echo "$(GREEN)✓ ComfyUI test complete$(NC)"

info: ## Show installation info
	@echo "$(BLUE)Hanzo Painter - Installation Info$(NC)"
	@echo "ComfyUI Directory: $(COMFYUI_DIR)"
	@echo "Python: $$($(PYTHON) --version)"
	@echo "Port: $(PORT)"
	@echo "Host: $(HOST)"
	@if [ -d "$(COMFYUI_DIR)" ]; then \
		echo "$(GREEN)✓ ComfyUI installed$(NC)"; \
	else \
		echo "$(YELLOW)✗ ComfyUI not installed$(NC)"; \
	fi

uninstall: ## Remove ComfyUI installation
	@echo "$(YELLOW)This will remove $(COMFYUI_DIR). Are you sure? [y/N]$(NC)" && read ans && [ $${ans:-N} = y ]
	@rm -rf $(COMFYUI_DIR)
	@echo "$(GREEN)✓ ComfyUI uninstalled$(NC)"

models-info: ## Show downloaded models info
	@echo "$(BLUE)Downloaded Models:$(NC)"
	@echo ""
	@echo "$(YELLOW)SAM2 Models:$(NC)"
	@ls -lh $(COMFYUI_DIR)/models/sam2/ 2>/dev/null || echo "  No SAM2 models found"
	@echo ""
	@echo "$(YELLOW)Checkpoints:$(NC)"
	@ls -lh $(COMFYUI_DIR)/models/checkpoints/*.safetensors 2>/dev/null || echo "  No checkpoints found"
	@echo ""
	@echo "$(YELLOW)Diffusers:$(NC)"
	@ls -lh $(COMFYUI_DIR)/models/diffusers/*.safetensors 2>/dev/null || echo "  No diffusers found"

# Quick start aliases
all: setup install-workflow download-models ## Complete installation (setup + workflow + models)

start: run ## Start server (alias)

stop: ## Stop ComfyUI server
	@pkill -f "main.py.*$(PORT)" || echo "$(YELLOW)No running ComfyUI server found$(NC)"
