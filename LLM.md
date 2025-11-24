# Hanzo Studio / Studio - Architecture & Evolution

**Last Updated**: 2025-11-22  
**Status**: Phase 1 Complete (Painter), Phase 2 Planning (Studio Evolution)

## Executive Summary

Hanzo Studio is an AI-powered video inpainting platform built on Hanzo Studio. It enables content-aware removal and reconstruction of video/image elements (watermarks, objects, blemishes) using advanced diffusion models.

**Evolution Plan**: Transforming from specialized inpainting tool → comprehensive AI creative studio ("Hanzo Studio")

---

## Current Architecture (Hanzo Studio v1.0)

### Core Technology Stack

**Foundation**: Hanzo Studio (node-based visual AI workflow platform)
- Python 3.8+
- PyTorch + CUDA/MLX acceleration
- Node-based visual workflow system
- Custom nodes via Python plugins

**AI Models**:
- **DiffuEraser**: Content-aware inpainting engine
- **SAM2** (Segment Anything Model 2): Advanced object segmentation
- **Realistic Vision v5.1**: Base diffusion model (SD 1.5)
- **PCM (Phased Consistency Model)**: Fast 2-step inference

**Acceleration**:
- CUDA: Standard GPU acceleration
- MLX: Apple Silicon native (70% faster model loading, 35% faster inference)

### Custom Node Ecosystem

All nodes maintained as Hanzo forks for stability + upstream sync:

| Node | Purpose | Upstream Source |
|------|---------|-----------------|
| **Hanzo-DiffuEraser** | Core inpainting engine | smthemex/Hanzo Studio_DiffuEraser |
| **Hanzo-VideoHelper** | Video I/O, frame extraction, encoding | Kosinkadink/ComfyUI-VideoHelperSuite |
| **Hanzo-EasyUse** | Simplified workflow utilities | yolain/ComfyUI-Easy-Use |
| **Hanzo-KJNodes** | Core utilities, JWInteger support | kijai/ComfyUI-KJNodes |
| **Hanzo-LayerStyle** | Photoshop-like compositing | chflame163/Hanzo Studio_LayerStyle |
| **Hanzo-MLX** | Apple Silicon acceleration | thoddnn/ComfyUI-MLX |

**Fork Philosophy**:
- Maintain compatibility with upstream
- Add Hanzo-specific enhancements
- Regular upstream sync for bug fixes
- Unified support across ecosystem

### Installation Structure

```
studio-old/                     # Painter project
├── Studio → ~/work/hanzo/Studio  # Symlink to main Studio repo
├── Makefile                    # Automation commands
├── requirements.txt            # Python dependencies
├── docker-compose.yml          # Docker deployment
└── docs/                       # GitHub Pages documentation

~/work/hanzo/Studio/            # Main Studio repository (v0.3.71)
├── studio/                     # Core Python package
│   ├── studio_types/           # Type definitions (renamed from comfy_types)
│   │   ├── __init__.py        # UnetWrapperFunction, StudioNodeABC, etc.
│   │   ├── node_typing.py     # IO, InputTypeDict, FileLocator
│   │   └── examples/
│   ├── model_patcher.py
│   ├── sd.py
│   └── ...
├── custom_nodes/               # Hanzo custom nodes
│   ├── Hanzo-DiffuEraser/
│   ├── Hanzo-VideoHelper/
│   ├── Hanzo-EasyUse/
│   ├── Hanzo-KJNodes/
│   ├── Hanzo-LayerStyle/
│   └── Hanzo-MLX/              # Optional: Apple Silicon
├── models/
│   ├── checkpoints/            # Base models (SD, SDXL)
│   ├── diffusers/              # PCM, specialized models
│   └── sam2/                   # SAM2 segmentation models
├── input/                      # Source videos/images
├── output/                     # Processed results
├── workflows/                  # Workflow JSON files
└── main.py                     # Server entry point
```

