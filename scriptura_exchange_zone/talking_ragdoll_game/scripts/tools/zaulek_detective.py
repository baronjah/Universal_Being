#!/usr/bin/env python3
"""
🕵️ ZAUŁEK DETECTIVE - Dead-End Function Finder
Finds functions that lead nowhere (only pass or print statements)
These are potential connection points for Pentagon Architecture

Author: Captain Claude, Code Surgeon
Created: 2025-06-01
"""

import os
import re
from pathlib import Path
from typing import List, Dict, Tuple

class ZaulekDetective:
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.dead_ends = []
        self.print_only_functions = []
        self.empty_functions = []
        
    def scan_project(self):
        """Scan all GDScript files for dead-end functions"""
        print("🕵️ ZAUŁEK DETECTIVE: Starting investigation...")
        
        for gd_file in self.project_path.rglob("*.gd"):
            if self._should_skip_file(gd_file):
                continue
                
            self._analyze_file(gd_file)
        
        self._print_report()
    
    def _should_skip_file(self, file_path: Path) -> bool:
        """Skip certain directories and files"""
        skip_dirs = {"addons", ".godot", "build"}
        return any(skip_dir in file_path.parts for skip_dir in skip_dirs)
    
    def _analyze_file(self, file_path: Path):
        """Analyze a single GDScript file for dead-end functions"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except (UnicodeDecodeError, FileNotFoundError):
            return
        
        # Find all functions with their content
        function_pattern = r'func\s+(\w+)\s*\([^)]*\)\s*(?:->\s*\w+)?\s*:\s*(.*?)(?=\nfunc|\nclass|\n#|\n"""|\Z)'
        functions = re.findall(function_pattern, content, re.DOTALL | re.MULTILINE)
        
        for func_name, func_body in functions:
            self._analyze_function(file_path, func_name, func_body)
    
    def _analyze_function(self, file_path: Path, func_name: str, func_body: str):
        """Analyze individual function for dead-end patterns"""
        # Clean up the function body
        body = func_body.strip()
        lines = [line.strip() for line in body.split('\n') if line.strip()]
        
        # Remove comments and docstrings
        filtered_lines = []
        for line in lines:
            if not (line.startswith('#') or line.startswith('"""') or line.startswith("'''")):
                filtered_lines.append(line)
        
        if not filtered_lines:
            self.empty_functions.append({
                'file': str(file_path.relative_to(self.project_path)),
                'function': func_name,
                'type': 'completely_empty'
            })
            return
        
        # Check for dead-end patterns
        meaningful_lines = []
        print_lines = []
        
        for line in filtered_lines:
            if line == 'pass':
                continue
            elif line.startswith('print(') or 'print(' in line:
                print_lines.append(line)
            elif not (line.startswith('var ') or line.startswith('await ') or 
                     line.startswith('return') or line.startswith('super.')):
                meaningful_lines.append(line)
        
        # Categorize the function
        relative_path = str(file_path.relative_to(self.project_path))
        
        if not meaningful_lines and not print_lines:
            self.dead_ends.append({
                'file': relative_path,
                'function': func_name,
                'type': 'pass_only',
                'lines': filtered_lines
            })
        elif not meaningful_lines and print_lines:
            self.print_only_functions.append({
                'file': relative_path,
                'function': func_name,
                'type': 'print_only',
                'prints': print_lines,
                'lines': filtered_lines
            })
    
    def _print_report(self):
        """Print the investigation report"""
        print("\n" + "="*80)
        print("🕵️ ZAUŁEK DETECTIVE REPORT - Dead-End Function Analysis")
        print("="*80)
        
        print(f"\n📊 SUMMARY:")
        print(f"  🚫 Pass-only functions: {len(self.dead_ends)}")
        print(f"  🖨️  Print-only functions: {len(self.print_only_functions)}")
        print(f"  📭 Empty functions: {len(self.empty_functions)}")
        print(f"  🎯 Total dead-ends found: {len(self.dead_ends) + len(self.print_only_functions) + len(self.empty_functions)}")
        
        if self.dead_ends:
            print(f"\n🚫 PASS-ONLY FUNCTIONS (Complete dead-ends):")
            for item in sorted(self.dead_ends, key=lambda x: x['file']):
                print(f"  📁 {item['file']}:")
                print(f"    🔴 {item['function']}() - only contains 'pass'")
        
        if self.print_only_functions:
            print(f"\n🖨️ PRINT-ONLY FUNCTIONS (Debug-only implementations):")
            for item in sorted(self.print_only_functions, key=lambda x: x['file']):
                print(f"  📁 {item['file']}:")
                print(f"    🟡 {item['function']}() - only prints:")
                for print_line in item['prints']:
                    print(f"      💬 {print_line}")
        
        if self.empty_functions:
            print(f"\n📭 EMPTY FUNCTIONS:")
            for item in sorted(self.empty_functions, key=lambda x: x['file']):
                print(f"  📁 {item['file']}:")
                print(f"    ⚪ {item['function']}() - completely empty")
        
        print(f"\n🎯 RECOMMENDATIONS:")
        print(f"  1. Review pass-only functions for missing implementations")
        print(f"  2. Consider connecting print-only functions to actual logic")
        print(f"  3. Implement empty functions or remove if unused")
        print(f"  4. Look for patterns to merge similar incomplete functions")
        
        print(f"\n🔗 POTENTIAL CONNECTION POINTS:")
        if self.dead_ends or self.print_only_functions:
            print(f"  These functions might be waiting for Pentagon Architecture integration!")

def main():
    detective = ZaulekDetective("/mnt/c/Users/Percision 15/talking_ragdoll_game")
    detective.scan_project()

if __name__ == "__main__":
    main()