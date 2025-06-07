#!/usr/bin/env python3

import os
import re
import glob

def fix_empty_functions_comprehensive(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except:
        return False
    
    lines = content.split('\n')
    fixed_lines = []
    i = 0
    
    while i < len(lines):
        line = lines[i]
        
        # Check for function definitions
        func_match = re.match(r'^(\s*)(func\s+(\w+)\s*\([^)]*\)(?:\s*->\s*(\w+))?:\s*)$', line)
        if func_match:
            indent = func_match.group(1)
            func_line = func_match.group(2)
            func_name = func_match.group(3)
            return_type = func_match.group(4)
            
            fixed_lines.append(line)
            
            # Look ahead to see if function has content
            j = i + 1
            has_content = False
            
            # Check next few lines for actual function content
            while j < len(lines):
                next_line = lines[j].strip()
                if not next_line or next_line.startswith('#'):
                    j += 1
                    continue
                elif (re.match(r'^func\s+', next_line) or 
                      re.match(r'^class\s+', next_line) or
                      re.match(r'^var\s+', next_line) or
                      re.match(r'^signal\s+', next_line) or
                      re.match(r'^enum\s+', next_line) or
                      re.match(r'^extends\s+', next_line) or
                      re.match(r'^@\w+', next_line)):
                    # Next line is a declaration, function is empty
                    has_content = False
                    break
                else:
                    # Function has content
                    has_content = True
                    break
            
            # Add minimal implementation if function is empty
            if not has_content:
                if return_type:
                    # Function has return type, provide appropriate default return
                    if return_type in ['void']:
                        fixed_lines.append(indent + '\tpass')
                    elif return_type in ['bool']:
                        fixed_lines.append(indent + '\treturn false')
                    elif return_type in ['int', 'float']:
                        fixed_lines.append(indent + '\treturn 0')
                    elif return_type in ['String']:
                        fixed_lines.append(indent + '\treturn ""')
                    elif return_type in ['Dictionary']:
                        fixed_lines.append(indent + '\treturn {}')
                    elif return_type in ['Array']:
                        fixed_lines.append(indent + '\treturn []')
                    elif return_type in ['Vector2']:
                        fixed_lines.append(indent + '\treturn Vector2.ZERO')
                    elif return_type in ['Vector3']:
                        fixed_lines.append(indent + '\treturn Vector3.ZERO')
                    elif return_type in ['Color']:
                        fixed_lines.append(indent + '\treturn Color.WHITE')
                    elif return_type in ['Node']:
                        fixed_lines.append(indent + '\treturn null')
                    else:
                        # Generic return for unknown types
                        fixed_lines.append(indent + '\treturn null')
                else:
                    # Function has no return type
                    fixed_lines.append(indent + '\tpass')
        else:
            fixed_lines.append(line)
        
        i += 1
    
    new_content = '\n'.join(fixed_lines)
    
    if new_content != content:
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            return True
        except:
            pass
    
    return False

# Main execution
if __name__ == "__main__":
    # Focus on critical files first
    critical_files = [
        'autoloads/SystemBootstrap.gd',
        'autoloads/GemmaAI.gd',
        'core/UniversalBeing.gd',
        'beings/ConsciousnessRevolutionSpawner.gd',
        'systems/storage/AkashicRecordsSystem.gd',
        'scripts/GemmaUniversalBeing.gd',
        'systems/state/GameStateSocketManager.gd'
    ]
    
    fixed_files = []
    
    print("Fixing critical files first...")
    for file_path in critical_files:
        if os.path.exists(file_path):
            if fix_empty_functions_comprehensive(file_path):
                fixed_files.append(file_path)
                print(f"  ✅ {file_path}")
    
    print(f"\nFixed {len(fixed_files)} critical files")
    print("Critical syntax fixing complete!")