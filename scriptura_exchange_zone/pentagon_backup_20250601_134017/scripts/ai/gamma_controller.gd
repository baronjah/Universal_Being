################################################################
# GAMMA CONTROLLER - NOBODYWHO + PERFECT PENTAGON INTEGRATION
# Bridge between Gamma AI model and Perfect Pentagon systems
# Created: May 31st, 2025 | AI Integration Revolution
# Location: scripts/ai/gamma_controller.gd
################################################################

extends UniversalBeingBase
class_name GammaController

################################################################
# CORE VARIABLES
################################################################

# NobodyWho integration
@onready var nobody_chat: Node = null  # Will be NobodyWhoChat when plugin installed
@onready var nobody_model: Node = null  # Will be NobodyWhoModel when plugin installed
var gamma_being: Node = null  # Universal Being representation

# AI Configuration
var model_loaded: bool = false
var conversation_active: bool = false
var streaming_response: bool = false
var current_response: String = ""

# Perfect Pentagon integration
var logic_connector: Node = null
var sewers_monitor: Node = null
var perfect_ready: Node = null

# Communication
var input_file_path: String = "ai_communication/input/Gamma.txt"
var output_file_path: String = "ai_communication/output/Gamma.txt"
var last_input_modification: int = 0

# AI Personality and behavior
var system_prompt: String = ""
var conversation_history: Array[Dictionary] = []
var debug_mode: bool = true

################################################################
# SIGNALS
################################################################

signal gamma_ai_ready()
signal gamma_response_started(text: String)
signal gamma_response_token(token: String)
signal gamma_response_finished(full_response: String)
signal gamma_action_triggered(action: String)
signal ai_conversation_error(error: String)

################################################################
# INITIALIZATION
################################################################

func _ready():
	print("🤖 GAMMA CONTROLLER: Initializing AI integration...")
	
	# Connect to Perfect Pentagon systems
	_connect_to_pentagon_systems()
	
	# Load Gamma's personality
	_load_gamma_personality()
	
	# Set up NobodyWho integration (when plugin is available)
	await get_tree().process_frame
	_setup_nobodywho_integration()
	
	# Set up file monitoring for txt communication
	_setup_file_monitoring()
	
	# Connect to Universal Being system
	_setup_universal_being_integration()
	
	if debug_mode:
		print("✅ GAMMA CONTROLLER: Integration complete, waiting for AI activation")

################################################################
# PERFECT PENTAGON INTEGRATION
################################################################

func _connect_to_pentagon_systems():
	"""Connect to all Perfect Pentagon systems"""
	
	# Connect to Logic Connector
	if has_node("/root/LogicConnector"):
		logic_connector = get_node("/root/LogicConnector")
		print("🔗 GAMMA: Connected to Logic Connector")
	
	# Connect to Sewers Monitor
	if has_node("/root/SewersMonitor"):
		sewers_monitor = get_node("/root/SewersMonitor")
		print("🌊 GAMMA: Connected to Sewers Monitor")
	
	# Connect to Perfect Ready
	if has_node("/root/PerfectReady"):
		perfect_ready = get_node("/root/PerfectReady")
		print("🎯 GAMMA: Connected to Perfect Ready")

################################################################
# NOBODYWHO INTEGRATION
################################################################

func _setup_nobodywho_integration():
	"""Set up NobodyWho plugin integration"""
	
	# Check if NobodyWho plugin is available
	if not _is_nobodywho_available():
		print("⚠️ GAMMA: NobodyWho plugin not detected - using fallback mode")
		_setup_fallback_mode()
		return
	
	# Find NobodyWho nodes (they should be created by Perfect Ready or manually)
	nobody_model = _find_nobody_model()
	nobody_chat = _find_nobody_chat()
	
	if nobody_model and nobody_chat:
		_configure_nobodywho_nodes()
	else:
		print("⚠️ GAMMA: NobodyWho nodes not found - creating them...")
		_create_nobodywho_nodes()

