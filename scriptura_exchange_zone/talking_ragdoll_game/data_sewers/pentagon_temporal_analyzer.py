#!/usr/bin/env python3
"""
🏛️ PENTAGON TEMPORAL ANALYZER - Script Compliance & Timeline Analysis
Author: Claude & JSH
Created: May 31, 2025, 13:45 CEST
Purpose: Analyze Pentagon compliance combined with temporal header analysis
Connection: Part of unified system understanding for "One Ready, One Init, One Process, One Input"

Combines:
- Pentagon compliance checking (5 sacred functions)
- Temporal header analysis (4D programming timeline)  
- Active script detection integration
- Unified reporting for alive vs dormant scripts
"""

import os
import re
import json
import argparse
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Optional
import subprocess

class PentagonTemporalAnalyzer:
    """Analyzes Pentagon compliance and temporal evolution of scripts"""
    
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.scripts_path = self.project_path / "scripts"
        
        # Pentagon pattern definitions
        self.pentagon_functions = {
            "_init": r"func\s+_init\s*\(",
            "_ready": r"func\s+_ready\s*\(",
            "_process": r"func\s+_process\s*\(",
            "_input": r"func\s+_input\s*\(",
            "sewers": r"func\s+sewers\s*\("
        }
        
        # Temporal analysis patterns
        self.header_patterns = {
            "standardized": r"# Author: .+\n# Created: .+\n# Purpose: .+",
            "early_org": r"# Created: .+\n# Purpose: .+",
            "structured": r"# .+ - .+\n#+",
            "prehistoric": r"^[^#].*extends.*"  # No headers at all
        }
        
        # Inheritance violations
        self.violation_patterns = {
            "extends_node": r"extends\s+Node\s*$",
            "extends_node3d": r"extends\s+Node3D\s*$", 
            "extends_control": r"extends\s+Control\s*$",
            "direct_add_child": r"\.add_child\s*\(",
            "timer_new": r"Timer\.new\s*\(",
            "material_new": r"StandardMaterial3D\.new\s*\("
        }
        
        # Results storage
        self.analysis_results = {
            "total_scripts": 0,
            "pentagon_compliant": 0,
            "pentagon_violators": 0,
            "temporal_categories": {
                "standardized": 0,
                "early_org": 0, 
                "structured": 0,
                "prehistoric": 0
            },
            "violation_summary": {},
            "scripts": [],
            "compliance_by_era": {},
            "evolution_timeline": []
        }
    
    def analyze_all_scripts(self) -> Dict:
        """Main analysis function - combines Pentagon and temporal analysis"""
        print("🏛️ Starting Pentagon Temporal Analysis...")
        
        # Find all GDScript files
        script_files = list(self.scripts_path.rglob("*.gd"))
        self.analysis_results["total_scripts"] = len(script_files)
        
        print(f"Found {len(script_files)} GDScript files to analyze")
        
        # Analyze each script
        for script_path in script_files:
            script_analysis = self._analyze_single_script(script_path)
            self.analysis_results["scripts"].append(script_analysis)
            
            # Update counters
            if script_analysis["pentagon"]["is_compliant"]:
                self.analysis_results["pentagon_compliant"] += 1
            else:
                self.analysis_results["pentagon_violators"] += 1
            
            # Update temporal category
            category = script_analysis["temporal"]["category"]
            self.analysis_results["temporal_categories"][category] += 1
        
        # Generate additional insights
        self._generate_compliance_by_era()
        self._generate_evolution_timeline()
        self._generate_violation_summary()
        
        return self.analysis_results
    
    def _analyze_single_script(self, script_path: Path) -> Dict:
        """Analyze a single script for Pentagon compliance and temporal classification"""
        try:
            with open(script_path, 'r', encoding='utf-8') as file:
                content = file.read()
        except Exception as e:
            return {
                "path": str(script_path.relative_to(self.project_path)),
                "error": str(e),
                "pentagon": {"is_compliant": False, "score": 0},
                "temporal": {"category": "error"}
            }
        
        relative_path = str(script_path.relative_to(self.project_path))
        
        # Pentagon analysis
        pentagon_analysis = self._analyze_pentagon_compliance(content)
        
        # Temporal analysis
        temporal_analysis = self._analyze_temporal_category(content)
        
        # Violation analysis
        violations = self._find_violations(content)
        
        # Extract creation date from header if available
        creation_date = self._extract_creation_date(content)
        
        return {
            "path": relative_path,
            "pentagon": pentagon_analysis,
            "temporal": temporal_analysis,
            "violations": violations,
            "creation_date": creation_date,
            "file_size": len(content),
            "line_count": content.count('\n') + 1
        }
    
    def _analyze_pentagon_compliance(self, content: str) -> Dict:
        """Check if script follows Pentagon pattern"""
        found_functions = {}
        total_score = 0
        
        for func_name, pattern in self.pentagon_functions.items():
            matches = re.search(pattern, content, re.MULTILINE)
            found = matches is not None
            found_functions[func_name] = found
            if found:
                total_score += 1
        
        # Pentagon compliance requires at least 3/5 functions
        is_compliant = total_score >= 3
        compliance_percentage = (total_score / 5) * 100
        
        # Check for proper inheritance
        has_universal_being = "extends UniversalBeing" in content or "extends UniversalBeingBase" in content
        
        return {
            "is_compliant": is_compliant,
            "score": total_score,
            "percentage": compliance_percentage,
            "functions": found_functions,
            "has_universal_being_inheritance": has_universal_being,
            "compliance_level": self._get_compliance_level(total_score)
        }
    
    def _analyze_temporal_category(self, content: str) -> Dict:
        """Classify script by temporal/evolutionary category"""
        lines = content.split('\n')
        header_lines = lines[:10]  # Check first 10 lines for headers
        header_text = '\n'.join(header_lines)
        
        # Check patterns in order of sophistication
        if re.search(self.header_patterns["standardized"], header_text, re.MULTILINE):
            category = "standardized"
            era = "Modern Era (2025)"
        elif re.search(self.header_patterns["early_org"], header_text, re.MULTILINE):
            category = "early_org"
            era = "Early Organization"
        elif re.search(self.header_patterns["structured"], header_text, re.MULTILINE):
            category = "structured"
            era = "Structured Period"
        else:
            category = "prehistoric"
            era = "Prehistoric Era"
        
        return {
            "category": category,
            "era": era,
            "has_header": category != "prehistoric",
            "header_lines": len([line for line in header_lines if line.strip().startswith('#')])
        }
    
    def _find_violations(self, content: str) -> Dict:
        """Find Pentagon architecture violations"""
        violations = {}
        
        for violation_name, pattern in self.violation_patterns.items():
            matches = re.findall(pattern, content, re.MULTILINE)
            violations[violation_name] = len(matches)
        
        # Calculate violation severity
        total_violations = sum(violations.values())
        severity = "low" if total_violations <= 2 else "medium" if total_violations <= 5 else "high"
        
        violations["total"] = total_violations
        violations["severity"] = severity
        
        return violations
    
    def _extract_creation_date(self, content: str) -> Optional[str]:
        """Extract creation date from header"""
        created_match = re.search(r"# Created: (.+)", content)
        if created_match:
            return created_match.group(1).strip()
        return None
    
    def _get_compliance_level(self, score: int) -> str:
        """Get human-readable compliance level"""
        if score == 5:
            return "Perfect Pentagon"
        elif score >= 3:
            return "Pentagon Compliant"
        elif score >= 2:
            return "Partial Pentagon"
        elif score >= 1:
            return "Minimal Pentagon"
        else:
            return "No Pentagon"
    
    def _generate_compliance_by_era(self):
        """Generate compliance statistics by temporal era"""
        era_compliance = {}
        
        for script in self.analysis_results["scripts"]:
            era = script["temporal"]["era"]
            if era not in era_compliance:
                era_compliance[era] = {"total": 0, "compliant": 0}
            
            era_compliance[era]["total"] += 1
            if script["pentagon"]["is_compliant"]:
                era_compliance[era]["compliant"] += 1
        
        # Calculate percentages
        for era in era_compliance:
            total = era_compliance[era]["total"]
            compliant = era_compliance[era]["compliant"]
            era_compliance[era]["compliance_percentage"] = (compliant / total * 100) if total > 0 else 0
        
        self.analysis_results["compliance_by_era"] = era_compliance
    
    def _generate_evolution_timeline(self):
        """Generate timeline showing evolution of Pentagon compliance"""
        scripts_with_dates = [
            script for script in self.analysis_results["scripts"] 
            if script.get("creation_date")
        ]
        
        # Sort by creation date (approximate)
        scripts_with_dates.sort(key=lambda x: x["creation_date"])
        
        timeline = []
        for script in scripts_with_dates:
            timeline.append({
                "date": script["creation_date"],
                "script": script["path"],
                "pentagon_score": script["pentagon"]["score"],
                "temporal_category": script["temporal"]["category"]
            })
        
        self.analysis_results["evolution_timeline"] = timeline
    
    def _generate_violation_summary(self):
        """Generate summary of all violations across scripts"""
        violation_totals = {}
        
        for script in self.analysis_results["scripts"]:
            violations = script.get("violations", {})
            for violation_type, count in violations.items():
                if violation_type not in ["total", "severity"]:
                    if violation_type not in violation_totals:
                        violation_totals[violation_type] = 0
                    violation_totals[violation_type] += count
        
        self.analysis_results["violation_summary"] = violation_totals
    
    def generate_report(self) -> str:
        """Generate comprehensive text report"""
        results = self.analysis_results
        
        report = f"""
🏛️ PENTAGON TEMPORAL ANALYSIS REPORT
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
Project: {self.project_path.name}

{'='*60}
📊 OVERVIEW
{'='*60}

Total Scripts Analyzed: {results['total_scripts']}
Pentagon Compliant: {results['pentagon_compliant']} ({results['pentagon_compliant']/results['total_scripts']*100:.1f}%)
Pentagon Violators: {results['pentagon_violators']} ({results['pentagon_violators']/results['total_scripts']*100:.1f}%)

{'='*60}
🕰️ TEMPORAL DISTRIBUTION
{'='*60}

"""
        
        for category, count in results["temporal_categories"].items():
            percentage = (count / results["total_scripts"] * 100) if results["total_scripts"] > 0 else 0
            report += f"{category.title():15}: {count:3d} files ({percentage:5.1f}%)\n"
        
        report += f"""
{'='*60}
🎯 COMPLIANCE BY ERA
{'='*60}

"""
        
        for era, data in results["compliance_by_era"].items():
            report += f"{era:20}: {data['compliant']:2d}/{data['total']:2d} compliant ({data['compliance_percentage']:5.1f}%)\n"
        
        report += f"""
{'='*60}
⚠️  VIOLATION SUMMARY
{'='*60}

"""
        
        for violation_type, count in results["violation_summary"].items():
            report += f"{violation_type:20}: {count:4d} occurrences\n"
        
        report += f"""
{'='*60}
🚀 RECOMMENDATIONS
{'='*60}

1. Pentagon Migration Priority:
   - Focus on {results['temporal_categories']['prehistoric']} prehistoric scripts first
   - Modernize {results['temporal_categories']['early_org']} early organization scripts
   
2. Most Critical Violations:
"""
        
        # Sort violations by severity
        sorted_violations = sorted(results["violation_summary"].items(), key=lambda x: x[1], reverse=True)
        for violation, count in sorted_violations[:3]:
            report += f"   - {violation}: {count} occurrences (high priority)\n"
        
        report += f"""
3. Success Rate by Era:
   - Modern scripts have {results['compliance_by_era'].get('Modern Era (2025)', {}).get('compliance_percentage', 0):.1f}% compliance
   - Prehistoric scripts need complete overhaul
   
4. Estimated Migration Effort:
   - {results['pentagon_violators']} scripts need Pentagon conversion
   - Focus on {len([s for s in results['scripts'] if s['pentagon']['score'] >= 2])} partially compliant scripts first

{'='*60}
"""
        
        return report
    
    def save_results(self, output_file: str = None):
        """Save analysis results to JSON file"""
        if output_file is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            output_file = f"pentagon_temporal_analysis_{timestamp}.json"
        
        output_path = self.project_path / output_file
        
        with open(output_path, 'w', encoding='utf-8') as file:
            json.dump(self.analysis_results, file, indent=2, ensure_ascii=False)
        
        print(f"✅ Analysis results saved to: {output_path}")
        return output_path

