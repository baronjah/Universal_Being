
# Resource spawner for your space scenes
class_name ResourceField
extends Node3D

@export var field_radius: float = 1000.0
@export var resource_count: int = 50
@export var resource_distribution: Dictionary = {
	ResourceType.METAL: 0.5,
	ResourceType.CRYSTAL: 0.3,
	ResourceType.ENERGY: 0.15,
	ResourceType.QUANTUM: 0.05
}

func _ready():
	generate_resource_field()

func generate_resource_field():
	var resource_scene = preload("res://scenes/space_resource.tscn")
	
	for i in range(resource_count):
		# Random position in sphere
		var pos = Vector3(
			randf_range(-1, 1),
			randf_range(-1, 1),
			randf_range(-1, 1)
		).normalized()
		pos *= randf() * field_radius
		
		# Determine resource type
		var type = _weighted_random_resource()
		
		# Create resource
		var resource = SpaceResource.new()
		resource.position = pos
		resource.resource_type = type
		resource.resource_amount = randf_range(50, 150)
		
		# Rarer resources are harder to mine
		match type:
			ResourceType.QUANTUM:
				resource.mining_difficulty = 3.0
			ResourceType.ENERGY:
				resource.mining_difficulty = 2.0
			ResourceType.CRYSTAL:
				resource.mining_difficulty = 1.5
			_:
				resource.mining_difficulty = 1.0
		
		add_child(resource)

func _weighted_random_resource() -> ResourceType:
	var rand = randf()
	var cumulative = 0.0
	
	for type in resource_distribution:
		cumulative += resource_distribution[type]
		if rand <= cumulative:
			return type
	
	return ResourceType.METAL  # Fallback
