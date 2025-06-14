extends Control
class_name CreativeCommandCenter

# UI Components
var terminal_input: LineEdit
var terminal_output: RichTextLabel
var visualization_view: SubViewport
var command_history: ItemList
var status_bar: Label
var mode_selector: OptionButton
var api_selector: OptionButton

# References to other systems
var openai_gateway = null
var idea_visualizer = null
var memory_manager = null
var word_translator = null

# Command history
var command_history_list: Array = []
var command_history_index: int = -1

# Current state
var current_command_mode: String = "creative"  # creative, terminal, hybrid
var last_command_result: String = ""
var working_directory: String = "/"
var api_in_use: String = "openai"  # openai, claude, gemini

# Command prefixes
const CREATIVE_PREFIX = "c:"
const TERMINAL_PREFIX = "t:"
const HYBRID_PREFIX = "h:"
const VISUALIZE_PREFIX = "v:"

# Signals
signal command_executed(command, result)
signal mode_changed(new_mode)
signal api_changed(new_api)
signal command_error(error_message)

func _ready():
	# Set up UI components
	_setup_ui()
	
	# Connect to required systems
	_connect_to_systems()
	
	# Set up command handlers
	_register_command_handlers()
	
	# Initialize default state
	set_command_mode("creative")
	_update_status()
	
	# Show welcome message
	_display_welcome_message()

func _setup_ui():
	# Create main layout
	var main_layout = VBoxContainer.new()
	main_layout.name = "MainLayout"
	main_layout.anchor_right = 1.0
	main_layout.anchor_bottom = 1.0
	add_child(main_layout)
	
	# Create top bar with mode & API selectors
	var top_bar = HBoxContainer.new()
	top_bar.name = "TopBar"
	main_layout.add_child(top_bar)
	
	# Mode selector
	var mode_label = Label.new()
	mode_label.text = "Mode:"
	top_bar.add_child(mode_label)
	
	mode_selector = OptionButton.new()
	mode_selector.add_item("Creative", 0)
	mode_selector.add_item("Terminal", 1)
	mode_selector.add_item("Hybrid", 2)
	mode_selector.add_item("Visualize", 3)
	mode_selector.select(0)
	top_bar.add_child(mode_selector)
	mode_selector.item_selected.connect(_on_mode_selected)
	
	# Add spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)
	
	# API selector
	var api_label = Label.new()
	api_label.text = "API:"
	top_bar.add_child(api_label)
	
	api_selector = OptionButton.new()
	api_selector.add_item("OpenAI", 0)
	api_selector.add_item("Claude", 1)
	api_selector.add_item("Gemini", 2)
	api_selector.select(0)
	top_bar.add_child(api_selector)
	api_selector.item_selected.connect(_on_api_selected)
	
	# Create middle content area with split view
	var content_split = HSplitContainer.new()
	content_split.name = "ContentSplit"
	content_split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_layout.add_child(content_split)
	
	# Left side: Terminal output and history
	var left_panel = VBoxContainer.new()
	left_panel.name = "LeftPanel"
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_split.add_child(left_panel)
	
	terminal_output = RichTextLabel.new()
	terminal_output.name = "TerminalOutput"
	terminal_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	terminal_output.bbcode_enabled = true
	terminal_output.scroll_following = true
	left_panel.add_child(terminal_output)
	
	command_history = ItemList.new()
	command_history.name = "CommandHistory"
	command_history.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	command_history.custom_minimum_size = Vector2(0, 150)
	command_history.item_selected.connect(_on_history_item_selected)
	left_panel.add_child(command_history)
	
	# Right side: Visualization view
	var right_panel = VBoxContainer.new()
	right_panel.name = "RightPanel"
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_split.add_child(right_panel)
	
	var visualization_label = Label.new()
	visualization_label.text = "Visualization"
	right_panel.add_child(visualization_label)
	
	var viewport_container = SubViewportContainer.new()
	viewport_container.name = "ViewportContainer"
	viewport_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	viewport_container.stretch = true
	right_panel.add_child(viewport_container)
	
	visualization_view = SubViewport.new()
	visualization_view.name = "VisualizationView"
	visualization_view.size = Vector2(400, 400)
	visualization_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport_container.add_child(visualization_view)
	
	# Add 3D environment to viewport
	var world_environment = WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	
	var environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.05, 0.05, 0.05)
	environment.ambient_light_color = Color(0.2, 0.2, 0.3)
	environment.ambient_light_energy = 1.0
	environment.ssao_enabled = true
	environment.glow_enabled = true
	
	world_environment.environment = environment
	visualization_view.add_child(world_environment)
	
	# Add camera
	var camera = Camera3D.new()
	camera.name = "Camera"
	camera.position = Vector3(0, 0, 10)
	camera.current = true
	visualization_view.add_child(camera)
	
	# Add lighting
	var light = DirectionalLight3D.new()
	light.name = "DirectionalLight"
	light.position = Vector3(10, 10, 10)
	light.look_at(Vector3.ZERO)
	visualization_view.add_child(light)
	
	# Bottom bar: Command input and status
	var bottom_bar = VBoxContainer.new()
	bottom_bar.name = "BottomBar"
	main_layout.add_child(bottom_bar)
	
	# Status bar
	status_bar = Label.new()
	status_bar.name = "StatusBar"
	status_bar.text = "Ready - Creative Mode"
	bottom_bar.add_child(status_bar)
	
	# Command input
	var input_container = HBoxContainer.new()
	input_container.name = "InputContainer"
	bottom_bar.add_child(input_container)
	
	var input_label = Label.new()
	input_label.text = "c> "
	input_label.name = "InputLabel"
	input_container.add_child(input_label)
	
	terminal_input = LineEdit.new()
	terminal_input.name = "TerminalInput"
	terminal_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	terminal_input.placeholder_text = "Enter creative command..."
	terminal_input.text_submitted.connect(_on_command_submitted)
	input_container.add_child(terminal_input)
	
	# Get focus to the input
	terminal_input.grab_focus()