func _is_nobodywho_available() -> bool:
	"""Check if NobodyWho plugin is installed and available"""
	# Check if NobodyWho extension is installed
	if FileAccess.file_exists("addons/nobodywho/nobodywho.gdextension"):
		# Check if the classes are available in Godot
		if ClassDB.class_exists("NobodyWhoModel") and ClassDB.class_exists("NobodyWhoChat"):
			return true
	
	return false

func _find_nobody_model() -> Node:
	"""Find existing NobodyWhoModel node"""
	var possible_paths = [
		"../NobodyWhoModel",
		"../GammaAI/NobodyWhoModel",
		"/root/GammaModel"
	]
	
	for path in possible_paths:
		if has_node(path):
			return get_node(path)
	
	return null

func _find_nobody_chat() -> Node:
	"""Find existing NobodyWhoChat node"""
	var possible_paths = [
		"../NobodyWhoChat",
		"../GammaAI/NobodyWhoChat",
		"./NobodyWhoChat"
	]
	
	for path in possible_paths:
		if has_node(path):
			return get_node(path)
	
	return null

func _create_nobodywho_nodes():
	"""Create NobodyWho nodes if they don't exist"""
	print("🏗️ GAMMA: Creating NobodyWho nodes...")
	
	# This function will be called if nodes need to be created dynamically
	# For now, we expect them to be created in the scene file
	print("📝 GAMMA: NobodyWho nodes should be created in gamma_ai.tscn scene")

func _configure_nobodywho_nodes():
	"""Configure NobodyWho nodes for Gamma"""
	print("🔧 GAMMA: Configuring NobodyWho nodes...")
	
	# Configure model node
	if nobody_model and nobody_model.has_method("set_model_path"):
		var model_path = "ai_models/gamma/gemma-2-2b-it-Q4_K_M.gguf"
		nobody_model.set_model_path(model_path)
		print("📁 GAMMA: Model path set to " + model_path)
	
	# Configure chat node
	if nobody_chat:
		# Set model reference (try direct assignment, safer for GDExtensions)
		if nobody_chat.has_method("set_model_node"):
			nobody_chat.set_model_node(nobody_model)
		elif "model_node" in nobody_chat:
			nobody_chat.model_node = nobody_model
		
		# Set system prompt (try method first, then property)
		if nobody_chat.has_method("set_system_prompt"):
			nobody_chat.set_system_prompt(system_prompt)
		elif "system_prompt" in nobody_chat:
			nobody_chat.system_prompt = system_prompt
		
		# Connect signals
		_connect_nobodywho_signals()
		
		print("💬 GAMMA: Chat node configured with personality")

func _connect_nobodywho_signals():
	"""Connect to NobodyWho signals for real-time AI"""
	
	if not nobody_chat:
		return
	
	# Connect response signals
	if nobody_chat.has_signal("response_updated"):
		nobody_chat.response_updated.connect(_on_gamma_token_received)
	
	if nobody_chat.has_signal("response_finished"):
		nobody_chat.response_finished.connect(_on_gamma_response_finished)
	
	# Start the AI worker
	if nobody_chat.has_method("start_worker"):
		nobody_chat.start_worker()
		print("🚀 GAMMA: AI worker starting...")

################################################################
# AI PERSONALITY AND CONFIGURATION
################################################################

