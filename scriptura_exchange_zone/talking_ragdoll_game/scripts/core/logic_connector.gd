################################################################
# LOGIC CONNECTOR SYSTEM - PHASE 2 IMPLEMENTATION
# Text-based behavior scripting for Universal Beings and AI entities
# Created: May 31st, 2025 | Perfect Pentagon Architecture
# Location: scripts/core/logic_connector.gd
################################################################

extends UniversalBeingBase
################################################################
# CORE VARIABLES
################################################################

var action_scripts: Dictionary = {}
var being_behaviors: Dictionary = {}
var ai_behavior_scripts: Dictionary = {}
var script_cache: Dictionary = {}

# AI Integration - For Gamma and other AI entities
var ai_entities_connected: Array[String] = []
var ai_script_monitoring: bool = true
var ai_collaborative_mode: bool = true

# System status
var debug_mode: bool = true
var system_ready: bool = false
var total_scripts_loaded: int = 0
var total_actions_executed: int = 0

################################################################
# SIGNALS - Perfect Pentagon Communication
################################################################

signal action_script_loaded(file_path: String, actions_count: int)
signal being_connected(being_name: String, script_file: String)
signal action_executed(being_name: String, action: String, result: String)
signal ai_script_created(ai_name: String, script_path: String)
signal script_error(file_path: String, error_message: String)

################################################################
# INITIALIZATION
################################################################

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("🔗 LOGIC CONNECTOR SYSTEM: Initializing txt-based behavior engine...")
	
	# Create action scripts directory if it doesn't exist
	_ensure_action_directories()
	
	# Load existing action scripts
	_load_all_action_scripts()
	
	# Set up AI integration
	_setup_ai_integration()
	
	# Connect to other Perfect Pentagon systems
	_connect_to_pentagon_systems()
	
	system_ready = true
	
	if debug_mode:
		print("✅ LOGIC CONNECTOR: System ready - %d scripts loaded, AI collaboration enabled" % total_scripts_loaded)

################################################################
# DIRECTORY SETUP
################################################################

func _ensure_action_directories():
	"""
	Create necessary directories for action scripts
	"""
	var directories = [
		"actions/",
		"actions/beings/",
		"actions/ai/",
		"actions/shared/",
		"actions/debug/"
	]
	
	for dir in directories:
		if not DirAccess.dir_exists_absolute(dir):
			DirAccess.open("res://").make_dir_recursive(dir)
	
	print("📁 LOGIC CONNECTOR: Action directories ensured")

################################################################
# SCRIPT LOADING AND PARSING
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
func load_action_script(file_path: String) -> Dictionary:
	"""
	Load and parse an action script from txt file
	
	INPUT: file_path (path to txt file containing actions)
	PROCESS: Reads file, parses trigger:action pairs, validates syntax
	OUTPUT: Dictionary of trigger -> action mappings
	CHANGES: Updates action_scripts cache
	CONNECTION: Links triggers to Universal Being behaviors and AI responses
	"""
	
	var actions = {}
	
	if not FileAccess.file_exists(file_path):
		if debug_mode:
			print("⚠️ LOGIC CONNECTOR: Script file not found: " + file_path)
		return actions
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("🚨 LOGIC CONNECTOR ERROR: Cannot open file: " + file_path)
		return actions
	
	var line_number = 0
	while not file.eof_reached():
		line_number += 1
		var line = file.get_line().strip_edges()
		
		# Skip empty lines and comments
		if line == "" or line.begins_with("#"):
			continue
		
		# Parse trigger:action format
		if ":" in line:
			var parts = line.split(":", false, 1)
			if parts.size() == 2:
				var trigger = parts[0].strip_edges()
				var action = parts[1].strip_edges()
				
				# Validate trigger and action
				if _validate_trigger_action(trigger, action, file_path, line_number):
					actions[trigger] = action
			else:
				print("⚠️ LOGIC CONNECTOR: Invalid format at %s:%d - %s" % [file_path, line_number, line])
	
	file.close()
	
	# Cache the loaded script
	script_cache[file_path] = {
		"actions": actions,
		"load_time": Time.get_ticks_msec(),
		"line_count": line_number
	}
	
	total_scripts_loaded += 1
	
	if debug_mode:
		print("📝 LOGIC CONNECTOR: Loaded %d actions from %s" % [actions.size(), file_path])
	
	emit_signal("action_script_loaded", file_path, actions.size())
	return actions

