# 🏛️ Universal Entity Debug - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
# Debug script to check why UniversalEntity might not be loading
# Add this to any scene temporarily to debug

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("\n=== UNIVERSAL ENTITY DEBUG CHECK ===\n")
	
	# Check if the script file exists and can be loaded
	var script_path = "res://scripts/core/universal_entity/universal_entity.gd"
	if ResourceLoader.exists(script_path):
		print("✅ Script file exists: " + script_path)
		
		var script = load(script_path)
		if script:
			print("✅ Script loaded successfully")
			
			# Try to instance it
			var test_instance = Node.new()
			test_instance.set_script(script)
			if test_instance.get_script() == script:
				print("✅ Script can be applied to nodes")
			else:
				print("❌ Failed to apply script to node")
			test_instance.queue_free()
		else:
			print("❌ Failed to load script - check for parse errors")
	else:
		print("❌ Script file not found: " + script_path)
	
	# Check autoload
	var universal = get_node_or_null("/root/UniversalEntity")
	if universal:
		print("✅ UniversalEntity autoload is active")
		print("   Node name: " + universal.name)
		print("   Has script: " + str(universal.get_script() != null))
		
		# Check if methods exist
		var methods = ["_cmd_universal_status", "_cmd_make_perfect", "_cmd_health_check"]
		for method in methods:
			if universal.has_method(method):
				print("   ✅ Method exists: " + method)
			else:
				print("   ❌ Method missing: " + method)
	else:
		print("❌ UniversalEntity autoload NOT FOUND in /root/")
		print("   Available autoloads:")
		for child in get_tree().root.get_children():
			if child != get_tree().current_scene:
				print("   - " + child.name)
	
	# Check ConsoleManager
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		print("\n✅ ConsoleManager found")
		if "commands" in console:
			print("✅ Commands dictionary exists")
			print("   Total commands: " + str(console.commands.size()))
			
			# Check for our commands
			var our_commands = ["universal", "perfect", "health", "evolve", "satisfy"]
			var found_any = false
			for cmd in our_commands:
				if cmd in console.commands:
					print("   ✅ Command registered: " + cmd)
					found_any = true
			
			if not found_any:
				print("   ❌ No Universal Entity commands found")
				print("   First 10 available commands:")
				var count = 0
				for cmd in console.commands:
					print("   - " + cmd)
					count += 1
					if count >= 10:
						break
		else:
			print("❌ Commands dictionary not found in ConsoleManager")
	else:
		print("❌ ConsoleManager not found")
	
	print("\n=== DEBUG CHECK COMPLETE ===")
	print("If UniversalEntity is not loading, check:")
	print("1. Project Settings > Autoload - Is it listed and enabled?")
	print("2. Are there any script errors in the Output panel?")
	print("3. Try manually adding it to autoload with path:")
	print("   res://scripts/core/universal_entity/universal_entity.gd")
	print("\n")


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