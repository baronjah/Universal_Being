#!/usr/bin/env python3
import zipfile
import os

# Create test ZIP file with TXT and GDScript
zip_path = "zip_worlds/test_world.zip"
os.makedirs("zip_worlds", exist_ok=True)

with zipfile.ZipFile(zip_path, 'w') as zipf:
    zipf.write("txt_realities/simple_world.txt", "simple_world.txt")
    zipf.write("gdscript_hotload/dynamic_cube.gd", "dynamic_cube.gd")
    
    # Add a configuration file
    config_content = """{
    "zip_settings": {
        "watch_interval": 0.5,
        "auto_reload": true
    },
    "consciousness_settings": {
        "consciousness_multiplier": 3.5,
        "enable_glow": true
    }
}"""
    zipf.writestr("config.json", config_content)

print(f"✅ Created test ZIP: {zip_path}")
print("📋 Contents:")
with zipfile.ZipFile(zip_path, 'r') as zipf:
    for info in zipf.infolist():
        print(f"  - {info.filename} ({info.file_size} bytes)")