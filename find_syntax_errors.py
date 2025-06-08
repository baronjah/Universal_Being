#!/usr/bin/env python3
"""Find syntax errors in GDScript files"""

import os
import re
import glob

def find_syntax_errors():
    base_dir = "/mnt/c/Users/Percision 15/Universal_being"
    error_patterns = [
        (r'UBPrint\.log_message\([^)]+\)\s*->\s*(?:void|bool|int|float|String|Dictionary|Array):', 'Malformed UBPrint with function definition'),
        (r'print\([^)]+\)\s*->\s*(?:void|bool|int|float|String|Dictionary|Array):', 'Malformed print with function definition'),
        (r'", "converted_print"\)\s*->\s*(?:void|bool|int|float|String|Dictionary|Array):', 'Malformed converted_print with function definition'),
        (r'UBPrint\.log_message.*\)\)$', 'Double closing parenthesis in UBPrint'),
        (r'UBPrint\.log_message.*\)\)[^)]', 'Malformed UBPrint ending'),
    ]
    
    files_to_check = [
        "core/UniversalBeing.gd",
        "beings/cursor/CursorUniversalBeing.gd",
        "beings/player/player_universal_being.gd",
        "systems/storage/AkashicRecordsSystem.gd",
        "autoloads/SystemBootstrap.gd",
        "autoloads/GemmaAI.gd"
    ]
    
    for file_path in files_to_check:
        full_path = os.path.join(base_dir, file_path)
        if not os.path.exists(full_path):
            print(f"File not found: {file_path}")
            continue
            
        with open(full_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            
        print(f"\nChecking {file_path}:")
        for i, line in enumerate(lines, 1):
            for pattern, description in error_patterns:
                if re.search(pattern, line):
                    print(f"  Line {i}: {description}")
                    print(f"    {line.strip()}")

if __name__ == "__main__":
    find_syntax_errors()