#!/usr/bin/env python3
"""
Universal Being Print Statement Scanner
Scans all .gd files for print statements and creates a comprehensive replacement plan
"""

import os
import re
import json
from pathlib import Path

def scan_directory_for_prints(directory_path):
    """Scan directory for all print statements in .gd files"""
    print_statements = []
    total_files = 0
    
    for root, dirs, files in os.walk(directory_path):
        # Skip hidden directories and common ignore patterns
        dirs[:] = [d for d in dirs if not d.startswith('.') and d not in ['__pycache__', '.import']]
        
        for file in files:
            if file.endswith('.gd'):
                file_path = os.path.join(root, file)
                total_files += 1
                
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        lines = f.readlines()
                        
                    for i, line in enumerate(lines, 1):
                        # Look for print statements (various patterns)
                        print_matches = re.finditer(r'print\s*\([^)]*\)', line)
                        for match in print_matches:
                            print_statements.append({
                                'file': os.path.relpath(file_path, directory_path),
                                'line_number': i,
                                'line_content': line.strip(),
                                'print_statement': match.group(),
                                'context': 'gemma' if 'gemma' in line.lower() else 'general'
                            })
                            
                except Exception as e:
                    print(f"Error reading {file_path}: {e}")
    
    return print_statements, total_files

def categorize_print_statements(statements):
    """Categorize print statements by type and priority"""
    categories = {
        'gemma_ai': [],
        'consciousness': [],
        'pentagon_lifecycle': [],
        'socket_system': [],
        'dna_evolution': [],
        'physics_interaction': [],
        'debugging': [],
        'general': []
    }
    
    for stmt in statements:
        line = stmt['line_content'].lower()
        
        if 'gemma' in line or '🤖' in line:
            categories['gemma_ai'].append(stmt)
        elif 'consciousness' in line or '🧠' in line:
            categories['consciousness'].append(stmt)
        elif 'pentagon' in line or any(phase in line for phase in ['init', 'ready', 'process', 'input', 'sewers']):
            categories['pentagon_lifecycle'].append(stmt)
        elif 'socket' in line or '🔌' in line:
            categories['socket_system'].append(stmt)
        elif 'dna' in line or 'evolution' in line or '🧬' in line:
            categories['dna_evolution'].append(stmt)
        elif 'physics' in line or 'collision' in line or '⚡' in line:
            categories['physics_interaction'].append(stmt)
        elif 'debug' in line or 'error' in line or 'warning' in line:
            categories['debugging'].append(stmt)
        else:
            categories['general'].append(stmt)
    
    return categories

def create_stellar_color_map():
    """Define stellar colors for different message types"""
    return {
        'gemma_ai': {'color': 'light_blue', 'rgb': '(0.7, 0.9, 1.0)', 'description': 'AI Communications'},
        'consciousness': {'color': 'white', 'rgb': '(1.0, 1.0, 1.0)', 'description': 'Consciousness Events'},
        'pentagon_lifecycle': {'color': 'yellow', 'rgb': '(1.0, 1.0, 0.0)', 'description': 'Pentagon Lifecycle'},
        'socket_system': {'color': 'orange', 'rgb': '(1.0, 0.6, 0.0)', 'description': 'Socket Operations'},
        'dna_evolution': {'color': 'purple', 'rgb': '(0.8, 0.2, 0.8)', 'description': 'DNA & Evolution'},
        'physics_interaction': {'color': 'red', 'rgb': '(1.0, 0.2, 0.2)', 'description': 'Physics Events'},
        'debugging': {'color': 'dark_brown', 'rgb': '(0.4, 0.2, 0.1)', 'description': 'Debug Messages'},
        'general': {'color': 'blue', 'rgb': '(0.2, 0.4, 1.0)', 'description': 'General Messages'}
    }

