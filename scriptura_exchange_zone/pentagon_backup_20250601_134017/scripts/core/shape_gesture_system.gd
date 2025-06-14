# 🏛️ Shape Gesture System - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: shape_gesture_system.gd  
# DESCRIPTION: Shape and gesture recognition from Eden project
# PURPOSE: Detect mouse-drawn shapes for spell casting
# BASED ON: Eden's shape detection algorithms
# ==================================================

extends UniversalBeingBase
class_name ShapeGestureSystem

signal shape_detected(shape: String, confidence: float)
signal gesture_completed(gesture: String, points: Array)
signal spell_gesture_recognized(spell: String)

## Shape detection settings
var min_points: int = 10
var max_points: int = 500
var point_threshold: float = 5.0  # Min distance between points
var shape_timeout: float = 2.0  # Max time to complete shape

## Current gesture tracking
var gesture_points: Array[Vector2] = []
var gesture_start_time: float = 0.0
var is_drawing: bool = false
var last_point: Vector2 = Vector2.ZERO

## Shape patterns (from Eden)
var shape_patterns = {
	"circle": {
		"min_points": 20,
		"closed": true,
		"smooth": true
	},
	"triangle": {
		"min_points": 15,
		"corners": 3,
		"closed": true
	},
	"square": {
		"min_points": 20,
		"corners": 4,
		"closed": true
	},
	"star": {
		"min_points": 25,
		"corners": 5,
		"intersections": true
	},
	"spiral": {
		"min_points": 30,
		"closed": false,
		"winding": true
	},
	"line": {
		"min_points": 10,
		"straight": true
	},
	"zigzag": {
		"min_points": 15,
		"alternating": true
	}
}

## Spell gestures mapping
var spell_gestures = {
	"circle": "protection_aura",
	"triangle": "focus_beam",
	"square": "solid_wall",
	"star": "cosmic_power",
	"spiral": "dimension_portal",
	"clockwise_circle": "time_accelerate",
	"counter_clockwise_circle": "time_slow",
	"double_tap": "quick_teleport",
	"hold_drag": "object_pull"
}

## Detection algorithms

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	# Pentagon setup - override in child classes
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
func start_gesture(start_pos: Vector2) -> void:
	gesture_points.clear()
	gesture_points.append(start_pos)
	gesture_start_time = Time.get_ticks_msec() / 1000.0
	is_drawing = true
	last_point = start_pos

func add_gesture_point(pos: Vector2) -> void:
	if not is_drawing:
		return
	
	# Check timeout
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - gesture_start_time > shape_timeout:
		end_gesture()
		return
	
	# Only add if far enough from last point
	if pos.distance_to(last_point) >= point_threshold:
		gesture_points.append(pos)
		last_point = pos
		
		# Limit points
		if gesture_points.size() > max_points:
			gesture_points.pop_front()

func end_gesture() -> void:
	if not is_drawing:
		return
	
	is_drawing = false
	
	if gesture_points.size() < min_points:
		return
	
	# Detect shape
	var detected_shape = _detect_shape(gesture_points)
	if detected_shape != "":
		emit_signal("shape_detected", detected_shape, 1.0)
		
		# Check for spell gesture
		if detected_shape in spell_gestures:
			var spell = spell_gestures[detected_shape]
			emit_signal("spell_gesture_recognized", spell)
	
	emit_signal("gesture_completed", detected_shape, gesture_points)

## Shape detection algorithms (from Eden)
func _detect_shape(points: Array) -> String:
	if points.size() < min_points:
		return ""
	
	# Try each shape pattern
	if _is_circle(points):
		return "circle"
	elif _is_triangle(points):
		return "triangle"
	elif _is_square(points):
		return "square"
	elif _is_star(points):
		return "star"
	elif _is_spiral(points):
		return "spiral"
	elif _is_line(points):
		return "line"
	elif _is_zigzag(points):
		return "zigzag"
	
	return "unknown"

func _is_circle(points: Array) -> bool:
	if points.size() < 20:
		return false
	
	# Calculate center
	var center = Vector2.ZERO
	for p in points:
		center += p
	center /= points.size()
	
	# Calculate average radius
	var avg_radius = 0.0
	for p in points:
		avg_radius += p.distance_to(center)
	avg_radius /= points.size()
	
	# Check if all points are roughly same distance from center
	var variance = 0.0
	for p in points:
		var dist = p.distance_to(center)
		variance += abs(dist - avg_radius)
	variance /= points.size()
	
	# Check if closed
	var closed = points[0].distance_to(points[-1]) < avg_radius * 0.3
	
	return variance < avg_radius * 0.25 and closed

