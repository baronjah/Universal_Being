@tool
extends MeshInstance3D

var triangles = []
var vertices = []

@export var subdivisions: int = 2:
	set = set_subdivisions, get = get_subdivisions
@export var roughness: float = 1.0:
	set = set_roughness, get = get_roughness
@export var radius: float = 1.0:
	set = set_radius, get = get_radius
@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var update_noise_flag: bool = false:
	set = update_noise, get = get_update_noise

func _ready():
#	randomize()
#	update_icosphere()
	pass

func generate_icosphere():
	vertices.clear()
	triangles.clear()
	
	# Calculate the golden ratio
	var t = (1.0 + sqrt(5.0)) / 2.0

	vertices.append(Vector3(-1, t, 0).normalized() * radius)
	vertices.append(Vector3(1, t, 0).normalized() * radius)
	vertices.append(Vector3(-1, -t, 0).normalized() * radius)
	vertices.append(Vector3(1, -t, 0).normalized() * radius)
	vertices.append(Vector3(0, -1, t).normalized() * radius)
	vertices.append(Vector3(0, 1, t).normalized() * radius)
	vertices.append(Vector3(0, -1, -t).normalized() * radius)
	vertices.append(Vector3(0, 1, -t).normalized() * radius)
	vertices.append(Vector3(t, 0, -1).normalized() * radius)
	vertices.append(Vector3(t, 0, 1).normalized() * radius)
	vertices.append(Vector3(-t, 0, -1).normalized() * radius)
	vertices.append(Vector3(-t, 0, 1).normalized() * radius)

	triangles.append(Triangle.new(0, 11, 5))
	triangles.append(Triangle.new(0, 5, 1))
	triangles.append(Triangle.new(0, 1, 7))
	triangles.append(Triangle.new(0, 7, 10))
	triangles.append(Triangle.new(0, 10, 11))
	triangles.append(Triangle.new(1, 5, 9))
	triangles.append(Triangle.new(5, 11, 4))
	triangles.append(Triangle.new(11, 10, 2))
	triangles.append(Triangle.new(10, 7, 6))
	triangles.append(Triangle.new(7, 1, 8))
	triangles.append(Triangle.new(3, 9, 4))
	triangles.append(Triangle.new(3, 4, 2))
	triangles.append(Triangle.new(3, 2, 6))
	triangles.append(Triangle.new(3, 6, 8))
	triangles.append(Triangle.new(3, 8, 9))
	triangles.append(Triangle.new(4, 9, 5))
	triangles.append(Triangle.new(2, 4, 11))
	triangles.append(Triangle.new(6, 2, 10))
	triangles.append(Triangle.new(8, 6, 7))
	triangles.append(Triangle.new(9, 8, 1))

func generate_mesh():
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	for triangle in triangles:
		# Add vertices in reverse order to flip faces
		for i in range(2, -1, -1):
			var vertex_index = triangle.vertices[i]
			var vertex = vertices[vertex_index]
			if noise:
				vertex += vertex.normalized() * noise.get_noise_3dv(vertex * roughness) * radius
			surface_tool.add_vertex(vertex)

	surface_tool.index()
	surface_tool.generate_normals()
	self.mesh = surface_tool.commit()

func subdivide_icosphere():
	var cache = {}
	for _i in range(subdivisions):
		var new_triangles = []
		for triangle in triangles:
			var a = triangle.vertices[0]
			var b = triangle.vertices[1]
			var c = triangle.vertices[2]
			var ab = get_midpoint(cache, a, b)
			var bc = get_midpoint(cache, b, c)
			var ca = get_midpoint(cache, c, a)
			new_triangles.append(Triangle.new(a, ab, ca))
			new_triangles.append(Triangle.new(b, bc, ab))
			new_triangles.append(Triangle.new(c, ca, bc))
			new_triangles.append(Triangle.new(ab, bc, ca))
		triangles = new_triangles

func get_midpoint(cache: Dictionary, a: int, b: int) -> int:
	var smaller = min(a, b)
	var greater = max(a, b)
	var key = (smaller << 16) + greater
	if cache.has(key):
		return cache[key]

	var p1 = vertices[a]
	var p2 = vertices[b]
	var middle = (p1 + p2).normalized() * radius
	var ret = vertices.size()
	vertices.append(middle)
	cache[key] = ret
	return ret

class Triangle:
	var vertices = []
	func _init(a: int, b: int, c: int):
		vertices.append(a)
		vertices.append(b)
		vertices.append(c)

func set_subdivisions(value: int) -> void:
	subdivisions = value
	update_icosphere()

func get_subdivisions() -> int:
	return subdivisions

func set_roughness(value: float) -> void:
	roughness = value
	update_icosphere()

func get_roughness() -> float:
	return roughness

func set_radius(value: float) -> void:
	radius = value
	update_icosphere()

func get_radius() -> float:
	return radius

func update_noise(value: bool) -> void:
	update_noise_flag = value
	update_icosphere()

func get_update_noise() -> bool:
	return update_noise_flag

func update_icosphere():
	generate_icosphere()
	subdivide_icosphere()
	generate_mesh()
