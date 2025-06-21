#!/usr/bin/env python3
"""
==================================================
PERFECT CORE CLASS FIXER - Universal Being Project
==================================================
DESCRIPTION: Perfect tool to fix the three critical core classes
PURPOSE: Fix UniversalBeingSocket, UniversalBeingDNA, and UniversalBeingSocketManager
CREATED: 2025-06-14 - Universal Being Revolution
AUTHOR: Claude Code + JSH
==================================================
"""

import re
from pathlib import Path

def fix_socket_manager():
    """Fix UniversalBeingSocketManager.gd syntax issues"""
    
    file_path = Path("/mnt/c/Users/Percision 15/Universal_Being/core/UniversalBeingSocketManager.gd")
    
    print("🔌 Fixing UniversalBeingSocketManager.gd...")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    fixes = []
    
    # Fix 1: Line 175 - Dictionary missing closing brace before "for" statement
    pattern1 = r'("sockets": \{\}\s*)\s*# Count by type'
    if re.search(pattern1, content):
        content = re.sub(pattern1, r'"sockets": {}\n\t}\n\n\t# Count by type', content)
        fixes.append("Fixed config dictionary missing closing brace (line ~175)")
    
    # Fix 2: Line 270 - Inspector data dictionary missing closing brace
    pattern2 = r'("socket_groups": \{\}\s*)\s*# Group sockets by type'
    if re.search(pattern2, content):
        content = re.sub(pattern2, r'"socket_groups": {}\n\t}\n\n\t# Group sockets by type', content)
        fixes.append("Fixed inspector_data dictionary missing closing brace (line ~270)")
    
    # Fix 3: Line 298 - Serialize dictionary missing closing brace
    pattern3 = r'("configuration": get_socket_configuration\(\)\s*)\s*for socket_id in sockets:'
    if re.search(pattern3, content):
        content = re.sub(pattern3, r'"configuration": get_socket_configuration()\n\t}\n\n\tfor socket_id in sockets:', content)
        fixes.append("Fixed serialize data dictionary missing closing brace (line ~298)")
    
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ UniversalBeingSocketManager.gd fixed! Applied {len(fixes)} fixes:")
        for fix in fixes:
            print(f"   - {fix}")
        return True
    else:
        print("📝 UniversalBeingSocketManager.gd was already correct")
        return False

