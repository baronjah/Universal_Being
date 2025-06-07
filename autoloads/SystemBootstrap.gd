# ==================================================
# SCRIPT NAME: SystemBootstrap.gd (Autoload)
# DESCRIPTION: Bootstrap Universal Being System - Load core classes safely
# PURPOSE: Initialize Universal Being ecosystem without circular dependencies
# CREATED: 2025-06-01 - Universal Being Revolution
# AUTHOR: JSH + Claude Code + Luminus + Alpha
# ==================================================

extends Node

# ===== ENHANCED SYSTEM BOOTSTRAP =====

# State machine for robust initialization
enum InitState {
	NOT_STARTED,
	LOADING_CLASSES,
	CREATING_INSTANCES,
	VALIDATING_SYSTEMS,
	READY,
	ERROR
}

var current_state: InitState = InitState.NOT_STARTED
var core_loaded: bool = false
var systems_ready: bool = false
var startup_time: int = 0
var initialization_errors: Array = []
var initialization_log: Array = []
var retry_attempts: Dictionary = {}
var max_retries: int = 3

# Global references
var flood_gates_instance = null
var akashic_records_instance = null
var akashic_library_instance = null

# Core resources
var UniversalBeingClass = null
var FloodGatesClass = null
var AkashicRecordsSystemClass = null
var AkashicLibraryClass = null

signal system_ready()
signal system_error(error: String)

func _ready() -> void:
	name = "SystemBootstrap"
	startup_time = Time.get_ticks_msec()
	_log_with_timestamp("🚀 SystemBootstrap: Initializing Universal Being core...")
	_log_with_timestamp("🚀 SystemBootstrap: Startup time: %d ms" % startup_time)
	
	# Start async initialization
	call_deferred("_start_async_initialization")

# ===== MISSING METHODS IMPLEMENTATION =====

func _log_with_timestamp(message: String) -> void:
	"""Log message with timestamp"""
	var timestamp = Time.get_datetime_string_from_system()
	var log_entry = "[%s] %s" % [timestamp, message]
	initialization_log.append(log_entry)
	print(log_entry)

func _load_core_classes_async() -> bool:
	"""Load all core classes asynchronously with validation"""
	_log_with_timestamp("🔄 Loading core classes...")
	
	# Define class paths with fallbacks
	var class_configs = {
		"UniversalBeing": {
			"paths": ["res://core/UniversalBeing.gd"],
			"required": true
		},
		"FloodGates": {
			"paths": ["res://core/FloodGates.gd", "res://systems/FloodGates.gd"],
			"required": true
		},
		"AkashicRecordsSystem": {
			"paths": ["res://systems/storage/AkashicRecordsSystem.gd", "res://systems/AkashicRecordsSystem.gd"],
			"required": true
		},
		"AkashicLibrary": {
			"paths": ["res://systems/AkashicLibrary.gd"],
			"required": false
		}
	}
	
	# Load each class
	for class_name_key in class_configs.keys():
		var config = class_configs[class_name_key]
		var loaded = false
		_log_with_timestamp("🔄 Loading %s..." % class_name_key)
		
		for path in config.paths:
			if ResourceLoader.exists(path):
				var resource = load(path)
				if resource:
					match class_name_key:
						"UniversalBeing": UniversalBeingClass = resource
						"FloodGates": FloodGatesClass = resource
						"AkashicRecordsSystem": AkashicRecordsSystemClass = resource
						"AkashicLibrary": AkashicLibraryClass = resource
					_log_with_timestamp("✓ Loaded %s from %s" % [class_name_key, path])
					loaded = true
					break
				else:
					_log_with_timestamp("❌ Failed to load resource from %s" % path)
			
			await get_tree().process_frame
		
		if not loaded and config.required:
			var error = "Failed to load required class: " + class_name_key
			initialization_errors.append(error)
			_log_with_timestamp("❌ %s" % error)
			return false
	
	# Validate all core classes loaded
	var core_classes_loaded = UniversalBeingClass and FloodGatesClass and AkashicRecordsSystemClass
	if core_classes_loaded:
		core_loaded = true
		_log_with_timestamp("✓ Core classes loaded successfully!")
		return true
	else:
		_log_with_timestamp("❌ Core class loading failed")
		return false