func _connect_to_systems():
	# Connect to OpenAI Gateway
	openai_gateway = get_node_or_null("/root/OpenAIGateway")
	if not openai_gateway:
		var gateway_instance = load("res://scripts/api/OpenAIGateway.gd").new()
		gateway_instance.name = "OpenAIGateway"
		get_tree().root.add_child(gateway_instance)
		openai_gateway = gateway_instance
	
	openai_gateway.request_completed.connect(_on_api_response)
	openai_gateway.request_error.connect(_on_api_error)
	
	# Create and connect to IdeaVisualizer
	var visualizer_scene = load("res://scripts/creative/IdeaVisualizer.gd")
	idea_visualizer = visualizer_scene.new()
	idea_visualizer.name = "IdeaVisualizer"
	visualization_view.add_child(idea_visualizer)
	
	idea_visualizer.visualization_complete.connect(_on_visualization_complete)
	idea_visualizer.word_selected.connect(_on_word_selected)
	
	# Connect to memory manager if available
	memory_manager = get_node_or_null("/root/MemoryEvolutionManager")
	if memory_manager:
		memory_manager.word_caught.connect(_on_word_caught)
	
	# Connect to word translator if available
	word_translator = get_node_or_null("/root/WordTranslator")

func _register_command_handlers():
	# Register commands for different modes
	# This could be expanded into a more robust command registry system
	pass

