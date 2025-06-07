extends Node

# Integrated Terminal System
# Combines all terminal subsystems:
# - Terminal Memory System
# - Concurrent Processor
# - Drive Connector
# - Terminal Symbols

# For the bottom terminal evolution with enhanced command support

class_name IntegratedTerminal

# Terminal UI elements
var terminal: RichTextLabel
var input_field: LineEdit
var terminal_container: Control

# Terminal systems
var memory_system
var concurrent_processor
var drive_connector
var symbol_system

# Terminal properties
var terminal_width = 80
var terminal_height = 24
var command_history = []
var command_index = -1
var terminal_colors = {
	"default": Color(0.9, 0.9, 0.9),
	"past": Color(0.6, 0.6, 0.9),
	"present": Color(0.9, 0.9, 0.9),
	"future": Color(0.9, 0.6, 0.6),
	"sad": Color(0.5, 0.5, 0.7),
	"system": Color(0.7, 0.9, 0.7),
	"error": Color(1.0, 0.5, 0.5),
	"command": Color(0.9, 0.9, 0.6)
}

# Current turn tracking
var current_turn = 1
var max_turns = 12
var turn_auto_advance = false

# Signal for turns
signal turn_changed(turn_number)
signal turns_completed()

func _ready():
	# Initialize the UI elements
	setup_terminal_ui()
	
	# Initialize subsystems
	initialize_subsystems()
	
	# Connect signals
	connect_signals()
	
	# Welcome message
	add_text("Integrated Terminal System v1.0", "system")
	add_text("Type #help for available commands", "system")
	add_text("Current turn: " + str(current_turn) + "/" + str(max_turns), "system")
	
	# Show command prompt
	show_prompt()

# Set up the terminal UI
func setup_terminal_ui():
	terminal_container = Control.new()
	terminal_container.rect_min_size = Vector2(800, 500)
	add_child(terminal_container)
	
	terminal = RichTextLabel.new()
	terminal.rect_min_size = Vector2(800, 470)
	terminal.bbcode_enabled = true
	terminal.scroll_following = true
	terminal_container.add_child(terminal)
	
	input_field = LineEdit.new()
	input_field.rect_min_size = Vector2(800, 30)
	input_field.rect_position = Vector2(0, 470)
	input_field.connect("text_entered", self, "_on_text_entered")
	terminal_container.add_child(input_field)
	
	# Set focus to input field
	input_field.grab_focus()

# Initialize all subsystems
func initialize_subsystems():
	# Initialize Memory System
	memory_system = load("res://12_turns_system/terminal_memory_system.gd").new()
	add_child(memory_system)
	
	# Get reference to Concurrent Processor
	concurrent_processor = memory_system.processor
	
	# Initialize Drive Connector
	drive_connector = load("res://12_turns_system/drive_connector.gd").new()
	add_child(drive_connector)
	
	# Initialize Symbol System
	symbol_system = load("res://12_turns_system/terminal_symbols.gd").new()
	add_child(symbol_system)
	
	# Connect systems
	drive_connector.terminal_memory = memory_system
	symbol_system.terminal_memory = memory_system

# Connect signals
func connect_signals():
	# Connect to internal signals
	connect("turn_changed", self, "_on_turn_changed")
	connect("turns_completed", self, "_on_turns_completed")
	
	# Connect to memory system signals if needed
	
	# Connect to drive connector signals
	drive_connector.connect("drive_connected", self, "_on_drive_connected")
	drive_connector.connect("drive_disconnected", self, "_on_drive_disconnected")
	drive_connector.connect("sync_completed", self, "_on_sync_completed")
	drive_connector.connect("sync_failed", self, "_on_sync_failed")

# Process text input
func _on_text_entered(text):
	if text.empty():
		show_prompt()
		return
	
	# Add to command history
	command_history.append(text)
	command_index = -1
	
	# Display the command
	add_text("> " + text, "command")
	
	# Clear input field
	input_field.text = ""
	
	# Process the command
	process_command(text)
	
	# Show prompt
	show_prompt()

# Show command prompt
func show_prompt():
	# You could customize this with current turn, etc.
	input_field.placeholder_text = "[" + str(current_turn) + "/" + str(max_turns) + "] > "
	input_field.grab_focus()

