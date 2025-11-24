#!/bin/bash
# Install Hanzo custom nodes for Painter

set -e

cd /workspace/Studio/custom_nodes

echo "Installing Hanzo custom nodes..."

# Hanzo-DiffuEraser (required for inpainting)
git clone https://github.com/hanzoai/Hanzo-DiffuEraser.git
cd Hanzo-DiffuEraser && pip3 install -r requirements.txt && cd ..

# Hanzo-VideoHelper (required for video I/O)
git clone https://github.com/hanzoai/Hanzo-VideoHelper.git
cd Hanzo-VideoHelper && pip3 install -r requirements.txt && cd ..

# Hanzo-EasyUse (workflow utilities)
git clone https://github.com/hanzoai/Hanzo-EasyUse.git
cd Hanzo-EasyUse && pip3 install -r requirements.txt && cd ..

# Hanzo-KJNodes (core utilities)
git clone https://github.com/hanzoai/Hanzo-KJNodes.git
cd Hanzo-KJNodes && pip3 install -r requirements.txt && cd ..

# Hanzo-LayerStyle (layer compositing)
git clone https://github.com/hanzoai/Hanzo-LayerStyle.git
cd Hanzo-LayerStyle && pip3 install -r requirements.txt && cd ..

echo "✓ Custom nodes installed successfully"
