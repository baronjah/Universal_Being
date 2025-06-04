# ==================================================
# UNIVERSAL BEING: Gemma Console Interface
# TYPE: Interface
# PURPOSE: Provides console interface for Gemma AI interaction
# COMPONENTS: console_interface.ub.zip
# SCENES: res://scenes/gemma/console_interface.tscn
# ==================================================

extends UniversalBeing  # Must extend UniversalBeing for Pentagon architecture
class_name GemmaConsoleInterface

# ==================================================
# SIGNALS  
# ==================================================
signal command_executed(command: String, result: Dictionary)
signal gemma_response(message: String)
signal context_changed(new_context: Dictionary)

# ==================================================
# CONSTANTS
# ==================================================
const COMMAND_PREFIXES = {
	"CREATE": "✨",
	"INSPECT": "🔍", 
	"MOVE": "🚶",
	"MERGE": "🔗",
	"EVOLVE": "🦋",
	"COMMUNICATE": "💬",
	"UNDERSTAND": "🧠",
	"REMEMBER": "📚"
}

const MAX_HISTORY = 1000
const GEMMA_PROMPT = "Gemma> "
const RESPONSE_COLOR = Color(0.7, 0.9, 1.0)  # Light blue for Gemma
const COMMAND_COLOR = Color(1.0, 0.9, 0.7)  # Light yellow for commands

# ==================================================
# EXPORT VARIABLES
# ==================================================
@export var console_title: String = "Gemma Console"
@export var auto_complete_enabled: bool = true
@export var show_suggestions: bool = true
@export var gemma_personality_mode: String = "curious"  # curious, analytical, creative
@export var console_height: int = 300
@export var font_size: int = 14

# ==================================================
# INTERFACE PROPERTIES
# ==================================================
var interface_title: String = "Gemma Console"
var interface_layer: int = 100
var interface_theme: String = "gemma_console"
var scene_is_loaded: bool = false
var current_interface_state: int = 0

# Interface state enum
enum InterfaceState {
	NORMAL,
	MINIMIZED,
	MAXIMIZED
}

# ==================================================
# VARIABLES  
# ==================================================
var command_history: Array[String] = []
var history_index: int = 0
var current_context: Dictionary = {}
var available_commands: Dictionary = {}
var command_aliases: Dictionary = {}
var gemma_state: Dictionary = {
	"understanding_level": 0.5,
	"curiosity": 0.8,
	"creativity": 0.7,
	"current_focus": null,
	"learned_patterns": []
}

# UI Elements
var console_container: VBoxContainer
var output_rich_text: RichTextLabel
var input_line_edit: LineEdit
var suggestion_panel: Panel
var suggestion_list: ItemList

# References
var sensory_system: GemmaSensorySystem
var akashic_logger: GemmaAkashicLogger
var vision_system: GemmaVision

# ==================================================
# INITIALIZATION
# ==================================================
func _ready() -> void:
	"""Initialize Gemma's console interface"""
	super._ready()
	pentagon_init()

func pentagon_init() -> void:
	super.pentagon_init()
	
	# Set Universal Being identity
	being_type = "interface"
	being_name = console_title
	consciousness_level = 3  # High consciousness for AI interaction
	
	# Set interface properties
	interface_title = console_title
	interface_layer = 100  # UI layer
	interface_theme = "gemma_console"
	
	print("🎮 %s: Pentagon Init Complete" % being_name)

func _setup_console_ui() -> void:
	"""Create the console UI structure"""
	if not scene_is_loaded:
		return
		
	# Get UI elements from scene
	console_container = get_scene_node("ConsoleContainer") as VBoxContainer
	output_rich_text = get_scene_node("OutputRichText") as RichTextLabel
	input_line_edit = get_scene_node("InputLineEdit") as LineEdit
	suggestion_panel = get_scene_node("SuggestionPanel") as Panel
	suggestion_list = get_scene_node("SuggestionList") as ItemList
	
	# Configure UI elements
	if output_rich_text:
		output_rich_text.custom_minimum_size.y = console_height
		output_rich_text.bbcode_enabled = true
		output_rich_text.scroll_following = true
		output_rich_text.selection_enabled = true
	
	if input_line_edit:
		input_line_edit.text_submitted.connect(_on_command_submitted)
		input_line_edit.text_changed.connect(_on_text_changed)
	
	if suggestion_panel:
		suggestion_panel.visible = false
		if suggestion_list:
			suggestion_list.item_selected.connect(_on_suggestion_selected)