def generate_replacement_functions():
    """Generate the visual replacement functions code"""
    stellar_colors = create_stellar_color_map()
    
    function_code = '''
# 3D Visual Communication System for Universal Being
# Replaces all print statements with stellar-colored 3D visual feedback

extends Node

# Stellar color definitions
const STELLAR_COLORS = {
'''
    
    for category, color_info in stellar_colors.items():
        function_code += f'    "{category}": Color{color_info["rgb"]},  # {color_info["description"]}\n'
    
    function_code += '''
}

# Main visual communication function
func visual_message(message: String, category: String = "general", duration: float = 3.0) -> void:
    var color = STELLAR_COLORS.get(category, STELLAR_COLORS["general"])
    
    # Create 3D text display
    var label_3d = Label3D.new()
    label_3d.text = message
    label_3d.modulate = color
    label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    label_3d.font_size = 24
    
    # Position above the being
    label_3d.position = Vector3(0, 2, 0)
    
    # Add to scene
    if get_parent():
        get_parent().add_child(label_3d)
    
    # Animate and remove
    var tween = create_tween()
    tween.parallel().tween_property(label_3d, "position", Vector3(0, 4, 0), duration)
    tween.parallel().tween_property(label_3d, "modulate:a", 0.0, duration)
    tween.tween_callback(label_3d.queue_free)

# Specific functions for each category
func gemma_message(text: String) -> void:
    visual_message("🤖 Gemma: " + text, "gemma_ai")

func consciousness_message(text: String) -> void:
    visual_message("🧠 " + text, "consciousness")

func pentagon_message(text: String) -> void:
    visual_message("🔆 " + text, "pentagon_lifecycle")

func socket_message(text: String) -> void:
    visual_message("🔌 " + text, "socket_system")

func dna_message(text: String) -> void:
    visual_message("🧬 " + text, "dna_evolution")

func physics_message(text: String) -> void:
    visual_message("⚡ " + text, "physics_interaction")

func debug_message(text: String) -> void:
    visual_message("🔧 " + text, "debugging")
'''
    
    return function_code

def main():
    # Scan the current directory (Universal_being)
    current_dir = os.getcwd()
    print(f"Scanning {current_dir} for print statements...")
    
    statements, total_files = scan_directory_for_prints(current_dir)
    categories = categorize_print_statements(statements)
    stellar_colors = create_stellar_color_map()
    
    print(f"\n📊 SCAN RESULTS:")
    print(f"Total .gd files scanned: {total_files}")
    print(f"Total print statements found: {len(statements)}")
    
    print(f"\n🎨 CATEGORIZATION:")
    for category, stmts in categories.items():
        if stmts:
            color_info = stellar_colors[category]
            print(f"{category}: {len(stmts)} statements ({color_info['color']} - {color_info['description']})")
    
    # Generate detailed report
    report = {
        'scan_summary': {
            'total_files': total_files,
            'total_print_statements': len(statements),
            'scan_directory': current_dir
        },
        'categories': {cat: len(stmts) for cat, stmts in categories.items()},
        'stellar_color_mapping': stellar_colors,
        'detailed_statements': categories
    }
    
    # Save comprehensive report
    with open('print_statements_analysis.json', 'w') as f:
        json.dump(report, f, indent=2)
    
    # Save visual replacement functions
    with open('VisualCommunicationSystem.gd', 'w') as f:
        f.write(generate_replacement_functions())
    
    print(f"\n📋 PRIORITY FILES FOR REPLACEMENT:")
    priority_files = {}
    for stmt in statements:
        file_path = stmt['file']
        if file_path not in priority_files:
            priority_files[file_path] = 0
        priority_files[file_path] += 1
    
    # Sort by number of print statements
    sorted_files = sorted(priority_files.items(), key=lambda x: x[1], reverse=True)
    
    for i, (file_path, count) in enumerate(sorted_files[:15]):
        print(f"{i+1:2d}. {file_path}: {count} print statements")
    
    print(f"\n✅ Analysis complete!")
    print(f"📄 Detailed report saved to: print_statements_analysis.json")
    print(f"🎨 Visual system code saved to: VisualCommunicationSystem.gd")

if __name__ == "__main__":
    main()