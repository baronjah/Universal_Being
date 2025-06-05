# UltraFastController - Manages the ultra-fast chunk scene

extends Node3D

var chunk_system: Node3D = null
var player: Node3D = null
var chunk_count_label: Label = null
var fps_label: Label = null

func _ready():
	# Find components
	chunk_system = get_node_or_null("LightweightChunkSystem")
	player = get_node_or_null("UltraFastPlayer")
	
	# Find UI labels
	var ui = get_node_or_null("UI")
	if ui:
		chunk_count_label = ui.get_node_or_null("DebugInfo/ChunkCount")
		fps_label = ui.get_node_or_null("DebugInfo/FPS")
	
	print("🚀 Ultra Fast Controller ready!")

func _process(delta):
	# Update UI every few frames
	if Engine.get_process_frames() % 10 == 0:
		update_debug_ui()

func update_debug_ui():
	"""Update debug information"""
	if chunk_count_label and chunk_system:
		var debug_info = chunk_system.get_debug_info()
		chunk_count_label.text = "Visible Chunks: %d" % debug_info.visible_chunks
	
	if fps_label:
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				# Toggle UI
				var ui = get_node_or_null("UI")
				if ui:
					ui.visible = !ui.visible
			
			KEY_F2:
				# Print debug info
				if chunk_system:
					var debug_info = chunk_system.get_debug_info()
					print("🔍 Debug Info: %s" % debug_info)
			
			KEY_F3:
				# Save current chunk as zip
				if chunk_system and player:
					var player_pos = player.global_position
					var chunk_coord = chunk_system.world_to_chunk_coord(player_pos)
					chunk_system.save_chunk_as_zip(chunk_coord)
			
			KEY_F4:
				# Save all visible chunks
				if chunk_system:
					var debug_info = chunk_system.get_debug_info()
					var coords = debug_info.get("chunk_coordinates", [])
					for coord in coords:
						chunk_system.save_chunk_as_zip(coord)
					print("💾 Saved %d chunks as .ub.zip files" % coords.size())