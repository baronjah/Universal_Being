#!/usr/bin/env python3
"""
🔄 INTELLIGENT SCRIPT MERGER
Systematically merge pentagon_migration_backups with main scripts
Created: June 1, 2025 - Emergency Cleanup System
"""

import os
import shutil
import difflib
from pathlib import Path
import re

class IntelligentScriptMerger:
    def __init__(self, project_root):
        self.project_root = Path(project_root)
        self.scripts_dir = self.project_root / "scripts"
        self.backups_dir = self.project_root / "pentagon_migration_backups"
        self.merged_count = 0
        self.conflicts_found = []
        self.unique_functions = {}
        
    def analyze_project(self):
        """Analyze the entire project for duplicate scripts"""
        print("🔍 ANALYZING PROJECT FOR DUPLICATES...")
        
        if not self.backups_dir.exists():
            print("❌ No pentagon_migration_backups found!")
            return
            
        # Find all GDScript files in both directories
        main_scripts = self._find_gdscripts(self.scripts_dir)
        backup_scripts = self._find_gdscripts(self.backups_dir)
        
        print(f"📊 Found {len(main_scripts)} main scripts")
        print(f"📊 Found {len(backup_scripts)} backup scripts")
        
        # Compare scripts by relative path
        self._compare_scripts(main_scripts, backup_scripts)
        
    def _find_gdscripts(self, directory):
        """Find all .gd files in directory"""
        gdscripts = []
        for file_path in directory.rglob("*.gd"):
            relative_path = file_path.relative_to(directory)
            gdscripts.append((relative_path, file_path))
        return gdscripts
    
    def _compare_scripts(self, main_scripts, backup_scripts):
        """Compare main scripts with backup scripts"""
        main_dict = {rel_path: abs_path for rel_path, abs_path in main_scripts}
        backup_dict = {rel_path: abs_path for rel_path, abs_path in backup_scripts}
        
        for rel_path in backup_dict:
            if rel_path in main_dict:
                # Found duplicate - compare and merge
                self._merge_duplicate_scripts(
                    main_dict[rel_path], 
                    backup_dict[rel_path], 
                    rel_path
                )
            else:
                # Backup-only script - check if it has unique functionality
                self._analyze_unique_script(backup_dict[rel_path], rel_path)
    
    def _merge_duplicate_scripts(self, main_path, backup_path, rel_path):
        """Intelligently merge two versions of the same script"""
        print(f"\n🔄 MERGING: {rel_path}")
        
        try:
            with open(main_path, 'r', encoding='utf-8') as f:
                main_content = f.read()
            with open(backup_path, 'r', encoding='utf-8') as f:
                backup_content = f.read()
                
            # Extract functions from both scripts
            main_functions = self._extract_functions(main_content)
            backup_functions = self._extract_functions(backup_content)
            
            # Find unique functions in backup
            unique_in_backup = []
            for func_name, func_content in backup_functions.items():
                if func_name not in main_functions:
                    unique_in_backup.append((func_name, func_content))
                    print(f"  📝 Found unique function in backup: {func_name}")
            
            # If backup has unique functions, create a report
            if unique_in_backup:
                self._create_merger_report(rel_path, unique_in_backup, main_path)
                
        except Exception as e:
            print(f"  ❌ Error merging {rel_path}: {e}")
    
    def _extract_functions(self, content):
        """Extract function definitions from GDScript content"""
        functions = {}
        lines = content.split('\n')
        current_function = None
        function_content = []
        
        for line in lines:
            # Check for function definition
            func_match = re.match(r'^\s*func\s+(\w+)', line)
            if func_match:
                # Save previous function if exists
                if current_function:
                    functions[current_function] = '\n'.join(function_content)
                
                # Start new function
                current_function = func_match.group(1)
                function_content = [line]
            elif current_function:
                function_content.append(line)
                
                # Check for end of function (dedent or new func/class)
                if line.strip() == '' or (line and not line[0].isspace() and not line.startswith('#')):
                    if not line.startswith('func ') and not line.startswith('class '):
                        continue
                    # Function ended
                    functions[current_function] = '\n'.join(function_content)
                    current_function = None
                    function_content = []
        
        # Save last function
        if current_function:
            functions[current_function] = '\n'.join(function_content)
            
        return functions
    
    def _create_merger_report(self, rel_path, unique_functions, main_path):
        """Create a report of functions that need manual merging"""
        report_path = self.project_root / f"MERGER_REPORT_{rel_path.name}.md"
        
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write(f"# 🔄 MERGER REPORT: {rel_path}\n\n")
            f.write(f"**Main Script**: `{main_path}`\n")
            f.write(f"**Backup Had**: {len(unique_functions)} unique functions\n\n")
            f.write("## 📝 UNIQUE FUNCTIONS TO CONSIDER MERGING:\n\n")
            
            for func_name, func_content in unique_functions:
                f.write(f"### Function: `{func_name}`\n")
                f.write("```gdscript\n")
                f.write(func_content)
                f.write("\n```\n\n")
                f.write("**Action Required**: Review and manually merge if needed\n\n")
        
        print(f"  📋 Created merger report: {report_path.name}")
        self.conflicts_found.append(str(report_path))
    
    def _analyze_unique_script(self, backup_path, rel_path):
        """Analyze scripts that only exist in backups"""
        print(f"\n📋 UNIQUE BACKUP SCRIPT: {rel_path}")
        print(f"  📍 Location: {backup_path}")
        print(f"  ⚠️  Consider if this should be moved to main scripts/")
    
    def eliminate_backups_safely(self):
        """Remove pentagon_migration_backups after analysis"""
        if self.conflicts_found:
            print(f"\n⚠️  Found {len(self.conflicts_found)} merger reports")
            print("❌ NOT removing backups yet - review merger reports first!")
            return False
        else:
            print("\n✅ No conflicts found - safe to remove backups")
            choice = input("🔥 Remove pentagon_migration_backups folder? (y/N): ")
            if choice.lower() == 'y':
                shutil.rmtree(self.backups_dir)
                print("✅ Pentagon migration backups removed!")
                return True
            return False
    
    def generate_summary(self):
        """Generate summary of merger process"""
        print("\n" + "="*60)
        print("📊 INTELLIGENT SCRIPT MERGER SUMMARY")
        print("="*60)
        print(f"🔍 Conflicts Found: {len(self.conflicts_found)}")
        print(f"📋 Merger Reports: {len(self.conflicts_found)}")
        
        if self.conflicts_found:
            print("\n📋 Review these merger reports:")
            for report in self.conflicts_found:
                print(f"  📄 {report}")
        
        print("\n🎯 NEXT STEPS:")
        print("1. Review merger reports")
        print("2. Manually merge unique functions if valuable")  
        print("3. Remove pentagon_migration_backups when ready")
        print("4. Fix remaining compilation errors")
        print("5. Build Universal Being Autoload System")

if __name__ == "__main__":
    merger = IntelligentScriptMerger("/mnt/c/Users/Percision 15/talking_ragdoll_game")
    merger.analyze_project()
    merger.eliminate_backups_safely()
    merger.generate_summary()