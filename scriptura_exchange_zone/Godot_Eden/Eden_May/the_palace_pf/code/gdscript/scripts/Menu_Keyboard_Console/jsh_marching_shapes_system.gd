extends Node
class_name JSHDataGrid
# res://code/gdscript/scripts/Menu_Keyboard_Console/jsh_marching_shapes_system.gd
# JSH_World/JSH_Marching_Shapes_System

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
## file name?
## how would i know, i had one empty, we shall call it also :
## jsh_marching_shapes_system
## in certain shape, and frequency, so fractals of distance?
## of attentions and pathways 3d

## also some new data to be added now lol 

#extends Node3D

# References
var task_manager = null
var data_grid = null

# Test patterns
enum DataPattern {
	WAVE,
	RIPPLE,
	RANDOM,
	GRADIENT,
	MOUNTAIN
}

# Configuration
var current_pattern = DataPattern.WAVE
var update_interval = 0.5
var grid_size = 10
var time_elapsed = 0.0
var animation_time = 0.0


#####################
# Signals
signal grid_updated
signal cell_selected(x, y, value)
signal data_threshold_reached(threshold_type, value)

# Grid properties
var grid_width = 10
var grid_height = 10
var cell_size = 0.2
var cell_spacing = 0.05
var grid_depth = 0.5  # Maximum height for values
var value_scale = 1.0 # Multiplier for visual height

# Visualization properties
var use_color_gradient = true
var min_color = 0.2  # For get_spectrum_color
var max_color = 0.8  # For get_spectrum_color
var base_opacity = 0.8
var highlight_opacity = 1.0
var animation_speed = 1.0

# Data properties
var grid_data = []
var current_min_value = 0.0
var current_max_value = 0.0
var data_label = "Value"
var data_units = ""

# Node references
var cells = []
var labels = []
var grid_container = null
var x_axis_labels = []
var y_axis_labels = []
var title_label = null
var info_panel = null

# References to other systems
var main_scene_reference = null
#var task_manager = null

#####################

## another addition

## some split needed :


#extends Node3D
#class_name JSHMarchingShapes

# Signals
signal mesh_generated
signal contour_changed(value)

# Configuration
#var grid_width = 32
#var grid_height = 32
#var cell_size = 0.1
var iso_level = 0.5  # Threshold for surface generation
var use_smoothing = true
var show_wireframe = false
var show_grid_points = false

# Noise parameters
var noise_scale = 5.0
var noise_octaves = 4
var noise_persistence = 0.5
var noise_lacunarity = 2.0
var noise_seed = 42
var animate_noise = false
var noise_speed = 1.0
var time_offset = 0.0

# Visual properties
var surface_color = Color(0.2, 0.6, 0.8, 1.0)
var wireframe_color = Color(0.1, 0.1, 0.1, 0.5)
var grid_point_color = Color(0.7, 0.7, 0.7, 0.3)

# Node references
var mesh_instance: MeshInstance3D
var wireframe_instance: MeshInstance3D
var grid_points_instance: MeshInstance3D
var scalar_field = []
var noise: FastNoiseLite

# References to other systems
#var main_scene_reference = null
#var task_manager = null


#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#

func _ready_add():
	setup_nodes()
	initialize_scalar_field()
	generate_mesh()
	
	# Connect to task manager if available
	task_manager = get_node_or_null("/root/JSHTaskManager")
	if task_manager:
		print("Marching shapes connected to task manager")


func _process_add(delta):
	if animate_noise:
		time_offset += delta * noise_speed
		update_scalar_field()
		generate_mesh()



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#





func _ready_old():
	# Initialize task manager if not already present
	setup_task_manager()
	
	# Create the data grid
	create_data_grid()
	
	# Create UI controls for testing
	create_pattern_controls()
	
	# Start update timer
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = update_interval
	timer.timeout.connect(_on_update_timer)
	timer.start()

func _process_old(delta):
	time_elapsed += delta
	animation_time += delta

# Public methods
func _ready_old_0():
	initialize_grid()
	
	# Connect to task manager if available
	task_manager = get_node_or_null("/root/JSHTaskManager")
	if task_manager:
		print("Data grid connected to task manager")



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#

func add_quad_seven(vertices, indices, v1, v2, v3, v4, v5):#(vertices, indices, v1, v2, v3, v4):
	var index = vertices.size()
	vertices.append(v1)
	vertices.append(v2)
	vertices.append(v3)
	vertices.append(v4)
	
	# First triangle
	indices.append(index)
	indices.append(index + 1)
	indices.append(index + 2)
	
	# Second triangle
	indices.append(index)
	indices.append(index + 2)
	indices.append(index + 3)
	print(" add_quad_seven ")



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓                 ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃ ┏┓┏┓┏┓┏┓┏┓┓┏┓   ┗┓┓┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗ ┗ ┛┗┗┫┛┗┗┗    ┗┛┗┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888               ┛                ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#



