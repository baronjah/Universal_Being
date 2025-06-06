#!/usr/bin/env python3
"""
UNIVERSAL BEING EMERGENCY REPAIR TOOL
====================================
Fixes all critical errors preventing game launch.
"""
import os
import re
from pathlib import Path

class EmergencyRepair:
    def __init__(self):
        self.project_root = Path.cwd()
        self.fixes_applied = []
        
    def fix_systembootstrap(self):
        """Fix the critical SystemBootstrap errors"""
        print("🔧 Fixing SystemBootstrap.gd...")
        bootstrap_path = self.project_root / "autoloads" / "SystemBootstrap.gd"
        
        with open(bootstrap_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Fix all the broken references
        fixes = [
            # Variable declarations
            (r'var AkashicRecordsSystemSystemClass = null', 
             'var AkashicRecordsSystemClass = null'),
            # Class configs
            (r'"AkashicRecordsSystemSystem":\s*{', 
             '"AkashicRecordsSystem": {'),
            # Path references
            (r'AkashicRecordsSystemSystem\.gd', 
             'AkashicRecordsSystem.gd'),
            # All identifier references
            (r'AkashicRecordsSystemSystemClass', 
             'AkashicRecordsSystemClass'),
            # Case statements
            (r'"AkashicRecordsSystemSystem":', 
             '"AkashicRecordsSystem":'),
        ]
        
        for old, new in fixes:
            content = re.sub(old, new, content)
        
        with open(bootstrap_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        self.fixes_applied.append("SystemBootstrap.gd - Fixed AkashicRecordsSystem references")
    
    def fix_class_name_conflicts(self):
        """Remove duplicate class_name declarations"""
        print("🔧 Fixing class name conflicts...")
        
        # Scripts that are duplicated and should have class_name removed
        duplicate_scripts = [
            "scripts/",  # Everything in scripts folder
            "scripts_backup/",  # Everything in backup
        ]
        
        for folder in duplicate_scripts:
            folder_path = self.project_root / folder
            if not folder_path.exists():
                continue
                
            for gd_file in folder_path.rglob("*.gd"):
                with open(gd_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Comment out class_name to avoid conflicts
                if 'class_name ' in content and folder == "scripts_backup/":
                    content = re.sub(r'^class_name\s+(\w+)', r'#class_name \1', content, flags=re.MULTILINE)
                    with open(gd_file, 'w', encoding='utf-8') as f:
                        f.write(content)
                    self.fixes_applied.append(f"Commented class_name in {gd_file.name}")
    
    def fix_missing_preloads(self):
        """Fix all broken preload paths"""
        print("🔧 Fixing broken preload paths...")
        
        preload_fixes = {
            # Component paths
            'res://components/camera_effects/camera_effects_component.gd': 'res://scripts/camera_effects_component.gd',
            'res://components/button_basic/button_basic.gd': 'res://scripts/button_basic.gd',
            'res://components/simple_camera_effects.gd': 'res://scripts/archive/simple_camera_effects.gd',
            # Being paths
            'res://beings/button_universal_being.gd': 'res://scripts/button_universal_being.gd',
            'res://beings/terminal_universal_being.gd': 'res://scripts/terminal_universal_being.gd',
            'res://beings/console_universal_being.gd': 'res://scripts/console_universal_being.gd',
            'res://beings/socket_grid_universal_being.gd': 'res://scripts/socket_grid_universal_being.gd',
            'res://beings/socket_cell_universal_being.gd': 'res://scripts/socket_cell_universal_being.gd',
            'res://beings/universe_console_integration.gd': 'res://scripts/universe_console_integration.gd',
            'res://beings/GemmaUniversalBeing.gd': 'res://scripts/GemmaUniversalBeing.gd',
            # System paths
            'res://systems/GemmaUniverseInjector.gd': 'res://scripts/GemmaUniverseInjector.gd',
            'res://systems/chunks/luminus_chunk_grid_manager.gd': 'res://scripts/luminus_chunk_grid_manager.gd',
            'res://systems/storage/AkashicRecordsSystemSystem.gd': 'res://systems/storage/AkashicRecordsSystem.gd',
            # Asset paths (create dummies)
            'res://assets/icons/consciousness/level_0.png': 'res://icon.svg',
            'res://assets/icons/consciousness/level_1.png': 'res://icon.svg',
            'res://assets/icons/consciousness/level_2.png': 'res://icon.svg',
            'res://assets/icons/consciousness/level_3.png': 'res://icon.svg',
            'res://assets/icons/consciousness/level_4.png': 'res://icon.svg',
            'res://assets/icons/consciousness/level_5.png': 'res://icon.svg',
            'res://assets/icons/consciousness/level_6.png': 'res://icon.svg',
            'res://assets/icons/consciousness/level_7.png': 'res://icon.svg',
        }
        
        # Fix all GDScript files
        for gd_file in self.project_root.rglob("*.gd"):
            try:
                with open(gd_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                modified = False
                for old_path, new_path in preload_fixes.items():
                    if old_path in content:
                        content = content.replace(old_path, new_path)
                        modified = True
                
                if modified:
                    with open(gd_file, 'w', encoding='utf-8') as f:
                        f.write(content)
                    self.fixes_applied.append(f"Fixed preloads in {gd_file.name}")
            except:
                pass
    
    def fix_extends_statements(self):
        """Fix broken extends statements"""
        print("🔧 Fixing extends statements...")
        
        # Components should extend Component, not UniversalBeing
        component_files = [
            "components/ActionComponent.gd",
            "components/MemoryComponent.gd",
            "components/PerceptionComponent.gd",
            "components/MovementComponent.gd",
            "components/InteractionComponent.gd",
        ]
        
        for comp_file in component_files:
            file_path = self.project_root / comp_file
            if file_path.exists():
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                if 'extends UniversalBeing' in content:
                    content = content.replace('extends UniversalBeing', 'extends Component')
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    self.fixes_applied.append(f"Fixed extends in {comp_file}")
    
    def fix_test_files(self):
        """Fix test file syntax errors"""
        print("🔧 Fixing test files...")
        
        test_file = self.project_root / "test_akashic_system.gd"
        if test_file.exists():
            with open(test_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Make it extend Node so it has has_node() and get_node()
            content = content.replace('extends RefCounted', 'extends Node')
            
            with open(test_file, 'w', encoding='utf-8') as f:
                f.write(content)
            self.fixes_applied.append("Fixed test_akashic_system.gd")
    
    def create_missing_component_base(self):
        """Create Component base class if missing"""
        print("🔧 Creating Component base class...")
        
        component_path = self.project_root / "core" / "Component.gd"
        if not component_path.exists():
            component_content = '''extends Node
class_name Component

# Base class for all Universal Being components
var parent_being: Node = null
var component_type: String = "base"
var is_active: bool = true

func _ready():
    if get_parent() and get_parent().has_method("register_component"):
        parent_being = get_parent()
        parent_being.register_component(self)

func activate():
    is_active = true
    
func deactivate():
    is_active = false
'''
            with open(component_path, 'w', encoding='utf-8') as f:
                f.write(component_content)
            self.fixes_applied.append("Created Component.gd base class")
    
    def run_emergency_repair(self):
        """Run all emergency repairs"""
        print("🚨 UNIVERSAL BEING EMERGENCY REPAIR STARTING...")
        print("=" * 60)
        
        self.fix_systembootstrap()
        self.fix_class_name_conflicts()
        self.fix_missing_preloads()
        self.fix_extends_statements()
        self.fix_test_files()
        self.create_missing_component_base()
        
        print("\n✅ EMERGENCY REPAIRS COMPLETE!")
        print(f"📊 Total fixes applied: {len(self.fixes_applied)}")
        print("\n📋 Fixes applied:")
        for fix in self.fixes_applied[:10]:  # Show first 10
            print(f"  - {fix}")
        if len(self.fixes_applied) > 10:
            print(f"  ... and {len(self.fixes_applied) - 10} more")
        
        print("\n🎮 NEXT STEPS:")
        print("1. Close Godot")
        print("2. Delete .godot folder")
        print("3. Reopen Godot")
        print("4. Let it reimport")
        print("5. Play the consciousness revolution!")

if __name__ == "__main__":
    repair = EmergencyRepair()
    repair.run_emergency_repair()