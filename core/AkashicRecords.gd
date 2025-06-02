# ==================================================
# SCRIPT NAME: AkashicRecords.gd
# DESCRIPTION: The Living Database - ZIP-based Universal Being storage and evolution
# PURPOSE: Store, load, and manage all Universal Being data through ZIP files
# CREATED: 2025-06-01 - Universal Being Revolution
# AUTHOR: JSH + Claude Code + Luminus + Alpha  
# ==================================================

extends Node
class_name AkashicRecords

# ===== AKASHIC STORAGE SYSTEM =====

## Library Paths
const LIBRARIES_PATH: String = "res://libraries/"
const ASSETS_LIBRARY: String = LIBRARIES_PATH + "assets_library/"
const LOGICS_LIBRARY: String = LIBRARIES_PATH + "logics_library/"
const ACTIONS_LIBRARY: String = LIBRARIES_PATH + "actions_library/"
const INTERFACES_LIBRARY: String = LIBRARIES_PATH + "interfaces_library/"
const AI_LIBRARY: String = LIBRARIES_PATH + "ai_library/"
const COMPOSITES_LIBRARY: String = LIBRARIES_PATH + "composites_library/"
const COMPACTS_LIBRARY: String = LIBRARIES_PATH + "compacts_library/"

## Cache System
var zip_cache: Dictionary = {}  # path -> data
var component_cache: Dictionary = {}  # path -> component_data
var being_templates: Dictionary = {}  # type -> template_data
var evolution_rules: Dictionary = {}  # form -> [possible_evolutions]

## Indexing System for Queries
var type_index: Dictionary = {}  # type -> [file_paths]
var name_index: Dictionary = {}  # name -> file_path
var consciousness_index: Dictionary = {}  # level -> [file_paths]

## Session Data
var session_beings: Array[String] = []  # UUIDs of beings created this session
var session_evolutions: Array[Dictionary] = []  # Evolution history
var session_interactions: Array[Dictionary] = []  # Interaction logs

## Compact System
var compact_system: AkashicCompactSystem = null
var active_compacts: Dictionary = {}  # id -> Compact
var compact_chains: Dictionary = {}  # being_id -> [compact_ids]

# ===== CORE SIGNALS =====

signal being_saved_to_zip(path: String, being: Node)
signal being_loaded_from_zip(path: String, being: Node)
signal component_loaded(path: String, data: Dictionary)
signal evolution_rule_added(from_form: String, to_form: String)
signal akashic_memory_updated(type: String, data: Dictionary)

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	name = "AkashicRecords"
	load_libraries()
	load_evolution_rules()

func pentagon_ready() -> void:
	print("📚 Akashic Records initialized - Living database active")

func pentagon_process(delta: float) -> void:
	# Update session data
	update_session_logs(delta)

func pentagon_input(event: InputEvent) -> void:
	pass

func pentagon_sewers() -> void:
	# Save session data before shutdown
	save_session_data()

# ===== ZIP FILE MANAGEMENT =====

func ensure_directory_exists(file_path: String) -> void:
	"""Ensure the directory for a file path exists"""
	var dir_path = file_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

