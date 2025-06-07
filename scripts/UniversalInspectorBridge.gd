# ==================================================
# SCRIPT NAME: UniversalInspectorBridge.gd
# DESCRIPTION: Bridge connecting Inspector to all Universal Being systems
# PURPOSE: Unified inspection system with Console, Cursor, LogicConnector, and Akashic integration
# CREATED: 2025-06-03 - Universal Being Revolution
# AUTHOR: JSH + Claude Desktop MCP
# ==================================================

extends Node
class_name UniversalInspectorBridge

# ===== SYSTEM CONNECTIONS =====
var inspector: Control = null
var console_being: ConversationalConsoleBeing = null
var cursor_being: Node = null
var logic_connector: Node = null
var akashic_records: Node = null
var gemma_ai: Node = null

# ===== INSPECTION STATE =====
var current_being: UniversalBeing = null
var inspection_history: Array[Dictionary] = []
var is_editing_mode: bool = false
var connected_systems: Dictionary = {}

# ===== SIGNALS =====
signal being_inspected(being: UniversalBeing)
signal property_modified(being: UniversalBeing, property_name: String, new_value: Variant)
signal system_connected(system_name: String)
signal inspection_logged(log_entry: Dictionary)

func _ready() -> void:
	name = "UniversalInspectorBridge"
	print("🔗 Universal Inspector Bridge initializing...")
	
	# Wait for systems to be ready
	await get_tree().create_timer(0.5).timeout
	
	# Connect to all systems
	connect_to_systems()
	
	# Set up cursor integration
	setup_cursor_integration()
	
	print("🔗 Universal Inspector Bridge ready!")

func connect_to_systems() -> void:
	# Connect to Inspector
	inspector = get_tree().get_nodes_in_group("inspector").front()
	if not inspector:
		# Try to find by name
		var main = get_tree().current_scene
		if main:
			inspector = main.get_node_or_null("InGameUniversalBeingInspector")
	
	if inspector:
		connected_systems["inspector"] = true
		system_connected.emit("inspector")
		print("🔗 Connected to Inspector")
	
	# Connect to Console
	console_being = get_tree().get_nodes_in_group("console_beings").front()
	if console_being:
		connected_systems["console"] = true
		system_connected.emit("console")
		print("🔗 Connected to Conversational Console")
	
	# Connect to Cursor
	cursor_being = find_cursor_being()
	if cursor_being:
		connected_systems["cursor"] = true
		# Connect to cursor inspection signal
		if cursor_being.has_signal("cursor_inspected"):
			cursor_being.cursor_inspected.connect(_on_cursor_inspected)
		system_connected.emit("cursor")
		print("🔗 Connected to Universal Cursor")
	
	# Connect to LogicConnector
	logic_connector = get_node_or_null("/root/LogicConnector")
	if not logic_connector:
		# Create it if needed
		var main = get_tree().current_scene
		if main:
			logic_connector = main.get_node_or_null("LogicConnector")
	
	if logic_connector:
		connected_systems["logic_connector"] = true
		system_connected.emit("logic_connector")
		print("🔗 Connected to LogicConnector")
	
	# Connect to Akashic Records
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		akashic_records = SystemBootstrap.get_akashic_records()
		if akashic_records:
			connected_systems["akashic_records"] = true
			system_connected.emit("akashic_records")
			print("🔗 Connected to Akashic Records")
	
	# Connect to Gemma AI
	gemma_ai = get_node_or_null("/root/GemmaAI")
	if gemma_ai:
		connected_systems["gemma_ai"] = true
		system_connected.emit("gemma_ai")
		print("🔗 Connected to Gemma AI")

func find_cursor_being() -> Node:
	pass
	# Find cursor being in the scene
	var main = get_tree().current_scene
	if main:
		for child in main.get_children():
			if child.has_method("get_being_type") and child.get_being_type() == "cursor":
				return child
			elif child.name.contains("Cursor"):
				return child
	return null

func setup_cursor_integration() -> void:
	# Override cursor click behavior when in inspect mode
	if cursor_being and cursor_being.has_method("get_cursor_info"):
		var cursor_info = cursor_being.get_cursor_info()
		if cursor_info.get("mode") == "INSPECT":
			print("🔗 Cursor is in INSPECT mode - ready for Universal Being inspection")

func _on_cursor_inspected(being: UniversalBeing) -> void:
	# When cursor inspects a being, route through our unified system
	inspect_being(being)

