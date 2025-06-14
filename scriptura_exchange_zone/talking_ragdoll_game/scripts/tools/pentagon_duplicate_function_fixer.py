#!/usr/bin/env python3
"""
Pentagon Duplicate Function Fixer
=================================

Purpose: Fix duplicate Pentagon function declarations created by auto-migration tools
Pattern: Removes empty duplicate functions while preserving implementations
Safety: Test-first approach with backup capabilities

Created: June 1, 2025
Author: Claude (Pentagon Architecture Team)
"""

import os
import re
import shutil
from typing import List, Dict, Tuple
from pathlib import Path

class PentagonDuplicateFixer:
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.backup_dir = self.project_root / "backups" / "pentagon_duplicate_fix"
        self.pentagon_functions = [
            "pentagon_init",
            "pentagon_ready", 
            "pentagon_process",
            "pentagon_input",
            "pentagon_sewers"
        ]
        self.test_files = []
        self.fixed_files = []
        self.stats = {
            "files_scanned": 0,
            "files_with_duplicates": 0,
            "duplicates_removed": 0,
            "errors": []
        }

    def create_backup_dir(self):
        """Create backup directory for safety"""
        self.backup_dir.mkdir(parents=True, exist_ok=True)
        print(f"📁 Backup directory: {self.backup_dir}")

    def find_all_gd_files(self) -> List[Path]:
        """Find all .gd files in the project"""
        gd_files = []
        for root, dirs, files in os.walk(self.project_root):
            # Skip backup directories
            if "backup" in root.lower():
                continue
            for file in files:
                if file.endswith('.gd'):
                    gd_files.append(Path(root) / file)
        return gd_files

    def analyze_file_for_duplicates(self, file_path: Path) -> Dict[str, List[Tuple[int, str]]]:
        """
        Analyze a file for duplicate Pentagon functions
        Returns: Dict[function_name, List[Tuple[line_number, function_content]]]
        """
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            duplicates = {}
            lines = content.split('\n')
            
            for func_name in self.pentagon_functions:
                # Find all occurrences of this function
                pattern = rf'^func {func_name}\([^)]*\).*?:'
                matches = []
                
                for i, line in enumerate(lines):
                    if re.match(pattern, line.strip()):
                        # Extract the function content until next function or end
                        func_content = self._extract_function_content(lines, i)
                        matches.append((i + 1, func_content))  # 1-based line numbers
                
                if len(matches) > 1:
                    duplicates[func_name] = matches
                    
            return duplicates
            
        except Exception as e:
            self.stats["errors"].append(f"Error analyzing {file_path}: {str(e)}")
            return {}

    def _extract_function_content(self, lines: List[str], start_line: int) -> str:
        """Extract function content from start_line until next function or class end"""
        content_lines = [lines[start_line]]  # Include the function declaration
        i = start_line + 1
        
        while i < len(lines):
            line = lines[i]
            stripped = line.strip()
            
            # Stop at next function, class, or significant dedent
            if (stripped.startswith('func ') or 
                stripped.startswith('class ') or
                stripped.startswith('enum ') or
                stripped.startswith('signal ') or
                (stripped and not line.startswith('\t') and not line.startswith(' ') and i > start_line + 1)):
                break
                
            content_lines.append(line)
            i += 1
            
            # Safety: don't extract more than 50 lines per function
            if len(content_lines) > 50:
                break
                
        return '\n'.join(content_lines)

    def identify_duplicate_to_remove(self, duplicates: List[Tuple[int, str]]) -> int:
        """
        Identify which duplicate to remove (keep the one with implementation)
        Returns: line number of duplicate to remove, or -1 if unsure
        """
        if len(duplicates) != 2:
            return -1  # Only handle exactly 2 duplicates for safety
        
        first_line, first_content = duplicates[0]
        second_line, second_content = duplicates[1]
        
        # Check which one has just "pass" or is empty
        first_is_empty = self._is_empty_function(first_content)
        second_is_empty = self._is_empty_function(second_content)
        
        if first_is_empty and not second_is_empty:
            return first_line  # Remove first, keep second
        elif second_is_empty and not first_is_empty:
            return second_line  # Remove second, keep first
        else:
            # Both have content or both are empty - don't auto-fix
            return -1

    def _is_empty_function(self, func_content: str) -> bool:
        """Check if function content is essentially empty (just pass or comments)"""
        lines = func_content.split('\n')[1:]  # Skip function declaration
        non_empty_lines = []
        
        for line in lines:
            stripped = line.strip()
            if stripped and not stripped.startswith('#') and stripped != 'pass':
                non_empty_lines.append(stripped)
        
        return len(non_empty_lines) == 0

    def fix_file_duplicates(self, file_path: Path, duplicates: Dict[str, List[Tuple[int, str]]]) -> bool:
        """
        Fix duplicates in a single file
        Returns: True if file was modified, False otherwise
        """
        try:
            # Create backup
            backup_path = self.backup_dir / file_path.name
            shutil.copy2(file_path, backup_path)
            
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            lines_to_remove = set()
            fixes_made = 0
            
            for func_name, func_duplicates in duplicates.items():
                line_to_remove = self.identify_duplicate_to_remove(func_duplicates)
                if line_to_remove > 0:
                    # Find the range of lines to remove for this function
                    start_line = line_to_remove - 1  # Convert to 0-based
                    func_content = None
                    
                    # Find the matching function content
                    for line_num, content in func_duplicates:
                        if line_num == line_to_remove:
                            func_content = content
                            break
                    
                    if func_content:
                        # Mark all lines of this function for removal
                        func_lines = func_content.split('\n')
                        for i in range(len(func_lines)):
                            if start_line + i < len(lines):
                                lines_to_remove.add(start_line + i)
                        fixes_made += 1
                        print(f"  🔧 Removing duplicate {func_name} at line {line_to_remove}")
            
            if fixes_made > 0:
                # Remove marked lines
                new_lines = [line for i, line in enumerate(lines) if i not in lines_to_remove]
                
                # Write fixed content
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.writelines(new_lines)
                
                self.stats["duplicates_removed"] += fixes_made
                return True
                
            return False
            
        except Exception as e:
            self.stats["errors"].append(f"Error fixing {file_path}: {str(e)}")
            return False

    def scan_for_duplicates(self, test_mode: bool = True) -> Dict[str, Dict[str, List[Tuple[int, str]]]]:
        """
        Scan all files for duplicates
        Returns: Dict[file_path, Dict[function_name, List[duplicates]]]
        """
        print("🔍 Scanning for Pentagon function duplicates...")
        
        all_files = self.find_all_gd_files()
        files_with_duplicates = {}
        
        # In test mode, only check first 5 files
        files_to_check = all_files[:5] if test_mode else all_files
        
        for file_path in files_to_check:
            self.stats["files_scanned"] += 1
            duplicates = self.analyze_file_for_duplicates(file_path)
            
            if duplicates:
                files_with_duplicates[str(file_path)] = duplicates
                self.stats["files_with_duplicates"] += 1
                print(f"📄 Found duplicates in: {file_path.name}")
                for func_name, dups in duplicates.items():
                    print(f"  - {func_name}: {len(dups)} occurrences")
        
        return files_with_duplicates

    def fix_duplicates(self, files_with_duplicates: Dict[str, Dict], test_mode: bool = True):
        """Fix duplicates in the identified files"""
        if not files_with_duplicates:
            print("✅ No duplicates found to fix!")
            return
            
        print(f"\n🛠️ Fixing duplicates in {len(files_with_duplicates)} files...")
        
        for file_path_str, duplicates in files_with_duplicates.items():
            file_path = Path(file_path_str)
            print(f"\n📝 Processing: {file_path.name}")
            
            if self.fix_file_duplicates(file_path, duplicates):
                self.fixed_files.append(str(file_path))
                print(f"  ✅ Fixed duplicates in {file_path.name}")
            else:
                print(f"  ⚠️ No automatic fixes applied to {file_path.name}")

    def print_summary(self):
        """Print operation summary"""
        print(f"\n{'='*50}")
        print("🎯 PENTAGON DUPLICATE FIXER SUMMARY")
        print(f"{'='*50}")
        print(f"📊 Files scanned: {self.stats['files_scanned']}")
        print(f"🔍 Files with duplicates: {self.stats['files_with_duplicates']}")
        print(f"🔧 Duplicates removed: {self.stats['duplicates_removed']}")
        print(f"📁 Files fixed: {len(self.fixed_files)}")
        
        if self.stats["errors"]:
            print(f"\n⚠️ Errors encountered: {len(self.stats['errors'])}")
            for error in self.stats["errors"][:5]:  # Show first 5 errors
                print(f"  - {error}")
        
        if self.fixed_files:
            print(f"\n✅ Successfully fixed files:")
            for file_path in self.fixed_files[:10]:  # Show first 10
                print(f"  - {Path(file_path).name}")
        
        print(f"\n💾 Backups saved to: {self.backup_dir}")