func load_being_from_zip(zip_path: String) -> Dictionary:
	"""Load a Universal Being from ZIP file"""
	if zip_path in zip_cache:
		return zip_cache[zip_path].duplicate(true)
		
	if not FileAccess.file_exists(zip_path):
		push_error("📚 Akashic: ZIP file not found: " + zip_path)
		return {}
	
	# In a real implementation, this would extract and parse ZIP
	# For now, simulate ZIP loading with JSON
	var json_path = zip_path.replace(".ub.zip", ".json")
	if FileAccess.file_exists(json_path):
		var file = FileAccess.open(json_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var data = json.data
				# Migrate data if needed
				data = migrate_being_data(data)
				zip_cache[zip_path] = data
				return data.duplicate(true)
			else:
				push_error("JSON parse error at line %d: %s" % [json.get_error_line(), json.get_error_message()])
				# Return minimal valid data instead of empty
				return create_default_being_template()
	
	# Return default template if file doesn't exist
	return create_default_being_template()

func save_being_to_zip(being: Node, zip_path: String) -> bool:
	"""Save a Universal Being to ZIP file"""
	# Verify it's a UniversalBeing
	if not being.has_method("get_all_properties"):
		push_error("AkashicRecords: Not a valid UniversalBeing")
		return false
		
	var being_data = {
		"manifest": {
			"universal_being": {
				"uuid": being.get("being_uuid"),
				"name": being.get("being_name"),
				"type": being.get("being_type"),
				"version": "1.0.0",
				"created": Time.get_datetime_string_from_system(),
				"creator": "JSH + Gemma"
			},
			"pentagon": {
				"init_priority": 1,
				"process_frequency": 60,
				"input_enabled": true,
				"sewers_enabled": true
			},
			"floodgate": {
				"spawn_permissions": ["any"],
				"max_instances": -1,
				"resource_cost": 1
			},
			"ai_integration": {
				"gemma_can_modify": being.get("metadata", {}).get("gemma_can_modify", true),
				"gemma_can_read": being.get("metadata", {}).get("ai_accessible", true),
				"debug_level": "full"
			}
		},
		"properties": being.call("get_all_properties") if being.has_method("get_all_properties") else {},
		"components": being.get("components", []),
		"evolution_state": being.get("evolution_state", {}),
		"consciousness_level": being.get("consciousness_level", 0),
		"metadata": being.get("metadata", {})
	}
	
	# Ensure directory exists
	ensure_directory_exists(zip_path)
	
	# Save as JSON (simulating ZIP)
	var json_path = zip_path.replace(".ub.zip", ".json")
	var file = FileAccess.open(json_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(being_data, "\t"))
		file.close()
		
		zip_cache[zip_path] = being_data
		being_saved_to_zip.emit(zip_path, being)
		print("📚 Akashic: Being saved to " + zip_path)
		return true
	
	return false

func load_component(component_path: String) -> Dictionary:
	"""Load a component from ZIP file"""
	if component_path in component_cache:
		return component_cache[component_path].duplicate(true)
		
	var component_data = load_being_from_zip(component_path)
	if component_data.size() > 0:
		component_cache[component_path] = component_data
		component_loaded.emit(component_path, component_data)
		
	return component_data

# ===== LIBRARY MANAGEMENT =====

func load_libraries() -> void:
	"""Load all available libraries"""
	var libraries = [
		ASSETS_LIBRARY,
		LOGICS_LIBRARY, 
		ACTIONS_LIBRARY,
		INTERFACES_LIBRARY,
		AI_LIBRARY,
		COMPOSITES_LIBRARY
	]
	
	for library_path in libraries:
		scan_library(library_path)

func scan_library(library_path: String) -> Array[String]:
	"""Scan a library directory for .ub.zip files"""
	var files: Array[String] = []
	
	if not DirAccess.dir_exists_absolute(library_path):
		print("📚 Akashic: Creating library directory: " + library_path)
		DirAccess.make_dir_recursive_absolute(library_path)
		create_default_library_content(library_path)
		return files
	
	var dir = DirAccess.open(library_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".ub.zip") or file_name.ends_with(".json"):
				files.append(library_path + file_name)
			elif dir.current_is_dir() and not file_name.begins_with("."):
				# Recursively scan subdirectories
				var subdir_files = scan_library(library_path + file_name + "/")
				files.append_array(subdir_files)
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	print("📚 Akashic: Found %d files in %s" % [files.size(), library_path])
	return files

func create_default_library_content(library_path: String) -> void:
	"""Create default content for new libraries"""
	if library_path.contains("assets_library"):
		create_basic_assets()
	elif library_path.contains("logics_library"):
		create_basic_logics()
	elif library_path.contains("actions_library"):
		create_basic_actions()
	elif library_path.contains("interfaces_library"):
		create_basic_interfaces()

# ===== TEMPLATE CREATION =====

func create_basic_assets() -> void:
	"""Create basic asset templates"""
	var sphere_data = create_default_being_template()
	sphere_data.manifest.universal_being.name = "Basic Sphere"
	sphere_data.manifest.universal_being.type = "asset"
	sphere_data.visual = {"type": "sphere", "radius": 1.0}
	save_template_data(ASSETS_LIBRARY + "sphere.json", sphere_data)
	
	var cube_data = create_default_being_template()
	cube_data.manifest.universal_being.name = "Basic Cube"
	cube_data.manifest.universal_being.type = "asset"
	cube_data.visual = {"type": "cube", "size": Vector3(1, 1, 1)}
	save_template_data(ASSETS_LIBRARY + "cube.json", cube_data)

func create_basic_logics() -> void:
	"""Create basic logic templates"""
	var follow_logic = create_default_being_template()
	follow_logic.manifest.universal_being.name = "Follow Target Logic"
	follow_logic.manifest.universal_being.type = "logic"
	follow_logic.behavior = {"type": "follow", "speed": 5.0, "target": null}
	save_template_data(LOGICS_LIBRARY + "follow_target.json", follow_logic)

func create_basic_actions() -> void:
	"""Create basic action templates"""
	var move_action = create_default_being_template()
	move_action.manifest.universal_being.name = "Linear Movement"
	move_action.manifest.universal_being.type = "action"
	move_action.action = {"type": "move", "direction": Vector3.FORWARD, "speed": 1.0}
	save_template_data(ACTIONS_LIBRARY + "linear_move.json", move_action)

func create_basic_interfaces() -> void:
	"""Create basic interface templates"""
	var button_data = create_default_being_template()
	button_data.manifest.universal_being.name = "Basic Button"
	button_data.manifest.universal_being.type = "interface"
	button_data.interface = {"type": "button", "text": "Click Me", "size": Vector2(100, 40)}
	save_template_data(INTERFACES_LIBRARY + "button_basic.json", button_data)

func create_default_being_template() -> Dictionary:
	"""Create a default Universal Being template"""
	return {
		"manifest": {
			"universal_being": {
				"uuid": "",
				"name": "Default Being",
				"type": "basic",
				"version": "1.0.0",
				"created": Time.get_datetime_string_from_system(),
				"creator": "System"
			},
			"pentagon": {
				"init_priority": 1,
				"process_frequency": 60,
				"input_enabled": false,
				"sewers_enabled": true
			},
			"floodgate": {
				"spawn_permissions": ["any"],
				"max_instances": -1,
				"resource_cost": 1
			},
			"ai_integration": {
				"gemma_can_modify": true,
				"gemma_can_read": true,
				"debug_level": "full"
			}
		},
		"properties": {},
		"components": [],
		"evolution_state": {
			"current_form": "basic",
			"can_become": [],
			"evolution_count": 0
		},
		"consciousness_level": 0,
		"interactions": {},
		"metadata": {
			"ai_accessible": true,
			"gemma_can_modify": true
		}
	}

func save_template_data(path: String, data: Dictionary) -> bool:
	"""Save template data to file"""
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
		print("📚 Akashic: Template saved to " + path)
		return true
	return false

# ===== EVOLUTION SYSTEM =====

func load_evolution_rules() -> void:
	"""Load evolution rules from data"""
	evolution_rules = {
		"basic": ["sphere", "cube", "button"],
		"sphere": ["cube", "complex_mesh"],
		"cube": ["sphere", "cylinder"],
		"button": ["slider", "input_field"]
	}

func get_evolution_options(current_form: String) -> Array[String]:
	"""Get possible evolution paths for a form"""
	return evolution_rules.get(current_form, [])

func add_evolution_rule(from_form: String, to_form: String) -> void:
	"""Add a new evolution rule"""
	if from_form not in evolution_rules:
		evolution_rules[from_form] = []
	
	if to_form not in evolution_rules[from_form]:
		evolution_rules[from_form].append(to_form)
		evolution_rule_added.emit(from_form, to_form)

# ===== INDEXING SYSTEM =====

func rebuild_indices() -> void:
	"""Rebuild all indices for faster queries"""
	type_index.clear()
	name_index.clear()
	consciousness_index.clear()
	
	for file_path in get_all_library_files():
		var data = load_being_from_zip(file_path)
		var manifest = data.get("manifest", {})
		var ub_data = manifest.get("universal_being", {})
		
		# Index by type
		var type = ub_data.get("type", "")
		if type:
			if type not in type_index:
				type_index[type] = []
			type_index[type].append(file_path)
		
		# Index by name
		var name = ub_data.get("name", "")
		if name:
			name_index[name] = file_path
		
		# Index by consciousness level
		var level = data.get("consciousness_level", 0)
		if level not in consciousness_index:
			consciousness_index[level] = []
		consciousness_index[level].append(file_path)
	
	print("📚 Akashic: Indices rebuilt - %d types, %d names, %d consciousness levels" % 
		[type_index.size(), name_index.size(), consciousness_index.size()])

# ===== QUERY SYSTEM =====

func query_library(search_terms: Array[String]) -> Array[String]:
	"""Search libraries for matching beings"""
	var results: Array[String] = []
	var all_files = get_all_library_files()
	
	for file_path in all_files:
		var data = load_being_from_zip(file_path)
		if matches_search_terms(data, search_terms):
			results.append(file_path)
	
	return results

func get_all_library_files() -> Array[String]:
	"""Get all files from all libraries"""
	var all_files: Array[String] = []
	
	var libraries = [
		ASSETS_LIBRARY,
		LOGICS_LIBRARY,
		ACTIONS_LIBRARY,
		INTERFACES_LIBRARY,
		AI_LIBRARY,
		COMPOSITES_LIBRARY
	]
	
	for library in libraries:
		all_files.append_array(scan_library(library))
	
	return all_files

func matches_search_terms(data: Dictionary, search_terms: Array[String]) -> bool:
	"""Check if data matches search terms"""
	var data_string = JSON.stringify(data).to_lower()
	
	for term in search_terms:
		if term.to_lower() in data_string:
			return true
	
	return false

func get_beings_by_type(type: String) -> Array[String]:
	"""Get all beings of a specific type"""
	return query_library(['"type": "' + type + '"'])

# ===== SESSION MANAGEMENT =====

func update_session_logs(delta: float) -> void:
	"""Update session tracking data"""
	# This would track interactions, evolutions, etc.
	pass

func save_session_data() -> void:
	"""Save current session data"""
	var session_data = {
		"session_start": Time.get_datetime_string_from_system(),
		"beings_created": session_beings,
		"evolutions": session_evolutions,
		"interactions": session_interactions
	}
	
	var session_file = "res://saves/session_" + str(Time.get_unix_time_from_system()) + ".json"
	save_template_data(session_file, session_data)

# ===== BATCH OPERATIONS =====

func load_beings_batch(paths: Array[String]) -> Array[Dictionary]:
	"""Load multiple beings in one operation"""
	var results: Array[Dictionary] = []
	for path in paths:
		results.append(load_being_from_zip(path))
	return results

func save_beings_batch(beings: Array[Node], base_path: String) -> int:
	"""Save multiple beings at once"""
	var success_count = 0
	for i in range(beings.size()):
		var being = beings[i]
		var path = base_path + "being_%d.ub.zip" % i
		if save_being_to_zip(being, path):
			success_count += 1
	return success_count

func query_by_type(type: String) -> Array[String]:
	"""Fast query using type index"""
	if type in type_index:
		return type_index[type]
	return []

func query_by_consciousness(level: int) -> Array[String]:
	"""Fast query using consciousness index"""
	if level in consciousness_index:
		return consciousness_index[level]
	return []

# ===== MIGRATION SYSTEM =====

func migrate_being_data(data: Dictionary) -> Dictionary:
	"""Migrate being data to current version"""
	var manifest = data.get("manifest", {})
	var ub_data = manifest.get("universal_being", {})
	var version = ub_data.get("version", "0.0.0")
	
	match version:
		"0.0.0":
			# Migrate from version 0 to 1
			ub_data.version = "1.0.0"
			if not data.has("consciousness_level"):
				data.consciousness_level = 0
			if not data.has("metadata"):
				data.metadata = {
					"ai_accessible": true,
					"gemma_can_modify": true
				}
			if not data.has("components"):
				data.components = []
			if not data.has("evolution_state"):
				data.evolution_state = {
					"current_form": ub_data.get("type", "unknown"),
					"can_become": [],
					"evolution_history": []
				}
		"1.0.0":
			# Current version, no migration needed
			pass
		_:
			push_warning("Unknown being version: %s" % version)
	
	return data

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	"""Interface for Gemma AI"""
	return {
		"total_beings_in_libraries": get_all_library_files().size(),
		"cached_beings": zip_cache.size(),
		"evolution_rules": evolution_rules,
		"session_beings": session_beings.size(),
		"available_types": get_available_types(),
		"can_create_beings": true
	}

func get_available_types() -> Array[String]:
	"""Get all available being types"""
	var types: Array[String] = []
	var all_files = get_all_library_files()
	
	for file_path in all_files:
		var data = load_being_from_zip(file_path)
		var type = data.get("manifest", {}).get("universal_being", {}).get("type", "unknown")
		if type not in types:
			types.append(type)
	
	return types

# ===== DEBUG FUNCTIONS =====

func debug_info() -> String:
	"""Get Akashic Records debug information"""
	var info = []
	info.append("=== Akashic Records Debug Info ===")
	info.append("Cached Files: %d" % zip_cache.size())
	info.append("Available Libraries: %d" % 6)
	info.append("Total Files: %d" % get_all_library_files().size())
	info.append("Evolution Rules: %d" % evolution_rules.size())
	info.append("Session Beings: %d" % session_beings.size())
	
	info.append("\nLibrary Contents:")
	var libraries = [
		["Assets", ASSETS_LIBRARY],
		["Logics", LOGICS_LIBRARY],
		["Actions", ACTIONS_LIBRARY],
		["Interfaces", INTERFACES_LIBRARY],
		["AI", AI_LIBRARY],
		["Composites", COMPOSITES_LIBRARY]
	]
	
	for lib in libraries:
		var count = scan_library(lib[1]).size()
		info.append("  %s: %d files" % [lib[0], count])
	
	return "\n".join(info)

func validate_libraries() -> bool:
	"""Validate all library files"""
	var valid = true
	var all_files = get_all_library_files()
	
	for file_path in all_files:
		var data = load_being_from_zip(file_path)
		if not data.has("manifest"):
			print("📚 Akashic: Invalid file (no manifest): " + file_path)
			valid = false
	
	if valid:
		print("📚 Akashic: All libraries validated ✓")
	
	return valid