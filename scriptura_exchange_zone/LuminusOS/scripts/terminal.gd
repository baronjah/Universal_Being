extends VBoxContainer

@onready var output = $OutputPanel/Output
@onready var input = $CommandLine/Input
@onready var title_label = $TitleBar/Label

var command_history = []
var history_position = -1

# System references
var multi_core_system = null
var word_story_system = null
var magic_system = null
var automation_system = null
var light_data_system = null
var light_story_integrator = null

func _ready():
	input.grab_focus()
	
	# Connect ScriptInterpreter signals
	ScriptInterpreter.connect("output_text", _on_script_output)
	
	# Initialize subsystems
	initialize_systems()
	show_welcome_message()

func _on_script_output(text):
	output.append_text(text)

func show_welcome_message():
	output.clear()
	output.append_text("[color=#88CCFF][b]LuminusOS v1.0[/b][/color]\n")
	output.append_text("Inspired by TempleOS - Created in Godot 4.4\n")
	output.append_text("-----------------------------------------\n")
	output.append_text("Type [color=#FFFF00]help[/color] to see available commands\n\n")
	
	# Show current path in title
	update_title()

func update_title():
	title_label.text = "LuminusOS v1.0 - " + FileSystem.get_current_path()

func initialize_systems():
	# Create subsystems
	multi_core_system = MultiCoreSystem.new()
	word_story_system = WordStorySystem.new()
	magic_system = MagicSystem.new()
	automation_system = AutomationSystem.new()
	light_data_system = LightDataTransformer.new()
	light_story_integrator = LightStoryIntegrator.new()
	
	# Add them to the scene
	add_child(multi_core_system)
	add_child(word_story_system)
	add_child(magic_system)
	add_child(automation_system)
	add_child(light_data_system)
	add_child(light_story_integrator)
	
	# Connect automation system to other systems
	automation_system.initialize(multi_core_system, word_story_system, magic_system)
	
	# Connect light systems
	light_story_integrator.transformer = light_data_system
	light_story_integrator.story_weaver = word_story_system

func _on_input_text_submitted(command):
	if command.strip_edges() == "":
		input.clear()
		return
		
	# Add command to output
	output.append_text("[color=#88FFAA]> " + command + "[/color]\n")
	
	# Add to history
	command_history.append(command)
	history_position = command_history.size()
	
	# Process command
	process_command(command)
	
	# Clear input
	input.clear()

