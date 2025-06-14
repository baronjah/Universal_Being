extends Node
# ═══════════════════════════════════════════════════════════════════════════════════════════════
# 🌟 WORD COMPONENTS - MODULAR FEATURE SEPARATION 🌟
# ═══════════════════════════════════════════════════════════════════════════════════════════════
#
# 📍 PROJECT PATH: /akashic_notepad3d_game/scripts/core/word_components.gd
# 🎯 FILE GOAL: Separate core features into word-based modular components
# 🔗 CONNECTED FILES:
#    - core/main_game_controller.gd (central coordination)
#    - core/notepad3d_environment.gd (screen and layer management)
#    - core/camera_controller.gd (camera and vision control)
#
# 🚀 REVOLUTIONARY FEATURES:
#    - Word-based component separation (controller, input, vision, screen, camera, mouse)
#    - Modular functionality that can be mixed and matched
#    - Clear separation of concerns for easier development
#    - Dynamic component loading and configuration
#
# 🎮 USER EXPERIENCE: Cleaner, more manageable system architecture
# ═══════════════════════════════════════════════════════════════════════════════════════════════

class_name WordComponents_wordcomponents

# ─────────────────────────────────────────────────────────────────────────────────
# 🎯 WORD COMPONENT DEFINITIONS
# ─────────────────────────────────────────────────────────────────────────────────

# Component registry
var word_components: Dictionary = {}

# Component types
enum \2 {

	CONTROLLER,  # Input handling and coordination
	INPUT,       # Keyboard, mouse, and interaction processing
	VISION,      # Camera positioning and movement
	SCREEN,      # Layer management and display
	DIRECTION,   # Navigation and orientation
	CAMERA,      # Camera control and framing
	MOUSE        # Mouse interaction and clicking
}

func _ready() -> void:
	_initialize_word_components()
	print("🔤 Word Components system initialized - Modular architecture active")

# ─────────────────────────────────────────────────────────────────────────────────
# 🏗️ COMPONENT INITIALIZATION - WORD-BASED ARCHITECTURE
# ─────────────────────────────────────────────────────────────────────────────────
func _initialize_word_components() -> void:
	# CONTROLLER component - Central coordination
	word_components["controller"] = {
		"type": ComponentType.CONTROLLER,
		"description": "Central game coordination and system management",
		"functions": ["coordinate_systems", "manage_state", "handle_events"],
		"connections": ["input", "vision", "screen"],
		"active": true
	}
	
	# INPUT component - User interaction processing
	word_components["input"] = {
		"type": ComponentType.INPUT,
		"description": "Keyboard and interaction processing",
		"functions": ["process_keys", "handle_shortcuts", "validate_input"],
		"connections": ["controller", "mouse"],
		"active": true,
		"key_bindings": {
			"n": "toggle_notepad3d",
			"u": "toggle_3d_ui", 
			"f": "cinema_perspective",
			"tab": "navigate_layers",
			"`": "debug_toggle"
		}
	}
	
	# VISION component - Camera and perspective control
	word_components["vision"] = {
		"type": ComponentType.VISION,
		"description": "Camera positioning and perspective management",
		"functions": ["set_perspective", "smooth_transitions", "auto_frame"],
		"connections": ["camera", "direction", "screen"],
		"active": true,
		"positions": {
			"cinema": Vector3(0, 2, -50),
			"close": Vector3(0, 2, -30),
			"overview": Vector3(0, 10, -60)
		}
	}
	
	# SCREEN component - Layer and display management
	word_components["screen"] = {
		"type": ComponentType.SCREEN,
		"description": "Layer management and visual display control",
		"functions": ["manage_layers", "toggle_visibility", "handle_markers"],
		"connections": ["vision", "direction"],
		"active": true,
		"layers": ["current_text", "recent_context", "file_structure", "akashic_data", "cosmic_background"]
	}
	
	# DIRECTION component - Navigation and orientation
	word_components["direction"] = {
		"type": ComponentType.DIRECTION,
		"description": "Navigation control and spatial orientation",
		"functions": ["navigate_layers", "orient_camera", "track_focus"],
		"connections": ["vision", "screen", "input"],
		"active": true
	}
	
	# CAMERA component - Physical camera control
	word_components["camera"] = {
		"type": ComponentType.CAMERA,
		"description": "Physical camera movement and control",
		"functions": ["move_camera", "rotate_camera", "adjust_fov"],
		"connections": ["vision", "direction"],
		"active": true
	}
	
	# MOUSE component - Mouse interaction handling
	word_components["mouse"] = {
		"type": ComponentType.MOUSE,
		"description": "Mouse click and interaction processing",
		"functions": ["detect_clicks", "handle_hover", "process_drag"],
		"connections": ["input", "screen"],
		"active": true
	}

# ─────────────────────────────────────────────────────────────────────────────────
# 🔧 COMPONENT MANAGEMENT FUNCTIONS
# ─────────────────────────────────────────────────────────────────────────────────

func get_component(word: String) -> Dictionary:
	return word_components.get(word, {})

func is_component_active(word: String) -> bool:
	var component = get_component(word)
	return component.get("active", false)

