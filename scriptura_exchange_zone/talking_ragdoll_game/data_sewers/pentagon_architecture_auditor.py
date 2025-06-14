#!/usr/bin/env python3
"""
PERFECT PENTAGON ARCHITECTURE AUDITOR
=====================================
Scans all GDScript files to ensure Perfect Pentagon compliance

Rules:
- One _ready() function per script
- One _init() function per script (optional)
- One _process() function per script (optional)
- One _input() function per script (optional)
- Proper Perfect Pentagon phase comments
- Floodgate integration compliance
- Universal Being pattern compliance

Created: May 31st, 2025
Purpose: Maintain architectural purity in the Perfect Pentagon system
"""

import os
import re
import json
from typing import Dict, List, Set
from dataclasses import dataclass, asdict
from pathlib import Path

@dataclass
class ScriptAnalysis:
    """Analysis results for a single GDScript file"""
    file_path: str
    class_name: str
    extends_from: str
    
    # Function counts (should be 0 or 1 for each)
    ready_count: int = 0
    init_count: int = 0
    process_count: int = 0
    input_count: int = 0
    unhandled_input_count: int = 0
    
    # Perfect Pentagon compliance
    has_pentagon_header: bool = False
    has_phase_comments: bool = False
    has_floodgate_integration: bool = False
    has_universal_being_pattern: bool = False
    
    # Architecture violations
    violations: List[str] = None
    warnings: List[str] = None
    
    # Function signatures found
    function_signatures: List[str] = None
    
    def __post_init__(self):
        if self.violations is None:
            self.violations = []
        if self.warnings is None:
            self.warnings = []
        if self.function_signatures is None:
            self.function_signatures = []