func process_command(command):
	var parts = command.strip_edges().split(" ", false)
	var cmd = parts[0].to_lower()
	var args = parts.slice(1)
	
	match cmd:
		"help":
			show_help()
		"clear":
			output.clear()
		"echo":
			output.append_text(" ".join(args) + "\n")
		"version":
			output.append_text("LuminusOS v1.0 running on Godot " + Engine.get_version_info().string + "\n")
		"exit":
			output.append_text("Goodbye!\n")
			await get_tree().create_timer(1.0).timeout
			get_tree().quit()
		"ls":
			var path = ""
			if args.size() > 0:
				path = args[0]
			show_directory_listing(path)
		"cd":
			if args.size() > 0:
				change_directory(args[0])
			else:
				output.append_text("Please specify a directory.\n")
		"cat":
			if args.size() > 0:
				cat_file(args[0])
			else:
				output.append_text("Please specify a file to read.\n")
		"mkdir":
			if args.size() > 0:
				create_directory(args[0])
			else:
				output.append_text("Please specify a directory name.\n")
		"write":
			if args.size() >= 2:
				write_file(args[0], " ".join(args.slice(1)))
			else:
				output.append_text("Usage: write <filename> <content>\n")
		"run":
			if args.size() > 0:
				run_script(args[0])
			else:
				output.append_text("Please specify a script file to run.\n")
		"script":
			show_script_help()
		"bible":
			show_random_bible_verse()
		"god":
			output.append_text("[color=#FFFF00]God is always watching.\n[/color]")
		"color":
			change_color(args)
		"draw":
			if args.size() > 0:
				match args[0]:
					"box":
						draw_box()
					"line":
						draw_line()
					"circle":
						draw_circle()
					"random":
						draw_random()
					_:
						output.append_text("Unknown drawing command. Try 'box', 'line', 'circle', or 'random'.\n")
			else:
				output.append_text("Please specify what to draw.\n")
		"random":
			if args.size() > 0:
				match args[0]:
					"number":
						var max_num = 100
						if args.size() > 1 and args[1].is_valid_int():
							max_num = int(args[1])
						output.append_text(str(randi() % max_num) + "\n")
					"color":
						var rand_color = Color(randf(), randf(), randf())
						output.append_text("[color=#" + rand_color.to_html() + "]■■■■■■■■■■■■■■■■■■■■[/color]\n")
					"verse":
						show_random_bible_verse()
					_:
						output.append_text("Unknown random command. Try 'number', 'color', or 'verse'.\n")
			else:
				output.append_text(str(randi() % 100) + "\n")
		"about":
			show_about()
		# Multi-Core System Commands
		"cores":
			if multi_core_system != null:
				output.append_text(multi_core_system.cmd_cores(args) + "\n")
			else:
				output.append_text("Multi-Core System not available\n")
		"task":
			if multi_core_system != null:
				output.append_text(multi_core_system.cmd_task(args) + "\n")
			else:
				output.append_text("Multi-Core System not available\n")
		"memory":
			if multi_core_system != null:
				output.append_text(multi_core_system.cmd_memory(args) + "\n")
			else:
				output.append_text("Multi-Core System not available\n")
		# Word/Story System Commands
		"word":
			if word_story_system != null:
				output.append_text(word_story_system.cmd_word(args) + "\n")
			else:
				output.append_text("Word/Story System not available\n")
		"story":
			if word_story_system != null:
				output.append_text(word_story_system.cmd_story(args) + "\n")
			else:
				output.append_text("Word/Story System not available\n")
		"narrative":
			if word_story_system != null:
				output.append_text(word_story_system.cmd_narrative(args) + "\n")
			else:
				output.append_text("Word/Story System not available\n")
		# Magic System Commands
		"magic":
			if magic_system != null:
				output.append_text(magic_system.cmd_magic(args) + "\n")
			else:
				output.append_text("Magic System not available\n")
		# Automation System Commands
		"auto":
			if automation_system != null:
				output.append_text(automation_system.cmd_auto(args) + "\n")
			else:
				output.append_text("Automation System not available\n")
		"tick":
			if automation_system != null:
				output.append_text(automation_system.cmd_auto(["once"]) + "\n")
			elif multi_core_system != null:
				output.append_text(multi_core_system.cmd_tick(args) + "\n")
			elif word_story_system != null:
				output.append_text(word_story_system.cmd_tick(args) + "\n")
			elif magic_system != null:
				output.append_text(magic_system.cmd_tick(args) + "\n")
			else:
				output.append_text("Tick systems not available\n")
		"stats":
			show_system_stats()
		_:
			output.append_text("Unknown command: " + cmd + "\n")

