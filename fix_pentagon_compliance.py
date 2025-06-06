#!/usr/bin/env python3
"""
Pentagon Compliance Recovery Tool
================================
Diagnoses and fixes the compliance drop from 94.3% to 44.8% after reorganization.
Focuses on:
1. Broken extends statements pointing to old paths
2. Missing class_name declarations  
3. Lost Pentagon method implementations
4. File encoding issues
"""

import os
import re
from pathlib import Path
from typing import List, Dict, Set

class PentagonComplianceRecovery:
    def __init__(self, project_root=None):
        if project_root is None:
            project_root = os.path.dirname(os.path.abspath(__file__))
        
        self.project_root = Path(project_root)
        self.issues_found = []
        self.fixes_applied = []
        
        # Pentagon method requirements
        self.pentagon_methods = [
            "pentagon_init", "pentagon_ready", "pentagon_process", 
            "pentagon_input", "pentagon_sewers"
        ]
        
        # Valid UniversalBeing paths
        self.valid_ub_paths = [
            "res://core/UniversalBeing.gd",
            "UniversalBeing"  # Direct class reference
        ]
    
    def diagnose_compliance_issues(self):
        """Find all Pentagon compliance issues"""
        print("🔍 DIAGNOSING PENTAGON COMPLIANCE ISSUES")
        print("=" * 50)
        
        # Scan all moved script locations
        scan_directories = [
            "scripts/beings", "scripts/systems", "scripts/tests", 
            "scripts/tools", "scripts/bridges", "scripts/archive",
            "beings", "systems", "components", "core"
        ]
        
        total_scripts = 0
        issue_scripts = 0
        
        for directory in scan_directories:
            dir_path = self.project_root / directory
            if dir_path.exists():
                print(f"\n📂 Scanning {directory}/")
                scripts = list(dir_path.rglob("*.gd"))
                total_scripts += len(scripts)
                
                for script in scripts:
                    issues = self.analyze_script_compliance(script)
                    if issues:
                        issue_scripts += 1
                        self.issues_found.extend(issues)
        
        print(f"\n📊 COMPLIANCE DIAGNOSIS COMPLETE")
        print(f"   Total scripts scanned: {total_scripts}")
        print(f"   Scripts with issues: {issue_scripts}")
        print(f"   Total issues found: {len(self.issues_found)}")
        
        return self.issues_found
    
    def analyze_script_compliance(self, script_path: Path) -> List[Dict]:
        """Analyze a single script for compliance issues"""
        issues = []
        
        try:
            with open(script_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except UnicodeDecodeError:
            try:
                with open(script_path, 'r', encoding='cp1252') as f:
                    content = f.read()
                issues.append({
                    "type": "ENCODING",
                    "file": str(script_path.relative_to(self.project_root)),
                    "message": "File has encoding issues (cp1252 detected)"
                })
            except:
                issues.append({
                    "type": "READ_ERROR", 
                    "file": str(script_path.relative_to(self.project_root)),
                    "message": "Cannot read file"
                })
                return issues
        except:
            issues.append({
                "type": "READ_ERROR",
                "file": str(script_path.relative_to(self.project_root)), 
                "message": "Cannot read file"
            })
            return issues
        
        relative_path = str(script_path.relative_to(self.project_root))
        
        # Check if this should be a Universal Being
        if self.should_be_universal_being(content, script_path.name):
            # Check extends statement
            extends_issues = self.check_extends_statement(content, relative_path)
            issues.extend(extends_issues)
            
            # Check class_name
            if not self.has_class_name(content):
                issues.append({
                    "type": "MISSING_CLASS_NAME",
                    "file": relative_path,
                    "message": "Missing class_name declaration"
                })
            
            # Check Pentagon methods
            pentagon_issues = self.check_pentagon_methods(content, relative_path)
            issues.extend(pentagon_issues)
        
        return issues
    
    def should_be_universal_being(self, content: str, filename: str) -> bool:
        """Determine if script should extend UniversalBeing"""
        # If it extends UniversalBeing (even with wrong path), it should be compliant
        if re.search(r'extends\s+.*Universal.*Being', content):
            return True
        
        # If it has Pentagon methods, it should extend UniversalBeing
        for method in self.pentagon_methods:
            if f"func {method}(" in content:
                return True
        
        # If it's in beings/ folder, it should extend UniversalBeing
        if "beings" in filename or "UniversalBeing" in filename:
            return True
        
        return False
    
    def check_extends_statement(self, content: str, filepath: str) -> List[Dict]:
        """Check extends statement for validity"""
        issues = []
        
        extends_match = re.search(r'extends\s+(.+)', content)
        if not extends_match:
            issues.append({
                "type": "MISSING_EXTENDS",
                "file": filepath,
                "message": "Missing extends statement"
            })
            return issues
        
        extends_value = extends_match.group(1).strip()
        
        # Check for broken paths
        if "res://" in extends_value and "UniversalBeing" in extends_value:
            # This is a path reference, check if it's valid
            if extends_value not in self.valid_ub_paths:
                issues.append({
                    "type": "BROKEN_EXTENDS_PATH",
                    "file": filepath,
                    "message": f"Invalid extends path: {extends_value}",
                    "suggested_fix": "extends UniversalBeing"
                })
        elif extends_value != "UniversalBeing" and "UniversalBeing" not in extends_value:
            # Not extending UniversalBeing at all
            issues.append({
                "type": "WRONG_EXTENDS",
                "file": filepath,
                "message": f"Extends {extends_value} instead of UniversalBeing",
                "suggested_fix": "extends UniversalBeing"
            })
        
        return issues
    
    def has_class_name(self, content: str) -> bool:
        """Check if script has class_name declaration"""
        return bool(re.search(r'class_name\s+\w+', content))
    
    def check_pentagon_methods(self, content: str, filepath: str) -> List[Dict]:
        """Check Pentagon method implementation"""
        issues = []
        
        for method in self.pentagon_methods:
            if f"func {method}(" not in content:
                issues.append({
                    "type": "MISSING_PENTAGON_METHOD",
                    "file": filepath,
                    "message": f"Missing {method}() method"
                })
            else:
                # Check for super() call
                method_pattern = rf"func {method}\([^)]*\).*?(?=func|\Z)"
                method_match = re.search(method_pattern, content, re.DOTALL)
                
                if method_match and f"super.{method}(" not in method_match.group():
                    issues.append({
                        "type": "MISSING_SUPER_CALL",
                        "file": filepath,
                        "message": f"{method}() missing super() call"
                    })
        
        return issues
    
    def fix_compliance_issues(self):
        """Automatically fix common compliance issues"""
        print("\n🔧 APPLYING PENTAGON COMPLIANCE FIXES")
        print("=" * 50)
        
        for issue in self.issues_found:
            if issue["type"] == "BROKEN_EXTENDS_PATH":
                self.fix_extends_path(issue)
            elif issue["type"] == "WRONG_EXTENDS":
                self.fix_extends_statement(issue)
            elif issue["type"] == "MISSING_CLASS_NAME":
                self.fix_class_name(issue)
        
        print(f"\n✅ Applied {len(self.fixes_applied)} fixes")
        
        return self.fixes_applied
    
    def fix_extends_path(self, issue: Dict):
        """Fix broken extends path"""
        file_path = self.project_root / issue["file"]
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Replace broken extends with simple class reference
            old_extends = re.search(r'extends\s+(.+)', content)
            if old_extends:
                new_content = content.replace(old_extends.group(0), "extends UniversalBeing")
                
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                
                self.fixes_applied.append({
                    "file": issue["file"],
                    "fix": f"Changed extends to 'UniversalBeing'"
                })
                print(f"  ✅ Fixed extends in {issue['file']}")
        
        except Exception as e:
            print(f"  ❌ Failed to fix {issue['file']}: {e}")
    
    def fix_extends_statement(self, issue: Dict):
        """Fix wrong extends statement"""
        file_path = self.project_root / issue["file"]
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Replace extends line
            extends_pattern = r'extends\s+.+'
            new_content = re.sub(extends_pattern, "extends UniversalBeing", content, count=1)
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            self.fixes_applied.append({
                "file": issue["file"],
                "fix": "Fixed extends statement to UniversalBeing"
            })
            print(f"  ✅ Fixed extends in {issue['file']}")
        
        except Exception as e:
            print(f"  ❌ Failed to fix {issue['file']}: {e}")
    
    def fix_class_name(self, issue: Dict):
        """Add missing class_name declaration"""
        file_path = self.project_root / issue["file"]
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Generate class name from filename
            filename = Path(issue["file"]).stem
            class_name = ''.join(word.capitalize() for word in filename.split('_'))
            
            # Insert class_name after extends line
            extends_match = re.search(r'(extends\s+.+\n)', content)
            if extends_match:
                insert_pos = extends_match.end()
                new_content = (content[:insert_pos] + 
                             f"class_name {class_name}\n" + 
                             content[insert_pos:])
                
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                
                self.fixes_applied.append({
                    "file": issue["file"],
                    "fix": f"Added class_name {class_name}"
                })
                print(f"  ✅ Added class_name to {issue['file']}")
        
        except Exception as e:
            print(f"  ❌ Failed to fix {issue['file']}: {e}")
    
    def generate_compliance_report(self):
        """Generate detailed compliance recovery report"""
        report_path = self.project_root / "docs" / "PENTAGON_COMPLIANCE_RECOVERY.md"
        report_path.parent.mkdir(exist_ok=True)
        
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write("# Pentagon Compliance Recovery Report\n\n")
            f.write("## Issues Found\n\n")
            
            # Group issues by type
            issues_by_type = {}
            for issue in self.issues_found:
                issue_type = issue["type"]
                if issue_type not in issues_by_type:
                    issues_by_type[issue_type] = []
                issues_by_type[issue_type].append(issue)
            
            for issue_type, issues in issues_by_type.items():
                f.write(f"### {issue_type} ({len(issues)} files)\n")
                for issue in issues[:10]:  # Show first 10
                    f.write(f"- `{issue['file']}`: {issue['message']}\n")
                if len(issues) > 10:
                    f.write(f"... and {len(issues) - 10} more files\n")
                f.write("\n")
            
            f.write("## Fixes Applied\n\n")
            for fix in self.fixes_applied:
                f.write(f"- `{fix['file']}`: {fix['fix']}\n")
            
            f.write(f"\n## Summary\n")
            f.write(f"- **Issues Found**: {len(self.issues_found)}\n")
            f.write(f"- **Fixes Applied**: {len(self.fixes_applied)}\n")
            f.write(f"- **Remaining Issues**: {len(self.issues_found) - len(self.fixes_applied)}\n")
        
        print(f"\n📄 Recovery report saved to: {report_path}")
    
    def run_recovery(self):
        """Execute complete Pentagon compliance recovery"""
        print("🏗️ PENTAGON COMPLIANCE RECOVERY TOOL")
        print("Diagnosing compliance drop from 94.3% → 44.8%")
        print("=" * 60)
        
        # Diagnose issues
        self.diagnose_compliance_issues()
        
        # Apply fixes
        if self.issues_found:
            self.fix_compliance_issues()
        
        # Generate report
        self.generate_compliance_report()
        
        print("\n🏆 Pentagon compliance recovery complete!")
        print(f"   Run 'python validate_pentagon.py' to verify improvements")

def main():
    recovery = PentagonComplianceRecovery()
    recovery.run_recovery()

if __name__ == "__main__":
    main()