# Add text to terminal with formatting
func add_text(text, category="default"):
	var color = terminal_colors.default
	
	if category in terminal_colors:
		color = terminal_colors[category]
	
	# Apply auto-wrapping if needed
	var wrapped_text = auto_wrap_text(text, terminal_width)
	
	# Process symbols if it's a system or command message
	if category in ["system", "command"]:
		wrapped_text = symbol_system.format_message(wrapped_text)
	
	# Add to terminal
	terminal.append_bbcode("[color=#" + color.to_html() + "]" + wrapped_text + "[/color]\n")
	
	# Also add to memory system
	memory_system.add_memory_text(text, category)

# Auto-wrap text to fit terminal width
func auto_wrap_text(text, width):
	var wrapped = ""
	var line = ""
	var words = text.split(" ")
	
	for word in words:
		if line.length() + word.length() + 1 <= width:
			if line.empty():
				line = word
			else:
				line += " " + word
		else:
			wrapped += line + "\n"
			line = word
	
	if not line.empty():
		wrapped += line
		
	return wrapped

# Process a command
func process_command(command):
	# Check for empty command
	if command.empty():
		return
	
	# Normalize command text
	command = command.strip_edges()
	
	# Check for special command prefixes
	if command.begins_with("#"):
		# Check for system level commands
		if command.begins_with("###"):
			process_system_command(command.substr(3).strip_edges())
		# Check for advanced commands
		elif command.begins_with("##"):
			process_advanced_command(command.substr(2).strip_edges())
		# Regular commands
		else:
			process_basic_command(command.substr(1).strip_edges())
	else:
		# Regular text input - treat as memory entry
		process_text_input(command)
	
	# Always check for turn advancement after processing a command
	check_turn_advancement()

# Process basic # commands
func process_basic_command(command):
	var parts = command.split(" ", true, 1)
	var cmd = parts[0].to_lower()
	var args = parts[1] if parts.size() > 1 else ""
	
	match cmd:
		"help":
			display_help()
		"turn":
			process_turn_command(args)
		"memory", "mem":
			memory_system.process_command("#" + args)
		"drive", "drives":
			drive_connector.process_command("#" + args)
		"symbol", "symbols":
			symbol_system.process_command("#" + args)
		"run":
			memory_system.process_command("#" + args)
		"chain":
			memory_system.process_command("#" + args)
		"clear":
			clear_terminal()
		"exit", "quit":
			add_text("Terminal session cannot be terminated in this mode.", "error")
		_:
			# Check if it's a command for one of our subsystems
			if memory_system.process_command("#" + command) or \
			   drive_connector.process_command("#" + command) or \
			   symbol_system.process_command("#" + command):
				pass
			else:
				add_text("Unknown command: " + cmd, "error")

# Process advanced ## commands
func process_advanced_command(command):
	var parts = command.split(" ", true, 1)
	var cmd = parts[0].to_lower()
	var args = parts[1] if parts.size() > 1 else ""
	
	match cmd:
		"help":
			display_advanced_help()
		"turn":
			process_advanced_turn_command(args)
		"memory", "mem":
			memory_system.process_command("##" + args)
		"drive", "drives":
			drive_connector.process_command("##" + args)
		"symbol", "symbols":
			symbol_system.process_command("##" + args)
		"color", "colors":
			set_terminal_colors(args)
		"dimensions":
			display_dimensions()
		_:
			# Check if it's a command for one of our subsystems
			if memory_system.process_command("##" + command) or \
			   drive_connector.process_command("##" + command) or \
			   symbol_system.process_command("##" + command):
				pass
			else:
				add_text("Unknown advanced command: " + cmd, "error")

# Process system ### commands
func process_system_command(command):
	var parts = command.split(" ", true, 1)
	var cmd = parts[0].to_lower()
	var args = parts[1] if parts.size() > 1 else ""
	
	match cmd:
		"help":
			display_system_help()
		"turn":
			process_system_turn_command(args)
		"memory", "mem":
			memory_system.process_command("###" + args)
		"drive", "drives":
			drive_connector.process_command("###" + args)
		"symbol", "symbols":
			symbol_system.process_command("###" + args)
		"reset":
			reset_terminal()
		"concurrent":
			set_concurrent_tasks(args)
		"export":
			export_terminal_state(args)
		"import":
			import_terminal_state(args)
		"evolution":
			evolve_terminal(args)
		_:
			# Check if it's a command for one of our subsystems
			if memory_system.process_command("###" + command) or \
			   drive_connector.process_command("###" + command) or \
			   symbol_system.process_command("###" + command):
				pass
			else:
				add_text("Unknown system command: " + cmd, "error")

