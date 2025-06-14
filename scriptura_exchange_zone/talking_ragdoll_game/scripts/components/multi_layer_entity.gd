extends UniversalBeingBase
class_name MultiLayerEntity
# Multi-Layer Entity - Exists across multiple reality layers
# Manages different representations of the same entity

signal layer_representation_changed(layer: int)  # Emitted when layer representation updates

# Entity data
@export var entity_id: String = ""
@export var entity_type: String = "generic"

# Layer representations
var text_representation: Dictionary = {}
var map_representation: Dictionary = {}
var debug_representation: Node3D
var full_representation: Node3D

# References
var layer_system: Node
var console_manager: Node

# Movement tracking for debug visualization
var movement_history: PackedVector3Array = []
var max_history_points: int = 50

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	if entity_id.is_empty():
		entity_id = "entity_" + str(get_instance_id())
	
	# Get system references
	layer_system = get_node_or_null("/root/LayerRealitySystem")
	console_manager = get_node_or_null("/root/ConsoleManager")
	
	# Initialize representations
	_create_layer_representations()
	
	# Connect to layer system
	if layer_system:
		layer_system.layer_visibility_changed.connect(_on_layer_visibility_changed)

func _create_layer_representations() -> void:
	# Text representation (Layer 0)
	text_representation = {
		"id": entity_id,
		"type": entity_type,
		"position": global_position,
		"state": "idle",
		"properties": {}
	}
	
	# 2D map representation (Layer 1)
	map_representation = {
		"icon": "●",  # Default circle icon
		"color": Color.WHITE,
		"size": 1.0,
		"height": global_position.y
	}
	
	# Debug representation (Layer 2)
	_create_debug_representation()
	
	# Full 3D representation (Layer 3) - already exists as this node
	full_representation = self

func _create_debug_representation() -> void:
	debug_representation = Node3D.new()
	debug_representation.name = entity_id + "_debug"
	
	# Add to debug layer if system exists
	if layer_system:
		layer_system.add_to_layer(debug_representation, layer_system.Layer.DEBUG_3D)


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	# Update all layer representations
	_update_text_layer()
	_update_map_layer()
	_update_debug_layer()
	
	# Track movement
	if movement_history.is_empty() or global_position.distance_to(movement_history[-1]) > 0.1:
		movement_history.append(global_position)
		if movement_history.size() > max_history_points:
			movement_history.remove_at(0)

func _update_text_layer() -> void:
	if not layer_system or not layer_system.is_layer_visible(layer_system.Layer.TEXT):
		return
	
	text_representation["position"] = global_position
	text_representation["velocity"] = get("velocity") if has_method("get_velocity") else Vector3.ZERO
	
	# Send to console as world text
	if console_manager:
		var text = "%s [%s] @ (%.1f, %.1f, %.1f)" % [
			entity_id,
			text_representation.get("state", "unknown"),
			global_position.x,
			global_position.y,
			global_position.z
		]
		layer_system.add_text_entity(entity_id, text, global_position)

func _update_map_layer() -> void:
	if not layer_system or not layer_system.is_layer_visible(layer_system.Layer.MAP_2D):
		return
	
	# Convert 3D position to 2D map coordinates
	var map_pos = Vector2(global_position.x, global_position.z)
	map_representation["height"] = global_position.y
	
	# Update height-based color
	var height_color = Color.BLUE.lerp(Color.RED, clamp(global_position.y / 10.0, 0.0, 1.0))
	layer_system.update_height_map(map_pos, global_position.y, height_color)

func _update_debug_layer() -> void:
	if not layer_system or not layer_system.is_layer_visible(layer_system.Layer.DEBUG_3D):
		return
	
	# Clear previous debug draw
	layer_system.clear_debug_draw()
	
	# Draw entity position
	layer_system.add_debug_point(global_position, Color.YELLOW, 0.2)
	
	# Draw movement trail
	if movement_history.size() > 1:
		layer_system.add_debug_path(movement_history, Color.GREEN.lerp(Color.TRANSPARENT, 0.5))
	
	# Draw velocity vector if available
	if has_method("get_velocity"):
		var vel = call("get_velocity")
		if vel.length() > 0.1:
			layer_system.add_debug_line(
				global_position,
				global_position + vel.normalized() * 2.0,
				Color.CYAN
			)
	
	# Draw state info
	if has_method("get_current_state"):
		var _state = call("get_current_state")  # Future: display state above entity
		# This would draw state text above entity
		pass

func _on_layer_visibility_changed(layer: int, layer_visible: bool) -> void:
	# React to layer visibility changes
	match layer:
		0: # TEXT
			if layer_visible:
				_update_text_layer()
		1: # MAP_2D
			if layer_visible:
				_update_map_layer()
		2: # DEBUG_3D
			if layer_visible:
				_update_debug_layer()
			else:
				layer_system.clear_debug_draw()
		3: # FULL_3D
			visible = layer_visible  # This node itself
	
	# Emit signal for representation change
	layer_representation_changed.emit(layer)

# API for setting representations

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func set_text_state(state: String) -> void:
	text_representation["state"] = state

func set_map_icon(icon: String, color: Color = Color.WHITE) -> void:
	map_representation["icon"] = icon
	map_representation["color"] = color

func add_debug_marker(offset: Vector3, color: Color, _label: String = "") -> void:
	if layer_system and layer_system.is_layer_visible(layer_system.Layer.DEBUG_3D):
		layer_system.add_debug_point(global_position + offset, color)

# Utility to get representation for a specific layer
func get_layer_representation(layer: int) -> Variant:
	match layer:
		0:
			return text_representation
		1:
			return map_representation
		2:
			return debug_representation
		3:
			return full_representation
		_:
			return null