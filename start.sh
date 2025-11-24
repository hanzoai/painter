#!/bin/bash
# Hanzo Painter - Simple start script using uv + Makefile

set -e

echo "🎨 Hanzo Painter - AI Video Inpainting"
echo ""

# Check if setup is needed
if [ ! -d ".venv" ]; then
    echo "Setting up virtual environment..."
    make setup-venv
    echo ""
fi

# Start the server
echo "Starting server..."
make run
