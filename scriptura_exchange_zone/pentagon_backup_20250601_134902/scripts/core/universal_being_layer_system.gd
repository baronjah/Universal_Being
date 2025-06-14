# ==================================================
# SCRIPT NAME: universal_being_layer_system.gd
# DESCRIPTION: Layer system for Universal Beings - interfaces always on top
# PURPOSE: Ensure gizmos and UI beings are always visible, even through ground
# CREATED: 2025-05-30
# ==================================================

extends UniversalBeingBase
class_name UniversalBeingLayerSystem

# Layer definitions
enum LayerType {
	WORLD,      # Normal objects - can be occluded
	INTERFACE,  # Gizmos, UI elements - always visible
	OVERLAY     # Top-most layer - always on absolute top
}

# Layer groups for easy management
var layer_groups = {
	LayerType.WORLD: [],
	LayerType.INTERFACE: [],
	LayerType.OVERLAY: []
}

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("[UniversalBeingLayerSystem] Initializing layer system...")
	name = "UniversalBeingLayerSystem"
	add_to_group("layer_system")
	
	# Register console commands
	_register_commands()
	
	# Setup material overrides for interface layer
	_setup_interface_materials()

func _register_commands() -> void:
	"""Register layer system commands"""
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		console.register_command("layer_add", cmd_layer_add, "Add object to layer")
		console.register_command("layer_list", cmd_layer_list, "List objects in layers")
		console.register_command("layer_gizmo", cmd_layer_gizmo, "Put gizmo on interface layer")
		console.register_command("layer_show", cmd_layer_show, "Show/hide layers")


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
func add_to_layer(node: Node3D, layer: LayerType) -> void:
	"""Add a node to a specific layer"""
	if not node:
		return
	
	# Remove from other layers first
	remove_from_all_layers(node)
	
	# Add to new layer
	layer_groups[layer].append(node)
	
	# Apply layer-specific properties
	match layer:
		LayerType.WORLD:
			_apply_world_layer(node)
		LayerType.INTERFACE:
			_apply_interface_layer(node)
		LayerType.OVERLAY:
			_apply_overlay_layer(node)
	
	print("[LayerSystem] Added ", node.name, " to layer: ", LayerType.keys()[layer])

func remove_from_all_layers(node: Node3D) -> void:
	"""Remove node from all layers"""
	for layer in layer_groups:
		if node in layer_groups[layer]:
			layer_groups[layer].erase(node)

func _apply_world_layer(node: Node3D) -> void:
	"""Apply world layer properties - normal rendering"""
	# Reset any layer overrides
	_reset_node_rendering(node)

func _apply_interface_layer(node: Node3D) -> void:
	"""Apply interface layer properties - always visible"""
	# Set render layer to always be on top
	_make_always_visible(node)
	
	# Add special material if needed
	_apply_interface_materials_to_node(node)

func _apply_overlay_layer(node: Node3D) -> void:
	"""Apply overlay layer properties - absolute top"""
	_make_always_visible(node)
	_apply_overlay_materials_to_node(node)

func _make_always_visible(node: Node3D) -> void:
	"""Make node always visible regardless of occlusion"""
	# Traverse all MeshInstance3D children
	_apply_always_visible_recursive(node)

func _apply_always_visible_recursive(node: Node) -> void:
	"""Recursively apply always-visible materials"""
	if node is MeshInstance3D:
		var mesh_instance = node as MeshInstance3D
		
		# Create or get material that renders on top
		var always_visible_material = _get_always_visible_material()
		
		# Store original material for restoration if needed
		if not mesh_instance.has_meta("original_material"):
			mesh_instance.set_meta("original_material", mesh_instance.material_override)
		
		# Apply always-visible material
		mesh_instance.material_override = always_visible_material
		
		# Ensure it's in the interface layer for rendering
		if mesh_instance.get_layer_mask() != 0:
			mesh_instance.set_layer_mask(2)  # Layer 2 for interface
	
	# Apply to children
	for child in node.get_children():
		_apply_always_visible_recursive(child)

func _get_always_visible_material() -> StandardMaterial3D:
	"""Get or create material that's always visible"""
	var material = MaterialLibrary.get_material("default")
	
	# Disable depth testing so it renders on top
	material.flags_unshaded = true
	material.flags_disable_depth_test = true
	material.flags_depth_draw_opaque = false
	material.no_depth_test = true
	
	# Keep original colors but ensure visibility
	material.albedo_color = Color.WHITE
	material.emission_enabled = true
	material.emission = Color(0.3, 0.3, 0.3)  # Slight glow for visibility
	
	return material

func _setup_interface_materials() -> void:
	"""Setup materials for interface layer"""
	# This creates the base materials we'll use
	print("[LayerSystem] Interface materials ready")

func _apply_interface_materials_to_node(node: Node3D) -> void:
	"""Apply interface materials to a specific node"""
	# Mark as interface layer
	node.set_meta("layer_type", "interface")
	
	# Apply always-visible properties
	_make_always_visible(node)

