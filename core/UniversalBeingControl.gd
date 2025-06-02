# ==================================================
# SCRIPT NAME: UniversalBeingControl.gd
# DESCRIPTION: Control-based Universal Being for UI elements
# PURPOSE: Type-safe UI Universal Being that properly handles layer management
# CREATED: 2025-06-03 - Layer System Evolution
# AUTHOR: Claude Code
# ==================================================

extends Control
class_name UniversalBeingControl

# Import core Universal Being functionality
var _universal_being_core = preload("res://core/UniversalBeing.gd")

# Universal Being properties
var being_uuid: String = ""
var being_name: String = "Control Universal Being"
var being_type: String = "ui_control"
var consciousness_level: int = 0
var visual_layer: int = 0

# Component system
var component_data: Dictionary = {}
var socket_manager = null

# Pentagon Architecture support
var pentagon_initialized: bool = false

# Signals (match UniversalBeing)
signal layer_changed(new_layer: int)
signal consciousness_changed(new_level: int)
signal being_evolved(from_form: String, to_form: String)

func _ready() -> void:
	"""Initialize Control Universal Being"""
	# Generate UUID
	being_uuid = _generate_uuid()
	
	# Initialize Pentagon
	pentagon_init()
	pentagon_ready()
	
	# Register with FloodGates
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates:
			flood_gates.register_being(self, being_uuid)

func pentagon_init() -> void:
	"""Pentagon initialization phase"""
	pentagon_initialized = true
	print("🎮 %s: Pentagon initialized (Control Being)" % being_name)

func pentagon_ready() -> void:
	"""Pentagon ready phase"""
	print("🎮 %s: Pentagon ready (Control Being)" % being_name)

func pentagon_process(delta: float) -> void:
	"""Pentagon process phase"""
	pass

func pentagon_input(event: InputEvent) -> void:
	"""Pentagon input phase"""
	pass

func pentagon_sewers() -> void:
	"""Pentagon cleanup phase"""
	print("🎮 %s: Pentagon sewers (Control Being cleanup)" % being_name)

func set_visual_layer(value: int) -> void:
	"""Set visual layer for proper UI ordering"""
	visual_layer = value
	update_visual_layer_order()
	emit_signal("layer_changed", visual_layer)

func update_visual_layer_order() -> void:
	"""Update Control draw order based on visual_layer"""
	# For Control nodes, we need to reorder among siblings
	var parent = get_parent()
	if not parent:
		return
	
	# Find our proper position based on layer
	var siblings = parent.get_children()
	var our_index = get_index()
	var target_index = our_index
	
	# Calculate where we should be
	for i in range(siblings.size()):
		var sibling = siblings[i]
		if sibling == self:
			continue
			
		if sibling.has_method("get_visual_layer"):
			var sibling_layer = sibling.get_visual_layer()
			if sibling_layer > visual_layer and i < target_index:
				target_index = i
			elif sibling_layer <= visual_layer and i > target_index:
				target_index = i + 1
	
	# Move to correct position if needed
	if target_index != our_index:
		parent.move_child(self, target_index)

func get_visual_layer() -> int:
	"""Get current visual layer"""
	return visual_layer

func set_consciousness_level(level: int) -> void:
	"""Set consciousness level"""
	consciousness_level = clamp(level, 0, 7)
	emit_signal("consciousness_changed", consciousness_level)
	_update_visual_consciousness()

func _update_visual_consciousness() -> void:
	"""Update visual appearance based on consciousness"""
	# Control-specific consciousness visualization
	# Could change modulate color, add glow effect, etc.
	var consciousness_colors = [
		Color(0.7451, 0.7451, 0.7451, 1.0),  # Level 0: Gray - Dormant
		Color(1.0, 1.0, 1.0, 1.0),           # Level 1: White - Awakening
		Color(0.0, 1.0, 1.0, 1.0),           # Level 2: Cyan - Aware
		Color(0.0, 1.0, 0.0, 1.0),           # Level 3: Green - Connected
		Color(1.0, 1.0, 0.0, 1.0),           # Level 4: Yellow - Enlightened
		Color(1.0, 0.0, 1.0, 1.0),           # Level 5: Magenta - Transcendent
		Color(1.0, 0.0, 0.0, 1.0),           # Level 6: Red - Beyond
		Color(1.0, 1.0, 1.0, 1.0)            # Level 7: Pure - Ultimate
	]
	
	if consciousness_level < consciousness_colors.size():
		modulate = consciousness_colors[consciousness_level]

func add_component(component_path: String) -> bool:
	"""Add a component to this Control being"""
	# TODO: Implement component loading for Control beings
	print("🎮 %s: Component system not yet implemented for Control beings" % being_name)
	return false

func ai_interface() -> Dictionary:
	"""AI interface for Control beings"""
	return {
		"being_uuid": being_uuid,
		"being_name": being_name,
		"being_type": being_type,
		"consciousness_level": consciousness_level,
		"visual_layer": visual_layer,
		"position": global_position,
		"size": size,
		"visible": visible,
		"modulate": modulate
	}

func _generate_uuid() -> String:
	"""Generate a unique UUID"""
	var time = Time.get_ticks_msec()
	var random_value = randi()
	return "%d-%d-%s" % [time, random_value, being_name.replace(" ", "_")]

func _exit_tree() -> void:
	"""Cleanup when removed from tree"""
	pentagon_sewers()
	
	# Unregister from FloodGates
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("unregister_being"):
			flood_gates.unregister_being(being_uuid)