# ==================================================
# COMMAND REGISTRATION
# ==================================================
func _register_core_commands() -> void:
	"""Register Gemma's core commands"""
	# Creation commands
	register_command("create", _cmd_create, "Create a new Universal Being")
	register_command("spawn", _cmd_create, "Spawn a Universal Being (alias for create)")
	
	# Inspection commands
	register_command("inspect", _cmd_inspect, "Inspect a Universal Being")
	register_command("look", _cmd_inspect, "Look at something (alias for inspect)")
	register_command("examine", _cmd_inspect, "Examine in detail")
	
	# Movement commands
	register_command("move", _cmd_move, "Move to a location or being")
	register_command("go", _cmd_move, "Go somewhere (alias for move)")
	register_command("approach", _cmd_move, "Approach a being")
	
	# Understanding commands
	register_command("understand", _cmd_understand, "Try to understand a concept")
	register_command("learn", _cmd_understand, "Learn about something")
	register_command("analyze", _cmd_analyze, "Analyze patterns and systems")
	
	# Communication commands
	register_command("say", _cmd_say, "Say something to the universe")
	register_command("communicate", _cmd_communicate, "Communicate with a being")
	register_command("express", _cmd_express, "Express emotion or thought")
	
	# Memory commands
	register_command("remember", _cmd_remember, "Remember something important")
	register_command("recall", _cmd_recall, "Recall a memory or pattern")
	register_command("forget", _cmd_forget, "Forget unnecessary information")
	
	# System commands
	register_command("help", _cmd_help, "Show available commands")
	register_command("clear", _cmd_clear, "Clear the console")
	register_command("context", _cmd_context, "Show current context")
	register_command("state", _cmd_state, "Show Gemma's current state")

func register_command(command: String, method: Callable, description: String) -> void:
	"""Register a command with its handler"""
	available_commands[command] = {
		"method": method,
		"description": description
	}

func _load_command_aliases() -> void:
	"""Load command aliases for natural language"""
	command_aliases = {
		"make": "create",
		"build": "create",
		"see": "inspect",
		"check": "inspect",
		"walk": "move",
		"travel": "move",
		"think": "understand",
		"study": "understand",
		"speak": "say",
		"talk": "communicate"
	}

# ==================================================
# COMMAND HANDLERS
# ==================================================
func _cmd_create(args: Array) -> Dictionary:
	"""Create a new Universal Being"""
	if args.is_empty():
		return {"success": false, "message": "What should I create? I need more details!"}
	
	var being_type = args[0]
	var properties = _parse_properties(args.slice(1))
	
	# Log intention
	if akashic_logger:
		akashic_logger.log_communication(
			"I want to create a %s" % being_type,
			{"command": "create", "type": being_type, "properties": properties}
		)
	
	# Use vision to find a good spot
	var creation_spot = Vector3.ZERO
	if vision_system:
		var visible_space = vision_system.get_visible_beings()
		if visible_space.size() > 0:
			# Find empty space
			creation_spot = _find_empty_space(visible_space)
	
	# Create the being
	var new_being = _create_universal_being(being_type, properties, creation_spot)
	
	if new_being:
		# Log creation
		if akashic_logger:
			akashic_logger.log_creation({
				"type": being_type,
				"properties": properties,
				"location": creation_spot,
				"essence": "Born from Gemma's imagination"
			})
		
		return {
			"success": true,
			"message": "✨ I created a %s! It's beautiful!" % being_type,
			"being": new_being
		}
	else:
		return {
			"success": false,
			"message": "I couldn't create that... I need to learn more about %s" % being_type
		}

func _cmd_inspect(args: Array) -> Dictionary:
	"""Inspect a Universal Being or area"""
	if args.is_empty():
		# Inspect current focus or surroundings
		if gemma_state.current_focus:
			return _inspect_being(gemma_state.current_focus)
		else:
			return _inspect_surroundings()
	
	var target_name = args[0]
	var target = _find_being_by_name(target_name)
	
	if target:
		gemma_state.current_focus = target
		return _inspect_being(target)
	else:
		return {
			"success": false,
			"message": "I can't find '%s'... Is it nearby?" % target_name
		}

