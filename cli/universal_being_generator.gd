#!/usr/bin/env -S godot --headless --script
extends SceneTree

# Universal Being Generator CLI
# Usage: godot --headless --script universal_being_generator.gd -- <command> [options]

const COMMANDS = {
	"new": "Create a new Universal Being",
	"component": "Create a new component template",
	"list": "List all Universal Beings",
	"test": "Run tests on a Universal Being",
	"help": "Show this help message"
}

func _init():
	var args = OS.get_cmdline_args()
	var script_args = []
	var found_separator = false
	
	for arg in args:
		if found_separator:
			script_args.append(arg)
		elif arg == "--":
			found_separator = true
	
	if script_args.is_empty():
		print_help()
		quit()
		return
	
	var command = script_args[0]
	var command_args = script_args.slice(1)
	
	match command:
		"new":
			create_new_being(command_args)
		"component":
			create_new_component(command_args)
		"list":
			list_beings()
		"test":
			test_being(command_args)
		"help":
			print_help()
		_:
			print("Unknown command: %s" % command)
			print_help()
	
	quit()

func print_help():
	print("Universal Being Generator v1.0")
	print("Usage: godot --headless --script universal_being_generator.gd -- <command> [options]\n")
	print("Commands:")
	for cmd in COMMANDS:
		print("  %-12s %s" % [cmd, COMMANDS[cmd]])
	print("\nExamples:")
	print("  godot --headless --script universal_being_generator.gd -- new player_being")
	print("  godot --headless --script universal_being_generator.gd -- component ui_behavior")

func create_new_being(args: Array):
	if args.is_empty():
		print("Error: Please provide a being name")
		return
	
	var being_name = args[0]
	var being_type = args[1] if args.size() > 1 else being_name.to_lower()
	var class_name = to_pascal_case(being_name) + "UniversalBeing"
	var file_name = being_name.to_snake_case() + "_universal_being.gd"
	var file_path = "res://beings/" + file_name
	
	var template = """# ==================================================
# UNIVERSAL BEING: %s
# TYPE: %s
# PURPOSE: [Add purpose here]
# COMPONENTS: [List components]
# SCENES: [List scenes]
# ==================================================

extends UniversalBeing
class_name %s

# ===== BEING-SPECIFIC PROPERTIES =====
# Add your exported properties here

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	being_type = "%s"
	being_name = "%s"
	consciousness_level = 1
	
	evolution_state.can_become = [
		# Add evolution paths
	]
	
	print("🌟 %%s: Pentagon Init Complete" %% being_name)

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Load scenes and components
	# load_scene("res://scenes/...")
	# add_component("res://components/...")
	
	print("🌟 %%s: Pentagon Ready Complete" %% being_name)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Process logic here

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Input handling here

func pentagon_sewers() -> void:
	print("🌟 %%s: Pentagon Sewers" %% being_name)
	
	# Cleanup here
	
	super.pentagon_sewers()

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	var base = super.ai_interface()
	base.custom_commands = [
		# Add custom AI commands
	]
	return base

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	match method_name:
		# Add custom command handlers
		_:
			return super.ai_invoke_method(method_name, args)

func _to_string() -> String:
	return "%s<%%s>" %% being_name
""" % [being_name.capitalize(), being_type, class_name, being_type, being_name.capitalize(), class_name]
	
	# Create the file
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(template)
		file.close()
		print("✨ Created new Universal Being: %s" % file_path)
		print("   Class name: %s" % class_name)
		print("   Being type: %s" % being_type)
	else:
		print("❌ Error: Could not create file: %s" % file_path)

func create_new_component(args: Array):
	if args.is_empty():
		print("Error: Please provide a component name")
		return
	
	var component_name = args[0]
	var output_path = "res://components/%s.ub.zip" % component_name
	
	ComponentLoader.create_component_template(output_path, component_name)

func list_beings():
	print("📋 Universal Beings in project:\n")
	
	var dir = DirAccess.open("res://beings")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var count = 0
		
		while file_name != "":
			if file_name.ends_with(".gd"):
				count += 1
				var being_name = file_name.trim_suffix("_universal_being.gd")
				print("  %d. %s" % [count, being_name])
			file_name = dir.get_next()
		
		if count == 0:
			print("  No Universal Beings found")
		else:
			print("\nTotal: %d Universal Beings" % count)
	else:
		print("  Error: Could not access beings directory")

func test_being(args: Array):
	if args.is_empty():
		print("Error: Please provide a being name to test")
		return
	
	var being_name = args[0]
	print("🧪 Testing Universal Being: %s" % being_name)
	print("   [Test implementation pending]")

func to_pascal_case(text: String) -> String:
	var words = text.split("_")
	var result = ""
	for word in words:
		result += word.capitalize()
	return result