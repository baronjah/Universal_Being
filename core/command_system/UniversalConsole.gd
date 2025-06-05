# ==================================================
# UNIVERSAL CONSOLE - The Interface to Reality
# PURPOSE: Complete in-game development environment
# LOCATION: core/command_system/UniversalConsole.gd
# ==================================================

extends Node3D
class_name UniversalConsole

## Console components
@onready var output_area: RichTextLabel = RichTextLabel.new()
@onready var input_line: LineEdit = LineEdit.new()
@onready var suggestions_box: ItemList = ItemList.new()

## Systems
var akashic_records: Node

## Console state
var command_history: Array[String] = []
var history_index: int = -1
var auto_complete_active: bool = false

signal console_opened()
signal console_closed()
signal reality_modified(what: String)

func _ready() -> void:
	_setup_ui()
	_connect_systems()
	_setup_input_handling()
	
	# Welcome message
	print_welcome()

func _setup_ui() -> void:
	# Create console UI container
	var console_ui = Control.new()
	console_ui.name = "ConsoleUI"
	console_ui.set_anchors_preset(Control.PRESET_TOP_WIDE)
	console_ui.size = Vector2(get_viewport().size.x, 400)
	
	# Background panel
	var panel = Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.modulate = Color(0.1, 0.1, 0.1, 0.9)
	console_ui.add_child(panel)
	
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.set("theme_override_constants/margin_left", 10)
	margin.set("theme_override_constants/margin_right", 10)
	margin.set("theme_override_constants/margin_top", 10)
	margin.set("theme_override_constants/margin_bottom", 10)
	add_child(margin)
	
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	# Output area
	output_area.bbcode_enabled = true
	output_area.scroll_following = true
	output_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	output_area.add_theme_color_override("default_color", Color.GREEN)
	vbox.add_child(output_area)
	
	# Input line
	input_line.placeholder_text = "Enter command or 'help'..."
	input_line.text_submitted.connect(_on_command_entered)
	input_line.text_changed.connect(_on_text_changed)
	vbox.add_child(input_line)
	
	# Suggestions box (hidden by default)
	suggestions_box.visible = false
	suggestions_box.max_columns = 1
	suggestions_box.item_selected.connect(_on_suggestion_selected)
	add_child(suggestions_box)

func _connect_systems() -> void:
	"""Connect to all subsystems"""
	# Simple command system for now
	add_child(command_processor)
	
	# Macro system
	macro_system = MacroSystem.new()
	add_child(macro_system)
	
	# Code editor
	code_editor = LiveCodeEditor.new()
	code_editor.visible = false
	add_child(code_editor)
	
	# Find Akashic Records
	if has_node("/root/AkashicRecords"):
		akashic_records = get_node("/root/AkashicRecords")

func _setup_input_handling() -> void:
	"""Setup keyboard shortcuts"""
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_console"):
		toggle()
	elif visible:
		if event.is_action_pressed("ui_up"):
			navigate_history(-1)
		elif event.is_action_pressed("ui_down"):
			navigate_history(1)
		elif event.is_action_pressed("ui_text_completion_accept"):
			accept_suggestion()

func toggle() -> void:
	"""Toggle console visibility"""
	visible = not visible
	if visible:
		input_line.grab_focus()
		console_opened.emit()
	else:
		console_closed.emit()

func print_welcome() -> void:
	output_line("=== UNIVERSAL CONSOLE ===")
	output_line("Reality Development Interface")
	output_line("Type 'help' for commands")
	output_line("Ready to create universes...")
	output_line("")
	output_line("Systems online:")
	output_line("• Console: Online")
	output_line("• AI Communication: Ready")
	output_line("• Game Creation: Ready")
	output_line("")

