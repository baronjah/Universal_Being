#!/usr/bin/env python3
"""
Universal Being Project Architecture Analyzer
Enhanced version for post-reorganization analysis
Validates the new beings/, systems/, components/ structure
Generated: 2025-06-06 - Post-Architecture Documentation
"""

import os
import json
from pathlib import Path
import re
from collections import defaultdict, Counter
import time

class ArchitectureAnalyzer:
    def __init__(self, project_root=None):
        # Auto-detect project root from script location
        if project_root is None:
            project_root = os.path.dirname(os.path.abspath(__file__))
        
        self.project_root = Path(project_root)
        
        # Analysis results
        self.analysis = {
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "project_structure": {},
            "pentagon_compliance": {},
            "socket_usage": {},
            "consciousness_levels": {},
            "component_analysis": {},
            "autoload_analysis": {},
            "scene_analysis": {},
            "akashic_integration": {},
            "architecture_health": {}
        }
        
        # Architecture patterns
        self.pentagon_methods = [
            "pentagon_init", "pentagon_ready", "pentagon_process", 
            "pentagon_input", "pentagon_sewers"
        ]
        
        self.consciousness_levels = {
            0: "Dormant (Gray)",
            1: "Awakening (White)", 
            2: "Aware (Blue)",
            3: "Connected (Green)",
            4: "Enlightened (Gold)",
            5: "Transcendent (Bright White)"
        }
        
        self.socket_types = [
            "visual_mesh", "consciousness_indicator", "behavior_logic",
            "ai_interface", "evolution_rules", "surface_material",
            "effect_overlay", "pentagon_actions", "custom_behaviors",
            "core_state", "interaction_history", "evolution_data",
            "control_interface", "inspector_panel", "debug_output"
        ]
    
    def analyze_project_structure(self):
        """Analyze the new organized project structure"""
        print("📁 Analyzing project structure...")
        
        structure = {}
        
        # Core analysis
        core_dir = self.project_root / "core"
        structure["core"] = self.analyze_directory(core_dir, "Core Architecture")
        
        # Beings analysis
        beings_dir = self.project_root / "beings"
        structure["beings"] = self.analyze_directory(beings_dir, "Being Implementations")
        
        # Systems analysis  
        systems_dir = self.project_root / "systems"
        structure["systems"] = self.analyze_directory(systems_dir, "System Components")
        
        # Components analysis
        components_dir = self.project_root / "components"
        structure["components"] = self.analyze_directory(components_dir, "Reusable Components")
        
        # Scripts analysis
        scripts_dir = self.project_root / "scripts"
        structure["scripts"] = self.analyze_directory(scripts_dir, "Working Scripts")
        
        # Autoloads analysis
        autoloads_dir = self.project_root / "autoloads"
        structure["autoloads"] = self.analyze_directory(autoloads_dir, "Global Singletons")
        
        # Akashic Library analysis
        akashic_dir = self.project_root / "akashic_library"
        structure["akashic_library"] = self.analyze_directory(akashic_dir, "Asset Library")
        
        self.analysis["project_structure"] = structure
        
        # Structure health assessment
        health = {
            "core_organization": "Excellent" if structure["core"]["script_count"] <= 20 else "Needs attention",
            "beings_separation": "Good" if structure["beings"]["script_count"] > 0 else "Missing",
            "systems_organization": "Good" if structure["systems"]["script_count"] > 5 else "Missing",
            "total_scripts": sum(folder["script_count"] for folder in structure.values()),
            "organization_score": self.calculate_organization_score(structure)
        }
        
        self.analysis["architecture_health"]["structure"] = health
    
    def analyze_directory(self, directory, description):
        """Analyze a specific directory"""
        if not directory.exists():
            return {
                "description": description,
                "exists": False,
                "script_count": 0,
                "subdirectories": [],
                "files": []
            }
        
        analysis = {
            "description": description,
            "exists": True,
            "script_count": 0,
            "subdirectories": [],
            "files": [],
            "size_kb": 0
        }
        
        # Count scripts and subdirectories
        try:
            for item in directory.iterdir():
                if item.is_file() and item.suffix == ".gd":
                    analysis["script_count"] += 1
                    analysis["files"].append({
                        "name": item.name,
                        "size": item.stat().st_size,
                        "modified": item.stat().st_mtime
                    })
                    analysis["size_kb"] += item.stat().st_size
                elif item.is_dir() and not item.name.startswith('.'):
                    subdir_analysis = self.analyze_directory(item, f"{description} - {item.name}")
                    analysis["subdirectories"].append({
                        "name": item.name,
                        "script_count": subdir_analysis["script_count"],
                        "analysis": subdir_analysis
                    })
                    analysis["script_count"] += subdir_analysis["script_count"]
                    analysis["size_kb"] += subdir_analysis["size_kb"]
        except Exception as e:
            print(f"  Error analyzing {directory}: {e}")
        
        analysis["size_kb"] = round(analysis["size_kb"] / 1024, 2)
        return analysis
    
    def analyze_pentagon_compliance(self):
        """Analyze Pentagon architecture compliance across the project"""
        print("⭐ Analyzing Pentagon compliance...")
        
        compliance = {
            "total_scripts": 0,
            "compliant_scripts": 0,
            "non_compliant": [],
            "missing_methods": defaultdict(list),
            "super_call_issues": [],
            "compliance_by_directory": {}
        }
        
        # Check all GDScript files
        for gd_file in self.project_root.rglob("*.gd"):
            if self.should_skip_file(gd_file):
                continue
                
            compliance["total_scripts"] += 1
            
            # Get directory for categorization
            relative_path = gd_file.relative_to(self.project_root)
            directory = str(relative_path.parts[0]) if relative_path.parts else "root"
            
            if directory not in compliance["compliance_by_directory"]:
                compliance["compliance_by_directory"][directory] = {
                    "total": 0, "compliant": 0, "files": []
                }
            
            compliance["compliance_by_directory"][directory]["total"] += 1
            
            # Analyze Pentagon compliance
            pentagon_result = self.check_pentagon_compliance(gd_file)
            
            if pentagon_result["is_compliant"]:
                compliance["compliant_scripts"] += 1
                compliance["compliance_by_directory"][directory]["compliant"] += 1
            else:
                compliance["non_compliant"].append({
                    "file": str(relative_path),
                    "issues": pentagon_result["issues"]
                })
                
                for missing_method in pentagon_result["missing_methods"]:
                    compliance["missing_methods"][missing_method].append(str(relative_path))
            
            compliance["compliance_by_directory"][directory]["files"].append({
                "name": gd_file.name,
                "compliant": pentagon_result["is_compliant"],
                "issues": pentagon_result["issues"]
            })
        
        # Calculate compliance percentage
        if compliance["total_scripts"] > 0:
            compliance["compliance_percentage"] = round(
                (compliance["compliant_scripts"] / compliance["total_scripts"]) * 100, 1
            )
        else:
            compliance["compliance_percentage"] = 0
            
        self.analysis["pentagon_compliance"] = compliance
    
    def check_pentagon_compliance(self, file_path):
        """Check if a script follows Pentagon architecture"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except:
            return {"is_compliant": False, "issues": ["Cannot read file"], "missing_methods": []}
        
        # Check if it extends UniversalBeing
        if "extends UniversalBeing" not in content:
            return {"is_compliant": True, "issues": ["Not a UniversalBeing"], "missing_methods": []}
        
        issues = []
        missing_methods = []
        
        # Check for Pentagon methods
        for method in self.pentagon_methods:
            if f"func {method}(" not in content:
                missing_methods.append(method)
                continue
            
            # Check for super calls (simplified check)
            method_pattern = rf"func {method}\([^)]*\).*?(?=func|\Z)"
            method_match = re.search(method_pattern, content, re.DOTALL)
            
            if method_match and method != "pentagon_sewers":
                # For most methods, super should be called first
                if f"super.{method}(" not in method_match.group():
                    issues.append(f"Missing super.{method}() call")
            elif method_match and method == "pentagon_sewers":
                # For sewers, super should be called last
                if f"super.{method}(" not in method_match.group():
                    issues.append(f"Missing super.{method}() call")
        
        is_compliant = len(missing_methods) == 0 and len(issues) == 0
        
        return {
            "is_compliant": is_compliant,
            "issues": issues,
            "missing_methods": missing_methods
        }
    
    def analyze_consciousness_levels(self):
        """Analyze consciousness level usage across beings"""
        print("🧠 Analyzing consciousness levels...")
        
        consciousness_analysis = {
            "level_distribution": Counter(),
            "beings_by_level": defaultdict(list),
            "consciousness_evolution": [],
            "total_conscious_beings": 0
        }
        
        # Scan for consciousness_level assignments
        for gd_file in self.project_root.rglob("*.gd"):
            if self.should_skip_file(gd_file):
                continue
                
            try:
                with open(gd_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                # Look for consciousness_level assignments
                level_matches = re.findall(r'consciousness_level\s*=\s*(\d+)', content)
                
                for level_str in level_matches:
                    level = int(level_str)
                    consciousness_analysis["level_distribution"][level] += 1
                    consciousness_analysis["beings_by_level"][level].append(gd_file.name)
                    consciousness_analysis["total_conscious_beings"] += 1
                    
            except:
                continue
        
        self.analysis["consciousness_levels"] = consciousness_analysis
    
    def analyze_autoloads(self):
        """Analyze autoload system configuration"""
        print("🚀 Analyzing autoload system...")
        
        autoload_analysis = {
            "configured_autoloads": {},
            "autoload_files_exist": {},
            "autoload_health": "Unknown"
        }
        
        # Read project.godot for autoload configuration
        project_godot = self.project_root / "project.godot"
        
        if project_godot.exists():
            try:
                with open(project_godot, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Extract autoload entries
                autoload_section = False
                for line in content.split('\n'):
                    if line.strip() == "[autoload]":
                        autoload_section = True
                        continue
                    elif line.startswith('[') and autoload_section:
                        break
                    elif autoload_section and '=' in line:
                        name, path = line.split('=', 1)
                        name = name.strip()
                        path = path.strip().strip('"').replace('*', '')
                        
                        autoload_analysis["configured_autoloads"][name] = path
                        
                        # Check if file exists
                        autoload_file = self.project_root / path.replace('res://', '')
                        autoload_analysis["autoload_files_exist"][name] = autoload_file.exists()
                        
            except Exception as e:
                autoload_analysis["error"] = str(e)
        
        # Health assessment
        total_autoloads = len(autoload_analysis["configured_autoloads"])
        existing_autoloads = sum(1 for exists in autoload_analysis["autoload_files_exist"].values() if exists)
        
        if total_autoloads == 0:
            autoload_analysis["autoload_health"] = "No autoloads configured"
        elif existing_autoloads == total_autoloads:
            autoload_analysis["autoload_health"] = "Excellent - all autoloads exist"
        elif existing_autoloads > total_autoloads * 0.8:
            autoload_analysis["autoload_health"] = "Good - most autoloads exist"
        else:
            autoload_analysis["autoload_health"] = "Poor - missing autoload files"
            
        self.analysis["autoload_analysis"] = autoload_analysis
    
    def analyze_akashic_integration(self):
        """Analyze AkashicRecords integration and usage"""
        print("📚 Analyzing Akashic Records integration...")
        
        akashic_analysis = {
            "akashic_references": 0,
            "save_operations": 0,
            "load_operations": 0,
            "component_packages": 0,
            "akashic_library_structure": {},
            "integration_health": "Unknown"
        }
        
        # Count AkashicRecords usage
        for gd_file in self.project_root.rglob("*.gd"):
            if self.should_skip_file(gd_file):
                continue
                
            try:
                with open(gd_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                if "AkashicRecords" in content:
                    akashic_analysis["akashic_references"] += 1
                    
                akashic_analysis["save_operations"] += content.count("save_being_to_zip")
                akashic_analysis["load_operations"] += content.count("load_being_from_zip")
                    
            except:
                continue
        
        # Analyze akashic_library structure
        akashic_lib = self.project_root / "akashic_library"
        if akashic_lib.exists():
            akashic_analysis["akashic_library_structure"] = self.analyze_directory(
                akashic_lib, "Akashic Library"
            )
            
            # Count .ub.zip packages
            akashic_analysis["component_packages"] = len(list(akashic_lib.rglob("*.ub.zip")))
        
        # Health assessment
        if akashic_analysis["akashic_references"] > 5 and akashic_analysis["component_packages"] > 0:
            akashic_analysis["integration_health"] = "Excellent - active integration"
        elif akashic_analysis["akashic_references"] > 0:
            akashic_analysis["integration_health"] = "Good - basic integration"
        else:
            akashic_analysis["integration_health"] = "Poor - minimal integration"
            
        self.analysis["akashic_integration"] = akashic_analysis
    
    def calculate_organization_score(self, structure):
        """Calculate overall organization score"""
        score = 0
        max_score = 100
        
        # Core organization (25 points)
        if structure["core"]["script_count"] <= 20:
            score += 25
        elif structure["core"]["script_count"] <= 30:
            score += 15
        else:
            score += 5
        
        # Beings separation (20 points)
        if structure["beings"]["script_count"] > 0:
            score += 20
        
        # Systems organization (20 points)
        if structure["systems"]["script_count"] > 5:
            score += 20
        elif structure["systems"]["script_count"] > 0:
            score += 10
        
        # Scripts cleanup (15 points)
        if structure["scripts"]["script_count"] < 100:
            score += 15
        elif structure["scripts"]["script_count"] < 200:
            score += 10
        else:
            score += 5
        
        # Components (10 points)
        if structure["components"]["script_count"] > 0:
            score += 10
        
        # Autoloads (10 points)
        if structure["autoloads"]["script_count"] > 0:
            score += 10
        
        return min(score, max_score)
    
    def should_skip_file(self, file_path):
        """Check if file should be skipped in analysis"""
        skip_patterns = [
            ".godot", "__pycache__", ".git", "node_modules",
            "backup", "temp", ".import"
        ]
        
        path_str = str(file_path)
        return any(pattern in path_str for pattern in skip_patterns)
    
    def generate_comprehensive_report(self):
        """Generate a comprehensive architecture analysis report"""
        print("📊 Generating comprehensive report...")
        
        # Create docs directory if it doesn't exist
        docs_dir = self.project_root / "docs"
        docs_dir.mkdir(parents=True, exist_ok=True)
        
        report_path = docs_dir / "ARCHITECTURE_ANALYSIS_REPORT.md"
        
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write("# Universal Being Architecture Analysis Report\n")
            f.write(f"**Generated**: {self.analysis['timestamp']}\n\n")
            
            # Executive Summary
            f.write("## 📋 Executive Summary\n\n")
            
            total_scripts = self.analysis["project_structure"]["core"]["script_count"] + \
                          self.analysis["project_structure"]["beings"]["script_count"] + \
                          self.analysis["project_structure"]["systems"]["script_count"] + \
                          self.analysis["project_structure"]["scripts"]["script_count"]
                          
            f.write(f"- **Total Scripts**: {total_scripts}\n")
            f.write(f"- **Pentagon Compliance**: {self.analysis['pentagon_compliance']['compliance_percentage']}%\n")
            f.write(f"- **Organization Score**: {self.analysis['architecture_health']['structure']['organization_score']}/100\n")
            f.write(f"- **Conscious Beings**: {self.analysis['consciousness_levels']['total_conscious_beings']}\n")
            f.write(f"- **Autoload Health**: {self.analysis['autoload_analysis']['autoload_health']}\n\n")
            
            # Project Structure
            f.write("## 📁 Project Structure Analysis\n\n")
            for folder, data in self.analysis["project_structure"].items():
                f.write(f"### {folder.title()}\n")
                f.write(f"- **Description**: {data['description']}\n")
                f.write(f"- **Scripts**: {data['script_count']}\n")
                f.write(f"- **Size**: {data['size_kb']} KB\n")
                if data["subdirectories"]:
                    f.write(f"- **Subdirectories**: {len(data['subdirectories'])}\n")
                f.write("\n")
            
            # Pentagon Compliance
            f.write("## ⭐ Pentagon Architecture Compliance\n\n")
            f.write(f"**Overall Compliance**: {self.analysis['pentagon_compliance']['compliance_percentage']}%\n")
            f.write(f"({self.analysis['pentagon_compliance']['compliant_scripts']}/{self.analysis['pentagon_compliance']['total_scripts']} scripts)\n\n")
            
            if self.analysis['pentagon_compliance']['non_compliant']:
                f.write("### Non-Compliant Scripts\n")
                for issue in self.analysis['pentagon_compliance']['non_compliant'][:10]:  # Show first 10
                    f.write(f"- `{issue['file']}`: {', '.join(issue['issues'])}\n")
                f.write("\n")
            
            # Consciousness Analysis
            f.write("## 🧠 Consciousness Level Distribution\n\n")
            for level, count in sorted(self.analysis['consciousness_levels']['level_distribution'].items()):
                level_name = self.consciousness_levels.get(level, f"Level {level}")
                f.write(f"- **{level_name}**: {count} beings\n")
            f.write("\n")
            
            # Autoload Analysis
            f.write("## 🚀 Autoload System\n\n")
            f.write(f"**Health**: {self.analysis['autoload_analysis']['autoload_health']}\n\n")
            f.write("### Configured Autoloads\n")
            for name, path in self.analysis['autoload_analysis']['configured_autoloads'].items():
                exists = self.analysis['autoload_analysis']['autoload_files_exist'].get(name, False)
                status = "✅" if exists else "❌"
                f.write(f"- {status} **{name}**: `{path}`\n")
            f.write("\n")
            
            # Akashic Integration
            f.write("## 📚 Akashic Records Integration\n\n")
            f.write(f"**Health**: {self.analysis['akashic_integration']['integration_health']}\n")
            f.write(f"- **References**: {self.analysis['akashic_integration']['akashic_references']} files\n")
            f.write(f"- **Save Operations**: {self.analysis['akashic_integration']['save_operations']}\n")
            f.write(f"- **Load Operations**: {self.analysis['akashic_integration']['load_operations']}\n")
            f.write(f"- **Component Packages**: {self.analysis['akashic_integration']['component_packages']}\n\n")
            
            # Recommendations
            f.write("## 🎯 Recommendations\n\n")
            
            org_score = self.analysis['architecture_health']['structure']['organization_score']
            if org_score >= 90:
                f.write("- ✅ Excellent organization - maintain current structure\n")
            elif org_score >= 70:
                f.write("- 🔄 Good organization - minor improvements needed\n")
            else:
                f.write("- ⚠️ Organization needs improvement - run clean_scripts_folder.py\n")
            
            compliance = self.analysis['pentagon_compliance']['compliance_percentage']
            if compliance >= 80:
                f.write("- ✅ Pentagon compliance is excellent\n")
            elif compliance >= 60:
                f.write("- 🔄 Pentagon compliance is good - fix remaining issues\n")
            else:
                f.write("- ⚠️ Pentagon compliance needs attention - many scripts missing proper architecture\n")
            
            if self.analysis['consciousness_levels']['total_conscious_beings'] < 10:
                f.write("- 🧠 Consider adding more conscious beings to enhance the experience\n")
            
            if self.analysis['akashic_integration']['component_packages'] < 10:
                f.write("- 📦 Develop more .ub.zip component packages for modularity\n")
        
        print(f"📄 Report saved to: {report_path}")
        
        # Save JSON data
        json_path = self.project_root / "architecture_analysis.json"
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(self.analysis, f, indent=2, default=str)
        
        print(f"📊 JSON data saved to: {json_path}")
    
    def run_analysis(self):
        """Execute complete architecture analysis"""
        print("🔍 Universal Being Architecture Analyzer")
        print("=" * 50)
        
        print(f"📂 Analyzing project: {self.project_root}")
        
        # Run all analyses
        self.analyze_project_structure()
        self.analyze_pentagon_compliance()
        self.analyze_consciousness_levels()
        self.analyze_autoloads()
        self.analyze_akashic_integration()
        
        # Generate reports
        self.generate_comprehensive_report()
        
        print("\n✅ Architecture analysis complete!")
        print(f"📊 Organization Score: {self.analysis['architecture_health']['structure']['organization_score']}/100")
        print(f"⭐ Pentagon Compliance: {self.analysis['pentagon_compliance']['compliance_percentage']}%")
        print(f"🧠 Conscious Beings: {self.analysis['consciousness_levels']['total_conscious_beings']}")

def main():
    # Get project root from current script location
    project_root = os.path.dirname(os.path.abspath(__file__))
    analyzer = ArchitectureAnalyzer(project_root)
    analyzer.run_analysis()

if __name__ == "__main__":
    main()