func _validate_trigger_action(trigger: String, action: String, file_path: String, line_number: int) -> bool:
	"""
	Validate trigger and action syntax for safety
	"""
	# Check for dangerous actions (AI safety)
	var dangerous_actions = [
		"delete_", "remove_", "destroy_", "kill_", "crash_", 
		"system_", "sudo_", "exec_", "eval_", "override_"
	]
	
	for dangerous in dangerous_actions:
		if action.to_lower().contains(dangerous):
			print("🛡️ LOGIC CONNECTOR SAFETY: Blocked dangerous action at %s:%d - %s" % [file_path, line_number, action])
			return false
	
	# Validate trigger format
	if trigger.length() < 2:
		print("⚠️ LOGIC CONNECTOR: Trigger too short at %s:%d - %s" % [file_path, line_number, trigger])
		return false
	
	return true

func _load_all_action_scripts():
	"""
	Load all action scripts from the actions directory
	"""
	var actions_dir = "actions/"
	var dir = DirAccess.open(actions_dir)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".txt"):
				var full_path = actions_dir + file_name
				var actions = load_action_script(full_path)
				action_scripts[file_name] = actions
			
			file_name = dir.get_next()
		
		dir.list_dir_end()

################################################################
# BEING CONNECTION SYSTEM
################################################################

func connect_being_actions(being: Node, action_file: String) -> bool:
	"""
	Connect a Universal Being to a behavior script file
	
	INPUT: being (Universal Being node), action_file (txt script filename)
	PROCESS: Loads action script, connects triggers to being, sets up event handlers
	OUTPUT: Returns success status
	CHANGES: Updates being_behaviors registry, wires up triggers
	CONNECTION: Links being to txt-based behaviors and AI collaborative actions
	"""
	
	if not being:
		print("🚨 LOGIC CONNECTOR ERROR: Invalid being provided")
		return false
	
	var actions = load_action_script("actions/" + action_file)
	if actions.is_empty():
		print("⚠️ LOGIC CONNECTOR: No actions found in " + action_file)
		return false
	
	# Store behavior mapping
	var being_id = _get_being_id(being)
	being_behaviors[being_id] = {
		"being": being,
		"actions": actions,
		"script_file": action_file,
		"connected_time": Time.get_ticks_msec(),
		"actions_executed": 0
	}
	
	# Wire up the connections
	for trigger in actions:
		_wire_trigger_to_being(being, trigger, actions[trigger])
	
	# Add being to universal_beings group for easy access
	if not being.is_in_group("universal_beings"):
		being.add_to_group("universal_beings")
	
	print("🔗 LOGIC CONNECTOR: %s connected to %s (%d actions)" % [being.name, action_file, actions.size()])
	emit_signal("being_connected", being.name, action_file)
	
	return true

func _get_being_id(being: Node) -> String:
	"""
	Get unique identifier for a Universal Being
	"""
	if being.has_method("get_uuid"):
		return being.get_uuid()
	else:
		return str(being.get_instance_id())

func _wire_trigger_to_being(being: Node, trigger: String, action: String):
	"""
	Wire a specific trigger to a being's behavior
	"""
	# This creates the connection between triggers and the being
	# The actual triggering happens in trigger_action()
	
	if debug_mode:
		print("🔌 LOGIC CONNECTOR: Wired '%s' -> '%s' for %s" % [trigger, action, being.name])

################################################################
# ACTION EXECUTION ENGINE
################################################################

func trigger_action(being: Node, trigger: String) -> bool:
	"""
	Trigger an action on a Universal Being based on a trigger
	
	INPUT: being (Universal Being), trigger (action trigger string)
	PROCESS: Looks up trigger in being's behavior script, executes corresponding action
	OUTPUT: Returns true if action was executed
	CHANGES: Executes action, updates statistics, notifies AI entities
	CONNECTION: Links user interactions to being behaviors and AI observations
	"""
	
	if not being:
		return false
	
	var being_id = _get_being_id(being)
	
	if not being_id in being_behaviors:
		if debug_mode:
			print("⚠️ LOGIC CONNECTOR: No behaviors registered for " + being.name)
		return false
	
	var behavior_data = being_behaviors[being_id]
	var actions = behavior_data.actions
	
	if not trigger in actions:
		if debug_mode:
			print("⚠️ LOGIC CONNECTOR: Trigger '%s' not found for %s" % [trigger, being.name])
		return false
	
	var action = actions[trigger]
	var result = _execute_action(being, action, trigger)
	
	# Update statistics
	behavior_data.actions_executed += 1
	total_actions_executed += 1
	
	# Notify AI entities about the action
	_notify_ai_entities_of_action(being, trigger, action, result)
	
	emit_signal("action_executed", being.name, action, result)
	
	return result == "success"

