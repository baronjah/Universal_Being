#!/usr/bin/env python3
"""
PERFECT PENTAGON VIOLATION FIXER
================================
Automatically fixes the 9 critical violations found by the auditor

Violations to fix:
1. Multiple _init() functions
2. Multiple _ready() functions  
3. Multiple _process() functions
4. Multiple _input() functions

Strategy: Combine multiple functions into single functions with proper phase separation
"""

import re
import os
from pathlib import Path

class ViolationFixer:
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        
    def fix_multiple_functions(self, file_path: str, function_type: str):
        """Fix multiple functions of the same type in a file"""
        
        full_path = self.project_root / file_path
        print(f"🔧 Fixing {function_type} violations in: {file_path}")
        
        # Read file
        with open(full_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Find all functions of this type
        pattern = rf'func\s+{function_type}\s*\([^)]*\):[^:]*?(?=\nfunc|\n#|\nclass|\nstatic|\n@|\Z)'
        matches = list(re.finditer(pattern, content, re.DOTALL | re.MULTILINE))
        
        if len(matches) <= 1:
            print(f"   ✅ No multiple {function_type} functions found")
            return
        
        print(f"   🔍 Found {len(matches)} {function_type} functions")
        
        # Extract function bodies
        function_bodies = []
        for i, match in enumerate(matches):
            func_content = match.group(0)
            # Extract just the body (everything after the function declaration)
            body_start = func_content.find(':') + 1
            body = func_content[body_start:].strip()
            if body:
                function_bodies.append(f"    # {function_type.upper()} PHASE {i+1}")
                function_bodies.append(f"    {body}")
        
        # Create unified function
        unified_function = f"func {function_type}():\n"
        unified_function += f'    """\n    Unified {function_type} function - Perfect Pentagon Architecture\n    """\n'
        unified_function += "\n".join(function_bodies)
        
        # Remove old functions from content
        for match in reversed(matches):  # Remove in reverse order to maintain indices
            content = content[:match.start()] + content[match.end():]
        
        # Add unified function at the end of the class
        # Find the best place to insert (after class declaration, before first function)
        insert_pos = len(content)
        class_match = re.search(r'class_name\s+\w+|extends\s+\w+', content)
        if class_match:
            # Find the first function after the class declaration
            func_match = re.search(r'\nfunc\s+', content[class_match.end():])
            if func_match:
                insert_pos = class_match.end() + func_match.start()
        
        # Insert the unified function
        content = content[:insert_pos] + "\n\n" + unified_function + "\n" + content[insert_pos:]
        
        # Write back to file
        with open(full_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"   ✅ Fixed: Combined {len(matches)} functions into 1 unified {function_type}")
    
    def fix_all_violations(self):
        """Fix all known violations from the audit report"""
        
        violations = [
            ("scripts/ragdoll/unified_biomechanical_walker.gd", "_init"),
            ("scripts/test/automated_warning_fixer.gd", "_process"),
            ("scripts/test/batch_parameter_fixer.gd", "_process"),
            ("scripts/test/run_warning_fixes.gd", "_process"),
            ("scripts/tools/script_migration_helper.gd", "_ready"),
            ("scripts/tools/script_migration_helper.gd", "_process"),
        ]
        
        print("🎯 PERFECT PENTAGON VIOLATION FIXER")
        print("=" * 50)
        
        fixed_files = set()
        
        for file_path, func_type in violations:
            try:
                self.fix_multiple_functions(file_path, func_type)
                fixed_files.add(file_path)
            except Exception as e:
                print(f"   ❌ Error fixing {file_path}: {e}")
        
        print(f"\n✅ FIXED {len(fixed_files)} FILES:")
        for file_path in sorted(fixed_files):
            print(f"   📁 {file_path}")
        
        print(f"\n🎮 PENTAGON COMPLIANCE IMPROVED!")
        print("   Run the auditor again to verify fixes")

def main():
    project_root = "/mnt/c/Users/Percision 15/talking_ragdoll_game"
    fixer = ViolationFixer(project_root)
    fixer.fix_all_violations()

if __name__ == "__main__":
    main()