################################################################
# GAMMA SPEECH BUBBLE SYSTEM - MANGA-STYLE TEXT BUBBLES
# Beautiful floating text bubbles for Gamma AI responses
# Created: May 31st, 2025 | Speech Bubble Revolution
# Location: scripts/core/gamma_speech_bubble.gd
################################################################

extends UniversalBeingBase
class_name GammaSpeechBubble

################################################################
# SPEECH BUBBLE COMPONENTS
################################################################

var bubble_mesh: MeshInstance3D
var text_viewport: SubViewport
var text_label: RichTextLabel
var tail_mesh: MeshInstance3D
var animation_tween: Tween

# Bubble properties
var bubble_text: String = ""
var bubble_lifetime: float = 8.0
var bubble_style: String = "manga"  # manga, thought, shout, whisper

# Visual components
var bubble_material: StandardMaterial3D
var text_container: Control

signal bubble_clicked()
signal bubble_expired()

################################################################
# INITIALIZATION
################################################################

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_create_speech_bubble()
	_setup_animations()

func _create_speech_bubble():
	"""Create the beautiful manga-style speech bubble"""
	
	# Main bubble mesh
	bubble_mesh = MeshInstance3D.new()
	add_child(bubble_mesh)
	
	# Create bubble geometry based on style
	_create_bubble_geometry()
	
	# Create text viewport system
	_create_text_system()
	
	# Create tail/pointer
	_create_bubble_tail()
	
	# Set initial scale and position
	scale = Vector3.ZERO
	
	print("💬 [GammaBubble] Speech bubble created")

func _create_bubble_geometry():
	"""Create the bubble shape based on style"""
	
	match bubble_style:
		"manga":
			var sphere = SphereMesh.new()
			sphere.radius = 1.0
			sphere.height = 1.8
			bubble_mesh.mesh = sphere
		"thought":
			var sphere = SphereMesh.new()
			sphere.radius = 0.8
			sphere.height = 1.6
			bubble_mesh.mesh = sphere
		"shout":
			var box = BoxMesh.new()
			box.size = Vector3(2.2, 1.5, 0.2)
			bubble_mesh.mesh = box
		_:
			var sphere = SphereMesh.new()
			bubble_mesh.mesh = sphere
	
	# Create bubble material
	bubble_material = MaterialLibrary.get_material("default")
	bubble_material.albedo_color = Color(1.0, 1.0, 1.0, 0.95)
	bubble_material.emission_enabled = true
	bubble_material.emission = Color(0.9, 0.95, 1.0) * 0.3
	bubble_material.flags_unshaded = true
	bubble_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	bubble_mesh.material_override = bubble_material

func _create_text_system():
	"""Create the text rendering system"""
	
	# Text viewport
	text_viewport = SubViewport.new()
	text_viewport.size = Vector2(400, 300)
	text_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(text_viewport)
	
	# Text container
	text_container = Control.new()
	text_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	FloodgateController.universal_add_child(text_container, text_viewport)
	
	# Background for text
	var text_bg = ColorRect.new()
	text_bg.color = Color(1.0, 1.0, 1.0, 0.0)  # Transparent
	text_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	FloodgateController.universal_add_child(text_bg, text_container)
	
	# Rich text label
	text_label = RichTextLabel.new()
	text_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	text_label.add_theme_constant_override("default_margin_left", 20)
	text_label.add_theme_constant_override("default_margin_right", 20)
	text_label.add_theme_constant_override("default_margin_top", 15)
	text_label.add_theme_constant_override("default_margin_bottom", 15)
	text_label.bbcode_enabled = true
	text_label.fit_content = true
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	FloodgateController.universal_add_child(text_label, text_container)
	
	# Apply viewport texture to bubble
	bubble_material.albedo_texture = text_viewport.get_texture()

func _create_bubble_tail():
	"""Create the speech bubble tail/pointer"""
	
	tail_mesh = MeshInstance3D.new()
	add_child(tail_mesh)
	
	# Create tail geometry
	var tail_shape = BoxMesh.new()
	tail_shape.size = Vector3(0.3, 0.8, 0.1)
	tail_mesh.mesh = tail_shape
	
	# Position tail
	tail_mesh.position = Vector3(0, -1.2, 0)
	tail_mesh.rotation_degrees = Vector3(0, 0, 25)
	
	# Tail material
	var tail_material = bubble_material.duplicate()
	tail_mesh.material_override = tail_material

