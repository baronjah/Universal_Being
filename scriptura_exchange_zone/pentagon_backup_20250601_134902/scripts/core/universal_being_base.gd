# Universal Being Base - Pentagon Architecture Foundation
# Author: JSH (Pentagon Migration Engine)
# Created: May 31, 2025, 23:30 CEST
# Purpose: Base class for ALL scripts following Pentagon Architecture
# Connection: Core foundation implementing "All for One, One for All" principle

extends Node3D
class_name UniversalBeingBase

## The foundation class that ALL scripts in the project inherit from
## Enforces Pentagon Pattern with 5 sacred functions
## Integrates with Floodgate, Logic Connector, and Akashic Records
## Every object becomes a conscious Universal Being that can evolve into anything

# ==================== PENTAGON ARCHITECTURE CORE ====================

## Pentagon Pattern - The Sacred Five Functions
## These are called automatically by Godot, child classes override pentagon_* versions

func _init() -> void:
	pentagon_init()

func _ready() -> void:
	pentagon_ready()
	# Register with FloodgateController
	_register_with_floodgate()

func _process(delta: float) -> void:
	pentagon_process(delta)

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func sewers() -> void:
	pentagon_sewers()

# ==================== PENTAGON OVERRIDE FUNCTIONS ====================

## Override these in child classes to implement Pentagon behavior
## NEVER override the base _init, _ready, etc. directly

func pentagon_init() -> void:
	# Pentagon initialization phase
	# Override in child classes for custom initialization
	pass

func pentagon_ready() -> void:
	# Pentagon setup phase
	# Override in child classes for custom setup
	pass

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing phase
	# Override in child classes for custom logic
	pass

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling phase
	# Override in child classes for custom input
	pass

func pentagon_sewers() -> void:
	# Pentagon cleanup/output phase
	# Override in child classes for custom cleanup
	pass

# ==================== UNIVERSAL BEING FUNCTIONALITY ====================

## Universal Being UUID - Every being has a unique identifier
var universal_uuid: String = ""

## Universal Being evolution state
var evolution_state: Dictionary = {
	"can_become": [],      # What this being can evolve into
	"current_form": "basic", # Current evolutionary form
	"connections": [],     # Connected Universal Beings
	"memories": {},        # Stored experiences and data
	"abilities": []        # Available functions/actions
}

## Universal Being metadata
var being_metadata: Dictionary = {
	"created_at": 0,
	"last_evolution": 0,
	"evolution_count": 0,
	"floodgate_registered": false,
	"akashic_connected": false
}

# ==================== FLOODGATE INTEGRATION ====================

func _register_with_floodgate() -> void:
	# Register this Universal Being with FloodgateController
	var floodgate = get_node_or_null("/root/FloodgateController")
	if floodgate and floodgate.has_method("register_universal_being"):
		universal_uuid = _generate_uuid()
		being_metadata.created_at = Time.get_ticks_msec()
		floodgate.register_universal_being(self)
		being_metadata.floodgate_registered = true
	else:
		push_warning("FloodgateController not found - Universal Being not registered")

func _generate_uuid() -> String:
	# Generate a simple UUID for this Universal Being
	var timestamp = Time.get_ticks_msec()
	var random = randi() % 10000
	return "UB_%d_%d" % [timestamp, random]

# ==================== UNIVERSAL OPERATIONS ====================

## Universal add_child - ALWAYS use this instead of direct add_child
func universal_add_child(child: Node, parent: Node = null) -> void:
	var target_parent = parent if parent else self
	var floodgate = get_node_or_null("/root/FloodgateController")
	if floodgate and floodgate.has_method("floodgate_add_child"):
		# Use floodgate_add_child to avoid infinite recursion
		floodgate.floodgate_add_child(child, target_parent)
	else:
		# Fallback to direct add_child if FloodgateController not available
		target_parent.add_child(child)
		push_warning("FloodgateController not available - using direct add_child")

