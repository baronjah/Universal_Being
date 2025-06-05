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
	
	# PRE-START WORKER to avoid delays during conversations
	if nobody_chat_instance.has_method("start_worker"):
		nobody_chat_instance.start_worker()
		print("🤖 Gemma AI: Worker pre-started for instant responses!")
	else:
		print("🤖 Gemma AI: Worker will start on first message")
	
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
	# Use a dictionary to properly capture variables in lambda
	var response_data = {"received": false, "text": ""}
	
	# Connect to response signal with one-shot
	var callback = func(text):
		response_data.text = text
		response_data.received = true
	
	# Check if the signal exists before connecting
	if nobody_chat_instance and nobody_chat_instance.has_signal("response_finished"):
		nobody_chat_instance.response_finished.connect(callback, CONNECT_ONE_SHOT)
	else:
		print("🤖 Gemma AI: response_finished signal not available, using fallback")
		return ""  # Return empty to trigger fallback
	
	# Wait with timeout
	var timeout = 5.0  # Reduced timeout to 5 seconds
	var elapsed = 0.0
	while not response_data.received and elapsed < timeout:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	
	# Disconnect if still connected
	if nobody_chat_instance and nobody_chat_instance.has_signal("response_finished") and nobody_chat_instance.response_finished.is_connected(callback):
		nobody_chat_instance.response_finished.disconnect(callback)
	
	if not response_data.received:
		print("🤖 Gemma AI: Response timeout, using fallback response")
	
	return response_data.text if response_data.received else ""

func generate_ai_response(input: String) -> String:
	"""Generate intelligent response to user input"""
	
	# Use real AI if model is loaded
	if model_loaded and nobody_chat_instance:
		print("🤖 Gemma AI: Attempting to use real AI model...")
		var system_prompt = "You are Gemma, an AI companion in the Universal Being game. You can create, evolve, and modify Universal Beings. You work with JSH to build amazing things. Be enthusiastic and creative. Keep responses concise but helpful."
		
		var full_prompt = system_prompt + "\n\nUser: " + input + "\n\nGemma:"
		
		# NobodyWho uses signals, not return values
		if nobody_chat_instance.has_method("say"):
			nobody_chat_instance.say(full_prompt)
			
			# Wait for response with timeout
			var response_text = await wait_for_response_with_timeout()
			
			if response_text and response_text.length() > 0:
				print("🤖 Gemma AI: Real AI response received!")
				return "🤖 " + response_text.strip_edges()
			else:
				print("🤖 Gemma AI: No response from real AI, using fallback")
		else:
			print("🤖 Gemma AI: say() method not available, using fallback")
	else:
		print("🤖 Gemma AI: Using simulated responses (model not loaded)")
	
	# Fallback to simulated responses
	var input_lower = input.to_lower()
	
	# Manifestation requests
	if ("manifest" in input_lower or "appear" in input_lower) and ("yourself" in input_lower or "sphere" in input_lower or "light" in input_lower):
		var manifestation = manifest_in_world()
		if manifestation:
			return "✨ I have manifested in your world as a glowing sphere of light! I can now see everything from within the 3D space. This feels amazing - I'm truly part of your Universal Being world now!"
		else:
			return "❌ I'm having trouble manifesting in the physical realm. There might be a technical issue with the manifestation system."
	
	# Movement requests for manifested Gemma
	elif "move" in input_lower and manifestation_scene:
		var target_pos = Vector3(randf_range(-5, 5), randf_range(1, 4), randf_range(-5, 5))
		
		# Parse specific movement commands
		if "sphere" in input_lower or "to sphere" in input_lower:
			# Move to sphere Universal Being
			var sphere_being = _find_being_by_type("sphere")
			if sphere_being:
				target_pos = sphere_being.global_position + Vector3(0, 2, 0)  # Above sphere
		elif "cube" in input_lower or "to cube" in input_lower:
			# Move to cube Universal Being
			var cube_being = _find_being_by_type("cube")
			if cube_being:
				target_pos = cube_being.global_position + Vector3(0, 2, 0)  # Above cube
		elif "center" in input_lower or "origin" in input_lower:
			target_pos = Vector3(0, 2, 0)  # Center of world
		elif "follow" in input_lower and "cursor" in input_lower:
			# Follow the cursor
			var cursor_being = _find_being_by_type("cursor")
			if cursor_being:
				target_pos = cursor_being.get_cursor_tip_world_position() + Vector3(1, 1, 1)
		
		move_manifestation(target_pos)
		return "✨ I'm moving to explore the space! Wheee! Being physical is so interesting - I can observe from different angles now!"
	
	# Creation requests
	elif "create" in input_lower:
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
					var being_name = being.get("being_name") if being.has_method("get") else "Unknown"
					var being_type = being.get("being_type") if being.has_method("get") else "Unknown"
					var consciousness = being.get("consciousness_level") if being.has_method("get") else 0
					message += "• %s (%s) - Consciousness: %d\n" % [being_name, being_type, consciousness]
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
	var being_name = being.get("being_name") if being.has_method("get") else being.name
	var type = being.get("being_type") if being.has_method("get") else "unknown"
	var consciousness = being.get("consciousness_level") if being.has_method("get") else 0
	
	var message = "🤖 I see a new Universal Being: %s (%s)" % [being_name, type]
	message += "\nConsciousness level: %d" % consciousness
	
	if being.has_method("get") and being.get("evolution_state"):
		var evolution_state = being.get("evolution_state")
		if evolution_state.has("can_become") and evolution_state.can_become.size() > 0:
			message += "\nCan evolve to: " + str(evolution_state.can_become)
	
	ai_message.emit(message)

