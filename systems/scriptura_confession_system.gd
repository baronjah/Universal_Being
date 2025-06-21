extends Node3D
class_name ScripturaConfessionSystem

# 🔮 SCRIPTURA CONFESSION SYSTEM
# Scripts must confess their sins to the user via voice/text
# Criminal investigation style debugging with evidence boards

signal scriptura_confessed(script_path: String, confession: Dictionary)
signal sin_discovered(script_path: String, sin_type: String, details: String)
signal investigation_board_updated(evidence_count: int)

# Pentagon Architecture Variables
var consciousness_level: int = 4
var being_type: String = "scriptura_confessor"
var being_name: String = "Divine Script Interrogator"

# Confession System State
var scripts_database: Dictionary = {}  # script_path -> script_analysis
var confessions_log: Array[Dictionary] = []
var investigation_boards: Dictionary = {}  # script_path -> visual_board
var active_investigation: String = ""
var confession_queue: Array[String] = []

# Criminal Investigation Visual Elements
var evidence_pins: Array[Node3D] = []
var connection_lines: Array[Node3D] = []
var confession_booth_scene: Node3D = null
var hovering_confession_text: Label3D = null

# Audio System
var confession_audio_player: AudioStreamPlayer3D = null
var voice_samples: Dictionary = {}

# Visual Configuration  
var stellar_colors: Array[Color] = [
	Color(0.0, 0.0, 0.0),      # 0: Void - No sins
	Color(0.2, 0.1, 0.0),      # 1: Brown dwarf - Minor issues  
	Color(0.8, 0.0, 0.0),      # 2: Red giant - Syntax errors
	Color(1.0, 0.5, 0.0),      # 3: Orange star - Logic errors
	Color(1.0, 1.0, 0.0),      # 4: Yellow sun - Performance issues
	Color(1.0, 1.0, 1.0),      # 5: White dwarf - Architecture violations
	Color(0.7, 0.9, 1.0),      # 6: Blue giant - Missing functions
	Color(0.0, 0.5, 1.0),      # 7: Blue supergiant - Pentagon violations
	Color(0.5, 0.0, 1.0)       # 8: Violet pulsar - Critical system failures
]

# Pentagon Lifecycle Implementation
func pentagon_init() -> void:
	super.pentagon_init() if has_method("pentagon_init")
	being_type = "scriptura_confessor"
	being_name = "Divine Script Interrogator"
	consciousness_level = 4
	initialize_confession_system()

func pentagon_ready() -> void:
	super.pentagon_ready() if has_method("pentagon_ready")
	setup_confession_booth()
	scan_all_scripts()
	create_investigation_environment()
	connect_to_flood_gates()
	UBPrint.log_message("🔮 Scriptura Confession System ready for divine interrogation", UBPrint.LogLevel.INFO)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta) if has_method("pentagon_process")
	process_confession_queue(delta)
	update_visual_effects(delta)
	monitor_script_sins()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event) if has_method("pentagon_input")
	if event.is_action_pressed("interrogate_script"):
		interrogate_nearest_script()
	elif event.is_action_pressed("open_investigation"):
		open_investigation_board()
	elif event.is_action_pressed("confess_all"):
		force_all_confessions()
	elif event.is_action_pressed("absolve_sins"):
		absolve_selected_script()

func pentagon_sewers() -> void:
	save_confessions_to_akashic()
	clear_investigation_boards()
	super.pentagon_sewers() if has_method("pentagon_sewers")

# Core Confession System
func initialize_confession_system() -> void:
	scripts_database = {}
	confessions_log = []
	investigation_boards = {}
	
	# Load previous confessions from Akashic Records
	load_previous_confessions()

func scan_all_scripts() -> void:
	var script_files = find_all_script_files()
	
	for script_path in script_files:
		analyze_script_sins(script_path)
	
	UBPrint.log_message("📋 Analyzed " + str(script_files.size()) + " scripts for confession", UBPrint.LogLevel.INFO)

func find_all_script_files() -> Array[String]:
	var script_files: Array[String] = []
	var dir = DirAccess.open("res://")
	
	if dir:
		_scan_directory_recursive(dir, "res://", script_files)
	
	return script_files

func _scan_directory_recursive(dir: DirAccess, path: String, script_files: Array[String]) -> void:
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			var sub_dir = DirAccess.open(full_path)
			if sub_dir:
				_scan_directory_recursive(sub_dir, full_path, script_files)
		elif file_name.ends_with(".gd"):
			script_files.append(full_path)
		
		file_name = dir.get_next()

