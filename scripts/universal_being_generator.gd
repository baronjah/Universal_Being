#!/usr/bin/env -S godot --headless --script
extends SceneTree

# ==================================================
# UNIVERSAL BEING: Universal Being Generator CLI
# TYPE: system
# PURPOSE: Command-line tool for generating Universal Beings
# COMPONENTS: []
# SCENES: []
# ==================================================

# This is a CLI tool, not a Universal Being
# It uses the Universal Being architecture for consistency

# ===== COMMAND DEFINITIONS =====

const COMMANDS = {
	"new": {
		"description": "Create a new Universal Being",
		"usage": "new <name> <type> [purpose] [components] [scenes]",
		"example": "new Player player \"Player character\" \"movement.ub.zip,combat.ub.zip\" \"player.tscn\""
	},
	"component": {
		"description": "Create a new component",
		"usage": "component <name> [description]",
		"example": "component movement \"Movement component for Universal Beings\""
	},
	"list": {
		"description": "List available beings or components",
		"usage": "list [beings|components]",
		"example": "list beings"
	},
	"test": {
		"description": "Test a Universal Being",
		"usage": "test <name>",
		"example": "test Player"
	}
}

# ===== INITIALIZATION =====

func _init() -> void:
	# Parse command line arguments
	var args = OS.get_cmdline_args()
	if args.size() > 0:
		process_command(args)
	else:
		print_help()

# ===== COMMAND PROCESSING =====

func process_command(args: Array) -> void:
	var command = args[0]
	var command_args = args.slice(1)
	
	match command:
		"new":
			if command_args.size() < 2:
				print_usage("new")
				return
			create_new_being(command_args)
		"component":
			if command_args.size() < 1:
				print_usage("component")
				return
			create_new_component(command_args)
		"list":
			list_items(command_args)
		"test":
			if command_args.size() < 1:
				print_usage("test")
				return
			test_being(command_args[0])
		_:
			print("Unknown command: %s" % command)
			print_help()

func print_help() -> void:
	print("Universal Being Generator - CLI Tool")
	print("Usage: ubg <command> [args]")
	print("\nAvailable commands:")
	for cmd in COMMANDS:
		var info = COMMANDS[cmd]
		print("\n  %s - %s" % [cmd, info.description])
		print("  Usage: %s" % info.usage)
		print("  Example: %s" % info.example)

func print_usage(command: String) -> void:
	if COMMANDS.has(command):
		var info = COMMANDS[command]
		print("Usage: %s" % info.usage)
		print("Example: %s" % info.example)
	else:
		print("Unknown command: %s" % command)

# ===== BEING GENERATION =====

func create_new_being(args: Array) -> void:
	var being_name: String = args[0]
	var being_type: String = args[1]
	var purpose: String = args[2] if args.size() > 2 else ""
	var components: String = args[3] if args.size() > 3 else ""
	var scenes: String = args[4] if args.size() > 4 else ""
	
	# Generate class name and file name
	var class_name_str: String = being_name.capitalize() + "UniversalBeing"
	var file_name_str: String = being_name.to_snake_case() + "_universal_being.gd"
	var file_path_str: String = "beings/" + file_name_str
	
	# Load template
	var template_path = "res://cli/templates/universal_being_template.gd"
	var template_file = FileAccess.open(template_path, FileAccess.READ)
	if not template_file:
		push_error("Failed to load template file: " + template_path)
		return
	
	var template = template_file.get_as_text()
	template_file.close()
	
	# Define replacements as a dictionary for clarity
	var replacements_dict = {
		"\"__BEING_NAME__\"": "\"" + being_name + "\"",
		"\"__BEING_TYPE__\"": "\"" + being_type + "\"",
		"\"__PURPOSE__\"": "\"" + purpose + "\"",
		"\"__COMPONENTS__\"": "\"" + components + "\"",
		"\"__SCENES__\"": "\"" + scenes + "\"",
		"# class_name \"__CLASS_NAME__\"": "class_name " + class_name_str,
		"# __PROPERTIES__": "# Add your properties here",
		"# __COMPONENT_LOADING__": "# Add component loading here",
		"# __SCENE_LOADING__": "# Add scene loading here",
		"# __PROCESS_LOGIC__": "# Add process logic here",
		"# __INPUT_LOGIC__": "# Add input handling here",
		"# __CLEANUP_LOGIC__": "# Add cleanup logic here",
		"# __METHODS__": "# Add your methods here",
		"# __AI_METHODS__": "# Add AI methods here"
	}
	
	# Handle capabilities based on components
	var capabilities = "\"basic_being\""
	if not components.is_empty():
		capabilities = "\"basic_being\", \"component_aware\""
	replacements_dict["\"" + "basic_being" + "\"  # __CAPABILITIES__"] = capabilities
	
	# Apply all replacements
	for key in replacements_dict:
		template = template.replace(key, replacements_dict[key])
	
	# Create file
	var file = FileAccess.open(file_path_str, FileAccess.WRITE)
	if not file:
		push_error("Failed to create file: " + file_path_str)
		return
	
	file.store_string(template)
	file.close()
	
	print("Created new Universal Being: " + file_path_str)
	print("Class: " + class_name_str)
	print("Type: " + being_type)
	if not purpose.is_empty():
		print("Purpose: " + purpose)
	if not components.is_empty():
		print("Components: " + components)
	if not scenes.is_empty():
		print("Scenes: " + scenes)

