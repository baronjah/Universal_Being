@tool
extends Node3D

@onready var child_mesh = $ChildMesh  # Assuming you have a child node named ChildMesh

func _ready():
	pass

func _process(delta):
	look_at_sun()

func look_at_sun():
	# Assuming the sun is at (0, 0, 0)
	var sun_position = Vector3.ZERO
	
	# Calculate direction to sun in global space
	var direction_to_sun = (sun_position - global_position).normalized()
	
	# Transform the direction to local space
	var local_direction = global_transform.basis.inverse() * direction_to_sun
	
	# Make the child mesh look at this direction
	# We need to use a point in front of the mesh, not the direction itself
	var target_position = child_mesh.position + local_direction
	
	# Look at the target position
	child_mesh.look_at(target_position, Vector3.UP)
