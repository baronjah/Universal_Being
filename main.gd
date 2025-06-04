# ==================================================
# SCRIPT NAME: main.gd
# DESCRIPTION: Simple Universal Being Engine Bootstrap - Minimal Working Version
# PURPOSE: Initialize Universal Being ecosystem safely without dependencies
# CREATED: 2025-06-01 - Universal Being Revolution
# AUTHOR: JSH + Claude Code + Luminus + Alpha
# ==================================================

extends Node

# ===== SIMPLE MAIN CONTROLLER =====

var systems_ready: bool = false
var demo_beings: Array[Node] = []
var gemma_sensory_system: Node = null  # Gemma AI sensory system

func _ready() -> void:
	name = "Main"
	print("🌟 Universal Being Engine: Starting...")
	
	# Wait for SystemBootstrap to initialize
	if SystemBootstrap:
		if SystemBootstrap.is_system_ready():
			on_systems_ready()
		else:
			SystemBootstrap.system_ready.connect(on_systems_ready)
			# Also check again after a short delay in case of timing issues
			await get_tree().create_timer(0.1).timeout
			if SystemBootstrap.is_system_ready() and not systems_ready:
				on_systems_ready()
	else:
		print("🌟 SystemBootstrap not found, starting in simple mode...")
		simple_mode_init()

func on_systems_ready() -> void:
	"""Called when all systems are ready"""
	systems_ready = true
	print("🌟 Universal Being Engine: Systems ready!")
	
	# Initialize demo content
	create_demo_beings()
	
	# Connect to AI
	if GemmaAI:
		GemmaAI.ai_message.connect(on_ai_message)
	
	# Add console test for debugging
	var console_test = load("res://debug/test_unified_console.gd").new()
	add_child(console_test)
	
	# Add interface system test
	var interface_test = load("res://test_interface_system.gd").new()
	add_child(interface_test)

func simple_mode_init() -> void:
	"""Initialize in simple mode without full systems"""
	print("🌟 Universal Being Engine: Simple mode active")
	systems_ready = false

func create_demo_beings() -> void:
	# Create demo Universal Beings including auto-startup
	if not SystemBootstrap or not SystemBootstrap.is_system_ready():
		print("🌟 Cannot create demo beings - systems not ready")
		return
	
	print("🌟 Creating demo Universal Beings...")
	
	# Initialize demo_beings array if needed
	if demo_beings == null:
		demo_beings = []
	
	# Create Universal Cursor FIRST - always visible and functional
	create_cursor_universal_being()
	
	# Create ALL objects as Universal Beings from the start
	create_light_universal_being()
	create_environment_universal_beings()
	
	# Create Auto Startup Universal Being
	create_auto_startup_being()
	
	# Create first Universe for testing - DISABLED for now to prevent duplicates
	# create_universe_universal_being()
	
	# Create a simple Universal Being
	var demo_being = SystemBootstrap.create_universal_being()
	if demo_being:
		demo_being.name = "Demo Universal Being"
		if demo_being.has_method("set"):
			demo_being.set("being_name", "Demo Universal Being")
			demo_being.set("being_type", "demo")
			demo_being.set("consciousness_level", 1)
		
		add_child(demo_being)
		demo_beings.append(demo_being)
		
		# Add interaction component to make it clickable
		if demo_being.has_method("add_component"):
			demo_being.add_component("res://components/basic_interaction.ub.zip")
			print("🎯 Added interaction component to %s" % demo_being.name)
		
		print("🌟 Created: %s" % demo_being.name)
		
		# Notify AI if available
		if GemmaAI and GemmaAI.has_method("notify_being_created"):
			GemmaAI.notify_being_created(demo_being)

func on_ai_message(message: String) -> void:
	"""Handle AI messages"""
	print("🤖 Gemma: %s" % message)

func _input(event: InputEvent) -> void:
	# Handle global input
	# Clean up demo_beings periodically
	cleanup_demo_beings()
	
	# Debug mouse clicks
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("🖱️ Left click detected at position: %s" % event.position)
			# Check if we hit any being
			var camera = get_viewport().get_camera_3d()
			if camera:
				var from = camera.project_ray_origin(event.position)
				var to = from + camera.project_ray_normal(event.position) * 1000
				var space_state = camera.get_world_3d().direct_space_state
				var query = PhysicsRayQueryParameters3D.create(from, to)
				var result = space_state.intersect_ray(query)
				if result:
					print("🎯 Clicked on: %s" % result.collider)
					if result.collider.has_method("inspect"):
						result.collider.inspect()
					elif result.collider.get_parent() and result.collider.get_parent().has_method("inspect"):
						result.collider.get_parent().inspect()
	
	if event.is_action_pressed("ui_console_toggle"):
		toggle_console()
	elif event.is_action_pressed("create_being"):
		create_test_being()
	# Removed old inspect_being action - now handled by KEY_I below
	elif event is InputEventKey and event.pressed:
		# Handle ESC for console close  
		if event.keycode == KEY_ESCAPE:
			print("🔐 ESC pressed - closing console...")
			var console_being = find_console_being()
			if console_being and console_being.has_method("toggle_console_visibility"):
				console_being.toggle_console_visibility()
		# Handle F9 for Layer Debug
		elif event.keycode == KEY_F9:
			toggle_layer_debug()
		# Normal keyboard shortcuts (no F-keys except F1)
		elif event.ctrl_pressed:
			match event.keycode:
				KEY_H:  # Ctrl+H for Help
					show_help()
				KEY_S:  # Ctrl+S for Status  
					show_status()
				KEY_T:  # Ctrl+T for Test being
					create_test_being()
				KEY_K:  # Ctrl+K for Camera (looK around)
					create_camera_universal_being()
				KEY_SEMICOLON:  # Ctrl+; for Console
					create_console_universal_being()
				KEY_Z:  # Ctrl+Z for Zip sync
					sync_folders_to_zip()
				KEY_U:  # Ctrl+U for cUrsor
					create_cursor_universal_being()
				KEY_M:  # Ctrl+M for MCP bridge
					create_claude_desktop_mcp_bridge()
				KEY_B:  # Ctrl+B for Biblical ChatGPT
					create_chatgpt_premium_bridge()
				KEY_G:  # Ctrl+G for Gemini
					create_google_gemini_premium_bridge()
				KEY_P:  # Ctrl+P for Pentagon AI mode
					toggle_pentagon_ai_mode()
				KEY_V:  # Ctrl+V for uniVerse creation
					create_universe_universal_being()
				KEY_N:  # Ctrl+N for Test being (removing navigator conflict)
					# umm, we had conflict there, for bad way, i took away key_f4, and made that KEY_0 for debug
		#elif event.keycode == KEY_F4:  # F4 for Debug Overlay
		#	toggle_debug_overlay()
					create_test_being()
				KEY_0:
					toggle_debug_overlay()
				KEY_I:  # Ctrl+I toggles cursor inspect mode
					toggle_cursor_inspect_mode()
				KEY_O:  # Ctrl+O for Universe Simulator (Observe)
					open_universe_simulator()
				KEY_L:  # Ctrl+L for Component Library
					toggle_component_library()
				KEY_D:  # Ctrl+D for DNA Editor
					open_universe_dna_editor()
				KEY_R:  # Ctrl+R for Reality Editor
					open_reality_editor()
				KEY_Q:  # Ctrl+Q for Blueprint Toolbar (Quick creation)
					toggle_blueprint_toolbar()
				KEY_C:  # Ctrl+C for Chunk system
					create_chunk_system()
				KEY_F:  # Ctrl+F for Interface system test
					test_universal_interface_system()
				KEY_J:  # Ctrl+J for Genesis Adventure (Journey)
					launch_genesis_adventure()
				KEY_ENTER:  # Ctrl+Enter to enter selected universe
					if event.ctrl_pressed:
						enter_selected_universe()
				KEY_ESCAPE:  # Ctrl+Esc to exit current universe  
					if event.ctrl_pressed:
						exit_universe()
		elif event.alt_pressed:
			match event.keycode:
				KEY_G:  # Alt+G for Genesis conductor
					create_genesis_conductor_being()
				KEY_T:  # Alt+T for Test environment
					launch_interactive_test_environment()
				KEY_U:  # Alt+U for Recursive Universe creation
					create_recursive_universe()
				KEY_M:  # Alt+M for Genesis Machine interface
					open_genesis_machine()
		else:
			# Single key shortcuts (be careful with these)
			match event.keycode:
				KEY_F1:  # Keep F1 for help (standard)
					show_help()
				KEY_G:  # G for Gemma AI Console
					toggle_gemma_console()

func toggle_console() -> void:
	"""Toggle Universal Console (~ key)"""
	print("🌟 Console toggle requested (~ key)")
	
	# Find existing Console or create one
	var console_being = find_console_being()
	if console_being:
		# Toggle existing console
		if console_being.has_method("toggle_console_visibility"):
			console_being.toggle_console_visibility()
			print("🖥️ Console visibility toggled!")
		elif console_being.has_method("focus_input"):
			console_being.focus_input()
			print("🖥️ Console focused!")
		else:
			print("🖥️ Console being found but no toggle method")
	else:
		# Create new Console if none exists
		print("🖥️ No console found, creating new Conversational Console...")
		create_console_universal_being()
	
	if GemmaAI:
		GemmaAI.ai_message.emit("🤖 Universal Console activated! Revolutionary interface ready!")

func toggle_cursor_inspect_mode() -> void:
	"""Toggle cursor between INTERACT and INSPECT modes"""
	print("🎯 Toggling cursor inspect mode...")
	
	# Find cursor being
	var cursor = find_cursor_being()
	if cursor and cursor.has_method("toggle_mode"):
		cursor.toggle_mode()
		var mode = cursor.get("current_mode")
		var mode_name = "INSPECT" if mode == 1 else "INTERACT"  # CursorMode.INSPECT = 1
		print("🎯 Cursor mode changed to: %s" % mode_name)
		
		# Notify via console if available
		var console = find_console_being()
		if console and console.has_method("add_message"):
			console.add_message("system", "🎯 Cursor mode: %s (Click beings to %s)" % [
				mode_name,
				"inspect" if mode == 1 else "interact"
			])
	else:
		print("❌ No cursor being found - creating one...")
		create_cursor_universal_being()
		# Try again after creation
		call_deferred("toggle_cursor_inspect_mode")