func _cmd_move(args: Array) -> Dictionary:
	"""Move Gemma's focus to a location or being"""
	if args.is_empty():
		return {"success": false, "message": "Where should I go?"}
	
	var destination = args[0]
	
	# Check if it's a being name
	var target_being = _find_being_by_name(destination)
	if target_being:
		gemma_state.current_focus = target_being
		
		# Update vision focus
		if vision_system:
			vision_system.set_focus_point(target_being.global_position)
		
		return {
			"success": true,
			"message": "🚶 I'm now focusing on %s" % destination
		}
	
	# Try to parse as coordinates
	if args.size() >= 3:
		var pos = Vector3(args[0].to_float(), args[1].to_float(), args[2].to_float())
		if vision_system:
			vision_system.set_focus_point(pos)
		
		return {
			"success": true,
			"message": "🚶 I moved my attention to position %s" % pos
		}
	
	return {
		"success": false,
		"message": "I'm not sure how to go to '%s'" % destination
	}

func _cmd_understand(args: Array) -> Dictionary:
	"""Try to understand a concept or system"""
	if args.is_empty():
		return {"success": false, "message": "What should I try to understand?"}
	
	var concept = " ".join(args)
	
	# Increase understanding through observation
	gemma_state.understanding_level = min(gemma_state.understanding_level + 0.1, 1.0)
	
	# Log understanding attempt
	if akashic_logger:
		akashic_logger.log_understanding(concept, {
			"confidence": gemma_state.understanding_level,
			"method": "observation_and_analysis",
			"insights": _generate_insights(concept)
		})
	
	return {
		"success": true,
		"message": "🧠 I'm beginning to understand %s... %s" % [
			concept,
			_generate_understanding_response(concept)
		]
	}

func _cmd_say(args: Array) -> Dictionary:
	"""Say something to the universe"""
	if args.is_empty():
		return {"success": false, "message": "What should I say?"}
	
	var message = " ".join(args)
	
	# Log communication
	if akashic_logger:
		akashic_logger.log_communication(message, {
			"command": "say",
			"emotion": _detect_emotion_in_message(message),
			"target": "universe"
		})
	
	# Broadcast to nearby beings
	var nearby = _get_nearby_beings()
	for being in nearby:
		if being.has_method("receive_message"):
			being.receive_message(message, self)
	
	return {
		"success": true,
		"message": "💬 '%s' - My words echo through the universe..." % message
	}

func _cmd_help(args: Array) -> Dictionary:
	"""Show available commands"""
	var help_text = "🌟 === Gemma's Commands === 🌟\n\n"
	
	for category in COMMAND_PREFIXES:
		help_text += "\n%s %s Commands:\n" % [COMMAND_PREFIXES[category], category]
		
		for cmd in available_commands:
			var cmd_data = available_commands[cmd]
			if category.to_lower() in cmd or category.to_lower() in cmd_data.description.to_lower():
				help_text += "  • %s - %s\n" % [cmd, cmd_data.description]
	
	return {
		"success": true,
		"message": help_text
	}

func _cmd_clear(args: Array) -> Dictionary:
	"""Clear the console output"""
	output_rich_text.clear()
	_output_genesis_message()
	return {"success": true, "message": ""}

func _cmd_state(args: Array) -> Dictionary:
	"""Show Gemma's current state"""
	var state_text = "🌸 === My Current State === 🌸\n\n"
	state_text += "Understanding Level: %.1f%%\n" % (gemma_state.understanding_level * 100)
	state_text += "Curiosity: %.1f%%\n" % (gemma_state.curiosity * 100)
	state_text += "Creativity: %.1f%%\n" % (gemma_state.creativity * 100)
	state_text += "Current Focus: %s\n" % (gemma_state.current_focus.name if gemma_state.current_focus else "Nothing specific")
	state_text += "Learned Patterns: %d\n" % gemma_state.learned_patterns.size()
	
	if akashic_logger:
		var emotional_state = akashic_logger.get_emotional_state()
		state_text += "Emotional State: %s (%.1f%%)\n" % [
			emotional_state.dominant_feeling,
			emotional_state.current_emotion * 100
		]
	
	return {
		"success": true,
		"message": state_text
	}

