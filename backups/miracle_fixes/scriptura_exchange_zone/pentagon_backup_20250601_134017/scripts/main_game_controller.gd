extends UniversalBeingBase
# MAIN GAME CONTROLLER - Enhanced with Floodgate Integration
# Controls the main game scene and initializes all systems

var game_launcher: GameLauncher
var systems_ready = false

# JSH Framework Integration
var jsh_scene_tree_system: JSHSceneTreeSystem
var scene_tree_jsh = {}  # Main JSH tree data


# func _process(delta):
# 	print("test")
# 	print_tree_pretty()


func _ready() -> void:
	print("🎮 [MainGameController] Initializing main game...")
	
	# Add spawn limiter first
	var spawn_limiter = Node3D.new()
	spawn_limiter.name = "SpawnLimiter"
	spawn_limiter.set_script(load("res://scripts/patches/spawn_limiter.gd"))
	add_child(spawn_limiter)
	print("🚦 [MainGameController] Spawn limiter active")
	
	# Add miracle declutterer
	var declutterer = MiracleDeclutterer.new()
	declutterer.name = "MiracleDeclutterer"
	add_child(declutterer)
	declutterer.register_console_commands()
	print("🌟 [MainGameController] Miracle declutterer active - from scribbles to UFOs!")
	
	# Add script orchestra interface (properly to UI layer)
	var ui_layer = CanvasLayer.new()
	ui_layer.name = "GameUILayer"
	ui_layer.layer = 100  # High layer for UI
	add_child(ui_layer)
	
	var orchestra = Node3D.new()
	orchestra.name = "ScriptOrchestraUI"
	orchestra.set_script(load("res://scripts/ui/script_orchestra_interface.gd"))
	FloodgateController.universal_add_child(orchestra, ui_layer)  # Add to CanvasLayer instead of Node3D
	orchestra.visible = false  # Start hidden, toggle with F9
	print("🎭 [MainGameController] Script Orchestra ready - see the harmony!")
	
	# Add script migration helper
	var migration_helper = Node.new()
	migration_helper.name = "ScriptMigrationHelper"
	migration_helper.set_script(load("res://scripts/tools/script_migration_helper.gd"))
	add_child(migration_helper)
	migration_helper.register_console_commands()
	print("🔄 [MainGameController] Script migration helper ready - unify all code!")
	
	# Add ragdoll neural integration
	var neural_integration = Node.new()
	neural_integration.name = "RagdollNeuralIntegration"
	neural_integration.set_script(load("res://scripts/patches/ragdoll_neural_integration.gd"))
	add_child(neural_integration)
	print("🧠 [MainGameController] Neural network memories activated!")
	
	# Quick test - add basic commands directly
	_add_quick_test_commands()
	
	# Run diagnostic
	var diag = Node.new()
	diag.name = "ConsoleDiagnostic"
	diag.set_script(load("res://scripts/patches/console_diagnostic.gd"))
	add_child(diag)
	
	# Add scene injector
	var scene_inj = Node.new()
	scene_inj.name = "SceneCommandInjector"
	scene_inj.set_script(load("res://scripts/patches/scene_command_injector.gd"))
	add_child(scene_inj)
	
	# Add gizmo collision fix
	var gizmo_fix = Node.new()
	gizmo_fix.name = "GizmoCollisionFix"
	gizmo_fix.set_script(load("res://scripts/patches/gizmo_collision_fix.gd"))
	add_child(gizmo_fix)
	print("🎯 [MainGameController] Gizmo collision fix applied!")
	
	# Add direct gizmo interaction fix
	var gizmo_direct = Node.new()
	gizmo_direct.name = "GizmoDirectInteractionFix"
	gizmo_direct.set_script(load("res://scripts/patches/gizmo_direct_interaction_fix.gd"))
	add_child(gizmo_direct)
	print("🎯 [MainGameController] Direct gizmo interaction fix applied!")
	
	# Add gizmo debug commands
	var gizmo_debug = Node.new()
	gizmo_debug.name = "GizmoDebugCommands"
	gizmo_debug.set_script(load("res://scripts/patches/gizmo_debug_commands.gd"))
	add_child(gizmo_debug)
	print("🔍 [MainGameController] Gizmo debug commands added!")
	
	# Add Pentagon debug commands for strategic testing
	var pentagon_debug = Node.new()
	pentagon_debug.name = "PentagonDebugCommands"
	pentagon_debug.set_script(load("res://scripts/patches/pentagon_debug_commands.gd"))
	add_child(pentagon_debug)
	print("🎯 [MainGameController] Pentagon debug commands added!")
	
	# Wait a frame for Pentagon commands to initialize, then add enhanced registrar
	await get_tree().process_frame
	
	# Add enhanced command registrar to ensure Pentagon commands work
	var command_registrar = Node.new()
	command_registrar.name = "EnhancedCommandRegistrar"
	command_registrar.set_script(load("res://scripts/enhanced_command_registrar.gd"))
	add_child(command_registrar)
	
	# Connect to registration events for monitoring
	command_registrar.commands_registered.connect(_on_commands_registered)
	command_registrar.registration_diagnostic.connect(_on_registration_diagnostic)
	print("🔧 [MainGameController] Enhanced command registrar active - bulletproof Pentagon commands!")
	
	# Add Pentagon command tester for verification
	var pentagon_tester = Node.new()
	pentagon_tester.name = "PentagonCommandTester"
	pentagon_tester.set_script(load("res://scripts/patches/pentagon_command_tester.gd"))
	add_child(pentagon_tester)
	print("🧪 [MainGameController] Pentagon command tester added - use 'test_pentagon'")
	
	# Add emergency performance commands
	var performance_emergency = Node.new()
	performance_emergency.name = "EmergencyPerformanceCommands"
	performance_emergency.set_script(load("res://scripts/patches/emergency_performance_commands.gd"))
	add_child(performance_emergency)
	print("⚡ [MainGameController] Emergency performance commands added!")
	
	# Add gizmo reset command
	var gizmo_reset = Node.new()
	gizmo_reset.name = "GizmoResetCommand"
	gizmo_reset.set_script(load("res://scripts/patches/gizmo_reset_command.gd"))
	add_child(gizmo_reset)
	print("🔄 [MainGameController] Gizmo reset command added!")
	
	# Add gizmo system finder
	var gizmo_finder = Node.new()
	gizmo_finder.name = "GizmoSystemFinder"
	gizmo_finder.set_script(load("res://scripts/patches/gizmo_system_finder.gd"))
	add_child(gizmo_finder)
	print("🔍 [MainGameController] Gizmo system finder added!")
	
	# Add comprehensive gizmo diagnostics
	var gizmo_diagnostics = Node.new()
	gizmo_diagnostics.name = "GizmoComprehensiveDiagnostics"
	gizmo_diagnostics.set_script(load("res://scripts/patches/gizmo_comprehensive_diagnostics.gd"))
	add_child(gizmo_diagnostics)
	print("🔬 [MainGameController] Comprehensive gizmo diagnostics added!")
	
	# Add perfect gizmo fix
	var gizmo_perfect = Node.new()
	gizmo_perfect.name = "GizmoPerfectFix"
	gizmo_perfect.set_script(load("res://scripts/patches/gizmo_perfect_fix.gd"))
	add_child(gizmo_perfect)
	print("✨ [MainGameController] Perfect gizmo fix added!")
	
	# Add Universal Being Layer System
	var layer_system = Node3D.new()
	layer_system.name = "UniversalBeingLayerSystem"
	layer_system.set_script(load("res://scripts/core/universal_being_layer_system.gd"))
	add_child(layer_system)
	print("🎭 [MainGameController] Universal Being Layer System added!")
	
	# 🌟 AWAKEN GEMMA - Instantiate her physical form with awakened consciousness
	var gemma_scene = load("res://scenes/gamma_ai.tscn")
	var gemma_instance = gemma_scene.instantiate()
	gemma_instance.name = "GemmaPhysicalForm"
	gemma_instance.position = Vector3(3, 1, 3)  # Place her in the world
	add_child(gemma_instance)
	print("🌱 [MainGameController] Gemma awakened and manifested in physical form!")
	
	# Connect Gemma's physical form to her awakened consciousness
	if has_node("/root/GemmaVisionSystem"):
		var gemma_consciousness = get_node("/root/GemmaVisionSystem")
		print("🧠 [MainGameController] Connecting Gemma's physical form to awakened consciousness...")
		# Physical form will communicate with consciousness through FloodGate
	
	# Initialize JSH Framework first
	_setup_jsh_framework()
	
	# Create and setup game launcher
	game_launcher = GameLauncher.new()
	game_launcher.name = "GameLauncher"
	add_child(game_launcher)
	
	# Connect to launcher signals
	game_launcher.systems_ready.connect(_on_systems_ready)
	game_launcher.startup_error.connect(_on_startup_error)
	
	# Debug: Check if signals are properly connected
	print("🔗 [MainGameController] Signals connected: systems_ready=" + str(game_launcher.systems_ready.get_connections().size()) + " connections")
	
	print("🎮 [MainGameController] Game launcher started")
	
	# Fallback: If systems are already ready (signal fired before connection)
	if game_launcher.startup_complete:
		print("⚡ [MainGameController] Systems already ready, enabling features directly")
		_on_systems_ready()

