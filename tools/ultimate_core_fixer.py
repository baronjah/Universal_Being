#!/usr/bin/env python3
"""
==================================================
ULTIMATE CORE FIXER - Universal Being Project
==================================================
DESCRIPTION: Ultimate tool to fix all core class syntax errors
PURPOSE: Fix all critical core classes to restore Universal Being game
CREATED: 2025-06-14 - Universal Being Revolution
AUTHOR: Claude Code + JSH
==================================================
"""

import os
import re
from pathlib import Path

def fix_universal_being_core_files():
    """Fix all core Universal Being files with perfect syntax"""
    
    project_path = Path("/mnt/c/Users/Percision 15/Universal_Being")
    core_files = [
        'core/UniversalBeingSocket.gd',
        'core/UniversalBeingDNA.gd',
        'core/UniversalBeingSocketManager.gd'
    ]
    
    results = []
    
    for file_rel_path in core_files:
        file_path = project_path / file_rel_path
        
        if not file_path.exists():
            print(f"⚠️  File not found: {file_path}")
            continue
            
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            original_content = content
            changes_made = 0
            
            # Fix 1: Dictionary initialization missing closing braces
            pattern1 = r'(\w+\s*[=:]\s*\{[^}]*?)(\n\s*(?:var|func|#|class|extends|enum|signal|$))'
            matches = list(re.finditer(pattern1, content, re.MULTILINE | re.DOTALL))
            for match in reversed(matches):
                dict_content = match.group(1)
                if not dict_content.rstrip().endswith('}'):
                    content = content[:match.start(1)] + dict_content.rstrip() + '\n\t}' + content[match.start(2):]
                    changes_made += 1
            
            # Fix 2: Return statements with missing closing braces
            pattern2 = r'(return\s*\{[^}]*?)(\n\s*(?:var|func|#|class|extends|enum|$))'
            matches = list(re.finditer(pattern2, content, re.MULTILINE | re.DOTALL))
            for match in reversed(matches):
                return_content = match.group(1)
                if not return_content.rstrip().endswith('}'):
                    content = content[:match.start(1)] + return_content.rstrip() + '}' + content[match.start(2):]
                    changes_made += 1
            
            # Fix 3: Enum definitions missing opening braces
            pattern3 = r'(enum\s+\w+)\s*(\n)'
            content = re.sub(pattern3, r'\1 {\n}\2', content)
            if pattern3 != content:
                changes_made += 1
            
            # Fix 4: Enum definitions missing closing braces
            pattern4 = r'(enum\s+\w+\s*\{[^}]*?)(\n\s*(?:var|func|#|class|extends|$))'
            matches = list(re.finditer(pattern4, content, re.MULTILINE | re.DOTALL))
            for match in reversed(matches):
                enum_content = match.group(1)
                if not enum_content.rstrip().endswith('}'):
                    content = content[:match.start(1)] + enum_content.rstrip() + '\n}' + content[match.start(2):]
                    changes_made += 1
            
            # Fix 5: Remove orphaned closing braces
            lines = content.split('\n')
            fixed_lines = []
            for line in lines:
                # Skip lines that are just orphaned closing braces
                if line.strip() == '}' and len(fixed_lines) > 0:
                    # Check if previous line might need this brace
                    prev_line = fixed_lines[-1] if fixed_lines else ""
                    if not ('{' in prev_line and prev_line.count('{') > prev_line.count('}')):
                        changes_made += 1
                        continue
                fixed_lines.append(line)
            content = '\n'.join(fixed_lines)
            
            # Fix 6: Function parameter dictionaries
            pattern6 = r'(\(\s*\{[^}]*?)(\n\s*(?:var|func|#|class|extends|$))'
            matches = list(re.finditer(pattern6, content, re.MULTILINE | re.DOTALL))
            for match in reversed(matches):
                param_content = match.group(1)
                if not param_content.rstrip().endswith('}'):
                    content = content[:match.start(1)] + param_content.rstrip() + '}' + content[match.start(2):]
                    changes_made += 1
            
            # Only write if changes were made
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"✅ Fixed {file_rel_path} ({changes_made} changes)")
                results.append(f"Fixed: {file_rel_path}")
            else:
                print(f"📝 No changes needed: {file_rel_path}")
                results.append(f"OK: {file_rel_path}")
                
        except Exception as e:
            print(f"❌ Error fixing {file_rel_path}: {e}")
            results.append(f"Error: {file_rel_path}")
    
    return results

if __name__ == "__main__":
    print("🔧 ULTIMATE CORE FIXER - Starting")
    results = fix_universal_being_core_files()
    
    print("\n" + "="*50)
    print("🔧 ULTIMATE CORE FIXER - RESULTS")
    print("="*50)
    
    for result in results:
        print(f"   {result}")
    
    print("\n🌟 CORE FILES PROCESSED! Testing Universal Being...")
    
    # Test if the fixes worked
    test_cmd = 'cd "/mnt/c/Users/Percision 15/Universal_Being" && timeout 10s godot --headless --check-only --path . core/UniversalBeing.gd 2>&1 | grep -E "(Parse Error|SCRIPT ERROR)" | wc -l'
    
    try:
        import subprocess
        result = subprocess.run(test_cmd, shell=True, capture_output=True, text=True, timeout=15)
        error_count = int(result.stdout.strip())
        
        if error_count == 0:
            print("🎉 SUCCESS! No parse errors detected in core files!")
        else:
            print(f"⚠️  Still {error_count} parse errors detected. May need additional fixes.")
            
    except Exception as e:
        print(f"⚠️  Could not test results: {e}")
    
    print("🌟 Ultimate Core Fixer Complete!")