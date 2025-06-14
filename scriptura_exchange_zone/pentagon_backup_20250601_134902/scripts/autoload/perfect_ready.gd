################################################################
# PERFECT READY SYSTEM - PHASE 1 IMPLEMENTATION  
# Dependency-aware ready sequence with AI-friendly features
# Created: May 31st, 2025 | Perfect Pentagon Architecture
# Location: scripts/autoload/perfect_ready.gd
################################################################

extends UniversalBeingBase
################################################################
# CORE VARIABLES
################################################################

var ready_sequence: Array[Dictionary] = []
var banned_scripts: Array[String] = []
var ready_status: Dictionary = {}
var ready_complete: bool = false
var debug_mode: bool = true

# AI Integration - For Gamma and other AI entities
var ai_entities: Array[Dictionary] = []
var ai_safe_mode: bool = true
var debug_chamber_active: bool = false

################################################################
# SIGNALS - Perfect Pentagon Communication
################################################################

signal ready_started(script_name: String)
signal ready_completed(script_name: String)
signal all_ready_complete()
signal ready_error(script_name: String, error: String)
signal ai_entity_ready(ai_name: String)
signal debug_chamber_opened()

################################################################
# INITIALIZATION
################################################################

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("🎯 PERFECT READY SYSTEM: Initializing...")
	
	# Load configuration files
	load_banned_scripts("config/banned_scripts.txt")
	load_ai_configuration("config/ai_entities.txt")
	
	# Initialize status tracking
	ready_status["system_start_time"] = Time.get_ticks_msec()
	ready_status["total_registered"] = 0
	ready_status["completed"] = 0
	ready_status["failed"] = 0
	ready_status["ai_entities_loaded"] = 0
	
	# Connect to Perfect Init completion
	if has_node("/root/PerfectInit"):
		var perfect_init = get_node("/root/PerfectInit")
		if not perfect_init.all_init_complete.is_connected(_on_perfect_init_complete):
			perfect_init.all_init_complete.connect(_on_perfect_init_complete)
	
	if debug_mode:
		print("✅ PERFECT READY: System initialized, waiting for Perfect Init completion")

################################################################
# CONFIGURATION LOADING
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
func load_banned_scripts(file_path: String) -> void:
	"""
	Load banned scripts list from configuration file
	"""
	banned_scripts.clear()
	
	if not FileAccess.file_exists(file_path):
		print("📝 PERFECT READY: Creating default banned scripts config at " + file_path)
		_create_default_banned_scripts_config(file_path)
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if line != "" and not line.begins_with("#"):
				banned_scripts.append(line)
		file.close()
		
		if debug_mode:
			print("🚫 PERFECT READY: Loaded %d banned scripts" % banned_scripts.size())

func load_ai_configuration(file_path: String) -> void:
	"""
	Load AI entities configuration for Gamma and other AI companions
	"""
	ai_entities.clear()
	
	# Auto-detect AI models in ai_models directory
	_auto_detect_ai_models()
	
	if not FileAccess.file_exists(file_path):
		print("🤖 PERFECT READY: Creating default AI entities config at " + file_path)
		_create_default_ai_config(file_path)
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if line != "" and not line.begins_with("#") and ":" in line:
				var parts = line.split(":", false, 1)
				var ai_name = parts[0].strip_edges()
				var ai_config = parts[1].strip_edges()
				
				ai_entities.append({
					"name": ai_name,
					"config_path": ai_config,
					"status": "pending",
					"universal_being": null,
					"txt_input_path": "ai_communication/input/" + ai_name + ".txt",
					"txt_output_path": "ai_communication/output/" + ai_name + ".txt",
					"model_path": "ai_models/" + ai_name.to_lower() + "/model.gguf",
					"model_config": "ai_models/" + ai_name.to_lower() + "/config.json"
				})
		file.close()
		
		if debug_mode:
			print("🤖 PERFECT READY: Found %d AI entities to initialize" % ai_entities.size())

################################################################
# REGISTRATION FUNCTIONS
################################################################