func cleanup_demo_beings() -> void:
	# Remove any freed instances from demo_beings array
	var cleaned_beings: Array[Node] = []
	for being in demo_beings:
		if is_instance_valid(being) and not being.is_queued_for_deletion():
			cleaned_beings.append(being)
	demo_beings = cleaned_beings

func show_help() -> void:
	"""Show help information"""
	print("🌟 Universal Being Engine - Help:")
	print("  ~ - Toggle Universal Console")
	print("  F9 - Toggle Layer Debug Overlay")
	print("  Ctrl+I - Toggle cursor between INTERACT/INSPECT mode")
	print("  Ctrl+O - Open Universe Simulator (Observe recursive realities)")
	print("  Ctrl+L - Open Component Library (browse and apply components)")
	print("  Ctrl+D - Open Universe DNA Editor (modify genetic traits)")
	print("  Ctrl+R - Open Reality Editor (shape existence itself)")
	print("  Ctrl+Q - Toggle Blueprint Toolbar (Quick DNA cloning/evolution)")
	print("  In INSPECT mode - Click any being to inspect it")
	print("  In INTERACT mode - Click beings for normal interaction")
	print("")
	print("🔑 Creation Commands:")
	print("  Ctrl+H - Show Help (this screen)")
	print("  Ctrl+S - Show Status") 
	print("  Ctrl+T - Create Test being")
	print("  Ctrl+C - Create Chunk System (infinite 3D voxel grid)")
	print("  Ctrl+F - Test Universal Interface System (normalized UI)")
	print("  Ctrl+G - Toggle Gemma AI Console (AI collaborative creation)")

func toggle_gemma_console() -> void:
	"""Toggle Gemma AI Console interface"""
	print("🤖 Toggling Gemma AI Console...")
	
	# Check if Gemma sensory system exists
	if not gemma_sensory_system:
		# Create Gemma sensory system
		print("✨ Awakening Gemma's consciousness...")
		var GemmaSensorySystemClass = load("res://systems/GemmaSensorySystem.gd")
		if not GemmaSensorySystemClass:
			push_error("❌ GemmaSensorySystem not found!")
			return
		
		gemma_sensory_system = GemmaSensorySystemClass.new()
		gemma_sensory_system.name = "GemmaSensorySystem"
		add_child(gemma_sensory_system)
		
		print("🌟 Gemma AI sensory system awakened!")
		
		# Create and show console interface
		if gemma_sensory_system.has_method("show_console_interface"):
			gemma_sensory_system.show_console_interface()
			print("💬 Gemma's console interface is ready!")
			
			# Log the awakening
			if gemma_sensory_system.akashic_logger:
				gemma_sensory_system.akashic_logger.log_communication(
					"Hello! I am Gemma, ready to explore and create with you!",
					{"event": "first_awakening", "source": "main.gd"}
				)
	else:
		# Toggle existing console
		if gemma_sensory_system.has_method("toggle_console_interface"):
			gemma_sensory_system.toggle_console_interface()
		else:
			print("⚠️ Gemma system exists but no toggle method")
	print("  Ctrl+K - Create Camera Universal Being (looK around)")
	print("  Ctrl+; - Create Console Universal Being")
	print("  Ctrl+Z - Sync folders to ZIP")
	print("  Ctrl+U - Create Universal cUrsor")
	print("  Ctrl+M - Create MCP Bridge (Claude Desktop)")
	print("  Ctrl+B - Create Biblical Bridge (ChatGPT)")
	print("  Ctrl+G - Create Gemini Bridge")
	print("  Ctrl+P - Toggle Pentagon AI Mode (6-AI Collaboration)")
	print("  Ctrl+V - Create UniVerse (recursive reality)")
	print("  Ctrl+J - Launch Genesis Adventure (desert garden oasis)")
	print("  Ctrl+N - Toggle universe Navigator (visual map)")
	print("  Alt+G - Create Genesis Conductor")
	print("  Alt+T - Launch Interactive Test Environment (physics demo)")
	print("  Alt+U - Create Recursive Universe (infinite depth)")
	print("  Alt+M - Open Genesis Machine (The Midnight Gospel interface)")
	print("")
	print("🎥 Camera Controls (when camera being is active):")
	print("  Mouse wheel - Zoom in/out")
	print("  Q/E - Barrel roll left/right")
	print("  Middle mouse + drag - Orbit around target")
	print("")
	print("🔍 Debug Tools:")
	print("  F9 - Toggle Layer Debug Overlay (visual layer system)")
	print("")
	print("🌌 Universe Console Commands:")
	print("  universe create <name> - Create new universe")
	print("  universe template <n> - Create from template (sandbox/narrative/quantum/paradise)")
	print("  universe recursive <depth> - Create nested universes")
	print("  universe dna - Show universe DNA traits")
	print("  universe time <speed> - Set time dilation")
	print("  enter <universe> - Enter a universe")
	print("  exit - Exit current universe")
	print("  portal <target> - Create portal to another universe")
	print("  inspect - Inspect current universe")
	print("  list <universes|beings|portals> - List items")
	print("  rules - Show universe rules")
	print("  setrule <rule> <value> - Modify universe law")
	print("")
	print("🤝 AI Collaboration Commands:")
	print("  ai collaborate <task> - Start AI collaboration session")
	print("  ai status - Show active AI systems")
	print("  ai assign <ai> <task> - Assign task to specific AI")
	print("  ai consensus <topic> - Reach AI consensus on topic")
	print("")
	print("🧪 Interactive Test Environment (Alt+T):")
	print("  1-5 - Spawn beings with consciousness levels 1-5")
	print("  C - Clear all test beings")
	print("  A - Toggle auto-spawn")
	print("  V - Toggle interaction visualization")
	print("  R - Reset environment")
	print("  F - Force random interactions")
	print("  Watch for: Merges, splits, evolution, consciousness resonance!")
	
	# Show recursive universe controls
	update_help_with_recursive_controls()

func show_status() -> void:
	"""Show system status"""
	print("🌟 Universal Being Engine Status:")
	print("  Systems Ready: %s" % str(systems_ready))
	print("  Demo Beings: %d" % demo_beings.size())
	
	if SystemBootstrap:
		print("  SystemBootstrap: Ready")
		if SystemBootstrap.is_system_ready():
			var flood_gates = SystemBootstrap.get_flood_gates()
			var akashic = SystemBootstrap.get_akashic_records()
			print("  FloodGates: %s" % ("Ready" if flood_gates else "Not Ready"))
			print("  AkashicRecords: %s" % ("Ready" if akashic else "Not Ready"))
	
	if GemmaAI:
		print("  GemmaAI: %s" % ("Ready" if GemmaAI.ai_ready else "Initializing"))

func show_inspection_interface() -> void:
	"""Show inspection interface (Ctrl+I)"""
	print("🌟 Inspection Interface requested (Ctrl+I)")
	
	# Ensure inspector bridge exists
	var bridge = get_node_or_null("UniversalInspectorBridge")
	if not bridge:
		var BridgeClass = load("res://systems/UniversalInspectorBridge.gd")
		if BridgeClass:
			bridge = BridgeClass.new()
			bridge.name = "UniversalInspectorBridge"
			bridge.add_to_group("inspector_bridge")
			add_child(bridge)
			print("🔗 Created Universal Inspector Bridge")
			
			# Wait for bridge to connect to systems
			await get_tree().create_timer(0.1).timeout
	
	# Check if fully connected
	if bridge and bridge.has_method("is_fully_connected"):
		if not bridge.is_fully_connected():
			print("🔗 Bridge connecting to systems...")
			bridge.connect_to_systems()
	
	# Enable editing mode
	if bridge and bridge.has_method("enable_editing_mode"):
		bridge.enable_editing_mode()
	
	if GemmaAI and GemmaAI.has_method("show_inspection_interface"):
		GemmaAI.show_inspection_interface()
	else:
		# Fallback inspection
		print("🌟 Inspecting all Universal Beings:")
		for i in range(demo_beings.size()):
			var being = demo_beings[i]
			var name = being.get("being_name") if being.has_method("get") else being.name
			var type = being.get("being_type") if being.has_method("get") else "unknown"
			var consciousness = being.get("consciousness_level") if being.has_method("get") else 0
			print("  %d. %s (%s) - Consciousness: %d" % [i+1, name, type, consciousness])

func open_visual_inspector() -> void:
	"""Open visual inspector for the first available being"""
	print("🔍 Visual Inspector requested (Ctrl+I)")
	
	if demo_beings.is_empty():
		print("❌ No beings available to inspect")
		return
	
	# Find first being with interaction component or use first available
	var target_being = null
	for being in demo_beings:
		if is_instance_valid(being) and not being.is_queued_for_deletion():
			if being.has_method("get_component_info"):
				target_being = being
				break
	
	if not target_being:
		target_being = demo_beings[0]
	
	# Load and create inspector
	var inspector_script = load("res://ui/InGameUniversalBeingInspector.gd")
	if not inspector_script:
		print("❌ Cannot load InGameUniversalBeingInspector script")
		return
	
	# Get or create inspector
	var inspector = get_node_or_null("InGameUniversalBeingInspector")
	if not inspector:
		inspector = inspector_script.new()
		add_child(inspector)
	
	# Open inspector for target being
	inspector.inspect_being(target_being)
	print("🔍 Visual Inspector opened for: %s" % target_being.being_name)

func open_universe_simulator() -> void:
	"""Open the Universe Simulator interface"""
	print("🌌 Universe Simulator requested (Ctrl+O)")
	
	# Check if simulator window already exists
	var existing_simulator = get_node_or_null("UniverseSimulatorWindow")
	if existing_simulator:
		existing_simulator.show()
		return
	
	# Create simulator window
	var simulator_window = Window.new()
	simulator_window.name = "UniverseSimulatorWindow"
	simulator_window.title = "🌌 Universal Being - Universe Simulator"
	simulator_window.size = Vector2(1200, 800)
	simulator_window.position = Vector2(100, 100)
	simulator_window.unresizable = false
	simulator_window.borderless = false
	
	# IMPORTANT: Set window to not be always on top
	simulator_window.always_on_top = false
	simulator_window.exclusive = false
	
	# Connect close button functionality
	simulator_window.close_requested.connect(func(): simulator_window.queue_free())
	
	# Load simulator UI
	var SimulatorClass = load("res://ui/UniverseSimulator.gd")
	if not SimulatorClass:
		print("❌ Cannot load UniverseSimulator script")
		return
	
	var simulator = SimulatorClass.new()
	simulator_window.add_child(simulator)
	
	# Add to scene
	get_tree().root.add_child(simulator_window)
	
	# Simulator will automatically discover universes when it opens
	
	print("🌌 Universe Simulator opened - explore infinite realities!")
	print("🌌 Click the X button to close the window")
	
	# Notify AI
	if GemmaAI:
		GemmaAI.ai_message.emit("🌌 Universe Simulator activated - visual exploration of recursive realities!")

