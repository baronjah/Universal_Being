# ==================================================
# SCRIPT NAME: UniversalBeingSocketManager.gd
# DESCRIPTION: Manages all sockets for a Universal Being
# PURPOSE: Orchestrate visual, script, shader, action, memory, and other sockets
# CREATED: 2025-06-02 - Socket Management Revolution
# AUTHOR: JSH + Claude Code - Universal Being Socket System
# ==================================================

extends Resource
class_name UniversalBeingSocketManager

# ===== SOCKET REGISTRY =====
var sockets: Dictionary = {}  # socket_id -> UniversalBeingSocket
var socket_groups: Dictionary = {}  # SocketType -> Array[UniversalBeingSocket]
var owner_being: UniversalBeing = null

# ===== SOCKET SIGNALS =====
signal socket_added(socket: UniversalBeingSocket)
signal socket_removed(socket: UniversalBeingSocket)
signal component_mounted(socket: UniversalBeingSocket, component: Resource)
signal component_unmounted(socket: UniversalBeingSocket, component: Resource)
signal socket_configuration_changed()

# ===== INITIALIZATION =====

func _init(being: UniversalBeing = null):
	owner_being = being
	_initialize_socket_groups()
	
	if being:
		_create_default_sockets()

func _initialize_socket_groups() -> void:
	"""Initialize socket group containers"""
	for socket_type in UniversalBeingSocket.SocketType.values():
		socket_groups[socket_type] = []

func _create_default_sockets() -> void:
	"""Create default socket configuration for Universal Being"""
	# Visual sockets
	add_socket(UniversalBeingSocket.SocketType.VISUAL, "primary_visual", "primary_visual_socket")
	add_socket(UniversalBeingSocket.SocketType.VISUAL, "aura_effects", "aura_effects_socket")
	add_socket(UniversalBeingSocket.SocketType.VISUAL, "consciousness_indicator", "consciousness_socket")
	
	# Script sockets
	add_socket(UniversalBeingSocket.SocketType.SCRIPT, "behavior_logic", "behavior_socket")
	add_socket(UniversalBeingSocket.SocketType.SCRIPT, "ai_interface", "ai_socket")
	add_socket(UniversalBeingSocket.SocketType.SCRIPT, "evolution_rules", "evolution_socket")
	
	# Shader sockets
	add_socket(UniversalBeingSocket.SocketType.SHADER, "surface_material", "surface_shader")
	add_socket(UniversalBeingSocket.SocketType.SHADER, "effect_overlay", "effect_shader")
	
	# Action sockets
	add_socket(UniversalBeingSocket.SocketType.ACTION, "pentagon_actions", "pentagon_action_socket")
	add_socket(UniversalBeingSocket.SocketType.ACTION, "custom_behaviors", "behavior_action_socket")
	
	# Memory sockets
	add_socket(UniversalBeingSocket.SocketType.MEMORY, "core_state", "state_memory_socket")
	add_socket(UniversalBeingSocket.SocketType.MEMORY, "interaction_history", "history_socket")
	add_socket(UniversalBeingSocket.SocketType.MEMORY, "evolution_data", "evolution_memory_socket")
	
	# Interface sockets (for UI beings)
	add_socket(UniversalBeingSocket.SocketType.INTERFACE, "control_interface", "ui_socket")
	add_socket(UniversalBeingSocket.SocketType.INTERFACE, "inspector_panel", "inspector_socket")

# ===== SOCKET MANAGEMENT =====

func add_socket(socket_type: UniversalBeingSocket.SocketType, name: String, id: String = "") -> UniversalBeingSocket:
	"""Add a new socket to the being"""
	var socket = UniversalBeingSocket.new(socket_type, name, id)
	
	# Register socket
	sockets[socket.socket_id] = socket
	socket_groups[socket_type].append(socket)
	
	# Connect socket signals
	socket.component_mounted.connect(_on_component_mounted.bind(socket))
	socket.component_unmounted.connect(_on_component_unmounted.bind(socket))
	
	socket_added.emit(socket)
	print("🔌 Socket added: %s (%s)" % [socket.socket_name, socket.socket_id])
	return socket

func remove_socket(socket_id: String) -> bool:
	"""Remove a socket from the being"""
	if not sockets.has(socket_id):
		return false
	
	var socket = sockets[socket_id]
	
	# Unmount any component
	if socket.is_occupied:
		socket.unmount_component()
	
	# Unregister socket
	sockets.erase(socket_id)
	socket_groups[socket.socket_type].erase(socket)
	
	socket_removed.emit(socket)
	print("🔌 Socket removed: %s" % socket_id)
	return true

