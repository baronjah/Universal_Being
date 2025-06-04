# ==================================================
# SCRIPT NAME: gemma_integration_status.gd
# DESCRIPTION: Status checker for Gemma AI integration
# PURPOSE: Verify all systems before running full test
# CREATED: 2025-06-04 - The Validation Hour
# AUTHOR: JSH + Claude Desktop MCP
# ==================================================
extends Node

# Status tracking
var status_results: Dictionary = {}
var all_systems_go: bool = true

func _ready() -> void:
	print("🔍 ==== GEMMA INTEGRATION STATUS CHECK ====")
	print("🔍 Verifying all systems before integration test...")
	print("")
	
	# Run all checks
	check_autoloads()
	check_core_systems()
	check_gemma_systems()
	check_test_files()
	
	# Display results
	display_results()

func check_autoloads() -> void:
	"""Check if required autoloads are present"""
	print("📋 Checking Autoloads...")
	
	var autoloads = {
		"SystemBootstrap": "/root/SystemBootstrap",
		"GemmaAI": "/root/GemmaAI"
	}
	
	for autoload_name in autoloads:
		var path = autoloads[autoload_name]
		if has_node(path):
			var node = get_node(path)
			status_results[autoload_name] = "✅ Found at %s" % path
			
			# Check if SystemBootstrap is ready
			if autoload_name == "SystemBootstrap" and node.has_method("is_system_ready"):
				if node.is_system_ready():
					status_results["SystemBootstrap Ready"] = "✅ Systems initialized"
				else:
					status_results["SystemBootstrap Ready"] = "⚠️ Not ready - waiting..."
					all_systems_go = false
		else:
			status_results[autoload_name] = "❌ Not found at %s" % path
			all_systems_go = false

func check_core_systems() -> void:
	"""Check core Universal Being systems"""
	print("📋 Checking Core Systems...")
	
	var core_files = {
		"UniversalBeing": "res://core/UniversalBeing.gd",
		"FloodGates": "res://core/FloodGates.gd",
		"AkashicRecords": "res://core/AkashicRecords.gd"
	}
	
	for system_name in core_files:
		var path = core_files[system_name]
		if ResourceLoader.exists(path):
			status_results[system_name] = "✅ Script exists at %s" % path
		else:
			status_results[system_name] = "❌ Script missing at %s" % path
			all_systems_go = false

func check_gemma_systems() -> void:
	"""Check Gemma-specific systems"""
	print("📋 Checking Gemma Systems...")
	
	var gemma_files = {
		"GemmaSensorySystem": "res://systems/GemmaSensorySystem.gd",
		"GemmaUniverseInjector": "res://systems/GemmaUniverseInjector.gd",
		"GemmaUniversalBeing": "res://beings/GemmaUniversalBeing.gd",
		"GemmaVision": "res://systems/gemma_components/GemmaVision.gd",
		"GemmaConsoleInterface": "res://systems/gemma_components/GemmaConsoleInterface.gd",
		"GemmaAkashicLogger": "res://systems/gemma_components/GemmaAkashicLogger.gd"
	}
	
	for system_name in gemma_files:
		var path = gemma_files[system_name]
		if ResourceLoader.exists(path):
			status_results[system_name] = "✅ Component ready at %s" % path
		else:
			status_results[system_name] = "❌ Component missing at %s" % path
			all_systems_go = false

func check_test_files() -> void:
	"""Check test files"""
	print("📋 Checking Test Files...")
	
	var test_files = {
		"Integration Test Script": "res://tests/gemma_universe_integration/test_gemma_full_integration.gd",		"Integration Test Scene": "res://tests/gemma_universe_integration/test_gemma_full_integration.tscn",
		"Test Launcher": "res://run_gemma_integration_test.gd"
	}
	
	for test_name in test_files:
		var path = test_files[test_name]
		if ResourceLoader.exists(path):
			status_results[test_name] = "✅ Test ready at %s" % path
		else:
			status_results[test_name] = "❌ Test missing at %s" % path
			all_systems_go = false

func display_results() -> void:
	"""Display all check results"""
	print("\n🔍 ==== STATUS CHECK RESULTS ====")
	
	for check_name in status_results:
		print("  %s: %s" % [check_name, status_results[check_name]])
	
	print("\n🔍 ==== FINAL STATUS ====")
	if all_systems_go:
		print("✅ ALL SYSTEMS GO! Ready for integration test!")
		print("\n🚀 To run the test:")
		print("  1. Open 'run_gemma_integration_test.tscn' in Godot")
		print("  2. Press F6 or click 'Run Current Scene'")
		print("  3. Watch the console for test results")
		print("\n💡 Or press Ctrl+G in main.tscn to test Gemma Console!")
	else:
		print("⚠️ ISSUES DETECTED! Please fix before running test.")
		print("\n🔧 Common fixes:")
		print("  - Ensure project.godot has autoloads configured")
		print("  - Check that all scripts compile without errors")
		print("  - Wait for SystemBootstrap to fully initialize")
		
	print("\n✨ Genesis awaits your command! ✨")