# Setup the necessary nodes
func setup_nodes():
	# Create mesh instance for the surface
	mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "SurfaceMesh"
	add_child(mesh_instance)
	
	# Set material
	var material = StandardMaterial3D.new()
	material.albedo_color = surface_color
	material.metallic_specular = 0.2
	material.roughness = 0.7
	mesh_instance.material_override = material
	
	# Create wireframe instance
	wireframe_instance = MeshInstance3D.new()
	wireframe_instance.name = "WireframeMesh"
	add_child(wireframe_instance)
	
	var wireframe_material = StandardMaterial3D.new()
	wireframe_material.albedo_color = wireframe_color
	wireframe_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wireframe_instance.material_override = wireframe_material
	wireframe_instance.visible = show_wireframe
	
	# Create grid points instance
	grid_points_instance = MeshInstance3D.new()
	grid_points_instance.name = "GridPoints"
	add_child(grid_points_instance)
	
	var points_material = StandardMaterial3D.new()
	points_material.albedo_color = grid_point_color
	points_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	grid_points_instance.material_override = points_material
	grid_points_instance.visible = show_grid_points
	
	# Initialize noise generator
	noise = FastNoiseLite.new()
	noise.seed = noise_seed
	noise.frequency = 1.0 / noise_scale
	noise.fractal_octaves = noise_octaves
	noise.fractal_lacunarity = noise_lacunarity
	noise.fractal_gain = noise_persistence

# Initialize the scalar field with noise
func initialize_scalar_field():
	scalar_field = []
	
	for y in range(grid_height + 1):
		var row = []
		for x in range(grid_width + 1):
			var value = get_noise_value(x, y)
			row.append(value)
		scalar_field.append(row)

# Update the scalar field (used during animation)
func update_scalar_field():
	for y in range(grid_height + 1):
		for x in range(grid_width + 1):
			scalar_field[y][x] = get_noise_value(x, y)

# Get noise value at a specific position
func get_noise_value(x, y):
	var nx = float(x) / grid_width
	var ny = float(y) / grid_height
	
	# Apply time offset for animation
	var value = noise.get_noise_2d(nx * noise_scale + time_offset, ny * noise_scale) * 0.5 + 0.5
	return value

