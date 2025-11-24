# Hanzo Studio on RunPod

Deploy Hanzo Studio on RunPod in seconds for GPU-accelerated video inpainting.

## Quick Deploy (1-Click)

### Option 1: Docker Template (Recommended)

1. **Create RunPod Account**: [runpod.io](https://runpod.io)
2. **Select GPU**: RTX 4090, A100, or any GPU with 8GB+ VRAM
3. **Use Docker Image**:
   ```
   docker pull ghcr.io/hanzoai/studio:latest
   ```
4. **Port Mapping**: Expose port `8188`
5. **Start Pod** and access via RunPod URL

### Option 2: GitHub Deploy

1. **SSH into RunPod pod**
2. **Run one command**:
   ```bash
   git clone https://github.com/hanzoai/painter.git /workspace/painter && \
   cd /workspace/painter && \
   bash runpod-start.sh
   ```

That's it! Server starts automatically.

## Manual Setup

If you prefer step-by-step:

```bash
# 1. Clone repo
cd /workspace
git clone https://github.com/hanzoai/painter.git
cd painter

# 2. Make scripts executable
chmod +x runpod-start.sh install-nodes.sh

# 3. Start server
bash runpod-start.sh
```

## What Gets Installed

- ✅ Hanzo Studio (latest from github.com/hanzoai/studio)
- ✅ All custom nodes (DiffuEraser, VideoHelper, etc.)
- ✅ SAM2 models (auto-downloaded)
- ✅ Python dependencies
- ✅ CUDA + PyTorch

## Storage & Models

### Persistent Storage (Recommended)

Mount RunPod network volume to `/workspace` to persist:
- Downloaded models (~2GB)
- Custom nodes
- Input/output files

### Models to Download Manually

Place in `Studio/models/`:

1. **Realistic Vision v5.1** (4.3GB):
   ```
   models/checkpoints/realisticVisionV51_v51VAE.safetensors
   ```
   Download: [Civitai](https://civitai.com/models/4201/realistic-vision-v51)

2. **PCM SD 1.5** (1.7GB):
   ```
   models/diffusers/pcm_sd15_smallcfg_2step_converted.safetensors
   ```
   Download: [HuggingFace](https://huggingface.co/wangfuyun/PCM_Weights)

Or use wget:
```bash
cd /workspace/painter/Studio/models

# Realistic Vision (via HuggingFace mirror)
wget -O checkpoints/realisticVisionV51_v51VAE.safetensors \
  https://huggingface.co/lllyasviel/fav_models/resolve/main/fav/realisticVisionV51_v51VAE.safetensors

# PCM
wget -O diffusers/pcm_sd15_smallcfg_2step_converted.safetensors \
  https://huggingface.co/wangfuyun/PCM_Weights/resolve/main/pcm_sd15_smallcfg_2step_converted.safetensors
```

## GPU Requirements

| GPU | VRAM | Performance | Status |
|-----|------|-------------|--------|
| RTX 4090 | 24GB | Excellent | ✅ Recommended |
| RTX 3090 | 24GB | Excellent | ✅ Recommended |
| A100 | 40GB+ | Overkill but fast | ✅ Great |
| RTX 4080 | 16GB | Good | ✅ Works |
| RTX 3080 | 10GB | Usable | ⚠️ Use --lowvram |

## Running

### Auto-Start (runpod-start.sh)

The script automatically:
- Clones/updates Studio
- Installs dependencies
- Downloads SAM2 models
- Starts server on port 8188

### Manual Start

```bash
cd /workspace/painter/Studio
python3 main.py --listen 0.0.0.0 --port 8188
```

### Low VRAM Mode

If you get OOM errors:
```bash
python3 main.py --listen 0.0.0.0 --port 8188 --lowvram
```

## Accessing the Interface

RunPod auto-exposes port 8188. Access via:
- RunPod proxy URL (shown in pod dashboard)
- Or: `https://<pod-id>-8188.proxy.runpod.net`

## Uploading Files

### Via Web UI:
1. Open Studio interface
2. Drag & drop video files

### Via SSH/rsync:
```bash
# From local machine
rsync -avz video.mp4 root@<pod-ip>:/workspace/painter/Studio/input/

# Or use RunPod web terminal
```

## Example Workflow

1. **Upload video**: Place in `Studio/input/video.mp4`
2. **Open Studio**: Access via RunPod URL
3. **Load workflow**:
   - Click menu → Load
   - Select `workflows/inpainting-workflow.json`
4. **Configure**:
   - Update filename in `VHS_LoadVideo` node
   - Adjust settings (guidance_scale, steps, etc.)
5. **Run**: Click "Queue Prompt"
6. **Download**: Output in `Studio/output/`

## Costs

Approximate RunPod costs:
- **RTX 4090**: ~$0.50/hour
- **RTX 3090**: ~$0.40/hour
- **A100 (40GB)**: ~$1.20/hour

### Tips to Save Money:
- Stop pod when not in use (outputs persist on network volume)
- Use Spot instances (50-70% cheaper)
- Download models once, mount network volume for reuse

## Troubleshooting

### Out of Memory
```bash
# Use low VRAM mode
python3 main.py --listen 0.0.0.0 --port 8188 --lowvram

# Or reduce batch size in workflow
```

### Models Not Found
```bash
# Check model paths
ls -lh /workspace/painter/Studio/models/checkpoints/
ls -lh /workspace/painter/Studio/models/diffusers/

# Re-download if needed
cd /workspace/painter
bash runpod-start.sh
```

### Custom Nodes Failed
```bash
# Reinstall nodes
cd /workspace/painter
bash install-nodes.sh
```

### Server Won't Start
```bash
# Check logs
cd /workspace/painter/Studio
python3 main.py --listen 0.0.0.0 --port 8188 --verbose

# Check port
lsof -i :8188
```

## Docker Deployment

Build and run locally or push to registry:

```bash
# Build
docker build -t hanzo-studio .

# Run locally (with GPU)
docker run --gpus all -p 8188:8188 hanzo-studio

# Push to registry (for RunPod template)
docker tag hanzo-studio ghcr.io/hanzoai/studio:latest
docker push ghcr.io/hanzoai/studio:latest
```

## Support

- **GitHub Issues**: [github.com/hanzoai/painter/issues](https://github.com/hanzoai/painter/issues)
- **RunPod Discord**: RunPod community for pod-specific help
- **Docs**: See main [README.md](README.md)

## Advanced: Auto-Shutdown

Save money by auto-stopping pod after processing:

```bash
# In workflow, add final step:
# After video processing completes
runpodctl stop pod $RUNPOD_POD_ID
```

Or set idle timeout in RunPod dashboard.

---

**Made with ❤️ by [Hanzo AI](https://hanzo.ai)**