func show_help():
	output.append_text("Available commands:\n")
	output.append_text("File System:\n")
	output.append_text("  ls      - List directory contents\n")
	output.append_text("  cd      - Change directory\n")
	output.append_text("  cat     - Display file contents\n")
	output.append_text("  mkdir   - Create a directory\n")
	output.append_text("  write   - Write content to a file\n")
	output.append_text("\nScripting:\n")
	output.append_text("  run     - Run a script file\n")
	output.append_text("  script  - Show script language help\n")
	output.append_text("\nUtilities:\n")
	output.append_text("  help    - Show this help\n")
	output.append_text("  clear   - Clear the screen\n")
	output.append_text("  echo    - Display a message\n")
	output.append_text("  version - Show version information\n")
	output.append_text("  exit    - Exit LuminusOS\n")
	output.append_text("\nSpecial Features:\n")
	output.append_text("  bible   - Display a random Bible verse\n")
	output.append_text("  god     - Acknowledge the divine\n")
	output.append_text("  random  - Generate random numbers/items\n")
	output.append_text("  color   - Change terminal color\n")
	output.append_text("  draw    - Simple drawing functions\n")
	output.append_text("  about   - About LuminusOS\n")
	output.append_text("\nAdvanced Systems:\n")
	output.append_text("  cores   - Multi-core processor management\n")
	output.append_text("  task    - Task scheduling and management\n")
	output.append_text("  memory  - Shared memory operations\n")
	output.append_text("  word    - Word database operations\n")
	output.append_text("  story   - Story generation and retrieval\n")
	output.append_text("  narrative - Narrative chain operations\n")
	output.append_text("  magic   - Multi-dimensional magic operations\n")
	output.append_text("  auto    - Automation system control\n")
	output.append_text("  tick    - Process a system tick\n")
	output.append_text("  stats   - Show system statistics\n")

func show_about():
	output.append_text("[color=#88CCFF][b]About LuminusOS[/b][/color]\n")
	output.append_text("LuminusOS is a Godot-based system inspired by TempleOS,\n")
	output.append_text("created as a creative coding environment with spiritual elements.\n\n")
	output.append_text("Unlike TempleOS which was an actual operating system,\n")
	output.append_text("LuminusOS is a simulation running on Godot 4.4.\n\n")
	output.append_text("Created as a tribute to Terry A. Davis.\n")

func show_directory_listing(path=""):
	var files = FileSystem.list_directory(path)
	if files.size() > 0:
		for file in files:
			output.append_text(file + "\n")
	else:
		output.append_text("Directory is empty or does not exist.\n")

func change_directory(path):
	if FileSystem.change_directory(path):
		update_title()
		output.append_text("Changed directory to " + FileSystem.get_current_path() + "\n")
	else:
		output.append_text("Directory not found: " + path + "\n")

func cat_file(path):
	var content = FileSystem.read_file(path)
	if content != null:
		output.append_text("[color=#AAAAFF]--- " + path + " ---[/color]\n")
		output.append_text(content + "\n")
		output.append_text("[color=#AAAAFF]--- End of file ---[/color]\n")
	else:
		output.append_text("File not found or is not a regular file: " + path + "\n")

func create_directory(path):
	if FileSystem.create_directory(path):
		output.append_text("Directory created: " + path + "\n")
	else:
		output.append_text("Failed to create directory: " + path + "\n")

func write_file(path, content):
	if FileSystem.write_file(path, content):
		output.append_text("File written: " + path + "\n")
	else:
		output.append_text("Failed to write file: " + path + "\n")

func run_script(path):
	var content = FileSystem.read_file(path)
	if content != null:
		output.append_text("[color=#AAFFAA]Running script: " + path + "[/color]\n")
		var result = ScriptInterpreter.execute_script(content)
		output.append_text("[color=#AAFFAA]" + result + "[/color]\n")
	else:
		output.append_text("Script file not found: " + path + "\n")

func show_script_help():
	output.append_text(ScriptInterpreter.get_help_text())

func show_system_stats():
	output.append_text("[color=#88CCFF][b]System Statistics[/b][/color]\n")
	
	# Multi-Core System Stats
	if multi_core_system != null:
		output.append_text("\nMulti-Core System:\n")
		output.append_text(multi_core_system.cmd_stats() + "\n")
	
	# Word/Story System Stats
	if word_story_system != null:
		output.append_text("\nWord/Story System:\n")
		output.append_text(word_story_system.cmd_stats() + "\n")
	
	# Magic System Stats
	if magic_system != null:
		output.append_text("\nMagic System:\n")
		output.append_text(magic_system.get_magic_stats() + "\n")
	
	# Automation System Stats
	if automation_system != null:
		output.append_text("\nAutomation System:\n")
		output.append_text(automation_system.get_performance_stats() + "\n")

