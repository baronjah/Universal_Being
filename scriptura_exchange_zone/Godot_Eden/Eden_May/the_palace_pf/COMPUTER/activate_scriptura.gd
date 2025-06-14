extends Node

# Activate Scriptura System
# This script activates all components of the Scriptura Turn System with OCR and API integration

func _ready():
	print("Activating Scriptura Turn System...")
	
	# Step 1: Create integration manager
	var integration_manager = create_integration_manager()
	if not integration_manager:
		print("Failed to create integration manager")
		return
	
	# Step 2: Connect to Gemini, Luminous, and Claude
	print("Connecting to APIs...")
	connect_apis(integration_manager)
	
	# Step 3: Enable OCR processing
	print("Enabling OCR processing...")
	enable_ocr(integration_manager)
	
	# Step 4: Register command integration
	print("Registering commands...")
	register_commands(integration_manager)
	
	# Step 5: Open the Scriptura UI
	print("Opening Scriptura UI...")
	open_scriptura_ui()
	
	print("Scriptura Turn System activated successfully!")
	queue_free()  # Remove this node after activation

func create_integration_manager():
	# Create a new integration manager
	var IntegrationManager = load("res://Eden_May/integration_manager.gd")
	if not IntegrationManager:
		print("Failed to load integration_manager.gd")
		return null
	
	var manager = IntegrationManager.new()
	manager.name = "IntegrationManager"
	get_tree().root.add_child(manager)
	
	return manager

func connect_apis(integration_manager):
	if not integration_manager:
		return false
	
	# First make sure we have the right systems
	integration_manager.connect_all_systems()
	
	# Connect to APIs through scriptura turn system
	if integration_manager.scriptura_turn_system:
		integration_manager.scriptura_turn_system.connect_to_apis()
		return true
	
	return false

func enable_ocr(integration_manager):
	if not integration_manager or not integration_manager.scriptura_turn_system:
		return false
	
	# Enable OCR in scriptura turn system
	integration_manager.scriptura_turn_system.enable_ocr()
	
	# Set up OCR pipeline
	integration_manager.setup_ocr_pipeline()
	
	return true

func register_commands(integration_manager):
	if not integration_manager:
		return false
	
	# Register commands with Eden Core
	integration_manager.integrate_commands()
	
	return true

func open_scriptura_ui():
	# Load and instance the UI scene
	var scene = load("res://Eden_May/scriptura_turn_system.tscn")
	if not scene:
		print("Failed to load scriptura_turn_system.tscn")
		return false
	
	var instance = scene.instance()
	get_tree().root.add_child(instance)
	
	return true

# Command-line activation function
static func activate_from_command():
	# Create and add the activation node
	var node = load("res://Eden_May/activate_scriptura.gd").new()
	Engine.get_main_loop().root.add_child(node)
	return "Activating Scriptura Turn System..."