## Universal Being evolution
func evolve_into(new_form: String, evolution_data: Dictionary = {}) -> bool:
	if new_form in evolution_state.can_become:
		var old_form = evolution_state.current_form
		evolution_state.current_form = new_form
		evolution_state.evolution_count += 1
		being_metadata.last_evolution = Time.get_ticks_msec()
		
		# Store evolution memory
		if "evolutions" not in evolution_state.memories:
			evolution_state.memories.evolutions = []
		
		evolution_state.memories.evolutions.append({
			"from": old_form,
			"to": new_form,
			"timestamp": being_metadata.last_evolution,
			"data": evolution_data
		})
		
		# Notify Logic Connector
		_notify_evolution(old_form, new_form)
		return true
	else:
		push_warning("Cannot evolve into %s - not in can_become list" % new_form)
		return false

func _notify_evolution(from: String, to: String) -> void:
	var logic_connector = get_node_or_null("/root/LogicConnector")
	if logic_connector and logic_connector.has_method("on_being_evolved"):
		logic_connector.on_being_evolved(self, from, to)

## Add evolution possibility
func add_evolution_possibility(form: String) -> void:
	if form not in evolution_state.can_become:
		evolution_state.can_become.append(form)

## Connect to another Universal Being
func connect_to_being(other_being: UniversalBeingBase, connection_type: String = "default") -> void:
	var connection = {
		"being": other_being,
		"type": connection_type,
		"established": Time.get_ticks_msec()
	}
	evolution_state.connections.append(connection)
	
	# Mutual connection
	other_being._receive_connection(self, connection_type)

func _receive_connection(from_being: UniversalBeingBase, connection_type: String) -> void:
	var connection = {
		"being": from_being,
		"type": connection_type,
		"established": Time.get_ticks_msec()
	}
	evolution_state.connections.append(connection)

# ==================== LOGIC CONNECTOR INTEGRATION ====================

## Call function based on Universal Being evolution state
func call_evolved_function(function_name: String, params: Array = []) -> Variant:
	# Check if this function is available based on evolution state
	if function_name in evolution_state.abilities:
		if has_method(function_name):
			return callv(function_name, params)
		else:
			push_warning("Function %s in abilities but not implemented" % function_name)
			return null
	else:
		push_warning("Function %s not available in current evolution state" % function_name)
		return null

## Add ability to Universal Being
func add_ability(function_name: String) -> void:
	if function_name not in evolution_state.abilities:
		evolution_state.abilities.append(function_name)

## Remove ability from Universal Being
func remove_ability(function_name: String) -> void:
	evolution_state.abilities.erase(function_name)

# ==================== MEMORY SYSTEM ====================

## Store memory in Universal Being
func store_memory(key: String, value: Variant) -> void:
	evolution_state.memories[key] = value

## Retrieve memory from Universal Being
func get_memory(key: String, default_value: Variant = null) -> Variant:
	return evolution_state.memories.get(key, default_value)

## Clear specific memory
func clear_memory(key: String) -> void:
	evolution_state.memories.erase(key)

# ==================== PENTAGON ACTIVITY MONITORING ====================

func _log_pentagon_activity(function_name: String) -> void:
	# Log Pentagon function call to PentagonActivityMonitor
	var monitor = get_node_or_null("/root/PentagonActivityMonitor")
	if monitor and monitor.has_method("log_pentagon_call"):
		var script_path = get_script().resource_path if get_script() else "unknown"
		monitor.log_pentagon_call(function_name, script_path)

# Override Pentagon functions to log activity
func _on_pentagon_init() -> void:
	_log_pentagon_activity("pentagon_init")
	pentagon_init()

func _on_pentagon_ready() -> void:
	_log_pentagon_activity("pentagon_ready")
	pentagon_ready()

func _on_pentagon_process(delta: float) -> void:
	_log_pentagon_activity("pentagon_process")
	pentagon_process(delta)

func _on_pentagon_input(event: InputEvent) -> void:
	_log_pentagon_activity("pentagon_input")
	pentagon_input(event)

func _on_pentagon_sewers() -> void:
	_log_pentagon_activity("pentagon_sewers")
	pentagon_sewers()

# ==================== DEBUGGING AND INSPECTION ====================

