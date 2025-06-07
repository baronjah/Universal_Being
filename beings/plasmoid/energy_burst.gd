extends Node3D
class_name EnergyBurst

var target_position: Vector3
var source_being: Node3D
var speed: float = 10.0

func _ready():
	# Auto-destroy after a short time
	create_tween().tween_callback(queue_free).set_delay(2.0)

func _process(delta):
	if target_position:
		var direction = (target_position - global_position).normalized()
		global_position += direction * speed * delta
		
		# Remove when close to target
		if global_position.distance_to(target_position) < 0.5:
			queue_free()
