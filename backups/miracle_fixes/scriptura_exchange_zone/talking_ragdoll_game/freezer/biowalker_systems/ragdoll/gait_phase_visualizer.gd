# 🏛️ Gait Phase Visualizer - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
class_name GaitPhaseVisualizer
# Visualizes gait phases and foot contacts in the debug layer

@export var walker: BiomechanicalWalker
@export var show_phase_labels: bool = true
@export var show_contact_points: bool = true
@export var show_force_vectors: bool = true
@export var show_gait_timeline: bool = true

var layer_system: Node
var debug_labels: Dictionary = {}
var contact_markers: Dictionary = {}

# Phase colors
var phase_colors = {
	BiomechanicalWalker.GaitPhase.HEEL_STRIKE: Color.RED,
	BiomechanicalWalker.GaitPhase.FOOT_FLAT: Color.ORANGE,
	BiomechanicalWalker.GaitPhase.MIDSTANCE: Color.GREEN,
	BiomechanicalWalker.GaitPhase.HEEL_OFF: Color.YELLOW,
	BiomechanicalWalker.GaitPhase.TOE_OFF: Color.CYAN,
	BiomechanicalWalker.GaitPhase.INITIAL_SWING: Color.BLUE,
	BiomechanicalWalker.GaitPhase.MID_SWING: Color.INDIGO,
	BiomechanicalWalker.GaitPhase.TERMINAL_SWING: Color.VIOLET
}

# UI elements for gait timeline
var timeline_canvas: CanvasLayer
var left_timeline: ProgressBar
var right_timeline: ProgressBar

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	layer_system = get_node_or_null("/root/LayerRealitySystem")
	
	if walker:
		walker.phase_changed.connect(_on_phase_changed)
		walker.step_completed.connect(_on_step_completed)
	
	_setup_timeline_ui()
	_create_debug_labels()

func _setup_timeline_ui() -> void:
	if not show_gait_timeline:
		return
		
	timeline_canvas = CanvasLayer.new()
	timeline_canvas.name = "GaitTimeline"
	add_child(timeline_canvas)
	
	var container = VBoxContainer.new()
	container.position = Vector2(10, 10)
	FloodgateController.universal_add_child(container, timeline_canvas)
	
	# Left leg timeline
	var left_label = Label.new()
	left_label.text = "Left Leg Gait Cycle"
	FloodgateController.universal_add_child(left_label, container)
	
	left_timeline = ProgressBar.new()
	left_timeline.custom_minimum_size = Vector2(300, 20)
	left_timeline.max_value = 1.0
	FloodgateController.universal_add_child(left_timeline, container)
	
	# Right leg timeline
	var right_label = Label.new()
	right_label.text = "Right Leg Gait Cycle"
	FloodgateController.universal_add_child(right_label, container)
	
	right_timeline = ProgressBar.new()
	right_timeline.custom_minimum_size = Vector2(300, 20)
	right_timeline.max_value = 1.0
	right_timeline.value = 0.5  # Offset by half cycle
	FloodgateController.universal_add_child(right_timeline, container)

func _create_debug_labels() -> void:
	if not show_phase_labels or not walker:
		return
	
	# Create 3D labels for each foot
	for side in ["left", "right"]:
		var label_3d = Label3D.new()
		label_3d.name = side + "_phase_label"
		label_3d.text = "STANCE"
		label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label_3d.no_depth_test = true
		label_3d.modulate = Color.WHITE
		add_child(label_3d)
		debug_labels[side] = label_3d


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	if not walker:
		return
	
	# Update debug visualization
	if layer_system and layer_system.is_layer_visible(layer_system.Layer.DEBUG_3D):
		_update_phase_labels()
		_update_contact_visualization()
		_update_force_vectors()
		_update_timeline()

func _update_phase_labels() -> void:
	if not show_phase_labels:
		return
	
	# Update left foot label
	if "left" in debug_labels:
		var left_pos = walker.left_leg.foot.global_position + Vector3(0, 0.3, 0)
		debug_labels["left"].global_position = left_pos
		debug_labels["left"].text = walker.get_current_phase("left")
		debug_labels["left"].modulate = phase_colors.get(walker.left_leg.phase, Color.WHITE)
	
	# Update right foot label
	if "right" in debug_labels:
		var right_pos = walker.right_leg.foot.global_position + Vector3(0, 0.3, 0)
		debug_labels["right"].global_position = right_pos
		debug_labels["right"].text = walker.get_current_phase("right")
		debug_labels["right"].modulate = phase_colors.get(walker.right_leg.phase, Color.WHITE)

func _update_contact_visualization() -> void:
	if not show_contact_points or not layer_system:
		return
	
	# Clear previous contact markers
	layer_system.clear_debug_draw()
	
	# Draw contact points for each foot part
	for leg in [walker.left_leg, walker.right_leg]:
		# Heel contact
		if walker.is_foot_on_ground(leg.side):
			var heel_color = Color.GREEN if leg.heel.name in walker.ground_contacts else Color.RED
			layer_system.add_debug_point(leg.heel.global_position, heel_color, 0.05)
			
			# Main foot contact
			var foot_color = Color.GREEN if leg.foot.name in walker.ground_contacts else Color.RED
			layer_system.add_debug_point(leg.foot.global_position, foot_color, 0.05)
			
			# Toe contact
			var toe_color = Color.GREEN if leg.toes.name in walker.ground_contacts else Color.RED
			layer_system.add_debug_point(leg.toes.global_position, toe_color, 0.05)
			
			# Draw ground contact line
			if leg.is_stance:
				var ground_y = 0.0  # Assuming ground at y=0
				var contact_start = Vector3(leg.heel.global_position.x, ground_y, leg.heel.global_position.z)
				var contact_end = Vector3(leg.toes.global_position.x, ground_y, leg.toes.global_position.z)
				layer_system.add_debug_line(contact_start, contact_end, Color.GREEN)

