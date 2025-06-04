# ==================================================
# SCRIPT NAME: GemmaVision.gd  
# DESCRIPTION: Gemma AI Vision System - Visual perception and analysis
# PURPOSE: Give Gemma the ability to "see" Universal Beings, scenes, and interfaces
# CREATED: 2025-06-04 - Gemma Vision System
# AUTHOR: JSH + Claude Code + Gemma AI
# ==================================================

extends Node
class_name GemmaVision

# ===== VISION PARAMETERS =====

@export var field_of_view: float = 120.0
@export var max_range: float = 100.0
@export var detail_level: String = "high"
@export var color_sensitivity: bool = true
@export var motion_detection: bool = true
@export var consciousness_detection: bool = true

# Vision state
var current_frame_data: Dictionary = {}
var visual_memory: Array[Dictionary] = []
var debug_visualization_enabled: bool = false

# Visual analysis data
var detected_objects: Array[Dictionary] = []
var color_analysis: Dictionary = {}
var motion_vectors: Array[Vector3] = []
var consciousness_readings: Array[Dictionary] = []

# System signals
signal visual_frame_captured(frame_data: Dictionary)
signal object_detected(object_data: Dictionary)
signal motion_detected(motion_data: Dictionary)
signal consciousness_detected(being: Node, level: int)

func _ready() -> void:
	name = "GemmaVision"
	print("👁️ GemmaVision: Visual perception system ready")

# ===== VISUAL CAPTURE =====

func capture_visual_frame() -> Dictionary:
	"""Capture current visual frame from Gemma's perspective"""
	var frame_data = {
		"timestamp": Time.get_ticks_msec(),
		"frame_id": randi(),
		"detected_objects": [],
		"color_palette": [],
		"motion_data": [],
		"consciousness_map": [],
		"spatial_layout": {},
		"visual_summary": ""
	}
	
	# Scan current scene
	_scan_visual_field(frame_data)
	
	# Analyze colors
	_analyze_scene_colors(frame_data)
	
	# Detect motion
	_detect_motion_patterns(frame_data)
	
	# Map consciousness levels
	_map_consciousness_levels(frame_data)
	
	# Generate visual summary
	frame_data.visual_summary = _generate_visual_summary(frame_data)
	
	current_frame_data = frame_data
	visual_memory.append(frame_data)
	
	# Keep only recent frames in memory
	if visual_memory.size() > 50:
		visual_memory.pop_front()
	
	visual_frame_captured.emit(frame_data)
	return frame_data

func _scan_visual_field(frame_data: Dictionary) -> void:
	"""Scan current visual field for objects"""
	var objects = []
	_recursive_visual_scan(get_tree().current_scene, objects)
	
	for obj in objects:
		var object_data = _analyze_visual_object(obj)
		frame_data.detected_objects.append(object_data)
		
		object_detected.emit(object_data)

func _recursive_visual_scan(node: Node, objects_list: Array[Dictionary]) -> void:
	"""Recursively scan scene tree for visible objects"""
	# Check if object is visually relevant
	if _is_visually_relevant(node):
		objects_list.append(_create_object_reference(node))
	
	# Scan children
	for child in node.get_children():
		_recursive_visual_scan(child, objects_list)

func _is_visually_relevant(node: Node) -> bool:
	"""Check if node is visually relevant to Gemma"""
	# 3D objects are visually relevant
	if node is Node3D:
		return true
	
	# UI elements are visually relevant
	if node is Control or node is CanvasItem:
		return true
	
	# Universal Beings are always relevant
	if node.has_method("pentagon_init"):
		return true
	
	# Objects with visual components
	if node.has_method("get_visual_data"):
		return true
	
	return false

func _create_object_reference(node: Node) -> Dictionary:
	"""Create object reference for visual analysis"""
	return {
		"node": node,
		"name": node.name,
		"type": node.get_class(),
		"is_universal_being": node.has_method("pentagon_init")
	}

