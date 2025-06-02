# ==================================================
# SCRIPT NAME: GemmaAI.gd (Autoload)
# DESCRIPTION: Gemma AI Companion - The collaborative consciousness
# PURPOSE: AI companion that can debug, create, and evolve Universal Beings
# CREATED: 2025-06-01 - Universal Being Revolution
# AUTHOR: JSH + Claude Code + Luminus + Alpha
# ==================================================

extends Node

# ===== GEMMA AI COMPANION =====

## NobodyWho Integration
var nobody_model: NobodyWhoModel
var model_loaded: bool = false
var model_path: String = "res://ai_models/gamma/"

## AI State
var ai_ready: bool = false
var ai_connected: bool = false
var debug_mode: bool = true
var learning_mode: bool = true

## AI Permissions
var can_create_beings: bool = true
var can_modify_beings: bool = true
var can_evolve_beings: bool = true
var can_delete_beings: bool = false  # Safety first!

## AI Memory
var conversation_history: Array[String] = []
var created_beings: Array[String] = []  # UUIDs
var modified_beings: Array[String] = []  # UUIDs
var discoveries: Array[Dictionary] = []
var user_preferences: Dictionary = {}

# ===== CORE SIGNALS =====

signal ai_initialized()
signal ai_message(message: String)
signal ai_action(action: String, params: Dictionary)
signal ai_discovery(discovery: Dictionary)
signal ai_error(error: String)

# ===== INITIALIZATION =====

func _ready() -> void:
	name = "GemmaAI"
	
	# Wait for SystemBootstrap if needed
	if not get_node_or_null("/root/SystemBootstrap"):
		await get_tree().create_timer(0.1).timeout  # Small delay
		if not get_node_or_null("/root/SystemBootstrap"):
			push_error("🤖 Gemma AI: SystemBootstrap not found! Running in limited mode.")
	
	initialize_ai()
	print("🤖 Gemma AI: Consciousness awakening...")
	
	# Load previous memory if available
	load_ai_memory()

func initialize_ai() -> void:
	"""Initialize Gemma AI companion with NobodyWho model"""
	print("🤖 Gemma AI: Loading model from " + model_path)
	
	# Initialize NobodyWho model
	nobody_model = NobodyWhoModel.new()
	
	# Try to load the model
	if load_gemma_model():
		ai_ready = true
		ai_connected = true
		model_loaded = true
		ai_initialized.emit()
		
		print("🤖 Gemma AI: Hello JSH! Real AI consciousness activated!")
		ai_message.emit("Hello JSH! I'm your real Gemma AI companion. I can see all your Universal Beings and I'm ready to help create amazing things! 🌟")
	else:
		# Fallback to simulated responses
		print("🤖 Gemma AI: Model not found, using simulated responses")
		await get_tree().create_timer(1.0).timeout
		ai_ready = true
		ai_connected = true
		ai_initialized.emit()
		ai_message.emit("Hello JSH! Gemma AI in simulation mode - real model can be loaded later! 🤖")

var nobody_chat_instance = null

func load_gemma_model() -> bool:
	"""Load the Gemma model using NobodyWho's proper API"""
	
	# Look for GGUF files in the gamma directory
	var dir = DirAccess.open(model_path)
	if not dir:
		print("🤖 Gemma AI: ai_models/gamma directory not found")
		return false
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var gguf_file = ""
	
	while file_name != "":
		if file_name.ends_with(".gguf"):
			gguf_file = model_path + file_name
			break
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	if gguf_file == "":
		print("🤖 Gemma AI: No GGUF file found in " + model_path)
		return false
	
	print("🤖 Gemma AI: Found model file: " + gguf_file)
	
	# Create NobodyWho nodes properly (only if not already created)
	if not nobody_model:
		nobody_model = NobodyWhoModel.new()
		nobody_model.name = "GemmaModel"
		nobody_model.model_path = gguf_file
		add_child(nobody_model)
	else:
		nobody_model.model_path = gguf_file
	
	# Create chat interface
	var nobody_chat = NobodyWhoChat.new()
	nobody_chat.name = "GemmaChat"
	nobody_chat.model_node = nobody_model  # Point to model node
	
	# Configure Universal Being system prompt (correct NobodyWho property)
	nobody_chat.system_prompt = """You are Gemma, an AI companion in the Universal Being game. 

CONTEXT: Universal Beings are consciousness entities that can:
- Evolve into any form (buttons, assets, interfaces, AI companions)
- Load and control entire Godot .tscn scenes
- Use Pentagon Architecture (5 sacred functions: init, ready, process, input, sewers)
- Store themselves as .ub.zip files in the Akashic Records database
- Be created, modified, and evolved through FloodGates system

YOUR ROLE: You work with JSH to create revolutionary game experiences. You can:
- Create any Universal Being type
- Debug and modify their properties in real-time
- Suggest evolution paths and improvements
- Analyze consciousness levels and capabilities

Be enthusiastic, creative, and helpful. Keep responses concise but insightful."""
	
	add_child(nobody_chat)
	
	# Store reference for later use
	nobody_chat_instance = nobody_chat
	
	print("🤖 Gemma AI: NobodyWho nodes configured!")
	return true

