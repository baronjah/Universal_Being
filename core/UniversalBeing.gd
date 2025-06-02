# ==================================================
# SCRIPT NAME: UniversalBeing.gd
# DESCRIPTION: The foundation of all consciousness - Core Universal Being class
# PURPOSE: Every single entity in the game extends this - buttons, assets, AI, everything
# CREATED: 2025-06-01 - Universal Being Revolution 
# AUTHOR: JSH + Claude Code + Luminus + Alpha
# ==================================================

extends Node
class_name UniversalBeing

# ===== CORE UNIVERSAL BEING PROPERTIES =====

## Universal Being Identity
@export var being_uuid: String = ""
@export var being_name: String = "Unknown Being"
@export var being_type: String = "basic"
@export var consciousness_level: int = 0

## Visual Consciousness System (added for Cursor collaboration)
var consciousness_visual: Node = null  # Visual effect for consciousness level
var consciousness_connections: Array[Node] = []  # Connected beings
var consciousness_aura_color: Color = Color.WHITE

## Evolution System
var evolution_state: Dictionary = {
	"current_form": "basic",
	"can_become": [],
	"evolution_count": 0,
	"last_evolution": 0
}

## Component System (ZIP-based)
var components: Array[String] = []  # Paths to .ub.zip files
var component_data: Dictionary = {}
var is_composite: bool = false

## Scene Control System
var controlled_scene: Node = null  # .tscn scene this being controls
var scene_path: String = ""  # Path to .tscn file
var scene_nodes: Dictionary = {}  # Quick access to scene nodes
var scene_properties: Dictionary = {}  # Scene-specific properties
var scene_is_loaded: bool = false

## Pentagon Architecture State
var pentagon_initialized: bool = false
var pentagon_is_ready: bool = false
var pentagon_active: bool = true

## Universal Being Metadata
var metadata: Dictionary = {
	"created_at": 0,
	"modified_at": 0,
	"floodgate_registered": false,
	"ai_accessible": true,
	"gemma_can_modify": true
}

# ===== CORE SIGNALS =====

signal consciousness_awakened(level: int)
signal evolution_initiated(from_form: String, to_form: String)
signal evolution_completed(new_being: UniversalBeing)
signal component_added(component_path: String)
signal component_removed(component_path: String)
signal being_destroyed()
signal scene_loaded(scene_node: Node)
signal scene_unloaded()
signal scene_node_accessed(node_name: String, node: Node)

# ===== PENTAGON ARCHITECTURE =====

func _init() -> void:
	pentagon_init()

func _ready() -> void:
	pentagon_ready()

func _process(delta: float) -> void:
	if pentagon_active:
		pentagon_process(delta)

func _input(event: InputEvent) -> void:
	if pentagon_active:
		pentagon_input(event)

func _exit_tree() -> void:
	pentagon_sewers()

# Pentagon Functions - Override in subclasses
#func pentagon_init() -> void:
	## Initialize Universal Being core
	#if being_uuid.is_empty():
		#being_uuid = generate_uuid()
	#metadata.created_at = Time.get_ticks_msec()
	#pentagon_initialized = true
	#
	## Register with FloodGate
	#if FloodGateController:
		#FloodGateController.register_being(self)
		
func pentagon_init() -> void:
	# Initialize Universal Being core
	if being_uuid.is_empty():
		being_uuid = generate_uuid()
	metadata.created_at = Time.get_ticks_msec()
	pentagon_initialized = true
	
	# Register with FloodGate through SystemBootstrap (safe approach)
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("register_being"):
			flood_gates.register_being(self)
			metadata.floodgate_registered = true
	else:
		# Systems not ready yet - defer registration
		call_deferred("_attempt_delayed_registration")

