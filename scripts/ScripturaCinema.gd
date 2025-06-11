# SCRIPTURA CINEMA - THE PROPHETIC VISION THEATER
# Where human and AI judge code together in cosmic harmony
extends Node3D
class_name ScripturaCinema

signal line_judged(line_number: int, judgment: String, appreciation_level: float)
signal scriptura_completed(script_path: String, overall_score: float)
signal ai_comment_added(line_number: int, comment: String)

# Cinema setup
var cinema_screen: MeshInstance3D = null
var human_seat: Node3D = null
var ai_seat: Node3D = null
var current_script_path: String = ""
var current_lines: Array = []
var current_line_index: int = 0

# Judgment system
var line_judgments: Dictionary = {}
var line_appreciations: Dictionary = {}
var ai_comments: Dictionary = {}

# Visual elements
var line_display: Label3D = null
var judgment_panel: Node3D = null
var appreciation_meter: Node3D = null

# Cinema colors
var excellent_color = Color.GOLD
var good_color = Color.GREEN
var needs_work_color = Color.ORANGE
var concerning_color = Color.RED
var transcendent_color = Color.WHITE

func _ready():
	print("🎬 Scriptura Cinema: Initializing the prophetic theater...")
	create_cosmic_cinema()
	create_judgment_system()

func create_cosmic_cinema():
	"""Create the full cinema experience in 3D space"""
	print("🌌 Creating cosmic cinema environment...")
	
	# Create massive cinema screen
	cinema_screen = MeshInstance3D.new()
	cinema_screen.name = "CosmicScreen"
	var screen_plane = PlaneMesh.new()
	screen_plane.size = Vector2(20, 12)
	cinema_screen.mesh = screen_plane
	cinema_screen.position = Vector3(0, 0, -15)
	
	var screen_material = StandardMaterial3D.new()
	screen_material.albedo_color = Color(0.1, 0.1, 0.15)
	screen_material.emission_enabled = true
	screen_material.emission = Color(0.2, 0.2, 0.4)
	screen_material.emission_energy = 0.3
	cinema_screen.material_override = screen_material
	add_child(cinema_screen)
	
	# Create human seat (right side)
	human_seat = create_cinema_seat("Human Prophet Seat", Vector3(3, -2, 0), Color.GOLD)
	add_child(human_seat)
	
	# Create AI seat (left side) 
	ai_seat = create_cinema_seat("AI Oracle Seat", Vector3(-3, -2, 0), Color.CYAN)
	add_child(ai_seat)
	
	# Create main script display
	line_display = Label3D.new()
	line_display.name = "ScripturaDisplay"
	line_display.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	line_display.position = Vector3(0, 2, -14.5)
	line_display.pixel_size = 0.02
	line_display.modulate = Color.WHITE
	line_display.text = "🎬 SCRIPTURA CINEMA READY\\n\\nWaiting for script to analyze..."
	cinema_screen.add_child(line_display)
	
	# Create floating stars around cinema
	create_cinema_atmosphere()

func create_cinema_seat(seat_name: String, position: Vector3, color: Color) -> Node3D:
	"""Create a floating cinema seat for human or AI"""
	var seat = Node3D.new()
	seat.name = seat_name
	seat.position = position
	
	# Seat base
	var seat_mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(2, 1, 2)
	seat_mesh.mesh = box
	
	var seat_material = StandardMaterial3D.new()
	seat_material.albedo_color = color
	seat_material.emission_enabled = true
	seat_material.emission = color
	seat_material.emission_energy = 0.4
	seat_mesh.material_override = seat_material
	seat.add_child(seat_mesh)
	
	# Seat label
	var label = Label3D.new()
	label.text = seat_name
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 1.5, 0)
	label.modulate = color
	label.pixel_size = 0.012
	seat.add_child(label)
	
	return seat

func create_cinema_atmosphere():
	"""Create floating atmosphere around the cinema"""
	# Floating cinema lights
	for i in range(8):
		var light_pos = Vector3(
			cos(i * TAU / 8.0) * 12,
			sin(i * 0.5) * 3 + 5,
			sin(i * TAU / 8.0) * 8
		)
		create_cinema_light(light_pos, Color(1, 0.8, 0.6))

