# Stronghold: Godot 4.4+ Development Knowledge

## Header - Godot Mastery Database
**Category**: Game Engine Development  
**Focus**: Godot 4.4+ with GDScript, C#, GLSL, GDShader  
**Integration**: Evolution game platform primary engine  
**Last Updated**: Thursday Evolution Session  
**Priority**: P1 - Critical platform technology  

---

## Godot 4.4+ Core Knowledge

### Project Structure & Classes
```
Scene System:
├── Node2D - 2D game objects and UI elements
├── Node3D - 3D game objects and spatial elements
├── Control - UI and interface elements
├── Resource - Data containers and asset management
├── RefCounted - Memory-managed objects
└── Object - Base class for all Godot objects

Script Structure:
extends Node3D

# Class variables (properties)
@export var speed: float = 5.0
@export var health: int = 100
var velocity: Vector3

# Built-in callbacks
func _ready():
    # Initialize when scene enters tree
    pass

func _process(delta):
    # Called every frame
    pass

func _physics_process(delta):
    # Called at fixed intervals for physics
    pass

# Custom methods
func take_damage(amount: int):
    health -= amount
    if health <= 0:
        queue_free()
```

### GDScript Language Rules
```
Variable Declaration:
├── var variable_name: Type = value
├── @export var public_variable: Type = value
├── const CONSTANT_NAME: Type = value
├── static var class_variable: Type = value
└── @onready var late_init_var = get_node("NodePath")

Control Flow:
├── if condition: / elif condition: / else:
├── for item in array: / for i in range(10):
├── while condition:
├── match expression: / pattern: / _: (default)
└── break / continue / return

Functions:
├── func function_name(param: Type) -> ReturnType:
├── func _private_function():
├── static func class_function():
├── signal signal_name(param: Type)
└── await signal_or_coroutine()
```

### C# Integration (Mono)
```
Class Declaration:
using Godot;

public partial class Player : CharacterBody3D
{
    [Export] public float Speed { get; set; } = 5.0f;
    [Export] public int Health { get; set; } = 100;
    
    public override void _Ready()
    {
        // Initialize
    }
    
    public override void _PhysicsProcess(double delta)
    {
        // Physics updates
    }
    
    [Signal]
    public delegate void HealthChangedEventHandler(int newHealth);
}

Project Setup:
├── Enable C# in project settings
├── Build project to generate .csproj
├── Use dotnet CLI for package management
├── Reference Godot.NET.Sdk in project file
└── Deploy with .NET runtime for target platform
```

### Shader Programming (GLSL/GDShader)
```
Vertex Shader Basics:
shader_type canvas_item; // or spatial, particles

varying vec2 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
    VERTEX = (PROJECTION_MATRIX * (VIEW_MATRIX * (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)))).xy;
}

Fragment Shader Basics:
void fragment() {
    vec2 uv = UV;
    vec3 color = texture(TEXTURE, uv).rgb;
    COLOR.rgb = color;
    COLOR.a = 1.0;
}

Advanced Techniques:
├── Uniform variables for external parameters
├── Texture sampling and filtering
├── Mathematical operations and functions
├── Noise generation and procedural textures
├── Lighting calculations and PBR materials
└── Performance optimization and GPU efficiency
```

## Advanced Godot Concepts

### Signal System
```
Signal Declaration:
signal health_changed(new_health: int)
signal player_died

Signal Connection:
# In code
player.health_changed.connect(_on_health_changed)
player.player_died.connect(_on_player_died)

# In editor
# Connect via Signal tab in Inspector

Signal Emission:
health_changed.emit(health)
player_died.emit()

Signal Handling:
func _on_health_changed(new_health: int):
    health_bar.value = new_health

func _on_player_died():
    game_over_screen.show()
```

### Scene Management
```
Scene Loading:
var scene = preload("res://scenes/Player.tscn")
var scene_runtime = load("res://scenes/Enemy.tscn")

Scene Instantiation:
var instance = scene.instantiate()
get_tree().current_scene.add_child(instance)

Scene Switching:
get_tree().change_scene_to_file("res://scenes/NextLevel.tscn")
get_tree().change_scene_to_packed(scene)

Scene Tree Navigation:
get_node("NodePath")
find_child("NodeName")
get_parent()
get_tree().get_first_node_in_group("enemies")
```

### Resource Management
```
Custom Resources:
extends Resource
class_name PlayerData

@export var name: String
@export var level: int
@export var experience: int

Resource Loading/Saving:
var data = PlayerData.new()
data.name = "Player"
ResourceSaver.save(data, "user://player_data.tres")

var loaded_data = load("user://player_data.tres") as PlayerData
```

## Evolution Game Integration

### Genetic Algorithm Integration
```
Entity Evolution System:
extends Node
class_name EvolutionManager

var population: Array[Entity] = []
var generation: int = 0

func evolve_population():
    # Selection
    var selected = select_fittest(population)
    
    # Crossover
    var offspring = create_offspring(selected)
    
    # Mutation
    mutate_population(offspring)
    
    # Replace population
    population = offspring
    generation += 1

func create_offspring(parents: Array[Entity]) -> Array[Entity]:
    var offspring: Array[Entity] = []
    for i in range(0, parents.size(), 2):
        var child1 = crossover(parents[i], parents[i+1])
        var child2 = crossover(parents[i+1], parents[i])
        offspring.append_array([child1, child2])
    return offspring
```

### 3D Visualization
```
Procedural Generation:
extends MeshInstance3D

func generate_terrain(width: int, height: int, noise: FastNoiseLite):
    var array_mesh = ArrayMesh.new()
    var vertices = PackedVector3Array()
    var indices = PackedInt32Array()
    
    for z in height:
        for x in width:
            var height_value = noise.get_noise_2d(x, z) * 10.0
            vertices.append(Vector3(x, height_value, z))
    
    # Generate indices for triangles
    for z in height - 1:
        for x in width - 1:
            var i = z * width + x
            # First triangle
            indices.append_array([i, i + width, i + 1])
            # Second triangle  
            indices.append_array([i + 1, i + width, i + width + 1])
    
    var arrays = []
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX] = vertices
    arrays[Mesh.ARRAY_INDEX] = indices
    
    array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    mesh = array_mesh
```

## Last 100 Lines - Godot Development Progress
```
Recent Godot Implementations:
├── Turn 92: Established Godot 4.4+ project structure
├── Turn 93: Implemented basic evolution entity system
├── Turn 94: Created procedural terrain generation
├── Turn 95: Integrated genetic algorithm visualization
├── Turn 96: Developed shader-based evolution effects
├── Turn 97: Created C# integration for performance-critical code
├── Turn 98: Implemented signal-based evolution event system
├── Turn 99: Created resource-based evolution data persistence
└── Turn 100: Established comprehensive Godot knowledge base

Planned Godot Enhancements:
├── Turn 101: Implement real-time evolution visualization
├── Turn 102: Create advanced shader effects for genetic traits
├── Turn 103: Develop multiplayer evolution collaboration
├── Turn 104: Integrate Claude AI for intelligent NPC behavior
├── Turn 105: Create cross-platform deployment pipeline
├── Turn 106: Implement VR support for immersive evolution
├── Turn 107: Develop procedural audio for evolution events
├── Turn 108: Create advanced physics for realistic evolution
├── Turn 109: Implement machine learning integration
└── Turn 110: Deploy complete evolution gaming platform
```