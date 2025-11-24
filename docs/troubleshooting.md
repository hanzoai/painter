---
layout: default
title: Troubleshooting
---

# Troubleshooting Guide

Common issues and solutions for Hanzo Studio.

## Installation Issues

### Python Not Found

**Error:**
```
python3: command not found
```

**Solution:**

```bash
# macOS
brew install python@3.11

# Ubuntu/Debian
sudo apt-get install python3.11

# Windows (WSL2)
sudo apt-get install python3.11
```

### Git Clone Failed

**Error:**
```
Permission denied (publickey)
```

**Solution:**

```bash
# Use HTTPS instead
git clone https://github.com/hanzoai/painter.git

# Or set up SSH keys
ssh-keygen -t ed25519 -C "your_email@example.com"
# Add to GitHub: Settings → SSH Keys
```

### Pip Install Failed

**Error:**
```
ERROR: Could not install packages due to an OSError
```

**Solution:**

```bash
# Try with --user flag
pip install --user -r requirements.txt

# Or create virtual environment
python3 -m venv venv
source venv/bin/activate  # Linux/macOS
# OR
venv\Scripts\activate  # Windows
pip install -r requirements.txt
```

## Runtime Issues

### CUDA Out of Memory

**Error:**
```
RuntimeError: CUDA out of memory
```

**Solutions:**

**Option 1: Low VRAM Mode**
```bash
make run-lowvram
```

**Option 2: Reduce Parameters**
```json
{
  "video_length": 30,        // Was: 50
  "subvideo_length": 50,     // Was: 80
  "frame_load_cap": 150      // Was: 300
}
```

**Option 3: Process Fewer Frames**
```json
{
  "select_every_nth": 2      // Process every 2nd frame
}
```

**Option 4: Use CPU Mode**
```bash
make run-cpu
```

### Models Not Found

**Error:**
```
FileNotFoundError: models/checkpoints/realisticVisionV51_v51VAE.safetensors
```

**Solution:**

```bash
# Check model paths
make models-info

# Download missing models manually
# Place in correct directories:
# - Hanzo Studio/models/checkpoints/
# - Hanzo Studio/models/diffusers/
# - Hanzo Studio/models/sam2/
```

**Verify paths:**
```bash
ls -lh Hanzo Studio/models/checkpoints/
ls -lh Hanzo Studio/models/diffusers/
ls -lh Hanzo Studio/models/sam2/
```

### Port Already in Use

**Error:**
```
OSError: [Errno 48] Address already in use
```

**Solution:**

```bash
# Find process using port 8188
lsof -i :8188

# Kill the process
kill -9 <PID>

# Or use different port
cd Hanzo Studio && python main.py --port 8189
```

### Module Not Found

**Error:**
```
ModuleNotFoundError: No module named 'torch'
```

**Solution:**

```bash
# Reinstall dependencies
cd Hanzo Studio
pip install -r requirements.txt --force-reinstall

# Verify installation
python -c "import torch; print(torch.__version__)"
```

## Performance Issues

### Slow Processing

**Symptoms:**
- Processing takes hours
- Low GPU utilization
- System feels sluggish

**Solutions:**

**1. Check GPU Usage:**
```bash
# NVIDIA
nvidia-smi

# Apple Silicon
sudo powermetrics --samplers gpu_power
```

**2. Reduce Quality Settings:**
```json
{
  "num_inference_steps": 8,     // Was: 15
  "ref_stride": 15,              // Was: 10
  "neighbor_length": 5           // Was: 10
}
```

**3. Use MLX (Apple Silicon):**
```bash
make install-mlx
make run-mlx
```

**4. Close Other Applications:**
- Close browser tabs
- Stop other GPU-intensive apps
- Free up system memory

### High Memory Usage

**Symptoms:**
- System swap is active
- "Out of memory" warnings
- Crashes during processing

**Solutions:**

**1. Reduce Batch Size:**
```json
{
  "video_length": 20,            // Smaller batches
  "frame_load_cap": 100          // Fewer frames in memory
}
```

**2. Process in Chunks:**
- Split video into smaller segments
- Process each separately
- Combine outputs afterward

**3. Monitor Memory:**
```bash
# General memory
free -h        # Linux
vm_stat        # macOS

# GPU memory
nvidia-smi     # NVIDIA
```

## Quality Issues

### Poor Inpainting Results

**Symptoms:**
- Blurry output
- Visible seams
- Unrealistic content
- Color mismatches

**Solutions:**

**1. Improve Mask Quality:**
- Use SAM2 for precise segmentation
- Ensure complete coverage
- Soften mask edges
- Preview mask before processing

**2. Increase Quality Settings:**
```json
{
  "num_inference_steps": 25,     // More steps
  "guidance_scale": 15,           // Stronger guidance
  "neighbor_length": 20           // More context
}
```

