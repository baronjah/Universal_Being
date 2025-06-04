# ==================================================
# SCRIPT NAME: GemmaInterfaceReader.gd
# DESCRIPTION: Gemma AI Interface Reader - UI/UX perception and interaction
# PURPOSE: Give Gemma the ability to read and understand Universal Being interfaces
# CREATED: 2025-06-04 - Gemma Interface System
# AUTHOR: JSH + Claude Code + Gemma AI
# ==================================================
extends Node
class_name GemmaInterfaceReader

# Interface analysis components
var interface_memory: Dictionary = {}
var ui_element_cache: Dictionary = {}
var interaction_patterns: Array[Dictionary] = []

# Reading settings
@export var scan_frequency: float = 1.0
@export var analyze_text: bool = true
@export var track_interactions: bool = true
@export var learn_patterns: bool = true

# Interface comprehension data
var readable_elements: Array[Dictionary] = []
var interface_hierarchy: Dictionary = {}
var user_interaction_history: Array[Dictionary] = []

signal interface_read(interface_data: Dictionary)
signal text_content_found(text_data: Dictionary)
signal interaction_opportunity_detected(opportunity: Dictionary)
signal interface_pattern_learned(pattern: Dictionary)

func _ready():
	_initialize_interface_systems()
	_start_interface_monitoring()

func _initialize_interface_systems():
	"""Initialize Gemma's interface reading capabilities"""
	print("🖥️ GemmaInterfaceReader: Initializing interface comprehension...")
	
	interface_memory = {
		"active_interfaces": {},
		"text_content": {},
		"button_elements": {},
		"input_fields": {},
		"interaction_points": {}
	}
	
	ui_element_cache = {}
	interaction_patterns = []
	
	print("🖥️ GemmaInterfaceReader: Interface reading systems ready")

func _start_interface_monitoring():
	"""Start continuous interface monitoring"""
	var timer = Timer.new()
	timer.wait_time = scan_frequency
	timer.autostart = true
	timer.timeout.connect(_scan_interfaces)
	add_child(timer)

func _scan_interfaces():
	"""Scan all active interfaces"""
	var interface_data = _capture_interface_snapshot()
	_process_interface_data(interface_data)

func _capture_interface_snapshot() -> Dictionary:
	"""Capture current interface state"""
	var interfaces = _find_all_interfaces()
	var readable_content = _extract_readable_content(interfaces)
	
	return {
		"timestamp": Time.get_datetime_string_from_system(),
		"active_interfaces": interfaces,
		"readable_content": readable_content,
		"interaction_points": _identify_interaction_points(interfaces),
		"interface_hierarchy": _build_interface_hierarchy(interfaces)
	}

func _find_all_interfaces() -> Array[Dictionary]:
	"""Find all active Universal Being interfaces"""
	var found_interfaces = []
	
	# Scan from scene root
	var root = get_tree().current_scene
	if root:
		_recursive_interface_scan(root, found_interfaces)
	
	return found_interfaces

func _recursive_interface_scan(node: Node, found_interfaces: Array):
	"""Recursively scan for interface elements"""
	# Check if this is an interface
	if _is_interface_element(node):
		var interface_data = _analyze_interface_element(node)
		found_interfaces.append(interface_data)
	
	# Scan children
	for child in node.get_children():
		_recursive_interface_scan(child, found_interfaces)

func _is_interface_element(node: Node) -> bool:
	"""Check if node is an interface element"""
	return (node is Control or 
			node.has_method("is_interface") or
			node.get_script() and "Interface" in str(node.get_script().get_path()))

func _analyze_interface_element(node: Node) -> Dictionary:
	"""Analyze an interface element"""
	var interface_data = {
		"id": node.name,
		"type": _determine_interface_type(node),
		"position": _get_interface_position(node),
		"size": _get_interface_size(node),
		"visible": node.visible if node.has_method("get") else true,
		"interactive": _is_interactive_element(node),
		"text_content": _extract_text_from_element(node),
		"children_count": node.get_child_count(),
		"signals": _get_element_signals(node)
	}
	
	return interface_data

func _determine_interface_type(node: Node) -> String:
	"""Determine the type of interface element"""
	if node is Button:
		return "button"
	elif node is LineEdit:
		return "text_input"
	elif node is Label:
		return "text_display"
	elif node is RichTextLabel:
		return "rich_text"
	elif node is Panel or node is PanelContainer:
		return "panel"
	elif node is VBoxContainer or node is HBoxContainer:
		return "container"
	elif node.has_method("is_interface"):
		return "universal_being_interface"
	else:
		return "generic_ui"