func show_random_bible_verse():
	var verses = [
		"In the beginning God created the heaven and the earth. - Genesis 1:1",
		"For God so loved the world, that he gave his only begotten Son. - John 3:16",
		"The Lord is my shepherd; I shall not want. - Psalm 23:1",
		"Ask, and it shall be given you; seek, and ye shall find. - Matthew 7:7",
		"I can do all things through Christ which strengtheneth me. - Philippians 4:13",
		"Blessed are the pure in heart: for they shall see God. - Matthew 5:8",
		"Trust in the LORD with all thine heart; and lean not unto thine own understanding. - Proverbs 3:5",
		"Let there be light: and there was light. - Genesis 1:3",
		"Be still, and know that I am God. - Psalm 46:10",
		"The Lord is my light and my salvation; whom shall I fear? - Psalm 27:1"
	]
	var verse = verses[randi() % verses.size()]
	output.append_text("[color=#FFFF88]" + verse + "[/color]\n")

func change_color(args):
	if args.size() < 1:
		output.append_text("Please specify a color (blue, green, red, white, default, random)\n")
		return
		
	var color = args[0].to_lower()
	
	if color == "random":
		var rand_color = Color(randf(), randf(), randf())
		output.add_theme_color_override("default_color", Color(0.7 + rand_color.r * 0.3, 0.7 + rand_color.g * 0.3, 0.7 + rand_color.b * 0.3))
		get_parent().get_node("ColorRect").color = Color(rand_color.r * 0.3, rand_color.g * 0.3, rand_color.b * 0.3)
		output.append_text("Color changed to random.\n")
		return
	
	match color:
		"blue":
			output.add_theme_color_override("default_color", Color(0.7, 0.7, 1.0))
			get_parent().get_node("ColorRect").color = Color(0, 0, 0.2)
		"green":
			output.add_theme_color_override("default_color", Color(0.7, 1.0, 0.7))
			get_parent().get_node("ColorRect").color = Color(0, 0.2, 0)
		"red":
			output.add_theme_color_override("default_color", Color(1.0, 0.7, 0.7))
			get_parent().get_node("ColorRect").color = Color(0.2, 0, 0)
		"white":
			output.add_theme_color_override("default_color", Color(1.0, 1.0, 1.0))
			get_parent().get_node("ColorRect").color = Color(0.1, 0.1, 0.1)
		"default":
			output.add_theme_color_override("default_color", Color(1, 1, 1))
			get_parent().get_node("ColorRect").color = Color(0, 0, 0.2)
		_:
			output.append_text("Unknown color. Try blue, green, red, white, default, or random.\n")
			return
	
	output.append_text("Color changed to " + color + ".\n")

func draw_box():
	var box = "+------------+\n"
	box += "|            |\n"
	box += "|            |\n"
	box += "|            |\n"
	box += "+------------+\n"
	output.append_text(box)

func draw_line():
	output.append_text("------------------------\n")

func draw_circle():
	var circle = "    ****    \n"
	circle += "  ********  \n"
	circle += " ********** \n"
	circle += "************\n"
	circle += "************\n"
	circle += "************\n"
	circle += " ********** \n"
	circle += "  ********  \n"
	circle += "    ****    \n"
	output.append_text(circle)

func draw_random():
	var chars = ["*", "#", "@", "%", "$", "+", ".", ":", "=", "-", "&"]
	var width = 20
	var height = 8
	var art = ""
	
	for y in range(height):
		for x in range(width):
			art += chars[randi() % chars.size()]
		art += "\n"
		
	output.append_text(art)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_UP:
			navigate_history_up()
		elif event.keycode == KEY_DOWN:
			navigate_history_down()

func navigate_history_up():
	if command_history.size() > 0 and history_position > 0:
		history_position -= 1
		input.text = command_history[history_position]
		input.caret_column = input.text.length()

func navigate_history_down():
	if history_position < command_history.size() - 1:
		history_position += 1
		input.text = command_history[history_position]
		input.caret_column = input.text.length()
	elif history_position == command_history.size() - 1:
		history_position = command_history.size()
		input.text = ""