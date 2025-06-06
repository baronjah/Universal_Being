#!/usr/bin/env python3
"""
Fix AkashicRecordsSystem double-naming issue
"""

import os
import re
from pathlib import Path

def fix_akashic_references():
    """Fix AkashicRecordsSystemSystem to AkashicRecordsSystem"""
    
    # Files to fix
    fixes = {
        "AkashicRecordsSystemSystem": "AkashicRecordsSystem",
        "AkashicRecordsSystemSystemEnhanced": "AkashicRecordsSystemEnhanced",
        "/root/AkashicRecordsSystemSystem": "/root/AkashicRecordsSystem",
        "res://systems/storage/AkashicRecordsSystemSystem.gd": "res://systems/storage/AkashicRecordsSystem.gd"
    }
    
    # Get project root from current script location
    root_dir = os.path.dirname(os.path.abspath(__file__))
    updated_files = []
    
    # File extensions to check
    extensions = ['.gd', '.tscn', '.cs', '.godot', '.cfg']
    
    for ext in extensions:
        for file_path in Path(root_dir).rglob(f'*{ext}'):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                original_content = content
                
                # Apply all fixes
                for old_ref, new_ref in fixes.items():
                    content = content.replace(old_ref, new_ref)
                
                # If content changed, write it back
                if content != original_content:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    updated_files.append(str(file_path))
                    print(f"✅ Fixed: {file_path}")
                    
            except Exception as e:
                print(f"❌ Error fixing {file_path}: {e}")
    
    return updated_files

def main():
    print("🔧 Fixing AkashicRecordsSystem double-naming issue...")
    print("=" * 60)
    
    updated_files = fix_akashic_references()
    
    print("\n" + "=" * 60)
    print(f"✅ COMPLETE: Fixed {len(updated_files)} files")
    print("✅ AkashicRecordsSystem references corrected")
    
    if updated_files:
        print("\nFiles fixed:")
        for f in updated_files[:10]:  # Show first 10
            print(f"  - {f}")
        if len(updated_files) > 10:
            print(f"  ... and {len(updated_files) - 10} more")

if __name__ == "__main__":
    main()
