# LuminusChunkUniversalBeing.gd — Luminus's elegant 10×10×10 spatial datastore
# This is Luminus's approach - we'll integrate the best parts with our existing system

extends UniversalBeing
class_name LuminusChunkUniversalBeing

## ─────────── CONSTANTS ───────────
const CHUNK_SIZE : float = 10.0        # Godot units per axis

## ─────────── STATE ────────────────
@export var coords   : Vector3i        # Grid coordinate (…-1,0,1…)
var   loaded_content : bool = false    # Has this chunk asked the Akashic Records yet?

# Debug billboard
var _label_3d : Label3D

## ─────────── PENTAGON LIFECYCLE ───
func pentagon_init() -> void:
	super.pentagon_init()
	being_name = "Chunk_%s_%s_%s" % [coords.x, coords.y, coords.z]
	being_type = "luminus_chunk"
	consciousness_level = 1
	_create_debug_label()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_request_content_from_akashic()

func pentagon_process(delta : float) -> void:
	super.pentagon_process(delta)
	# Simple distance-based self-unload hint (real culling handled by manager)
	if get_viewport().get_camera_3d():
		var cam_pos := get_viewport().get_camera_3d().global_position
		if cam_pos.distance_to(global_position) > LuminusChunkGridManager.UNLOAD_RADIUS:
			LuminusChunkGridManager.queue_unload(coords)

func pentagon_input(event : InputEvent) -> void:
	super.pentagon_input(event)

func pentagon_sewers() -> void:
	# Persist any runtime changes back to Akashic Records before freeing
	if loaded_content:
		AkashicSpatialDB.save_chunk(self)
	super.pentagon_sewers()

## ─────────── HELPERS ──────────────
func _create_debug_label() -> void:
	_label_3d = Label3D.new()
	_label_3d.text        = "Chunk (%d %d %d)" % [coords.x, coords.y, coords.z]
	_label_3d.billboard   = BaseMaterial3D.BILLBOARD_ENABLED
	_label_3d.modulate.a  = 0.6
	add_child(_label_3d)
	# centre of the cube
	_label_3d.position = Vector3(CHUNK_SIZE/2.0, CHUNK_SIZE/2.0, CHUNK_SIZE/2.0)

func _request_content_from_akashic() -> void:
	if AkashicSpatialDB.has_chunk(coords):
		AkashicSpatialDB.load_chunk_into(self)
		loaded_content = true
	else:
		# First-time visit → seed content according to Y-layer rules
		ChunkGenerator.populate(self as ChunkUniversalBeing)
		AkashicSpatialDB.save_chunk(self)
		loaded_content = true