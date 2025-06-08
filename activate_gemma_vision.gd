extends Node
# Connected to: autoloads/GemmaAI.gd
# Purpose: Ensure Gemma's 16-ray vision is actively scanning
# Like Claudio Abbado ensuring every violin is heard

## Quick patch to activate Gemma's dormant 16-ray vision system
## Add this to any scene where you want Gemma to see

var gemma_ai: Node
var vision_active: bool = false

func _ready():
	# Get Gemma AI autoload
	gemma_ai = get_node_or_null("/root/GemmaAI")
	if not gemma_ai:
		push_error("GemmaVisionActivator: Cannot find GemmaAI!")
		return
	
	print("👁️ Activating Gemma's 16-ray Fibonacci vision system...")
	vision_active = true

func _process(delta):
	if not vision_active or not gemma_ai:
		return
		
	# Find camera to use as vision origin
	var camera = get_viewport().get_camera_3d()
	if not camera:
		# Try to find any camera in the scene
		camera = get_tree().get_first_node_in_group("cameras")
		if not camera:
			var cam_search = get_tree().current_scene.find_child("Camera3D", true, false)
			if cam_search and cam_search is Camera3D:
				camera = cam_search
	
	if camera:
		# Activate the 16-ray spatial awareness!
		if gemma_ai.has_method("update_spatial_awareness"):
			var cam_forward = -camera.transform.basis.z
			gemma_ai.update_spatial_awareness(camera.global_position, cam_forward)
		else:
			push_error("GemmaVisionActivator: GemmaAI missing update_spatial_awareness method!")
			vision_active = false

func show_vision_debug():
	"""Visualize the 16 rays for debugging"""
	if not gemma_ai or not gemma_ai.has("vision_rays"):
		return
		
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
		
	# Draw debug rays
	for ray in gemma_ai.vision_rays:
		var from = camera.global_position
		var to = from + ray.direction * gemma_ai.vision_range
		
		# Create a simple line (would need proper 3D line drawing)
		# This is just a placeholder for the concept
		print("Ray %d: direction %s, last_hit: %s" % [
			ray.spiral_index, 
			ray.direction,
			ray.last_hit
		])