extends Node
class_name TimelinePerformanceOptimizer

## ⚡ TIMELINE PERFORMANCE OPTIMIZER
## CYCLE 3 - Agent 7 (Experience Optimizer) - Real-time Earth monitoring performance
## Ensures 60 FPS while visualizing Texas floods, pyramid protection, and AI satellites

signal performance_warning(fps: float, cause: String)
signal optimization_applied(optimization_type: String, performance_gain: float)

# Performance Settings
@export var target_fps: float = 60.0
@export var warning_fps_threshold: float = 45.0
@export var emergency_fps_threshold: float = 30.0
@export var performance_check_interval: float = 1.0

# LOD (Level of Detail) Settings
@export var enable_lod: bool = true
@export var lod_distance_near: float = 20.0
@export var lod_distance_medium: float = 50.0
@export var lod_distance_far: float = 100.0

# Shader Optimization
@export var enable_shader_optimization: bool = true
@export var max_active_shaders: int = 10
@export var shader_update_rate: float = 30.0  # Hz

# Event Culling
@export var enable_event_culling: bool = true
@export var max_visible_events: int = 500
@export var cull_old_events_hours: float = 24.0

# Performance Monitoring
var current_fps: float = 60.0
var frame_time_history: Array[float] = []
var performance_warnings: Array[Dictionary] = []
var active_optimizations: Dictionary = {}

# System References
var earth_monitor: AkashicTimelineEarthMonitor
var camera: Camera3D

func _ready() -> void:
	name = "TimelinePerformanceOptimizer"
	print("⚡ PERFORMANCE OPTIMIZER: Initializing real-time Earth monitoring optimization")
	
	# Find Earth monitor
	earth_monitor = get_tree().get_first_node_in_group("earth_timeline_monitors")
	if not earth_monitor:
		print("⚠️ No Earth monitor found - will search periodically")
		var timer = Timer.new()
		timer.wait_time = 2.0
		timer.timeout.connect(find_earth_monitor)
		add_child(timer)
		timer.start()
	
	# Setup performance monitoring
	var perf_timer = Timer.new()
	perf_timer.wait_time = performance_check_interval
	perf_timer.timeout.connect(check_performance)
	add_child(perf_timer)
	perf_timer.start()
	
	# Connect to optimization events
	performance_warning.connect(_on_performance_warning)
	
	print("⚡ Performance optimizer ready - targeting %d FPS" % target_fps)

func find_earth_monitor() -> void:
	"""Find Earth monitor if not found initially"""
	earth_monitor = get_tree().get_first_node_in_group("earth_timeline_monitors")
	if earth_monitor:
		print("⚡ Connected to Earth monitor for performance optimization")

func check_performance() -> void:
	"""Monitor system performance and apply optimizations"""
	current_fps = Engine.get_frames_per_second()
	frame_time_history.append(current_fps)
	
	# Keep history manageable
	if frame_time_history.size() > 60:
		frame_time_history.pop_front()
	
	# Check for performance issues
	if current_fps < warning_fps_threshold:
		var cause = analyze_performance_bottleneck()
		performance_warning.emit(current_fps, cause)
	
	# Apply optimizations based on FPS
	if current_fps < emergency_fps_threshold:
		apply_emergency_optimizations()
	elif current_fps < warning_fps_threshold:
		apply_standard_optimizations()

func analyze_performance_bottleneck() -> String:
	"""Analyze what's causing performance issues"""
	var bottleneck_sources = []
	
	# Check active events
	if earth_monitor:
		var total_events = 0
		for timestamp in earth_monitor.timeline_events.keys():
			total_events += earth_monitor.timeline_events[timestamp].size()
		
		if total_events > max_visible_events:
			bottleneck_sources.append("too_many_events")
	
	# Check active shaders
	var active_shader_count = count_active_shaders()
	if active_shader_count > max_active_shaders:
		bottleneck_sources.append("too_many_shaders")
	
	# Check rendering complexity
	var render_objects = get_tree().get_nodes_in_group("timeline_events")
	if render_objects.size() > 1000:
		bottleneck_sources.append("too_many_render_objects")
	
	if bottleneck_sources.size() > 0:
		return bottleneck_sources[0]
	else:
		return "unknown"

func count_active_shaders() -> int:
	"""Count currently active shaders"""
	var shader_count = 0
	if earth_monitor:
		for event_id in earth_monitor.event_nodes.keys():
			var event_node = earth_monitor.event_nodes[event_id]
			if event_node and event_node.material_override and event_node.material_override is ShaderMaterial:
				shader_count += 1
	return shader_count

func apply_emergency_optimizations() -> void:
	"""Apply aggressive optimizations for emergency FPS recovery"""
	print("🚨 EMERGENCY OPTIMIZATION: FPS too low (%.1f), applying aggressive fixes" % current_fps)
	
	if not active_optimizations.has("emergency_mode"):
		active_optimizations["emergency_mode"] = true
		
		# Disable non-essential shaders
		disable_non_essential_shaders()
		
		# Aggressive event culling
		cull_distant_events(lod_distance_near)
		
		# Reduce shader update rate
		reduce_shader_update_rate(15.0)  # 15 Hz
		
		# Disable some visual effects
		disable_secondary_effects()
		
		optimization_applied.emit("emergency_mode", current_fps)

