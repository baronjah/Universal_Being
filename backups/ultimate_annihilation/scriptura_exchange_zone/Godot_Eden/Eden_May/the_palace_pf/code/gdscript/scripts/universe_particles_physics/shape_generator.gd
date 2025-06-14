# ShapeGenerator.gd - Creates geometric shapes
extends Node3D

var config
var shapes = []

func generate_shapes():
	# Clear existing shapes
	for shape in shapes:
		shape.queue_free()
	shapes.clear()
	
	# Create geometric shapes
	var shape_types = [
		"tetrahedron",
		"cube",
		"prism" 
	]
	
	var colors = [
		Color(1.0, 0.2, 0.0),
		Color(0.0, 0.2, 1.0),
		Color(0.4, 0.4, 0.4)
	]
	
	for i in range(20):
		var shape_node = Node3D.new()
		var mesh_instance = MeshInstance3D.new()
		
		# Choose random shape
		var shape_type = shape_types[randi() % shape_types.size()]
		var mesh
		
		match shape_type:
			"tetrahedron":
				mesh = PrismMesh.new()
				mesh.size = Vector3(rand_range(0.5, 2.0), rand_range(0.5, 2.0), rand_range(0.5, 2.0))
			"cube":
				mesh = BoxMesh.new()
				mesh.size = Vector3(rand_range(0.5, 2.0), rand_range(0.5, 2.0), rand_range(0.5, 2.0))
			"prism":
				mesh = PrismMesh.new()
				mesh.size = Vector3(rand_range(0.5, 2.0), rand_range(0.5, 2.0), rand_range(0.5, 2.0))
		
		# Material setup
		var material = StandardMaterial3D.new()
		material.albedo_color = colors[randi() % colors.size()]
		material.flags_unshaded = true
		
		if randf() > 0.5:
			material.flags_use_wireframe = true
		
		mesh_instance.mesh = mesh
		mesh_instance.material_override = material
		shape_node.add_child(mesh_instance)
		
		# Start at center
		shape_node.position = Vector3.ZERO
		
		# Random velocity
		var direction = Vector3(
			rand_range(-1, 1),
			rand_range(-1, 1),
			rand_range(-1, 1)
		).normalized()
		
		var speed = rand_range(0.05, 0.15)
		shape_node.velocity = direction * speed
		
		add_child(shape_node)
		shapes.append(shape_node)

# Update shapes
func update_shapes(delta):
	for shape in shapes:
		shape.position += shape.velocity


# Creates geometric shapes in the universe
extends Node3D

var config: Dictionary
var shapes: Array[Node3D] = []

# Generate shapes for the big bang
func generate_shapes() -> void:
	# Clear existing shapes
	for shape in shapes:
		shape.queue_free()
	shapes.clear()
	
	# Create geometric shapes
	var shape_types = [
		"tetrahedron",
		"cube",
		"prism" 
	]
	
	var colors = [
		Color(1.0, 0.2, 0.0),
		Color(0.0, 0.2, 1.0),
		Color(0.4, 0.4, 0.4)
	]
	
	for i in range(20):
		var shape_node = Node3D.new()
		var mesh_instance = MeshInstance3D.new()
		
		# Choose random shape
		var shape_type = shape_types[randi() % shape_types.size()]
		var mesh
		
		match shape_type:
			"tetrahedron":
				mesh = PrismMesh.new()
				mesh.size = Vector3(randf_range(0.5, 2.0), randf_range(0.5, 2.0), randf_range(0.5, 2.0))
			"cube":
				mesh = BoxMesh.new()
				mesh.size = Vector3(randf_range(0.5, 2.0), randf_range(0.5, 2.0), randf_range(0.5, 2.0))
			"prism":
				mesh = PrismMesh.new()
				mesh.size = Vector3(randf_range(0.5, 2.0), randf_range(0.5, 2.0), randf_range(0.5, 2.0))
		
		# Material setup
		var material = StandardMaterial3D.new()
		material.albedo_color = colors[randi() % colors.size()]
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		
		if randf() > 0.5:
			material.use_wireframe = true
		
		mesh_instance.mesh = mesh
		mesh_instance.material_override = material
		shape_node.add_child(mesh_instance)
		
		# Start at center
		shape_node.position = Vector3.ZERO
		
		# Random velocity
		var direction = Vector3(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		).normalized()
		
		var speed = randf_range(0.05, 0.15)
		shape_node.set_meta("velocity", direction * speed)
		
		add_child(shape_node)
		shapes.append(shape_node)

# Update shapes (called by physics_controller)
func update_shapes(delta: float) -> void:
	for shape in shapes:
		if shape.has_meta("velocity"):
			shape.position += shape.get_meta("velocity")
			
			# Apply gravity
			var velocity = shape.get_meta("velocity")
			velocity += get_parent().config.gravity * delta
			shape.set_meta("velocity", velocity)