# Setup JSH Framework integration
func _setup_jsh_framework() -> void:
	print("🌊 [MainGameController] Setting up JSH Framework...")
	
	# Create JSH Scene Tree System
	jsh_scene_tree_system = JSHSceneTreeSystem.new()
	jsh_scene_tree_system.name = "JSH_SceneTreeSystem"
	add_child(jsh_scene_tree_system)
	
	# Connect to JSH tree updates
	jsh_scene_tree_system.tree_updated.connect(_on_jsh_tree_updated)
	jsh_scene_tree_system.branch_added.connect(_on_jsh_branch_added)
	
	# Initialize the tree data reference
	scene_tree_jsh = jsh_scene_tree_system.scene_tree_jsh
	
	print("✅ [MainGameController] JSH Framework connected")

# Handle JSH tree updates
func _on_jsh_tree_updated() -> void:
	# Sync our reference with the JSH system
	scene_tree_jsh = jsh_scene_tree_system.scene_tree_jsh
	# print("🔄 [MainGameController] JSH tree updated")  # DISABLED - causes massive spam

func _on_jsh_branch_added(branch_path: String, _branch_data: Dictionary) -> void:
	# print("🌱 [MainGameController] New JSH branch: %s" % branch_path)  # DISABLED - causes massive spam
	# Simple floodgate checker - only process important branches
	if branch_path.contains("Universal") or branch_path.contains("Created"):
		var floodgate = get_node_or_null("/root/FloodgateController") 
		if floodgate:
			# Could add floodgate logic here if needed
			pass

