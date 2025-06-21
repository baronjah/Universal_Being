#!/usr/bin/env python3
"""
==================================================
PERFECT SYSTEMS SCRIPTURA - Universal Being Project
==================================================
DESCRIPTION: Comprehensive systems folder analysis and management
PURPOSE: Add systems folder to python scriptura with perfect tools
CREATED: 2025-06-15 - Universal Being Revolution
AUTHOR: Claude Code + JSH
==================================================
"""

import os
import re
import json
from pathlib import Path
from typing import Dict, List, Tuple

class UniversalBeingSystemsAnalyzer:
    """Perfect analyzer for Universal Being systems folder"""
    
    def __init__(self):
        self.systems_path = Path("/mnt/c/Users/Percision 15/Universal_Being/systems")
        self.analysis_results = {}
        self.system_map = {}
        
    def analyze_all_systems(self) -> Dict:
        """Analyze the entire systems folder comprehensively"""
        print("🌌 PERFECT SYSTEMS SCRIPTURA - Universal Being Analysis")
        print("="*60)
        
        if not self.systems_path.exists():
            print("❌ Systems folder not found!")
            return {}
            
        # Scan all system files
        system_files = list(self.systems_path.rglob("*.gd"))
        print(f"📊 Found {len(system_files)} system files")
        
        for file_path in system_files:
            print(f"🔍 Analyzing: {file_path.relative_to(self.systems_path)}")
            self.analysis_results[str(file_path)] = self._analyze_system_file(file_path)
            
        # Generate system map
        self._generate_system_map()
        
        # Generate summary report
        self._generate_summary_report()
        
        return self.analysis_results
    
    def _analyze_system_file(self, file_path: Path) -> Dict:
        """Analyze individual system file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            analysis = {
                "file_name": file_path.name,
                "relative_path": str(file_path.relative_to(self.systems_path)),
                "size_bytes": len(content),
                "lines": len(content.splitlines()),
                "class_name": self._extract_class_name(content),
                "extends": self._extract_extends(content),
                "exports": self._extract_exports(content),
                "functions": self._extract_functions(content),
                "pentagon_methods": self._extract_pentagon_methods(content),
                "signals": self._extract_signals(content),
                "dependencies": self._extract_dependencies(content),
                "complexity": self._calculate_complexity(content),
                "consciousness_integration": self._check_consciousness_integration(content),
                "universal_being_compliance": self._check_ub_compliance(content),
                "syntax_health": self._check_syntax_health(content)
            }
            
            return analysis
            
        except Exception as e:
            return {"error": str(e), "file_name": file_path.name}
    
    def _extract_class_name(self, content: str) -> str:
        """Extract class name from content"""
        match = re.search(r'class_name\s+(\w+)', content)
        return match.group(1) if match else "NoClassName"
    
    def _extract_extends(self, content: str) -> str:
        """Extract what the class extends"""
        match = re.search(r'extends\s+(\w+)', content)
        return match.group(1) if match else "Node"
    
    def _extract_exports(self, content: str) -> List[str]:
        """Extract all @export variables"""
        return re.findall(r'@export\s+var\s+(\w+)', content)
    
    def _extract_functions(self, content: str) -> List[str]:
        """Extract all function names"""
        return re.findall(r'func\s+(\w+)\s*\(', content)
    
    def _extract_pentagon_methods(self, content: str) -> List[str]:
        """Extract Pentagon architecture methods"""
        pentagon_methods = ['pentagon_init', 'pentagon_ready', 'pentagon_process', 'pentagon_input', 'pentagon_sewers']
        found_methods = []
        for method in pentagon_methods:
            if f'func {method}(' in content:
                found_methods.append(method)
        return found_methods
    
    def _extract_signals(self, content: str) -> List[str]:
        """Extract signal declarations"""
        return re.findall(r'signal\s+(\w+)', content)
    
    def _extract_dependencies(self, content: str) -> List[str]:
        """Extract dependencies (preload, get_node calls, etc)"""
        dependencies = []
        
        # Preload statements
        preloads = re.findall(r'preload\s*\(\s*["\']([^"\']+)["\']', content)
        dependencies.extend([f"preload:{dep}" for dep in preloads])
        
        # get_node calls
        nodes = re.findall(r'get_node\s*\(\s*["\']([^"\']+)["\']', content)
        dependencies.extend([f"node:{dep}" for dep in nodes])
        
        # Other class references
        classes = re.findall(r'(\w+UniversalBeing|\w+Manager|\w+System)', content)
        dependencies.extend([f"class:{dep}" for dep in set(classes)])
        
        return list(set(dependencies))
    
    def _calculate_complexity(self, content: str) -> Dict:
        """Calculate complexity metrics"""
        lines = content.splitlines()
        
        return {
            "total_lines": len(lines),
            "code_lines": len([l for l in lines if l.strip() and not l.strip().startswith('#')]),
            "comment_lines": len([l for l in lines if l.strip().startswith('#')]),
            "function_count": len(re.findall(r'func\s+\w+', content)),
            "variable_count": len(re.findall(r'var\s+\w+', content)),
            "if_statements": len(re.findall(r'\bif\b', content)),
            "for_loops": len(re.findall(r'\bfor\b', content)),
            "while_loops": len(re.findall(r'\bwhile\b', content))
        }
    
    def _check_consciousness_integration(self, content: str) -> Dict:
        """Check consciousness-related integration"""
        consciousness_features = {
            "consciousness_level": "consciousness_level" in content,
            "awakening": "awaken" in content.lower(),
            "evolution": "evolve" in content.lower() or "evolution" in content.lower(),
            "transcendence": "transcend" in content.lower(),
            "aura_effects": "aura" in content.lower() or "glow" in content.lower(),
            "consciousness_colors": "_get_consciousness_color" in content,
            "resonance": "resonance" in content.lower()
        }
        
        return {
            "features": consciousness_features,
            "integration_score": sum(consciousness_features.values()) / len(consciousness_features)
        }
    
    def _check_ub_compliance(self, content: str) -> Dict:
        """Check Universal Being compliance"""
        compliance_checks = {
            "extends_universal_being": "extends UniversalBeing" in content,
            "pentagon_architecture": len(self._extract_pentagon_methods(content)) >= 3,
            "being_uuid": "being_uuid" in content,
            "flood_gates": "FloodGate" in content or "flood_gate" in content,
            "akashic_records": "Akashic" in content,
            "socket_system": "socket" in content.lower(),
            "component_system": "component" in content.lower()
        }
        
        return {
            "checks": compliance_checks,
            "compliance_score": sum(compliance_checks.values()) / len(compliance_checks)
        }
    
    def _check_syntax_health(self, content: str) -> Dict:
        """Check basic syntax health"""
        health_checks = {
            "balanced_braces": content.count('{') == content.count('}'),
            "balanced_parentheses": content.count('(') == content.count(')'),
            "balanced_brackets": content.count('[') == content.count(']'),
            "no_empty_functions": "func " in content and "pass" not in content,
            "proper_indentation": self._check_indentation(content),
            "no_syntax_errors": self._basic_syntax_check(content)
        }
        
        return {
            "checks": health_checks,
            "health_score": sum(health_checks.values()) / len(health_checks)
        }
    
    def _check_indentation(self, content: str) -> bool:
        """Check if indentation looks correct"""
        lines = content.splitlines()
        for line in lines:
            stripped = line.lstrip()
            if stripped and not stripped.startswith('#'):
                # Check if indentation uses tabs or consistent spaces
                indent = line[:len(line) - len(stripped)]
                if '\t' in indent and ' ' in indent:
                    return False  # Mixed tabs and spaces
        return True
    
    def _basic_syntax_check(self, content: str) -> bool:
        """Basic syntax validation"""
        # Check for common syntax errors
        error_patterns = [
            r'func\s+\w+\s*\(\s*\).*[^:]$',  # Function without colon
            r'if\s+.*[^:]$',                 # If without colon
            r'for\s+.*[^:]$',                # For without colon
            r'while\s+.*[^:]$'               # While without colon
        ]
        
        for pattern in error_patterns:
            if re.search(pattern, content, re.MULTILINE):
                return False
        
        return True
    
    def _generate_system_map(self):
        """Generate a map of all systems and their relationships"""
        self.system_map = {
            "core_systems": {},
            "storage_systems": {},
            "consciousness_systems": {},
            "performance_systems": {},
            "ui_systems": {},
            "unknown_systems": {}
        }
        
        for file_path, analysis in self.analysis_results.items():
            if "error" in analysis:
                continue
                
            system_name = analysis["class_name"]
            file_name = analysis["file_name"].lower()
            
            # Categorize systems
            if "storage" in file_name or "akashic" in file_name:
                self.system_map["storage_systems"][system_name] = analysis
            elif "consciousness" in file_name or "aura" in file_name:
                self.system_map["consciousness_systems"][system_name] = analysis
            elif "performance" in file_name or "optimization" in file_name:
                self.system_map["performance_systems"][system_name] = analysis
            elif "ui" in file_name or "interface" in file_name:
                self.system_map["ui_systems"][system_name] = analysis
            elif analysis["universal_being_compliance"]["compliance_score"] > 0.5:
                self.system_map["core_systems"][system_name] = analysis
            else:
                self.system_map["unknown_systems"][system_name] = analysis
    
    def _generate_summary_report(self):
        """Generate comprehensive summary report"""
        print("\n🌟 UNIVERSAL BEING SYSTEMS ANALYSIS REPORT")
        print("="*60)
        
        total_files = len(self.analysis_results)
        total_lines = sum(a.get("lines", 0) for a in self.analysis_results.values())
        
        print(f"📊 Total Systems: {total_files}")
        print(f"📏 Total Lines: {total_lines}")
        
        # Category breakdown
        print(f"\n🏗️ SYSTEM CATEGORIES:")
        for category, systems in self.system_map.items():
            print(f"   {category.replace('_', ' ').title()}: {len(systems)} systems")
        
        # Compliance analysis
        compliant_systems = [a for a in self.analysis_results.values() 
                           if a.get("universal_being_compliance", {}).get("compliance_score", 0) > 0.7]
        print(f"\n✅ High UB Compliance: {len(compliant_systems)}/{total_files} systems")
        
        # Consciousness integration
        conscious_systems = [a for a in self.analysis_results.values() 
                           if a.get("consciousness_integration", {}).get("integration_score", 0) > 0.5]
        print(f"🧠 Consciousness Integrated: {len(conscious_systems)}/{total_files} systems")
        
        # Pentagon architecture
        pentagon_systems = [a for a in self.analysis_results.values() 
                          if len(a.get("pentagon_methods", [])) >= 3]
        print(f"🔯 Pentagon Architecture: {len(pentagon_systems)}/{total_files} systems")
        
        # Health status
        healthy_systems = [a for a in self.analysis_results.values() 
                         if a.get("syntax_health", {}).get("health_score", 0) > 0.8]
        print(f"💚 Healthy Syntax: {len(healthy_systems)}/{total_files} systems")
        
        print("\n🌌 Systems folder successfully added to Python scriptura!")
    
    def save_analysis_report(self, output_path: str = "systems_analysis_report.json"):
        """Save complete analysis to JSON file"""
        report = {
            "analysis_timestamp": "2025-06-15",
            "systems_path": str(self.systems_path),
            "total_systems": len(self.analysis_results),
            "system_map": self.system_map,
            "detailed_analysis": self.analysis_results
        }
        
        output_file = Path(output_path)
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, default=str)
        
        print(f"📄 Analysis report saved to: {output_file}")
        return output_file

def create_systems_tools():
    """Create additional tools for systems management"""
    
    tools_created = []
    
    # Create systems validator
    validator_code = '''#!/usr/bin/env python3
"""Perfect Systems Validator for Universal Being"""

import sys
from pathlib import Path

def validate_system_file(file_path):
    """Validate a single system file"""
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Pentagon compliance check
    pentagon_methods = ['pentagon_init', 'pentagon_ready', 'pentagon_process', 'pentagon_input', 'pentagon_sewers']
    found_methods = [method for method in pentagon_methods if f'func {method}(' in content]
    
    print(f"🔯 Pentagon compliance: {len(found_methods)}/5 methods")
    for method in pentagon_methods:
        status = "✅" if method in found_methods else "❌"
        print(f"   {status} {method}")
    
    return len(found_methods) >= 3

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python validate_system.py <system_file.gd>")
        sys.exit(1)
    
    file_path = Path(sys.argv[1])
    if validate_system_file(file_path):
        print("✅ System validation passed!")
    else:
        print("❌ System needs Pentagon architecture improvements")
'''
    
    validator_path = Path("/mnt/c/Users/Percision 15/Universal_Being/tools/validate_system.py")
    with open(validator_path, 'w') as f:
        f.write(validator_code)
    tools_created.append("validate_system.py")
    
    return tools_created

if __name__ == "__main__":
    print("🌌 PERFECT SYSTEMS SCRIPTURA - Universal Being Revolution")
    
    # Initialize analyzer
    analyzer = UniversalBeingSystemsAnalyzer()
    
    # Analyze all systems
    results = analyzer.analyze_all_systems()
    
    # Save comprehensive report
    report_file = analyzer.save_analysis_report("/mnt/c/Users/Percision 15/Universal_Being/docs/systems_analysis_report.json")
    
    # Create additional tools
    tools = create_systems_tools()
    print(f"\n🛠️ Created {len(tools)} additional tools: {', '.join(tools)}")
    
    print("\n🌟 PERFECT SYSTEMS SCRIPTURA COMPLETE! 🌟")
    print("🧬 Systems folder fully integrated into Python toolchain!")