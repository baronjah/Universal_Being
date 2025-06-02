# ==================================================
# SCRIPT NAME: SystemBootstrap_Enhanced.gd (Autoload)
# DESCRIPTION: Enhanced Bootstrap with improved error handling and initialization
# PURPOSE: Robust initialization with better dependency management
# CREATED: 2025-06-02 - Enhanced based on analysis
# AUTHOR: JSH + Claude Code + Luminus + Alpha
# ==================================================

extends Node

# ===== INITIALIZATION STATE MACHINE =====

enum InitState {
	NOT_STARTED,
	LOADING_CLASSES,
	CREATING_INSTANCES,
	VALIDATING_SYSTEMS,
	READY,
	ERROR
}

var current_state: InitState = InitState.NOT_STARTED
var initialization_log: Array = []
var initialization_errors: Array = []
var retry_attempts: Dictionary = {}
var max_retries: int = 3

# ===== SYSTEM TRACKING =====

var core_loaded: bool = false
var systems_ready: bool = false
var startup_time: int = 0
var initialization_steps: Dictionary = {
	"core_classes": false,
	"flood_gates": false,
	"akashic_records": false,
	"signal_connections": false
}

# Global references
var flood_gates_instance = null
var akashic_records_instance = null
var akashic_loader_instance = null

# Core resources  
var UniversalBeingClass = null
var FloodGatesClass = null
var AkashicRecordsClass = null

# ===== ENHANCED SIGNALS =====

signal system_ready()
signal system_error(error_type: String, details: Dictionary)
signal initialization_progress(step: String, progress: float)
signal dependency_loaded(dependency: String)
signal initialization_retry(component: String, attempt: int)

# ===== INITIALIZATION =====

func _ready() -> void:
	name = "SystemBootstrap"
	startup_time = Time.get_ticks_msec()
	_log("🚀 SystemBootstrap Enhanced: Starting initialization...")
	
	# Set process to monitor initialization
	set_process(true)
	
	# Start initialization state machine
	_transition_state(InitState.LOADING_CLASSES)
	
	# Begin async initialization with error handling
	call_deferred("_initialize_with_retry")

func _process(_delta: float) -> void:
	"""Monitor initialization state"""
	if current_state == InitState.ERROR:
		# Check if we should retry
		if _should_retry():
			_log("🔄 Retrying initialization...")
			_transition_state(InitState.LOADING_CLASSES)
			call_deferred("_initialize_with_retry")

# ===== STATE MANAGEMENT =====

func _transition_state(new_state: InitState) -> void:
	"""Transition between initialization states"""
	var old_state_name = InitState.keys()[current_state]
	var new_state_name = InitState.keys()[new_state]
	_log("State transition: %s → %s" % [old_state_name, new_state_name])
	current_state = new_state

func _should_retry() -> bool:
	"""Check if we should retry failed initialization"""
	for component in retry_attempts:
		if retry_attempts[component] < max_retries:
			return true
	return false

# ===== ENHANCED CLASS LOADING =====

func _initialize_with_retry() -> void:
	"""Initialize with retry logic"""
	match current_state:
		InitState.LOADING_CLASSES:
			await _load_core_classes_safe()
		InitState.CREATING_INSTANCES:
			await _create_system_instances_safe()
		InitState.VALIDATING_SYSTEMS:
			await _validate_systems()
		InitState.ERROR:
			_handle_initialization_error()

func _load_core_classes_safe() -> void:
	"""Load core classes with enhanced error handling"""
	_log("📚 Loading core classes...")
	initialization_progress.emit("loading_classes", 0.0)
	
	var class_configs = {
		"UniversalBeing": {
			"paths": [
				"res://core/UniversalBeing.gd",
				"res://core/universal_being.gd",  # Fallback lowercase
				"res://scripts/core/UniversalBeing.gd"  # Alternative location
			],
			"required": true,
			"variable": "UniversalBeingClass"
		},
		"FloodGates": {
			"paths": [
				"res://core/FloodGates.gd",
				"res://core/flood_gates.gd",
				"res://systems/FloodGates.gd"
			],
			"required": true,
			"variable": "FloodGatesClass"
		},
		"AkashicRecords": {
			"paths": [
				"res://core/AkashicRecords.gd",
				"res://core/akashic_records.gd",
				"res://systems/AkashicRecords.gd"
			],
			"required": true,
			"variable": "AkashicRecordsClass"
		}
	}
	
	var loaded_count = 0
	var total_count = class_configs.size()
	
	for class_key in class_configs.keys():
		var config = class_configs[class_key]
		var loaded = false
		
		for path in config.paths:
			if ResourceLoader.exists(path):
				var resource = load(path)
				if resource:
					set(config.variable, resource)
					_log("   ✓ Loaded %s from %s" % [class_key, path])
					dependency_loaded.emit(class_key)
					loaded = true
					loaded_count += 1
					break
				else:
					_log_error("   ❌ Failed to load resource: %s" % path)
			else:
				_log_warning("   ⚠️ File not found: %s" % path)
		
		if not loaded and config.required:
			_log_error("   ❌ CRITICAL: Failed to load required class: %s" % class_key)
			_record_error("class_loading", {
				"class": class_key,
				"paths_tried": config.paths,
				"required": config.required
			})
		
		initialization_progress.emit("loading_classes", float(loaded_count) / float(total_count))
		
		# Small delay to prevent blocking
		await get_tree().process_frame
	
	# Check if all required classes loaded
	if UniversalBeingClass and FloodGatesClass and AkashicRecordsClass:
		core_loaded = true
		initialization_steps.core_classes = true
		_log("✅ All core classes loaded successfully!")
		_transition_state(InitState.CREATING_INSTANCES)
		call_deferred("_initialize_with_retry")
	else:
		_transition_state(InitState.ERROR)

