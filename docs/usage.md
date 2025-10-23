---
layout: default
title: Usage
---

# Usage Guide

Learn how to use Hanzo Painter for content-aware inpainting.

## Starting the Server

```bash
# Standard GPU mode
make run

# Apple Silicon with MLX
make run-mlx

# Low VRAM mode
make run-lowvram

# CPU-only mode (slower)
make run-cpu
```

Access the UI at [http://localhost:8188](http://localhost:8188)

## Basic Workflow

### 1. Prepare Your Input

**For Videos:**
- Place video file in `ComfyUI/input/`
- Supported formats: MP4, AVI, MOV, MKV

**For Images:**
- Place image in `ComfyUI/input/`
- Supported formats: PNG, JPG, JPEG, WebP

### 2. Load Workflow

1. Open [http://localhost:8188](http://localhost:8188)
2. Click "Load" button
3. Select `workflows/inpainting-workflow.json`

### 3. Configure Input

Update the **VHS_LoadVideo** node:

```json
{
  "video": "your-video.mp4",
  "frame_load_cap": 300,
  "skip_first_frames": 0,
  "select_every_nth": 1
}
```

### 4. Create/Load Mask

**Option A: Use SAM2 (Recommended)**

1. Add **SAM2** node to workflow
2. Click on object in preview
3. SAM2 generates precise mask automatically

**Option B: Manual Mask**

1. Create mask in image editor (white = remove, black = keep)
2. Save as PNG
3. Load in **LoadImage** node

**Option C: Use Provided Masks**

```bash
# Horizontal mask (top/bottom removal)
horizontal-mask.png

# Vertical mask (sides removal)
vertical-mask.png
```

### 5. Adjust Parameters

#### Core Settings

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| num_inference_steps | 15 | 5-50 | Quality vs speed trade-off |
| guidance_scale | 10 | 1-20 | Removal strength |
| seed | -1 | -1 to ∞ | Randomness (-1 = random) |

#### Video Processing

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| video_length | 50 | 10-200 | Frames per batch |
| subvideo_length | 80 | 20-300 | Processing window |
| neighbor_length | 10 | 5-30 | Temporal context |
| ref_stride | 10 | 1-20 | Reference frame spacing |

#### Performance

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| frame_load_cap | 300 | 10-1000 | Max frames to load |
| frame_rate | 8 | 1-60 | Output FPS |

### 6. Run Processing

1. Click **"Queue Prompt"**
2. Monitor progress in UI
3. Check console for detailed logs

### 7. Retrieve Output

Output files appear in `ComfyUI/output/`

Format: `output_YYYYMMDD_HHMMSS.mp4`

## Advanced Usage

### Multi-Object Removal

1. Create composite mask with multiple white regions
2. Or run workflow multiple times with different masks
3. Each pass refines the inpainting

### Watermark Removal

**Best Settings:**
```json
{
  "num_inference_steps": 20,
  "guidance_scale": 12,
  "neighbor_length": 15,
  "ref_stride": 5
}
```

1. Create precise mask around watermark
2. Ensure mask covers entire watermark
3. Use higher guidance_scale for stubborn watermarks

### Object Removal

**Best Settings:**
```json
{
  "num_inference_steps": 25,
  "guidance_scale": 15,
  "neighbor_length": 20
}
```

1. Use SAM2 for precise object segmentation
2. Increase neighbor_length for better context
3. Higher inference steps for complex scenes

### Background Cleanup

**Best Settings:**
```json
{
  "num_inference_steps": 15,
  "guidance_scale": 8,
  "ref_stride": 10
}
```

1. Create mask for unwanted background elements
2. Lower guidance_scale for subtle blending
3. Use reference stride for consistency

## Performance Tuning

### Out of Memory

**GPU Memory Issues:**

```bash
# Use low VRAM mode
make run-lowvram
```

**Reduce these parameters:**
- `video_length`: 50 → 30
- `subvideo_length`: 80 → 50
- `frame_load_cap`: 300 → 150

### Slow Processing

**Speed up with:**
- Increase `ref_stride`: 10 → 15
- Reduce `neighbor_length`: 10 → 5
- Lower `num_inference_steps`: 15 → 10
- Process fewer frames per batch

### Poor Quality

**Improve quality with:**
- Increase `guidance_scale`: 10 → 15
- More `num_inference_steps`: 15 → 25
- Better mask precision (use SAM2)
- Lower `ref_stride`: 10 → 5

## Quality Settings Presets

### Fast (Low Quality)

```json
{
  "num_inference_steps": 8,
  "guidance_scale": 8,
  "video_length": 30,
  "ref_stride": 15
}
```

Processing time: ~1min per 100 frames

### Balanced (Recommended)

```json
{
  "num_inference_steps": 15,
  "guidance_scale": 10,
  "video_length": 50,
  "ref_stride": 10
}
```

Processing time: ~2min per 100 frames

### High Quality

```json
{
  "num_inference_steps": 25,
  "guidance_scale": 15,
  "video_length": 50,
  "ref_stride": 5
}
```

Processing time: ~4min per 100 frames

### Ultra (Maximum Quality)

```json
{
  "num_inference_steps": 50,
  "guidance_scale": 20,
  "video_length": 80,
  "ref_stride": 3,
  "neighbor_length": 20
}
```

Processing time: ~8min per 100 frames

## Tips & Best Practices

### Masking

✅ **Do:**
- Create precise masks (SAM2 recommended)
- Use soft edges for natural blending
- Cover entire unwanted area
- Test on single frame first

❌ **Don't:**
- Use jagged, pixelated masks
- Leave gaps in mask coverage
- Use overly large masks
- Skip mask preview

### Processing

✅ **Do:**
- Process in batches for long videos
- Monitor GPU memory usage
- Save intermediate results
- Use consistent settings across batches

❌ **Don't:**
- Process entire 1hr video at once
- Ignore memory warnings
- Change settings mid-processing
- Mix different quality presets

### Iteration

✅ **Do:**
- Start with fast settings for testing
- Refine with higher quality settings
- Save successful parameter combinations
- Document what works for your use case

❌ **Don't:**
- Jump to ultra quality immediately
- Discard parameter experiments
- Process without testing first
- Ignore quality issues

## Command Reference

```bash
# Server control
make run                # Start server
make stop               # Stop server

# Cleaning
make clean              # Remove caches
make clean-output       # Remove output files

# Information
make info               # Installation info
make models-info        # Model status
make test               # Test installation

# Updates
make update             # Update all components
```

## Keyboard Shortcuts (ComfyUI)

| Shortcut | Action |
|----------|--------|
| `Ctrl+Enter` | Queue Prompt |
| `Ctrl+Shift+Enter` | Queue Prompt (front) |
| `Ctrl+S` | Save Workflow |
| `Ctrl+O` | Load Workflow |
| `Ctrl+A` | Select All Nodes |
| `Delete` | Delete Selected |
| `Ctrl+C` / `Ctrl+V` | Copy / Paste |
| `Ctrl+Z` / `Ctrl+Y` | Undo / Redo |

---

[← Installation](installation) | [Troubleshooting →](troubleshooting)
