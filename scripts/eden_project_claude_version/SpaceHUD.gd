# SpaceHUD.gd
extends Control
class_name SpaceHUD

# HUD components
@onready var energy_bar: ProgressBar = $StatusPanel/EnergyBar
@onready var shield_bar: ProgressBar = $StatusPanel/ShieldBar
@onready var consciousness_bar: ProgressBar = $StatusPanel/ConsciousnessBar
@onready var frequency_label: Label = $StatusPanel/FrequencyLabel
@onready var velocity_label: Label = $StatusPanel/VelocityLabel
@onready var position_label: Label = $StatusPanel/PositionLabel
@onready var system_label: Label = $StatusPanel/SystemLabel

# Resource display
@onready var resource_container: VBoxContainer = $ResourcePanel/ResourceList
var resource_labels: Dictionary = {}

# Messages and notifications
@onready var message_container: VBoxContainer = $MessagePanel/MessageContainer
@onready var notification_container: VBoxContainer = $NotificationContainer
var message_queue: Array = []
var active_notifications: Array = []

# Companion interface
@onready var companion_panel: Panel = $CompanionPanel
@onready var companion_name: Label = $CompanionPanel/CompanionName
@onready var companion_message: RichTextLabel = $CompanionPanel/CompanionMessage
@onready var companion_emotion: Label = $CompanionPanel/EmotionLabel
@onready var companion_portrait: TextureRect = $CompanionPanel/Portrait

# Target information
@onready var target_panel: Panel = $TargetPanel
@onready var target_name: Label = $TargetPanel/TargetName
@onready var target_distance: Label = $TargetPanel/DistanceLabel
@onready var target_composition: ItemList = $TargetPanel/CompositionList

# Minimap
@onready var minimap: Control = $Minimap
@onready var minimap_viewport: SubViewport = $Minimap/ViewportContainer/Viewport
@onready var minimap_camera: Camera3D = $Minimap/ViewportContainer/Viewport/Camera3D

# Star chart preview
@onready var star_chart_preview: Control = $StarChartPreview
@onready var current_route: Line2D = $StarChartPreview/CurrentRoute

# Consciousness visualization
@onready var consciousness_indicator: Control = $ConsciousnessIndicator
@onready var perception_ring: TextureRect = $ConsciousnessIndicator/PerceptionRing
@onready var frequency_wave: Line2D = $ConsciousnessIndicator/FrequencyWave

# Crosshair
@onready var crosshair: TextureRect = $Crosshair
@onready var mining_indicator: TextureRect = $Crosshair/MiningIndicator

# Settings
@export var message_lifetime: float = 5.0
@export var notification_lifetime: float = 3.0
@export var companion_message_duration: float = 4.0
@export var hud_color: Color = Color(0.0, 1.0, 0.5)
@export var warning_color: Color = Color(1.0, 0.5, 0.0)
@export var critical_color: Color = Color(1.0, 0.0, 0.0)

# References
var player_ship: PlayerShip = null
var consciousness_system: ConsciousnessSystem = null
var stellar_system: StellarProgressionSystem = null
var companion_system: AICompanionSystem = null

# State
var is_visible: bool = true
var current_target: Node3D = null
var flash_timers: Dictionary = {}

func _ready() -> void:
	_setup_hud_layout()
	_initialize_resource_display()
	_setup_minimap()
	_connect_to_systems()
	_apply_hud_theme()

func _setup_hud_layout() -> void:
	# Create main panels if they don't exist
	if not has_node("StatusPanel"):
		_create_status_panel()
	if not has_node("ResourcePanel"):
		_create_resource_panel()
	if not has_node("MessagePanel"):
		_create_message_panel()
	if not has_node("CompanionPanel"):
		_create_companion_panel()
	if not has_node("TargetPanel"):
		_create_target_panel()
	if not has_node("Minimap"):
		_create_minimap()
	if not has_node("ConsciousnessIndicator"):
		_create_consciousness_indicator()
	if not has_node("Crosshair"):
		_create_crosshair()

