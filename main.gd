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

func simple_mode_init() -> void:
	"""Initialize in simple mode without full systems"""
	print("🌟 Universal Being Engine: Simple mode active")
	systems_ready = false

func create_demo_beings() -> void:
	"""Create demo Universal Beings including auto-startup"""
	if not SystemBootstrap or not SystemBootstrap.is_system_ready():
		print("🌟 Cannot create demo beings - systems not ready")
		return
	
	print("🌟 Creating demo Universal Beings...")
	
	# Create Auto Startup Universal Being first
	create_auto_startup_being()
	
	# Create first Universe for testing
	create_universe_universal_being()
	
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
	"""Handle global input"""
	if event.is_action_pressed("ui_console_toggle"):
		toggle_console()
	elif event.is_action_pressed("create_being"):
		create_test_being()
	# Removed old inspect_being action - now handled by KEY_I below
	elif event is InputEventKey and event.pressed:
		# Handle F9 for Layer Debug
		if event.keycode == KEY_F9:
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
				KEY_N:  # Ctrl+N for universe Navigator
					toggle_universe_navigator()
				KEY_I:  # Ctrl+I for Visual Inspector
					open_visual_inspector()
				KEY_O:  # Ctrl+O for Universe Simulator (Observe)
					open_universe_simulator()
		elif event.alt_pressed:
			match event.keycode:
				KEY_G:  # Alt+G for Genesis conductor
					create_genesis_conductor_being()
		else:
			# Single key shortcuts (be careful with these)
			match event.keycode:
				KEY_F1:  # Keep F1 for help (standard)
					show_help()

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

func show_help() -> void:
	"""Show help information"""
	print("🌟 Universal Being Engine - Help:")
	print("  ~ - Toggle Universal Console")
	print("  F9 - Toggle Layer Debug Overlay")
	print("  Ctrl+I - Open Visual Inspector (click beings to inspect)")
	print("  Ctrl+O - Open Universe Simulator (Observe recursive realities)")
	print("  Click beings - Open Inspector for that being")
	print("")
	print("🔑 Creation Commands:")
	print("  Ctrl+H - Show Help (this screen)")
	print("  Ctrl+S - Show Status") 
	print("  Ctrl+T - Create Test being")
	print("  Ctrl+K - Create Camera Universal Being (looK around)")
	print("  Ctrl+; - Create Console Universal Being")
	print("  Ctrl+Z - Sync folders to ZIP")
	print("  Ctrl+U - Create Universal cUrsor")
	print("  Ctrl+M - Create MCP Bridge (Claude Desktop)")
	print("  Ctrl+B - Create Biblical Bridge (ChatGPT)")
	print("  Ctrl+G - Create Gemini Bridge")
	print("  Ctrl+P - Toggle Pentagon AI Mode (6-AI Collaboration)")
	print("  Ctrl+V - Create UniVerse (recursive reality)")
	print("  Ctrl+N - Toggle universe Navigator (visual map)")
	print("  Alt+G - Create Genesis Conductor")
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
	
	# Load simulator UI
	var SimulatorClass = load("res://ui/universe_simulator/UniverseSimulator.gd")
	if not SimulatorClass:
		print("❌ Cannot load UniverseSimulator script")
		return
	
	var simulator = SimulatorClass.new()
	simulator_window.add_child(simulator)
	
	# Add to scene
	get_tree().root.add_child(simulator_window)
	
	# Load first universe if available
	for being in demo_beings:
		if being is UniverseUniversalBeing:
			simulator.load_universe(being)
			break
	
	print("🌌 Universe Simulator opened - explore infinite realities!")
	
	# Notify AI
	if GemmaAI:
		GemmaAI.ai_message.emit("🌌 Universe Simulator activated - visual exploration of recursive realities!")