**Integration Details**:
- Painter builds on the main Studio repository via symlink
- Studio package installed in editable mode: `pip install -e ~/work/hanzo/Studio`
- Type system unified under `studio.studio_types` namespace
- Shared custom nodes, models, and workflows across projects

### Current Workflow (Inpainting Pipeline)

**Workflow File**: `inpainting-workflow.json`

```
Input Video → Frame Extraction → DiffuEraser → Temporal Smoothing → Re-encode → Output
                     ↓                ↓
                  SAM2 Mask    Context Analysis
```

**Key Parameters**:
- `num_inference_steps`: 15 (denoising quality vs speed)
- `guidance_scale`: 10 (removal strength)
- `video_length`: 50 frames (processing chunk size)
- `frame_rate`: 8 FPS (output framerate)

**Performance Tuning**:
- Low VRAM: Reduce `video_length` to 25-30
- High quality: Increase `guidance_scale` to 12-15
- Speed: Reduce `num_inference_steps` to 8-10

### Supported Use Cases (Current)

1. **Watermark Removal**: Stock footage logos, text overlays
2. **Object Removal**: People, vehicles, props, equipment
3. **Video Restoration**: Scratches, artifacts, blemishes
4. **Background Cleanup**: Wires, poles, unwanted elements

---

## Evolution to Hanzo Studio

### Vision

Transform Hanzo Studio into a comprehensive AI creative suite leveraging Hanzo Studio's full capabilities:

**From**: Specialized video inpainting tool  
**To**: Unified AI creative studio for generation, editing, video, 3D

### Expanded Capabilities Matrix

| Category | Current (Painter) | Studio (Planned) |
|----------|-------------------|------------------|
| **Image Generation** | ❌ | ✅ SD, SDXL, FLUX, custom LoRAs |
| **Image Editing** | ✅ Inpainting only | ✅ Inpaint, outpaint, style transfer, face restoration |
| **Video** | ✅ Inpainting | ✅ Generation (AnimateDiff), interpolation, upscaling |
| **3D** | ❌ | ✅ TripoSR, depth maps, normal maps |
| **Audio** | ✅ Passthrough | ✅ Audio-reactive visuals, music generation |
| **Batch Processing** | ❌ | ✅ Queue system, batch workflows |
| **API Access** | ❌ | ✅ REST API, programmatic workflows |

### Proposed Workflow Library Structure

```
workflows/
├── inpainting/              # Current Painter workflows
│   ├── video-inpainting.json
│   ├── image-inpainting.json
│   └── sam2-precision.json
│
├── generation/              # NEW: Text/image to image
│   ├── txt2img-sd15.json
│   ├── txt2img-sdxl.json
│   ├── txt2img-flux.json
│   ├── img2img-standard.json
│   └── controlnet-guided.json
│
├── video/                   # NEW: Video creation
│   ├── animatediff-txt2vid.json
│   ├── frame-interpolation.json
│   ├── video-upscaling.json
│   └── motion-transfer.json
│
├── editing/                 # NEW: Advanced editing
│   ├── outpainting.json
│   ├── style-transfer.json
│   ├── face-restoration.json
│   ├── color-grading.json
│   └── background-replace.json
│
├── 3d/                      # NEW: 3D workflows
│   ├── triposr-3d-gen.json
│   ├── depth-estimation.json
│   └── normal-map-gen.json
│
└── advanced/                # NEW: Pro features
    ├── batch-processing.json
    ├── api-workflow.json
    └── custom-pipeline.json
```

### Required New Custom Nodes

Additional Hanzo-maintained nodes for Studio features:

1. **Hanzo-AnimateDiff**: Video generation from text/images
2. **Hanzo-ControlNet**: Guided image generation (pose, depth, canny)
3. **Hanzo-TripoSR**: 3D model generation
4. **Hanzo-Upscaler**: ESRGAN, RealESRGAN, etc.
5. **Hanzo-LoRA**: LoRA management and loading
6. **Hanzo-API**: REST API server for programmatic access