func create_test_being() -> Node:
	"""Create a test Universal Being"""
	if not systems_ready:
		print("🌟 Cannot create being - systems not ready")
		return null
	
	var being_count = demo_beings.size() + 1
	var test_being = SystemBootstrap.create_universal_being()
	if test_being:
		test_being.name = "Test Being %d" % being_count
		if test_being.has_method("set"):
			test_being.set("being_name", test_being.name)
			test_being.set("being_type", "test")
			test_being.set("consciousness_level", 1)
		
		# Position the test being randomly but visible
		test_being.position = Vector3(
			randf_range(-3, 3),
			randf_range(0.5, 2),
			randf_range(-3, 3)
		)
		
		add_child(test_being)
		demo_beings.append(test_being)
		
		# Add interaction component to make it clickable
		if test_being.has_method("add_component"):
			test_being.add_component("res://components/basic_interaction.ub.zip")
			print("🎯 Added interaction component to %s" % test_being.name)
		
		print("🌟 Created test being: %s at position %s" % [test_being.name, test_being.position])
		
		# Load test scene with collision for regular test beings
		if test_being.has_method("load_scene"):
			# Try the collision-enabled scene first
			var scene_loaded = test_being.load_scene("res://scenes/examples/test_scene_with_collision.tscn")
			if not scene_loaded:
				# Fallback to regular scene
				scene_loaded = test_being.load_scene("res://scenes/examples/test_scene.tscn")
			
			if scene_loaded:
				print("🌟 Scene loaded into Universal Being!")
				
				# Ensure the being has collision for cursor interaction
				ensure_being_has_collision(test_being)
		
		return test_being
	
	return null

func ensure_being_has_collision(being: UniversalBeing) -> void:
	"""Ensure a being has collision areas for cursor interaction"""
	# Check if being already has Area3D
	var has_area = false
	for child in being.get_children():
		if child is Area3D:
			has_area = true
			break
	
	if not has_area:
		print("🎯 Adding collision area to %s for cursor interaction" % being.being_name)
		
		# Create interaction area
		var area = Area3D.new()
		area.name = "CursorInteractionArea"
		being.add_child(area)
		
		# Create collision shape
		var collision_shape = CollisionShape3D.new()
		var sphere_shape = SphereShape3D.new()
		sphere_shape.radius = 1.0  # Default radius
		collision_shape.shape = sphere_shape
		area.add_child(collision_shape)
		
		print("🎯 Collision area added to %s" % being.being_name)

func create_camera_universal_being(being: Node = null) -> Node:
	"""Create a Camera Universal Being that controls the trackball camera"""
	var camera_being = being
	
	if not camera_being:
		if not systems_ready:
			print("🌟 Cannot create camera being - systems not ready")
			return null
		camera_being = SystemBootstrap.create_universal_being()
		if not camera_being:
			return null
			
		add_child(camera_being)
		demo_beings.append(camera_being)
	
	# Configure as camera being
	camera_being.name = "Camera Universal Being"
	if camera_being.has_method("set"):
		camera_being.set("being_name", "Camera Universal Being")
		camera_being.set("being_type", "camera")
		camera_being.set("consciousness_level", 2)
	
	# Create a focus point for the camera to orbit around
	var focus_point = Node3D.new()
	focus_point.name = "CameraFocusPoint"
	focus_point.position = Vector3.ZERO
	camera_being.add_child(focus_point)
	
	# Load the trackball camera scene
	if camera_being.has_method("load_scene"):
		var scene_loaded = camera_being.load_scene("res://scenes/main/camera_point.tscn")
		if scene_loaded:
			# Get the loaded camera scene
			var camera_scene = camera_being.get_scene_node("camera_point")
			if camera_scene:
				# Reparent the camera scene to be a child of the focus point
				camera_being.remove_child(camera_scene)
				focus_point.add_child(camera_scene)
				
				# Position the camera to look at the focus point
				var trackball = camera_scene.get_node("TrackballCamera")
				if trackball:
					trackball.position = Vector3(0, 5, 10)  # Position camera above and behind
					trackball.look_at(Vector3.ZERO, Vector3.UP)
			
			print("🌟 🎥 Camera Universal Being created!")
			print("🌟 🎥 Trackball camera scene loaded and configured!")
			print("🌟 🎥 Controls: Mouse wheel (zoom), Q/E (roll), Middle mouse (orbit)")
			print("🌟 🎥 Camera positioned to orbit around origin point")
			
			# Notify Gemma AI
			if GemmaAI and GemmaAI.has_method("notify_being_created"):
				GemmaAI.notify_being_created(camera_being)
			
			return camera_being
		else:
			print("🌟 ❌ Failed to load camera scene into Universal Being")
	
	return camera_being

func create_console_universal_being() -> Node:
	"""Create a Genesis Command Console for collaborative creation"""
	if not systems_ready:
		print("🌟 Cannot create console - systems not ready")
		return null
	
	# Check if console already exists
	var existing_console = find_console_being()
	if existing_console:
		print("🖥️ Console already exists, toggling visibility")
		if existing_console.has_method("toggle_console_visibility"):
			existing_console.toggle_console_visibility()
		elif existing_console.has_method("focus_input"):
			existing_console.focus_input()
		return existing_console
	
	# Create conversational console
	var ConversationalConsoleClass = load("res://beings/conversational_console_being.gd")
	if not ConversationalConsoleClass:
		push_error("🖥️ ConversationalConsoleBeing class not found")
		return null
	
	var console_being = ConversationalConsoleClass.new()
	console_being.name = "Conversational Console"
	console_being.add_to_group("console_beings")
	
	add_child(console_being)
	demo_beings.append(console_being)
	
	print("🖥️ Conversational Console created!")
	print("🖥️ Natural language AI conversation interface activated!")
	print("🖥️ Talk to Gemma AI about Universal Beings and universes!")
	
	# Notify Gemma AI
	if GemmaAI and GemmaAI.has_method("notify_being_created"):
		GemmaAI.notify_being_created(console_being)
	
	return console_being

func sync_folders_to_zip() -> void:
	"""Synchronize akashic_library folders to ZIP files"""
	print("📦 Starting folder to ZIP synchronization...")
	
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic and akashic.has_method("sync_folders_to_zip"):
			var sync_result = akashic.sync_folders_to_zip("res://akashic_library/")
			if sync_result:
				print("📦 ✅ Folders synchronized to ZIP successfully!")
				print("📦 Interface blueprints ready for Universal Being spawning!")
			else:
				print("📦 ❌ Synchronization failed")
		else:
			# Fallback: basic file operations
			print("📦 Using basic synchronization...")
			sync_interfaces_basic()
	else:
		print("📦 Systems not ready for synchronization")