**3. Adjust Guidance:**
- Too low (< 8): Weak removal
- Too high (> 15): Artifacts
- Sweet spot: 10-12

**4. Use Better Models:**
- Verify model versions
- Try different checkpoints
- Ensure models are uncorrupted

### Temporal Flickering

**Symptoms:**
- Video flickers/jitters
- Inconsistent frames
- Color shifts

**Solutions:**

**1. Increase Temporal Context:**
```json
{
  "neighbor_length": 20,         // More temporal info
  "ref_stride": 5                // Tighter references
}
```

**2. Process More Frames:**
```json
{
  "video_length": 80,            // Larger batches
  "subvideo_length": 100         // Longer windows
}
```

**3. Use Consistent Settings:**
- Don't change parameters mid-video
- Process entire video in one session
- Use same seed for reproducibility

### Audio Sync Issues

**Symptoms:**
- Audio out of sync
- Missing audio
- Crackling/pops

**Solutions:**

**1. Preserve Frame Rate:**
```json
{
  "frame_rate": 30               // Match source FPS
}
```

**2. Re-sync Audio:**
```bash
# Use ffmpeg to re-attach audio
ffmpeg -i output.mp4 -i original.mp4 \
  -c:v copy -c:a copy -map 0:v:0 -map 1:a:0 \
  final-output.mp4
```

**3. Check Source:**
- Ensure original has audio
- Verify audio codec compatibility
- Test with different source files

## Workflow Issues

### Workflow Won't Load

**Error:**
```
Error loading workflow
```

**Solutions:**

**1. Verify File Path:**
```bash
# Check workflow exists
ls -l Hanzo Studio/workflows/inpainting-workflow.json
```

**2. Validate JSON:**
```bash
# Check JSON syntax
python -m json.tool inpainting-workflow.json
```

**3. Update Workflow:**
```bash
# Reinstall latest version
make install-workflow
```

### Missing Nodes

**Error:**
```
Unknown node type: DiffuEraser
```

**Solutions:**

**1. Verify Node Installation:**
```bash
ls -l Hanzo Studio/custom_nodes/
```

**2. Reinstall Nodes:**
```bash
make install-nodes
```

**3. Restart Server:**
```bash
make stop
make run
```

### Node Connection Errors

**Error:**
```
Node connection failed
```

**Solutions:**

**1. Check Node Compatibility:**
- Ensure all nodes are installed
- Update to latest versions
- Check for breaking changes

**2. Reload Workflow:**
- Save current state
- Restart Hanzo Studio
- Reload workflow

**3. Clear Cache:**
```bash
make clean
```

## System-Specific Issues

### Windows WSL2

**Issue: Slow Performance**

**Solution:**
```bash
# Store files in WSL2 filesystem, not /mnt/c/
cd ~
git clone https://github.com/hanzoai/painter.git
```

**Issue: CUDA Not Detected**

**Solution:**
```bash
# Install CUDA in WSL2
# Follow: https://docs.nvidia.com/cuda/wsl-user-guide/
```

### macOS

**Issue: MLX Not Working**

**Solution:**
```bash
# Ensure on Apple Silicon
uname -m  # Should show: arm64

# Reinstall MLX
make install-mlx
```

**Issue: Permission Denied**

**Solution:**
```bash
# Fix permissions
chmod +x setup.sh
sudo chown -R $USER:staff ~/work/hanzo/painter
```

### Linux

**Issue: Missing System Dependencies**

**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get install -y \
  python3-dev \
  build-essential \
  git \
  wget \
  libgl1-mesa-glx \
  libglib2.0-0

# Fedora/RHEL
sudo dnf install -y \
  python3-devel \
  gcc \
  git \
  wget \
  mesa-libGL

# Arch
sudo pacman -S \
  python \
  base-devel \
  git \
  wget \
  mesa
```

## Getting Help

### Collect Debug Information

```bash
# System info
make info

# Model status
make models-info

# Test installation
make test

# Check logs
tail -n 100 Hanzo Studio/comfyui.log
```

### Report Issues

Include this information when reporting bugs:

1. **System Info:**
   - OS version
   - Python version
   - GPU model
   - Available VRAM

2. **Error Details:**
   - Full error message
   - Stack trace
   - When error occurs

3. **Steps to Reproduce:**
   - What you did
   - Expected behavior
   - Actual behavior

4. **Configuration:**
   - Workflow parameters
   - Custom modifications
   - Installed models

### Community Support

- **GitHub Issues:** [hanzoai/painter/issues](https://github.com/hanzoai/painter/issues)
- **Discord:** [Hanzo AI Community](https://discord.gg/hanzoai)
- **Docs:** [hanzoai.github.io/painter](https://hanzoai.github.io/painter)

### Commercial Support

For commercial deployments and priority support:

- **Email:** support@hanzo.ai
- **Website:** [hanzo.ai/support](https://hanzo.ai/support)

---

[← Usage Guide](usage) | [Back to Home](index)
