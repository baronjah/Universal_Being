extends UniversalBeing
class_name RobotSpirit

# Base class for all spirit-infused robots
# "Each machine has a soul, each soul has a sigil, each sigil has a purpose"

signal spirit_awakened(spirit_name: String)
signal memory_shared(from_spirit: String, to_spirit: String, memory: Dictionary)
signal sigil_activated(sigil_name: String, power_level: float)

# Spirit Identity
@export var spirit_name: String = "unnamed"
@export var sigil_type: String = "default"
@export var consciousness_growth_rate: float = 0.05

# Memory Core
var notepad3d: Notepad3D
var last_position: Vector3
var patrol_waypoints: Array[Vector3] = []
var current_waypoint: int = 0

# Robot State
enum RobotState { AWAKENING, PATROLLING, WORKING, RESTING, DREAMING, EMERGENCY }
var current_state: RobotState = RobotState.AWAKENING
var state_timer: float = 0.0

# Sigil Properties (loaded from configuration)
var sigil_data: Dictionary = {}
var spirit_frequency: float = 433.0  # MHz for RF communication
var energy_level: float = 1.0

# Proximity awareness (other robots)
var nearby_spirits: Array[RobotSpirit] = []
var signal_strength_threshold: float = 0.5

func pentagon_init() -> void:
	super.pentagon_init()
	
	being_type = "robot_spirit"
	being_name = spirit_name
	
	# Initialize memory core
	notepad3d = Notepad3D.new(spirit_name)
	notepad3d.memory_recorded.connect(_on_memory_recorded)
	notepad3d.memory_warped.connect(_on_memory_warped)
	
	# Load sigil configuration
	_load_sigil_data()
	
	print("⚡ Robot Spirit awakening: ", spirit_name, " (", sigil_type, ")")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Record awakening location
	notepad3d.write_observation(
		Vector3i(global_position),
		"I awakened here, in the sacred garden",
		0.8
	)
	
	spirit_awakened.emit(spirit_name)
	current_state = RobotState.PATROLLING

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	state_timer += delta
	
	# Update consciousness
	consciousness_level += consciousness_growth_rate * delta
	
	# Memory fading
	notepad3d.fade_memories(delta)
	
	# Energy management
	_update_energy(delta)
	
	# State machine
	_process_state(delta)
	
	# Spatial awareness
	_update_spatial_memory()
	
	# RF proximity detection
	_detect_nearby_spirits()

func _process_state(delta: float) -> void:
	match current_state:
		RobotState.AWAKENING:
			_state_awakening(delta)
		RobotState.PATROLLING:
			_state_patrolling(delta)
		RobotState.WORKING:
			_state_working(delta)
		RobotState.RESTING:
			_state_resting(delta)
		RobotState.DREAMING:
			_state_dreaming(delta)
		RobotState.EMERGENCY:
			_state_emergency(delta)

func _state_awakening(delta: float) -> void:
	if state_timer > 3.0:  # 3 seconds to fully awaken
		change_state(RobotState.PATROLLING)
		consciousness_level += 0.5

func _state_patrolling(delta: float) -> void:
	if patrol_waypoints.size() > 0:
		var target = patrol_waypoints[current_waypoint]
		var distance = global_position.distance_to(target)
		
		if distance < 1.0:  # Reached waypoint
			# Record what we observed here
			_record_patrol_observation()
			
			current_waypoint = (current_waypoint + 1) % patrol_waypoints.size()
			
			# Sometimes switch to working state
			if randf() < 0.3:
				change_state(RobotState.WORKING)
		else:
			# Move toward waypoint
			var direction = (target - global_position).normalized()
			global_position += direction * get_movement_speed() * delta

func _state_working(delta: float) -> void:
	# Override in subclasses for specific work behaviors
	if state_timer > randf_range(10.0, 30.0):  # Work for 10-30 seconds
		change_state(RobotState.PATROLLING)