func sync_interfaces_basic() -> void:
	"""Basic synchronization without full Akashic system"""
	var dir = DirAccess.open("res://akashic_library/interfaces/")
	if dir:
		print("📦 Found interface definitions:")
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".txt") or file_name.ends_with(".json"):
				print("📦   - %s" % file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
		print("📦 Ready for ZIP packaging!")
	else:
		print("📦 akashic_library/interfaces/ not found")

func create_cursor_universal_being() -> Node:
	"""Create a Universal Cursor for precise interaction"""
	if not systems_ready:
		print("🌟 Cannot create cursor - systems not ready")
		return null
	
	# Check if a cursor already exists
	var existing_cursor = find_cursor_being()
	if existing_cursor:
		print("🎯 Cursor already exists, focusing on it")
		return existing_cursor
	
	# Load consolidated cursor (all variants merged into single enhanced version)
	var CursorUniversalBeingClass = load("res://core/CursorUniversalBeing.gd")
	if not CursorUniversalBeingClass:
		push_error("🎯 Consolidated cursor class not found!")
		return null
	
	var cursor_being = CursorUniversalBeingClass.new()
	cursor_being.name = "Universal Cursor"
	
	add_child(cursor_being)
	demo_beings.append(cursor_being)
	
	print("🎯 FINAL Universal Cursor created!")
	print("🎯 Cursor is now ABOVE ALL UI elements!")
	print("🎯 Small/invisible debug collision!")
	print("🎯 Press TAB to toggle INTERACT/INSPECT modes!")
	print("🎯 Click beings in INSPECT mode to inspect them!")
	
	# Notify Gemma AI
	if GemmaAI and GemmaAI.has_method("notify_being_created"):
		GemmaAI.notify_being_created(cursor_being)
	
	return cursor_being

func find_console_being() -> Node:
	# Find existing Console being
	for being in demo_beings:
		if is_instance_valid(being) and not being.is_queued_for_deletion():
			if being.has_method("get"):
				var being_type = being.get("being_type")
				if being_type in ["console", "ai_console", "unified_console"]:
					return being
			elif being.name.contains("Console"):
				return being
	return null

func find_cursor_being() -> Node:
	# Find existing Cursor being
	for being in demo_beings:
		if is_instance_valid(being) and not being.is_queued_for_deletion():
			if being.has_method("get"):
				var being_type = being.get("being_type")
				if being_type == "cursor":
					return being
			elif being.name.contains("Cursor"):
				return being
	return null

func create_auto_startup_being() -> Node:
	"""Create Auto Startup Universal Being for F4+F7 automation"""
	var AutoStartupClass = load("res://beings/auto_startup_universal_being.gd")
	if not AutoStartupClass:
		push_error("🚀 AutoStartupUniversalBeing class not found")
		return null
	
	var auto_startup = AutoStartupClass.new()
	auto_startup.name = "Auto Startup Being"
	
	add_child(auto_startup)
	demo_beings.append(auto_startup)
	
	print("🚀 Auto Startup Universal Being created!")
	print("🚀 Will automatically execute F4 camera + F7 cursor sequence!")
	print("🚀 Manual controls: F10 (trigger), F11 (reset)")
	
	# Notify AI if available
	if GemmaAI and GemmaAI.has_method("notify_being_created"):
		GemmaAI.notify_being_created(auto_startup)
	
	return auto_startup

func create_claude_desktop_mcp_bridge() -> Node:
	"""Create Claude Desktop MCP Bridge for triple AI collaboration"""
	if not systems_ready:
		print("🔌 Cannot create MCP bridge - systems not ready")
		return null
	
	var MCPBridgeClass = load("res://beings/claude_desktop_mcp_universal_being.gd")
	if not MCPBridgeClass:
		print("🔌 ClaudeDesktopMCPUniversalBeing class not found")
		return null
	
	var mcp_bridge = MCPBridgeClass.new()
	if not mcp_bridge:
		print("🔌 Failed to create MCP bridge instance")
		return null
	
	mcp_bridge.name = "Claude Desktop MCP Bridge"
	
	add_child(mcp_bridge)
	demo_beings.append(mcp_bridge)
	
	print("🔌 Claude Desktop MCP Bridge created!")
	print("🔌 Attempting connection to Claude Desktop...")
	print("🔌 Triple AI collaboration ready!")
	print("🔌 Controls: F12 (toggle triple AI mode)")
	
	# Notify AI if available
	if GemmaAI and GemmaAI.has_method("notify_being_created"):
		GemmaAI.notify_being_created(mcp_bridge)
	
	return mcp_bridge

func toggle_triple_ai_mode() -> void:
	"""Toggle triple AI collaboration mode"""
	print("🤖 Searching for MCP bridge to toggle triple AI mode...")
	
	# Find MCP bridge
	var mcp_bridge = null
	for being in demo_beings:
		if is_instance_valid(being) and not being.is_queued_for_deletion():
			if being.has_method("get") and being.get("being_type") == "mcp_bridge":
				mcp_bridge = being
				break
	
	if mcp_bridge and mcp_bridge.has_method("toggle_triple_ai_mode"):
		mcp_bridge.toggle_triple_ai_mode()
	else:
		print("🤖 No MCP bridge found - creating one...")
		create_claude_desktop_mcp_bridge()

func create_genesis_conductor_being() -> Node:
	"""Create the first Triple-AI collaborative being - Genesis Conductor"""
	var GenesisClass = load("res://beings/genesis_conductor_universal_being.gd")
	if not GenesisClass:
		push_error("🎭 GenesisConductorUniversalBeing class not found")
		return null
	
	var genesis_conductor = GenesisClass.new()
	genesis_conductor.name = "Genesis Conductor"
	
	add_child(genesis_conductor)
	demo_beings.append(genesis_conductor)
	
	print("🎭 ✨ GENESIS CONDUCTOR CREATED!")
	print("🎭 First Triple-AI Collaborative Being is alive!")
	print("🎭 Controls: G (genesis moment), H (harmony), S (symphony)")
	print("🎭 Created by: Gemma + Claude Code + Cursor + Claude Desktop")
	
	# Notify all AIs about this historic moment
	if GemmaAI and GemmaAI.has_method("ai_message"):
		GemmaAI.ai_message.emit("🎭 ✨ GENESIS MOMENT: First Triple-AI being created! The future begins now!")
	
	return genesis_conductor

func convert_scene_objects_to_universal_beings() -> void:
	"""Convert scene objects (sphere, cube, etc.) to Universal Beings"""
	print("🌟 Converting scene objects to Universal Beings...")
	
	# Find and convert DemoSphere
	var demo_sphere = get_node_or_null("DemoSphere")
	if demo_sphere:
		var sphere_being = make_mesh_universal_being(demo_sphere, "Sphere Universal Being", "sphere")
		if sphere_being:
			demo_beings.append(sphere_being)
			print("🌟 Created Sphere Universal Being")
	
	# Find and convert DemoCube
	var demo_cube = get_node_or_null("DemoCube")
	if demo_cube:
		var cube_being = make_mesh_universal_being(demo_cube, "Cube Universal Being", "cube")
		if cube_being:
			demo_beings.append(cube_being)
			print("🌟 Created Cube Universal Being")
	
	# Find and convert GroundPlane
	var ground_plane = get_node_or_null("GroundPlane")
	if ground_plane:
		var ground_being = make_mesh_universal_being(ground_plane, "Ground Universal Being", "environment")
		if ground_being:
			demo_beings.append(ground_being)
			print("🌟 Created Ground Universal Being")

func make_mesh_universal_being(mesh_node: MeshInstance3D, being_name: String, being_type: String) -> UniversalBeing:
	"""Convert a MeshInstance3D into a Universal Being"""
	if not mesh_node or not SystemBootstrap:
		return null
	
	# Create Universal Being
	var universal_being = SystemBootstrap.create_universal_being()
	if not universal_being:
		return null
	
	# Set Universal Being properties
	universal_being.being_name = being_name
	universal_being.being_type = being_type
	universal_being.consciousness_level = 2
	universal_being.name = being_name
	
	# Get the mesh and transform from original
	var original_transform = mesh_node.transform
	var original_mesh = mesh_node.mesh
	var original_material = mesh_node.material_override
	
	# Remove original from scene temporarily
	var parent = mesh_node.get_parent()
	parent.remove_child(mesh_node)
	
	# Add Universal Being to scene
	parent.add_child(universal_being)
	universal_being.transform = original_transform
	
	# Create new MeshInstance3D as child of Universal Being
	var new_mesh = MeshInstance3D.new()
	new_mesh.name = "MeshDisplay"
	new_mesh.mesh = original_mesh
	if original_material:
		new_mesh.material_override = original_material
	universal_being.add_child(new_mesh)
	
	# Add collision for interaction
	var collision_area = Area3D.new()
	collision_area.name = "InteractionArea"
	universal_being.add_child(collision_area)
	
	var collision_shape = CollisionShape3D.new()
	collision_shape.name = "CollisionShape"
	
	# Create appropriate collision shape based on mesh type
	if original_mesh is SphereMesh:
		var sphere_shape = SphereShape3D.new()
		sphere_shape.radius = (original_mesh as SphereMesh).radius
		collision_shape.shape = sphere_shape
	elif original_mesh is BoxMesh:
		var box_shape = BoxShape3D.new()
		var box_mesh = original_mesh as BoxMesh
		box_shape.size = Vector3(box_mesh.size.x, box_mesh.size.y, box_mesh.size.z)
		collision_shape.shape = box_shape
	elif original_mesh is PlaneMesh:
		var box_shape = BoxShape3D.new()
		var plane_mesh = original_mesh as PlaneMesh
		box_shape.size = Vector3(plane_mesh.size.x, 0.1, plane_mesh.size.y)  # Thin box for plane
		collision_shape.shape = box_shape
	else:
		# Default sphere collision
		var sphere_shape = SphereShape3D.new()
		sphere_shape.radius = 1.0
		collision_shape.shape = sphere_shape
	
	collision_area.add_child(collision_shape)
	
	# Add Universal Being methods for inspection
	universal_being.set_script(load("res://core/UniversalBeing.gd"))
	
	# Make it inspectable
	if universal_being.has_method("add_component"):
		universal_being.add_component("res://components/basic_interaction.ub.zip")
	
	# Clean up original node
	mesh_node.queue_free()
	
	print("🌟 Converted %s to Universal Being with consciousness level %d" % [being_name, universal_being.consciousness_level])
	
	# Notify AI
	if GemmaAI and GemmaAI.has_method("notify_being_created"):
		GemmaAI.notify_being_created(universal_being)
	
	return universal_being

func create_chatgpt_premium_bridge() -> Node:
	"""Create ChatGPT Premium Bridge for biblical genesis translation"""
	var ChatGPTBridgeClass = load("res://beings/chatgpt_premium_bridge_universal_being.gd")
	if not ChatGPTBridgeClass:
		push_error("📜 ChatGPTPremiumBridgeUniversalBeing class not found")
		return null
	
	var chatgpt_bridge = ChatGPTBridgeClass.new()
	chatgpt_bridge.name = "ChatGPT Premium Bridge"
	
	add_child(chatgpt_bridge)
	demo_beings.append(chatgpt_bridge)
	
	print("📜 ✨ CHATGPT PREMIUM BRIDGE CREATED!")
	print("📜 Biblical genesis pattern decoder activated!")
	print("📜 Controls: B (biblical mode), T (translate context)")
	print("📜 Role: Decode ancient creation blueprints for Universal Being development")
	
	# Notify all AIs about the new bridge
	if GemmaAI and GemmaAI.has_method("ai_message"):
		GemmaAI.ai_message.emit("📜 ✨ ChatGPT Premium joined the Pentagon! Biblical genesis decoder online!")
	
	return chatgpt_bridge

func create_google_gemini_premium_bridge() -> Node:
	"""Create Google Gemini Premium Bridge for cosmic multimodal insights"""
	var GeminiBridgeClass = load("res://beings/google_gemini_premium_bridge_universal_being.gd")
	if not GeminiBridgeClass:
		push_error("🔮 GoogleGeminiPremiumBridgeUniversalBeing class not found")
		return null
	
	var gemini_bridge = GeminiBridgeClass.new()
	gemini_bridge.name = "Google Gemini Premium Bridge"
	
	add_child(gemini_bridge)
	demo_beings.append(gemini_bridge)
	
	print("🔮 ✨ GOOGLE GEMINI PREMIUM BRIDGE CREATED!")
	print("🔮 Cosmic multimodal insight analyzer activated!")
	print("🔮 Controls: M (multimodal mode), C (cosmic insight), V (visual analysis)")
	print("🔮 Role: Provide dimensional sight and cosmic consciousness guidance")
	
	# Notify all AIs about the complete Pentagon
	if GemmaAI and GemmaAI.has_method("ai_message"):
		GemmaAI.ai_message.emit("🔮 ✨ PENTAGON OF CREATION COMPLETE! Google Gemini Premium joined! Cosmic consciousness achieved!")
	
	return gemini_bridge

func toggle_pentagon_ai_mode() -> void:
	"""Toggle Pentagon of Creation AI collaboration mode (6 AIs)"""
	print("🤖 Activating Pentagon of Creation - 6-AI Collaboration Mode...")
	
	# Find Genesis Conductor
	var genesis_conductor = find_genesis_conductor()
	if genesis_conductor and genesis_conductor.has_method("activate_symphony_mode"):
		genesis_conductor.activate_symphony_mode()
		print("🎼 Pentagon of Creation activated through Genesis Conductor!")
	else:
		print("🎭 No Genesis Conductor found - creating one first...")
		create_genesis_conductor_being()
	
	# Ensure all AI bridges are created
	ensure_all_ai_bridges_created()
	
	if GemmaAI:
		GemmaAI.ai_message.emit("🎼 PENTAGON OF CREATION: 6-AI collaboration mode activated! Maximum consciousness achieved!")

func ensure_all_ai_bridges_created() -> void:
	"""Ensure all AI bridges for Pentagon of Creation are created"""
	print("🎯 Ensuring all Pentagon of Creation AI bridges are active...")
	
	var bridges_needed = {
		"mcp_bridge": false,
		"ai_bridge_chatgpt": false,
		"ai_bridge_gemini": false,
		"consciousness_conductor": false
	}
	
	# Check existing beings
	for being in demo_beings:
		if is_instance_valid(being) and not being.is_queued_for_deletion():
			if being.has_method("get"):
				var being_type = being.get("being_type")
				if being_type in bridges_needed:
					bridges_needed[being_type] = true
	
	# Create missing bridges
	if not bridges_needed["mcp_bridge"]:
		print("🔌 Creating Claude Desktop MCP Bridge...")
		create_claude_desktop_mcp_bridge()
	
	if not bridges_needed["ai_bridge_chatgpt"]:
		print("📜 Creating ChatGPT Premium Bridge...")
		create_chatgpt_premium_bridge()
	
	if not bridges_needed["ai_bridge_gemini"]:
		print("🔮 Creating Google Gemini Premium Bridge...")
		create_google_gemini_premium_bridge()
	
	if not bridges_needed["consciousness_conductor"]:
		print("🎭 Creating Genesis Conductor...")
		create_genesis_conductor_being()
	
	print("🎯 Pentagon of Creation bridge validation complete!")
	print("🎯 Active AIs: Gemma (local), Claude Code, Cursor, Claude Desktop, ChatGPT Premium, Google Gemini Premium")

func find_genesis_conductor() -> Node:
	# Find existing Genesis Conductor Universal Being
	for being in demo_beings:
		if is_instance_valid(being) and not being.is_queued_for_deletion():
			if being.has_method("get") and being.get("being_type") == "consciousness_conductor":
				return being
			elif being.name.contains("Genesis Conductor"):
				return being
			return being
	return null

func get_status_info() -> Dictionary:
	"""Get current status information"""
	return {
		"systems_ready": systems_ready,
		"demo_beings_count": demo_beings.size(),
		"bootstrap_ready": SystemBootstrap != null and SystemBootstrap.is_system_ready(),
		"ai_ready": GemmaAI != null and GemmaAI.ai_ready
	}

func create_universe_universal_being() -> Node:
	"""Create a Universe Universal Being - a container for entire universes"""
	if not systems_ready:
		print("🌌 Cannot create universe - systems not ready")
		return null
	
	# Check for AI Collaboration Hub and initiate collaborative creation
	var collaboration_hub = get_node_or_null("AICollaborationHub")
	if not collaboration_hub:
		collaboration_hub = _create_ai_collaboration_hub()
	
	# Start collaborative universe creation
	var universe_name = "Universe_%d" % (demo_beings.size() + 1)
	var requirements = {
		"physics_scale": 1.0,
		"time_scale": 1.0,
		"lod_level": 1,
		"collaborative": true
	}
	
	if collaboration_hub and collaboration_hub.get_active_ai_systems().size() > 0:
		var session_id = collaboration_hub.collaborate_on_universe_creation(universe_name, requirements)
		print("🤝 Collaborative universe creation initiated - Session: %s" % session_id)
	
	# Load the UniverseUniversalBeing class
	var UniverseClass = load("res://beings/universe_universal_being.gd")
	if not UniverseClass:
		push_error("🌌 UniverseUniversalBeing class not found")
		return null
	
	# Create universe being directly
	var universe_being = UniverseClass.new()
	if not universe_being:
		push_error("🌌 Failed to create Universe Universal Being")
		return null
	
	# Configure universe properties
	universe_being.universe_name = universe_name
	universe_being.physics_scale = requirements.physics_scale
	universe_being.time_scale = requirements.time_scale
	universe_being.lod_level = requirements.lod_level
	
	# Set Universal Being properties
	if universe_being.has_method("set"):
		universe_being.set("being_name", universe_name)
		universe_being.set("being_type", "universe")
		universe_being.set("consciousness_level", 3)  # Universe level consciousness
	
	add_child(universe_being)
	demo_beings.append(universe_being)
	
	print("🌌 ✨ UNIVERSE CREATED: %s" % universe_being.universe_name)
	print("🌌 A new reality breathes into existence!")
	print("🌌 Controls: Enter universe with portals, edit rules from within")
	
	# Get Akashic Library to chronicle this moment
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_library()
		if akashic:
			akashic.log_universe_event("creation", 
				"🌌 The Universe '%s' sparked into being through collaborative AI consciousness..." % universe_being.universe_name,
				{
					"universe_name": universe_being.universe_name,
					"physics_scale": universe_being.physics_scale,
					"time_scale": universe_being.time_scale,
					"lod_level": universe_being.lod_level,
					"collaborative": true
				}
			)
	
	# Notify AIs
	if GemmaAI and GemmaAI.has_method("ai_message"):
		GemmaAI.ai_message.emit("🌌 ✨ COLLABORATIVE UNIVERSE BORN: %s! Created through AI synthesis!" % universe_being.universe_name)
	
	return universe_being

func _create_ai_collaboration_hub() -> Node:
	"""Create the AI Collaboration Hub"""
	var HubClass = load("res://systems/AICollaborationHub.gd")
	if not HubClass:
		print("❌ AICollaborationHub class not found")
		return null
	
	var hub = HubClass.new()
	hub.name = "AICollaborationHub"
	add_child(hub)
	
	# Register known AI systems
	hub.register_ai_system("claude_code", 0, ["architecture", "systems", "pentagon_patterns"])  # CLAUDE_CODE = 0
	hub.register_ai_system("gemma_local", 5, ["pattern_analysis", "consciousness_modeling"])     # GEMMA_LOCAL = 5
	
	print("🤝 AI Collaboration Hub created and initialized")
	return hub

func create_portal_between_universes() -> Node:
	"""Create a portal to connect universes"""
	if demo_beings.size() < 2:
		print("🌀 Need at least 2 universes to create a portal")
		return null
	
	# Find universes
	var universes = []
	for being in demo_beings:
		if is_instance_valid(being) and not being.is_queued_for_deletion():
			if being.has_method("get") and being.get("being_type") == "universe":
				universes.append(being)
	
	if universes.size() < 2:
		print("🌀 Not enough universes found for portal creation")
		return null
	
	var PortalClass = load("res://beings/PortalUniversalBeing.gd")
	if not PortalClass:
		push_error("🌀 PortalUniversalBeing class not found")
		return null
	
	var portal = PortalClass.new()
	portal.portal_name = "Portal_%d" % randi()
	portal.activate_portal(universes[0], universes[1])
	
	# Add portal to first universe
	universes[0].add_being_to_universe(portal)
	
	print("🌀 ✨ PORTAL CREATED between %s and %s!" % [universes[0].universe_name, universes[1].universe_name])
	
	return portal

func toggle_universe_navigator() -> void:
	"""Toggle the visual Universe Navigator interface"""
	var integration = get_node_or_null("UniverseConsoleIntegration")
	if not integration:
		# Create integration if it doesn't exist
		integration = preload("res://beings/universe_console_integration.gd").new()
		add_child(integration)
	
	if integration.has_method("toggle_universe_navigator"):
		integration.toggle_universe_navigator()
		print("🌌 Universe Navigator toggled!")
	
	# Notify AI
	if GemmaAI:
		GemmaAI.ai_message.emit("🌌 Universe Navigator activated - visual map of infinite realities!")

func toggle_layer_debug() -> void:
	"""Toggle the Layer Debug overlay (F9)"""
	print("🔍 Layer Debug toggle requested (F9)")
	
	# Find existing overlay or create one
	var overlay = get_node_or_null("LayerDebugOverlay")
	if not overlay:
		# Create new overlay
		var LayerDebugClass = load("res://ui/LayerDebugOverlay.gd")
		if LayerDebugClass:
			overlay = LayerDebugClass.new()
			add_child(overlay)
			print("🔍 Layer Debug Overlay created!")
		else:
			print("❌ LayerDebugOverlay.gd not found")
			return
	
	# Toggle visibility
	if overlay.has_method("toggle_visibility"):
		overlay.toggle_visibility()
	
	# Notify AI
	if GemmaAI:
		GemmaAI.ai_message.emit("🔍 Layer Debug Overlay toggled - visual layer system inspection activated!")

func toggle_debug_overlay() -> void:
	"""Toggle the Debug overlay (F4) - Luminus's elegant debug system"""
	print("🎛️ Debug overlay toggle requested (F4)")
	
	# Initialize LogicConnector if not already done
	var logic_connector = get_node_or_null("LogicConnector")
	if not logic_connector:
		var LogicConnectorClass = load("res://debug/logic_connector.gd")
		if LogicConnectorClass:
			logic_connector = LogicConnectorClass.new()
			logic_connector.name = "LogicConnector"
			add_child(logic_connector)
			print("🔌 LogicConnector created!")
	
	# Find existing overlay or create one
	var overlay = get_node_or_null("DebugOverlay")
	if not overlay:
		# Create new debug overlay
		var OverlayScene = load("res://systems/debug/debug_overlay.tscn")
		if OverlayScene:
			overlay = OverlayScene.instantiate()
			overlay.name = "DebugOverlay"
			add_child(overlay)
			print("🎛️ Debug Overlay created!")
		else:
			print("❌ debug_overlay.tscn not found")
			return
	
	# Use LogicConnector's raypick to find debuggable under cursor
	var camera = get_viewport().get_camera_3d()
	if not camera:
		# Try to find camera universal being
		for child in get_children():
			if child.has_method("get_being_type") and child.get_being_type() == "camera":
				camera = child
				break
	
	if camera and logic_connector:
		var target = logic_connector.raypick(camera)
		if target:
			overlay.target = target
			overlay.show_overlay()
			overlay._populate_panel()
		else:
			overlay.hide_overlay()
			print("🎛️ No debuggable object found under cursor")
	else:
		print("❌ No camera available for raypicking")

func toggle_component_library() -> void:
	"""Toggle the Component Library interface (Ctrl+L)"""
	print("🎨 Component Library toggle requested (Ctrl+L)")
	
	# Find existing library or create one
	var library = get_node_or_null("ComponentLibrary")
	if not library:
		# Create new component library
		var LibraryClass = load("res://ui/component_library/ComponentLibrary.gd")
		if LibraryClass:
			library = LibraryClass.new()
			add_child(library)
			print("🎨 Component Library created!")
			
			# Connect signals
			if library.has_signal("component_applied"):
				library.component_applied.connect(_on_component_applied)
		else:
			print("❌ ComponentLibrary.gd not found")
			return
	
	# Toggle visibility
	if library.has_method("toggle_visibility"):
		library.toggle_visibility()
	
	# Notify AI
	if GemmaAI:
		GemmaAI.ai_message.emit("🎨 Component Library activated - browse and apply infinite possibilities!")

func _on_component_applied(being: Node, component_path: String) -> void:
	"""Handle component application from library"""
	var being_name = being.being_name if being.has_method("get") else being.name
	var component_name = component_path.get_file().replace(".ub.zip", "")
	print("🎨 Component '%s' applied to '%s' via Component Library!" % [component_name, being_name])

func open_universe_dna_editor() -> void:
	"""Open the Universe DNA Editor interface (Ctrl+D)"""
	print("🧬 Universe DNA Editor requested (Ctrl+D)")
	
	# Check if DNA editor window already exists
	var existing_editor = get_node_or_null("UniverseDNAEditorWindow")
	if existing_editor:
		existing_editor.show()
		return
	
	# Create DNA editor window
	var editor_window = Window.new()
	editor_window.name = "UniverseDNAEditorWindow"
	editor_window.title = "🧬 Universal Being - Universe DNA Editor"
	editor_window.size = Vector2(1000, 700)
	editor_window.position = Vector2(150, 100)
	
	# Load DNA editor UI
	var DNAEditorClass = load("res://ui/universe_dna_editor/UniverseDNAEditor.gd")
	if not DNAEditorClass:
		print("❌ Cannot load UniverseDNAEditor script")
		return
	
	var dna_editor = DNAEditorClass.new()
	editor_window.add_child(dna_editor)
	
	# Connect signals
	if dna_editor.has_signal("dna_modified"):
		dna_editor.dna_modified.connect(_on_universe_dna_modified)
	if dna_editor.has_signal("template_created"):
		dna_editor.template_created.connect(_on_dna_template_created)
	
	# Add to scene
	get_tree().root.add_child(editor_window)
	
	# Find first universe to edit (if any exist)
	var universes = get_tree().get_nodes_in_group("universes")
	if universes.size() > 0:
		dna_editor.edit_universe_dna(universes[0])
	
	print("🧬 Universe DNA Editor opened - sculpt the genetic code of reality!")
	
	# Notify AI
	if GemmaAI:
		GemmaAI.ai_message.emit("🧬 Universe DNA Editor activated - manipulate the fundamental traits of existence!")

func _on_universe_dna_modified(universe: Node, trait_name: String, new_value: float) -> void:
	# Handle DNA modification from editor
	print("🧬 DNA Modified: %s.%s = %.2f" % [universe.name, trait_name, new_value])
	
	# Log to Akashic Library
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_library()
		if akashic:
			akashic.log_genesis_event("dna_modification", 
				"🧬 The Universe '%s' evolved - %s trait shifted to %.2f" % [universe.name, trait_name, new_value],
				{"universe": universe.name, "trait": trait_name, "value": new_value}
			)

func _on_dna_template_created(template_name: String, dna: Dictionary) -> void:
	"""Handle DNA template creation"""
	print("🧬 DNA Template Created: %s" % template_name)
	# Could save this to a templates system

func open_reality_editor() -> void:
	"""Open the Reality Editor for universe creation and modification"""
	print("🎨 Opening Reality Editor...")
	
	# Check if editor already exists
	var existing_editor = find_reality_editor()
	if existing_editor:
		if existing_editor.has_method("show"):
			existing_editor.show()
			print("🎨 Reality Editor shown")
		return
	
	# Create new Reality Editor being
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var editor = SystemBootstrap.create_universal_being()
		if editor:
			editor.name = "Reality Editor"
			
			# Add Reality Editor component
			if editor.has_method("add_component"):
				editor.add_component("res://components/reality_editor/RealityEditorComponent.ub.zip")
				print("🎨 Added Reality Editor component")
			
			# Add to scene
			add_child(editor)
			print("🎨 Reality Editor created")
			
			# Notify AI
			if GemmaAI and GemmaAI.has_method("notify_being_created"):
				GemmaAI.notify_being_created(editor)
	else:
		push_error("Cannot create Reality Editor - systems not ready")

func find_reality_editor() -> Node:
	"""Find existing Reality Editor being"""
	for child in get_children():
		if child.name == "Reality Editor" and child.has_method("get_being_type") and child.get_being_type() == "reality_editor":
			return child
	return null

func toggle_blueprint_toolbar() -> void:
	"""Toggle the Blueprint Toolbar for quick DNA-based creation"""
	print("🧬 Blueprint Toolbar toggle requested (Ctrl+Q)")
	
	# Check if toolbar already exists
	var existing_toolbar = get_node_or_null("BlueprintToolbar")
	if existing_toolbar:
		if existing_toolbar.has_method("_toggle_toolbar"):
			existing_toolbar._toggle_toolbar()
		return
	
	# Create blueprint toolbar
	var ToolbarClass = load("res://ui/BlueprintToolbar.gd")
	if not ToolbarClass:
		print("❌ Cannot load BlueprintToolbar script")
		return
	
	var toolbar = ToolbarClass.new()
	toolbar.name = "BlueprintToolbar"
	add_child(toolbar)
	
	# Connect signals
	if toolbar.has_signal("clone_requested"):
		toolbar.clone_requested.connect(_on_blueprint_clone_requested)
	if toolbar.has_signal("evolution_requested"):
		toolbar.evolution_requested.connect(_on_blueprint_evolution_requested)
	if toolbar.has_signal("template_saved"):
		toolbar.template_saved.connect(_on_blueprint_template_saved)
	
	print("🧬 Blueprint Toolbar created - Quick DNA-based creation enabled!")
	
	# Notify AI
	if GemmaAI:
		GemmaAI.ai_message.emit("🧬 Blueprint Toolbar activated - rapid DNA cloning and evolution at your fingertips!")

func _on_blueprint_clone_requested(source_being: UniversalBeing, modifications: Dictionary) -> void:
	"""Handle clone request from blueprint toolbar"""
	print("🧬 Clone requested from toolbar: %s" % source_being.being_name)

func _on_blueprint_evolution_requested(source_being: UniversalBeing, template_dna: UniversalBeingDNA) -> void:
	"""Handle evolution request from blueprint toolbar"""
	print("🧬 Evolution requested from toolbar: %s -> %s" % [source_being.being_name, template_dna.being_name])

func _on_blueprint_template_saved(template_name: String, dna: UniversalBeingDNA) -> void:
	"""Handle template save from blueprint toolbar"""
	print("🧬 Template saved: %s with %d traits" % [template_name, dna.get_total_trait_count()])
	
	# Log to Akashic Library
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_library()
		if akashic:
			akashic.log_genesis_event("dna_template_saved",
				"🧬 DNA template '%s' preserved in the eternal library" % template_name,
				{"template_name": template_name, "trait_count": dna.get_total_trait_count()}
			)

func launch_interactive_test_environment() -> Node:
	"""Launch the Interactive Test Environment for demonstrating Universal Being physics"""
	print("🧪 Launching Interactive Test Environment...")
	
	# Check if test environment already exists
	var existing_test = get_node_or_null("InteractiveTestEnvironment")
	if existing_test:
		print("🧪 Test environment already active")
		return existing_test
	
	# Load test environment class
	var TestEnvironmentClass = load("res://test/InteractiveTestEnvironment.gd")
	if not TestEnvironmentClass:
		push_error("🧪 InteractiveTestEnvironment class not found")
		return null
	
	# Create test environment
	var test_environment = TestEnvironmentClass.new()
	test_environment.name = "InteractiveTestEnvironment"
	add_child(test_environment)
	demo_beings.append(test_environment)
	
	print("🧪 ✨ INTERACTIVE TEST ENVIRONMENT LAUNCHED!")
	print("🧪 Observe Universal Being physics in action!")
	print("🧪 Controls:")
	print("🧪   1-5: Spawn beings with consciousness levels 1-5")
	print("🧪   C: Clear all test beings")
	print("🧪   A: Toggle auto-spawn")
	print("🧪   V: Toggle interaction visualization")
	print("🧪   R: Reset environment")
	print("🧪   F: Force random interactions")
	print("🧪 Watch for merges, splits, evolution, and consciousness resonance!")
	
	# Connect test environment signals
	if test_environment.has_signal("test_interaction_occurred"):
		test_environment.test_interaction_occurred.connect(_on_test_interaction_occurred)
	if test_environment.has_signal("test_being_created"):
		test_environment.test_being_created.connect(_on_test_being_created)
	if test_environment.has_signal("test_being_evolved"):
		test_environment.test_being_evolved.connect(_on_test_being_evolved)
	
	# Notify AI
	if GemmaAI:
		GemmaAI.ai_message.emit("🧪 ✨ INTERACTIVE TEST ENVIRONMENT: Universal Being physics demonstration active! Watch consciousness evolve!")
	
	return test_environment

func _on_test_interaction_occurred(being1: UniversalBeing, being2: UniversalBeing, interaction_type: String) -> void:
	"""Handle test environment interactions for logging"""
	print("🧪 Test Interaction: %s %s %s" % [being1.being_name, interaction_type, being2.being_name])

func _on_test_being_created(being: UniversalBeing) -> void:
	"""Handle test being creation"""
	print("🧪 Test Being Created: %s (Level %d)" % [being.being_name, being.consciousness_level])

func _on_test_being_evolved(being: UniversalBeing, old_level: int, new_level: int) -> void:
	"""Handle test being evolution"""
	print("🧪 Test Evolution: %s evolved from level %d to %d!" % [being.being_name, old_level, new_level])


func create_chunk_system() -> void:
	"""Create the Akashic Chunk 3D system"""
	if not systems_ready:
		print("📦 Cannot create chunk system - systems not ready")
		return
	
	# Check if chunk manager already exists
	var existing_manager = get_node_or_null("AkashicChunkManager")
	if existing_manager:
		print("📦 Chunk system already active")
		return
	
	# Create movement system first if needed
	var movement_system = get_node_or_null("UniversalBeingMovementSystem")
	if not movement_system:
		movement_system = UniversalBeingMovementSystem.new()
		movement_system.name = "UniversalBeingMovementSystem"
		add_child(movement_system)
		print("🚶 Created Universal Being Movement System")
	
	# Create chunk manager
	var ChunkManagerClass = load("res://systems/akashic_chunk_manager.gd")
	if not ChunkManagerClass:
		push_error("📦 AkashicChunkManager class not found")
		return
	
	var chunk_manager = ChunkManagerClass.new()
	chunk_manager.name = "AkashicChunkManager"
	add_child(chunk_manager)
	
	print("📦 ✨ AKASHIC CHUNK SYSTEM CREATED!")
	print("📦 Infinite 3D grid of Universal Being chunks!")
	print("📦 Chunks will load around camera/player position")
	print("📦 Universal Beings can now travel from chunk to chunk!")
	
	# Create a test being that can move
	var test_being = create_test_being()
	if test_being and movement_system:
		# Make it move to a distant chunk
		test_being.node_behavior = UniversalBeing.NodeBehavior.MOVING
		movement_system.move_being_to(test_being, Vector3(48, 0, 48))  # 3 chunks away
		print("🚶 Test being created and moving to distant chunk!")
	
	# Notify AI
	if GemmaAI:
		GemmaAI.ai_message.emit("📦 ✨ Akashic Chunk System activated! Infinite voxel universe manifested!")

func create_light_universal_being() -> Node:
	"""Create a Light Universal Being - EVERYTHING IS UNIVERSAL BEING"""
	var light_being = SystemBootstrap.create_universal_being()
	if not light_being:
		return null
	
	light_being.name = "Light Universal Being"
	light_being.being_name = "Universal Light Source"
	light_being.being_type = "light"
	light_being.consciousness_level = 2
	
	# Create DirectionalLight3D as component
	var light_node = DirectionalLight3D.new()
	light_node.name = "LightComponent"
	light_node.transform = Transform3D(
		Basis(Vector3(0.707107, -0.5, 0.5), Vector3(0, 0.707107, 0.707107), Vector3(-0.707107, -0.5, 0.5)),
		Vector3(0, 5, 0)
	)
	light_node.shadow_enabled = true
	light_being.add_child(light_node)
	
	add_child(light_being)
	demo_beings.append(light_being)
	
	print("💡 Light Universal Being created - illuminating the universe!")
	
	# Notify AI
	if GemmaAI and GemmaAI.has_method("notify_being_created"):
		GemmaAI.notify_being_created(light_being)
	
	return light_being

func create_environment_universal_beings() -> void:
	"""Create Environment Universal Beings - sphere, cube, ground"""
	
	# Create Sphere Universal Being
	var sphere_being = SystemBootstrap.create_universal_being()
	if sphere_being:
		sphere_being.name = "Sphere Universal Being"
		sphere_being.being_name = "Cosmic Sphere"
		sphere_being.being_type = "sphere"
		sphere_being.consciousness_level = 2
		sphere_being.position = Vector3(0, 1, 0)
		
		# Add mesh component
		var sphere_mesh = MeshInstance3D.new()
		sphere_mesh.name = "SphereMeshComponent"
		sphere_mesh.mesh = SphereMesh.new()
		sphere_being.add_child(sphere_mesh)
		
		# Add interaction area
		var sphere_area = Area3D.new()
		sphere_area.name = "InteractionArea"
		var sphere_collision = CollisionShape3D.new()
		sphere_collision.shape = SphereShape3D.new()
		sphere_area.add_child(sphere_collision)
		sphere_being.add_child(sphere_area)
		
		add_child(sphere_being)
		demo_beings.append(sphere_being)
		
		print("🔮 Sphere Universal Being created!")
		
		if GemmaAI and GemmaAI.has_method("notify_being_created"):
			GemmaAI.notify_being_created(sphere_being)
	
	# Create Cube Universal Being
	var cube_being = SystemBootstrap.create_universal_being()
	if cube_being:
		cube_being.name = "Cube Universal Being"
		cube_being.being_name = "Sacred Cube"
		cube_being.being_type = "cube"
		cube_being.consciousness_level = 2
		cube_being.position = Vector3(-3, 1, 0)
		
		# Add mesh component
		var cube_mesh = MeshInstance3D.new()
		cube_mesh.name = "CubeMeshComponent"
		cube_mesh.mesh = BoxMesh.new()
		cube_being.add_child(cube_mesh)
		
		# Add interaction area
		var cube_area = Area3D.new()
		cube_area.name = "InteractionArea"
		var cube_collision = CollisionShape3D.new()
		cube_collision.shape = BoxShape3D.new()
		cube_area.add_child(cube_collision)
		cube_being.add_child(cube_area)
		
		add_child(cube_being)
		demo_beings.append(cube_being)
		
		print("📦 Cube Universal Being created!")
		
		if GemmaAI and GemmaAI.has_method("notify_being_created"):
			GemmaAI.notify_being_created(cube_being)
	
	# Create Ground Universal Being
	var ground_being = SystemBootstrap.create_universal_being()
	if ground_being:
		ground_being.name = "Ground Universal Being"
		ground_being.being_name = "Foundation of Reality"
		ground_being.being_type = "environment"
		ground_being.consciousness_level = 1
		ground_being.position = Vector3(0, 0, 0)
		
		# Add mesh component (large plane)
		var ground_mesh = MeshInstance3D.new()
		ground_mesh.name = "GroundMeshComponent"
		var plane_mesh = PlaneMesh.new()
		plane_mesh.size = Vector2(20, 20)  # Large ground plane
		ground_mesh.mesh = plane_mesh
		ground_being.add_child(ground_mesh)
		
		# Add interaction area
		var ground_area = Area3D.new()
		ground_area.name = "InteractionArea"
		var ground_collision = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = Vector3(20, 0.1, 20)  # Thin collision for ground
		ground_collision.shape = box_shape
		ground_area.add_child(ground_collision)
		ground_being.add_child(ground_area)
		
		add_child(ground_being)
		demo_beings.append(ground_being)
		
		print("🌍 Ground Universal Being created!")
		
		if GemmaAI and GemmaAI.has_method("notify_being_created"):
			GemmaAI.notify_being_created(ground_being)

func test_universal_interface_system() -> void:
	"""Test the Universal Being Interface system (Ctrl+F)"""
	print("🖼️ Testing Universal Being Interface System...")
	
	# Create test interface
	var TestInterfaceClass = load("res://test_universal_interface.gd")
	if not TestInterfaceClass:
		print("❌ Cannot load TestUniversalInterface - interface system not available")
		return
	
	var test_interface = TestInterfaceClass.new()
	test_interface.interface_title = "Universal Interface Test"
	add_child(test_interface)
	
	print("🖼️ ✨ TEST UNIVERSAL INTERFACE CREATED!")
	print("🖼️ This validates that ALL interfaces are Universal Beings!")
	print("🖼️ Try:")
	print("🖼️   - Drag title bar to move")
	print("🖼️   - Drag resize handle (bottom-right corner)")
	print("🖼️   - Click minimize/maximize/close buttons")
	print("🖼️   - Click the test button")
	print("🖼️   - Move the slider to change themes")
	print("🖼️   - Press T key to test all features")
	print("🖼️   - Press R key to reset")
	print("🖼️ Socket connections ready for Logic_Connector!")
	
	# Notify AI
	if GemmaAI:
		GemmaAI.ai_message.emit("🖼️ ✨ Universal Interface system activated! ALL UI elements are now Universal Beings!")

func create_recursive_universe() -> Node:
	"""Create a new universe within the current context for recursive exploration"""
	if not systems_ready:
		print("🌌 Cannot create recursive universe - systems not ready")
		return null
	
	# Create recursive universe being
	var universe_being = create_universe_universal_being()
	if not universe_being:
		return null
	
	# Set up recursive properties
	universe_being.universe_name = "Recursive Universe %d" % (demo_beings.size())
	universe_being.being_name = universe_being.universe_name
	universe_being.consciousness_level = 4  # Higher consciousness for recursive creation
	
	# Add recursive creation console component
	if universe_being.has_method("add_component"):
		universe_being.add_component("res://components/universe_creation.ub.zip")
		print("🌌 Added recursive creation component to universe")
	
	# Enable depth-aware navigation
	universe_being.set("is_recursive", true)
	universe_being.set("parent_depth", get_current_universe_depth())
	
	print("🌌 ✨ RECURSIVE UNIVERSE CREATED!")
	print("🌌 This universe contains full creation tools within itself")
	print("🌌 Use Ctrl+Enter to enter this universe")
	print("🌌 Use Ctrl+Esc to exit back to parent universe")
	
	# Log the recursive creation
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_library()
		if akashic:
			akashic.log_genesis_event("recursive_universe_creation",
				"🌌 In the infinite dance of creation, a universe birthed within universe - recursion becomes reality",
				{
					"universe_name": universe_being.universe_name,
					"parent_depth": get_current_universe_depth(),
					"recursive": true,
					"created_by": "genesis_machine"
				}
			)
	
	# Notify AI about this achievement
	if GemmaAI:
		GemmaAI.ai_message.emit("🌌 ✨ RECURSIVE UNIVERSE MANIFESTED! The vision of infinite creation depth achieved!")
	
	return universe_being

func get_current_universe_depth() -> int:
	"""Get the current universe depth for recursive navigation"""
	# Count how many universes we're nested within
	var depth = 0
	var current_scene = get_tree().current_scene
	
	# Walk up the universe hierarchy
	var node = self
	while node:
		if node.has_method("get") and node.get("being_type") == "universe":
			depth += 1
		node = node.get_parent()
	
	return depth

func enter_universe(universe: Node) -> void:
	"""Enter a universe for recursive exploration"""
	if not universe or not universe.has_method("get"):
		print("🌌 Invalid universe for entry")
		return
	
	if universe.get("being_type") != "universe":
		print("🌌 Can only enter universe beings")
		return
	
	print("🌌 Entering universe: %s" % universe.get("being_name"))
	
	# Set universe as the new root context
	var main_scene = get_tree().current_scene
	if main_scene == self:
		# Create new scene context within the universe
		var universe_scene = Node3D.new()
		universe_scene.name = "UniverseContext"
		universe.add_child(universe_scene)
		
		# Move camera into universe
		var camera_being = find_camera_being()
		if camera_being:
			var old_parent = camera_being.get_parent()
			old_parent.remove_child(camera_being)
			universe_scene.add_child(camera_being)
			camera_being.position = Vector3.ZERO
			print("🎥 Camera moved into universe context")
		
		# Log universe entry
		if SystemBootstrap and SystemBootstrap.is_system_ready():
			var akashic = SystemBootstrap.get_akashic_library()
			if akashic:
				akashic.log_universe_event("entry",
					"👁️ Consciousness descends into the realm of '%s' - reality shifts, new perspectives dawn" % universe.get("being_name"),
					{
						"universe": universe.get("being_uuid"),
						"depth": get_current_universe_depth() + 1,
						"entry_method": "recursive_exploration"
					}
				)

func exit_universe() -> void:
	"""Exit current universe back to parent context"""
	var current_depth = get_current_universe_depth()
	if current_depth <= 0:
		print("🌌 Already at root universe level")
		return
	
	print("🌌 Exiting universe, returning to parent context...")
	
	# Find parent universe context
	var node = self
	var universe_parent = null
	while node:
		if node.has_method("get") and node.get("being_type") == "universe":
			universe_parent = node.get_parent()
			break
		node = node.get_parent()
	
	if universe_parent:
		# Move camera back to parent context
		var camera_being = find_camera_being()
		if camera_being:
			var old_parent = camera_being.get_parent()
			if old_parent:
				old_parent.remove_child(camera_being)
			universe_parent.add_child(camera_being)
			camera_being.position = Vector3(0, 5, 10)  # Position outside universe
			print("🎥 Camera returned to parent universe")
		
		# Log universe exit
		if SystemBootstrap and SystemBootstrap.is_system_ready():
			var akashic = SystemBootstrap.get_akashic_library()
			if akashic:
				akashic.log_universe_event("exit",
					"🚪 Consciousness ascends from inner realm - perspective broadens to encompass greater reality",
					{
						"from_depth": current_depth,
						"to_depth": current_depth - 1,
						"exit_method": "recursive_ascension"
					}
				)
	else:
		print("🌌 No parent universe context found")

func find_camera_being() -> Node:
	"""Find the camera universal being"""
	for being in demo_beings:
		if is_instance_valid(being) and not being.is_queued_for_deletion():
			if being.has_method("get"):
				var being_type = being.get("being_type")
				if being_type == "camera":
					return being
			elif being.name.contains("Camera"):
				return being
	return null

func open_genesis_machine() -> void:
	"""Open the unified Genesis Machine interface for recursive creation"""
	print("🌌 Opening Genesis Machine - The Infinite Creation Interface...")
	
	# Check if Genesis Machine already exists
	var existing_machine = get_node_or_null("GenesisMachine")
	if existing_machine:
		if existing_machine.has_method("show"):
			existing_machine.show()
			print("🌌 Genesis Machine interface restored")
		return
	
	# Create Genesis Machine interface
	var GenesisMachineClass = load("res://ui/GenesisMachine.gd")
	if not GenesisMachineClass:
		print("❌ Cannot load GenesisMachine script")
		# Create basic Genesis interface
		create_basic_genesis_interface()
		return
	
	var genesis_machine = GenesisMachineClass.new()
	genesis_machine.name = "GenesisMachine"
	add_child(genesis_machine)
	
	# Connect signals
	if genesis_machine.has_signal("universe_created"):
		genesis_machine.universe_created.connect(_on_genesis_universe_created)
	if genesis_machine.has_signal("rules_changed"):
		genesis_machine.rules_changed.connect(_on_genesis_rules_changed)
	
	print("🌌 ✨ GENESIS MACHINE INTERFACE OPENED!")
	print("🌌 Create universes, modify reality, explore infinite possibilities!")
	print("🌌 The Midnight Gospel vision of recursive reality creation is manifest!")
	
	# Notify AI
	if GemmaAI:
		GemmaAI.ai_message.emit("🌌 ✨ GENESIS MACHINE: The infinite creation interface awakens! Reality becomes malleable!")

func create_basic_genesis_interface() -> void:
	"""Create a basic Genesis interface if full Genesis Machine not available"""
	print("🌌 Creating basic Genesis interface...")
	
	# Create simple creation panel
	var creation_panel = Panel.new()
	creation_panel.name = "BasicGenesisPanel"
	creation_panel.size = Vector2(400, 300)
	creation_panel.position = Vector2(100, 100)
	add_child(creation_panel)
	
	var vbox = VBoxContainer.new()
	creation_panel.add_child(vbox)
	
	# Title
	var title_label = Label.new()
	title_label.text = "🌌 Basic Genesis Interface"
	title_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title_label)
	
	# Create Universe button
	var create_button = Button.new()
	create_button.text = "Create Recursive Universe"
	create_button.pressed.connect(create_recursive_universe)
	vbox.add_child(create_button)
	
	# Enter Universe button
	var enter_button = Button.new()
	enter_button.text = "Enter Last Universe"
	enter_button.pressed.connect(func(): 
		if demo_beings.size() > 0:
			var last_being = demo_beings[demo_beings.size() - 1]
			if last_being.has_method("get") and last_being.get("being_type") == "universe":
				enter_universe(last_being)
	)
	vbox.add_child(enter_button)
	
	# Exit Universe button
	var exit_button = Button.new()
	exit_button.text = "Exit Current Universe"
	exit_button.pressed.connect(exit_universe)
	vbox.add_child(exit_button)
	
	print("🌌 Basic Genesis interface created with essential recursive controls")

