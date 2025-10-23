---
layout: default
title: Installation
---

# Installation Guide

Comprehensive installation instructions for Hanzo Painter.

## System Requirements

### Hardware

**Minimum:**
- 8GB RAM
- 10GB free disk space

**GPU (Recommended):**
- NVIDIA GPU with 8GB+ VRAM (CUDA support)
- OR Apple Silicon (M1/M2/M3/M4) with MLX

**CPU-Only (Slower):**
- Multi-core CPU (4+ cores recommended)
- 16GB+ RAM

### Software

- Python 3.8+
- Git
- wget
- CUDA Toolkit 11.8+ (for NVIDIA GPUs)

## Installation Methods

### Method 1: Automated Setup (Recommended)

```bash
git clone https://github.com/hanzoai/painter.git
cd painter
make all
```

### Method 2: Manual Installation

#### Step 1: Clone Repository

```bash
git clone https://github.com/hanzoai/painter.git
cd painter
```

#### Step 2: Install ComfyUI

```bash
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
pip install -r requirements.txt
```

#### Step 3: Install Hanzo Custom Nodes

```bash
cd custom_nodes

# Hanzo-DiffuEraser
git clone https://github.com/hanzoai/Hanzo-DiffuEraser.git

# Hanzo-VideoHelper
git clone https://github.com/hanzoai/Hanzo-VideoHelper.git
cd Hanzo-VideoHelper && pip install -r requirements.txt && cd ..

# Hanzo-EasyUse
git clone https://github.com/hanzoai/Hanzo-EasyUse.git

# Hanzo-KJNodes
git clone https://github.com/hanzoai/Hanzo-KJNodes.git
cd Hanzo-KJNodes && pip install -r requirements.txt && cd ..

# Hanzo-LayerStyle
git clone https://github.com/hanzoai/Hanzo-LayerStyle.git

cd ../..
```

#### Step 4: Download Models

```bash
# SAM2 models (automated)
make download-models

# OR manually:
mkdir -p ComfyUI/models/sam2
wget -O ComfyUI/models/sam2/sam2_hiera_large.pt \
  https://dl.fbaipublicfiles.com/segment_anything_2/072824/sam2_hiera_large.pt
wget -O ComfyUI/models/sam2/sam2_hiera_base_plus.pt \
  https://dl.fbaipublicfiles.com/segment_anything_2/072824/sam2_hiera_base_plus.pt
```

**Required Manual Downloads:**

1. **Realistic Vision V5.1**
   - Download: [realisticVisionV51_v51VAE.safetensors](https://huggingface.co/SG161222/Realistic_Vision_V5.1_noVAE)
   - Place in: `ComfyUI/models/checkpoints/`

2. **PCM DiffuEraser Model**
   - Download: [pcm_sd15_smallcfg_2step_converted.safetensors](https://huggingface.co/wangfuyun/PCM_Weights)
   - Place in: `ComfyUI/models/diffusers/`

#### Step 5: Install Workflow

```bash
mkdir -p ComfyUI/workflows
cp inpainting-workflow.json ComfyUI/workflows/
```

### Method 3: Docker (Coming Soon)

```bash
docker compose up
```

## Optional Components

### SAM2 (Advanced Segmentation)

For precise object segmentation:

```bash
make install-sam2
```

### MLX (Apple Silicon Acceleration)

For M1/M2/M3/M4 Macs:

```bash
make install-mlx
```

Benefits:
- 70% faster model loading
- 35% faster inference
- 30% lower memory usage

**Note:** Currently optimized for Flux models. SD 1.5 support coming soon.

## Verification

### Test Installation

```bash
make test
```

Expected output:
```
PyTorch: 2.x.x
CUDA available: True (or False for CPU/MLX)
CUDA version: 11.8+ (if GPU)
```

### Check Installed Components

```bash
make info
```

### Verify Models

```bash
make models-info
```

Should show:
- SAM2 models (2 files)
- Checkpoint models
- Diffuser models

## Platform-Specific Notes

### Windows

Install in WSL2 for best compatibility:

```bash
# In WSL2
sudo apt-get update
sudo apt-get install python3-pip git wget
make all
```

### macOS

Install Homebrew dependencies:

```bash
brew install python@3.11 git wget
make all
```

For Apple Silicon, install MLX:

```bash
make install-mlx
```

### Linux

Install dependencies:

```bash
# Ubuntu/Debian
sudo apt-get install python3-pip git wget

# Fedora/RHEL
sudo dnf install python3-pip git wget

# Arch
sudo pacman -S python-pip git wget
```

For NVIDIA GPUs, install CUDA toolkit:

```bash
# Follow NVIDIA's official guide
# https://developer.nvidia.com/cuda-downloads
```

## Troubleshooting Installation

### Common Issues

**"Python not found"**

```bash
# Install Python 3.8+
# macOS
brew install python@3.11

# Ubuntu
sudo apt-get install python3.11

# Windows
# Download from python.org
```

**"Git not found"**

```bash
# macOS
brew install git

# Ubuntu
sudo apt-get install git

# Windows
# Download from git-scm.com
```

**"CUDA out of memory"**

- Use `make run-lowvram`
- Reduce `video_length` parameter
- Close other GPU-intensive applications

**"Module not found"**

```bash
# Reinstall dependencies
cd ComfyUI
pip install -r requirements.txt --force-reinstall
```

**"Models not found"**

```bash
# Verify model paths
make models-info

# Re-download if needed
make download-models
```

## Updating

Keep Hanzo Painter up to date:

```bash
# Update all components
make update

# This updates:
# - ComfyUI core
# - All custom nodes
# - Git pulls latest changes
```

## Uninstalling

Remove Hanzo Painter:

```bash
make uninstall
```

**Warning:** This removes the entire ComfyUI directory including downloaded models.

---

[← Quick Start](quickstart) | [Usage Guide →](usage)
