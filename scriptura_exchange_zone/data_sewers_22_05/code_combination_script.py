#!/usr/bin/env python3
"""
Automated Code Combination Script
Combines compatible functions from different projects into unified modules
"""

import shutil
from pathlib import Path

def combine_akashic_systems():
    """Combine all akashic record systems into unified module"""
    print("🔗 Combining akashic systems...")
    
    target_dir = Path("/mnt/c/Users/Percision 15/unified_game/core/akashic")
    target_dir.mkdir(parents=True, exist_ok=True)
    
    # Source files to combine
    sources = [
        "12_turns_system/akashic_notepad_controller.gd",
        "12_turns_system/akashic_database_connector.gd", 
        "12_turns_system/terminal_akashic_interface.gd",
        "Notepad3d/akashic_record_connector.gd",
        "akashic_notepad_test/scripts/akashic_notepad_controller.gd",
        "Godot_Eden/eden_case/terminal_cmd_console/akashic_records_system.gd"
    ]
    
    for source in sources:
        source_path = Path("/mnt/c/Users/Percision 15") / source
        if source_path.exists():
            target_file = target_dir / source_path.name
            shutil.copy2(source_path, target_file)
            print(f"  ✅ Copied {source_path.name}")

def combine_terminal_systems():
    """Combine all terminal interface systems"""
    print("🖥️ Combining terminal systems...")
    
    target_dir = Path("/mnt/c/Users/Percision 15/unified_game/interface/terminal")
    target_dir.mkdir(parents=True, exist_ok=True)
    
    sources = [
        "12_turns_system/terminal_akashic_interface.gd",
        "12_turns_system/terminal_to_godot_bridge.gd",
        "Notepad3d/terminal_akashic_interface.gd"
    ]
    
    for source in sources:
        source_path = Path("/mnt/c/Users/Percision 15") / source
        if source_path.exists():
            target_file = target_dir / source_path.name
            shutil.copy2(source_path, target_file)
            print(f"  ✅ Copied {source_path.name}")

def combine_ai_systems():
    """Combine AI integration systems"""
    print("🤖 Combining AI systems...")
    
    target_dir = Path("/mnt/c/Users/Percision 15/unified_game/ai")
    target_dir.mkdir(parents=True, exist_ok=True)
    
    sources = [
        "evolution_game_claude/core/claude_interface.py",
        "evolution_game_claude/core/evolution_engine.py",
        "12_turns_system/claude_akashic_bridge.gd",
        "12_turns_system/claude_integration_bridge.gd"
    ]
    
    for source in sources:
        source_path = Path("/mnt/c/Users/Percision 15") / source
        if source_path.exists():
            target_file = target_dir / source_path.name
            shutil.copy2(source_path, target_file)
            print(f"  ✅ Copied {source_path.name}")

def combine_visualization_systems():
    """Combine 3D visualization systems"""
    print("🎨 Combining visualization systems...")
    
    target_dir = Path("/mnt/c/Users/Percision 15/unified_game/visualization")
    target_dir.mkdir(parents=True, exist_ok=True)
    
    sources = [
        "12_turns_system/dimension_visualizer.gd",
        "12_turns_system/dimensional_color_system.gd",
        "Notepad3d/notepad3d_visualizer.gd",
        "12_turns_system/word_visualization_3d.gd"
    ]
    
    for source in sources:
        source_path = Path("/mnt/c/Users/Percision 15") / source
        if source_path.exists():
            target_file = target_dir / source_path.name
            shutil.copy2(source_path, target_file)
            print(f"  ✅ Copied {source_path.name}")

if __name__ == "__main__":
    print("🚀 Starting automated code combination...")
    
    combine_akashic_systems()
    combine_terminal_systems() 
    combine_ai_systems()
    combine_visualization_systems()
    
    print("🎉 Code combination completed!")
    print("📁 Check /mnt/c/Users/Percision 15/unified_game/ for combined modules")
