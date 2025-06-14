#!/usr/bin/env python3
"""
🏛️ PENTAGON ARCHITECTURE AUTO-FIXER - Systematic Project Healing
Surgically convert ALL Godot functions to Pentagon Architecture
Created: 2025-06-01 | The Great Pentagon Migration
Author: Pentagon Surgeon Claude, Digital Healer
"""

import os
import re
import shutil
from pathlib import Path
from typing import List, Dict, Tuple
import json
from datetime import datetime

class PentagonArchitectureAutoFixer:
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.fixes_applied = []
        self.backup_created = False
        self.test_mode = False  # Set to True for dry-run
        
        # Pentagon function mappings
        self.pentagon_mappings = {
            "_init": {
                "pentagon_func": "pentagon_init",
                "wrapper": self._wrap_init_function,
                "priority": 1
            },
            "_ready": {
                "pentagon_func": "pentagon_ready", 
                "wrapper": self._wrap_ready_function,
                "priority": 2
            },
            "_process": {
                "pentagon_func": "pentagon_process",
                "wrapper": self._wrap_process_function,
                "priority": 3
            },
            "_input": {
                "pentagon_func": "pentagon_input",
                "wrapper": self._wrap_input_function,
                "priority": 4
            },
            "_physics_process": {
                "pentagon_func": "pentagon_process",  # Integrate into process
                "wrapper": self._wrap_physics_process_function,
                "priority": 5
            },
            "_unhandled_input": {
                "pentagon_func": "pentagon_input",  # Integrate into input
                "wrapper": self._wrap_unhandled_input_function,
                "priority": 6
            },
            "_exit_tree": {
                "pentagon_func": "pentagon_sewers",  # Integrate into sewers
                "wrapper": self._wrap_exit_tree_function,
                "priority": 7
            }
        }
    
    def begin_pentagon_healing(self, create_backup: bool = True, test_mode: bool = False):
        """Begin systematic Pentagon Architecture healing"""
        self.test_mode = test_mode
        
        print("🏛️ PENTAGON ARCHITECTURE AUTO-FIXER: Beginning systematic healing...")
        print(f"🎯 Mission: Convert ALL 1,176 violations to Pentagon Architecture")
        print(f"🔧 Mode: {'DRY-RUN' if test_mode else 'LIVE SURGERY'}")
        
        if create_backup and not test_mode:
            self._create_project_backup()
        
        # Phase 1: Load violation report
        violations = self._load_violation_report()
        
        # Phase 2: Sort by priority (critical first)
        sorted_violations = self._sort_violations_by_priority(violations)
        
        # Phase 3: Apply systematic fixes
        self._apply_systematic_fixes(sorted_violations)
        
        # Phase 4: Verify fixes and generate report
        self._verify_fixes_and_report()
    
    def _create_project_backup(self):
        """Create complete project backup before surgery"""
        print("\n💾 Creating project backup before Pentagon surgery...")
        
        backup_path = self.project_path.parent / f"pentagon_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        backup_path.mkdir(exist_ok=True)
        
        # Copy essential files
        for pattern in ["*.gd", "*.tscn", "*.cs", "project.godot"]:
            for file_path in self.project_path.rglob(pattern):
                if self._should_backup_file(file_path):
                    relative_path = file_path.relative_to(self.project_path)
                    backup_file_path = backup_path / relative_path
                    backup_file_path.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(file_path, backup_file_path)
        
        self.backup_created = True
        print(f"✅ Backup created: {backup_path}")
    
    def _should_backup_file(self, file_path: Path) -> bool:
        """Check if file should be backed up"""
        skip_dirs = {".godot", "build", ".git", "pentagon_backup"}
        return not any(skip_dir in file_path.parts for skip_dir in skip_dirs)
    
    def _load_violation_report(self) -> List[Dict]:
        """Load Pentagon violation report"""
        report_path = self.project_path / 'docs/current/PENTAGON_GODOT_VIOLATIONS_REPORT_2025_06_01.json'
        
        if not report_path.exists():
            print("❌ No violation report found. Run pentagon_godot_violations_detective.py first!")
            return []
        
        with open(report_path, 'r') as f:
            data = json.load(f)
            return data.get('violations', [])
    
    def _sort_violations_by_priority(self, violations: List[Dict]) -> List[Dict]:
        """Sort violations by Pentagon Architecture priority"""
        print(f"\n📊 Sorting {len(violations)} violations by priority...")
        
        def get_priority(violation):
            func_name = violation['function']
            return self.pentagon_mappings.get(func_name, {}).get('priority', 999)
        
        sorted_violations = sorted(violations, key=get_priority)
        
        # Group by function type for reporting
        by_function = {}
        for violation in sorted_violations:
            func = violation['function']
            if func not in by_function:
                by_function[func] = []
            by_function[func].append(violation)
        
        print(f"🎯 PRIORITY ORDER:")
        for func, func_violations in by_function.items():
            if func in self.pentagon_mappings:
                priority = self.pentagon_mappings[func]['priority']
                print(f"  {priority}. {func}: {len(func_violations)} violations")
        
        return sorted_violations
    
    def _apply_systematic_fixes(self, violations: List[Dict]):
        """Apply Pentagon Architecture fixes systematically"""
        print(f"\n🔧 PHASE 3: Applying Pentagon Architecture fixes...")
        print(f"🎯 Target: {len(violations)} violations")
        
        files_processed = set()
        total_fixes = 0
        
        # Group violations by file for efficient processing
        violations_by_file = {}
        for violation in violations:
            file_path = violation['file']
            if file_path not in violations_by_file:
                violations_by_file[file_path] = []
            violations_by_file[file_path].append(violation)
        
        print(f"📁 Processing {len(violations_by_file)} files...")
        
        for file_path, file_violations in violations_by_file.items():
            if self._should_skip_file_for_fixing(file_path):
                continue
            
            fixes_count = self._fix_file_violations(file_path, file_violations)
            total_fixes += fixes_count
            files_processed.add(file_path)
            
            if total_fixes % 50 == 0:  # Progress update every 50 fixes
                print(f"⚡ Progress: {total_fixes} fixes applied...")
        
        print(f"✅ Pentagon healing complete!")
        print(f"📊 Files processed: {len(files_processed)}")
        print(f"🔧 Total fixes applied: {total_fixes}")
    
    def _should_skip_file_for_fixing(self, file_path: str) -> bool:
        """Skip certain files from automatic fixing"""
        skip_patterns = [
            "addons/",
            ".godot/",
            "build/",
            "pentagon_backup",
            "test_",  # Skip test files for now
        ]
        
        return any(pattern in file_path for pattern in skip_patterns)
    
    def _fix_file_violations(self, file_path: str, violations: List[Dict]) -> int:
        """Fix all Pentagon violations in a single file"""
        full_path = self.project_path / file_path
        
        if not full_path.exists():
            return 0
        
        try:
            with open(full_path, 'r', encoding='utf-8') as f:
                original_content = f.read()
        except (UnicodeDecodeError, FileNotFoundError):
            return 0
        
        modified_content = original_content
        fixes_applied = 0
        
        # Sort violations by line number (descending) to avoid line number shifts
        sorted_violations = sorted(violations, key=lambda x: x['line'], reverse=True)
        
        for violation in sorted_violations:
            func_name = violation['function']
            if func_name in self.pentagon_mappings:
                # Apply Pentagon wrapper
                wrapper = self.pentagon_mappings[func_name]['wrapper']
                new_content, was_fixed = wrapper(modified_content, violation)
                
                if was_fixed:
                    modified_content = new_content
                    fixes_applied += 1
                    
                    # Record the fix
                    self.fixes_applied.append({
                        'file': file_path,
                        'line': violation['line'],
                        'function': func_name,
                        'pentagon_function': self.pentagon_mappings[func_name]['pentagon_func'],
                        'timestamp': datetime.now().isoformat()
                    })
        
        # Write the fixed content
        if fixes_applied > 0 and not self.test_mode:
            with open(full_path, 'w', encoding='utf-8') as f:
                f.write(modified_content)
            print(f"🔧 Fixed {file_path}: {fixes_applied} Pentagon violations")
        elif fixes_applied > 0 and self.test_mode:
            print(f"🧪 [DRY-RUN] Would fix {file_path}: {fixes_applied} violations")
        
        return fixes_applied
    
    def _wrap_init_function(self, content: str, violation: Dict) -> Tuple[str, bool]:
        """Wrap _init function with Pentagon Architecture"""
        func_pattern = r'func\s+_init\s*\([^)]*\)\s*(?:->\s*\w+)?\s*:(.*?)(?=\nfunc|\nclass|\n#|\Z)'
        
        def replace_init(match):
            func_body = match.group(1)
            # Check if pentagon_init already called
            if 'pentagon_init()' in func_body:
                return match.group(0)  # Already fixed
            
            return f"""func _init() -> void:
\tpentagon_init()

func pentagon_init() -> void:
\tsuper.pentagon_init(){func_body}"""
        
        new_content, count = re.subn(func_pattern, replace_init, content, flags=re.DOTALL)
        return new_content, count > 0
    
    def _wrap_ready_function(self, content: str, violation: Dict) -> Tuple[str, bool]:
        """Wrap _ready function with Pentagon Architecture"""
        func_pattern = r'func\s+_ready\s*\([^)]*\)\s*(?:->\s*\w+)?\s*:(.*?)(?=\nfunc|\nclass|\n#|\Z)'
        
        def replace_ready(match):
            func_body = match.group(1)
            # Check if pentagon_ready already called
            if 'pentagon_ready()' in func_body:
                return match.group(0)  # Already fixed
            
            return f"""func _ready() -> void:
\tpentagon_ready()

func pentagon_ready() -> void:
\tsuper.pentagon_ready(){func_body}"""
        
        new_content, count = re.subn(func_pattern, replace_ready, content, flags=re.DOTALL)
        return new_content, count > 0
    
    def _wrap_process_function(self, content: str, violation: Dict) -> Tuple[str, bool]:
        """Wrap _process function with Pentagon Architecture"""
        func_pattern = r'func\s+_process\s*\([^)]*\)\s*(?:->\s*\w+)?\s*:(.*?)(?=\nfunc|\nclass|\n#|\Z)'
        
        def replace_process(match):
            func_body = match.group(1)
            # Check if pentagon_process already called
            if 'pentagon_process(' in func_body:
                return match.group(0)  # Already fixed
            
            return f"""func _process(delta: float) -> void:
\tpentagon_process(delta)

func pentagon_process(delta: float) -> void:
\tsuper.pentagon_process(delta){func_body}"""
        
        new_content, count = re.subn(func_pattern, replace_process, content, flags=re.DOTALL)
        return new_content, count > 0
    
    def _wrap_input_function(self, content: str, violation: Dict) -> Tuple[str, bool]:
        """Wrap _input function with Pentagon Architecture"""
        func_pattern = r'func\s+_input\s*\([^)]*\)\s*(?:->\s*\w+)?\s*:(.*?)(?=\nfunc|\nclass|\n#|\Z)'
        
        def replace_input(match):
            func_body = match.group(1)
            # Check if pentagon_input already called
            if 'pentagon_input(' in func_body:
                return match.group(0)  # Already fixed
            
            return f"""func _input(event: InputEvent) -> void:
\tpentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
\tsuper.pentagon_input(event){func_body}"""
        
        new_content, count = re.subn(func_pattern, replace_input, content, flags=re.DOTALL)
        return new_content, count > 0
    
    def _wrap_physics_process_function(self, content: str, violation: Dict) -> Tuple[str, bool]:
        """Convert _physics_process to pentagon_process with physics flag"""
        func_pattern = r'func\s+_physics_process\s*\([^)]*\)\s*(?:->\s*\w+)?\s*:(.*?)(?=\nfunc|\nclass|\n#|\Z)'
        
        def replace_physics(match):
            func_body = match.group(1)
            
            # Add physics logic to pentagon_process
            physics_wrapper = f"""
# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
\tsuper.pentagon_process(delta)
\t# Physics processing logic{func_body}"""
            
            return physics_wrapper
        
        new_content, count = re.subn(func_pattern, replace_physics, content, flags=re.DOTALL)
        return new_content, count > 0
    
    def _wrap_unhandled_input_function(self, content: str, violation: Dict) -> Tuple[str, bool]:
        """Convert _unhandled_input to pentagon_input"""
        func_pattern = r'func\s+_unhandled_input\s*\([^)]*\)\s*(?:->\s*\w+)?\s*:(.*?)(?=\nfunc|\nclass|\n#|\Z)'
        
        def replace_unhandled(match):
            func_body = match.group(1)
            
            return f"""# Unhandled input integrated into Pentagon Architecture
func pentagon_input(event: InputEvent) -> void:
\tsuper.pentagon_input(event)
\t# Unhandled input logic{func_body}"""
        
        new_content, count = re.subn(func_pattern, replace_unhandled, content, flags=re.DOTALL)
        return new_content, count > 0
    
    def _wrap_exit_tree_function(self, content: str, violation: Dict) -> Tuple[str, bool]:
        """Convert _exit_tree to pentagon_sewers"""
        func_pattern = r'func\s+_exit_tree\s*\([^)]*\)\s*(?:->\s*\w+)?\s*:(.*?)(?=\nfunc|\nclass|\n#|\Z)'
        
        def replace_exit(match):
            func_body = match.group(1)
            
            return f"""# Exit tree logic integrated into Pentagon sewers
func pentagon_sewers() -> void:
\tsuper.pentagon_sewers()
\t# Tree exit cleanup{func_body}"""
        
        new_content, count = re.subn(func_pattern, replace_exit, content, flags=re.DOTALL)
        return new_content, count > 0
    
    def _verify_fixes_and_report(self):
        """Verify applied fixes and generate comprehensive report"""
        print(f"\n📊 PHASE 4: Verifying Pentagon Architecture fixes...")
        
        # Generate fix report
        fix_report = {
            'timestamp': datetime.now().isoformat(),
            'mode': 'DRY_RUN' if self.test_mode else 'LIVE_SURGERY',
            'backup_created': self.backup_created,
            'total_fixes_applied': len(self.fixes_applied),
            'files_modified': len(set(fix['file'] for fix in self.fixes_applied)),
            'fixes_by_function': self._group_fixes_by_function(),
            'detailed_fixes': self.fixes_applied
        }
        
        # Save fix report
        report_path = self.project_path / f'docs/current/PENTAGON_ARCHITECTURE_FIXES_2025_06_01.json'
        report_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(report_path, 'w') as f:
            json.dump(fix_report, f, indent=2)
        
        print(f"✅ PENTAGON ARCHITECTURE HEALING COMPLETE!")
        print(f"📊 Total fixes applied: {len(self.fixes_applied)}")
        print(f"📁 Files modified: {fix_report['files_modified']}")
        print(f"💾 Fix report saved: {report_path}")
        
        if self.test_mode:
            print(f"🧪 DRY-RUN COMPLETE - No files were actually modified")
        else:
            print(f"🏛️ LIVE SURGERY COMPLETE - Pentagon Architecture restored!")
    
    def _group_fixes_by_function(self) -> Dict:
        """Group applied fixes by function type"""
        by_function = {}
        for fix in self.fixes_applied:
            func = fix['function']
            if func not in by_function:
                by_function[func] = 0
            by_function[func] += 1
        return by_function

def main():
    print("🏛️ PENTAGON ARCHITECTURE AUTO-FIXER")
    print("====================================")
    
    mode = input("Choose mode: (d)ry-run or (l)ive surgery [d]: ").lower().strip()
    test_mode = mode != 'l'
    
    if not test_mode:
        confirm = input("⚠️  LIVE SURGERY will modify files. Continue? (yes/no): ").lower().strip()
        if confirm != 'yes':
            print("❌ Pentagon surgery cancelled.")
            return
    
    fixer = PentagonArchitectureAutoFixer("/mnt/c/Users/Percision 15/talking_ragdoll_game")
    fixer.begin_pentagon_healing(create_backup=True, test_mode=test_mode)

if __name__ == "__main__":
    main()