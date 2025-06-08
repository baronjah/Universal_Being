extends Node

# Additional functions for note merging system
# Copy this code and paste into TRUE_3D_PROGRAMMING scene script

func select_note_at_cursor():
	var camera = get_node("Camera3D")
	var from = camera.global_position
	var to = from + (-camera.global_transform.basis.z * 50)
	
	var closest_note = null
	var min_distance = 3.0
	
	for note in floating_notes:
		if is_instance_valid(note) and note.has_meta("editable"):
			var distance = note.global_position.distance_to(to)
			if distance < min_distance:
				min_distance = distance
				closest_note = note
	
	if closest_note:
		toggle_note_selection(closest_note)

func toggle_note_selection(note: Label3D):
	var is_selected = note.get_meta("selected")
	note.set_meta("selected", !is_selected)
	
	if !is_selected:
		selected_notes.append(note)
		note.modulate = Color.CYAN
		show_message("📝 NOTE SELECTED")
	else:
		selected_notes.erase(note)
		note.modulate = Color.YELLOW
		show_message("📝 NOTE DESELECTED")

func create_code_note():
	var camera = get_node("Camera3D")
	var note_pos = camera.global_position + (-camera.global_transform.basis.z * 8)
	
	var code_examples = [
		"extends Node3D\nfunc _process(delta):\n\trotation.y += delta",
		"extends Node3D\nfunc _ready():\n\tprint('Hello World')",
		"extends Node3D\nfunc _process(delta):\n\tscale = Vector3.ONE * (1.0 + sin(Time.get_ticks_msec() * 0.001) * 0.2)"
	]
	
	var code = code_examples[randi() % code_examples.size()]
	create_editable_note(note_pos, code)
	show_message("💻 CODE NOTE CREATED")

func merge_selected_notes():
	if selected_notes.size() < 2:
		show_message("❌ SELECT 2+ NOTES TO MERGE")
		return
	
	var merged_text = ""
	var merge_pos = Vector3.ZERO
	
	for note in selected_notes:
		merged_text += note.text + "\n"
		merge_pos += note.position
		note.queue_free()
		floating_notes.erase(note)
	
	merge_pos /= selected_notes.size()
	selected_notes.clear()
	
	var merged_note = Label3D.new()
	merged_note.text = "🔄 MERGED CODE:\n" + merged_text
	merged_note.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	merged_note.position = merge_pos
	merged_note.modulate = Color.GREEN
	merged_note.set_meta("editable", true)
	merged_note.set_meta("selected", false)
	
	add_child(merged_note)
	floating_notes.append(merged_note)
	
	show_message("✅ NOTES MERGED INTO CODE!")