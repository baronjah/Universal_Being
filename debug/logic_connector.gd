# Logic Connector - Universal interface pattern for all Universal Being scripts
# Provides standardized debugging, inspection, and interaction capabilities

extends RefCounted
class_name LogicConnector

# ===== CONNECTOR INTERFACE =====

# Standard interface that every Universal Being script should implement
static func get_debug_interface(object: Node) -> Dictionary:
	"""Get standardized debug interface for any Universal Being script"""
	var interface = {
		"object_info": get_object_info(object),
		"available_actions": get_available_actions(object),
		"current_state": get_current_state(object),
		"connection_points": get_connection_points(object),
		"possible_interactions": get_possible_interactions(object),
		"pentagon_status": get_pentagon_status(object),
		"consciousness_data": get_consciousness_data(object),
		"debug_capabilities": get_debug_capabilities(object)
	}
	
	return interface

# ===== OBJECT INFORMATION =====

static func get_object_info(object: Node) -> Dictionary:
	"""Get basic information about the object"""
	var info = {
		"name": object.name,
		"class": object.get_class(),
		"script_path": "",
		"type": "unknown",
		"position": Vector3.ZERO,
		"children_count": object.get_child_count(),
		"groups": object.get_groups()
	}
	
	# Script information
	if object.get_script():
		info.script_path = object.get_script().get_path()
	
	# Universal Being type
	if object.has_method("get") and object.get("being_type"):
		info.type = object.get("being_type")
	
	# Position for 3D objects
	if object is Node3D:
		info.position = object.global_position
		info.rotation = object.rotation
		info.scale = object.scale
	
	return info

static func get_available_actions(object: Node) -> Array[Dictionary]:
	"""Get all available actions/methods on the object"""
	var actions = []
	
	# Standard Universal Being actions
	if object.has_method("pentagon_init"):
		actions.append_array([
			{"name": "pentagon_init", "description": "Initialize Universal Being", "category": "lifecycle"},
			{"name": "pentagon_ready", "description": "Ready Universal Being", "category": "lifecycle"},
			{"name": "pentagon_process", "description": "Process Universal Being", "category": "lifecycle"},
			{"name": "pentagon_input", "description": "Handle input", "category": "lifecycle"},
			{"name": "pentagon_sewers", "description": "Cleanup Universal Being", "category": "lifecycle"}
		])
	
	# Evolution actions
	if object.has_method("evolve_to"):
		actions.append({"name": "evolve_to", "description": "Evolve to new form", "category": "evolution"})
	
	if object.has_method("can_evolve_to"):
		actions.append({"name": "can_evolve_to", "description": "Check evolution possibility", "category": "evolution"})
	
	# Consciousness actions
	if object.has_method("set_consciousness_level"):
		actions.append({"name": "set_consciousness_level", "description": "Change consciousness level", "category": "consciousness"})
	
	# Component actions
	if object.has_method("add_component"):
		actions.append({"name": "add_component", "description": "Add component to being", "category": "components"})
	
	if object.has_method("remove_component"):
		actions.append({"name": "remove_component", "description": "Remove component", "category": "components"})
	
	# Chunk-specific actions
	if object.has_method("add_being_to_chunk"):
		actions.append({"name": "add_being_to_chunk", "description": "Add being to chunk", "category": "spatial"})
	
	if object.has_method("generate_content_in_chunk"):
		actions.append({"name": "generate_content_in_chunk", "description": "Generate chunk content", "category": "generation"})
	
	# Scene control actions
	if object.has_method("load_scene"):
		actions.append({"name": "load_scene", "description": "Load scene into being", "category": "scene"})
	
	# AI interface actions
	if object.has_method("ai_interface"):
		actions.append({"name": "ai_interface", "description": "Get AI interface", "category": "ai"})
	
	# Custom script methods
	var custom_actions = get_custom_methods(object)
	actions.append_array(custom_actions)
	
	return actions

static func get_custom_methods(object: Node) -> Array[Dictionary]:
	"""Get custom methods from the object's script"""
	var methods = []
	
	if object.get_script():
		var method_list = object.get_method_list()
		for method in method_list:
			var method_name = method.get("name", "")
			
			# Skip built-in Godot methods
			if method_name.begins_with("_") or method_name in ["get", "set", "has_method"]:
				continue
			
			# Skip pentagon methods (already handled)
			if method_name.begins_with("pentagon_"):
				continue
			
			methods.append({
				"name": method_name,
				"description": "Custom method",
				"category": "custom",
				"args": method.get("args", [])
			})
	
	return methods

# ===== STATE INFORMATION =====

