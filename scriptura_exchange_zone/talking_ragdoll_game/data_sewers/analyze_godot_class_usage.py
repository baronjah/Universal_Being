#!/usr/bin/env python3
"""
Analyze Godot class usage in all GDScript files
Helps identify which Godot classes we're using and which powerful ones we're missing
"""

import os
import re
from collections import defaultdict
import json

# Common Godot classes we should check for
IMPORTANT_GODOT_CLASSES = [
    # Nodes
    "Node", "Node2D", "Node3D", "Control", "CanvasItem",
    # 3D
    "MeshInstance3D", "CollisionShape3D", "RigidBody3D", "Area3D",
    "Camera3D", "DirectionalLight3D", "SpotLight3D", "OmniLight3D",
    "Path3D", "PathFollow3D", "CSGShape3D", "GPUParticles3D",
    # Mesh & Geometry
    "ArrayMesh", "ImmediateMesh", "SurfaceTool", "MeshDataTool",
    "Curve3D", "Curve2D", "Geometry3D", "TriangleMesh",
    # Physics
    "PhysicsBody3D", "CharacterBody3D", "StaticBody3D", "PhysicsServer3D",
    "PhysicsDirectBodyState3D", "PhysicsShapeQueryParameters3D",
    # Resources
    "Resource", "Material", "Mesh", "Texture", "Shape3D",
    "StandardMaterial3D", "ShaderMaterial", "Environment",
    # Animation
    "AnimationPlayer", "AnimationTree", "Tween", "SkeletonIK3D",
    # UI
    "Label", "Button", "LineEdit", "TextEdit", "Panel",
    "VBoxContainer", "HBoxContainer", "GridContainer",
    # Utilities
    "Timer", "HTTPRequest", "Thread", "Mutex", "Semaphore",
    "PackedScene", "Script", "GDScript", "Expression",
    # Rendering
    "Viewport", "SubViewport", "RenderingServer", "VisualInstance3D",
    # Audio
    "AudioStreamPlayer", "AudioStreamPlayer3D", "AudioServer",
    # Input
    "Input", "InputEvent", "InputEventKey", "InputEventMouse",
]

def find_godot_classes_in_file(filepath):
    """Find all Godot class references in a GDScript file"""
    classes_found = defaultdict(int)
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Look for class references in various contexts
        patterns = [
            r'\b(\w+)\.new\(',  # ClassName.new()
            r'extends\s+(\w+)',  # extends ClassName
            r':\s*(\w+)\s*=',   # var x: ClassName =
            r'is\s+(\w+)',      # if x is ClassName
            r'as\s+(\w+)',      # x as ClassName
            r'->\s*(\w+):',     # func() -> ClassName:
            r'preload\(".*\.(\w+)"\)',  # preload references
        ]
        
        for pattern in patterns:
            matches = re.findall(pattern, content)
            for match in matches:
                if match in IMPORTANT_GODOT_CLASSES:
                    classes_found[match] += 1
                    
        # Also look for direct class name mentions
        for class_name in IMPORTANT_GODOT_CLASSES:
            count = len(re.findall(r'\b' + class_name + r'\b', content))
            if count > 0:
                classes_found[class_name] += count
                
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        
    return dict(classes_found)

def analyze_project(project_path):
    """Analyze entire project for Godot class usage"""
    all_classes = defaultdict(int)
    file_count = 0
    class_by_file = {}
    
    for root, dirs, files in os.walk(os.path.join(project_path, "scripts")):
        for file in files:
            if file.endswith(".gd"):
                filepath = os.path.join(root, file)
                file_count += 1
                
                classes = find_godot_classes_in_file(filepath)
                if classes:
                    class_by_file[filepath] = classes
                    for class_name, count in classes.items():
                        all_classes[class_name] += count
    
    # Find unused important classes
    unused_classes = []
    for class_name in IMPORTANT_GODOT_CLASSES:
        if class_name not in all_classes:
            unused_classes.append(class_name)
    
    return {
        "total_files": file_count,
        "classes_used": dict(all_classes),
        "unused_important_classes": unused_classes,
        "files_using_classes": class_by_file,
        "most_used": sorted(all_classes.items(), key=lambda x: x[1], reverse=True)[:20]
    }

def generate_report(analysis):
    """Generate a readable report"""
    report = []
    report.append("# Godot Class Usage Analysis Report\n")
    report.append(f"## Summary")
    report.append(f"- Total GDScript files analyzed: {analysis['total_files']}")
    report.append(f"- Unique Godot classes used: {len(analysis['classes_used'])}")
    report.append(f"- Important classes not used: {len(analysis['unused_important_classes'])}\n")
    
    report.append("## Most Used Classes")
    for class_name, count in analysis['most_used']:
        report.append(f"- {class_name}: {count} references")
    
    report.append("\n## Powerful Classes You're Not Using Yet")
    report.append("These could enhance your Universal Being system:")
    
    class_suggestions = {
        "Path3D": "Create smooth paths for beings to follow",
        "PathFollow3D": "Make beings move along paths",
        "CSGShape3D": "Boolean operations for dynamic shapes",
        "GPUParticles3D": "Visual effects for transformations",
        "ImmediateMesh": "Dynamic mesh generation",
        "SurfaceTool": "Procedural mesh building",
        "Curve3D": "Smooth curves for organic shapes",
        "Tween": "Smooth property animations",
        "AnimationTree": "Complex state-based animations",
        "SkeletonIK3D": "Inverse kinematics for natural movement"
    }
    
    for class_name in analysis['unused_important_classes']:
        if class_name in class_suggestions:
            report.append(f"- **{class_name}**: {class_suggestions[class_name]}")
    
    return "\n".join(report)

if __name__ == "__main__":
    project_path = "/mnt/c/Users/Percision 15/talking_ragdoll_game"
    
    print("Analyzing Godot class usage...")
    analysis = analyze_project(project_path)
    
    # Save raw data
    with open(os.path.join(project_path, "godot_class_analysis.json"), "w") as f:
        json.dump(analysis, f, indent=2)
    
    # Generate report
    report = generate_report(analysis)
    with open(os.path.join(project_path, "GODOT_CLASS_USAGE_REPORT.md"), "w") as f:
        f.write(report)
    
    print(f"\nAnalysis complete!")
    print(f"Files analyzed: {analysis['total_files']}")
    print(f"Classes found: {len(analysis['classes_used'])}")
    print(f"\nTop 5 most used classes:")
    for class_name, count in analysis['most_used'][:5]:
        print(f"  {class_name}: {count}")
    print(f"\nFull report saved to: GODOT_CLASS_USAGE_REPORT.md")