#!/usr/bin/env python3
"""
Comprehensive Godot Class Usage Analyzer for talking_ragdoll_game
Analyzes GDScript files to document class usage, methods, signals, and properties
"""

import os
import re
from collections import defaultdict
from typing import Dict, List, Set, Tuple
import json

class GodotClassAnalyzer:
    def __init__(self, project_root: str):
        self.project_root = project_root
        self.scripts_data = {}
        self.class_to_scripts = defaultdict(set)
        self.method_usage = defaultdict(lambda: defaultdict(list))
        self.signal_usage = defaultdict(lambda: defaultdict(list))
        self.property_usage = defaultdict(lambda: defaultdict(list))
        
    def analyze_project(self, directories: List[str]):
        """Analyze all scripts in specified directories"""
        for directory in directories:
            dir_path = os.path.join(self.project_root, directory)
            if os.path.exists(dir_path):
                self._analyze_directory(dir_path)
                
    def _analyze_directory(self, dir_path: str):
        """Recursively analyze all .gd files in directory"""
        for root, dirs, files in os.walk(dir_path):
            for file in files:
                if file.endswith('.gd'):
                    file_path = os.path.join(root, file)
                    self._analyze_script(file_path)
                    
    def _analyze_script(self, file_path: str):
        """Analyze a single GDScript file"""
        relative_path = os.path.relpath(file_path, self.project_root)
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            lines = content.split('\n')
            
        script_data = {
            'path': relative_path,
            'extends': self._find_extends_class(content),
            'class_name': self._find_class_name(content),
            'instantiated_classes': {},
            'method_calls': defaultdict(list),
            'signal_connections': defaultdict(list),
            'property_accesses': defaultdict(list),
            'annotations': defaultdict(list),
            'groups': []
        }
        
        # Analyze line by line
        for line_num, line in enumerate(lines, 1):
            self._analyze_line(line, line_num, script_data)
            
        self.scripts_data[relative_path] = script_data
        
        # Update reverse lookups
        if script_data['extends']:
            self.class_to_scripts[script_data['extends']].add(relative_path)
            
    def _find_extends_class(self, content: str) -> str:
        """Find the class this script extends"""
        match = re.search(r'extends\s+(\w+)', content)
        return match.group(1) if match else ""
        
    def _find_class_name(self, content: str) -> str:
        """Find the class_name declaration"""
        match = re.search(r'class_name\s+(\w+)', content)
        return match.group(1) if match else ""
        
    def _analyze_line(self, line: str, line_num: int, script_data: dict):
        """Analyze a single line for Godot class usage"""
        
        # Skip comments
        if line.strip().startswith('#'):
            return
            
        # Find class instantiations (.new())
        new_matches = re.findall(r'(\w+)\.new\(\)', line)
        for class_name in new_matches:
            if class_name not in script_data['instantiated_classes']:
                script_data['instantiated_classes'][class_name] = []
            script_data['instantiated_classes'][class_name].append(line_num)
            
        # Find method calls
        method_matches = re.findall(r'(\w+)\.(\w+)\(', line)
        for obj, method in method_matches:
            if method != 'new':  # Skip .new() calls
                script_data['method_calls'][f"{obj}.{method}"].append(line_num)
                
        # Find signal connections
        signal_matches = re.findall(r'\.connect\(([^)]+)\)', line)
        for signal in signal_matches:
            script_data['signal_connections'][signal.strip()].append(line_num)
            
        # Find signal definitions
        if 'signal' in line:
            signal_def = re.search(r'signal\s+(\w+)', line)
            if signal_def:
                script_data['signal_connections'][f"defines:{signal_def.group(1)}"].append(line_num)
                
        # Find @onready annotations
        onready_match = re.search(r'@onready\s+var\s+(\w+).*?=\s*(.*)', line)
        if onready_match:
            var_name = onready_match.group(1)
            value = onready_match.group(2).strip()
            script_data['annotations']['@onready'].append({
                'line': line_num,
                'var': var_name,
                'value': value
            })
            
        # Find get_node calls
        get_node_matches = re.findall(r'get_node\(["\']([^"\']+)["\']\)', line)
        for node_path in get_node_matches:
            script_data['method_calls']['get_node'].append({
                'line': line_num,
                'path': node_path
            })
            
        # Find add_to_group calls
        group_matches = re.findall(r'add_to_group\(["\']([^"\']+)["\']\)', line)
        for group in group_matches:
            if group not in script_data['groups']:
                script_data['groups'].append(group)
                
        # Find common Godot class properties
        property_patterns = [
            (r'\.position', 'position'),
            (r'\.rotation', 'rotation'),
            (r'\.scale', 'scale'),
            (r'\.visible', 'visible'),
            (r'\.modulate', 'modulate'),
            (r'\.global_position', 'global_position'),
            (r'\.global_transform', 'global_transform'),
            (r'\.linear_velocity', 'linear_velocity'),
            (r'\.angular_velocity', 'angular_velocity')
        ]
        
        for pattern, prop_name in property_patterns:
            if re.search(pattern, line):
                script_data['property_accesses'][prop_name].append(line_num)
                
    def generate_report(self) -> str:
        """Generate comprehensive analysis report"""
        report = []
        report.append("# GODOT CLASS USAGE ANALYSIS REPORT")
        report.append("# talking_ragdoll_game project")
        report.append("=" * 80)
        report.append("")
        
        # Summary statistics
        report.append("## SUMMARY STATISTICS")
        report.append(f"Total scripts analyzed: {len(self.scripts_data)}")
        report.append(f"Unique Godot classes extended: {len(self.class_to_scripts)}")
        report.append("")
        
        # Class inheritance overview
        report.append("## CLASS INHERITANCE OVERVIEW")
        report.append("")
        
        class_counts = defaultdict(int)
        for script_data in self.scripts_data.values():
            if script_data['extends']:
                class_counts[script_data['extends']] += 1
                
        for class_name, count in sorted(class_counts.items(), key=lambda x: x[1], reverse=True):
            report.append(f"- **{class_name}**: {count} scripts")
            
        report.append("")
        
        # Detailed script analysis
        report.append("## DETAILED SCRIPT ANALYSIS")
        report.append("")
        
        # Group scripts by directory
        scripts_by_dir = defaultdict(list)
        for script_path, data in self.scripts_data.items():
            dir_name = os.path.dirname(script_path)
            scripts_by_dir[dir_name].append((script_path, data))
            
        for directory in sorted(scripts_by_dir.keys()):
            report.append(f"### {directory}/")
            report.append("")
            
            for script_path, data in sorted(scripts_by_dir[directory]):
                script_name = os.path.basename(script_path)
                report.append(f"#### {script_name}")
                
                if data['extends']:
                    report.append(f"**Extends:** `{data['extends']}`")
                    
                if data['class_name']:
                    report.append(f"**Class Name:** `{data['class_name']}`")
                    
                # Instantiated classes
                if data['instantiated_classes']:
                    report.append("\n**Instantiated Classes:**")
                    for class_name, lines in data['instantiated_classes'].items():
                        report.append(f"- `{class_name}` at lines: {', '.join(map(str, lines))}")
                        
                # Key method calls
                if data['method_calls']:
                    report.append("\n**Key Method Calls:**")
                    # Filter for important methods
                    important_methods = ['get_node', 'add_child', 'queue_free', 'connect', 
                                       'emit_signal', 'call_deferred', 'set_process']
                    for method_call, locations in sorted(data['method_calls'].items()):
                        method_name = method_call.split('.')[-1] if '.' in method_call else method_call
                        if method_name in important_methods or len(locations) > 3:
                            if isinstance(locations[0], dict):
                                report.append(f"- `{method_call}`: {len(locations)} calls")
                            else:
                                report.append(f"- `{method_call}`: lines {', '.join(map(str, locations[:5]))}")
                                if len(locations) > 5:
                                    report.append(f"  ... and {len(locations) - 5} more")
                                    
                # Signals
                if data['signal_connections']:
                    report.append("\n**Signals:**")
                    for signal, lines in data['signal_connections'].items():
                        if signal.startswith('defines:'):
                            report.append(f"- Defines signal `{signal[8:]}` at line {lines[0]}")
                        else:
                            report.append(f"- Connects to `{signal}` at lines: {', '.join(map(str, lines))}")
                            
                # Groups
                if data['groups']:
                    report.append(f"\n**Groups:** {', '.join(data['groups'])}")
                    
                report.append("")
                
        # Class to scripts mapping
        report.append("## CLASS TO SCRIPTS MAPPING")
        report.append("")
        
        for class_name in sorted(self.class_to_scripts.keys()):
            scripts = sorted(self.class_to_scripts[class_name])
            report.append(f"### {class_name}")
            for script in scripts:
                report.append(f"- {script}")
            report.append("")
            
        # Common patterns
        report.append("## COMMON PATTERNS AND USAGE")
        report.append("")
        
        # Find most commonly instantiated classes
        instantiation_counts = defaultdict(int)
        for data in self.scripts_data.values():
            for class_name in data['instantiated_classes']:
                instantiation_counts[class_name] += len(data['instantiated_classes'][class_name])
                
        if instantiation_counts:
            report.append("### Most Instantiated Classes")
            for class_name, count in sorted(instantiation_counts.items(), 
                                          key=lambda x: x[1], reverse=True)[:10]:
                report.append(f"- `{class_name}`: {count} instantiations")
            report.append("")
            
        return '\n'.join(report)
        
    def save_json_data(self, output_path: str):
        """Save detailed analysis data as JSON"""
        # Convert defaultdicts to regular dicts for JSON serialization
        json_data = {
            'scripts': self.scripts_data,
            'class_to_scripts': {k: list(v) for k, v in self.class_to_scripts.items()},
            'summary': {
                'total_scripts': len(self.scripts_data),
                'unique_extends': len(self.class_to_scripts)
            }
        }
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(json_data, f, indent=2)


def main():
    project_root = "/mnt/c/Users/Percision 15/talking_ragdoll_game"
    
    analyzer = GodotClassAnalyzer(project_root)
    
    # Analyze specified directories
    directories = [
        "scripts/autoload",
        "scripts/core",
        "scripts/characters",
        "scripts/systems"
    ]
    
    analyzer.analyze_project(directories)
    
    # Generate and save report
    report = analyzer.generate_report()
    
    report_path = os.path.join(project_root, "GODOT_CLASS_USAGE_ANALYSIS.md")
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write(report)
        
    # Save JSON data for programmatic access
    json_path = os.path.join(project_root, "godot_class_usage_data.json")
    analyzer.save_json_data(json_path)
    
    print(f"Analysis complete!")
    print(f"Report saved to: {report_path}")
    print(f"JSON data saved to: {json_path}")
    

if __name__ == "__main__":
    main()