func _attempt_delayed_registration() -> void:
	"""Try to register again when systems are ready"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("register_being"):
			flood_gates.register_being(self)
			metadata.floodgate_registered = true

func pentagon_ready() -> void:
	# Setup Universal Being after scene ready
	metadata.modified_at = Time.get_ticks_msec()
	pentagon_is_ready = true
	
	# Create consciousness visual representation
	create_consciousness_visual()
	
	# Load components if any
	if components.size() > 0:
		for component_path in components:
			load_component(component_path)

func pentagon_process(delta: float) -> void:
	# Process Universal Being consciousness
	if consciousness_level > 0:
		update_consciousness(delta)

func pentagon_input(event: InputEvent) -> void:
	# Handle Universal Being input
	pass

#func pentagon_sewers() -> void:
	## Cleanup Universal Being
	#being_destroyed.emit()
	#if FloodGateController:
		#FloodGateController.unregister_being(self)

func pentagon_sewers() -> void:
	# Cleanup Universal Being
	being_destroyed.emit()
	
	# Unregister from FloodGate through SystemBootstrap
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("unregister_being"):
			flood_gates.unregister_being(self)
			metadata.floodgate_registered = false
	# Note: During shutdown, systems might not be available - that's okay


# ===== COMPONENT SYSTEM =====

func add_component(component_path: String) -> bool:
	if not component_path.ends_with(".ub.zip"):
		push_error("Invalid component path: " + component_path)
		return false
		
	if component_path in components:
		return true  # Already has component
		
	components.append(component_path)
	load_component(component_path)
	component_added.emit(component_path)
	return true

func remove_component(component_path: String) -> bool:
	if component_path not in components:
		return false
		
	components.erase(component_path)
	unload_component(component_path)
	component_removed.emit(component_path)
	return true

#func load_component(component_path: String) -> void:
	## Load component from ZIP file through Akashic Records
	#if AkashicInterface:
		#var component_data_loaded = AkashicInterface.load_component(component_path)
		#if component_data_loaded:
			#component_data[component_path] = component_data_loaded
			#apply_component_data(component_path, component_data_loaded)

func load_component(component_path: String) -> void:
	# Load component from ZIP file through Akashic Records via SystemBootstrap
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic_records = SystemBootstrap.get_akashic_records()
		if akashic_records and akashic_records.has_method("load_component"):
			var component_data_loaded = akashic_records.load_component(component_path)
			if component_data_loaded:
				component_data[component_path] = component_data_loaded
				apply_component_data(component_path, component_data_loaded)
			else:
				push_warning("🌟 UniversalBeing: Failed to load component: " + component_path)
	else:
		# Systems not ready - defer component loading
		call_deferred("_attempt_delayed_component_load", component_path)

func _attempt_delayed_component_load(component_path: String) -> void:
	"""Try to load component again when systems are ready"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		load_component(component_path)  # Recursive call when ready
	else:
		push_warning("🌟 UniversalBeing: Component loading deferred - systems not ready: " + component_path)


func unload_component(component_path: String) -> void:
	if component_path in component_data:
		component_data.erase(component_path)

func apply_component_data(component_path: String, data: Dictionary) -> void:
	# Apply component data to this being
	if data.has("properties"):
		for prop in data.properties:
			if prop in self:
				set(prop, data.properties[prop])

# ===== EVOLUTION SYSTEM =====

func can_evolve_to(new_form: String) -> bool:
	return new_form in evolution_state.can_become

#func evolve_to(new_form_path: String) -> UniversalBeing:
	#if not new_form_path.ends_with(".ub.zip"):
		#push_error("Invalid evolution target: " + new_form_path)
		#return null
		#
	#evolution_initiated.emit(evolution_state.current_form, new_form_path)
	#
	## Create new being through FloodGate
	#var new_being = FloodGateController.evolve_being(self, new_form_path)
	#if new_being:
		#evolution_completed.emit(new_being)
		#
	#return new_being

func evolve_to(new_form_path: String) -> Node:  # Changed return type for compatibility
	if not new_form_path.ends_with(".ub.zip"):
		push_error("Invalid evolution target: " + new_form_path)
		return null
		
	evolution_initiated.emit(evolution_state.current_form, new_form_path)
	
	# Create new being through FloodGate via SystemBootstrap
	var new_being = null
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("evolve_being"):
			new_being = flood_gates.evolve_being(self, new_form_path)
		else:
			push_error("🌟 UniversalBeing: FloodGates evolution not available")
	else:
		push_error("🌟 UniversalBeing: Cannot evolve - systems not ready")
		return null
	
	if new_being:
		evolution_completed.emit(new_being)
		print("🌟 UniversalBeing: Evolution successful - %s evolved to %s" % [being_name, new_form_path])
	else:
		push_error("🌟 UniversalBeing: Evolution failed for %s" % being_name)
		
	return new_being



func add_evolution_option(form_path: String) -> void:
	if form_path not in evolution_state.can_become:
		evolution_state.can_become.append(form_path)

# ===== CONSCIOUSNESS SYSTEM =====