class PentagonArchitectureAuditor:
    """Audits GDScript files for Perfect Pentagon architecture compliance"""
    
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.scripts_dir = self.project_root / "scripts"
        self.results: List[ScriptAnalysis] = []
        
        # Perfect Pentagon patterns to look for
        self.pentagon_patterns = {
            'pentagon_header': re.compile(r'PERFECT PENTAGON|Perfect Pentagon|pentagon', re.IGNORECASE),
            'phase_comments': re.compile(r'PHASE [0-9]|Perfect (Init|Ready|Input|Logic|Sewers)', re.IGNORECASE),
            'floodgate_integration': re.compile(r'floodgate|FloodgateController', re.IGNORECASE),
            'universal_being': re.compile(r'UniversalBeing|universal_being', re.IGNORECASE)
        }
        
        # Function patterns
        self.function_patterns = {
            'ready': re.compile(r'func\s+_ready\s*\('),
            'init': re.compile(r'func\s+_init\s*\('),
            'process': re.compile(r'func\s+_process\s*\('),
            'input': re.compile(r'func\s+_input\s*\('),
            'unhandled_input': re.compile(r'func\s+_unhandled_input\s*\('),
            'all_functions': re.compile(r'func\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(([^)]*)\)')
        }
    
    def scan_all_scripts(self) -> List[ScriptAnalysis]:
        """Scan all GDScript files in the project"""
        print(f"🔍 Scanning GDScript files in: {self.scripts_dir}")
        
        gd_files = list(self.scripts_dir.rglob("*.gd"))
        print(f"📁 Found {len(gd_files)} GDScript files")
        
        for gd_file in gd_files:
            try:
                analysis = self.analyze_script(gd_file)
                self.results.append(analysis)
                print(f"✅ Analyzed: {gd_file.relative_to(self.project_root)}")
            except Exception as e:
                print(f"❌ Error analyzing {gd_file}: {e}")
        
        return self.results
    
    def analyze_script(self, file_path: Path) -> ScriptAnalysis:
        """Analyze a single GDScript file"""
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Create analysis object
        analysis = ScriptAnalysis(
            file_path=str(file_path.relative_to(self.project_root)),
            class_name=self.extract_class_name(content),
            extends_from=self.extract_extends(content)
        )
        
        # Count core functions
        analysis.ready_count = len(self.function_patterns['ready'].findall(content))
        analysis.init_count = len(self.function_patterns['init'].findall(content))
        analysis.process_count = len(self.function_patterns['process'].findall(content))
        analysis.input_count = len(self.function_patterns['input'].findall(content))
        analysis.unhandled_input_count = len(self.function_patterns['unhandled_input'].findall(content))
        
        # Check Perfect Pentagon patterns
        analysis.has_pentagon_header = bool(self.pentagon_patterns['pentagon_header'].search(content))
        analysis.has_phase_comments = bool(self.pentagon_patterns['phase_comments'].search(content))
        analysis.has_floodgate_integration = bool(self.pentagon_patterns['floodgate_integration'].search(content))
        analysis.has_universal_being_pattern = bool(self.pentagon_patterns['universal_being'].search(content))
        
        # Extract all function signatures
        all_functions = self.function_patterns['all_functions'].findall(content)
        analysis.function_signatures = [f"func {name}({args})" for name, args in all_functions]
        
        # Check for violations
        self.check_violations(analysis)
        
        return analysis
    
    def extract_class_name(self, content: str) -> str:
        """Extract class name from script"""
        class_match = re.search(r'class_name\s+([a-zA-Z_][a-zA-Z0-9_]*)', content)
        return class_match.group(1) if class_match else "Anonymous"
    
    def extract_extends(self, content: str) -> str:
        """Extract extends declaration"""
        extends_match = re.search(r'extends\s+([a-zA-Z_][a-zA-Z0-9_]*)', content)
        return extends_match.group(1) if extends_match else "Node"
    
    def check_violations(self, analysis: ScriptAnalysis):
        """Check for Perfect Pentagon architecture violations"""
        
        # Core function violations
        if analysis.ready_count > 1:
            analysis.violations.append(f"Multiple _ready() functions ({analysis.ready_count})")
        if analysis.init_count > 1:
            analysis.violations.append(f"Multiple _init() functions ({analysis.init_count})")
        if analysis.process_count > 1:
            analysis.violations.append(f"Multiple _process() functions ({analysis.process_count})")
        if analysis.input_count > 1:
            analysis.violations.append(f"Multiple _input() functions ({analysis.input_count})")
        
        # Architecture warnings
        if not analysis.has_pentagon_header and analysis.ready_count > 0:
            analysis.warnings.append("Missing Perfect Pentagon header/documentation")
        
        if analysis.ready_count > 0 and not analysis.has_phase_comments:
            analysis.warnings.append("Missing Perfect Pentagon phase comments")
        
        # Check for potential system integrations
        if analysis.extends_from in ["Control", "Node3D", "Node2D"] and not analysis.has_floodgate_integration:
            analysis.warnings.append("Core node type should integrate with Floodgate system")
    
    def generate_report(self) -> Dict:
        """Generate comprehensive audit report"""
        
        total_scripts = len(self.results)
        violation_scripts = [r for r in self.results if r.violations]
        warning_scripts = [r for r in self.results if r.warnings]
        compliant_scripts = [r for r in self.results if not r.violations and not r.warnings]
        
        # Function distribution
        ready_functions = sum(1 for r in self.results if r.ready_count > 0)
        init_functions = sum(1 for r in self.results if r.init_count > 0)
        process_functions = sum(1 for r in self.results if r.process_count > 0)
        input_functions = sum(1 for r in self.results if r.input_count > 0)
        
        # Pentagon pattern adoption
        pentagon_headers = sum(1 for r in self.results if r.has_pentagon_header)
        phase_comments = sum(1 for r in self.results if r.has_phase_comments)
        floodgate_integration = sum(1 for r in self.results if r.has_floodgate_integration)
        universal_being_pattern = sum(1 for r in self.results if r.has_universal_being_pattern)
        
        report = {
            "audit_summary": {
                "total_scripts": total_scripts,
                "compliant_scripts": len(compliant_scripts),
                "scripts_with_violations": len(violation_scripts),
                "scripts_with_warnings": len(warning_scripts),
                "compliance_percentage": round((len(compliant_scripts) / total_scripts) * 100, 2) if total_scripts > 0 else 0
            },
            "function_distribution": {
                "scripts_with_ready": ready_functions,
                "scripts_with_init": init_functions,
                "scripts_with_process": process_functions,
                "scripts_with_input": input_functions
            },
            "pentagon_pattern_adoption": {
                "pentagon_headers": pentagon_headers,
                "phase_comments": phase_comments,
                "floodgate_integration": floodgate_integration,
                "universal_being_pattern": universal_being_pattern
            },
            "violation_details": [asdict(r) for r in violation_scripts],
            "warning_details": [asdict(r) for r in warning_scripts],
            "compliant_scripts": [r.file_path for r in compliant_scripts]
        }
        
        return report
    
    def print_summary_report(self):
        """Print a human-readable summary report"""
        report = self.generate_report()
        
        print("\n" + "="*60)
        print("🎯 PERFECT PENTAGON ARCHITECTURE AUDIT REPORT")
        print("="*60)
        
        summary = report["audit_summary"]
        print(f"📊 OVERVIEW:")
        print(f"   Total Scripts: {summary['total_scripts']}")
        print(f"   ✅ Compliant: {summary['compliant_scripts']}")
        print(f"   ⚠️  Warnings: {summary['scripts_with_warnings']}")
        print(f"   ❌ Violations: {summary['scripts_with_violations']}")
        print(f"   📈 Compliance: {summary['compliance_percentage']}%")
        
        func_dist = report["function_distribution"]
        print(f"\n🔧 FUNCTION DISTRIBUTION:")
        print(f"   _ready() functions: {func_dist['scripts_with_ready']}")
        print(f"   _init() functions: {func_dist['scripts_with_init']}")
        print(f"   _process() functions: {func_dist['scripts_with_process']}")
        print(f"   _input() functions: {func_dist['scripts_with_input']}")
        
        pentagon = report["pentagon_pattern_adoption"]
        print(f"\n🌟 PERFECT PENTAGON ADOPTION:")
        print(f"   Pentagon Headers: {pentagon['pentagon_headers']}")
        print(f"   Phase Comments: {pentagon['phase_comments']}")
        print(f"   Floodgate Integration: {pentagon['floodgate_integration']}")
        print(f"   Universal Being Pattern: {pentagon['universal_being_pattern']}")
        
        # Show top violations
        if report["violation_details"]:
            print(f"\n❌ TOP VIOLATIONS:")
            for violation in report["violation_details"][:5]:
                print(f"   📁 {violation['file_path']}")
                for v in violation['violations']:
                    print(f"      🚨 {v}")
        
        # Show samples of warnings
        if report["warning_details"]:
            print(f"\n⚠️  SAMPLE WARNINGS:")
            for warning in report["warning_details"][:5]:
                print(f"   📁 {warning['file_path']}")
                for w in warning['warnings']:
                    print(f"      ⚠️  {w}")
        
        print("\n" + "="*60)
        print("🎮 READY TO OPTIMIZE YOUR PERFECT PENTAGON! 🌟")
        print("="*60)

def main():
    """Main execution function"""
    project_root = "/mnt/c/Users/Percision 15/talking_ragdoll_game"
    
    print("🎯 PERFECT PENTAGON ARCHITECTURE AUDITOR")
    print("=" * 50)
    
    auditor = PentagonArchitectureAuditor(project_root)
    results = auditor.scan_all_scripts()
    
    # Print summary
    auditor.print_summary_report()
    
    # Save detailed report
    report = auditor.generate_report()
    report_file = Path(project_root) / "pentagon_audit_report.json"
    
    with open(report_file, 'w') as f:
        json.dump(report, f, indent=2)
    
    print(f"\n📄 Detailed report saved to: {report_file}")
    print(f"🔍 Analyzed {len(results)} scripts total")

if __name__ == "__main__":
    main()