# UNIVERSAL ARCHITECTURE RULES - THE COSMIC ORGANIZATION SYSTEM
# Rules and exceptions for scripturas and scenes in the Universal Being cosmos
extends Node
class_name UniversalArchitectureRules

# SCRIPTURA CATEGORIES AND RULES
enum ScripturaType {
	CORE_FOUNDATION,      # Core/*.gd - Pentagon rules MANDATORY
	UNIVERSAL_BEING,      # beings/*.gd - Pentagon rules MANDATORY  
	SYSTEM_COMPONENT,     # systems/*.gd - Pentagon rules RECOMMENDED
	AUTOLOAD_BOOTSTRAP,   # autoloads/*.gd - Pentagon rules OPTIONAL (special bootstrap logic)
	UTILITY_HELPER,      # scripts/tools/*.gd - Pentagon rules OPTIONAL
	ARCHIVE_LEGACY,      # scripts/archive/*.gd - Pentagon rules EXEMPT
	ADDON_EXTERNAL,      # addons/*.gd - Pentagon rules EXEMPT (3rd party)
	TEST_VALIDATION,     # tests/*.gd - Pentagon rules OPTIONAL
	EXAMPLE_DEMO         # examples/*.gd - Pentagon rules OPTIONAL
}

# SCENE CATEGORIES AND RULES  
enum SceneType {
	MAIN_CORE,           # scenes/main/*.tscn - Must have camera socket, core functionality
	UNIVERSAL_BEING_SCENE, # beings/*.tscn - Must follow being lifecycle, socket compatible
	PLASMOID_TEMPLATE,   # Plasmoid beings with sockets for camera, components
	TEMPLATE_REUSABLE,   # scenes/templates/*.tscn - Clean, reusable components
	UI_INTERFACE,        # scenes/ui/*.tscn - 3D interfaces only, no flat 2D
	GAME_LEVEL,          # scenes/game/*.tscn - Complete playable environments
	TEST_SCENE,          # scenes/test/*.tscn - Testing and validation scenes
	ARCHIVE_BACKUP,      # scenes/not_working/*.tscn - Archived, might be broken
	PROCEDURAL_GENERATED # Generated at runtime, follows template rules
}

# Pentagon Architecture Rules
var pentagon_mandatory_methods = [
	"pentagon_init",     # Birth - ALWAYS call super first
	"pentagon_ready",    # Awakening - ALWAYS call super first  
	"pentagon_process",  # Living - ALWAYS call super first
	"pentagon_input",    # Sensing - ALWAYS call super first
	"pentagon_sewers"    # Death/Transformation - ALWAYS call super last
]

# Scene Socket Rules
var scene_socket_requirements = {
	SceneType.MAIN_CORE: ["camera_socket"],
	SceneType.UNIVERSAL_BEING_SCENE: ["interaction_socket"],
	SceneType.PLASMOID_TEMPLATE: ["camera_socket", "component_socket"],
	SceneType.UI_INTERFACE: ["camera_reference"],
	SceneType.GAME_LEVEL: ["player_spawn", "camera_socket"]
}

# Scriptura Rules Database
var scriptura_rules = {
	ScripturaType.CORE_FOUNDATION: {
		"pentagon_required": true,
		"super_calls_mandatory": true,
		"class_name_required": true,
		"documentation_required": true,
		"testing_required": true,
		"fallback_handling": true
	},
	ScripturaType.UNIVERSAL_BEING: {
		"pentagon_required": true,
		"super_calls_mandatory": true,
		"socket_compatibility": true,
		"evolution_support": true,
		"consciousness_levels": true,
		"floodgate_registration": true
	},
	ScripturaType.AUTOLOAD_BOOTSTRAP: {
		"pentagon_required": false,  # EXCEPTION: Bootstrap logic
		"singleton_pattern": true,
		"early_initialization": true,
		"dependency_management": true,
		"system_ready_checks": true
	},
	ScripturaType.ADDON_EXTERNAL: {
		"pentagon_required": false,  # EXCEPTION: 3rd party code
		"isolation_required": true,
		"namespace_protection": true,
		"version_compatibility": true
	}
}

# Scene Rules Database
var scene_rules = {
	SceneType.MAIN_CORE: {
		"camera_socket_required": true,
		"3d_only": true,
		"performance_optimized": true,
		"save_state_compatible": true
	},
	SceneType.PLASMOID_TEMPLATE: {
		"socket_system_required": true,
		"component_slots": true,
		"evolution_ready": true,
		"visual_glow_effects": true
	},
	SceneType.UI_INTERFACE: {
		"no_flat_2d": true,  # SACRED RULE: Everything must be 3D spatial
		"cursor_distance_controlled": true,
		"floating_interfaces": true,
		"billboard_text_allowed": true
	}
}