func _get_interface_position(node: Node) -> Vector2:
	"""Get interface element position"""
	if node is Control:
		return node.global_position
	return Vector2.ZERO

func _get_interface_size(node: Node) -> Vector2:
	"""Get interface element size"""
	if node is Control:
		return node.size
	return Vector2(0, 0)

func _is_interactive_element(node: Node) -> bool:
	"""Check if element is interactive"""
	return (node is Button or 
			node is LineEdit or 
			node is CheckBox or
			node is Slider or
			node.has_method("_input"))

func _extract_text_from_element(node: Node) -> String:
	"""Extract readable text from element"""
	var text_content = ""
	
	if node.has_method("get_text"):
		text_content = node.get_text()
	elif node.has_property("text"):
		text_content = str(node.text)
	elif node is RichTextLabel:
		text_content = node.get_parsed_text()
	
	return text_content

func _get_element_signals(node: Node) -> Array[String]:
	"""Get available signals for element"""
	var signals = []
	for signal_info in node.get_signal_list():
		signals.append(signal_info.name)
	return signals

func _extract_readable_content(interfaces: Array) -> Dictionary:
	"""Extract all readable text content"""
	var content = {
		"text_elements": [],
		"button_labels": [],
		"input_placeholders": [],
		"rich_content": []
	}
	
	for interface in interfaces:
		var text = interface.text_content
		if not text.is_empty():
			var text_data = {
				"source_id": interface.id,
				"type": interface.type,
				"content": text,
				"position": interface.position
			}
			
			match interface.type:
				"button":
					content.button_labels.append(text_data)
				"text_input":
					content.input_placeholders.append(text_data)
				"rich_text":
					content.rich_content.append(text_data)
				_:
					content.text_elements.append(text_data)
	
	return content

func _identify_interaction_points(interfaces: Array) -> Array[Dictionary]:
	"""Identify points where Gemma could interact"""
	var interaction_points = []
	
	for interface in interfaces:
		if interface.interactive:
			var interaction = {
				"interface_id": interface.id,
				"interaction_type": _determine_interaction_type(interface),
				"position": interface.position,
				"size": interface.size,
				"signals": interface.signals,
				"accessibility": _assess_accessibility(interface)
			}
			interaction_points.append(interaction)
	
	return interaction_points

func _determine_interaction_type(interface: Dictionary) -> String:
	"""Determine how Gemma could interact with this interface"""
	match interface.type:
		"button":
			return "click"
		"text_input":
			return "text_entry"
		"universal_being_interface":
			return "socket_connection"
		_:
			return "generic_interaction"

func _assess_accessibility(interface: Dictionary) -> String:
	"""Assess how accessible this interface is for Gemma"""
	if not interface.visible:
		return "hidden"
	elif interface.size.x < 10 or interface.size.y < 10:
		return "very_small"
	elif interface.interactive:
		return "accessible"
	else:
		return "read_only"

func _build_interface_hierarchy(interfaces: Array) -> Dictionary:
	"""Build hierarchy of interface relationships"""
	var hierarchy = {
		"root_interfaces": [],
		"parent_child_relationships": [],
		"interaction_chains": []
	}
	
	# Analyze interface relationships
	for interface in interfaces:
		if interface.children_count == 0:
			hierarchy.root_interfaces.append(interface.id)
	
	return hierarchy

func _process_interface_data(interface_data: Dictionary):
	"""Process captured interface data"""
	# Update interface memory
	_update_interface_memory(interface_data)
	
	# Emit interface read signal
	interface_read.emit(interface_data)
	
	# Analyze for text content
	if analyze_text:
		_analyze_text_content(interface_data.readable_content)
	
	# Look for interaction opportunities
	_detect_interaction_opportunities(interface_data.interaction_points)
	
	# Learn interface patterns
	if learn_patterns:
		_learn_interface_patterns(interface_data)

func _update_interface_memory(interface_data: Dictionary):
	"""Update interface memory with new data"""
	interface_memory.active_interfaces = {}
	
	for interface in interface_data.active_interfaces:
		interface_memory.active_interfaces[interface.id] = interface

