# ==================================================
# UNIVERSAL BEING: 3D Button Universal Being
# TYPE: button_3d
# PURPOSE: Simple 3D button that can be clicked in 3D space
# ==================================================

extends UniversalBeing
class_name Button3DUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var click_count: int = 0
@export var consciousness_per_click: float = 0.1

# 3D button references
var mesh_instance: MeshInstance3D
var area_3d: Area3D
var material: StandardMaterial3D
var base_color: Color = Color.WHITE

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()  # 🌱 ALWAYS CALL SUPER FIRST
	
	being_type = "button_3d"
	being_name = "3D Button"
	consciousness_level = 0
	
	print("🌟 %s: Pentagon Init Complete" % being_name)

func pentagon_ready() -> void:
	super.pentagon_ready()  # 🔄 ALWAYS CALL SUPER FIRST
	
	# Find child nodes
	mesh_instance = find_child("MeshInstance3D") as MeshInstance3D
	area_3d = find_child("Area3D", true) as Area3D
	
	# Set up material for visual feedback
	if mesh_instance and mesh_instance.mesh:
		material = StandardMaterial3D.new()
		material.albedo_color = base_color
		mesh_instance.material_override = material
	
	# Connect area signals
	if area_3d:
		area_3d.input_event.connect(_on_area_input_event)
		area_3d.mouse_entered.connect(_on_mouse_entered)
		area_3d.mouse_exited.connect(_on_mouse_exited)
	
	print("🌟 %s: Pentagon Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)  # ⚡ ALWAYS CALL SUPER FIRST
	
	# Update visual based on consciousness
	if material:
		material.albedo_color = consciousness_aura_color
		
		# Add glow based on consciousness level
		if consciousness_level > 0:
			material.emission_enabled = true
			material.emission = consciousness_aura_color
			material.emission_energy = consciousness_level * 0.2

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)  # 👂 ALWAYS CALL SUPER FIRST

func pentagon_sewers() -> void:
	print("🌟 %s: Pentagon Sewers - Total clicks: %d" % [being_name, click_count])
	super.pentagon_sewers()  # 💀 ALWAYS CALL SUPER LAST

# ===== BUTTON-SPECIFIC METHODS =====

func _on_area_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_button_clicked()

func _on_button_clicked() -> void:
	click_count += 1
	
	# Increase consciousness with each click
	consciousness_level = mini(5, int(click_count * consciousness_per_click))
	update_consciousness_visual()
	
	print("🔘 %s clicked! Count: %d, Consciousness: %d" % [being_name, click_count, consciousness_level])
	
	# Visual feedback - pulse effect
	if mesh_instance:
		var tween = get_tree().create_tween()
		tween.tween_property(mesh_instance, "scale", Vector3.ONE * 1.2, 0.1)
		tween.tween_property(mesh_instance, "scale", Vector3.ONE, 0.1)
	
	# Emit consciousness awakening at milestones
	if click_count in [10, 25, 50, 100]:
		consciousness_awakened.emit(consciousness_level)

func _on_mouse_entered() -> void:
	if mesh_instance:
		mesh_instance.scale = Vector3.ONE * 1.1

func _on_mouse_exited() -> void:
	if mesh_instance:
		mesh_instance.scale = Vector3.ONE

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	pass
	var base = super.ai_interface()
	base.button_state = {
		"clicks": click_count,
		"is_3d": true
	}
	return base

func _to_string() -> String:
	return "Button3DUniversalBeing<%s> [Clicks:%d, Consciousness:%d]" % [being_name, click_count, consciousness_level]