func _initialize_systems_async() -> bool:
	"""Initialize all core system instances asynchronously"""
	_log_with_timestamp("🔄 Initializing system instances...")
	
	if not core_loaded:
		_log_with_timestamp("❌ Cannot initialize - core not loaded")
		return false
	
	# Create FloodGates instance
	_log_with_timestamp("🔄 Creating FloodGates instance...")
	if not FloodGatesClass:
		var error = "FloodGatesClass not loaded"
		initialization_errors.append(error)
		_log_with_timestamp("❌ %s" % error)
		return false
		
	flood_gates_instance = FloodGatesClass.new()
	flood_gates_instance.name = "FloodGates"
	add_child(flood_gates_instance)
	_log_with_timestamp("✓ FloodGates instance created")
	
	await get_tree().process_frame
	
	   # Create AkashicRecordsSystem instance
	_log_with_timestamp("🔄 Creating AkashicRecordsSystem instance...")
	if not AkashicRecordsSystemClass:
		var error = "AkashicRecordsSystemClass not loaded"
		initialization_errors.append(error)
		_log_with_timestamp("❌ %s" % error)
		return false
		
	akashic_records_instance = AkashicRecordsSystemClass.new()
	akashic_records_instance.name = "AkashicRecordsSystem"
	add_child(akashic_records_instance)
	_log_with_timestamp("✓ AkashicRecordsSystem instance created")
	
	await get_tree().process_frame
	
	# Create AkashicLibrary instance (optional)
	if AkashicLibraryClass:
		_log_with_timestamp("🔄 Creating AkashicLibrary instance...")
		akashic_library_instance = AkashicLibraryClass.new()
		akashic_library_instance.name = "AkashicLibrary"
		akashic_library_instance.add_to_group("akashic_library")
		add_child(akashic_library_instance)
		_log_with_timestamp("✓ AkashicLibrary instance created")
	
	await get_tree().process_frame
	
	_log_with_timestamp("✓ System instances initialized successfully")
	return true

func _validate_systems() -> bool:
	"""Validate all systems are properly initialized and functional"""
	_log_with_timestamp("🔄 Validating systems...")
	
	# Check required instances exist
	var required_systems = {
		"FloodGates": flood_gates_instance,
		"AkashicRecordsSystem": akashic_records_instance
	}
	
	for system_name in required_systems:
		var instance = required_systems[system_name]
		if not instance:
			var error = "Required system missing: " + system_name
			initialization_errors.append(error)
			_log_with_timestamp("❌ %s" % error)
			return false
		
		# Validate Pentagon methods exist
		var required_methods = ["pentagon_init", "pentagon_ready", "pentagon_process", "pentagon_input", "pentagon_sewers"]
		for method in required_methods:
			if not instance.has_method(method):
				var error = "%s missing Pentagon method: %s" % [system_name, method]
				initialization_errors.append(error)
				_log_with_timestamp("⚠️ %s" % error)
		
		_log_with_timestamp("✓ %s validated" % system_name)
	
	_log_with_timestamp("✓ System validation complete")
	return true

func _print_initialization_summary() -> void:
	"""Print comprehensive initialization summary"""
	var boot_time = (Time.get_ticks_msec() - startup_time) / 1000.0
	_log_with_timestamp("📊 INITIALIZATION SUMMARY:")
	_log_with_timestamp("   Boot time: %.2fs" % boot_time)
	_log_with_timestamp("   State: %s" % InitState.keys()[current_state])
	_log_with_timestamp("   Core loaded: %s" % core_loaded)
	_log_with_timestamp("   Systems ready: %s" % systems_ready)
	_log_with_timestamp("   FloodGates: %s" % ("Ready" if flood_gates_instance else "Not Ready"))
	_log_with_timestamp("   AkashicRecordsSystem: %s" % ("Ready" if akashic_records_instance else "Not Ready"))
	_log_with_timestamp("   AkashicLibrary: %s" % ("Ready" if akashic_library_instance else "Not Ready"))
	_log_with_timestamp("   Errors: %d" % initialization_errors.size())
	_log_with_timestamp("✓ Universal Being systems ready!")

