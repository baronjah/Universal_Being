#!/usr/bin/env python3

import os
import re
import glob

def remove_erroneous_pass_statements(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except:
        return False
    
    # Remove 'pass' statements that are followed by actual function content
    lines = content.split('\n')
    fixed_lines = []
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # If this line is just 'pass' (with optional whitespace)
        if re.match(r'^\s*pass\s*$', line):
            # Check if the next non-empty line is not a function/class/var declaration
            # If so, this pass is erroneous and should be removed
            j = i + 1
            should_remove_pass = False
            
            while j < len(lines):
                next_line = lines[j].strip()
                if not next_line or next_line.startswith('#'):
                    j += 1
                    continue
                
                # If next line is NOT a new declaration, then this pass is erroneous
                if not (re.match(r'^func\s+', next_line) or 
                        re.match(r'^class\s+', next_line) or
                        re.match(r'^var\s+', next_line) or
                        re.match(r'^signal\s+', next_line) or
                        re.match(r'^enum\s+', next_line) or
                        re.match(r'^extends\s+', next_line)):
                    should_remove_pass = True
                break
            
            if not should_remove_pass:
                fixed_lines.append(line)
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
    # Fix all .gd files
    gd_files = glob.glob('**/*.gd', recursive=True)
    fixed_files = []

    for file_path in gd_files:
        if remove_erroneous_pass_statements(file_path):
            fixed_files.append(file_path)

    print(f'Removed erroneous pass statements from {len(fixed_files)} files')
    if len(fixed_files) > 0:
        for file_path in fixed_files[:10]:
            print(f'  {file_path}')