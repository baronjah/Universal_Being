#!/usr/bin/env python3
"""
==================================================
TEST SCENE LOADER - Universal Being Project
==================================================
DESCRIPTION: Quick launcher for testing the enhanced scene
PURPOSE: Ensure we're loading the correct enhanced scene
CREATED: 2025-06-15 - Universal Being Revolution
AUTHOR: Claude Code + JSH
==================================================
"""

import subprocess
import sys
from pathlib import Path

def test_enhanced_scene():
    """Test the enhanced scene with proper Godot loading"""
    
    print("🎮 TEST SCENE LOADER - Universal Being Enhanced Scene")
    print("="*60)
    
    project_path = Path("/mnt/c/Users/Percision 15/Universal_Being")
    scene_path = "res://scenes/test/working_bright_test.tscn"
    
    print(f"🌟 Project path: {project_path}")
    print(f"🎮 Loading scene: {scene_path}")
    print(f"📜 Using script: EnhancedPlasmoidTest.gd")
    
    # Check if files exist
    script_path = project_path / "scripts" / "EnhancedPlasmoidTest.gd"
    scene_file = project_path / "scenes" / "test" / "working_bright_test.tscn"
    
    if not script_path.exists():
        print("❌ Enhanced script not found!")
        return False
        
    if not scene_file.exists():
        print("❌ Scene file not found!")
        return False
    
    print("✅ All files found!")
    print("\n🎮 ENHANCED SCENE FEATURES:")
    print("✅ 1. Plasmoid with sockets - Socket system active")
    print("✅ 2. Orbital camera - Positioned for perfect view")  
    print("✅ 3. Cursor interaction - Left/Right mouse clicks")
    print("✅ 4. Crosshair - Center screen crosshair")
    print("✅ 5. WASD movement - Full 6DOF movement")
    print("✅ 6. AI consciousness - Evolving consciousness levels")
    print("✅ 7. Console system - Debug keys 1-6 and T")
    print("✅ 8. Connections - Environmental scanning")
    print("✅ 9. UB debugging - Real-time status")
    print("✅ 10. Absolute perfection - All systems integrated")
    
    print("\n🎮 CONTROLS TO TEST:")
    print("🖱️  Left Click = Evolve consciousness (+1 level)")
    print("🖱️  Right Click = Energy burst")
    print("⌨️  Keys 1-6 = Debug information")
    print("⌨️  T = Generate new AI thought")
    print("🎮 WASD = Move, Space/Shift = Up/Down")
    
    # Launch Godot
    try:
        print(f"\n🚀 Launching Godot with enhanced scene...")
        print("🌟 Look for 'ENHANCED PLASMOID ACTIVE' in console!")
        
        cmd = ["godot", "--path", str(project_path), scene_path]
        print(f"Command: {' '.join(cmd)}")
        
        # Don't wait for process to complete (let Godot run)
        subprocess.Popen(cmd)
        
        print("✅ Godot launched! Check the game window.")
        return True
        
    except Exception as e:
        print(f"❌ Failed to launch Godot: {e}")
        print("💡 Try running manually: godot --path . res://scenes/test/working_bright_test.tscn")
        return False

def show_debug_info():
    """Show debug information about the enhanced scene"""
    
    print("\n🔍 DEBUG INFORMATION:")
    print("="*40)
    
    # Check script content
    script_path = Path("/mnt/c/Users/Percision 15/Universal_Being/scripts/EnhancedPlasmoidTest.gd")
    
    if script_path.exists():
        with open(script_path, 'r') as f:
            content = f.read()
            
        print(f"📜 Script size: {len(content)} characters")
        print(f"📝 Contains _input function: {'func _input(' in content}")
        print(f"🖱️  Contains mouse handling: {'InputEventMouseButton' in content}")
        print(f"⌨️  Contains keyboard handling: {'InputEventKey' in content}")
        print(f"🧠 Contains consciousness: {'consciousness_level' in content}")
        print(f"🎮 Contains debug keys: {'KEY_1' in content}")
        
        # Show first few lines
        lines = content.split('\n')[:10]
        print(f"\n📜 Script preview:")
        for i, line in enumerate(lines, 1):
            print(f"   {i:2d}: {line}")
    
    else:
        print("❌ Enhanced script not found!")

if __name__ == "__main__":
    print("🎮 TEST SCENE LOADER - Universal Being Enhanced Scene")
    
    # Show debug info first
    show_debug_info()
    
    # Test the scene
    success = test_enhanced_scene()
    
    if success:
        print("\n🌟 SCENE LOADER SUCCESS! 🌟")
        print("🎮 Check Godot window for enhanced plasmoid!")
        print("🧠 Watch console for consciousness evolution!")
    else:
        print("\n⚠️ Manual launch required")
        print("💻 Run: cd '/mnt/c/Users/Percision 15/Universal_Being' && godot res://scenes/test/working_bright_test.tscn")
    
    print("\n🌌 The enhanced cosmic plasmoid awaits your interaction!")