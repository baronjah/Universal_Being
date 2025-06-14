# 🏛️ Enhanced Command Registrar - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: enhanced_command_registrar.gd
# DESCRIPTION: Bulletproof command registration system for Pentagon debug commands
# PURPOSE: Ensures Pentagon debug commands are always accessible with multiple strategies
# CREATED: 2025-05-31
# ==================================================

extends UniversalBeingBase
class_name EnhancedCommandRegistrar

# ═══════════════════════════════════════════════════════════════════════════════
# REGISTRATION STRATEGIES USED:
# 1. IMMEDIATE: Try registration immediately when added to scene
# 2. DELAYED: Wait for console manager initialization with multiple timeouts
# 3. FALLBACK: Direct dictionary access if standard registration fails
# 4. PERSISTENT: Keep retrying until successful registration
# 5. DIAGNOSTIC: Provide detailed information about registration status
# ═══════════════════════════════════════════════════════════════════════════════

signal commands_registered(success: bool)
signal registration_diagnostic(message: String)

var registration_attempts: int = 0
var max_attempts: int = 10
var registration_successful: bool = false
var console_manager: Node = null
var pentagon_commands: Node = null

# Command registration tracking
var registered_commands: Dictionary = {}
var expected_commands: Array = ["pentagon_status", "system_health", "flow_trace", "gamma_status"]

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("🔧 [EnhancedCommandRegistrar] Initializing bulletproof command registration...")
	_start_registration_sequence()

func _start_registration_sequence() -> void:
	"""
	Initiates the multi-strategy command registration sequence
	Uses multiple approaches to ensure commands are always registered
	"""
	registration_diagnostic.emit("Starting enhanced registration sequence...")
	
	# STRATEGY 1: IMMEDIATE REGISTRATION
	_attempt_immediate_registration()
	
	# STRATEGY 2: DELAYED REGISTRATION (Multiple timeouts)
	_schedule_delayed_registration()
	
	# STRATEGY 3: PERSISTENT MONITORING
	_start_persistent_monitoring()

func _attempt_immediate_registration() -> void:
	"""
	STRATEGY 1: Try immediate registration
	Sometimes console manager is already available
	"""
	registration_attempts += 1
	print("🎯 [EnhancedCommandRegistrar] Attempt #%d - Immediate registration" % registration_attempts)
	
	console_manager = get_node_or_null("/root/ConsoleManager")
	pentagon_commands = get_node_or_null("/root/MainGameController/PentagonDebugCommands")
	
	if console_manager and pentagon_commands:
		_perform_registration()
	else:
		var diagnostic = "Immediate registration failed - "
		if not console_manager:
			diagnostic += "ConsoleManager not found. "
		if not pentagon_commands:
			diagnostic += "PentagonDebugCommands not found."
		
		registration_diagnostic.emit(diagnostic)
		print("⚠️ [EnhancedCommandRegistrar] " + diagnostic)

func _schedule_delayed_registration() -> void:
	"""
	STRATEGY 2: Schedule multiple delayed registration attempts
	Uses progressive delays to catch console manager at different initialization stages
	"""
	var delays = [0.5, 1.0, 2.0, 3.0, 5.0]  # Progressive delays in seconds
	
	for delay in delays:
		await get_tree().create_timer(delay).timeout
		if not registration_successful:
			await _attempt_delayed_registration(delay)

func _attempt_delayed_registration(delay: float) -> void:
	"""
	STRATEGY 2: Delayed registration with specific timeout
	"""
	registration_attempts += 1
	print("🕐 [EnhancedCommandRegistrar] Attempt #%d - Delayed registration (%.1fs)" % [registration_attempts, delay])
	
	console_manager = get_node_or_null("/root/ConsoleManager")
	pentagon_commands = get_node_or_null("/root/MainGameController/PentagonDebugCommands")
	
	if console_manager and pentagon_commands and not registration_successful:
		await _perform_registration()
	elif registration_attempts >= max_attempts:
		_attempt_fallback_registration()

func _start_persistent_monitoring() -> void:
	"""
	STRATEGY 3: Persistent monitoring for console manager appearance
	Continuously checks for console manager and attempts registration
	"""
	while not registration_successful and registration_attempts < max_attempts:
		await get_tree().create_timer(1.0).timeout
		
		if not registration_successful:
			console_manager = get_node_or_null("/root/ConsoleManager")
			pentagon_commands = get_node_or_null("/root/MainGameController/PentagonDebugCommands")
			
			if console_manager and pentagon_commands:
				registration_attempts += 1
				print("👁️ [EnhancedCommandRegistrar] Attempt #%d - Persistent monitoring" % registration_attempts)
				await _perform_registration()