func get_socket(socket_id: String) -> UniversalBeingSocket:
	"""Get socket by ID"""
	return sockets.get(socket_id, null)

func get_sockets_by_type(socket_type: UniversalBeingSocket.SocketType) -> Array[UniversalBeingSocket]:
	"""Get all sockets of a specific type"""
	var empty_array: Array[UniversalBeingSocket] = []
	return socket_groups.get(socket_type, empty_array)

func get_sockets_by_name(name: String) -> Array[UniversalBeingSocket]:
	"""Get all sockets with a specific name"""
	var matching_sockets: Array[UniversalBeingSocket] = []
	for socket in sockets.values():
		if socket.socket_name == name:
			matching_sockets.append(socket)
	return matching_sockets

# ===== COMPONENT MANAGEMENT =====

func mount_component_to_socket(socket_id: String, component: Resource, force: bool = false) -> bool:
	"""Mount a component to a specific socket"""
	var socket = get_socket(socket_id)
	if not socket:
		push_error("Socket not found: %s" % socket_id)
		return false
	
	return socket.mount_component(component, force)

func mount_component_by_type(socket_type: UniversalBeingSocket.SocketType, component: Resource, socket_name: String = "") -> bool:
	"""Mount component to first available socket of type"""
	var type_sockets = get_sockets_by_type(socket_type)
	
	# If socket name specified, try to find it first
	if not socket_name.is_empty():
		for socket in type_sockets:
			if socket.socket_name == socket_name and not socket.is_occupied:
				return socket.mount_component(component)
	
	# Otherwise use first available socket
	for socket in type_sockets:
		if not socket.is_occupied:
			return socket.mount_component(component)
	
	push_error("No available sockets of type %s" % UniversalBeingSocket.SocketType.keys()[socket_type])
	return false

func unmount_component_from_socket(socket_id: String) -> bool:
	"""Unmount component from specific socket"""
	var socket = get_socket(socket_id)
	if not socket:
		return false
	
	return socket.unmount_component()

func get_mounted_component(socket_id: String) -> Resource:
	"""Get component mounted to socket"""
	var socket = get_socket(socket_id)
	if not socket:
		return null
	
	return socket.mounted_component

# ===== SOCKET INTROSPECTION =====

func get_socket_configuration() -> Dictionary:
	"""Get complete socket configuration"""
	var config = {
		"total_sockets": sockets.size(),
		"socket_types": {},
		"occupied_sockets": 0,
		"locked_sockets": 0,
		"sockets": {}
	}
	
	# Count by type
	for socket_type in UniversalBeingSocket.SocketType.values():
		var type_name = UniversalBeingSocket.SocketType.keys()[socket_type]
		config.socket_types[type_name] = socket_groups[socket_type].size()
	
	# Socket details
	for socket_id in sockets:
		var socket = sockets[socket_id]
		config.sockets[socket_id] = socket.get_socket_info()
		
		if socket.is_occupied:
			config.occupied_sockets += 1
		if socket.is_locked:
			config.locked_sockets += 1
	
	return config

func get_available_sockets(socket_type: UniversalBeingSocket.SocketType = -1) -> Array[UniversalBeingSocket]:
	"""Get all available (unoccupied) sockets, optionally filtered by type"""
	var available: Array[UniversalBeingSocket] = []
	
	var search_sockets = sockets.values()
	if socket_type != -1:
		search_sockets = socket_groups[socket_type]
	
	for socket in search_sockets:
		if not socket.is_occupied and not socket.is_locked:
			available.append(socket)
	
	return available

func get_occupied_sockets(socket_type: UniversalBeingSocket.SocketType = -1) -> Array[UniversalBeingSocket]:
	"""Get all occupied sockets, optionally filtered by type"""
	var occupied: Array[UniversalBeingSocket] = []
	
	var search_sockets = sockets.values()
	if socket_type != -1:
		search_sockets = socket_groups[socket_type]
	
	for socket in search_sockets:
		if socket.is_occupied:
			occupied.append(socket)
	
	return occupied

# ===== HOT-SWAPPING =====

