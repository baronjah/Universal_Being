# ==================================================
# SCRIPT NAME: SystemBootstrap.gd (Autoload)
# DESCRIPTION: Bootstrap Universal Being System - Load core classes safely
# PURPOSE: Initialize Universal Being ecosystem without circular dependencies
# CREATED: 2025-06-01 - Universal Being Revolution
# AUTHOR: JSH + Claude Code + Luminus + Alpha
# ==================================================

extends Node

# ===== SYSTEM BOOTSTRAP =====

var core_loaded: bool = false
var systems_ready: bool = false
var startup_time: int = 0
var initialization_errors: Array = []

# Global references
var flood_gates_instance = null
var akashic_records_instance = null

# Core resources
var UniversalBeingClass = null
var FloodGatesClass = null
var AkashicRecordsClass = null

signal system_ready()
signal system_error(error: String)

func _ready() -> void:
	name = "SystemBootstrap"
	startup_time = Time.get_ticks_msec()
	print("🚀 SystemBootstrap: Initializing Universal Being core...")
	
	# Load synchronously first
	load_core_classes()
	
	# Then initialize on next frame to ensure scene tree is ready
	call_deferred("initialize_systems")

func load_core_classes() -> void:
	"""Load core class resources with validation"""
	print("🚀 SystemBootstrap: Loading core classes...")
	
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
		"AkashicRecords": {
			"paths": ["res://core/AkashicRecords.gd", "res://systems/AkashicRecords.gd"],
			"required": true
		}
	}
	
	# Load each class
	for class_name in class_configs:
		var config = class_configs[class_name]
		var loaded = false
		
		for path in config.paths:
			if ResourceLoader.exists(path):
				var resource = load(path)
				if resource:
					match class_name:
						"UniversalBeing": UniversalBeingClass = resource
						"FloodGates": FloodGatesClass = resource
						"AkashicRecords": AkashicRecordsClass = resource
					print("   ✓ Loaded %s from %s" % [class_name, path])
					loaded = true
					break
		
		if not loaded and config.required:
			var error = "Failed to load required class: " + class_name
			initialization_errors.append(error)
			push_error("🚀 SystemBootstrap: " + error)
	
	# Validate all loaded
	if UniversalBeingClass and FloodGatesClass and AkashicRecordsClass:
		core_loaded = true
		print("🚀 SystemBootstrap: Core classes loaded successfully!")
	else:
		system_error.emit("Core class loading failed")

func initialize_systems() -> void:
	"""Initialize core system instances"""
	if not core_loaded:
		push_error("🚀 SystemBootstrap: Cannot initialize - core not loaded")
		return
	
	print("🚀 SystemBootstrap: Creating system instances...")
	
	# Create FloodGates instance
	flood_gates_instance = FloodGatesClass.new()
	flood_gates_instance.name = "FloodGates"
	add_child(flood_gates_instance)
	
	# Create AkashicRecords instance  
	akashic_records_instance = AkashicRecordsClass.new()
	akashic_records_instance.name = "AkashicRecords"
	add_child(akashic_records_instance)
	
	# Verify all systems ready
	if flood_gates_instance and akashic_records_instance:
		systems_ready = true
		system_ready.emit()
		var boot_time = (Time.get_ticks_msec() - startup_time) / 1000.0
		print("🚀 SystemBootstrap: Universal Being systems ready! (Boot time: %.2fs)" % boot_time)
	else:
		system_error.emit("System initialization incomplete")

# ===== GLOBAL ACCESS FUNCTIONS =====

func get_flood_gates():
	"""Get FloodGates instance"""
	if not flood_gates_instance:
		push_warning("SystemBootstrap: FloodGates not initialized")
	return flood_gates_instance

func get_akashic_records():
	"""Get AkashicRecords instance"""
	if not akashic_records_instance:
		push_warning("SystemBootstrap: AkashicRecords not initialized")
	return akashic_records_instance

func create_universal_being() -> Node:
	"""Create a new Universal Being instance"""
	if UniversalBeingClass:
		return UniversalBeingClass.new()
	return null

func create_console_universal_being() -> Node:
	"""Create a new Console Universal Being instance"""
	var ConsoleUniversalBeingClass = load("res://core/ConsoleUniversalBeing.gd")
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
		"universal_being_class": UniversalBeingClass != null,
		"uptime": (Time.get_ticks_msec() - startup_time) / 1000.0,
		"errors": initialization_errors
	}

# ===== CONVENIENCE FUNCTIONS =====

static func add_being_to_scene(being: Node, parent: Node) -> bool:
	"""Static function to add being to scene through FloodGates"""
	if not being or not parent:
		push_error("SystemBootstrap: Invalid being or parent")
		return false
		
	var bootstrap = get_node_or_null("/root/SystemBootstrap")
	if bootstrap and bootstrap.flood_gates_instance:
		return bootstrap.flood_gates_instance.add_being(being, parent)
	else:
		push_warning("SystemBootstrap: Using fallback add_child - FloodGates not ready")
		parent.add_child(being)
		return true

static func load_being_data(path: String) -> Dictionary:
	"""Static function to load being data from Akashic Records"""
	var bootstrap = get_node_or_null("/root/SystemBootstrap")
	if bootstrap and bootstrap.akashic_records_instance:
		return bootstrap.akashic_records_instance.load_being_from_zip(path)
	push_error("SystemBootstrap: AkashicRecords not available")
	return {}

static func get_bootstrap_instance():
	"""Get the bootstrap instance"""
	return get_node_or_null("/root/SystemBootstrap")
