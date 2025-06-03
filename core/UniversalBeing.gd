# ==================================================
# SCRIPT NAME: UniversalBeing.gd
# DESCRIPTION: The foundation of all consciousness - Core Universal Being class
# PURPOSE: Every single entity in the game extends this - buttons, assets, AI, everything
# CREATED: 2025-06-01 - Universal Being Revolution 
# AUTHOR: JSH + Claude Code + Luminus + Alpha
# ==================================================

extends Node3D
class_name UniversalBeing

# ===== CORE UNIVERSAL BEING PROPERTIES =====

## Universal Being Identity
@export var being_uuid: String = ""
@export var being_name: String = "Unknown Being"
@export var being_type: String = "basic"
@export var consciousness_level: int = 0
@export var visual_layer: int = 0 : set = set_visual_layer

#@export var visual_layer: int = 0 setget set_visual_layer # Universal draw/sort order (see docs: Universal Being Layer System)
# "The visual_layer property controls the draw/sort order of this being in 2D, 3D, and UI. Higher = in front. Never affects visual aspect."

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

## Socket System - Modular Component Architecture
var socket_manager: UniversalBeingSocketManager = null
var socket_hot_swap_enabled: bool = true

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

# ===== CONSCIOUSNESS AURA VISUAL SYSTEM =====

var aura_node: Node2D = null
var aura_animation_timer: float = 0.0

# ===== PHYSICS AND INTERACTION SYSTEM =====

var collision_area: Area3D = null
var collision_shape: CollisionShape3D = null
var proximity_area: Area3D = null
var proximity_shape: CollisionShape3D = null
var interaction_radius: float = 2.0
var physics_enabled: bool = true

# ===== STATE MACHINE SYSTEM =====

enum BeingState {
	DORMANT,        # Not active
	IDLE,           # Active but not doing anything
	THINKING,       # Processing/computing
	MOVING,         # Changing position
	INTERACTING,    # Engaging with other beings
	CREATING,       # Birthing new entities
	EVOLVING,       # Changing form/capabilities
	MERGING,        # Combining with other beings
	SPLITTING,      # Dividing into multiple beings
	TRANSCENDING    # Moving to higher consciousness
}

var current_state: BeingState = BeingState.DORMANT
var state_timer: float = 0.0
var state_history: Array[BeingState] = []
var nearby_beings: Array[UniversalBeing] = []
var interaction_partners: Array[UniversalBeing] = []

# ===== CORE SIGNALS =====

signal consciousness_awakened(level: int)
signal evolution_initiated(from_form: String, to_form: String)
signal evolution_completed(new_being: UniversalBeing)
signal component_added(component_path: String)
signal component_removed(component_path: String)
signal being_destroyed()

# Physics and interaction signals
signal being_entered_proximity(other_being: UniversalBeing)
signal being_exited_proximity(other_being: UniversalBeing)
signal collision_detected(other_being: UniversalBeing)
signal interaction_initiated(other_being: UniversalBeing, interaction_type: String)
signal interaction_completed(other_being: UniversalBeing, result: Dictionary)

# State machine signals
signal state_changed(old_state: BeingState, new_state: BeingState)
signal thinking_started(thought_topic: String)
signal thinking_completed(thought_result: Dictionary)
signal action_initiated(action_type: String, parameters: Dictionary)
signal action_completed(action_type: String, result: Dictionary)
signal scene_loaded(scene_node: Node)
signal scene_unloaded()
signal scene_node_accessed(node_name: String, node: Node)
signal layer_changed(new_layer: int)

# ===== PENTAGON ARCHITECTURE =====

func _init() -> void:
	pentagon_init()

func _ready() -> void:
	if not (self is UniversalBeing):
		push_warning("Node is not a UniversalBeing! All scene elements must extend UniversalBeing.")
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

func pentagon_init() -> void:
	"""Initialize Universal Being core - ALWAYS CALL SUPER FIRST in subclasses"""
	if being_uuid.is_empty():
		being_uuid = generate_uuid()
	metadata.created_at = Time.get_ticks_msec()
	pentagon_initialized = true
	
	# Register with FloodGate system
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates:
			flood_gates.register_being(self)
	
	# Create consciousness visual
	create_consciousness_visual()
	
	# Initialize physics and collision system
	_initialize_physics_system()
	
	# Initialize socket system
	_initialize_socket_system()
	
	# Initialize state machine
	_initialize_state_machine()

func pentagon_ready() -> void:
	"""Ready phase - ALWAYS CALL SUPER FIRST in subclasses"""
	pentagon_is_ready = true
	consciousness_awakened.emit(consciousness_level)
	update_visual_layer_order()

func pentagon_process(delta: float) -> void:
	"""Process phase - ALWAYS CALL SUPER FIRST in subclasses"""
	update_consciousness_visual()
	_update_state_machine(delta)
	_update_physics_interactions()
	_process_proximity_detection()

