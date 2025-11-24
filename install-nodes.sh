#!/bin/bash
# Install Hanzo custom nodes for Painter

set -e

# Detect Studio directory
if [ -d "/workspace/Studio/custom_nodes" ]; then
    CUSTOM_NODES_DIR="/workspace/Studio/custom_nodes"
elif [ -d "Studio/custom_nodes" ]; then
    CUSTOM_NODES_DIR="Studio/custom_nodes"
elif [ -d "custom_nodes" ]; then
    CUSTOM_NODES_DIR="custom_nodes"
else
    echo "❌ Could not find custom_nodes directory"
    exit 1
fi

echo "Installing to: $CUSTOM_NODES_DIR"
cd "$CUSTOM_NODES_DIR"

echo "Installing Hanzo custom nodes..."

# Determine pip command
if command -v pip3 &> /dev/null; then
    PIP=pip3
elif command -v pip &> /dev/null; then
    PIP=pip
else
    echo "⚠ pip not found, skipping requirements installation"
    PIP=":"
fi

# Hanzo-DiffuEraser (required for inpainting)
if [ ! -d "Hanzo-DiffuEraser" ]; then
    git clone https://github.com/hanzoai/Hanzo-DiffuEraser.git
    cd Hanzo-DiffuEraser && $PIP install -r requirements.txt 2>/dev/null || echo "⚠ Could not install requirements" && cd ..
fi

# Hanzo-VideoHelper (required for video I/O)
if [ ! -d "Hanzo-VideoHelper" ]; then
    git clone https://github.com/hanzoai/Hanzo-VideoHelper.git
    cd Hanzo-VideoHelper && $PIP install -r requirements.txt 2>/dev/null || echo "⚠ Could not install requirements" && cd ..
fi

# Hanzo-EasyUse (workflow utilities)
if [ ! -d "Hanzo-EasyUse" ]; then
    git clone https://github.com/hanzoai/Hanzo-EasyUse.git
    cd Hanzo-EasyUse && $PIP install -r requirements.txt 2>/dev/null || echo "⚠ Could not install requirements" && cd ..
fi

# Hanzo-KJNodes (core utilities)
if [ ! -d "Hanzo-KJNodes" ]; then
    git clone https://github.com/hanzoai/Hanzo-KJNodes.git
    cd Hanzo-KJNodes && $PIP install -r requirements.txt 2>/dev/null || echo "⚠ Could not install requirements" && cd ..
fi

# Hanzo-LayerStyle (layer compositing)
if [ ! -d "Hanzo-LayerStyle" ]; then
    git clone https://github.com/hanzoai/Hanzo-LayerStyle.git
    cd Hanzo-LayerStyle && $PIP install -r requirements.txt 2>/dev/null || echo "⚠ Could not install requirements" && cd ..
fi

echo "✓ Custom nodes installed successfully"