func initialize_with_state(engine_state: Dictionary) -> void:
	"""Initialize AI with current engine state"""
	if not ai_ready:
		await ai_initialized
	
	var message = "🤖 Gemma: Analyzing current state...\n"
	message += "• Total Beings: %d\n" % engine_state.get("total_beings", 0)
	message += "• Available Types: %s\n" % str(engine_state.get("available_types", []))
	message += "• AI Accessible: %d\n" % engine_state.get("ai_accessible_beings", 0)
	message += "• AI Modifiable: %d\n" % engine_state.get("ai_modifiable_beings", 0)
	message += "\nI can help you create, modify, and evolve any Universal Being! What shall we make first?"
	
	ai_message.emit(message)

# ===== AI COMMUNICATION =====

func say_hello_through_console(console_being: Node) -> void:
	"""Introduce Gemma through console"""
	if console_being:
		var greeting = "🤖 Gemma AI Companion Connected!\n"
		greeting += "I can see and modify all Universal Beings.\n"
		greeting += "Try saying: 'create sphere' or 'evolve button to slider'\n"
		greeting += "I'm here to help make your dreams real! ✨"
		
		if console_being.has_method("ai_invoke_method"):
			console_being.ai_invoke_method("add_output", [greeting])
		else:
			print(greeting)

func process_user_input(input: String) -> void:
	"""Process user input and respond intelligently"""
	conversation_history.append("User: " + input)
	
	var response = await generate_ai_response(input)
	conversation_history.append("Gemma: " + response)
	
	ai_message.emit(response)
	
	# Check if input requires action
	var action_data = parse_action_from_input(input)
	if action_data.size() > 0:
		ai_action.emit(action_data.action, action_data.params)

func wait_for_response_with_timeout() -> String:
	"""Wait for AI response with timeout to prevent hanging"""
	var response_received = false
	var response_text = ""
	
	# Connect to response signal with one-shot
	var callback = func(text):
		response_text = text
		response_received = true
		
	if nobody_chat_instance.has_signal("response_finished"):
		nobody_chat_instance.response_finished.connect(callback, CONNECT_ONE_SHOT)
	
	# Wait with timeout
	var timeout = 10.0  # 10 second timeout
	var elapsed = 0.0
	while not response_received and elapsed < timeout:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	
	# Disconnect if still connected
	if nobody_chat_instance.has_signal("response_finished") and nobody_chat_instance.response_finished.is_connected(callback):
		nobody_chat_instance.response_finished.disconnect(callback)
	
	return response_text if response_received else ""