def main():
    """Main execution function"""
    parser = argparse.ArgumentParser(
        description="Pentagon Temporal Analyzer - Analyze script compliance and evolution"
    )
    parser.add_argument(
        "project_path",
        nargs='?',
        default="/mnt/c/Users/Percision 15/talking_ragdoll_game",
        help="Path to the Godot project"
    )
    parser.add_argument(
        "--output", "-o",
        help="Output file for JSON results"
    )
    parser.add_argument(
        "--report", "-r",
        action="store_true",
        help="Generate text report"
    )
    
    args = parser.parse_args()
    
    # Initialize analyzer
    analyzer = PentagonTemporalAnalyzer(args.project_path)
    
    # Run analysis
    print("🔍 Starting comprehensive analysis...")
    results = analyzer.analyze_all_scripts()
    
    # Save JSON results
    output_path = analyzer.save_results(args.output)
    
    # Generate and display report
    if args.report:
        report = analyzer.generate_report()
        print(report)
        
        # Save report to file
        report_path = output_path.with_suffix('.txt')
        with open(report_path, 'w', encoding='utf-8') as file:
            file.write(report)
        print(f"📋 Text report saved to: {report_path}")
    
    # Summary
    print(f"""
🎯 ANALYSIS COMPLETE!

Total Scripts: {results['total_scripts']}
Pentagon Compliant: {results['pentagon_compliant']} ({results['pentagon_compliant']/results['total_scripts']*100:.1f}%)
Violations Found: {sum(results['violation_summary'].values())}

Next Steps:
1. Review results in {output_path}
2. Run Pentagon Activity Monitor in-game
3. Start Pentagon migration with highest priority scripts
4. Monitor real-time compliance improvements

🏛️ "All for One, One for All" - Pentagon Architecture Initiative
""")

if __name__ == "__main__":
    main()