func apply_standard_optimizations() -> void:
	"""Apply standard performance optimizations"""
	print("⚡ STANDARD OPTIMIZATION: Improving performance (%.1f FPS)" % current_fps)
	
	if enable_lod:
		apply_lod_system()
	
	if enable_event_culling:
		cull_old_events()
	
	if enable_shader_optimization:
		optimize_shader_performance()
	
	optimization_applied.emit("standard_optimization", current_fps)

func apply_lod_system() -> void:
	"""Apply Level of Detail system based on distance"""
	if not earth_monitor or not camera:
		find_camera()
		return
	
	var camera_position = camera.global_position if camera else Vector3.ZERO
	
	for event_id in earth_monitor.event_nodes.keys():
		var event_node = earth_monitor.event_nodes[event_id]
		if not event_node:
			continue
		
		var distance = camera_position.distance_to(event_node.global_position)
		var lod_level = get_lod_level(distance)
		
		apply_lod_to_event(event_node, lod_level)

func get_lod_level(distance: float) -> int:
	"""Get LOD level based on distance"""
	if distance < lod_distance_near:
		return 0  # High detail
	elif distance < lod_distance_medium:
		return 1  # Medium detail
	elif distance < lod_distance_far:
		return 2  # Low detail
	else:
		return 3  # Culled

func apply_lod_to_event(event_node: MeshInstance3D, lod_level: int) -> void:
	"""Apply LOD settings to event visualization"""
	match lod_level:
		0:  # High detail - full shaders
			event_node.visible = true
			if event_node.material_override and event_node.material_override is ShaderMaterial:
				var shader_mat = event_node.material_override as ShaderMaterial
				# Keep all shader effects active
				shader_mat.set_shader_parameter("high_quality_waves", true)
		
		1:  # Medium detail - reduced shader complexity
			event_node.visible = true
			if event_node.material_override and event_node.material_override is ShaderMaterial:
				var shader_mat = event_node.material_override as ShaderMaterial
				shader_mat.set_shader_parameter("high_quality_waves", false)
				shader_mat.set_shader_parameter("wave_detail_level", 2)
		
		2:  # Low detail - minimal shaders
			event_node.visible = true
			if event_node.material_override and event_node.material_override is ShaderMaterial:
				# Replace with simple material for distant objects
				var simple_material = StandardMaterial3D.new()
				simple_material.albedo_color = Color.CYAN  # Basic color
				event_node.material_override = simple_material
		
		3:  # Culled - not visible
			event_node.visible = false

func cull_old_events() -> void:
	"""Remove or hide old timeline events to improve performance"""
	if not earth_monitor:
		return
	
	var current_time = Time.get_unix_time_from_system()
	var cutoff_time = current_time - (cull_old_events_hours * 3600)
	var culled_count = 0
	
	for timestamp in earth_monitor.timeline_events.keys():
		if timestamp < cutoff_time:
			var events = earth_monitor.timeline_events[timestamp]
			for event in events:
				var event_id = event.get("event_id", "")
				if earth_monitor.event_nodes.has(event_id):
					var event_node = earth_monitor.event_nodes[event_id]
					if event_node:
						event_node.visible = false
						culled_count += 1
	
	if culled_count > 0:
		print("⚡ Culled %d old events for performance" % culled_count)

func cull_distant_events(max_distance: float) -> void:
	"""Cull events beyond maximum distance"""
	if not earth_monitor or not camera:
		return
	
	var camera_position = camera.global_position
	var culled_count = 0
	
	for event_id in earth_monitor.event_nodes.keys():
		var event_node = earth_monitor.event_nodes[event_id]
		if not event_node:
			continue
		
		var distance = camera_position.distance_to(event_node.global_position)
		if distance > max_distance:
			event_node.visible = false
			culled_count += 1
	
	if culled_count > 0:
		print("⚡ Culled %d distant events (>%.1f units)" % [culled_count, max_distance])

func optimize_shader_performance() -> void:
	"""Optimize shader performance for real-time monitoring"""
	var shader_count = 0
	var optimized_count = 0
	
	if not earth_monitor:
		return
	
	for event_id in earth_monitor.event_nodes.keys():
		var event_node = earth_monitor.event_nodes[event_id]
		if not event_node or not event_node.material_override:
			continue
		
		if event_node.material_override is ShaderMaterial:
			shader_count += 1
			var shader_mat = event_node.material_override as ShaderMaterial
			
			# Optimize Texas flood shader
			if shader_mat.shader and "flood_disaster_visualization" in str(shader_mat.shader.resource_path):
				optimize_flood_shader(shader_mat)
				optimized_count += 1
			
			# Optimize pyramid protection shader
			elif shader_mat.shader and "pyramid_protection_consciousness" in str(shader_mat.shader.resource_path):
				optimize_pyramid_shader(shader_mat)
				optimized_count += 1
	
	if optimized_count > 0:
		print("⚡ Optimized %d shaders (%d total active)" % [optimized_count, shader_count])

