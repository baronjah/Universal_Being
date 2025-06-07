# ==================================================
# SCRIPT NAME: basic_interaction.gd
# DESCRIPTION: Basic interaction component for Universal Beings
# PURPOSE: Enable click, hover, and basic input interactions
# CREATED: 2025-06-03 - Claude Code Universal Being Component
# ==================================================

extends Node
class_name BasicInteractionComponent

# Godot lifecycle functions removed - base UniversalBeing handles bridging to Pentagon Architecture

# Component properties
var click_enabled: bool = true
var hover_enabled: bool = true  
var double_click_enabled: bool = false
var interaction_range: float = 100.0

# State tracking
var is_hovered: bool = false
var last_click_time: float = 0.0
var double_click_threshold: float = 0.3
var being: UniversalBeing = null

# Signals
signal interaction_started()
signal interaction_ended()
signal clicked(being: UniversalBeing)
signal double_clicked(being: UniversalBeing)
signal hover_entered(being: UniversalBeing)
signal hover_exited(being: UniversalBeing)

func apply_to_being(target_being: UniversalBeing) -> void:
	"""Apply this interaction component to a Universal Being"""
	being = target_being
	
	# Connect to being's input system
	if being.has_method("pentagon_input"):
		# The being will call our handle_input method
	
	# Add collision detection for mouse interactions
	setup_interaction_area()
	
	print("🎯 Basic Interaction applied to: %s" % being.being_name)

func setup_interaction_area() -> void:
	"""Setup collision area for mouse interactions"""
	if not being:
		return
		
	# Create collision shape for interaction
	var area = Area3D.new()
	area.name = "InteractionArea"
	
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(2, 2, 2)  # 2x2x2 interaction box
	collision_shape.shape = box_shape
	
	area.add_child(collision_shape)
	being.add_child(area)
	
	# Connect area signals
	area.input_event.connect(_on_area_input_event)
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	
	print("🎯 Interaction area created for %s" % being.being_name)

func _on_area_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	"""Handle input events on the interaction area"""
	if not click_enabled or not being:
		return
		
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			handle_click()
		
func _on_mouse_entered() -> void:
	"""Handle mouse entering the being's area"""
	if not hover_enabled or not being:
		return
		
	is_hovered = true
	hover_entered.emit(being)
	
	# Visual feedback - make being glow
	if being.has_method("set_consciousness_level"):
		var current_level = being.consciousness_level
		being.set_consciousness_level(min(7, current_level + 1))
	
	print("🎯 Mouse entered: %s" % being.being_name)

func _on_mouse_exited() -> void:
	"""Handle mouse leaving the being's area"""
	if not hover_enabled or not being:
		return
		
	is_hovered = false
	hover_exited.emit(being)
	
	# Remove visual feedback
	if being.has_method("set_consciousness_level"):
		var current_level = being.consciousness_level
		being.set_consciousness_level(max(0, current_level - 1))
	
	print("🎯 Mouse exited: %s" % being.being_name)

func handle_click() -> void:
	"""Handle click interaction"""
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# Check for double click
	if double_click_enabled and (current_time - last_click_time) < double_click_threshold:
		handle_double_click()
		return
	
	last_click_time = current_time
	clicked.emit(being)
	
	# Open inspector for this being
	open_inspector()
	
	# Basic click response - increase consciousness temporarily
	if being.has_method("awaken_consciousness"):
		var current_level = being.consciousness_level
		being.awaken_consciousness(min(7, current_level + 2))
		
		# Reset after delay
		var timer = Timer.new()
		timer.wait_time = 1.0
		timer.one_shot = true
		timer.timeout.connect(func(): being.awaken_consciousness(current_level))
		being.add_child(timer)
		timer.start()
	
	print("🎯 %s was clicked! Opening inspector..." % being.being_name)

func handle_double_click() -> void:
	"""Handle double click interaction"""
	double_clicked.emit(being)
	
	# Double click creates a stronger reaction
	if being.has_method("awaken_consciousness"):
		being.awaken_consciousness(7)  # Maximum consciousness
	
	print("🎯 %s was double-clicked! Maximum consciousness achieved!" % being.being_name)

func remove_from_being(target_being: UniversalBeing) -> void:
	"""Remove this interaction component from a Universal Being"""
	if target_being == being:
		# Remove interaction area
		var interaction_area = being.get_node_or_null("InteractionArea")
		if interaction_area:
			interaction_area.queue_free()
		
		being = null
		print("🎯 Basic Interaction removed from: %s" % target_being.being_name)

func get_component_info() -> Dictionary:
	"""Get information about this component"""
	return {
		"name": "Basic Interaction Component",
		"type": "interaction",
		"enabled": click_enabled or hover_enabled,
		"click_enabled": click_enabled,
		"hover_enabled": hover_enabled,
		"double_click_enabled": double_click_enabled,
		"is_hovered": is_hovered,
		"being": being.being_name if being else "none"
	}

# AI Interface methods
func ai_interface() -> Dictionary:
	"""Interface for AI systems to control interaction"""
	return {
		"component": "BasicInteractionComponent",
		"methods": ["enable_click", "disable_click", "enable_hover", "disable_hover", "trigger_click"],
		"properties": ["click_enabled", "hover_enabled", "double_click_enabled"],
		"info": get_component_info()
	}

func enable_click() -> void:
	click_enabled = true
	print("🎯 Click interaction enabled for %s" % (being.being_name if being else "component"))

func disable_click() -> void:
	click_enabled = false
	print("🎯 Click interaction disabled for %s" % (being.being_name if being else "component"))

func enable_hover() -> void:
	hover_enabled = true
	print("🎯 Hover interaction enabled for %s" % (being.being_name if being else "component"))

func disable_hover() -> void:
	hover_enabled = false
	print("🎯 Hover interaction disabled for %s" % (being.being_name if being else "component"))

func trigger_click() -> void:
	"""AI can trigger a click programmatically"""
	if being:
		handle_click()

func open_inspector() -> void:
	"""Open the Universal Being Inspector for this being"""
	if not being:
		return
	
	# Find main scene to add inspector to
	var main_scene = being.get_tree().current_scene
	if not main_scene:
		print("❌ Cannot find main scene for inspector")
		return
	
	# Load inspector class if not already loaded
	var inspector_script = load("res://ui/InGameUniversalBeingInspector.gd")
	if not inspector_script:
		print("❌ Cannot load InGameUniversalBeingInspector script")
		return
	
	# Get or create inspector
	var inspector = null
	var existing_inspector = main_scene.get_node_or_null("InGameUniversalBeingInspector")
	
	if existing_inspector:
		inspector = existing_inspector
	else:
		inspector = inspector_script.new()
		main_scene.add_child(inspector)
	
	# Open inspector for this being
	inspector.inspect_being(being)
	print("🔍 Inspector opened for: %s" % being.being_name)