### Desktop App Packaging Strategy

**Goal**: Standalone desktop application with auto-updates

**Technology Options**:

1. **Electron Wrapper** (Recommended)
   - Wrap Hanzo Studio web UI in Electron
   - Native installers (.dmg, .exe, .deb)
   - Auto-update via electron-updater
   - Pros: Cross-platform, web UI reuse
   - Cons: Larger download size

2. **Tauri** (Alternative)
   - Rust-based, smaller binary
   - Native webview (no Chromium)
   - Pros: Smaller size, faster
   - Cons: More complex setup

**Packaging Structure**:
```
hanzo-studio/
├── app/                    # Electron/Tauri app
│   ├── main/              # Main process
│   ├── renderer/          # UI (Hanzo Studio)
│   └── resources/         # Bundled Python/models
├── backend/               # Hanzo Studio server
│   ├── comfyui/
│   ├── custom_nodes/
│   └── models/
└── installers/            # Platform-specific installers
    ├── macos/            # .dmg
    ├── windows/          # .exe
    └── linux/            # .deb, .AppImage
```

**Auto-Update Strategy**:
- GitHub Releases for distribution
- Electron-updater for background updates
- Model updates via separate download manager
- Version compatibility checks

**Model Management**:
- Built-in model downloader
- Model library browser
- HuggingFace integration
- CivitAI integration (optional)

### Branding & UI Updates

**Repository Rename**:
- `painter` → `studio`
- GitHub: `hanzoai/painter` → `hanzoai/studio`
- NPM package: `@hanzo/studio`

**Visual Branding**:
- Custom Hanzo Studio theme (Hanzo colors)
- Splash screen with Hanzo logo
- Custom menu/toolbar
- Workflow templates library
- Tutorial/onboarding system

**Node Categories** (Custom organization):
```
Hanzo Studio/
├── Generation/
│   ├── Text to Image
│   ├── Image to Image
│   └── LoRA Tools
├── Editing/
│   ├── Inpainting
│   ├── Outpainting
│   └── Style Transfer
├── Video/
│   ├── Generation
│   ├── Processing
│   └── Effects
├── 3D/
└── Utilities/
```

---

## Migration Strategy (Painter → Studio)

### Phase 1: Foundation (COMPLETE ✅)
- ✅ Hanzo Studio installation
- ✅ Hanzo custom nodes
- ✅ SAM2 models
- ✅ Inpainting workflow
- ✅ Documentation (README, GitHub Pages)
- ✅ CI/CD pipeline

### Phase 2: Core Expansion (NEXT)
- ⏳ Add generation workflows (SD, SDXL, FLUX)
- ⏳ Download additional models (SDXL, ControlNet)
- ⏳ Create Hanzo-ControlNet node
- ⏳ Add img2img workflows
- ⏳ Test multi-workflow support

### Phase 3: Video & 3D
- ⏳ Integrate AnimateDiff
- ⏳ Add video generation workflows
- ⏳ Integrate TripoSR for 3D
- ⏳ Add frame interpolation
- ⏳ Video upscaling workflows

### Phase 4: Pro Features
- ⏳ REST API development
- ⏳ Batch processing system
- ⏳ Custom workflow builder UI
- ⏳ Advanced parameter controls

### Phase 5: Desktop Packaging
- ⏳ Electron app structure
- ⏳ Model downloader/manager
- ⏳ Auto-update system
- ⏳ Platform-specific installers

### Phase 6: Polish & Release
- ⏳ UI/UX refinement
- ⏳ Tutorial system
- ⏳ Workflow marketplace
- ⏳ Community features
- ⏳ Official release as "Hanzo Studio 1.0"

---

## Technical Decisions & Rationale

### Why Hanzo Studio?

**Pros**:
- Node-based visual programming (accessible to non-coders)
- Extremely flexible workflow system
- Active community + ecosystem
- Supports virtually all AI models/techniques
- Python-based (easy customization)
- Open source