func _perform_registration() -> void:
	"""
	Core registration logic using multiple methods
	Tries standard registration first, then fallback methods
	"""
	var success = false
	
	# METHOD 1: Standard registration using register_command
	if console_manager.has_method("register_command"):
		success = _register_commands_standard()
		if success:
			print("✅ [EnhancedCommandRegistrar] Standard registration successful!")
	
	# METHOD 2: Fallback - Direct dictionary access
	if not success and console_manager.has_property("commands"):
		success = _register_commands_fallback()
		if success:
			print("✅ [EnhancedCommandRegistrar] Fallback registration successful!")
	
	# METHOD 3: Force registration through pentagon commands node
	if not success:
		success = await _register_commands_force()
		if success:
			print("✅ [EnhancedCommandRegistrar] Force registration successful!")
	
	if success:
		registration_successful = true
		_verify_registration()
		commands_registered.emit(true)
		registration_diagnostic.emit("Registration successful using multiple strategies!")
	else:
		registration_diagnostic.emit("All registration methods failed - attempting fallback")
		_attempt_fallback_registration()

func _register_commands_standard() -> bool:
	"""
	METHOD 1: Standard registration using console manager's register_command method
	"""
	var commands_registered_count = 0
	
	for cmd in expected_commands:
		var method_name = "_cmd_" + cmd
		if pentagon_commands.has_method(method_name):
			var callable = Callable(pentagon_commands, method_name)
			console_manager.register_command(cmd, callable, "Pentagon debug command: " + cmd)
			registered_commands[cmd] = "standard"
			commands_registered_count += 1
		else:
			print("❌ [EnhancedCommandRegistrar] Method %s not found in pentagon_commands" % method_name)
	
	return commands_registered_count == expected_commands.size()

func _register_commands_fallback() -> bool:
	"""
	METHOD 2: Fallback registration using direct dictionary access
	"""
	var commands_registered_count = 0
	
	for cmd in expected_commands:
		var method_name = "_cmd_" + cmd
		if pentagon_commands.has_method(method_name):
			var callable = Callable(pentagon_commands, method_name)
			console_manager.commands[cmd] = callable
			registered_commands[cmd] = "fallback"
			commands_registered_count += 1
	
	return commands_registered_count == expected_commands.size()

func _register_commands_force() -> bool:
	"""
	METHOD 3: Force registration by calling pentagon commands registration directly
	"""
	if pentagon_commands.has_method("_register_commands"):
		pentagon_commands._register_commands()
		
		# Wait a moment for registration to complete
		await get_tree().create_timer(0.1).timeout
		
		# Check if commands are now available
		return _test_command_availability()
	
	return false

func _attempt_fallback_registration() -> void:
	"""
	STRATEGY 4: Ultimate fallback - Create our own command handler
	This ensures commands work even if console manager is completely broken
	"""
	print("🚨 [EnhancedCommandRegistrar] Attempting ultimate fallback registration...")
	
	# Create a fallback command handler
	var fallback_handler = Node.new()
	fallback_handler.name = "FallbackCommandHandler"
	fallback_handler.set_script(load("res://scripts/patches/pentagon_debug_commands.gd"))
	get_tree().FloodgateController.universal_add_child(fallback_handler, root)
	
	# Try to register through console directly
	if console_manager:
		if not console_manager.has_property("commands"):
			console_manager.commands = {}
		
		for cmd in expected_commands:
			var method_name = "_cmd_" + cmd
			if fallback_handler.has_method(method_name):
				var callable = Callable(fallback_handler, method_name)
				console_manager.commands[cmd] = callable
				registered_commands[cmd] = "ultimate_fallback"
		
		registration_successful = true
		print("🆘 [EnhancedCommandRegistrar] Ultimate fallback registration completed!")
		commands_registered.emit(true)
	else:
		print("💀 [EnhancedCommandRegistrar] All registration strategies failed!")
		commands_registered.emit(false)

func _verify_registration() -> void:
	"""
	Verify that all expected commands are properly registered and accessible
	"""
	print("🔍 [EnhancedCommandRegistrar] Verifying command registration...")
	
	var verification_results = {}
	for cmd in expected_commands:
		var available = _test_single_command(cmd)
		verification_results[cmd] = available
		
		if available:
			print("✅ Command '%s' verified and accessible" % cmd)
		else:
			print("❌ Command '%s' verification failed" % cmd)
	
	# Generate comprehensive diagnostic report
	_generate_diagnostic_report(verification_results)

func _test_single_command(command_name: String) -> bool:
	"""
	Test if a single command is accessible and executable
	"""
	if not console_manager:
		return false
	
	# Test if command exists in console manager
	if console_manager.has_property("commands") and console_manager.commands.has(command_name):
		return true
	
	# Test if console manager has the command registered another way
	if console_manager.has_method("has_command") and console_manager.has_command(command_name):
		return true
	
	return false

