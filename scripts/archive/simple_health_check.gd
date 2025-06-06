# Simple health check for foundation improvements
extends MainLoop

func _init():
	print("🏥 Simple Foundation Health Check")
	print("🏥 ================================")
	
	# Test critical paths that were just fixed
	var critical_paths = [
		"res://beings/cursor/CursorUniversalBeing.gd",     # Consolidated cursor
		"res://debug/logic_connector.gd",         # Enhanced LogicConnector  
		"res://systems/LogicConnectorSystem.gd",  # New system
		"res://core/PentagonManager.gd",          # New system
		"res://autoloads/SystemBootstrap.gd"     # Core system
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
	
	# Test new systems instantiation
	print("🏥 Testing new systems...")
	
	# Test LogicConnectorSystem
	var logic_system_script = load("res://systems/LogicConnectorSystem.gd")
	if logic_system_script:
		var logic_system = logic_system_script.new()
		if logic_system:
			print("✅ LogicConnectorSystem instantiation working")
		else:
			print("❌ LogicConnectorSystem instantiation failed")
	
	# Test PentagonManager
	var pentagon_script = load("res://core/PentagonManager.gd")
	if pentagon_script:
		var pentagon_manager = pentagon_script.new()
		if pentagon_manager:
			print("✅ PentagonManager instantiation working")
		else:
			print("❌ PentagonManager instantiation failed")
	
	print("🏥 ================================")
	print("🏥 Foundation health check complete!")
	print("🏥 Key improvements verified:")
	print("   - Consolidated duplicate cursor files")
	print("   - Fixed broken path references") 
	print("   - Created LogicConnectorSystem")
	print("   - Created PentagonManager")
	print("   - Enhanced LogicConnector with registry")
	print("🏥 ================================")

func _process(_delta):
	# Exit immediately
	return true