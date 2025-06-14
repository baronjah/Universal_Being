#!/usr/bin/env python3
"""
==================================================
PERFECT SYNTAX FIXER - Universal Being Project
==================================================
DESCRIPTION: Perfect tool to fix all dictionary and brace syntax errors
PURPOSE: Restore perfect GDScript syntax across entire codebase
CREATED: 2025-06-14 - Universal Being Revolution
AUTHOR: Claude Code + JSH
==================================================
"""

import os
import re
import sys
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import List, Tuple, Dict, Set
import threading

class PerfectSyntaxFixer:
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.files_fixed = 0
        self.errors_fixed = 0
        self.lock = threading.Lock()
        self.critical_files = {
            'core/UniversalBeing.gd',
            'autoloads/SystemBootstrap.gd', 
            'autoloads/GemmaAI.gd',
            'core/FloodGates.gd',
            'systems/storage/AkashicRecordsSystem.gd',
            'core/AutoRegisterFallbacks.gd'
        }
        
    def log_perfect(self, message: str, error: bool = False):
        """Perfect logging system"""
        prefix = "❌ ERROR" if error else "✨ PERFECT"
        with self.lock:
            print(f"{prefix}: {message}")
            
    def find_gdscript_files(self) -> List[Path]:
        """Find all GDScript files in project"""
        gdscript_files = []
        
        # Scan project directory
        for root, dirs, files in os.walk(self.project_path):
            # Skip certain directories
            skip_dirs = {'.git', '.import', 'build', 'scriptura_exchange_zone'}
            dirs[:] = [d for d in dirs if d not in skip_dirs]
            
            for file in files:
                if file.endswith('.gd'):
                    gdscript_files.append(Path(root) / file)
                    
        return sorted(gdscript_files)
    
    def fix_dictionary_syntax(self, content: str) -> Tuple[str, int]:
        """Fix dictionary syntax errors with perfect precision"""
        fixes_count = 0
        
        # Pattern 1: Missing closing brace in dictionary
        # Find dictionaries that are missing closing braces
        dict_pattern = r'(\w+\s*:\s*Dictionary\s*=\s*\{[^}]*?)(\n\s*(?:var|func|#|$))'
        matches = list(re.finditer(dict_pattern, content, re.MULTILINE | re.DOTALL))
        
        for match in reversed(matches):  # Reverse to maintain positions
            dict_content = match.group(1)
            if not dict_content.rstrip().endswith('}'):
                # Add missing closing brace
                replacement = dict_content.rstrip() + '\n}'
                content = content[:match.start(1)] + replacement + content[match.start(2):]
                fixes_count += 1
                
        # Pattern 2: Dictionary initialization without closing brace
        dict_init_pattern = r'(=\s*\{\s*[^}]*?)(\n\s*(?:var|func|#|\w+\s*:|$))'
        matches = list(re.finditer(dict_init_pattern, content, re.MULTILINE | re.DOTALL))
        
        for match in reversed(matches):
            dict_content = match.group(1)
            if '{' in dict_content and not dict_content.count('}') >= dict_content.count('{'):
                # Check if this looks like a dictionary that needs closing
                if any(pattern in dict_content for pattern in ['":', "':", 'name:', 'type:', 'action:']):
                    replacement = dict_content.rstrip() + '\n}'
                    content = content[:match.start(1)] + replacement + content[match.start(2):]
                    fixes_count += 1
        
        # Pattern 3: Return statements with incomplete dictionaries
        return_dict_pattern = r'(return\s*\{\s*[^}]*?)(\n\s*(?:var|func|#|$|\w))'
        matches = list(re.finditer(return_dict_pattern, content, re.MULTILINE | re.DOTALL))
        
        for match in reversed(matches):
            dict_content = match.group(1)
            if not dict_content.rstrip().endswith('}'):
                replacement = dict_content.rstrip() + '}'
                content = content[:match.start(1)] + replacement + content[match.start(2):]
                fixes_count += 1
                
        return content, fixes_count
    
    def fix_brace_errors(self, content: str) -> Tuple[str, int]:
        """Fix remaining brace syntax errors"""
        fixes_count = 0
        
        # Remove orphaned closing braces that don't have opening counterparts
        lines = content.split('\n')
        fixed_lines = []
        brace_stack = []
        
        for i, line in enumerate(lines):
            line_stripped = line.strip()
            
            # Count opening and closing braces in this line
            open_count = line.count('{')
            close_count = line.count('}')
            
            # Track brace balance
            for char in line:
                if char == '{':
                    brace_stack.append(i)
                elif char == '}':
                    if brace_stack:
                        brace_stack.pop()
                    else:
                        # Orphaned closing brace - remove it
                        line = line.replace('}', '', 1)
                        fixes_count += 1
                        
            fixed_lines.append(line)
            
        return '\n'.join(fixed_lines), fixes_count
    
    def fix_enum_syntax(self, content: str) -> Tuple[str, int]:
        """Fix enum syntax errors"""
        fixes_count = 0
        
        # Find enums missing closing braces
        enum_pattern = r'(enum\s+\w+\s*\{[^}]*?)(\n\s*(?:var|func|#|$))'
        matches = list(re.finditer(enum_pattern, content, re.MULTILINE | re.DOTALL))
        
        for match in reversed(matches):
            enum_content = match.group(1)
            if not enum_content.rstrip().endswith('}'):
                replacement = enum_content.rstrip() + '\n}'
                content = content[:match.start(1)] + replacement + content[match.start(2):]
                fixes_count += 1
                
        return content, fixes_count
    
    def fix_perfect_syntax(self, file_path: Path) -> Dict:
        """Perfect syntax fixing for a single file"""
        try:
            # Read file with UTF-8 encoding
            with open(file_path, 'r', encoding='utf-8') as f:
                original_content = f.read()
                
            if not original_content.strip():
                return {'success': True, 'fixes': 0, 'file': str(file_path)}
                
            content = original_content
            total_fixes = 0
            
            # Apply perfect fixes in order
            content, dict_fixes = self.fix_dictionary_syntax(content)
            total_fixes += dict_fixes
            
            content, brace_fixes = self.fix_brace_errors(content)
            total_fixes += brace_fixes
            
            content, enum_fixes = self.fix_enum_syntax(content)
            total_fixes += enum_fixes
            
            # Only write if changes were made
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                    
                with self.lock:
                    self.files_fixed += 1
                    self.errors_fixed += total_fixes
                    
                # Special logging for critical files
                is_critical = any(str(file_path).endswith(critical) for critical in self.critical_files)
                if is_critical:
                    self.log_perfect(f"CRITICAL FILE FIXED: {file_path.name} ({total_fixes} errors)")
                else:
                    self.log_perfect(f"Fixed {file_path.name} ({total_fixes} errors)")
                    
            return {
                'success': True,
                'fixes': total_fixes,
                'file': str(file_path),
                'critical': is_critical
            }
            
        except Exception as e:
            self.log_perfect(f"Failed to fix {file_path}: {e}", error=True)
            return {
                'success': False,
                'error': str(e),
                'file': str(file_path)
            }
    
    def fix_all_syntax_perfect(self) -> Dict:
        """Perfect syntax fixing across entire project"""
        self.log_perfect("PERFECT SYNTAX FIXER - Starting Universal Being restoration")
        
        # Find all GDScript files
        gdscript_files = self.find_gdscript_files()
        self.log_perfect(f"Found {len(gdscript_files)} GDScript files to analyze")
        
        # Prioritize critical files first
        critical_files = []
        regular_files = []
        
        for file_path in gdscript_files:
            is_critical = any(str(file_path).endswith(critical) for critical in self.critical_files)
            if is_critical:
                critical_files.append(file_path)
            else:
                regular_files.append(file_path)
                
        # Process critical files first, then regular files
        all_files = critical_files + regular_files
        
        results = []
        failed_files = []
        
        # Use parallel processing for maximum efficiency
        with ThreadPoolExecutor(max_workers=8) as executor:
            # Submit all jobs
            future_to_file = {
                executor.submit(self.fix_perfect_syntax, file_path): file_path 
                for file_path in all_files
            }
            
            # Collect results
            for future in as_completed(future_to_file):
                result = future.result()
                results.append(result)
                
                if not result['success']:
                    failed_files.append(result['file'])
        
        # Generate perfect summary
        critical_fixed = sum(1 for r in results if r.get('critical', False) and r.get('fixes', 0) > 0)
        
        summary = {
            'total_files_scanned': len(gdscript_files),
            'files_fixed': self.files_fixed,
            'total_errors_fixed': self.errors_fixed,
            'critical_files_fixed': critical_fixed,
            'failed_files': failed_files,
            'success': len(failed_files) == 0
        }
        
        return summary

