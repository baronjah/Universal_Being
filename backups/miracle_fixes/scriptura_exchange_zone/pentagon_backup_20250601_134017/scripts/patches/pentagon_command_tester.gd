# 🏛️ Pentagon Command Tester - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: pentagon_command_tester.gd
# DESCRIPTION: Test and verify Pentagon debug commands work
# PURPOSE: Validate that strategic testing commands are available
# CREATED: 2025-05-31
# ==================================================

extends UniversalBeingBase
func _ready() -> void:
	# Register test command
	await get_tree().create_timer(2.0).timeout
	_register_test_command()

func _register_test_command() -> void:
	var console = get_node_or_null("/root/ConsoleManager")
	if console and console.has_method("register_command"):
		console.register_command("test_pentagon", _cmd_test_pentagon, "Test Pentagon debug commands availability")
		print("🧪 [PentagonTester] Test command registered - use 'test_pentagon'")

func _cmd_test_pentagon(_args: Array) -> String:
	var result = "🧪 PENTAGON COMMAND TEST\n"
	result += "═══════════════════════════\n"
	
	var console = get_node_or_null("/root/ConsoleManager")
	if not console:
		return result + "❌ ConsoleManager not found!"
	
	result += "✅ ConsoleManager found\n"
	result += "📊 Total commands: " + str(console.commands.size()) + "\n\n"
	
	# Check each Pentagon command
	var pentagon_commands = {
		"pentagon_status": "Show Perfect Pentagon system status",
		"system_health": "Show overall system health",
		"flow_trace": "Trace Pentagon flow patterns", 
		"gamma_status": "Show Gamma AI status"
	}
	
	result += "🎯 PENTAGON COMMANDS STATUS:\n"
	var found_count = 0
	
	for cmd_name in pentagon_commands:
		if cmd_name in console.commands:
			result += "✅ " + cmd_name + ": AVAILABLE\n"
			found_count += 1
		else:
			result += "❌ " + cmd_name + ": MISSING\n"
	
	result += "\n📈 SUMMARY: " + str(found_count) + "/" + str(pentagon_commands.size()) + " commands found\n"
	
	# Test executing pentagon_status if available
	if "pentagon_status" in console.commands:
		result += "\n🔄 TESTING pentagon_status execution...\n"
		var status_result = console.commands["pentagon_status"].call([])
		if status_result:
			result += "✅ pentagon_status executed successfully!\n"
			result += "📋 First 200 chars: " + str(status_result).substr(0, 200) + "...\n"
		else:
			result += "❌ pentagon_status execution failed\n"
	
	# Check for PentagonDebugCommands node
	result += "\n🔍 NODE EXISTENCE CHECK:\n"
	var pentagon_node = get_node_or_null("/root/MainGame/PentagonDebugCommands")
	if pentagon_node:
		result += "✅ PentagonDebugCommands node found\n"
	else:
		result += "❌ PentagonDebugCommands node missing\n"
		
	# Check enhanced registrar
	var registrar = get_node_or_null("/root/MainGame/EnhancedCommandRegistrar")
	if registrar:
		result += "✅ EnhancedCommandRegistrar node found\n"
	else:
		result += "❌ EnhancedCommandRegistrar node missing\n"
	
	return result

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