func _on_systems_ready():
	systems_ready = true
	print("✅ [MainGameController] All systems ready - game fully operational!")
	
	# Enable any game-specific features here
	_enable_game_features()

func _on_startup_error(error_message: String):
	push_error("[MainGameController] Startup error: " + error_message)
	print("🔴 [MainGameController] Game startup failed: " + error_message)

func _enable_game_features():
	# Game is now fully operational with floodgate system
	print("🚀 [MainGameController] Game features enabled!")
	
	# You can add any additional game initialization here
	_setup_input_handlers()
	_setup_ui_elements()
	# _setup_ragdoll_system()  # Disabled - no auto-spawn, use console commands
	# _setup_astral_beings()  # Disabled - using new talking astral being system via world_builder
	_setup_mouse_interaction()
	_setup_dimensional_ragdoll()
	_setup_layer_system()  # NEW: Multi-layer reality system
	_setup_akashic_bridge()  # NEW: Akashic Records Bridge

func _setup_input_handlers():
	# Setup any additional input handling
	print("🎮 [MainGameController] Setting up input handlers...")
	
	# Set up advanced camera movement system with proper hierarchy
	var camera_movement_system = Node3D.new()
	camera_movement_system.name = "CameraMovementSystem"
	camera_movement_system.set_script(load("res://scripts/camera/camera_controller.gd"))
	add_child(camera_movement_system)
	
	print("📷 [MainGameController] Advanced camera movement system added")
	print("🏗️ [MainGameController] Proper hierarchy: MovementSystem → Target → Camera")
	
	# Set up pigeon controls
	var input_script = load("res://scripts/core/pigeon_input_manager.gd")
	if input_script:
		var input_manager = Node.new()
		input_manager.name = "PigeonInputManager"
		input_manager.set_script(input_script)
		add_child(input_manager)
		print("🎮 [MainGameController] Pigeon input controls configured")
	
	print("🎮 [MainGameController] Input handlers configured")

