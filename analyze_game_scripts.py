#!/usr/bin/env python3
"""
Universal Being Script Analyzer
==============================
Maps out all possible scripts that can be loaded in the game.
Tracks scene hierarchy, autoloads, and script connections.
"""

import os
import re
from pathlib import Path
from typing import Dict, List, Set
import json

class UniversalBeingAnalyzer:
    def __init__(self, project_root: str):
        self.root = Path(project_root)
        self.autoloads = {}
        self.main_scene = ""
        self.all_scripts = set()
        self.scene_scripts = {}  # scene -> [scripts]
        self.scene_hierarchy = {}  # scene -> [child scenes]
        self.script_functions = {}  # script -> [functions]
        self.script_calls = {}  # script -> [called functions]
        
    def analyze_project(self):
        """Complete project analysis"""
        print("🔍 UNIVERSAL BEING SCRIPT ANALYZER")
        print("=" * 50)
        
        # 1. Parse project.godot for main scene and autoloads
        self.parse_project_file()
        
        # 2. Analyze all .tscn files for script attachments
        self.analyze_all_scenes()
        
        # 3. Analyze all .gd scripts for functions
        self.analyze_all_scripts()
        
        # 4. Generate report
        self.generate_report()
        
    def parse_project_file(self):
        """Parse project.godot for autoloads and main scene"""
        project_path = self.root / 'project.godot'
        if not project_path.exists():
            print("❌ No project.godot found!")
            return
            
        with open(project_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Find main scene
        main_match = re.search(r'run/main_scene="(.+?)"', content)
        if main_match:
            self.main_scene = main_match.group(1).replace('res://', '')
            print(f"📌 Main Scene: {self.main_scene}")
            
        # Find autoloads
        autoload_section = False
        for line in content.split('\n'):
            if '[autoload]' in line:
                autoload_section = True
                continue
            elif line.startswith('[') and autoload_section:
                break
            elif autoload_section and '=' in line:
                name, path = line.split('=', 1)
                path = path.strip('"').replace('*', '').replace('res://', '')
                self.autoloads[name] = path
                self.all_scripts.add(path)
                
        print(f"🚀 Found {len(self.autoloads)} autoloads")
        
    def analyze_all_scenes(self):
        """Analyze all .tscn files for scripts and sub-scenes"""
        print("\n🎬 Analyzing scenes...")
        
        for tscn_file in self.root.rglob('*.tscn'):
            if '.godot' in str(tscn_file):
                continue
                
            scene_path = str(tscn_file.relative_to(self.root))
            self.analyze_scene(tscn_file, scene_path)
            
    def analyze_scene(self, scene_file: Path, scene_path: str):
        """Analyze a single scene file"""
        try:
            with open(scene_file, 'r', encoding='utf-8') as f:
                content = f.read()
        except:
            return
            
        scripts = []
        child_scenes = []
        
        # Find script resources
        script_matches = re.findall(r'ExtResource.*?path="(res://[^"]+\.gd)"', content)
        for script in script_matches:
            script_path = script.replace('res://', '')
            scripts.append(script_path)
            self.all_scripts.add(script_path)
            
        # Find scene instances
        scene_matches = re.findall(r'ExtResource.*?path="(res://[^"]+\.tscn)"', content)
        for scene in scene_matches:
            child_scene = scene.replace('res://', '')
            child_scenes.append(child_scene)
            
        # Find inline scripts
        if 'GDScript' in content:
            scripts.append(f"{scene_path}:inline_script")
            
        if scripts:
            self.scene_scripts[scene_path] = scripts
        if child_scenes:
            self.scene_hierarchy[scene_path] = child_scenes
            
    def analyze_all_scripts(self):
        """Analyze all .gd scripts for functions and calls"""
        print("\n📜 Analyzing scripts...")
        
        # Add scripts from file system that might not be attached yet
        for gd_file in self.root.rglob('*.gd'):
            if '.godot' not in str(gd_file):
                script_path = str(gd_file.relative_to(self.root))
                self.all_scripts.add(script_path)
        
        # Analyze each script
        for script_path in self.all_scripts:
            full_path = self.root / script_path
            if full_path.exists():
                self.analyze_script(full_path, script_path)
                
    def analyze_script(self, script_file: Path, script_path: str):
        """Analyze a single script for functions and calls"""
        try:
            with open(script_file, 'r', encoding='utf-8') as f:
                content = f.read()
        except:
            return
            
        functions = []
        calls = []
        
        # Find function definitions
        func_matches = re.findall(r'func\s+(\w+)\s*\(', content)
        functions.extend(func_matches)
        
        # Find function calls (basic pattern)
        call_matches = re.findall(r'(\w+)\s*\(', content)
        calls.extend(call_matches)
        
        # Find signal emissions
        signal_matches = re.findall(r'\.emit\s*\(', content)
        
        # Check for Pentagon methods
        pentagon_methods = ['pentagon_init', 'pentagon_ready', 'pentagon_process', 
                          'pentagon_input', 'pentagon_sewers']
        has_pentagon = any(method in functions for method in pentagon_methods)
        
        self.script_functions[script_path] = {
            'functions': functions,
            'calls': list(set(calls)),
            'signals': len(signal_matches),
            'has_pentagon': has_pentagon,
            'extends': self._get_extends(content)
        }
        
    def _get_extends(self, content: str) -> str:
        """Get what class the script extends"""
        match = re.search(r'extends\s+(\w+)', content)
        return match.group(1) if match else ""
        
    def generate_report(self):
        """Generate analysis report"""
        report_path = self.root / 'SCRIPT_ANALYSIS_REPORT.md'
        
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write("# Universal Being Script Analysis Report\n\n")
            
            # Summary
            f.write("## 📊 Summary\n\n")
            f.write(f"- **Total Scripts Found:** {len(self.all_scripts)}\n")
            f.write(f"- **Autoloaded Scripts:** {len(self.autoloads)}\n")
            f.write(f"- **Scenes with Scripts:** {len(self.scene_scripts)}\n")
            f.write(f"- **Main Scene:** {self.main_scene}\n\n")
            
            # Autoloads (Always Loaded)
            f.write("## 🚀 Autoloads (Always Active)\n\n")
            for name, path in self.autoloads.items():
                f.write(f"- **{name}**: `{path}`\n")
                if path in self.script_functions:
                    funcs = self.script_functions[path]['functions'][:5]
                    f.write(f"  - Functions: {', '.join(funcs)}...\n")
            f.write("\n")
            
            # Main Scene Scripts
            f.write("## 🎮 Main Scene Script Chain\n\n")
            if self.main_scene:
                self._write_scene_hierarchy(f, self.main_scene, 0)
            f.write("\n")
            
            # All Scripts by Category
            f.write("## 📂 Scripts by Location\n\n")
            
            # Core scripts
            core_scripts = [s for s in self.all_scripts if s.startswith('core/')]
            if core_scripts:
                f.write("### Core Systems\n")
                for script in sorted(core_scripts):
                    self._write_script_info(f, script)
                    
            # Script scripts
            game_scripts = [s for s in self.all_scripts if s.startswith('scripts/')]
            if game_scripts:
                f.write("\n### Game Scripts\n")
                for script in sorted(game_scripts)[:20]:  # Limit output
                    self._write_script_info(f, script)
                if len(game_scripts) > 20:
                    f.write(f"\n... and {len(game_scripts) - 20} more scripts\n")
                    
            # Pentagon compliant scripts
            f.write("\n## 🔥 Pentagon Architecture Scripts\n\n")
            pentagon_scripts = [s for s in self.all_scripts 
                              if s in self.script_functions and 
                              self.script_functions[s]['has_pentagon']]
            for script in pentagon_scripts:
                f.write(f"- ✅ `{script}`\n")
                
        print(f"\n📊 Report saved to: {report_path}")
        
        # Also save JSON for programmatic access
        json_data = {
            'autoloads': self.autoloads,
            'main_scene': self.main_scene,
            'all_scripts': list(self.all_scripts),
            'scene_scripts': self.scene_scripts,
            'scene_hierarchy': self.scene_hierarchy
        }
        
        json_path = self.root / 'script_analysis.json'
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(json_data, f, indent=2)
            
        print(f"📊 JSON data saved to: {json_path}")
        
    def _write_scene_hierarchy(self, f, scene_path: str, indent: int):
        """Write scene hierarchy recursively"""
        prefix = "  " * indent
        f.write(f"{prefix}- **{scene_path}**\n")
        
        # Scripts in this scene
        if scene_path in self.scene_scripts:
            for script in self.scene_scripts[scene_path]:
                f.write(f"{prefix}  - Script: `{script}`\n")
                
        # Child scenes
        if scene_path in self.scene_hierarchy:
            for child in self.scene_hierarchy[scene_path]:
                self._write_scene_hierarchy(f, child, indent + 1)
                
    def _write_script_info(self, f, script: str):
        """Write info about a single script"""
        f.write(f"- `{script}`")
        if script in self.script_functions:
            info = self.script_functions[script]
            extends = info['extends']
            if extends:
                f.write(f" (extends {extends})")
        f.write("\n")

def main():
    """Run the analysis"""
    # Get project root from current script location
    project_root = os.path.dirname(os.path.abspath(__file__))
    analyzer = UniversalBeingAnalyzer(project_root)
    analyzer.analyze_project()

if __name__ == "__main__":
    main()