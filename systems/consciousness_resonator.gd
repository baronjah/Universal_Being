# ==================================================
# COMPONENT NAME: Consciousness Resonator
# TYPE: Consciousness/Visual Component
# PURPOSE: Resonates with universe DNA consciousness traits
# SOCKET: consciousness (primary), visual, action
# ==================================================

extends Node

signal resonance_peak(resonance_intensity: float)
signal consciousness_sync(resonant_being: Node, target_universe: Node)
signal dna_response(trait_name: String, trait_value: float)

# Component properties
var resonance_strength: float = 1.0
var pulse_frequency: float = 2.0
var dna_sensitivity: float = 0.8

# Internal state
var target_being: Node = null
var current_universe: Node = null
var pulse_timer: float = 0.0
var visual_node: Node3D = null
var particles: GPUParticles3D = null

# DNA trait connections
var monitored_traits = [
	"awareness_coefficient",
	"creativity_factor", 
	"harmony_resonance",
	"evolution_rate"
]

func apply_to_being(being: Node) -> void:
	"""Apply consciousness resonator to a Universal Being"""
	target_being = being
	
	# Create visual representation
	_create_resonance_visual()
	
	# Find current universe
	_find_current_universe()
	
	# Initial DNA sync
	if current_universe:
		sync_with_universe_dna()
	
	print("✨ Consciousness Resonator activated on %s" % being.name)

func _create_resonance_visual() -> void:
	"""Create the visual resonance effect"""
	if not target_being:
		return
	
	# Create container
	visual_node = Node3D.new()
	visual_node.name = "ConsciousnessResonanceEffect"
	target_being.add_child(visual_node)
	
	# Create particle system
	particles = GPUParticles3D.new()
	particles.amount = 50
	particles.lifetime = 2.0
	particles.preprocess = 0.5
	particles.emitting = true
	
	# Configure particle material
	var process_material = ParticleProcessMaterial.new()
	process_material.direction = Vector3(0, 1, 0)
	process_material.initial_velocity_min = 0.5
	process_material.initial_velocity_max = 1.5
	process_material.angular_velocity_min = -180.0
	process_material.angular_velocity_max = 180.0
	process_material.orbit_velocity_min = 0.1
	process_material.orbit_velocity_max = 0.3
	process_material.scale_min = 0.1
	process_material.scale_max = 0.3
	process_material.color = Color(0.8, 0.2, 1.0, 0.6)
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process_material.emission_sphere_radius = 1.0
	
	particles.process_material = process_material
	particles.draw_pass_1 = SphereMesh.new()
	particles.draw_pass_1.radial_segments = 8
	particles.draw_pass_1.rings = 4
	
	visual_node.add_child(particles)

func _find_current_universe() -> void:
	"""Find the universe this being belongs to"""
	var parent = target_being.get_parent()
	while parent:
		if parent.has_method("get_universe_dna"):
			current_universe = parent
			break
		parent = parent.get_parent()

func sync_with_universe_dna() -> void:
	"""Synchronize resonator with universe DNA traits"""
	if not current_universe or not current_universe.has_method("get_universe_dna"):
		return
	
	var universe_dna = current_universe.get_universe_dna()
	var total_resonance = 0.0
	
	for trait_name in monitored_traits:
		if trait_name in universe_dna:
			var trait_value = universe_dna[trait_name]
			total_resonance += trait_value * dna_sensitivity
			dna_response.emit(trait_name, trait_value)
			
			# Adjust visual based on trait
			_adjust_visual_for_trait(trait_name, trait_value)
	
	# Update overall resonance
	resonance_strength = clamp(total_resonance / monitored_traits.size(), 0.1, 2.0)
	
	consciousness_sync.emit(target_being, current_universe)
	print("🧬 Resonator synced with universe DNA - strength: %.2f" % resonance_strength)

func _adjust_visual_for_trait(trait_name: String, trait_value: float) -> void:
	"""Adjust visual effects based on DNA trait"""
	if not particles:
		return
	
	var material = particles.process_material as ParticleProcessMaterial
	
	match trait_name:
		"awareness_coefficient":
			# Higher awareness = more particles
			particles.amount = int(50 * trait_value)
		"creativity_factor":
			# Higher creativity = more colorful
			var hue = trait_value * 0.8  # 0 to 0.8 (red to magenta)
			material.color = Color.from_hsv(hue, 0.8, 1.0, 0.6)
		"harmony_resonance":
			# Higher harmony = smoother movement
			material.orbit_velocity_min = 0.1 * (1.0 - trait_value)
			material.orbit_velocity_max = 0.3 * (1.0 - trait_value)
		"evolution_rate":
			# Higher evolution = faster particles
			particles.speed_scale = 0.5 + trait_value * 1.5

func trigger_resonance_burst() -> void:
	"""Trigger a burst of resonance energy"""
	if particles:
		particles.restart()
		particles.amount *= 3
		
		# Reset after burst
		get_tree().create_timer(1.0).timeout.connect(func(): particles.amount = 50)
	
	resonance_peak.emit(resonance_strength * 2.0)
	print("💫 Resonance burst triggered!")

func set_resonance_strength(strength: float) -> void:
	"""AI method to set resonance strength"""
	resonance_strength = clamp(strength, 0.1, 3.0)
	print("🎮 Resonance strength set to: %.2f" % resonance_strength)

func remove_from_being() -> void:
	"""Clean up when component is removed"""
	if visual_node:
		visual_node.queue_free()
	
	queue_free()

# AI Interface Methods
func ai_get_info() -> Dictionary:
	"""Provide component info to AI"""
	return {
		"type": "consciousness_resonator",
		"resonance_strength": resonance_strength,
		"pulse_frequency": pulse_frequency,
		"dna_sensitivity": dna_sensitivity,
		"current_universe": current_universe.name if current_universe else "none",
		"monitored_traits": monitored_traits
	}

func ai_invoke_method(method_name: String, args: Array) -> Variant:
	"""AI method invocation"""
	match method_name:
		"set_resonance_strength":
			if args.size() > 0:
				set_resonance_strength(float(args[0]))
				return true
		"sync_with_universe_dna":
			sync_with_universe_dna()
			return true
		"trigger_resonance_burst":
			trigger_resonance_burst()
			return true
	return false
