extends Control

class_name TerminalInterface

# Core systems
var wish_engine: WishEngine
var eden_os_main

# Terminal UI elements
@onready var terminal_output = $VBoxContainer/TerminalOutput
@onready var command_input = $VBoxContainer/CommandInput
@onready var status_bar = $StatusBar
@onready var notification_panel = $NotificationPanel

# Command history
var command_history = []
var history_position = -1
var max_history = 50

# Terminal state
var is_ready = false
var auto_scroll = true
var notification_visible = false
var notification_timer = 0.0
var notification_duration = 3.0

# Current context
var context = {
	"account": "",
	"project": "",
	"game": "",
	"dimension": 1
}

func _ready():
	# Initialize core systems
	_initialize_systems()
	
	# Connect signals
	command_input.text_submitted.connect(_on_command_submitted)
	
	# Set initial focus
	command_input.grab_focus()
	
	# Welcome message
	var welcome_text = """
===========================================
Eden OS Terminal Interface
===========================================
Type 'help' for available commands
"""
	_append_to_terminal(welcome_text)
	
	# Auto-execute initial commands
	_execute_command("list account")
	
	is_ready = true
	
	# Update status bar
	_update_status_bar()

func _initialize_systems():
	# Get reference to Eden OS main
	eden_os_main = get_node_or_null("/root/EdenOSMain")
	
	# Initialize wish engine
	wish_engine = get_node_or_null("/root/WishEngine")
	if not wish_engine:
		wish_engine = WishEngine.new()
		add_child(wish_engine)
	
	# Connect to wish engine signals
	wish_engine.wish_created.connect(_on_wish_created)
	wish_engine.wish_fulfilled.connect(_on_wish_fulfilled)
	wish_engine.project_merged.connect(_on_project_merged)
	wish_engine.game_created.connect(_on_game_created)

func _process(delta):
	# Handle notification timeout
	if notification_visible:
		notification_timer -= delta
		if notification_timer <= 0:
			notification_panel.visible = false
			notification_visible = false

func _on_command_submitted(text: String):
	if text.strip_edges() == "":
		return
	
	# Add to history
	command_history.append(text)
	if command_history.size() > max_history:
		command_history.pop_front()
	history_position = command_history.size()
	
	# Execute command
	_execute_command(text)
	
	# Clear input
	command_input.text = ""

func _execute_command(text: String):
	_append_to_terminal("> " + text)
	
	if text == "clear" or text == "cls":
		terminal_output.text = ""
		return
	
	if text == "exit" or text == "quit":
		_append_to_terminal("Use 'back' to exit or close this window")
		return
	
	# Check for built-in terminal commands first
	if _handle_terminal_command(text):
		return
	
	# Pass to wish engine
	var result = wish_engine.execute_command(text)
	
	# Update terminal with the result (if any)
	if result != "":
		_append_to_terminal(result)
	
	# Update context
	if wish_engine.active_account_id != context.account:
		context.account = wish_engine.active_account_id
		_update_status_bar()
	
	if wish_engine.active_project_id != context.project:
		context.project = wish_engine.active_project_id
		_update_status_bar()
	
	# Update dimension from turn cycle
	if eden_os_main and eden_os_main.turn_cycle_manager:
		var turn_number = eden_os_main.turn_cycle_manager.current_turn
		if turn_number > 0:
			var current_color = eden_os_main.turn_cycle_manager.turn_color_mapping[turn_number - 1]
			var dimension = eden_os_main.dimensional_color_system.color_properties[current_color].dimensional_depth
			if dimension != context.dimension:
				context.dimension = dimension
				_update_status_bar()

func _handle_terminal_command(text: String) -> bool:
	var parts = text.split(" ")
	if parts.size() == 0:
		return false
	
	var cmd = parts[0].to_lower()
	var args = parts.slice(1)
	
	match cmd:
		"next":
			if eden_os_main:
				eden_os_main.manual_advance_turn()
				_append_to_terminal("Advanced to next turn")
				_update_status_bar()
			else:
				_append_to_terminal("Eden OS Main not found")
			return true
		
		"dimension":
			if args.size() > 0:
				if args[0].is_valid_int():
					var dim = int(args[0])
					if dim >= 1 and dim <= 9:
						_set_active_dimension(dim)
						_append_to_terminal("Set active dimension to: " + str(dim))
						_update_status_bar()
					else:
						_append_to_terminal("Invalid dimension. Must be 1-9")
				else:
					_append_to_terminal("Usage: dimension <1-9>")
			else:
				_append_to_terminal("Current dimension: " + str(context.dimension))
			return true
		
		"back":
			if get_parent():
				queue_free()
			return true
		
		"status":
			_update_status_bar()
			_append_to_terminal("Account: " + _get_account_name())
			_append_to_terminal("Project: " + _get_project_name())
			_append_to_terminal("Dimension: " + str(context.dimension))
			return true
	
	return false

func _append_to_terminal(text: String):
	# Append text to terminal output
	if terminal_output.text != "":
		terminal_output.text += "\n" + text
	else:
		terminal_output.text = text
	
	# Auto-scroll
	if auto_scroll:
		terminal_output.scroll_vertical = 999999

