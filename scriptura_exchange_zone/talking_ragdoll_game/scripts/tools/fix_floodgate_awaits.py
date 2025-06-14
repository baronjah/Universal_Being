#!/usr/bin/env python3
"""
Fix FloodgateController redundant await statements and other warnings
"""

import re

# Read the floodgate controller file
with open('/mnt/c/Users/Percision 15/talking_ragdoll_game/scripts/core/floodgate_controller.gd', 'r') as f:
    content = f.read()

# Remove redundant awaits from operation calls
operations_to_fix = [
    '_op_create_node', '_op_delete_node', '_op_move_node', '_op_rotate_node',
    '_op_scale_node', '_op_reparent_node', '_op_load_asset', '_op_unload_asset',
    '_op_play_sound', '_op_run_script', '_op_show_ui', '_op_hide_ui',
    '_op_set_property', '_op_modify_terrain', '_op_particle_effect', '_op_save_scene'
]

for op in operations_to_fix:
    # Remove await from these operation calls
    pattern = rf'success = await {op}\('
    replacement = f'success = {op}('
    content = re.sub(pattern, replacement, content)

# Fix other warnings
fixes = [
    # Unused parameters
    (r'func _process\(delta: float\) -> void:', r'func _process(_delta: float) -> void:'),
    (r'func _notify_beings_of_replacement\(([^,]+), removed_object: Node3D\) -> void:', 
     r'func _notify_beings_of_replacement(\1, _removed_object: Node3D) -> void:'),
    
    # Unused variables  
    (r'var last_delta_to_forget = ', r'var _last_delta_to_forget = '),
    (r'var unload_type = ', r'var _unload_type = '),
    (r'var node_id = ', r'var _node_id = '),
]

for pattern, replacement in fixes:
    content = re.sub(pattern, replacement, content)

# Write back the fixed content
with open('/mnt/c/Users/Percision 15/talking_ragdoll_game/scripts/core/floodgate_controller.gd', 'w') as f:
    f.write(content)

print("✅ Fixed FloodgateController redundant awaits and warnings!")
print("🌊 Floodgate system should now be clean and functional!")