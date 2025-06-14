# ==================================================
# SYSTEM: Gemma Text Interface System
# PURPOSE: Provide Gemma with text-based sensory interfaces for vision/sight/senses
# FEATURES: Convert visual interfaces to text descriptions for AI understanding
# CREATED: 2025-06-04
# ==================================================

extends UniversalBeing
class_name GemmaTextInterfaceSystem

# ===== GEMMA SENSORY PROPERTIES =====
@export var update_interval: float = 0.5  # How often to scan interfaces
@export var max_description_length: int = 2000  # Limit text descriptions
@export var include_position_data: bool = true
@export var include_interaction_hints: bool = true

# Observed interfaces
var observed_interfaces: Array[Node] = []
var interface_descriptions: Dictionary = {}  # Node -> String description
var last_scan_time: float = 0.0

# Text output for Gemma
var current_scene_description: String = ""
var interface_inventory: Array[String] = []
var interaction_suggestions: Array[String] = []

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "gemma_text_interface"
	being_name = "Gemma's Text Vision System"
	consciousness_level = 5  # Transcendent AI awareness
	
	print("👁️ %s: Pentagon Init - Text vision awakening" % being_name)

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Connect to GemmaAI
	_connect_to_gemma()
	
	# Start scanning for interfaces
	_start_interface_scanning()
	
	print("👁️ %s: Pentagon Ready - Scanning reality for interfaces" % being_name)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update interface descriptions
	if Time.get_ticks_msec() * 0.001 - last_scan_time > update_interval:
		_scan_all_interfaces()
		_update_gemma_vision()
		last_scan_time = Time.get_ticks_msec() * 0.001

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)

func pentagon_sewers() -> void:
	print("👁️ %s: Text vision system shutting down..." % being_name)
	super.pentagon_sewers()

# ===== GEMMA CONNECTION =====

func _connect_to_gemma() -> void:
	"""Connect to Gemma AI system"""
	var gemma = get_node_or_null("/root/GemmaAI")
	if gemma:
		if gemma.has_method("set_text_interface_system"):
			gemma.set_text_interface_system(self)
		print("👁️ Connected to Gemma AI for text-based vision")

func _start_interface_scanning() -> void:
	"""Start scanning for interfaces"""
	# Get initial interface list
	_discover_all_interfaces()

# ===== INTERFACE DISCOVERY =====

func _discover_all_interfaces() -> void:
	"""Discover all interfaces in the game world"""
	observed_interfaces.clear()
	
	# Find Universal Interface Beings
	var interface_beings = get_tree().get_nodes_in_group("interface")
	for interface in interface_beings:
		add_observed_interface(interface)
	
	# Find console interfaces
	var consoles = get_tree().get_nodes_in_group("console")
	for console in consoles:
		add_observed_interface(console)
	
	# Find any Control nodes (UI interfaces)
	_scan_node_for_interfaces(get_tree().root)
	
	print("👁️ Discovered %d interfaces for Gemma" % observed_interfaces.size())

func _scan_node_for_interfaces(node: Node) -> void:
	"""Recursively scan node tree for interfaces"""
	if node is Control and node.visible:
		# Check if it's a significant interface
		if _is_significant_interface(node):
			add_observed_interface(node)
	
	for child in node.get_children():
		_scan_node_for_interfaces(child)

func _is_significant_interface(control: Control) -> bool:
	"""Check if a Control node is a significant interface"""
	# Must be visible and have some size
	if not control.visible or control.size.length() < 50:
		return false
	
	# Must have interactive elements or be a container
	if control is Panel or control is TabContainer:
		return true
	
	# Check for interactive children
	for child in control.get_children():
		if child is Button or child is LineEdit or child is TextEdit or child is ItemList:
			return true
	
	return false

func add_observed_interface(interface: Node) -> void:
	"""Add an interface to the observation list"""
	if interface not in observed_interfaces:
		observed_interfaces.append(interface)
		_generate_interface_description(interface)