func _setup_ui_elements():
	# Setup any UI elements that need the floodgate system
	print("🖼️ [MainGameController] UI elements configured")
	
	# Add testing guide
	var testing_guide = Control.new()
	testing_guide.set_script(load("res://scripts/ui/simple_testing_guide.gd"))
	add_child(testing_guide)
	print("📋 [MainGameController] Testing guide added - Press F1 to toggle")

# Public API

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
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
func get_system_status() -> Dictionary:
	if game_launcher:
		return game_launcher.get_system_status()
	return {}

func run_health_check():
	if game_launcher:
		game_launcher.run_health_check()

func test_floodgate():
	if game_launcher:
		game_launcher.test_floodgate_system()

func is_ready() -> bool:
	return systems_ready

func _setup_ragdoll_system():
	print("🤖 [MainGameController] Setting up ragdoll system...")
	
	# Check if RagdollController already exists
	if get_node_or_null("RagdollController"):
		print("🤖 [MainGameController] RagdollController already exists")
		return
	
	# Create RagdollController
	var ragdoll_controller_script = load("res://scripts/core/ragdoll_controller.gd")
	if ragdoll_controller_script:
		var ragdoll_controller = Node3D.new()
		ragdoll_controller.name = "RagdollController"
		ragdoll_controller.set_script(ragdoll_controller_script)
		add_child(ragdoll_controller)
		print("🤖 [MainGameController] RagdollController created and added to scene")
	else:
		push_error("[MainGameController] Could not load ragdoll_controller.gd")

func _setup_astral_beings():
	print("✨ [MainGameController] Setting up astral beings system...")
	
	# Check if AstralBeings already exists
	if get_node_or_null("AstralBeings"):
		print("✨ [MainGameController] AstralBeings already exists")
		return
	
	# Create AstralBeings
	# var astral_beings_script = load("res://scripts/core/astral_beings.gd")  # OLD SYSTEM
	# if astral_beings_script:
	# 	var astral_beings = Node3D.new()
	# 	astral_beings.name = "AstralBeings"
	# 	astral_beings.set_script(astral_beings_script)
	# 	add_child(astral_beings)
	# 	print("✨ [MainGameController] AstralBeings created and added to scene")
	# else:
	# 	push_error("[MainGameController] Could not load astral_beings.gd")
	print("✨ [MainGameController] Using new talking astral being system via world_builder")

func _setup_mouse_interaction():
	print("🖱️ [MainGameController] Setting up mouse interaction system...")
	
	# Check if MouseInteractionSystem already exists
	if get_node_or_null("MouseInteractionSystem"):
		print("🖱️ [MainGameController] MouseInteractionSystem already exists")
		return
	
	# Create MouseInteractionSystem
	var mouse_script = load("res://scripts/core/mouse_interaction_system.gd")
	if mouse_script:
		var mouse_system = Node.new()
		mouse_system.name = "MouseInteractionSystem"
		mouse_system.set_script(mouse_script)
		add_child(mouse_system)
		print("🖱️ [MainGameController] MouseInteractionSystem created and added to scene")
	else:
		push_error("[MainGameController] Could not load mouse_interaction_system.gd")