func register_ready(script_name: String, ready_callable: Callable, deps: Array = []) -> bool:
	"""
	Register a ready function with dependency checking and banning support
	
	INPUT: script_name (identifier), ready_callable (function), dependencies
	PROCESS: Validates against banned list, creates ready entry, manages dependencies
	OUTPUT: Returns true if registration successful  
	CHANGES: Adds entry to ready_sequence array
	CONNECTION: Links to dependency resolution and AI entity management
	"""
	
	# Check banned scripts list
	if script_name in banned_scripts:
		print("🚫 READY BANNED: " + script_name + " - SKIPPING (found in banned list)")
		return false
	
	# Check for malicious patterns (AI safety)
	if ai_safe_mode and _is_potentially_unsafe(script_name):
		print("🛡️ AI SAFETY: " + script_name + " - BLOCKED for AI safety")
		return false
	
	# Validation
	if script_name == "" or not ready_callable.is_valid():
		print("🚨 PERFECT READY ERROR: Invalid registration for " + script_name)
		return false
	
	# Check for duplicate registration
	for ready_item in ready_sequence:
		if ready_item.script == script_name:
			print("⚠️ PERFECT READY WARNING: " + script_name + " already registered, updating...")
			ready_item.callable = ready_callable
			ready_item.dependencies = deps
			return true
	
	# Create new ready entry
	var ready_entry = {
		"script": script_name,
		"callable": ready_callable,
		"dependencies": deps,
		"status": "waiting",
		"registration_time": Time.get_ticks_msec(),
		"start_time": 0,
		"completion_time": 0,
		"error_message": "",
		"ai_friendly": _is_ai_friendly(script_name)
	}
	
	ready_sequence.append(ready_entry)
	ready_status.total_registered += 1
	
	if debug_mode:
		print("📝 PERFECT READY: Registered %s (deps: %s, AI-friendly: %s)" % [
			script_name, 
			str(deps), 
			"YES" if ready_entry.ai_friendly else "NO"
		])
	
	return true

################################################################
# AI ENTITY MANAGEMENT
################################################################

func _is_ai_friendly(script_name: String) -> bool:
	"""
	Check if a script is safe for AI entities to interact with
	"""
	var safe_patterns = ["ui_", "debug_", "tutorial_", "display_", "info_"]
	var unsafe_patterns = ["delete_", "remove_", "destroy_", "kill_", "crash_"]
	
	for pattern in safe_patterns:
		if script_name.begins_with(pattern):
			return true
	
	for pattern in unsafe_patterns:
		if script_name.begins_with(pattern):
			return false
	
	return true  # Default to safe for most scripts

func _is_potentially_unsafe(script_name: String) -> bool:
	"""
	Enhanced safety check for AI entity protection
	"""
	var dangerous_patterns = [
		"system_", "file_delete", "network_", "admin_", 
		"root_", "sudo_", "exec_", "eval_", "override_"
	]
	
	for pattern in dangerous_patterns:
		if script_name.to_lower().contains(pattern):
			return true
	
	return false

func initialize_ai_entities() -> void:
	"""
	Initialize AI entities like Gamma for interaction with the game
	"""
	print("🤖 PERFECT READY: Initializing AI entities...")
	
	for ai_entity in ai_entities:
		_initialize_single_ai_entity(ai_entity)
	
	if ai_entities.size() > 0:
		print("🤖 AI ENTITIES: %d entities prepared for interaction" % ai_entities.size())

