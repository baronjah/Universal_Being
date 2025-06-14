#!/usr/bin/env python3
"""
🏛️ PENTAGON GODOT VIOLATIONS DETECTIVE - Find All Architecture Breaches
Detect scripts using raw Godot functions instead of Pentagon Architecture
Created: 2025-06-01 | Pentagon Compliance Mission
Author: Detective Claude, Pentagon Architecture Enforcer
"""

import os
import re
from pathlib import Path
from typing import List, Dict, Tuple
import json
from datetime import datetime

class PentagonGodotViolationsDetective:
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.violations = []
        self.compliant_scripts = []
        self.pentagon_functions = {
            "_init": "pentagon_init",
            "_ready": "pentagon_ready", 
            "_process": "pentagon_process",
            "_input": "pentagon_input",
            "sewers": "pentagon_sewers"
        }
        
        # Extended Godot function violations to detect
        self.godot_violations = {
            # Core lifecycle
            "_init": "Pentagon: pentagon_init()",
            "_ready": "Pentagon: pentagon_ready()",
            "_process": "Pentagon: pentagon_process()",
            "_input": "Pentagon: pentagon_input()",
            "_unhandled_input": "Pentagon: pentagon_input() with unhandled check",
            "_gui_input": "Pentagon: pentagon_input() with GUI handling",
            "_physics_process": "Pentagon: pentagon_process() with physics flag",
            
            # Scene tree notifications
            "_enter_tree": "Pentagon: pentagon_ready() with tree entry",
            "_exit_tree": "Pentagon: pentagon_sewers() with tree exit",
            "_tree_entered": "Pentagon: pentagon_ready() variant",
            "_tree_exiting": "Pentagon: pentagon_sewers() variant",
            
            # Drawing and rendering
            "_draw": "Pentagon: pentagon_process() with draw flag",
            "_notification": "Pentagon: pentagon_input() with notification handling",
            
            # Animation and tweening
            "_on_tween_completed": "Pentagon: pentagon_sewers() with tween cleanup",
            "_on_animation_finished": "Pentagon: pentagon_sewers() with animation cleanup",
            
            # Input handling
            "_unhandled_key_input": "Pentagon: pentagon_input() with key filtering",
            "_shortcut_input": "Pentagon: pentagon_input() with shortcut handling",
            
            # Timer and signals
            "_on_timeout": "Pentagon: pentagon_process() with timer logic",
            "_on_timer_timeout": "Pentagon: pentagon_process() with timer logic",
            
            # UI callbacks
            "_on_button_pressed": "Pentagon: pentagon_input() with button logic",
            "_on_item_selected": "Pentagon: pentagon_input() with selection logic",
            "_on_text_changed": "Pentagon: pentagon_input() with text logic",
            "_on_value_changed": "Pentagon: pentagon_input() with value logic",
            
            # Area/body detection
            "_on_body_entered": "Pentagon: pentagon_input() with collision logic",
            "_on_body_exited": "Pentagon: pentagon_sewers() with cleanup logic",
            "_on_area_entered": "Pentagon: pentagon_input() with area logic",
            "_on_area_exited": "Pentagon: pentagon_sewers() with area cleanup",
            
            # Resource loading
            "_resource_changed": "Pentagon: pentagon_process() with resource update",
            "_validate_property": "Pentagon: pentagon_init() with validation"
        }
    
    def begin_investigation(self):
        """Begin comprehensive Pentagon Architecture violation investigation"""
        print("🏛️ PENTAGON GODOT VIOLATIONS DETECTIVE: Starting investigation...")
        print(f"🎯 Mission: Find ALL scripts violating Pentagon Architecture")
        print(f"🔍 Scanning: {self.project_path}")
        print(f"⚖️ Checking for {len(self.godot_violations)} Godot function violations")
        
        # Phase 1: Scan all GDScript files
        self._scan_all_scripts()
        
        # Phase 2: Analyze violation patterns
        self._analyze_violation_patterns()
        
        # Phase 3: Generate comprehensive report
        self._generate_violation_report()
        
        # Phase 4: Create fix recommendations
        self._create_fix_recommendations()
    
    def _scan_all_scripts(self):
        """Scan all GDScript files for Pentagon violations"""
        print("\n🔍 PHASE 1: Scanning all scripts for Pentagon Architecture violations...")
        
        total_files = 0
        
        for gd_file in self.project_path.rglob("*.gd"):
            if self._should_skip_file(gd_file):
                continue
                
            total_files += 1
            violations = self._analyze_file_violations(gd_file)
            
            if violations:
                self.violations.extend(violations)
            else:
                # Check if it's pentagon compliant
                compliance = self._check_pentagon_compliance(gd_file)
                if compliance["is_compliant"]:
                    self.compliant_scripts.append(compliance)
        
        print(f"📊 Scanned: {total_files} files")
        print(f"🚨 Violations found: {len(self.violations)} functions in violation")
        print(f"✅ Compliant scripts: {len(self.compliant_scripts)}")
    
    def _should_skip_file(self, file_path: Path) -> bool:
        """Skip certain directories and files"""
        skip_dirs = {"addons", ".godot", "build", ".git"}
        skip_files = {"project.godot"}
        
        if any(skip_dir in file_path.parts for skip_dir in skip_dirs):
            return True
        if file_path.name in skip_files:
            return True
        return False
    
    def _analyze_file_violations(self, file_path: Path) -> List[Dict]:
        """Analyze single file for Pentagon Architecture violations"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except (UnicodeDecodeError, FileNotFoundError):
            return []
        
        relative_path = str(file_path.relative_to(self.project_path))
        violations = []
        
        # Check for direct Godot function usage
        lines = content.split('\n')
        for line_num, line in enumerate(lines, 1):
            line_stripped = line.strip()
            
            # Skip comments and empty lines
            if line_stripped.startswith('#') or not line_stripped:
                continue
            
            # Check for Godot function violations
            for godot_func, pentagon_replacement in self.godot_violations.items():
                # Match function definitions
                if re.match(rf'func\s+{re.escape(godot_func)}\s*\(', line_stripped):
                    violations.append({
                        'file': relative_path,
                        'line': line_num,
                        'function': godot_func,
                        'violation_type': 'DIRECT_GODOT_FUNCTION',
                        'pentagon_replacement': pentagon_replacement,
                        'code_line': line.strip(),
                        'severity': self._assess_violation_severity(godot_func),
                        'fix_suggestion': self._suggest_pentagon_fix(godot_func, line.strip())
                    })
        
        return violations
    
    def _assess_violation_severity(self, godot_func: str) -> str:
        """Assess how critical this violation is"""
        critical_functions = ['_init', '_ready', '_process', '_input']
        high_priority = ['_enter_tree', '_exit_tree', '_physics_process']
        medium_priority = ['_draw', '_notification', '_unhandled_input']
        
        if godot_func in critical_functions:
            return "🚨 CRITICAL"
        elif godot_func in high_priority:
            return "⚠️ HIGH"
        elif godot_func in medium_priority:
            return "🔶 MEDIUM"
        else:
            return "🔹 LOW"
    
    def _suggest_pentagon_fix(self, godot_func: str, code_line: str) -> str:
        """Suggest specific Pentagon Architecture fix"""
        
        if godot_func == "_init":
            return """func _init() -> void:
    pentagon_init()