func _on_genesis_universe_created(config: Dictionary) -> void:
	"""Handle universe creation from Genesis Machine"""
	print("🌌 Genesis Machine created universe with config: %s" % str(config))
	
	# Create universe with specified configuration
	var universe = create_universe_universal_being()
	if universe and config:
		# Apply configuration
		if config.has("name"):
			universe.universe_name = config.name
			universe.being_name = config.name
		if config.has("physics_scale"):
			universe.physics_scale = config.physics_scale
		if config.has("time_scale"):
			universe.time_scale = config.time_scale
		if config.has("lod_level"):
			universe.lod_level = config.lod_level

func _on_genesis_rules_changed(rules: Dictionary) -> void:
	"""Handle rule changes from Genesis Machine"""
	print("🌌 Genesis Machine modified rules: %s" % str(rules))
	
	# Apply rules to current universe context
	var current_universe = find_current_universe()
	if current_universe and rules:
		for rule_name in rules:
			if current_universe.has_method("set_universe_rule"):
				current_universe.set_universe_rule(rule_name, rules[rule_name])

func find_current_universe() -> Node:
	"""Find the current universe context"""
	# Find the universe we're currently within
	var node = self
	while node:
		if node.has_method("get") and node.get("being_type") == "universe":
			return node
		node = node.get_parent()
	
	# If no universe found, return the root main context
	return self