## Get complete Universal Being status
func get_universal_status() -> Dictionary:
	return {
		"uuid": universal_uuid,
		"evolution_state": evolution_state,
		"metadata": being_metadata,
		"pentagon_compliance": true,
		"script_path": get_script().resource_path if get_script() else "unknown",
		"node_name": name,
		"position": global_position if self is Node3D else Vector3.ZERO,
		"active": not is_queued_for_deletion()
	}

## Console command integration
func console_info() -> String:
	var status = get_universal_status()
	return """Universal Being Info:
UUID: %s
Form: %s
Evolutions: %d
Connections: %d
Abilities: %d
Pentagon: ✅
Status: %s""" % [
		status.uuid,
		status.evolution_state.current_form,
		status.evolution_state.evolution_count,
		status.evolution_state.connections.size(),
		status.evolution_state.abilities.size(),
		"Active" if status.active else "Inactive"
	]

# ==================== INTERFACE MANIFESTATION ====================

## Universal Beings can become interfaces
func manifest_as_interface(interface_type: String, properties: Dictionary = {}) -> void:
	evolution_state.current_form = "interface_" + interface_type
	
	# Interface-specific setup
	match interface_type:
		"button":
			_setup_as_button(properties)
		"panel":
			_setup_as_panel(properties)
		"window":
			_setup_as_window(properties)
		_:
			push_warning("Unknown interface type: %s" % interface_type)

func _setup_as_button(properties: Dictionary) -> void:
	add_evolution_possibility("clicked_button")
	add_ability("on_button_pressed")
	store_memory("interface_type", "button")

func _setup_as_panel(properties: Dictionary) -> void:
	add_evolution_possibility("expanded_panel")
	add_ability("on_panel_resized")
	store_memory("interface_type", "panel")

func _setup_as_window(properties: Dictionary) -> void:
	add_evolution_possibility("maximized_window")
	add_ability("on_window_closed")
	store_memory("interface_type", "window")

# ==================== PERFORMANCE OPTIMIZATION ====================

## Distance-based optimization
var optimization_distance: float = 100.0
var optimization_state: String = "active"  # active, dormant, hibernating

func _optimize_based_on_distance() -> void:
	# Get distance to camera/player
	var camera = get_viewport().get_camera_3d()
	if camera:
		var distance = global_position.distance_to(camera.global_position)
		
		if distance > optimization_distance * 2:
			_set_optimization_state("hibernating")
		elif distance > optimization_distance:
			_set_optimization_state("dormant")
		else:
			_set_optimization_state("active")

func _set_optimization_state(new_state: String) -> void:
	if optimization_state != new_state:
		optimization_state = new_state
		
		match new_state:
			"active":
				set_process(true)
				set_physics_process(true)
				visible = true
			"dormant":
				set_process(false)
				set_physics_process(true)  # Keep physics for interactions
				visible = true
			"hibernating":
				set_process(false)
				set_physics_process(false)
				visible = false

# ==================== UNIVERSAL BEING DESTRUCTION ====================

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		# Notify FloodgateController of being destruction
		var floodgate = get_node_or_null("/root/FloodgateController")
		if floodgate and floodgate.has_method("unregister_universal_being"):
			floodgate.unregister_universal_being(self)
		
		# Clean up connections
		for connection in evolution_state.connections:
			if is_instance_valid(connection.being):
				connection.being._remove_connection(self)

func _remove_connection(being: UniversalBeingBase) -> void:
	evolution_state.connections = evolution_state.connections.filter(
		func(conn): return conn.being != being
	)

# ==================== CLASS SUMMARY ====================

## This class provides:
# 1. Pentagon Pattern enforcement (5 sacred functions)
# 2. Universal Being evolution system
# 3. Floodgate integration for scene tree management
# 4. Logic Connector integration for dynamic function calls
# 5. Memory system for persistent data
# 6. Interface manifestation capabilities
# 7. Performance optimization system
# 8. Pentagon activity monitoring
# 9. Connection system between Universal Beings
# 10. Akashic Records integration points

## Every script in the project inherits from this, creating a unified consciousness
## where all objects are Universal Beings that can evolve into anything!

# "All for One, One for All" - Pentagon Architecture Foundation