func pentagon_init() -> void:
    super.pentagon_init()
    # Your initialization logic here"""
        
        elif godot_func == "_ready":
            return """func _ready() -> void:
    pentagon_ready()

func pentagon_ready() -> void:
    super.pentagon_ready()
    # Your ready logic here"""
        
        elif godot_func == "_process":
            return """func _process(delta: float) -> void:
    pentagon_process(delta)

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    # Your process logic here"""
        
        elif godot_func == "_input":
            return """func _input(event: InputEvent) -> void:
    pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    # Your input logic here"""
        
        elif godot_func.startswith("_on_"):
            return f"""# Move this logic to pentagon_input() or pentagon_process()
# Connect signals through Pentagon Architecture"""
        
        else:
            return f"# Convert {godot_func} to appropriate Pentagon function"
    
    def _check_pentagon_compliance(self, file_path: Path) -> Dict:
        """Check if file follows Pentagon Architecture"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except (UnicodeDecodeError, FileNotFoundError):
            return {"is_compliant": False, "error": "Could not read file"}
        
        relative_path = str(file_path.relative_to(self.project_path))
        
        # Check for Pentagon compliance indicators
        has_pentagon_functions = {}
        has_universal_being = "extends UniversalBeing" in content
        has_class_name = "class_name" in content
        
        for pentagon_func in self.pentagon_functions.values():
            has_pentagon_functions[pentagon_func] = pentagon_func in content
        
        compliance_score = sum(has_pentagon_functions.values()) / len(has_pentagon_functions)
        
        return {
            'file': relative_path,
            'is_compliant': compliance_score >= 0.6 and has_universal_being,
            'has_universal_being': has_universal_being,
            'has_class_name': has_class_name,
            'pentagon_functions': has_pentagon_functions,
            'compliance_score': compliance_score
        }
    
    def _analyze_violation_patterns(self):
        """Analyze patterns in Pentagon violations"""
        print("\n🔍 PHASE 2: Analyzing violation patterns...")
        
        # Group violations by type
        violation_types = {}
        files_with_violations = set()
        
        for violation in self.violations:
            vtype = violation['function']
            if vtype not in violation_types:
                violation_types[vtype] = []
            violation_types[vtype].append(violation)
            files_with_violations.add(violation['file'])
        
        print(f"\n📊 VIOLATION STATISTICS:")
        print(f"  Files with violations: {len(files_with_violations)}")
        print(f"  Total violations: {len(self.violations)}")
        print(f"  Violation types: {len(violation_types)}")
        
        print(f"\n🚨 TOP PENTAGON VIOLATIONS:")
        sorted_violations = sorted(violation_types.items(), 
                                 key=lambda x: len(x[1]), reverse=True)
        
        for i, (func_name, violations_list) in enumerate(sorted_violations[:10], 1):
            severity = violations_list[0]['severity']
            print(f"  {i}. {func_name}: {len(violations_list)} violations {severity}")
    
    def _generate_violation_report(self):
        """Generate comprehensive violation report"""
        print("\n📝 PHASE 3: Generating comprehensive Pentagon violation report...")
        
        # Create detailed report
        report = {
            'timestamp': datetime.now().isoformat(),
            'project_path': str(self.project_path),
            'summary': {
                'total_files_scanned': len(self.violations) + len(self.compliant_scripts),
                'files_with_violations': len(set(v['file'] for v in self.violations)),
                'total_violations': len(self.violations),
                'compliant_scripts': len(self.compliant_scripts),
                'violation_types': len(set(v['function'] for v in self.violations))
            },
            'violations': self.violations,
            'compliant_scripts': self.compliant_scripts,
            'godot_functions_checked': list(self.godot_violations.keys())
        }
        
        # Save detailed report
        report_path = self.project_path / 'docs/current/PENTAGON_GODOT_VIOLATIONS_REPORT_2025_06_01.json'
        report_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(report_path, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"💾 Detailed report saved: {report_path}")
    
    def _create_fix_recommendations(self):
        """Create actionable fix recommendations"""
        print("\n🛠️ PHASE 4: Creating Pentagon Architecture fix recommendations...")
        
        print(f"\n🎯 PRIORITY FIXES FOR GEMMA AND PENTAGON COMPLIANCE:")
        
        # Group by severity
        critical_violations = [v for v in self.violations if v['severity'] == "🚨 CRITICAL"]
        high_violations = [v for v in self.violations if v['severity'] == "⚠️ HIGH"]
        
        print(f"\n🚨 CRITICAL PENTAGON VIOLATIONS ({len(critical_violations)}):")
        for violation in critical_violations[:10]:  # Top 10
            print(f"  📁 {violation['file']}:{violation['line']}")
            print(f"     🚫 {violation['function']} - {violation['pentagon_replacement']}")
            print(f"     💡 {violation['fix_suggestion'][:100]}...")
            print()
        
        print(f"\n⚠️ HIGH PRIORITY VIOLATIONS ({len(high_violations)}):")
        for violation in high_violations[:5]:  # Top 5
            print(f"  📁 {violation['file']}:{violation['line']}")
            print(f"     🚫 {violation['function']}")
        
        # Create fix script template
        print(f"\n🤖 AUTOMATED FIX RECOMMENDATIONS:")
        print(f"  1. Start with CRITICAL violations - they break Pentagon Architecture")
        print(f"  2. Focus on _ready(), _init(), _process(), _input() first")
        print(f"  3. Use surgical modifications, not rewrites")
        print(f"  4. Test each fix before moving to next")
        print(f"  5. Ensure all scripts extend UniversalBeingBase")

def main():
    detective = PentagonGodotViolationsDetective("/mnt/c/Users/Percision 15/talking_ragdoll_game")
    detective.begin_investigation()

if __name__ == "__main__":
    main()