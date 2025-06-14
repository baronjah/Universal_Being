# Performance Monitor UI - Shows real-time performance stats
# Displays FPS, active chunks, generation mode, and emergency status

extends Control
class_name PerformanceMonitorUI

@onready var fps_label: Label = $VBoxContainer/FPSLabel
@onready var chunks_label: Label = $VBoxContainer/ChunksLabel
@onready var mode_label: Label = $VBoxContainer/ModeLabel
@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var emergency_panel: Panel = $EmergencyPanel
@onready var emergency_label: Label = $EmergencyPanel/EmergencyLabel

var generation_coordinator: GenerationCoordinator = null
var update_timer: float = 0.0
var update_interval: float = 0.1  # Update 10 times per second

# Color coding for FPS
var color_good = Color.GREEN
var color_warning = Color.YELLOW
var color_emergency = Color.RED

func _ready():
	# Create UI structure if not in scene
	_create_ui_structure()
	
	# Find generation coordinator
	generation_coordinator = get_node_or_null("/root/Main/GenerationCoordinator")
	if generation_coordinator:
		generation_coordinator.emergency_optimization_triggered.connect(_on_emergency_triggered)
		generation_coordinator.performance_recovered.connect(_on_performance_recovered)
		generation_coordinator.generation_mode_changed.connect(_on_mode_changed)
	
	# Position in top-left corner
	position = Vector2(10, 10)
	
	print("📊 Performance Monitor UI initialized")

func _create_ui_structure():
	"""Create UI elements if not already in scene"""
	if not has_node("VBoxContainer"):
		var vbox = VBoxContainer.new()
		vbox.name = "VBoxContainer"
		add_child(vbox)
		
		# FPS Label
		fps_label = Label.new()
		fps_label.name = "FPSLabel"
		fps_label.add_theme_font_size_override("font_size", 16)
		vbox.add_child(fps_label)
		
		# Chunks Label
		chunks_label = Label.new()
		chunks_label.name = "ChunksLabel"
		chunks_label.add_theme_font_size_override("font_size", 14)
		vbox.add_child(chunks_label)
		
		# Mode Label
		mode_label = Label.new()
		mode_label.name = "ModeLabel"
		mode_label.add_theme_font_size_override("font_size", 14)
		vbox.add_child(mode_label)
		
		# Status Label
		status_label = Label.new()
		status_label.name = "StatusLabel"
		status_label.add_theme_font_size_override("font_size", 14)
		vbox.add_child(status_label)
	
	# Emergency Panel (hidden by default)
	if not has_node("EmergencyPanel"):
		emergency_panel = Panel.new()
		emergency_panel.name = "EmergencyPanel"
		emergency_panel.custom_minimum_size = Vector2(300, 100)
		emergency_panel.position = Vector2(10, 150)
		emergency_panel.visible = false
		add_child(emergency_panel)
		
		emergency_label = Label.new()
		emergency_label.name = "EmergencyLabel"
		emergency_label.add_theme_font_size_override("font_size", 18)
		emergency_label.add_theme_color_override("font_color", Color.RED)
		emergency_label.position = Vector2(10, 10)
		emergency_panel.add_child(emergency_label)

func _process(delta: float):
	update_timer += delta
	if update_timer >= update_interval:
		update_timer = 0.0
		_update_display()

func _update_display():
	"""Update all performance metrics"""
	if not generation_coordinator:
		generation_coordinator = get_node_or_null("/root/Main/GenerationCoordinator")
		if not generation_coordinator:
			return
	
	var stats = generation_coordinator.get_performance_stats()
	var current_fps = stats.get("current_fps", 0.0)
	var avg_fps = stats.get("average_fps", 0.0)
	
	# Update FPS with color coding
	fps_label.text = "FPS: %.1f (Avg: %.1f)" % [current_fps, avg_fps]
	if avg_fps >= 40:
		fps_label.add_theme_color_override("font_color", color_good)
	elif avg_fps >= 25:
		fps_label.add_theme_color_override("font_color", color_warning)
	else:
		fps_label.add_theme_color_override("font_color", color_emergency)
	
	# Update chunk count
	var chunk_count = stats.get("active_chunks", 0)
	chunks_label.text = "Active Chunks: %d" % chunk_count
	
	# Update generation mode
	var mode = stats.get("current_mode", "Unknown")
	mode_label.text = "Mode: %s" % mode
	
	# Update status
	if stats.get("emergency_mode", false):
		status_label.text = "Status: EMERGENCY OPTIMIZATION"
		status_label.add_theme_color_override("font_color", color_emergency)
	elif stats.get("generation_paused", false):
		status_label.text = "Status: Generation Paused"
		status_label.add_theme_color_override("font_color", color_warning)
	else:
		status_label.text = "Status: Normal"
		status_label.add_theme_color_override("font_color", color_good)

func _on_emergency_triggered(fps: float):
	"""Show emergency warning"""
	emergency_panel.visible = true
	emergency_label.text = "🚨 EMERGENCY OPTIMIZATION 🚨\nFPS: %.1f\nAll generation paused!" % fps

func _on_performance_recovered():
	"""Hide emergency warning"""
	emergency_panel.visible = false

func _on_mode_changed(new_mode):
	"""Flash mode change"""
	mode_label.add_theme_color_override("font_color", Color.CYAN)
	var tween = create_tween()
	tween.tween_property(mode_label, "modulate:a", 0.3, 0.2)
	tween.tween_property(mode_label, "modulate:a", 1.0, 0.2)