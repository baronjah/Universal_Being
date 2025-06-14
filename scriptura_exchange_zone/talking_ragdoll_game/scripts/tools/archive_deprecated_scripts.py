#!/usr/bin/env python3
"""
Archive old and deprecated scripts to clean up core folder structure
"""

import os
import shutil
from pathlib import Path

base_path = Path('/mnt/c/Users/Percision 15/talking_ragdoll_game')
scripts_path = base_path / 'scripts'
archive_path = scripts_path / 'archive'

# Create archive structure
deprecated_path = archive_path / 'deprecated'
old_path = archive_path / 'old_implementations'

os.makedirs(deprecated_path, exist_ok=True)
os.makedirs(old_path, exist_ok=True)

# Files to archive based on naming patterns
deprecated_patterns = [
    '*OLD_DEPRECATED*',
    '*deprecated*',
    '*DEPRECATED*'
]

old_patterns = [
    '*_old.*',
    '*OLD.*',
    'old_*',
]

# Find and move deprecated files
deprecated_files = []
for pattern in deprecated_patterns:
    deprecated_files.extend(scripts_path.rglob(pattern))

old_files = []
for pattern in old_patterns:
    old_files.extend(scripts_path.rglob(pattern))

print("🗂️ Archiving deprecated and old scripts...")

# Move deprecated files
for file_path in deprecated_files:
    if file_path.exists() and 'archive' not in str(file_path):
        relative_path = file_path.relative_to(scripts_path)
        target_path = deprecated_path / relative_path.name
        
        try:
            shutil.move(str(file_path), str(target_path))
            print(f"📦 Moved to deprecated/: {relative_path}")
        except Exception as e:
            print(f"❌ Error moving {file_path}: {e}")

# Move old implementation files  
for file_path in old_files:
    if file_path.exists() and 'archive' not in str(file_path):
        relative_path = file_path.relative_to(scripts_path)
        target_path = old_path / relative_path.name
        
        try:
            shutil.move(str(file_path), str(target_path))
            print(f"📦 Moved to old_implementations/: {relative_path}")
        except Exception as e:
            print(f"❌ Error moving {file_path}: {e}")

# Also fix the remaining active script warnings
active_fixes = [
    'scripts/core/astral_ragdoll_helper.gd'
]

for file_path in active_fixes:
    full_path = base_path / file_path
    if full_path.exists():
        try:
            with open(full_path, 'r') as f:
                content = f.read()
            
            # Fix unused delta parameter
            content = content.replace('func _process(delta: float)', 'func _process(_delta: float)')
            
            with open(full_path, 'w') as f:
                f.write(content)
                
            print(f"🔧 Fixed warnings in: {file_path}")
        except Exception as e:
            print(f"❌ Error fixing {file_path}: {e}")

print("\n✅ Archive operation completed!")
print(f"📁 Deprecated files moved to: scripts/archive/deprecated/")
print(f"📁 Old implementation files moved to: scripts/archive/old_implementations/")
print("🧹 Core folder cleaned up - only active scripts remain!")