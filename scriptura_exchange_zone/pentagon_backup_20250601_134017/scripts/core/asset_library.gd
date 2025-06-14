extends UniversalBeingBase
# ASSET LIBRARY - Centralized Asset Management
# Works with FloodgateController to manage all game assets
# Provides cataloging, loading, and approval systems
# Enhanced with TXT + TSCN Universal Being system

# ----- ASSET CATALOG -----
var asset_catalog = {
	"objects": {
		"tree": {
			"path": "res://assets/models/tree.tscn",
			"type": "scene",
			"category": "nature",
			"spawn_height": 0.0,
			"tags": ["foliage", "static", "outdoor"],
			"preview": "res://assets/previews/tree.png"
		},
		"rock": {
			"path": "res://assets/models/rock.tscn",
			"type": "scene",
			"category": "nature",
			"spawn_height": 0.0,
			"tags": ["static", "outdoor", "obstacle"],
			"preview": "res://assets/previews/rock.png"
		},
		"bush": {
			"path": "res://assets/models/bush.tscn",
			"type": "scene",
			"category": "nature",
			"spawn_height": 0.0,
			"tags": ["foliage", "static", "outdoor"],
			"preview": "res://assets/previews/bush.png"
		},
		"crate": {
			"path": "res://assets/models/crate.tscn",
			"type": "scene",
			"category": "props",
			"spawn_height": 0.0,
			"tags": ["physics", "movable", "indoor", "outdoor"],
			"preview": "res://assets/previews/crate.png"
		},
		"barrel": {
			"path": "res://assets/models/barrel.tscn",
			"type": "scene",
			"category": "props",
			"spawn_height": 0.0,
			"tags": ["physics", "movable", "indoor", "outdoor"],
			"preview": "res://assets/previews/barrel.png"
		},
		"wall": {
			"path": "res://assets/models/wall.tscn",
			"type": "scene",
			"category": "structure",
			"spawn_height": 0.0,
			"tags": ["static", "building", "indoor", "outdoor"],
			"preview": "res://assets/previews/wall.png"
		},
		"stick": {
			"path": "res://assets/models/stick.tscn",
			"type": "scene",
			"category": "nature",
			"spawn_height": 0.0,
			"tags": ["physics", "movable", "small", "outdoor"],
			"preview": "res://assets/previews/stick.png"
		},
		"leaf": {
			"path": "res://assets/models/leaf.tscn",
			"type": "scene",
			"category": "nature",
			"spawn_height": 0.0,
			"tags": ["physics", "small", "light", "outdoor"],
			"preview": "res://assets/previews/leaf.png"
		}
	},
	"ragdolls": {
		"basic_ragdoll": {
			"path": "res://assets/ragdolls/basic_ragdoll.tscn",
			"type": "scene",
			"category": "character",
			"spawn_height": 1.0,
			"tags": ["physics", "character", "ragdoll"],
			"preview": "res://assets/previews/basic_ragdoll.png"
		},
		"advanced_ragdoll": {
			"path": "res://assets/ragdolls/advanced_ragdoll.tscn",
			"type": "scene",
			"category": "character",
			"spawn_height": 1.0,
			"tags": ["physics", "character", "ragdoll", "advanced"],
			"preview": "res://assets/previews/advanced_ragdoll.png"
		}
	},
	"materials": {
		"grass": {
			"path": "res://assets/materials/grass.tres",
			"type": "material",
			"category": "ground",
			"tags": ["terrain", "outdoor"],
			"preview": "res://assets/previews/grass_mat.png"
		},
		"stone": {
			"path": "res://assets/materials/stone.tres",
			"type": "material",
			"category": "ground",
			"tags": ["terrain", "outdoor", "indoor"],
			"preview": "res://assets/previews/stone_mat.png"
		},
		"wood": {
			"path": "res://assets/materials/wood.tres",
			"type": "material",
			"category": "surface",
			"tags": ["indoor", "furniture"],
			"preview": "res://assets/previews/wood_mat.png"
		}
	},
	"textures": {
		"noise": {
			"path": "res://assets/textures/noise.png",
			"type": "texture",
			"category": "utility",
			"tags": ["procedural", "effect"],
			"preview": "res://assets/textures/noise.png"
		}
	},
	"audio": {
		"footstep_grass": {
			"path": "res://assets/audio/footstep_grass.ogg",
			"type": "audio",
			"category": "sfx",
			"tags": ["footstep", "movement", "grass"],
			"preview": null
		},
		"impact_wood": {
			"path": "res://assets/audio/impact_wood.ogg",
			"type": "audio",
			"category": "sfx",
			"tags": ["impact", "collision", "wood"],
			"preview": null
		}
	}
}

