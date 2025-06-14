#!/usr/bin/env python3
"""
🎯 SURGICAL ERROR DESTROYER - Targeted fixes for critical patterns
Focuses on the specific errors preventing engine startup
"""

import os
import re
import sys
from pathlib import Path
import shutil

class SurgicalErrorDestroyer:
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.fixed_files = 0
        self.total_fixes = 0
        self.backup_dir = self.project_path / "backups" / "surgical_fixes"
        
        # Focus on CRITICAL patterns only
        self.critical_patterns = {
            # Most critical Godot 3→4 fixes
            "funcref_fix": {
                "pattern": r'\bfuncref\(([^,]+),\s*"([^"]+)"\)',
                "replacement": r'Callable(\1, "\2")',
                "description": "funcref(obj, method) → Callable(obj, method)"
            },
            
            "spatial_fix": {
                "pattern": r'\bSpatial\b',
                "replacement": r'Node3D',
                "description": "Spatial → Node3D"
            },
            
            "rigidbody_fix": {
                "pattern": r'\bRigidBody\b(?!3D)',
                "replacement": r'RigidBody3D',
                "description": "RigidBody → RigidBody3D"
            },
            
            "kinematic_body_fix": {
                "pattern": r'\bKinematicBody\b(?!3D)',
                "replacement": r'CharacterBody3D',
                "description": "KinematicBody → CharacterBody3D"
            },
            
            "static_body_fix": {
                "pattern": r'\bStaticBody\b(?!3D)',
                "replacement": r'StaticBody3D',
                "description": "StaticBody → StaticBody3D"
            },
            
            "area_fix": {
                "pattern": r'\bArea\b(?!3D)',
                "replacement": r'Area3D',
                "description": "Area → Area3D"
            }
        }
        
        self.prepare_backup_system()
        print("🎯 SURGICAL ERROR DESTROYER: Targeting critical engine-breaking errors!")
        
    def prepare_backup_system(self):
        self.backup_dir.mkdir(parents=True, exist_ok=True)
        print(f"🛡️ Surgical backup system ready: {self.backup_dir}")
    
    def backup_file(self, file_path: Path) -> Path:
        relative_path = file_path.relative_to(self.project_path)
        backup_path = self.backup_dir / relative_path
        backup_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(file_path, backup_path)
        return backup_path
    
    def fix_critical_brace_issues(self, file_path: Path) -> bool:
        """Fix critical missing brace issues that break parsing"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            return False
        
        original_content = content
        fixes_made = False
        
        # Count braces
        open_braces = content.count('{')
        close_braces = content.count('}')
        
        if open_braces > close_braces:
            missing_braces = open_braces - close_braces
            print(f"   🔧 Adding {missing_braces} missing closing braces")
            
            # Add missing braces at the end
            for _ in range(missing_braces):
                content += "\n}"
            fixes_made = True
        
        # Fix obvious syntax issues
        if '"/' in content and 'ERROR: Expected statement, found "/" instead' in str(file_path):
            content = re.sub(r'"\s*/', r'"', content)
            fixes_made = True
        
        if content != original_content and fixes_made:
            self.backup_file(file_path)
            try:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                return True
            except Exception as e:
                return False
        
        return False
    
    def apply_critical_fixes(self, file_path: Path) -> tuple[bool, int]:
        """Apply critical pattern fixes"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            return False, 0
        
        original_content = content
        fixes_applied = 0
        
        # Apply critical patterns
        for pattern_name, pattern_info in self.critical_patterns.items():
            pattern = pattern_info["pattern"]
            replacement = pattern_info["replacement"]
            
            matches_before = len(re.findall(pattern, content))
            if matches_before > 0:
                content = re.sub(pattern, replacement, content)
                matches_after = len(re.findall(pattern, content))
                fixed_count = matches_before - matches_after
                
                if fixed_count > 0:
                    fixes_applied += fixed_count
                    print(f"   ✅ {pattern_info['description']}: {fixed_count} fixes")
        
        # Write changes
        if content != original_content and fixes_applied > 0:
            self.backup_file(file_path)
            try:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                return True, fixes_applied
            except Exception as e:
                return False, 0
        
        return False, 0
    
    def surgical_strike(self):
        """Main surgical strike function"""
        print("🎯 BEGINNING SURGICAL STRIKE ON CRITICAL ERRORS!")
        print("=" * 50)
        
        # Focus on scriptura_exchange_zone where most errors are
        target_paths = [
            self.project_path / "scriptura_exchange_zone",
            self.project_path / "addons",
            self.project_path / "core",
            self.project_path / "scripts"
        ]
        
        gdscript_files = []
        for target_path in target_paths:
            if target_path.exists():
                gdscript_files.extend(list(target_path.rglob("*.gd")))
        
        print(f"🎯 Found {len(gdscript_files)} GDScript files in critical areas")
        
        processed_files = 0
        for file_path in gdscript_files:
            processed_files += 1
            if processed_files % 100 == 0:
                print(f"🎯 Surgical progress: {processed_files}/{len(gdscript_files)}")
            
            # Fix critical brace issues first
            brace_fixed = self.fix_critical_brace_issues(file_path)
            
            # Apply critical pattern fixes
            pattern_fixed, fixes_count = self.apply_critical_fixes(file_path)
            
            if brace_fixed or pattern_fixed:
                self.fixed_files += 1
                self.total_fixes += fixes_count + (1 if brace_fixed else 0)
        
        self.print_surgical_report()
    
    def print_surgical_report(self):
        print("\n" + "=" * 50)
        print("🎯 SURGICAL STRIKE COMPLETE!")
        print("=" * 50)
        print(f"🗡️ Files surgically repaired: {self.fixed_files}")
        print(f"⚔️ Critical errors eliminated: {self.total_fixes}")
        print(f"🛡️ Surgical backups in: {self.backup_dir}")
        
        if self.total_fixes > 500:
            print("🎯 MASTER SURGEON! Critical systems stabilized!")
        elif self.total_fixes > 100:
            print("⚔️ SURGICAL SUCCESS! Major errors eliminated!")
        else:
            print("🔧 PRECISION FIXES applied!")

def main():
    if len(sys.argv) != 2:
        print("Usage: python surgical_error_destroyer.py <project_path>")
        sys.exit(1)
    
    project_path = sys.argv[1]
    if not os.path.exists(project_path):
        print(f"❌ Project path does not exist: {project_path}")
        sys.exit(1)
    
    surgeon = SurgicalErrorDestroyer(project_path)
    surgeon.surgical_strike()

if __name__ == "__main__":
    main()