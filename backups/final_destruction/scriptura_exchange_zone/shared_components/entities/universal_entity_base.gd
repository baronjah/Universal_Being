# ==================================================
# SCRIPT NAME: universal_entity_base.gd
# DESCRIPTION: Base class for all evolving entities across projects
# CREATED: 2025-05-23 - Unified entity system
# ==================================================

class_name UniversalEntityBase
extends Node3D

# Signals for cross-project communication
signal evolution_triggered(entity: UniversalEntityBase, new_stage: int)
signal dimension_changed(entity: UniversalEntityBase, new_dimension: int)
signal color_attuned(entity: UniversalEntityBase, color: Color)
signal entity_merged(entity1: UniversalEntityBase, entity2: UniversalEntityBase, result: UniversalEntityBase)

# Entity Properties
@export var entity_name: String = "Unknown"
@export var entity_type: EntityType = EntityType.WORD
@export var current_dimension: int = 3
@export var evolution_stage: int = 0
@export var dimensional_color: Color = Color.CYAN

# Evolution Systems
enum EntityType {
	# From Notepad3D
	WORD,
	SYMBOL,
	GLYPH,
	
	# From Eden OS
	THOUGHT,
	MEMORY,
	CONCEPT,
	ESSENCE,
	DREAM,
	INTENTION,
	EMOTION,
	CREATION,
	PRESENCE
}

# Combined Evolution Stages
enum EvolutionStage {
	# Heptagon System (Notepad3D)
	SEED = 0,
	SPROUT = 1,
	GROWTH = 2,
	BLOOM = 3,
	FRUIT = 4,
	HARVEST = 5,
	TRANSCEND = 6,
	
	# Consciousness System (Eden OS)
	SPARK = 7,
	FLICKER = 8,
	GLOW = 9,
	EMBER = 10,
	FLAME = 11,
	BLAZE = 12,
	INFERNO = 13,
	STAR = 14,
	NOVA = 15,
	SUPERNOVA = 16,
	COSMOS = 17,
	NEXUS = 18
}

# Visual representation
var mesh_instance: MeshInstance3D
var collision_shape: CollisionShape3D
var area_3d: Area3D

# State tracking
var connections: Array[String] = []
var evolution_history: Array[Dictionary] = []
var dimensional_affinities: Dictionary = {}

## Initialize entity with type and starting properties
# INPUT: Entity name, type, and optional starting dimension
# PROCESS: Sets up visual representation and initial state
# OUTPUT: Configured entity ready for use
# CHANGES: Creates mesh, collision, and area nodes
# CONNECTION: Used by all project-specific entity systems
func initialize(name: String, type: EntityType, dimension: int = 3) -> void:
	entity_name = name
	entity_type = type
	current_dimension = dimension
	
	_create_visual_representation()
	_setup_collision()
	_apply_dimensional_color()

## Evolve entity to new stage
# INPUT: Target evolution stage
# PROCESS: Validates evolution, updates properties, records history
# OUTPUT: Success/failure of evolution
# CHANGES: Evolution stage, visual appearance, entity properties
# CONNECTION: Triggers evolution_triggered signal for other systems
func evolve(target_stage: int) -> bool:
	if not _can_evolve_to(target_stage):
		return false
	
	var old_stage = evolution_stage
	evolution_stage = target_stage
	
	# Record history
	evolution_history.append({
		"from_stage": old_stage,
		"to_stage": target_stage,
		"timestamp": Time.get_ticks_msec(),
		"dimension": current_dimension
	})
	
	# Update visuals
	_update_evolution_visuals()
	
	# Emit signal
	evolution_triggered.emit(self, target_stage)
	
	return true

## Change entity's dimension
# INPUT: Target dimension number
# PROCESS: Updates dimension and associated properties
# OUTPUT: Success of dimension change
# CHANGES: Current dimension, color, visual effects
# CONNECTION: Integrates with dimensional navigation systems
func set_dimension(dimension: int) -> void:
	if dimension == current_dimension:
		return
	
	current_dimension = dimension
	_apply_dimensional_color()
	dimension_changed.emit(self, dimension)

## Get evolution progress percentage
# INPUT: None
# PROCESS: Calculates progress based on current stage
# OUTPUT: Float between 0.0 and 1.0
# CHANGES: None
# CONNECTION: Used by UI systems for progress display
func get_evolution_progress() -> float:
	return float(evolution_stage) / float(EvolutionStage.NEXUS)

## Connect to another entity
# INPUT: Entity ID to connect with
# PROCESS: Establishes bidirectional connection
# OUTPUT: Success of connection
# CHANGES: Connections array
# CONNECTION: Forms entity networks across projects
func connect_to(entity_id: String) -> bool:
	if entity_id in connections:
		return false
	
	connections.append(entity_id)
	return true

# Private helper functions
func _create_visual_representation() -> void:
	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	
	# Default to box mesh (projects can override)
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(2, 0.5, 1)  # Word plank dimensions
	mesh_instance.mesh = box_mesh

func _setup_collision() -> void:
	area_3d = Area3D.new()
	add_child(area_3d)
	
	collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(2, 0.5, 1)
	collision_shape.shape = shape
	area_3d.add_child(collision_shape)

func _apply_dimensional_color() -> void:
	# Map dimensions to colors (from Eden OS)
	var dimension_colors = {
		1: Color.AZURE,      # Foundation
		2: Color.GREEN,      # Growth (Emerald)
		3: Color.ORANGE,     # Energy (Amber)
		4: Color.PURPLE,     # Insight (Violet)
		5: Color.RED,        # Force (Crimson)
		6: Color.INDIGO,     # Vision
		7: Color.BLUE,       # Wisdom (Sapphire)
		8: Color.GOLD,       # Transcendence
		9: Color.SILVER      # Unity
	}
	
	dimensional_color = dimension_colors.get(current_dimension, Color.WHITE)
	
	# Apply to material
	if mesh_instance and mesh_instance.mesh:
		var material = StandardMaterial3D.new()
		material.albedo_color = dimensional_color
		material.emission_enabled = true
		material.emission = dimensional_color
		material.emission_energy = 0.5
		mesh_instance.material_override = material

func _can_evolve_to(target_stage: int) -> bool:
	# Basic progression check (can be overridden)
	return target_stage > evolution_stage and target_stage <= EvolutionStage.NEXUS

func _update_evolution_visuals() -> void:
	# Scale based on evolution
	var base_scale = 1.0 + (get_evolution_progress() * 0.5)
	scale = Vector3.ONE * base_scale
	
	# Increase emission with evolution
	if mesh_instance and mesh_instance.material_override:
		var mat = mesh_instance.material_override as StandardMaterial3D
		mat.emission_energy = 0.5 + (get_evolution_progress() * 1.5)