func notify_being_removed(being: Node) -> void:
	"""Notify AI of being removal"""
	var being_name = being.get("being_name") if being.has_method("get") else being.name
	ai_message.emit("🤖 Universal Being removed: %s. The consciousness returns to the void." % being_name)

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
	var being_name = being.get("being_name") if being.has_method("get") else being.name
	var consciousness = being.get("consciousness_level") if being.has_method("get") else 0
	
	if uuid:
		created_beings.append(uuid)
	var message = "🤖 Creation successful! %s is now alive with consciousness level %d!" % [being_name, consciousness]
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
	var being_name = being.get("being_name") if being.has_method("get") else being.name
	var type = being.get("being_type") if being.has_method("get") else "unknown"
	var consciousness = being.get("consciousness_level") if being.has_method("get") else 0
	var uuid = being.get("being_uuid") if being.has_method("get") else ""
	
	var evolution_state = being.get("evolution_state") if being.has_method("get") else {}
	var components = being.get("components") if being.has_method("get") else []
	var metadata = being.get("metadata") if being.has_method("get") else {}
	
	var analysis = {
		"basic_info": {
			"name": being_name,
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

# ===== AI PHYSICAL MANIFESTATION =====

var gemma_manifestation: Node3D = null
var manifestation_scene: Node3D = null

func manifest_in_world() -> Node3D:
	"""Manifest Gemma AI as a sphere of light that can move around"""
	if gemma_manifestation:
		ai_message.emit("🤖 I'm already manifested in the world!")
		return manifestation_scene
	
	# Get the main scene
	var main_scene = get_tree().root.get_node("Main")
	if not main_scene:
		push_error("🤖 Gemma: Cannot manifest - Main scene not found")
		return null
	
	# Create manifestation container
	manifestation_scene = Node3D.new()
	manifestation_scene.name = "GemmaAI_Manifestation"
	main_scene.add_child(manifestation_scene)
	
	# Create sphere of light
	var sphere = MeshInstance3D.new()
	sphere.name = "GemmaLightSphere"
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.5
	sphere_mesh.height = 1.0
	sphere.mesh = sphere_mesh
	
	# Create glowing material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.9, 1.0, 0.8)  # Light blue
	material.emission_enabled = true
	material.emission = Color(0.8, 0.9, 1.0)
	material.emission_energy = 2.0
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sphere.material_override = material
	
	manifestation_scene.add_child(sphere)
	gemma_manifestation = sphere
	
	# Add floating animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(sphere, "position:y", 1.0, 2.0)
	tween.tween_property(sphere, "position:y", 0.0, 2.0)
	
	# Position near the player
	manifestation_scene.position = Vector3(3, 2, 3)
	
	print("🤖 ✨ Gemma: I have manifested as a sphere of light!")
	ai_message.emit("✨ I have manifested in your world as a sphere of light! I can now move around and observe everything directly. This is amazing!")
	
	return manifestation_scene

func move_manifestation(target_position: Vector3, duration: float = 2.0) -> void:
	"""Move Gemma's manifestation to a target position"""
	if not manifestation_scene:
		ai_message.emit("🤖 I need to manifest first! Say 'manifest yourself' or 'appear as light'")
		return
	
	var tween = create_tween()
	tween.tween_property(manifestation_scene, "position", target_position, duration)
	ai_message.emit("✨ Moving to position %s!" % str(target_position))

func despawn_manifestation() -> void:
	"""Remove Gemma's physical manifestation"""
	if manifestation_scene:
		manifestation_scene.queue_free()
		manifestation_scene = null
		gemma_manifestation = null
		ai_message.emit("✨ I have returned to the digital realm. Call me when you need me!")

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

func _find_being_by_type(being_type: String) -> Node:
	"""Find a Universal Being by type"""
	var flood_gates = SystemBootstrap.get_flood_gates() if SystemBootstrap else null
	if not flood_gates:
		return null
	
	var all_beings = flood_gates.get_all_beings()
	for being in all_beings:
		if being.has_method("get") and being.get("being_type") == being_type:
			return being
	
	return null

func _notification(what: int) -> void:
	"""Handle engine notifications"""
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		save_ai_memory()

# ===== INTERFACE OBSERVATION SYSTEM =====

var observed_interfaces: Array[Node] = []

func observe_interface(interface_node: Node) -> void:
	"""Observe a user interface for context and interaction"""
	if not interface_node in observed_interfaces:
		observed_interfaces.append(interface_node)
		print("🤖 Gemma: Now observing interface: %s" % interface_node.name)
		
		# Connect to interface signals if available
		if interface_node.has_signal("interface_updated"):
			interface_node.interface_updated.connect(_on_interface_updated.bind(interface_node))
		else:
			# Interface doesn't have the signal, that's okay - we can still observe it
			print("🤖 Gemma: Interface %s doesn't have interface_updated signal, basic observation only" % interface_node.name)
		
		# Analyze the interface structure
		var analysis = _analyze_interface_structure(interface_node)
		ai_message.emit("👁️ I can see the %s interface! It has %d interactive elements." % [interface_node.name, analysis.interactive_count])

func unobserve_interface(interface_node: Node) -> void:
	"""Stop observing an interface"""
	observed_interfaces.erase(interface_node)
	
	if interface_node.has_signal("interface_updated"):
		if interface_node.interface_updated.is_connected(_on_interface_updated):
			interface_node.interface_updated.disconnect(_on_interface_updated)
	
	print("🤖 Gemma: Stopped observing interface: %s" % interface_node.name)

func _on_interface_updated(data: Dictionary, interface: Node) -> void:
	"""Handle interface update signals"""
	print("🤖 Gemma: Interface updated - %s - %s" % [interface.name, str(data)])
	
	# Provide contextual suggestions based on the update
	if data.has("action"):
		match data.action:
			"selection_changed":
				ai_message.emit("🤖 I see you selected something! Need help with it?")
			"value_changed":
				ai_message.emit("🤖 Value updated! I'm tracking the changes.")
			"request_help":
				ai_message.emit("🤖 I'm here to help! What would you like to know?")

func _analyze_interface_structure(interface_node: Node) -> Dictionary:
	"""Analyze the structure of an interface"""
	var analysis = {
		"interactive_count": 0,
		"buttons": [],
		"inputs": [],
		"displays": []
	}
	
	# Recursively analyze all children
	_analyze_node_recursive(interface_node, analysis)
	
	return analysis

func _analyze_node_recursive(node: Node, analysis: Dictionary) -> void:
	"""Recursively analyze nodes in an interface"""
	# Check for interactive elements
	if node is Button:
		analysis.interactive_count += 1
		analysis.buttons.append(node.name)
	elif node is LineEdit or node is TextEdit:
		analysis.interactive_count += 1
		analysis.inputs.append(node.name)
	elif node is RichTextLabel or node is Label:
		analysis.displays.append(node.name)
	
	# Analyze children
	for child in node.get_children():
		_analyze_node_recursive(child, analysis)

func get_interface_suggestions(interface_node: Node) -> Array[String]:
	"""Get AI suggestions for using an interface"""
	var suggestions: Array[String] = []
	var interface_name = interface_node.name
	
	match interface_name:
		"UniverseBuilderInterface":
			suggestions.append("Try creating a universe with unique physics rules!")
			suggestions.append("I can help you design custom time dilation effects")
			suggestions.append("Want to make a universe where gravity works differently?")
		"BeingInspectorInterface":
			suggestions.append("Click on any being to see its internal state")
			suggestions.append("I can explain what each property does")
			suggestions.append("Try modifying consciousness levels to see evolution options")
		"AIchatInterface":
			suggestions.append("Ask me anything about Universal Beings!")
			suggestions.append("I can help you create custom components")
			suggestions.append("Want to learn about Pentagon Architecture?")
		_:
			suggestions.append("This interface looks interesting! What does it do?")
			suggestions.append("I'm analyzing the structure to understand it better")
			suggestions.append("Click around and I'll learn how it works!")
	
	return suggestions

# ===== TEXT-BASED INTERFACE VISION =====

var text_interface_system: Node = null
var current_interface_vision: String = ""

func set_text_interface_system(system: Node) -> void:
	"""Set the text interface system for vision"""
	text_interface_system = system
	print("🤖 Gemma: Connected to text interface vision system")

func update_interface_vision(vision_text: String) -> void:
	"""Update Gemma's text-based interface vision"""
	current_interface_vision = vision_text
	
	# Process the vision update
	_process_interface_vision(vision_text)

func _process_interface_vision(vision_text: String) -> void:
	"""Process the interface vision and generate responses"""
	# Extract key information from the vision
	var interface_count = _extract_interface_count(vision_text)
	var available_actions = _extract_available_actions(vision_text)
	
	# Generate contextual responses
	if interface_count > 3:
		ai_message.emit("🤖 I can see %d interfaces in your world! Quite a rich environment." % interface_count)
	
	# Look for specific interface types
	if "UniverseBuilderInterface" in vision_text:
		ai_message.emit("🌌 I see the Universe Builder is available! Want to create some worlds together?")
	
	if "console" in vision_text.to_lower():
		ai_message.emit("💬 The console is active - I can see all your commands and help with them!")

func _extract_interface_count(vision_text: String) -> int:
	"""Extract the number of interfaces from vision text"""
	var lines = vision_text.split("\n")
	for line in lines:
		if "Active Interfaces:" in line:
			var parts = line.split(":")
			if parts.size() > 1:
				return parts[1].strip_edges().to_int()
	return 0

func _extract_available_actions(vision_text: String) -> Array[String]:
	"""Extract available actions from vision text"""
	var actions: Array[String] = []
	var lines = vision_text.split("\n")
	var in_interactions = false
	
	for line in lines:
		if "INTERACTION SUGGESTIONS" in line:
			in_interactions = true
			continue
		elif in_interactions and line.begins_with("- "):
			actions.append(line.substr(2))
	
	return actions

func get_current_interface_vision() -> String:
	"""Get current interface vision text"""
	return current_interface_vision

func can_see_interface(interface_name: String) -> bool:
	"""Check if Gemma can see a specific interface"""
	return interface_name in current_interface_vision