# Generate the mesh using marching squares algorithm
func generate_mesh():
	# Create ArrayMesh for the main surface
	var surface_mesh = ArrayMesh.new()
	var wireframe_mesh = ArrayMesh.new()
	var points_mesh = ArrayMesh.new()
	
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
	var wireframe_vertices = PackedVector3Array()
	var points_vertices = PackedVector3Array()
	
	# Generate the grid points visualization
	if show_grid_points:
		for y in range(grid_height + 1):
			for x in range(grid_width + 1):
				var value = scalar_field[y][x]
				var position = Vector3(x * cell_size, value * cell_size * 2, y * cell_size)
				points_vertices.append(position)
	
	# Generate the mesh using marching squares
	for y in range(grid_height):
		for x in range(grid_width):
			# Get the four corners of this cell
			var top_left = scalar_field[y][x]
			var top_right = scalar_field[y][x+1]
			var bottom_left = scalar_field[y+1][x]
			var bottom_right = scalar_field[y+1][x+1]
			
			# Determine cell configuration based on iso level
			var cell_type = 0
			if top_left > iso_level: cell_type |= 1
			if top_right > iso_level: cell_type |= 2
			if bottom_right > iso_level: cell_type |= 4
			if bottom_left > iso_level: cell_type |= 8
			
			# Skip empty cells
			if cell_type == 0 or cell_type == 15:
				continue
				
			# Calculate positions
			var top = lerp_vertex(x, y, x+1, y, top_left, top_right)
			var right = lerp_vertex(x+1, y, x+1, y+1, top_right, bottom_right)
			var bottom = lerp_vertex(x, y+1, x+1, y+1, bottom_left, bottom_right)
			var left = lerp_vertex(x, y, x, y+1, top_left, bottom_left)
			
			# Add triangles based on cell configuration
			match cell_type:
				# One corner cases
				1: # Top-left
					add_triangle(vertices, indices, left, top, Vector3(x * cell_size, top_left * cell_size * 2, y * cell_size))
				2: # Top-right
					add_triangle(vertices, indices, top, right, Vector3((x+1) * cell_size, top_right * cell_size * 2, y * cell_size))
				4: # Bottom-right
					add_triangle(vertices, indices, right, bottom, Vector3((x+1) * cell_size, bottom_right * cell_size * 2, (y+1) * cell_size))
				8: # Bottom-left
					add_triangle(vertices, indices, bottom, left, Vector3(x * cell_size, bottom_left * cell_size * 2, (y+1) * cell_size))
				
				# Two corner cases (adjacent)
				3: # Top-left and top-right
					add_quad_seven(vertices, indices, left, top, right, Vector3(x * cell_size, top_left * cell_size * 2, y * cell_size), 
							 Vector3((x+1) * cell_size, top_right * cell_size * 2, y * cell_size))
				5: # Top-left and bottom-right
					add_quad(vertices, indices, left, top, right, bottom)
				6: # Top-right and bottom-right
					add_quad_seven(vertices, indices, top, right, bottom, Vector3((x+1) * cell_size, top_right * cell_size * 2, y * cell_size),
							 Vector3((x+1) * cell_size, bottom_right * cell_size * 2, (y+1) * cell_size))
				9: # Top-left and bottom-left
					add_quad_seven(vertices, indices, top, left, bottom, Vector3(x * cell_size, top_left * cell_size * 2, y * cell_size),
							 Vector3(x * cell_size, bottom_left * cell_size * 2, (y+1) * cell_size))
				10: # Top-right and bottom-left
					add_quad(vertices, indices, top, right, bottom, left)
				12: # Bottom-left and bottom-right
					add_quad_seven(vertices, indices, left, bottom, right, Vector3(x * cell_size, bottom_left * cell_size * 2, (y+1) * cell_size),
							 Vector3((x+1) * cell_size, bottom_right * cell_size * 2, (y+1) * cell_size))
				
				# Three corner cases
				7: # All except bottom-left
					add_pentagon_nine(vertices, indices, left, top, right, bottom, Vector3(x * cell_size, top_left * cell_size * 2, y * cell_size),
								Vector3((x+1) * cell_size, top_right * cell_size * 2, y * cell_size),
								Vector3((x+1) * cell_size, bottom_right * cell_size * 2, (y+1) * cell_size))
				11: # All except bottom-right
					add_pentagon_nine(vertices, indices, top, right, bottom, left, Vector3(x * cell_size, top_left * cell_size * 2, y * cell_size),
								Vector3((x+1) * cell_size, top_right * cell_size * 2, y * cell_size),
								Vector3(x * cell_size, bottom_left * cell_size * 2, (y+1) * cell_size))
				13: # All except top-right
					add_pentagon_nine(vertices, indices, right, bottom, left, top, Vector3(x * cell_size, top_left * cell_size * 2, y * cell_size),
								Vector3((x+1) * cell_size, bottom_right * cell_size * 2, (y+1) * cell_size),
								Vector3(x * cell_size, bottom_left * cell_size * 2, (y+1) * cell_size))
				14: # All except top-left
					add_pentagon_nine(vertices, indices, bottom, left, top, right, Vector3((x+1) * cell_size, top_right * cell_size * 2, y * cell_size),
								Vector3((x+1) * cell_size, bottom_right * cell_size * 2, (y+1) * cell_size),
								Vector3(x * cell_size, bottom_left * cell_size * 2, (y+1) * cell_size))
			
			# Add wireframe outline if enabled
			if show_wireframe:
				match cell_type:
					1, 2, 4, 8: # Single corner cases
						add_wireframe_line(wireframe_vertices, top, left) if cell_type == 1 else null
						add_wireframe_line(wireframe_vertices, top, right) if cell_type == 2 else null
						add_wireframe_line(wireframe_vertices, right, bottom) if cell_type == 4 else null
						add_wireframe_line(wireframe_vertices, bottom, left) if cell_type == 8 else null
					3, 5, 6, 9, 10, 12: # Two corner cases
						add_wireframe_line(wireframe_vertices, left, right) if cell_type == 3 else null
						add_wireframe_line(wireframe_vertices, top, bottom) if cell_type == 5 or cell_type == 10 else null
						add_wireframe_line(wireframe_vertices, top, bottom) if cell_type == 6 else null
						add_wireframe_line(wireframe_vertices, top, bottom) if cell_type == 9 else null
						add_wireframe_line(wireframe_vertices, left, right) if cell_type == 12 else null
					7, 11, 13, 14: # Three corner cases - complex wireframes
						add_wireframe_line(wireframe_vertices, left, bottom) if cell_type == 7 else null
						add_wireframe_line(wireframe_vertices, right, bottom) if cell_type == 11 else null
						add_wireframe_line(wireframe_vertices, right, top) if cell_type == 13 else null
						add_wireframe_line(wireframe_vertices, left, top) if cell_type == 14 else null
	
	# Create surface mesh
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	
	if vertices.size() > 0:
		surface_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		
		# Optionally smooth the mesh
		if use_smoothing:
			var st = SurfaceTool.new()
			st.create_from(surface_mesh, 0)
			st.generate_normals()
			surface_mesh = st.commit()
	
	# Create wireframe mesh
	if show_wireframe and wireframe_vertices.size() > 0:
		var wireframe_arrays = []
		wireframe_arrays.resize(Mesh.ARRAY_MAX)
		wireframe_arrays[Mesh.ARRAY_VERTEX] = wireframe_vertices
		wireframe_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, wireframe_arrays)
	
	# Create points mesh
	if show_grid_points and points_vertices.size() > 0:
		var points_arrays = []
		points_arrays.resize(Mesh.ARRAY_MAX)
		points_arrays[Mesh.ARRAY_VERTEX] = points_vertices
		points_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, points_arrays)
	
	# Assign meshes to instances
	mesh_instance.mesh = surface_mesh
	wireframe_instance.mesh = wireframe_mesh
	grid_points_instance.mesh = points_mesh
	
	emit_signal("mesh_generated")
	
	# Track in task manager
	if task_manager and task_manager.has_method("track_data_flow"):
		task_manager.track_data_flow(
			"MarchingShapes", 
			"MeshSystem", 
			"mesh_generation", 
			vertices.size()
		)

# Set the iso level (contour value)
func set_iso_level(value):
	iso_level = clamp(value, 0.0, 1.0)
	generate_mesh()
	emit_signal("contour_changed", iso_level)

