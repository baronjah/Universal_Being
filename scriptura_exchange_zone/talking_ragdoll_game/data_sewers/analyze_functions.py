#!/usr/bin/env python3
"""
Comprehensive Function Analysis for Talking Ragdoll Game
Scans all GDScript files and creates detailed function documentation.
"""

import os
import re
import json
from pathlib import Path
from collections import defaultdict

def analyze_gdscript_file(file_path):
    """Analyze a single GDScript file and extract function information."""
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    lines = content.split('\n')
    functions = []
    current_function = None
    in_function = False
    indent_level = 0
    
    for i, line in enumerate(lines):
        line_num = i + 1
        stripped = line.strip()
        
        # Skip empty lines and comments
        if not stripped or stripped.startswith('#'):
            continue
            
        # Check for function definition
        func_match = re.match(r'^(\s*)func\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\((.*?)\)\s*(?:->\s*([^:]+))?\s*:', line)
        if func_match:
            if current_function:
                functions.append(current_function)
            
            indent_level = len(func_match.group(1))
            func_name = func_match.group(2)
            params = func_match.group(3)
            return_type = func_match.group(4)
            
            current_function = {
                'name': func_name,
                'line_start': line_num,
                'parameters': params.strip() if params else '',
                'return_type': return_type.strip() if return_type else 'void',
                'line_count': 0,
                'description': '',
                'calls': [],
                'signals': [],
                'variables': []
            }
            in_function = True
            continue
        
        # If we're in a function, count lines and analyze content
        if in_function and current_function:
            # Check if we've exited the function (less indentation)
            if stripped and len(line) - len(line.lstrip()) <= indent_level:
                # We've exited the function
                current_function['line_count'] = line_num - current_function['line_start']
                functions.append(current_function)
                current_function = None
                in_function = False
                continue
            
            # Look for function calls
            call_matches = re.findall(r'([a-zA-Z_][a-zA-Z0-9_]*)\s*\(', line)
            for call in call_matches:
                if call not in ['if', 'while', 'for', 'match', 'func', 'class']:
                    current_function['calls'].append(call)
            
            # Look for signal emissions
            signal_matches = re.findall(r'emit_signal\s*\(\s*["\']([^"\']+)["\']', line)
            current_function['signals'].extend(signal_matches)
            
            # Look for variable declarations
            var_matches = re.findall(r'var\s+([a-zA-Z_][a-zA-Z0-9_]*)', line)
            current_function['variables'].extend(var_matches)
    
    # Handle last function if file ends while in function
    if current_function:
        current_function['line_count'] = len(lines) - current_function['line_start'] + 1
        functions.append(current_function)
    
    return functions

def categorize_script(file_path):
    """Categorize a script based on its path and content."""
    path_parts = Path(file_path).parts
    
    # Check path-based categories
    if 'autoload' in path_parts:
        return 'Core Systems - Autoload'
    elif 'ui' in path_parts:
        return 'Interface Systems'
    elif 'core' in path_parts:
        return 'Core Systems'
    elif 'debug' in path_parts:
        return 'Debug & Testing'
    elif 'patches' in path_parts:
        return 'Patches & Fixes'
    elif 'ragdoll' in path_parts or 'ragdoll_v2' in path_parts:
        return 'Ragdoll Systems'
    elif 'jsh_framework' in path_parts:
        return 'JSH Framework'
    elif 'test' in path_parts:
        return 'Testing Systems'
    elif 'tutorial' in path_parts:
        return 'Tutorial Systems'
    elif 'passive_mode' in path_parts:
        return 'Passive Mode Systems'
    elif 'effects' in path_parts:
        return 'Visual Effects'
    elif 'tools' in path_parts:
        return 'Development Tools'
    elif 'components' in path_parts:
        return 'Component Systems'
    elif 'old_implementations' in path_parts:
        return 'Deprecated/Archive'
    elif 'copy_ragdoll_all_files' in path_parts:
        return 'Ragdoll Archive'
    else:
        return 'Utility Scripts'

def analyze_all_scripts():
    """Analyze all GDScript files in the project."""
    base_path = "/mnt/c/Users/Percision 15/talking_ragdoll_game"
    
    all_scripts = []
    categories = defaultdict(list)
    function_map = {}
    cross_references = defaultdict(list)
    
    # Find all .gd files
    for root, dirs, files in os.walk(base_path):
        for file in files:
            if file.endswith('.gd'):
                file_path = os.path.join(root, file)
                rel_path = os.path.relpath(file_path, base_path)
                
                print(f"Analyzing: {rel_path}")
                
                try:
                    functions = analyze_gdscript_file(file_path)
                    category = categorize_script(file_path)
                    
                    script_info = {
                        'file_path': rel_path,
                        'absolute_path': file_path,
                        'category': category,
                        'functions': functions,
                        'function_count': len(functions)
                    }
                    
                    all_scripts.append(script_info)
                    categories[category].append(script_info)
                    
                    # Build function map
                    for func in functions:
                        func_key = f"{rel_path}::{func['name']}"
                        function_map[func_key] = {
                            'file': rel_path,
                            'function': func,
                            'category': category
                        }
                        
                        # Build cross-references
                        for call in func['calls']:
                            cross_references[call].append(func_key)
                
                except Exception as e:
                    print(f"Error analyzing {rel_path}: {e}")
    
    return {
        'scripts': all_scripts,
        'categories': dict(categories),
        'function_map': function_map,
        'cross_references': dict(cross_references),
        'total_scripts': len(all_scripts),
        'total_functions': sum(len(script['functions']) for script in all_scripts)
    }

