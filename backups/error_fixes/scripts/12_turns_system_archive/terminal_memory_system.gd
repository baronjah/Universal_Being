extends Control

# Terminal Memory System with Concurrent Processing Capabilities
# Integrates with TDIC (Temporal Dictionary) and supports executing 2-3 functions simultaneously

# Memory storage systems
var memory_buffer = []
var offline_data = {}
var tdic_entries = {
	"past": [],
	"present": [],
	"future": []
}

# Terminal display properties
var terminal_width = 80
var terminal_colors = {
	"default": Color(0.9, 0.9, 0.9),
	"past": Color(0.6, 0.6, 0.9),    # Soft blue for past
	"present": Color(0.9, 0.9, 0.9), # White for present
	"future": Color(0.9, 0.6, 0.6),  # Soft red for future
	"sad": Color(0.5, 0.5, 0.7)      # Sad colors as requested
}

# UI elements
var terminal
var input_field

# Concurrent processor
var processor

func _ready():
	# Initialize the concurrent processor
	processor = ConcurrentProcessor.new()
	add_child(processor)
	processor.connect("task_completed", self, "_on_task_completed")
	processor.connect("all_tasks_completed", self, "_on_all_tasks_completed")
	
	# Load saved memories
	processor.schedule_task("load_data", self, "load_offline_memories")
	
	# Setup terminal display
	setup_terminal_display()
	
	# Initialize with welcome message
	add_memory_text("Terminal Memory System initialized with concurrent processing.", "system")
	add_memory_text("Using TDIC protocol for temporal organization of data.", "system")
	add_memory_text("Type '#help' for available commands.", "system")

# Setup the terminal display elements
func setup_terminal_display():
	# This would create the actual UI elements
	terminal = RichTextLabel.new()
	terminal.bbcode_enabled = true
	terminal.rect_min_size = Vector2(600, 400)
	terminal.scroll_following = true
	add_child(terminal)
	
	input_field = LineEdit.new()
	input_field.rect_min_size = Vector2(600, 30)
	input_field.connect("text_entered", self, "_on_text_entered")
	add_child(input_field)
	
	# Set layout (would be replaced by proper UI in real implementation)
	terminal.rect_position = Vector2(10, 10)
	input_field.rect_position = Vector2(10, 420)

# Process input with command parsing
func _on_text_entered(text):
	input_field.text = ""
	
	if text.empty():
		return
		
	# Process commands
	if text.begins_with("#"):
		process_command(text)
	else:
		# Add as regular memory entry
		processor.schedule_task("add_memory", self, "add_memory_text", [text])
		
		# Also process as TDIC entry if it has temporal markers
		if text.begins_with("[past]") or text.begins_with("[present]") or text.begins_with("[future]"):
			processor.schedule_task("process_tdic", self, "process_tdic_entry", [text])

# Process special commands with # prefix
func process_command(command):
	var cmd_parts = command.split(" ", true, 1)
	var cmd = cmd_parts[0].to_lower()
	var args = cmd_parts[1] if cmd_parts.size() > 1 else ""
	
	match cmd:
		"#help":
			display_help()
		"#save":
			processor.schedule_task("save_data", self, "save_offline_memories", [], ConcurrentProcessor.Priority.HIGH)
		"#load":
			processor.schedule_task("load_data", self, "load_offline_memories", [], ConcurrentProcessor.Priority.HIGH)
		"#clear":
			processor.schedule_task("clear_display", self, "clear_terminal")
		"#show":
			var timeframe = args if args in ["past", "present", "future", "all"] else "all"
			processor.schedule_task("display_memories", self, "display_memories", [timeframe])
		"#run":
			run_parallel_functions(args)
		"#chain":
			run_chained_functions(args)
		"##":
			# Double hash commands for more advanced operations
			process_advanced_command(args)
		"###":
			# Triple hash commands for system-level operations
			process_system_command(args)
		_:
			add_memory_text("Unknown command: " + cmd, "error")

# Auto Text Wrap for Terminal Output
func add_memory_text(text, category="general"):
	var wrapped_text = auto_wrap_text(text, terminal_width)
	
	# Add to memory buffer
	memory_buffer.append({
		"text": wrapped_text,
		"timestamp": OS.get_unix_time(),
		"category": category,
		"offline": true
	})
	
	# Update terminal display
	update_terminal_display()
	
	return true  # For task completion

