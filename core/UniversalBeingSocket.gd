# ==================================================
# SCRIPT NAME: UniversalBeingSocket.gd
# DESCRIPTION: Core socket system for modular Universal Being architecture
# PURPOSE: Enable hot-swappable visual, script, shader, action, and memory components
# CREATED: 2025-06-02 - Socket Architecture Revolution
# AUTHOR: JSH + Claude Code - Universal Being Socket Architects
# ==================================================

extends UniversalBeing
class_name UniversalBeingSocket

# ===== SOCKET TYPES =====
enum SocketType {
	ANY = -1,   # Special value for searching all types
	VISUAL,     # Visual appearance, models, textures, particles
	SCRIPT,     # Behavior scripts, logic components  
	SHADER,     # Material shaders, visual effects
	ACTION,     # Action sequences, animations, behaviors
	MEMORY,     # Data storage, state management
	INTERFACE,  # UI elements, controls, panels
	AUDIO,      # Sound effects, music, audio processing
	PHYSICS     # Collision, forces, physics properties
}

# ===== SOCKET PROPERTIES =====
@export var socket_type: SocketType = SocketType.VISUAL
@export var socket_name: String = ""
@export var socket_id: String = ""
@export var is_occupied: bool = false
@export var is_locked: bool = false
@export var compatibility_tags: Array[String] = []

# ===== SOCKET CONTENT =====
var mounted_component: Resource = null
var component_path: String = ""
var component_data: Dictionary = {}
var socket_metadata: Dictionary = {}

# ===== SOCKET SIGNALS =====
signal component_mounted(component: Resource)
signal component_unmounted(component: Resource)
signal socket_locked()
signal socket_unlocked()
signal compatibility_changed()

# ===== SOCKET INITIALIZATION =====

func _init(type: SocketType = SocketType.VISUAL, name: String = "", id: String = ""):
	socket_type = type
	socket_name = name if not name.is_empty() else SocketType.keys()[type].to_lower()
	socket_id = id if not id.is_empty() else _generate_socket_id()
	
	# Set default compatibility based on type
	_set_default_compatibility()

func _generate_socket_id() -> String:
	return "socket_%s_%d" % [SocketType.keys()[socket_type].to_lower(), randi()]

func _set_default_compatibility() -> void:
	"""Set default compatibility tags based on socket type"""
	match socket_type:
		SocketType.VISUAL:
			compatibility_tags = ["mesh", "texture", "material", "particle", "sprite"]
		SocketType.SCRIPT:
			compatibility_tags = ["gdscript", "behavior", "logic", "ai"]
		SocketType.SHADER:
			compatibility_tags = ["vertex", "fragment", "compute", "material"]
		SocketType.ACTION:
			compatibility_tags = ["animation", "sequence", "trigger", "movement"]
		SocketType.MEMORY:
			compatibility_tags = ["data", "state", "cache", "storage"]
		SocketType.INTERFACE:
			compatibility_tags = ["ui", "control", "widget", "panel"]
		SocketType.AUDIO:
			compatibility_tags = ["sound", "music", "stream", "effect"]
		SocketType.PHYSICS:
			compatibility_tags = ["collision", "rigidbody", "force", "physics"]

# ===== COMPONENT MOUNTING =====

func mount_component(component: Resource, force: bool = false) -> bool:
	"""Mount a component into this socket"""
	if is_locked and not force:
		push_error("Socket %s is locked" % socket_id)
		return false
	
	if is_occupied and not force:
		push_error("Socket %s is already occupied" % socket_id)
		return false
	
	# Check compatibility
	if not _check_compatibility(component):
		push_error("Component incompatible with socket %s" % socket_id)
		return false
	
	# Unmount existing component if any
	if is_occupied:
		unmount_component()
	
	# Mount new component
	mounted_component = component
	is_occupied = true
	component_path = component.resource_path if component.resource_path else ""
	
	# Extract component metadata
	if component.has_method("get_socket_metadata"):
		component_data = component.get_socket_metadata()
	
	component_mounted.emit(component)
	print("🔌 Component mounted to %s socket: %s" % [socket_name, component_path])
	return true