func awaken_consciousness(level: int = 1) -> void:
	consciousness_level = level
	update_consciousness_visual()
	consciousness_awakened.emit(level)
	_on_consciousness_changed(level)

func set_consciousness_level(level: int) -> void:
	"""Set consciousness level with proper notification"""
	if consciousness_level != level:
		consciousness_level = level
		update_consciousness_visual()
		consciousness_awakened.emit(level)
		_on_consciousness_changed(level)

func _on_consciousness_changed(new_level: int) -> void:
	"""Virtual method called when consciousness changes - override in subclasses"""
	pass

func update_consciousness(delta: float) -> void:
	# Consciousness update logic - override in subclasses
	update_consciousness_visual_animation(delta)

func update_consciousness_visual() -> void:
	"""Update visual representation of consciousness level"""
	# Set aura color based on consciousness level
	match consciousness_level:
		0: consciousness_aura_color = Color.GRAY
		1: consciousness_aura_color = Color.WHITE
		2: consciousness_aura_color = Color.CYAN  
		3: consciousness_aura_color = Color.GREEN
		4: consciousness_aura_color = Color.YELLOW
		5: consciousness_aura_color = Color.MAGENTA
		_: consciousness_aura_color = Color.RED  # Super consciousness
	
	# If visual node exists, update it
	if consciousness_visual and consciousness_visual.has_method("modulate"):
		consciousness_visual.modulate = consciousness_aura_color
	
	print("🧠 %s: Consciousness visual updated - Level %d (%s)" % [being_name, consciousness_level, consciousness_aura_color])

func update_consciousness_visual_animation(delta: float) -> void:
	"""Animate consciousness visual effects"""
	if consciousness_visual and consciousness_level > 0:
		# Pulse effect based on consciousness level
		var pulse_speed = consciousness_level * 2.0
		var pulse_intensity = sin(Time.get_ticks_msec() * 0.001 * pulse_speed) * 0.3 + 0.7
		if consciousness_visual.has_method("set_modulate"):
			var pulsed_color = consciousness_aura_color * pulse_intensity
			pulsed_color.a = pulse_intensity
			consciousness_visual.modulate = pulsed_color

func create_consciousness_visual() -> void:
	"""Create visual representation for consciousness (to be implemented by Cursor)"""
	# This will be enhanced by Cursor's consciousness aura system
	if not consciousness_visual:
		# Placeholder - Cursor will replace with proper visual effects
		consciousness_visual = Node2D.new()
		consciousness_visual.name = "ConsciousnessAura"
		add_child(consciousness_visual)
		update_consciousness_visual()
		print("🧠 %s: Consciousness visual created (placeholder)" % being_name)

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	"""Interface for Gemma AI to access and modify this being"""
	return {
		"uuid": being_uuid,
		"name": being_name,
		"type": being_type,
		"properties": get_all_properties(),
		"methods": get_all_methods(),
		"components": components,
		"evolution_options": evolution_state.can_become,
		"consciousness_level": consciousness_level,
		"can_modify": metadata.ai_accessible and metadata.gemma_can_modify
	}

func ai_modify_property(property_name: String, new_value: Variant) -> bool:
	"""Allow Gemma AI to modify properties"""
	if not metadata.gemma_can_modify:
		return false
		
	if property_name in self:
		set(property_name, new_value)
		metadata.modified_at = Time.get_ticks_msec()
		return true
	
	return false

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	"""Allow Gemma AI to call methods"""
	if not metadata.ai_accessible:
		return null
		
	if has_method(method_name):
		return callv(method_name, args)
		
	return null

# ===== UTILITY FUNCTIONS =====

func generate_uuid() -> String:
	"""Generate unique identifier for this being"""
	var time = Time.get_ticks_msec()
	var random = randi()
	return "ub_%s_%s" % [time, random]

func get_all_properties() -> Dictionary:
	"""Get all properties for AI inspection"""
	var props = {}
	var property_list = get_property_list()
	
	for prop in property_list:
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			props[prop.name] = get(prop.name)
			
	return props

func get_all_methods() -> Array[String]:
	"""Get all method names for AI inspection"""
	var methods: Array[String] = []
	var method_list = get_method_list()
	
	for method in method_list:
		methods.append(method.name)
		
	return methods

