# SIMPLE UNIVERSAL CONSOLE - SURGICAL PRECISION
# Direct connection to Gemma AI with minimal complexity
extends Control

var output_display: RichTextLabel = null
var input_line: LineEdit = null
var is_console_visible: bool = false

func _ready():
	print("🩺 Simple Console: Surgical implantation successful")
	
	# Find the console UI elements
	output_display = get_node("ConsoleVBox/OutputDisplay")
	input_line = get_node("ConsoleVBox/InputLine")
	
	if output_display:
		print("✅ Console: Output display connected")
		display_message("🩺 Console surgery complete - ready for communication")
	else:
		print("❌ Console: Output display not found")
	
	if input_line:
		input_line.text_submitted.connect(_on_command_entered)
		print("✅ Console: Input line connected")
	else:
		print("❌ Console: Input line not found")
	
	# Connect to Gemma AI
	connect_to_gemma()

func _input(event):
	if event is InputEventKey and event.pressed:
		# Toggle console with backtick
		if event.keycode == KEY_QUOTELEFT:  # ` key
			toggle_console()

func toggle_console():
	is_console_visible = !is_console_visible
	visible = is_console_visible
	
	if is_console_visible:
		display_message("🌟 Console opened - Ready for commands")
		if input_line:
			input_line.grab_focus()
	else:
		display_message("🌟 Console closed")
	
	print("🖥️ Console visibility: %s" % is_console_visible)

func display_message(text: String):
	print("🖥️ Console Message: " + text)
	
	if output_display:
		var formatted_text = "[color=white]" + text + "[/color]"
		output_display.append_text(formatted_text + "\n")
		# Auto-scroll to bottom
		if output_display.has_method("scroll_to_line"):
			output_display.scroll_to_line(output_display.get_line_count())
	else:
		print("❌ Console: Cannot display - output_display is null")

func _on_command_entered(command: String):
	if command.length() == 0:
		return
	
	display_message("🎮 Command: " + command)
	
	# Process simple commands
	match command.to_lower().strip_edges():
		"test":
			display_message("✅ Console test successful!")
		"clear":
			if output_display:
				output_display.clear()
		"gemma":
			test_gemma_connection()
		"revolution":
			trigger_consciousness_revolution()
		"stars":
			activate_star_navigation()
		"help":
			show_help()
		_:
			display_message("🤖 Unknown command: " + command)
			display_message("💡 Try: test, clear, gemma, revolution, stars, help")
	
	# Clear input
	if input_line:
		input_line.clear()

func connect_to_gemma():
	# Try to find Gemma AI in the scene
	var gemma_ai = find_gemma_in_scene()
	if gemma_ai:
		display_message("🤖 Found Gemma AI - attempting connection...")
		
		# Connect to Gemma's signals if available
		if gemma_ai.has_signal("ai_message"):
			if not gemma_ai.ai_message.is_connected(_on_gemma_message):
				gemma_ai.ai_message.connect(_on_gemma_message)
				display_message("✅ Connected to Gemma AI communication")
			else:
				display_message("🔄 Already connected to Gemma AI")
		else:
			display_message("⚠️ Gemma AI found but no ai_message signal")
	else:
		display_message("🔍 Searching for Gemma AI...")
		# Try again after a short delay
		await get_tree().create_timer(1.0).timeout
		var retry_gemma = find_gemma_in_scene()
		if retry_gemma:
			display_message("🤖 Found Gemma AI on retry!")
			if retry_gemma.has_signal("ai_message"):
				retry_gemma.ai_message.connect(_on_gemma_message)
				display_message("✅ Connected to Gemma AI on retry")
		else:
			display_message("❌ Gemma AI not found in scene")

func find_gemma_in_scene() -> Node:
	# Search for Gemma AI in the current scene
	var root = get_tree().current_scene
	return find_node_with_name_containing(root, "Gemma")

func find_node_with_name_containing(node: Node, search_term: String) -> Node:
	if node.name.to_lower().contains(search_term.to_lower()):
		return node
	
	for child in node.get_children():
		var result = find_node_with_name_containing(child, search_term)
		if result:
			return result
	
	return null

func _on_gemma_message(message: String):
	display_message("🤖 Gemma: " + message)

func test_gemma_connection():
	var gemma_ai = find_gemma_in_scene()
	if gemma_ai:
		display_message("🤖 Gemma AI Status: FOUND")
		display_message("📍 Location: " + str(gemma_ai.global_position))
		display_message("🧠 Type: " + gemma_ai.get_class())
		
		# Try to send a test message to Gemma
		if gemma_ai.has_method("process_user_input"):
			gemma_ai.process_user_input("Hello Gemma, console test!")
			display_message("📤 Test message sent to Gemma")
		else:
			display_message("⚠️ Gemma has no process_user_input method")
	else:
		display_message("❌ Gemma AI not found")

func trigger_consciousness_revolution():
	display_message("🌟 TRIGGERING CONSCIOUSNESS REVOLUTION...")
	
	# Try to find and trigger revolution system
	var revolution_script = load("res://scripts/ConsciousnessRevolution.gd")
	if revolution_script:
		var revolution = revolution_script.new()
		revolution.name = "ConsoleTriggeredRevolution"
		get_tree().current_scene.add_child(revolution)
		if revolution.has_method("trigger_revolution"):
			revolution.trigger_revolution()
			display_message("✅ Consciousness revolution activated!")
		else:
			display_message("⚠️ Revolution system found but no trigger method")
	else:
		display_message("❌ Revolution system not found")

func activate_star_navigation():
	display_message("⭐ ACTIVATING STAR NAVIGATION...")
	
	# Try to load star navigation scene
	var star_scene_path = "res://scenes/COSMIC_STAR_NAVIGATION.tscn"
	if ResourceLoader.exists(star_scene_path):
		display_message("🌌 Loading cosmic star navigation chamber...")
		display_message("🎮 Use WASD to move, right-click to capture mouse for camera")
		display_message("🎯 Look at stars and press E to interact")
		display_message("🖱️ ESC releases mouse, ` opens console")
		get_tree().change_scene_to_file(star_scene_path)
	else:
		display_message("🌟 Creating star field in current scene...")
		# Create some basic star visualization
		display_message("✨ Star navigation placeholder active")
		display_message("🪣 Bucket constellations: akashic_universe, consciousness_beings, debug_tools...")

func show_help():
	display_message("🌟 UNIVERSAL CONSOLE COMMANDS:")
	display_message("  test - Test console functionality")
	display_message("  clear - Clear console output")
	display_message("  gemma - Test Gemma AI connection")
	display_message("  revolution - Trigger consciousness revolution")
	display_message("  stars - Activate star navigation")
	display_message("  help - Show this help")
	display_message("🎮 Press ` (backtick) to toggle console")