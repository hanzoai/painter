---
layout: default
title: Home
---

# Hanzo Painter

AI-powered content-aware inpainting for videos and images. Intelligently remove and reconstruct content using ComfyUI, DiffuEraser, and SAM2.

Part of the [Hanzo AI](https://hanzo.ai) ecosystem.

![Workflow](https://raw.githubusercontent.com/hanzoai/painter/main/workflow-screenshot.png)

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

```bash
# Complete setup
make all

# Or step by step
make setup              # Install ComfyUI + nodes
make download-models    # Download SAM2 models
make install-workflow   # Copy workflow to ComfyUI
make run               # Start server on localhost:8188
```

Visit [Quick Start Guide](quickstart) for detailed instructions.

## Documentation

- [Installation Guide](installation) - Detailed setup instructions
- [Usage Guide](usage) - How to use Hanzo Painter
- [Troubleshooting](troubleshooting) - Common issues and solutions
- [GitHub Repository](https://github.com/hanzoai/painter) - Source code

## How It Works

1. **Mask Selection** - Use SAM2 to click/segment objects or create manual masks
2. **Context Analysis** - AI analyzes surrounding pixels and video frames
3. **Intelligent Reconstruction** - Diffusion model generates realistic fill content
4. **Temporal Blending** - Ensures smooth consistency across frames
5. **Output** - Clean video with removed content seamlessly inpainted

**Note**: This is true inpainting, not just erasing. The AI intelligently reconstructs what should be there based on context.

## Hanzo ComfyUI Ecosystem

Hanzo Painter uses a curated stack of ComfyUI custom nodes maintained as **Hanzo forks**. This approach ensures:

- ✅ **Stability** - Tested versions that work together seamlessly
- ✅ **Upstream Sync** - Regular updates from original maintainers
- ✅ **Hanzo Enhancements** - Custom improvements and integrations
- ✅ **Unified Support** - Single source of truth for the Hanzo ecosystem

### Hanzo Custom Nodes

All nodes are available at [github.com/hanzoai](https://github.com/hanzoai):

| Node | Purpose | Upstream |
|------|---------|----------|
| **Hanzo-DiffuEraser** | Content-aware inpainting | smthemex/ComfyUI_DiffuEraser |
| **Hanzo-VideoHelper** | Video I/O suite | Kosinkadink/ComfyUI-VideoHelperSuite |
| **Hanzo-EasyUse** | Workflow utilities | yolain/ComfyUI-Easy-Use |
| **Hanzo-KJNodes** | Core utilities | kijai/ComfyUI-KJNodes |
| **Hanzo-LayerStyle** | Layer compositing | chflame163/ComfyUI_LayerStyle |
| **Hanzo-MLX** | Apple Silicon acceleration | thoddnn/ComfyUI-MLX |

## About

Hanzo Painter is part of the [Hanzo AI](https://hanzo.ai) ecosystem, providing AI infrastructure and services for developers.

- **hanzo.ai** - Core AI infrastructure platform
- **hanzo.io** - Business solutions
- **hanzo.network** - Decentralized compute marketplace

---

Made with ❤️ by [Hanzo AI](https://hanzo.ai)
