extends Node3D

## Enhanced game world with memory optimization and better visuals

@export var spawn_radius: float = 50.0
@export var max_beings: int = 50
@export var being_types: Array[String] = ["button", "particle", "light", "sound", "thought"]

var spawn_timer: Timer
var memory_monitor: Label
var being_counter: Label

func _ready():
	setup_environment()
	setup_ui()
	setup_spawning()
	
	# Connect to memory optimizer
	if MemoryOptimizer.instance:
		MemoryOptimizer.instance.memory_warning.connect(_on_memory_warning)
		MemoryOptimizer.instance.memory_critical.connect(_on_memory_critical)

func setup_environment():
	# Add more interesting lighting
	var omni_light = OmniLight3D.new()
	omni_light.position = Vector3(0, 10, 0)
	omni_light.light_energy = 0.5
	omni_light.light_color = Color(0.8, 0.9, 1.0)
	omni_light.omni_range = 100
	add_child(omni_light)
	
	# Add fog for atmosphere
	var env = get_node_or_null("WorldEnvironment")
	if env and env.environment:
		env.environment.fog_enabled = true
		env.environment.fog_light_color = Color(0.7, 0.8, 1.0)
		env.environment.fog_density = 0.01
		env.environment.fog_sun_scatter = 0.5

func setup_ui():
	var ui_layer = CanvasLayer.new()
	ui_layer.layer = 10
	add_child(ui_layer)
	
	# Memory monitor
	memory_monitor = Label.new()
	memory_monitor.position = Vector2(10, 50)
	memory_monitor.add_theme_color_override("font_color", Color.WHITE)
	memory_monitor.add_theme_color_override("font_shadow_color", Color.BLACK)
	memory_monitor.add_theme_constant_override("shadow_offset_x", 2)
	memory_monitor.add_theme_constant_override("shadow_offset_y", 2)
	ui_layer.add_child(memory_monitor)
	
	# Being counter
	being_counter = Label.new()
	being_counter.position = Vector2(10, 80)
	being_counter.add_theme_color_override("font_color", Color.WHITE)
	being_counter.add_theme_color_override("font_shadow_color", Color.BLACK)
	being_counter.add_theme_constant_override("shadow_offset_x", 2)
	being_counter.add_theme_constant_override("shadow_offset_y", 2)
	ui_layer.add_child(being_counter)

func setup_spawning():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 2.0
	spawn_timer.timeout.connect(_spawn_random_being)
	add_child(spawn_timer)
	spawn_timer.start()

func _process(_delta):
	# Update UI
	if memory_monitor and MemoryOptimizer.instance:
		var stats = MemoryOptimizer.instance.get_stats()
		memory_monitor.text = "Memory: %.1f MB" % stats.current_usage_mb
	
	if being_counter:
		var bootstrap = get_node_or_null("/root/SystemBootstrap")
		if bootstrap:
			var flood_gates = bootstrap.get_flood_gates()
			if flood_gates:
				being_counter.text = "Beings: %d / %d" % [flood_gates.get_being_count(), max_beings]

func _spawn_random_being():
	var bootstrap = get_node_or_null("/root/SystemBootstrap")
	if not bootstrap:
		return
	
	var flood_gates = bootstrap.get_flood_gates()
	if not flood_gates or flood_gates.get_being_count() >= max_beings:
		return
	
	# Create a random Universal Being
	var being_scene = preload("res://scenes/universal_being_template.tscn")
	if being_scene:
		var being = being_scene.instantiate()
		
		# Random position
		var angle = randf() * TAU
		var distance = randf() * spawn_radius
		being.position = Vector3(
			cos(angle) * distance,
			randf_range(1, 5),
			sin(angle) * distance
		)
		
		# Random properties
		being.being_type = being_types.pick_random()
		being.consciousness_level = randi_range(0, 3)
		
		add_child(being)
		print("🌟 Spawned ", being.being_type, " at ", being.position)

func _on_memory_warning(usage_mb: float):
	print("⚠️ Memory warning: ", usage_mb, " MB")
	# Reduce spawn rate
	if spawn_timer:
		spawn_timer.wait_time = 5.0

func _on_memory_critical(usage_mb: float):
	print("🚨 Memory critical: ", usage_mb, " MB")
	# Stop spawning
	if spawn_timer:
		spawn_timer.stop()