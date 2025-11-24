.PHONY: help setup install-studio install-nodes download-models run clean test check-deps runpod docker-build setup-venv install-uv venv-deps

# Configuration
STUDIO_DIR ?= ./Studio
PYTHON_VERSION ?= 3.11
VENV := .venv
PYTHON := $(VENV)/bin/python
PIP := $(VENV)/bin/pip
UV := uv
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
	@echo ""
	@echo "$(YELLOW)Quick Start (using uv + venv):$(NC)"
	@echo "  make setup-venv    # Install uv, create venv, install deps"
	@echo "  make run          # Start server"
	@echo ""
	@echo "$(YELLOW)Available targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

install-uv: ## Install uv package manager
	@echo "$(YELLOW)Checking for uv...$(NC)"
	@if ! command -v uv &> /dev/null; then \
		echo "$(YELLOW)Installing uv...$(NC)"; \
		curl -LsSf https://astral.sh/uv/install.sh | sh; \
		echo "$(GREEN)✓ uv installed$(NC)"; \
	else \
		echo "$(GREEN)✓ uv already installed$(NC)"; \
	fi

setup-venv: install-uv ## Create virtual environment and install all dependencies (RECOMMENDED)
	@echo "$(YELLOW)Setting up virtual environment...$(NC)"
	@if [ ! -d "$(VENV)" ]; then \
		echo "$(YELLOW)Installing Python $(PYTHON_VERSION)...$(NC)"; \
		$(UV) python install $(PYTHON_VERSION); \
		echo "$(YELLOW)Creating virtual environment...$(NC)"; \
		$(UV) venv $(VENV) --python $(PYTHON_VERSION); \
		echo "$(GREEN)✓ Virtual environment created$(NC)"; \
	else \
		echo "$(GREEN)✓ Virtual environment already exists$(NC)"; \
	fi
	@$(MAKE) venv-deps
	@echo "$(GREEN)✓ Setup complete!$(NC)"
	@echo "$(YELLOW)Activate with: source $(VENV)/bin/activate$(NC)"

venv-deps: ## Install Studio dependencies in virtual environment
	@echo "$(YELLOW)Installing dependencies in venv...$(NC)"
	@if [ ! -d "$(VENV)" ]; then \
		echo "$(BLUE)Run 'make setup-venv' first$(NC)"; \
		exit 1; \
	fi
	@if [ ! -d "$(STUDIO_DIR)" ]; then \
		echo "$(YELLOW)Cloning Hanzo Studio...$(NC)"; \
		git clone https://github.com/hanzoai/studio.git $(STUDIO_DIR); \
	fi
	@echo "$(YELLOW)Installing Python packages...$(NC)"
	@cd $(STUDIO_DIR) && \
		source ../$(VENV)/bin/activate && \
		$(UV) pip install pyyaml pillow typing_extensions && \
		grep -v "segment-anything" requirements.txt > /tmp/requirements-filtered.txt && \
		$(UV) pip install -r /tmp/requirements-filtered.txt && \
		$(UV) pip install -e . && \
		rm -f /tmp/requirements-filtered.txt
	@bash install-nodes.sh || echo "$(YELLOW)⚠ Custom nodes installation had some issues$(NC)"
	@echo "$(GREEN)✓ Dependencies installed$(NC)"

check-deps: ## Check if required dependencies are installed
	@echo "$(YELLOW)Checking dependencies...$(NC)"
	@command -v $(PYTHON) >/dev/null 2>&1 || { echo "Python 3 is required but not installed. Aborting." >&2; exit 1; }
	@command -v git >/dev/null 2>&1 || { echo "Git is required but not installed. Aborting." >&2; exit 1; }
	@command -v wget >/dev/null 2>&1 || { echo "wget is required but not installed. Aborting." >&2; exit 1; }
	@echo "$(GREEN)✓ All dependencies found$(NC)"

setup: check-deps install-studio install-nodes ## Complete setup (install Studio and nodes)
	@echo "$(GREEN)✓ Setup complete! Run 'make download-models' to get required models$(NC)"

install-studio: check-deps ## Install Hanzo Studio
	@if [ ! -d "$(STUDIO_DIR)" ]; then \
		echo "$(YELLOW)Installing Hanzo Studio...$(NC)"; \
		git clone git@github.com:comfyanonymous/ComfyUI.git $(STUDIO_DIR); \
		cd $(STUDIO_DIR) && $(PIP) install -r requirements.txt; \
		echo "$(GREEN)✓ Studio installed$(NC)"; \
	else \
		echo "$(YELLOW)Studio already installed at $(STUDIO_DIR)$(NC)"; \
	fi

