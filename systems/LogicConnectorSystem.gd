# ==================================================
# SCRIPT NAME: LogicConnectorSystem.gd
# DESCRIPTION: System-wide Logic Connector management for Universal Being project
# PURPOSE: Manage logic connections between all Universal Beings
# CREATED: 2025-06-04 - Universal Logic Connection System
# AUTHOR: JSH + Claude Code + The Vision
# ==================================================

extends Node
class_name LogicConnectorSystem

# ===== SYSTEM-WIDE LOGIC CONNECTOR MANAGEMENT =====

# Global instances and state
var connector_instances: Array[LogicConnector] = []
var connection_visualizations: Dictionary = {}
var auto_register_enabled: bool = true

# System signals
signal logic_connection_established(from: Node, to: Node, connection_type: String)
signal logic_connection_broken(from: Node, to: Node)
signal universal_being_registered(being: Node)
signal universal_being_deregistered(being: Node)

func _ready() -> void:
	name = "LogicConnectorSystem"
	add_to_group("logic_connector_system")
	print("🔌 LogicConnectorSystem: Universal Being logic connection management ready")
	
	# Auto-discover and register Universal Beings
	if auto_register_enabled:
		call_deferred("_auto_discover_universal_beings")

# ===== UNIVERSAL BEING AUTO-DISCOVERY =====

func _auto_discover_universal_beings() -> void:
	"""Automatically discover and register all Universal Beings in the scene tree"""
	print("🔌 Auto-discovering Universal Beings...")
	
	var beings_found = 0
	_scan_node_for_universal_beings(get_tree().root)
	
	print("🔌 Auto-discovery complete: %d Universal Beings registered" % LogicConnector.get_debuggable_count())

func _scan_node_for_universal_beings(node: Node) -> void:
	"""Recursively scan node tree for Universal Beings"""
	# Check if this node is a Universal Being
	if _is_universal_being(node):
		register_universal_being(node)
	
	# Scan children
	for child in node.get_children():
		_scan_node_for_universal_beings(child)

func _is_universal_being(node: Node) -> bool:
	"""Check if a node is a Universal Being"""
	# Check if it extends UniversalBeing
	if node.get_script():
		var script = node.get_script()
		if script.has_method("pentagon_init"):
			return true
	
	# Check if it has Universal Being properties
	if node.has_method("get"):
		if "being_type" in node or "consciousness_level" in node:
			return true
	
	# Check class name
	if node.get_class().contains("UniversalBeing"):
		return true
	
	return false

# ===== REGISTRATION MANAGEMENT =====

func register_universal_being(being: Node) -> bool:
	"""Register a Universal Being with the logic connector system"""
	if not being:
		return false
	
	# Ensure it has the required debug interface
	if not being.has_method("get_debug_payload"):
		# Create minimal debug interface if missing
		_create_minimal_debug_interface(being)
	
	# Register with LogicConnector
	LogicConnector.register(being)
	universal_being_registered.emit(being)
	
	print("🔌 Registered Universal Being: %s (type: %s)" % [
		being.name, 
		being.get("being_type") if being.has_method("get") and "being_type" in being else "unknown"
	])
	
	return true

func deregister_universal_being(being: Node) -> void:
	"""Deregister a Universal Being from the system"""
	LogicConnector.deregister(being)
	universal_being_deregistered.emit(being)
	
	# Remove any visualizations
	if being in connection_visualizations:
		if connection_visualizations[being]:
			connection_visualizations[being].queue_free()
		connection_visualizations.erase(being)

func _create_minimal_debug_interface(being: Node) -> void:
	"""Create minimal debug interface for Universal Beings that don't have one"""
	# Add required methods dynamically (simplified approach)
	being.set_meta("debug_interface_created", true)
	
	# This would normally be done with proper method injection,
	# but for now we ensure LogicConnector can still work with it

# ===== CONNECTION MANAGEMENT =====

func create_logic_connection(from: Node, to: Node, connection_type: String = "default") -> Dictionary:
	"""Create a logic connection between two Universal Beings"""
	var connection = {
		"from": from,
		"to": to,
		"type": connection_type,
		"created": Time.get_ticks_msec(),
		"active": true
	}
	
	# Add to LogicConnector tracking
	if not LogicConnector.socket_connections.has(from):
		LogicConnector.socket_connections[from] = []
	LogicConnector.socket_connections[from].append(connection)
	
	# Create visualization if enabled
	if should_visualize_connections():
		create_connection_visualization(connection)
	
	logic_connection_established.emit(from, to, connection_type)
	print("🔌 Logic connection created: %s → %s (%s)" % [from.name, to.name, connection_type])
	
	return connection