# Process regular text input
func process_text_input(text):
	# Check for TDIC temporal markers
	if text.begins_with("[past]") or text.begins_with("[present]") or text.begins_with("[future]"):
		memory_system.process_tdic_entry(text)
	else:
		memory_system.add_memory_text(text)

# Turn management commands
func process_turn_command(args):
	var parts = args.split(" ", true, 1)
	
	if parts.size() < 1:
		add_text("Current turn: " + str(current_turn) + "/" + str(max_turns), "system")
		return
		
	var subcmd = parts[0].to_lower()
	var subargs = parts[1] if parts.size() > 1 else ""
	
	match subcmd:
		"next", "advance":
			advance_turn()
		"auto":
			toggle_auto_advance(subargs)
		"set":
			set_turn(subargs)
		"max":
			set_max_turns(subargs)
		"reset":
			reset_turns()
		"status":
			display_turn_status()
		_:
			add_text("Unknown turn command: " + subcmd, "error")

# Advanced turn commands
func process_advanced_turn_command(args):
	var parts = args.split(" ", true, 1)
	
	if parts.size() < 1:
		add_text("Current turn: " + str(current_turn) + "/" + str(max_turns), "system")
		return
		
	var subcmd = parts[0].to_lower()
	var subargs = parts[1] if parts.size() > 1 else ""
	
	match subcmd:
		"skip":
			skip_turns(subargs)
		"interval":
			set_auto_interval(subargs)
		"save":
			save_turn_state(subargs)
		"load":
			load_turn_state(subargs)
		_:
			add_text("Unknown advanced turn command: " + subcmd, "error")

# System turn commands
func process_system_turn_command(args):
	var parts = args.split(" ", true, 1)
	
	if parts.size() < 1:
		add_text("Current turn: " + str(current_turn) + "/" + str(max_turns), "system")
		return
		
	var subcmd = parts[0].to_lower()
	var subargs = parts[1] if parts.size() > 1 else ""
	
	match subcmd:
		"cycle":
			restart_turn_cycle()
		"export":
			export_turn_data(subargs)
		"import":
			import_turn_data(subargs)
		_:
			add_text("Unknown system turn command: " + subcmd, "error")

# Advance to next turn
func advance_turn():
	if current_turn < max_turns:
		current_turn += 1
		add_text("Advanced to turn " + str(current_turn) + "/" + str(max_turns), "system")
		emit_signal("turn_changed", current_turn)
		
		# Save state automatically
		save_turn_state("auto_" + str(current_turn))
	else:
		add_text("Maximum turns reached (" + str(max_turns) + ").", "system")
		emit_signal("turns_completed")

# Toggle auto turn advancement
func toggle_auto_advance(enabled=""):
	if enabled.empty():
		turn_auto_advance = !turn_auto_advance
	else:
		turn_auto_advance = (enabled.to_lower() == "on" or enabled.to_lower() == "true")
	
	add_text("Auto turn advancement: " + ("ON" if turn_auto_advance else "OFF"), "system")

# Set current turn
func set_turn(turn_number):
	var new_turn = int(turn_number)
	
	if new_turn >= 1 and new_turn <= max_turns:
		current_turn = new_turn
		add_text("Set current turn to: " + str(current_turn) + "/" + str(max_turns), "system")
		emit_signal("turn_changed", current_turn)
	else:
		add_text("Invalid turn number. Must be between 1 and " + str(max_turns) + ".", "error")

# Set maximum turns
func set_max_turns(max_turn_count):
	var new_max = int(max_turn_count)
	
	if new_max >= current_turn and new_max > 0:
		max_turns = new_max
		add_text("Set maximum turns to: " + str(max_turns), "system")
	else:
		add_text("Invalid maximum turn count. Must be at least " + str(current_turn) + ".", "error")

# Reset turn counter
func reset_turns():
	current_turn = 1
	add_text("Turn counter reset to 1/" + str(max_turns), "system")
	emit_signal("turn_changed", current_turn)