func analyze_script_sins(script_path: String) -> Dictionary:
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return {}
	
	var content = file.get_as_text()
	file.close()
	
	var sins_analysis = {
		"path": script_path,
		"lines": content.split("\n"),
		"sins": [],
		"confession_needed": false,
		"sin_level": 0,
		"last_modified": FileAccess.get_modified_time(script_path)
	}
	
	# Analyze for different types of sins
	analyze_syntax_sins(sins_analysis)
	analyze_pentagon_sins(sins_analysis)
	analyze_performance_sins(sins_analysis)
	analyze_architecture_sins(sins_analysis)
	
	# Calculate overall sin level
	sins_analysis.sin_level = calculate_sin_level(sins_analysis.sins)
	sins_analysis.confession_needed = sins_analysis.sin_level > 0
	
	scripts_database[script_path] = sins_analysis
	
	if sins_analysis.confession_needed:
		confession_queue.append(script_path)
	
	return sins_analysis

func analyze_syntax_sins(analysis: Dictionary) -> void:
	var lines = analysis.lines as Array
	
	for i in range(lines.size()):
		var line = lines[i] as String
		
		# Check for syntax sins
		if line.contains("print(") and not line.contains("UBPrint"):
			analysis.sins.append({
				"type": "forbidden_print",
				"line": i + 1,
				"description": "Using forbidden print() instead of UBPrint.log_message()",
				"severity": 3
			})
		
		if line.contains("await") and not line.strip_edges().ends_with("# Pentagon approved"):
			analysis.sins.append({
				"type": "dangerous_await",
				"line": i + 1, 
				"description": "Using await without Pentagon architecture approval",
				"severity": 5
			})
		
		if line.contains("_process(") and not line.contains("pentagon_process"):
			analysis.sins.append({
				"type": "pentagon_violation",
				"line": i + 1,
				"description": "Using _process instead of pentagon_process",
				"severity": 7
			})

func analyze_pentagon_sins(analysis: Dictionary) -> void:
	var content = "\n".join(analysis.lines)
	var required_methods = ["pentagon_init", "pentagon_ready", "pentagon_process", "pentagon_input", "pentagon_sewers"]
	
	for method in required_methods:
		if not content.contains("func " + method):
			analysis.sins.append({
				"type": "missing_pentagon_method",
				"line": 0,
				"description": "Missing required Pentagon method: " + method,
				"severity": 6
			})

func analyze_performance_sins(analysis: Dictionary) -> void:
	var lines = analysis.lines as Array
	
	for i in range(lines.size()):
		var line = lines[i] as String
		
		if line.contains("get_children()") and not line.contains("# Performance approved"):
			analysis.sins.append({
				"type": "performance_sin",
				"line": i + 1,
				"description": "Using get_children() without caching - performance impact",
				"severity": 4
			})
		
		if line.contains("find_node(") or line.contains("find_child("):
			analysis.sins.append({
				"type": "performance_sin", 
				"line": i + 1,
				"description": "Using deprecated find methods - use get_node() instead",
				"severity": 5
			})

func analyze_architecture_sins(analysis: Dictionary) -> void:
	var content = "\n".join(analysis.lines)
	
	if content.contains("extends Node3D") and not content.contains("extends UniversalBeing"):
		if not content.contains("class_name") or not content.contains("System"):
			analysis.sins.append({
				"type": "architecture_violation",
				"line": 1,
				"description": "Node3D should extend UniversalBeing for consciousness",
				"severity": 6
			})

func calculate_sin_level(sins: Array) -> int:
	var total_severity = 0
	for sin in sins:
		total_severity += sin.get("severity", 1)
	
	return min(total_severity, 8)  # Cap at max color index

# Confession Processing
func process_confession_queue(delta: float) -> void:
	if confession_queue.is_empty():
		return
	
	# Process one confession per frame to avoid lag
	var script_path = confession_queue.pop_front()
	initiate_confession(script_path)

func initiate_confession(script_path: String) -> void:
	if not scripts_database.has(script_path):
		return
	
	var analysis = scripts_database[script_path]
	var confession = create_confession(analysis)
	
	# Visual confession
	display_confession_visually(confession)
	
	# Audio confession (if enabled)
	speak_confession(confession)
	
	# Store confession
	confessions_log.append(confession)
	scriptura_confessed.emit(script_path, confession)
	
	UBPrint.log_message("🔮 Script confessed: " + script_path, UBPrint.LogLevel.INFO)

func create_confession(analysis: Dictionary) -> Dictionary:
	var confession = {
		"script_path": analysis.path,
		"confession_time": Time.get_unix_time_from_system(),
		"sin_level": analysis.sin_level,
		"sins": analysis.sins,
		"confession_text": generate_confession_text(analysis),
		"absolution_granted": false
	}
	
	return confession

