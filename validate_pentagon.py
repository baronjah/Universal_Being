#!/usr/bin/env python3
"""
Pentagon Architecture Validator
==============================
Validates that all Universal Being scripts follow the Pentagon Architecture rules.

PENTAGON RULES (The 5 Sacred Methods):
1. pentagon_init() -> void     # Birth - ALWAYS call super.pentagon_init() first
2. pentagon_ready() -> void    # Awakening - ALWAYS call super.pentagon_ready() first  
3. pentagon_process(delta: float) -> void  # Living - ALWAYS call super.pentagon_process(delta) first
4. pentagon_input(event: InputEvent) -> void  # Sensing - ALWAYS call super.pentagon_input(event) first
5. pentagon_sewers() -> void   # Death/Transformation - ALWAYS call super.pentagon_sewers() last

UNIVERSAL BEING RULES:
- Must extend UniversalBeing (or be UniversalBeing itself)
- Must have proper class_name declaration
- Must implement consciousness levels properly
- Must follow Pentagon lifecycle
- Must call super() methods correctly
"""

import os
import re
from pathlib import Path
from typing import Dict, List, Set
from datetime import datetime

class PentagonValidator:
    def __init__(self, project_root: str):
        self.root = Path(project_root)
        self.violations = []
        self.compliant_files = []
        self.non_ub_files = []  # Files that don't need to be Universal Beings
        
        # Pentagon methods that must be implemented
        self.pentagon_methods = {
            'pentagon_init': {
                'signature': r'func\s+pentagon_init\s*\(\s*\)\s*->\s*void:',
                'super_call': r'super\.pentagon_init\(\)',
                'super_position': 'first'
            },
            'pentagon_ready': {
                'signature': r'func\s+pentagon_ready\s*\(\s*\)\s*->\s*void:',
                'super_call': r'super\.pentagon_ready\(\)',
                'super_position': 'first'
            },
            'pentagon_process': {
                'signature': r'func\s+pentagon_process\s*\(\s*delta\s*:\s*float\s*\)\s*->\s*void:',
                'super_call': r'super\.pentagon_process\s*\(\s*delta\s*\)',
                'super_position': 'first'
            },
            'pentagon_input': {
                'signature': r'func\s+pentagon_input\s*\(\s*event\s*:\s*InputEvent\s*\)\s*->\s*void:',
                'super_call': r'super\.pentagon_input\s*\(\s*event\s*\)',
                'super_position': 'first'
            },
            'pentagon_sewers': {
                'signature': r'func\s+pentagon_sewers\s*\(\s*\)\s*->\s*void:',
                'super_call': r'super\.pentagon_sewers\s*\(\)',
                'super_position': 'last'
            }
        }
        
        # Files that are exempt from Universal Being rules
        self.exempt_files = {
            'SystemBootstrap.gd', 'GemmaAI.gd',  # Autoloads
            'clean_project.py', 'validate_pentagon.py'  # Tools
        }
        
        # Non-Universal Being core files
        self.core_system_files = {
            'UniversalBeing.gd',  # Base class - doesn't extend itself!
            'FloodGates.gd', 'Pentagon.gd', 'PentagonManager.gd',
            'AkashicRecords.gd', 'AkashicRecordsEnhanced.gd', 'AkashicRecordsSystem.gd',
            'Component.gd', 'Connector.gd', 'ZipPackageManager.gd',
            'UniversalBeingDNA.gd', 'UniversalBeingSocket.gd', 'UniversalBeingSocketManager.gd',
            'akashic_living_database.gd', 'input_focus_manager.gd', 'macro_system.gd'
        }

    def validate_project(self):
        """Run complete Pentagon validation on the project"""
        print("🔍 PENTAGON ARCHITECTURE VALIDATOR")
        print("=" * 50)
        print(f"📁 Project: {self.root}")
        print(f"⚡ Validating Universal Being compliance...")
        print()
        
        # Scan all .gd files in relevant directories
        scan_dirs = ['autoloads', 'core', 'scripts', 'beings']
        
        for directory in scan_dirs:
            dir_path = self.root / directory
            if dir_path.exists():
                self._scan_directory(dir_path, directory)
        
        # Generate report
        self._generate_report()
        
        print(f"✅ Validation complete! See docs/PENTAGON_VALIDATION_REPORT.md")

    def _scan_directory(self, directory: Path, dir_name: str):
        """Scan a directory for .gd files and validate them"""
        print(f"🔍 Scanning {dir_name}/...")
        
        for gd_file in directory.rglob('*.gd'):
            if gd_file.name in self.exempt_files:
                continue
                
            self._validate_file(gd_file, dir_name)

    def _validate_file(self, file_path: Path, directory: str):
        """Validate a single .gd file for Pentagon compliance"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            self.violations.append({
                'file': str(file_path.relative_to(self.root)),
                'type': 'READ_ERROR',
                'message': f"Could not read file: {e}"
            })
            return
        
        file_rel = str(file_path.relative_to(self.root))
        
        # Check if this should be a Universal Being
        is_universal_being = self._is_universal_being_file(content, file_path.name)
        
        if not is_universal_being:
            self.non_ub_files.append(file_rel)
            return
        
        # Validate Universal Being compliance
        violations = []
        
        # Check Universal Being inheritance
        if not self._check_universal_being_inheritance(content):
            violations.append("Missing 'extends UniversalBeing' declaration")
        
        # Check class_name declaration
        if not self._check_class_name(content):
            violations.append("Missing proper 'class_name' declaration")
        
        # Check Pentagon methods
        pentagon_violations = self._check_pentagon_methods(content)
        violations.extend(pentagon_violations)
        
        # Check consciousness level
        if not self._check_consciousness_level(content):
            violations.append("Missing consciousness_level assignment")
        
        # Check being_type and being_name
        if not self._check_being_properties(content):
            violations.append("Missing being_type or being_name assignment")
        
        if violations:
            self.violations.append({
                'file': file_rel,
                'type': 'PENTAGON_VIOLATION',
                'violations': violations
            })
        else:
            self.compliant_files.append(file_rel)

    def _is_universal_being_file(self, content: str, filename: str) -> bool:
        """Determine if this file should be a Universal Being"""
        # Exempt files
        if filename in self.exempt_files or filename in self.core_system_files:
            return False
        
        # If it extends UniversalBeing, it should follow rules
        if re.search(r'extends\s+UniversalBeing', content):
            return True
        
        # If it's in beings/ directory, it should be a Universal Being
        if 'beings/' in str(filename):
            return True
        
        # If it has Pentagon methods, it should be a Universal Being
        for method in self.pentagon_methods:
            if re.search(self.pentagon_methods[method]['signature'], content):
                return True
        
        return False

    def _check_universal_being_inheritance(self, content: str) -> bool:
        """Check if file properly extends UniversalBeing"""
        return bool(re.search(r'extends\s+UniversalBeing', content))

    def _check_class_name(self, content: str) -> bool:
        """Check if file has proper class_name declaration"""
        return bool(re.search(r'class_name\s+\w+', content))

    def _check_pentagon_methods(self, content: str) -> List[str]:
        """Check Pentagon method implementation and super() calls"""
        violations = []
        
        for method_name, rules in self.pentagon_methods.items():
            # Check if method exists
            method_match = re.search(rules['signature'], content)
            if not method_match:
                violations.append(f"Missing {method_name}() method")
                continue
            
            # Extract method body
            method_body = self._extract_method_body(content, method_match.start())
            
            # Check super() call
            super_call_match = re.search(rules['super_call'], method_body)
            if not super_call_match:
                violations.append(f"{method_name}() missing super() call")
                continue
            
            # Check super() call position
            if not self._check_super_position(method_body, super_call_match, rules['super_position']):
                position = rules['super_position']
                violations.append(f"{method_name}() super() call must be {position}")
        
        return violations

    def _extract_method_body(self, content: str, method_start: int) -> str:
        """Extract the body of a method from content"""
        lines = content[method_start:].split('\n')
        body_lines = []
        indent_level = None
        
        for i, line in enumerate(lines):
            if i == 0:  # Method signature line
                body_lines.append(line)
                continue
            
            # Determine indentation level from first non-empty line
            if indent_level is None and line.strip():
                indent_level = len(line) - len(line.lstrip())
            
            # If we hit a line with same or less indentation, method is done
            if line.strip() and indent_level is not None:
                current_indent = len(line) - len(line.lstrip())
                if current_indent <= indent_level - 1:  # Allow for method end
                    break
            
            body_lines.append(line)
            
            # Stop after reasonable number of lines
            if len(body_lines) > 50:
                break
        
        return '\n'.join(body_lines)

    def _check_super_position(self, method_body: str, super_match, expected_position: str) -> bool:
        """Check if super() call is in the correct position"""
        lines = method_body.split('\n')
        super_line_idx = None
        
        # Find which line has the super() call
        for i, line in enumerate(lines):
            if super_match.group() in line:
                super_line_idx = i
                break
        
        if super_line_idx is None:
            return False
        
        # Count non-comment, non-empty lines
        code_lines = []
        for line in lines[1:]:  # Skip method signature
            stripped = line.strip()
            if stripped and not stripped.startswith('#'):
                code_lines.append(line)
        
        if not code_lines:
            return True  # Only super() call, that's fine
        
        super_code_idx = None
        for i, line in enumerate(code_lines):
            if super_match.group() in line:
                super_code_idx = i
                break
        
        if expected_position == 'first':
            return super_code_idx == 0
        elif expected_position == 'last':
            return super_code_idx == len(code_lines) - 1
        
        return True

    def _check_consciousness_level(self, content: str) -> bool:
        """Check if consciousness_level is properly assigned"""
        return bool(re.search(r'consciousness_level\s*=\s*\d+', content))

    def _check_being_properties(self, content: str) -> bool:
        """Check if being_type and being_name are assigned"""
        has_type = bool(re.search(r'being_type\s*=\s*["\'][\w_]+["\']', content))
        has_name = bool(re.search(r'being_name\s*=\s*["\'][^"\']+["\']', content))
        return has_type and has_name

    def _generate_report(self):
        """Generate validation report"""
        report_path = self.root / 'docs' / 'PENTAGON_VALIDATION_REPORT.md'
        report_path.parent.mkdir(exist_ok=True)
        
        total_files = len(self.compliant_files) + len(self.violations)
        compliance_rate = (len(self.compliant_files) / total_files * 100) if total_files > 0 else 100
        
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write("# Pentagon Architecture Validation Report\n\n")
            f.write(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  \n")
            f.write(f"**Compliance Rate:** {compliance_rate:.1f}%  \n")
            f.write(f"**Total Files Scanned:** {total_files}  \n\n")
            
            # Summary
            f.write("## 📊 Summary\n\n")
            f.write(f"- ✅ **Compliant Files:** {len(self.compliant_files)}\n")
            f.write(f"- ❌ **Files with Violations:** {len(self.violations)}\n")
            f.write(f"- ⚪ **Non-Universal Being Files:** {len(self.non_ub_files)}\n\n")
            
            # Pentagon Rules Reminder
            f.write("## 🔥 Pentagon Architecture Rules\n\n")
            f.write("All Universal Beings MUST implement these 5 sacred methods:\n\n")
            f.write("1. `pentagon_init()` - Birth (super() call FIRST)\n")
            f.write("2. `pentagon_ready()` - Awakening (super() call FIRST)\n")
            f.write("3. `pentagon_process(delta)` - Living (super() call FIRST)\n")
            f.write("4. `pentagon_input(event)` - Sensing (super() call FIRST)\n")
            f.write("5. `pentagon_sewers()` - Death/Transformation (super() call LAST)\n\n")
            
            # Violations
            if self.violations:
                f.write("## ❌ Pentagon Violations\n\n")
                for violation in self.violations:
                    f.write(f"### `{violation['file']}`\n")
                    if violation['type'] == 'READ_ERROR':
                        f.write(f"- 🚨 **Error:** {violation['message']}\n\n")
                    else:
                        for v in violation['violations']:
                            f.write(f"- ❌ {v}\n")
                        f.write("\n")
            
            # Compliant Files
            if self.compliant_files:
                f.write("## ✅ Pentagon Compliant Files\n\n")
                for file in sorted(self.compliant_files):
                    f.write(f"- ✅ `{file}`\n")
                f.write("\n")
            
            # Non-Universal Being Files
            if self.non_ub_files:
                f.write("## ⚪ Non-Universal Being Files (Exempt)\n\n")
                for file in sorted(self.non_ub_files):
                    f.write(f"- ⚪ `{file}`\n")
                f.write("\n")
            
            # Recommendations
            f.write("## 🎯 Recommendations\n\n")
            if self.violations:
                f.write("1. **Fix Pentagon Violations:** All Universal Beings must follow the 5 sacred methods\n")
                f.write("2. **Add Missing super() Calls:** Ensure proper inheritance chain\n")
                f.write("3. **Set Consciousness Levels:** All beings need consciousness_level assignment\n")
                f.write("4. **Define Being Properties:** Set being_type and being_name properly\n")
            else:
                f.write("🎉 **Perfect Pentagon Compliance!** All Universal Beings follow the sacred architecture.\n")
        
        # Console summary
        print("📊 VALIDATION SUMMARY")
        print("=" * 30)
        print(f"✅ Compliant: {len(self.compliant_files)}")
        print(f"❌ Violations: {len(self.violations)}")
        print(f"⚪ Non-UB Files: {len(self.non_ub_files)}")
        print(f"📈 Compliance: {compliance_rate:.1f}%")
        print()

def main():
    """Main validation function"""
    # Get project root from current script location
    project_root = os.path.dirname(os.path.abspath(__file__))
    validator = PentagonValidator(project_root)
    validator.validate_project()

if __name__ == "__main__":
    main()