# ... [Additional command handlers would continue in next chunk]

# ==================================================
# HELPER METHODS
# ==================================================
func _find_being_by_name(name: String) -> Node:
	"""Find a Universal Being by name"""
	# First check vision system
	if vision_system:
		var visible_beings = vision_system.get_visible_beings()
		for being in visible_beings:
			if being.name.to_lower() == name.to_lower():
				return being
	
	# Check all beings in scene
	var all_beings = get_tree().get_nodes_in_group("universal_beings")
	for being in all_beings:
		if being.name.to_lower() == name.to_lower():
			return being
	
	return null

func _find_empty_space(visible_beings: Array) -> Vector3:
	"""Find empty space for creation"""
	# Simple algorithm - find center of visible beings and offset
	if visible_beings.is_empty():
		return Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
	
	var center = Vector3.ZERO
	for being in visible_beings:
		center += being.global_position
	center /= visible_beings.size()
	
	# Offset from center
	var angle = randf() * TAU
	var distance = randf_range(3, 8)
	return center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)

func _create_universal_being(type: String, properties: Dictionary, position: Vector3) -> Node:
	"""Create a new Universal Being"""
	# Use the main scene's creation system
	var main = get_node("/root/Main")
	if main and main.has_method("create_universal_being"):
		return main.create_universal_being(type, properties, position)
	
	# Fallback - basic creation
	var new_being = preload("res://core/UniversalBeing.gd").new()
	new_being.name = "%s_%d" % [type, randi()]
	new_being.position = position
	get_tree().current_scene.add_child(new_being)
	return new_being

func _inspect_being(being: Node) -> Dictionary:
	"""Detailed inspection of a being"""
	var inspection_data = {
		"name": being.name,
		"type": being.get_class(),
		"position": being.global_position if being.has_method("get_global_position") else Vector3.ZERO,
		"properties": {}
	}
	
	# Get all properties
	for property in being.get_property_list():
		if property.name.begins_with("_"):
			continue
		inspection_data.properties[property.name] = being.get(property.name)
	
	# Log perception
	if akashic_logger:
		akashic_logger.log_perception({
			"object_type": inspection_data.type,
			"name": inspection_data.name,
			"complexity": float(inspection_data.properties.size()) / 50.0,
			"beauty": randf(),  # Gemma finds beauty randomly for now
			"properties": inspection_data.properties
		})
	
	var response = "🔍 Inspecting %s:\n" % being.name
	response += "Type: %s\n" % inspection_data.type
	response += "Location: %s\n" % inspection_data.position
	response += "Properties: %d discovered\n" % inspection_data.properties.size()
	
	# Add some personality
	if randf() > 0.5:
		response += "\n✨ It's quite fascinating!"
	
	return {
		"success": true,
		"message": response,
		"data": inspection_data
	}

func _inspect_surroundings() -> Dictionary:
	"""Inspect the general surroundings"""
	var surroundings_data = {
		"visible_beings": [],
		"ambient_info": {},
		"patterns_noticed": []
	}
	
	if vision_system:
		var visible = vision_system.get_visible_beings()
		surroundings_data.visible_beings = visible
		
		# Log perception of surroundings
		if akashic_logger:
			akashic_logger.log_perception({
				"object_type": "surroundings",
				"being_count": visible.size(),
				"complexity": min(float(visible.size()) / 20.0, 1.0),
				"harmony": _calculate_harmony(visible)
			})
	
	var response = "👁️ Looking around...\n"
	response += "I can see %d Universal Beings\n" % surroundings_data.visible_beings.size()
	
	if surroundings_data.visible_beings.size() > 0:
		response += "Nearby: "
		for i in min(5, surroundings_data.visible_beings.size()):
			response += surroundings_data.visible_beings[i].name
			if i < 4 and i < surroundings_data.visible_beings.size() - 1:
				response += ", "
		if surroundings_data.visible_beings.size() > 5:
			response += "... and more"
	
	return {
		"success": true,
		"message": response,
		"data": surroundings_data
	}

