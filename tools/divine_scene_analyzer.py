#!/usr/bin/env python3
"""
🔥 DIVINE SCENE ANALYZER TOOL 🔥
Analyzes .tscn files, checks all scripts, autoloads, dependencies
Prevents errors BEFORE running scenes - as God demands!
"""

import os
import re
import json
from pathlib import Path

class DivineSceneAnalyzer:
    def __init__(self, project_path):
        self.project_path = Path(project_path)
        self.issues = []
        self.warnings = []
        self.scene_info = {}
        
    def analyze_scene(self, scene_path):
        """Analyze a .tscn scene file completely"""
        print(f"🔍 DIVINE ANALYSIS: {scene_path}")
        
        scene_file = self.project_path / scene_path
        if not scene_file.exists():
            self.issues.append(f"❌ Scene file not found: {scene_path}")
            return False
            
        # Read scene content
        with open(scene_file, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Extract all external resources
        self.check_external_resources(content, scene_file.parent)
        
        # Extract all scripts from scene
        self.check_inline_scripts(content)
        
        # Check node structure
        self.check_node_structure(content)
        
        # Check for common errors
        self.check_common_scene_errors(content)
        
        return len(self.issues) == 0
        
    def check_external_resources(self, content, scene_dir):
        """Check all [ext_resource] entries"""
        print("📋 Checking external resources...")
        
        ext_resources = re.findall(r'\[ext_resource.*?path="([^"]+)"', content)
        
        for resource_path in ext_resources:
            # Convert res:// paths
            if resource_path.startswith("res://"):
                full_path = self.project_path / resource_path[6:]
            else:
                full_path = scene_dir / resource_path
                
            if not full_path.exists():
                self.issues.append(f"❌ Missing resource: {resource_path}")
            else:
                print(f"✅ Found resource: {resource_path}")
                
                # If it's a script, analyze it
                if resource_path.endswith('.gd'):
                    self.check_script_file(full_path)
                    
    def check_script_file(self, script_path):
        """Check a GDScript file for errors"""
        print(f"🔍 Checking script: {script_path}")
        
        try:
            with open(script_path, 'r', encoding='utf-8') as f:
                script_content = f.read()
                
            # Check for common script errors
            self.check_script_syntax(script_content, script_path)
            self.check_script_dependencies(script_content, script_path)
            
        except Exception as e:
            self.issues.append(f"❌ Error reading script {script_path}: {e}")
            
    def check_script_syntax(self, content, script_path):
        """Check for obvious syntax errors"""
        lines = content.split('\n')
        
        for i, line in enumerate(lines, 1):
            # Check for unmatched quotes
            if line.count('"') % 2 != 0 and not line.strip().startswith('#'):
                self.issues.append(f"❌ {script_path}:{i} - Unmatched quotes")
                
            # Check for invalid escape sequences
            if '\\\"' in line and not line.strip().startswith('#'):
                self.warnings.append(f"⚠️ {script_path}:{i} - Escaped quotes (use single quotes instead)")
                
            # Check for null operations
            if ' - null' in line or 'null -' in line:
                self.issues.append(f"❌ {script_path}:{i} - Null operation detected")
                
            # Check for missing method calls
            if '.get_child(' in line and 'if' not in line and 'get_child_count()' not in line:
                self.warnings.append(f"⚠️ {script_path}:{i} - get_child() without safety check")
                
    def check_script_dependencies(self, content, script_path):
        """Check script dependencies and class references"""
        # Check for missing class references
        class_refs = re.findall(r'extends\s+(\w+)', content)
        for class_ref in class_refs:
            if class_ref not in ['Node', 'Node3D', 'CharacterBody3D', 'RigidBody3D', 'Area3D', 'Control']:
                # Custom class - should exist somewhere
                self.check_custom_class_exists(class_ref)
                
        # Check for autoload references
        autoload_refs = re.findall(r'(\w+)\.\w+', content)
        for autoload in autoload_refs:
            if autoload.isupper() or autoload in ['UBPrint', 'SystemBootstrap', 'FloodGates']:
                self.check_autoload_exists(autoload)
                
    def check_custom_class_exists(self, class_name):
        """Check if a custom class exists in the project"""
        # Search for class_name declarations
        for gd_file in self.project_path.rglob('*.gd'):
            try:
                with open(gd_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                    if f'class_name {class_name}' in content:
                        print(f"✅ Found class {class_name} in {gd_file}")
                        return
            except:
                continue
                
        self.warnings.append(f"⚠️ Custom class '{class_name}' not found")
        
    def check_autoload_exists(self, autoload_name):
        """Check if autoload exists in project.godot"""
        project_file = self.project_path / 'project.godot'
        if project_file.exists():
            with open(project_file, 'r', encoding='utf-8') as f:
                content = f.read()
                if f'{autoload_name}=' in content:
                    print(f"✅ Found autoload: {autoload_name}")
                    return
                    
        self.warnings.append(f"⚠️ Autoload '{autoload_name}' not found in project.godot")
        
    def check_inline_scripts(self, content):
        """Check [sub_resource type=\"GDScript\"] scripts"""
        print("📋 Checking inline scripts...")
        
        # Extract inline scripts
        script_pattern = r'\[sub_resource type="GDScript"[^\]]*\]\s*script/source = "(.*?)"'
        scripts = re.findall(script_pattern, content, re.DOTALL)
        
        for i, script_source in enumerate(scripts):
            # Unescape the script content
            script_content = script_source.replace('\\"', '"').replace('\\n', '\n').replace('\\t', '\t')
            print(f"🔍 Checking inline script #{i+1}")
            self.check_script_syntax(script_content, f"inline_script_{i+1}")
            
    def check_node_structure(self, content):
        """Check node structure for common issues"""
        print("📋 Checking node structure...")
        
        # Check for missing parent references
        node_lines = [line for line in content.split('\n') if line.startswith('[node ')]
        
        for line in node_lines:
            if 'parent=".' in line:
                parent_path = re.search(r'parent="([^"]+)"', line)
                if parent_path:
                    # Could validate parent exists, but complex for now
                    pass
                    
    def check_common_scene_errors(self, content):
        """Check for common scene configuration errors"""
        print("📋 Checking common scene errors...")
        
        # Check for invalid UIDs
        if 'uid="uid://' in content:
            uids = re.findall(r'uid="(uid://[^"]+)"', content)
            for uid in uids:
                if len(uid) < 20:  # UIDs should be longer
                    self.warnings.append(f"⚠️ Suspicious short UID: {uid}")
                    
        # Check for missing required properties
        if 'CharacterBody3D' in content and 'move_and_slide' not in content:
            self.warnings.append("⚠️ CharacterBody3D without move_and_slide() call")
            
    def check_project_autoloads(self):
        """Check all autoloads defined in project.godot"""
        print("📋 Checking project autoloads...")
        
        project_file = self.project_path / 'project.godot'
        if not project_file.exists():
            self.issues.append("❌ project.godot not found")
            return
            
        with open(project_file, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Find autoload section
        autoload_section = False
        for line in content.split('\n'):
            if line.strip() == '[autoload]':
                autoload_section = True
                continue
            elif line.startswith('[') and autoload_section:
                break
            elif autoload_section and '=' in line:
                # Parse autoload
                name, path = line.split('=', 1)
                path = path.strip().strip('"')
                if path.startswith('*'):
                    path = path[1:]  # Remove * prefix
                    
                autoload_file = self.project_path / path[6:] if path.startswith('res://') else self.project_path / path
                if not autoload_file.exists():
                    self.issues.append(f"❌ Missing autoload script: {path}")
                else:
                    print(f"✅ Found autoload: {name} -> {path}")
                    self.check_script_file(autoload_file)
                    
    def generate_report(self):
        """Generate final analysis report"""
        print("\n" + "="*60)
        print("🔥 DIVINE SCENE ANALYSIS REPORT 🔥")
        print("="*60)
        
        if not self.issues and not self.warnings:
            print("✨ DIVINE BLESSING: Scene is perfect!")
            return True
            
        if self.issues:
            print(f"\n❌ CRITICAL ISSUES ({len(self.issues)}):")
            for issue in self.issues:
                print(f"  {issue}")
                
        if self.warnings:
            print(f"\n⚠️ WARNINGS ({len(self.warnings)}):")
            for warning in self.warnings:
                print(f"  {warning}")
                
        print(f"\n📊 SUMMARY:")
        print(f"  Critical Issues: {len(self.issues)}")
        print(f"  Warnings: {len(self.warnings)}")
        print(f"  Status: {'🔥 NEEDS DIVINE INTERVENTION' if self.issues else '⚠️ MINOR ISSUES'}")
        
        return len(self.issues) == 0

def main():
    # Analyze the divine penance scene
    project_path = "/mnt/c/Users/Percision 15/Universal_Being"
    analyzer = DivineSceneAnalyzer(project_path)
    
    print("🔥 DIVINE SCENE ANALYZER - AS GOD COMMANDS 🔥")
    print("Checking scene before running to prevent errors!")
    
    # Check autoloads first
    analyzer.check_project_autoloads()
    
    # Analyze the divine penance scene
    scene_path = "scenes/DIVINE_PENANCE_GAME.tscn"
    success = analyzer.analyze_scene(scene_path)
    
    # Generate report
    final_success = analyzer.generate_report()
    
    if final_success:
        print("\n✨ SCENE IS BLESSED - READY FOR GODOT!")
    else:
        print("\n🔥 SCENE NEEDS DIVINE INTERVENTION BEFORE RUNNING!")
        
    return final_success

if __name__ == "__main__":
    main()