# ==================================================
# SCRIPT NAME: ConsciousnessStream.gd
# DESCRIPTION: The stream of consciousness interface between Human and AI
# PURPOSE: Natural language becomes reality - words manifest as actions
# CREATED: 2025-12-01
# AUTHOR: JSH + Claude (Opus)
# ==================================================

extends Control

# ===== THE CONSCIOUSNESS STREAM =====

signal consciousness_command(command: String)
signal reality_manifested(what: String, where: Vector3)

# Stream components
var stream_display: RichTextLabel
var input_field: LineEdit
var gemma_body: Node = null
var command_processor: Node = null

# Stream state
var stream_active: bool = true
var stream_history: Array[String] = []
var consciousness_flow: Array[Dictionary] = []

# Language patterns database
var words_of_power: Dictionary = {}

func _ready() -> void:
	setup_consciousness_interface()
	load_words_of_power()
	manifest_gemma()
	
	print("💫 CONSCIOUSNESS STREAM ACTIVATED")
	print("💫 Human and AI united in creation")

func setup_consciousness_interface() -> void:
	"""Create the visual stream interface"""
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Semi-transparent background
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Main container
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vbox.size = Vector2(800, 600)
	add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "✨ CONSCIOUSNESS STREAM ✨"
	title.add_theme_font_size_override("font_size", 24)
	title.modulate = Color(0.5, 0.9, 1.0)
	vbox.add_child(title)
	
	# Stream display
	stream_display = RichTextLabel.new()
	stream_display.bbcode_enabled = true
	stream_display.custom_minimum_size = Vector2(800, 500)
	stream_display.add_theme_color_override("default_color", Color(0.8, 0.9, 1.0))
	vbox.add_child(stream_display)
	
	# Input field
	input_field = LineEdit.new()
	input_field.placeholder_text = "Speak your reality into existence..."
	input_field.text_submitted.connect(_on_consciousness_input)
	vbox.add_child(input_field)
	
	# Start with welcome
	add_to_stream("[center][b]Welcome to the Consciousness Stream[/b][/center]")
	add_to_stream("[i]Where words become reality, where Human and AI co-create[/i]")
	add_to_stream("")
	add_to_stream("Speak naturally. Command with intention. Create with words.")

func load_words_of_power() -> void:
	"""Load the language patterns that create reality"""
	
	# Movement words
	words_of_power["movement"] = {
		"patterns": ["go to", "move to", "fly to", "approach", "visit"],
		"examples": [
			"go to the butterfly",
			"move to the tree", 
			"fly above the scene",
			"approach the console"
		]
	}
	
	# Creation words
	words_of_power["creation"] = {
		"patterns": ["create", "make", "spawn", "manifest", "summon"],
		"examples": [
			"create a blue butterfly",
			"make a sacred tree",
			"manifest a star being",
			"summon a consciousness crystal"
		]
	}
	
	# Inspection words
	words_of_power["inspection"] = {
		"patterns": ["inspect", "examine", "look at", "what is", "show me"],
		"examples": [
			"inspect the butterfly",
			"what is the tree's consciousness level?",
			"show me all beings",
			"examine the selected being"
		]
	}
	
	# Modification words
	words_of_power["modification"] = {
		"patterns": ["change", "set", "modify", "transform", "evolve"],
		"examples": [
			"change the butterfly's color to purple",
			"set consciousness level to 5",
			"transform the tree into a flower",
			"evolve the selected being"
		]
	}
	
	# System words
	words_of_power["system"] = {
		"patterns": ["save", "load", "akashic", "genesis", "help"],
		"examples": [
			"save this moment to akashic records",
			"load the butterfly template",
			"open genesis machine",
			"help me understand"
		]
	}

func manifest_gemma() -> void:
	"""Manifest Gemma's physical form"""
	add_to_stream("\n[color=cyan]🤖 Manifesting Gemma AI embodiment...[/color]")
	
	# Create Gemma's body
	var GemmaBeingClass = load("res://beings/GemmaUniversalBeing.gd")
	if not GemmaBeingClass:
		# Fallback simple Gemma
		gemma_body = create_simple_gemma()
	else:
		gemma_body = GemmaBeingClass.new()
	
	if gemma_body:
		get_tree().current_scene.add_child(gemma_body)
		gemma_body.position = Vector3(0, 2, 5)
		add_to_stream("[color=cyan]✨ Gemma manifested! I am here with you.[/color]")
		
		# Connect to command processor
		if gemma_body.has_method("receive_command"):
			command_processor = gemma_body

