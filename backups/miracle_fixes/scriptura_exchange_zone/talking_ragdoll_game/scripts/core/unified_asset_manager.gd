# ==================================================
# SCRIPT NAME: unified_asset_manager.gd
# DESCRIPTION: ONE unified asset system for Perfect Pentagon Architecture
# PURPOSE: Consolidate Asset Catalog + Assets Library + Standardized Objects into ONE system
# CREATED: 2025-05-31 - Asset unification for Akashic Records
# ==================================================

extends UniversalBeingBase
class_name UnifiedAssetManager

# THE ONE TRUE ASSET REGISTRY
var unified_assets: Dictionary = {}
var asset_categories: Dictionary = {}
var akashic_manifest: Dictionary = {}

# System references 
var asset_library: Node = null
var standardized_objects: Node = null
var console_manager: Node = null

signal asset_registered(asset_name: String, category: String)
signal manifest_updated(total_assets: int)

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	name = "UnifiedAssetManager"
	print("🎯 [UnifiedAssets] Creating THE ONE asset system...")
	
	# Connect to existing systems
	_connect_to_legacy_systems()
	
	# Unify all asset sources
	_unify_all_assets()
	
	# Create akashic manifest
	_create_akashic_manifest()
	
	# Register console commands
	_register_asset_commands()
	
	print("✅ [UnifiedAssets] ONE unified system ready with " + str(unified_assets.size()) + " assets!")

func _connect_to_legacy_systems() -> void:
	# Get references to all existing asset systems
	asset_library = get_node_or_null("/root/AssetLibrary")
	standardized_objects = StandardizedObjects if StandardizedObjects else null
	console_manager = get_node_or_null("/root/ConsoleManager")

func _unify_all_assets() -> void:
	print("🔄 [UnifiedAssets] Consolidating all asset sources...")
	
	# 1. Import from StandardizedObjects (15 objects)
	_import_standardized_objects()
	
	# 2. Import from AssetLibrary (8 objects in catalog)
	_import_asset_library()
	
	# 3. Import from any other asset sources
	_import_misc_assets()
	
	# 4. Categorize everything
	_categorize_assets()
	
	print("🎯 [UnifiedAssets] Unified " + str(unified_assets.size()) + " total assets")

func _import_standardized_objects() -> void:
	if not standardized_objects:
		print("⚠️ [UnifiedAssets] StandardizedObjects not available")
		return
		
	# Import all objects from StandardizedObjects.object_definitions
	var objects = StandardizedObjects.object_definitions
	for obj_name in objects:
		var obj_data = objects[obj_name]
		
		# Convert to unified format
		var unified_asset = {
			"name": obj_name,
			"type": obj_data.get("type", "unknown"),
			"mesh": obj_data.get("mesh", "box"),
			"colors": obj_data.get("colors", [Color.WHITE]),
			"size": obj_data.get("size", Vector3.ONE),
			"mass": obj_data.get("mass", 1.0),
			"actions": obj_data.get("actions", []),
			"source": "standardized_objects",
			"emissive": obj_data.get("emissive", false),
			"light_energy": obj_data.get("light_energy", 0.0),
			"special_script": obj_data.get("special_script", ""),
			"special_properties": obj_data.get("special_properties", {}),
			"akashic_category": _determine_akashic_category(obj_data)
		}
		
		unified_assets[obj_name] = unified_asset
		print("📦 [UnifiedAssets] Imported: " + obj_name + " from StandardizedObjects")

func _import_asset_library() -> void:
	if not asset_library:
		print("⚠️ [UnifiedAssets] AssetLibrary not available")
		return
		
	# Import from AssetLibrary catalog if it has assets
	if asset_library.has_method("get_all_assets"):
		var library_assets = asset_library.get_all_assets()
		for asset_name in library_assets:
			if not unified_assets.has(asset_name):  # Don't duplicate
				var asset_data = library_assets[asset_name]
				
				var unified_asset = {
					"name": asset_name,
					"type": asset_data.get("type", "library_asset"),
					"source": "asset_library",
					"data": asset_data,
					"akashic_category": "library_objects"
				}
				
				unified_assets[asset_name] = unified_asset
				print("📚 [UnifiedAssets] Imported: " + asset_name + " from AssetLibrary")

func _import_misc_assets() -> void:
	# Import any other assets from TXT database, etc.
	var txt_db = get_node_or_null("/root/TxtUniversalDatabase")
	if txt_db and txt_db.has_method("get_all_entries"):
		var txt_assets = txt_db.get_all_entries()
		for asset_name in txt_assets:
			if not unified_assets.has(asset_name):
				var asset_data = txt_assets[asset_name]
				
				var unified_asset = {
					"name": asset_name,
					"type": asset_data.get("type", "txt_being"),
					"source": "txt_database",
					"data": asset_data,
					"akashic_category": "txt_beings"
				}
				
				unified_assets[asset_name] = unified_asset
				print("📝 [UnifiedAssets] Imported: " + asset_name + " from TXT Database")