# Helper function to linearly interpolate between vertices
func lerp_vertex(x1, y1, x2, y2, val1, val2):
	if abs(iso_level - val1) < 0.00001:
		return Vector3(x1 * cell_size, val1 * cell_size * 2, y1 * cell_size)
		
	if abs(iso_level - val2) < 0.00001:
		return Vector3(x2 * cell_size, val2 * cell_size * 2, y2 * cell_size)
		
	if abs(val1 - val2) < 0.00001:
		return Vector3(x1 * cell_size, val1 * cell_size * 2, y1 * cell_size)
	
	# Calculate interpolation factor
	var t = (iso_level - val1) / (val2 - val1)
	
	# Interpolate x, y positions
	var x = lerp(x1, x2, t)
	var y = lerp(y1, y2, t)
	
	# Calculate height at the interpolated position
	var height = lerp(val1, val2, t)
	
	return Vector3(x * cell_size, height * cell_size * 2, y * cell_size)

# Add a triangle to the mesh
func add_triangle(vertices, indices, v1, v2, v3):
	var index = vertices.size()
	vertices.append(v1)
	vertices.append(v2)
	vertices.append(v3)
	
	indices.append(index)
	indices.append(index + 1)
	indices.append(index + 2)

# Add a quad (two triangles) to the mesh
func add_quad(vertices, indices, v1, v2, v3, v4):
	var index = vertices.size()
	vertices.append(v1)
	vertices.append(v2)
	vertices.append(v3)
	vertices.append(v4)
	
	# First triangle
	indices.append(index)
	indices.append(index + 1)
	indices.append(index + 2)
	
	# Second triangle
	indices.append(index)
	indices.append(index + 2)
	indices.append(index + 3)


func add_pentagon_nine(vertices, indices, v1, v2, v3, v4, v5, v6, v7):
	var index = vertices.size()
	vertices.append(v1)
	vertices.append(v2)
	vertices.append(v3)
	vertices.append(v4)
	vertices.append(v5)
	
	# Three triangles to form the pentagon
	indices.append(index)
	indices.append(index + 1)
	indices.append(index + 2)
	
	indices.append(index)
	indices.append(index + 2)
	indices.append(index + 3)
	
	indices.append(index)
	indices.append(index + 3)
	indices.append(index + 4)

# Add a pentagon (three triangles) to the mesh
func add_pentagon(vertices, indices, v1, v2, v3, v4, v5):
	var index = vertices.size()
	vertices.append(v1)
	vertices.append(v2)
	vertices.append(v3)
	vertices.append(v4)
	vertices.append(v5)
	
	# Three triangles to form the pentagon
	indices.append(index)
	indices.append(index + 1)
	indices.append(index + 2)
	
	indices.append(index)
	indices.append(index + 2)
	indices.append(index + 3)
	
	indices.append(index)
	indices.append(index + 3)
	indices.append(index + 4)

# Add a wireframe line
func add_wireframe_line(wireframe_vertices, start, end):
	wireframe_vertices.append(start)
	wireframe_vertices.append(end)

# Set the noise parameters
func set_noise_parameters(scale, octaves, persistence, lacunarity, seed_value):
	noise_scale = scale
	noise_octaves = octaves
	noise_persistence = persistence
	noise_lacunarity = lacunarity
	noise_seed = seed_value
	
	# Update noise generator
	noise.seed = noise_seed
	noise.frequency = 1.0 / noise_scale
	noise.fractal_octaves = noise_octaves
	noise.fractal_lacunarity = noise_lacunarity
	noise.fractal_gain = noise_persistence
	
	# Regenerate the field and mesh
	initialize_scalar_field()
	generate_mesh()

# Toggle animation
func set_animation(enabled, speed = 1.0):
	animate_noise = enabled
	noise_speed = speed

# Toggle wireframe display
func set_wireframe(enabled):
	show_wireframe = enabled
	wireframe_instance.visible = enabled
	generate_mesh()  # Regenerate to include/exclude wireframe data

# Toggle grid points display
func set_grid_points(enabled):
	show_grid_points = enabled
	grid_points_instance.visible = enabled
	generate_mesh()  # Regenerate to include/exclude point data

# Set up reference to main scene
func setup_main_reference(main_ref):
	main_scene_reference = main_ref
	
	# If main reference has get_spectrum_color, use it for surface color
	if main_scene_reference and main_scene_reference.has_method("get_spectrum_color"):
		var material = mesh_instance.material_override
		material.albedo_color = main_scene_reference.get_spectrum_color(0.6)


func generate_gradient_pattern(data):
	for y in range(grid_size):
		for x in range(grid_size):
			# Create a simple diagonal gradient
			var nx = float(x) / grid_size
			var ny = float(y) / grid_size
			
			# Diagonal gradient from bottom-left to top-right
			var value = (nx + ny) / 2.0
			data[y][x] = value

func generate_mountain_pattern(data):
	# Generate terrain-like pattern with noise
	var noise = FastNoiseLite.new()
	noise.seed = int(Time.get_unix_time_from_system() * 1000) % 1000000
	noise.frequency = 0.1
	noise.fractal_octaves = 4
	
	for y in range(grid_size):
		for x in range(grid_size):
			var nx = float(x) / grid_size
			var ny = float(y) / grid_size
			
			# Create mountain pattern with noise and some peaks
			var base_noise = noise.get_noise_2d(x * 3, y * 3) * 0.5 + 0.5
			
			# Add some peaks
			var dist_from_center = sqrt(pow((nx - 0.5), 2) + pow((ny - 0.5), 2)) * 2
			var peak_factor = max(0, 1 - dist_from_center)
			
			var value = base_noise * 0.7 + peak_factor * 0.3
			data[y][x] = value

