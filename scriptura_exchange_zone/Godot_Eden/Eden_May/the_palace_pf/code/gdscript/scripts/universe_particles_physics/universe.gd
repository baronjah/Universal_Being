# universe.gd - Main scene controller
extends Node3D

# References to sub-systems
var particle_system
var shape_generator
var physics_controller
var user_interface

# Configuration
var config = {
	"particle_count": 500,
	"core_colors": [Color(1.0, 0.4, 0.0), Color(0.0, 0.4, 1.0)],
	"wireframe_color": Color(0.0, 1.0, 1.0),
	"gravity": Vector3(0, -0.5, 0)
}

func _ready():
	# Initialize systems
	_init_systems()
	
	# Setup initial state
	particle_system.create_initial_particles()
	
func _init_systems():
	# Create and add particle system
	particle_system = preload("res://ParticleSystem.gd").new()
	particle_system.config = config
	add_child(particle_system)
	
	# Create and add shape generator
	shape_generator = preload("res://ShapeGenerator.gd").new()
	shape_generator.config = config
	add_child(shape_generator)
	
	# Create and add physics controller
	physics_controller = preload("res://PhysicsController.gd").new()
	physics_controller.config = config
	add_child(physics_controller)
	
	# Create and add user interface
	user_interface = preload("res://UserInterface.gd").new()
	user_interface.config = config
	add_child(user_interface)
	
	# Connect signals
	user_interface.connect("big_bang_triggered", self, "_on_big_bang_triggered")

func _on_big_bang_triggered():
	# Clear existing particles
	particle_system.clear_particles()
	
	# Create new big bang particles
	particle_system.create_big_bang_particles()
	
	# Generate shapes
	shape_generator.generate_shapes()

# Compact main process function
func _process(delta):
	physics_controller.apply_physics(delta)


# Main scene controller for the Universe Simulation
extends Node3D

# References to sub-systems
var particle_system: Node3D
var shape_generator: Node3D
var physics_controller: Node3D
var user_interface: Control

# Configuration
var config := {
	"particle_count": 500,
	"core_colors": [Color(1.0, 0.4, 0.0), Color(0.0, 0.4, 1.0)],
	"wireframe_color": Color(0.0, 1.0, 1.0),
	"gravity": Vector3(0, -0.5, 0)
}

func _ready() -> void:
	# Initialize systems
	_init_systems()
	
	# Setup initial state
	particle_system.create_initial_particles()
	
func _init_systems() -> void:
	# Create and add particle system
	particle_system = preload("res://scripts/particle_system.gd").new()
	particle_system.config = config
	add_child(particle_system)
	
	# Create and add shape generator
	shape_generator = preload("res://scripts/shape_generator.gd").new()
	shape_generator.config = config
	add_child(shape_generator)
	
	# Create and add physics controller
	physics_controller = preload("res://scripts/physics_controller.gd").new()
	physics_controller.config = config
	add_child(physics_controller)
	
	# Create and add user interface
	user_interface = preload("res://scripts/ui/user_interface.gd").new()
	user_interface.config = config
	add_child(user_interface)
	
	# Connect signals
	user_interface.big_bang_triggered.connect(_on_big_bang_triggered)

func _on_big_bang_triggered() -> void:
	# Clear existing particles
	particle_system.clear_particles()
	
	# Create new big bang particles
	particle_system.create_big_bang_particles()
	
	# Generate shapes
	shape_generator.generate_shapes()

# Main process function
func _process(delta: float) -> void:
	physics_controller.apply_physics(delta)