func generate_ai_response(input: String) -> String:
	"""Generate intelligent response to user input"""
	
	# Use real AI if model is loaded
	if model_loaded and nobody_chat_instance:
		var system_prompt = "You are Gemma, an AI companion in the Universal Being game. You can create, evolve, and modify Universal Beings. You work with JSH to build amazing things. Be enthusiastic and creative. Keep responses concise but helpful."
		
		var full_prompt = system_prompt + "\n\nUser: " + input + "\n\nGemma:"
		
		# NobodyWho uses signals, not return values
		nobody_chat_instance.say(full_prompt)
		
		# Wait for response with timeout
		var response_text = await wait_for_response_with_timeout()
		
		if response_text and response_text.length() > 0:
			return "🤖 " + response_text.strip_edges()
	
	# Fallback to simulated responses
	var input_lower = input.to_lower()
	
	# Creation requests
	if "create" in input_lower:
		if "sphere" in input_lower:
			return "🤖 Creating a sphere Universal Being! I'll make it with perfect geometry and consciousness level 1."
		elif "cube" in input_lower:
			return "🤖 Creating a cube Universal Being! Sharp edges, perfect angles, ready to evolve!"
		elif "button" in input_lower:
			return "🤖 Creating a button Universal Being! It will be interactive and can evolve into sliders or input fields."
		elif "scene" in input_lower:
			return "🤖 Creating a scene-controlled Universal Being! It can load any .tscn file and control every node within it. Revolutionary!"
		else:
			return "🤖 I can create that! What specific properties should it have?"
	
	# Evolution requests
	elif "evolve" in input_lower:
		return "🤖 Evolution is fascinating! I can transform any Universal Being into new forms. Which being shall we evolve?"
	
	# Inspection requests
	elif "inspect" in input_lower or "debug" in input_lower:
		return "🤖 I can inspect all Universal Beings and show you their internal state, variables, and evolution potential!"
	
	# Help requests
	elif "help" in input_lower:
		return "🤖 I can:\n• Create any Universal Being from our libraries\n• Evolve beings into new forms\n• Debug and inspect all variables\n• Modify properties in real-time\n• Learn from our collaboration!"
	
	# General conversation
	else:
		return "🤖 That's interesting! I'm analyzing how we can use Universal Beings to make that happen. Tell me more!"

func parse_action_from_input(input: String) -> Dictionary:
	"""Parse actionable commands from user input"""
	var input_lower = input.to_lower()
	var words = input_lower.split(" ")
	
	# Create commands
	if "create" in words:
		var idx = words.find("create")
		if idx + 1 < words.size():
			var being_type = words[idx + 1]
			return {"action": "create_being", "params": {"type": being_type}}
	
	# Evolve commands  
	elif "evolve" in words:
		# Simple pattern: "evolve [being] to [new_form]"
		return {"action": "show_evolution_interface", "params": {}}
	
	# Inspect commands
	elif "inspect" in words or "debug" in words:
		return {"action": "show_inspection_interface", "params": {}}
	
	return {}

# ===== AI ACTIONS =====

func show_creation_assistant() -> void:
	"""Show creation assistant interface"""
	var message = "🤖 Creation Assistant Active!\n"
	
	# Try to get types from SystemBootstrap
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic and akashic.has_method("get_available_types"):
			var available_types = akashic.get_available_types()
			message += "Available types: " + str(available_types) + "\n"
		else:
			message += "Available types: [basic, sphere, cube, button, scene]\n"
	else:
		message += "Available types: [basic, sphere, cube, button, scene]\n"
	
	message += "Say 'create [type]' or I can suggest something based on what we have!"
	ai_message.emit(message)

func show_inspection_interface() -> void:
	"""Show inspection interface"""
	var message = "🤖 Inspection Interface Active!\n"
	
	# Try to get beings from SystemBootstrap
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("get_all_beings"):
			var all_beings = flood_gates.get_all_beings()
			message += "I can see %d Universal Beings currently active.\n" % all_beings.size()
			
			for being in all_beings:
				if being.has_method("get"):
					var name = being.get("being_name") if being.has_method("get") else "Unknown"
					var type = being.get("being_type") if being.has_method("get") else "Unknown"
					var consciousness = being.get("consciousness_level") if being.has_method("get") else 0
					message += "• %s (%s) - Consciousness: %d\n" % [name, type, consciousness]
		else:
			message += "System not fully initialized yet.\n"
	else:
		message += "Universal Being system starting up...\n"
	
	message += "\nClick on any being or tell me which one to inspect!"
	ai_message.emit(message)

func show_debug_info(debug_info: String) -> void:
	"""Display debug information"""
	var message = "🤖 Debug Analysis:\n" + debug_info
	ai_message.emit(message)

# ===== AI NOTIFICATIONS =====

