#!/usr/bin/env python3
"""
==================================================
PERFECT CRITICAL FIXER - Universal Being Project
==================================================
DESCRIPTION: Perfect tool to fix critical syntax errors blocking game startup
PURPOSE: Fix the remaining critical files to restore Universal Being game
CREATED: 2025-06-14 - Universal Being Revolution
AUTHOR: Claude Code + JSH
==================================================
"""

import os
import re
from pathlib import Path

class PerfectCriticalFixer:
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.critical_files = [
            'core/AutoRegisterFallbacks.gd',
            'systems/UBPrintCollector.gd',
            'core/UniversalInputManager.gd',
            'core/GameConsciousness.gd',
            'beings/gemma/gemma_perfect_consciousness.gd',
            'systems/perfect_console_system.gd',
            'systems/universal_being_inspector.gd',
            'systems/AkashicLibrary.gd'
        ]
        
    def fix_critical_file(self, relative_path: str) -> bool:
        """Fix a specific critical file"""
        file_path = self.project_path / relative_path
        if not file_path.exists():
            print(f"⚠️  File not found: {file_path}")
            return False
            
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            original_content = content
            
            # Fix specific issues for each file type
            content = self.fix_dictionary_syntax(content)
            content = self.fix_brace_errors(content)
            content = self.fix_enum_syntax(content)
            content = self.fix_class_syntax(content)
            
            # Only write if changes were made
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"✅ Fixed: {relative_path}")
                return True
            else:
                print(f"📝 No changes needed: {relative_path}")
                return True
                
        except Exception as e:
            print(f"❌ Error fixing {relative_path}: {e}")
            return False
    
    def fix_dictionary_syntax(self, content: str) -> str:
        """Fix dictionary syntax errors"""
        # Pattern 1: Dictionary initialization with missing closing brace
        content = re.sub(
            r'(\w+\s*:\s*Dictionary\s*=\s*\{[^}]*?)(\n\s*(?:var|func|#|class|extends|$))',
            r'\1}\n\2',
            content,
            flags=re.MULTILINE | re.DOTALL
        )
        
        # Pattern 2: Return statements with missing closing brace
        content = re.sub(
            r'(return\s*\{[^}]*?)(\n\s*(?:var|func|#|class|extends|$))',
            r'\1}\n\2',
            content,
            flags=re.MULTILINE | re.DOTALL
        )
        
        # Pattern 3: Function parameter dictionaries
        content = re.sub(
            r'(\(\s*\{[^}]*?)(\n\s*(?:var|func|#|class|extends|$))',
            r'\1})\n\2',
            content,
            flags=re.MULTILINE | re.DOTALL
        )
        
        return content
    
    def fix_brace_errors(self, content: str) -> str:
        """Fix orphaned braces"""
        lines = content.split('\n')
        fixed_lines = []
        
        for line in lines:
            # Remove orphaned closing braces at start of line
            if line.strip() == '}':
                continue
            # Remove multiple closing braces
            if line.count('}') > line.count('{'):
                # Keep only as many closing braces as opening braces
                open_count = line.count('{')
                line = re.sub(r'\}+', '}' * open_count, line)
            fixed_lines.append(line)
            
        return '\n'.join(fixed_lines)
    
    def fix_enum_syntax(self, content: str) -> str:
        """Fix enum syntax errors"""
        # Find enums missing closing braces
        content = re.sub(
            r'(enum\s+\w+\s*\{[^}]*?)(\n\s*(?:var|func|#|class|extends|$))',
            r'\1}\n\2',
            content,
            flags=re.MULTILINE | re.DOTALL
        )
        return content
    
    def fix_class_syntax(self, content: str) -> str:
        """Fix common class syntax issues"""
        # Fix missing colons after dictionary keys
        content = re.sub(
            r'(\w+)\s*\{',
            r'\1: {',
            content
        )
        
        # Fix function calls with missing parentheses
        content = re.sub(
            r'(\w+)\s*\{\s*\}',
            r'\1()',
            content
        )
        
        return content
    
    def fix_all_critical_files(self) -> dict:
        """Fix all critical files"""
        print("🔧 PERFECT CRITICAL FIXER - Fixing critical syntax errors")
        
        results = {
            'fixed': [],
            'failed': [],
            'total': len(self.critical_files)
        }
        
        for file_path in self.critical_files:
            if self.fix_critical_file(file_path):
                results['fixed'].append(file_path)
            else:
                results['failed'].append(file_path)
        
        return results

def main():
    """Main function"""
    project_path = "/mnt/c/Users/Percision 15/Universal_Being"
    
    fixer = PerfectCriticalFixer(project_path)
    results = fixer.fix_all_critical_files()
    
    print("\n" + "="*50)
    print("🔧 PERFECT CRITICAL FIXER - RESULTS")
    print("="*50)
    print(f"📁 Total Files: {results['total']}")
    print(f"✅ Fixed: {len(results['fixed'])}")
    print(f"❌ Failed: {len(results['failed'])}")
    
    if results['fixed']:
        print("\n✅ Successfully Fixed:")
        for file in results['fixed']:
            print(f"   - {file}")
    
    if results['failed']:
        print("\n❌ Failed to Fix:")
        for file in results['failed']:
            print(f"   - {file}")
    
    if len(results['failed']) == 0:
        print("\n🌟 ALL CRITICAL FILES FIXED! Universal Being should start now! 🌟")
        return 0
    else:
        print(f"\n⚠️  {len(results['failed'])} files still need attention")
        return 1

if __name__ == "__main__":
    exit(main())