func hot_swap_component(socket_id: String, new_component: Resource) -> bool:
	"""Hot-swap component in socket without disrupting being operation"""
	var socket = get_socket(socket_id)
	if not socket:
		return false
	
	print("🔄 Hot-swapping component in socket: %s" % socket_id)
	
	# Store old component data
	var old_data = socket.get_component_data()
	
	# Unmount old, mount new
	socket.unmount_component()
	var success = socket.mount_component(new_component, true)
	
	# Restore data if compatible
	if success and not old_data.is_empty():
		socket.set_component_data(old_data)
	
	if success:
		print("🔄 Hot-swap successful for socket: %s" % socket_id)
		# Trigger being refresh if needed
		if owner_being and owner_being.has_method("_on_socket_hot_swapped"):
			owner_being._on_socket_hot_swapped(socket, new_component)
	
	return success

func refresh_all_sockets() -> void:
	"""Refresh all socket components"""
	print("🔄 Refreshing all sockets for being: %s" % (owner_being.being_name if owner_being else "Unknown"))
	
	for socket in sockets.values():
		if socket.is_occupied and socket.mounted_component:
			# Trigger component refresh if it supports it
			if socket.mounted_component.has_method("refresh"):
				socket.mounted_component.refresh()

# ===== INSPECTOR/EDITOR INTEGRATION =====

func get_inspector_data() -> Dictionary:
	"""Get data formatted for inspector/editor interface"""
	var inspector_data = {
		"being_name": owner_being.being_name if owner_being else "Unknown",
		"being_type": owner_being.being_type if owner_being else "Unknown",
		"socket_groups": {}
	}
	
	# Group sockets by type for inspector display
	for socket_type in UniversalBeingSocket.SocketType.values():
		var type_name = UniversalBeingSocket.SocketType.keys()[socket_type]
		var type_sockets = socket_groups[socket_type]
		
		if type_sockets.size() > 0:
			inspector_data.socket_groups[type_name] = []
			
			for socket in type_sockets:
				inspector_data.socket_groups[type_name].append({
					"socket_id": socket.socket_id,
					"socket_name": socket.socket_name,
					"is_occupied": socket.is_occupied,
					"is_locked": socket.is_locked,
					"component_path": socket.component_path,
					"compatibility_tags": socket.compatibility_tags
				})
	
	return inspector_data

# ===== SERIALIZATION =====

func serialize() -> Dictionary:
	"""Serialize entire socket configuration"""
	var data = {
		"sockets": {},
		"configuration": get_socket_configuration()
	}
	
	for socket_id in sockets:
		data.sockets[socket_id] = sockets[socket_id].serialize()
	
	return data

func deserialize(data: Dictionary) -> void:
	"""Deserialize socket configuration"""
	# Clear existing sockets
	sockets.clear()
	_initialize_socket_groups()
	
	# Restore sockets
	var socket_data = data.get("sockets", {})
	for socket_id in socket_data:
		var socket_info = socket_data[socket_id]
		var socket = UniversalBeingSocket.new()
		socket.deserialize(socket_info)
		
		# Register restored socket
		sockets[socket_id] = socket
		socket_groups[socket.socket_type].append(socket)
		
		# Connect signals
		socket.component_mounted.connect(_on_component_mounted.bind(socket))
		socket.component_unmounted.connect(_on_component_unmounted.bind(socket))

# ===== SIGNAL HANDLERS =====

func _on_component_mounted(socket: UniversalBeingSocket, component: Resource) -> void:
	"""Handle component mounted to socket"""
	component_mounted.emit(socket, component)
	socket_configuration_changed.emit()

func _on_component_unmounted(socket: UniversalBeingSocket, component: Resource) -> void:
	"""Handle component unmounted from socket"""
	component_unmounted.emit(socket, component)
	socket_configuration_changed.emit()

# ===== DEBUG =====

func debug_socket_status() -> String:
	"""Get debug information about all sockets"""
	var info = ["=== Socket Manager Debug ==="]
	info.append("Owner: %s" % (owner_being.being_name if owner_being else "None"))
	info.append("Total Sockets: %d" % sockets.size())
	
	for socket_type in UniversalBeingSocket.SocketType.values():
		var type_name = UniversalBeingSocket.SocketType.keys()[socket_type]
		var type_sockets = socket_groups[socket_type]
		info.append("%s Sockets: %d" % [type_name, type_sockets.size()])
		
		for socket in type_sockets:
			var status = "🔴" if socket.is_occupied else "⚪"
			var lock_status = "🔒" if socket.is_locked else ""
			info.append("  %s %s %s %s" % [status, lock_status, socket.socket_name, socket.socket_id])
	
	return "\n".join(info)