**Cons**:
- Steeper learning curve than single-purpose tools
- UI can feel technical to beginners
- Some workflows are complex

**Decision**: Benefits outweigh complexity. We'll add:
- Pre-built workflow templates
- Simplified "studio mode" UI
- Tutorial system
- Community workflows

### Why Fork Custom Nodes?

**Rationale**:
1. **Stability**: Test before pulling upstream changes
2. **Hanzo Enhancements**: Add custom features
3. **Support**: Single source of truth for users
4. **Branding**: Consistent Hanzo ecosystem
5. **Quality Control**: Ensure compatibility

**Process**:
- Fork → Enhance → Sync upstream regularly
- Contribute improvements back upstream
- Document Hanzo-specific changes

### Why Desktop App?

**User Benefits**:
1. **Simplified Setup**: No Python/dependency hell
2. **Auto-Updates**: Always latest features
3. **Integrated Models**: Pre-bundled common models
4. **Native Experience**: OS integration, notifications
5. **Offline Capable**: Local processing

**Market Positioning**:
- Compete with: Topaz Video AI, DaVinci Resolve AI
- Differentiate: More flexible, node-based, extensible
- Target: Creators, editors, studios, researchers

---

## Performance Optimization

### Apple Silicon (MLX)

**Current Performance** (M1/M2/M3/M4):
- 70% faster model loading
- 35% faster inference
- 30% lower memory usage

**Limitations**:
- Currently optimized for Flux models
- SD 1.5 support in progress
- Not all nodes support MLX

**Future Optimization**:
- Full SD 1.5 MLX support
- SDXL MLX implementation
- Custom MLX kernels for common operations

### CUDA Optimization

**Current**: Standard PyTorch CUDA
**Planned**:
- xFormers for attention optimization
- Flash Attention 2 integration
- TensorRT acceleration
- Mixed precision (FP16/FP32)

### Model Optimization

**Quantization**:
- INT8 quantization for models
- GGUF format support (smaller, faster)
- Dynamic loading (load models on demand)

**Caching**:
- Model cache management
- VAE caching
- Prompt embedding caching

---

## Model Requirements

### Current Models (Painter)

**Required**:
- `realisticVisionV51_v51VAE.safetensors` (4.3GB) - Base SD 1.5
- `pcm_sd15_smallcfg_2step_converted.safetensors` (1.7GB) - Fast inference
- SAM2 Large (856MB) - Advanced segmentation ✅
- SAM2 Base Plus (344MB) - Faster segmentation ✅

### Planned Models (Studio)

**Image Generation**:
- SDXL Base (6.9GB)
- SDXL Refiner (6.1GB)
- FLUX.1-dev (23.8GB)
- FLUX.1-schnell (23.8GB)

**ControlNet** (various sizes):
- Canny, Depth, OpenPose, Scribble, etc.
- ~1.5GB each

**LoRA Library** (community):
- User-downloadable
- HuggingFace/CivitAI integration
- 10MB - 500MB each

**Video**:
- AnimateDiff motion modules (~1.8GB)
- Frame interpolation models (~500MB)

**3D**:
- TripoSR (~500MB)
- Depth estimation models (~400MB)

**Total Storage Estimate**:
- Minimal (Painter only): ~7GB
- Full Studio (all models): ~80-100GB
- Recommended: 150GB free space

---

## API Architecture (Planned)

### REST API Design

**Endpoints**:
```
POST /api/v1/generate        # Run workflow
GET  /api/v1/workflows       # List workflows
POST /api/v1/workflows       # Upload workflow
GET  /api/v1/models          # List models
GET  /api/v1/status          # Server status
WS   /api/v1/stream          # Progress updates
```

**Authentication**:
- API key-based
- Rate limiting
- Usage quotas (optional)

**Example Usage**:
```python
import requests

response = requests.post('http://localhost:8188/api/v1/generate', json={
    'workflow': 'inpainting',
    'inputs': {
        'video': 'path/to/video.mp4',
        'mask': 'path/to/mask.png'
    },
    'parameters': {
        'guidance_scale': 10,
        'steps': 15
    }
})

result = response.json()
```

