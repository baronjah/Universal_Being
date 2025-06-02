# ==================================================
# SCRIPT NAME: SystemBootstrap_Fixed.gd (Autoload)
# DESCRIPTION: Enhanced Bootstrap Universal Being System with robust initialization
# PURPOSE: Initialize Universal Being ecosystem with proper state management
# CREATED: 2025-12-01 - Fixed Version
# AUTHOR: JSH + Claude (Opus)
# ==================================================

extends Node

# ===== STATE MANAGEMENT =====
enum BootstrapState {
	IDLE,
	LOADING_CLASSES,
	CLASSES_LOADED,
	INITIALIZING_SYSTEMS,
	SYSTEMS_READY,
	ERROR
}

var current_state: BootstrapState = BootstrapState.IDLE
var core_loaded: bool = false
var systems_ready: bool = false
var startup_time: int = 0
var initialization_errors: Array = []
var retry_count: int = 0
var max_retries: int = 3

# Global references
var flood_gates_instance = null
var akashic_records_instance = null

# Core resources
var UniversalBeingClass = null
var FloodGatesClass = null
var AkashicRecordsClass = null

# Signals
signal system_ready()
signal system_error(error: String)
signal state_changed(new_state: BootstrapState)

func _ready() -> void:
	name = "SystemBootstrap"
	startup_time = Time.get_ticks_msec()
	print("🚀 SystemBootstrap: Enhanced initialization starting...")
	print("🚀 SystemBootstrap: Godot version: %s" % Engine.get_version_info().string)
	
	# Start initialization process
	set_state(BootstrapState.LOADING_CLASSES)
	call_deferred("_initialize_async")

func _initialize_async() -> void:
	"""Async initialization with retry logic"""
	print("🚀 SystemBootstrap: Starting async initialization...")
	
	# Try loading core classes
	if not load_core_classes():
		if retry_count < max_retries:
			retry_count += 1
			print("🚀 SystemBootstrap: Retry %d/%d..." % [retry_count, max_retries])
			await get_tree().create_timer(0.5).timeout
			_initialize_async()
			return
		else:
			set_state(BootstrapState.ERROR)
			var error = "Failed to load core classes after %d attempts" % max_retries
			push_error("🚀 SystemBootstrap: " + error)
			system_error.emit(error)
			return
	
	# Classes loaded successfully
	set_state(BootstrapState.CLASSES_LOADED)
	await get_tree().process_frame  # Wait one frame
	
	# Initialize systems
	set_state(BootstrapState.INITIALIZING_SYSTEMS)
	initialize_systems()

func set_state(new_state: BootstrapState) -> void:
	"""Update bootstrap state with logging"""
	current_state = new_state
	state_changed.emit(new_state)
	
	var state_names = {
		BootstrapState.IDLE: "IDLE",
		BootstrapState.LOADING_CLASSES: "LOADING_CLASSES",
		BootstrapState.CLASSES_LOADED: "CLASSES_LOADED",
		BootstrapState.INITIALIZING_SYSTEMS: "INITIALIZING_SYSTEMS",
		BootstrapState.SYSTEMS_READY: "SYSTEMS_READY",
		BootstrapState.ERROR: "ERROR"
	}
	
	print("🚀 SystemBootstrap: State changed to %s" % state_names[new_state])