# Display turn status
func display_turn_status():
	add_text("Turn Status:", "system")
	add_text("- Current turn: " + str(current_turn) + "/" + str(max_turns), "system")
	add_text("- Auto advance: " + ("ON" if turn_auto_advance else "OFF"), "system")
	
	var progress = float(current_turn) / float(max_turns)
	var progress_bar = symbol_system.format_progress_bar(progress, 20)
	add_text("- Progress: " + progress_bar, "system")

# Skip multiple turns
func skip_turns(count):
	var skip_count = int(count)
	
	if skip_count > 0:
		var target_turn = min(current_turn + skip_count, max_turns)
		var turns_skipped = target_turn - current_turn
		
		current_turn = target_turn
		add_text("Skipped " + str(turns_skipped) + " turns. Now at turn " + str(current_turn) + "/" + str(max_turns), "system")
		emit_signal("turn_changed", current_turn)
		
		if current_turn >= max_turns:
			emit_signal("turns_completed")
	else:
		add_text("Invalid skip count. Must be positive.", "error")

# Set auto turn interval (not implemented in this mock-up)
func set_auto_interval(interval):
	add_text("Auto interval feature not implemented in this version.", "system")

# Save turn state
func save_turn_state(name):
	if name.empty():
		name = "turn_" + str(current_turn)
	
	add_text("Saving turn state: " + name, "system")
	
	# In a real implementation, this would save the current state to a file
	# For now, we'll just simulate it by adding it to memory
	memory_system.add_memory_text("[Turn Save] Turn " + str(current_turn) + " state saved as '" + name + "'", "system")

# Load turn state
func load_turn_state(name):
	add_text("Loading turn state: " + name, "system")
	
	# In a real implementation, this would load state from a file
	# For now, we'll just simulate it
	memory_system.add_memory_text("[Turn Load] Loaded turn state '" + name + "'", "system")

# Restart turn cycle
func restart_turn_cycle():
	add_text("Restarting turn cycle...", "system")
	
	# Save current state before restart
	save_turn_state("before_restart")
	
	# Reset turns
	reset_turns()
	
	add_text("Turn cycle restarted. Beginning new 12-turn cycle.", "system")

# Export turn data
func export_turn_data(path):
	add_text("Exporting turn data to: " + path, "system")
	
	# In a real implementation, this would export data to a file
	# For now, we'll just simulate it
	add_text("Turn data exported successfully.", "system")

# Import turn data
func import_turn_data(path):
	add_text("Importing turn data from: " + path, "system")
	
	# In a real implementation, this would import data from a file
	# For now, we'll just simulate it
	add_text("Turn data imported successfully.", "system")

# Check if we should advance turns
func check_turn_advancement():
	if turn_auto_advance and current_turn < max_turns:
		# In a real implementation, this would use a timer
		# For now, we'll just simulate it with a yield
		add_text("Auto-advancing to next turn in 3 seconds...", "system")
		yield(get_tree().create_timer(3.0), "timeout")
		advance_turn()

# Color commands
func set_terminal_colors(theme):
	match theme:
		"default":
			terminal_colors.default = Color(0.9, 0.9, 0.9)
			terminal_colors.past = Color(0.6, 0.6, 0.9)
			terminal_colors.present = Color(0.9, 0.9, 0.9)
			terminal_colors.future = Color(0.9, 0.6, 0.6)
			terminal_colors.system = Color(0.7, 0.9, 0.7)
			terminal_colors.error = Color(1.0, 0.5, 0.5)
			terminal_colors.command = Color(0.9, 0.9, 0.6)
		"sad":
			# Sad colors palette
			terminal_colors.default = Color(0.5, 0.5, 0.7)
			terminal_colors.past = Color(0.4, 0.4, 0.6)
			terminal_colors.present = Color(0.5, 0.5, 0.7)
			terminal_colors.future = Color(0.6, 0.4, 0.5)
			terminal_colors.system = Color(0.4, 0.6, 0.5)
			terminal_colors.error = Color(0.7, 0.4, 0.4)
			terminal_colors.command = Color(0.6, 0.6, 0.5)
		"dark":
			# Dark theme
			terminal_colors.default = Color(0.7, 0.7, 0.7)
			terminal_colors.past = Color(0.4, 0.4, 0.7)
			terminal_colors.present = Color(0.7, 0.7, 0.7)
			terminal_colors.future = Color(0.7, 0.4, 0.4)
			terminal_colors.system = Color(0.4, 0.7, 0.4)
			terminal_colors.error = Color(0.9, 0.3, 0.3)
			terminal_colors.command = Color(0.7, 0.7, 0.4)
		"bright":
			# Bright theme
			terminal_colors.default = Color(1.0, 1.0, 1.0)
			terminal_colors.past = Color(0.7, 0.7, 1.0)
			terminal_colors.present = Color(1.0, 1.0, 1.0)
			terminal_colors.future = Color(1.0, 0.7, 0.7)
			terminal_colors.system = Color(0.7, 1.0, 0.7)
			terminal_colors.error = Color(1.0, 0.5, 0.5)
			terminal_colors.command = Color(1.0, 1.0, 0.7)
		_:
			add_text("Unknown color theme: " + theme, "error")
			return
	
	add_text("Terminal color theme changed to: " + theme, "system")

