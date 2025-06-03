# Transform Animator Component
# Animates Universal Being transforms
# Created: 2025-06-03 - Claude Desktop MCP

extends Node

class_name TransformAnimatorComponent

# Godot lifecycle functions removed - base UniversalBeing handles bridging to Pentagon Architecture

# Animation settings
var enabled: bool = true
var animate_position: bool = true
var animate_rotation: bool = true
var animate_scale: bool = false
var position_amplitude: float = 2.0
var rotation_speed: float = 1.0
var scale_amplitude: float = 0.2
var animation_speed: float = 1.0

# Internal state
var time_passed: float = 0.0
var original_position: Vector3
var original_scale: Vector3
var being_reference: Node

# Signals
signal animation_started()
signal animation_stopped()

func apply_to_being(being: Node) -> void:
	"""Apply animation to being"""
	being_reference = being
	original_position = being.position
	original_scale = being.scale
	if enabled:
		start_animation()

func start_animation() -> void:
	enabled = true
	animation_started.emit()

func stop_animation() -> void:
	enabled = false
	being_reference.position = original_position
	being_reference.scale = original_scale
	animation_stopped.emit()

func get_component_info() -> Dictionary:
	return {
		"name": "Transform Animator",
		"type": "action",
		"active": enabled
	}

func remove_from_being() -> void:
	stop_animation()

# AI Interface
func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	match method_name:
		"start": 
			start_animation()
			return "Animation started"
		"stop": 
			stop_animation()
			return "Animation stopped"
		"set_speed":
			if args.size() > 0:
				animation_speed = args[0]
				return "Speed set to " + str(args[0])
	return "Unknown method"