func _create_status_panel() -> void:
	var panel = Panel.new()
	panel.name = "StatusPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	panel.size = Vector2(300, 200)
	panel.position = Vector2(20, 20)
	add_child(panel)
	
	# Energy bar
	var energy_container = HBoxContainer.new()
	energy_container.position = Vector2(10, 10)
	panel.add_child(energy_container)
	
	var energy_label = Label.new()
	energy_label.text = "Energy:"
	energy_label.custom_minimum_size.x = 70
	energy_container.add_child(energy_label)
	
	energy_bar = ProgressBar.new()
	energy_bar.name = "EnergyBar"
	energy_bar.custom_minimum_size = Vector2(200, 20)
	energy_bar.value = 100
	energy_container.add_child(energy_bar)
	
	# Shield bar
	var shield_container = HBoxContainer.new()
	shield_container.position = Vector2(10, 40)
	panel.add_child(shield_container)
	
	var shield_label = Label.new()
	shield_label.text = "Shields:"
	shield_label.custom_minimum_size.x = 70
	shield_container.add_child(shield_label)
	
	shield_bar = ProgressBar.new()
	shield_bar.name = "ShieldBar"
	shield_bar.custom_minimum_size = Vector2(200, 20)
	shield_bar.value = 100
	shield_container.add_child(shield_bar)
	
	# Consciousness bar
	var consciousness_container = HBoxContainer.new()
	consciousness_container.position = Vector2(10, 70)
	panel.add_child(consciousness_container)
	
	var consciousness_label = Label.new()
	consciousness_label.text = "Awareness:"
	consciousness_label.custom_minimum_size.x = 70
	consciousness_container.add_child(consciousness_label)
	
	consciousness_bar = ProgressBar.new()
	consciousness_bar.name = "ConsciousnessBar"
	consciousness_bar.custom_minimum_size = Vector2(200, 20)
	consciousness_bar.max_value = 10
	consciousness_bar.value = 1
	consciousness_container.add_child(consciousness_bar)
	
	# Info labels
	frequency_label = Label.new()
	frequency_label.name = "FrequencyLabel"
	frequency_label.text = "Frequency: 432.0 Hz"
	frequency_label.position = Vector2(10, 100)
	panel.add_child(frequency_label)
	
	velocity_label = Label.new()
	velocity_label.name = "VelocityLabel"
	velocity_label.text = "Velocity: 0 m/s"
	velocity_label.position = Vector2(10, 120)
	panel.add_child(velocity_label)
	
	position_label = Label.new()
	position_label.name = "PositionLabel"
	position_label.text = "Position: (0, 0, 0)"
	position_label.position = Vector2(10, 140)
	panel.add_child(position_label)
	
	system_label = Label.new()
	system_label.name = "SystemLabel"
	system_label.text = "System: Sol"
	system_label.position = Vector2(10, 160)
	panel.add_child(system_label)

func _create_resource_panel() -> void:
	var panel = Panel.new()
	panel.name = "ResourcePanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	panel.size = Vector2(200, 300)
	panel.position = Vector2(-220, 20)
	add_child(panel)
	
	var title = Label.new()
	title.text = "Resources"
	title.position = Vector2(10, 10)
	panel.add_child(title)
	
	resource_container = VBoxContainer.new()
	resource_container.name = "ResourceList"
	resource_container.position = Vector2(10, 40)
	panel.add_child(resource_container)

func _create_message_panel() -> void:
	var panel = Panel.new()
	panel.name = "MessagePanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	panel.size = Vector2(400, 150)
	panel.position = Vector2(20, -170)
	add_child(panel)
	
	message_container = VBoxContainer.new()
	message_container.name = "MessageContainer"
	message_container.position = Vector2(10, 10)
	message_container.size = Vector2(380, 130)
	panel.add_child(message_container)

func _create_companion_panel() -> void:
	companion_panel = Panel.new()
	companion_panel.name = "CompanionPanel"
	companion_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	companion_panel.size = Vector2(300, 200)
	companion_panel.position = Vector2(-320, -220)
	companion_panel.visible = false
	add_child(companion_panel)
	
	# Portrait placeholder
	companion_portrait = TextureRect.new()
	companion_portrait.name = "Portrait"
	companion_portrait.position = Vector2(10, 10)
	companion_portrait.size = Vector2(64, 64)
	companion_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	companion_panel.add_child(companion_portrait)
	
	companion_name = Label.new()
	companion_name.name = "CompanionName"
	companion_name.text = "Nova"
	companion_name.position = Vector2(80, 10)
	companion_panel.add_child(companion_name)
	
	companion_emotion = Label.new()
	companion_emotion.name = "EmotionLabel"
	companion_emotion.text = "Curious"
	companion_emotion.position = Vector2(80, 30)
	companion_emotion.modulate = Color(0.7, 0.7, 0.7)
	companion_panel.add_child(companion_emotion)
	
	companion_message = RichTextLabel.new()
	companion_message.name = "CompanionMessage"
	companion_message.position = Vector2(10, 80)
	companion_message.size = Vector2(280, 100)
	companion_message.text = ""
	companion_panel.add_child(companion_message)