func pentagon_input(event: InputEvent) -> void:
	"""Input phase - ALWAYS CALL SUPER FIRST in subclasses"""
	pass

func pentagon_sewers() -> void:
	"""Cleanup phase - ALWAYS CALL SUPER LAST in subclasses"""
	being_destroyed.emit()
	
	# Unregister from FloodGate
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates:
			flood_gates.unregister_being(self)
	
	# Cleanup consciousness visual
	if consciousness_visual:
		consciousness_visual.queue_free()

func _attempt_delayed_registration() -> void:
	"""Try to register again when systems are ready"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("register_being"):
			flood_gates.register_being(self)
			metadata.floodgate_registered = true

# ===== CONSCIOUSNESS VISUAL SYSTEM =====

class AuraNode2D extends Node2D:
	var aura_color: Color = Color.WHITE
	var aura_radius: float = 32.0
	var aura_opacity: float = 0.3
	func _draw() -> void:
		var color_with_alpha = aura_color
		color_with_alpha.a = aura_opacity
		draw_circle(Vector2.ZERO, aura_radius, color_with_alpha)

func create_consciousness_visual() -> void:
	if aura_node:
		aura_node.queue_free()
	aura_node = AuraNode2D.new()
	aura_node.name = "ConsciousnessAura"
	add_child(aura_node)
	_update_aura_visual()
	print("🧠 %s: Animated consciousness aura created (level %d)" % [being_name, consciousness_level])
	log_action("visual_update", "🧠 %s: Aura visual created for consciousness level %d" % [being_name, consciousness_level])

func update_consciousness_visual() -> void:
	aura_animation_timer += get_process_delta_time()
	_update_aura_visual()

func _update_aura_visual() -> void:
	if not aura_node:
		return
	var aura_color = _get_consciousness_color()
	var pulse = 0.7 + 0.3 * sin(aura_animation_timer * (1.0 + consciousness_level))
	var socket_count = 0
	if socket_manager:
		socket_count = socket_manager.sockets.size()
	var aura_radius = 32 + 8 * consciousness_level + 4 * socket_count
	var aura_opacity = 0.3 + 0.1 * consciousness_level
	aura_node.aura_color = aura_color
	aura_node.aura_radius = aura_radius * pulse
	aura_node.aura_opacity = aura_opacity
	aura_node.queue_redraw()

func _get_consciousness_color() -> Color:
	"""Get color for consciousness level"""
	match consciousness_level:
		0: return Color(0.7451, 0.7451, 0.7451, 1.0)  # Gray - Dormant
		1: return Color(1.0, 1.0, 1.0, 1.0)           # White - Awakening  
		2: return Color(0.0, 1.0, 1.0, 1.0)           # Cyan - Aware
		3: return Color(0.0, 1.0, 0.0, 1.0)           # Green - Connected
		4: return Color(1.0, 1.0, 0.0, 1.0)           # Yellow - Enlightened
		5: return Color(1.0, 0.0, 1.0, 1.0)           # Magenta - Transcendent
		6: return Color(1.0, 0.0, 0.0, 1.0)           # Red - Beyond
		7: return Color(1.0, 1.0, 1.0, 1.0)           # Pure White - Ultimate
		_: return Color.WHITE

# ===== UTILITY METHODS =====

func generate_uuid() -> String:
	"""Generate a unique ID for this being"""
	return "ub_%d_%d" % [Time.get_ticks_msec(), randi()]

# ===== SOCKET SYSTEM =====

func _initialize_socket_system() -> void:
	"""Initialize the modular socket system"""
	socket_manager = UniversalBeingSocketManager.new(self)
	
	# Connect socket signals
	socket_manager.component_mounted.connect(_on_socket_component_mounted)
	socket_manager.component_unmounted.connect(_on_socket_component_unmounted)
	socket_manager.socket_configuration_changed.connect(_on_socket_configuration_changed)
	
	print("🔌 Socket system initialized for %s with %d sockets" % [being_name, socket_manager.sockets.size()])

func get_socket(socket_id: String) -> UniversalBeingSocket:
	"""Get socket by ID"""
	if not socket_manager:
		return null
	return socket_manager.get_socket(socket_id)

func get_sockets_by_type(socket_type: UniversalBeingSocket.SocketType) -> Array[UniversalBeingSocket]:
	"""Get all sockets of specific type"""
	if not socket_manager:
		return []
	return socket_manager.get_sockets_by_type(socket_type)

func mount_component(socket_id: String, component: Resource, force: bool = false) -> bool:
	"""Mount component to socket"""
	if not socket_manager:
		push_error("Socket system not initialized")
		return false
	return socket_manager.mount_component_to_socket(socket_id, component, force)

func mount_component_by_type(socket_type: UniversalBeingSocket.SocketType, component: Resource, socket_name: String = "") -> bool:
	"""Mount component to first available socket of type"""
	if not socket_manager:
		push_error("Socket system not initialized")
		return false
	return socket_manager.mount_component_by_type(socket_type, component, socket_name)

func unmount_component(socket_id: String) -> bool:
	"""Unmount component from socket"""
	if not socket_manager:
		return false
	return socket_manager.unmount_component_from_socket(socket_id)

func hot_swap_component(socket_id: String, new_component: Resource) -> bool:
	"""Hot-swap component in socket"""
	if not socket_manager or not socket_hot_swap_enabled:
		return false
	return socket_manager.hot_swap_component(socket_id, new_component)

func get_socket_configuration() -> Dictionary:
	"""Get complete socket configuration"""
	if not socket_manager:
		return {}
	return socket_manager.get_socket_configuration()

func get_inspector_data() -> Dictionary:
	"""Get data for inspector/editor interface"""
	if not socket_manager:
		return {"error": "Socket system not initialized"}
	return socket_manager.get_inspector_data()

# ===== SOCKET SIGNAL HANDLERS =====

func _on_socket_component_mounted(socket: UniversalBeingSocket, component: Resource) -> void:
	"""Handle component mounted to socket"""
	print("🔌 Component mounted: %s -> %s" % [component.get_class(), socket.socket_name])
	
	# Apply component based on socket type
	match socket.socket_type:
		UniversalBeingSocket.SocketType.VISUAL:
			_apply_visual_component(socket, component)
		UniversalBeingSocket.SocketType.SCRIPT:
			_apply_script_component(socket, component)
		UniversalBeingSocket.SocketType.SHADER:
			_apply_shader_component(socket, component)
		UniversalBeingSocket.SocketType.ACTION:
			_apply_action_component(socket, component)
		UniversalBeingSocket.SocketType.MEMORY:
			_apply_memory_component(socket, component)
		UniversalBeingSocket.SocketType.INTERFACE:
			_apply_interface_component(socket, component)

func _on_socket_component_unmounted(socket: UniversalBeingSocket, component: Resource) -> void:
	"""Handle component unmounted from socket"""
	print("🔌 Component unmounted: %s <- %s" % [component.get_class(), socket.socket_name])
	
	# Remove component effects based on socket type
	match socket.socket_type:
		UniversalBeingSocket.SocketType.VISUAL:
			_remove_visual_component(socket, component)
		UniversalBeingSocket.SocketType.SCRIPT:
			_remove_script_component(socket, component)
		UniversalBeingSocket.SocketType.SHADER:
			_remove_shader_component(socket, component)
		UniversalBeingSocket.SocketType.ACTION:
			_remove_action_component(socket, component)
		UniversalBeingSocket.SocketType.MEMORY:
			_remove_memory_component(socket, component)
		UniversalBeingSocket.SocketType.INTERFACE:
			_remove_interface_component(socket, component)

func _on_socket_configuration_changed() -> void:
	"""Handle socket configuration changes"""
	# Update visual representation
	update_consciousness_visual()
	
	# Notify inspector if connected
	if has_signal("socket_configuration_changed"):
		emit_signal("socket_configuration_changed")

func _on_socket_hot_swapped(socket: UniversalBeingSocket, new_component: Resource) -> void:
	"""Handle hot-swap completion"""
	print("🔄 Hot-swap completed: %s in %s socket" % [new_component.get_class(), socket.socket_name])
	
	# Refresh being state
	_refresh_being_state()

# ===== COMPONENT APPLICATION METHODS =====

func _apply_visual_component(socket: UniversalBeingSocket, component: Resource) -> void:
	"""Apply visual component to being"""
	# Override in subclasses for specific visual handling
	if component.has_method("apply_to_being"):
		component.apply_to_being(self)

func _apply_script_component(socket: UniversalBeingSocket, component: Resource) -> void:
	"""Apply script component to being"""
	# Override in subclasses for specific script handling
	if component.has_method("attach_to_being"):
		component.attach_to_being(self)

func _apply_shader_component(socket: UniversalBeingSocket, component: Resource) -> void:
	"""Apply shader component to being"""
	# Override in subclasses for specific shader handling
	if component is Material:
		# Apply material to visual nodes
		pass

func _apply_action_component(socket: UniversalBeingSocket, component: Resource) -> void:
	"""Apply action component to being"""
	# Override in subclasses for specific action handling
	if component.has_method("register_actions"):
		component.register_actions(self)

func _apply_memory_component(socket: UniversalBeingSocket, component: Resource) -> void:
	"""Apply memory component to being"""
	# Override in subclasses for specific memory handling
	if component.has_method("initialize_memory"):
		component.initialize_memory(self)

func _apply_interface_component(socket: UniversalBeingSocket, component: Resource) -> void:
	"""Apply interface component to being"""
	# Override in subclasses for specific interface handling
	if component.has_method("create_interface"):
		component.create_interface(self)

# ===== COMPONENT REMOVAL METHODS =====

func _remove_visual_component(socket: UniversalBeingSocket, component: Resource) -> void:
	"""Remove visual component effects"""
	if component.has_method("remove_from_being"):
		component.remove_from_being(self)

func _remove_script_component(socket: UniversalBeingSocket, component: Resource) -> void:
	"""Remove script component effects"""
	if component.has_method("detach_from_being"):
		component.detach_from_being(self)

func _remove_shader_component(socket: UniversalBeingSocket, component: Resource) -> void:
	"""Remove shader component effects"""
	# Reset materials to default
	pass

func _remove_action_component(socket: UniversalBeingSocket, component: Resource) -> void:
	"""Remove action component effects"""
	if component.has_method("unregister_actions"):
		component.unregister_actions(self)

func _remove_memory_component(socket: UniversalBeingSocket, component: Resource) -> void:
	"""Remove memory component effects"""
	if component.has_method("cleanup_memory"):
		component.cleanup_memory(self)

func _remove_interface_component(socket: UniversalBeingSocket, component: Resource) -> void:
	"""Remove interface component effects"""
	if component.has_method("destroy_interface"):
		component.destroy_interface(self)

# ===== UTILITY METHODS =====

func _refresh_being_state() -> void:
	"""Refresh being state after socket changes"""
	# Update consciousness visual
	update_consciousness_visual()
	
	# Refresh scene if loaded
	if scene_is_loaded and controlled_scene:
		# Trigger scene refresh
		pass

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
	
	# If this is an interaction component, load it directly as a node
	if component_path.contains("basic_interaction"):
		_load_basic_interaction_component()
	
	print("🔧 Applied component data: %s" % component_path.get_file())

func _load_basic_interaction_component() -> void:
	"""Load basic interaction component as an actual node"""
	# Check if already loaded
	var existing = get_node_or_null("BasicInteractionComponent")
	if existing:
		print("🎯 Basic interaction component already loaded")
		return
	
	# Load the script and create instance
	var component_script = load("res://components/basic_interaction.ub.zip/basic_interaction.gd")
	if not component_script:
		push_error("❌ Cannot load basic_interaction.gd script")
		return
	
	# Create component instance
	var component = component_script.new()
	component.name = "BasicInteractionComponent"
	add_child(component)
	
	# Apply component to this being
	if component.has_method("apply_to_being"):
		component.apply_to_being(self)
	
	print("🎯 Basic interaction component loaded and applied to: %s" % being_name)

# ===== EVOLUTION SYSTEM =====

func can_evolve_to(new_form: String) -> bool:
	return new_form in evolution_state.can_become

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

# ===== AKASHIC LOGGING INTERFACE =====

func log_action(event_type: String, message: String = "", data: Dictionary = {}) -> void:
	if component_data.has("akashic_logger"):
		component_data.akashic_logger.log_action(event_type, message, data)
	else:
		push_error("AkashicLoggerComponent not found on this being!")

func set_visual_layer(value: int) -> void:
	visual_layer = value
	update_visual_layer_order()
	emit_signal("layer_changed", visual_layer)

func update_visual_layer_order() -> void:
	"""Update draw/sort order for this being based on visual_layer (2D: z_index, 3D: custom, UI: CanvasLayer/Control)"""
	# Handle visual layer for different node types
	# Note: UniversalBeing extends Node3D, so we need special handling for UI elements
	
	# Check if we have UI children that need layer management
	_update_child_ui_layers()
	
	# For Node3D (which UniversalBeing extends), we can use position.z or custom sorting
	if self is Node3D:
		# For 3D beings, we can adjust the z position slightly for layering
		# This is a subtle effect - higher layer = slightly forward in 3D space
		var layer_offset = visual_layer * 0.01  # Small offset to avoid major position changes
		if abs(position.z - layer_offset) > 0.001:  # Avoid unnecessary updates
			position.z = layer_offset
			
	# Log layer change to Akashic Library
	_log_layer_change_to_akashic()

func _update_child_ui_layers() -> void:
	"""Update visual layers for any UI children (Control, CanvasLayer nodes)"""
	for child in get_children():
		if child is Control:
			# Type-safe handling of Control nodes
			if child.has_method("get_visual_layer"):
				# If child has visual layer method, respect it
				var child_layer = child.call("get_visual_layer")
				_move_control_to_layer(child, child_layer)
			else:
				# Use parent's visual layer
				_move_control_to_layer(child, visual_layer)
		elif child is CanvasLayer:
			# Type-safe handling of CanvasLayer nodes
			child.layer = visual_layer

func _move_control_to_layer(control_node: Node, layer: int) -> void:
	"""Move a Control node to the appropriate layer"""
	if not control_node or not control_node.get_parent():
		return
	
	# Ensure we're actually working with a Control node
	if not control_node is Control:
		return
	
	# Type-safe operations for Control node ordering
	var siblings_with_layers = []
	
	for sibling in control_node.get_parent().get_children():
		if sibling != control_node and sibling is Control and sibling.has_method("get_visual_layer"):
			var sibling_layer = sibling.call("get_visual_layer")
			siblings_with_layers.append({"node": sibling, "layer": sibling_layer})
	
	# Sort siblings by layer
	siblings_with_layers.sort_custom(func(a, b): return a.layer < b.layer)
	
	# Find where this control should be positioned
	var target_index = control_node.get_index()
	for i in range(siblings_with_layers.size()):
		if siblings_with_layers[i].layer > layer:
			target_index = siblings_with_layers[i].node.get_index()
			break
		else:
			target_index = siblings_with_layers[i].node.get_index() + 1
	
	# Move to correct position if needed
	if target_index != control_node.get_index():
		control_node.get_parent().move_child(control_node, target_index)

func get_visual_layer() -> int:
	return visual_layer


func _log_layer_change_to_akashic() -> void:
	"""Log layer changes to the Akashic Library in poetic style"""
	if not SystemBootstrap or not SystemBootstrap.is_system_ready():
		return
		
	var akashic = SystemBootstrap.get_akashic_library()
	if akashic:
		var poetic_message = "🌟 The %s shifted through the dimensional layers, ascending to stratum %d of existence..." % [being_name, visual_layer]
		akashic.log_universe_event("layer_change", poetic_message, {
			"being_uuid": being_uuid,
			"being_name": being_name,
			"new_layer": visual_layer,
			"timestamp": Time.get_ticks_msec()
		})

# ===== PHYSICS AND COLLISION SYSTEM =====

func _initialize_physics_system() -> void:
	"""Initialize collision and proximity detection systems"""
	if not physics_enabled:
		return
	
	# Create main collision area for direct interactions
	collision_area = Area3D.new()
	collision_area.name = "CollisionArea"
	collision_area.collision_layer = 1
	collision_area.collision_mask = 1
	add_child(collision_area)
	
	# Create collision shape
	collision_shape = CollisionShape3D.new()
	collision_shape.name = "CollisionShape"
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 0.5  # Base collision radius
	collision_shape.shape = sphere_shape
	collision_area.add_child(collision_shape)
	
	# Create proximity detection area (larger radius)
	proximity_area = Area3D.new()
	proximity_area.name = "ProximityArea"
	proximity_area.collision_layer = 2
	proximity_area.collision_mask = 2
	add_child(proximity_area)
	
	# Create proximity shape
	proximity_shape = CollisionShape3D.new()
	proximity_shape.name = "ProximityShape"
	var proximity_sphere = SphereShape3D.new()
	proximity_sphere.radius = interaction_radius
	proximity_shape.shape = proximity_sphere
	proximity_area.add_child(proximity_shape)
	
	# Connect signals
	collision_area.body_entered.connect(_on_collision_entered)
	collision_area.body_exited.connect(_on_collision_exited)
	collision_area.area_entered.connect(_on_area_collision_entered)
	collision_area.area_exited.connect(_on_area_collision_exited)
	
	proximity_area.area_entered.connect(_on_proximity_entered)
	proximity_area.area_exited.connect(_on_proximity_exited)
	
	print("⚡ Physics system initialized for %s with collision and proximity detection" % being_name)

func _update_physics_interactions() -> void:
	"""Update physics-based interactions"""
	if not physics_enabled or not collision_area:
		return
	
	# Update collision radius based on consciousness level
	var base_radius = 0.5
	var consciousness_multiplier = 1.0 + (consciousness_level * 0.2)
	var new_radius = base_radius * consciousness_multiplier
	
	if collision_shape and collision_shape.shape:
		collision_shape.shape.radius = new_radius
	
	# Update proximity radius
	var proximity_multiplier = 1.0 + (consciousness_level * 0.5)
	interaction_radius = 2.0 * proximity_multiplier
	
	if proximity_shape and proximity_shape.shape:
		proximity_shape.shape.radius = interaction_radius

func _process_proximity_detection() -> void:
	"""Process proximity-based interactions"""
	for being in nearby_beings:
		if not is_instance_valid(being):
			nearby_beings.erase(being)
			continue
		
		var distance = global_position.distance_to(being.global_position)
		var consciousness_resonance = _calculate_consciousness_resonance(being)
		
		# Check for automatic interactions based on consciousness levels
		if consciousness_resonance > 0.8 and distance < interaction_radius * 0.5:
			_initiate_consciousness_interaction(being)

func _calculate_consciousness_resonance(other_being: UniversalBeing) -> float:
	"""Calculate consciousness resonance between beings"""
	if not other_being:
		return 0.0
	
	var level_difference = abs(consciousness_level - other_being.consciousness_level)
	var max_difference = 7.0  # Maximum consciousness levels
	
	# Higher resonance for similar consciousness levels
	var base_resonance = 1.0 - (level_difference / max_difference)
	
	# Bonus for beings in creative or transcendent states
	var state_bonus = 0.0
	if current_state in [BeingState.CREATING, BeingState.TRANSCENDING]:
		state_bonus += 0.2
	if other_being.current_state in [BeingState.CREATING, BeingState.TRANSCENDING]:
		state_bonus += 0.2
	
	return clamp(base_resonance + state_bonus, 0.0, 1.0)

# ===== COLLISION SIGNAL HANDLERS =====

func _on_collision_entered(body: Node3D) -> void:
	"""Handle collision with another body"""
	var other_being = _find_universal_being_in_node(body)
	if other_being and other_being != self:
		collision_detected.emit(other_being)
		_handle_collision_interaction(other_being)

func _on_collision_exited(body: Node3D) -> void:
	"""Handle collision exit"""
	pass  # Could implement separation effects here

func _on_area_collision_entered(area: Area3D) -> void:
	"""Handle collision with another area"""
	var other_being = _find_universal_being_in_node(area)
	if other_being and other_being != self:
		collision_detected.emit(other_being)
		_handle_collision_interaction(other_being)

func _on_area_collision_exited(area: Area3D) -> void:
	"""Handle area collision exit"""
	pass

func _on_proximity_entered(area: Area3D) -> void:
	"""Handle proximity detection"""
	var other_being = _find_universal_being_in_node(area)
	if other_being and other_being != self and other_being not in nearby_beings:
		nearby_beings.append(other_being)
		being_entered_proximity.emit(other_being)
		_handle_proximity_interaction(other_being)

func _on_proximity_exited(area: Area3D) -> void:
	"""Handle proximity exit"""
	var other_being = _find_universal_being_in_node(area)
	if other_being and other_being in nearby_beings:
		nearby_beings.erase(other_being)
		being_exited_proximity.emit(other_being)

func _find_universal_being_in_node(node: Node) -> UniversalBeing:
	"""Find UniversalBeing in a node hierarchy"""
	var current = node
	while current:
		if current is UniversalBeing:
			return current
		current = current.get_parent()
	return null

# ===== STATE MACHINE SYSTEM =====

func _initialize_state_machine() -> void:
	"""Initialize the Universal Being state machine"""
	current_state = BeingState.IDLE
	state_timer = 0.0
	state_history.clear()
	
	# Connect state change signal to log changes
	state_changed.connect(_on_state_changed)
	
	print("🧠 State machine initialized for %s in %s state" % [being_name, _state_to_string(current_state)])

func _update_state_machine(delta: float) -> void:
	"""Update the state machine"""
	state_timer += delta
	
	# State-specific behavior
	match current_state:
		BeingState.DORMANT:
			_process_dormant_state(delta)
		BeingState.IDLE:
			_process_idle_state(delta)
		BeingState.THINKING:
			_process_thinking_state(delta)
		BeingState.MOVING:
			_process_moving_state(delta)
		BeingState.INTERACTING:
			_process_interacting_state(delta)
		BeingState.CREATING:
			_process_creating_state(delta)
		BeingState.EVOLVING:
			_process_evolving_state(delta)
		BeingState.MERGING:
			_process_merging_state(delta)
		BeingState.SPLITTING:
			_process_splitting_state(delta)
		BeingState.TRANSCENDING:
			_process_transcending_state(delta)

func change_state(new_state: BeingState, reason: String = "") -> void:
	"""Change the current state"""
	if new_state == current_state:
		return
	
	var old_state = current_state
	state_history.append(old_state)
	
	# Keep history manageable
	if state_history.size() > 10:
		state_history.pop_front()
	
	current_state = new_state
	state_timer = 0.0
	
	state_changed.emit(old_state, new_state)
	log_action("state_change", "State changed from %s to %s%s" % [
		_state_to_string(old_state), 
		_state_to_string(new_state),
		(" - " + reason) if not reason.is_empty() else ""
	])

func _state_to_string(state: BeingState) -> String:
	"""Convert state enum to string"""
	match state:
		BeingState.DORMANT: return "DORMANT"
		BeingState.IDLE: return "IDLE"
		BeingState.THINKING: return "THINKING"
		BeingState.MOVING: return "MOVING"
		BeingState.INTERACTING: return "INTERACTING"
		BeingState.CREATING: return "CREATING"
		BeingState.EVOLVING: return "EVOLVING"
		BeingState.MERGING: return "MERGING"
		BeingState.SPLITTING: return "SPLITTING"
		BeingState.TRANSCENDING: return "TRANSCENDING"
		_: return "UNKNOWN"

func _on_state_changed(old_state: BeingState, new_state: BeingState) -> void:
	"""Handle state changes"""
	print("🧠 %s: %s → %s" % [being_name, _state_to_string(old_state), _state_to_string(new_state)])

# ===== STATE PROCESSING METHODS =====

func _process_dormant_state(delta: float) -> void:
	"""Process dormant state - minimal activity"""
	if consciousness_level > 0:
		change_state(BeingState.IDLE, "consciousness activated")

func _process_idle_state(delta: float) -> void:
	"""Process idle state - waiting for stimulation"""
	# Random chance to start thinking
	if randf() < 0.01:  # 1% chance per frame
		change_state(BeingState.THINKING, "spontaneous thought")
	
	# Check if nearby beings should trigger interaction
	if not nearby_beings.is_empty() and randf() < 0.005:
		change_state(BeingState.INTERACTING, "proximity triggered")

func _process_thinking_state(delta: float) -> void:
	"""Process thinking state - consciousness processing"""
	if state_timer > 2.0:  # Think for 2 seconds
		var thought_result = _generate_thought_result()
		thinking_completed.emit(thought_result)
		
		# Decide next action based on thought
		if thought_result.get("should_create", false):
			change_state(BeingState.CREATING, "inspired to create")
		elif thought_result.get("should_evolve", false):
			change_state(BeingState.EVOLVING, "evolution insight")
		else:
			change_state(BeingState.IDLE, "thought completed")

func _process_moving_state(delta: float) -> void:
	"""Process moving state"""
	# Simple movement logic
	if state_timer > 3.0:
		change_state(BeingState.IDLE, "movement completed")

func _process_interacting_state(delta: float) -> void:
	"""Process interaction state"""
	if interaction_partners.is_empty():
		change_state(BeingState.IDLE, "no interaction partners")
		return
	
	# Process interactions
	for partner in interaction_partners:
		if is_instance_valid(partner):
			_process_interaction_with(partner)
	
	if state_timer > 5.0:
		change_state(BeingState.IDLE, "interaction completed")

func _process_creating_state(delta: float) -> void:
	"""Process creation state - birthing new entities"""
	if state_timer > 3.0:
		_attempt_creation()
		change_state(BeingState.IDLE, "creation completed")

func _process_evolving_state(delta: float) -> void:
	"""Process evolution state"""
	if state_timer > 4.0:
		_attempt_evolution()
		change_state(BeingState.IDLE, "evolution completed")

func _process_merging_state(delta: float) -> void:
	"""Process merging state"""
	if state_timer > 2.0:
		_attempt_merge()
		change_state(BeingState.IDLE, "merge attempted")

func _process_splitting_state(delta: float) -> void:
	"""Process splitting state"""
	if state_timer > 3.0:
		_attempt_split()
		change_state(BeingState.IDLE, "split completed")

func _process_transcending_state(delta: float) -> void:
	"""Process transcending state"""
	if state_timer > 5.0:
		consciousness_level = min(consciousness_level + 1, 7)
		change_state(BeingState.IDLE, "transcendence achieved")

# ===== INTERACTION METHODS =====

func _handle_collision_interaction(other_being: UniversalBeing) -> void:
	"""Handle direct collision with another being"""
	var interaction_type = _determine_interaction_type(other_being)
	interaction_initiated.emit(other_being, interaction_type)
	
	match interaction_type:
		"merge":
			if consciousness_level >= 3 and other_being.consciousness_level >= 3:
				_initiate_merge(other_being)
		"consciousness_transfer":
			_transfer_consciousness(other_being)
		"evolution_trigger":
			change_state(BeingState.EVOLVING, "collision triggered evolution")

func _handle_proximity_interaction(other_being: UniversalBeing) -> void:
	"""Handle proximity-based interaction"""
	var resonance = _calculate_consciousness_resonance(other_being)
	
	if resonance > 0.7:
		if not other_being in interaction_partners:
			interaction_partners.append(other_being)
		
		if current_state == BeingState.IDLE:
			change_state(BeingState.INTERACTING, "high consciousness resonance")

func _initiate_consciousness_interaction(other_being: UniversalBeing) -> void:
	"""Initiate consciousness-based interaction"""
	if current_state in [BeingState.IDLE, BeingState.THINKING]:
		change_state(BeingState.INTERACTING, "consciousness interaction")
		if not other_being in interaction_partners:
			interaction_partners.append(other_being)

func _determine_interaction_type(other_being: UniversalBeing) -> String:
	"""Determine what type of interaction should occur"""
	var level_sum = consciousness_level + other_being.consciousness_level
	var level_diff = abs(consciousness_level - other_being.consciousness_level)
	
	if level_sum >= 10:
		return "transcendence_catalyst"
	elif level_diff <= 1 and consciousness_level >= 4:
		return "merge"
	elif level_diff >= 3:
		return "consciousness_transfer"
	else:
		return "resonance_sharing"

# ===== CREATION AND EVOLUTION METHODS =====

func _generate_thought_result() -> Dictionary:
	"""Generate result of thinking process"""
	var result = {
		"topic": "existence",
		"duration": state_timer,
		"consciousness_used": consciousness_level,
		"should_create": false,
		"should_evolve": false
	}
	
	# Higher consciousness beings more likely to create/evolve
	if consciousness_level >= 3:
		result.should_create = randf() < 0.3
	if consciousness_level >= 5:
		result.should_evolve = randf() < 0.2
	
	return result

func _attempt_creation() -> void:
	"""Attempt to create a new being"""
	if consciousness_level < 2:
		return
	
	print("🌟 %s attempting creation..." % being_name)
	action_initiated.emit("creation", {"parent": being_uuid})
	
	# Create a simple offspring being
	var offspring = UniversalBeing.new()
	offspring.being_name = being_name + "_Offspring"
	offspring.being_type = being_type + "_child"
	offspring.consciousness_level = max(1, consciousness_level - 1)
	offspring.position = position + Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))
	
	get_parent().add_child(offspring)
	
	action_completed.emit("creation", {"offspring": offspring.being_uuid})
	log_action("creation", "Created offspring: %s" % offspring.being_name)

func _attempt_evolution() -> void:
	"""Attempt to evolve to a higher form"""
	print("🦋 %s attempting evolution..." % being_name)
	action_initiated.emit("evolution", {"current_level": consciousness_level})
	
	# Increase consciousness with small chance
	if randf() < 0.5:
		consciousness_level = min(consciousness_level + 1, 7)
		evolution_initiated.emit(being_type, being_type + "_evolved")
		log_action("evolution", "Evolved to consciousness level %d" % consciousness_level)
	
	action_completed.emit("evolution", {"new_level": consciousness_level})

func _initiate_merge(other_being: UniversalBeing) -> void:
	"""Initiate merging with another being"""
	if other_being.current_state == BeingState.MERGING:
		return  # Already merging
	
	change_state(BeingState.MERGING, "initiated merge")
	other_being.change_state(BeingState.MERGING, "merge partner")

func _attempt_merge() -> void:
	"""Attempt to merge with nearby beings"""
	var merge_candidates = []
	for being in nearby_beings:
		if being.current_state == BeingState.MERGING and being != self:
			merge_candidates.append(being)
	
	if not merge_candidates.is_empty():
		var partner = merge_candidates[0]
		_complete_merge(partner)

func _complete_merge(other_being: UniversalBeing) -> void:
	"""Complete merge with another being"""
	print("🌊 %s merging with %s" % [being_name, other_being.being_name])
	
	# Combine consciousness levels
	var new_level = min((consciousness_level + other_being.consciousness_level) / 2 + 1, 7)
	consciousness_level = new_level
	
	# Remove the other being
	other_being.queue_free()
	
	log_action("merge", "Merged with %s, new consciousness: %d" % [other_being.being_name, consciousness_level])

func _attempt_split() -> void:
	"""Attempt to split into multiple beings"""
	if consciousness_level < 4:
		return
	
	print("✂️ %s attempting split..." % being_name)
	
	# Create two smaller beings
	for i in range(2):
		var split_being = UniversalBeing.new()
		split_being.being_name = being_name + "_Split_%d" % (i + 1)
		split_being.being_type = being_type
		split_being.consciousness_level = max(1, consciousness_level - 2)
		split_being.position = position + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
		
		get_parent().add_child(split_being)
	
	# Reduce own consciousness
	consciousness_level = max(1, consciousness_level - 1)
	log_action("split", "Split into multiple beings")

func _transfer_consciousness(other_being: UniversalBeing) -> void:
	"""Transfer consciousness between beings"""
	if consciousness_level > other_being.consciousness_level:
		var transfer_amount = min(1, consciousness_level - other_being.consciousness_level)
		consciousness_level -= transfer_amount
		other_being.consciousness_level += transfer_amount
		
		log_action("consciousness_transfer", "Transferred %d consciousness to %s" % [transfer_amount, other_being.being_name])

func _process_interaction_with(partner: UniversalBeing) -> void:
	"""Process ongoing interaction with a partner"""
	var resonance = _calculate_consciousness_resonance(partner)
	
	if resonance > 0.9:
		# High resonance can trigger evolution
		if randf() < 0.1:
			change_state(BeingState.EVOLVING, "resonance evolution")
	elif resonance > 0.5:
		# Medium resonance shares consciousness
		_transfer_consciousness(partner)