func _print_error_summary() -> void:
	"""Print comprehensive error summary"""
	_log_with_timestamp("❌ INITIALIZATION ERRORS:")
	if initialization_errors.size() == 0:
		_log_with_timestamp("   No errors recorded")
	else:
		for i in range(initialization_errors.size()):
			_log_with_timestamp("   %d. %s" % [i+1, initialization_errors[i]])
	_log_with_timestamp("❌ Initialization failed - see errors above")

func _start_async_initialization() -> void:
	"""Start the async initialization process"""
	current_state = InitState.LOADING_CLASSES
	_log_with_timestamp("🚀 SystemBootstrap: Starting enhanced async initialization...")
	
	var success = await _initialize_with_retry()
	if success:
		_log_with_timestamp("🚀 SystemBootstrap: ✓ Initialization complete!")
		_print_initialization_summary()
	else:
		_log_with_timestamp("🚀 SystemBootstrap: ❌ Initialization failed!")
		current_state = InitState.ERROR
		_print_error_summary()

func _initialize_with_retry() -> bool:
	"""Initialize with retry logic"""
	for attempt in range(max_retries):
		_log_with_timestamp("🚀 SystemBootstrap: Initialization attempt %d/%d" % [attempt + 1, max_retries])
		
		if await _attempt_initialization():
			return true
		
		if attempt < max_retries - 1:
			_log_with_timestamp("🚀 SystemBootstrap: Retrying in 0.5 seconds...")
			await get_tree().create_timer(0.5).timeout
	
	return false

func _attempt_initialization() -> bool:
	"""Single initialization attempt"""
	# Load core classes
	current_state = InitState.LOADING_CLASSES
	if not await _load_core_classes_async():
		return false
	
	# Create system instances
	current_state = InitState.CREATING_INSTANCES
	if not await _initialize_systems_async():
		return false
	
	# Validate all systems
	current_state = InitState.VALIDATING_SYSTEMS
	if not _validate_systems():
		return false
	
	current_state = InitState.READY
	systems_ready = true
	system_ready.emit()
	return true

# ===== LEGACY SYNCHRONOUS METHODS (for backward compatibility) =====

func load_core_classes() -> void:
	"""Legacy synchronous method - use _load_core_classes_async() instead"""
	_log_with_timestamp("⚠️ Using legacy load_core_classes() - consider async version")
	var result = await _load_core_classes_async()
	if not result:
		_log_with_timestamp("❌ Legacy load_core_classes() failed")

func initialize_systems() -> void:
	"""Legacy synchronous method - use _initialize_systems_async() instead"""
	_log_with_timestamp("⚠️ Using legacy initialize_systems() - consider async version")
	var result = await _initialize_systems_async()
	if not result:
		_log_with_timestamp("❌ Legacy initialize_systems() failed")

# ===== GLOBAL ACCESS FUNCTIONS =====

func get_flood_gates():
	"""Get FloodGates instance"""
	if not flood_gates_instance:
		push_warning("SystemBootstrap: FloodGates not initialized")
	return flood_gates_instance

func get_akashic_records():

	if not akashic_records_instance:
		push_warning("SystemBootstrap: AkashicRecordsSystem not initialized")
	return akashic_records_instance

func get_akashic_library():
	"""Get AkashicLibrary instance"""
	if not akashic_library_instance:
		push_warning("SystemBootstrap: AkashicLibrary not initialized")
	return akashic_library_instance