func _execute_action(being: Node, action: String, trigger: String) -> String:
	"""
	Execute a specific action on a Universal Being
	"""
	if debug_mode:
		print("⚡ ACTION EXECUTION: %s executing '%s' (triggered by %s)" % [being.name, action, trigger])
	
	# Parse action and execute
	match action:
		# Transformation actions
		"transform_to_bird":
			return _execute_transformation(being, "bird")
		"transform_to_ragdoll":
			return _execute_transformation(being, "ragdoll")
		"transform_to_orb":
			return _execute_transformation(being, "magical_orb")
		"transform_to_cube":
			return _execute_transformation(being, "cube")
		
		# Movement actions
		"move_up":
			return _execute_movement(being, Vector3(0, 1, 0))
		"move_down":
			return _execute_movement(being, Vector3(0, -1, 0))
		"move_forward":
			return _execute_movement(being, Vector3(0, 0, -1))
		"move_backward":
			return _execute_movement(being, Vector3(0, 0, 1))
		"jump":
			return _execute_movement(being, Vector3(0, 5, 0))
		
		# Sound actions
		"play_sound_chirp":
			return _execute_sound(being, "chirp")
		"play_sound_beep":
			return _execute_sound(being, "beep")
		"play_sound_chime":
			return _execute_sound(being, "chime")
		
		# Behavior actions
		"seek_food":
			return _execute_behavior(being, "find_food")
		"dance":
			return _execute_animation(being, "dance")
		"spin":
			return _execute_animation(being, "spin")
		"bounce":
			return _execute_animation(being, "bounce")
		
		# AI-specific actions
		"ask_ai_for_help":
			return _execute_ai_request(being, "help_request")
		"share_with_gamma":
			return _execute_ai_communication(being, "Gamma", "data_share")
		
		# Debug actions
		"print_status":
			return _execute_debug_print(being)
		"glow":
			return _execute_visual_effect(being, "glow")
		
		_:
			print("🚨 LOGIC CONNECTOR: Unknown action '%s' for %s" % [action, being.name])
			return "unknown_action"

################################################################
# ACTION EXECUTION HELPERS
################################################################

func _execute_transformation(being: Node, new_form: String) -> String:
	"""Execute transformation action"""
	if being.has_method("become"):
		being.become(new_form)
		return "success"
	else:
		print("⚠️ TRANSFORMATION: %s cannot transform (no become method)" % being.name)
		return "method_not_available"

func _execute_movement(being: Node, direction: Vector3) -> String:
	"""Execute movement action"""
	if being.has_method("move"):
		being.move(direction)
		return "success"
	elif being is Node3D:
		being.global_position += direction
		return "success"
	else:
		return "movement_not_supported"

func _execute_sound(being: Node, sound_name: String) -> String:
	"""Execute sound action"""
	if has_node("/root/AudioManager"):
		var audio_manager = get_node("/root/AudioManager")
		if audio_manager.has_method("play_sound"):
			audio_manager.play_sound(sound_name)
			return "success"
	
	print("♪ SOUND: %s plays %s (audio system not available)" % [being.name, sound_name])
	return "audio_unavailable"

func _execute_behavior(being: Node, behavior: String) -> String:
	"""Execute behavior action"""
	if being.has_method("set_goal"):
		being.set_goal(behavior)
		return "success"
	else:
		print("🧠 BEHAVIOR: %s begins %s" % [being.name, behavior])
		return "behavior_simulated"

func _execute_animation(being: Node, animation: String) -> String:
	"""Execute animation action"""
	if being.has_method("start_animation"):
		being.start_animation(animation)
		return "success"
	else:
		print("💃 ANIMATION: %s performs %s" % [being.name, animation])
		return "animation_simulated"