func generate_random_pattern(data):
	# Use noise for smoother random pattern
	var noise = FastNoiseLite.new()
	noise.seed = int(Time.get_unix_time_from_system() * 1000) % 1000000
	noise.frequency = 0.2
	
	for y in range(grid_size):
		for x in range(grid_width):
			# Create random pattern that changes with time
			var value = noise.get_noise_2d(x + animation_time * 5, y + animation_time * 3) * 0.5 + 0.5
			data[y][x] = value

func setup_task_manager():
	# Check if task manager exists
	task_manager = get_node_or_null("/root/JSHTaskManager")
	
	if not task_manager:
		# Create and add task manager
		task_manager = load("res://scripts/jsh_task_manager.gd").new()
		task_manager.name = "JSHTaskManager"
		get_tree().root.add_child(task_manager)
		print("Task Manager created")

func create_data_grid():
	# Create the data grid node
	data_grid = JSHDataGrid.new()
	data_grid.name = "DataGrid"
	add_child(data_grid)
	
	# Set grid properties
	data_grid.grid_width = grid_size
	data_grid.grid_height = grid_size
	data_grid.setup_main_reference(self)
	
	# Set initial data
	var initial_data = generate_data(current_pattern)
	data_grid.set_data(initial_data)
	
	# Position the grid
	data_grid.position = Vector3(0, 1, 0)
	
	# Set data labels
	data_grid.set_data_properties("Amplitude", "")
	data_grid.set_title("Dynamic Data Visualization: Wave Pattern")
	
	# Connect signals
	data_grid.cell_selected.connect(_on_cell_selected)

func create_pattern_controls():
	# Create a simple panel with buttons to switch patterns
	var control_panel = Node3D.new()
	control_panel.name = "ControlPanel"
	add_child(control_panel)
	
	# Position above the grid
	control_panel.position = Vector3(0, 2.5, -2)
	
	# Create buttons for each pattern
	var button_width = 0.5
	var spacing = 0.1
	var total_width = (button_width + spacing) * DataPattern.size()
	
	for i in range(DataPattern.size()):
		var pattern_name = DataPattern.keys()[i]
		var x_pos = (i - DataPattern.size()/2.0 + 0.5) * (button_width + spacing)
		
		var button = create_pattern_button(pattern_name, Vector3(x_pos, 0, 0), i)
		control_panel.add_child(button)

func create_pattern_button(label_text, position, pattern_index):
	var button = Node3D.new()
	button.name = "Button_" + label_text
	button.position = position
	
	# Create button mesh
	var button_mesh = MeshInstance3D.new()
	button.add_child(button_mesh)
	
	var quad = QuadMesh.new()
	quad.size = Vector2(0.5, 0.2)
	button_mesh.mesh = quad
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.3, 0.8, 0.8)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	button_mesh.material_override = material
	
	# Add label
	var text = Label3D.new()
	button.add_child(text)
	text.text = label_text
	text.font_size = 10
	text.position.z = 0.01
	
	# Add collision shape for interaction
	var area = Area3D.new()
	button.add_child(area)
	
	var collision = CollisionShape3D.new()
	area.add_child(collision)
	
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(0.5, 0.2, 0.05)
	collision.shape = box_shape
	
	# Connect signal for click
	area.input_event.connect(func(camera, event, pos, normal, shape_idx):
		if event is InputEventMouseButton:
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_on_pattern_selected(pattern_index)
	)
	
	return button

func _on_pattern_selected(pattern_index):
	current_pattern = pattern_index
	
	# Update the title
	var pattern_name = DataPattern.keys()[pattern_index]
	data_grid.set_title("Dynamic Data Visualization: " + pattern_name + " Pattern")
	
	# Reset animation time
	animation_time = 0.0
	
	# Generate and set new data with animation
	var new_data = generate_data(current_pattern)
	data_grid.animate_to_new_data(new_data, 1.0)
	
	# Record in task manager
	if task_manager and task_manager.has_method("track_data_flow"):
		task_manager.track_data_flow(
			"PatternControl", 
			"DataGrid", 
			"pattern_change", 
			1.0
		)

func _on_update_timer():
	# Generate new data based on current pattern and time
	var new_data = generate_data(current_pattern)
	data_grid.set_data(new_data)

func _on_cell_selected(x, y, value):
	print("Cell selected: (%d, %d) = %f" % [x, y, value])
	
	# You could toggle a special state for this cell
	# For now, let's just highlight it briefly
	data_grid.highlight_cell(x, y, true)
	
	# Create a timer to turn off highlight
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.5
	timer.one_shot = true
	timer.timeout.connect(func(): data_grid.highlight_cell(x, y, false))
	timer.start()

func generate_data(pattern):
	var data = []
	
	# Initialize data array
	for y in range(grid_size):
		var row = []
		for x in range(grid_size):
			row.append(0.0)
		data.append(row)
	
	# Fill with pattern
	match pattern:
		DataPattern.WAVE:
			generate_wave_pattern(data)
		DataPattern.RIPPLE:
			generate_ripple_pattern(data)
		DataPattern.RANDOM:
			generate_random_pattern(data)
		DataPattern.GRADIENT:
			generate_gradient_pattern(data)
		DataPattern.MOUNTAIN:
			generate_mountain_pattern(data)
	
	return data