func _on_command_entered(text: String) -> void:
	if text.strip_edges().is_empty():
		return
	
	# Add to history
	command_history.append(text)
	history_index = -1
	
	# Show command
	output_line("> " + text)
	
	# Basic commands
	var parts = text.split(" ")
	var cmd = parts[0].to_lower()
	
	match cmd:
		"help":
			output_line("Commands: help, clear, spawn, test, ai")
		"clear":
			output_area.clear()
		"spawn":
			output_line("Spawning Universal Being...")
		"test":
			output_line("AI Communication test: Hello from console!")
		"ai":
			output_line("AI Communication ready - type messages to create game together")
		_:
			output_line("AI: " + text)
			output_line("Creating game element: " + text)
	
	# Clear input
	input_line.text = ""

			if args:
				load_session(args)
			else:
				output_line("Usage: /load <session_name>")
		
		"macro":
			process_macro_command(args)
		
		"edit":
			toggle_code_editor()
		
		"reload":
			reload_reality()
		
		"tutorial":
			show_tutorial()
		
		_:
			output_line("Unknown console command: /%s" % command)

func process_macro_command(args: String) -> void:
	"""Handle macro subcommands"""
	var parts = args.split(" ", 2)
	if parts.is_empty():
		output_line("Usage: /macro <record|stop|play|list> [args]")
		return
	
	var subcmd = parts[0]
	var macro_args = parts[1] if parts.size() > 1 else ""
	
	match subcmd:
		"record":
			if macro_args:
				macro_system.start_recording(macro_args)
				output_line("🔴 Recording macro: %s" % macro_args)
			else:
				output_line("Usage: /macro record <name>")
		
		"stop":
			if macro_system.stop_recording():
				output_line("⏹️ Macro recording stopped")
			else:
				output_line("No macro recording in progress")
		
		"play":
			if macro_args:
				macro_system.play_macro(macro_args)
				output_line("▶️ Playing macro: %s" % macro_args)
			else:
				output_line("Usage: /macro play <name>")
		
		"list":
			var macros = macro_system.list_macros()
			output_line("Available macros:")
			for macro in macros:
				var info = macro_system.get_macro_info(macro)
				output_line("  • %s - %d commands" % [macro, info.command_count])

func show_tutorial() -> void:
	"""Show interactive tutorial"""
	output_line("\n[color=yellow]🎓 REALITY MANIPULATION TUTORIAL[/color]\n")
	
	output_line("1. [color=cyan]Basic Commands:[/color]")
	output_line("   inspect <target> - Examine anything")
	output_line("   create being <name> - Create a new being")
	output_line("   load script <path> - Load GDScript")
	output_line("")
	
	output_line("2. [color=cyan]Natural Language Triggers:[/color]")
	output_line("   create trigger <word> <action>")
	output_line("   Example: create trigger potato open_doors")
	output_line("   Then say 'potato' near a door!")
	output_line("")
	
	output_line("3. [color=cyan]Reality Modification:[/color]")
	output_line("   reality gravity <value> - Change gravity")
	output_line("   reality time <scale> - Alter time flow")
	output_line("   execute <code> - Run GDScript directly")
	output_line("")
	
	output_line("4. [color=cyan]Macro System:[/color]")
	output_line("   /macro record <name> - Start recording")
	output_line("   /macro stop - Stop recording")
	output_line("   /macro play <name> - Replay commands")
	output_line("")
	
	output_line("5. [color=cyan]Live Editing:[/color]")
	output_line("   /edit - Open code editor")
	output_line("   Select any being and edit its code live!")
	output_line("")
	
	output_line("Try: [color=green]create being TestSubject[/color]")

func reload_reality() -> void:
	"""Hot reload the entire game while running"""
	output_line("🔄 Reloading reality...")
	
	# Save current state
	var state = capture_reality_state()
	
	# Reload all scripts
	var scripts_reloaded = 0
	for node in get_tree().get_nodes_in_group("universal_beings"):
		if node.get_script():
			var script_path = node.get_script().resource_path
			if script_path:
				node.set_script(load(script_path))
				scripts_reloaded += 1
	
	# Restore state
	restore_reality_state(state)
	
	output_line("✅ Reality reloaded! (%d scripts)" % scripts_reloaded)
	reality_modified.emit("reload")