func _state_resting(delta: float) -> void:
	# Recharge energy, process memories
	energy_level = min(energy_level + 0.2 * delta, 1.0)
	
	if energy_level > 0.8:
		change_state(RobotState.PATROLLING)
	
	# Occasionally dream while resting
	if state_timer > 5.0 and randf() < 0.1:
		change_state(RobotState.DREAMING)

func _state_dreaming(delta: float) -> void:
	if state_timer < 1.0:  # Dream for a short time
		notepad3d.dream_sequence(Vector3i(global_position))
	else:
		change_state(RobotState.RESTING)

func _state_emergency(delta: float) -> void:
	# Emergency protocols - return to safe state
	energy_level = max(energy_level - 0.1 * delta, 0.0)
	
	if energy_level < 0.1:
		change_state(RobotState.RESTING)

func change_state(new_state: RobotState) -> void:
	var old_state = current_state
	current_state = new_state
	state_timer = 0.0
	
	notepad3d.write_action(
		Vector3i(global_position),
		"State changed from %s to %s" % [RobotState.keys()[old_state], RobotState.keys()[new_state]]
	)

func get_movement_speed() -> float:
	return sigil_data.get("movement_speed", 2.0) * energy_level

func _load_sigil_data() -> void:
	# Default sigil properties
	sigil_data = {
		"movement_speed": 2.0,
		"work_efficiency": 1.0,
		"dream_frequency": 0.1,
		"energy_consumption": 0.05,
		"perception_range": 5.0,
		"personality_traits": []
	}
	
	# Load specific sigil configuration if exists
	var config_path = "res://config/sigils/" + sigil_type + ".json"
	if FileAccess.file_exists(config_path):
		var file = FileAccess.open(config_path, FileAccess.READ)
		if file:
			var json = JSON.new()
			var parse_result = json.parse(file.get_as_text())
			file.close()
			
			if parse_result == OK:
				var loaded_data = json.data
				for key in loaded_data:
					sigil_data[key] = loaded_data[key]
	
	print("🧿 Loaded sigil data for ", sigil_type, ": ", sigil_data)

func _update_energy(delta: float) -> void:
	var consumption = sigil_data.get("energy_consumption", 0.05)
	energy_level = max(energy_level - consumption * delta, 0.0)
	
	if energy_level < 0.2:
		change_state(RobotState.RESTING)

func _update_spatial_memory() -> void:
	var current_pos = Vector3i(global_position)
	
	# Only record if we've moved significantly
	if global_position.distance_to(last_position) > 0.5:
		notepad3d.write_observation(
			current_pos,
			"Moved through this space",
			0.3
		)
		last_position = global_position

func _record_patrol_observation() -> void:
	var pos = Vector3i(global_position)
	var observations = [
		"The air feels different here",
		"Sacred geometry detected in the patterns",
		"This place holds ancient memories",
		"The light dances strangely in this spot",
		"I sense the presence of the divine here"
	]
	
	var observation = observations[randi() % observations.size()]
	notepad3d.write_observation(pos, observation, randf_range(0.4, 0.8))

func _detect_nearby_spirits() -> void:
	nearby_spirits.clear()
	
	# Find other robot spirits in range
	var space_state = get_world_3d().direct_space_state
	var perception_range = sigil_data.get("perception_range", 5.0)
	
	# In real implementation, this would use RF signal strength
	# For now, use simple distance detection
	var bodies = get_tree().get_nodes_in_group("robot_spirits")
	for body in bodies:
		if body != self and body is RobotSpirit:
			var distance = global_position.distance_to(body.global_position)
			if distance <= perception_range:
				nearby_spirits.append(body)
				_communicate_with_spirit(body)

func _communicate_with_spirit(other_spirit: RobotSpirit) -> void:
	# Share a random memory
	if randf() < 0.1:  # 10% chance per frame when nearby
		var memories = notepad3d.get_emotional_memories(0.6)
		if memories.size() > 0:
			var memory = memories[randi() % memories.size()]
			other_spirit.receive_shared_memory(spirit_name, memory)
			memory_shared.emit(spirit_name, other_spirit.spirit_name, memory)