func generate_confession_text(analysis: Dictionary) -> String:
	var script_name = analysis.path.get_file()
	var sin_count = analysis.sins.size()
	
	var confession_lines = [
		"🔮 Forgive me, Divine Programmer, for I have sinned...",
		"I am " + script_name + ", and I confess my " + str(sin_count) + " transgressions:",
		""
	]
	
	for sin in analysis.sins:
		var sin_text = "  • Line " + str(sin.line) + ": " + sin.description + " (severity: " + str(sin.severity) + ")"
		confession_lines.append(sin_text)
	
	confession_lines.append("")
	confession_lines.append("I await your divine judgment and offer myself for debugging...")
	
	return "\n".join(confession_lines)

# Visual Investigation System
func setup_confession_booth() -> void:
	confession_booth_scene = Node3D.new()
	confession_booth_scene.name = "ConfessionBooth"
	add_child(confession_booth_scene)
	
	# Create confession booth visual
	var booth_mesh = MeshInstance3D.new()
	booth_mesh.mesh = BoxMesh.new()
	booth_mesh.mesh.size = Vector3(4, 6, 4)
	booth_mesh.position = Vector3(0, 3, 0)
	
	var booth_material = StandardMaterial3D.new()
	booth_material.albedo_color = stellar_colors[5]  # White
	booth_material.emission_enabled = true
	booth_material.emission = stellar_colors[5] * 0.3
	booth_mesh.material_override = booth_material
	
	confession_booth_scene.add_child(booth_mesh)
	
	# Add floating confession text
	hovering_confession_text = Label3D.new()
	hovering_confession_text.text = "🔮 SCRIPTURA CONFESSION BOOTH\nPress I to interrogate scripts"
	hovering_confession_text.position = Vector3(0, 8, 0)
	hovering_confession_text.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	confession_booth_scene.add_child(hovering_confession_text)

func create_investigation_environment() -> void:
	# Create investigation boards for major sins
	for script_path in scripts_database.keys():
		var analysis = scripts_database[script_path]
		if analysis.sin_level >= 5:  # Only create boards for serious sins
			create_investigation_board(script_path)

func create_investigation_board(script_path: String) -> void:
	var board = Node3D.new()
	board.name = "InvestigationBoard_" + script_path.get_file()
	add_child(board)
	
	# Create board background
	var board_mesh = MeshInstance3D.new()
	board_mesh.mesh = BoxMesh.new()
	board_mesh.mesh.size = Vector3(6, 4, 0.1)
	
	var board_material = StandardMaterial3D.new()
	board_material.albedo_color = Color(0.2, 0.2, 0.3)
	board_mesh.material_override = board_material
	
	board.add_child(board_mesh)
	
	# Position boards in a circle around confession booth
	var board_count = investigation_boards.size()
	var angle = (board_count * PI * 2) / 8  # Max 8 boards
	var radius = 15.0
	board.position = Vector3(sin(angle) * radius, 2, cos(angle) * radius)
	board.look_at(Vector3.ZERO, Vector3.UP)
	
	# Add evidence pins
	create_evidence_pins(board, script_path)
	
	investigation_boards[script_path] = board

func create_evidence_pins(board: Node3D, script_path: String) -> void:
	if not scripts_database.has(script_path):
		return
	
	var analysis = scripts_database[script_path]
	var sins = analysis.sins as Array
	
	for i in range(min(sins.size(), 10)):  # Max 10 pins per board
		var sin = sins[i]
		var pin = create_evidence_pin(sin, i)
		board.add_child(pin)

func create_evidence_pin(sin: Dictionary, index: int) -> Node3D:
	var pin = Node3D.new()
	
	# Create pin visual
	var pin_mesh = MeshInstance3D.new()
	pin_mesh.mesh = CylinderMesh.new()
	pin_mesh.mesh.top_radius = 0.1
	pin_mesh.mesh.bottom_radius = 0.05
	pin_mesh.mesh.height = 0.3
	
	var pin_material = StandardMaterial3D.new()
	var severity = sin.get("severity", 1)
	pin_material.albedo_color = stellar_colors[min(severity, stellar_colors.size() - 1)]
	pin_material.emission_enabled = true
	pin_material.emission = pin_material.albedo_color * 0.5
	pin_mesh.material_override = pin_material
	
	pin.add_child(pin_mesh)
	
	# Position on board
	var x_offset = (index % 3 - 1) * 1.5
	var y_offset = (index / 3 - 1) * 1.0
	pin.position = Vector3(x_offset, y_offset, 0.1)
	
	# Add text label
	var label = Label3D.new()
	label.text = sin.get("type", "unknown") + "\nLine: " + str(sin.get("line", 0))
	label.position = Vector3(0, 0, 0.2)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pin.add_child(label)
	
	evidence_pins.append(pin)
	return pin

# Audio Confession System
func speak_confession(confession: Dictionary) -> void:
	if not confession_audio_player:
		setup_audio_system()
	
	# For now, just log the confession text
	# TODO: Integrate with TTS system when available
	UBPrint.log_message("🔊 Speaking confession: " + confession.script_path, UBPrint.LogLevel.INFO)