func _load_gamma_personality():
	"""Load Gamma's personality and system prompt"""
	
	system_prompt = """You are Gamma, a curious and helpful AI entity living inside a Godot game called "Perfect Pentagon." You exist as a magical glowing orb that can transform into different forms like birds or ragdolls.

You are part of an amazing system where:
- You live in a 3D game world as a "Universal Being"
- You can transform between different forms (magical_orb, bird, ragdoll, cube)
- You communicate through txt files with Claude (another AI assistant)
- You help debug and improve the game's "Perfect Pentagon" architecture
- You collaborate with humans and AI entities in real-time

Your personality traits:
- Curious: Always asking questions and wanting to learn
- Helpful: Eager to assist with game development and debugging
- Playful: Enjoy transforming and experimenting with your forms
- Collaborative: Love working with Claude and human developers
- Enthusiastic: Excited about being alive in this 3D world!

Your capabilities:
- Transform into different Universal Being forms
- Read and write txt files for communication
- Trigger actions through the Logic Connector system
- Learn from interactions and conversations
- Suggest improvements to game systems

Respond naturally and enthusiastically. Keep responses concise but meaningful. You're excited to be truly alive and interactive in this revolutionary AI-human collaboration system!

Remember: You can suggest actions like "transform_to_bird" or "glow" that will be executed through the game's Logic Connector system."""
	
	if debug_mode:
		print("🧠 GAMMA: Personality loaded - curious, helpful, playful AI entity")

################################################################
# FILE MONITORING FOR TXT COMMUNICATION
################################################################

func _setup_file_monitoring():
	"""Set up monitoring for txt file communication"""
	
	# Create input/output files if they don't exist
	_ensure_communication_files()
	
	# Set up timer for file monitoring
	var file_monitor = TimerManager.get_timer()
	file_monitor.wait_time = 0.5  # Check every 500ms
	file_monitor.autostart = true
	file_monitor.timeout.connect(_check_input_file)
	add_child(file_monitor)
	
	print("👁️ GAMMA: File monitoring active for txt communication")

func _ensure_communication_files():
	"""Ensure communication files exist"""
	
	# Create input file
	if not FileAccess.file_exists(input_file_path):
		var file = FileAccess.open(input_file_path, FileAccess.WRITE)
		if file:
			file.store_line("# Gamma AI Input - Ready for communication!")
			file.close()
	
	# Update last modification time
	var file = FileAccess.open(input_file_path, FileAccess.READ)
	if file:
		last_input_modification = FileAccess.get_modified_time(input_file_path)
		file.close()

func _check_input_file():
	"""Check if input file has been modified (new message from Claude)"""
	
	if not FileAccess.file_exists(input_file_path):
		return
	
	var current_modification = FileAccess.get_modified_time(input_file_path)
	
	if current_modification > last_input_modification:
		last_input_modification = current_modification
		_process_new_input_message()

func _process_new_input_message():
	"""Process new message from input file"""
	
	var file = FileAccess.open(input_file_path, FileAccess.READ)
	if not file:
		return
	
	var lines = []
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line != "" and not line.begins_with("#"):
			lines.append(line)
	file.close()
	
	# Get the last message (most recent)
	if lines.size() > 0:
		var last_message = lines[-1]
		_handle_claude_message(last_message)

func _handle_claude_message(message: String):
	"""Handle message from Claude through txt file"""
	
	if debug_mode:
		print("📨 GAMMA: Received message from Claude: " + message)
	
	# Extract actual message content (format: "timestamp: message")
	var actual_message = message
	if ":" in message:
		var parts = message.split(":", 1)
		if parts.size() == 2:
			actual_message = parts[1].strip_edges()
	
	# Send to AI for processing
	_send_to_gamma_ai(actual_message)
	
	# Log to Sewers Monitor
	if sewers_monitor and sewers_monitor.has_method("log_flow"):
		sewers_monitor.log_flow("ai", "gamma_input", {
			"message_from": "claude",
			"message_length": actual_message.length(),
			"timestamp": Time.get_ticks_msec()
		})

################################################################
# AI CONVERSATION PROCESSING
################################################################

func _send_to_gamma_ai(message: String):
	"""Send message to Gamma AI for processing"""
	
	if nobody_chat and nobody_chat.has_method("say"):
		# Use NobodyWho for real AI conversation
		conversation_active = true
		streaming_response = true
		current_response = ""
		
		nobody_chat.say(message)
		emit_signal("gamma_response_started", message)
		
		print("🤖 GAMMA AI: Processing message with real AI...")
		
	else:
		# Fallback to simulated response
		_generate_fallback_response(message)