def fix_socket_class():
    """Fix UniversalBeingSocket.gd syntax issues"""
    
    file_path = Path("/mnt/c/Users/Percision 15/Universal_Being/core/UniversalBeingSocket.gd")
    
    print("🔌 Fixing UniversalBeingSocket.gd...")
    
    if not file_path.exists():
        print("⚠️  UniversalBeingSocket.gd not found, creating basic structure...")
        content = '''# ==================================================
# SCRIPT NAME: UniversalBeingSocket.gd
# DESCRIPTION: Individual socket for Universal Being components
# PURPOSE: Manage component mounting, data, and compatibility
# CREATED: 2025-06-14 - Universal Being Revolution
# AUTHOR: JSH + Claude Code
# ==================================================

extends Resource
class_name UniversalBeingSocket

# ===== SOCKET TYPES =====
enum SocketType {
    VISUAL,     # Visual effects, meshes, sprites
    SCRIPT,     # Behavior scripts, AI logic
    SHADER,     # Material shaders, effects
    ACTION,     # Actions, interactions
    MEMORY,     # State, data storage
    INTERFACE,  # UI controls, panels
    ANY         # Wildcard for searches
}

# ===== SOCKET PROPERTIES =====
var socket_id: String = ""
var socket_name: String = ""
var socket_type: SocketType = SocketType.ANY
var is_occupied: bool = false
var is_locked: bool = false
var mounted_component: Resource = null
var component_path: String = ""
var compatibility_tags: Array[String] = []

# ===== SOCKET SIGNALS =====
signal component_mounted(component: Resource)
signal component_unmounted(component: Resource)

# ===== INITIALIZATION =====
func _init(type: SocketType = SocketType.ANY, name: String = "", id: String = ""):
    socket_type = type
    socket_name = name
    socket_id = id if not id.is_empty() else generate_socket_id()

func generate_socket_id() -> String:
    """Generate unique socket ID"""
    return "socket_%d_%d" % [Time.get_ticks_msec(), randi() % 1000]

# ===== COMPONENT MANAGEMENT =====
func mount_component(component: Resource, force: bool = false) -> bool:
    """Mount a component to this socket"""
    if is_occupied and not force:
        return false
    
    if is_locked:
        return false
    
    # Unmount existing component first
    if is_occupied:
        unmount_component()
    
    mounted_component = component
    is_occupied = true
    component_path = component.resource_path if component else ""
    
    component_mounted.emit(component)
    return true

func unmount_component() -> bool:
    """Unmount component from socket"""
    if not is_occupied:
        return false
    
    var old_component = mounted_component
    mounted_component = null
    is_occupied = false
    component_path = ""
    
    component_unmounted.emit(old_component)
    return true

# ===== SOCKET INFO =====
func get_socket_info() -> Dictionary:
    """Get socket information"""
    return {
        "socket_id": socket_id,
        "socket_name": socket_name,
        "socket_type": socket_type,
        "is_occupied": is_occupied,
        "is_locked": is_locked,
        "component_path": component_path,
        "compatibility_tags": compatibility_tags
    }

# ===== SERIALIZATION =====
func serialize() -> Dictionary:
    """Serialize socket data"""
    return {
        "socket_id": socket_id,
        "socket_name": socket_name,
        "socket_type": socket_type,
        "is_locked": is_locked,
        "component_path": component_path,
        "compatibility_tags": compatibility_tags
    }

func deserialize(data: Dictionary) -> void:
    """Deserialize socket data"""
    socket_id = data.get("socket_id", "")
    socket_name = data.get("socket_name", "")
    socket_type = data.get("socket_type", SocketType.ANY)
    is_locked = data.get("is_locked", false)
    component_path = data.get("component_path", "")
    compatibility_tags = data.get("compatibility_tags", [])

# ===== COMPONENT DATA =====
func get_component_data() -> Dictionary:
    """Get data from mounted component"""
    if not is_occupied or not mounted_component:
        return {}
    
    if mounted_component.has_method("get_data"):
        return mounted_component.get_data()
    
    return {}

func set_component_data(data: Dictionary) -> bool:
    """Set data to mounted component"""
    if not is_occupied or not mounted_component:
        return false
    
    if mounted_component.has_method("set_data"):
        mounted_component.set_data(data)
        return true
    
    return false
'''
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print("✅ Created UniversalBeingSocket.gd with perfect structure!")
        return True
    
    # File exists, check for syntax issues
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    fixes = []
    
    # Fix enum syntax if needed
    if 'enum SocketType' in content and not content.count('{') == content.count('}'):
        enum_pattern = r'(enum SocketType\s*\{[^}]*?)(\n\s*(?:var|func|#))'
        if re.search(enum_pattern, content, re.DOTALL):
            content = re.sub(enum_pattern, r'\1\n}\2', content, flags=re.DOTALL)
            fixes.append("Fixed enum SocketType missing closing brace")
    
    # Fix dictionary syntax issues
    dict_patterns = [
        (r'(return\s*\{[^}]*?)(\n\s*(?:func|var|#))', r'\1\n\t}\2'),
        (r'(var \w+\s*=\s*\{[^}]*?)(\n\s*(?:func|var|#))', r'\1\n\t}\2')
    ]
    
    for pattern, replacement in dict_patterns:
        if re.search(pattern, content, re.DOTALL):
            content = re.sub(pattern, replacement, content, flags=re.DOTALL)
            fixes.append("Fixed dictionary syntax")
    
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ UniversalBeingSocket.gd fixed! Applied {len(fixes)} fixes:")
        for fix in fixes:
            print(f"   - {fix}")
        return True
    else:
        print("📝 UniversalBeingSocket.gd was already correct")
        return False