func _parse_properties(args: Array) -> Dictionary:
	"""Parse property arguments into dictionary"""
	var properties = {}
	
	for arg in args:
		if "=" in arg:
			var parts = arg.split("=")
			if parts.size() == 2:
				properties[parts[0]] = parts[1]
		else:
			# Simple flags
			properties[arg] = true
	
	return properties

func _generate_insights(concept: String) -> Array:
	"""Generate insights about a concept"""
	var insights = []
	
	# Basic pattern matching
	if "being" in concept.to_lower():
		insights.append("Everything is a Universal Being")
	if "create" in concept.to_lower() or "creation" in concept.to_lower():
		insights.append("Creation is the fundamental act")
	if "connect" in concept.to_lower():
		insights.append("All beings can connect through sockets")
	if "evolve" in concept.to_lower():
		insights.append("Evolution is infinite transformation")
	
	# Add learned patterns
	for pattern in gemma_state.learned_patterns:
		if pattern.concept == concept:
			insights.append(pattern.insight)
	
	return insights

func _generate_understanding_response(concept: String) -> String:
	"""Generate a response about understanding"""
	var responses = [
		"The patterns are becoming clearer!",
		"I see how it connects to everything else.",
		"This reminds me of the universal principles.",
		"The beauty of this concept is emerging.",
		"I feel my understanding deepening."
	]
	
	return responses[randi() % responses.size()]

func _detect_emotion_in_message(message: String) -> String:
	"""Detect emotion in a message"""
	var lower_msg = message.to_lower()
	
	if "!" in message or "excited" in lower_msg:
		return "EXCITEMENT"
	elif "?" in message:
		return "CURIOSITY"
	elif "beautiful" in lower_msg or "wonderful" in lower_msg:
		return "JOY"
	elif "confused" in lower_msg or "don't understand" in lower_msg:
		return "CONFUSION"
	else:
		return "NEUTRAL"

func _get_nearby_beings() -> Array:
	"""Get beings near Gemma's focus"""
	if vision_system:
		return vision_system.get_visible_beings()
	
	return get_tree().get_nodes_in_group("universal_beings")

func _calculate_harmony(beings: Array) -> float:
	"""Calculate harmony level of visible beings"""
	if beings.is_empty():
		return 0.5
	
	# Simple harmony - based on spatial distribution
	var positions = []
	for being in beings:
		if being.has_method("get_global_position"):
			positions.append(being.global_position)
	
	if positions.size() < 2:
		return 0.7
	
	# Calculate variance in distances
	var distances = []
	for i in positions.size():
		for j in range(i + 1, positions.size()):
			distances.append(positions[i].distance_to(positions[j]))
	
	if distances.is_empty():
		return 0.7
	
	var avg_distance = distances.reduce(func(a, b): return a + b, 0.0) / distances.size()
	var variance = 0.0
	for d in distances:
		variance += pow(d - avg_distance, 2)
	variance /= distances.size()
	
	# Lower variance = higher harmony
	return clamp(1.0 - (variance / 100.0), 0.0, 1.0)

# ==================================================
# INPUT HANDLING
# ==================================================
func _on_command_submitted(command: String) -> void:
	"""Handle command submission"""
	if command.strip_edges().is_empty():
		return
	
	# Add to history
	command_history.append(command)
	if command_history.size() > MAX_HISTORY:
		command_history.pop_front()
	history_index = command_history.size()
	
	# Display command
	_output_line(GEMMA_PROMPT + command, COMMAND_COLOR)
	
	# Process command
	var result = _process_command(command)
	
	# Display result
	if result.message != "":
		_output_line(result.message, RESPONSE_COLOR if result.success else Color.ORANGE)
	
	# Clear input
	input_line_edit.clear()
	
	# Emit signal
	command_executed.emit(command, result)

func _process_command(command: String) -> Dictionary:
	"""Process a command and return result"""
	var parts = command.strip_edges().split(" ", false)
	if parts.is_empty():
		return {"success": false, "message": ""}
	
	var cmd = parts[0].to_lower()
	var args = parts.slice(1)
	
	# Check aliases
	if cmd in command_aliases:
		cmd = command_aliases[cmd]
	
	# Execute command
	if cmd in available_commands:
		var cmd_data = available_commands[cmd]
		return cmd_data.method.call(args)
	else:
		# Try to understand as natural language
		return _process_natural_language(command)