func _on_command_submitted(command: String):
	if command.strip_edges() == "":
		return
	
	# Add to history
	_add_to_history(command)
	
	# Process command based on mode
	var result = ""
	
	# Check for explicit mode prefixes
	if command.begins_with(CREATIVE_PREFIX):
		result = _process_creative_command(command.substr(CREATIVE_PREFIX.length()).strip_edges())
	elif command.begins_with(TERMINAL_PREFIX):
		result = _process_terminal_command(command.substr(TERMINAL_PREFIX.length()).strip_edges())
	elif command.begins_with(HYBRID_PREFIX):
		result = _process_hybrid_command(command.substr(HYBRID_PREFIX.length()).strip_edges())
	elif command.begins_with(VISUALIZE_PREFIX):
		result = _process_visualize_command(command.substr(VISUALIZE_PREFIX.length()).strip_edges())
	else:
		# Use current mode
		match current_command_mode:
			"creative":
				result = _process_creative_command(command)
			"terminal":
				result = _process_terminal_command(command)
			"hybrid":
				result = _process_hybrid_command(command)
			"visualize":
				result = _process_visualize_command(command)
	
	# Clear input
	terminal_input.text = ""
	
	# Store result
	last_command_result = result
	
	# Update UI
	_update_status()
	
	# Emit signal
	emit_signal("command_executed", command, result)

func _process_creative_command(command: String) -> String:
	# Process commands for creative mode - sends to API for processing
	_display_output("[b]> " + command + "[/b]", "command")
	
	# Special commands
	if command.begins_with("transform "):
		var word = command.substr("transform ".length()).strip_edges()
		openai_gateway.transform_word(word)
		return "Transforming word: " + word
		
	elif command.begins_with("dialogue "):
		var parts = command.substr("dialogue ".length()).split(" as ")
		if parts.size() >= 2:
			var char_name = parts[1].strip_edges()
			var context = parts[0].strip_edges()
			openai_gateway.generate_dialogue(char_name, context)
			return "Generating dialogue for: " + char_name
			
	elif command.begins_with("describe "):
		var theme = command.substr("describe ".length()).strip_edges()
		openai_gateway.generate_world_description(theme)
		return "Generating world description for: " + theme
		
	elif command.begins_with("keywords "):
		var text = command.substr("keywords ".length()).strip_edges()
		openai_gateway.extract_keywords_from_text(text)
		return "Extracting keywords from text"
	
	# Default: general creative prompt
	openai_gateway.generate_text(command)
	return "Processing creative command..."

func _process_terminal_command(command: String) -> String:
	# Process commands for terminal mode - executes system/file operations
	_display_output("[b]$ " + command + "[/b]", "command")
	
	# Basic terminal commands
	var parts = command.split(" ", false)
	if parts.size() == 0:
		return "Empty command"
	
	var cmd = parts[0].to_lower()
	var args = parts.slice(1)
	
	match cmd:
		"help":
			return _show_terminal_help()
			
		"ls":
			return _list_directory(args)
			
		"cd":
			return _change_directory(args)
			
		"pwd":
			return working_directory
			
		"cat":
			return _cat_file(args)
			
		"echo":
			return " ".join(args)
			
		"clear":
			terminal_output.text = ""
			return "Terminal cleared"
			
		"history":
			return _show_history()
			
		"exit":
			set_command_mode("creative")
			return "Switched to creative mode"
			
		_:
			return "Unknown command: " + cmd

func _process_hybrid_command(command: String) -> String:
	# Process commands that combine creative and terminal functionality
	_display_output("[b]h> " + command + "[/b]", "command")
	
	# Special hybrid commands
	if command.begins_with("connect "):
		var system_name = command.substr("connect ".length()).strip_edges()
		return _connect_to_system(system_name)
		
	elif command.begins_with("process "):
		var file_path = command.substr("process ".length()).strip_edges()
		return _process_file_with_api(file_path)
		
	elif command.begins_with("save "):
		var parts = command.substr("save ".length()).split(" to ")
		if parts.size() >= 2:
			var content = parts[0].strip_edges()
			var file_path = parts[1].strip_edges()
			return _save_to_file(content, file_path)
	
	# If no specific hybrid command matches, try processing it creatively
	// First check if it looks like a terminal command
	if command.begins_with("ls") || command.begins_with("cd") || command.begins_with("cat"):
		return _process_terminal_command(command)
	else:
		// Otherwise treat as creative
		return _process_creative_command(command)

