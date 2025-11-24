#!/bin/bash
# Hanzo Studio - RunPod Quick Start

set -e

echo "🎨 Starting Hanzo Studio..."

# Detect workspace directory
if [ -n "$RUNPOD_POD_ID" ]; then
    # Running on RunPod
    WORKSPACE=/workspace
    echo "✓ RunPod environment detected"
    echo "  Pod ID: $RUNPOD_POD_ID"
elif [ -d "/workspace" ]; then
    # /workspace exists (cloud environment)
    WORKSPACE=/workspace
    echo "✓ Cloud environment detected"
else
    # Local development - use current directory
    WORKSPACE="$(pwd)"
    echo "✓ Local environment detected"
fi

echo "  Workspace: $WORKSPACE"
cd "$WORKSPACE"

# Clone/update Studio if needed
if [ ! -d "Studio" ]; then
    echo "📦 Cloning Hanzo Studio..."
    git clone https://github.com/hanzoai/studio.git Studio
    cd Studio

    # Install requirements
    if command -v pip3 &> /dev/null; then
        pip3 install -r requirements.txt || echo "⚠ Some requirements may have failed"
        pip3 install -e . || echo "⚠ Could not install Studio in editable mode"
    else
        echo "⚠ pip3 not found, skipping requirements install"
    fi
else
    echo "✓ Studio directory exists"
    cd Studio

    # Try to update
    if command -v git &> /dev/null; then
        git pull origin master 2>/dev/null || echo "⚠ Could not update Studio (continuing with existing version)"
    fi
fi

# Install custom nodes if not present
if [ ! -d "custom_nodes/Hanzo-DiffuEraser" ]; then
    echo "📦 Installing custom nodes..."

    # Check if install-nodes.sh exists
    if [ -f "$WORKSPACE/install-nodes.sh" ]; then
        bash "$WORKSPACE/install-nodes.sh"
    elif [ -f "../install-nodes.sh" ]; then
        bash ../install-nodes.sh
    else
        echo "⚠ install-nodes.sh not found, skipping custom nodes installation"
        echo "  Clone nodes manually to custom_nodes/ directory"
    fi
else
    echo "✓ Custom nodes already installed"
fi

# Download models if needed
echo "📥 Checking models..."

# SAM2 models
if command -v wget &> /dev/null; then
    if [ ! -f "models/sam2/sam2_hiera_large.safetensors" ]; then
        echo "  Downloading SAM2 Large..."
        mkdir -p models/sam2
        wget -q --show-progress -O models/sam2/sam2_hiera_large.safetensors \
            https://huggingface.co/Kijai/sam2-safetensors/resolve/main/sam2_hiera_large.safetensors || \
            echo "⚠ Failed to download SAM2 Large"
    fi

    if [ ! -f "models/sam2/sam2_hiera_base_plus.safetensors" ]; then
        echo "  Downloading SAM2 Base Plus..."
        wget -q --show-progress -O models/sam2/sam2_hiera_base_plus.safetensors \
            https://huggingface.co/Kijai/sam2-safetensors/resolve/main/sam2_hiera_base_plus.safetensors || \
            echo "⚠ Failed to download SAM2 Base Plus"
    fi
    echo "✓ Models ready"
else
    echo "⚠ wget not found, skipping model downloads"
    echo "  Download models manually to models/sam2/"
fi

# Print access info
echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║           🎨 Hanzo Studio - Ready to Paint! 🎨           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
if [ -n "$RUNPOD_POD_ID" ]; then
    echo "🌐 Access via RunPod proxy URL"
    echo "   Your pod will auto-expose port 8188"
else
    echo "🌐 Access at: http://localhost:8188"
fi
echo ""
echo "📖 Quick Start:"
echo "   1. Upload video to input/"
echo "   2. Load workflow: workflows/inpainting-workflow.json"
echo "   3. Update video filename in VHS_LoadVideo node"
echo "   4. Click 'Queue Prompt'"
echo ""

# Start Studio
echo "🚀 Starting server..."
python3 main.py --listen 0.0.0.0 --port 8188