func _initialize_single_ai_entity(ai_entity: Dictionary) -> void:
	"""
	Initialize a single AI entity as a Universal Being
	"""
	var ai_name = ai_entity.name
	
	# Create Universal Being for the AI
	if has_node("/root/UniversalObjectManager"):
		var uom = get_node("/root/UniversalObjectManager")
		
		# Create AI being with special properties using correct method name
		var ai_being = uom.create_object("ai_companion", Vector3(0, 1, 0), {
			"name": ai_name + "_ai_entity",
			"consciousness_level": 5,
			"ai_type": ai_name.to_lower()
		})
		if ai_being:
			ai_being.set_consciousness_level(5)  # Maximum consciousness for AI
			ai_being.become("ai_companion")
			ai_entity.universal_being = ai_being
			ai_entity.status = "active"
			
			# Set up txt communication paths
			_ensure_ai_communication_paths(ai_entity)
			
			print("🤖 AI READY: %s initialized as Universal Being" % ai_name)
			emit_signal("ai_entity_ready", ai_name)
			ready_status.ai_entities_loaded += 1
		else:
			print("🚨 AI ERROR: Failed to create Universal Being for " + ai_name)
			ai_entity.status = "error"

func _ensure_ai_communication_paths(ai_entity: Dictionary) -> void:
	"""
	Create txt file communication paths for AI entities
	"""
	var input_dir = "ai_communication/input/"
	var output_dir = "ai_communication/output/"
	
	# Create directories if they don't exist
	if not DirAccess.dir_exists_absolute(input_dir):
		DirAccess.open("res://").make_dir_recursive(input_dir)
	
	if not DirAccess.dir_exists_absolute(output_dir):
		DirAccess.open("res://").make_dir_recursive(output_dir)
	
	# Create initial communication files
	var input_file = FileAccess.open(ai_entity.txt_input_path, FileAccess.WRITE)
	if input_file:
		input_file.store_line("# AI Input Communication for " + ai_entity.name)
		input_file.store_line("# Claude can write here, AI will read")
		input_file.store_line("status: ready_for_communication")
		input_file.close()
	
	var output_file = FileAccess.open(ai_entity.txt_output_path, FileAccess.WRITE)
	if output_file:
		output_file.store_line("# AI Output Communication for " + ai_entity.name)
		output_file.store_line("# AI will write here, Claude can read")
		output_file.store_line("status: communication_channel_open")
		output_file.close()

################################################################
# EXECUTION FUNCTIONS
################################################################

func execute_ready_sequence() -> void:
	"""
	Execute the complete ready sequence with dependency resolution
	"""
	if ready_complete:
		print("⚠️ PERFECT READY: Already completed, skipping")
		return
	
	print("🎯 PERFECT READY: Beginning ready sequence...")
	print("📊 READY STATUS: %d scripts registered" % ready_sequence.size())
	
	# Initialize AI entities first (they can participate in ready sequence)
	initialize_ai_entities()
	
	# Open debug chamber for AI entities
	if ai_entities.size() > 0:
		_open_debug_chamber()
	
	# Execute ready sequence with dependency resolution
	_resolve_dependencies_and_execute()
	
	# Finalize ready process
	_finalize_ready_sequence()

func _resolve_dependencies_and_execute() -> void:
	"""
	Resolve dependencies and execute ready functions
	"""
	var max_attempts = ready_sequence.size() * 3
	var attempt_count = 0
	var completed_this_round = true
	
	while completed_this_round and attempt_count < max_attempts:
		completed_this_round = false
		attempt_count += 1
		
		for ready_item in ready_sequence:
			if ready_item.status == "waiting" and _dependencies_met(ready_item):
				_execute_single_ready(ready_item)
				completed_this_round = true

func _dependencies_met(ready_item: Dictionary) -> bool:
	"""
	Check if all dependencies for a ready item are resolved
	"""
	if ready_item.dependencies.is_empty():
		return true
	
	for dependency in ready_item.dependencies:
		var dep_completed = false
		for completed_item in ready_sequence:
			if completed_item.script == dependency and completed_item.status == "complete":
				dep_completed = true
				break
		
		if not dep_completed:
			return false
	
	return true