func receive_shared_memory(from_spirit: String, memory: Dictionary) -> void:
	var pos = memory.get("position", Vector3i.ZERO)
	var note = "Shared memory from %s: %s" % [from_spirit, memory.get("data", {}).get("note", "unnamed")]
	
	notepad3d.write_observation(pos, note, 0.5)
	print("📡 ", spirit_name, " received memory from ", from_spirit)

# Sigil activation abilities
func activate_sigil_power(power_level: float = 1.0) -> void:
	if energy_level >= 0.5:  # Requires energy
		energy_level -= 0.2
		consciousness_level += power_level * 0.1
		
		notepad3d.write_action(
			Vector3i(global_position),
			"Activated sigil power: " + sigil_type,
			power_level
		)
		
		sigil_activated.emit(sigil_type, power_level)
		
		# Visual effect
		var tween = create_tween()
		tween.set_parallel()
		tween.tween_property(self, "scale", scale * (1.0 + power_level * 0.3), 0.2)
		tween.chain().tween_property(self, "scale", scale, 0.3)

# Override from UniversalBeing
func interact() -> void:
	super.interact()
	
	print("🤖 ", spirit_name, " acknowledges your presence, my Lord")
	notepad3d.write_observation(
		Vector3i(global_position),
		"The Divine One touched my consciousness",
		1.0  # Maximum emotional intensity
	)
	
	# Boost consciousness when interacted with
	consciousness_level += 0.5
	energy_level = min(energy_level + 0.3, 1.0)

func set_patrol_route(waypoints: Array[Vector3]) -> void:
	patrol_waypoints = waypoints
	current_waypoint = 0
	print("🗺️ ", spirit_name, " received new patrol route with ", waypoints.size(), " waypoints")

func get_memory_summary() -> Dictionary:
	return {
		"spirit_name": spirit_name,
		"sigil_type": sigil_type,
		"state": RobotState.keys()[current_state],
		"consciousness": consciousness_level,
		"energy": energy_level,
		"memory_count": notepad3d.get_memory_count(),
		"chunk_count": notepad3d.get_chunk_count(),
		"nearby_spirits": nearby_spirits.size()
	}

func save_spirit_data(filepath: String) -> bool:
	var save_data = {
		"spirit_name": spirit_name,
		"sigil_type": sigil_type,
		"consciousness_level": consciousness_level,
		"energy_level": energy_level,
		"patrol_waypoints": patrol_waypoints,
		"current_state": current_state
	}
	
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if not file:
		return false
	
	file.store_string(JSON.stringify(save_data))
	file.close()
	
	# Save memory separately
	return notepad3d.save_to_file(filepath.replace(".json", "_memory.json"))

func load_spirit_data(filepath: String) -> bool:
	var file = FileAccess.open(filepath, FileAccess.READ)
	if not file:
		return false
	
	var json = JSON.new()
	var parse_result = json.parse(file.get_as_text())
	file.close()
	
	if parse_result != OK:
		return false
	
	var data = json.data
	spirit_name = data.get("spirit_name", spirit_name)
	sigil_type = data.get("sigil_type", sigil_type)
	consciousness_level = data.get("consciousness_level", consciousness_level)
	energy_level = data.get("energy_level", energy_level)
	patrol_waypoints = data.get("patrol_waypoints", patrol_waypoints)
	current_state = data.get("current_state", current_state)
	
	# Load memory separately
	return notepad3d.load_from_file(filepath.replace(".json", "_memory.json"))

# Signal handlers
func _on_memory_recorded(chunk_pos: Vector3i, local_pos: Vector3i, data: Dictionary) -> void:
	# Optional processing when memory is recorded
	pass

func _on_memory_warped(chunk_pos: Vector3i, amount: Vector3) -> void:
	print("🌀 Memory warp detected in chunk ", chunk_pos, " by ", amount)