func generate_gradient_pattern_old(data):
	print(" generate_gradient_patter ", data)


func generate_mountain_pattern_old(data):
	print(" generate mountain patter " , data)

func generate_wave_pattern(data):
	for y in range(grid_size):
		for x in range(grid_size):
			var nx = float(x) / grid_size
			var ny = float(y) / grid_size
			
			# Create wave pattern
			var value = sin(nx * 4 + animation_time) * cos(ny * 4 + animation_time * 0.7) * 0.5 + 0.5
			data[y][x] = value

func generate_ripple_pattern(data):
	var center_x = grid_size / 2.0
	var center_y = grid_size / 2.0
	
	for y in range(grid_size):
		for x in range(grid_size):
			var dx = x - center_x
			var dy = y - center_y
			var distance = sqrt(dx*dx + dy*dy) / grid_size * 10.0
			
			# Create ripple pattern
			var value = sin(distance - animation_time * 3) * 0.5 + 0.5
			data[y][x] = value

func generate_random_pattern_old(data):
	for y in range(grid_size):
		for x in range(grid_size):
			print(" doing noise", data, x,y)
			# Use noise for


func initialize_grid():
	# Create container node
	grid_container = Node3D.new()
	grid_container.name = "GridContainer"
	add_child(grid_container)
	
	# Initialize empty data grid
	grid_data = []
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			row.append(0.0)
		grid_data.append(row)
	
	# Create visual grid
	create_grid_cells()
	create_axis_labels()
	create_title()
	create_info_panel()

func set_grid_size(width, height):
	if width == grid_width and height == grid_height:
		return
		
	grid_width = width
	grid_height = height
	
	# Clear existing grid
	clear_grid()
	
	# Recreate with new dimensions
	initialize_grid()

func set_data(data_array):
	# Check if data array matches our grid dimensions
	if data_array.size() != grid_height or data_array[0].size() != grid_width:
		print("Data dimensions don't match grid dimensions")
		return false
	
	grid_data = data_array
	
	# Find min/max values for scaling
	current_min_value = INF
	current_max_value = -INF
	
	for y in range(grid_height):
		for x in range(grid_width):
			var value = grid_data[y][x]
			current_min_value = min(current_min_value, value)
			current_max_value = max(current_max_value, value)
	
	# Update visualization
	update_grid_visualization()
	
	# Track in task manager
	if task_manager and task_manager.has_method("track_data_flow"):
		task_manager.track_data_flow(
			"DataSource", 
			"DataGrid", 
			"grid_data_update", 
			grid_width * grid_height
		)
	
	emit_signal("grid_updated")
	return true

func update_cell_value(x, y, value):
	if x < 0 or x >= grid_width or y < 0 or y >= grid_height:
		return false
	
	grid_data[y][x] = value
	
	# Update min/max if needed
	if value < current_min_value:
		current_min_value = value
	if value > current_max_value:
		current_max_value = value
	
	# Update just this cell
	update_cell_visualization(x, y)
	
	# Record this interaction
	if task_manager and task_manager.has_method("record_interaction"):
		var cell_position = cells[y][x].global_position
		task_manager.record_interaction(
			cell_position,
			"cell_update",
			{
				"x": x,
				"y": y,
				"value": value,
				"prev_min": current_min_value,
				"prev_max": current_max_value
			}
		)
	
	return true

func highlight_cell(x, y, highlight = true):
	if x < 0 or x >= grid_width or y < 0 or y >= grid_height:
		return
	
	var cell = cells[y][x]
	var material = cell.material_override
	
	if highlight:
		material.albedo_color.a = highlight_opacity
		# Option: Make it slightly larger
		cell.scale = Vector3(1.1, 1.1, 1.1)
	else:
		material.albedo_color.a = base_opacity
		cell.scale = Vector3(1.0, 1.0, 1.0)

func set_title(title_text):
	if title_label:
		title_label.text = title_text

func set_data_properties(label, units):
	data_label = label
	data_units = units
	update_info_panel()

func animate_to_new_data(new_data, duration = 1.0):
	# Store initial data for interpolation
	var initial_data = []
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			row.append(grid_data[y][x])
		initial_data.append(row)
	
	# Create a tween for smooth animation
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	
	# Custom property to track interpolation
	var interpolation_object = {"value": 0.0}
	
	# Tween the interpolation value from 0 to 1
	tween.tween_property(interpolation_object, "value", 1.0, duration)
	
	# Connect to the tween's step signal
	tween.tween_callback(func():
		var t = interpolation_object.value
		var interpolated_data = []
		
		# Create interpolated data
		for y in range(grid_height):
			var row = []
			for x in range(grid_width):
				var start_val = initial_data[y][x]
				var end_val = new_data[y][x]
				var current_val = lerp(start_val, end_val, t)
				row.append(current_val)
			interpolated_data.append(row)
		
		# Set the interpolated data
		set_data(interpolated_data)
	).set_delay(0.0)
	
	# Wait for animation to complete
	await tween.finished
	
	# Ensure we end with exactly the target data
	set_data(new_data)