# ----- ASSET STATE -----
var loaded_assets = {}
var pending_approval = []
var approved_assets = []
var rejected_assets = []
var asset_load_queue = []
var custom_asset_count: int = 0

# ----- REFERENCES -----
var floodgate: Node = null

# ----- SIGNALS -----
signal asset_catalog_updated()
signal asset_loaded(asset_id, asset)  # Emitted when asset loading completes
signal asset_unloaded(asset_id)
signal asset_approval_requested(asset_id, asset_info)
signal asset_approved(asset_id)
signal asset_rejected(asset_id)

# ----- INITIALIZATION -----
func _ready():
	print("[AssetLibrary] Initializing asset management system...")
	
	# Find floodgate controller
	floodgate = get_node_or_null("/root/FloodgateController")
	if not floodgate:
		push_error("FloodgateController not found! Asset Library requires FloodgateController.")
		return
	
	# Connect to floodgate signals
	floodgate.asset_approval_needed.connect(_on_asset_approval_needed)
	
	print("[AssetLibrary] Asset Library ready with " + str(_count_total_assets()) + " assets cataloged")

# ----- ASSET CATALOG MANAGEMENT -----

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
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
func register_asset(category: String, asset_id: String, asset_info: Dictionary) -> bool:
	if not asset_catalog.has(category):
		asset_catalog[category] = {}
	
	# Validate required fields
	if not asset_info.has("path") or not asset_info.has("type"):
		push_error("Asset registration missing required fields: path and type")
		return false
	
	asset_catalog[category][asset_id] = asset_info
	emit_signal("asset_catalog_updated")
	
	print("[AssetLibrary] Registered asset: " + category + "/" + asset_id)
	return true

func unregister_asset(category: String, asset_id: String) -> bool:
	if not asset_catalog.has(category) or not asset_catalog[category].has(asset_id):
		return false
	
	asset_catalog[category].erase(asset_id)
	if asset_catalog[category].is_empty():
		asset_catalog.erase(category)
	
	emit_signal("asset_catalog_updated")
	return true

func get_asset_info(category: String, asset_id: String) -> Dictionary:
	if asset_catalog.has(category) and asset_catalog[category].has(asset_id):
		return asset_catalog[category][asset_id]
	return {}

func get_assets_by_category(category: String) -> Dictionary:
	if asset_catalog.has(category):
		return asset_catalog[category]
	return {}

func get_assets_by_tag(tag: String) -> Array:
	var results = []
	for category in asset_catalog:
		for asset_id in asset_catalog[category]:
			var asset_info = asset_catalog[category][asset_id]
			if asset_info.has("tags") and tag in asset_info.tags:
				results.append({
					"category": category,
					"id": asset_id,
					"info": asset_info
				})
	return results

func search_assets(search_term: String) -> Array:
	var results = []
	var term = search_term.to_lower()
	
	for category in asset_catalog:
		for asset_id in asset_catalog[category]:
			var asset_info = asset_catalog[category][asset_id]
			
			# Search in ID
			if asset_id.to_lower().contains(term):
				results.append({
					"category": category,
					"id": asset_id,
					"info": asset_info,
					"match": "id"
				})
				continue
			
			# Search in tags
			if asset_info.has("tags"):
				for tag in asset_info.tags:
					if tag.to_lower().contains(term):
						results.append({
							"category": category,
							"id": asset_id,
							"info": asset_info,
							"match": "tag: " + tag
						})
						break
			
			# Search in category
			if category.to_lower().contains(term):
				results.append({
					"category": category,
					"id": asset_id,
					"info": asset_info,
					"match": "category"
				})
	
	return results

# ----- ASSET LOADING -----
func load_asset(category: String, asset_id: String, auto_approve: bool = false) -> String:
	var asset_info = get_asset_info(category, asset_id)
	if asset_info.is_empty():
		push_error("Asset not found: " + category + "/" + asset_id)
		return ""
	
	# Check if already loaded
	var full_id = category + "/" + asset_id
	if loaded_assets.has(full_id):
		print("[AssetLibrary] Asset already loaded: " + full_id)
		return loaded_assets[full_id].operation_id
	
	# Auto-approve if requested
	if auto_approve and not asset_info.path in approved_assets:
		approved_assets.append(asset_info.path)
	
	# Queue load operation through floodgate  
	var operation_id = floodgate.queue_operation(
		floodgate.OperationType.LOAD_ASSET,
		{
			"path": asset_info.path,
			"type": _get_asset_type_enum(asset_info.type)
		},
		1  # Higher priority
	)
	
	# Track loading
	loaded_assets[full_id] = {
		"operation_id": operation_id,
		"status": "loading",
		"info": asset_info
	}
	
	return operation_id