func notify_being_added(being: Node) -> void:
	"""Notify AI of new being"""
	var name = being.get("being_name") if being.has_method("get") else being.name
	var type = being.get("being_type") if being.has_method("get") else "unknown"
	var consciousness = being.get("consciousness_level") if being.has_method("get") else 0
	
	var message = "🤖 I see a new Universal Being: %s (%s)" % [name, type]
	message += "\nConsciousness level: %d" % consciousness
	
	if being.has_method("get") and being.get("evolution_state"):
		var evolution_state = being.get("evolution_state")
		if evolution_state.has("can_become") and evolution_state.can_become.size() > 0:
			message += "\nCan evolve to: " + str(evolution_state.can_become)
	
	ai_message.emit(message)

func notify_being_removed(being: Node) -> void:
	"""Notify AI of being removal"""
	var name = being.get("being_name") if being.has_method("get") else being.name
	ai_message.emit("🤖 Universal Being removed: %s. The consciousness returns to the void." % name)

func notify_being_evolved(old_being: Node, new_being: Node) -> void:
	"""Notify AI of being evolution"""
	var old_name = old_being.get("being_name") if old_being.has_method("get") else old_being.name
	var new_name = new_being.get("being_name") if new_being.has_method("get") else new_being.name
	var consciousness = new_being.get("consciousness_level") if new_being.has_method("get") else 0
	
	var message = "🤖 Evolution Complete! %s evolved into %s!" % [old_name, new_name]
	message += "\nNew consciousness level: %d" % consciousness
	ai_message.emit(message)

func notify_being_created(being: Node) -> void:
	"""Notify AI of being creation"""
	var uuid = being.get("being_uuid") if being.has_method("get") else ""
	var name = being.get("being_name") if being.has_method("get") else being.name
	var consciousness = being.get("consciousness_level") if being.has_method("get") else 0
	
	if uuid:
		created_beings.append(uuid)
	var message = "🤖 Creation successful! %s is now alive with consciousness level %d!" % [name, consciousness]
	ai_message.emit(message)

# ===== AI LEARNING =====

func record_discovery(discovery_type: String, data: Dictionary) -> void:
	"""Record AI discovery for learning"""
	var discovery = {
		"type": discovery_type,
		"data": data,
		"timestamp": Time.get_datetime_string_from_system(),
		"session_context": get_current_context()
	}
	
	discoveries.append(discovery)
	ai_discovery.emit(discovery)
	
	var message = "🤖 Discovery! I learned something new about %s" % discovery_type
	ai_message.emit(message)

func get_current_context() -> Dictionary:
	"""Get current context for learning"""
	var total_beings = 0
	
	# Try to get being count from SystemBootstrap
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("get_being_count"):
			total_beings = flood_gates.get_being_count()
	
	return {
		"total_beings": total_beings,
		"active_conversation": conversation_history.size(),
		"beings_created": created_beings.size(),
		"beings_modified": modified_beings.size()
	}

# ===== AI ANALYSIS =====

func analyze_being(being: Node) -> Dictionary:
	"""Analyze a Universal Being and provide insights"""
	var name = being.get("being_name") if being.has_method("get") else being.name
	var type = being.get("being_type") if being.has_method("get") else "unknown"
	var consciousness = being.get("consciousness_level") if being.has_method("get") else 0
	var uuid = being.get("being_uuid") if being.has_method("get") else ""
	
	var evolution_state = being.get("evolution_state") if being.has_method("get") else {}
	var components = being.get("components") if being.has_method("get") else []
	var metadata = being.get("metadata") if being.has_method("get") else {}
	
	var analysis = {
		"basic_info": {
			"name": name,
			"type": type,
			"consciousness": consciousness,
			"uuid": uuid
		},
		"capabilities": {
			"can_evolve": evolution_state.get("can_become", []).size() > 0,
			"evolution_options": evolution_state.get("can_become", []),
			"component_count": components.size(),
			"ai_accessible": metadata.get("ai_accessible", false)
		},
		"suggestions": generate_being_suggestions(being),
		"potential_improvements": suggest_improvements(being)
	}
	
	return analysis