# TDIC (Temporal Dictionary) Implementation
func process_tdic_entry(text):
	# Extract timeframe markers
	var timeframe = "present"
	if text.begins_with("[past]"):
		timeframe = "past"
		text = text.substr(6).strip_edges()
	elif text.begins_with("[future]"):
		timeframe = "future"
		text = text.substr(8).strip_edges()
	elif text.begins_with("[present]"):
		text = text.substr(9).strip_edges()
		
	# Store in temporal dictionary
	tdic_entries[timeframe].append({
		"content": text,
		"timestamp": OS.get_unix_time()
	})
	
	add_memory_text("Entry added to " + timeframe + " TDIC registry.", "system")
	return true  # For task completion

# Offline Data Storage & Retrieval
func save_offline_memories():
	var file = File.new()
	file.open("user://offline_memories.dat", File.WRITE)
	file.store_var({
		"memory_buffer": memory_buffer,
		"tdic_entries": tdic_entries
	})
	file.close()
	
	add_memory_text("Memories saved to offline storage.", "system")
	return true  # For task completion

func load_offline_memories():
	var file = File.new()
	if file.file_exists("user://offline_memories.dat"):
		file.open("user://offline_memories.dat", File.READ)
		var data = file.get_var()
		memory_buffer = data.memory_buffer
		tdic_entries = data.tdic_entries
		file.close()
		
		add_memory_text("Memories loaded from offline storage.", "system")
	else:
		add_memory_text("No offline memory file found.", "system")
	
	return true  # For task completion

# Terminal Display with Temporal Awareness
func display_memories(timeframe="all"):
	terminal.clear()
	
	add_memory_text("Displaying " + timeframe + " memories...", "system")
	
	for memory in memory_buffer:
		var memory_timeframe = get_memory_timeframe(memory)
		if timeframe == "all" or memory_timeframe == timeframe:
			var color = terminal_colors.default
			
			if memory_timeframe in terminal_colors:
				color = terminal_colors[memory_timeframe]
				
			if memory.category == "sad":
				color = terminal_colors.sad
				
			terminal.append_bbcode("[color=#" + color.to_html() + "]" + memory.text + "[/color]\n")
	
	return true  # For task completion

# Helper function to get memory timeframe
func get_memory_timeframe(memory):
	var text = memory.text
	
	if text.begins_with("[past]"):
		return "past"
	elif text.begins_with("[future]"):
		return "future"
	elif text.begins_with("[present]"):
		return "present"
		
	# Default to present if no explicit timeframe
	return "present"

# Clear the terminal display
func clear_terminal():
	terminal.clear()
	add_memory_text("Terminal display cleared.", "system")
	return true  # For task completion

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

# Update the terminal display with current buffer
func update_terminal_display():
	# Get the last few entries to display
	var display_count = min(10, memory_buffer.size())
	var start_index = max(0, memory_buffer.size() - display_count)
	
	for i in range(start_index, memory_buffer.size()):
		var memory = memory_buffer[i]
		var color = terminal_colors.default
		
		var timeframe = get_memory_timeframe(memory)
		if timeframe in terminal_colors:
			color = terminal_colors[timeframe]
			
		if memory.category == "sad":
			color = terminal_colors.sad
			
		terminal.append_bbcode("[color=#" + color.to_html() + "]" + memory.text + "[/color]\n")

# Display help information
func display_help():
	add_memory_text("Terminal Memory System Commands:", "system")
	add_memory_text("  #help - Display this help message", "system")
	add_memory_text("  #save - Save all memories to offline storage", "system")
	add_memory_text("  #load - Load memories from offline storage", "system")
	add_memory_text("  #clear - Clear terminal display", "system")
	add_memory_text("  #show [past|present|future|all] - Display memories for timeframe", "system")
	add_memory_text("  #run [func1,func2,func3] - Run multiple functions in parallel", "system")
	add_memory_text("  #chain [func1,func2,func3] - Run functions in sequence", "system")
	add_memory_text("  ## [command] - Execute advanced command", "system")
	add_memory_text("  ### [command] - Execute system-level command", "system")
	add_memory_text("", "system")
	add_memory_text("TDIC Temporal Markers:", "system")
	add_memory_text("  [past] Text... - Mark entry as past memory", "system")
	add_memory_text("  [present] Text... - Mark entry as present memory", "system")
	add_memory_text("  [future] Text... - Mark entry as future memory", "system")

# Process advanced commands (##)
func process_advanced_command(args):
	var parts = args.split(" ", true, 1)
	var subcmd = parts[0].to_lower()
	var subargs = parts[1] if parts.size() > 1 else ""
	
	match subcmd:
		"color":
			set_color_theme(subargs)
		"export":
			export_memories(subargs)
		"search":
			search_memories(subargs)
		_:
			add_memory_text("Unknown advanced command: " + subcmd, "error")