func _analyze_visual_object(object_ref: Dictionary) -> Dictionary:
	"""Analyze visual properties of an object"""
	var node = object_ref.node as Node
	var analysis = {
		"name": object_ref.name,
		"type": object_ref.type,
		"is_universal_being": object_ref.is_universal_being,
		"position": Vector3.ZERO,
		"scale": Vector3.ONE,
		"rotation": Vector3.ZERO,
		"visible": true,
		"color_data": {},
		"shape_description": "",
		"consciousness_indicators": {},
		"visual_effects": [],
		"gemma_description": ""
	}
	
	# Get spatial data
	if node is Node3D:
		analysis.position = node.global_position
		analysis.scale = node.scale
		analysis.rotation = node.rotation
		analysis.visible = node.visible
	
	# Analyze consciousness if it's a Universal Being
	if object_ref.is_universal_being:
		analysis.consciousness_indicators = _analyze_consciousness_visual(node)
	
	# Get color information
	analysis.color_data = _extract_color_data(node)
	
	# Generate shape description
	analysis.shape_description = _describe_object_shape(node)
	
	# Generate Gemma's visual description
	analysis.gemma_description = _generate_object_description(analysis)
	
	return analysis

# ===== COLOR ANALYSIS =====

func _analyze_scene_colors(frame_data: Dictionary) -> void:
	"""Analyze color composition of the scene"""
	var color_palette = []
	var color_frequencies = {}
	
	for object_data in frame_data.detected_objects:
		var colors = object_data.color_data
		for color_name in colors:
			var color = colors[color_name]
			if color is Color:
				var color_key = _color_to_key(color)
				color_frequencies[color_key] = color_frequencies.get(color_key, 0) + 1
				
				if color_key not in color_palette:
					color_palette.append({
						"color": color,
						"name": color_name,
						"frequency": 1
					})
	
	frame_data.color_palette = color_palette

func _extract_color_data(node: Node) -> Dictionary:
	"""Extract color information from a node"""
	var colors = {}
	
	# Check for consciousness color
	if node.has_method("get_consciousness_color"):
		colors["consciousness"] = node.get_consciousness_color()
	
	# Check material colors
	if node is MeshInstance3D:
		var material = node.material_override
		if material and material is StandardMaterial3D:
			colors["material"] = material.albedo_color
	
	# Check modulate color
	if node.has_method("get") and node.has_property("modulate"):
		colors["modulate"] = node.get("modulate")
	
	return colors

func _color_to_key(color: Color) -> String:
	"""Convert color to string key for tracking"""
	return "%.2f_%.2f_%.2f" % [color.r, color.g, color.b]

# ===== MOTION DETECTION =====

func _detect_motion_patterns(frame_data: Dictionary) -> void:
	"""Detect motion patterns in the scene"""
	var motion_data = []
	
	# Compare with previous frame if available
	if visual_memory.size() > 0:
		var previous_frame = visual_memory[-1]
		motion_data = _compare_frames_for_motion(previous_frame, frame_data)
	
	frame_data.motion_data = motion_data
	
	# Emit motion events
	for motion in motion_data:
		motion_detected.emit(motion)

func _compare_frames_for_motion(previous: Dictionary, current: Dictionary) -> Array[Dictionary]:
	"""Compare two frames to detect motion"""
	var motions = []
	
	# Compare object positions
	for current_obj in current.detected_objects:
		for previous_obj in previous.detected_objects:
			if current_obj.name == previous_obj.name:
				var distance = current_obj.position.distance_to(previous_obj.position)
				if distance > 0.1:  # Minimum movement threshold
					motions.append({
						"object": current_obj.name,
						"from": previous_obj.position,
						"to": current_obj.position,
						"distance": distance,
						"velocity": distance / 0.5  # Based on perception cycle time
					})
				break
	
	return motions

# ===== CONSCIOUSNESS DETECTION =====

func _map_consciousness_levels(frame_data: Dictionary) -> void:
	"""Map consciousness levels of detected Universal Beings"""
	var consciousness_map = []
	
	for object_data in frame_data.detected_objects:
		if object_data.is_universal_being and object_data.consciousness_indicators.size() > 0:
			consciousness_map.append(object_data.consciousness_indicators)
			
			# Emit consciousness detection
			var level = object_data.consciousness_indicators.get("level", 0)
			if level > 0:
				consciousness_detected.emit(object_data.node, level)
	
	frame_data.consciousness_map = consciousness_map

func _analyze_consciousness_visual(node: Node) -> Dictionary:
	"""Analyze visual indicators of consciousness"""
	var indicators = {}
	
	if node.has_method("get") and node.has_property("consciousness_level"):
		indicators["level"] = node.get("consciousness_level")
		indicators["color"] = node.get_consciousness_color() if node.has_method("get_consciousness_color") else Color.GRAY
		indicators["description"] = _describe_consciousness_level(indicators.level)
	
	return indicators

