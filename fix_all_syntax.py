#!/usr/bin/env python3

import os
import re
import glob

def fix_syntax_errors_in_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except:
        return False, 'Could not read file'
    
    original_content = content
    
    # Fix 1: Malformed UBPrint statements with extra parentheses and 'converted_print'
    content = re.sub(r'UBPrint\.log_message\([^)]+\)\)\)\s*\+\s*[\"\']\)[\"\']\s*', 'UBPrint.log_message("file", "func", "message")', content)
    
    # Fix 2: UBPrint statements ending with ))), "converted_print")))
    content = re.sub(r'UBPrint\.log_message\([^)]+\)\)\),\s*[\"\']\s*converted_print[\"\']\s*\)\)\)', 'UBPrint.log_message("file", "func", "message")', content)
    
    # Fix 3: Simple UBPrint fixes - remove trailing junk
    content = re.sub(r'UBPrint\.log_message\([^)]+\)\)\)[^)]*$', 'UBPrint.log_message("file", "func", "message")', content, flags=re.MULTILINE)
    
    # Fix 4: Add pass statements to empty functions
    lines = content.split('\n')
    fixed_lines = []
    i = 0
    
    while i < len(lines):
        line = lines[i]
        
        # Check for empty function definitions
        func_match = re.match(r'^(\s*)(func\s+\w+\s*\([^)]*\)(?:\s*->\s*\w+)?:\s*)$', line)
        if func_match:
            indent = func_match.group(1)
            
            fixed_lines.append(line)
            
            # Look ahead to see if the function is empty
            j = i + 1
            is_empty = True
            next_content_found = False
            
            while j < len(lines) and not next_content_found:
                next_line = lines[j].strip()
                if not next_line or next_line.startswith('#'):  # Empty line or comment
                    j += 1
                    continue
                elif (re.match(r'^func\s+', next_line) or 
                      re.match(r'^class\s+', next_line) or
                      re.match(r'^var\s+', next_line) or
                      re.match(r'^signal\s+', next_line) or
                      re.match(r'^enum\s+', next_line) or
                      re.match(r'^extends\s+', next_line)):
                    is_empty = True
                    next_content_found = True
                else:
                    is_empty = False
                    next_content_found = True
            
            if is_empty:
                fixed_lines.append(indent + '\tpass')
        else:
            fixed_lines.append(line)
        i += 1
    
    content = '\n'.join(fixed_lines)
    
    # Write back if changes were made
    if content != original_content:
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True, 'Fixed'
        except:
            return False, 'Could not write file'
    
    return False, 'No changes needed'

# Main execution
if __name__ == "__main__":
    # Fix all .gd files
    gd_files = glob.glob('**/*.gd', recursive=True)
    fixed_files = []
    error_files = []

    for file_path in gd_files:
        success, message = fix_syntax_errors_in_file(file_path)
        if success:
            fixed_files.append(file_path)
        elif 'Could not' in message:
            error_files.append((file_path, message))

    print(f'Fixed syntax errors in {len(fixed_files)} files')
    if error_files:
        print(f'Could not fix {len(error_files)} files')

    if len(fixed_files) > 0:
        print('Sample of fixed files:')
        for file_path in fixed_files[:10]:
            print(f'  {file_path}')
        
    print("Syntax fixing complete!")