func unload_asset(category: String, asset_id: String) -> bool:
	var full_id = category + "/" + asset_id
	if not loaded_assets.has(full_id):
		return false
	
	var asset_info = loaded_assets[full_id].info
	
	# Queue unload operation
	floodgate.queue_operation(
		FloodgateController.OperationType.UNLOAD_ASSET,
		{
			"path": asset_info.path
		}
	)
	
	loaded_assets.erase(full_id)
	emit_signal("asset_unloaded", full_id)
	return true

func preload_category(category: String, auto_approve: bool = false):
	if not asset_catalog.has(category):
		push_error("Category not found: " + category)
		return
	
	print("[AssetLibrary] Preloading category: " + category)
	
	for asset_id in asset_catalog[category]:
		load_asset(category, asset_id, auto_approve)

func preload_by_tag(tag: String, auto_approve: bool = false):
	var assets = get_assets_by_tag(tag)
	print("[AssetLibrary] Preloading " + str(assets.size()) + " assets with tag: " + tag)
	
	for asset in assets:
		load_asset(asset.category, asset.id, auto_approve)

# ----- ASSET SPAWNING -----
func spawn_asset(category: String, asset_id: String, parent: Node, position: Vector3 = Vector3.ZERO) -> String:
	var asset_info = get_asset_info(category, asset_id)
	if asset_info.is_empty():
		push_error("Asset not found for spawning: " + category + "/" + asset_id)
		return ""
	
	# Ensure asset is loaded first
	var full_id = category + "/" + asset_id
	if not loaded_assets.has(full_id):
		load_asset(category, asset_id, true)
		# TODO: Wait for load to complete
	
	# Apply spawn height offset
	if asset_info.has("spawn_height"):
		position.y += asset_info.spawn_height
	
	# Queue create operation through floodgate
	var operation_id = floodgate.queue_operation(
		FloodgateController.OperationType.CREATE_NODE,
		{
			"class_name": "Node3D",  # Will be replaced by loaded scene
			"parent_path": parent.get_path(),
			"name": asset_id,
			"properties": {
				"position": position
			}
		}
	)
	
	return operation_id

# ----- ASSET APPROVAL -----
func _on_asset_approval_needed(asset_path: String):
	# Find asset in catalog
	var asset_entry = _find_asset_by_path(asset_path)
	if asset_entry.is_empty():
		push_warning("Unknown asset requested approval: " + asset_path)
		return
	
	pending_approval.append(asset_entry)
	emit_signal("asset_approval_requested", asset_entry.full_id, asset_entry.info)

func approve_asset(full_id: String):
	for i in range(pending_approval.size()):
		if pending_approval[i].full_id == full_id:
			var asset_entry = pending_approval[i]
			approved_assets.append(asset_entry.info.path)
			floodgate.approve_asset(asset_entry.info.path)
			pending_approval.remove_at(i)
			emit_signal("asset_approved", full_id)
			return

func reject_asset(full_id: String):
	for i in range(pending_approval.size()):
		if pending_approval[i].full_id == full_id:
			var asset_entry = pending_approval[i]
			rejected_assets.append(asset_entry.info.path)
			floodgate.reject_asset(asset_entry.info.path)
			pending_approval.remove_at(i)
			emit_signal("asset_rejected", full_id)
			return

func get_pending_approvals() -> Array:
	return pending_approval.duplicate()

func auto_approve_all():
	while pending_approval.size() > 0:
		approve_asset(pending_approval[0].full_id)

func set_auto_approval(enabled: bool):
	floodgate.set_asset_approval_required(not enabled)

# ----- UTILITY FUNCTIONS -----
func _count_total_assets() -> int:
	var count = 0
	for category in asset_catalog:
		count += asset_catalog[category].size()
	return count

func _get_asset_type_enum(type_string: String) -> FloodgateController.AssetType:
	match type_string:
		"scene": return FloodgateController.AssetType.SCENE
		"mesh": return FloodgateController.AssetType.MESH
		"texture": return FloodgateController.AssetType.TEXTURE
		"audio": return FloodgateController.AssetType.AUDIO
		"script": return FloodgateController.AssetType.SCRIPT
		"shader": return FloodgateController.AssetType.SHADER
		"material": return FloodgateController.AssetType.MATERIAL
		_: return FloodgateController.AssetType.SCENE