func activate_component(word: String) -> void:
	if word_components.has(word):
		word_components[word]["active"] = true
		print("🔤 Activated component: %s" % word)

func deactivate_component(word: String) -> void:
	if word_components.has(word):
		word_components[word]["active"] = false
		print("🔤 Deactivated component: %s" % word)

func get_component_connections(word: String) -> Array:
	var component = get_component(word)
	return component.get("connections", [])

func get_component_functions(word: String) -> Array:
	var component = get_component(word)
	return component.get("functions", [])

# ─────────────────────────────────────────────────────────────────────────────────
# 🎯 COMPONENT INTERACTION SYSTEM
# ─────────────────────────────────────────────────────────────────────────────────

func execute_component_function(component_word: String, function_name: String, parameters: Array = []) -> void:
	if not is_component_active(component_word):
		print("⚠️ Component %s is not active" % component_word)
		return
		
	var functions = get_component_functions(component_word)
	if function_name in functions:
		print("🔤 Executing %s.%s with parameters: %s" % [component_word, function_name, parameters])
		_dispatch_function_call(component_word, function_name, parameters)
	else:
		print("⚠️ Function %s not found in component %s" % [function_name, component_word])

func _dispatch_function_call(component_word: String, function_name: String, parameters: Array) -> void:
	# Route function calls to appropriate systems
	match component_word:
		"controller":
			_handle_controller_function(function_name, parameters)
		"input":
			_handle_input_function(function_name, parameters)
		"vision":
			_handle_vision_function(function_name, parameters)
		"screen":
			_handle_screen_function(function_name, parameters)
		"direction":
			_handle_direction_function(function_name, parameters)
		"camera":
			_handle_camera_function(function_name, parameters)
		"mouse":
			_handle_mouse_function(function_name, parameters)

# ─────────────────────────────────────────────────────────────────────────────────
# 🎮 COMPONENT FUNCTION HANDLERS
# ─────────────────────────────────────────────────────────────────────────────────

func _handle_controller_function(function_name: String, parameters: Array) -> void:
	match function_name:
		"coordinate_systems":
			print("🎮 Coordinating all game systems")
		"manage_state":
			print("🎮 Managing game state: %s" % parameters)
		"handle_events":
			print("🎮 Handling events: %s" % parameters)

func _handle_input_function(function_name: String, parameters: Array) -> void:
	match function_name:
		"process_keys":
			print("⌨️ Processing key input: %s" % parameters)
		"handle_shortcuts":
			print("⌨️ Handling shortcuts: %s" % parameters)
		"validate_input":
			print("⌨️ Validating input: %s" % parameters)

func _handle_vision_function(function_name: String, parameters: Array) -> void:
	match function_name:
		"set_perspective":
			print("👁️ Setting camera perspective: %s" % parameters)
		"smooth_transitions":
			print("👁️ Creating smooth camera transition")
		"auto_frame":
			print("👁️ Auto-framing view")

func _handle_screen_function(function_name: String, parameters: Array) -> void:
	match function_name:
		"manage_layers":
			print("🖥️ Managing screen layers: %s" % parameters)
		"toggle_visibility":
			print("🖥️ Toggling screen visibility")
		"handle_markers":
			print("🖥️ Handling layer markers: %s" % parameters)

func _handle_direction_function(function_name: String, parameters: Array) -> void:
	match function_name:
		"navigate_layers":
			print("🧭 Navigating between layers: %s" % parameters)
		"orient_camera":
			print("🧭 Orienting camera direction")
		"track_focus":
			print("🧭 Tracking focus point")

func _handle_camera_function(function_name: String, parameters: Array) -> void:
	match function_name:
		"move_camera":
			print("📷 Moving camera: %s" % parameters)
		"rotate_camera":
			print("📷 Rotating camera: %s" % parameters)
		"adjust_fov":
			print("📷 Adjusting field of view: %s" % parameters)

func _handle_mouse_function(function_name: String, parameters: Array) -> void:
	match function_name:
		"detect_clicks":
			print("🖱️ Detecting mouse clicks: %s" % parameters)
		"handle_hover":
			print("🖱️ Handling mouse hover: %s" % parameters)
		"process_drag":
			print("🖱️ Processing mouse drag: %s" % parameters)

# ─────────────────────────────────────────────────────────────────────────────────
# 🔍 COMPONENT DEBUGGING AND INSPECTION
# ─────────────────────────────────────────────────────────────────────────────────

func print_component_status() -> void:
	print("🔤 === WORD COMPONENTS STATUS ===")
	for word in word_components.keys():
		var component = word_components[word]
		var status = "ACTIVE" if component["active"] else "INACTIVE"
		print("🔤 %s: %s - %s" % [word.to_upper(), status, component["description"]])

func get_active_components() -> Array:
	var active = []
	for word in word_components.keys():
		if is_component_active(word):
			active.append(word)
	return active

func test_component_system() -> void:
	print("🔤 Testing Word Component System...")
	execute_component_function("input", "process_keys", ["n", "u", "f"])
	execute_component_function("vision", "set_perspective", ["cinema"])
	execute_component_function("screen", "manage_layers", [0, 1, 2])
	print("🔤 Component system test complete")