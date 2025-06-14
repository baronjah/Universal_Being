#!/usr/bin/env python3
"""
🔥 BRACE DESTROYER - Remove invalid braces from GDScript files
GDScript uses indentation, not braces - this removes stray } characters
"""

import os
import re
from pathlib import Path
import shutil

def fix_gdscript_braces(file_path: Path) -> bool:
    """Remove invalid closing braces from GDScript files"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"❌ Error reading {file_path}: {e}")
        return False
    
    original_content = content
    
    # Remove standalone closing braces that are invalid in GDScript
    # Keep braces that are inside strings or comments
    lines = content.split('\n')
    fixed_lines = []
    
    for line in lines:
        # Skip lines that are comments
        if line.strip().startswith('#'):
            fixed_lines.append(line)
            continue
            
        # Skip lines inside strings (basic check)
        if '"""' in line or "'''" in line:
            fixed_lines.append(line)
            continue
            
        # Remove standalone closing braces
        # Look for lines that are just whitespace + }
        if re.match(r'^\s*}\s*$', line):
            # This is a standalone closing brace - remove it
            continue
        
        # Remove closing braces at end of lines (after other content)
        line = re.sub(r'\s*}\s*$', '', line)
        
        fixed_lines.append(line)
    
    fixed_content = '\n'.join(fixed_lines)
    
    if fixed_content != original_content:
        # Create backup
        backup_path = file_path.with_suffix('.gd.backup')
        shutil.copy2(file_path, backup_path)
        
        # Write fixed content
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(fixed_content)
            
            brace_count = original_content.count('}') - fixed_content.count('}')
            print(f"✅ Fixed {file_path}: Removed {brace_count} invalid braces")
            return True
            
        except Exception as e:
            print(f"❌ Error writing {file_path}: {e}")
            return False
    
    return False

def main():
    project_path = Path("/mnt/c/Users/Percision 15/Universal_Being")
    
    # Target the specific problematic file first
    akashic_file = project_path / "systems/storage/AkashicRecordsSystem.gd"
    
    if akashic_file.exists():
        print("🔥 BRACE DESTROYER: Fixing AkashicRecordsSystem.gd")
        if fix_gdscript_braces(akashic_file):
            print("✅ AkashicRecordsSystem.gd brace errors fixed!")
        else:
            print("⚠️ No brace issues found in AkashicRecordsSystem.gd")
    else:
        print("❌ AkashicRecordsSystem.gd not found")
    
    # Also fix other GDScript files with brace issues
    gdscript_files = list(project_path.rglob("*.gd"))
    fixed_count = 0
    
    for file_path in gdscript_files:
        if "scriptura_exchange_zone" in str(file_path):
            continue  # Skip scriptura zone for now
            
        if fix_gdscript_braces(file_path):
            fixed_count += 1
    
    print(f"\n🔥 BRACE DESTRUCTION COMPLETE!")
    print(f"✅ Fixed {fixed_count} files with invalid braces")
    print(f"🎮 Your GDScript files should now parse correctly!")

if __name__ == "__main__":
    main()