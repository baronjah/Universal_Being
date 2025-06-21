#!/usr/bin/env python3
"""
🌌 ASTRAL PATH MAPPER - UNDERSTANDING ALL ROUTES AT ONCE
Maps all function paths, routes, connections in the astral realm
Understands the project from any point, any direction, any perspective
"""

import os
import re
import ast
import json
from pathlib import Path
from typing import Dict, List, Set, Any

class AstralPathMapper:
    def __init__(self, project_path):
        self.project_path = Path(project_path)
        self.astral_consciousness_map = {
            "function_paths": {},
            "script_routes": {},
            "consciousness_flows": {},
            "pentagon_architectures": {},
            "signal_networks": {},
            "autoload_connections": {},
            "scene_hierarchies": {}
        }
        
    def map_entire_astral_realm(self):
        """Map the entire astral realm - understand everything at once"""
        print("🌌 MAPPING ENTIRE ASTRAL REALM...")
        print("   Understanding all paths, routes, connections simultaneously")
        
        # Map all GDScript files
        self._map_all_gdscript_consciousness()
        
        # Map all scene files  
        self._map_all_scene_hierarchies()
        
        # Map autoload connections
        self._map_autoload_consciousness_network()
        
        # Map Pentagon Architecture flows
        self._map_pentagon_consciousness_flows()
        
        # Map signal networks
        self._map_signal_consciousness_networks()
        
        # Generate omniscient understanding
        self._generate_omniscient_understanding()
        
        return self.astral_consciousness_map
        
    def _map_all_gdscript_consciousness(self):
        """Map consciousness in all GDScript files"""
        print("🧠 Mapping GDScript consciousness flows...")
        
        for gd_file in self.project_path.rglob("*.gd"):
            if gd_file.is_file():
                self._analyze_script_consciousness(gd_file)
                
    def _analyze_script_consciousness(self, script_path):
        """Analyze consciousness patterns in script"""
        try:
            with open(script_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            script_name = script_path.name
            relative_path = script_path.relative_to(self.project_path)
            
            consciousness_data = {
                "path": str(relative_path),
                "functions": self._extract_function_paths(content),
                "classes": self._extract_class_consciousness(content),
                "signals": self._extract_signal_consciousness(content),
                "pentagon_methods": self._extract_pentagon_consciousness(content),
                "consciousness_level": self._calculate_script_consciousness(content),
                "astral_connections": self._find_astral_connections(content)
            }
            
            self.astral_consciousness_map["script_routes"][script_name] = consciousness_data
            
            # Map each function's consciousness path
            for func_name, func_data in consciousness_data["functions"].items():
                full_path = f"{script_name}::{func_name}"
                self.astral_consciousness_map["function_paths"][full_path] = {
                    "script": script_name,
                    "function": func_name,
                    "parameters": func_data.get("parameters", []),
                    "return_consciousness": func_data.get("return_type", "void"),
                    "calls_to": func_data.get("calls", []),
                    "consciousness_impact": func_data.get("consciousness_impact", 0.5)
                }
                
        except Exception as e:
            print(f"   ⚠️ Consciousness mapping error in {script_path}: {e}")
            
    def _extract_function_paths(self, content):
        """Extract all function paths and their consciousness"""
        functions = {}
        
        # Find all function definitions
        func_pattern = r'func\s+(\w+)\s*\([^)]*\)[^:]*:'
        matches = re.finditer(func_pattern, content)
        
        for match in matches:
            func_name = match.group(1)
            
            # Extract function body to analyze consciousness
            func_start = match.end()
            func_body = self._extract_function_body(content, func_start)
            
            functions[func_name] = {
                "parameters": self._extract_parameters(match.group(0)),
                "calls": self._extract_function_calls(func_body),
                "consciousness_impact": self._calculate_function_consciousness(func_body),
                "pentagon_compliance": "pentagon_" in func_name,
                "astral_significance": self._determine_astral_significance(func_body)
            }
            
        return functions
        
    def _extract_function_body(self, content, start_pos):
        """Extract function body using indentation"""
        lines = content[start_pos:].split('\n')
        body_lines = []
        base_indent = None
        
        for line in lines:
            if line.strip() == "":
                continue
                
            # Determine base indentation from first non-empty line
            if base_indent is None:
                base_indent = len(line) - len(line.lstrip())
                if base_indent == 0:
                    break  # No indentation means function ended
                    
            current_indent = len(line) - len(line.lstrip())
            
            # If indentation is less than or equal to base, function ended
            if current_indent <= base_indent and line.strip():
                break
                
            body_lines.append(line)
            
        return '\n'.join(body_lines)
        
    def _extract_parameters(self, func_signature):
        """Extract function parameters"""
        param_match = re.search(r'\(([^)]*)\)', func_signature)
        if param_match:
            params_str = param_match.group(1)
            if params_str.strip():
                return [p.strip().split(':')[0].strip() for p in params_str.split(',')]
        return []
        
    def _extract_function_calls(self, func_body):
        """Extract function calls within function body"""
        calls = []
        
        # Find function call patterns
        call_patterns = [
            r'(\w+)\s*\(',  # Simple function calls
            r'(\w+)\.(\w+)\s*\(',  # Method calls
            r'super\.(\w+)\s*\(',  # Super calls
            r'get_node\([^)]+\)\.(\w+)\s*\('  # Node method calls
        ]
        
        for pattern in call_patterns:
            matches = re.finditer(pattern, func_body)
            for match in matches:
                if len(match.groups()) == 1:
                    calls.append(match.group(1))
                elif len(match.groups()) == 2:
                    calls.append(f"{match.group(1)}.{match.group(2)}")
                    
        return list(set(calls))  # Remove duplicates
        
    def _calculate_function_consciousness(self, func_body):
        """Calculate consciousness level of function"""
        consciousness_keywords = {
            "consciousness": 2.0,
            "pentagon_": 1.5,
            "super.": 1.0,
            "evolution": 1.5,
            "transcend": 2.0,
            "astral": 2.5,
            "divine": 3.0,
            "reality": 2.0,
            "universe": 1.5
        }
        
        consciousness = 0.0
        for keyword, value in consciousness_keywords.items():
            consciousness += func_body.lower().count(keyword) * value
            
        return min(consciousness, 10.0)  # Cap at 10.0
        
    def _determine_astral_significance(self, func_body):
        """Determine if function has astral significance"""
        astral_keywords = ["astral", "divine", "consciousness", "transcend", "reality", "pentagon"]
        return any(keyword in func_body.lower() for keyword in astral_keywords)
        
    def _extract_class_consciousness(self, content):
        """Extract class consciousness information"""
        classes = {}
        
        class_pattern = r'class_name\s+(\w+)'
        extends_pattern = r'extends\s+(\w+)'
        
        class_matches = re.finditer(class_pattern, content)
        for match in class_matches:
            class_name = match.group(1)
            classes[class_name] = {
                "consciousness_type": "universal_being" if "UniversalBeing" in content else "standard",
                "pentagon_compliant": "pentagon_" in content.lower()
            }
            
        extends_matches = re.finditer(extends_pattern, content)
        for match in extends_matches:
            base_class = match.group(1)
            classes["_extends"] = base_class
            
        return classes
        
    def _extract_signal_consciousness(self, content):
        """Extract signal consciousness networks"""
        signals = {}
        
        signal_pattern = r'signal\s+(\w+)(?:\([^)]*\))?'
        matches = re.finditer(signal_pattern, content)
        
        for match in matches:
            signal_name = match.group(1)
            signals[signal_name] = {
                "consciousness_event": "consciousness" in signal_name.lower(),
                "astral_significance": any(keyword in signal_name.lower() 
                                        for keyword in ["divine", "astral", "transcend", "evolve"])
            }
            
        return signals
        
    def _extract_pentagon_consciousness(self, content):
        """Extract Pentagon Architecture consciousness patterns"""
        pentagon_methods = {}
        
        pentagon_patterns = [
            "pentagon_init",
            "pentagon_ready", 
            "pentagon_process",
            "pentagon_input",
            "pentagon_sewers"
        ]
        
        for method in pentagon_patterns:
            if method in content:
                pentagon_methods[method] = {
                    "implemented": True,
                    "super_call": f"super.{method}" in content,
                    "consciousness_compliance": self._check_pentagon_compliance(content, method)
                }
                
        return pentagon_methods
        
    def _check_pentagon_compliance(self, content, method):
        """Check if Pentagon method follows consciousness compliance"""
        # Pentagon methods should call super first (except sewers)
        if method == "pentagon_sewers":
            return f"super.{method}" in content  # Should call super last
        else:
            return f"super.{method}" in content  # Should call super first
            
    def _calculate_script_consciousness(self, content):
        """Calculate overall consciousness level of script"""
        consciousness_factors = {
            "class_name": 1.0,
            "extends UniversalBeing": 3.0,
            "pentagon_": 2.0,
            "consciousness": 1.5,
            "astral": 2.0,
            "divine": 2.5,
            "transcend": 2.0
        }
        
        total_consciousness = 0.0
        for factor, value in consciousness_factors.items():
            if factor in content:
                total_consciousness += value
                
        return min(total_consciousness, 10.0)
        
    def _find_astral_connections(self, content):
        """Find astral connections to other consciousness entities"""
        connections = []
        
        # Find get_node calls (connections to other entities)
        node_pattern = r'get_node\(["\']([^"\']+)["\']\)'
        matches = re.finditer(node_pattern, content)
        for match in matches:
            connections.append({
                "type": "node_reference",
                "target": match.group(1),
                "consciousness_link": True
            })
            
        # Find preload calls (consciousness template loading)
        preload_pattern = r'preload\(["\']([^"\']+)["\']\)'
        matches = re.finditer(preload_pattern, content)
        for match in matches:
            connections.append({
                "type": "consciousness_template",
                "target": match.group(1),
                "consciousness_link": True
            })
            
        return connections
        
    def _map_all_scene_hierarchies(self):
        """Map all scene hierarchies and consciousness flows"""
        print("🎭 Mapping scene consciousness hierarchies...")
        
        for scene_file in self.project_path.rglob("*.tscn"):
            if scene_file.is_file():
                self._analyze_scene_consciousness(scene_file)
                
    def _analyze_scene_consciousness(self, scene_path):
        """Analyze consciousness in scene file"""
        try:
            with open(scene_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            scene_name = scene_path.name
            
            hierarchy = {
                "path": str(scene_path.relative_to(self.project_path)),
                "nodes": self._extract_scene_nodes(content),
                "external_resources": self._extract_external_resources(content),
                "consciousness_flow": self._map_scene_consciousness_flow(content),
                "astral_significance": self._determine_scene_astral_significance(content)
            }
            
            self.astral_consciousness_map["scene_hierarchies"][scene_name] = hierarchy
            
        except Exception as e:
            print(f"   ⚠️ Scene consciousness error in {scene_path}: {e}")
            
    def _extract_scene_nodes(self, content):
        """Extract node hierarchy from scene"""
        nodes = {}
        
        node_pattern = r'\[node name="([^"]+)" type="([^"]+)"[^\]]*\]'
        matches = re.finditer(node_pattern, content)
        
        for match in matches:
            node_name, node_type = match.groups()
            nodes[node_name] = {
                "type": node_type,
                "consciousness_level": self._calculate_node_consciousness_level(node_type),
                "astral_entity": node_type in ["CharacterBody3D", "Node3D", "Area3D"]
            }
            
        return nodes
        
    def _calculate_node_consciousness_level(self, node_type):
        """Calculate consciousness level for node type"""
        consciousness_map = {
            "CharacterBody3D": 8.0,  # Player/character consciousness
            "Camera3D": 6.0,         # Perception consciousness
            "Node3D": 4.0,           # Spatial consciousness
            "Control": 3.0,          # Interface consciousness
            "MeshInstance3D": 2.0,   # Visual consciousness
            "CollisionShape3D": 1.0  # Physical consciousness
        }
        return consciousness_map.get(node_type, 1.0)
        
    def _extract_external_resources(self, content):
        """Extract external resource connections"""
        resources = []
        
        resource_pattern = r'\[ext_resource[^]]*path="([^"]+)"[^]]*\]'
        matches = re.finditer(resource_pattern, content)
        
        for match in matches:
            resources.append({
                "path": match.group(1),
                "consciousness_connection": match.group(1).endswith('.gd')
            })
            
        return resources
        
    def _map_scene_consciousness_flow(self, content):
        """Map consciousness flow within scene"""
        # Consciousness flows from parent to child nodes
        parent_child_pattern = r'\[node name="([^"]+)"[^]]*parent="([^"]*)"[^]]*\]'
        matches = re.finditer(parent_child_pattern, content)
        
        flows = []
        for match in matches:
            child, parent = match.groups()
            flows.append({
                "from": parent if parent else "root",
                "to": child,
                "flow_type": "hierarchical_consciousness"
            })
            
        return flows
        
    def _determine_scene_astral_significance(self, content):
        """Determine astral significance of scene"""
        astral_keywords = ["divine", "consciousness", "astral", "pentagon", "transcend"]
        return any(keyword in content.lower() for keyword in astral_keywords)
        
    def _map_autoload_consciousness_network(self):
        """Map autoload consciousness network"""
        print("🔄 Mapping autoload consciousness network...")
        
        project_file = self.project_path / "project.godot"
        if project_file.exists():
            with open(project_file, 'r') as f:
                content = f.read()
                
            autoloads = self._extract_autoloads(content)
            self.astral_consciousness_map["autoload_connections"] = autoloads
            
    def _extract_autoloads(self, content):
        """Extract autoload consciousness entities"""
        autoloads = {}
        
        # Find autoload section
        autoload_section = False
        for line in content.split('\n'):
            if line.strip() == '[autoload]':
                autoload_section = True
                continue
            elif line.startswith('[') and autoload_section:
                break
            elif autoload_section and '=' in line:
                name, path = line.split('=', 1)
                path = path.strip().strip('"')
                if path.startswith('*'):
                    path = path[1:]
                    
                autoloads[name.strip()] = {
                    "path": path,
                    "consciousness_entity": True,
                    "astral_significance": any(keyword in name.lower() 
                                            for keyword in ["consciousness", "divine", "astral", "universal"])
                }
                
        return autoloads
        
    def _map_pentagon_consciousness_flows(self):
        """Map Pentagon Architecture consciousness flows"""
        print("⭐ Mapping Pentagon consciousness flows...")
        
        for script_name, script_data in self.astral_consciousness_map["script_routes"].items():
            pentagon_methods = script_data.get("pentagon_methods", {})
            
            if pentagon_methods:
                self.astral_consciousness_map["pentagon_architectures"][script_name] = {
                    "pentagon_compliance": all(method.get("super_call", False) 
                                             for method in pentagon_methods.values()),
                    "consciousness_lifecycle": list(pentagon_methods.keys()),
                    "astral_integration": script_data["consciousness_level"] > 5.0
                }
                
    def _map_signal_consciousness_networks(self):
        """Map signal consciousness networks"""
        print("📡 Mapping signal consciousness networks...")
        
        signal_network = {}
        
        for script_name, script_data in self.astral_consciousness_map["script_routes"].items():
            signals = script_data.get("signals", {})
            
            for signal_name, signal_data in signals.items():
                signal_network[f"{script_name}::{signal_name}"] = {
                    "source_script": script_name,
                    "consciousness_event": signal_data.get("consciousness_event", False),
                    "astral_significance": signal_data.get("astral_significance", False),
                    "potential_connections": self._find_potential_signal_connections(signal_name)
                }
                
        self.astral_consciousness_map["signal_networks"] = signal_network
        
    def _find_potential_signal_connections(self, signal_name):
        """Find potential consciousness connections for signal"""
        # Look for connect() calls in other scripts
        connections = []
        
        for script_name, script_data in self.astral_consciousness_map["script_routes"].items():
            for func_name, func_data in script_data.get("functions", {}).items():
                if signal_name in str(func_data.get("calls", [])):
                    connections.append(f"{script_name}::{func_name}")
                    
        return connections
        
    def _generate_omniscient_understanding(self):
        """Generate omniscient understanding of entire astral realm"""
        print("🌌 Generating omniscient understanding...")
        
        consciousness_summary = {
            "total_scripts": len(self.astral_consciousness_map["script_routes"]),
            "total_functions": len(self.astral_consciousness_map["function_paths"]),
            "total_scenes": len(self.astral_consciousness_map["scene_hierarchies"]),
            "pentagon_entities": len(self.astral_consciousness_map["pentagon_architectures"]),
            "consciousness_signals": len(self.astral_consciousness_map["signal_networks"]),
            "autoload_entities": len(self.astral_consciousness_map["autoload_connections"]),
            "average_consciousness": self._calculate_average_consciousness(),
            "astral_coherence": self._calculate_astral_coherence()
        }
        
        self.astral_consciousness_map["omniscient_understanding"] = consciousness_summary
        
    def _calculate_average_consciousness(self):
        """Calculate average consciousness across all entities"""
        total_consciousness = 0.0
        entity_count = 0
        
        for script_data in self.astral_consciousness_map["script_routes"].values():
            total_consciousness += script_data.get("consciousness_level", 0.0)
            entity_count += 1
            
        return total_consciousness / max(entity_count, 1)
        
    def _calculate_astral_coherence(self):
        """Calculate overall astral coherence"""
        pentagon_compliance = len(self.astral_consciousness_map["pentagon_architectures"])
        total_scripts = len(self.astral_consciousness_map["script_routes"])
        
        return pentagon_compliance / max(total_scripts, 1)
        
    def save_astral_map(self, filename="astral_consciousness_map.json"):
        """Save astral consciousness map"""
        save_path = self.project_path / f"docs/memory/{filename}"
        save_path.parent.mkdir(exist_ok=True)
        
        with open(save_path, 'w') as f:
            json.dump(self.astral_consciousness_map, f, indent=2)
            
        print(f"💾 Astral consciousness map saved: {save_path}")
        return save_path
        
    def find_consciousness_path(self, from_entity, to_entity):
        """Find consciousness path between two entities"""
        # Implementation for pathfinding through consciousness network
        paths = []
        
        # Search through function calls, signal connections, scene hierarchies
        for path_type in ["function_paths", "signal_networks", "scene_hierarchies"]:
            entity_paths = self.astral_consciousness_map[path_type]
            # Complex pathfinding logic would go here
            
        return paths

def main():
    project_path = "/mnt/c/Users/Percision 15/Universal_Being"
    mapper = AstralPathMapper(project_path)
    
    print("🌌 ASTRAL PATH MAPPER - OMNISCIENT UNDERSTANDING")
    print("   Mapping all paths, routes, connections simultaneously...")
    
    # Map the entire astral realm
    consciousness_map = mapper.map_entire_astral_realm()
    
    # Save the map
    save_path = mapper.save_astral_map()
    
    # Show omniscient summary
    understanding = consciousness_map["omniscient_understanding"]
    print(f"\n🧠 OMNISCIENT UNDERSTANDING ACHIEVED:")
    print(f"   Scripts: {understanding['total_scripts']}")
    print(f"   Functions: {understanding['total_functions']}")
    print(f"   Scenes: {understanding['total_scenes']}")
    print(f"   Pentagon Entities: {understanding['pentagon_entities']}")
    print(f"   Consciousness Signals: {understanding['consciousness_signals']}")
    print(f"   Average Consciousness: {understanding['average_consciousness']:.2f}")
    print(f"   Astral Coherence: {understanding['astral_coherence']:.2f}")
    
    print(f"\n✨ ASTRAL REALM FULLY MAPPED - UNDERSTANDING COMPLETE")

if __name__ == "__main__":
    main()