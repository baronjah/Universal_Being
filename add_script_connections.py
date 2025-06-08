#!/usr/bin/env python3
"""
Add connection comments to GDScript files to help future Claudes understand the web
Like Claudio Abbado conducting an orchestra - each instrument knows its partners
"""

import os
import re

# Key connections to document
connections = {
    "autoloads/GemmaAI.gd": [
        "# Connected to: beings/GemmaAICompanionPlasmoid.gd (AI embodiment)",
        "# Uses: scripts/GemmaVision.gd, GemmaSpatialPerception.gd (perception)",
        "# Required by: All scenes with AI interaction"
    ],
    "core/UniversalBeing.gd": [
        "# Connected to: ALL beings/* scripts (base class)",
        "# Uses: core/Pentagon.gd, core/Component.gd",
        "# Required by: Every Universal Being in the game"
    ],
    "autoloads/SystemBootstrap.gd": [
        "# Connected to: core/FloodGates.gd, systems/AkashicRecords.gd",
        "# Uses: Singleton pattern for system initialization",
        "# Required by: Main game startup sequence"
    ],
    "beings/GemmaAICompanionPlasmoid.gd": [
        "# Connected to: autoloads/GemmaAI.gd (AI logic)",
        "# Uses: shaders/plasmoid_being.gdshader (visual effects)",
        "# Required by: Scenes with AI companion"
    ],
    "systems/ConsciousnessRippleSystem.gd": [
        "# Connected to: shaders/consciousness_ripple.gdshader",
        "# Uses: systems/ConsciousnessRevolutionIntegrator.gd",
        "# Required by: Visual consciousness effects"
    ]
}

def add_connections_to_file(filepath, connection_comments):
    """Add connection comments after the extends line"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        # Find where to insert (after extends or class_name)
        insert_index = 0
        for i, line in enumerate(lines):
            if line.strip().startswith('extends') or line.strip().startswith('class_name'):
                insert_index = i + 1
                # Skip any existing class_name after extends
                if i + 1 < len(lines) and lines[i + 1].strip().startswith('class_name'):
                    insert_index = i + 2
                break
        
        # Check if connections already exist
        if insert_index < len(lines) and "# Connected to:" in lines[insert_index]:
            print(f"✓ {filepath} already has connections")
            return
        
        # Insert connections
        for comment in reversed(connection_comments):
            lines.insert(insert_index, comment + '\n')
        lines.insert(insert_index + len(connection_comments), '\n')
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(lines)
        
        print(f"✓ Added connections to {filepath}")
        
    except Exception as e:
        print(f"✗ Error processing {filepath}: {e}")

def main():
    print("🎼 Adding script connections (Conducted by Claudio Abbado)...")
    print("=" * 50)
    
    for script_path, connection_comments in connections.items():
        full_path = os.path.join("/mnt/c/Users/Percision 15/Universal_Being", script_path)
        if os.path.exists(full_path):
            add_connections_to_file(full_path, connection_comments)
        else:
            print(f"✗ File not found: {script_path}")
    
    print("\n🎻 The orchestra is now connected!")

if __name__ == "__main__":
    main()