func load_core_classes() -> bool:
	"""Load core class resources with validation"""
	print("🚀 SystemBootstrap: Loading core classes...")
	initialization_errors.clear()
	
	# Define class paths with multiple fallbacks
	var class_configs = {
		"UniversalBeing": {
			"paths": [
				"res://core/UniversalBeing.gd",
				"res://systems/UniversalBeing.gd",
				"res://beings/UniversalBeing.gd"
			],
			"required": true,
			"validate": true
		},
		"FloodGates": {
			"paths": [
				"res://core/FloodGates.gd",
				"res://systems/FloodGates.gd",
				"res://autoloads/FloodGates.gd"
			],
			"required": true,
			"validate": true
		},
		"AkashicRecords": {
			"paths": [
				"res://core/AkashicRecords.gd",
				"res://systems/AkashicRecords.gd",
				"res://libraries/AkashicRecords.gd"
			],
			"required": true,
			"validate": true
		}
	}
	
	# Load each class with validation
	for class_name_key in class_configs:
		var config = class_configs[class_name_key]
		var loaded = false
		
		print("🚀 SystemBootstrap: Loading %s..." % class_name_key)
		
		for path in config.paths:
			if ResourceLoader.exists(path):
				print("🚀 SystemBootstrap: Found at %s" % path)
				
				# Use thread-safe loading
				var resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REUSE)
				
				if resource:
					# Validate if needed
					if config.validate and not _validate_class(resource, path):
						print("🚀 SystemBootstrap: ❌ Validation failed for %s" % class_name_key)
						continue
					
					# Assign to appropriate variable
					match class_name_key:
						"UniversalBeing":
							UniversalBeingClass = resource
						"FloodGates":
							FloodGatesClass = resource
						"AkashicRecords":
							AkashicRecordsClass = resource
					
					print("🚀 SystemBootstrap: ✅ Loaded %s from %s" % [class_name_key, path])
					loaded = true
					break
		
		if not loaded and config.required:
			var error = "Failed to load required class: " + class_name_key
			initialization_errors.append(error)
			push_error("🚀 SystemBootstrap: " + error)
	
	# Check if all required classes loaded
	var all_loaded = UniversalBeingClass and FloodGatesClass and AkashicRecordsClass
	
	if all_loaded:
		core_loaded = true
		print("🚀 SystemBootstrap: ✅ All core classes loaded successfully!")
		return true
	else:
		print("🚀 SystemBootstrap: ❌ Core class loading failed")
		_log_missing_classes()
		return false

func _validate_class(resource: Resource, path: String) -> bool:
	"""Validate that a loaded resource is the expected class"""
	if not resource:
		return false
	
	# Basic validation - check if it's a GDScript
	if not resource is GDScript:
		print("🚀 SystemBootstrap: Resource is not a GDScript")
		return false
	
	# Could add more validation here if needed
	return true

func _log_missing_classes() -> void:
	"""Log which classes are missing"""
	if not UniversalBeingClass:
		print("🚀 SystemBootstrap: ❌ UniversalBeing class not loaded")
	if not FloodGatesClass:
		print("🚀 SystemBootstrap: ❌ FloodGates class not loaded")
	if not AkashicRecordsClass:
		print("🚀 SystemBootstrap: ❌ AkashicRecords class not loaded")

func initialize_systems() -> void:
	"""Initialize core system instances with error handling"""
	print("🚀 SystemBootstrap: Initializing systems...")
	
	if not core_loaded:
		set_state(BootstrapState.ERROR)
		var error = "Cannot initialize - core not loaded"
		push_error("🚀 SystemBootstrap: " + error)
		system_error.emit(error)
		return
	
	# Create FloodGates instance
	if not _create_system_instance("FloodGates", FloodGatesClass):
		return
	
	# Create AkashicRecords instance
	if not _create_system_instance("AkashicRecords", AkashicRecordsClass):
		return
	
	# All systems created successfully
	systems_ready = true
	set_state(BootstrapState.SYSTEMS_READY)
	system_ready.emit()
	
	var boot_time = (Time.get_ticks_msec() - startup_time) / 1000.0
	print("🚀 SystemBootstrap: ✅ All systems ready!")
	print("🚀 SystemBootstrap: Boot time: %.2fs" % boot_time)
	_log_system_status()

func _create_system_instance(system_name: String, system_class: Resource) -> bool:
	"""Create a system instance with error handling"""
	print("🚀 SystemBootstrap: Creating %s instance..." % system_name)
	
	# Create instance with error handling
	var instance = system_class.new()
	if not instance:
		var error = "Failed to instantiate " + system_name
		initialization_errors.append(error)
		push_error("🚀 SystemBootstrap: " + error)
		set_state(BootstrapState.ERROR)
		system_error.emit(error)
		return false
	
	# Set up instance
	instance.name = system_name
	add_child(instance)
	
	# Assign to appropriate variable
	match system_name:
		"FloodGates":
			flood_gates_instance = instance
		"AkashicRecords":
			akashic_records_instance = instance
	
	print("🚀 SystemBootstrap: ✅ %s instance created" % system_name)
	return true

func throw_error(message: String) -> void:
	"""Helper to throw an error (GDScript doesn't have exceptions)"""
	push_error(message)
	assert(false, message)

# ===== GLOBAL ACCESS FUNCTIONS =====