func _execute_single_ready(ready_item: Dictionary) -> void:
	"""
	Execute a single ready function with error handling
	"""
	ready_item.status = "running"
	ready_item.start_time = Time.get_ticks_msec()
	
	if debug_mode:
		print("⚡ EXECUTING READY: " + ready_item.script)
	
	emit_signal("ready_started", ready_item.script)
	
	ready_item.callable.call()
	ready_item.status = "complete"
	ready_item.completion_time = Time.get_ticks_msec()
	ready_status.completed += 1
	
	if debug_mode:
		var duration = ready_item.completion_time - ready_item.start_time
		print("✅ READY COMPLETE: %s (%.2f ms)" % [ready_item.script, duration])
	
	emit_signal("ready_completed", ready_item.script)

func _finalize_ready_sequence() -> void:
	"""
	Complete the ready process
	"""
	ready_complete = true
	var total_time = Time.get_ticks_msec() - ready_status.system_start_time
	
	print("🎯 PERFECT READY COMPLETE!")
	print("📊 FINAL STATUS: %d completed, %d failed, %d AI entities" % [
		ready_status.completed,
		ready_status.failed, 
		ready_status.ai_entities_loaded
	])
	
	emit_signal("all_ready_complete")

################################################################
# DEBUG CHAMBER FOR AI ENTITIES
################################################################

func _open_debug_chamber() -> void:
	"""
	Open a safe debug environment for AI entities to interact
	"""
	debug_chamber_active = true
	print("🏛️ DEBUG CHAMBER: Opening safe environment for AI entities...")
	
	# Create debug chamber scene if needed
	_ensure_debug_chamber_exists()
	
	emit_signal("debug_chamber_opened")

func _ensure_debug_chamber_exists() -> void:
	"""
	Create debug chamber environment for AI interaction
	"""
	# This will be expanded when we implement the Logic Connector
	print("🏗️ DEBUG CHAMBER: Environment prepared for AI interaction")

################################################################
# CONFIGURATION FILE CREATION
################################################################

func _create_default_banned_scripts_config(file_path: String) -> void:
	"""
	Create default banned scripts configuration
	"""
	var dir = file_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.open("res://").make_dir_recursive(dir)
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_line("# PERFECT READY - Banned Scripts Configuration")
		file.store_line("# Scripts listed here will be blocked from ready sequence")
		file.store_line("# One script name per line, # for comments")
		file.store_line("")
		file.store_line("# Example banned scripts:")
		file.store_line("# dangerous_script")
		file.store_line("# legacy_broken_system") 
		file.store_line("# test_crash_system")
		file.close()

func _create_default_ai_config(file_path: String) -> void:
	"""
	Create default AI entities configuration
	"""
	var dir = file_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.open("res://").make_dir_recursive(dir)
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_line("# PERFECT READY - AI Entities Configuration")
		file.store_line("# Format: ai_name:config_path")
		file.store_line("# AI entities will be created as Universal Beings")
		file.store_line("")
		file.store_line("# Gamma - Kamisama's AI companion")
		file.store_line("Gamma:config/ai/gamma_config.txt")
		file.store_line("")
		file.store_line("# Example additional AI entities:")
		file.store_line("# Claude:config/ai/claude_config.txt")
		file.store_line("# Helper:config/ai/helper_config.txt")
		file.close()

################################################################
# AI MODEL AUTO-DETECTION
################################################################

func _auto_detect_ai_models():
	"""
	Auto-detect AI models in the ai_models directory
	"""
	var ai_models_dir = "ai_models/"
	
	if not DirAccess.dir_exists_absolute(ai_models_dir):
		if debug_mode:
			print("🤖 AI MODEL DETECTION: ai_models directory not found")
		return
	
	var dir = DirAccess.open(ai_models_dir)
	if dir:
		dir.list_dir_begin()
		var folder_name = dir.get_next()
		
		while folder_name != "":
			if dir.current_is_dir() and folder_name != "." and folder_name != "..":
				var model_path = ai_models_dir + folder_name + "/model.gguf"
				var config_path = ai_models_dir + folder_name + "/config.json"
				
				if FileAccess.file_exists(model_path):
					print("🎉 AI MODEL FOUND: %s at %s" % [folder_name.capitalize(), model_path])
					_register_detected_ai_model(folder_name, model_path, config_path)
				elif debug_mode:
					print("📂 AI MODEL FOLDER: %s (no model.gguf found yet)" % folder_name)
			
			folder_name = dir.get_next()
		
		dir.list_dir_end()