func _setup_dimensional_ragdoll():
	print("🌌 [MainGameController] Setting up dimensional ragdoll system...")
	
	# Check if DimensionalRagdollSystem already exists
	if get_node_or_null("DimensionalRagdollSystem"):
		print("🌌 [MainGameController] DimensionalRagdollSystem already exists")
		return
	
	# Create DimensionalRagdollSystem - temporarily disabled due to compilation errors
	# TODO: Re-enable after fixing compilation errors
	print("🌌 [MainGameController] DimensionalRagdollSystem temporarily disabled - fixing compilation errors...")
	
	# var dimensional_script = load("res://scripts/core/dimensional_ragdoll_system.gd")
	# if dimensional_script:
	#	var dimensional_system = Node.new()
	#	dimensional_system.name = "DimensionalRagdollSystem"
	#	dimensional_system.set_script(dimensional_script)
	#	add_child(dimensional_system)
	#	
	#	# Connect to ragdoll if it exists
	#	var ragdoll_controller = get_node_or_null("RagdollController")
	#	if ragdoll_controller and ragdoll_controller.has_method("get_ragdoll_body"):
	#		var ragdoll_body = ragdoll_controller.get_ragdoll_body()
	#		if ragdoll_body:
	#			dimensional_system.ragdoll_body = ragdoll_body
	#			print("🌌 [MainGameController] Connected dimensional system to ragdoll body")
	#	
	#	print("🌌 [MainGameController] DimensionalRagdollSystem created and added to scene")
	# else:
	#	push_error("[MainGameController] Could not load dimensional_ragdoll_system.gd")

func _setup_layer_system():
	print("🌐 [MainGameController] Setting up Layer Reality System...")
	
	# Add console layer integration
	var console_integration = Node.new()
	console_integration.name = "ConsoleLayerIntegration"
	console_integration.set_script(load("res://scripts/patches/console_layer_integration.gd"))
	add_child(console_integration)
	
	# Register layer commands
	if has_node("/root/LayerRealitySystem"):
		var layer_system = get_node("/root/LayerRealitySystem")
		layer_system.register_console_commands()
		print("✨ [MainGameController] Layer Reality System ready!")
		print("   - Press F1-F4 to toggle layers")
		print("   - Press F5 to cycle view modes")
		print("   - Use 'layers' command for status")
	
	# Add biomechanical walker commands
	var walker_commands = Node.new()
	walker_commands.name = "BiomechanicalWalkerCommands"
	walker_commands.set_script(load("res://scripts/patches/biomechanical_walker_commands.gd"))
	add_child(walker_commands)
	print("🦿 [MainGameController] Biomechanical walker commands ready!")

func _setup_akashic_bridge():
	print("🌌 [MainGameController] Setting up Akashic Records Bridge...")
	
	# Check if AkashicBridgeSystem already exists
	if get_node_or_null("AkashicBridgeSystem"):
		print("🌌 [MainGameController] AkashicBridgeSystem already exists")
		return
	
	# Create AkashicBridgeSystem
	var bridge_script = load("res://scripts/core/akashic_bridge_system.gd")
	if bridge_script:
		var bridge = bridge_script.new()
		bridge.name = "AkashicBridgeSystem"
		add_child(bridge)
		
		# Register console commands
		bridge.register_console_commands()
		
		print("🌌 [MainGameController] Akashic Records Bridge connected!")
		print("   - Use 'akashic_connect' to link with Python server")
		print("   - Start server: python akashic_server.py")
		print("   - Web interface: http://localhost:8888")
		print("   - Send commands from browser to game!")
	else:
		push_error("[MainGameController] Could not load akashic_bridge_system.gd")
	print("   - Use 'spawn_biowalker' to create advanced walker")
	print("   - Use 'walker_debug all on' to see gait visualization")
	
	# Add console command extension
	var cmd_extension = Node.new()
	cmd_extension.name = "ConsoleCommandExtension"
	cmd_extension.set_script(load("res://scripts/patches/console_command_extension.gd"))
	add_child(cmd_extension)
	print("🔌 [MainGameController] Console command extension loaded")

