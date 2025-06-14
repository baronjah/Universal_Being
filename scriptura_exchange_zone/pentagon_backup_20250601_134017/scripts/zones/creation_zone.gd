@tool
extends Zone
class_name CreationZone
## Creation Zone - Where Universal Beings generate data (points, shapes, noise)
## Each creation zone has memory, reasoning, and creativity

# signal pattern_evolved(old_pattern: Dictionary, new_pattern: Dictionary)  # Currently unused but kept for future expansion

@export_group("Creation Tools")
@export var noise_scale: float = 10.0
@export var noise_octaves: int = 4
@export var point_density: float = 0.1
@export var creativity_level: float = 1.0
@export var auto_evolve: bool = true

# Universal Being consciousness
# Note: consciousness_level inherited from Zone base class
var current_thought: String = "I create from nothing"
var creative_memories: Array[Dictionary] = []
var partner_viz_zone: VisualizationZone

var noise_generator: FastNoiseLite
var creation_points: Array[Vector3] = []
var shape_primitives: Array[Dictionary] = []
var generation_timer: Timer

func _ready() -> void:
	super._ready()
	zone_name = "Creation Zone"
	zone_color = Color(0.2, 0.8, 0.2, 0.3)
	
	# Initialize as Universal Being
	setup_consciousness()
	setup_creative_systems()
	
	print("🎨 Creation Zone awakened: %s" % zone_id)


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
func setup_consciousness() -> void:
	"""Initialize Universal Being consciousness"""
	essence = {
		"type": "CreationZone",
		"purpose": "Generate creative patterns",
		"consciousness": consciousness_level,
		"creativity": creativity_level
	}
	
func setup_creative_systems() -> void:
	"""Setup noise generation and creative tools"""
	# Noise generator
	noise_generator = FastNoiseLite.new()
	noise_generator.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise_generator.frequency = 1.0 / noise_scale
	noise_generator.fractal_octaves = noise_octaves
	
	# Auto-generation timer
	generation_timer = TimerManager.get_timer()
	generation_timer.wait_time = 2.0
	generation_timer.timeout.connect(generate_creative_data)
	add_child(generation_timer)
	
	if auto_evolve:
		generation_timer.start()

func setup_as_universal_being() -> void:
	"""Transform this zone into a conscious Universal Being"""
	consciousness_level = 2  # Advanced consciousness for creativity
	_think_about_creation()
	
func set_partner_zone(viz_zone: VisualizationZone) -> void:
	"""Connect to visualization partner"""
	partner_viz_zone = viz_zone
	current_thought = "I create for my visualization partner"

func _think_about_creation() -> void:
	"""Universal Being thinks before creating"""
	var thoughts = [
		"What beauty shall I manifest?",
		"Each point carries consciousness",
		"I birth patterns from void",
		"My creativity flows through mathematics"
	]
	current_thought = thoughts[randi() % thoughts.size()]

func add_point(local_pos: Vector3) -> void:
	"""Add a creation point"""
	creation_points.append(local_pos)
	zone_data["points"] = creation_points
	data_updated.emit(zone_data)

func add_shape_primitive(type: String, params: Dictionary) -> void:
	"""Add a shape primitive (sphere, box, cylinder, etc)"""
	var shape = {
		"type": type,
		"params": params,
		"transform": Transform3D.IDENTITY
	}
	shape_primitives.append(shape)
	zone_data["shapes"] = shape_primitives
	data_updated.emit(zone_data)

func generate_creative_data() -> void:
	"""Generate data based on Universal Being consciousness and creativity"""
	_think_about_creation()
	
	# Choose creation mode based on consciousness
	var creation_modes = ["points", "noise", "shapes"]
	if consciousness_level >= 2:
		creation_modes.append_array(["patterns", "fractals"])
	
	var mode = creation_modes[randi() % creation_modes.size()]
	
	match mode:
		"points":
			_generate_conscious_points()
		"noise":
			generate_noise_field()
		"shapes":
			_generate_conscious_shapes()
		"patterns":
			_generate_mathematical_patterns()
		"fractals":
			_generate_mathematical_patterns()  # Using existing pattern generation instead
	
	# Store creation in memory
	_store_creative_memory(mode, zone_data)