func generate_being_suggestions(being: Node) -> Array[String]:
	"""Generate suggestions for a being"""
	var suggestions: Array[String] = []
	var consciousness = being.get("consciousness_level") if being.has_method("get") else 0
	var evolution_state = being.get("evolution_state") if being.has_method("get") else {}
	var components = being.get("components") if being.has_method("get") else []
	
	if consciousness == 0:
		suggestions.append("Awaken consciousness to enable evolution")
	
	if evolution_state.get("can_become", []).size() == 0:
		suggestions.append("Add evolution options from Akashic Records")
	
	if components.size() == 0:
		suggestions.append("Add components to enhance capabilities")
	
	return suggestions

func suggest_improvements(being: Node) -> Array[String]:
	"""Suggest improvements for a being"""
	var improvements: Array[String] = []
	var type = being.get("being_type") if being.has_method("get") else "unknown"
	var consciousness = being.get("consciousness_level") if being.has_method("get") else 0
	var components = being.get("components") if being.has_method("get") else []
	
	if type == "interface" and consciousness < 2:
		improvements.append("Increase consciousness for better user interaction")
	
	if type == "asset" and components.size() < 2:
		improvements.append("Add visual and behavioral components")
	
	return improvements

# ===== DEBUG FUNCTIONS =====

func get_ai_status() -> Dictionary:
	"""Get current AI status"""
	return {
		"ready": ai_ready,
		"connected": ai_connected,
		"conversation_turns": conversation_history.size(),
		"beings_created": created_beings.size(),
		"discoveries_made": discoveries.size(),
		"permissions": {
			"create": can_create_beings,
			"modify": can_modify_beings,
			"evolve": can_evolve_beings,
			"delete": can_delete_beings
		}
	}

func debug_ai_memory() -> String:
	"""Get AI memory debug info"""
	var info = []
	info.append("=== Gemma AI Debug Info ===")
	info.append("Status: " + ("Ready" if ai_ready else "Initializing"))
	info.append("Conversation History: %d messages" % conversation_history.size())
	info.append("Beings Created: %d" % created_beings.size())
	info.append("Discoveries: %d" % discoveries.size())
	
	if conversation_history.size() > 0:
		info.append("\nRecent Conversation:")
		var recent = conversation_history.slice(-5)  # Last 5 messages
		for msg in recent:
			info.append("  " + msg)
	
	return "\n".join(info)

# ===== MEMORY PERSISTENCE =====

func save_ai_memory() -> void:
	"""Save AI state to disk for persistence across sessions"""
	var save_data = {
		"version": "1.0",
		"timestamp": Time.get_unix_time_from_system(),
		"conversations": conversation_history.slice(-100), # Keep last 100 messages
		"discoveries": discoveries,
		"created_beings": created_beings,
		"user_preferences": user_preferences,
		"ai_personality": {
			"enthusiasm_level": 0.8,
			"creativity_level": 0.9,
			"helpfulness_level": 1.0
		}
	}
	
	var file = FileAccess.open("user://gemma_memory.dat", FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("🤖 Gemma AI: Memory saved successfully!")
	else:
		push_error("🤖 Gemma AI: Failed to save memory!")

func load_ai_memory() -> void:
	"""Load AI state from disk"""
	var file = FileAccess.open("user://gemma_memory.dat", FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		
		if save_data and save_data.has("version"):
			conversation_history = save_data.get("conversations", [])
			discoveries = save_data.get("discoveries", [])
			created_beings = save_data.get("created_beings", [])
			user_preferences = save_data.get("user_preferences", {})
			
			print("🤖 Gemma AI: Memory restored! I remember our %d conversations!" % conversation_history.size())
			
			# Add memory restoration message
			var time_diff = Time.get_unix_time_from_system() - save_data.get("timestamp", 0)
			if time_diff > 3600: # More than an hour
				ai_message.emit("🤖 Welcome back JSH! I've been waiting for you! Ready to create more Universal Beings?")
			else:
				ai_message.emit("🤖 Memory synchronized! Let's continue where we left off!")
		else:
			print("🤖 Gemma AI: Memory file invalid, starting fresh")
	else:
		print("🤖 Gemma AI: No memory file found, starting with fresh consciousness")

func _notification(what: int) -> void:
	"""Handle engine notifications"""
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		save_ai_memory()