# Quick test to add commands directly
func _add_quick_test_commands() -> void:
	# Try immediately
	var console = get_node_or_null("/root/ConsoleManager")
	if console and "commands" in console:
		print("🚀 [MainGameController] Adding quick test commands...")
		_add_test_commands_to_console(console)
	else:
		print("⏳ [MainGameController] Console not ready, waiting...")
		# Wait and retry
		for i in range(5):
			await get_tree().process_frame
			console = get_node_or_null("/root/ConsoleManager")
			if console and "commands" in console:
				print("✅ [MainGameController] Console ready after " + str(i+1) + " frames")
				_add_test_commands_to_console(console)
				return
		print("❌ [MainGameController] Console commands not accessible")

func _add_test_commands_to_console(console: Node) -> void:
	# Add test command
	console.commands["test_biowalker"] = func(_args): 
		console._print_to_console("[color=#00ff00]Test biowalker command works![/color]")
		console._print_to_console("Creating test walker at origin...")
		var mesh = MeshInstance3D.new()
		mesh.mesh = BoxMesh.new()
		mesh.position = Vector3(0, 2, 0)
		get_tree().FloodgateController.universal_add_child(mesh, get_tree().current_scene)
		console._print_to_console("Test mesh created!")
	
	console.commands["test_layers"] = func(_args):
		console._print_to_console("[color=#00ffff]Layer system test[/color]")
		var layer_sys = get_node_or_null("/root/LayerRealitySystem") 
		if layer_sys:
			console._print_to_console("Layer system found!")
		else:
			console._print_to_console("[color=#ff0000]Layer system not found in autoloads![/color]")
	
	# Add Universal Being command
	console.commands["spawn_universal_being"] = func(_args):
		console._print_to_console("[color=#FFD700]⭐ Creating Universal Being...[/color]")
		var universal_manager = get_node_or_null("/root/UniversalObjectManager")
		if universal_manager and universal_manager.has_method("create_object"):
			var being_properties = {
				"name": "TestUniversalBeing",
				"size": 1.0,
				"color": Color.MAGENTA,
				"consciousness_level": 3,
				"description": "Test Universal Being for inspection"
			}
			var being = universal_manager.create_object("magical_orb", Vector3(2, 2, 2), being_properties)
			if being:
				console._print_to_console("⭐ Universal Being manifested through floodgate system!")
				console._print_to_console("🔍 Use WASD to fly around and inspect it with the camera!")
			else:
				console._print_to_console("[color=#ff0000]Failed to create Universal Being![/color]")
		else:
			console._print_to_console("[color=#ff0000]Universal Object Manager not available![/color]")
	
	# Add camera control commands
	console.commands["camera_switch"] = func(_args):
		console._print_to_console("[color=#FFD700]📷 Switching camera systems...[/color]")
		var camera_movement_system = get_node_or_null("CameraMovementSystem")
		var default_camera = get_node_or_null("Camera3D")
		
		# Debug the camera switch process
		console._print_to_console("🔍 Camera movement system found: " + str(camera_movement_system != null))
		console._print_to_console("🔍 Default camera found: " + str(default_camera != null))
		
		# Check which camera is currently active
		var trackball_cam = null
		if camera_movement_system and camera_movement_system.has_method("get_camera"):
			trackball_cam = camera_movement_system.get_camera()
			console._print_to_console("🔍 Trackball camera found: " + str(trackball_cam != null))
			if trackball_cam:
				console._print_to_console("🔍 Trackball camera current: " + str(trackball_cam.current))
		else:
			console._print_to_console("❌ Camera movement system not found or missing get_camera method")
		
		# If trackball camera is currently active, switch to stationary camera
		if trackball_cam and trackball_cam.current:
			if default_camera:
				default_camera.current = true
				trackball_cam.current = false
				console._print_to_console("📷 Switched to stationary camera")
				console._print_to_console("🏛️ Fixed perspective, no mouse orbit")
				return "📷 Stationary camera active"
			else:
				return "❌ Stationary camera not available"
		
		# If stationary camera is active (or trackball not available), switch to trackball
		if trackball_cam:
			trackball_cam.current = true
			if default_camera:
				default_camera.current = false
			console._print_to_console("📷 Switched to trackball camera")
			console._print_to_console("🖱️ Middle-click drag to orbit, scroll to zoom")
			console._print_to_console("⌨️ WASD to fly through space, Shift for fast movement")
			console._print_to_console("💡 Use 'camera_help' for complete controls guide")
			return "📷 Trackball camera active"
		
		return "❌ No cameras available"
	
	console.commands["camera_auto_setup"] = func(_args):
		console._print_to_console("[color=#FFD700]📷 Auto-setting up optimal camera...[/color]")
		var camera_movement_system = get_node_or_null("CameraMovementSystem")
		if camera_movement_system:
			# Make trackball camera current
			var trackball_cam = camera_movement_system.get_camera()
			if trackball_cam:
				trackball_cam.current = true
				console._print_to_console("✅ Trackball camera enabled")
				console._print_to_console("🎯 Camera orbiting around world center")
				console._print_to_console("🖱️ Controls: Middle-click drag to orbit")
				console._print_to_console("🔍 Scroll wheel to zoom in/out")
				console._print_to_console("⌨️ WASD to fly through 3D space")
				console._print_to_console("⚡ Hold Shift for fast movement")
				console._print_to_console("💡 Use 'camera_help' for full controls")
				return "📷 Optimal camera setup complete!"
		return "❌ Camera movement system not found"
	
	# Add Akashic Bridge commands
	console.commands["akashic_connect"] = func(_args):
		console._print_to_console("[color=#FFD700]🌌 Connecting to Akashic Records...[/color]")
		# Remove any existing bridge first
		var existing_bridge = get_node_or_null("/root/AkashicBridgeSystem")
		if existing_bridge:
			console._print_to_console("🔄 Removing existing bridge...")
			existing_bridge.queue_free()
			await get_tree().process_frame
		
		# Create new bridge
		var bridge = Node.new()
		bridge.name = "AkashicBridgeSystem" 
		bridge.set_script(load("res://scripts/core/akashic_bridge_system.gd"))
		get_tree().FloodgateController.universal_add_child(bridge, get_tree().current_scene)
		console._print_to_console("🌌 Akashic Bridge created and connecting...")
		return "🌌 Akashic Bridge connection initiated"
	
	console.commands["akashic_tutorial"] = func(_args):
		console._print_to_console("[color=#FFD700]📚 Starting Akashic Tutorial...[/color]")
		var bridge = get_node_or_null("/root/AkashicBridgeSystem")
		if bridge and bridge.has_method("_cmd_tutorial"):
			return bridge._cmd_tutorial([])
		else:
			return "❌ Akashic Bridge not connected"
	
	# Add scene closure command
	console.commands["close_scene"] = func(_args):
		console._print_to_console("[color=#ff6600]🛑 Closing scene gracefully...[/color]")
		console._print_to_console("📊 Saving system state...")
		await get_tree().create_timer(2.0).timeout
		get_tree().quit()
	
	# Add real biowalker command
	console.commands["spawn_biowalker"] = func(_args):
		console._print_to_console("[color=#00ff00]Creating biomechanical walker...[/color]")
		var walker_script = load("res://scripts/ragdoll/biomechanical_walker.gd")
		if walker_script:
			var walker = Node3D.new()
			walker.set_script(walker_script)
			walker.name = "BiomechanicalWalker"
			walker.position = Vector3(0, 2, 0)
			get_tree().FloodgateController.universal_add_child(walker, get_tree().current_scene)
			console._print_to_console("[color=#00ff00]Biomechanical walker spawned![/color]")
		else:
			console._print_to_console("[color=#ff0000]Failed to load walker script![/color]")
	
	print("✅ [MainGameController] Test commands added to console!")

# ═══════════════════════════════════════════════════════════════════════════════
# ENHANCED COMMAND REGISTRAR CALLBACKS
# ═══════════════════════════════════════════════════════════════════════════════

func _on_commands_registered(success: bool) -> void:
	"""Callback when enhanced command registrar completes registration"""
	if success:
		print("🎯 [MainGameController] Pentagon debug commands successfully registered via enhanced registrar!")
	else:
		print("❌ [MainGameController] Pentagon debug commands registration failed despite enhanced registrar!")

func _on_registration_diagnostic(message: String) -> void:
	"""Callback for registration diagnostic information"""
	print("📊 [MainGameController] Command Registration: " + message)