# Clear the terminal
func clear_terminal():
	terminal.clear()
	add_text("Terminal cleared.", "system")

# Reset terminal
func reset_terminal():
	terminal.clear()
	memory_system.reset_system()
	reset_turns()
	add_text("Terminal reset complete.", "system")

# Set concurrent tasks
func set_concurrent_tasks(count):
	var task_count = int(count)
	if task_count >= 1 and task_count <= 5:
		concurrent_processor.set_max_concurrent_tasks(task_count)
		add_text("Concurrent tasks set to: " + str(task_count), "system")
	else:
		add_text("Invalid concurrent task count. Must be between 1 and 5.", "error")

# Export terminal state
func export_terminal_state(path):
	add_text("Exporting terminal state to: " + path, "system")
	
	# In a real implementation, this would export data to a file
	# For now, we'll just simulate it
	add_text("Terminal state exported successfully.", "system")

# Import terminal state
func import_terminal_state(path):
	add_text("Importing terminal state from: " + path, "system")
	
	# In a real implementation, this would import data from a file
	# For now, we'll just simulate it
	add_text("Terminal state imported successfully.", "system")

# Evolve terminal (bottom evolution as requested)
func evolve_terminal(evolution_type):
	add_text("Evolving terminal: " + evolution_type, "system")
	add_text("Terminal evolution in progress...", "system")
	
	# Show fancy progress animation
	for i in range(5):
		yield(get_tree().create_timer(0.3), "timeout")
		add_text(symbol_system.generate_symbol_pattern("▪ ", 20), "system")
	
	match evolution_type:
		"bottom":
			add_text("Terminal bottom evolution complete!", "system")
			add_text("Added 4 more lines down for expanded view.", "system")
			terminal.rect_min_size.y += 100
			input_field.rect_position.y += 100
		"split":
			add_text("Terminal split evolution complete!", "system")
			add_text("Terminal now supports split screen mode.", "system")
		"emoji":
			add_text("Terminal emoji evolution complete!", "system")
			add_text("Enhanced emoji support with Pokémon themes! " + symbol_system.get_symbol("pikachu", "pokemon"), "system")
		"crooked":
			add_text("Terminal crooked evolution complete!", "system")
			add_text("Special <> crooked symbols mode enabled.", "system")
		_:
			add_text("Unknown evolution type: " + evolution_type, "error")
			return
	
	add_text("Terminal has evolved to its next form!", "system")

# Display dimensions
func display_dimensions():
	var dimensions = [
		{"name": "Physical", "symbol": symbol_system.get_symbol("physical", "dimensions"), "desc": "The tangible world of matter"},
		{"name": "Digital", "symbol": symbol_system.get_symbol("digital", "dimensions"), "desc": "The realm of data and information"},
		{"name": "Temporal", "symbol": symbol_system.get_symbol("temporal", "dimensions"), "desc": "The flow of time and memory"},
		{"name": "Conceptual", "symbol": symbol_system.get_symbol("conceptual", "dimensions"), "desc": "The space of ideas and abstractions"},
		{"name": "Quantum", "symbol": symbol_system.get_symbol("quantum", "dimensions"), "desc": "The underlying fabric of possibilities"}
	]
	
	add_text(symbol_system.format_header("Dimensional Analysis", 60), "system")
	
	for dim in dimensions:
		add_text(dim.symbol + " " + dim.name + " Dimension", "system")
		add_text("   - " + dim.desc, "system")
	
	add_text(symbol_system.generate_symbol_pattern("─", 60), "system")