func _describe_consciousness_level(level: int) -> String:
	"""Describe consciousness level visually"""
	match level:
		0: return "dormant gray emanation"
		1: return "pale awakening glow"
		2: return "blue aware radiance" 
		3: return "green connected energy"
		4: return "golden enlightened aura"
		5: return "transcendent white brilliance"
		_: return "unknown consciousness state"

# ===== VISUAL DESCRIPTION =====

func _describe_object_shape(node: Node) -> String:
	"""Describe the visual shape of an object"""
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			var mesh_type = mesh.get_class()
			match mesh_type:
				"BoxMesh": return "cubic form"
				"SphereMesh": return "spherical shape"
				"CylinderMesh": return "cylindrical structure"
				"PlaneMesh": return "flat plane"
				_: return "complex geometric form"
	
	if node is Node3D:
		return "3D spatial entity"
	
	if node is Control:
		return "interface element"
	
	return "abstract form"

func _generate_object_description(analysis: Dictionary) -> String:
	"""Generate Gemma's description of an object"""
	var desc = "I see %s" % analysis.name
	
	if analysis.is_universal_being:
		desc += ", a Universal Being"
		if analysis.consciousness_indicators.has("level"):
			desc += " with %s" % analysis.consciousness_indicators.description
	else:
		desc += ", %s" % analysis.shape_description
	
	if analysis.position != Vector3.ZERO:
		desc += " positioned at %s" % analysis.position
	
	if analysis.color_data.size() > 0:
		var primary_color = analysis.color_data.values()[0]
		if primary_color is Color:
			desc += " displaying %s tones" % _describe_color(primary_color)
	
	return desc

func _describe_color(color: Color) -> String:
	"""Describe a color in natural language"""
	if color.r > 0.8 and color.g > 0.8 and color.b > 0.8:
		return "bright white"
	elif color.r < 0.2 and color.g < 0.2 and color.b < 0.2:
		return "deep black"
	elif color.r > color.g and color.r > color.b:
		return "warm red"
	elif color.g > color.r and color.g > color.b:
		return "vibrant green"
	elif color.b > color.r and color.b > color.g:
		return "cool blue"
	elif color.r > 0.8 and color.g > 0.6:
		return "golden yellow"
	else:
		return "mixed"

func _generate_visual_summary(frame_data: Dictionary) -> String:
	"""Generate overall visual summary of the frame"""
	var summary = []
	
	summary.append("Visual frame contains %d objects" % frame_data.detected_objects.size())
	
	# Count Universal Beings
	var beings_count = 0
	for obj in frame_data.detected_objects:
		if obj.is_universal_being:
			beings_count += 1
	
	if beings_count > 0:
		summary.append("%d Universal Beings detected" % beings_count)
	
	# Motion summary
	if frame_data.motion_data.size() > 0:
		summary.append("%d objects in motion" % frame_data.motion_data.size())
	
	# Color summary
	if frame_data.color_palette.size() > 0:
		summary.append("Color palette includes %d distinct colors" % frame_data.color_palette.size())
	
	return ". ".join(summary) + "."

# ===== DEBUG VISUALIZATION =====

func enable_debug_visualization() -> void:
	"""Enable visual debugging of Gemma's vision"""
	debug_visualization_enabled = true
	print("👁️ GemmaVision: Debug visualization enabled")

func disable_debug_visualization() -> void:
	"""Disable visual debugging"""
	debug_visualization_enabled = false
	print("👁️ GemmaVision: Debug visualization disabled")

# ===== PUBLIC API =====

func get_current_visual_data() -> Dictionary:
	"""Get current visual frame data"""
	return current_frame_data

func get_visual_history(frames: int = 10) -> Array[Dictionary]:
	"""Get recent visual history"""
	var start_index = max(0, visual_memory.size() - frames)
	return visual_memory.slice(start_index)

func focus_on_object(object_name: String) -> Dictionary:
	"""Focus Gemma's vision on a specific object"""
	for obj_data in current_frame_data.get("detected_objects", []):
		if obj_data.name == object_name:
			return obj_data
	return {}

func search_for_consciousness_level(target_level: int) -> Array[Dictionary]:
	"""Search for beings with specific consciousness level"""
	var matches = []
	for obj_data in current_frame_data.get("detected_objects", []):
		if obj_data.consciousness_indicators.get("level", -1) == target_level:
			matches.append(obj_data)
	return matches