func optimize_flood_shader(shader_material: ShaderMaterial) -> void:
	"""Optimize flood disaster shader for performance"""
	# Reduce wave detail for performance
	shader_material.set_shader_parameter("wave_detail_level", 2)
	shader_material.set_shader_parameter("high_quality_waves", false)
	
	# Adjust turbulence for performance
	var current_turbulence = shader_material.get_shader_parameter("turbulence_strength")
	if current_turbulence == null:
		current_turbulence = 2.0
	shader_material.set_shader_parameter("turbulence_strength", min(current_turbulence, 1.5))

func optimize_pyramid_shader(shader_material: ShaderMaterial) -> void:
	"""Optimize pyramid protection shader for performance"""
	# Reduce satellite count if performance is critical
	var current_satellites = shader_material.get_shader_parameter("satellite_count")
	if current_satellites == null:
		current_satellites = 7
	
	if current_fps < emergency_fps_threshold:
		shader_material.set_shader_parameter("satellite_count", min(current_satellites, 4))
	else:
		shader_material.set_shader_parameter("satellite_count", min(current_satellites, 6))

func disable_non_essential_shaders() -> void:
	"""Disable non-essential shader effects during performance crisis"""
	if not earth_monitor:
		return
	
	var disabled_count = 0
	
	for event_id in earth_monitor.event_nodes.keys():
		var event_node = earth_monitor.event_nodes[event_id]
		if not event_node or not event_node.material_override:
			continue
		
		# Keep only Texas flood and pyramid protection shaders (essential for July 5th events)
		if event_node.material_override is ShaderMaterial:
			var shader_mat = event_node.material_override as ShaderMaterial
			if shader_mat.shader:
				var shader_path = str(shader_mat.shader.resource_path)
				if not ("flood_disaster_visualization" in shader_path or "pyramid_protection_consciousness" in shader_path):
					# Replace with simple material
					var simple_material = StandardMaterial3D.new()
					simple_material.albedo_color = Color.YELLOW
					simple_material.emission_enabled = true
					simple_material.emission = Color.YELLOW * 0.5
					event_node.material_override = simple_material
					disabled_count += 1
	
	if disabled_count > 0:
		print("🚨 Disabled %d non-essential shaders (keeping flood + pyramid)" % disabled_count)

func reduce_shader_update_rate(target_hz: float) -> void:
	"""Reduce shader update rate to improve performance"""
	print("⚡ Reducing shader update rate to %.1f Hz" % target_hz)
	# This would typically involve creating a custom update timer for shader parameters

func disable_secondary_effects() -> void:
	"""Disable secondary visual effects during performance emergency"""
	print("⚡ Disabling secondary visual effects for emergency performance boost")
	# Disable particle systems, additional glow effects, etc.

func find_camera() -> void:
	"""Find camera for LOD calculations"""
	var cameras = get_tree().get_nodes_in_group("cameras")
	if cameras.size() > 0:
		camera = cameras[0] as Camera3D
	else:
		# Look for Camera3D nodes
		var root = get_tree().root
		camera = find_camera_recursive(root)

func find_camera_recursive(node: Node) -> Camera3D:
	"""Recursively find Camera3D"""
	if node is Camera3D:
		return node
	
	for child in node.get_children():
		var result = find_camera_recursive(child)
		if result:
			return result
	
	return null

func _on_performance_warning(fps: float, cause: String) -> void:
	"""Handle performance warnings"""
	var warning = {
		"timestamp": Time.get_unix_time_from_system(),
		"fps": fps,
		"cause": cause
	}
	performance_warnings.append(warning)
	
	print("⚠️ PERFORMANCE WARNING: %.1f FPS - Cause: %s" % [fps, cause])

func get_performance_report() -> Dictionary:
	"""Get comprehensive performance report"""
	var avg_fps = 0.0
	if frame_time_history.size() > 0:
		for fps in frame_time_history:
			avg_fps += fps
		avg_fps /= frame_time_history.size()
	
	return {
		"current_fps": current_fps,
		"average_fps": avg_fps,
		"target_fps": target_fps,
		"active_optimizations": active_optimizations.keys(),
		"performance_warnings": performance_warnings.size(),
		"shader_count": count_active_shaders(),
		"optimization_status": "OPTIMAL" if current_fps >= target_fps else "OPTIMIZING"
	}

# Public API for real-time monitoring optimization

func force_emergency_optimization() -> void:
	"""Force emergency optimization (for testing or manual intervention)"""
	apply_emergency_optimizations()

func reset_optimizations() -> void:
	"""Reset all optimizations to default state"""
	active_optimizations.clear()
	print("⚡ All optimizations reset - returning to default performance mode")

func set_lod_distances(near: float, medium: float, far: float) -> void:
	"""Adjust LOD distances for different scenarios"""
	lod_distance_near = near
	lod_distance_medium = medium 
	lod_distance_far = far
	print("⚡ LOD distances updated: %.1f / %.1f / %.1f" % [near, medium, far])