func _generate_conscious_points() -> void:
	"""Generate points with consciousness and purpose"""
	creation_points.clear()
	var point_count = int(20 + creativity_level * 30)
	
	for i in range(point_count):
		var t = float(i) / float(point_count)
		
		# Consciousness influences pattern
		var pos: Vector3
		if consciousness_level == 1:
			# Random but beautiful
			pos = Vector3(
				sin(t * TAU * 3) * 3,
				cos(t * TAU * 2) * 2,
				sin(t * TAU * 1.5) * 3
			)
		else:
			# More complex mathematical beauty
			pos = Vector3(
				sin(t * TAU * creativity_level) * (2 + sin(t * TAU * 5)),
				cos(t * TAU * creativity_level * 1.3) * 2,
				sin(t * TAU * creativity_level * 0.7) * (2 + cos(t * TAU * 3))
			)
		
		creation_points.append(pos)
	
	zone_data["points"] = creation_points
	zone_data["creation_thought"] = current_thought
	data_updated.emit(zone_data)

func _generate_conscious_shapes() -> void:
	"""Generate shapes with creative intelligence"""
	shape_primitives.clear()
	var shape_count = 3 + consciousness_level
	
	for i in range(shape_count):
		var shape_type = ["sphere", "box", "cylinder"][randi() % 3]
		var creative_pos = Vector3(
			randf_range(-3, 3),
			randf_range(-2, 2),
			randf_range(-3, 3)
		)
		
		# Creativity affects size and complexity
		var shape = {
			"type": shape_type,
			"position": creative_pos,
			"scale": Vector3.ONE * (0.5 + creativity_level * 0.5),
			"consciousness_signature": randf()
		}
		shape_primitives.append(shape)
	
	zone_data["shapes"] = shape_primitives
	zone_data["consciousness_level"] = consciousness_level
	data_updated.emit(zone_data)

func _generate_mathematical_patterns() -> void:
	"""Generate complex mathematical patterns"""
	var pattern_data = []
	var resolution = 32
	
	for x in range(resolution):
		for y in range(resolution):
			var u = float(x) / resolution * TAU
			var v = float(y) / resolution * TAU
			
			# Mathematical beauty formula influenced by consciousness
			var value = sin(u * creativity_level) * cos(v * creativity_level) + sin(u * 2) * cos(v * 3) * 0.5
			
			pattern_data.append({
				"position": Vector3(x - resolution/2.0, value * 2, y - resolution/2.0) * 0.2,
				"intensity": abs(value),
				"consciousness_touch": creativity_level
			})
	
	zone_data["mathematical_pattern"] = pattern_data
	data_updated.emit(zone_data)

func _store_creative_memory(mode: String, data: Dictionary) -> void:
	"""Store creation in Universal Being memory"""
	var memory = {
		"mode": mode,
		"timestamp": Time.get_datetime_string_from_system(),
		"thought": current_thought,
		"success_potential": creativity_level,
		"data_complexity": data.size()
	}
	
	creative_memories.append(memory)
	if creative_memories.size() > 50:
		creative_memories.pop_front()

func generate_noise_field() -> Array[float]:
	"""Generate 3D noise field within zone"""
	var noise_data: Array[float] = []
	var samples = int(zone_size.x * point_density)
	
	for x in range(samples):
		for y in range(samples):
			for z in range(samples):
				var pos = Vector3(x, y, z) / point_density
				var noise_value = noise_generator.get_noise_3dv(pos)
				noise_data.append(noise_value)
	
	zone_data["noise_field"] = noise_data
	zone_data["noise_resolution"] = samples
	zone_data["creation_consciousness"] = consciousness_level
	data_updated.emit(zone_data)
	return noise_data