func _update_force_vectors() -> void:
	if not show_force_vectors or not layer_system:
		return
	
	# Show force application points based on gait phase
	for leg in [walker.left_leg, walker.right_leg]:
		var force_origin = Vector3.ZERO
		var force_direction = Vector3.ZERO
		var force_color = Color.CYAN
		
		match leg.phase:
			BiomechanicalWalker.GaitPhase.HEEL_STRIKE:
				force_origin = leg.heel.global_position
				force_direction = Vector3(0, -1, 0)  # Impact force
				force_color = Color.RED
				
			BiomechanicalWalker.GaitPhase.MIDSTANCE:
				force_origin = leg.foot.global_position
				force_direction = Vector3(0, 1, 0)  # Support force
				force_color = Color.GREEN
				
			BiomechanicalWalker.GaitPhase.TOE_OFF:
				force_origin = leg.toes.global_position
				force_direction = Vector3(0, 0.5, -1).normalized()  # Push-off force
				force_color = Color.YELLOW
				
			BiomechanicalWalker.GaitPhase.MID_SWING:
				force_origin = leg.shin.global_position
				force_direction = Vector3(0, 0, -1)  # Forward swing
				force_color = Color.BLUE
		
		if force_direction.length() > 0:
			layer_system.add_debug_line(
				force_origin,
				force_origin + force_direction * 0.5,
				force_color
			)

func _update_timeline() -> void:
	if not show_gait_timeline:
		return
	
	# Calculate cycle progress (0.0 to 1.0)
	var left_progress = _calculate_cycle_progress(walker.left_leg)
	var right_progress = _calculate_cycle_progress(walker.right_leg)
	
	if left_timeline:
		left_timeline.value = left_progress
		# Color based on stance/swing
		var style = StyleBoxFlat.new()
		style.bg_color = Color.GREEN if walker.left_leg.is_stance else Color.BLUE
		left_timeline.add_theme_stylebox_override("fill", style)
	
	if right_timeline:
		right_timeline.value = right_progress
		var style = StyleBoxFlat.new()
		style.bg_color = Color.GREEN if walker.right_leg.is_stance else Color.BLUE
		right_timeline.add_theme_stylebox_override("fill", style)

func _calculate_cycle_progress(leg: BiomechanicalWalker.Leg) -> float:
	# Map phase to cycle progress
	var phase_progress = {
		BiomechanicalWalker.GaitPhase.HEEL_STRIKE: 0.0,
		BiomechanicalWalker.GaitPhase.FOOT_FLAT: 0.12,
		BiomechanicalWalker.GaitPhase.MIDSTANCE: 0.25,
		BiomechanicalWalker.GaitPhase.HEEL_OFF: 0.40,
		BiomechanicalWalker.GaitPhase.TOE_OFF: 0.55,
		BiomechanicalWalker.GaitPhase.INITIAL_SWING: 0.60,
		BiomechanicalWalker.GaitPhase.MID_SWING: 0.75,
		BiomechanicalWalker.GaitPhase.TERMINAL_SWING: 0.90
	}
	
	var base_progress = phase_progress.get(leg.phase, 0.0)
	var phase_duration = walker.stance_duration / 5.0 if leg.is_stance else walker.swing_duration / 3.0
	var phase_interpolation = leg.phase_timer / phase_duration
	
	# Add interpolation within current phase
	var next_phase_value = 1.0 if leg.phase == BiomechanicalWalker.GaitPhase.TERMINAL_SWING else base_progress + 0.15
	return lerp(base_progress, next_phase_value, phase_interpolation)

func _on_phase_changed(leg_side: String, phase_name: String) -> void:
	print("Gait Phase Changed: %s leg -> %s" % [leg_side, phase_name])

func _on_step_completed(foot: String) -> void:
	print("Step completed: %s foot" % foot)
	
	# Could trigger footstep sounds here
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_footstep(foot)

# Console integration

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

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
func handle_console_command(command: String, args: Array) -> String:
	match command:
		"gait_debug":
			if args.size() > 0:
				match args[0]:
					"labels":
						show_phase_labels = !show_phase_labels
						return "Phase labels: " + str(show_phase_labels)
					"contacts":
						show_contact_points = !show_contact_points
						return "Contact points: " + str(show_contact_points)
					"forces":
						show_force_vectors = !show_force_vectors
						return "Force vectors: " + str(show_force_vectors)
					"timeline":
						show_gait_timeline = !show_gait_timeline
						timeline_canvas.visible = show_gait_timeline
						return "Gait timeline: " + str(show_gait_timeline)
					"all":
						var state = args.size() > 1 and args[1] == "on"
						show_phase_labels = state
						show_contact_points = state
						show_force_vectors = state
						show_gait_timeline = state
						return "All gait debug: " + str(state)
			return "Usage: gait_debug [labels|contacts|forces|timeline|all] [on|off]"
	
	return "Unknown gait debug command"