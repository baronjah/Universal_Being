#!/usr/bin/env python3
"""
🏛️ PENTAGON MIGRATION ENGINE - Automated Script Modernization
Author: Claude & JSH  
Created: May 31, 2025, 23:25 CEST
Purpose: Automatically migrate scripts to Pentagon compliance
Connection: Core part of "All for One, One for All" Pentagon Architecture

Fixes:
- 913 direct add_child violations → FloodgateController integration
- 177 extends Node violations → UniversalBeing inheritance  
- 172 material_new violations → Material pooling
- Missing Pentagon functions → Full Pentagon pattern
- Prehistoric headers → Standardized format
"""

import os
import re
import json
import shutil
import argparse
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Optional

class PentagonMigrationEngine:
    """Automated Pentagon compliance migration system"""
    
    def __init__(self, project_path: str, backup: bool = True):
        self.project_path = Path(project_path)
        self.scripts_path = self.project_path / "scripts"
        self.backup_enabled = backup
        self.backup_dir = self.project_path / "pentagon_migration_backups"
        
        # Migration statistics
        self.migration_stats = {
            "total_processed": 0,
            "successfully_migrated": 0,
            "failed_migrations": 0,
            "violations_fixed": {
                "inheritance_fixes": 0,
                "add_child_fixes": 0,
                "material_pooling_fixes": 0,
                "timer_pooling_fixes": 0,
                "pentagon_functions_added": 0,
                "headers_standardized": 0
            },
            "processed_scripts": []
        }
        
        # Pentagon function templates
        self.pentagon_templates = {
            "_init": '''func _init() -> void:
\tpentagon_init()

func pentagon_init() -> void:
\t# Pentagon initialization - override in child classes
\tpass''',
            "_ready": '''func _ready() -> void:
\tpentagon_ready()

func pentagon_ready() -> void:
\t# Pentagon setup - override in child classes
\tpass''',
            "_process": '''func _process(delta: float) -> void:
\tpentagon_process(delta)

func pentagon_process(delta: float) -> void:
\t# Pentagon logic processing - override in child classes
\tpass''',
            "_input": '''func _input(event: InputEvent) -> void:
\tpentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
\t# Pentagon input handling - override in child classes
\tpass''',
            "sewers": '''func sewers() -> void:
\tpentagon_sewers()

func pentagon_sewers() -> void:
\t# Pentagon cleanup/output - override in child classes
\tpass'''
        }
    
    def migrate_all_scripts(self, dry_run: bool = False) -> Dict:
        """Main migration function - process all scripts"""
        print("🏛️ Starting Pentagon Migration Engine...")
        
        if self.backup_enabled and not dry_run:
            self._create_backup()
        
        # Load previous analysis results
        analysis_files = list(self.project_path.glob("pentagon_temporal_analysis_*.json"))
        if not analysis_files:
            print("❌ No analysis results found. Run pentagon_temporal_analyzer.py first!")
            return self.migration_stats
        
        latest_analysis = max(analysis_files, key=lambda x: x.stat().st_mtime)
        print(f"📊 Loading analysis from: {latest_analysis.name}")
        
        with open(latest_analysis, 'r') as file:
            analysis_data = json.load(file)
        
        # Process scripts in priority order
        scripts_to_migrate = self._prioritize_migrations(analysis_data["scripts"])
        
        print(f"🎯 Migrating {len(scripts_to_migrate)} scripts...")
        
        for script_data in scripts_to_migrate:
            script_path = self.project_path / script_data["path"]
            if script_path.exists():
                success = self._migrate_single_script(script_path, script_data, dry_run)
                if success:
                    self.migration_stats["successfully_migrated"] += 1
                else:
                    self.migration_stats["failed_migrations"] += 1
                self.migration_stats["total_processed"] += 1
        
        # Save migration report
        if not dry_run:
            self._save_migration_report()
        
        return self.migration_stats
    
    def _prioritize_migrations(self, scripts: List[Dict]) -> List[Dict]:
        """Prioritize scripts for migration based on complexity and violations"""
        def get_priority_score(script):
            pentagon_score = script["pentagon"]["score"]
            violations = script["violations"]["total"]
            
            # Higher Pentagon score + lower violations = higher priority
            # These are easier to migrate first
            priority = (pentagon_score * 10) - violations
            
            # Boost priority for autoload scripts (more critical)
            if "/autoload/" in script["path"]:
                priority += 50
            
            # Boost priority for core scripts
            if "/core/" in script["path"]:
                priority += 30
                
            return priority
        
        return sorted(scripts, key=get_priority_score, reverse=True)
    
    def _migrate_single_script(self, script_path: Path, script_data: Dict, dry_run: bool) -> bool:
        """Migrate a single script to Pentagon compliance"""
        try:
            with open(script_path, 'r', encoding='utf-8') as file:
                original_content = file.read()
            
            migrated_content = original_content
            fixes_applied = []
            
            # 1. Fix inheritance violations
            if not script_data["pentagon"]["has_universal_being_inheritance"]:
                migrated_content, inheritance_fixes = self._fix_inheritance(migrated_content)
                fixes_applied.extend(inheritance_fixes)
                self.migration_stats["violations_fixed"]["inheritance_fixes"] += len(inheritance_fixes)
            
            # 2. Fix add_child violations  
            migrated_content, add_child_fixes = self._fix_add_child_calls(migrated_content)
            fixes_applied.extend(add_child_fixes)
            self.migration_stats["violations_fixed"]["add_child_fixes"] += len(add_child_fixes)
            
            # 3. Fix material/timer violations
            migrated_content, pooling_fixes = self._fix_resource_pooling(migrated_content)
            fixes_applied.extend(pooling_fixes)
            
            # 4. Add missing Pentagon functions
            missing_functions = self._find_missing_pentagon_functions(script_data["pentagon"]["functions"])
            if missing_functions:
                migrated_content = self._add_pentagon_functions(migrated_content, missing_functions)
                fixes_applied.extend([f"Added {func}" for func in missing_functions])
                self.migration_stats["violations_fixed"]["pentagon_functions_added"] += len(missing_functions)
            
            # 5. Standardize header
            if script_data["temporal"]["category"] == "prehistoric":
                migrated_content = self._add_standardized_header(migrated_content, script_path)
                fixes_applied.append("Added standardized header")
                self.migration_stats["violations_fixed"]["headers_standardized"] += 1
            
            # Apply changes
            if not dry_run and migrated_content != original_content:
                with open(script_path, 'w', encoding='utf-8') as file:
                    file.write(migrated_content)
            
            # Record migration
            migration_record = {
                "script": str(script_path.relative_to(self.project_path)),
                "fixes_applied": fixes_applied,
                "original_pentagon_score": script_data["pentagon"]["score"],
                "violations_before": script_data["violations"]["total"],
                "dry_run": dry_run
            }
            
            self.migration_stats["processed_scripts"].append(migration_record)
            
            if fixes_applied:
                status = "[DRY RUN] " if dry_run else ""
                print(f"✅ {status}Migrated: {script_path.name} ({len(fixes_applied)} fixes)")
            
            return True
            
        except Exception as e:
            print(f"❌ Failed to migrate {script_path.name}: {e}")
            return False
    
    def _fix_inheritance(self, content: str) -> Tuple[str, List[str]]:
        """Fix inheritance violations - convert to UniversalBeing"""
        fixes = []
        
        # Replace Node inheritance
        if re.search(r'extends\s+Node\s*$', content, re.MULTILINE):
            content = re.sub(r'extends\s+Node\s*$', 'extends UniversalBeingBase', content, flags=re.MULTILINE)
            fixes.append("extends Node → extends UniversalBeingBase")
        
        # Replace Node3D inheritance  
        if re.search(r'extends\s+Node3D\s*$', content, re.MULTILINE):
            content = re.sub(r'extends\s+Node3D\s*$', 'extends UniversalBeingBase', content, flags=re.MULTILINE)
            fixes.append("extends Node3D → extends UniversalBeingBase")
        
        # Replace Control inheritance
        if re.search(r'extends\s+Control\s*$', content, re.MULTILINE):
            content = re.sub(r'extends\s+Control\s*$', 'extends UniversalBeingBase', content, flags=re.MULTILINE)
            fixes.append("extends Control → extends UniversalBeingBase")
        
        return content, fixes
    
    def _fix_add_child_calls(self, content: str) -> Tuple[str, List[str]]:
        """Fix add_child violations - route through FloodgateController"""
        fixes = []
        
        # Find all add_child calls
        add_child_pattern = r'(\w+)\.add_child\s*\(([^)]+)\)'
        matches = re.findall(add_child_pattern, content)
        
        if matches:
            # Replace with FloodgateController calls
            for object_name, child_param in matches:
                if object_name != "FloodgateController":  # Don't replace if already using FloodgateController
                    old_call = f"{object_name}.add_child({child_param})"
                    new_call = f"FloodgateController.universal_add_child({child_param}, {object_name})"
                    content = content.replace(old_call, new_call)
                    fixes.append(f"add_child → FloodgateController.universal_add_child")
        
        return content, fixes
    
    def _fix_resource_pooling(self, content: str) -> Tuple[str, List[str]]:
        """Fix material and timer violations - use pooling"""
        fixes = []
        
        # Fix Timer.new() calls
        timer_pattern = r'Timer\.new\s*\(\s*\)'
        if re.search(timer_pattern, content):
            content = re.sub(timer_pattern, 'TimerManager.get_timer()', content)
            fixes.append("Timer.new() → TimerManager.get_timer()")
            self.migration_stats["violations_fixed"]["timer_pooling_fixes"] += 1
        
        # Fix StandardMaterial3D.new() calls
        material_pattern = r'StandardMaterial3D\.new\s*\(\s*\)'
        if re.search(material_pattern, content):
            content = re.sub(material_pattern, 'MaterialLibrary.get_material("default")', content)
            fixes.append("StandardMaterial3D.new() → MaterialLibrary.get_material()")
            self.migration_stats["violations_fixed"]["material_pooling_fixes"] += 1
        
        return content, fixes
    
    def _find_missing_pentagon_functions(self, existing_functions: Dict) -> List[str]:
        """Find which Pentagon functions are missing"""
        required_functions = ["_init", "_ready", "_process", "_input", "sewers"]
        missing = []
        
        for func_name in required_functions:
            if not existing_functions.get(func_name, False):
                missing.append(func_name)
        
        return missing
    
    def _add_pentagon_functions(self, content: str, missing_functions: List[str]) -> str:
        """Add missing Pentagon functions to script"""
        
        # Add functions at the end of the file, before any existing functions if possible
        lines = content.split('\n')
        
        # Find a good insertion point (after class_name, before first function)
        insertion_point = len(lines)
        for i, line in enumerate(lines):
            if line.strip().startswith('func ') and not line.strip().startswith('func _'):
                insertion_point = i
                break
        
        # Insert Pentagon functions
        new_lines = []
        for func_name in missing_functions:
            new_lines.append("")  # Empty line before function
            new_lines.extend(self.pentagon_templates[func_name].split('\n'))
        
        # Insert at the right position
        result_lines = lines[:insertion_point] + new_lines + lines[insertion_point:]
        
        return '\n'.join(result_lines)
    
    def _add_standardized_header(self, content: str, script_path: Path) -> str:
        """Add standardized header to prehistoric scripts"""
        
        # Determine script purpose from path and content
        purpose = self._guess_script_purpose(script_path, content)
        
        header = f"""# 🏛️ {script_path.stem.title().replace('_', ' ')} - {purpose}
# Author: JSH (Migrated by Pentagon Engine)
# Created: {datetime.now().strftime('%B %d, %Y, %H:%M CEST')}
# Purpose: {purpose}
# Connection: Part of Pentagon Architecture migration

"""
        
        # Add header at the beginning
        return header + content
    
    def _guess_script_purpose(self, script_path: Path, content: str) -> str:
        """Guess script purpose from path and content"""
        path_str = str(script_path).lower()
        
        if "controller" in path_str:
            return "System controller for Pentagon architecture"
        elif "manager" in path_str:
            return "Resource management system"
        elif "ragdoll" in path_str:
            return "Ragdoll physics and behavior system" 
        elif "universal" in path_str:
            return "Universal Being functionality"
        elif "floodgate" in path_str:
            return "Floodgate flow control system"
        elif "console" in path_str:
            return "Console command interface"
        elif "ui" in path_str or "interface" in path_str:
            return "User interface component"
        elif "autoload" in path_str:
            return "Global autoload system"
        else:
            return "Pentagon architecture component"
    
    def _create_backup(self):
        """Create backup of all scripts before migration"""
        if self.backup_dir.exists():
            shutil.rmtree(self.backup_dir)
        
        print(f"💾 Creating backup in: {self.backup_dir}")
        shutil.copytree(self.scripts_path, self.backup_dir)
    
    def _save_migration_report(self):
        """Save detailed migration report"""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        report_file = self.project_path / f"pentagon_migration_report_{timestamp}.json"
        
        # Add summary statistics
        self.migration_stats["summary"] = {
            "migration_timestamp": timestamp,
            "success_rate": (self.migration_stats["successfully_migrated"] / max(1, self.migration_stats["total_processed"])) * 100,
            "total_fixes_applied": sum(self.migration_stats["violations_fixed"].values()),
            "backup_location": str(self.backup_dir) if self.backup_enabled else None
        }
        
        with open(report_file, 'w', encoding='utf-8') as file:
            json.dump(self.migration_stats, file, indent=2, ensure_ascii=False)
        
        print(f"📋 Migration report saved: {report_file}")
        
        # Generate text summary
        self._print_migration_summary()
    
    def _print_migration_summary(self):
        """Print human-readable migration summary"""
        stats = self.migration_stats
        
        print(f"""
🏛️ PENTAGON MIGRATION COMPLETE!

📊 MIGRATION STATISTICS:
Total Scripts Processed: {stats['total_processed']}
Successfully Migrated: {stats['successfully_migrated']}
Failed Migrations: {stats['failed_migrations']}
Success Rate: {stats['summary']['success_rate']:.1f}%

🔧 FIXES APPLIED:
Inheritance Fixes: {stats['violations_fixed']['inheritance_fixes']}
Add_Child Fixes: {stats['violations_fixed']['add_child_fixes']}
Material Pooling: {stats['violations_fixed']['material_pooling_fixes']}
Timer Pooling: {stats['violations_fixed']['timer_pooling_fixes']}
Pentagon Functions Added: {stats['violations_fixed']['pentagon_functions_added']}
Headers Standardized: {stats['violations_fixed']['headers_standardized']}

Total Fixes: {stats['summary']['total_fixes_applied']}

💾 Backup Location: {stats['summary']['backup_location']}

🎯 NEXT STEPS:
1. Test the migrated scripts in-game
2. Run Pentagon Activity Monitor to verify improvements
3. Check for any compilation errors
4. Fine-tune Pentagon function implementations

🏛️ "All for One, One for All" - Pentagon Architecture Achieved!
""")

def main():
    """Main execution function"""
    parser = argparse.ArgumentParser(
        description="Pentagon Migration Engine - Automated compliance migration"
    )
    parser.add_argument(
        "project_path",
        nargs='?',
        default="/mnt/c/Users/Percision 15/talking_ragdoll_game",
        help="Path to the Godot project"
    )
    parser.add_argument(
        "--dry-run", "-d",
        action="store_true",
        help="Simulate migration without making changes"
    )
    parser.add_argument(
        "--no-backup", "-n",
        action="store_true",
        help="Skip creating backup (NOT recommended)"
    )
    
    args = parser.parse_args()
    
    # Initialize migration engine
    engine = PentagonMigrationEngine(args.project_path, backup=not args.no_backup)
    
    # Run migration
    if args.dry_run:
        print("🔍 Running DRY RUN migration (no files will be changed)")
    else:
        print("⚠️  Running FULL migration (files will be modified)")
        if not args.no_backup:
            print("💾 Backup will be created automatically")
    
    results = engine.migrate_all_scripts(dry_run=args.dry_run)
    
    print("\n🏛️ Pentagon Migration Engine completed!")

if __name__ == "__main__":
    main()