# ===== TEXT DESCRIPTION GENERATION =====

func _scan_all_interfaces() -> void:
	"""Scan all observed interfaces and update descriptions"""
	interface_descriptions.clear()
	interface_inventory.clear()
	interaction_suggestions.clear()
	
	for interface in observed_interfaces:
		if is_instance_valid(interface):
			_generate_interface_description(interface)
		else:
			# Remove invalid interfaces
			observed_interfaces.erase(interface)
	
	_compile_scene_description()

func _generate_interface_description(interface: Node) -> void:
	"""Generate text description of an interface"""
	var description = ""
	var interface_name = interface.name
	
	# Get interface type and basic info
	if interface.has_method("get") and interface.get("being_type"):
		description += "Universal Being Interface: %s (Type: %s)\n" % [interface_name, interface.get("being_type")]
	else:
		description += "Interface: %s (%s)\n" % [interface_name, interface.get_class()]
	
	# Position information
	if include_position_data and interface.has_method("get_global_position"):
		var pos = interface.global_position
		description += "  Position: %.1f, %.1f, %.1f\n" % [pos.x, pos.y, pos.z]
	
	# Interface-specific descriptions
	if interface is UniversalInterfaceBeing:
		description += _describe_universal_interface(interface)
	elif interface is Control:
		description += _describe_control_interface(interface)
	elif interface.has_method("get") and interface.get("being_type") == "console":
		description += _describe_console_interface(interface)
	
	# Store description
	interface_descriptions[interface] = description
	interface_inventory.append(description)

func _describe_universal_interface(interface: UniversalInterfaceBeing) -> String:
	"""Describe a Universal Interface Being"""
	var desc = ""
	desc += "  Title: %s\n" % interface.interface_title
	desc += "  Size: %.0fx%.0f\n" % [interface.interface_size.x, interface.interface_size.y]
	desc += "  Moveable: %s\n" % ("Yes" if interface.is_moveable else "No")
	desc += "  Resizable: %s\n" % ("Yes" if interface.is_resizable else "No")
	
	# Content description
	if interface.loaded_interface:
		desc += "  Content: %s interface loaded\n" % interface.interface_type
	
	# Interaction hints
	if include_interaction_hints:
		desc += "  Interactions: "
		var interactions = []
		if interface.is_moveable:
			interactions.append("grab to move")
		if interface.is_resizable:
			interactions.append("resize from corner")
		if interface.is_closeable:
			interactions.append("close button available")
		desc += " / ".join(interactions) + "\n"
	
	return desc

func _describe_control_interface(control: Control) -> String:
	"""Describe a standard Control interface"""
	var desc = ""
	desc += "  Type: %s\n" % control.get_class()
	desc += "  Size: %.0fx%.0f\n" % [control.size.x, control.size.y]
	desc += "  Visible: %s\n" % ("Yes" if control.visible else "No")
	
	# Describe interactive elements
	var buttons = _find_children_of_type(control, Button)
	if buttons.size() > 0:
		desc += "  Buttons: "
		var button_names = []
		for button in buttons:
			button_names.append("'%s'" % button.text)
		desc += ", ".join(button_names) + "\n"
	
	var inputs = _find_children_of_type(control, LineEdit)
	if inputs.size() > 0:
		desc += "  Text Inputs: %d fields\n" % inputs.size()
	
	var labels = _find_children_of_type(control, Label)
	if labels.size() > 0 and labels.size() <= 5:  # Don't overwhelm with too many labels
		desc += "  Labels: "
		var label_texts = []
		for label in labels:
			if label.text.length() < 50:  # Keep text short
				label_texts.append("'%s'" % label.text)
		desc += ", ".join(label_texts) + "\n"
	
	return desc

