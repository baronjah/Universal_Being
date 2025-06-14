#!/usr/bin/env python3
"""
🔧 DICTIONARY FIXER - Fix incomplete dictionary declarations in GDScript
Specifically targets dictionaries missing closing braces
"""

import os
import re
from pathlib import Path
import shutil

def fix_dictionary_syntax(file_path: Path) -> bool:
    """Fix incomplete dictionary declarations in GDScript files"""
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
        
        # Look for dictionary declarations that might be incomplete
        if 'Dictionary = {' in line and not line.strip().endswith('}'):
            # Check if this is an incomplete dictionary (next line doesn't start with proper dict content)
            if i + 1 < len(lines):
                next_line = lines[i + 1].strip()
                # If next line is empty, a function, or another variable declaration, this dict is incomplete
                if (not next_line or 
                    next_line.startswith('var ') or 
                    next_line.startswith('func ') or
                    next_line.startswith('@') or
                    next_line.startswith('#') or
                    next_line.startswith('class ') or
                    next_line.startswith('extends ') or
                    next_line.startswith('signal ') or
                    next_line.startswith('enum ')):
                    # Fix by adding closing brace
                    line = line.replace('Dictionary = {', 'Dictionary = {}')
                    print(f"   🔧 Fixed incomplete dictionary: {file_path.name}:{i+1}")
        
        # Also look for trailing dictionary elements without closing braces
        if (line.strip() and 
            not line.strip().startswith('#') and
            '"' in line and ':' in line and
            i + 1 < len(lines)):
            next_line = lines[i + 1].strip()
            if (not next_line or 
                next_line.startswith('var ') or 
                next_line.startswith('func ') or
                next_line.startswith('#') or
                next_line.startswith('class ') or
                next_line.startswith('extends ')):
                # This might be the last line of a dictionary - add closing brace
                if not line.strip().endswith('}') and not line.strip().endswith(','):
                    # Count tabs/spaces for proper indentation
                    indent = len(line) - len(line.lstrip())
                    if indent > 0:
                        # Add closing brace with proper indentation
                        fixed_lines.append(line)
                        fixed_lines.append('\t' * (indent // 4) + '}')
                        i += 1
                        continue
        
        fixed_lines.append(line)
        i += 1
    
    fixed_content = '\n'.join(fixed_lines)
    
    if fixed_content != original_content:
        # Create backup
        backup_path = file_path.with_suffix('.gd.dictfix_backup')
        shutil.copy2(file_path, backup_path)
        
        # Write fixed content
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(fixed_content)
            print(f"✅ Fixed dictionary syntax: {file_path}")
            return True
        except Exception as e:
            print(f"❌ Error writing {file_path}: {e}")
            return False
    
    return False

def main():
    project_path = Path("/mnt/c/Users/Percision 15/Universal_Being")
    
    # Target critical autoload files first
    critical_files = [
        "autoloads/GemmaAI.gd",
        "systems/UBPrintCollector.gd", 
        "core/AutoRegisterFallbacks.gd",
        "core/FloodGates.gd",
        "core/UniversalBeing.gd"
    ]
    
    print("🔧 DICTIONARY FIXER: Fixing critical autoload files...")
    
    for file_rel_path in critical_files:
        file_path = project_path / file_rel_path
        if file_path.exists():
            fix_dictionary_syntax(file_path)
    
    # Also fix other GDScript files with dictionary issues
    gdscript_files = list(project_path.rglob("*.gd"))
    fixed_count = 0
    
    for file_path in gdscript_files:
        if "scriptura_exchange_zone" in str(file_path):
            continue  # Skip scriptura zone
            
        if fix_dictionary_syntax(file_path):
            fixed_count += 1
    
    print(f"\n🔧 DICTIONARY FIXING COMPLETE!")
    print(f"✅ Fixed {fixed_count} files with dictionary syntax errors")
    print(f"🎮 Your Universal Being should now load without dictionary errors!")

if __name__ == "__main__":
    main()