func _process_visualize_command(command: String) -> String:
	# Process commands for visualization mode
	_display_output("[b]v> " + command + "[/b]", "command")
	
	# Special visualization commands
	if command.begins_with("mode "):
		var mode = command.substr("mode ".length()).strip_edges()
		return _set_visualization_mode(mode)
		
	elif command.begins_with("visualize "):
		var words_text = command.substr("visualize ".length()).strip_edges()
		var words = words_text.split(" ")
		idea_visualizer.visualize_keywords(words)
		return "Visualizing: " + words_text
		
	elif command == "clear":
		idea_visualizer.clear_visualization()
		return "Visualization cleared"
		
	elif command.begins_with("extract "):
		var text = command.substr("extract ".length()).strip_edges()
		var keywords = idea_visualizer._extract_simple_keywords(text)
		idea_visualizer.visualize_keywords(keywords)
		return "Extracted and visualized: " + ", ".join(keywords)
	
	# Default: use the command as a theme and generate visualization
	openai_gateway.generate_world_description(command)
	return "Generating visualization for theme: " + command

func _on_api_response(response_data):
	if "choices" in response_data and response_data.choices.size() > 0:
		var content = response_data.choices[0].message.content
		
		# Display the response
		_display_output("\n" + content + "\n", "response")
		
		# If in visualization mode, visualize the response
		if current_command_mode == "visualize":
			var keywords = idea_visualizer._extract_simple_keywords(content)
			idea_visualizer.visualize_keywords(keywords)
	else:
		_display_output("\nReceived empty or invalid response\n", "error")

func _on_api_error(error_message):
	_display_output("\nError: " + error_message + "\n", "error")
	emit_signal("command_error", error_message)

func _on_visualization_complete(word_count):
	_display_output("\nVisualization complete with " + str(word_count) + " words\n", "system")

func _on_word_selected(word_text, word_position, word_properties):
	_display_output("\nSelected word: " + word_text + "\n", "highlight")
	
	# If word translator is available, process the word
	if word_translator:
		var translation = word_translator.translate_word(word_text)
		_display_output("Translation: " + translation + "\n", "system")

func _on_word_caught(source, word):
	_display_output("\nWord caught: " + word + " (from " + source + ")\n", "system")

func _on_mode_selected(index):
	var mode = ""
	match index:
		0: mode = "creative"
		1: mode = "terminal"
		2: mode = "hybrid"
		3: mode = "visualize"
	
	set_command_mode(mode)

func _on_api_selected(index):
	var api = ""
	match index:
		0: api = "openai"
		1: api = "claude"
		2: api = "gemini"
	
	set_api(api)

func _on_history_item_selected(index):
	if index >= 0 && index < command_history_list.size():
		terminal_input.text = command_history_list[index]
		terminal_input.grab_focus()
		terminal_input.caret_column = terminal_input.text.length()

func set_command_mode(mode: String):
	current_command_mode = mode
	
	# Update UI
	var prefix_label = ""
	var placeholder_text = ""
	
	match mode:
		"creative":
			prefix_label = "c> "
			placeholder_text = "Enter creative command..."
			mode_selector.select(0)
		"terminal":
			prefix_label = "$ "
			placeholder_text = "Enter terminal command..."
			mode_selector.select(1)
		"hybrid":
			prefix_label = "h> "
			placeholder_text = "Enter hybrid command..."
			mode_selector.select(2)
		"visualize":
			prefix_label = "v> "
			placeholder_text = "Enter visualization command..."
			mode_selector.select(3)
	
	$MainLayout/BottomBar/InputContainer/InputLabel.text = prefix_label
	terminal_input.placeholder_text = placeholder_text
	
	_update_status()
	
	emit_signal("mode_changed", mode)
	return mode

