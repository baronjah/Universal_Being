extends Node3D
class_name GemmaRayVisualizer

# Connected to: autoloads/GemmaAI.gd (16-ray perception system)
# Uses: scripts/GemmaSpatialPerception.gd (spatial awareness)
# Required by: beings/GemmaAICompanionPlasmoid.gd (AI vision display)

## Make Gemma's 16-ray Fibonacci sphere vision VISIBLE
## Shows what the AI sees - her perception rays as colored lines in 3D space

var gemma_ai: Node
var ray_lines: Array[MeshInstance3D] = []
var debug_enabled: bool = false
var ray_material: StandardMaterial3D
var hit_indicators: Array[MeshInstance3D] = []

signal ray_visualization_toggled(enabled: bool)

func _ready():
	gemma_ai = get_node_or_null("/root/GemmaAI")
	if not gemma_ai:
		push_error("GemmaRayVisualizer: Cannot find GemmaAI autoload!")
		return
	
	create_ray_materials()
	print("👁️ Gemma Ray Visualizer: Ready to show AI vision!")

func create_ray_materials():
	"""Create materials for different ray states"""
	ray_material = StandardMaterial3D.new()
	ray_material.albedo_color = Color.CYAN
	ray_material.emission_enabled = true
	ray_material.emission = Color.CYAN * 0.5
	ray_material.flags_unshaded = true
	ray_material.flags_transparent = true

func toggle_visualization():
	"""Toggle visibility of Gemma's 16-ray perception system"""
	debug_enabled = !debug_enabled
	
	if debug_enabled:
		create_ray_visualization()
		print("👁️ Gemma's 16-ray vision: VISIBLE")
	else:
		clear_ray_visualization()
		print("👁️ Gemma's 16-ray vision: HIDDEN")
	
	ray_visualization_toggled.emit(debug_enabled)

func create_ray_visualization():
	"""Create visual representation of all 16 Fibonacci sphere rays"""
	if not gemma_ai or not gemma_ai.has("vision_rays"):
		return
	
	clear_ray_visualization()
	
	for i in range(gemma_ai.vision_rays.size()):
		var ray_data = gemma_ai.vision_rays[i]
		create_ray_line(i, ray_data)

func create_ray_line(index: int, ray_data: Dictionary):
	"""Create a visual line for one perception ray"""
	var mesh_instance = MeshInstance3D.new()
	var line_mesh = QuadMesh.new()
	
	# Create thin line geometry
	line_mesh.size = Vector2(0.05, gemma_ai.vision_range)
	
	# Material based on ray properties
	var material = ray_material.duplicate()
	
	# Color by focus weight and spiral index
	var focus_weight = ray_data.get("focus_weight", 0.5)
	var base_color = Color.CYAN.lerp(Color.YELLOW, focus_weight)
	
	# Add spiral index variation
	var spiral_hue = (ray_data.get("spiral_index", 0) % 16) / 16.0
	var spiral_color = Color.from_hsv(spiral_hue, 0.7, 1.0)
	material.albedo_color = base_color.lerp(spiral_color, 0.3)
	material.emission = material.albedo_color * 0.8
	
	mesh_instance.mesh = line_mesh
	mesh_instance.material_override = material
	
	# Position and orient the ray
	var direction = ray_data.get("direction", Vector3.FORWARD)
	mesh_instance.position = direction * gemma_ai.vision_range * 0.5
	mesh_instance.look_at(global_position + direction, Vector3.UP)
	mesh_instance.rotate_object_local(Vector3.RIGHT, PI/2)
	
	add_child(mesh_instance)
	ray_lines.append(mesh_instance)
	
	# Create hit indicator if ray hit something
	if ray_data.get("last_hit"):
		create_hit_indicator(index, ray_data)

func create_hit_indicator(index: int, ray_data: Dictionary):
	"""Create visual indicator where ray hit an object"""
	var hit_sphere = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.2
	sphere_mesh.height = 0.4
	
	var hit_material = StandardMaterial3D.new()
	hit_material.albedo_color = Color.RED
	hit_material.emission_enabled = true
	hit_material.emission = Color.RED * 0.5
	
	hit_sphere.mesh = sphere_mesh
	hit_sphere.material_override = hit_material
	
	# Position at hit location
	var direction = ray_data.get("direction", Vector3.FORWARD)
	var distance = ray_data.get("distance", gemma_ai.vision_range)
	hit_sphere.position = direction * distance
	
	add_child(hit_sphere)
	hit_indicators.append(hit_sphere)

func update_ray_visualization():
	"""Update visualization with current ray data from Gemma"""
	if not debug_enabled or not gemma_ai:
		return
	
	# Update ray colors based on current focus weights
	for i in range(min(ray_lines.size(), gemma_ai.vision_rays.size())):
		var ray_data = gemma_ai.vision_rays[i]
		var ray_line = ray_lines[i]
		
		if ray_line and is_instance_valid(ray_line):
			var material = ray_line.material_override as StandardMaterial3D
			if material:
				var focus_weight = ray_data.get("focus_weight", 0.5)
				var new_color = Color.CYAN.lerp(Color.YELLOW, focus_weight)
				material.albedo_color = new_color
				material.emission = new_color * 0.8

func clear_ray_visualization():
	"""Remove all ray visualization objects"""
	for ray_line in ray_lines:
		if is_instance_valid(ray_line):
			ray_line.queue_free()
	
	for hit_indicator in hit_indicators:
		if is_instance_valid(hit_indicator):
			hit_indicator.queue_free()
	
	ray_lines.clear()
	hit_indicators.clear()

func _process(delta):
	"""Update visualization every frame when enabled"""
	if debug_enabled:
		update_ray_visualization()

func _input(event):
	"""Toggle visualization with V key"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_V:
			toggle_visualization()

func show_ray_debug_info():
	"""Print debug information about current rays"""
	if not gemma_ai or not gemma_ai.has("vision_rays"):
		print("👁️ No vision ray data available")
		return
	
	print("👁️ Gemma's 16-Ray Vision Debug:")
	print("  Total Rays: ", gemma_ai.vision_rays.size())
	print("  Vision Range: ", gemma_ai.vision_range)
	print("  Focus Direction: ", gemma_ai.current_focus_direction)
	
	var hits = 0
	for ray in gemma_ai.vision_rays:
		if ray.get("last_hit"):
			hits += 1
	
	print("  Rays Hitting Objects: ", hits, "/", gemma_ai.vision_rays.size())
	print("  Spatial Data: ", gemma_ai.spatial_data.keys() if gemma_ai.has("spatial_data") else "None")