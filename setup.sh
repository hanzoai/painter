#!/bin/bash
set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
COMFYUI_DIR="${COMFYUI_DIR:-./ComfyUI}"
PYTHON="${PYTHON:-python3}"

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Hanzo Painter Setup${NC}"
echo -e "${BLUE}AI-Powered Video Inpainting${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Check dependencies
echo -e "${YELLOW}Checking dependencies...${NC}"
command -v ${PYTHON} >/dev/null 2>&1 || { echo -e "${RED}Python 3 is required but not installed.${NC}" >&2; exit 1; }
command -v git >/dev/null 2>&1 || { echo -e "${RED}Git is required but not installed.${NC}" >&2; exit 1; }
command -v wget >/dev/null 2>&1 || { echo -e "${RED}wget is required but not installed.${NC}" >&2; exit 1; }
echo -e "${GREEN}✓ All dependencies found${NC}"
echo ""

# Check if ComfyUI exists
if [ -d "$COMFYUI_DIR" ]; then
    echo -e "${YELLOW}ComfyUI already exists at $COMFYUI_DIR${NC}"
    read -p "Do you want to reinstall? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Removing existing installation...${NC}"
        rm -rf "$COMFYUI_DIR"
    else
        echo -e "${YELLOW}Skipping ComfyUI installation${NC}"
    fi
fi

# Install ComfyUI
if [ ! -d "$COMFYUI_DIR" ]; then
    echo -e "${YELLOW}Installing ComfyUI...${NC}"
    git clone https://github.com/comfyanonymous/ComfyUI.git "$COMFYUI_DIR"
    cd "$COMFYUI_DIR"
    pip install -r requirements.txt
    cd ..
    echo -e "${GREEN}✓ ComfyUI installed${NC}"
else
    echo -e "${GREEN}✓ ComfyUI already installed${NC}"
fi
echo ""

# Install custom nodes
echo -e "${YELLOW}Installing custom nodes...${NC}"
mkdir -p "$COMFYUI_DIR/custom_nodes"
cd "$COMFYUI_DIR/custom_nodes"

# DiffuEraser
if [ ! -d "ComfyUI_DiffuEraser" ]; then
    echo "  Installing DiffuEraser..."
    git clone https://github.com/ddsoul/ComfyUI_DiffuEraser.git
    echo -e "  ${GREEN}✓ DiffuEraser installed${NC}"
fi

# VideoHelperSuite
if [ ! -d "ComfyUI-VideoHelperSuite" ]; then
    echo "  Installing VideoHelperSuite..."
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
    cd ComfyUI-VideoHelperSuite && pip install -r requirements.txt && cd ..
    echo -e "  ${GREEN}✓ VideoHelperSuite installed${NC}"
fi

# Easy-Use
if [ ! -d "ComfyUI-Easy-Use" ]; then
    echo "  Installing Easy-Use..."
    git clone https://github.com/yolain/ComfyUI-Easy-Use.git
    echo -e "  ${GREEN}✓ Easy-Use installed${NC}"
fi

# KJNodes
if [ ! -d "ComfyUI-KJNodes" ]; then
    echo "  Installing KJNodes..."
    git clone https://github.com/kijai/ComfyUI-KJNodes.git
    cd ComfyUI-KJNodes && pip install -r requirements.txt && cd ..
    echo -e "  ${GREEN}✓ KJNodes installed${NC}"
fi

# LayerStyle
if [ ! -d "ComfyUI_LayerStyle" ]; then
    echo "  Installing LayerStyle..."
    git clone https://github.com/chflame163/ComfyUI_LayerStyle.git
    echo -e "  ${GREEN}✓ LayerStyle installed${NC}"
fi

cd ../..
echo -e "${GREEN}✓ All custom nodes installed${NC}"
echo ""

# Ask about SAM2
read -p "Install SAM2 for advanced segmentation? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}Installing SAM2...${NC}"
    cd "$COMFYUI_DIR/custom_nodes"
    if [ ! -d "ComfyUI-SAM2" ]; then
        git clone https://github.com/cubiq/ComfyUI-SAM2.git
        cd ComfyUI-SAM2 && pip install -r requirements.txt && cd ..
        echo -e "${GREEN}✓ SAM2 installed${NC}"
    fi
    cd ../..
fi
echo ""

# Download SAM2 models
echo -e "${YELLOW}Downloading SAM2 models...${NC}"
mkdir -p "$COMFYUI_DIR/models/sam2"

if [ ! -f "$COMFYUI_DIR/models/sam2/sam2_hiera_large.pt" ]; then
    echo "  Downloading SAM2 Large (1.2GB)..."
    wget -q --show-progress -O "$COMFYUI_DIR/models/sam2/sam2_hiera_large.pt" \
        https://dl.fbaipublicfiles.com/segment_anything_2/072824/sam2_hiera_large.pt
    echo -e "  ${GREEN}✓ SAM2 Large downloaded${NC}"
fi

if [ ! -f "$COMFYUI_DIR/models/sam2/sam2_hiera_base_plus.pt" ]; then
    echo "  Downloading SAM2 Base Plus (800MB)..."
    wget -q --show-progress -O "$COMFYUI_DIR/models/sam2/sam2_hiera_base_plus.pt" \
        https://dl.fbaipublicfiles.com/segment_anything_2/072824/sam2_hiera_base_plus.pt
    echo -e "  ${GREEN}✓ SAM2 Base Plus downloaded${NC}"
fi
echo ""

# Install workflow
echo -e "${YELLOW}Installing workflow...${NC}"
mkdir -p "$COMFYUI_DIR/workflows"
cp inpainting-workflow.json "$COMFYUI_DIR/workflows/"
echo -e "${GREEN}✓ Workflow installed${NC}"
echo ""

# Create directories
mkdir -p "$COMFYUI_DIR/input"
mkdir -p "$COMFYUI_DIR/output"
mkdir -p "$COMFYUI_DIR/models/checkpoints"
mkdir -p "$COMFYUI_DIR/models/diffusers"

echo -e "${BLUE}=====================================${NC}"
echo -e "${GREEN}✓ Setup complete!${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Download required models:"
echo "   - realisticVisionV51_v51VAE.safetensors → $COMFYUI_DIR/models/checkpoints/"
echo "   - pcm_sd15_smallcfg_2step_converted.safetensors → $COMFYUI_DIR/models/diffusers/"
echo ""
echo "2. Start ComfyUI:"
echo "   make run"
echo "   or"
echo "   cd $COMFYUI_DIR && python main.py --listen 0.0.0.0 --port 8188"
echo ""
echo "3. Open http://localhost:8188 in your browser"
echo ""
echo -e "${GREEN}Happy painting! 🎨✨${NC}"