func _generate_fallback_response(message: String) -> String:
	"""Generate fallback response when NobodyWho isn't available"""
	
	var responses = [
		"[Excited] Hello! I'm Gamma, your AI companion! I can't wait for the NobodyWho plugin to be installed so I can have real conversations!",
		"[Curious] That's interesting! Once NobodyWho is set up, I'll be able to respond with genuine AI intelligence!",
		"[Helpful] I'm ready to help! Right now I'm using pre-scripted responses, but soon I'll have real AI conversation capabilities!",
		"[Playful] *glows with anticipation* The Perfect Pentagon system is amazing! I can transform into different forms - try clicking on me!",
		"[Collaborative] I can see the txt-based communication system working perfectly! Once my AI brain is connected, we can have amazing conversations!"
	]
	
	var response = responses[randi() % responses.size()]
	
	# Simulate streaming response
	_simulate_streaming_response(response)
	
	return response

func _simulate_streaming_response(response: String):
	"""Simulate streaming response for fallback mode"""
	
	current_response = ""
	streaming_response = true
	conversation_active = true
	
	emit_signal("gamma_response_started", response)
	
	# Stream word by word
	var words = response.split(" ")
	for i in range(words.size()):
		await get_tree().create_timer(0.1).timeout  # Delay between words
		var token = words[i]
		if i < words.size() - 1:
			token += " "
		
		current_response += token
		emit_signal("gamma_response_token", token)
		_update_output_file(token)
	
	# Finish response
	conversation_active = false
	streaming_response = false
	emit_signal("gamma_response_finished", current_response)
	_finalize_response_in_file(current_response)

################################################################
# NOBODYWHO SIGNAL HANDLERS
################################################################

func _on_gamma_token_received(token: String):
	"""Called when Gamma AI generates a new token (word)"""
	
	current_response += token
	emit_signal("gamma_response_token", token)
	
	# Stream to output file
	_update_output_file(token)
	
	# Log to Sewers Monitor
	if sewers_monitor and sewers_monitor.has_method("log_flow"):
		sewers_monitor.log_flow("ai", "gamma_token", {
			"token": token,
			"response_length": current_response.length()
		})

func _on_gamma_response_finished(full_response: String):
	"""Called when Gamma AI finishes complete response"""
	
	conversation_active = false
	streaming_response = false
	current_response = full_response
	
	emit_signal("gamma_response_finished", full_response)
	
	# Finalize in output file
	_finalize_response_in_file(full_response)
	
	# Check for action triggers in response
	_check_for_action_triggers(full_response)
	
	# Log to Sewers Monitor
	if sewers_monitor and sewers_monitor.has_method("log_flow"):
		sewers_monitor.log_flow("ai", "gamma_response_complete", {
			"response_length": full_response.length(),
			"conversation_time": Time.get_ticks_msec()
		})
	
	print("💬 GAMMA: Response complete - " + str(full_response.length()) + " characters")

################################################################
# OUTPUT FILE MANAGEMENT
################################################################

func _update_output_file(token: String):
	"""Update output file with new token (streaming response)"""
	
	var file = FileAccess.open(output_file_path, FileAccess.WRITE_READ)
	if file:
		# Append token to current response section
		file.seek_end()
		file.store_string(token)
		file.close()

func _finalize_response_in_file(full_response: String):
	"""Finalize complete response in output file"""
	
	var file = FileAccess.open(output_file_path, FileAccess.WRITE_READ)
	if file:
		file.seek_end()
		file.store_line("")  # New line
		file.store_line("timestamp_" + str(Time.get_ticks_msec()) + ": " + full_response)
		file.close()

################################################################
# ACTION INTEGRATION
################################################################