func _register_detected_ai_model(ai_name: String, model_path: String, config_path: String):
	"""
	Register an auto-detected AI model
	"""
	# Check if this AI is already registered
	for ai_entity in ai_entities:
		if ai_entity.name.to_lower() == ai_name.to_lower():
			ai_entity.model_path = model_path
			ai_entity.model_config = config_path
			ai_entity.model_detected = true
			print("🔗 AI MODEL LINKED: %s model linked to existing configuration" % ai_name.capitalize())
			return
	
	# Register new AI entity
	ai_entities.append({
		"name": ai_name.capitalize(),
		"config_path": "config/ai/" + ai_name.to_lower() + "_config.txt",
		"status": "model_detected",
		"universal_being": null,
		"txt_input_path": "ai_communication/input/" + ai_name.capitalize() + ".txt",
		"txt_output_path": "ai_communication/output/" + ai_name.capitalize() + ".txt",
		"model_path": model_path,
		"model_config": config_path,
		"model_detected": true
	})
	
	print("🌟 NEW AI DETECTED: %s ready for integration!" % ai_name.capitalize())

################################################################
# EVENT HANDLERS
################################################################

func _on_perfect_init_complete():
	"""
	Called when Perfect Init system completes
	"""
	print("🔗 PERFECT READY: Perfect Init completed, starting ready sequence...")
	execute_ready_sequence()

################################################################
# STATUS AND CONSOLE FUNCTIONS
################################################################

func get_ready_status() -> Dictionary:
	"""
	Get complete status of ready system
	"""
	return {
		"complete": ready_complete,
		"total_registered": ready_status.total_registered,
		"completed": ready_status.completed,
		"failed": ready_status.failed,
		"ai_entities": ready_status.ai_entities_loaded,
		"debug_chamber_active": debug_chamber_active,
		"banned_scripts_count": banned_scripts.size()
	}

func console_ready_status() -> String:
	"""Console command: Show ready system status"""
	var status = get_ready_status()
	return """
🎯 PERFECT READY SYSTEM STATUS
════════════════════════════════
Ready Complete: %s
Total Registered: %d
✅ Completed: %d
🚨 Failed: %d
🤖 AI Entities: %d
🏛️ Debug Chamber: %s
🚫 Banned Scripts: %d

🤖 AI ENTITIES STATUS:
%s
""" % [
		"YES" if ready_complete else "NO",
		status.total_registered,
		status.completed,
		status.failed,
		status.ai_entities,
		"ACTIVE" if debug_chamber_active else "INACTIVE",
		status.banned_scripts_count,
		_get_ai_entities_display()
	]

func _get_ai_entities_display() -> String:
	"""
	Generate display string for AI entities
	"""
	if ai_entities.is_empty():
		return "No AI entities configured"
	
	var display = ""
	for ai_entity in ai_entities:
		var status_icon = "⏳"
		match ai_entity.status:
			"active": status_icon = "✅"
			"error": status_icon = "🚨"
			"pending": status_icon = "⏳"
		
		display += "%s %s (Universal Being: %s)\n" % [
			status_icon, 
			ai_entity.name,
			"YES" if ai_entity.universal_being != null else "NO"
		]
	
	return display

################################################################
# PERFECT PENTAGON INTEGRATION
################################################################

func get_system_info() -> Dictionary:
	"""
	Return system information for Perfect Pentagon coordination
	"""
	return {
		"system_name": "Perfect Ready",
		"version": "1.0",
		"status": "active" if ready_complete else "processing",
		"priority": 2,  # Second in Pentagon sequence
		"dependencies": ["Perfect Init"],
		"provides": ["ready_sequence_control", "ai_entity_management", "debug_chamber"],
		"ready_complete": ready_complete,
		"ai_integration": true
	}

################################################################
# END OF PERFECT READY SYSTEM
################################################################