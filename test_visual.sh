#!/bin/bash
# Visual Integration Test Launcher

echo "🎨 Launching Visual Integration Test..."
echo "=================================="
echo "Controls:"
echo "  - Numbers 0-6: Set consciousness level"
echo "  - ESC: Exit test"
echo "=================================="
echo ""

# Run the visual test
godot --path . tests/test_visual_integration.gd