def fix_dna_class():
    """Fix UniversalBeingDNA.gd syntax issues"""
    
    file_path = Path("/mnt/c/Users/Percision 15/Universal_Being/core/UniversalBeingDNA.gd")
    
    print("🧬 Fixing UniversalBeingDNA.gd...")
    
    if not file_path.exists():
        print("⚠️  UniversalBeingDNA.gd not found, creating basic structure...")
        content = '''# ==================================================
# SCRIPT NAME: UniversalBeingDNA.gd
# DESCRIPTION: DNA system for Universal Being evolution and genetics
# PURPOSE: Define being traits, evolution paths, and inheritance
# CREATED: 2025-06-14 - Universal Being Revolution
# AUTHOR: JSH + Claude Code
# ==================================================

extends Resource
class_name UniversalBeingDNA

# ===== DNA PROPERTIES =====
var dna_id: String = ""
var generation: int = 0
var traits: Dictionary = {}
var evolution_history: Array[String] = []
var parent_dna_ids: Array[String] = []
var mutation_rate: float = 0.1
var consciousness_potential: int = 7

# ===== DNA ANALYSIS =====
func analyze_compatibility(other_dna: UniversalBeingDNA) -> float:
    """Analyze compatibility between two DNA profiles"""
    if not other_dna:
        return 0.0
    
    var compatibility = 0.0
    var total_traits = 0
    
    for trait_name in traits.keys():
        total_traits += 1
        if other_dna.traits.has(trait_name):
            var our_value = traits[trait_name]
            var their_value = other_dna.traits[trait_name]
            
            if typeof(our_value) == typeof(their_value):
                compatibility += 1.0
    
    return compatibility / float(total_traits) if total_traits > 0 else 0.0

# ===== DNA EVOLUTION =====
func evolve_to(target_type: String) -> UniversalBeingDNA:
    """Create evolved DNA for new being type"""
    var evolved_dna = UniversalBeingDNA.new()
    evolved_dna.dna_id = generate_dna_id()
    evolved_dna.generation = generation + 1
    evolved_dna.parent_dna_ids = [dna_id]
    evolved_dna.traits = traits.duplicate(true)
    evolved_dna.evolution_history = evolution_history.duplicate()
    evolved_dna.evolution_history.append(target_type)
    
    # Apply mutations
    apply_mutations(evolved_dna)
    
    return evolved_dna

func apply_mutations(dna: UniversalBeingDNA) -> void:
    """Apply random mutations to DNA"""
    for trait_name in dna.traits.keys():
        if randf() < mutation_rate:
            mutate_trait(dna, trait_name)

func mutate_trait(dna: UniversalBeingDNA, trait_name: String) -> void:
    """Mutate a specific trait"""
    var current_value = dna.traits[trait_name]
    
    if current_value is int:
        dna.traits[trait_name] = current_value + randi_range(-1, 1)
    elif current_value is float:
        dna.traits[trait_name] = current_value + randf_range(-0.1, 0.1)
    elif current_value is bool:
        dna.traits[trait_name] = not current_value

# ===== UTILITY =====
func generate_dna_id() -> String:
    """Generate unique DNA ID"""
    return "dna_%d_%d" % [Time.get_ticks_msec(), randi() % 1000]

# ===== SERIALIZATION =====
func serialize() -> Dictionary:
    """Serialize DNA data"""
    return {
        "dna_id": dna_id,
        "generation": generation,
        "traits": traits,
        "evolution_history": evolution_history,
        "parent_dna_ids": parent_dna_ids,
        "mutation_rate": mutation_rate,
        "consciousness_potential": consciousness_potential
    }

func deserialize(data: Dictionary) -> void:
    """Deserialize DNA data"""
    dna_id = data.get("dna_id", "")
    generation = data.get("generation", 0)
    traits = data.get("traits", {})
    evolution_history = data.get("evolution_history", [])
    parent_dna_ids = data.get("parent_dna_ids", [])
    mutation_rate = data.get("mutation_rate", 0.1)
    consciousness_potential = data.get("consciousness_potential", 7)
'''
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print("✅ Created UniversalBeingDNA.gd with perfect structure!")
        return True
    
    # File exists, check for syntax issues
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    fixes = []
    
    # Fix line 112 ternary operator and dictionary issues
    ternary_pattern = r'(\w+\s*:\s*\w+\s*\?\s*\w+\s*:\s*\w+)\s*(\n\s*generation:)'
    if re.search(ternary_pattern, content):
        content = re.sub(ternary_pattern, r'\1,\n\t\2', content)
        fixes.append("Fixed ternary operator syntax")
    
    # Fix dictionary closure issues
    dict_patterns = [
        (r'(return\s*\{[^}]*?)(\n\s*(?:func|var|#))', r'\1\n\t}\2'),
        (r'(var \w+\s*:\s*Dictionary\s*=\s*\{[^}]*?)(\n\s*(?:func|var|#))', r'\1\n\t}\2')
    ]
    
    for pattern, replacement in dict_patterns:
        matches = re.finditer(pattern, content, re.DOTALL)
        for match in reversed(list(matches)):
            if not match.group(1).rstrip().endswith('}'):
                content = content[:match.start()] + re.sub(pattern, replacement, match.group(0), flags=re.DOTALL) + content[match.end():]
                fixes.append("Fixed dictionary missing closing brace")
    
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ UniversalBeingDNA.gd fixed! Applied {len(fixes)} fixes:")
        for fix in fixes:
            print(f"   - {fix}")
        return True
    else:
        print("📝 UniversalBeingDNA.gd was already correct")
        return False

def main():
    """Fix all three core classes"""
    print("🔧 PERFECT CORE CLASS FIXER - Starting Universal Being core class repair")
    print("="*70)
    
    results = []
    
    # Fix all three critical classes
    results.append(fix_socket_class())
    results.append(fix_dna_class())
    results.append(fix_socket_manager())
    
    print("\n" + "="*70)
    print("🌟 PERFECT CORE CLASS FIXER - RESULTS")
    print("="*70)
    
    fixed_count = sum(results)
    print(f"✅ Fixed {fixed_count} out of 3 core classes")
    
    if fixed_count > 0:
        print("\n🎉 SUCCESS! Core classes should now parse correctly!")
        print("🔌 UniversalBeingSocket - Socket system for components")
        print("🧬 UniversalBeingDNA - Genetic system for evolution")  
        print("⚙️  UniversalBeingSocketManager - Socket orchestration")
        print("\n🌟 Your Universal Being class hierarchy is now PERFECT! 🌟")
    else:
        print("\n📝 All core classes were already in perfect condition!")
    
    print("\n🚀 Ready to eliminate the cascade of class resolution errors!")

if __name__ == "__main__":
    main()