### SDK Libraries

**Official SDKs**:
- Python SDK (@hanzo/studio-py)
- JavaScript/TypeScript SDK (@hanzo/studio-js)
- Go SDK (github.com/hanzoai/studio-go)

**Integration Examples**:
- Video editing pipelines
- Batch processing scripts
- Web service integration
- Cloud deployment

---

## Deployment Options

### Local Development
```bash
make run              # Standard mode
make run-mlx          # Apple Silicon
make run-lowvram      # Low VRAM
```

### Docker Deployment
```bash
docker compose up -d  # Production mode
docker compose -f docker-compose.dev.yml up  # Development
```

### Cloud Deployment (Planned)

**Platforms**:
- AWS EC2 (GPU instances)
- Google Cloud (GPU VMs)
- RunPod, Vast.ai (GPU rental)
- Kubernetes (scaling)

**Auto-scaling**:
- Queue-based worker pools
- Dynamic GPU allocation
- Cost optimization

---

## Community & Ecosystem

### Workflow Marketplace (Planned)

**Features**:
- Community-submitted workflows
- Rating/review system
- Categories & search
- One-click install
- Versioning & updates

### Plugin System (Planned)

**Extensions**:
- Custom nodes (Python)
- UI extensions (JavaScript)
- Model packs (bundled models)
- Theme marketplace

### Documentation

**Current**:
- GitHub Pages (docs/)
- README.md
- QUICKSTART.md
- In-code comments

**Planned**:
- Interactive tutorials
- Video walkthroughs
- Community wiki
- API reference docs
- Best practices guide

---

## Security Considerations

**Code Execution**:
- Custom nodes run Python (potential risk)
- Sandboxing for community nodes
- Code review process
- Signature verification

**Model Safety**:
- Verify model checksums
- Scan for malicious code
- Official model repository
- User warnings for community models

**Privacy**:
- Local-first processing
- Optional cloud sync
- No telemetry by default
- Encrypted credentials

---

## Success Metrics

### Phase 1 (Painter) - ACHIEVED ✅
- ✅ Local installation working
- ✅ Single workflow (inpainting) functional
- ✅ Documentation complete
- ✅ CI/CD pipeline

### Phase 2 (Studio) - Goals
- [ ] 10+ workflow templates
- [ ] 3+ model types supported
- [ ] Desktop app alpha release
- [ ] 100+ community users

### Phase 3 (Mature Studio) - Goals
- [ ] 50+ workflow templates
- [ ] Plugin marketplace
- [ ] 1000+ community users
- [ ] Commercial partnerships

---

## Risks & Mitigation

### Risk: Model Size Bloat
**Impact**: Users need 100GB+ storage  
**Mitigation**: 
- Streaming download
- Optional model packs
- Cloud storage integration
- Model quantization

### Risk: Complexity Overwhelming Users
**Impact**: High learning curve  
**Mitigation**:
- Pre-built templates
- "Easy mode" UI
- Interactive tutorials
- Video walkthroughs

### Risk: Breaking Changes in Hanzo Studio
**Impact**: Workflows break on updates  
**Mitigation**:
- Pin Hanzo Studio version
- Compatibility testing
- Migration guides
- Version compatibility matrix

### Risk: Community Node Quality
**Impact**: Unstable/unsafe nodes  
**Mitigation**:
- Official Hanzo forks
- Code review process
- Testing requirements
- Warning system

---

## Contributing

### For Hanzo Team

**Custom Nodes**:
1. Fork upstream repo → `Hanzo-{NodeName}`
2. Add Hanzo enhancements
3. Regular upstream sync (weekly)
4. Document changes in LLM.md
5. Update tests

**Workflows**:
1. Create in Hanzo Studio UI
2. Export JSON
3. Test thoroughly
4. Add to `workflows/` with docs
5. PR to main repo