func _analyze_text_content(readable_content: Dictionary):
	"""Analyze readable text content"""
	var total_text_elements = (readable_content.text_elements.size() + 
							   readable_content.button_labels.size() + 
							   readable_content.rich_content.size())
	
	if total_text_elements > 0:
		var text_data = {
			"total_elements": total_text_elements,
			"button_count": readable_content.button_labels.size(),
			"text_fields": readable_content.text_elements.size(),
			"rich_content": readable_content.rich_content.size(),
			"content_summary": _summarize_text_content(readable_content)
		}
		
		text_content_found.emit(text_data)

func _summarize_text_content(content: Dictionary) -> String:
	"""Create summary of text content"""
	var summary_parts = []
	
	if not content.button_labels.is_empty():
		summary_parts.append("%d buttons" % content.button_labels.size())
	
	if not content.text_elements.is_empty():
		summary_parts.append("%d text elements" % content.text_elements.size())
	
	if not content.rich_content.is_empty():
		summary_parts.append("%d rich content areas" % content.rich_content.size())
	
	return ", ".join(summary_parts)

func _detect_interaction_opportunities(interaction_points: Array):
	"""Detect opportunities for Gemma to interact"""
	var accessible_interactions = []
	
	for point in interaction_points:
		if point.accessibility == "accessible":
			accessible_interactions.append(point)
	
	if not accessible_interactions.is_empty():
		var opportunity = {
			"count": accessible_interactions.size(),
			"types": _get_interaction_types(accessible_interactions),
			"recommended_action": _recommend_interaction(accessible_interactions)
		}
		
		interaction_opportunity_detected.emit(opportunity)

func _get_interaction_types(interactions: Array) -> Array[String]:
	"""Get unique interaction types"""
	var types = []
	for interaction in interactions:
		if interaction.interaction_type not in types:
			types.append(interaction.interaction_type)
	return types

func _recommend_interaction(interactions: Array) -> String:
	"""Recommend best interaction for Gemma"""
	# Prioritize certain interaction types
	for interaction in interactions:
		if interaction.interaction_type == "socket_connection":
			return "Connect to Universal Being interface"
		elif interaction.interaction_type == "click":
			return "Click button: %s" % interaction.interface_id
	
	return "Explore available interactions"

func _learn_interface_patterns(interface_data: Dictionary):
	"""Learn patterns from interface usage"""
	var pattern = {
		"timestamp": interface_data.timestamp,
		"interface_count": interface_data.active_interfaces.size(),
		"interaction_count": interface_data.interaction_points.size(),
		"content_types": _get_content_types(interface_data.readable_content),
		"complexity_level": _assess_interface_complexity(interface_data)
	}
	
	interaction_patterns.append(pattern)
	
	# Keep only recent patterns
	if interaction_patterns.size() > 50:
		interaction_patterns.pop_front()
	
	interface_pattern_learned.emit(pattern)

func _get_content_types(content: Dictionary) -> Array[String]:
	"""Get types of content present"""
	var types = []
	if not content.button_labels.is_empty():
		types.append("buttons")
	if not content.text_elements.is_empty():
		types.append("text")
	if not content.rich_content.is_empty():
		types.append("rich_content")
	return types

func _assess_interface_complexity(interface_data: Dictionary) -> String:
	"""Assess interface complexity level"""
	var total_elements = interface_data.active_interfaces.size()
	var interaction_points = interface_data.interaction_points.size()
	
	if total_elements > 20 or interaction_points > 10:
		return "complex"
	elif total_elements > 10 or interaction_points > 5:
		return "medium"
	else:
		return "simple"

func get_interface_summary() -> Dictionary:
	"""Get summary of current interface understanding"""
	var active_count = interface_memory.active_interfaces.size()
	var pattern_count = interaction_patterns.size()
	
	return {
		"active_interfaces": active_count,
		"learned_patterns": pattern_count,
		"scanning": scan_frequency,
		"text_analysis": analyze_text,
		"interaction_tracking": track_interactions,
		"last_scan": Time.get_datetime_string_from_system()
	}

func read_specific_interface(interface_id: String) -> Dictionary:
	"""Read specific interface in detail"""
	if interface_memory.active_interfaces.has(interface_id):
		var interface = interface_memory.active_interfaces[interface_id]
		print("🖥️ Gemma reading interface: %s" % interface_id)
		return interface
	else:
		print("🖥️ Gemma: Interface %s not found" % interface_id)
		return {}