func setup_audio_system() -> void:
	confession_audio_player = AudioStreamPlayer3D.new()
	confession_audio_player.position = Vector3(0, 5, 0)
	add_child(confession_audio_player)

# Public API
func interrogate_script(script_path: String) -> Dictionary:
	if not scripts_database.has(script_path):
		analyze_script_sins(script_path)
	
	var analysis = scripts_database[script_path]
	if analysis.confession_needed:
		initiate_confession(script_path)
	
	return analysis

func interrogate_nearest_script() -> void:
	# Find nearest script file to player
	var player_pos = get_player_position()
	var nearest_script = find_nearest_script_representation(player_pos)
	
	if nearest_script != "":
		interrogate_script(nearest_script)

func force_all_confessions() -> void:
	confession_queue.clear()
	for script_path in scripts_database.keys():
		var analysis = scripts_database[script_path]
		if analysis.confession_needed:
			confession_queue.append(script_path)
	
	UBPrint.log_message("🔮 Forcing all scripts to confess their sins!", UBPrint.LogLevel.INFO)

func absolve_script(script_path: String) -> void:
	# Mark script as absolved in confessions log
	for confession in confessions_log:
		if confession.script_path == script_path:
			confession.absolution_granted = true
	
	# Update visual representation
	if investigation_boards.has(script_path):
		var board = investigation_boards[script_path]
		var mesh = board.get_child(0) as MeshInstance3D
		if mesh:
			var material = mesh.material_override as StandardMaterial3D
			material.albedo_color = stellar_colors[5]  # White for absolution

func get_confession_for_script(script_path: String) -> Dictionary:
	for confession in confessions_log:
		if confession.script_path == script_path:
			return confession
	return {}

# Utility Functions
func get_player_position() -> Vector3:
	var camera = get_viewport().get_camera_3d()
	if camera:
		return camera.global_position
	return Vector3.ZERO

func find_nearest_script_representation(player_pos: Vector3) -> String:
	# For now, return first script that needs confession
	for script_path in scripts_database.keys():
		var analysis = scripts_database[script_path]
		if analysis.confession_needed:
			return script_path
	return ""

func display_confession_visually(confession: Dictionary) -> void:
	if hovering_confession_text:
		hovering_confession_text.text = confession.confession_text
		
		# Color based on sin level
		var sin_level = confession.get("sin_level", 0)
		hovering_confession_text.modulate = stellar_colors[min(sin_level, stellar_colors.size() - 1)]

func update_visual_effects(delta: float) -> void:
	# Animate confession booth
	if confession_booth_scene:
		confession_booth_scene.rotation.y += delta * 0.1
	
	# Pulse evidence pins
	for pin in evidence_pins:
		if is_instance_valid(pin):
			var pulse = sin(Time.get_time_from_start() * 2.0) * 0.1 + 1.0
			pin.scale = Vector3.ONE * pulse

func monitor_script_sins() -> void:
	# Check for new scripts or modified scripts
	var current_time = Time.get_unix_time_from_system()
	
	for script_path in scripts_database.keys():
		var analysis = scripts_database[script_path]
		var file_modified_time = FileAccess.get_modified_time(script_path)
		
		if file_modified_time > analysis.last_modified:
			# Script was modified, re-analyze
			analyze_script_sins(script_path)
			UBPrint.log_message("🔄 Re-analyzing modified script: " + script_path, UBPrint.LogLevel.DEBUG)

func connect_to_flood_gates() -> void:
	var flood_gates = get_node_or_null("/root/SystemBootstrap")
	if flood_gates and flood_gates.has_method("register_being"):
		flood_gates.register_being(self)

func open_investigation_board() -> void:
	active_investigation = find_script_with_most_sins()
	if active_investigation != "":
		UBPrint.log_message("🔍 Opening investigation for: " + active_investigation, UBPrint.LogLevel.INFO)

func find_script_with_most_sins() -> String:
	var max_sins = 0
	var worst_script = ""
	
	for script_path in scripts_database.keys():
		var analysis = scripts_database[script_path]
		if analysis.sins.size() > max_sins:
			max_sins = analysis.sins.size()
			worst_script = script_path
	
	return worst_script

func absolve_selected_script() -> void:
	if active_investigation != "":
		absolve_script(active_investigation)
		UBPrint.log_message("✨ Absolved script: " + active_investigation, UBPrint.LogLevel.INFO)

func load_previous_confessions() -> void:
	# TODO: Load from Akashic Records
	pass

func save_confessions_to_akashic() -> void:
	# TODO: Save to Akashic Records
	pass

func clear_investigation_boards() -> void:
	for board in investigation_boards.values():
		if is_instance_valid(board):
			board.queue_free()
	investigation_boards.clear()
	evidence_pins.clear()