# Hanzo Studio - RunPod Optimized
FROM nvidia/cuda:12.1.0-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    STUDIO_PORT=8188

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3-pip \
    git \
    wget \
    curl \
    ffmpeg \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# Upgrade pip
RUN python3 -m pip install --upgrade pip setuptools wheel

# Create app directory
WORKDIR /workspace

# Clone Hanzo Studio
RUN git clone https://github.com/hanzoai/studio.git Studio && \
    cd Studio && \
    pip3 install -r requirements.txt && \
    pip3 install -e .

# Create necessary directories
RUN cd Studio && \
    mkdir -p models/checkpoints models/diffusers models/sam2 \
    mkdir -p input output custom_nodes workflows

# Copy custom nodes install script (will be created)
COPY install-nodes.sh /workspace/install-nodes.sh
RUN chmod +x /workspace/install-nodes.sh && \
    bash /workspace/install-nodes.sh

# Expose Studio port
EXPOSE 8188

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8188/ || exit 1

# Default startup command
CMD ["python3", "Studio/main.py", "--listen", "0.0.0.0", "--port", "8188"]