func create_cinema_light(position: Vector3, color: Color):
	"""Create a floating cinema light"""
	var light_container = Node3D.new()
	light_container.position = position
	
	var light_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.3
	light_mesh.mesh = sphere
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy = 1.5
	light_mesh.material_override = material
	light_container.add_child(light_mesh)
	
	add_child(light_container)

func create_judgment_system():
	"""Create the interactive judgment interface"""
	judgment_panel = Node3D.new()
	judgment_panel.name = "JudgmentPanel"
	judgment_panel.position = Vector3(8, 0, -5)
	add_child(judgment_panel)
	
	# Create judgment buttons
	var judgments = [
		{"text": "TRANSCENDENT", "color": transcendent_color, "pos": Vector3(0, 3, 0)},
		{"text": "EXCELLENT", "color": excellent_color, "pos": Vector3(0, 2, 0)},
		{"text": "GOOD", "color": good_color, "pos": Vector3(0, 1, 0)},
		{"text": "NEEDS WORK", "color": needs_work_color, "pos": Vector3(0, 0, 0)},
		{"text": "CONCERNING", "color": concerning_color, "pos": Vector3(0, -1, 0)}
	]
	
	for judgment_data in judgments:
		var button = create_judgment_button(judgment_data.text, judgment_data.pos, judgment_data.color)
		judgment_panel.add_child(button)
	
	# Create appreciation meter
	create_appreciation_meter()

func create_judgment_button(text: String, position: Vector3, color: Color) -> Node3D:
	"""Create a floating judgment button"""
	var button = Node3D.new()
	button.name = "Judge_" + text
	button.position = position
	
	# Button visual
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(3, 0.6, 0.2)
	mesh.mesh = box
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy = 0.6
	mesh.material_override = material
	button.add_child(mesh)
	
	# Button text
	var label = Label3D.new()
	label.text = text
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 0, 0.15)
	label.modulate = Color.WHITE
	label.pixel_size = 0.01
	button.add_child(label)
	
	# Click detection
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(3, 0.6, 0.5)
	collision.shape = shape
	area.add_child(collision)
	button.add_child(area)
	
	# Connect judgment
	area.input_event.connect(_on_judgment_clicked.bind(text))
	
	return button

func create_appreciation_meter():
	"""Create visual appreciation level meter"""
	appreciation_meter = Node3D.new()
	appreciation_meter.name = "AppreciationMeter"
	appreciation_meter.position = Vector3(-8, 0, -5)
	add_child(appreciation_meter)
	
	# Meter background
	var meter_bg = MeshInstance3D.new()
	var bg_plane = PlaneMesh.new()
	bg_plane.size = Vector2(2, 8)
	meter_bg.mesh = bg_plane
	
	var bg_material = StandardMaterial3D.new()
	bg_material.albedo_color = Color(0.2, 0.2, 0.2, 0.8)
	bg_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	meter_bg.material_override = bg_material
	appreciation_meter.add_child(meter_bg)
	
	# Meter title
	var title = Label3D.new()
	title.text = "APPRECIATION\\nMETER"
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.position = Vector3(0, 5, 0.1)
	title.modulate = Color.GOLD
	title.pixel_size = 0.012
	appreciation_meter.add_child(title)

