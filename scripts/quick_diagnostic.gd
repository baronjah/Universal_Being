extends Node

# Quick diagnostic - paste this into a new script and run it

func _ready() -> void:
	print("\n🔍 === QUICK DIAGNOSTIC ===")
	
	# Check files exist
	print("\n📁 File Check:")
	check_file("res://core/UniversalBeing.gd")
	check_file("res://core/FloodGates.gd") 
	check_file("res://core/AkashicRecords.gd")
	check_file("res://autoloads/SystemBootstrap.gd")
	
	# Try loading classes
	print("\n📦 Load Test:")
	test_load("res://core/UniversalBeing.gd", "UniversalBeing")
	test_load("res://core/FloodGates.gd", "FloodGates")
	test_load("res://core/AkashicRecords.gd", "AkashicRecords")
	
	# Check SystemBootstrap
	print("\n🚀 SystemBootstrap Check:")
	if SystemBootstrap:
		print("✅ SystemBootstrap exists")
		print("   Ready: %s" % SystemBootstrap.is_system_ready())
		var status = SystemBootstrap.get_system_status()
		print("   Core Loaded: %s" % status.core_loaded)
		print("   Errors: %d" % status.errors.size())
		for err in status.errors:
			print("   ❌ %s" % err)
	else:
		print("❌ SystemBootstrap not found!")
	
	print("\n🔍 === END DIAGNOSTIC ===\n")

func check_file(path: String) -> void:
	if ResourceLoader.exists(path):
		print("✅ %s exists" % path)
	else:
		print("❌ %s NOT FOUND" % path)

func test_load(path: String, expected_class: String) -> void:
	var resource = load(path)
	if resource:
		print("✅ %s loaded successfully" % expected_class)
		if resource is GDScript:
			print("   Type: GDScript ✓")
		else:
			print("   Type: %s ⚠️" % resource.get_class())
	else:
		print("❌ %s failed to load!" % expected_class)
