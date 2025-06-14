#!/usr/bin/env python3
"""
Script to fix unused parameter warnings in console_manager.gd
Replaces 'args: Array' with '_args: Array' for unused parameters
"""

import re

# Read the console_manager.gd file
with open('/mnt/c/Users/Percision 15/talking_ragdoll_game/scripts/autoload/console_manager.gd', 'r') as f:
    content = f.read()

# List of function names that need args parameter fixed (from the warnings)
functions_to_fix = [
    '_cmd_help', '_cmd_test_tutorial', '_cmd_create_tree', '_cmd_create_rock',
    '_cmd_create_box', '_cmd_create_ball', '_cmd_create_ramp', '_cmd_create_wall',
    '_cmd_create_stick', '_cmd_create_leaf', '_cmd_list_assets', '_cmd_list_objects',
    '_cmd_ragdoll_walk', '_cmd_spawn_ragdoll', '_cmd_spawn_skeleton_ragdoll',
    '_cmd_create_sun', '_cmd_create_pathway', '_cmd_create_bush', '_cmd_create_fruit',
    '_cmd_create_pigeon', '_cmd_scene_status', '_cmd_restore_ground',
    '_cmd_test_being_assets', '_cmd_timing_info', '_cmd_balance_workload',
    '_cmd_floodgate_status', '_cmd_health_check', '_cmd_test_floodgate',
    '_cmd_system_status', '_cmd_ragdoll_come_here', '_cmd_ragdoll_pickup_nearest',
    '_cmd_ragdoll_drop', '_cmd_ragdoll_organize', '_cmd_ragdoll_patrol',
    '_cmd_beings_status', '_cmd_beings_help_ragdoll', '_cmd_beings_organize',
    '_cmd_beings_harmony', '_cmd_setup_systems', '_cmd_test_mouse_click',
    '_cmd_action_list', '_cmd_ragdoll_status', '_cmd_console_debug_toggle',
    '_cmd_performance_stats', '_cmd_debug_panel_status', '_cmd_object_limits',
    '_cmd_being_count', '_cmd_jsh_status', '_cmd_thread_status', '_cmd_scene_tree',
    '_cmd_ragdoll_run', '_cmd_ragdoll_crouch', '_cmd_ragdoll_jump', '_cmd_ragdoll_stand',
    '_cmd_ragdoll_state', '_cmd_tutorial_start', '_cmd_tutorial_stop',
    '_cmd_tutorial_status', '_cmd_tutorial_hide', '_cmd_tutorial_show',
    '_cmd_ragdoll2_state', '_cmd_ragdoll2_debug', '_cmd_interactive_tutorial',
    '_cmd_txt_rules', '_cmd_list_scene_objects', '_cmd_open_asset_creator',
    '_cmd_test_cube', '_cmd_inspect_cube', '_cmd_viewport_info', '_cmd_camera_rays',
    '_cmd_neural_status', '_cmd_test_consciousness', '_cmd_zone_list', '_cmd_create_being'
]

# Fix unused args parameters
for func_name in functions_to_fix:
    pattern = rf'func {func_name}\(args: Array\) -> void:'
    replacement = rf'func {func_name}(_args: Array) -> void:'
    content = re.sub(pattern, replacement, content)

# Fix other specific unused parameters
fixes = [
    (r'func _on_asset_created\(asset_node: Node3D, properties: Dictionary\) -> void:', 
     r'func _on_asset_created(asset_node: Node3D, _properties: Dictionary) -> void:'),
    (r'func _on_cube_clicked\(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int\) -> void:',
     r'func _on_cube_clicked(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:'),
    (r'var scene_tree_sys = get_node_or_null\("/root/SceneTreeSystem"\)',
     r'var _scene_tree_sys = get_node_or_null("/root/SceneTreeSystem")'),
    (r'var ragdoll = _find_ragdoll\(\)',
     r'var _ragdoll = _find_ragdoll()'),
    (r'func _find_universal_being\(name: String\) -> UniversalBeing:',
     r'func _find_universal_being(being_name: String) -> UniversalBeing:'),
]

for pattern, replacement in fixes:
    content = re.sub(pattern, replacement, content)

# Write back the fixed content
with open('/mnt/c/Users/Percision 15/talking_ragdoll_game/scripts/autoload/console_manager.gd', 'w') as f:
    f.write(content)

print("Fixed unused parameter warnings in console_manager.gd")