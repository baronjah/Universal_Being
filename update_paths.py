#!/usr/bin/env python3
"""
Universal Being Path Updater
Updates all file references after the great reorganization of 2025-06-06
"""

import os
import re
from pathlib import Path

# Path mapping for the reorganization
PATH_UPDATES = {
    # Being moves from core to beings
    "res://core/CameraUniversalBeing.gd": "res://beings/camera/CameraUniversalBeing.gd",
    "res://core/ConsoleUniversalBeing.gd": "res://beings/console/ConsoleUniversalBeing.gd", 
    "res://core/CursorUniversalBeing.gd": "res://beings/cursor/CursorUniversalBeing.gd",
    
    # Storage system moves to systems/storage
    "res://core/AkashicRecords.gd": "res://systems/storage/AkashicRecordsSystem.gd",
    "res://core/AkashicRecordsEnhanced.gd": "res://systems/storage/AkashicRecordsSystem.gd",
    "res://core/akashic_living_database.gd": "res://systems/storage/akashic_living_database.gd",
    "res://core/akashic_loader.gd": "res://systems/storage/akashic_loader.gd",
    "res://core/ZipPackageManager.gd": "res://systems/storage/ZipPackageManager.gd",
    
    # Performance and timing systems
    "res://core/MemoryOptimizer.gd": "res://systems/performance/MemoryOptimizer.gd",
    "res://core/UniversalTimersSystem.gd": "res://systems/timing/UniversalTimersSystem.gd",
    "res://core/input_focus_manager.gd": "res://systems/input/input_focus_manager.gd",
    "res://core/GameStateSocketManager.gd": "res://systems/state/GameStateSocketManager.gd",
    
    # Components
    "res://core/ActionComponent.gd": "res://components/ActionComponent.gd",
    "res://core/MemoryComponent.gd": "res://components/MemoryComponent.gd",
    
    # Scripts moved to scripts folder
    "res://core/meta_game_testing_ground.gd": "res://scripts/meta_game_testing_ground.gd",
    "res://core/universal_being_template.gd": "res://scripts/universal_being_template.gd",
    
    # Class name updates for merged systems
    "AkashicRecords": "AkashicRecordsSystem",
    "AkashicRecordsEnhanced": "AkashicRecordsSystem",
}

def update_file_paths(root_dir):
    """Update all file references in the project"""
    updated_files = []
    
    # File extensions to check
    extensions = ['.gd', '.tscn', '.cs', '.godot', '.cfg']
    
    for ext in extensions:
        for file_path in Path(root_dir).rglob(f'*{ext}'):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                original_content = content
                
                # Update all path references
                for old_path, new_path in PATH_UPDATES.items():
                    content = content.replace(old_path, new_path)
                
                # If content changed, write it back
                if content != original_content:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    updated_files.append(str(file_path))
                    print(f"✅ Updated: {file_path}")
                    
            except Exception as e:
                print(f"❌ Error updating {file_path}: {e}")
    
    return updated_files

def main():
    # Get project root from current script location
    root_dir = os.path.dirname(os.path.abspath(__file__))
    
    print("🚀 Universal Being Path Updater - Great Reorganization 2025-06-06")
    print("=" * 60)
    
    updated_files = update_file_paths(root_dir)
    
    print("\n" + "=" * 60)
    print(f"✅ COMPLETE: Updated {len(updated_files)} files")
    print("✅ All path references updated for new structure")
    print("✅ Consciousness revolution paths should now work!")
    
    if updated_files:
        print("\nFiles updated:")
        for f in updated_files[:10]:  # Show first 10
            print(f"  - {f}")
        if len(updated_files) > 10:
            print(f"  ... and {len(updated_files) - 10} more")

if __name__ == "__main__":
    main()