func inspect_being(being: UniversalBeing) -> void:
	if not being:
		return
	
	current_being = being
	
	# Create inspection data
	var inspection_data = {
		"timestamp": Time.get_datetime_string_from_system(),
		"being_uuid": being.being_uuid if being.has_method("get") else "",
		"being_name": being.being_name,
		"being_type": being.being_type,
		"consciousness_level": being.consciousness_level,
		"position": being.global_position,
		"visual_layer": being.visual_layer,
		"state": being.current_state if being.has_method("get") else "unknown",
		"metadata": being.metadata if being.has_method("get") else {},
		"components": get_being_components(being),
		"editable_properties": get_editable_properties(being),
		"available_actions": get_available_actions(being)
	}
	
	# Log to history
	inspection_history.append(inspection_data)
	being_inspected.emit(being)
	
	# Update inspector UI if connected
	if inspector and inspector.has_method("inspect_being"):
		inspector.inspect_being(being)
	
	# Send to console
	if console_being and console_being.has_method("add_message"):
		var console_msg = "🔍 INSPECTING: %s\n" % being.being_name
		console_msg += "📊 Type: %s | Consciousness: %d | Layer: %d\n" % [
			being.being_type,
			being.consciousness_level,
			being.visual_layer
		]
		console_msg += "📍 Position: %s | State: %s" % [
			str(being.global_position),
			inspection_data.get("state", "unknown")
		]
		console_being.add_message("system", console_msg)
	
	# Notify Gemma AI
	if gemma_ai and gemma_ai.has_method("ai_message"):
		var ai_msg = "🔍 Universal Being Inspection:\n"
		ai_msg += "Being: %s (%s)\n" % [being.being_name, being.being_type]
		ai_msg += "Consciousness Level: %d\n" % being.consciousness_level
		ai_msg += "Editable Properties: %s\n" % str(inspection_data.editable_properties.keys())
		ai_msg += "Available Actions: %s" % str(inspection_data.available_actions)
		gemma_ai.ai_message.emit(ai_msg)
	
	# Log to Akashic Records
	if akashic_records and akashic_records.has_method("log_inspection"):
		akashic_records.log_inspection(being, inspection_data)
	
	# Register with LogicConnector if it's a debuggable
	if logic_connector and being.has_method("get_debug_payload"):
		if logic_connector.has_method("register_debuggable"):
			logic_connector.register_debuggable(being)
	
	inspection_logged.emit(inspection_data)

func get_being_components(being: UniversalBeing) -> Array:
	pass
	var components = []
	if being.has_method("get_components"):
		components = being.get_components()
	elif being.has_method("get") and being.get("components"):
		components = being.get("components")
	return components

func get_editable_properties(being: UniversalBeing) -> Dictionary:
	pass
	# Properties that can be edited in the inspector
	var editable = {}
	
	# Core Universal Being properties
	editable["being_name"] = {
		"type": "String",
		"value": being.being_name,
		"category": "Core"
	}
	editable["consciousness_level"] = {
		"type": "int",
		"value": being.consciousness_level,
		"min": 0,
		"max": 10,
		"category": "Core"
	}
	editable["visual_layer"] = {
		"type": "int",
		"value": being.visual_layer,
		"min": -100,
		"max": 1000,
		"category": "Visual"
	}
	
	# Transform properties
	editable["position"] = {
		"type": "Vector3",
		"value": being.position,
		"category": "Transform"
	}
	editable["rotation"] = {
		"type": "Vector3",
		"value": being.rotation,
		"category": "Transform"
	}
	editable["scale"] = {
		"type": "Vector3",
		"value": being.scale,
		"category": "Transform"
	}
	
	# Add custom properties from metadata
	if being.has_method("get") and being.get("metadata"):
		var metadata = being.get("metadata")
		for key in metadata:
			if key.begins_with("editable_"):
				var prop_name = key.trim_prefix("editable_")
				editable[prop_name] = {
					"type": "Variant",
					"value": metadata[key],
					"category": "Custom"
				}
	
	return editable

func get_available_actions(being: UniversalBeing) -> Array:
	pass
	var actions = []
	
	# Universal actions
	actions.append("evolve")
	actions.append("duplicate")
	actions.append("save_to_akashic")
	actions.append("export_dna")
	
	# Type-specific actions
	match being.being_type:
		"universe":
			actions.append("enter_universe")
			actions.append("create_portal")
			actions.append("set_universe_rules")
		"chunk":
			actions.append("generate_content")
			actions.append("clear_chunk")
			actions.append("test_lod")
		"cursor":
			actions.append("toggle_mode")
			actions.append("set_color")
		"console":
			actions.append("clear_history")
			actions.append("export_conversation")
	
	# Check for custom actions in metadata
	if being.has_method("get_available_actions"):
		var custom_actions = being.get_available_actions()
		actions.append_array(custom_actions)
	
	return actions