func _apply_overlay_materials_to_node(node: Node3D) -> void:
	"""Apply overlay materials to a specific node"""
	node.set_meta("layer_type", "overlay")
	_make_always_visible(node)

func _reset_node_rendering(node: Node3D) -> void:
	"""Reset node to normal rendering"""
	_reset_rendering_recursive(node)

func _reset_rendering_recursive(node: Node) -> void:
	"""Recursively reset rendering properties"""
	if node is MeshInstance3D:
		var mesh_instance = node as MeshInstance3D
		
		# Restore original material if available
		if mesh_instance.has_meta("original_material"):
			mesh_instance.material_override = mesh_instance.get_meta("original_material")
			mesh_instance.remove_meta("original_material")
		
		# Reset layer mask
		mesh_instance.set_layer_mask(1)  # Back to layer 1
	
	for child in node.get_children():
		_reset_rendering_recursive(child)

# Auto-detection and layer assignment
func auto_assign_gizmo_to_interface_layer() -> void:
	"""Automatically find and assign gizmo to interface layer"""
	var gizmos = get_tree().get_nodes_in_group("universal_gizmo_system")
	for gizmo in gizmos:
		add_to_layer(gizmo, LayerType.INTERFACE)
		print("[LayerSystem] Auto-assigned gizmo to interface layer")

func auto_assign_interface_beings() -> void:
	"""Find and assign interface beings to appropriate layers"""
	# Find all gizmo components
	var components = get_tree().get_nodes_in_group("gizmo_components")
	for comp in components:
		if comp is Node3D:
			add_to_layer(comp, LayerType.INTERFACE)

# Console commands
func cmd_layer_add(args: Array) -> String:
	"""Add object to layer: layer_add <object_name> <layer>"""
	if args.size() < 2:
		return "Usage: layer_add <object_name> <world|interface|overlay>"
	
	var object_name = args[0]
	var layer_name = args[1].to_lower()
	
	# Find object
	var obj = _find_object_by_name(object_name)
	if not obj:
		return "❌ Object not found: " + object_name
	
	# Parse layer
	var layer = LayerType.WORLD
	match layer_name:
		"world":
			layer = LayerType.WORLD
		"interface":
			layer = LayerType.INTERFACE
		"overlay":
			layer = LayerType.OVERLAY
		_:
			return "❌ Invalid layer. Use: world, interface, or overlay"
	
	add_to_layer(obj, layer)
	return "✅ Added " + object_name + " to " + layer_name + " layer"

func cmd_layer_list(_args: Array) -> String:
	"""List objects in each layer"""
	var output = "🎭 LAYER SYSTEM STATUS\n"
	output += "====================\n\n"
	
	for layer_type in LayerType.values():
		var layer_name = LayerType.keys()[layer_type]
		var objects = layer_groups[layer_type]
		
		output += "📁 " + layer_name + " Layer (" + str(objects.size()) + " objects):\n"
		for obj in objects:
			if is_instance_valid(obj):
				output += "   • " + obj.name + "\n"
		output += "\n"
	
	return output

func cmd_layer_gizmo(_args: Array) -> String:
	"""Put gizmo and interface elements on interface layer"""
	auto_assign_gizmo_to_interface_layer()
	auto_assign_interface_beings()
	return "✅ Gizmo and interface elements moved to interface layer (always visible)"

func cmd_layer_show(args: Array) -> String:
	"""Show/hide specific layers"""
	if args.is_empty():
		return "Usage: layer_show <world|interface|overlay> <on|off>"
	
	var layer_name = args[0].to_lower()
	var should_show = true
	if args.size() > 1:
		should_show = args[1].to_lower() == "on"
	
	var layer_type = LayerType.WORLD
	match layer_name:
		"world":
			layer_type = LayerType.WORLD
		"interface":
			layer_type = LayerType.INTERFACE
		"overlay":
			layer_type = LayerType.OVERLAY
		_:
			return "❌ Invalid layer: " + layer_name
	
	# Toggle visibility for all objects in layer
	var count = 0
	for obj in layer_groups[layer_type]:
		if is_instance_valid(obj):
			obj.visible = should_show
			count += 1
	
	return "✅ " + layer_name.capitalize() + " layer " + ("shown" if should_show else "hidden") + " (" + str(count) + " objects)"

func _find_object_by_name(object_name: String) -> Node3D:
	"""Find object by name"""
	# Try gizmo components first
	var components = get_tree().get_nodes_in_group("gizmo_components")
	for comp in components:
		if comp.name == object_name and comp is Node3D:
			return comp
	
	# Try spawned objects
	var spawned = get_tree().get_nodes_in_group("spawned_objects")
	for obj in spawned:
		if obj.name == object_name and obj is Node3D:
			return obj
	
	# Try universal beings
	var beings = get_tree().get_nodes_in_group("universal_beings")
	for being in beings:
		if being.name == object_name and being is Node3D:
			return being
	
	return null