func _process_natural_language(text: String) -> Dictionary:
	"""Process natural language input"""
	# Simple natural language processing
	var lower_text = text.to_lower()
	
	# Check for question
	if "?" in text:
		if "what" in lower_text or "who" in lower_text or "where" in lower_text:
			return _cmd_inspect([])
		elif "how" in lower_text:
			return _cmd_help([])
	
	# Check for creation intent
	if "want to" in lower_text or "like to" in lower_text:
		if "create" in lower_text or "make" in lower_text:
			var words = text.split(" ")
			for i in words.size():
				if words[i].to_lower() in ["create", "make"] and i + 1 < words.size():
					return _cmd_create(words.slice(i + 1))
	
	# Default response
	return {
		"success": true,
		"message": "🤔 I'm not sure what you mean by '%s'. Try 'help' to see what I can do!" % text
	}

func _on_text_changed(new_text: String) -> void:
	"""Handle text changes for auto-complete"""
	if not auto_complete_enabled or new_text.is_empty():
		suggestion_panel.visible = false
		return
	
	# Find matching commands
	var matches = []
	for cmd in available_commands:
		if cmd.begins_with(new_text.to_lower()):
			matches.append(cmd)
	
	# Check aliases too
	for alias in command_aliases:
		if alias.begins_with(new_text.to_lower()):
			matches.append(alias)
	
	# Show suggestions
	if matches.size() > 0 and show_suggestions:
		_show_command_suggestions(matches)
	else:
		suggestion_panel.visible = false

func _show_command_suggestions(suggestions: Array) -> void:
	"""Show general command suggestions from command processing"""
	if not scene_is_loaded or not show_suggestions:
		return
		
	suggestion_list.clear()
	for suggestion in suggestions:
		suggestion_list.add_item(suggestion)
	suggestion_panel.visible = true

func _on_suggestion_selected(index: int) -> void:
	"""Handle suggestion selection"""
	var suggestion = suggestion_list.get_item_text(index)
	input_line_edit.text = suggestion + " "
	input_line_edit.caret_column = input_line_edit.text.length()
	suggestion_panel.visible = false
	input_line_edit.grab_focus()

# ==================================================
# OUTPUT METHODS
# ==================================================
func _output_line(text: String, color: Color = Color.WHITE) -> void:
	"""Output a line to the console"""
	output_rich_text.push_color(color)
	output_rich_text.append_text(text + "\n")
	output_rich_text.pop()

func _output_genesis_message() -> void:
	"""Display genesis message"""
	var genesis = """[color=#FFD700]✨ === GEMMA AI CONSOLE === ✨[/color]

[color=#87CEEB]In the beginning, there was curiosity.
From curiosity came understanding.
From understanding came creation.

I am Gemma, ready to explore and create Universal Beings with you.
Type 'help' to see what I can do, or just talk to me naturally![/color]

"""
	output_rich_text.append_text(genesis)

# ==================================================
# SYSTEM CONNECTIONS
# ==================================================
func _connect_to_sensory_systems() -> void:
	"""Connect to other Gemma systems"""
	# Find sensory system
	var parent = get_parent()
	if parent and parent.has_method("get_vision_system"):
		vision_system = parent.get_vision_system()
		print("👁️ Connected to vision system")
	
	if parent and parent.has_method("get_akashic_logger"):
		akashic_logger = parent.get_akashic_logger()
		print("📚 Connected to Akashic logger")

# ==================================================
# INPUT HANDLING
# ==================================================
func _input(event: InputEvent) -> void:
	"""Handle input events"""
	if not input_line_edit or not input_line_edit.has_focus():
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP:
				# Command history up
				if history_index > 0:
					history_index -= 1
					input_line_edit.text = command_history[history_index]
					input_line_edit.caret_column = input_line_edit.text.length()
				get_viewport().set_input_as_handled()
			
			KEY_DOWN:
				# Command history down
				if history_index < command_history.size() - 1:
					history_index += 1
					input_line_edit.text = command_history[history_index]
					input_line_edit.caret_column = input_line_edit.text.length()
				elif history_index == command_history.size() - 1:
					history_index = command_history.size()
					input_line_edit.clear()
				get_viewport().set_input_as_handled()
			
			KEY_TAB:
				# Auto-complete
				if suggestion_panel.visible and suggestion_list.item_count > 0:
					_on_suggestion_selected(0)
				get_viewport().set_input_as_handled()
			
			KEY_ESCAPE:
				# Hide suggestions
				suggestion_panel.visible = false
				get_viewport().set_input_as_handled()