# Private methods
func create_grid_cells():
	cells = []
	
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			var cell = create_cell(x, y)
			row.append(cell)
			grid_container.add_child(cell)
		cells.append(row)

func create_cell(x, y):
	var cell = MeshInstance3D.new()
	cell.name = "Cell_%d_%d" % [x, y]
	
	# Create box mesh for the cell
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(cell_size, 0.01, cell_size) # Start with minimal height
	cell.mesh = box_mesh
	
	# Position cell in grid
	var x_pos = x * (cell_size + cell_spacing) - (grid_width * (cell_size + cell_spacing)) / 2 + cell_size/2
	var y_pos = 0.0 # Will be adjusted based on value
	var z_pos = y * (cell_size + cell_spacing) - (grid_height * (cell_size + cell_spacing)) / 2 + cell_size/2
	cell.position = Vector3(x_pos, y_pos, z_pos)
	
	# Create material
	var material = StandardMaterial3D.new()
	if main_scene_reference and main_scene_reference.has_method("get_spectrum_color"):
		material.albedo_color = main_scene_reference.get_spectrum_color(min_color)
	else:
		material.albedo_color = Color(0.3, 0.5, 0.8, base_opacity)
	
	material.albedo_color.a = base_opacity
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	cell.material_override = material
	
	# Add collision for interaction
	var area = Area3D.new()
	cell.add_child(area)
	
	var collision = CollisionShape3D.new()
	area.add_child(collision)
	
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(cell_size, grid_depth, cell_size) # Full height for collision
	collision.shape = box_shape
	
	# Connect area signals
	area.input_event.connect(func(camera, event, position, normal, shape_idx): 
		_on_cell_input_event(x, y, camera, event, position, normal, shape_idx)
	)
	area.mouse_entered.connect(func(): _on_cell_mouse_entered(x, y))
	area.mouse_exited.connect(func(): _on_cell_mouse_exited(x, y))
	
	# Add value label above cell
	var label = Label3D.new()
	label.name = "Value_Label"
	label.text = "0.0"
	label.font_size = 8
	label.position = Vector3(0, grid_depth + 0.05, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.modulate = Color(1, 1, 1, 0)  # Start invisible
	cell.add_child(label)
	
	return cell

func create_axis_labels():
	# Create X-axis labels
	for x in range(grid_width):
		var label = Label3D.new()
		label.text = str(x)
		label.font_size = 10
		
		var x_pos = x * (cell_size + cell_spacing) - (grid_width * (cell_size + cell_spacing)) / 2 + cell_size/2
		var z_pos = (grid_height * (cell_size + cell_spacing)) / 2 + cell_spacing*2
		
		label.position = Vector3(x_pos, 0, z_pos)
		grid_container.add_child(label)
		x_axis_labels.append(label)
	
	# Create Y-axis labels
	for y in range(grid_height):
		var label = Label3D.new()
		label.text = str(y)
		label.font_size = 10
		
		var x_pos = -(grid_width * (cell_size + cell_spacing)) / 2 - cell_spacing*2
		var z_pos = y * (cell_size + cell_spacing) - (grid_height * (cell_size + cell_spacing)) / 2 + cell_size/2
		
		label.position = Vector3(x_pos, 0, z_pos)
		grid_container.add_child(label)
		y_axis_labels.append(label)

func create_title():
	title_label = Label3D.new()
	title_label.text = "Data Grid Visualization"
	title_label.font_size = 16
	title_label.position = Vector3(0, grid_depth + 0.2, -(grid_height * (cell_size + cell_spacing)) / 2 - cell_size)
	grid_container.add_child(title_label)

func create_info_panel():
	info_panel = Node3D.new()
	info_panel.name = "InfoPanel"
	grid_container.add_child(info_panel)
	
	# Position panel to the right of the grid
	var panel_x = (grid_width * (cell_size + cell_spacing)) / 2 + cell_size
	info_panel.position = Vector3(panel_x, 0, 0)
	
	# Create background quad
	var panel_mesh = MeshInstance3D.new()
	panel_mesh.name = "PanelBackground"
	info_panel.add_child(panel_mesh)
	
	var quad = QuadMesh.new()
	quad.size = Vector2(1.5, 1.0)
	panel_mesh.mesh = quad
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.2, 0.2, 0.7)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	panel_mesh.material_override = material
	
	# Set up info labels
	var y_offset = 0.3
	
	var min_value_label = Label3D.new()
	min_value_label.name = "MinValue"
	min_value_label.position = Vector3(0, y_offset, 0.01)
	min_value_label.font_size = 10
	min_value_label.text = "Min: 0.0"
	info_panel.add_child(min_value_label)
	
	var max_value_label = Label3D.new()
	max_value_label.name = "MaxValue"
	max_value_label.position = Vector3(0, y_offset - 0.15, 0.01)
	max_value_label.font_size = 10
	max_value_label.text = "Max: 0.0"
	info_panel.add_child(max_value_label)
	
	var avg_value_label = Label3D.new()
	avg_value_label.name = "AvgValue"
	avg_value_label.position = Vector3(0, y_offset - 0.3, 0.01)
	avg_value_label.font_size = 10
	avg_value_label.text = "Avg: 0.0"
	info_panel.add_child(avg_value_label)
	
	# Add color legend
	create_color_legend()

