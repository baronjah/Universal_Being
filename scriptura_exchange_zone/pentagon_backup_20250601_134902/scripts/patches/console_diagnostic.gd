# 🏛️ Console Diagnostic - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
# Console diagnostic - checks console structure

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	# Wait for everything to load
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("\n=== CONSOLE DIAGNOSTIC ===")
	
	var console = get_node_or_null("/root/ConsoleManager")
	if not console:
		print("❌ ConsoleManager not found!")
		return
	
	print("✅ ConsoleManager found")
	
	# Check what properties console has
	print("Console properties:")
	var properties = console.get_property_list()
	for prop in properties:
		if prop.name == "commands" or prop.name.contains("command"):
			print("  - " + prop.name + " (" + str(prop.type) + ")")
	
	# Try to access commands
	if "commands" in console:
		print("✅ 'commands' property exists")
		var commands = console.commands
		print("  Type: " + str(typeof(commands)))
		print("  Is Dictionary: " + str(commands is Dictionary))
		if commands is Dictionary:
			print("  Command count: " + str(commands.size()))
			print("  First 5 commands:")
			var count = 0
			for cmd in commands:
				print("    - " + cmd)
				count += 1
				if count >= 5:
					break
	else:
		print("❌ 'commands' property not found")
		
		# Try get() method
		var commands_via_get = console.get("commands")
		if commands_via_get != null:
			print("✅ Found via get() method")
			print("  Type: " + str(typeof(commands_via_get)))
		else:
			print("❌ get('commands') returned null")
	
	print("=== END DIAGNOSTIC ===\n")

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