func create_universal_being() -> Node:
	"""Create a new Universal Being instance"""
	if UniversalBeingClass:
		return UniversalBeingClass.new()
	return null

func create_console_universal_being() -> Node:
	"""Create a new Console Universal Being instance"""
	var ConsoleUniversalBeingClass = load("res://beings/console/ConsoleUniversalBeing.gd")
	if ConsoleUniversalBeingClass:
		return ConsoleUniversalBeingClass.new()
	return null

func is_system_ready() -> bool:
	"""Check if system is ready"""
	return systems_ready

# ===== SYSTEM DIAGNOSTICS =====

func get_system_status() -> Dictionary:
	"""Get comprehensive system status"""
	return {
		"core_loaded": core_loaded,
		"systems_ready": systems_ready,
		"flood_gates": flood_gates_instance != null,
		"akashic_records": akashic_records_instance != null,
		"akashic_library": akashic_library_instance != null,
		"universal_being_class": UniversalBeingClass != null,
		"uptime": (Time.get_ticks_msec() - startup_time) / 1000.0,
		"errors": initialization_errors
	}

# ===== CONVENIENCE FUNCTIONS =====

func add_being_to_scene(being: Node, parent: Node) -> bool:
	"""Static function to add being to scene through FloodGates"""
	if not being or not parent:
		push_error("SystemBootstrap: Invalid being or parent")
		return false
		
	if flood_gates_instance:
		return flood_gates_instance.add_being_to_scene(being, parent)
	else:
		push_warning("SystemBootstrap: Using fallback add_child - FloodGates not ready")
		parent.add_child(being)
		return true

func load_being_data(path: String) -> Dictionary:

	if akashic_records_instance:
		return akashic_records_instance.load_being_from_zip(path)
		#push_error("SystemBootstrap: AkashicRecordsSystem not available")
	return {}

func get_bootstrap_instance():
	"""Get the bootstrap instance"""
	return self

# ===== ENHANCED DEBUGGING & MONITORING =====

func force_reinitialize() -> bool:
	"""Force complete reinitialization - useful for debugging"""
	_log_with_timestamp("🔄 Force reinitialization requested...")
	
	# Reset state
	current_state = InitState.NOT_STARTED
	core_loaded = false
	systems_ready = false
	initialization_errors.clear()
	
	# Clear instances
	if flood_gates_instance:
		flood_gates_instance.queue_free()
		flood_gates_instance = null
	if akashic_records_instance:
		akashic_records_instance.queue_free()
		akashic_records_instance = null
	if akashic_library_instance:
		akashic_library_instance.queue_free()
		akashic_library_instance = null
	
	# Clear classes
	UniversalBeingClass = null
	FloodGatesClass = null
	AkashicRecordsSystemClass = null
	AkashicLibraryClass = null
	
	# Restart initialization
	await get_tree().process_frame
	var success = await _initialize_with_retry()
	
	_log_with_timestamp("🔄 Force reinitialization %s" % ("succeeded" if success else "failed"))
	return success

func get_initialization_log() -> Array:
	"""Get complete initialization log"""
	return initialization_log.duplicate()

func get_detailed_status() -> Dictionary:
	"""Get detailed system status for debugging"""
	return {
		"timestamp": Time.get_datetime_string_from_system(),
		"state": InitState.keys()[current_state],
		"uptime_ms": Time.get_ticks_msec() - startup_time,
		"core_loaded": core_loaded,
		"systems_ready": systems_ready,
		"instances": {
			"flood_gates": flood_gates_instance != null,
			"akashic_records": akashic_records_instance != null,
			"akashic_library": akashic_library_instance != null
		},
		"classes": {
			"universal_being": UniversalBeingClass != null,
			"flood_gates": FloodGatesClass != null,
			"akashic_records": AkashicRecordsSystemClass != null,
			"akashic_library": AkashicLibraryClass != null
		},
		"errors": initialization_errors.duplicate(),
		"log_entries": initialization_log.size(),
		"retry_attempts": retry_attempts.duplicate()
	}
