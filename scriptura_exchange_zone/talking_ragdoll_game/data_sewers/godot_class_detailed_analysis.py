#!/usr/bin/env python3
"""
Enhanced Godot Class Usage Analyzer with detailed method and property tracking
"""

import os
import re
from collections import defaultdict
import json

class DetailedGodotAnalyzer:
    def __init__(self, project_root: str):
        self.project_root = project_root
        self.godot_classes = {
            # Node classes
            'Node', 'Node2D', 'Node3D', 'CanvasItem', 'Control', 'CanvasLayer',
            # Body classes
            'RigidBody2D', 'RigidBody3D', 'CharacterBody2D', 'CharacterBody3D', 
            'StaticBody2D', 'StaticBody3D', 'Area2D', 'Area3D',
            # Visual classes
            'MeshInstance3D', 'Label3D', 'Sprite3D', 'GPUParticles3D',
            # Shape classes
            'CollisionShape2D', 'CollisionShape3D', 'BoxShape3D', 'SphereShape3D', 
            'CapsuleShape3D', 'CylinderShape3D',
            # Mesh classes
            'BoxMesh', 'SphereMesh', 'CapsuleMesh', 'CylinderMesh', 'PlaneMesh',
            # Material classes
            'StandardMaterial3D', 'ShaderMaterial', 'ParticleProcessMaterial',
            # Joint classes
            'Joint3D', 'Generic6DOFJoint3D', 'HingeJoint3D', 'PinJoint3D',
            # UI classes
            'Button', 'Label', 'LineEdit', 'RichTextLabel', 'ScrollContainer',
            'VBoxContainer', 'HBoxContainer', 'PanelContainer', 'ColorRect',
            # Other important classes
            'Timer', 'Tween', 'Thread', 'Mutex', 'ConfigFile', 'JSON',
            'PhysicsRayQueryParameters3D', 'ImageTexture', 'ArrayMesh',
            'FastNoiseLite', 'PhysicsMaterial', 'StyleBoxFlat'
        }
        
        self.godot_methods = {
            # Node methods
            'add_child', 'remove_child', 'queue_free', 'get_node', 'has_node',
            'get_tree', 'get_parent', 'get_children', 'set_process', 'set_physics_process',
            # Signal methods
            'connect', 'disconnect', 'emit_signal', 'call_deferred',
            # Physics methods
            'apply_force', 'apply_central_force', 'apply_torque', 'apply_impulse',
            'move_and_slide', 'move_and_collide',
            # Input methods
            'is_action_pressed', 'is_action_just_pressed', 'get_action_strength',
            # Other common methods
            'instance', 'duplicate', 'set_meta', 'get_meta', 'has_method'
        }
        
        self.analysis_results = defaultdict(lambda: {
            'extends': '',
            'class_name': '',
            'godot_class_usage': defaultdict(list),
            'godot_method_usage': defaultdict(list),
            'signal_definitions': [],
            'signal_connections': [],
            'annotations': defaultdict(list),
            'groups': [],
            'properties_accessed': defaultdict(list)
        })
        
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
        """Deeply analyze a single GDScript file"""
        relative_path = os.path.relpath(file_path, self.project_root)
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            lines = content.split('\n')
            
        script_data = self.analysis_results[relative_path]
        
        # Find extends
        extends_match = re.search(r'extends\s+(\w+)', content)
        if extends_match:
            script_data['extends'] = extends_match.group(1)
            
        # Find class_name
        class_name_match = re.search(r'class_name\s+(\w+)', content)
        if class_name_match:
            script_data['class_name'] = class_name_match.group(1)
            
        # Analyze each line
        for line_num, line in enumerate(lines, 1):
            self._analyze_line(line, line_num, script_data)
            
    def _analyze_line(self, line: str, line_num: int, script_data: dict):
        """Analyze a single line for Godot class and method usage"""
        
        # Skip comments
        if line.strip().startswith('#'):
            return
            
        # Check for Godot class instantiation
        for godot_class in self.godot_classes:
            pattern = rf'\b{godot_class}\.new\(\)'
            if re.search(pattern, line):
                script_data['godot_class_usage'][godot_class].append({
                    'line': line_num,
                    'type': 'instantiation',
                    'context': line.strip()
                })
                
        # Check for Godot method calls
        for method in self.godot_methods:
            pattern = rf'\.{method}\('
            if re.search(pattern, line):
                script_data['godot_method_usage'][method].append({
                    'line': line_num,
                    'context': line.strip()
                })
                
        # Find signal definitions
        signal_def = re.search(r'signal\s+(\w+)(?:\((.*?)\))?', line)
        if signal_def:
            script_data['signal_definitions'].append({
                'name': signal_def.group(1),
                'line': line_num,
                'parameters': signal_def.group(2) if signal_def.group(2) else ''
            })
            
        # Find signal connections
        connect_match = re.search(r'(\w+)\.connect\(([^)]+)\)', line)
        if connect_match:
            script_data['signal_connections'].append({
                'signal': connect_match.group(1),
                'target': connect_match.group(2),
                'line': line_num
            })
            
        # Find @onready variables
        onready_match = re.search(r'@onready\s+var\s+(\w+)(?:\s*:\s*(\w+))?\s*=\s*(.*)', line)
        if onready_match:
            script_data['annotations']['@onready'].append({
                'var_name': onready_match.group(1),
                'type': onready_match.group(2) if onready_match.group(2) else '',
                'value': onready_match.group(3),
                'line': line_num
            })
            
        # Find @export variables
        export_match = re.search(r'@export\s+var\s+(\w+)(?:\s*:\s*(\w+))?\s*=?\s*(.*)', line)
        if export_match:
            script_data['annotations']['@export'].append({
                'var_name': export_match.group(1),
                'type': export_match.group(2) if export_match.group(2) else '',
                'default': export_match.group(3).strip() if export_match.group(3) else '',
                'line': line_num
            })
            
        # Find group additions
        group_match = re.search(r'add_to_group\(["\']([^"\']+)["\']\)', line)
        if group_match and group_match.group(1) not in script_data['groups']:
            script_data['groups'].append(group_match.group(1))
            
        # Track property access
        property_patterns = {
            'position': r'\.position',
            'global_position': r'\.global_position',
            'rotation': r'\.rotation',
            'scale': r'\.scale',
            'visible': r'\.visible',
            'modulate': r'\.modulate',
            'linear_velocity': r'\.linear_velocity',
            'angular_velocity': r'\.angular_velocity',
            'transform': r'\.transform',
            'global_transform': r'\.global_transform'
        }
        
        for prop_name, pattern in property_patterns.items():
            if re.search(pattern, line):
                script_data['properties_accessed'][prop_name].append(line_num)
                
    def generate_detailed_report(self) -> str:
        """Generate a comprehensive report with method groupings"""
        report = []
        report.append("# DETAILED GODOT CLASS USAGE ANALYSIS")
        report.append("# talking_ragdoll_game project")
        report.append("=" * 80)
        report.append("")
        
        # Generate class usage summary
        class_usage_count = defaultdict(int)
        method_usage_count = defaultdict(int)
        
        for script_path, data in self.analysis_results.items():
            for godot_class, usages in data['godot_class_usage'].items():
                class_usage_count[godot_class] += len(usages)
            for method, usages in data['godot_method_usage'].items():
                method_usage_count[method] += len(usages)
                
        report.append("## GODOT CLASS INSTANTIATION SUMMARY")
        report.append("")
        for class_name, count in sorted(class_usage_count.items(), key=lambda x: x[1], reverse=True):
            report.append(f"- **{class_name}**: {count} instantiations")
        report.append("")
        
        report.append("## GODOT METHOD USAGE SUMMARY")
        report.append("")
        for method, count in sorted(method_usage_count.items(), key=lambda x: x[1], reverse=True)[:20]:
            report.append(f"- **{method}()**: {count} calls")
        report.append("")
        
        # Group scripts by functionality
        report.append("## SCRIPTS GROUPED BY FUNCTIONALITY")
        report.append("")
        
        # Physics-heavy scripts
        physics_scripts = []
        ui_scripts = []
        visual_scripts = []
        
        for script_path, data in self.analysis_results.items():
            # Check for physics usage
            physics_methods = ['apply_force', 'apply_central_force', 'move_and_slide', 'apply_torque']
            physics_classes = ['RigidBody3D', 'CharacterBody3D', 'CollisionShape3D']
            
            physics_score = sum(len(data['godot_method_usage'][m]) for m in physics_methods)
            physics_score += sum(len(data['godot_class_usage'][c]) for c in physics_classes)
            
            if physics_score > 3:
                physics_scripts.append((script_path, physics_score))
                
            # Check for UI usage
            ui_classes = ['Button', 'Label', 'Control', 'PanelContainer', 'LineEdit']
            ui_score = sum(len(data['godot_class_usage'][c]) for c in ui_classes)
            if ui_score > 2:
                ui_scripts.append((script_path, ui_score))
                
            # Check for visual/3D usage
            visual_classes = ['MeshInstance3D', 'GPUParticles3D', 'StandardMaterial3D']
            visual_score = sum(len(data['godot_class_usage'][c]) for c in visual_classes)
            if visual_score > 2:
                visual_scripts.append((script_path, visual_score))
                
        report.append("### Physics-Heavy Scripts")
        for script, score in sorted(physics_scripts, key=lambda x: x[1], reverse=True):
            report.append(f"- {script} (score: {score})")
        report.append("")
        
        report.append("### UI-Heavy Scripts")
        for script, score in sorted(ui_scripts, key=lambda x: x[1], reverse=True):
            report.append(f"- {script} (score: {score})")
        report.append("")
        
        report.append("### Visual/3D-Heavy Scripts")
        for script, score in sorted(visual_scripts, key=lambda x: x[1], reverse=True):
            report.append(f"- {script} (score: {score})")
        report.append("")
        
        # Signal usage analysis
        report.append("## SIGNAL ANALYSIS")
        report.append("")
        
        total_signals_defined = 0
        total_connections = 0
        
        for script_path, data in self.analysis_results.items():
            total_signals_defined += len(data['signal_definitions'])
            total_connections += len(data['signal_connections'])
            
        report.append(f"- Total signals defined: {total_signals_defined}")
        report.append(f"- Total signal connections: {total_connections}")
        report.append("")
        
        # Most connected scripts
        report.append("### Scripts with Most Signal Activity")
        signal_activity = []
        for script_path, data in self.analysis_results.items():
            activity = len(data['signal_definitions']) + len(data['signal_connections'])
            if activity > 0:
                signal_activity.append((script_path, activity))
                
        for script, activity in sorted(signal_activity, key=lambda x: x[1], reverse=True)[:10]:
            report.append(f"- {script}: {activity} signal operations")
            
        return '\n'.join(report)
        
    def save_detailed_json(self, output_path: str):
        """Save detailed analysis as JSON"""
        # Convert defaultdicts to regular dicts
        json_data = {}
        for script_path, data in self.analysis_results.items():
            json_data[script_path] = {
                'extends': data['extends'],
                'class_name': data['class_name'],
                'godot_class_usage': dict(data['godot_class_usage']),
                'godot_method_usage': dict(data['godot_method_usage']),
                'signal_definitions': data['signal_definitions'],
                'signal_connections': data['signal_connections'],
                'annotations': dict(data['annotations']),
                'groups': data['groups'],
                'properties_accessed': dict(data['properties_accessed'])
            }
            
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(json_data, f, indent=2)


def main():
    from typing import List
    
    project_root = "/mnt/c/Users/Percision 15/talking_ragdoll_game"
    
    analyzer = DetailedGodotAnalyzer(project_root)
    
    directories = [
        "scripts/autoload",
        "scripts/core",
        "scripts/characters",
        "scripts/systems"
    ]
    
    analyzer.analyze_project(directories)
    
    # Generate detailed report
    report = analyzer.generate_detailed_report()
    
    report_path = os.path.join(project_root, "GODOT_CLASS_DETAILED_ANALYSIS.md")
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write(report)
        
    # Save detailed JSON
    json_path = os.path.join(project_root, "godot_class_detailed_data.json")
    analyzer.save_detailed_json(json_path)
    
    print(f"Detailed analysis complete!")
    print(f"Report saved to: {report_path}")
    print(f"JSON data saved to: {json_path}")
    

if __name__ == "__main__":
    main()