static func get_current_state(object: Node) -> Dictionary:
	"""Get current state of the object"""
	var state = {
		"visible": object.visible if object.has_method("set_visible") else true,
		"active": true,
		"process_mode": object.process_mode,
		"variables": get_state_variables(object)
	}
	
	# Universal Being state
	if object.has_method("get"):
		state.consciousness_level = object.get("consciousness_level") if "consciousness_level" in object else 0
		state.being_type = object.get("being_type") if "being_type" in object else "unknown"
		state.being_name = object.get("being_name") if "being_name" in object else object.name
	
	# Pentagon state
	if object.has_method("get") and "pentagon_active" in object:
		state.pentagon_active = object.get("pentagon_active")
	
	# Chunk state
	if object.has_method("get") and "chunk_active" in object:
		state.chunk_active = object.get("chunk_active")
		state.generation_level = object.get("generation_level") if "generation_level" in object else 0
	
	return state

static func get_state_variables(object: Node) -> Dictionary:
	"""Get all state variables from the object"""
	var variables = {}
	
	if object.get_script():
		var property_list = object.get_property_list()
		for prop in property_list:
			var prop_name = prop.name
			
			# Skip private and built-in properties
			if prop_name.begins_with("_") or prop_name in ["script"]:
				continue
			
			# Get value safely
			if object.has_method("get"):
				variables[prop_name] = object.get(prop_name)
	
	return variables

# ===== CONNECTION POINTS =====

static func get_connection_points(object: Node) -> Array[Dictionary]:
	"""Get connection points where this object can connect to others"""
	var connections = []
	
	# Parent-child connections
	connections.append({
		"type": "parent",
		"target": object.get_parent(),
		"description": "Parent node connection"
	})
	
	for child in object.get_children():
		connections.append({
			"type": "child",
			"target": child,
			"description": "Child node: " + child.name
		})
	
	# Signal connections
	var signal_connections = get_signal_connections(object)
	connections.append_array(signal_connections)
	
	# Universal Being specific connections
	if object.has_method("get_connected_beings"):
		var connected_beings = object.get_connected_beings()
		for being in connected_beings:
			connections.append({
				"type": "being_connection",
				"target": being,
				"description": "Connected Universal Being"
			})
	
	# Chunk connections
	if object.has_method("get") and "stored_beings" in object:
		var stored_beings = object.get("stored_beings")
		if stored_beings is Array:
			for being in stored_beings:
				connections.append({
					"type": "chunk_content",
					"target": being,
					"description": "Being stored in chunk"
				})
	
	return connections

static func get_signal_connections(object: Node) -> Array[Dictionary]:
	"""Get signal connections for the object"""
	var connections = []
	
	var signal_list = object.get_signal_list()
	for signal_info in signal_list:
		var signal_name = signal_info.name
		var connections_list = object.get_signal_connection_list(signal_name)
		
		for connection in connections_list:
			connections.append({
				"type": "signal",
				"signal_name": signal_name,
				"target": connection.callable.get_object(),
				"method": connection.callable.get_method(),
				"description": "Signal: %s -> %s" % [signal_name, connection.callable.get_method()]
			})
	
	return connections

# ===== INTERACTION POSSIBILITIES =====

static func get_possible_interactions(object: Node) -> Array[Dictionary]:
	"""Get possible interactions with this object"""
	var interactions = []
	
	# Basic interactions
	interactions.append_array([
		{"action": "inspect", "description": "Inspect object properties", "category": "debug"},
		{"action": "move", "description": "Change position", "category": "transform"},
		{"action": "rename", "description": "Change object name", "category": "basic"}
	])
	
	# Universal Being interactions
	if object.has_method("evolve_to"):
		interactions.append({"action": "evolve", "description": "Evolve to new form", "category": "evolution"})
	
	if object.has_method("add_component"):
		interactions.append({"action": "add_component", "description": "Add new component", "category": "components"})
	
	if object.has_method("set_consciousness_level"):
		interactions.append({"action": "consciousness", "description": "Change consciousness level", "category": "consciousness"})
	
	# Chunk interactions
	if object.has_method("generate_content_in_chunk"):
		interactions.append({"action": "generate", "description": "Generate chunk content", "category": "generation"})
	
	# Scene interactions
	if object.has_method("load_scene"):
		interactions.append({"action": "load_scene", "description": "Load scene into being", "category": "scene"})
	
	# AI interactions
	if object.has_method("ai_interface"):
		interactions.append({"action": "ai_command", "description": "Send AI command", "category": "ai"})
	
	return interactions

# ===== PENTAGON STATUS =====

static func get_pentagon_status(object: Node) -> Dictionary:
	"""Get Pentagon Architecture status"""
	var status = {
		"is_universal_being": object.has_method("pentagon_init"),
		"pentagon_methods": [],
		"lifecycle_stage": "unknown",
		"pentagon_active": false
	}
	
	if status.is_universal_being:
		# Check which pentagon methods exist
		var pentagon_methods = ["pentagon_init", "pentagon_ready", "pentagon_process", "pentagon_input", "pentagon_sewers"]
		for method in pentagon_methods:
			if object.has_method(method):
				status.pentagon_methods.append(method)
		
		# Check if pentagon is active
		if object.has_method("get") and "pentagon_active" in object:
			status.pentagon_active = object.get("pentagon_active")
		
		# Determine lifecycle stage
		if status.pentagon_active:
			status.lifecycle_stage = "active"
		elif object.is_inside_tree():
			status.lifecycle_stage = "ready"
		else:
			status.lifecycle_stage = "initialized"
	
	return status