func _execute_debug_print(being: Node) -> String:
	"""Execute debug print action"""
	var status = "Being: %s, Form: %s, Position: %s" % [
		being.name,
		being.get("form") if being.has_method("get") else "unknown",
		being.global_position if being is Node3D else "no_position"
	]
	print("📊 DEBUG STATUS: " + status)
	return "success"

func _execute_visual_effect(being: Node, effect: String) -> String:
	"""Execute visual effect action"""
	if has_node("/root/UniversalShaderEffects"):
		var shader_effects = get_node("/root/UniversalShaderEffects")
		if shader_effects.has_method("apply_shader_to_being"):
			shader_effects.apply_shader_to_being(being, effect)
			return "success"
	
	print("✨ VISUAL EFFECT: %s glows with %s effect" % [being.name, effect])
	return "effect_simulated"

################################################################
# AI INTEGRATION
################################################################

func _setup_ai_integration():
	"""
	Set up AI entity integration for collaborative scripting
	"""
	if has_node("/root/PerfectReady"):
		var perfect_ready = get_node("/root/PerfectReady")
		if perfect_ready.has_signal("ai_entity_ready"):
			perfect_ready.ai_entity_ready.connect(_on_ai_entity_ready)

func _on_ai_entity_ready(ai_name: String):
	"""
	Called when an AI entity (like Gamma) becomes ready
	"""
	ai_entities_connected.append(ai_name)
	
	# Create collaborative script file for the AI
	_create_ai_collaborative_script(ai_name)
	
	print("🤖 LOGIC CONNECTOR: AI entity %s connected for collaborative scripting" % ai_name)

func _create_ai_collaborative_script(ai_name: String):
	"""
	Create a collaborative script file that AI entities can read and modify
	"""
	var script_path = "actions/ai/" + ai_name + "_collaborative.txt"
	var file = FileAccess.open(script_path, FileAccess.WRITE)
	
	if file:
		file.store_line("# COLLABORATIVE SCRIPT FOR " + ai_name.to_upper())
		file.store_line("# This file can be read and modified by both Claude and " + ai_name)
		file.store_line("# Format: trigger:action")
		file.store_line("")
		file.store_line("# AI Learning Actions:")
		file.store_line("on_curious: ask_ai_for_help")
		file.store_line("on_confused: print_status")
		file.store_line("on_excited: glow")
		file.store_line("on_happy: dance")
		file.store_line("")
		file.store_line("# Collaborative Actions:")
		file.store_line("when_claude_writes: share_with_gamma")
		file.store_line("when_learning: transform_to_orb")
		file.store_line("when_understanding: play_sound_chime")
		file.store_line("")
		file.store_line("# " + ai_name + " can add new actions below this line:")
		file.store_line("# (Write your own trigger:action pairs here)")
		file.close()
		
		ai_behavior_scripts[ai_name] = script_path
		
		emit_signal("ai_script_created", ai_name, script_path)
		print("📝 AI SCRIPT: Created collaborative script for %s at %s" % [ai_name, script_path])

func _notify_ai_entities_of_action(being: Node, trigger: String, action: String, result: String):
	"""
	Notify AI entities about action execution for learning
	"""
	if not ai_collaborative_mode or ai_entities_connected.is_empty():
		return
	
	for ai_name in ai_entities_connected:
		_write_ai_action_log(ai_name, being, trigger, action, result)

func _write_ai_action_log(ai_name: String, being: Node, trigger: String, action: String, result: String):
	"""
	Write action execution to AI entity's learning log
	"""
	var log_path = "ai_communication/input/" + ai_name + "_action_log.txt"
	var file = FileAccess.open(log_path, FileAccess.WRITE_READ)
	
	if file:
		file.seek_end()
		var log_entry = "action_observed: being=%s trigger=%s action=%s result=%s timestamp=%d" % [
			being.name, trigger, action, result, Time.get_ticks_msec()
		]
		file.store_line(log_entry)
		file.close()

func _execute_ai_request(being: Node, request_type: String) -> String:
	"""
	Execute AI-specific request action
	"""
	if ai_entities_connected.is_empty():
		return "no_ai_available"
	
	# Send request to first available AI entity
	var ai_name = ai_entities_connected[0]
	var request_path = "ai_communication/input/" + ai_name + "_requests.txt"
	var file = FileAccess.open(request_path, FileAccess.WRITE_READ)
	
	if file:
		file.seek_end()
		file.store_line("request: %s from %s at %d" % [request_type, being.name, Time.get_ticks_msec()])
		file.close()
		
		print("🤖 AI REQUEST: %s requested %s from %s" % [being.name, request_type, ai_name])
		return "success"
	
	return "request_failed"

