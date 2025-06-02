# Quick Fix Instructions for SystemBootstrap.gd
# 
# Apply these changes to improve initialization:

# 1. Add retry mechanism to load_core_classes():
# Replace the load_core_classes() function with this enhanced version:

func load_core_classes() -> void:
	"""Load core class resources with validation and better error handling"""
	print("🚀 SystemBootstrap: Loading core classes...")
	print("🚀 SystemBootstrap: Checking class paths...")
	
	# Define class paths with fallbacks
	var class_configs = {
		"UniversalBeing": {
			"paths": ["res://core/UniversalBeing.gd"],
			"required": true
		},
		"FloodGates": {
			"paths": ["res://core/FloodGates.gd", "res://systems/FloodGates.gd"],
			"required": true
		},
		"AkashicRecords": {
			"paths": ["res://core/AkashicRecords.gd", "res://systems/AkashicRecords.gd"],
			"required": true
		}
	}
	
	# Load each class with better error handling
	for class_name_key in ["UniversalBeing", "FloodGates", "AkashicRecords"]:
		var config = class_configs[class_name_key]
		var loaded = false
		print("🚀 SystemBootstrap: Loading %s..." % class_name_key)
		
		for path in config.paths:
			print("🚀 SystemBootstrap: Checking path: %s" % path)
			if ResourceLoader.exists(path):
				print("🚀 SystemBootstrap: Path exists, attempting to load...")
				
				# Use ResourceLoader with error checking
				var resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REUSE)
				
				if resource:
					# Additional validation
					if resource is GDScript:
						match class_name_key:
							"UniversalBeing": UniversalBeingClass = resource
							"FloodGates": FloodGatesClass = resource
							"AkashicRecords": AkashicRecordsClass = resource
						print("🚀 SystemBootstrap: ✓ Loaded %s from %s" % [class_name_key, path])
						loaded = true
						break
					else:
						print("🚀 SystemBootstrap: ❌ Resource is not a GDScript: %s" % path)
				else:
					print("🚀 SystemBootstrap: ❌ Failed to load resource from %s" % path)
			else:
				print("🚀 SystemBootstrap: Path does not exist: %s" % path)
		
		if not loaded and config.required:
			var error = "Failed to load required class: " + class_name_key
			initialization_errors.append(error)
			push_error("🚀 SystemBootstrap: " + error)
			print("🚀 SystemBootstrap: ❌ %s" % error)
	
	# Validate all loaded
	if UniversalBeingClass and FloodGatesClass and AkashicRecordsClass:
		core_loaded = true
		print("🚀 SystemBootstrap: ✓ Core classes loaded successfully!")
	else:
		var error = "Core class loading failed - Missing: "
		if not UniversalBeingClass: error += "UniversalBeing "
		if not FloodGatesClass: error += "FloodGates "
		if not AkashicRecordsClass: error += "AkashicRecords"
		system_error.emit(error)
		print("🚀 SystemBootstrap: ❌ %s" % error)

# 2. Add safer instance creation in initialize_systems():
# Replace the instance creation sections with try-catch equivalent:

func initialize_systems() -> void:
	"""Initialize core system instances with better error handling"""
	print("🚀 SystemBootstrap: Starting system initialization...")
	
	if not core_loaded:
		var error = "Cannot initialize - core not loaded"
		push_error("🚀 SystemBootstrap: " + error)
		print("🚀 SystemBootstrap: ❌ %s" % error)
		return
	
	print("🚀 SystemBootstrap: Creating system instances...")
	
	# Create FloodGates instance with error handling
	print("🚀 SystemBootstrap: Creating FloodGates instance...")
	if FloodGatesClass:
		flood_gates_instance = FloodGatesClass.new()
		if flood_gates_instance:
			flood_gates_instance.name = "FloodGates"
			add_child(flood_gates_instance)
			print("🚀 SystemBootstrap: ✓ FloodGates instance created")
		else:
			print("🚀 SystemBootstrap: ❌ Failed to instantiate FloodGates")
	else:
		print("🚀 SystemBootstrap: ❌ FloodGates class not available")
	
	# Create AkashicRecords instance with error handling
	print("🚀 SystemBootstrap: Creating AkashicRecords instance...")
	if AkashicRecordsClass:
		akashic_records_instance = AkashicRecordsClass.new()
		if akashic_records_instance:
			akashic_records_instance.name = "AkashicRecords"
			add_child(akashic_records_instance)
			print("🚀 SystemBootstrap: ✓ AkashicRecords instance created")
		else:
			print("🚀 SystemBootstrap: ❌ Failed to instantiate AkashicRecords")
	else:
		print("🚀 SystemBootstrap: ❌ AkashicRecords class not available")
	
	# Verify all systems ready
	if flood_gates_instance and akashic_records_instance:
		systems_ready = true
		system_ready.emit()
		var boot_time = (Time.get_ticks_msec() - startup_time) / 1000.0
		print("🚀 SystemBootstrap: ✓ Universal Being systems ready!")
		print("🚀 SystemBootstrap: - Boot time: %.2fs" % boot_time)
	else:
		var error = "System initialization incomplete"
		system_error.emit(error)
		print("🚀 SystemBootstrap: ❌ %s" % error)

# 3. Add this helper function for better being creation:

func create_universal_being() -> Node:
	"""Create a new Universal Being instance with error handling"""
	if not UniversalBeingClass:
		push_error("SystemBootstrap: UniversalBeing class not loaded")
		return null
	
	var being = UniversalBeingClass.new()
	if not being:
		push_error("SystemBootstrap: Failed to instantiate UniversalBeing")
		return null
	
	print("SystemBootstrap: Created new Universal Being")
	return being