func set_api(api: String):
	api_in_use = api
	
	# Update selector
	match api:
		"openai": api_selector.select(0)
		"claude": api_selector.select(1)
		"gemini": api_selector.select(2)
	
	_update_status()
	
	emit_signal("api_changed", api)
	return api

func _update_status():
	var mode_name = current_command_mode.capitalize()
	var api_name = api_in_use.capitalize()
	status_bar.text = "Mode: " + mode_name + " | API: " + api_name + " | Working Dir: " + working_directory

func _display_output(text: String, type: String = "normal"):
	var formatted_text = ""
	
	match type:
		"command":
			formatted_text = "[color=#8be9fd]" + text + "[/color]\n"
		"response":
			formatted_text = "[color=#f1fa8c]" + text + "[/color]\n"
		"error":
			formatted_text = "[color=#ff5555]" + text + "[/color]\n"
		"system":
			formatted_text = "[color=#6272a4]" + text + "[/color]\n"
		"highlight":
			formatted_text = "[color=#50fa7b]" + text + "[/color]\n"
		_:
			formatted_text = text + "\n"
	
	terminal_output.append_text(formatted_text)

func _add_to_history(command: String):
	# Don't add duplicates consecutively
	if command_history_list.size() > 0 and command_history_list.back() == command:
		return
	
	command_history_list.append(command)
	command_history.add_item(command)
	command_history_index = command_history_list.size()
	
	# Limit history size
	if command_history_list.size() > 100:
		command_history_list.pop_front()
		command_history.remove_item(0)

func _show_terminal_help() -> String:
	var help_text = """Available Commands:
- help: Show this help message
- ls [path]: List directory contents
- cd [path]: Change directory
- pwd: Show current directory
- cat [file]: Display file contents
- echo [text]: Echo text back
- clear: Clear terminal output
- history: Show command history
- exit: Exit terminal mode
"""
	_display_output(help_text, "system")
	return "Help displayed"

func _list_directory(args: Array) -> String:
	var path = working_directory
	if args.size() > 0:
		path = _resolve_path(args[0])
	
	var dir = DirAccess.open(path)
	if dir:
		var files = []
		var directories = []
		
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				directories.append(file_name + "/")
			else:
				files.append(file_name)
			file_name = dir.get_next()
		
		directories.sort()
		files.sort()
		
		var output = ""
		for directory in directories:
			output += "[color=#50fa7b]" + directory + "[/color]  "
		
		for file in files:
			output += file + "  "
		
		_display_output(output, "system")
		return "Listed directory: " + path
	else:
		return "Could not access directory: " + path

func _change_directory(args: Array) -> String:
	if args.size() == 0:
		return "Usage: cd [path]"
	
	var new_path = _resolve_path(args[0])
	var dir = DirAccess.open(new_path)
	
	if dir:
		working_directory = new_path
		_update_status()
		return "Changed directory to: " + new_path
	else:
		return "Could not access directory: " + new_path

func _cat_file(args: Array) -> String:
	if args.size() == 0:
		return "Usage: cat [file]"
	
	var file_path = _resolve_path(args[0])
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		_display_output(content, "normal")
		return "Displayed file: " + file_path
	else:
		return "Could not read file: " + file_path

func _show_history() -> String:
	var history_text = "Command History:\n"
	for i in range(command_history_list.size()):
		history_text += str(i+1) + ": " + command_history_list[i] + "\n"
	
	_display_output(history_text, "system")
	return "History displayed"

func _connect_to_system(system_name: String) -> String:
	match system_name.to_lower():
		"memory":
			if memory_manager:
				return "Already connected to memory system"
			else:
				memory_manager = get_node_or_null("/root/MemoryEvolutionManager")
				if memory_manager:
					memory_manager.word_caught.connect(_on_word_caught)
					return "Connected to memory system"
				else:
					return "Memory system not found"
					
		"wordtranslator":
			if word_translator:
				return "Already connected to word translator"
			else:
				word_translator = get_node_or_null("/root/WordTranslator")
				if word_translator:
					return "Connected to word translator"
				else:
					return "Word translator not found"
		
		_:
			return "Unknown system: " + system_name

