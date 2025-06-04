# ==================================================
# COMPONENT: Dimensional Sight
# DESCRIPTION: Dimensional perception and visualization component
# ==================================================

extends Node
class_name DimensionalSightComponent

var sight_ready: bool = false

func _ready() -> void:
	name = "DimensionalSightComponent"
	print("👁️‍🗨️ Dimensional Sight Component loaded")

func initialize_component() -> void:
	sight_ready = true
	print("👁️‍🗨️ Dimensional Sight initialized")

func get_component_info() -> Dictionary:
	return {"name": "Dimensional Sight", "ready": sight_ready}