# Hanzo Studio - Quick Start Guide

Get Hanzo Studio (AI-powered video inpainting) running in 5 minutes.

**What it does**: Intelligently removes and reconstructs content in videos - watermarks, objects, blemishes, or any unwanted elements.

## 1. One-Command Setup

```bash
# Complete setup (recommended)
make all

# Or use the automated script
./setup.sh
```

This will:
- ✓ Install Hanzo Studio
- ✓ Install all Hanzo custom nodes (Hanzo-DiffuEraser, Hanzo-VideoHelper, etc.)
- ✓ Download SAM2 models
- ✓ Copy workflow to Hanzo Studio

## 2. Download Required Models

You need to manually download these two models:

### Model 1: Base Model
- **Name**: `realisticVisionV51_v51VAE.safetensors`
- **Source**: [HuggingFace](https://huggingface.co/SG161222/Realistic_Vision_V5.1_noVAE)
- **Destination**: `Hanzo Studio/models/checkpoints/`

### Model 2: DiffuEraser Model
- **Name**: `pcm_sd15_smallcfg_2step_converted.safetensors`
- **Source**: [HuggingFace](https://huggingface.co/wangfuyun/PCM)
- **Destination**: `Hanzo Studio/models/diffusers/`

```bash
# After downloading, place them:
mv ~/Downloads/realisticVisionV51_v51VAE.safetensors Hanzo Studio/models/checkpoints/
mv ~/Downloads/pcm_sd15_smallcfg_2step_converted.safetensors Hanzo Studio/models/diffusers/
```

## 3. Start Hanzo Studio

```bash
make run
```

Access at: **http://localhost:8188**

## 4. Process Your First Video

1. **Place video in input folder**:
   ```bash
   cp your_video.mp4 Hanzo Studio/input/
   ```

2. **Open Hanzo Studio**: http://localhost:8188

3. **Load workflow**:
   - Click "Load" button
   - Select `inpainting-workflow.json` from `workflows/` folder

4. **Configure video**:
   - Find the `VHS_LoadVideo` node
   - Update filename to `your_video.mp4`

5. **Run**:
   - Click "Queue Prompt"
   - Wait for processing
   - Output appears in `Hanzo Studio/output/`

## Common Commands

```bash
# Start server
make run                # Normal mode
make run-mlx            # MLX acceleration (Apple Silicon M1/M2/M3/M4)
make run-lowvram        # Low VRAM mode (if out of memory)
make run-cpu            # CPU-only (slow, no GPU needed)

# Maintenance
make update             # Update Hanzo Studio and nodes
make clean              # Clear caches
make info               # Show installation info
make models-info        # Show downloaded models
make stop               # Stop server

# Help
make help               # Show all commands
```

## Docker (Alternative)

If you prefer Docker:

```bash
# Start with Docker Compose
docker compose up -d

# View logs
docker compose logs -f

# Stop
docker compose down
```

## Apple Silicon Acceleration (MLX)

For Apple Silicon Macs (M1/M2/M3/M4), enable native MLX acceleration:

```bash
# Install MLX support
make install-mlx

# Run with MLX acceleration
make run-mlx
```

**Performance Benefits:**
- 🚀 70% faster model loading
- ⚡ 35% faster inference
- 💾 30% lower memory usage

**Note:** MLX is currently optimized for Flux models. Full SD 1.5 support coming soon.

## Troubleshooting

### Out of Memory?
```bash
make run-lowvram
```
Or reduce video length in the workflow settings.

### Models Not Found?
```bash
make models-info        # Check what's downloaded
ls -lh Hanzo Studio/models/checkpoints/
ls -lh Hanzo Studio/models/diffusers/
```

### Server Won't Start?
```bash
make test              # Test Python/CUDA
make stop              # Kill any running instances
make run               # Try again
```

## Performance Tips

- **Fast**: Use `sam2_hiera_base_plus.pt` model
- **Accurate**: Use `sam2_hiera_large.pt` model
- **Low VRAM**: Reduce `video_length` to 25-30 frames
- **High Quality**: Increase `guidance_scale` to 12-15

## What Can You Remove?

- **Watermarks** - Stock footage logos, text overlays
- **Objects** - People, cars, signs, props
- **Blemishes** - Scratches, artifacts, imperfections
- **Background Elements** - Wires, equipment, unwanted items
- **Anything** - If you can mask it, the AI can inpaint it

## Next Steps

1. Read the full [README.md](README.md) for advanced configuration
2. Experiment with different parameters
3. Try the SAM2 integration for precise object segmentation
4. Explore use cases: watermark removal, object removal, video restoration

## Need Help?

- Check `make help` for all commands
- Review the full README for detailed docs
- Check Hanzo Studio logs for errors

---

**You're ready to paint! 🎨**