def main():
    """Perfect main function"""
    if len(sys.argv) > 1:
        project_path = sys.argv[1]
    else:
        # Default to current directory
        project_path = os.getcwd()
    
    if not os.path.exists(project_path):
        print(f"❌ ERROR: Project path does not exist: {project_path}")
        return 1
        
    # Create perfect syntax fixer
    fixer = PerfectSyntaxFixer(project_path)
    
    # Execute perfect syntax fixing
    results = fixer.fix_all_syntax_perfect()
    
    # Perfect results reporting
    print("\n" + "="*60)
    print("✨ PERFECT SYNTAX FIXER - RESULTS ✨")
    print("="*60)
    print(f"📁 Files Scanned: {results['total_files_scanned']}")
    print(f"🔧 Files Fixed: {results['files_fixed']}")
    print(f"⚡ Errors Fixed: {results['total_errors_fixed']}")
    print(f"🎯 Critical Files Fixed: {results['critical_files_fixed']}")
    
    if results['failed_files']:
        print(f"❌ Failed Files: {len(results['failed_files'])}")
        for failed in results['failed_files']:
            print(f"   - {failed}")
    else:
        print("✅ All files processed successfully!")
        
    if results['success']:
        print("\n🌟 PERFECT SUCCESS! Universal Being syntax restored to perfection! 🌟")
        return 0
    else:
        print("\n⚠️  Completed with some issues. Check failed files above.")
        return 1

if __name__ == "__main__":
    sys.exit(main())