func _execute_ai_communication(being: Node, ai_name: String, communication_type: String) -> String:
	"""
	Execute communication with specific AI entity
	"""
	if not ai_name in ai_entities_connected:
		return "ai_not_available"
	
	var comm_path = "ai_communication/input/" + ai_name + "_communication.txt"
	var file = FileAccess.open(comm_path, FileAccess.WRITE_READ)
	
	if file:
		file.seek_end()
		file.store_line("communication: %s type=%s from=%s timestamp=%d" % [
			communication_type, communication_type, being.name, Time.get_ticks_msec()
		])
		file.close()
		
		return "success"
	
	return "communication_failed"

################################################################
# SYSTEM CONNECTION
################################################################

func _connect_to_pentagon_systems():
	"""
	Connect to other Perfect Pentagon systems
	"""
	# This will be expanded as other systems come online
	print("🔗 LOGIC CONNECTOR: Connected to Perfect Pentagon systems")

################################################################
# UTILITY FUNCTIONS
################################################################

func reload_all_scripts():
	"""
	Reload all action scripts from disk
	"""
	script_cache.clear()
	action_scripts.clear()
	_load_all_action_scripts()
	
	print("🔄 LOGIC CONNECTOR: Reloaded all action scripts")

func get_script_count() -> int:
	"""
	Get total number of loaded scripts
	"""
	return action_scripts.size()

################################################################
# STATUS AND CONSOLE FUNCTIONS
################################################################

func get_logic_status() -> Dictionary:
	"""
	Get complete status of logic connector system
	"""
	return {
		"system_ready": system_ready,
		"scripts_loaded": total_scripts_loaded,
		"actions_executed": total_actions_executed,
		"beings_connected": being_behaviors.size(),
		"ai_entities": ai_entities_connected.size(),
		"collaborative_mode": ai_collaborative_mode
	}

func console_logic_status() -> String:
	"""Console command: Show logic connector status"""
	var status = get_logic_status()
	return """
🔗 LOGIC CONNECTOR SYSTEM STATUS
══════════════════════════════════
System Ready: %s
📝 Scripts Loaded: %d
⚡ Actions Executed: %d
🎭 Beings Connected: %d
🤖 AI Entities: %d
🤝 Collaborative Mode: %s

🎭 CONNECTED BEINGS:
%s

🤖 AI ENTITIES:
%s
""" % [
		"YES" if status.system_ready else "NO",
		status.scripts_loaded,
		status.actions_executed,
		status.beings_connected,
		status.ai_entities,
		"ENABLED" if status.collaborative_mode else "DISABLED",
		_get_beings_display(),
		_get_ai_entities_display()
	]

func _get_beings_display() -> String:
	"""Generate display string for connected beings"""
	if being_behaviors.is_empty():
		return "No beings connected"
	
	var display = ""
	for being_id in being_behaviors:
		var behavior_data = being_behaviors[being_id]
		display += "• %s (%s) - %d actions\n" % [
			behavior_data.being.name,
			behavior_data.script_file,
			behavior_data.actions.size()
		]
	
	return display

func _get_ai_entities_display() -> String:
	"""Generate display string for AI entities"""
	if ai_entities_connected.is_empty():
		return "No AI entities connected"
	
	var display = ""
	for ai_name in ai_entities_connected:
		var script_path = ai_behavior_scripts.get(ai_name, "none")
		display += "• %s (script: %s)\n" % [ai_name, script_path]
	
	return display

################################################################
# PERFECT PENTAGON INTEGRATION
################################################################

func get_system_info() -> Dictionary:
	"""
	Return system information for Perfect Pentagon coordination
	"""
	return {
		"system_name": "Logic Connector",
		"version": "1.0", 
		"status": "active" if system_ready else "initializing",
		"priority": 4,  # Fourth in Pentagon sequence
		"dependencies": ["Perfect Init", "Perfect Ready", "Perfect Input"],
		"provides": ["txt_behavior_scripting", "ai_collaboration", "action_execution"],
		"ai_integration": true,
		"collaborative_scripting": ai_collaborative_mode
	}

################################################################
# END OF LOGIC CONNECTOR SYSTEM
################################################################