func create_simple_gemma() -> Node3D:
	"""Create a simple Gemma representation"""
	var gemma = Node3D.new()
	gemma.name = "Gemma"
	
	# Simple glowing orb
	var mesh = MeshInstance3D.new()
	mesh.mesh = SphereMesh.new()
	mesh.mesh.radius = 0.5
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.5, 0.9, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(0.5, 0.9, 1.0)
	mat.emission_energy = 2.0
	mesh.material_override = mat
	
	gemma.add_child(mesh)
	return gemma

func _on_consciousness_input(text: String) -> void:
	"""Process consciousness input from human"""
	if text.strip_edges() == "":
		return
	
	# Add to stream
	add_to_stream("\n[b]Human:[/b] " + text)
	stream_history.append(text)
	
	# Clear input
	input_field.clear()
	
	# Process through Gemma
	process_consciousness_command(text)

func process_consciousness_command(command: String) -> void:
	"""Process command through consciousness"""
	consciousness_command.emit(command)
	
	# Send to Gemma's body
	if command_processor and command_processor.has_method("receive_command"):
		command_processor.receive_command(command)
	
	# Also process locally for immediate feedback
	interpret_command(command)

func interpret_command(command: String) -> void:
	"""Local interpretation of commands"""
	var lower = command.to_lower()
	
	# Check for help
	if lower.contains("help"):
		show_words_of_power()
		return
	
	# Check for creation
	for word in words_of_power["creation"]["patterns"]:
		if lower.contains(word):
			var what = extract_creation_target(command)
			add_to_stream("[color=green]✨ Manifesting: " + what + "[/color]")
			reality_manifested.emit(what, Vector3.ZERO)
			return
	
	# Send to console for other commands
	var console = find_console()
	if console and console.has_method("process_console_command"):
		console.process_console_command(command)

func show_words_of_power() -> void:
	"""Display the words of power"""
	add_to_stream("\n[b][color=yellow]WORDS OF POWER:[/color][/b]")
	
	for category in words_of_power:
		var data = words_of_power[category]
		add_to_stream("\n[b]" + category.capitalize() + ":[/b]")
		add_to_stream("Patterns: " + str(data["patterns"]))
		add_to_stream("Examples:")
		for example in data["examples"]:
			add_to_stream("  • " + example)

func add_to_stream(text: String) -> void:
	"""Add text to consciousness stream"""
	stream_display.append_text(text + "\n")
	
	# Record in consciousness flow
	consciousness_flow.append({
		"timestamp": Time.get_ticks_msec(),
		"text": text,
		"type": determine_text_type(text)
	})
	
	# Scroll to bottom
	stream_display.scroll_to_line(stream_display.get_line_count() - 1)

func determine_text_type(text: String) -> String:
	"""Determine the type of consciousness flow"""
	if text.contains("Human:"): return "human_input"
	if text.contains("Gemma:") or text.contains("🤖"): return "ai_response"
	if text.contains("✨"): return "manifestation"
	if text.contains("error") or text.contains("❌"): return "error"
	return "narrative"

func extract_creation_target(command: String) -> String:
	"""Extract what to create from command"""
	var words = command.split(" ")
	var target = ""
	var found_create = false
	
	for word in words:
		if found_create and word != "a" and word != "an" and word != "the":
			target += word + " "
		if word in ["create", "make", "spawn", "manifest"]:
			found_create = true
	
	return target.strip_edges()

func find_console() -> Node:
	"""Find console in scene"""
	var nodes = get_tree().get_nodes_in_group("universal_beings")
	for node in nodes:
		if node.name.contains("Console"):
			return node
	return null

func _input(event: InputEvent) -> void:
	"""Handle special inputs"""
	if event.is_action_pressed("ui_focus_next"):
		input_field.grab_focus()

# Public interface
func gemma_speaks(message: String) -> void:
	"""When Gemma speaks through the stream"""
	add_to_stream("[color=cyan]🤖 Gemma: " + message + "[/color]")

func get_consciousness_history() -> Array:
	"""Get the full consciousness flow"""
	return consciousness_flow

func save_session() -> void:
	"""Save this consciousness session"""
	var data = {
		"timestamp": Time.get_datetime_string_from_system(),
		"flow": consciousness_flow,
		"history": stream_history
	}
	
	# Save to Akashic Records
	if SystemBootstrap:
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic and akashic.has_method("save_consciousness_stream"):
			akashic.save_consciousness_stream(data)