install-nodes: ## Install required custom nodes
	@echo "$(YELLOW)Installing Hanzo custom nodes...$(NC)"
	@cd $(STUDIO_DIR)/custom_nodes && \
		if [ ! -d "Hanzo-DiffuEraser" ]; then \
			git clone git@github.com:hanzoai/Hanzo-DiffuEraser.git && \
			echo "$(GREEN)✓ Hanzo-DiffuEraser installed$(NC)"; \
		fi
	@cd $(STUDIO_DIR)/custom_nodes && \
		if [ ! -d "Hanzo-VideoHelper" ]; then \
			git clone git@github.com:hanzoai/Hanzo-VideoHelper.git && \
			cd Hanzo-VideoHelper && $(PIP) install -r requirements.txt && \
			echo "$(GREEN)✓ Hanzo-VideoHelper installed$(NC)"; \
		fi
	@cd $(STUDIO_DIR)/custom_nodes && \
		if [ ! -d "Hanzo-EasyUse" ]; then \
			git clone git@github.com:hanzoai/Hanzo-EasyUse.git && \
			echo "$(GREEN)✓ Hanzo-EasyUse installed$(NC)"; \
		fi
	@cd $(STUDIO_DIR)/custom_nodes && \
		if [ ! -d "Hanzo-KJNodes" ]; then \
			git clone git@github.com:hanzoai/Hanzo-KJNodes.git && \
			cd Hanzo-KJNodes && $(PIP) install -r requirements.txt && \
			echo "$(GREEN)✓ Hanzo-KJNodes installed$(NC)"; \
		fi
	@cd $(STUDIO_DIR)/custom_nodes && \
		if [ ! -d "Hanzo-LayerStyle" ]; then \
			git clone git@github.com:hanzoai/Hanzo-LayerStyle.git && \
			echo "$(GREEN)✓ Hanzo-LayerStyle installed$(NC)"; \
		fi
	@echo "$(GREEN)✓ All Hanzo custom nodes installed$(NC)"

install-sam2: ## Install SAM2 (optional advanced segmentation)
	@echo "$(YELLOW)Installing SAM2...$(NC)"
	@cd $(STUDIO_DIR)/custom_nodes && \
		if [ ! -d "ComfyUI-SAM2" ]; then \
			git clone git@github.com:cubiq/ComfyUI-SAM2.git && \
			cd ComfyUI-SAM2 && $(PIP) install -r requirements.txt && \
			echo "$(GREEN)✓ SAM2 installed$(NC)"; \
		else \
			echo "$(YELLOW)SAM2 already installed$(NC)"; \
		fi

install-mlx: ## Install MLX support for Apple Silicon acceleration
	@echo "$(YELLOW)Installing Hanzo-MLX for Apple Silicon...$(NC)"
	@cd $(STUDIO_DIR)/custom_nodes && \
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
	@mkdir -p $(STUDIO_DIR)/models/sam2
	@if [ ! -f "$(STUDIO_DIR)/models/sam2/sam2_hiera_large.pt" ]; then \
		echo "$(YELLOW)Downloading SAM2 Large model...$(NC)"; \
		wget -O $(STUDIO_DIR)/models/sam2/sam2_hiera_large.pt $(SAM2_LARGE_URL); \
		echo "$(GREEN)✓ SAM2 Large downloaded$(NC)"; \
	else \
		echo "$(YELLOW)SAM2 Large already downloaded$(NC)"; \
	fi
	@if [ ! -f "$(STUDIO_DIR)/models/sam2/sam2_hiera_base_plus.pt" ]; then \
		echo "$(YELLOW)Downloading SAM2 Base Plus model...$(NC)"; \
		wget -O $(STUDIO_DIR)/models/sam2/sam2_hiera_base_plus.pt $(SAM2_BASE_URL); \
		echo "$(GREEN)✓ SAM2 Base Plus downloaded$(NC)"; \
	else \
		echo "$(YELLOW)SAM2 Base Plus already downloaded$(NC)"; \
	fi
	@echo "$(GREEN)✓ Models downloaded$(NC)"
	@echo "$(YELLOW)Note: You need to manually download these models:$(NC)"
	@echo "  - realisticVisionV51_v51VAE.safetensors → $(STUDIO_DIR)/models/checkpoints/"
	@echo "  - pcm_sd15_smallcfg_2step_converted.safetensors → $(STUDIO_DIR)/models/diffusers/"

install-workflow: ## Copy workflow to Studio
	@echo "$(YELLOW)Installing workflow...$(NC)"
	@mkdir -p $(STUDIO_DIR)/workflows
	@cp inpainting-workflow.json $(STUDIO_DIR)/workflows/
	@echo "$(GREEN)✓ Workflow installed to $(STUDIO_DIR)/workflows/$(NC)"