# ===== COMPONENT GENERATION =====

func create_new_component(args: Array) -> void:
	var component_name: String = args[0]
	var description: String = args[1] if args.size() > 1 else ""
	
	ComponentTemplateCreator.create_component_template("res://components/" + component_name + ".ub.zip", component_name)

# ===== LISTING =====

func list_items(args: Array) -> void:
	var type = args[0] if args.size() > 0 else "beings"
	
	match type:
		"beings":
			list_beings()
		"components":
			list_components()
		_:
			print("Unknown list type: %s" % type)
			print("Available types: beings, components")

func list_beings() -> void:
	var dir = DirAccess.open("res://beings")
	if not dir:
		push_error("Failed to open beings directory")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	print("\nAvailable Universal Beings:")
	while file_name != "":
		if file_name.ends_with("_universal_being.gd"):
			var being_name = file_name.replace("_universal_being.gd", "").replace("_", " ").capitalize()
			print("  - %s" % being_name)
		file_name = dir.get_next()

func list_components() -> void:
	var dir = DirAccess.open("res://components")
	if not dir:
		push_error("Failed to open components directory")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	print("\nAvailable Components:")
	while file_name != "":
		if file_name.ends_with(".ub.zip"):
			var component_name = file_name.replace(".ub.zip", "").replace("_", " ").capitalize()
			print("  - %s" % component_name)
		file_name = dir.get_next()

# ===== TESTING =====

func test_being(being_name: String) -> void:
	var file_name = being_name.to_snake_case() + "_universal_being.gd"
	var file_path = "res://beings/" + file_name
	
	if not FileAccess.file_exists(file_path):
		push_error("Being not found: %s" % being_name)
		return
	
	print("Testing being: %s" % being_name)
	
	# Load and instantiate being
	var script = load(file_path)
	if not script:
		push_error("Failed to load being script")
		return
	
	var being = script.new()
	if not being:
		push_error("Failed to instantiate being")
		return
	
	# Run basic tests
	print("\nRunning tests...")
	
	# Test Pentagon methods
	print("  Testing Pentagon methods...")
	being.pentagon_init()
	being.pentagon_ready()
	being.pentagon_process(0.0)
	being.pentagon_input(null)
	being.pentagon_sewers()
	
	# Test AI interface
	print("  Testing AI interface...")
	var ai_interface = being.ai_interface()
	print("    Type: %s" % ai_interface.get("being_info", {}).get("type", "unknown"))
	print("    Name: %s" % ai_interface.get("being_info", {}).get("name", "unknown"))
	print("    Consciousness: %d" % ai_interface.get("being_info", {}).get("consciousness", 0))
	print("    Capabilities: %s" % str(ai_interface.get("capabilities", [])))
	
	print("\nTests completed!")

# ===== COMPONENT LOADER =====

class ComponentTemplateCreator:
	static func create_component_template(output_path: String, component_name: String) -> void:
		# Create manifest
		var manifest = {
			"name": component_name,
			"version": "1.0.0",
			"description": "Universal Being component for " + component_name,
			"author": "Universal Being Generator",
			"created_at": Time.get_unix_time_from_system(),
			"files": []
		}
		
		# Save manifest
		var json = JSON.stringify(manifest, "  ")
		var file = FileAccess.open(output_path, FileAccess.WRITE)
		if not file:
			push_error("Failed to create component file: %s" % output_path)
			return
		
		file.store_string(json)
		file.close()
		
		print("Created new component: %s" % output_path)
		print("Name: %s" % component_name)
		print("Version: %s" % manifest.version)
		print("Description: %s" % manifest.description)