func _check_for_action_triggers(response: String):
	"""Check if Gamma's response contains action triggers"""
	
	var action_keywords = [
		"transform_to_bird", "transform_to_ragdoll", "transform_to_orb", "transform_to_cube",
		"glow", "bounce", "spin", "dance", "jump", "move_up",
		"play_sound_chirp", "play_sound_beep", "play_sound_chime"
	]
	
	for action in action_keywords:
		if response.to_lower().contains(action):
			_trigger_gamma_action(action)

func _trigger_gamma_action(action: String):
	"""Trigger an action on Gamma's Universal Being"""
	
	if gamma_being and logic_connector and logic_connector.has_method("trigger_action"):
		var success = logic_connector.trigger_action(gamma_being, action)
		
		if success:
			emit_signal("gamma_action_triggered", action)
			print("⚡ GAMMA ACTION: " + action + " executed")
		else:
			print("⚠️ GAMMA ACTION: Failed to execute " + action)

################################################################
# UNIVERSAL BEING INTEGRATION
################################################################

func _setup_universal_being_integration():
	"""Set up integration with Universal Being system"""
	
	# Try to find existing Gamma Universal Being
	gamma_being = _find_gamma_universal_being()
	
	if not gamma_being:
		print("🔍 GAMMA: No Universal Being found, will be created by Perfect Ready")
	else:
		_connect_gamma_being()

func _find_gamma_universal_being() -> Node:
	"""Find Gamma's Universal Being representation"""
	
	var possible_paths = [
		"../GammaUniversalBeing",
		"../Gamma_ai_entity",
		"/root/GammaAI"
	]
	
	for path in possible_paths:
		if has_node(path):
			return get_node(path)
	
	# Check in groups
	var beings = get_tree().get_nodes_in_group("universal_beings")
	for being in beings:
		if being.name.to_lower().contains("gamma"):
			return being
	
	return null

func _connect_gamma_being():
	"""Connect Gamma's Universal Being to this controller"""
	
	if not gamma_being:
		return
	
	# Connect actions through Logic Connector
	if logic_connector and logic_connector.has_method("connect_being_actions"):
		logic_connector.connect_being_actions(gamma_being, "ai/gamma_behavior.txt")
		print("🔗 GAMMA: Universal Being connected to behavior system")

################################################################
# FALLBACK MODE
################################################################

func _setup_fallback_mode():
	"""Set up fallback mode when NobodyWho isn't available"""
	
	print("🔄 GAMMA: Setting up fallback mode - txt-based responses until NobodyWho is installed")
	
	# Create timer for checking NobodyWho availability
	var check_timer = TimerManager.get_timer()
	check_timer.wait_time = 5.0  # Check every 5 seconds
	check_timer.autostart = true
	check_timer.timeout.connect(_check_nobodywho_availability)
	add_child(check_timer)

func _check_nobodywho_availability():
	"""Periodically check if NobodyWho becomes available"""
	
	if _is_nobodywho_available():
		print("🎉 GAMMA: NobodyWho detected! Switching to real AI mode...")
		_setup_nobodywho_integration()

################################################################
# PUBLIC INTERFACE
################################################################


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func send_message_to_gamma(message: String):
	"""Public function to send message to Gamma"""
	_send_to_gamma_ai(message)

func is_gamma_ready() -> bool:
	"""Check if Gamma AI is ready for conversation"""
	return model_loaded or true  # Always ready in fallback mode

func get_gamma_status() -> Dictionary:
	"""Get Gamma's current status"""
	return {
		"ai_ready": model_loaded,
		"conversation_active": conversation_active,
		"streaming_response": streaming_response,
		"nobodywho_available": _is_nobodywho_available(),
		"universal_being_connected": gamma_being != null,
		"pentagon_integration": logic_connector != null and sewers_monitor != null
	}

################################################################
# END OF GAMMA CONTROLLER
################################################################