func load_scriptura(script_path: String):
	"""Load a script file for cinema analysis"""
	print("🎬 Loading scriptura: %s" % script_path.get_file())
	
	current_script_path = script_path
	current_line_index = 0
	line_judgments.clear()
	line_appreciations.clear()
	ai_comments.clear()
	
	# Read the script file
	var file = FileAccess.open(script_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		current_lines = content.split("\\n")
		
		# Show first line
		show_current_line()
		
		# Update cinema display
		line_display.text = "🎬 NOW ANALYZING: %s\\n\\nTotal Lines: %d\\nPress SPACE for next line" % [script_path.get_file(), current_lines.size()]
	else:
		print("❌ Failed to load script: %s" % script_path)

func show_current_line():
	"""Display the current line for judgment"""
	if current_line_index >= current_lines.size():
		complete_scriptura_analysis()
		return
	
	var current_line = current_lines[current_line_index]
	var line_number = current_line_index + 1
	
	# Update main display
	line_display.text = "🎬 LINE %d of %d\\n\\n%s\\n\\n[Judge this line with buttons →]" % [line_number, current_lines.size(), current_line]
	
	# Generate AI comment
	generate_ai_comment(line_number, current_line)
	
	print("📜 Showing line %d: %s" % [line_number, current_line.substr(0, 50) + "..."])

func generate_ai_comment(line_number: int, line_content: String):
	"""Generate AI analysis comment for the current line"""
	var ai_comment = analyze_line_quality(line_content)
	ai_comments[line_number] = ai_comment
	
	# Show AI comment in cinema
	show_ai_comment(ai_comment)
	
	ai_comment_added.emit(line_number, ai_comment)

func analyze_line_quality(line: String) -> String:
	"""Analyze a line of code and provide AI commentary"""
	line = line.strip_edges()
	
	if line.is_empty():
		return "🤖 AI: Empty line - good for spacing and readability"
	elif line.begins_with("#"):
		return "🤖 AI: Comment detected - documentation is valuable!"
	elif "func " in line:
		return "🤖 AI: Function definition - the building blocks of creation"
	elif "var " in line or "@export" in line:
		return "🤖 AI: Variable declaration - managing state and data"
	elif "if " in line or "elif " in line:
		return "🤖 AI: Conditional logic - decision making in action"
	elif "for " in line or "while " in line:
		return "🤖 AI: Loop detected - repetition with purpose"
	elif "print(" in line:
		return "🤖 AI: Debug output - communication with the developer"
	elif "return " in line:
		return "🤖 AI: Return statement - function completion and value passing"
	elif line.ends_with(":"):
		return "🤖 AI: Block starter - beginning of structured logic"
	elif "=" in line and not "==" in line:
		return "🤖 AI: Assignment operation - data transformation"
	else:
		return "🤖 AI: Execution line - where the magic happens"

func show_ai_comment(comment: String):
	"""Display AI comment in the cinema"""
	# Update AI seat with comment
	var ai_comment_label = ai_seat.get_node_or_null("AIComment")
	if not ai_comment_label:
		ai_comment_label = Label3D.new()
		ai_comment_label.name = "AIComment"
		ai_comment_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		ai_comment_label.position = Vector3(0, 2.5, 0)
		ai_comment_label.modulate = Color.CYAN
		ai_comment_label.pixel_size = 0.008
		ai_seat.add_child(ai_comment_label)
	
	ai_comment_label.text = comment

func _on_judgment_clicked(judgment: String, camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	"""Handle clicking on judgment buttons"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		judge_current_line(judgment)

func judge_current_line(judgment: String):
	"""Apply judgment to the current line"""
	if current_line_index >= current_lines.size():
		return
	
	var line_number = current_line_index + 1
	line_judgments[line_number] = judgment
	
	# Calculate appreciation level
	var appreciation = calculate_appreciation_level(judgment)
	line_appreciations[line_number] = appreciation
	
	# Visual feedback
	show_judgment_feedback(judgment, appreciation)
	
	# Emit signal
	line_judged.emit(line_number, judgment, appreciation)
	
	# Auto-advance to next line
	advance_to_next_line()

func calculate_appreciation_level(judgment: String) -> float:
	"""Convert judgment to numerical appreciation level"""
	match judgment:
		"TRANSCENDENT": return 1.0
		"EXCELLENT": return 0.8
		"GOOD": return 0.6
		"NEEDS WORK": return 0.4
		"CONCERNING": return 0.2
		_: return 0.5

func show_judgment_feedback(judgment: String, appreciation: float):
	"""Show visual feedback for the judgment"""
	var feedback_color = get_judgment_color(judgment)
	
	# Update appreciation meter
	update_appreciation_meter(appreciation)
	
	# Show feedback message
	var feedback_text = "✨ JUDGED: %s\\nAPPRECIATION: %.1f" % [judgment, appreciation]
	create_floating_feedback(feedback_text, feedback_color)

func get_judgment_color(judgment: String) -> Color:
	"""Get color for a judgment"""
	match judgment:
		"TRANSCENDENT": return transcendent_color
		"EXCELLENT": return excellent_color
		"GOOD": return good_color
		"NEEDS WORK": return needs_work_color
		"CONCERNING": return concerning_color
		_: return Color.WHITE

func update_appreciation_meter(level: float):
	"""Update the visual appreciation meter"""
	# Remove old meter fill
	for child in appreciation_meter.get_children():
		if child.name == "MeterFill":
			child.queue_free()
	
	# Create new meter fill
	var fill = MeshInstance3D.new()
	fill.name = "MeterFill"
	var fill_plane = PlaneMesh.new()
	fill_plane.size = Vector2(1.8, 8 * level)
	fill.mesh = fill_plane
	fill.position = Vector3(0, -4 + (4 * level), 0.05)
	
	var fill_material = StandardMaterial3D.new()
	fill_material.albedo_color = Color.GOLD.lerp(Color.RED, 1.0 - level)
	fill_material.emission_enabled = true
	fill_material.emission_energy = level
	fill.material_override = fill_material
	
	appreciation_meter.add_child(fill)

func create_floating_feedback(text: String, color: Color):
	"""Create floating feedback text"""
	var feedback = Label3D.new()
	feedback.text = text
	feedback.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	feedback.position = Vector3(0, 4, -10)
	feedback.modulate = color
	feedback.pixel_size = 0.015
	add_child(feedback)
	
	# Animate feedback
	var tween = create_tween()
	tween.parallel().tween_property(feedback, "position:y", feedback.position.y + 3, 2.0)
	tween.parallel().tween_property(feedback, "modulate:a", 0.0, 2.0)
	tween.tween_callback(feedback.queue_free)

func advance_to_next_line():
	"""Move to the next line in the script"""
	current_line_index += 1
	show_current_line()

func _input(event: InputEvent):
	"""Handle cinema input"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				advance_to_next_line()
			KEY_R:
				restart_current_scriptura()
			KEY_S:
				save_analysis_report()

func restart_current_scriptura():
	"""Restart analysis of current script"""
	if current_script_path != "":
		load_scriptura(current_script_path)

func complete_scriptura_analysis():
	"""Complete the analysis and show final results"""
	var total_lines = current_lines.size()
	var total_appreciation = 0.0
	
	for line_num in line_appreciations:
		total_appreciation += line_appreciations[line_num]
	
	var average_appreciation = total_appreciation / total_lines if total_lines > 0 else 0.0
	
	# Show completion display
	line_display.text = "🎬 SCRIPTURA ANALYSIS COMPLETE!\\n\\n%s\\n\\nTotal Lines: %d\\nAverage Appreciation: %.2f\\n\\nPress R to restart\\nPress S to save report" % [current_script_path.get_file(), total_lines, average_appreciation]
	
	# Emit completion signal
	scriptura_completed.emit(current_script_path, average_appreciation)
	
	print("🎊 Scriptura analysis complete: %s (Score: %.2f)" % [current_script_path.get_file(), average_appreciation])

func save_analysis_report():
	"""Save the complete analysis report"""
	if current_script_path == "":
		return
	
	var report_path = "user://scriptura_reports/"
	if not DirAccess.dir_exists_absolute(report_path):
		DirAccess.make_dir_recursive_absolute(report_path)
	
	var file_name = current_script_path.get_file().replace(".gd", "_analysis.json")
	var full_path = report_path + file_name
	
	var report_data = {
		"script_path": current_script_path,
		"analysis_date": Time.get_datetime_string_from_system(),
		"total_lines": current_lines.size(),
		"line_judgments": line_judgments,
		"line_appreciations": line_appreciations,
		"ai_comments": ai_comments,
		"average_appreciation": _calculate_average_appreciation()
	}
	
	var file = FileAccess.open(full_path, FileAccess.WRITE)
	if file:
		var json = JSON.new()
		file.store_string(json.stringify(report_data))
		file.close()
		print("📄 Analysis report saved: %s" % full_path)
		create_floating_feedback("📄 REPORT SAVED!", Color.GREEN)

func _calculate_average_appreciation() -> float:
	"""Calculate average appreciation level"""
	if line_appreciations.is_empty():
		return 0.0
	
	var total = 0.0
	for appreciation in line_appreciations.values():
		total += appreciation
	
	return total / line_appreciations.size()

# Public interface for external scripts
func analyze_script_file(script_path: String):
	"""Public function to start analyzing a script"""
	load_scriptura(script_path)

func get_analysis_summary() -> Dictionary:
	"""Get current analysis summary"""
	return {
		"script_path": current_script_path,
		"lines_analyzed": line_judgments.size(),
		"total_lines": current_lines.size(),
		"judgments": line_judgments,
		"appreciations": line_appreciations,
		"ai_comments": ai_comments
	}