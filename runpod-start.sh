#!/bin/bash
# Hanzo Studio - RunPod Quick Start

set -e

echo "🎨 Starting Hanzo Studio on RunPod..."

# Check if running in RunPod
if [ -n "$RUNPOD_POD_ID" ]; then
    echo "✓ RunPod environment detected"
    echo "  Pod ID: $RUNPOD_POD_ID"
fi

# Navigate to workspace
cd /workspace

# Clone/update Studio if needed
if [ ! -d "Studio" ]; then
    echo "📦 Cloning Hanzo Studio..."
    git clone https://github.com/hanzoai/studio.git Studio
    cd Studio
    pip3 install -r requirements.txt
    pip3 install -e .
else
    echo "✓ Studio directory exists"
    cd Studio
    git pull origin master || echo "⚠ Could not update Studio (continuing with existing version)"
fi

# Install custom nodes if not present
if [ ! -d "custom_nodes/Hanzo-DiffuEraser" ]; then
    echo "📦 Installing custom nodes..."
    bash /workspace/install-nodes.sh
else
    echo "✓ Custom nodes already installed"
fi

# Download models if needed
echo "📥 Checking models..."

# SAM2 models
if [ ! -f "models/sam2/sam2_hiera_large.safetensors" ]; then
    echo "  Downloading SAM2 Large..."
    mkdir -p models/sam2
    wget -q --show-progress -O models/sam2/sam2_hiera_large.safetensors \
        https://huggingface.co/Kijai/sam2-safetensors/resolve/main/sam2_hiera_large.safetensors
fi

if [ ! -f "models/sam2/sam2_hiera_base_plus.safetensors" ]; then
    echo "  Downloading SAM2 Base Plus..."
    wget -q --show-progress -O models/sam2/sam2_hiera_base_plus.safetensors \
        https://huggingface.co/Kijai/sam2-safetensors/resolve/main/sam2_hiera_base_plus.safetensors
fi

echo "✓ Models ready"

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