func create_test_being() -> void:
	"""Create a test Universal Being"""
	if not systems_ready:
		print("🌟 Cannot create being - systems not ready")
		return
	
	var being_count = demo_beings.size() + 1
	var test_being = SystemBootstrap.create_universal_being()
	if test_being:
		test_being.name = "Test Being %d" % being_count
		if test_being.has_method("set"):
			test_being.set("being_name", test_being.name)
			test_being.set("being_type", "test")
			test_being.set("consciousness_level", 1)
		
		add_child(test_being)
		demo_beings.append(test_being)
		
		# Add interaction component to make it clickable
		if test_being.has_method("add_component"):
			test_being.add_component("res://components/basic_interaction.ub.zip")
			print("🎯 Added interaction component to %s" % test_being.name)
		
		print("🌟 Created test being: %s" % test_being.name)
		
		# Load test scene for regular test beings
		if test_being.has_method("load_scene"):
			var scene_loaded = test_being.load_scene("res://scenes/examples/test_scene.tscn")
			if scene_loaded:
				print("🌟 Scene loaded into Universal Being!")

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
	
	# Load the trackball camera scene
	if camera_being.has_method("load_scene"):
		var scene_loaded = camera_being.load_scene("res://scenes/main/camera_point.tscn")
		if scene_loaded:
			print("🌟 🎥 Camera Universal Being created!")
			print("🌟 🎥 Trackball camera scene loaded and controlled!")
			print("🌟 🎥 Controls: Mouse wheel (zoom), Q/E (roll), Middle mouse (orbit)")
			
			# Notify Gemma AI
			if GemmaAI and GemmaAI.has_method("notify_being_created"):
				GemmaAI.notify_being_created(camera_being)
			
			return camera_being
		else:
			print("🌟 ❌ Failed to load camera scene into Universal Being")
	
	return camera_being

func create_console_universal_being() -> Node:
	"""Create a Unified Console with universe command integration"""
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
	
	# Load cursor class
	var CursorUniversalBeingClass = load("res://core/CursorUniversalBeing.gd")
	if not CursorUniversalBeingClass:
		push_error("🎯 CursorUniversalBeing class not found")
		return null
	
	var cursor_being = CursorUniversalBeingClass.new()
	cursor_being.name = "Universal Cursor"
	
	add_child(cursor_being)
	demo_beings.append(cursor_being)
	
	print("🎯 Universal Cursor created!")
	print("🎯 Triangle cursor with sphere collision activated!")
	print("🎯 Precise interaction for 2D/3D interfaces enabled!")
	
	# Notify Gemma AI
	if GemmaAI and GemmaAI.has_method("notify_being_created"):
		GemmaAI.notify_being_created(cursor_being)
	
	return cursor_being

func find_console_being() -> Node:
	"""Find existing Console being"""
	for being in demo_beings:
		if being.has_method("get"):
			var being_type = being.get("being_type")
			if being_type in ["console", "ai_console", "unified_console"]:
				return being
		elif being.name.contains("Console"):
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
	"""Find existing Genesis Conductor Universal Being"""
	for being in demo_beings:
		if being.has_method("get") and being.get("being_type") == "consciousness_conductor":
			return being
		elif being.name.contains("Genesis Conductor"):
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
	universe_being.universe_name = "Universe_%d" % (demo_beings.size() + 1)
	universe_being.physics_scale = 1.0
	universe_being.time_scale = 1.0
	universe_being.lod_level = 1
	
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
				"🌌 The Universe '%s' sparked into being, infinite potential awakening..." % universe_being.universe_name,
				{
					"universe_name": universe_being.universe_name,
					"physics_scale": universe_being.physics_scale,
					"time_scale": universe_being.time_scale,
					"lod_level": universe_being.lod_level
				}
			)
	
	# Notify AIs
	if GemmaAI and GemmaAI.has_method("ai_message"):
		GemmaAI.ai_message.emit("🌌 ✨ NEW UNIVERSE BORN: %s! A cosmos of infinite possibility!" % universe_being.universe_name)
	
	return universe_being

func create_portal_between_universes() -> Node:
	"""Create a portal to connect universes"""
	if demo_beings.size() < 2:
		print("🌀 Need at least 2 universes to create a portal")
		return null
	
	# Find universes
	var universes = []
	for being in demo_beings:
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
