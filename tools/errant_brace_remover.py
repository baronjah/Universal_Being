#!/usr/bin/env python3
"""
🚫 ERRANT BRACE REMOVER - Remove misplaced closing braces in functions
Targets specific pattern: closing brace immediately after function content
"""

import os
import re
from pathlib import Path
import shutil

def fix_errant_braces(file_path: Path) -> bool:
    """Remove misplaced closing braces in function bodies"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"❌ Error reading {file_path}: {e}")
        return False
    
    original_content = content
    lines = content.split('\n')
    fixed_lines = []
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # Look for misplaced closing braces after statements
        if (line.strip() == '}' and 
            i > 0 and 
            not lines[i-1].strip().startswith('{')):
            # This might be an errant closing brace
            # Check if previous line is a statement (not dictionary start)
            prev_line = lines[i-1].strip()
            if (prev_line and 
                not prev_line.endswith('{') and
                not prev_line.endswith('= {') and
                not prev_line.startswith('#') and
                not prev_line == ''):
                # Skip this errant brace
                print(f"   🚫 Removed errant brace after: {prev_line[:50]}...")
                i += 1
                continue
        
        fixed_lines.append(line)
        i += 1
    
    fixed_content = '\n'.join(fixed_lines)
    
    if fixed_content != original_content:
        # Create backup
        backup_path = file_path.with_suffix('.gd.bracefix_backup')
        shutil.copy2(file_path, backup_path)
        
        # Write fixed content
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(fixed_content)
            print(f"✅ Fixed errant braces: {file_path}")
            return True
        except Exception as e:
            print(f"❌ Error writing {file_path}: {e}")
            return False
    
    return False

def main():
    project_path = Path("/mnt/c/Users/Percision 15/Universal_Being")
    
    # Target critical files first
    critical_files = [
        "autoloads/GemmaAI.gd",
        "systems/UBPrintCollector.gd", 
        "core/AutoRegisterFallbacks.gd",
        "core/FloodGates.gd",
        "core/UniversalBeing.gd",
        "systems/storage/AkashicRecordsSystem.gd"
    ]
    
    print("🚫 ERRANT BRACE REMOVER: Fixing critical files...")
    
    for file_rel_path in critical_files:
        file_path = project_path / file_rel_path
        if file_path.exists():
            fix_errant_braces(file_path)
    
    print(f"\n🚫 ERRANT BRACE REMOVAL COMPLETE!")
    print(f"🎮 Your Universal Being should now load without brace errors!")

if __name__ == "__main__":
    main()