# Display help
func display_help():
	add_text(symbol_system.format_header("Terminal Help", 60), "system")
	add_text("Basic Commands:", "system")
	add_text("  #help - Display this help", "system")
	add_text("  #turn [next|auto|set|max|reset|status] - Manage turns", "system")
	add_text("  #memory/#mem [command] - Memory system commands", "system")
	add_text("  #drive/#drives [command] - Drive connector commands", "system")
	add_text("  #symbol/#symbols [command] - Symbol system commands", "system")
	add_text("  #run [func1,func2,func3] - Run multiple functions in parallel", "system")
	add_text("  #chain [func1,func2,func3] - Run functions in sequence", "system")
	add_text("  #clear - Clear terminal display", "system")
	add_text("", "system")
	add_text("For advanced commands, type ##help", "system")
	add_text("For system commands, type ###help", "system")
	add_text("", "system")
	add_text("TDIC Temporal Markers:", "system")
	add_text("  [past] Text... - Mark entry as past memory", "system")
	add_text("  [present] Text... - Mark entry as present memory", "system")
	add_text("  [future] Text... - Mark entry as future memory", "system")

# Display advanced help
func display_advanced_help():
	add_text(symbol_system.format_header("Advanced Commands", 60), "system")
	add_text("Advanced Commands (##):", "system")
	add_text("  ##help - Display this help", "system")
	add_text("  ##turn [skip|interval|save|load] - Advanced turn management", "system")
	add_text("  ##memory/##mem [command] - Advanced memory commands", "system")
	add_text("  ##drive/##drives [command] - Advanced drive commands", "system")
	add_text("  ##symbol/##symbols [command] - Advanced symbol commands", "system")
	add_text("  ##color/##colors [theme] - Set terminal color theme", "system")
	add_text("  ##dimensions - Display information about dimensions", "system")

# Display system help
func display_system_help():
	add_text(symbol_system.format_header("System Commands", 60), "system")
	add_text("System Commands (###):", "system")
	add_text("  ###help - Display this help", "system")
	add_text("  ###turn [cycle|export|import] - System turn management", "system")
	add_text("  ###memory/###mem [command] - System memory commands", "system")
	add_text("  ###drive/###drives [command] - System drive commands", "system")
	add_text("  ###symbol/###symbols [command] - System symbol commands", "system")
	add_text("  ###reset - Reset the terminal", "system")
	add_text("  ###concurrent [count] - Set concurrent task count (1-5)", "system")
	add_text("  ###export [path] - Export terminal state", "system")
	add_text("  ###import [path] - Import terminal state", "system")
	add_text("  ###evolution [type] - Evolve the terminal", "system")

# Signal handlers
func _on_turn_changed(turn_number):
	# This is called when the turn changes
	# You could add custom logic here
	pass

func _on_turns_completed():
	add_text("All 12 turns completed. The cycle is finished.", "system")
	add_text("Take a break for reflection before starting a new cycle.", "system")

func _on_drive_connected(drive_name):
	add_text("Drive connected: " + drive_name, "system")

func _on_drive_disconnected(drive_name):
	add_text("Drive disconnected: " + drive_name, "system")

func _on_sync_completed(drive_name):
	add_text("Drive sync completed: " + drive_name, "system")

func _on_sync_failed(drive_name, error):
	add_text("Drive sync failed: " + drive_name + " (" + error + ")", "error")

# Input handling for command history
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_UP:
				navigate_history_up()
			KEY_DOWN:
				navigate_history_down()

# Navigate command history upward
func navigate_history_up():
	if command_history.size() > 0:
		if command_index < command_history.size() - 1:
			command_index += 1
			input_field.text = command_history[command_history.size() - 1 - command_index]
			input_field.caret_position = input_field.text.length()

# Navigate command history downward
func navigate_history_down():
	if command_index > 0:
		command_index -= 1
		input_field.text = command_history[command_history.size() - 1 - command_index]
		input_field.caret_position = input_field.text.length()
	elif command_index == 0:
		command_index = -1
		input_field.text = ""