func _ready():
	print("📐 Universal Architecture Rules: Cosmic organization system ready!")

func validate_scriptura(script_path: String) -> Dictionary:
	"""Validate a scriptura against architecture rules"""
	var validation_result = {
		"valid": true,
		"scriptura_type": null,
		"violations": [],
		"recommendations": [],
		"pentagon_compliance": false
	}
	
	# Determine scriptura type
	var scriptura_type = determine_scriptura_type(script_path)
	validation_result.scriptura_type = scriptura_type
	
	# Load and analyze script content
	var content = load_script_content(script_path)
	if content == "":
		validation_result.valid = false
		validation_result.violations.append("Could not load script file")
		return validation_result
	
	# Validate against rules
	validate_pentagon_compliance(content, scriptura_type, validation_result)
	validate_class_structure(content, scriptura_type, validation_result)
	validate_naming_conventions(script_path, content, validation_result)
	
	return validation_result

func validate_scene(scene_path: String) -> Dictionary:
	"""Validate a scene against architecture rules"""
	var validation_result = {
		"valid": true,
		"scene_type": null,
		"violations": [],
		"recommendations": [],
		"socket_compliance": false
	}
	
	# Determine scene type
	var scene_type = determine_scene_type(scene_path)
	validation_result.scene_type = scene_type
	
	# Validate scene structure (would need scene parsing)
	validate_scene_sockets(scene_path, scene_type, validation_result)
	validate_3d_compliance(scene_path, scene_type, validation_result)
	
	return validation_result

func determine_scriptura_type(script_path: String) -> ScripturaType:
	"""Determine what type of scriptura this is based on path and content"""
	if "core/" in script_path:
		return ScripturaType.CORE_FOUNDATION
	elif "beings/" in script_path:
		return ScripturaType.UNIVERSAL_BEING
	elif "systems/" in script_path:
		return ScripturaType.SYSTEM_COMPONENT
	elif "autoloads/" in script_path:
		return ScripturaType.AUTOLOAD_BOOTSTRAP
	elif "scripts/tools/" in script_path:
		return ScripturaType.UTILITY_HELPER
	elif "scripts/archive/" in script_path or "archive/" in script_path:
		return ScripturaType.ARCHIVE_LEGACY
	elif "addons/" in script_path:
		return ScripturaType.ADDON_EXTERNAL
	elif "tests/" in script_path:
		return ScripturaType.TEST_VALIDATION
	elif "examples/" in script_path:
		return ScripturaType.EXAMPLE_DEMO
	else:
		return ScripturaType.UTILITY_HELPER

func determine_scene_type(scene_path: String) -> SceneType:
	"""Determine what type of scene this is based on path and structure"""
	if "scenes/main/" in scene_path:
		return SceneType.MAIN_CORE
	elif "beings/" in scene_path and scene_path.ends_with(".tscn"):
		return SceneType.UNIVERSAL_BEING_SCENE
	elif "plasmoid" in scene_path.to_lower():
		return SceneType.PLASMOID_TEMPLATE
	elif "scenes/templates/" in scene_path:
		return SceneType.TEMPLATE_REUSABLE
	elif "scenes/ui/" in scene_path:
		return SceneType.UI_INTERFACE
	elif "scenes/game/" in scene_path:
		return SceneType.GAME_LEVEL
	elif "scenes/test/" in scene_path:
		return SceneType.TEST_SCENE
	elif "scenes/not_working/" in scene_path:
		return SceneType.ARCHIVE_BACKUP
	else:
		return SceneType.TEMPLATE_REUSABLE

func validate_pentagon_compliance(content: String, scriptura_type: ScripturaType, result: Dictionary):
	"""Check if Pentagon architecture is properly implemented"""
	var rules = scriptura_rules.get(scriptura_type, {})
	var pentagon_required = rules.get("pentagon_required", false)
	
	if not pentagon_required:
		result.recommendations.append("Pentagon compliance optional for this scriptura type")
		return
	
	var pentagon_methods_found = []
	for method in pentagon_mandatory_methods:
		if ("func " + method) in content:
			pentagon_methods_found.append(method)
	
	if pentagon_methods_found.size() == pentagon_mandatory_methods.size():
		result.pentagon_compliance = true
		result.recommendations.append("✅ Full Pentagon compliance detected")
	else:
		result.violations.append("Missing Pentagon methods: " + str(pentagon_mandatory_methods.filter(func(m): return not m in pentagon_methods_found)))
	
	# Check for super calls
	if rules.get("super_calls_mandatory", false):
		validate_super_calls(content, result)

