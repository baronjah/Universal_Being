# ==================================================
# SCRIPT NAME: universal_being_asset_connector.gd
# DESCRIPTION: Connects Universal Beings directly to StandardizedObjects
# PURPOSE: Make Universal Beings use proper assets from the library
# CREATED: 2025-05-29 - Direct asset integration
# ==================================================

extends UniversalBeingBase
class_name UniversalBeingAssetConnector

# Static function to enhance Universal Being with proper asset
static func enhance_being_with_asset(being: Node3D, asset_type: String) -> void:
	"""Make a Universal Being use the proper asset from StandardizedObjects"""
	
	var std_objects = being.get_node_or_null("/root/StandardizedObjects")
	if not std_objects:
		print("[AssetConnector] StandardizedObjects not found!")
		return
	
	# Check if this is a valid asset type
	if not std_objects.has_method("create_object"):
		print("[AssetConnector] StandardizedObjects missing create_object method!")
		return
	
	# Create the proper visual asset
	var visual = std_objects.create_object(asset_type, Vector3.ZERO)
	if not visual:
		print("[AssetConnector] Failed to create asset: ", asset_type)
		return
	
	# If being is a Universal Being, update its manifestation
	if being.has_method("get_script") and being.get_script() != null:
		var script_path = being.get_script().resource_path
		if "universal_being" in script_path:
			# Remove old manifestation
			if being.get("manifestation") != null and being.manifestation:
				being.manifestation.queue_free()
			
			# Set new manifestation
			FloodgateController.universal_add_child(visual, being)
			being.set("manifestation", visual)
			being.set("is_manifested", true)
			being.set("form", asset_type)
			
			print("[AssetConnector] Enhanced Universal Being with asset: ", asset_type)
			return
	
	# Otherwise just add as child
	FloodgateController.universal_add_child(visual, being)
	print("[AssetConnector] Added asset visual to being: ", asset_type)

# Function to get all available assets
static func get_available_assets() -> Array:
	"""Get list of all available asset types"""
	
	var std_objects = Engine.get_singleton("StandardizedObjects") if Engine.has_singleton("StandardizedObjects") else null
	if not std_objects:
		std_objects = Engine.get_main_loop().root.get_node_or_null("/root/StandardizedObjects")
	
	if not std_objects:
		return []
	
	# Get object definitions
	if std_objects.has("object_definitions"):
		return std_objects.object_definitions.keys()
	
	# Fallback list
	return ["tree", "rock", "box", "ball", "bush", "wall", "stick", "leaf", "ramp", "pathway", "sun", "ragdoll", "astral_being"]

# Check if asset exists
static func has_asset(asset_type: String) -> bool:
	"""Check if an asset type exists in StandardizedObjects"""
	
	var available = get_available_assets()
	return asset_type in available

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	# Pentagon setup - override in child classes
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