func _is_triangle(points: Array) -> bool:
	# Find corners (sharp direction changes)
	var corners = _find_corners(points)
	if corners.size() != 3:
		return false
	
	# Check if closed
	var closed = points[0].distance_to(points[-1]) < _get_shape_size(points) * 0.2
	
	return closed

func _is_square(points: Array) -> bool:
	var corners = _find_corners(points)
	if corners.size() != 4:
		return false
	
	# Check for right angles
	var angles_ok = true
	for i in range(4):
		var prev = corners[(i-1) % 4]
		var curr = corners[i]
		var next = corners[(i+1) % 4]
		
		var angle = _calculate_angle(prev, curr, next)
		if abs(angle - PI/2) > PI/6:  # 30 degree tolerance
			angles_ok = false
			break
	
	return angles_ok

func _is_star(points: Array) -> bool:
	var corners = _find_corners(points)
	return corners.size() >= 8 and corners.size() <= 12  # 4-6 pointed star

func _is_spiral(points: Array) -> bool:
	if points.size() < 30:
		return false
	
	# Check for increasing distance from start
	var start = points[0]
	var increasing = true
	var last_dist = 0.0
	
	for i in range(1, points.size(), 5):  # Sample every 5th point
		var dist = points[i].distance_to(start)
		if dist < last_dist * 0.9:  # Allow some variance
			increasing = false
			break
		last_dist = dist
	
	return increasing

func _is_line(points: Array) -> bool:
	if points.size() < 10:
		return false
	
	# Calculate line from first to last point
	var start = points[0]
	var end = points[-1]
	var line_dir = (end - start).normalized()
	
	# Check if all points are close to this line
	var max_deviation = 0.0
	for p in points:
		var closest_point = start + line_dir * line_dir.dot(p - start)
		var deviation = p.distance_to(closest_point)
		max_deviation = max(max_deviation, deviation)
	
	var line_length = start.distance_to(end)
	return max_deviation < line_length * 0.1

func _is_zigzag(points: Array) -> bool:
	if points.size() < 15:
		return false
	
	# Count direction changes
	var direction_changes = 0
	var last_dir = Vector2.ZERO
	
	for i in range(1, points.size()):
		var dir = (points[i] - points[i-1]).normalized()
		if last_dir != Vector2.ZERO:
			var angle_change = last_dir.angle_to(dir)
			if abs(angle_change) > PI/3:  # 60 degrees
				direction_changes += 1
		last_dir = dir
	
	return direction_changes >= 4

## Helper functions
func _find_corners(points: Array) -> Array:
	var corners = []
	var angle_threshold = PI / 3.0  # 60 degrees
	
	for i in range(1, points.size() - 1):
		var prev = points[i-1]
		var curr = points[i]
		var next = points[i+1]
		
		var angle = _calculate_angle(prev, curr, next)
		if angle < PI - angle_threshold:  # Sharp turn
			corners.append(curr)
	
	return corners

func _calculate_angle(p1: Vector2, p2: Vector2, p3: Vector2) -> float:
	var v1 = (p1 - p2).normalized()
	var v2 = (p3 - p2).normalized()
	return acos(clamp(v1.dot(v2), -1.0, 1.0))

func _get_shape_size(points: Array) -> float:
	var min_p = points[0]
	var max_p = points[0]
	
	for p in points:
		min_p.x = min(min_p.x, p.x)
		min_p.y = min(min_p.y, p.y)
		max_p.x = max(max_p.x, p.x)
		max_p.y = max(max_p.y, p.y)
	
	return max_p.distance_to(min_p)

## Get gesture direction (for circle detection)
func get_gesture_direction(points: Array) -> String:
	if points.size() < 3:
		return "unknown"
	
	# Calculate winding using cross product
	var winding = 0.0
	for i in range(points.size()):
		var p1 = points[i]
		var p2 = points[(i + 1) % points.size()]
		winding += (p2.x - p1.x) * (p2.y + p1.y)
	
	if winding > 0:
		return "clockwise"
	else:
		return "counter_clockwise"

## Debug visualization
func get_simplified_path(points: Array, max_simplified_points: int = 50) -> Array:
	if points.size() <= max_simplified_points:
		return points
	
	# Simplify using Douglas-Peucker algorithm
	var simplified = []
	var step = float(points.size()) / float(max_simplified_points)
	
	for i in range(0, points.size(), int(step)):
		simplified.append(points[i])
	
	return simplified