func _test_command_availability() -> bool:
	"""
	Test if all expected commands are available
	"""
	var available_count = 0
	for cmd in expected_commands:
		if _test_single_command(cmd):
			available_count += 1
	
	return available_count == expected_commands.size()

func _generate_diagnostic_report(verification_results: Dictionary) -> void:
	"""
	Generate comprehensive diagnostic report about registration status
	"""
	var report = "\n🔧 ENHANCED COMMAND REGISTRAR DIAGNOSTIC REPORT\n"
	report += "═══════════════════════════════════════════════════\n"
	
	report += "📊 REGISTRATION STATUS:\n"
	report += "   Attempts: %d/%d\n" % [registration_attempts, max_attempts]
	report += "   Success: %s\n" % ("YES" if registration_successful else "NO")
	report += "   Console Manager: %s\n" % ("FOUND" if console_manager else "NOT FOUND")
	report += "   Pentagon Commands: %s\n" % ("FOUND" if pentagon_commands else "NOT FOUND")
	
	report += "\n🎯 COMMAND VERIFICATION:\n"
	for cmd in expected_commands:
		var status = "✅ AVAILABLE" if verification_results.get(cmd, false) else "❌ UNAVAILABLE"
		var method = registered_commands.get(cmd, "unknown")
		report += "   %s: %s (%s)\n" % [cmd, status, method]
	
	report += "\n🛠️ REGISTRATION METHODS USED:\n"
	var methods_used = {}
	for cmd in registered_commands:
		var method = registered_commands[cmd]
		methods_used[method] = methods_used.get(method, 0) + 1
	
	for method in methods_used:
		report += "   %s: %d commands\n" % [method, methods_used[method]]
	
	report += "\n💡 RECOMMENDATIONS:\n"
	if not registration_successful:
		report += "   - Check console manager initialization order\n"
		report += "   - Verify pentagon_debug_commands.gd is properly loaded\n"
		report += "   - Consider manual command registration\n"
	else:
		report += "   - Registration successful! Commands should be accessible\n"
		report += "   - Test commands in console to verify functionality\n"
	
	print(report)
	registration_diagnostic.emit(report)

# ═══════════════════════════════════════════════════════════════════════════════
# PUBLIC API METHODS
# ═══════════════════════════════════════════════════════════════════════════════


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
func get_registration_status() -> Dictionary:
	"""
	Returns current registration status and diagnostic information
	"""
	return {
		"successful": registration_successful,
		"attempts": registration_attempts,
		"console_manager_found": console_manager != null,
		"pentagon_commands_found": pentagon_commands != null,
		"registered_commands": registered_commands,
		"expected_commands": expected_commands
	}

func force_re_registration() -> void:
	"""
	Force a complete re-registration of all commands
	Useful for debugging or recovery scenarios
	"""
	print("🔄 [EnhancedCommandRegistrar] Forcing complete re-registration...")
	registration_successful = false
	registration_attempts = 0
	registered_commands.clear()
	_start_registration_sequence()

func test_all_commands() -> Dictionary:
	"""
	Test all registered commands and return their status
	"""
	var test_results = {}
	
	for cmd in expected_commands:
		var available = _test_single_command(cmd)
		test_results[cmd] = {
			"available": available,
			"method": registered_commands.get(cmd, "unknown")
		}
	
	return test_results

# ═══════════════════════════════════════════════════════════════════════════════
# INTEGRATION INSTRUCTIONS:
# 
# 1. Add this script to main_game_controller.gd in the _ready() function:
#    ```gdscript
#    # Add enhanced command registrar for Pentagon debug commands
#    var command_registrar = Node.new()
#    command_registrar.name = "EnhancedCommandRegistrar"
#    command_registrar.set_script(load("res://scripts/enhanced_command_registrar.gd"))
#    add_child(command_registrar)
#    
#    # Connect to registration events for monitoring
#    command_registrar.commands_registered.connect(_on_commands_registered)
#    command_registrar.registration_diagnostic.connect(_on_registration_diagnostic)
#    ```
#
# 2. Add these callback methods to main_game_controller.gd:
#    ```gdscript
#    func _on_commands_registered(success: bool) -> void:
#        if success:
#            print("🎯 Pentagon debug commands successfully registered!")
#        else:
#            print("❌ Pentagon debug commands registration failed!")
#
#    func _on_registration_diagnostic(message: String) -> void:
#        print("📊 Command Registration: " + message)
#    ```
#
# 3. Ensure pentagon_debug_commands.gd is added to the scene tree BEFORE this registrar
#
# ═══════════════════════════════════════════════════════════════════════════════