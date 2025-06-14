#!/usr/bin/env python3
"""
Batch fix remaining warnings in core scripts
"""

import re
import os

base_path = '/mnt/c/Users/Percision 15/talking_ragdoll_game/'

# Files and their specific fixes
files_fixes = {
    'scripts/core/background_process_manager.gd': [
        # Add debug output for processes_run variables
        (r'(# Track performance\s+var physics_time = \(Time\.get_ticks_usec\(\) - start_time\) / 1000\.0\s+if physics_time > 8\.0:  # Half of target frame time\s+performance_warning\.emit\("physics", physics_time\))',
         r'\1\n\t\t# Debug: track processes run\n\t\tif debug_enabled and processes_run > 0:\n\t\t\tprint("[BGProcess] Physics: ", processes_run, " processes in ", physics_time, "ms")'),
        
        (r'(if frame_time > PERFORMANCE_WARNING_THRESHOLD:\s+performance_warning\.emit\("frame", frame_time\))',
         r'\1\n\t\t# Debug: track visual processes run\n\t\tif debug_enabled and processes_run > 0:\n\t\t\tprint("[BGProcess] Visual: ", processes_run, " processes in ", frame_time, "ms")')
    ],
    
    'scripts/core/console_channel_system.gd': [
        (r'func _display_message\(channel: String, formatted_text: String\) -> void:', 
         r'func _display_message(channel: String, _formatted_text: String) -> void:')
    ],
    
    'scripts/core/debug_3d_screen.gd': [
        (r'func _create_axis_indicator\(origin: Vector3, direction: Vector3, color: Color, label: String\) -> void:', 
         r'func _create_axis_indicator(origin: Vector3, direction: Vector3, color: Color, _label: String) -> void:'),
        (r'func _process\(delta: float\) -> void:', 
         r'func _process(_delta: float) -> void:'),
        (r'func _draw_char\(position: Vector3, character: String, size: float = 1\.0\) -> void:', 
         r'func _draw_char(position: Vector3, _character: String, size: float = 1.0) -> void:'),
        # Fix shadowed name variables
        (r'(\s+)(for name in [^:]+:)', r'\1for debug_name in \2'.replace('name', 'debug_name')),
        (r'func ([^(]+)\(([^,]*), name: String([^)]*)\) -> ([^:]+):', r'func \1(\2, debug_name: String\3) -> \4:'),
    ]
}

print("🔧 Fixing remaining warnings in core scripts...")

for file_path, fixes in files_fixes.items():
    full_path = os.path.join(base_path, file_path)
    
    if not os.path.exists(full_path):
        print(f"⚠️ Skipping {file_path} - file not found")
        continue
        
    try:
        with open(full_path, 'r') as f:
            content = f.read()
        
        original_content = content
        
        # Apply fixes
        for pattern, replacement in fixes:
            content = re.sub(pattern, replacement, content, flags=re.MULTILINE | re.DOTALL)
        
        # Only write if changes were made
        if content != original_content:
            with open(full_path, 'w') as f:
                f.write(content)
            print(f"✅ Fixed warnings in {file_path}")
        else:
            print(f"📝 No changes needed in {file_path}")
            
    except Exception as e:
        print(f"❌ Error fixing {file_path}: {e}")

print("\n🎉 Batch fix completed!")