def generate_documentation(analysis_data):
    """Generate comprehensive documentation files."""
    
    # 1. Function Map Documentation
    function_doc = "# COMPLETE FUNCTION MAP\n\n"
    function_doc += f"Total Scripts: {analysis_data['total_scripts']}\n"
    function_doc += f"Total Functions: {analysis_data['total_functions']}\n\n"
    
    for script in sorted(analysis_data['scripts'], key=lambda x: x['file_path']):
        if script['functions']:
            function_doc += f"## {script['file_path']}\n"
            function_doc += f"**Category:** {script['category']}\n"
            function_doc += f"**Functions:** {script['function_count']}\n\n"
            
            for func in script['functions']:
                function_doc += f"### `{func['name']}()`\n"
                function_doc += f"- **Lines:** {func['line_count']}\n"
                function_doc += f"- **Parameters:** `{func['parameters']}`\n"
                function_doc += f"- **Returns:** `{func['return_type']}`\n"
                if func['calls']:
                    function_doc += f"- **Calls:** {', '.join(set(func['calls']))}\n"
                if func['signals']:
                    function_doc += f"- **Signals:** {', '.join(set(func['signals']))}\n"
                function_doc += "\n"
            function_doc += "\n"
    
    # 2. Category Documentation
    category_doc = "# SCRIPT CATEGORIES\n\n"
    for category, scripts in sorted(analysis_data['categories'].items()):
        category_doc += f"## {category}\n"
        category_doc += f"**Script Count:** {len(scripts)}\n\n"
        
        for script in sorted(scripts, key=lambda x: x['file_path']):
            category_doc += f"- **{script['file_path']}** ({script['function_count']} functions)\n"
        category_doc += "\n"
    
    # 3. Cross-Reference Documentation
    cross_ref_doc = "# FUNCTION CROSS-REFERENCES\n\n"
    for func_name, callers in sorted(analysis_data['cross_references'].items()):
        if len(callers) > 1:  # Only show functions called from multiple places
            cross_ref_doc += f"## `{func_name}()`\n"
            cross_ref_doc += f"**Called by {len(callers)} functions:**\n"
            for caller in sorted(callers):
                cross_ref_doc += f"- {caller}\n"
            cross_ref_doc += "\n"
    
    # 4. Master Documentation Hub
    master_doc = "# TALKING RAGDOLL GAME - DOCUMENTATION HUB\n\n"
    master_doc += "## Quick Navigation\n\n"
    master_doc += "- [Complete Function Map](FUNCTION_MAP.md)\n"
    master_doc += "- [Script Categories](SCRIPT_CATEGORIES.md)\n"
    master_doc += "- [Cross-References](CROSS_REFERENCES.md)\n\n"
    
    master_doc += "## Project Overview\n\n"
    master_doc += f"- **Total Scripts:** {analysis_data['total_scripts']}\n"
    master_doc += f"- **Total Functions:** {analysis_data['total_functions']}\n\n"
    
    master_doc += "## System Categories Summary\n\n"
    for category, scripts in sorted(analysis_data['categories'].items()):
        total_funcs = sum(script['function_count'] for script in scripts)
        master_doc += f"- **{category}:** {len(scripts)} scripts, {total_funcs} functions\n"
    
    master_doc += "\n## Core Systems Quick Access\n\n"
    core_systems = ['universal_being.gd', 'floodgate_controller.gd', 'console_manager.gd', 'asset_library.gd']
    for system in core_systems:
        for script in analysis_data['scripts']:
            if system in script['file_path']:
                master_doc += f"- **{system}:** {script['function_count']} functions\n"
                break
    
    return {
        'FUNCTION_MAP.md': function_doc,
        'SCRIPT_CATEGORIES.md': category_doc,
        'CROSS_REFERENCES.md': cross_ref_doc,
        'DOCUMENTATION_HUB.md': master_doc
    }

if __name__ == "__main__":
    print("Starting comprehensive function analysis...")
    analysis_data = analyze_all_scripts()
    
    print("Generating documentation...")
    docs = generate_documentation(analysis_data)
    
    # Save documentation files
    base_path = "/mnt/c/Users/Percision 15/talking_ragdoll_game"
    for filename, content in docs.items():
        file_path = os.path.join(base_path, filename)
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Created: {filename}")
    
    # Save raw analysis data as JSON
    json_path = os.path.join(base_path, "function_analysis.json")
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(analysis_data, f, indent=2)
    print(f"Created: function_analysis.json")
    
    print("\nDocumentation generation complete!")
    print(f"Total scripts analyzed: {analysis_data['total_scripts']}")
    print(f"Total functions found: {analysis_data['total_functions']}")