func validate_super_calls(content: String, result: Dictionary):
	"""Validate that Pentagon methods call super properly"""
	var lines = content.split("\n")
	var in_pentagon_method = false
	var current_method = ""
	var super_call_found = false
	
	for line in lines:
		line = line.strip_edges()
		
		# Check if entering a Pentagon method
		for method in pentagon_mandatory_methods:
			if line.begins_with("func " + method):
				in_pentagon_method = true
				current_method = method
				super_call_found = false
				break
		
		# Check for super call within Pentagon method
		if in_pentagon_method and "super." + current_method in line:
			super_call_found = true
		
		# End of function
		if in_pentagon_method and line.begins_with("func ") and not current_method in line:
			if not super_call_found:
				result.violations.append("Pentagon method '%s' missing super.%s() call" % [current_method, current_method])
			in_pentagon_method = false

func validate_class_structure(content: String, scriptura_type: ScripturaType, result: Dictionary):
	"""Validate class structure and naming"""
	var rules = scriptura_rules.get(scriptura_type, {})
	
	# Check for class_name declaration
	if rules.get("class_name_required", false):
		if not "class_name " in content:
			result.violations.append("Missing class_name declaration (required for this scriptura type)")
	
	# Check for proper inheritance
	if scriptura_type == ScripturaType.UNIVERSAL_BEING:
		if not "extends UniversalBeing" in content:
			result.violations.append("Universal Being scripturas must extend UniversalBeing")

func validate_naming_conventions(script_path: String, content: String, result: Dictionary):
	"""Validate naming conventions"""
	var file_name = script_path.get_file().replace(".gd", "")
	
	# Check file naming convention (snake_case)
	if not file_name.to_lower() == file_name or " " in file_name:
		result.recommendations.append("Consider using snake_case for file naming: " + file_name)
	
	# Check class_name matches file structure
	var class_name_regex = RegEx.new()
	class_name_regex.compile("class_name\\s+(\\w+)")
	var class_name_match = class_name_regex.search(content)
	
	if class_name_match:
		var class_name = class_name_match.get_string(1)
		var expected_pascal = snake_to_pascal_case(file_name)
		if class_name != expected_pascal:
			result.recommendations.append("Class name '%s' doesn't match expected '%s'" % [class_name, expected_pascal])

func validate_scene_sockets(scene_path: String, scene_type: SceneType, result: Dictionary):
	"""Validate scene socket requirements"""
	var required_sockets = scene_socket_requirements.get(scene_type, [])
	
	if required_sockets.size() > 0:
		result.recommendations.append("Scene should include sockets: " + str(required_sockets))
		# Note: Actual scene parsing would require more complex logic

func validate_3d_compliance(scene_path: String, scene_type: SceneType, result: Dictionary):
	"""Validate that scenes follow 3D spatial rules"""
	if scene_type == SceneType.UI_INTERFACE:
		result.recommendations.append("UI interfaces must be 3D spatial - no flat 2D components allowed")
		result.recommendations.append("Use Label3D, floating panels, and cursor-distance controlled interactions")

