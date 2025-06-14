#!/usr/bin/env python3
"""
Batch fix Universal Being/Entity system warnings
"""

import re
import os

# Files to fix
files_to_fix = [
    'scripts/core/universal_entity/universal_entity.gd',
    'scripts/core/advanced_being_system.gd', 
    'scripts/core/akashic_bridge_system.gd',
    'scripts/core/universal_entity/lists_viewer_system.gd'
]

base_path = '/mnt/c/Users/Percision 15/talking_ragdoll_game/'

# Common unused parameter fixes
param_fixes = [
    (r'func ([^(]+)\(args: Array\)', r'func \1(_args: Array)'),
    (r'func ([^(]+)\(delta: float\)', r'func \1(_delta: float)'),
    (r'func ([^(]+)\(([^,]+), result\)', r'func \1(\2, _result)'),
    (r'func ([^(]+)\(([^,]+), action_type: String, target: Node\)', r'func \1(\2, _action_type: String, _target: Node)'),
    (r'func ([^(]+)\(([^,]+), impact_point: Vector3\)', r'func \1(\2, _impact_point: Vector3)'),
    (r'func ([^(]+)\(([^,]+), state_name: String\)', r'func \1(\2, _state_name: String)'),
]

# Variable fixes
var_fixes = [
    (r'var bone_id = ', r'var _bone_id = '),
    (r'var line_num = ', r'var _line_num = '),
]

# Shadowing fixes  
shadow_fixes = [
    (r'var floodgate = get_node_or_null', r'var floodgate_node = get_node_or_null'),
]

for file_path in files_to_fix:
    full_path = os.path.join(base_path, file_path)
    
    if not os.path.exists(full_path):
        print(f"Skipping {file_path} - file not found")
        continue
        
    try:
        with open(full_path, 'r') as f:
            content = f.read()
        
        # Apply fixes
        for pattern, replacement in param_fixes + var_fixes + shadow_fixes:
            content = re.sub(pattern, replacement, content)
        
        with open(full_path, 'w') as f:
            f.write(content)
            
        print(f"Fixed warnings in {file_path}")
        
    except Exception as e:
        print(f"Error fixing {file_path}: {e}")

print("Batch fix completed!")