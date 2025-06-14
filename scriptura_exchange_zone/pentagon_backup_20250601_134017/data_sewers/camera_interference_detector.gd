extends SceneTree

# Detects what's interfering with camera movement system
func _ready():
	print("🔍 [InterferenceDetector] Analyzing camera movement interference...")
	
	var root = Node3D.new()
	root.name = "TestRoot"
	current_scene = root
	
	# Create camera system
	var camera_system = Node3D.new()
	camera_system.name = "CameraMovementSystem"
	camera_system.set_script(load("res://scripts/camera/camera_controller.gd"))
	root.add_child(camera_system)
	
	await process_frame
	await process_frame
	
	print("🔍 [InterferenceDetector] Camera system created, analyzing interference patterns...")
	
	# Test 1: Check for LOD system interference
	print("🔍 [InterferenceDetector] Test 1: Checking LOD system...")
	check_lod_interference()
	
	# Test 2: Check for UniversalEntity interference
	print("🔍 [InterferenceDetector] Test 2: Checking UniversalEntity interference...")
	check_universal_entity_interference()
	
	# Test 3: Check for performance optimization interference
	print("🔍 [InterferenceDetector] Test 3: Checking performance optimizations...")
	check_performance_interference()
	
	# Test 4: Check for input system conflicts
	print("🔍 [InterferenceDetector] Test 4: Checking input system conflicts...")
	check_input_conflicts()
	
	# Test 5: Check Pentagon system compliance
	print("🔍 [InterferenceDetector] Test 5: Checking Pentagon system compliance...")
	check_pentagon_compliance()
	
	print("🔍 [InterferenceDetector] Analysis complete!")
	quit()

func check_lod_interference():
	# Look for LOD-related scripts that might disable systems at distance
	var lod_scripts = []
	if ResourceLoader.exists("res://scripts/core/lod_manager.gd"):
		lod_scripts.append("LOD Manager found")
	if ResourceLoader.exists("res://scripts/performance/distance_optimizer.gd"):
		lod_scripts.append("Distance Optimizer found")
	
	if lod_scripts.size() > 0:
		print("⚠️ [InterferenceDetector] LOD systems detected: " + str(lod_scripts))
		print("💡 [InterferenceDetector] LOD systems may disable input at distance")
	else:
		print("✅ [InterferenceDetector] No obvious LOD interference")

func check_universal_entity_interference():
	# Check if UniversalEntity has performance optimizations that affect input
	if ResourceLoader.exists("res://scripts/core/universal_entity.gd"):
		print("⚠️ [InterferenceDetector] UniversalEntity system found")
		print("💡 [InterferenceDetector] Check for performance optimizations in UniversalEntity")
		print("💡 [InterferenceDetector] Look for distance-based input disabling")
	else:
		print("✅ [InterferenceDetector] UniversalEntity not interfering")

func check_performance_interference():
	# Check for performance systems that might disable input
	var performance_scripts = []
	if ResourceLoader.exists("res://scripts/core/performance_guardian.gd"):
		performance_scripts.append("Performance Guardian")
	if ResourceLoader.exists("res://scripts/core/delta_guardian.gd"):
		performance_scripts.append("Delta Guardian")
	if ResourceLoader.exists("res://scripts/autoload/perfect_delta_process.gd"):
		performance_scripts.append("Perfect Delta Process")
	
	if performance_scripts.size() > 0:
		print("⚠️ [InterferenceDetector] Performance systems: " + str(performance_scripts))
		print("💡 [InterferenceDetector] These may disable input during optimization")
	else:
		print("✅ [InterferenceDetector] No performance interference detected")

func check_input_conflicts():
	# Check for other input systems that might conflict
	var input_scripts = []
	if ResourceLoader.exists("res://scripts/autoload/perfect_input.gd"):
		input_scripts.append("Perfect Input")
	if ResourceLoader.exists("res://scripts/core/divine_input.gd"):
		input_scripts.append("Divine Input")
	if ResourceLoader.exists("res://scripts/ui/mouse_interaction.gd"):
		input_scripts.append("Mouse Interaction")
	
	if input_scripts.size() > 0:
		print("⚠️ [InterferenceDetector] Input systems: " + str(input_scripts))
		print("💡 [InterferenceDetector] Multiple input systems may conflict")
	else:
		print("✅ [InterferenceDetector] No input conflicts detected")

func check_pentagon_compliance():
	print("🔍 [InterferenceDetector] Pentagon Architecture Analysis:")
	print("📋 [InterferenceDetector] Pentagon phases: Init → Ready → Input → Logic → Sewers")
	
	# Check if camera system follows Pentagon pattern
	var camera_script = load("res://scripts/camera/camera_controller.gd")
	if camera_script:
		var source = camera_script.source_code
		var has_init = "PERFECT INIT" in source or "_init(" in source
		var has_ready = "_ready(" in source
		var has_input = "_input(" in source or "_handle_movement_input" in source
		var has_process = "_process(" in source
		
		print("📊 [InterferenceDetector] Camera Pentagon compliance:")
		print("  Init: " + str(has_init))
		print("  Ready: " + str(has_ready))
		print("  Input: " + str(has_input))
		print("  Process: " + str(has_process))
		
		if not (has_init and has_ready and has_input and has_process):
			print("⚠️ [InterferenceDetector] Camera system not fully Pentagon compliant!")
		else:
			print("✅ [InterferenceDetector] Camera system Pentagon compliant")
	
	print("💡 [InterferenceDetector] Recommendation: Check all autoload scripts for Pentagon compliance")