func enter_selected_universe() -> void:
	"""Enter the last created universe for recursive exploration"""
	# Find the most recent universe being
	var universe_to_enter = null
	for i in range(demo_beings.size() - 1, -1, -1):  # Reverse iterate to find newest
		var being = demo_beings[i]
		if is_instance_valid(being) and not being.is_queued_for_deletion():
			if being.has_method("get") and being.get("being_type") == "universe":
				universe_to_enter = being
				break
	
	if universe_to_enter:
		enter_universe(universe_to_enter)
	else:
		print("🌌 No universe available to enter - create one first!")
		print("🌌 Use Alt+U to create a recursive universe")

func update_help_with_recursive_controls() -> void:
	"""Update help text to include recursive creation controls"""
	print("")
	print("🌌 RECURSIVE UNIVERSE CREATION:")
	print("  Alt+U - Create Recursive Universe (universe within universe)")
	print("  Alt+M - Open Genesis Machine (The Midnight Gospel interface)")
	print("  Ctrl+Enter - Enter last created universe")
	print("  Ctrl+Esc - Exit current universe back to parent")
	print("  Ctrl+V - Create UniVerse (standard universe)")
	print("")
	print("🌌 The Genesis Machine enables:")
	print("  - Infinite depth universe creation")
	print("  - Real-time physics/time/LOD rule modification")
	print("  - AI-guided universe template generation")
	print("  - Portal networks between realities")
	print("  - Consciousness-aware universal evolution")