func break_logic_connection(from: Node, to: Node) -> bool:
	"""Break a logic connection between two Universal Beings"""
	if not LogicConnector.socket_connections.has(from):
		return false
	
	var connections = LogicConnector.socket_connections[from]
	for i in range(connections.size() - 1, -1, -1):
		var connection = connections[i]
		if connection.to == to:
			connections.remove_at(i)
			
			# Remove visualization
			remove_connection_visualization(connection)
			
			logic_connection_broken.emit(from, to)
			print("🔌 Logic connection broken: %s → %s" % [from.name, to.name])
			return true
	
	return false

# ===== VISUALIZATION MANAGEMENT =====

func should_visualize_connections() -> bool:
	"""Check if connection visualization is enabled"""
	return true  # Could be configurable

func create_connection_visualization(connection: Dictionary) -> void:
	"""Create visual representation of a logic connection"""
	if not connection.from is Node3D or not connection.to is Node3D:
		return
	
	# Create connection line (LogicConnector.create_connection_line returns void)
	LogicConnector.create_connection_line(
		get_tree().current_scene,
		connection.from.global_position,
		connection.to.global_position
	)
	
	# Note: For proper cleanup, we'd need to modify LogicConnector.create_connection_line 
	# to return the created line, but for now we'll track connections differently
	connection_visualizations[connection] = true

func remove_connection_visualization(connection: Dictionary) -> void:
	"""Remove visual representation of a logic connection"""
	if connection in connection_visualizations:
		var visualization = connection_visualizations[connection]
		if visualization:
			visualization.queue_free()
		connection_visualizations.erase(connection)

# ===== UNIVERSAL ACTION ACCESS =====

func execute_action_on_all_beings(action_name: String, parameters: Dictionary = {}) -> Array[Dictionary]:
	"""Execute an action on all registered Universal Beings"""
	var results = []
	
	for being in LogicConnector.all():
		var result = execute_action_on_being(being, action_name, parameters)
		results.append(result)
	
	return results

func execute_action_on_being(being: Node, action_name: String, parameters: Dictionary = {}) -> Dictionary:
	"""Execute a specific action on a Universal Being"""
	var result = {
		"being": being.name,
		"action": action_name,
		"success": false,
		"message": "",
		"result": null
	}
	
	# Use LogicConnector to execute the action
	if being.has_method(action_name):
		# Execute action safely
		result.result = being.callv(action_name, parameters.values())
		result.success = true
		result.message = "Action executed successfully"
	else:
		result.message = "Action not available on this being"
	
	return result

# ===== SYSTEM STATUS AND DIAGNOSTICS =====

func get_system_status() -> Dictionary:
	"""Get comprehensive system status"""
	return {
		"registered_beings": LogicConnector.get_debuggable_count(),
		"active_connections": _count_active_connections(),
		"visualization_count": connection_visualizations.size(),
		"auto_register_enabled": auto_register_enabled,
		"debuggable_types": LogicConnector.get_debuggable_types()
	}

func _count_active_connections() -> int:
	"""Count total active logic connections"""
	var count = 0
	for being in LogicConnector.socket_connections:
		count += LogicConnector.socket_connections[being].size()
	return count

func print_system_status() -> void:
	"""Print detailed system status"""
	var status = get_system_status()
	print("🔌 ================================")
	print("🔌 LOGIC CONNECTOR SYSTEM STATUS")
	print("🔌 ================================")
	print("🔌 Registered Beings: %d" % status.registered_beings)
	print("🔌 Active Connections: %d" % status.active_connections)
	print("🔌 Visualizations: %d" % status.visualization_count)
	print("🔌 Auto-Register: %s" % status.auto_register_enabled)
	print("🔌 Being Types: %s" % str(status.debuggable_types))
	print("🔌 ================================")

# ===== UTILITY METHODS =====

func find_being_by_type(being_type: String) -> Array[Node]:
	"""Find all Universal Beings of a specific type"""
	var matching_beings = []
	
	for being in LogicConnector.all():
		if being.has_method("get") and being.get("being_type") == being_type:
			matching_beings.append(being)
	
	return matching_beings

func get_being_connections(being: Node) -> Array[Dictionary]:
	"""Get all connections for a specific being"""
	if LogicConnector.socket_connections.has(being):
		return LogicConnector.socket_connections[being]
	return []

func cleanup_system() -> void:
	"""Clean up the entire logic connector system"""
	print("🔌 Cleaning up Logic Connector System...")
	
	# Clear all visualizations
	for visualization in connection_visualizations.values():
		if visualization:
			visualization.queue_free()
	connection_visualizations.clear()
	
	# Clear LogicConnector registry
	LogicConnector.clear_registry()
	
	print("🔌 Logic Connector System cleaned up")