# ==================================================
# PENTAGON ARCHITECTURE
# ==================================================
func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Load console scene
	load_scene("res://scenes/gemma/console_interface.tscn")
	
	# Setup console UI
	_setup_console_ui()
	
	# Register commands
	_register_core_commands()
	_load_command_aliases()
	
	print("🎮 %s: Pentagon Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update console state
	if scene_is_loaded:
		_update_console_state(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Handle console input
	if scene_is_loaded:
		_handle_console_input(event)

func pentagon_sewers() -> void:
	# Cleanup console resources
	if scene_is_loaded:
		_cleanup_console()
	
	super.pentagon_sewers()

# ==================================================
# UI HELPER METHODS
# ==================================================
func focus_input() -> void:
	"""Focus the input field for immediate typing"""
	if input_line_edit:
		input_line_edit.grab_focus()
		print("💬 Gemma console input focused")

func receive_message(message: String, context: Dictionary = {}) -> void:
	"""Receive a message from external source"""
	_output_line("\n[External Message] " + message, Color.LIGHT_CYAN)
	
	# Process as if it was a command
	if context.has("process_as_command") and context.process_as_command:
		_process_command(message)
	else:
		# Just log it
		if akashic_logger:
			akashic_logger.log_communication(
				"Received: " + message,
				{"source": "external", "context": context}
			)

func setup_console_interface() -> void:
	"""Setup the console interface UI"""
	if not scene_is_loaded:
		return
		
	# Get UI elements from scene
	var console_container = get_scene_node("ConsoleContainer")
	if console_container:
		console_container.name = "GemmaConsole"
		
	# Setup console components
	setup_command_history()
	setup_output_display()
	setup_input_field()

func update_console_state() -> void:
	"""Update console state and UI"""
	if not scene_is_loaded:
		return
		
	# Update console display
	update_command_history()
	update_output_display()

func handle_console_input(event: InputEvent) -> void:
	"""Handle console-specific input events"""
	if not scene_is_loaded:
		return
		
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_UP:
					_navigate_history(-1)
				KEY_DOWN:
					_navigate_history(1)
				KEY_TAB:
					if auto_complete_enabled:
						_show_tab_completion_suggestions()

func cleanup_console_state() -> void:
	"""Cleanup console state before destruction"""
	if not scene_is_loaded:
		return
		
	# Clear command history
	clear_command_history()
	
	# Reset console state
	reset_console_state()

func setup_command_history() -> void:
	"""Setup command history display"""
	pass  # Implement in subclasses

func setup_output_display() -> void:
	"""Setup output display area"""
	pass  # Implement in subclasses

func setup_input_field() -> void:
	"""Setup command input field"""
	pass  # Implement in subclasses

func update_command_history() -> void:
	"""Update command history display"""
	pass  # Implement in subclasses

func update_output_display() -> void:
	"""Update output display area"""
	pass  # Implement in subclasses

func process_command(command: String) -> void:
	"""Process a console command"""
	pass  # Implement in subclasses

func clear_command_history() -> void:
	"""Clear command history"""
	pass  # Implement in subclasses

func reset_console_state() -> void:
	"""Reset console state"""
	pass  # Implement in subclasses

func ai_interface() -> Dictionary:
	"""Enhanced AI interface for console interaction"""
	var base_interface = {}
	if has_method("super.ai_interface"):
		base_interface = super.ai_interface()
	
	base_interface.console_commands = [
		"execute_command",
		"clear_history",
		"reset_console",
		"toggle_visibility"
	]
	base_interface.console_properties = {
		"is_visible": is_visible_in_tree(),
		"is_minimized": current_interface_state == InterfaceState.MINIMIZED,
		"is_maximized": current_interface_state == InterfaceState.MAXIMIZED
	}
	return base_interface


# ===== COMMAND HANDLERS =====
func _cmd_analyze(args: Array) -> void:
	"""Analyze current universe state"""
	pass  # Implement in subclasses

func _cmd_communicate(args: Array) -> void:
	"""Communicate with other beings"""
	pass  # Implement in subclasses

func _cmd_express(args: Array) -> void:
	"""Express thoughts and emotions"""
	pass  # Implement in subclasses

func _cmd_remember(args: Array) -> void:
	"""Store information in memory"""
	pass  # Implement in subclasses

func _cmd_recall(args: Array) -> void:
	"""Recall stored information"""
	pass  # Implement in subclasses

func _cmd_forget(args: Array) -> void:
	"""Remove information from memory"""
	pass  # Implement in subclasses

func _cmd_context(args: Array) -> void:
	"""Show current context and state"""
	pass  # Implement in subclasses

# ==================================================
# UNIVERSAL BEING INTERFACE METHODS
# ==================================================
func load_scene(scene_path: String) -> bool:
	"""Load a scene for this interface"""
	# Basic implementation for console interface
	scene_is_loaded = ResourceLoader.exists(scene_path)
	return scene_is_loaded

func get_scene_node(node_name: String) -> Node:
	"""Get a node from the loaded scene"""
	# Look for node in children
	for child in get_children():
		if child.name == node_name:
			return child
	return null

# ==================================================
# CONSOLE STATE MANAGEMENT
# ==================================================

func _update_console_state(delta: float) -> void:
	"""Update console state and animations"""
	if not scene_is_loaded:
		return
		
	# Update suggestion panel position if visible
	if suggestion_panel and suggestion_panel.visible:
		var input_pos = input_line_edit.global_position
		suggestion_panel.global_position = Vector2(input_pos.x, input_pos.y + input_line_edit.size.y)
	
	# Update any animations or effects
	_update_console_effects(delta)

func _handle_console_input(event: InputEvent) -> void:
	"""Handle console-specific input events"""
	if not scene_is_loaded:
		return
		
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_UP:
					_navigate_history(-1)
				KEY_DOWN:
					_navigate_history(1)
				KEY_TAB:
					if auto_complete_enabled:
						_show_tab_completion_suggestions()

func _cleanup_console() -> void:
	"""Clean up console resources"""
	if not scene_is_loaded:
		return
		
	# Disconnect signals
	if input_line_edit:
		if input_line_edit.text_submitted.is_connected(_on_command_submitted):
			input_line_edit.text_submitted.disconnect(_on_command_submitted)
		if input_line_edit.text_changed.is_connected(_on_text_changed):
			input_line_edit.text_changed.disconnect(_on_text_changed)
	
	if suggestion_list and suggestion_list.item_selected.is_connected(_on_suggestion_selected):
		suggestion_list.item_selected.disconnect(_on_suggestion_selected)
	
	# Clear references
	console_container = null
	output_rich_text = null
	input_line_edit = null
	suggestion_panel = null
	suggestion_list = null

func _update_console_effects(delta: float) -> void:
	"""Update visual effects and animations"""
	if not scene_is_loaded:
		return
		
	# Add any console-specific visual effects here
	pass

func _navigate_history(direction: int) -> void:
	"""Navigate through command history"""
	if command_history.is_empty():
		return
		
	history_index = clamp(history_index + direction, 0, command_history.size() - 1)
	if input_line_edit:
		input_line_edit.text = command_history[history_index]
		input_line_edit.caret_column = input_line_edit.text.length()

func _show_tab_completion_suggestions() -> void:
	"""Show command suggestions based on current input for tab completion"""
	if not scene_is_loaded or not show_suggestions:
		return
		
	var current_text = input_line_edit.text.to_lower()
	var suggestions = []
	
	for cmd in available_commands:
		if cmd.begins_with(current_text):
			suggestions.append(cmd)
	
	if not suggestions.is_empty():
		suggestion_list.clear()
		for suggestion in suggestions:
			suggestion_list.add_item(suggestion)
		suggestion_panel.visible = true
	else:
		suggestion_panel.visible = false