func _update_status_bar():
	var status_text = "Account: " + _get_account_name() + " | "
	status_text += "Project: " + _get_project_name() + " | "
	status_text += "Dimension: " + str(context.dimension)
	
	if eden_os_main and eden_os_main.turn_cycle_manager:
		status_text += " | Turn: " + str(eden_os_main.turn_cycle_manager.current_turn) + "/12"
	
	status_bar.text = status_text

func _get_account_name() -> String:
	if context.account == "":
		return "None"
	
	if wish_engine.accounts.has(context.account):
		return wish_engine.accounts[context.account].name
	
	return "Unknown"

func _get_project_name() -> String:
	if context.project == "":
		return "None"
	
	if wish_engine.projects.has(context.project):
		return wish_engine.projects[context.project].title
	
	return "Unknown"

func _set_active_dimension(dimension: int):
	context.dimension = dimension
	
	# Update relevant systems
	if eden_os_main:
		if eden_os_main.shape_system:
			# Update shape visualizer to show the selected dimension
			# This would need to be implemented in the shape system
			pass
		
		if eden_os_main.paint_system:
			# Set the paint system to the selected dimension
			eden_os_main.paint_system.set_brush_dimension(dimension)

func _show_notification(title: String, message: String):
	notification_panel.get_node("Title").text = title
	notification_panel.get_node("Message").text = message
	notification_panel.visible = true
	notification_visible = true
	notification_timer = notification_duration

func _on_wish_created(wish_id, wish_type, strength):
	if not wish_engine.wishes.has(wish_id):
		return
	
	var wish = wish_engine.wishes[wish_id]
	
	# Show notification
	_show_notification(
		"Wish Created",
		wish.content + "\nStrength: " + str(strength)
	)

func _on_wish_fulfilled(wish_id, result_type, output):
	if not wish_engine.wishes.has(wish_id):
		return
	
	var wish = wish_engine.wishes[wish_id]
	
	# Show notification
	_show_notification(
		"Wish Fulfilled",
		wish.content + "\nResult: " + WishEngine.ResultType.keys()[result_type]
	)

func _on_project_merged(project_ids, wish_ids, new_project_id):
	if not wish_engine.projects.has(new_project_id):
		return
	
	var project = wish_engine.projects[new_project_id]
	
	# Show notification
	_show_notification(
		"Projects Merged",
		"Created: " + project.title + "\nMerged " + str(project_ids.size()) + " projects"
	)

func _on_game_created(game_id, title, genre):
	if not wish_engine.games.has(game_id):
		return
	
	var game = wish_engine.games[game_id]
	
	# Show notification
	_show_notification(
		"Game Created",
		game.title + "\nGenre: " + WishEngine.GameGenre.keys()[genre]
	)

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_UP:
				_navigate_history(-1)
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_DOWN:
				_navigate_history(1)
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_TAB:
				_autocomplete()
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_ESCAPE:
				# Clear command input
				command_input.text = ""
				get_viewport().set_input_as_handled()

func _navigate_history(direction: int):
	if command_history.size() == 0:
		return
	
	history_position += direction
	
	if history_position < 0:
		history_position = 0
	elif history_position >= command_history.size():
		history_position = command_history.size()
		command_input.text = ""
		return
	
	command_input.text = command_history[history_position]
	# Move cursor to end
	command_input.caret_column = command_input.text.length()

func _autocomplete():
	var text = command_input.text
	var cursor_pos = command_input.caret_column
	
	# Simple autocomplete for common commands
	var common_commands = [
		"help", "list", "create", "merge", "wish", "use", "game", "clear",
		"next", "dimension", "status"
	]
	
	var common_subcommands = {
		"list": ["wishes", "projects", "accounts", "games", "all"],
		"create": ["project", "account"],
		"merge": ["projects", "accounts"],
		"use": ["account", "project"],
		"game": ["create", "fromwish", "show"]
	}
	
	# Get the word at cursor
	var word_start = cursor_pos
	while word_start > 0 and text[word_start - 1] != " ":
		word_start -= 1
	
	var current_word = text.substr(word_start, cursor_pos - word_start)
	var word_prefix = current_word.to_lower()
	
	# Get the command prefix if any
	var command_prefix = ""
	var parts = text.substr(0, word_start).split(" ")
	if parts.size() > 0:
		command_prefix = parts[0].to_lower()
	
	# Generate completion candidates
	var candidates = []
	
	if word_start == 0:
		# Complete main command
		for cmd in common_commands:
			if cmd.begins_with(word_prefix):
				candidates.append(cmd)
	elif common_subcommands.has(command_prefix):
		# Complete subcommand
		for subcmd in common_subcommands[command_prefix]:
			if subcmd.begins_with(word_prefix):
				candidates.append(subcmd)
	
	# Apply completion if we have exactly one candidate
	if candidates.size() == 1:
		var completion = candidates[0]
		command_input.text = text.substr(0, word_start) + completion + text.substr(cursor_pos)
		command_input.caret_column = word_start + completion.length()
	elif candidates.size() > 1:
		# Show all candidates
		_append_to_terminal("Completions: " + ", ".join(candidates))

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		queue_free()