func unmount_component() -> bool:
	"""Unmount the current component"""
	if not is_occupied:
		return false
	
	var old_component = mounted_component
	
	# Cleanup
	mounted_component = null
	is_occupied = false
	component_path = ""
	component_data.clear()
	
	component_unmounted.emit(old_component)
	print("🔌 Component unmounted from %s socket" % socket_name)
	return true

func _check_compatibility(component: Resource) -> bool:
	"""Check if component is compatible with this socket"""
	if not component:
		return false
	
	# Check if component has compatibility tags
	if component.has_method("get_compatibility_tags"):
		var comp_tags = component.get_compatibility_tags()
		for tag in comp_tags:
			if tag in compatibility_tags:
				return true
		return false
	
	# Fallback: check by resource type
	var type_name = component.get_class().to_lower()
	for tag in compatibility_tags:
		if type_name.contains(tag):
			return true
	
	return false

# ===== SOCKET MANAGEMENT =====

func lock_socket(reason: String = "") -> void:
	"""Lock socket to prevent component changes"""
	is_locked = true
	socket_metadata.lock_reason = reason
	socket_locked.emit()

func unlock_socket() -> void:
	"""Unlock socket to allow component changes"""
	is_locked = false
	socket_metadata.erase("lock_reason")
	socket_unlocked.emit()

func add_compatibility_tag(tag: String) -> void:
	"""Add a compatibility tag"""
	if not tag in compatibility_tags:
		compatibility_tags.append(tag)
		compatibility_changed.emit()

func remove_compatibility_tag(tag: String) -> void:
	"""Remove a compatibility tag"""
	if tag in compatibility_tags:
		compatibility_tags.erase(tag)
		compatibility_changed.emit()

# ===== SOCKET INTROSPECTION =====

func get_socket_info() -> Dictionary:
	"""Get comprehensive socket information"""
	return {
		"socket_id": socket_id,
		"socket_name": socket_name,
		"socket_type": SocketType.keys()[socket_type],
		"is_occupied": is_occupied,
		"is_locked": is_locked,
		"compatibility_tags": compatibility_tags,
		"component_path": component_path,
		"component_data": component_data,
		"socket_metadata": socket_metadata
	}

func get_component_data() -> Dictionary:
	"""Get data from mounted component"""
	return component_data.duplicate()

func set_component_data(data: Dictionary) -> void:
	"""Set data for mounted component"""
	component_data = data.duplicate()
	
	# If component supports setting data, call it
	if mounted_component and mounted_component.has_method("set_socket_data"):
		mounted_component.set_socket_data(data)

# ===== SOCKET SERIALIZATION =====

func serialize() -> Dictionary:
	"""Serialize socket state for saving"""
	return {
		"socket_type": socket_type,
		"socket_name": socket_name,
		"socket_id": socket_id,
		"is_locked": is_locked,
		"compatibility_tags": compatibility_tags,
		"component_path": component_path,
		"component_data": component_data,
		"socket_metadata": socket_metadata
	}

func deserialize(data: Dictionary) -> void:
	"""Deserialize socket state from saved data"""
	socket_type = data.get("socket_type", SocketType.VISUAL)
	socket_name = data.get("socket_name", "")
	socket_id = data.get("socket_id", "")
	is_locked = data.get("is_locked", false)
	compatibility_tags = data.get("compatibility_tags", [])
	component_path = data.get("component_path", "")
	component_data = data.get("component_data", {})
	socket_metadata = data.get("socket_metadata", {})
	
	# Try to reload component if path exists
	if not component_path.is_empty() and FileAccess.file_exists(component_path):
		var component = load(component_path)
		if component:
			mount_component(component, true)

# ===== DEBUG AND UTILITIES =====

func _to_string() -> String:
	var status = "occupied" if is_occupied else "empty"
	var lock_status = " (locked)" if is_locked else ""
	return "Socket<%s:%s:%s%s>" % [SocketType.keys()[socket_type], socket_name, status, lock_status]