def main():
    """Main execution function"""
    import sys
    
    project_root = "/mnt/c/Users/Percision 15/talking_ragdoll_game"
    
    print("🏛️ Pentagon Duplicate Function Fixer")
    print("=====================================")
    print("Fixing duplicate Pentagon functions created by auto-migration...")
    
    # Check for command line arguments
    scan_only = "--scan-only" in sys.argv
    auto_fix = "--auto-fix" in sys.argv
    
    fixer = PentagonDuplicateFixer(project_root)
    fixer.create_backup_dir()
    
    if scan_only:
        print("\n🔍 SCAN ONLY MODE: Finding all duplicates...")
        all_duplicates = fixer.scan_for_duplicates(test_mode=False)
        fixer.print_summary()
        return
    
    if auto_fix:
        print("\n🚀 AUTO-FIX MODE: Scanning and fixing all duplicates...")
        all_duplicates = fixer.scan_for_duplicates(test_mode=False)
        if all_duplicates:
            fixer.fix_duplicates(all_duplicates, test_mode=False)
        fixer.print_summary()
        return
    
    # Default: Test mode first - check only a few files
    print("\n🧪 TEST MODE: Scanning first 5 files...")
    duplicates = fixer.scan_for_duplicates(test_mode=True)
    
    if duplicates:
        print(f"\n⚠️ Found duplicates in {len(duplicates)} files (test mode)")
        print("🔧 Run with --auto-fix to apply fixes automatically")
        print("🔍 Run with --scan-only to scan entire project without fixing")
    else:
        print("✅ No duplicates found in test files!")
        print("🔍 Run with --scan-only to scan entire project")
    
    fixer.print_summary()

if __name__ == "__main__":
    main()