func get_flood_gates():
	"""Get FloodGates instance with null check"""
	if not flood_gates_instance:
		push_warning("SystemBootstrap: FloodGates not initialized")
		if current_state == BootstrapState.ERROR:
			push_error("SystemBootstrap: System is in error state")
	return flood_gates_instance

func get_akashic_records():
	"""Get AkashicRecords instance with null check"""
	if not akashic_records_instance:
		push_warning("SystemBootstrap: AkashicRecords not initialized")
		if current_state == BootstrapState.ERROR:
			push_error("SystemBootstrap: System is in error state")
	return akashic_records_instance

func create_universal_being() -> Node:
	"""Create a new Universal Being instance"""
	if not UniversalBeingClass:
		push_error("SystemBootstrap: UniversalBeing class not loaded")
		return null
	
	var being = UniversalBeingClass.new()
	if being:
		print("🚀 SystemBootstrap: Created new Universal Being")
		return being
	
	push_error("SystemBootstrap: Failed to create Universal Being")
	return null

func create_console_universal_being() -> Node:
	"""Create a new Console Universal Being instance"""
	var console_path = "res://core/ConsoleUniversalBeing.gd"
	
	if not ResourceLoader.exists(console_path):
		push_error("SystemBootstrap: ConsoleUniversalBeing.gd not found")
		return null
	
	var ConsoleUniversalBeingClass = load(console_path)
	if ConsoleUniversalBeingClass:
		return ConsoleUniversalBeingClass.new()
	return null

func is_system_ready() -> bool:
	"""Check if system is ready"""
	return current_state == BootstrapState.SYSTEMS_READY

func get_current_state() -> BootstrapState:
	"""Get current bootstrap state"""
	return current_state

# ===== SYSTEM DIAGNOSTICS =====

func get_system_status() -> Dictionary:
	"""Get comprehensive system status"""
	return {
		"state": current_state,
		"core_loaded": core_loaded,
		"systems_ready": systems_ready,
		"flood_gates": flood_gates_instance != null,
		"akashic_records": akashic_records_instance != null,
		"universal_being_class": UniversalBeingClass != null,
		"uptime": (Time.get_ticks_msec() - startup_time) / 1000.0,
		"errors": initialization_errors,
		"retry_count": retry_count
	}

func _log_system_status() -> void:
	"""Log the status of all systems"""
	print("\n🚀 SystemBootstrap: System Status Report")
	print("----------------------------------------")
	print("UniversalBeing Class: %s" % ("✅ Loaded" if UniversalBeingClass else "❌ Missing"))
	print("FloodGates: %s" % ("✅ Ready" if flood_gates_instance else "❌ Not Ready"))
	print("AkashicRecords: %s" % ("✅ Ready" if akashic_records_instance else "❌ Not Ready"))
	print("----------------------------------------")

# ===== CONVENIENCE FUNCTIONS =====

func add_being_to_scene(being: Node, parent: Node) -> bool:
	"""Add being to scene through FloodGates"""
	if not being or not parent:
		push_error("SystemBootstrap: Invalid being or parent")
		return false
		
	if flood_gates_instance and flood_gates_instance.has_method("add_being"):
		return flood_gates_instance.add_being(being, parent)
	else:
		push_warning("SystemBootstrap: Using fallback add_child - FloodGates not ready")
		parent.add_child(being)
		return true

func load_being_data(path: String) -> Dictionary:
	"""Load being data from Akashic Records"""
	if akashic_records_instance and akashic_records_instance.has_method("load_being_from_zip"):
		return akashic_records_instance.load_being_from_zip(path)
	push_error("SystemBootstrap: AkashicRecords not available")
	return {}

# ===== DEBUG FUNCTIONS =====

func force_reinitialize() -> void:
	"""Force reinitialize the system (for debugging)"""
	print("🚀 SystemBootstrap: Force reinitializing...")
	
	# Clean up existing instances
	if flood_gates_instance:
		flood_gates_instance.queue_free()
		flood_gates_instance = null
	if akashic_records_instance:
		akashic_records_instance.queue_free()
		akashic_records_instance = null
	
	# Reset state
	current_state = BootstrapState.IDLE
	core_loaded = false
	systems_ready = false
	retry_count = 0
	initialization_errors.clear()
	
	# Restart
	await get_tree().process_frame
	set_state(BootstrapState.LOADING_CLASSES)
	_initialize_async()

func get_bootstrap_instance():
	"""Get the bootstrap instance (self)"""
	return self
