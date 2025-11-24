#!/bin/bash
# Hanzo Studio - RunPod Quick Start

set -e

echo "🎨 Starting Hanzo Studio..."

# Detect best Python version (prefer 3.11, avoid 3.14)
if command -v python3.11 &> /dev/null; then
    PYTHON=python3.11
    echo "✓ Using Python 3.11"
elif command -v python3.12 &> /dev/null; then
    PYTHON=python3.12
    echo "✓ Using Python 3.12"
elif command -v python3.10 &> /dev/null; then
    PYTHON=python3.10
    echo "✓ Using Python 3.10"
elif command -v python3 &> /dev/null; then
    PYTHON=python3
    PY_VERSION=$($PYTHON --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    if [[ "$PY_VERSION" == "3.14" ]]; then
        echo "⚠️  Warning: Python 3.14 detected - may have compatibility issues"
        echo "  Recommend: brew install python@3.11 && use python3.11"
    fi
else
    echo "❌ Python 3 not found"
    exit 1
fi

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
    # Local development - check if we're in painter directory
    if [ -f "runpod-start.sh" ] && [ -f "install-nodes.sh" ]; then
        # We're already in the painter directory
        WORKSPACE="$(pwd)"
        echo "✓ Local environment detected (painter directory)"
    else
        # Use current directory
        WORKSPACE="$(pwd)"
        echo "✓ Local environment detected"
    fi
fi

echo "  Workspace: $WORKSPACE"
cd "$WORKSPACE"

# Clone/update Studio if needed
if [ ! -d "Studio" ]; then
    echo "📦 Cloning Hanzo Studio..."
    git clone https://github.com/hanzoai/studio.git Studio
    cd Studio

    # Install requirements
    echo "  Installing dependencies..."

    # Ensure critical dependencies are installed
    $PYTHON -m pip install --break-system-packages pyyaml pillow 2>/dev/null || \
        $PYTHON -m pip install pyyaml pillow 2>/dev/null || \
        echo "⚠ Could not install base dependencies"

    # Install requirements, filtering out SAM2 (installed via custom nodes)
    grep -v "segment-anything" requirements.txt > /tmp/requirements-filtered.txt 2>/dev/null || cp requirements.txt /tmp/requirements-filtered.txt
    $PYTHON -m pip install --break-system-packages -r /tmp/requirements-filtered.txt 2>/dev/null || \
        $PYTHON -m pip install -r /tmp/requirements-filtered.txt 2>/dev/null || \
        echo "⚠ Some requirements may have failed"

    # Install Studio in editable mode
    $PYTHON -m pip install --break-system-packages -e . 2>/dev/null || \
        $PYTHON -m pip install -e . 2>/dev/null || \
        echo "⚠ Could not install Studio in editable mode (continuing anyway)"
    rm -f /tmp/requirements-filtered.txt
else
    echo "✓ Studio directory exists"
    cd Studio

    # Ensure critical dependencies are installed
    $PYTHON -m pip install --break-system-packages pyyaml pillow 2>/dev/null || \
        $PYTHON -m pip install pyyaml pillow 2>/dev/null || \
        echo "⚠ Could not install base dependencies"

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
$PYTHON main.py --listen 0.0.0.0 --port 8188
