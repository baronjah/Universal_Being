#@tool
extends Node3D

func _on_mover_movement_send(current_origin):
	global_transform.origin = current_origin
	#print("on mover =", global_transform.origin)
