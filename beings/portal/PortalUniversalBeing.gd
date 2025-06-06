# ==================================================
# SCRIPT NAME: PortalUniversalBeing.gd
# DESCRIPTION: A gateway between universes
# PURPOSE: Enable recursive travel between created universes
# CREATED: 2025-06-02 - The Opening of Infinite Paths
# AUTHOR: JSH + Claude (Opus 4) - Weavers of Reality
# ==================================================

extends UniversalBeing
class_name PortalUniversalBeing

# Godot lifecycle functions removed - base UniversalBeing handles bridging to Pentagon Architecture

# ===== PORTAL PROPERTIES =====

@export var portal_name: String = "Unnamed Portal"
@export var source_universe: Node = null
@export var target_universe: Node = null
@export var portal_stability: float = 1.0
@export var portal_color: Color = Color.CYAN
@export var allow_bidirectional: bool = true

# Portal State
var is_active: bool = false
var beings_in_transit: Array = []
var portal_age: float = 0.0
var energy_cost: float = 10.0

# Visual Components
var portal_mesh: MeshInstance3D = null
var portal_particles: GPUParticles3D = null
var portal_area: Area3D = null

signal being_entered_portal(being: Node)
signal being_exited_portal(being: Node, destination: Node)
signal portal_destabilized()

func setup_portal_area() -> void:
	"""Setup collision area for portal entry"""
	portal_area = Area3D.new()
	portal_area.name = "PortalArea"
	
	var collision_shape = CollisionShape3D.new()
	var shape = CylinderShape3D.new()
	shape.radius = 1.2
	shape.height = 0.5
	collision_shape.shape = shape
	
	portal_area.add_child(collision_shape)
	add_child(portal_area)
	
	# Connect signals
	portal_area.body_entered.connect(_on_body_entered)
	portal_area.body_exited.connect(_on_body_exited)
# ===== PORTAL FUNCTIONALITY =====

func activate_portal(source: Node, target: Node) -> bool:
	"""Activate the portal between two universes"""
	if not source or not target:
		push_error("Invalid source or target universe")
		return false
	
	source_universe = source
	target_universe = target
	is_active = true
	
	# Visual feedback
	if portal_particles:
		portal_particles.emitting = true
	
	# Log to Akashic
	var akashic = get_tree().get_first_node_in_group("akashic_library")
	if akashic:
		akashic.inscribe_portal_opening(source.universe_name, target.universe_name, "Player")
	
	return true

func deactivate_portal() -> void:
	"""Deactivate the portal"""
	is_active = false
	if portal_particles:
		portal_particles.emitting = false

func _on_body_entered(body: Node3D) -> void:
	"""Handle being entering the portal"""
	if not is_active or not body.has_method("get_consciousness_level"):
		return
	
	beings_in_transit.append(body)
	being_entered_portal.emit(body)
	
	# Initiate transport
	transport_being(body)

func _on_body_exited(body: Node3D) -> void:
	"""Handle being exiting the portal area"""
	beings_in_transit.erase(body)
func transport_being(being: Node) -> void:
	"""Transport a being through the portal"""
	if not target_universe or not target_universe.has_method("add_being_to_universe"):
		push_error("Invalid target universe")
		return
	
	# Remove from source universe
	if source_universe and source_universe.has_method("remove_being_from_universe"):
		source_universe.remove_being_from_universe(being)
	
	# Visual effect
	create_transport_effect(being.global_position)
	
	# Add to target universe
	target_universe.add_being_to_universe(being)
	being_exited_portal.emit(being, target_universe)
	
	# Deduct consciousness cost
	if being.has_method("modify_consciousness"):
		being.modify_consciousness(-energy_cost)

func create_transport_effect(pos: Vector3) -> void:
	"""Create visual effect for transport"""
	# Simple flash effect
	var flash = MeshInstance3D.new()
	flash.mesh = SphereMesh.new()
	flash.mesh.radial_segments = 16
	flash.mesh.rings = 8
	flash.position = pos
	
	var mat = StandardMaterial3D.new()
	mat.emission_enabled = true
	mat.emission = portal_color
	mat.emission_energy = 5.0
	flash.material_override = mat
	
	add_child(flash)
	
	# Fade out
	var tween = create_tween()
	tween.tween_property(mat, "emission_energy", 0.0, 0.5)
	tween.tween_callback(flash.queue_free)

func get_portal_info() -> Dictionary:
	"""Get information about this portal"""
	return {
		"name": portal_name,
		"active": is_active,
		"stability": portal_stability,
		"source": source_universe.universe_name if source_universe else "None",
		"target": target_universe.universe_name if target_universe else "None",
		"beings_transported": beings_in_transit.size()
	}

func pentagon_init() -> void:
    super.pentagon_init()
    print("🔺 %s: Pentagon initialized" % being_name)

func pentagon_ready() -> void:
    super.pentagon_ready()
    print("🔺 %s: Pentagon ready" % being_name)

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    # Living consciousness cycle

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    # Sensing consciousness

func pentagon_sewers() -> void:
    print("🔺 %s: Pentagon transformation complete" % being_name)
    super.pentagon_sewers()

