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

# Global references
var flood_gates_instance = null
var akashic_records_instance = null

# Core resources
var UniversalBeingClass = null
var FloodGatesClass = null
var AkashicRecordsClass = null

signal system_ready()

func _ready() -> void:
	name = "SystemBootstrap"
	print("🚀 SystemBootstrap: Initializing Universal Being core...")
	
	load_core_classes()
	await get_tree().create_timer(0.1).timeout  # Small delay for loading
	initialize_systems()

func load_core_classes() -> void:
	"""Load core class resources"""
	print("🚀 SystemBootstrap: Loading core classes...")
	
	# Load class scripts
	UniversalBeingClass = load("res://core/UniversalBeing.gd")
	FloodGatesClass = load("res://core/FloodGates.gd") 
	AkashicRecordsClass = load("res://core/AkashicRecords.gd")
	
	if UniversalBeingClass and FloodGatesClass and AkashicRecordsClass:
		core_loaded = true
		print("🚀 SystemBootstrap: Core classes loaded successfully!")
	else:
		push_error("🚀 SystemBootstrap: Failed to load core classes")

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
	
	systems_ready = true
	system_ready.emit()
	print("🚀 SystemBootstrap: Universal Being systems ready!")

# ===== GLOBAL ACCESS FUNCTIONS =====

func get_flood_gates():
	"""Get FloodGates instance"""
	return flood_gates_instance

func get_akashic_records():
	"""Get AkashicRecords instance"""
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

# ===== CONVENIENCE FUNCTIONS =====

static func add_being_to_scene(being: Node, parent: Node) -> bool:
	"""Static function to add being to scene"""
	var bootstrap = Engine.get_singleton("SystemBootstrap")
	if bootstrap and bootstrap.flood_gates_instance:
		return bootstrap.flood_gates_instance.add_being(being, parent)
	else:
		# Fallback to direct add
		parent.add_child(being)
		return true

static func load_being_data(path: String) -> Dictionary:
	"""Static function to load being data"""
	var bootstrap = Engine.get_singleton("SystemBootstrap")
	if bootstrap and bootstrap.akashic_records_instance:
		return bootstrap.akashic_records_instance.load_being_from_zip(path)
	return {}

static func get_bootstrap_instance():
	"""Get the bootstrap instance"""
	return Engine.get_singleton("SystemBootstrap")