func _create_target_panel() -> void:
	target_panel = Panel.new()
	target_panel.name = "TargetPanel"
	target_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	target_panel.size = Vector2(300, 150)
	target_panel.position = Vector2(-150, 100)
	target_panel.visible = false
	add_child(target_panel)
	
	target_name = Label.new()
	target_name.name = "TargetName"
	target_name.text = "Target: Unknown"
	target_name.position = Vector2(10, 10)
	target_panel.add_child(target_name)
	
	target_distance = Label.new()
	target_distance.name = "DistanceLabel"
	target_distance.text = "Distance: 0m"
	target_distance.position = Vector2(10, 30)
	target_panel.add_child(target_distance)
	
	var comp_label = Label.new()
	comp_label.text = "Composition:"
	comp_label.position = Vector2(10, 50)
	target_panel.add_child(comp_label)
	
	target_composition = ItemList.new()
	target_composition.name = "CompositionList"
	target_composition.position = Vector2(10, 70)
	target_composition.size = Vector2(280, 70)
	target_panel.add_child(target_composition)

func _create_minimap() -> void:
	minimap = Control.new()
	minimap.name = "Minimap"
	minimap.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	minimap.size = Vector2(200, 200)
	minimap.position = Vector2(-220, 340)
	add_child(minimap)
	
	var border = ReferenceRect.new()
	border.border_color = hud_color
	border.border_width = 2.0
	border.size = minimap.size
	minimap.add_child(border)
	
	# Minimap would need viewport setup for 3D view

func _create_consciousness_indicator() -> void:
	consciousness_indicator = Control.new()
	consciousness_indicator.name = "ConsciousnessIndicator"
	consciousness_indicator.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
	consciousness_indicator.size = Vector2(100, 100)
	consciousness_indicator.position = Vector2(20, -50)
	add_child(consciousness_indicator)
	
	# Perception ring visual
	perception_ring = TextureRect.new()
	perception_ring.name = "PerceptionRing"
	perception_ring.size = Vector2(100, 100)
	consciousness_indicator.add_child(perception_ring)
	
	# Frequency wave visualization
	frequency_wave = Line2D.new()
	frequency_wave.name = "FrequencyWave"
	frequency_wave.width = 2.0
	frequency_wave.default_color = hud_color
	consciousness_indicator.add_child(frequency_wave)

func _create_crosshair() -> void:
	crosshair = TextureRect.new()
	crosshair.name = "Crosshair"
	crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	crosshair.size = Vector2(32, 32)
	crosshair.position = Vector2(-16, -16)
	add_child(crosshair)
	
	# Create simple crosshair texture or use image
	var crosshair_image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	crosshair_image.fill(Color.TRANSPARENT)
	# Draw crosshair lines
	for i in range(14, 18):
		crosshair_image.set_pixel(i, 16, hud_color)
		crosshair_image.set_pixel(16, i, hud_color)
	
	var texture = ImageTexture.create_from_image(crosshair_image)
	crosshair.texture = texture
	
	# Mining indicator
	mining_indicator = TextureRect.new()
	mining_indicator.name = "MiningIndicator"
	mining_indicator.size = Vector2(40, 40)
	mining_indicator.position = Vector2(-4, -4)
	mining_indicator.visible = false
	crosshair.add_child(mining_indicator)

func _initialize_resource_display() -> void:
	# Create labels for common resources
	var resources = ["Energy", "Iron", "Copper", "Gold", "Consciousness Crystals"]
	for resource in resources:
		var label = Label.new()
		label.text = resource + ": 0"
		resource_container.add_child(label)
		resource_labels[resource] = label

func _setup_minimap() -> void:
	# Minimap camera follows player from above
	if minimap_camera:
		minimap_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		minimap_camera.size = 200
		minimap_camera.position = Vector3(0, 100, 0)
		minimap_camera.rotation = Vector3(-PI/2, 0, 0)

