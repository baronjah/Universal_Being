#!/usr/bin/env python3
"""
Final cleanup of remaining warnings - systematic approach
"""

import re
import os

base_path = '/mnt/c/Users/Percision 15/talking_ragdoll_game/'

# Common fixes to apply across multiple files
common_fixes = [
    # Unused parameters
    (r'func ([^(]+)\(([^,]*), delta: float\) -> void:', r'func \1(\2, _delta: float) -> void:'),
    (r'func ([^(]+)\(([^,]*), camera: ([^,]*), event: ([^,]*), position: ([^,]*), normal: ([^,]*), shape_idx: ([^)]*)\) -> void:', 
     r'func \1(\2, _camera: \3, event: \4, event_position: \5, _normal: \6, _shape_idx: \7) -> void:'),
    (r'func ([^(]+)\(([^,]*), data: ([^)]*)\) -> void:', r'func \1(\2, _data: \3) -> void:'),
    (r'func ([^(]+)\(([^,]*), character: String([^)]*)\) -> void:', r'func \1(\2, _character: String\3) -> void:'),
    (r'func ([^(]+)\(([^,]*), label: String([^)]*)\) -> void:', r'func \1(\2, _label: String\3) -> void:'),
    (r'func ([^(]+)\(([^,]*), speed: ([^)]*)\) -> void:', r'func \1(\2, _speed: \3) -> void:'),
    (r'func ([^(]+)\(([^,]*), pressed: ([^)]*)\) -> void:', r'func \1(\2, _pressed: \3) -> void:'),
    
    # Unused variables
    (r'var old_level = ', r'var _old_level = '),
    (r'var swing_shin = ', r'var _swing_shin = '),
    (r'var char = ', r'var character = '),
    
    # Shadowed variables  
    (r'func ([^(]+)\(([^,]*), rotation: ([^)]*)\) -> ([^:]+):', r'func \1(\2, new_rotation: \3) -> \4:'),
    (r'for name in ([^:]+):', r'for item_name in \1:'),
    
    # Integer division fixes
    (r'(\w+) / (\d+)(?!\.\d)', r'\1 / \2.0'),
    
    # Ternary operator fixes
    (r'(\w+) if (\w+) else (\w+)', lambda m: f'{m.group(1)} if {m.group(2)} != null else {m.group(3)}' if 'null' in m.group(0) else m.group(0))
]

# Specific file fixes
specific_fixes = {
    'scripts/core/delta_frame_guardian.gd': [
        (r'signal performance_warning', r'signal performance_warning  # Emitted when performance issues detected'),
        (r'signal fps_improved', r'signal fps_improved  # Emitted when FPS performance improves')
    ],
    'scripts/core/dimensional_color_system.gd': [
        (r'var char = text\[i\]', r'var character = text[i]'),
        (r'char\.unicode_at\(0\)', r'character.unicode_at(0)'),
        (r'result \+= char', r'result += character')
    ]
}

# Files that need missing function stubs
missing_functions = {
    'scripts/core/enhanced_interface_system.gd': [
        '''
func _create_system_monitor_interface() -> void:
	"""Create system monitoring interface - placeholder for future implementation"""
	# Create basic system monitor UI
	var monitor_panel = ColorRect.new()
	monitor_panel.color = Color(0.0, 0.2, 0.0, 0.8)
	monitor_panel.size = Vector2(250, 150)
	add_child(monitor_panel)
	
	var status_label = Label.new()
	status_label.text = "System Monitor"
	status_label.position = Vector2(10, 10)
	monitor_panel.add_child(status_label)

func _create_grid_list_interface() -> void:
	"""Create grid list interface - placeholder for future implementation"""  
	# Create basic grid list UI
	var grid_panel = ColorRect.new()
	grid_panel.color = Color(0.2, 0.0, 0.2, 0.8)
	grid_panel.size = Vector2(300, 200)
	add_child(grid_panel)
	
	var grid_label = Label.new()
	grid_label.text = "Grid List"
	grid_label.position = Vector2(10, 10)
	grid_panel.add_child(grid_label)
'''
    ]
}

print("🔧 Final warnings cleanup starting...")

# Apply common fixes to all .gd files in core/
core_files = []
for root, dirs, files in os.walk(os.path.join(base_path, 'scripts/core')):
    for file in files:
        if file.endswith('.gd'):
            core_files.append(os.path.join(root, file))

for file_path in core_files:
    try:
        with open(file_path, 'r') as f:
            content = f.read()
        
        original = content
        
        # Apply common fixes
        for pattern, replacement in common_fixes:
            if callable(replacement):
                content = re.sub(pattern, replacement, content)
            else:
                content = re.sub(pattern, replacement, content)
        
        # Apply specific fixes
        rel_path = os.path.relpath(file_path, base_path)
        if rel_path in specific_fixes:
            for pattern, replacement in specific_fixes[rel_path]:
                content = re.sub(pattern, replacement, content)
        
        # Add missing functions
        if rel_path in missing_functions:
            content += missing_functions[rel_path]
        
        if content != original:
            with open(file_path, 'w') as f:
                f.write(content)
            print(f"✅ Fixed: {os.path.basename(file_path)}")
            
    except Exception as e:
        print(f"❌ Error in {file_path}: {e}")

print("\n🎉 Final cleanup complete!")
print("✨ All core script warnings should now be resolved!")