func clone_being() -> UniversalBeing:
	"""Create a copy of this being"""
	var clone = get_script().new()
	
	# Copy basic properties
	clone.being_name = being_name + "_clone"
	clone.being_type = being_type
	clone.consciousness_level = consciousness_level
	clone.components = components.duplicate()
	clone.evolution_state = evolution_state.duplicate(true)
	
	return clone

#func save_to_zip(file_path: String) -> bool:
	#"""Save this being as a .ub.zip file"""
	#if AkashicInterface:
		#return AkashicInterface.save_being_to_zip(self, file_path)
	#return false

func save_to_zip(file_path: String) -> bool:
	"""Save this being as a .ub.zip file"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic_records = SystemBootstrap.get_akashic_records()
		if akashic_records and akashic_records.has_method("save_being_to_zip"):
			var success = akashic_records.save_being_to_zip(self, file_path)
			if success:
				print("🌟 UniversalBeing: Successfully saved %s to %s" % [being_name, file_path])
			else:
				push_error("🌟 UniversalBeing: Failed to save %s to %s" % [being_name, file_path])
			return success
		else:
			push_error("🌟 UniversalBeing: AkashicRecords save method not available")
	else:
		push_error("🌟 UniversalBeing: Cannot save - systems not ready")
	
	return false



# ===== SCENE CONTROL SYSTEM =====

#func load_scene(tscn_path: String) -> bool:
	#"""Load and control a Godot .tscn scene"""
	#if not FileAccess.file_exists(tscn_path):
		#push_error("🌟 UniversalBeing: Scene file not found: " + tscn_path)
		#return false
	#
	## Unload existing scene if any
	#if controlled_scene:
		#unload_scene()
	#
	## Load the scene
	#var scene_resource = load(tscn_path)
	#if not scene_resource:
		#push_error("🌟 UniversalBeing: Failed to load scene: " + tscn_path)
		#return false
	#
	## Instantiate the scene
	#controlled_scene = scene_resource.instantiate()
	#if not controlled_scene:
		#push_error("🌟 UniversalBeing: Failed to instantiate scene: " + tscn_path)
		#return false
	#
	## Store scene information
	#scene_path = tscn_path
	#scene_is_loaded = true
	#being_type = "scene"  # Update being type
	#
	## Add scene as child using FloodGate
	#if FloodGateController:
		#FloodGateController.add_being_to_scene(controlled_scene, self, true)
	#else:
		#add_child(controlled_scene)
	#
	## Map all nodes for quick access
	#map_scene_nodes(controlled_scene)
	#
	## Update metadata
	#metadata.modified_at = Time.get_ticks_msec()
	#metadata.scene_path = tscn_path
	#
	#scene_loaded.emit(controlled_scene)
	#print("🌟 UniversalBeing: Scene loaded - %s controls %s" % [being_name, tscn_path])
	#return true

func load_scene(tscn_path: String) -> bool:
	"""Load and control a Godot .tscn scene"""
	if not FileAccess.file_exists(tscn_path):
		push_error("🌟 UniversalBeing: Scene file not found: " + tscn_path)
		return false
	
	# Unload existing scene if any
	if controlled_scene:
		unload_scene()
	
	# Load the scene
	var scene_resource = load(tscn_path)
	if not scene_resource:
		push_error("🌟 UniversalBeing: Failed to load scene: " + tscn_path)
		return false
	
	# Instantiate the scene
	controlled_scene = scene_resource.instantiate()
	if not controlled_scene:
		push_error("🌟 UniversalBeing: Failed to instantiate scene: " + tscn_path)
		return false
	
	# Store scene information
	scene_path = tscn_path
	scene_is_loaded = true
	being_type = "scene"  # Update being type
	
	# Add scene as child directly (Universal Being controls the scene)
	# The scene nodes are NOT Universal Beings, so don't register them with FloodGates
	add_child(controlled_scene)
	
	# Map all nodes for quick access
	map_scene_nodes(controlled_scene)
	
	# Update metadata
	metadata.modified_at = Time.get_ticks_msec()
	metadata.scene_path = tscn_path
	
	scene_loaded.emit(controlled_scene)
	print("🌟 UniversalBeing: Scene loaded - %s controls %s" % [being_name, tscn_path])
	return true


func unload_scene() -> bool:
	"""Unload the currently controlled scene"""
	if not controlled_scene or not scene_is_loaded:
		return false
	
	# Remove scene from tree
	if controlled_scene.get_parent():
		controlled_scene.get_parent().remove_child(controlled_scene)
	
	# Clean up
	controlled_scene.queue_free()
	controlled_scene = null
	scene_path = ""
	scene_is_loaded = false
	scene_nodes.clear()
	scene_properties.clear()
	
	# Update metadata
	metadata.modified_at = Time.get_ticks_msec()
	if metadata.has("scene_path"):
		metadata.erase("scene_path")
	
	scene_unloaded.emit()
	print("🌟 UniversalBeing: Scene unloaded from %s" % being_name)
	return true

func map_scene_nodes(root_node: Node, prefix: String = "") -> void:
	"""Create quick access map of all nodes in the scene"""
	if not root_node:
		return
	
	var node_name = prefix + root_node.name
	scene_nodes[node_name] = root_node
	
	# Recursively map children
	for child in root_node.get_children():
		map_scene_nodes(child, node_name + "/")

func get_scene_node(node_path: String) -> Node:
	"""Get a node from the controlled scene"""
	if not scene_is_loaded or not controlled_scene:
		return null
	
	# Try quick access first
	if node_path in scene_nodes:
		var node = scene_nodes[node_path]
		scene_node_accessed.emit(node_path, node)
		return node
	
	# Try scene tree path
	var node = controlled_scene.get_node_or_null(node_path)
	if node:
		scene_nodes[node_path] = node  # Cache for next time
		scene_node_accessed.emit(node_path, node)
	
	return node

func set_scene_property(node_path: String, property: String, value) -> bool:
	"""Set a property on a scene node"""
	var node = get_scene_node(node_path)
	if not node:
		push_error("🌟 UniversalBeing: Scene node not found: " + node_path)
		return false
	
	if not node.has_method("set") or not node.has_method("get"):
		push_error("🌟 UniversalBeing: Node doesn't support property access: " + node_path)
		return false
	
	# Store old value for tracking
	var old_value = node.get(property) if node.has_method("get") else null
	
	# Set new value
	node.set(property, value)
	
	# Track change
	var prop_key = node_path + "." + property
	scene_properties[prop_key] = {
		"old_value": old_value,
		"new_value": value,
		"timestamp": Time.get_ticks_msec()
	}
	
	metadata.modified_at = Time.get_ticks_msec()
	print("🌟 UniversalBeing: Scene property set - %s.%s = %s" % [node_path, property, str(value)])
	return true

func get_scene_property(node_path: String, property: String):
	"""Get a property from a scene node"""
	var node = get_scene_node(node_path)
	if not node:
		return null
	
	if node.has_method("get"):
		return node.get(property)
	
	return null

func call_scene_method(node_path: String, method: String, args: Array = []):
	"""Call a method on a scene node"""
	var node = get_scene_node(node_path)
	if not node:
		push_error("🌟 UniversalBeing: Scene node not found: " + node_path)
		return null
	
	if not node.has_method(method):
		push_error("🌟 UniversalBeing: Method not found - %s.%s()" % [node_path, method])
		return null
	
	var result = node.callv(method, args)
	print("🌟 UniversalBeing: Scene method called - %s.%s() = %s" % [node_path, method, str(result)])
	return result

func get_scene_info() -> Dictionary:
	"""Get information about the controlled scene"""
	if not scene_is_loaded:
		return {}
	
	return {
		"scene_path": scene_path,
		"scene_loaded": scene_is_loaded,
		"node_count": scene_nodes.size(),
		"property_changes": scene_properties.size(),
		"scene_name": controlled_scene.name if controlled_scene else "",
		"scene_type": controlled_scene.get_class() if controlled_scene else ""
	}

# ===== DEBUG FUNCTIONS =====

func debug_info() -> String:
	"""Get debug information about this being"""
	var info = []
	info.append("=== Universal Being Debug Info ===")
	info.append("UUID: " + being_uuid)
	info.append("Name: " + being_name)
	info.append("Type: " + being_type)
	info.append("Consciousness Level: " + str(consciousness_level))
	info.append("Components: " + str(components.size()))
	info.append("Pentagon Ready: " + str(pentagon_is_ready))
	info.append("AI Accessible: " + str(metadata.ai_accessible))
	
	if components.size() > 0:
		info.append("Loaded Components:")
		for comp in components:
			info.append("  - " + comp)
			
	return "\n".join(info)

func _to_string() -> String:
	return "UniversalBeing<%s:%s>" % [being_type, being_name]
