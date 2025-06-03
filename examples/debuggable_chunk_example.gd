# Debuggable Chunk Example - Shows how to implement Luminus's Debuggable interface
# This is how ChunkUniversalBeing should implement clean debug interface

extends ChunkUniversalBeing

# ===== DEBUGGABLE INTERFACE IMPLEMENTATION =====

func get_debug_payload() -> Dictionary:
	"""Return clean debug payload - only what matters for debugging"""
	return {
		# Spatial properties
		"position": global_position,
		"chunk_coordinates": chunk_coordinates,
		"chunk_size": chunk_size,
		
		# State properties
		"chunk_active": chunk_active,
		"generation_level": generation_level,
		"current_lod": LODLevel.keys()[current_lod],
		
		# Content properties
		"stored_beings_count": stored_beings.size(),
		"render_distance": render_distance,
		"detail_distance": detail_distance,
		
		# Consciousness properties
		"consciousness_level": consciousness_level,
		"being_name": being_name,
		"being_type": being_type
	}

func set_debug_field(key: String, value) -> void:
	"""Handle live field editing from debug interface"""
	match key:
		"position":
			if value is Vector3:
				global_position = value
				print("🧊 Chunk moved to: %s" % value)
		
		"chunk_coordinates":
			if value is Vector3i:
				chunk_coordinates = value
				being_name = "Chunk_%d_%d_%d" % [value.x, value.y, value.z]
				print("🧊 Chunk coordinates changed to: %s" % value)
		
		"chunk_active":
			if value is bool:
				chunk_active = value
				if chunk_active:
					print("🔥 Chunk activated!")
				else:
					print("❄️ Chunk deactivated!")
		
		"generation_level":
			if value is int:
				generation_level = clampi(value, 0, 3)
				print("🎨 Generation level set to: %d" % generation_level)
		
		"consciousness_level":
			if value is int:
				consciousness_level = clampi(value, 0, 5)
				print("🧠 Consciousness level changed to: %d" % consciousness_level)
				# Update debug label color
				if debug_label:
					debug_label.modulate = get_consciousness_color()
		
		"render_distance":
			if value is float:
				render_distance = maxf(value, 1.0)
				print("👁️ Render distance set to: %.1f" % render_distance)
		
		"detail_distance":
			if value is float:
				detail_distance = maxf(value, 1.0)
				print("🔍 Detail distance set to: %.1f" % detail_distance)
		
		"being_name":
			if value is String:
				being_name = value
				if debug_label:
					debug_label.text = "[%d,%d,%d] %s" % [chunk_coordinates.x, chunk_coordinates.y, chunk_coordinates.z, being_name]
				print("📝 Being name changed to: %s" % value)
		
		_:
			print("⚠️ Unknown debug field: %s" % key)

func get_debug_actions() -> Dictionary:
	"""Return callable debug actions"""
	return {
		"Force Generate": force_generate_content,
		"Clear Content": clear_chunk_content,
		"Activate": activate_chunk_full,
		"Deactivate": deactivate_chunk,
		"Save to Akashic": save_chunk_to_akashic,
		"Regenerate Debug": regenerate_debug_label,
		"Test LOD": test_lod_levels,
		"Show Bounds": toggle_chunk_boundary
	}

# ===== DEBUG ACTION IMPLEMENTATIONS =====

func force_generate_content() -> void:
	"""Force generate content regardless of current state"""
	print("🚀 Force generating content for %s" % being_name)
	
	# Generate all levels
	generate_basic_content()
	generate_detailed_content() 
	generate_full_content()
	
	print("✨ Force generation complete - Level: %d, Beings: %d" % [generation_level, stored_beings.size()])

func clear_chunk_content() -> void:
	"""Clear all generated content"""
	print("🧹 Clearing content for %s" % being_name)
	
	# Remove all stored beings
	for being in stored_beings:
		if being and is_instance_valid(being):
			being.queue_free()
	
	stored_beings.clear()
	generation_level = 0
	stored_data.clear()
	
	print("🧹 Chunk content cleared")

func regenerate_debug_label() -> void:
	"""Regenerate the debug label"""
	if debug_label:
		debug_label.queue_free()
		debug_label = null
	
	create_debug_visualization()
	print("🏷️ Debug label regenerated")

func test_lod_levels() -> void:
	"""Cycle through all LOD levels for testing"""
	print("🔄 Testing all LOD levels...")
	
	var original_lod = current_lod
	
	# Cycle through all levels
	for lod_level in LODLevel.values():
		set_lod_level(lod_level)
		print("  LOD %s: %s" % [LODLevel.keys()[lod_level], get_lod_description(lod_level)])
		await get_tree().create_timer(1.0).timeout
	
	# Return to original
	set_lod_level(original_lod)
	print("🔄 LOD test complete")

func toggle_chunk_boundary() -> void:
	"""Toggle chunk boundary visualization"""
	if chunk_boundary:
		chunk_boundary.visible = !chunk_boundary.visible
		print("📦 Chunk boundary: %s" % ("visible" if chunk_boundary.visible else "hidden"))
	else:
		create_chunk_boundary()
		print("📦 Chunk boundary created")

func get_lod_description(lod: LODLevel) -> String:
	"""Get description of LOD level"""
	match lod:
		LODLevel.HIDDEN: return "Completely hidden"
		LODLevel.MINIMAL: return "Debug labels only"
		LODLevel.BASIC: return "Basic terrain"
		LODLevel.DETAILED: return "Detailed content"
		LODLevel.FULL_DETAIL: return "Full content + beings"
		_: return "Unknown LOD"

# ===== ENHANCED PENTAGON METHODS FOR DEBUGGING =====

func pentagon_init() -> void:
	"""Enhanced init with debug feedback"""
	super.pentagon_init()
	print("🧊 Debuggable Chunk initializing: %s" % being_name)

func pentagon_ready() -> void:
	"""Enhanced ready with debug feedback"""
	super.pentagon_ready()
	print("🧊 Debuggable Chunk ready: %s at %s" % [being_name, global_position])

# ===== HELPER METHODS =====

func get_debug_summary() -> String:
	"""Get a quick debug summary"""
	return "Chunk %s: LOD=%s, Gen=%d, Beings=%d, Active=%s" % [
		chunk_coordinates,
		LODLevel.keys()[current_lod],
		generation_level,
		stored_beings.size(),
		chunk_active
	]

func print_debug_status() -> void:
	"""Print detailed debug status"""
	print("🧊 Debug Status for %s:" % being_name)
	print("  Position: %s" % global_position)
	print("  Coordinates: %s" % chunk_coordinates)
	print("  LOD Level: %s" % LODLevel.keys()[current_lod])
	print("  Generation Level: %d" % generation_level)
	print("  Stored Beings: %d" % stored_beings.size())
	print("  Active: %s" % chunk_active)
	print("  Consciousness: %d" % consciousness_level)
	print("  Render Distance: %.1f" % render_distance)
	print("  Detail Distance: %.1f" % detail_distance)