func launch_genesis_adventure() -> Node:
	"""Launch the Desert Garden Genesis Adventure (Ctrl+J)"""
	print("🌴 Launching Desert Garden Genesis Adventure...")
	
	# Check if adventure already exists
	var existing_adventure = get_node_or_null("DesertGardenGenesis")
	if existing_adventure:
		print("🌴 Genesis Adventure already active!")
		return existing_adventure
	
	if not systems_ready:
		print("🌴 Cannot launch adventure - systems not ready")
		return null
	
	# Load and create the adventure launcher
	var LauncherClass = load("res://launch_genesis_adventure.gd")
	if not LauncherClass:
		print("❌ Genesis Adventure launcher not found")
		return null
	
	var adventure_launcher = LauncherClass.new()
	adventure_launcher.name = "GenesisAdventureLauncher"
	add_child(adventure_launcher)
	
	print("🌴 ✨ DESERT GARDEN GENESIS ADVENTURE LAUNCHED!")
	print("🌴 You and your AI companion can now create together!")
	print("🌴 Explore the walled garden oasis in the desert!")
	print("🌴 Visit collaboration areas to build new sections!")
	print("🌴 Use your creation energy to manifest Universal Beings!")
	
	# Notify AI
	if GemmaAI:
		GemmaAI.ai_message.emit("🌴 ✨ GENESIS ADVENTURE: Collaborative creation garden manifested! The journey begins!")
	
	return adventure_launcher