func create_color_legend():
	var legend = Node3D.new()
	legend.name = "ColorLegend"
	info_panel.add_child(legend)
	
	# Position at bottom of info panel
	legend.position = Vector3(0, -0.3, 0.01)
	
	# Create colored boxes
	var segments = 5
	var box_size = 0.1
	var total_width = segments * box_size
	
	for i in range(segments):
		var box = MeshInstance3D.new()
		legend.add_child(box)
		
		var mesh = QuadMesh.new()
		mesh.size = Vector2(box_size, box_size)
		box.mesh = mesh
		
		# Position along horizontal line
		var x_pos = (i - segments/2.0 + 0.5) * box_size
		box.position = Vector3(x_pos, 0, 0)
		
		# Create gradient color
		var t = float(i) / (segments - 1)
		var material = StandardMaterial3D.new()
		
		if main_scene_reference and main_scene_reference.has_method("get_spectrum_color"):
			var color_val = lerp(min_color, max_color, t)
			material.albedo_color = main_scene_reference.get_spectrum_color(color_val)
		else:
			material.albedo_color = Color(t, t*0.8, 1.0-t, base_opacity)
		
		box.material_override = material
	
	# Add min/max labels
	var min_label = Label3D.new()
	min_label.text = "Min"
	min_label.font_size = 8
	min_label.position = Vector3(-total_width/2 - 0.05, 0, 0)
	legend.add_child(min_label)
	
	var max_label = Label3D.new()
	max_label.text = "Max"
	max_label.font_size = 8
	max_label.position = Vector3(total_width/2 + 0.05, 0, 0)
	legend.add_child(max_label)

func update_grid_visualization():
	# Update each cell based on data
	for y in range(grid_height):
		for x in range(grid_width):
			update_cell_visualization(x, y)
	
	# Update info panel
	update_info_panel()

func update_cell_visualization(x, y):
	var cell = cells[y][x]
	var value = grid_data[y][x]
	
	# Skip if cell doesn't exist
	if not cell:
		return
	
	# Calculate normalized value (0-1)
	var normalized_value = 0.0
	if current_max_value != current_min_value:
		normalized_value = (value - current_min_value) / (current_max_value - current_min_value)
	
	# Update height
	var box_mesh = cell.mesh as BoxMesh
	var height = normalized_value * grid_depth * value_scale
	height = max(0.01, height)  # Ensure minimum height for visibility
	
	box_mesh.size = Vector3(cell_size, height, cell_size)
	
	# Center the box vertically
	cell.position.y = height / 2
	
	# Update color
	var material = cell.material_override
	
	if use_color_gradient and main_scene_reference and main_scene_reference.has_method("get_spectrum_color"):
		var color_val = lerp(min_color, max_color, normalized_value)
		material.albedo_color = main_scene_reference.get_spectrum_color(color_val)
		material.albedo_color.a = base_opacity
	else:
		# Fallback color gradient
		material.albedo_color = Color(
			normalized_value * 0.8 + 0.2,
			(1.0 - normalized_value) * 0.8 + 0.2,
			0.5,
			base_opacity
		)
	
	# Update value label
	var label = cell.get_node("Value_Label")
	if label:
		label.text = "%0.1f" % value
		label.position.y = height + 0.05

func update_info_panel():
	if not info_panel:
		return
	
	# Calculate stats
	var min_label = info_panel.get_node("MinValue")
	var max_label = info_panel.get_node("MaxValue")
	var avg_label = info_panel.get_node("AvgValue")
	
	if min_label:
		min_label.text = "Min %s: %0.2f%s" % [data_label, current_min_value, data_units]
	
	if max_label:
		max_label.text = "Max %s: %0.2f%s" % [data_label, current_max_value, data_units]
	
	if avg_label:
		var total = 0.0
		for y in range(grid_height):
			for x in range(grid_width):
				total += grid_data[y][x]
		
		var avg = total / (grid_width * grid_height)
		avg_label.text = "Avg %s: %0.2f%s" % [data_label, avg, data_units]

func clear_grid():
	# Remove all grid elements
	if grid_container:
		for child in grid_container.get_children():
			child.queue_free()
		
		grid_container.queue_free()
		grid_container = null
	
	cells = []
	x_axis_labels = []
	y_axis_labels = []
	title_label = null
	info_panel = null

# Signal handlers
func _on_cell_input_event(x, y, camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal("cell_selected", x, y, grid_data[y][x])
			
			# Record this interaction
			if task_manager and task_manager.has_method("record_interaction"):
				task_manager.record_interaction(
					position,
					"cell_click",
					{
						"x": x,
						"y": y,
						"value": grid_data[y][x]
					}
				)

func _on_cell_mouse_entered(x, y):
	highlight_cell(x, y, true)
	
	# Show value label
	var cell = cells[y][x]
	var label = cell.get_node("Value_Label")
	if label:
		label.modulate = Color(1, 1, 1, 1)  # Make visible

func _on_cell_mouse_exited(x, y):
	highlight_cell(x, y, false)
	
	# Hide value label
	var cell = cells[y][x]
	var label = cell.get_node("Value_Label")
	if label:
		label.modulate = Color(1, 1, 1, 0)  # Make invisible

# Set up reference to main scene
func setup_main_reference_old(main_ref):
	main_scene_reference = main_ref
	# Need to refresh all materials
	update_grid_visualization()
