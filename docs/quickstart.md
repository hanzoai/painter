---
layout: default
title: Quick Start
---

# Quick Start Guide

Get Hanzo Studio running in minutes.

## Prerequisites

- Python 3.8+
- CUDA-compatible GPU (8GB+ VRAM recommended) OR Apple Silicon Mac (M1/M2/M3/M4 with MLX)
- Git, wget

## One-Command Setup

```bash
make all
```

This will:
1. Install Hanzo Studio
2. Install all Hanzo custom nodes
3. Download SAM2 models
4. Install the inpainting workflow

## Step-by-Step Setup

### 1. Install Hanzo Studio and Nodes

```bash
make setup              # Install Hanzo Studio and all custom nodes
```

### 2. Download Models

```bash
make download-models    # Download SAM2 models
```

You also need to manually download these models:

1. **realisticVisionV51_v51VAE.safetensors**
   - Download and place in `Hanzo Studio/models/checkpoints/`

2. **pcm_sd15_smallcfg_2step_converted.safetensors**
   - Download and place in `Hanzo Studio/models/diffusers/`

### 3. Install Workflow

```bash
make install-workflow   # Copy workflow to Hanzo Studio
```

### 4. Start Server

```bash
make run               # Standard mode
# OR
make run-mlx           # MLX acceleration (Apple Silicon)
# OR
make run-lowvram       # Low VRAM mode
# OR
make run-cpu           # CPU-only mode
```

### 5. Open Browser

Navigate to [http://localhost:8188](http://localhost:8188)

## Your First Inpainting

### 1. Prepare Your Video

Place your video file in `Hanzo Studio/input/`

### 2. Load Workflow

1. Open [http://localhost:8188](http://localhost:8188)
2. Load workflow: `workflows/inpainting-workflow.json`

### 3. Configure

Update the `VHS_LoadVideo` node with your video filename:

```json
"video": "your-video.mp4"
```

### 4. Adjust Parameters (Optional)

| Parameter | Default | Description |
|-----------|---------|-------------|
| num_inference_steps | 15 | Denoising steps |
| guidance_scale | 10 | Removal strength |
| video_length | 50 | Processing chunk size |
| frame_load_cap | 300 | Max frames to load |
| frame_rate | 8 | Output FPS |

### 5. Run

Click **"Queue Prompt"** in the UI

### 6. Get Results

Output video appears in `Hanzo Studio/output/`

## Optional Enhancements

### Install SAM2 for Advanced Segmentation

```bash
make install-sam2
```

### Install MLX for Apple Silicon Acceleration

```bash
make install-mlx
```

MLX provides:
- 70% faster model loading
- 35% faster inference
- 30% lower memory usage

## Next Steps

- [Installation Guide](installation) - Detailed setup information
- [Usage Guide](usage) - Advanced usage and configuration
- [Troubleshooting](troubleshooting) - Common issues and solutions

## Makefile Commands Reference

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

---

[← Back to Home](index) | [Installation Guide →](installation)