func _process_file_with_api(file_path: String) -> String:
	var full_path = _resolve_path(file_path)
	
	var file = FileAccess.open(full_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		# Send content to API
		openai_gateway.generate_text("Process and analyze this content: " + content)
		return "Processing file with API: " + full_path
	else:
		return "Could not read file: " + full_path

func _save_to_file(content: String, file_path: String) -> String:
	var full_path = _resolve_path(file_path)
	
	var file = FileAccess.open(full_path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		return "Content saved to file: " + full_path
	else:
		return "Could not write to file: " + full_path

func _set_visualization_mode(mode: String) -> String:
	var result = idea_visualizer.set_visualization_mode(mode)
	return "Visualization mode set to: " + result

func _resolve_path(path: String) -> String:
	if path.begins_with("/"):
		return path
	else:
		if working_directory.ends_with("/"):
			return working_directory + path
		else:
			return working_directory + "/" + path

func _display_welcome_message():
	var welcome_text = """
[center][color=#ff79c6]╔═══════════════════════════════════════════╗
║       Creative Command Center - v1.0       ║
║  World of Words 3D - LuminusOS Interface   ║
╚═══════════════════════════════════════════╝[/color][/center]

Welcome to the Creative Command Center - your interface to the World of Words 3D!

[color=#8be9fd]Available modes:[/color]
• [b]Creative[/b]: Send prompts directly to API (prefix: c:)
• [b]Terminal[/b]: Execute system commands (prefix: t:)
• [b]Hybrid[/b]: Combine creative and terminal (prefix: h:)
• [b]Visualize[/b]: Control 3D word visualization (prefix: v:)

[color=#8be9fd]Creative commands:[/color]
• [b]transform[/b] <word>: Transform a word into a new form
• [b]dialogue[/b] <context> as <character>: Generate character dialogue
• [b]describe[/b] <theme>: Generate a world description
• [b]keywords[/b] <text>: Extract keywords from text

[color=#8be9fd]Visualization commands:[/color]
• [b]mode[/b] <mode>: Set visualization mode (cloud, network, orbit, flow)
• [b]visualize[/b] <words...>: Visualize specific words
• [b]clear[/b]: Clear visualization
• [b]extract[/b] <text>: Extract and visualize keywords from text

Use 'help' in Terminal mode for more commands.
"""
	
	_display_output(welcome_text)
	
	# Add some starter words to the visualization
	idea_visualizer.visualize_keywords(["creative", "command", "center", "words", "visualize", "openai", "transform", "memory"], "Welcome")
	
func _input(event):
	# Handle up/down arrows for command history
	if event is InputEventKey and event.pressed:
		if terminal_input.has_focus():
			if event.keycode == KEY_UP:
				_navigate_history_up()
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_DOWN:
				_navigate_history_down()
				get_viewport().set_input_as_handled()

func _navigate_history_up():
	if command_history_list.size() == 0:
		return
	
	if command_history_index <= 0:
		command_history_index = 0
	else:
		command_history_index -= 1
	
	if command_history_index >= 0 and command_history_index < command_history_list.size():
		terminal_input.text = command_history_list[command_history_index]
		terminal_input.caret_column = terminal_input.text.length()

func _navigate_history_down():
	if command_history_list.size() == 0:
		return
	
	if command_history_index >= command_history_list.size() - 1:
		command_history_index = command_history_list.size()
		terminal_input.text = ""
	else:
		command_history_index += 1
		if command_history_index < command_history_list.size():
			terminal_input.text = command_history_list[command_history_index]
			terminal_input.caret_column = terminal_input.text.length()