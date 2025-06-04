# Quick health check for foundation improvements
extends Node

func _ready() -> void:
	print("🏥 Quick Foundation Health Check")
	print("🏥 ================================")
	
	# Test critical paths that were just fixed
	var critical_paths = [
		"res://core/CursorUniversalBeing.gd",  # Consolidated cursor
		"res://debug/logic_connector.gd",      # Enhanced LogicConnector  
		"res://systems/LogicConnectorSystem.gd", # New system
		"res://core/PentagonManager.gd",        # New system
		"res://autoloads/SystemBootstrap.gd"   # Core system
	]
	
	var working_paths = 0
	for path in critical_paths:
		if ResourceLoader.exists(path):
			var script = load(path)
			if script:
				print("✅ %s" % path)
				working_paths += 1
			else:
				print("❌ %s (failed to load)" % path)
		else:
			print("❌ %s (not found)" % path)
	
	var health_percentage = (working_paths / float(critical_paths.size())) * 100
	print("🏥 ================================")
	print("🏥 Critical Path Health: %.1f%% (%d/%d)" % [health_percentage, working_paths, critical_paths.size()])
	
	# Test SystemBootstrap access
	if SystemBootstrap:
		print("✅ SystemBootstrap autoload accessible")
		if SystemBootstrap.is_system_ready():
			print("✅ SystemBootstrap systems ready")
		else:
			print("⏳ SystemBootstrap systems initializing...")
	else:
		print("❌ SystemBootstrap autoload not accessible")
	
	# Test new systems instantiation
	print("🏥 Testing new systems...")
	
	# Test LogicConnectorSystem
	var logic_system_script = load("res://systems/LogicConnectorSystem.gd")
	if logic_system_script:
		var logic_system = logic_system_script.new()
		if logic_system:
			print("✅ LogicConnectorSystem instantiation working")
			logic_system.queue_free()
		else:
			print("❌ LogicConnectorSystem instantiation failed")
	
	# Test PentagonManager
	var pentagon_script = load("res://core/PentagonManager.gd")
	if pentagon_script:
		var pentagon_manager = pentagon_script.new()
		if pentagon_manager:
			print("✅ PentagonManager instantiation working")
			pentagon_manager.queue_free()
		else:
			print("❌ PentagonManager instantiation failed")
	
	print("🏥 Quick health check complete!")
	
	# Exit after test
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()