func _connect_to_systems() -> void:
	# Get system references
	await get_tree().process_frame
	
	player_ship = get_tree().get_first_node_in_group("player")
	consciousness_system = get_node_or_null("/root/SpaceGame/ConsciousnessSystem")
	stellar_system = get_node_or_null("/root/SpaceGame/StellarProgressionSystem")
	companion_system = get_node_or_null("/root/SpaceGame/AICompanionSystem")
	
	# Connect signals
	if player_ship:
		player_ship.consciousness_resonance_changed.connect(_on_frequency_changed)
		player_ship.mining_target_acquired.connect(_on_target_acquired)
		player_ship.energy_depleted.connect(_on_energy_depleted)
		player_ship.ship_damaged.connect(_on_ship_damaged)
	
	if consciousness_system:
		consciousness_system.awareness_expanded.connect(_on_awareness_expanded)
		consciousness_system.perception_unlocked.connect(_on_perception_unlocked)
	
	if stellar_system:
		stellar_system.warp_jump_initiated.connect(_on_warp_initiated)
		stellar_system.warp_jump_completed.connect(_on_warp_completed)
		stellar_system.system_discovered.connect(_on_system_discovered)
	
	if companion_system:
		companion_system.companion_message.connect(_on_companion_message)

func _apply_hud_theme() -> void:
	# Apply consistent styling
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0, 0, 0, 0.7)
	style_box.border_color = hud_color
	style_box.set_border_width_all(1)
	
	for child in get_children():
		if child is Panel:
			child.add_theme_stylebox_override("panel", style_box)

func _process(delta: float) -> void:
	if not is_visible:
		return
	
	_update_status_display()
	_update_target_info()
	_update_messages(delta)
	_update_consciousness_visualization(delta)
	_update_flash_effects(delta)

func _update_status_display() -> void:
	if not player_ship:
		return
	
	var status = player_ship.get_ship_status()
	
	# Update bars
	energy_bar.value = status["energy"]
	energy_bar.max_value = status["max_energy"]
	shield_bar.value = status["shields"]
	shield_bar.max_value = status["max_shields"]
	
	# Update text
	velocity_label.text = "Velocity: %.1f m/s" % status["velocity"]
	position_label.text = "Position: (%.0f, %.0f, %.0f)" % [status["position"].x, status["position"].y, status["position"].z]
	
	# Frequency
	frequency_label.text = "Frequency: %.1f Hz" % status["consciousness_frequency"]
	
	# Consciousness level
	if consciousness_system:
		consciousness_bar.value = consciousness_system.get_consciousness_level()
	
	# Current system
	if stellar_system and stellar_system.get_current_system():
		system_label.text = "System: " + stellar_system.get_current_system().name

func _update_target_info() -> void:
	if not current_target or not is_instance_valid(current_target):
		target_panel.visible = false
		return
	
	target_panel.visible = true
	
	# Update name
	if current_target.has_method("get_asteroid_info"):
		var info = current_target.get_asteroid_info()
		target_name.text = "Target: " + info["name"]
		
		# Update composition
		target_composition.clear()
		for ore in info["ore_types"]:
			target_composition.add_item(ore)
	else:
		target_name.text = "Target: " + current_target.name
	
	# Update distance
	if player_ship:
		var distance = player_ship.global_position.distance_to(current_target.global_position)
		target_distance.text = "Distance: %.1fm" % distance

func _update_messages(delta: float) -> void:
	# Process message queue
	for i in range(message_container.get_child_count() - 1, -1, -1):
		var label = message_container.get_child(i)
		label.modulate.a -= delta / message_lifetime
		if label.modulate.a <= 0:
			label.queue_free()
	
	# Process notifications
	for i in range(notification_container.get_child_count() - 1, -1, -1):
		var notif = notification_container.get_child(i)
		notif.modulate.a -= delta / notification_lifetime
		if notif.modulate.a <= 0:
			notif.queue_free()

func _update_consciousness_visualization(delta: float) -> void:
	if not consciousness_system:
		return
	
	# Update perception ring based on consciousness level
	var level = consciousness_system.get_consciousness_level()
	var scale = 1.0 + level * 0.1
	perception_ring.scale = Vector2(scale, scale)
	
	# Update frequency wave
	frequency_wave.clear_points()
	var freq = consciousness_system.get_consciousness_frequency()
	for i in range(50):
		var x = i * 2.0
		var y = 50 + sin(i * 0.5 + Time.get_ticks_msec() * 0.001 * freq * 0.01) * 20
		frequency_wave.add_point(Vector2(x, y))