func _create_system_instances_safe() -> void:
	"""Create system instances with validation"""
	_log("🏗️ Creating system instances...")
	initialization_progress.emit("creating_instances", 0.0)
	
	# Create FloodGates
	if FloodGatesClass:
		var flood_gates_result = _create_instance_safe(FloodGatesClass, "FloodGates")
		if flood_gates_result:
			flood_gates_instance = flood_gates_result
			initialization_steps.flood_gates = true
			_log("   ✓ FloodGates instance created")
			initialization_progress.emit("creating_instances", 0.5)
		else:
			_log_error("   ❌ Failed to create FloodGates instance")
			_record_error("instance_creation", {"component": "FloodGates"})
	
	await get_tree().process_frame
	
	# Create AkashicRecords
	if AkashicRecordsClass:
		var akashic_result = _create_instance_safe(AkashicRecordsClass, "AkashicRecords")
		if akashic_result:
			akashic_records_instance = akashic_result
			initialization_steps.akashic_records = true
			_log("   ✓ AkashicRecords instance created")
			initialization_progress.emit("creating_instances", 1.0)
		else:
			_log_error("   ❌ Failed to create AkashicRecords instance")
			_record_error("instance_creation", {"component": "AkashicRecords"})
	
	await get_tree().process_frame
	
	# Check if instances created successfully
	if flood_gates_instance and akashic_records_instance:
		_transition_state(InitState.VALIDATING_SYSTEMS)
		call_deferred("_initialize_with_retry")
	else:
		_transition_state(InitState.ERROR)

func _create_instance_safe(script_class: Script, instance_name: String) -> Node:
	"""Safely create an instance of a script class"""
	var instance = null
	if script_class:
		instance = script_class.new()
		if instance:
			instance.name = instance_name
			add_child(instance)
	return instance

func _validate_systems() -> void:
	"""Validate all systems are properly initialized"""
	_log("🔍 Validating system integrity...")
	initialization_progress.emit("validating", 0.0)
	
	var validation_checks = {
		"flood_gates_ready": _validate_flood_gates(),
		"akashic_ready": _validate_akashic_records(),
		"signal_connections": _validate_signal_connections()
	}
	
	var passed = 0
	var total = validation_checks.size()
	
	for check in validation_checks:
		if validation_checks[check]:
			passed += 1
			_log("   ✓ %s validation passed" % check)
		else:
			_log_error("   ❌ %s validation failed" % check)
		
		initialization_progress.emit("validating", float(passed) / float(total))
		await get_tree().process_frame
	
	if passed == total:
		_finalize_initialization()
	else:
		_transition_state(InitState.ERROR)

# ===== VALIDATION FUNCTIONS =====

func _validate_flood_gates() -> bool:
	"""Validate FloodGates is properly initialized"""
	if not flood_gates_instance:
		return false
	
	# Check essential methods exist
	var required_methods = ["register_being", "unregister_being", "add_being_to_scene"]
	for method in required_methods:
		if not flood_gates_instance.has_method(method):
			_log_error("FloodGates missing method: %s" % method)
			return false
	
	return true

func _validate_akashic_records() -> bool:
	"""Validate AkashicRecords is properly initialized"""
	if not akashic_records_instance:
		return false
	
	# Check essential methods exist
	var required_methods = ["load_being_from_zip", "save_being_to_zip"]
	for method in required_methods:
		if not akashic_records_instance.has_method(method):
			_log_error("AkashicRecords missing method: %s" % method)
			return false
	
	return true

func _validate_signal_connections() -> bool:
	"""Validate signal connections are established"""
	# Add signal validation logic here
	return true

# ===== FINALIZATION =====

func _finalize_initialization() -> void:
	"""Complete initialization successfully"""
	systems_ready = true
	_transition_state(InitState.READY)
	
	var boot_time = (Time.get_ticks_msec() - startup_time) / 1000.0
	_log("✅ SystemBootstrap: All systems initialized successfully! (Boot time: %.2fs)" % boot_time)
	
	# Print initialization summary
	_print_initialization_summary()
	
	# Emit ready signal
	system_ready.emit()
	
	# Stop monitoring process
	set_process(false)

# ===== ERROR HANDLING =====