func _find_asset_by_path(path: String) -> Dictionary:
	for category in asset_catalog:
		for asset_id in asset_catalog[category]:
			if asset_catalog[category][asset_id].path == path:
				return {
					"category": category,
					"id": asset_id,
					"full_id": category + "/" + asset_id,
					"info": asset_catalog[category][asset_id]
				}
	return {}

# ----- PUBLIC API -----
func get_catalog_summary() -> Dictionary:
	var summary = {}
	for category in asset_catalog:
		summary[category] = asset_catalog[category].size()
	return summary

func get_loaded_assets_list() -> Array:
	return loaded_assets.keys()

func is_asset_loaded(category: String, asset_id: String) -> bool:
	return loaded_assets.has(category + "/" + asset_id)

func get_asset_load_status(category: String, asset_id: String) -> String:
	var full_id = category + "/" + asset_id
	if loaded_assets.has(full_id):
		return loaded_assets[full_id].status
	return "not_loaded"

func export_catalog(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		return false
	
	file.store_string(JSON.stringify(asset_catalog, "\t"))
	file.close()
	return true

func import_catalog(file_path: String, merge: bool = false) -> bool:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("Failed to parse catalog JSON")
		return false
	
	if merge:
		# Merge with existing catalog
		for category in json.data:
			if not asset_catalog.has(category):
				asset_catalog[category] = {}
			for asset_id in json.data[category]:
				asset_catalog[category][asset_id] = json.data[category][asset_id]
	else:
		# Replace catalog
		asset_catalog = json.data
	
	emit_signal("asset_catalog_updated")
	return true

# ========== UNIVERSAL BEING SYSTEM ==========

func load_universal_being(asset_id: String, variant: String = "default"):
	"""Load a Universal Being from TXT + TSCN definition"""
	var category = _get_asset_category(asset_id)
	var txt_path = "res://assets/definitions/" + category + "/" + asset_id + ".txt"
	var tscn_path = "res://assets/arrangements/" + category + "/" + asset_id + ".tscn"
	
	# Load variant if specified
	if variant != "default":
		var variant_path = "res://assets/variants/" + asset_id + "_" + variant + ".tscn"
		if ResourceLoader.exists(variant_path):
			tscn_path = variant_path
	
	# Parse TXT definition
	var definition = _parse_txt_definition(txt_path)
	if definition.is_empty():
		print("⚠️ [AssetLibrary] No TXT definition found for: " + asset_id)
		# Fallback to creating from StandardizedObjects
		return _create_from_standardized_objects(asset_id)
	
	# Load TSCN arrangement (optional)
	var scene_template = null
	if ResourceLoader.exists(tscn_path):
		scene_template = load(tscn_path)
	
	# Create Universal Being
	return _create_universal_being(definition, scene_template, asset_id)

func _create_from_standardized_objects(asset_id: String):
	"""Fallback: Create Universal Being from StandardizedObjects"""
	var being_class = load("res://scripts/core/universal_being.gd")
	var being = being_class.new()
	being.set_property("asset_id", asset_id)
	being.set_property("name", asset_id.capitalize())
	being.set_property("type", "object")
	
	# Let Universal Being manifest itself using StandardizedObjects
	being.become(asset_id)
	
	being.add_to_group("universal_beings")
	being.add_to_group("standard_objects")
	
	print("📦 [AssetLibrary] Created from StandardizedObjects: " + asset_id)
	return being

# ========== HELPER FUNCTIONS ==========

func _get_asset_category(asset_id: String) -> String:
	"""Determine category from asset catalog or guess"""
	for category in asset_catalog:
		if asset_catalog[category].has(asset_id):
			return category
	
	# Guess category based on asset type
	match asset_id:
		"tree", "rock", "bush", "flower", "box", "ball":
			return "objects"
		"console", "grid", "debug":
			return "interfaces"
		"ragdoll", "astral_being":
			return "creatures"
		_:
			return "objects"

func _parse_txt_definition(path: String) -> Dictionary:
	"""Parse TXT definition file"""
	var definition = {}
	var current_section = ""
	
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		
		# Skip comments and empty lines
		if line.begins_with("#") or line.is_empty():
			continue
		
		# Section headers [SECTION]
		if line.begins_with("[") and line.ends_with("]"):
			current_section = line.substr(1, line.length() - 2).to_lower()
			definition[current_section] = {}
			continue
		
		# Key-value pairs
		var equals_pos = line.find("=")
		if equals_pos > 0:
			var key = line.substr(0, equals_pos).strip_edges()
			var value = line.substr(equals_pos + 1).strip_edges()
			
			# Convert to appropriate type
			value = _convert_value_type(value)
			
			if current_section.is_empty():
				definition[key] = value
			else:
				definition[current_section][key] = value
	
	file.close()
	return definition

func _convert_value_type(value: String) -> Variant:
	"""Convert string value to appropriate type"""
	# Boolean conversion
	if value.to_lower() in ["true", "false"]:
		return value.to_lower() == "true"
	
	# Number conversion
	if value.is_valid_float():
		if "." in value:
			return value.to_float()
		else:
			return value.to_int()
	
	# Vector3 conversion
	if value.count(",") == 2:
		var parts = value.split(",")
		if parts.size() == 3:
			var x = parts[0].strip_edges()
			var y = parts[1].strip_edges()
			var z = parts[2].strip_edges()
			if x.is_valid_float() and y.is_valid_float() and z.is_valid_float():
				return Vector3(x.to_float(), y.to_float(), z.to_float())
	
	# Color conversion
	if value.begins_with("#") and value.length() == 7:
		return Color(value)
	
	# Array conversion (comma-separated)
	if "," in value and not value.begins_with("#"):
		return value.split(",")
	
	# String (default)
	return value

func _create_universal_being(definition: Dictionary, scene_template: PackedScene, asset_id: String):
	"""Create Universal Being from definition and template"""
	var being_class = load("res://scripts/core/universal_being.gd")
	var being = being_class.new()
	
	# Apply identity
	if definition.has("properties"):
		var props = definition.properties
		being.set_property("name", props.get("name", asset_id.capitalize()))
		being.set_property("asset_id", asset_id)
		
		for key in props:
			being.set_property(key, props[key])
	
	# Set initial form
	var form_name = definition.get("properties", {}).get("name", asset_id)
	being.form = form_name
	
	# Add to groups
	being.add_to_group("universal_beings")
	
	print("✨ [AssetLibrary] Created Universal Being: " + asset_id)
	return being

# ----- PUBLIC UNIVERSAL BEING CREATION -----
func create_universal_being(being_type: String, properties: Dictionary = {}):
	"""Public interface for creating Universal Beings - called by FloodgateController"""
	# First check if it's in our catalog
	for category in asset_catalog:
		if being_type in asset_catalog[category]:
			return load_universal_being(being_type)
	
	# If not in catalog, create from standardized objects
	var being = _create_from_standardized_objects(being_type)
	if being:
		# Apply custom properties
		for key in properties:
			if being.has_method("set_property"):
				being.set_property(key, properties[key])
			else:
				being.set(key, properties[key])
		return being
	
	# Try to create a generic Universal Being with the type as form
	var universal_being_script = load("res://scripts/core/universal_being.gd")
	if universal_being_script:
		var generic_being = Node3D.new()
		generic_being.set_script(universal_being_script)
		generic_being.name = being_type.capitalize()
		
		# Initialize with type as form
		if generic_being.has_method("_ready"):
			generic_being._ready()
		
		# Check if it's an interface type
		if being_type.begins_with("interface_"):
			var interface_type = being_type.substr(10)  # Remove "interface_" prefix
			if generic_being.has_method("become_interface"):
				generic_being.become_interface(interface_type, properties)
		elif generic_being.has_method("become"):
			generic_being.become(being_type)
		
		# Apply properties
		for key in properties:
			if generic_being.has_method("set_property"):
				generic_being.set_property(key, properties[key])
		
		generic_being.add_to_group("universal_beings")
		print("✨ [AssetLibrary] Created generic Universal Being: " + being_type)
		return generic_being
	
	push_error("Failed to create Universal Being: " + being_type)
	return null

# ----- TXT ASSET DEFINITION HELPERS -----
func register_txt_asset(category: String, asset_id: String, txt_path: String, tscn_path: String = ""):
	"""Register a TXT-based asset definition"""
	if not asset_catalog.has(category):
		asset_catalog[category] = {}
	
	asset_catalog[category][asset_id] = {
		"path": txt_path,
		"scene": tscn_path if tscn_path != "" else "",
		"type": "txt_definition",
		"category": category,
		"tags": ["custom", "txt_based"],
		"preview": ""
	}
	
	custom_asset_count += 1
	print("[AssetLibrary] Registered TXT asset: " + asset_id + " in category: " + category)