func _update_flash_effects(delta: float) -> void:
	# Flash timers for visual feedback
	for key in flash_timers.keys():
		flash_timers[key] -= delta
		if flash_timers[key] <= 0:
			flash_timers.erase(key)
			# Reset color
			match key:
				"energy":
					energy_bar.modulate = Color.WHITE
				"shields":
					shield_bar.modulate = Color.WHITE

# Public interface
func set_energy(current: float, maximum: float) -> void:
	energy_bar.value = current
	energy_bar.max_value = maximum
	
	# Flash on low energy
	if current / maximum < 0.2:
		flash_bar(energy_bar, critical_color)

func set_shields(current: float, maximum: float) -> void:
	shield_bar.value = current
	shield_bar.max_value = maximum
	
	# Flash on low shields
	if current / maximum < 0.3:
		flash_bar(shield_bar, warning_color)

func set_consciousness_level(level: int) -> void:
	consciousness_bar.value = level

func set_frequency(freq: float) -> void:
	frequency_label.text = "Frequency: %.1f Hz" % freq

func update_resources(resources: Dictionary) -> void:
	for resource in resources:
		if resource_labels.has(resource):
			resource_labels[resource].text = resource + ": " + str(int(resources[resource]))

func add_message(text: String, color: Color = Color.WHITE) -> void:
	var label = Label.new()
	label.text = text
	label.modulate = color
	message_container.add_child(label)
	
	# Limit messages
	if message_container.get_child_count() > 5:
		message_container.get_child(0).queue_free()

func show_notification(text: String, duration: float = 3.0) -> void:
	var notif = Label.new()
	notif.text = text
	notif.modulate = hud_color
	notif.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	notif.position.y = 50
	notification_container.add_child(notif)
	
	# Fade in
	notif.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(notif, "modulate:a", 1.0, 0.3)

func flash_bar(bar: ProgressBar, color: Color) -> void:
	bar.modulate = color
	var key = bar.name.replace("Bar", "").to_lower()
	flash_timers[key] = 0.5

# Signal callbacks
func _on_frequency_changed(frequency: float) -> void:
	set_frequency(frequency)

func _on_target_acquired(target: Node3D) -> void:
	current_target = target
	add_message("Target acquired: " + target.name, hud_color)

func _on_energy_depleted() -> void:
	add_message("WARNING: Energy depleted!", critical_color)
	flash_bar(energy_bar, critical_color)

func _on_ship_damaged(amount: float) -> void:
	add_message("Hull damage: %.0f" % amount, warning_color)
	flash_bar(shield_bar, critical_color)

func _on_awareness_expanded(level: int) -> void:
	show_notification("Consciousness expanded to level " + str(level))
	consciousness_bar.value = level

func _on_perception_unlocked(perception: String) -> void:
	show_notification("New perception unlocked: " + perception)

func _on_warp_initiated(from_system: String, to_system: String) -> void:
	add_message("Initiating warp jump: " + from_system + " → " + to_system, hud_color)

func _on_warp_completed() -> void:
	add_message("Warp jump complete", hud_color)

func _on_system_discovered(system_data: Dictionary) -> void:
	show_notification("New system discovered: " + system_data["name"])

func _on_companion_message(companion: AICompanion, message: String) -> void:
	companion_panel.visible = true
	companion_name.text = companion.companion_name
	companion_message.text = message
	companion_emotion.text = companion.current_emotion.capitalize()
	
	# Auto-hide after duration
	var timer = Timer.new()
	timer.wait_time = companion_message_duration
	timer.one_shot = true
	timer.timeout.connect(func(): companion_panel.visible = false)
	add_child(timer)
	timer.start()

# Mining interface
func show_mining_indicator(active: bool) -> void:
	mining_indicator.visible = active
	if active:
		# Animate mining indicator
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(mining_indicator, "rotation", TAU, 2.0)

# Toggle HUD visibility
func toggle_hud() -> void:
	is_visible = !is_visible
	visible = is_visible

# Debug info
func show_debug_info(info: Dictionary) -> void:
	var debug_text = "=== DEBUG ===\n"
	for key in info:
		debug_text += key + ": " + str(info[key]) + "\n"
	add_message(debug_text, Color(0.5, 0.5, 0.5))