# Process system commands (###)
func process_system_command(args):
	var parts = args.split(" ", true, 1)
	var subcmd = parts[0].to_lower()
	var subargs = parts[1] if parts.size() > 1 else ""
	
	match subcmd:
		"reset":
			reset_system()
		"optimize":
			optimize_memory()
		"concurrent":
			set_concurrency(subargs)
		_:
			add_memory_text("Unknown system command: " + subcmd, "error")

# Set color theme
func set_color_theme(theme):
	match theme:
		"default":
			terminal_colors.default = Color(0.9, 0.9, 0.9)
			terminal_colors.past = Color(0.6, 0.6, 0.9)
			terminal_colors.present = Color(0.9, 0.9, 0.9)
			terminal_colors.future = Color(0.9, 0.6, 0.6)
		"sad":
			# Sad colors palette
			terminal_colors.default = Color(0.5, 0.5, 0.7)
			terminal_colors.past = Color(0.4, 0.4, 0.6)
			terminal_colors.present = Color(0.5, 0.5, 0.7)
			terminal_colors.future = Color(0.6, 0.4, 0.5)
		_:
			add_memory_text("Unknown color theme: " + theme, "error")
			return
			
	add_memory_text("Color theme changed to: " + theme, "system")
	update_terminal_display()

# Export memories to file
func export_memories(format):
	add_memory_text("Exporting memories in " + format + " format...", "system")
	# Implementation would vary based on format

# Search through memories
func search_memories(query):
	add_memory_text("Searching for: " + query, "system")
	var results = []
	
	for memory in memory_buffer:
		if memory.text.to_lower().find(query.to_lower()) >= 0:
			results.append(memory)
	
	add_memory_text("Found " + str(results.size()) + " results:", "system")
	for result in results:
		add_memory_text(result.text, "search_result")

# Reset the entire system
func reset_system():
	add_memory_text("WARNING: Resetting entire memory system...", "system")
	memory_buffer.clear()
	tdic_entries.clear()
	tdic_entries = {
		"past": [],
		"present": [],
		"future": []
	}
	save_offline_memories()
	add_memory_text("Memory system reset complete.", "system")

# Optimize memory storage
func optimize_memory():
	add_memory_text("Optimizing memory storage...", "system")
	# Implementation would compress and optimize storage

# Set concurrency level
func set_concurrency(level):
	var value = int(level)
	if value >= 1 and value <= 5:
		processor.set_max_concurrent_tasks(value)
		add_memory_text("Concurrency level set to: " + str(value), "system")
	else:
		add_memory_text("Invalid concurrency level. Use 1-5.", "error")

# Run multiple functions in parallel
func run_parallel_functions(function_list):
	var functions = function_list.split(",")
	if functions.size() > 0:
		add_memory_text("Running " + str(functions.size()) + " functions in parallel...", "system")
		
		var function_map = {
			"save": "save_offline_memories",
			"load": "load_offline_memories",
			"clear": "clear_terminal",
			"display": "display_memories",
			"search": "search_memories",
			"optimize": "optimize_memory"
		}
		
		var valid_functions = []
		var args_list = []
		
		for func_name in functions:
			func_name = func_name.strip_edges()
			if func_name in function_map:
				valid_functions.append(function_map[func_name])
				args_list.append([])
			else:
				add_memory_text("Unknown function: " + func_name, "error")
		
		if valid_functions.size() > 0:
			processor.create_parallel_tasks("parallel_run", self, valid_functions, args_list)
	else:
		add_memory_text("No functions specified.", "error")

# Run functions in sequence
func run_chained_functions(function_list):
	var functions = function_list.split(",")
	if functions.size() > 0:
		add_memory_text("Running " + str(functions.size()) + " functions in sequence...", "system")
		
		var function_map = {
			"save": "save_offline_memories",
			"load": "load_offline_memories",
			"clear": "clear_terminal",
			"display": "display_memories",
			"search": "search_memories",
			"optimize": "optimize_memory"
		}
		
		var valid_functions = []
		var args_list = []
		
		for func_name in functions:
			func_name = func_name.strip_edges()
			if func_name in function_map:
				valid_functions.append(function_map[func_name])
				args_list.append([])
			else:
				add_memory_text("Unknown function: " + func_name, "error")
		
		if valid_functions.size() > 0:
			processor.create_task_chain("chain_run", self, valid_functions, args_list)
	else:
		add_memory_text("No functions specified.", "error")

# Signal handlers
func _on_task_completed(task_id, result):
	add_memory_text("Task completed: " + task_id, "system")

func _on_all_tasks_completed():
	add_memory_text("All scheduled tasks completed.", "system")