func _describe_console_interface(console: Node) -> String:
	"""Describe a console interface"""
	var desc = ""
	desc += "  Console Type: Perfect Universal Console\n"
	desc += "  Features: Commands, Natural Language, AI Chat\n"
	
	# Check for loaded interfaces in tabs
	if console.has_method("get_loaded_interfaces"):
		var loaded = console.get_loaded_interfaces()
		if loaded.size() > 0:
			desc += "  Loaded Interfaces: %d tabs active\n" % loaded.size()
	
	if include_interaction_hints:
		desc += "  Usage: Type commands or speak naturally\n"
		desc += "  Commands: /help, /load, /create, /inspect\n"
	
	return desc

func _find_children_of_type(node: Node, node_type) -> Array:
	"""Find all children of a specific type"""
	var found = []
	for child in node.get_children():
		if child.is_class(str(node_type)):
			found.append(child)
		found.append_array(_find_children_of_type(child, node_type))
	return found

# ===== SCENE DESCRIPTION COMPILATION =====

func _compile_scene_description() -> void:
	"""Compile complete scene description for Gemma"""
	current_scene_description = "=== GEMMA'S INTERFACE VISION ===\n"
	current_scene_description += "Timestamp: %s\n" % Time.get_datetime_string_from_system()
	current_scene_description += "Active Interfaces: %d\n\n" % observed_interfaces.size()
	
	# Add all interface descriptions
	for description in interface_inventory:
		current_scene_description += description + "\n"
	
	# Add interaction suggestions
	if interaction_suggestions.size() > 0:
		current_scene_description += "=== INTERACTION SUGGESTIONS ===\n"
		for suggestion in interaction_suggestions:
			current_scene_description += "- %s\n" % suggestion
	
	# Keep within length limit
	if current_scene_description.length() > max_description_length:
		current_scene_description = current_scene_description.substr(0, max_description_length) + "...[truncated]"

func _update_gemma_vision() -> void:
	"""Send updated vision to Gemma"""
	var gemma = get_node_or_null("/root/GemmaAI")
	if gemma and gemma.has_method("update_interface_vision"):
		gemma.update_interface_vision(current_scene_description)

# ===== PUBLIC API =====

func get_interface_description(interface: Node) -> String:
	"""Get text description of a specific interface"""
	return interface_descriptions.get(interface, "Interface not found")

func get_scene_description() -> String:
	"""Get complete scene description"""
	return current_scene_description

func get_interface_count() -> int:
	"""Get number of observed interfaces"""
	return observed_interfaces.size()

func get_interaction_suggestions() -> Array[String]:
	"""Get current interaction suggestions"""
	return interaction_suggestions

func add_interaction_suggestion(suggestion: String) -> void:
	"""Add an interaction suggestion for Gemma"""
	if suggestion not in interaction_suggestions:
		interaction_suggestions.append(suggestion)

# ===== INTERFACE EVENTS =====

func on_interface_created(interface: Node) -> void:
	"""Called when a new interface is created"""
	add_observed_interface(interface)
	print("👁️ New interface detected: %s" % interface.name)

func on_interface_destroyed(interface: Node) -> void:
	"""Called when an interface is destroyed"""
	observed_interfaces.erase(interface)
	interface_descriptions.erase(interface)
	print("👁️ Interface removed: %s" % interface.name)

func on_interface_changed(interface: Node) -> void:
	"""Called when an interface changes"""
	_generate_interface_description(interface)

# ===== AI INTERFACE =====

func ai_interface() -> Dictionary:
	"""AI interface for console commands"""
	var base = super.ai_interface()
	
	base.commands.merge({
		"scan_interfaces": "Scan for all interfaces in the scene",
		"describe_interface": "Get description of specific interface",
		"get_scene_vision": "Get complete interface vision",
		"add_suggestion": "Add interaction suggestion"
	})
	
	base.state.merge({
		"observed_interfaces": observed_interfaces.size(),
		"last_scan": last_scan_time,
		"description_length": current_scene_description.length(),
		"suggestions": interaction_suggestions.size()
	})
	
	return base