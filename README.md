# Hanzo Studio

[![Tests](https://github.com/hanzoai/painter/actions/workflows/tests.yml/badge.svg)](https://github.com/hanzoai/painter/actions/workflows/tests.yml)
[![Docker](https://github.com/hanzoai/painter/actions/workflows/docker.yml/badge.svg)](https://github.com/hanzoai/painter/actions/workflows/docker.yml)
[![License](https://img.shields.io/badge/license-Educational-blue.svg)](LICENSE)

AI-powered content-aware inpainting for videos and images. Intelligently remove and reconstruct content using Hanzo Studio, DiffuEraser, and SAM2.

Part of the [Hanzo AI](https://hanzo.ai) ecosystem.

![Workflow](workflow-screenshot.png)

## Features

- 🎨 **Content-Aware Inpainting** - AI reconstructs removed areas intelligently
- 🪄 **Smart Removal** - Remove watermarks, objects, blemishes, or any unwanted elements
- 🧠 **Context Understanding** - Analyzes surroundings to generate realistic fill content
- 🤖 **SAM2 Integration** - Click-to-segment any object with precision (optional)
- 🎬 **Temporal Consistency** - Smooth, flicker-free video output across frames
- 🔊 **Audio Preservation** - Maintains original audio track
- ⚡ **GPU-Accelerated** - Fast processing with CUDA support
- 🍎 **MLX Support** - Native Apple Silicon acceleration (70% faster model loading, 35% faster inference)

## Quick Start

### One-Command Deployment ⚡

The simplest way to get started - works on **local machines**, **cloud VMs**, and **RunPod**:

```bash
git clone https://github.com/hanzoai/painter.git && \
cd painter && \
bash runpod-start.sh
```

**What it does automatically:**
1. ✅ Detects your environment (local/cloud/RunPod)
2. ✅ Clones Hanzo Studio from [hanzoai/studio](https://github.com/hanzoai/studio)
3. ✅ Installs all Python dependencies (filtering segment-anything-2)
4. ✅ Installs 5 Hanzo custom nodes with their requirements
5. ✅ Downloads SAM2 models (if wget available)
6. ✅ Starts server on port 8188

**Local Development:**
```bash
# From your home directory or any location
cd ~/projects  # or any directory
git clone https://github.com/hanzoai/painter.git
cd painter
bash runpod-start.sh  # Auto-detects local environment

# Access at http://localhost:8188
```

**RunPod (Cloud GPU):**
```bash
# From RunPod terminal - use /workspace
git clone https://github.com/hanzoai/painter.git /workspace/painter && \
cd /workspace/painter && \
bash runpod-start.sh  # Auto-detects RunPod environment

# Server auto-exposes on pod's proxy URL
```

**Cost**: ~$0.40-0.50/hour (RTX 3090/4090) | See [RUNPOD.md](RUNPOD.md) for details

### Traditional Makefile Setup

Prefer step-by-step installation with Make:

```bash
make all                # Complete setup: Studio + nodes + models
make run                # Start server on localhost:8188

# Or step by step
make setup              # Install Hanzo Studio + custom nodes
make download-models    # Download SAM2 models
make install-workflow   # Copy workflow to Hanzo Studio
```

## Manual Installation

### Prerequisites

- Python 3.8+
- CUDA-compatible GPU (8GB+ VRAM recommended) OR Apple Silicon Mac (M1/M2/M3/M4 with MLX)
- Git, wget

```bash
# Using Make (recommended)
make setup              # Install Hanzo Studio and all custom nodes
make install-sam2       # (Optional) Install SAM2 for advanced segmentation
make install-mlx        # (Optional) Install MLX for Apple Silicon acceleration
make download-models    # Download SAM2 models
make install-workflow   # Copy workflow to Hanzo Studio

# Manual installation
git clone https://github.com/comfyanonymous/Hanzo Studio.git
cd Hanzo Studio && pip install -r requirements.txt
```

### Required Models

Place these in `Hanzo Studio/models/`:

1. **checkpoints/realisticVisionV51_v51VAE.safetensors**
2. **diffusers/pcm_sd15_smallcfg_2step_converted.safetensors**
3. **sam2/** (auto-downloaded via `make download-models`)

### Hanzo Custom Nodes (Auto-installed)

The deployment script automatically installs **5 essential custom nodes** to `Studio/custom_nodes/`:

| Node | Purpose | Auto-Install | Repository |
|------|---------|--------------|------------|
| **Hanzo-DiffuEraser** | Content-aware video/image inpainting engine | ✅ Required | [hanzoai/Hanzo-DiffuEraser](https://github.com/hanzoai/Hanzo-DiffuEraser) |
| **Hanzo-VideoHelper** | Video I/O, frame extraction, encoding | ✅ Required | [hanzoai/Hanzo-VideoHelper](https://github.com/hanzoai/Hanzo-VideoHelper) |
| **Hanzo-EasyUse** | Simplified workflow utilities and helpers | ✅ Required | [hanzoai/Hanzo-EasyUse](https://github.com/hanzoai/Hanzo-EasyUse) |
| **Hanzo-KJNodes** | Core utility nodes with JWInteger support | ✅ Required | [hanzoai/Hanzo-KJNodes](https://github.com/hanzoai/Hanzo-KJNodes) |
| **Hanzo-LayerStyle** | Photoshop-like layer compositing effects | ✅ Required | [hanzoai/Hanzo-LayerStyle](https://github.com/hanzoai/Hanzo-LayerStyle) |
| **Hanzo-MLX** | Native Apple Silicon (M1/M2/M3/M4) acceleration | ⚙️ Optional | Install with `make install-mlx` |
| **ComfyUI-SAM2** | Segment Anything Model 2 for object segmentation | ⚙️ Optional | Install with `make install-sam2` |

**Installation Details:**
- Nodes are cloned from GitHub during setup
- Each node's `requirements.txt` is automatically installed
- If nodes already exist, they're skipped (no reinstall)
- Works offline if nodes are pre-installed
- See `install-nodes.sh` for implementation details

## Usage

```bash
# Start server
make run                # Standard mode
make run-mlx            # MLX acceleration (Apple Silicon only)
make run-lowvram        # Low VRAM mode
make run-cpu            # CPU-only mode

# Access at http://localhost:8188
# Load workflow: workflows/inpainting-workflow.json
```

### Processing Workflow

1. Place video in `Hanzo Studio/input/`
2. Open http://localhost:8188
3. Load `inpainting-workflow.json`
4. Update video filename in `VHS_LoadVideo` node
5. Configure parameters (see below)
6. Click "Queue Prompt"
7. Output appears in `Hanzo Studio/output/`

## Configuration

### Key Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| num_inference_steps | 15 | Denoising steps |
| guidance_scale | 10 | Removal strength |
| video_length | 50 | Processing chunk size |
| frame_load_cap | 300 | Max frames to load |
| frame_rate | 8 | Output FPS |

### Performance Tuning

**Out of memory?**
- Reduce `video_length` or `subvideo_length`
- Use `make run-lowvram`
- Decrease `frame_load_cap`

**Too slow?**
- Increase `ref_stride`
- Reduce `neighbor_length`
- Lower `num_inference_steps`

**Poor quality?**
- Increase `guidance_scale`
- Add more `num_inference_steps`
- Enable SAM2 for better masks

## Makefile Commands

```bash
make help               # Show all commands
make setup              # Complete setup
make all                # Setup + workflow + models
make run                # Start Hanzo Studio server
make update             # Update Hanzo Studio and nodes
make test               # Test installation
make clean              # Remove caches
make info               # Show installation info
make models-info        # Show downloaded models
```

## Architecture

### Processing Pipeline

```
Input Video → Load & Process → DiffuEraser → SAM2 (optional) → Output Video
                                    ↓
                            Watermark Removal
                                    ↓
                            Temporal Smoothing
```

### Deployment Architecture

**Integration with Main Studio:**

This project builds on the main [Hanzo Studio repository](https://github.com/hanzoai/studio), sharing:
- ✅ Core Python package (`hanzo-studio`)
- ✅ Unified type system (`studio.studio_types` namespace)
- ✅ Custom nodes architecture
- ✅ Model management and workflows

**Directory Structure:**
```
painter/                         # This repository
├── runpod-start.sh             # One-command deployment script
├── install-nodes.sh            # Automatic custom nodes installer
├── inpainting-workflow.json    # Pre-configured workflow
├── Dockerfile                  # RunPod-optimized container
└── Studio/                     # Symlink to ~/work/hanzo/Studio

~/work/hanzo/Studio/            # Main Studio repository
├── main.py                     # Studio server entry point
├── studio/                     # Core Python package
│   ├── studio_types/          # Unified type definitions
│   └── ...
├── custom_nodes/              # Auto-installed custom nodes
│   ├── Hanzo-DiffuEraser/
│   ├── Hanzo-VideoHelper/
│   ├── Hanzo-EasyUse/
│   ├── Hanzo-KJNodes/
│   └── Hanzo-LayerStyle/
└── models/                    # Downloaded models
    ├── sam2/
    ├── checkpoints/
    └── diffusers/
```

**Environment Auto-Detection:**

The `runpod-start.sh` script intelligently adapts to your environment:

```bash
# Detection logic
if [ -n "$RUNPOD_POD_ID" ]; then
    WORKSPACE=/workspace              # RunPod environment
elif [ -d "/workspace" ]; then
    WORKSPACE=/workspace              # Cloud VM
else
    WORKSPACE="$(pwd)"                # Local development
fi
```

This ensures the same deployment script works everywhere without modification.

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| **Server won't start** | Check Python version (3.8-3.11 recommended, 3.14 has PIL issues) |
| **CUDA out of memory** | Use `make run-lowvram` or reduce `video_length` parameter |
| **Models not found** | Run `make download-models` or check `Studio/models/sam2/` |
| **Slow processing** | Reduce `video_length`, increase `ref_stride`, or use better GPU |
| **Poor inpainting quality** | Increase `guidance_scale` (10-20), add `num_inference_steps`, enable SAM2 |
| **Custom nodes missing** | Run `bash install-nodes.sh` manually or check `Studio/custom_nodes/` |
| **Port 8188 in use** | Kill existing process: `lsof -i :8188` then `kill -9 PID` |

### Deployment-Specific Issues

**Local Development:**
```bash
# Missing dependencies
pip3 install pyyaml pillow torch torchvision torchaudio

# Wrong Python version
PYTHON=/usr/bin/python3.11 make run  # Specify Python path

# Permission issues
chmod +x runpod-start.sh install-nodes.sh
```

**RunPod:**
```bash
# Check environment detection
echo $RUNPOD_POD_ID  # Should show pod ID
ls -la /workspace     # Should exist

# Manual workspace setup
export WORKSPACE=/workspace
cd $WORKSPACE && bash runpod-start.sh

# Check GPU availability
nvidia-smi  # Verify GPU is accessible
```

**Environment Auto-Detection:**

The deployment script (`runpod-start.sh`) automatically detects your environment:

1. **RunPod** - Checks for `$RUNPOD_POD_ID` environment variable
2. **Cloud VM** - Checks if `/workspace` directory exists
3. **Local** - Falls back to current working directory

If auto-detection fails, manually set workspace:
```bash
export WORKSPACE=/your/preferred/path
bash runpod-start.sh
```

### Verification Commands

```bash
# Check installation
make info                    # Show paths and versions
make models-info             # List downloaded models
ls Studio/custom_nodes/      # Verify 5 Hanzo nodes installed

# Test server accessibility
curl http://localhost:8188/  # Local
curl http://localhost:8188/system_stats  # API health check

# Check logs
tail -f Studio/comfyui.log   # Server logs
python3 --version            # Python version
pip3 list | grep -i torch    # PyTorch installation
```

## Development

```bash
make clean              # Clean caches
make update             # Update all components
make uninstall          # Remove Hanzo Studio
```

## License

Educational and research purposes only.

## How It Works

1. **Mask Selection** - Use SAM2 to click/segment objects or create manual masks
2. **Context Analysis** - AI analyzes surrounding pixels and video frames
3. **Intelligent Reconstruction** - Diffusion model generates realistic fill content
4. **Temporal Blending** - Ensures smooth consistency across frames
5. **Output** - Clean video with removed content seamlessly inpainted

**Note**: This is true inpainting, not just erasing. The AI intelligently reconstructs what should be there based on context.

## Deployment Features

### Intelligent Environment Detection

The deployment script provides a seamless experience across all platforms:

✅ **Zero Configuration** - Same command works everywhere
✅ **Automatic Path Detection** - Adapts to local/cloud/RunPod environments
✅ **Dependency Filtering** - Skips problematic packages (segment-anything-2)
✅ **Graceful Fallbacks** - Works even if tools like wget/git are missing
✅ **Smart Caching** - Skips already-installed components for faster restarts
✅ **Comprehensive Logging** - Clear status messages for each step

### What Gets Installed

When you run `bash runpod-start.sh`, the script:

1. **Detects your environment** (RunPod vs cloud VM vs local machine)
2. **Clones Hanzo Studio** from github.com/hanzoai/studio (if not present)
3. **Installs Python dependencies** (filtering segment-anything-2 from requirements)
4. **Installs hanzo-studio package** in editable mode for development
5. **Clones 5 custom nodes** from github.com/hanzoai (if not present):
   - Hanzo-DiffuEraser
   - Hanzo-VideoHelper
   - Hanzo-EasyUse
   - Hanzo-KJNodes
   - Hanzo-LayerStyle
6. **Installs each node's requirements** (with error handling)
7. **Downloads SAM2 models** (if wget available and models not present)
8. **Starts the server** on port 8188 with proper host binding

**Smart Skipping**: Already installed components are detected and skipped, making subsequent runs much faster.

## Hanzo Studio Ecosystem

Hanzo Studio uses a curated stack of Hanzo Studio custom nodes maintained as **Hanzo forks**. This approach ensures:

- ✅ **Stability** - Tested versions that work together seamlessly
- ✅ **Upstream Sync** - Regular updates from original maintainers
- ✅ **Hanzo Enhancements** - Custom improvements and integrations
- ✅ **Unified Support** - Single source of truth for the Hanzo ecosystem

### Hanzo Custom Nodes

All nodes are available at [github.com/hanzoai](https://github.com/hanzoai):

| Node | Purpose | Upstream |
|------|---------|----------|
| **Hanzo-DiffuEraser** | Content-aware inpainting | smthemex/Hanzo Studio_DiffuEraser |
| **Hanzo-VideoHelper** | Video I/O suite | Kosinkadink/ComfyUI-VideoHelperSuite |
| **Hanzo-EasyUse** | Workflow utilities | yolain/ComfyUI-Easy-Use |
| **Hanzo-KJNodes** | Core utilities | kijai/ComfyUI-KJNodes |
| **Hanzo-LayerStyle** | Layer compositing | chflame163/Hanzo Studio_LayerStyle |
| **Hanzo-MLX** | Apple Silicon acceleration | thoddnn/ComfyUI-MLX |

### Contributing

Improvements to Hanzo custom nodes benefit the entire ecosystem:

1. **Fork & PR** - Submit PRs to Hanzo forks for Hanzo-specific features
2. **Upstream First** - For general improvements, contribute to upstream repos
3. **Sync Back** - Hanzo forks regularly pull upstream changes

## About

Hanzo Studio is part of the [Hanzo AI](https://hanzo.ai) ecosystem, providing AI infrastructure and services for developers.

- **hanzo.ai** - Core AI infrastructure platform
- **hanzo.io** - Business solutions
- **hanzo.network** - Decentralized compute marketplace

---

Made with ❤️ by [Hanzo AI](https://hanzo.ai)
