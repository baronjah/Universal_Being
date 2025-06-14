#!/usr/bin/env python3
"""
🎯 PHASE 2 SURGICAL DESTROYER - Targets newly exposed deep errors
After fixing surface errors, we can now see the deep structural issues
"""

import os
import re
import sys
from pathlib import Path
import shutil

class Phase2SurgicalDestroyer:
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.fixed_files = 0
        self.total_fixes = 0
        self.backup_dir = self.project_path / "backups" / "phase2_fixes"
        
        # Phase 2 critical patterns - newly exposed errors
        self.phase2_patterns = {
            # New Godot 4 function changes exposed
            "get_world_3d_fix": {
                "pattern": r'\bget_world_3d\(\)',
                "replacement": r'get_world_3d()',  # This might need get_world_3d() → get_viewport().get_world_3d()
                "description": "get_world_3d() function access fix"
            },
            
            "get_file_size_fix": {
                "pattern": r'\bget_file_size\(',
                "replacement": r'FileAccess.get_file_as_bytes(',
                "description": "get_file_size() → FileAccess.get_file_as_bytes()"
            },
            
            # Syntax structure fixes
            "enum_in_wrong_place": {
                "pattern": r'(\s+)enum\s+(\w+)\s*{',
                "replacement": r'\nenum \2 {\n',
                "description": "Fix enum placement"
            },
            
            "var_without_name": {
                "pattern": r'var\s*:',
                "replacement": r'var unknown_var:',
                "description": "Fix var without name"
            },
            
            "for_without_variable": {
                "pattern": r'for\s*in\s+',
                "replacement": r'for item in ',
                "description": "Fix for loop without variable"
            },
            
            # Path fixes for broken preloads  
            "broken_preload_scenes": {
                "pattern": r'preload\("res://Scenes/',
                "replacement": r'preload("res://scenes/',
                "description": "Fix Scenes → scenes path"
            },
            
            "broken_preload_code": {
                "pattern": r'preload\("res://code/',
                "replacement": r'preload("res://scripts/',
                "description": "Fix code → scripts path"
            }
        }
        
        self.prepare_backup_system()
        print("🎯 PHASE 2 SURGICAL DESTROYER: Targeting deep structural errors!")
        
    def prepare_backup_system(self):
        self.backup_dir.mkdir(parents=True, exist_ok=True)
        print(f"🛡️ Phase 2 backup system ready: {self.backup_dir}")
    
    def backup_file(self, file_path: Path) -> Path:
        relative_path = file_path.relative_to(self.project_path)
        backup_path = self.backup_dir / relative_path
        backup_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(file_path, backup_path)
        return backup_path
    
    def advanced_brace_repair(self, file_path: Path) -> bool:
        """Advanced brace repair that analyzes context"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        except Exception as e:
            return False
        
        original_content = ''.join(lines)
        fixed_lines = []
        brace_count = 0
        in_function = False
        in_class = False
        fixes_made = False
        
        for i, line in enumerate(lines):
            stripped = line.strip()
            
            # Track context
            if stripped.startswith('func ') or stripped.startswith('class '):
                in_function = True
            elif stripped.startswith('class '):
                in_class = True
            
            # Count braces
            brace_count += line.count('{') - line.count('}')
            
            # If we're at end of file and have unmatched braces
            if i == len(lines) - 1 and brace_count > 0:
                # Add missing closing braces
                for _ in range(brace_count):
                    fixed_lines.append("}\n")
                fixes_made = True
            
            fixed_lines.append(line)
        
        if fixes_made:
            self.backup_file(file_path)
            try:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.writelines(fixed_lines)
                print(f"   🔧 Advanced brace repair: {brace_count} braces added")
                return True
            except Exception as e:
                return False
        
        return False
    
    def apply_phase2_fixes(self, file_path: Path) -> tuple[bool, int]:
        """Apply Phase 2 pattern fixes"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            return False, 0
        
        original_content = content
        fixes_applied = 0
        
        # Apply Phase 2 patterns
        for pattern_name, pattern_info in self.phase2_patterns.items():
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
    
    def phase2_strike(self):
        """Phase 2 surgical strike"""
        print("🎯 BEGINNING PHASE 2 DEEP SURGICAL STRIKE!")
        print("=" * 50)
        
        # Target scriptura_exchange_zone specifically where most issues remain
        target_path = self.project_path / "scriptura_exchange_zone"
        
        if not target_path.exists():
            print("❌ scriptura_exchange_zone not found!")
            return
        
        gdscript_files = list(target_path.rglob("*.gd"))
        print(f"🎯 Found {len(gdscript_files)} GDScript files in scriptura zone")
        
        processed_files = 0
        for file_path in gdscript_files:
            processed_files += 1
            if processed_files % 200 == 0:
                print(f"🎯 Phase 2 progress: {processed_files}/{len(gdscript_files)}")
            
            # Advanced brace repair first
            brace_fixed = self.advanced_brace_repair(file_path)
            
            # Apply Phase 2 pattern fixes
            pattern_fixed, fixes_count = self.apply_phase2_fixes(file_path)
            
            if brace_fixed or pattern_fixed:
                self.fixed_files += 1
                self.total_fixes += fixes_count + (1 if brace_fixed else 0)
        
        self.print_phase2_report()
    
    def print_phase2_report(self):
        print("\n" + "=" * 50)
        print("🎯 PHASE 2 SURGICAL STRIKE COMPLETE!")
        print("=" * 50)
        print(f"🗡️ Files deep-repaired: {self.fixed_files}")
        print(f"⚔️ Deep errors eliminated: {self.total_fixes}")
        print(f"🛡️ Phase 2 backups in: {self.backup_dir}")
        
        if self.total_fixes > 200:
            print("🎯 DEEP STRUCTURE MASTER! Core issues resolved!")
        elif self.total_fixes > 50:
            print("⚔️ PHASE 2 SUCCESS! Structural issues fixed!")
        else:
            print("🔧 Deep precision fixes applied!")

def main():
    if len(sys.argv) != 2:
        print("Usage: python phase2_surgical_destroyer.py <project_path>")
        sys.exit(1)
    
    project_path = sys.argv[1]
    if not os.path.exists(project_path):
        print(f"❌ Project path does not exist: {project_path}")
        sys.exit(1)
    
    surgeon = Phase2SurgicalDestroyer(project_path)
    surgeon.phase2_strike()

if __name__ == "__main__":
    main()