func capture_reality_state() -> Dictionary:
	"""Capture current state of reality"""
	var state = {
		"beings": [],
		"gravity": ProjectSettings.get_setting("physics/2d/default_gravity"),
		"time_scale": Engine.time_scale,
		"triggers": command_processor.natural_triggers.duplicate()
	}
	
	# Capture all beings
	for being in get_tree().get_nodes_in_group("universal_beings"):
		state.beings.append({
			"name": being.being_name,
			"type": being.being_type,
			"consciousness": being.consciousness_level,
			"position": being.position if being is Node2D else Vector2.ZERO
		})
	
	return state

func restore_reality_state(state: Dictionary) -> void:
	"""Restore reality to saved state"""
	# Restore physics
	ProjectSettings.set_setting("physics/2d/default_gravity", state.gravity)
	Engine.time_scale = state.time_scale
	
	# Restore triggers
	command_processor.natural_triggers = state.triggers

func toggle_code_editor() -> void:
	"""Toggle live code editor"""
	code_editor.toggle_visibility()
	if code_editor.visible:
		output_line("Code editor opened - Ctrl+Enter to execute")

func save_session() -> void:
	"""Save console session to Akashic Records"""
	if akashic_records:
		var session_data = {
			"timestamp": Time.get_unix_time_from_system(),
			"commands": command_history,
			"reality_state": capture_reality_state()
		}
		akashic_records.save_record("console_session", "system", session_data)

func load_session(name: String) -> void:
	"""Load session from Akashic Records"""
	if akashic_records:
		var data = akashic_records.load_record("console_session", name)
		if data:
			restore_reality_state(data.reality_state)
			output_line("Session loaded: %s" % name)

func output_line(text: String) -> void:
	output_area.append_text(text + "\n")

func navigate_history(direction: int) -> void:
	"""Navigate command history"""
	if command_history.is_empty():
		return
	
	history_index = clamp(history_index + direction, 0, command_history.size())
	
	if history_index < command_history.size():
		input_line.text = command_history[history_index]
		input_line.caret_column = input_line.text.length()
	else:
		input_line.clear()

func _on_text_changed(new_text: String) -> void:
	"""Handle auto-complete"""
	if new_text.length() < 2:
		suggestions_box.visible = false
		return
	
	# Get suggestions
	var suggestions = get_suggestions(new_text)
	if suggestions.is_empty():
		suggestions_box.visible = false
		return
	
	# Show suggestions
	suggestions_box.clear()
	for suggestion in suggestions:
		suggestions_box.add_item(suggestion)
	
	suggestions_box.visible = true
	position_suggestions_box()

func get_suggestions(partial: String) -> Array[String]:
	"""Get command suggestions"""
	var suggestions: Array[String] = []
	
	# Check command registry
	for cmd in command_processor.command_registry:
		if cmd.begins_with(partial):
			suggestions.append(cmd)
	
	# Check macro names
	for macro in macro_system.list_macros():
		if macro.begins_with(partial):
			suggestions.append("macro play " + macro)
	
	return suggestions.slice(0, 5) # Limit to 5

func position_suggestions_box() -> void:
	"""Position suggestions below input"""
	var input_pos = input_line.global_position
	suggestions_box.position = Vector2(input_pos.x, input_pos.y - 100)
	suggestions_box.size = Vector2(input_line.size.x, 100)

func _on_suggestion_selected(index: int) -> void:
	"""Apply selected suggestion"""
	var suggestion = suggestions_box.get_item_text(index)
	input_line.text = suggestion
	input_line.caret_column = suggestion.length()
	suggestions_box.visible = false
	input_line.grab_focus()

func accept_suggestion() -> void:
	"""Accept first suggestion"""
	if suggestions_box.visible and suggestions_box.item_count > 0:
		_on_suggestion_selected(0)

## AI Interface Methods
func ai_print(text: String) -> void:
	"""Allow AI to print to console"""
	output_line("[color=purple][AI][/color] %s" % text)

func ai_execute(command: String) -> Variant:
	"""Allow AI to execute commands"""
	output_line("[color=purple][AI][/color] > %s" % command)
	return command_processor.execute_command(command)

func ai_query_state(query: String) -> Variant:
	"""Allow AI to query game state"""
	match query:
		"beings":
			return get_tree().get_nodes_in_group("universal_beings")
		"reality":
			return capture_reality_state()
		"macros":
			return macro_system.list_macros()
		_:
			return null