# ===== CONSCIOUSNESS DATA =====

static func get_consciousness_data(object: Node) -> Dictionary:
	"""Get consciousness-related data"""
	var consciousness = {
		"level": 0,
		"color": Color.GRAY,
		"evolution_paths": [],
		"awareness_range": 0.0
	}
	
	if object.has_method("get"):
		consciousness.level = object.get("consciousness_level") if "consciousness_level" in object else 0
		consciousness.color = object.get_consciousness_color() if object.has_method("get_consciousness_color") else Color.GRAY
		
		# Evolution paths
		if object.has_method("get_evolution_paths"):
			consciousness.evolution_paths = object.get_evolution_paths()
		elif "evolution_state" in object:
			var evolution_state = object.get("evolution_state")
			if evolution_state and "can_become" in evolution_state:
				consciousness.evolution_paths = evolution_state.can_become
	
	return consciousness

# ===== DEBUG CAPABILITIES =====

static func get_debug_capabilities(object: Node) -> Dictionary:
	"""Get debugging capabilities for this object"""
	var capabilities = {
		"can_inspect_variables": true,
		"can_modify_variables": true,
		"can_call_methods": true,
		"can_move": object is Node3D,
		"can_evolve": object.has_method("evolve_to"),
		"can_add_components": object.has_method("add_component"),
		"has_visual_feedback": object is Node3D,
		"supports_ai_commands": object.has_method("ai_interface")
	}
	
	return capabilities

# ===== INTERACTION HELPERS =====

static func execute_action(object: Node, action_name: String, parameters: Array = []) -> Dictionary:
	"""Execute an action on the object"""
	var result = {
		"success": false,
		"message": "",
		"return_value": null
	}
	
	if not object.has_method(action_name):
		result.message = "Method '%s' not found" % action_name
		return result
	
	try:
		result.return_value = object.callv(action_name, parameters)
		result.success = true
		result.message = "Action '%s' executed successfully" % action_name
	except:
		result.message = "Failed to execute action '%s'" % action_name
	
	return result

static func set_variable(object: Node, variable_name: String, value) -> Dictionary:
	"""Set a variable on the object"""
	var result = {
		"success": false,
		"message": "",
		"old_value": null
	}
	
	try:
		# Get old value
		if object.has_method("get"):
			result.old_value = object.get(variable_name)
		
		# Set new value
		if object.has_method("set"):
			object.set(variable_name, value)
		else:
			object.set(variable_name, value)
		
		result.success = true
		result.message = "Variable '%s' set to %s" % [variable_name, value]
	except:
		result.message = "Failed to set variable '%s'" % variable_name
	
	return result

static func get_variable(object: Node, variable_name: String):
	"""Get a variable from the object"""
	if object.has_method("get"):
		return object.get(variable_name)
	else:
		return object.get(variable_name) if variable_name in object else null

# ===== VISUAL HELPERS =====

static func create_debug_visualization(object: Node) -> Node:
	"""Create debug visualization for the object"""
	if not object is Node3D:
		return null
	
	var debug_container = Node3D.new()
	debug_container.name = "DebugVisualization"
	
	# Connection lines to other objects
	var connections = get_connection_points(object)
	for connection in connections:
		if connection.target and connection.target is Node3D:
			create_connection_line(debug_container, object.global_position, connection.target.global_position)
	
	# State indicator
	create_state_indicator(debug_container, object)
	
	object.add_child(debug_container)
	return debug_container

static func create_connection_line(parent: Node3D, from: Vector3, to: Vector3) -> void:
	"""Create a visual line between two points"""
	var line = MeshInstance3D.new()
	var mesh = CylinderMesh.new()
	mesh.height = from.distance_to(to)
	mesh.top_radius = 0.02
	mesh.bottom_radius = 0.02
	line.mesh = mesh
	
	# Position and orient the line
	line.global_position = (from + to) / 2
	line.look_at(to, Vector3.UP)
	
	parent.add_child(line)

static func create_state_indicator(parent: Node3D, object: Node) -> void:
	"""Create visual state indicator"""
	var indicator = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.1
	indicator.mesh = sphere
	
	# Color based on consciousness level
	var material = StandardMaterial3D.new()
	if object.has_method("get_consciousness_color"):
		material.albedo_color = object.get_consciousness_color()
	else:
		material.albedo_color = Color.WHITE
	
	indicator.material_override = material
	indicator.position = Vector3(0, 1, 0)
	
	parent.add_child(indicator)