@tool
extends MeshInstance3D

signal over_head_position(origin_position)


func _process(delta):
	emit_signal("over_head_position", global_transform.origin)
#	print("over_head_position , global_transform.origin = ", global_transform.origin)
