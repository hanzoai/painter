# Painter - LLM Context

## Overview

AI-powered video inpainting platform built on Hanzo Studio (ComfyUI fork). Content-aware removal and reconstruction of video/image elements using diffusion models.

**Status**: Phase 1 complete (inpainting works). Future: expand to full "Hanzo Studio" creative suite.

## Tech Stack

- Python 3.8+, PyTorch
- CUDA (GPU) or MLX (Apple Silicon: 70% faster model loading, 35% faster inference)
- Node-based visual workflow system (ComfyUI)

## AI Models

| Model | Size | Purpose |
|-------|------|---------|
| DiffuEraser | - | Core inpainting engine |
| SAM2 Large | 856MB | Advanced object segmentation |
| SAM2 Base Plus | 344MB | Faster segmentation |
| Realistic Vision v5.1 | 4.3GB | Base SD 1.5 model |
| PCM (Phased Consistency) | 1.7GB | Fast 2-step inference |

## Custom Nodes (Hanzo forks)

| Node | Upstream | Purpose |
|------|----------|---------|
| Hanzo-DiffuEraser | smthemex/ComfyUI_DiffuEraser | Inpainting engine |
| Hanzo-VideoHelper | Kosinkadink/ComfyUI-VideoHelperSuite | Video I/O |
| Hanzo-EasyUse | yolain/ComfyUI-Easy-Use | Simplified workflows |
| Hanzo-KJNodes | kijai/ComfyUI-KJNodes | Core utilities |
| Hanzo-LayerStyle | chflame163/ComfyUI_LayerStyle | Compositing |
| Hanzo-MLX | thoddnn/ComfyUI-MLX | Apple Silicon acceleration |

Fork philosophy: maintain upstream compat, add Hanzo enhancements, sync regularly.

## Directory Structure

```
painter/
  Studio@              Symlink to ~/work/hanzo/Studio
  Makefile             Automation commands
  requirements.txt     Python dependencies
  inpainting-workflow.json

~/work/hanzo/Studio/   Main Studio repo (v0.3.71)
  studio/              Core Python package
    studio_types/      Type definitions (renamed from comfy_types)
  custom_nodes/        Hanzo custom nodes
  models/              checkpoints/, diffusers/, sam2/
  input/               Source videos/images
  output/              Processed results
  workflows/           Workflow JSON files
```

## Inpainting Pipeline

```
Input Video -> Frame Extraction -> DiffuEraser -> Temporal Smoothing -> Re-encode -> Output
                    |                   |
                 SAM2 Mask       Context Analysis
```

Key parameters:
- `num_inference_steps`: 15 (quality vs speed)
- `guidance_scale`: 10 (removal strength; 12-15 for high quality)
- `video_length`: 50 frames (reduce to 25-30 for low VRAM)
- `frame_rate`: 8 FPS

## Commands

```bash
# Setup
make setup              # Install Studio + nodes
make download-models    # Download SAM2 models
make all                # Complete setup

# Running
make run                # Start server (0.0.0.0:8188)
make run-mlx            # Apple Silicon
make run-lowvram        # Low VRAM mode
make run-cpu            # CPU-only (slow)

# Maintenance
make update             # Update Studio + nodes
make clean              # Clear caches
make test               # Run test suite
```

## Docker

```bash
docker compose up -d                    # Production
docker compose -f compose.dev.yml up    # Development
```

## Gotchas

- Studio package installed in editable mode: `pip install -e ~/work/hanzo/Studio`
- Type system unified under `studio.studio_types` namespace
- `comfy_types` was renamed to `studio_types` -- no remaining old references
- Use `uv` for Python virtualenv per project conventions
