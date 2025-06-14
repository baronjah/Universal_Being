extends Node
# global_resources_loader
# code
# res://code/gdscript/scripts/Space_Place_Point/global_resources_loader.gd

# This singleton class will manage global resources and model access
# Add to your Autoload in Project Settings with name "Globals"

# Resources
var model_loader: ModelLoader
var segment_model: PackedScene
var head_model: PackedScene
var debug_material: StandardMaterial3D

# Thread management
var active_threads = {}
var max_threads = 8

# Settings
var settings = {
	"grid_resolution": 32,
	"cell_size": 1.0,
	"game_speed": 0.2,
	"max_shapes_per_frame": 100,
	"elasticity": 0.3,
	"animation_speed": 1.0
}

# Function to initialize the model loader
func initialize():
	if model_loader == null:
		model_loader = ModelLoader.new()
		add_child(model_loader)
		model_loader.connect("models_ready", _on_models_ready)
		print("Globals: ModelLoader initialized")
	else:
		print("Globals: ModelLoader already initialized")

# Callback when models are ready
func _on_models_ready():
	segment_model = model_loader.get_segment_model()
	head_model = model_loader.get_head_model()
	debug_material = model_loader.get_debug_material()
	print("Globals: Models loaded and ready to use")

# Thread management functions
func register_thread(thread_id, thread_info):
	active_threads[thread_id] = thread_info
	
func unregister_thread(thread_id):
	if active_threads.has(thread_id):
		active_threads.erase(thread_id)
		
func get_active_thread_count():
	return active_threads.size()
	
func can_create_thread():
	return get_active_thread_count() < max_threads

# Settings access
func get_setting(key):
	if settings.has(key):
		return settings[key]
	return null
	
func set_setting(key, value):
	settings[key] = value
	
# Grid conversion helpers
func world_to_grid(world_pos, cell_size = null):
	if cell_size == null:
		cell_size = settings.cell_size
		
	return Vector3(
		floor(world_pos.x / cell_size) * cell_size,
		floor(world_pos.y / cell_size) * cell_size,
		floor(world_pos.z / cell_size) * cell_size
	)
	
func grid_to_world(grid_pos, cell_size = null):
	if cell_size == null:
		cell_size = settings.cell_size
		
	return Vector3(
		grid_pos.x * cell_size + cell_size/2,
		grid_pos.y * cell_size + cell_size/2,
		grid_pos.z * cell_size + cell_size/2
	)

# On ready
func _ready():
	initialize()
	print("Globals: Ready and waiting for models to load")