**Documentation**:
1. Update LLM.md for architectural changes
2. Update README for user-facing changes
3. Add examples for new features
4. Keep QUICKSTART simple

### For Community (Future)

**Workflow Submissions**:
- GitHub issues with workflow JSON
- Description + use case
- Example images/videos
- Performance notes

**Bug Reports**:
- Version info (Hanzo Studio, Python, OS)
- Steps to reproduce
- Expected vs actual behavior
- Logs/screenshots

---

## Appendix: Command Reference

### Makefile Commands

```bash
# Setup
make setup              # Install Hanzo Studio + nodes
make download-models    # Download SAM2 models
make install-workflow   # Copy workflow files
make all                # Complete setup

# Running
make run                # Start server (0.0.0.0:8188)
make run-mlx            # Apple Silicon acceleration
make run-lowvram        # Low VRAM mode
make run-cpu            # CPU-only (slow)

# Maintenance
make update             # Update Hanzo Studio + nodes
make clean              # Clear Python caches
make clean-output       # Clear output files
make uninstall          # Remove Hanzo Studio

# Testing
make test               # Run test suite
make test-unit          # Unit tests only
make test-integration   # Integration tests
make test-comfyui       # Test Hanzo Studio installation

# Info
make help               # Show all commands
make info               # Installation info
make models-info        # Downloaded models
```

### Docker Commands

```bash
# Start
docker compose up -d                    # Production
docker compose -f compose.dev.yml up    # Development

# Logs
docker compose logs -f                  # All services
docker compose logs -f comfyui          # Hanzo Studio only

# Stop
docker compose down                     # Stop services
docker compose down -v                  # Stop + remove volumes

# Rebuild
docker compose build --no-cache         # Full rebuild
docker compose up -d --build            # Rebuild + start
```

### Python Environment

```bash
# If using venv manually (not recommended - use Makefile)
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# With uv (faster, recommended for new projects)
uv venv
uv pip install -r requirements.txt
```

---

## Changelog

### 2025-11-23 - Studio Integration
- ✅ Linked painter to main Hanzo Studio repository
  - Created symlink: `studio-old/Studio → ~/work/hanzo/Studio`
  - Main repo: `git@github.com:hanzoai/studio.git` (hanzo-studio v0.3.71)
- ✅ Renamed `studio/comfy_types` → `studio/studio_types`
  - Flattened nested directory structure
  - Updated all imports to use `studio.studio_types`
  - Verified no remaining `comfy_types` references
- ✅ Completed rebranding to "Hanzo Studio"
  - Updated Makefile, README, documentation
  - Custom Hanzo logo (SVG)
  - Browser title shows "Hanzo Studio"
  - Settings file: `studio.settings.json`
- ✅ Integration tested successfully
  - Server starts without import errors
  - API responding correctly
  - All type definitions working

### 2025-11-22 - Initial Setup
- Hanzo Studio installed successfully
- All Hanzo custom nodes cloned and configured
- SAM2 models downloaded (Large + Base Plus)
- Workflow template installed
- Created comprehensive LLM.md documentation
- Status: Ready for model downloads (realisticVision, PCM)

---

## Next Steps

### Immediate (Phase 1 Complete)
1. Download realisticVisionV51_v51VAE.safetensors manually
2. Download pcm_sd15_smallcfg_2step_converted.safetensors manually
3. Test inpainting workflow with sample video
4. Verify Apple Silicon MLX acceleration

### Short-term (Phase 2)
1. Design Studio workflow library structure
2. Add txt2img workflows (SD, SDXL)
3. Download generation models
4. Create Hanzo-ControlNet node
5. Test multi-workflow capabilities

### Medium-term (Phase 3-4)
1. Add video generation workflows
2. Integrate 3D capabilities
3. Build REST API
4. Create batch processing system

### Long-term (Phase 5-6)
1. Desktop app (Electron)
2. Model manager
3. Plugin marketplace
4. Community features

---

**End of LLM.md**