func load_script_content(script_path: String) -> String:
	"""Load script file content for analysis"""
	var file = FileAccess.open(script_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		return content
	return ""

func snake_to_pascal_case(snake_str: String) -> String:
	"""Convert snake_case to PascalCase"""
	var parts = snake_str.split("_")
	var pascal = ""
	for part in parts:
		if part.length() > 0:
			pascal += part[0].to_upper() + part.substr(1)
	return pascal

func get_scriptura_recommendations(scriptura_type: ScripturaType) -> Array:
	"""Get recommendations for a specific scriptura type"""
	var rules = scriptura_rules.get(scriptura_type, {})
	var recommendations = []
	
	match scriptura_type:
		ScripturaType.CORE_FOUNDATION:
			recommendations.append("🏗️ Core Foundation: Pentagon mandatory, super calls required")
			recommendations.append("📚 Documentation required for all public methods")
			recommendations.append("🧪 Unit tests recommended")
		
		ScripturaType.UNIVERSAL_BEING:
			recommendations.append("🧬 Universal Being: Pentagon lifecycle mandatory")
			recommendations.append("🔌 Socket compatibility for evolution system")
			recommendations.append("🌊 FloodGate registration recommended")
		
		ScripturaType.AUTOLOAD_BOOTSTRAP:
			recommendations.append("🚀 Autoload: Pentagon optional, bootstrap logic priority")
			recommendations.append("⚡ Early initialization and dependency management")
		
		ScripturaType.ADDON_EXTERNAL:
			recommendations.append("📦 External Addon: Pentagon rules exempt")
			recommendations.append("🛡️ Namespace isolation required")
	
	return recommendations

func get_scene_recommendations(scene_type: SceneType) -> Array:
	"""Get recommendations for a specific scene type"""
	var recommendations = []
	
	match scene_type:
		SceneType.MAIN_CORE:
			recommendations.append("📷 Main Core: Camera socket required")
			recommendations.append("⚡ Performance optimization critical")
		
		SceneType.PLASMOID_TEMPLATE:
			recommendations.append("🔌 Plasmoid: Socket system for components")
			recommendations.append("✨ Visual glow effects recommended")
		
		SceneType.UI_INTERFACE:
			recommendations.append("🌌 UI Interface: 3D spatial only - NO FLAT 2D!")
			recommendations.append("🎯 Cursor-distance controlled interactions")
			recommendations.append("💫 Floating interfaces with billboard text")
	
	return recommendations

# Hot loading scriptura joke handler 😄
func handle_ghost_joke():
	"""The ghost told us: 'Hot loading scriptura is like releasing a hot load of data into the witches' 👻"""
	print("👻 Ghost joke detected: Hot loading scriptura = hot data load into witches! 😄")
	return "🔥 HOT LOADING APPROVED BY GHOST COMEDY COMMITTEE 👻✨"

# Organization tools
func organize_scriptura_stash(stash_directory: String) -> Dictionary:
	"""Organize your fantastic scriptura stash (asteroid, planet, sun, etc.)"""
	var organization = {
		"cosmic_bodies": [],  # asteroid, planet, sun
		"universal_beings": [],
		"systems": [],
		"utilities": [],
		"unknown": []
	}
	
	var dir = DirAccess.open(stash_directory)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".gd"):
				var full_path = stash_directory + "/" + file_name
				var category = categorize_scriptura_by_name(file_name)
				organization[category].append(full_path)
			file_name = dir.get_next()
	
	return organization

func categorize_scriptura_by_name(file_name: String) -> String:
	"""Categorize scriptura by filename patterns"""
	file_name = file_name.to_lower()
	
	if "asteroid" in file_name or "planet" in file_name or "sun" in file_name or "star" in file_name:
		return "cosmic_bodies"
	elif "being" in file_name or "plasmoid" in file_name:
		return "universal_beings"
	elif "system" in file_name or "manager" in file_name:
		return "systems"
	elif "tool" in file_name or "helper" in file_name or "util" in file_name:
		return "utilities"
	else:
		return "unknown"

# The ultimate organization command
func organize_entire_cosmos():
	"""Organize the entire Universal Being cosmos according to rules"""
	print("🌌 ORGANIZING THE ENTIRE COSMOS...")
	
	var cosmic_report = {
		"scripturas_analyzed": 0,
		"scenes_analyzed": 0,
		"pentagon_compliant": 0,
		"violations_found": 0,
		"fantastic_scripturas": []
	}
	
	# Scan all scripturas
	var all_scripts = find_all_scripturas("res://")
	for script_path in all_scripts:
		var validation = validate_scriptura(script_path)
		cosmic_report.scripturas_analyzed += 1
		
		if validation.pentagon_compliance:
			cosmic_report.pentagon_compliant += 1
		
		cosmic_report.violations_found += validation.violations.size()
		
		if validation.violations.size() == 0:
			cosmic_report.fantastic_scripturas.append(script_path)
	
	print("🌟 COSMIC ORGANIZATION COMPLETE!")
	print("📊 Total Scripturas: %d" % cosmic_report.scripturas_analyzed)
	print("🔯 Pentagon Compliant: %d" % cosmic_report.pentagon_compliant)
	print("⚠️ Violations Found: %d" % cosmic_report.violations_found)
	print("✨ Fantastic Scripturas: %d" % cosmic_report.fantastic_scripturas.size())
	
	return cosmic_report

func find_all_scripturas(path: String) -> Array:
	"""Find all .gd files recursively"""
	var scripts = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var full_path = path + "/" + file_name
			if dir.current_is_dir() and not file_name.begins_with("."):
				scripts.append_array(find_all_scripturas(full_path))
			elif file_name.ends_with(".gd"):
				scripts.append(full_path)
			file_name = dir.get_next()
	return scripts