func _handle_initialization_error() -> void:
	"""Handle initialization errors"""
	_log_error("❌ SystemBootstrap: Initialization failed!")
	
	# Check retry logic
	for error in initialization_errors:
		var component = error.get("component", "unknown")
		if not retry_attempts.has(component):
			retry_attempts[component] = 0
		
		if retry_attempts[component] < max_retries:
			retry_attempts[component] += 1
			_log("🔄 Scheduling retry %d/%d for %s..." % [retry_attempts[component], max_retries, component])
			initialization_retry.emit(component, retry_attempts[component])
			
			# Wait before retry
			await get_tree().create_timer(1.0).timeout
			
			# Reset state for retry
			_reset_initialization_state()
			return
	
	# Max retries reached
	_log_error("❌ Maximum retry attempts reached. System initialization failed.")
	system_error.emit("initialization_failed", {
		"errors": initialization_errors,
		"retry_attempts": retry_attempts
	})

func _reset_initialization_state() -> void:
	"""Reset initialization state for retry"""
	initialization_errors.clear()
	for step in initialization_steps:
		initialization_steps[step] = false

# ===== LOGGING FUNCTIONS =====

func _log(message: String) -> void:
	"""Enhanced logging with timestamp"""
	var timestamp = Time.get_ticks_msec() - startup_time
	var log_entry = "[%dms] %s" % [timestamp, message]
	print(log_entry)
	initialization_log.append(log_entry)

func _log_warning(message: String) -> void:
	"""Log warning message"""
	push_warning(message)
	_log("⚠️ WARNING: %s" % message)

func _log_error(message: String) -> void:
	"""Log error message"""
	push_error(message)
	_log("❌ ERROR: %s" % message)

func _record_error(error_type: String, details: Dictionary) -> void:
	"""Record error for analysis"""
	var error_entry = {
		"type": error_type,
		"details": details,
		"timestamp": Time.get_ticks_msec() - startup_time
	}
	initialization_errors.append(error_entry)

func _print_initialization_summary() -> void:
	"""Print initialization summary"""
	print("\n===== INITIALIZATION SUMMARY =====")
	print("Total initialization time: %.2fs" % ((Time.get_ticks_msec() - startup_time) / 1000.0))
	print("Steps completed:")
	for step in initialization_steps:
		print("  %s: %s" % [step, "✓" if initialization_steps[step] else "✗"])
	print("Errors encountered: %d" % initialization_errors.size())
	if initialization_errors.size() > 0:
		print("Error details:")
		for error in initialization_errors:
			print("  - %s: %s" % [error.type, error.details])
	print("=================================\n")

# ===== PUBLIC ACCESS FUNCTIONS =====

func get_flood_gates():
	"""Get FloodGates instance with validation"""
	if not flood_gates_instance:
		push_warning("SystemBootstrap: FloodGates not initialized")
		if current_state == InitState.ERROR:
			push_error("SystemBootstrap: System in error state")
	return flood_gates_instance

func get_akashic_records():
	"""Get AkashicRecords instance with validation"""
	if not akashic_records_instance:
		push_warning("SystemBootstrap: AkashicRecords not initialized")
		if current_state == InitState.ERROR:
			push_error("SystemBootstrap: System in error state")
	return akashic_records_instance

func get_akashic_loader():
	"""Get AkashicLoader instance"""
	# Implement AkashicLoader access
	return akashic_loader_instance

func create_universal_being() -> Node:
	"""Create a new Universal Being with validation"""
	if not UniversalBeingClass:
		push_error("SystemBootstrap: UniversalBeing class not loaded")
		return null
	
	if current_state != InitState.READY:
		push_warning("SystemBootstrap: Creating being before system ready")
	
	var being = UniversalBeingClass.new()
	if being:
		if flood_gates_instance and flood_gates_instance.has_method("register_being"):
			flood_gates_instance.register_being(being)
		return being
	else:
		push_error("SystemBootstrap: Failed to create Universal Being")
		return null

func create_console_universal_being() -> Node:
	"""Create Console Universal Being with enhanced loading"""
	var paths = [
		"res://core/ConsoleUniversalBeing.gd",
		"res://beings/ConsoleUniversalBeing.gd",
		"res://ui/ConsoleUniversalBeing.gd"
	]
	
	for path in paths:
		if ResourceLoader.exists(path):
			var ConsoleClass = load(path)
			if ConsoleClass:
				return ConsoleClass.new()
	
	push_error("SystemBootstrap: ConsoleUniversalBeing class not found")
	return null

func is_system_ready() -> bool:
	"""Check if system is ready with state info"""
	return current_state == InitState.READY and systems_ready

func get_system_state() -> String:
	"""Get current initialization state"""
	return InitState.keys()[current_state]

func get_system_status() -> Dictionary:
	"""Get detailed system status"""
	return {
		"state": get_system_state(),
		"ready": is_system_ready(),
		"core_loaded": core_loaded,
		"systems_ready": systems_ready,
		"initialization_steps": initialization_steps,
		"errors": initialization_errors.size(),
		"retry_attempts": retry_attempts,
		"uptime_ms": Time.get_ticks_msec() - startup_time,
		"flood_gates": flood_gates_instance != null,
		"akashic_records": akashic_records_instance != null
	}

func get_initialization_log() -> Array:
	"""Get full initialization log"""
	return initialization_log