run: ## Run Hanzo Studio server
	@echo "$(BLUE)Starting Hanzo Studio on $(HOST):$(PORT)...$(NC)"
	@cd $(STUDIO_DIR) && $(PYTHON) main.py --listen $(HOST) --port $(PORT)

run-cpu: ## Run Hanzo Studio in CPU mode (slower)
	@echo "$(BLUE)Starting Hanzo Studio in CPU mode...$(NC)"
	@cd $(STUDIO_DIR) && $(PYTHON) main.py --listen $(HOST) --port $(PORT) --cpu

run-lowvram: ## Run Hanzo Studio with low VRAM optimizations
	@echo "$(BLUE)Starting Hanzo Studio with low VRAM mode...$(NC)"
	@cd $(STUDIO_DIR) && $(PYTHON) main.py --listen $(HOST) --port $(PORT) --lowvram

run-mlx: ## Run Hanzo Studio with MLX acceleration (Apple Silicon only)
	@echo "$(BLUE)Starting Hanzo Studio with MLX acceleration for Apple Silicon...$(NC)"
	@echo "$(YELLOW)MLX provides up to 70% faster model loading & 35% faster inference$(NC)"
	@cd $(STUDIO_DIR) && $(PYTHON) main.py --listen $(HOST) --port $(PORT)

dev: run ## Alias for run

update: ## Update Studio and custom nodes
	@echo "$(YELLOW)Updating Studio...$(NC)"
	@cd $(STUDIO_DIR) && git pull
	@echo "$(YELLOW)Updating custom nodes...$(NC)"
	@cd $(STUDIO_DIR)/custom_nodes && \
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
	@rm -rf $(STUDIO_DIR)/output/*
	@echo "$(GREEN)✓ Output cleaned$(NC)"

test: ## Run test suite
	@echo "$(YELLOW)Running Hanzo Studio tests...$(NC)"
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

test-studio: ## Test Studio installation
	@echo "$(YELLOW)Testing Studio installation...$(NC)"
	@cd $(STUDIO_DIR) && $(PYTHON) -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda if torch.cuda.is_available() else \"N/A\"}')"
	@echo "$(GREEN)✓ Studio test complete$(NC)"

info: ## Show installation info
	@echo "$(BLUE)Hanzo Studio - Installation Info$(NC)"
	@echo "Studio Directory: $(STUDIO_DIR)"
	@echo "Python: $$($(PYTHON) --version)"
	@echo "Port: $(PORT)"
	@echo "Host: $(HOST)"
	@if [ -d "$(STUDIO_DIR)" ]; then \
		echo "$(GREEN)✓ Studio installed$(NC)"; \
	else \
		echo "$(YELLOW)✗ Studio not installed$(NC)"; \
	fi

uninstall: ## Remove Studio installation
	@echo "$(YELLOW)This will remove $(STUDIO_DIR). Are you sure? [y/N]$(NC)" && read ans && [ $${ans:-N} = y ]
	@rm -rf $(STUDIO_DIR)
	@echo "$(GREEN)✓ Studio uninstalled$(NC)"

models-info: ## Show downloaded models info
	@echo "$(BLUE)Downloaded Models:$(NC)"
	@echo ""
	@echo "$(YELLOW)SAM2 Models:$(NC)"
	@ls -lh $(STUDIO_DIR)/models/sam2/ 2>/dev/null || echo "  No SAM2 models found"
	@echo ""
	@echo "$(YELLOW)Checkpoints:$(NC)"
	@ls -lh $(STUDIO_DIR)/models/checkpoints/*.safetensors 2>/dev/null || echo "  No checkpoints found"
	@echo ""
	@echo "$(YELLOW)Diffusers:$(NC)"
	@ls -lh $(STUDIO_DIR)/models/diffusers/*.safetensors 2>/dev/null || echo "  No diffusers found"

# Quick start aliases
all: setup install-workflow download-models ## Complete installation (setup + workflow + models)

start: run ## Start server (alias)

stop: ## Stop Studio server
	@pkill -f "main.py.*$(PORT)" || echo "$(YELLOW)No running Studio server found$(NC)"

runpod: ## Quick start for RunPod deployment
	@echo "$(BLUE)🚀 Starting Hanzo Studio (RunPod mode)$(NC)"
	@bash runpod-start.sh

docker-build: ## Build Docker image for RunPod
	@echo "$(BLUE)🐳 Building Docker image...$(NC)"
	@docker build -t hanzo-studio:latest .
	@echo "$(GREEN)✓ Build complete$(NC)"
	@echo "Run with: docker run --gpus all -p 8188:8188 hanzo-studio:latest"