################################################################
# SPEECH BUBBLE CONTENT
################################################################


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func set_text(text: String, style: String = "manga"):
	"""Set the speech bubble text and style"""
	bubble_text = text
	bubble_style = style
	
	# Style the text based on bubble type
	var styled_text = _style_text_for_bubble(text, style)
	text_label.text = styled_text
	
	# Adjust bubble size based on text length
	_adjust_bubble_size()
	
	print("💬 [GammaBubble] Text set: " + text.substr(0, 50) + "...")

func _style_text_for_bubble(text: String, style: String) -> String:
	"""Apply styling to text based on bubble style"""
	
	var styled = ""
	
	match style:
		"manga":
			styled = "[center][color=#000000][font_size=16]"
			styled += text
			styled += "[/font_size][/color][/center]"
		"thought":
			styled = "[center][color=#444444][font_size=14][i]"
			styled += text
			styled += "[/i][/font_size][/color][/center]"
		"shout":
			styled = "[center][color=#FF0000][font_size=20][b]"
			styled += text.to_upper()
			styled += "[/b][/font_size][/color][/center]"
		"whisper":
			styled = "[center][color=#666666][font_size=12]"
			styled += text.to_lower()
			styled += "[/font_size][/color][/center]"
		_:
			styled = "[center][color=#000000][font_size=16]" + text + "[/font_size][/color][/center]"
	
	return styled

func _adjust_bubble_size():
	"""Adjust bubble size based on text content"""
	
	var text_length = bubble_text.length()
	var scale_factor = 1.0
	
	if text_length > 200:
		scale_factor = 1.5
	elif text_length > 100:
		scale_factor = 1.3
	elif text_length > 50:
		scale_factor = 1.1
	
	# Apply scale to mesh only
	bubble_mesh.scale = Vector3.ONE * scale_factor
	tail_mesh.scale = Vector3.ONE * scale_factor

################################################################
# ANIMATIONS
################################################################

func _setup_animations():
	"""Set up bubble animations"""
	animation_tween = create_tween()

func show_bubble():
	"""Animate bubble appearing"""
	
	# Appear animation
	if animation_tween:
		animation_tween.kill()
	
	animation_tween = create_tween()
	animation_tween.set_parallel(true)
	
	# Scale up from zero
	animation_tween.tween_property(self, "scale", Vector3.ONE, 0.5)
	animation_tween.tween_method(_bounce_effect, 0.0, 1.0, 0.5)
	
	# Auto-hide after lifetime
	animation_tween.tween_callback(_start_lifetime_timer).set_delay(0.5)
	
	print("💬 [GammaBubble] Showing bubble")

func _bounce_effect(progress: float):
	"""Create bounce effect during appearance"""
	var bounce = sin(progress * PI * 3) * 0.1 * (1.0 - progress)
	scale = Vector3.ONE * (progress + bounce)

func _start_lifetime_timer():
	"""Start the bubble lifetime countdown"""
	var timer = get_tree().create_timer(bubble_lifetime)
	timer.timeout.connect(_hide_bubble)

func _hide_bubble():
	"""Animate bubble disappearing"""
	
	if animation_tween:
		animation_tween.kill()
	
	animation_tween = create_tween()
	animation_tween.tween_property(self, "scale", Vector3.ZERO, 0.3)
	animation_tween.tween_callback(_bubble_finished)
	
	bubble_expired.emit()

func _bubble_finished():
	"""Called when bubble animation finishes"""
	queue_free()

################################################################
# INTERACTION
################################################################

func _input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	"""Handle clicks on the speech bubble"""
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("💬 [GammaBubble] Bubble clicked!")
			bubble_clicked.emit()
			_hide_bubble()

################################################################
# PUBLIC API
################################################################

func create_gamma_speech(text: String, position: Vector3, style: String = "manga") -> GammaSpeechBubble:
	"""Static method to create a speech bubble for Gamma"""
	
	var bubble = GammaSpeechBubble.new()
	bubble.global_position = position
	bubble.set_text(text, style)
	
	return bubble

################################################################
# END OF GAMMA SPEECH BUBBLE
################################################################