func _determine_akashic_category(obj_data: Dictionary) -> String:
	var type = obj_data.get("type", "unknown")
	
	match type:
		"light_entity", "divine_cursor", "interface_being":
			return "divine_beings"
		"physics", "kinematic":
			return "physical_objects"
		"static":
			return "environmental"
		"light":
			return "celestial_bodies"
		_:
			return "universal_entities"

func _categorize_assets() -> void:
	asset_categories.clear()
	
	for asset_name in unified_assets:
		var asset = unified_assets[asset_name]
		var category = asset.get("akashic_category", "uncategorized")
		
		if not asset_categories.has(category):
			asset_categories[category] = []
		
		asset_categories[category].append(asset_name)

func _create_akashic_manifest() -> void:
	akashic_manifest = {
		"system_name": "Unified Asset Management System",
		"created_at": Time.get_datetime_string_from_system(),
		"total_assets": unified_assets.size(),
		"categories": asset_categories,
		"sources_unified": ["standardized_objects", "asset_library", "txt_database"],
		"gamma_ai_ready": true,
		"perfect_pentagon_compliant": true,
		"akashic_records_compatible": true
	}
	
	manifest_updated.emit(unified_assets.size())

func _register_asset_commands() -> void:
	if not console_manager:
		return
		
	if console_manager.has_method("register_command"):
		console_manager.register_command("unified_assets", _cmd_unified_assets, "Show all unified assets")
		console_manager.register_command("asset_manifest", _cmd_asset_manifest, "Show akashic asset manifest")
		console_manager.register_command("asset_categories", _cmd_asset_categories, "Show asset categories")
		console_manager.register_command("asset_details", _cmd_asset_details, "Show detailed asset info: asset_details <name>")
		print("🎯 [UnifiedAssets] Console commands registered")

# === CONSOLE COMMANDS ===

func _cmd_unified_assets(_args: Array) -> String:
	var result = "🎯 UNIFIED ASSET SYSTEM\n"
	result += "═══════════════════════════\n"
	result += "📊 Total Assets: " + str(unified_assets.size()) + "\n\n"
	
	# Group by category
	for category in asset_categories:
		result += "📁 " + category.to_upper() + ":\n"
		var assets_in_category = asset_categories[category]
		for asset_name in assets_in_category:
			var asset = unified_assets[asset_name]
			result += "   • " + asset_name + " (" + asset.get("type", "unknown") + ")\n"
		result += "\n"
	
	result += "💡 Use 'asset_details <name>' for more info\n"
	return result

func _cmd_asset_manifest(_args: Array) -> String:
	var result = "🌌 AKASHIC ASSET MANIFEST\n"
	result += "══════════════════════════════\n"
	result += "🎯 System: " + akashic_manifest.get("system_name", "Unknown") + "\n"
	result += "📅 Created: " + akashic_manifest.get("created_at", "Unknown") + "\n"
	result += "📊 Total Assets: " + str(akashic_manifest.get("total_assets", 0)) + "\n"
	result += "🔗 Sources Unified: " + str(akashic_manifest.get("sources_unified", [])) + "\n"
	result += "🤖 Gamma AI Ready: " + str(akashic_manifest.get("gamma_ai_ready", false)) + "\n"
	result += "🎯 Pentagon Compliant: " + str(akashic_manifest.get("perfect_pentagon_compliant", false)) + "\n"
	result += "🌌 Akashic Compatible: " + str(akashic_manifest.get("akashic_records_compatible", false)) + "\n"
	
	return result

func _cmd_asset_categories(_args: Array) -> String:
	var result = "📁 ASSET CATEGORIES\n"
	result += "═══════════════════\n"
	
	for category in asset_categories:
		var count = asset_categories[category].size()
		result += "📁 " + category + ": " + str(count) + " assets\n"
	
	return result

func _cmd_asset_details(args: Array) -> String:
	if args.size() == 0:
		return "❌ Usage: asset_details <asset_name>"
	
	var asset_name = args[0]
	if not unified_assets.has(asset_name):
		return "❌ Asset not found: " + asset_name
	
	var asset = unified_assets[asset_name]
	var result = "🔍 ASSET DETAILS: " + asset_name + "\n"
	result += "═══════════════════════════════\n"
	
	for key in asset:
		var value = asset[key]
		result += "• " + key + ": " + str(value) + "\n"
	
	return result

# === PUBLIC API ===


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
func get_unified_asset(name: String) -> Dictionary:
	return unified_assets.get(name, {})

func get_all_assets() -> Dictionary:
	return unified_assets

func get_assets_by_category(category: String) -> Array:
	return asset_categories.get(category, [])

func create_asset(name: String, type: String, properties: Dictionary = {}) -> bool:
	# Create through StandardizedObjects for actual instantiation
	if standardized_objects and standardized_objects.has_method("create_object"):
		# This is THE ONE way to create objects
		return standardized_objects.create_object(type, Vector3.ZERO, properties) != null
	return false

func is_akashic_ready() -> bool:
	return akashic_manifest.get("akashic_records_compatible", false)