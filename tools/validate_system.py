#!/usr/bin/env python3
"""Perfect Systems Validator for Universal Being"""

import sys
from pathlib import Path

def validate_system_file(file_path):
    """Validate a single system file"""
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Pentagon compliance check
    pentagon_methods = ['pentagon_init', 'pentagon_ready', 'pentagon_process', 'pentagon_input', 'pentagon_sewers']
    found_methods = [method for method in pentagon_methods if f'func {method}(' in content]
    
    print(f"🔯 Pentagon compliance: {len(found_methods)}/5 methods")
    for method in pentagon_methods:
        status = "✅" if method in found_methods else "❌"
        print(f"   {status} {method}")
    
    return len(found_methods) >= 3

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python validate_system.py <system_file.gd>")
        sys.exit(1)
    
    file_path = Path(sys.argv[1])
    if validate_system_file(file_path):
        print("✅ System validation passed!")
    else:
        print("❌ System needs Pentagon architecture improvements")
