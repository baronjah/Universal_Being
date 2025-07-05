extends MeshInstance3D
class_name DynamicCube

# Hot-loaded cube that responds to consciousness
var consciousness_level: float = 3.0
var rotation_speed: float = 1.0

func _ready():
	name = "HotLoadedDynamicCube"
	mesh = BoxMesh.new()
	
	# Set up material with consciousness glow
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.CYAN
	material.emission_enabled = true
	material.emission = Color.CYAN * 0.5
	material_override = material
	
	print("🔥 Dynamic Cube hot-loaded! Consciousness level: %f" % consciousness_level)

func _process(delta):
	# Rotate based on consciousness level
	rotate_y(rotation_speed * consciousness_level * delta)
	
	# Pulse emission based on time
	if material_override:
		var pulse = sin(Time.get_time_from_start() * 2.0) * 0.3 + 0.7
		material_override.emission = Color.CYAN * pulse * consciousness_level * 0.2