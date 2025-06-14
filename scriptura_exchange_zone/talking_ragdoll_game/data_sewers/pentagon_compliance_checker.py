#!/usr/bin/env python3
"""
Pentagon Architecture Compliance Checker
Verifies all GDScript files follow the "All for One, One for All" Pentagon system:
1. ONE _init() - Initialization phase
2. ONE _ready() - Ready setup phase  
3. ONE _input() - Input handling phase
4. ONE _process() - Logic processing phase
5. ONE sewers() - Cleanup/output phase

Plus Universal Being inheritance requirements.
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Tuple

class PentagonChecker:
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.violations = []
        self.compliant_files = []
        self.stats = {
            'total_files': 0,
            'compliant': 0,
            'violations': 0,
            'critical_violations': 0
        }
    
    def check_file(self, file_path: Path) -> Dict:
        """Check a single GDScript file for Pentagon compliance"""
        result = {
            'file': str(file_path.relative_to(self.project_path)),
            'violations': [],
            'compliant': True,
            'functions_found': {},
            'inheritance': None
        }
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            result['violations'].append(f"Could not read file: {e}")
            result['compliant'] = False
            return result
        
        # Check Pentagon functions
        pentagon_functions = {
            '_init': 0,
            '_ready': 0,
            '_input': 0,
            '_process': 0,
            'sewers': 0  # Custom cleanup function
        }
        
        # Count function definitions
        for func_name in pentagon_functions.keys():
            pattern = rf'func\s+{func_name}\s*\('
            matches = re.findall(pattern, content, re.MULTILINE)
            count = len(matches)
            pentagon_functions[func_name] = count
            result['functions_found'][func_name] = count
            
            # Check violations
            if count == 0:
                result['violations'].append(f"Missing {func_name}() function")
            elif count > 1:
                result['violations'].append(f"Multiple {func_name}() functions found ({count})")
                result['compliant'] = False
        
        # Check Universal Being inheritance
        extends_pattern = r'extends\s+(\w+)'
        extends_matches = re.findall(extends_pattern, content)
        
        if extends_matches:
            inheritance = extends_matches[0]
            result['inheritance'] = inheritance
            
            # Check if inherits from Universal Being
            if inheritance not in ['UniversalBeing', 'UniversalEntity', 'UniversalEntitySystem']:
                if inheritance in ['Node', 'Node3D', 'Control', 'RigidBody3D', 'Camera3D']:
                    result['violations'].append(f"Inherits from {inheritance} instead of UniversalBeing (CRITICAL)")
                    result['compliant'] = False
                else:
                    result['violations'].append(f"Inherits from {inheritance} - verify this inherits from UniversalBeing")
        else:
            result['violations'].append("No inheritance found - should extend UniversalBeing")
            result['compliant'] = False
        
        # Check for direct add_child usage (should use floodgates)
        add_child_pattern = r'\.add_child\s*\('
        add_child_matches = re.findall(add_child_pattern, content)
        if add_child_matches:
            result['violations'].append(f"Direct add_child() usage found ({len(add_child_matches)} times) - should use FloodgateController")
        
        # Check for class_name
        class_name_pattern = r'class_name\s+(\w+)'
        class_name_matches = re.findall(class_name_pattern, content)
        if class_name_matches:
            result['class_name'] = class_name_matches[0]
        
        # Determine compliance
        if result['violations']:
            result['compliant'] = False
        
        return result
    
    def scan_project(self) -> None:
        """Scan entire project for GDScript files"""
        print("🔍 Pentagon Architecture Compliance Checker")
        print("=" * 50)
        print(f"Scanning project: {self.project_path}")
        print()
        
        # Find all .gd files
        gd_files = list(self.project_path.rglob("*.gd"))
        self.stats['total_files'] = len(gd_files)
        
        print(f"📊 Found {len(gd_files)} GDScript files")
        print()
        
        # Check each file
        for file_path in gd_files:
            result = self.check_file(file_path)
            
            if result['compliant']:
                self.compliant_files.append(result)
                self.stats['compliant'] += 1
                print(f"✅ {result['file']}")
            else:
                self.violations.append(result)
                self.stats['violations'] += 1
                
                # Count critical violations
                critical_violations = [v for v in result['violations'] if 'CRITICAL' in v]
                if critical_violations:
                    self.stats['critical_violations'] += 1
                
                print(f"❌ {result['file']}")
                for violation in result['violations']:
                    if 'CRITICAL' in violation:
                        print(f"   🚨 {violation}")
                    else:
                        print(f"   ⚠️  {violation}")
        
        print()
        self.print_summary()
    
    def print_summary(self) -> None:
        """Print compliance summary"""
        print("📋 PENTAGON COMPLIANCE SUMMARY")
        print("=" * 40)
        print(f"Total files scanned: {self.stats['total_files']}")
        print(f"✅ Compliant files: {self.stats['compliant']}")
        print(f"❌ Files with violations: {self.stats['violations']}")
        print(f"🚨 Critical violations: {self.stats['critical_violations']}")
        print()
        
        compliance_rate = (self.stats['compliant'] / self.stats['total_files']) * 100
        print(f"📊 Compliance rate: {compliance_rate:.1f}%")
        print()
        
        if self.stats['critical_violations'] > 0:
            print("🚨 CRITICAL ISSUES FOUND:")
            print("- Scripts extending Node/Node3D instead of UniversalBeing")
            print("- These break the Universal Being architecture!")
            print()
        
        if self.stats['violations'] > 0:
            print("💡 RECOMMENDED ACTIONS:")
            print("1. Convert all scripts to extend UniversalBeing")
            print("2. Ensure each script has exactly one of each Pentagon function")
            print("3. Replace direct add_child() with FloodgateController usage")
            print("4. Implement missing Pentagon functions")
            print()
    
    def save_report(self, output_file: str = "pentagon_compliance_report.json") -> None:
        """Save detailed report to JSON"""
        report = {
            'scan_timestamp': str(Path().cwd()),
            'project_path': str(self.project_path),
            'statistics': self.stats,
            'compliant_files': self.compliant_files,
            'violations': self.violations
        }
        
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2)
        
        print(f"📄 Detailed report saved to: {output_file}")

def main():
    """Main function"""
    project_path = "/mnt/c/Users/Percision 15/talking_ragdoll_game"
    
    checker = PentagonChecker(project_path)
    checker.scan_project()
    checker.save_report()
    
    print()
    print("🏗️ Pentagon Architecture Compliance Check Complete!")
    print("Use this report to guide your Universal Being migration.")

if __name__ == "__main__":
    main()