func modify_property(being: UniversalBeing, property_name: String, new_value: Variant) -> void:
	if not being or not is_editing_mode:
		return
	
	# Store old value for undo
	var old_value = being.get(property_name)
	
	# Modify the property
	being.set(property_name, new_value)
	
	# Emit signal
	property_modified.emit(being, property_name, new_value)
	
	# Log to console
	if console_being and console_being.has_method("add_message"):
		var msg = "✏️ Modified %s.%s: %s → %s" % [
			being.being_name,
			property_name,
			str(old_value),
			str(new_value)
		]
		console_being.add_message("system", msg)
	
	# Log to Akashic Records
	if akashic_records and akashic_records.has_method("log_modification"):
		akashic_records.log_modification(being, property_name, old_value, new_value)
	
	# Update inspector display
	if inspector and inspector.has_method("refresh_properties"):
		inspector.refresh_properties()

func execute_action(being: UniversalBeing, action_name: String) -> void:
	if not being:
		return
	
	print("🎬 Executing action '%s' on %s" % [action_name, being.being_name])
	
	# Handle universal actions
	match action_name:
		"evolve":
			if being.has_method("evolve"):
				being.evolve()
		"duplicate":
			duplicate_being(being)
		"save_to_akashic":
			save_being_to_akashic(being)
		"export_dna":
			export_being_dna(being)
		_:
			# Try to call the method directly
			if being.has_method(action_name):
				being.call(action_name)
			else:
				print("⚠️ Action '%s' not found on being" % action_name)
	
	# Log action
	if console_being:
		console_being.add_message("system", "🎬 Executed: %s on %s" % [action_name, being.being_name])

func duplicate_being(being: UniversalBeing) -> UniversalBeing:
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var new_being = SystemBootstrap.create_universal_being()
		if new_being:
			# Copy properties
			new_being.being_name = being.being_name + "_copy"
			new_being.being_type = being.being_type
			new_being.consciousness_level = being.consciousness_level
			new_being.position = being.position + Vector3(2, 0, 0)
			
			# Add to scene
			being.get_parent().add_child(new_being)
			
			print("🎯 Duplicated being: %s" % new_being.being_name)
			return new_being
	return null

func save_being_to_akashic(being: UniversalBeing) -> void:
	if akashic_records and akashic_records.has_method("save_being"):
		var save_path = "res://akashic_library/beings/%s_%s.ub.zip" % [
			being.being_type,
			being.being_uuid
		]
		akashic_records.save_being(being, save_path)
		print("💾 Saved being to Akashic Records: %s" % save_path)

func export_being_dna(being: UniversalBeing) -> void:
	pass
	# Export being DNA for cloning/evolution
	var dna = {
		"being_name": being.being_name,
		"being_type": being.being_type,
		"consciousness_level": being.consciousness_level,
		"metadata": being.metadata if being.has_method("get") else {},
		"components": get_being_components(being),
		"visual_layer": being.visual_layer
	}
	
	# Save DNA to file
	var file = FileAccess.open("user://being_dna_%s.json" % being.being_uuid, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(dna, "\t"))
		file.close()
		print("🧬 Exported being DNA: being_dna_%s.json" % being.being_uuid)

func enable_editing_mode() -> void:
	is_editing_mode = true
	print("✏️ Inspector editing mode ENABLED")
	
	if console_being:
		console_being.add_message("system", "✏️ Inspector editing mode enabled - click properties to modify")
	
	if cursor_being and cursor_being.has_method("set_mode"):
		cursor_being.set_mode(1)  # Set to INSPECT mode

func disable_editing_mode() -> void:
	is_editing_mode = false
	print("✏️ Inspector editing mode DISABLED")
	
	if console_being:
		console_being.add_message("system", "✏️ Inspector editing mode disabled")

func get_inspection_history() -> Array[Dictionary]:
	return inspection_history

func clear_inspection_history() -> void:
	inspection_history.clear()
	print("🗑️ Inspection history cleared")

func get_connected_systems() -> Dictionary:
	return connected_systems

func is_fully_connected() -> bool:
	pass
	# Check if all essential systems are connected
	var essential_systems = ["inspector", "console", "cursor", "akashic_records"]
	for system in essential_systems:
		if not connected_systems.get(system, false):
			return false
	return true
