extends Node

# Eden OS - Main Controller

# References to core systems
var turn_cycle_manager: TurnCycleManager
var astral_entity_system: AstralEntitySystem 
var dimensional_color_system: DimensionalColorSystem
var eden_organizer: EdenOrganizer
var shape_system: ShapeSystem
var shape_dimension_controller: ShapeDimensionController
var paint_system: PaintSystem
var letter_paint_system: LetterPaintSystem

# System state
var initialized: bool = false
var running: bool = false

# Configuration
var auto_advance_turns: bool = false
var auto_advance_interval: float = 30.0 # seconds

# Timer for auto-advancing turns
var auto_advance_timer: Timer

func _ready():
	# Create core systems
	turn_cycle_manager = TurnCycleManager.new()
	astral_entity_system = AstralEntitySystem.new()
	dimensional_color_system = DimensionalColorSystem.new()
	eden_organizer = EdenOrganizer.new()
	shape_system = ShapeSystem.new()
	shape_dimension_controller = ShapeDimensionController.new()
	paint_system = PaintSystem.new()
	letter_paint_system = LetterPaintSystem.new()

	# Add systems to the scene tree
	add_child(turn_cycle_manager)
	add_child(astral_entity_system)
	add_child(dimensional_color_system)
	add_child(eden_organizer)
	add_child(shape_system)
	add_child(shape_dimension_controller)
	add_child(paint_system)
	add_child(letter_paint_system)
	
	# Setup auto-advance timer
	auto_advance_timer = Timer.new()
	auto_advance_timer.wait_time = auto_advance_interval
	auto_advance_timer.one_shot = false
	auto_advance_timer.timeout.connect(_on_auto_advance_timeout)
	add_child(auto_advance_timer)
	
	# Connect signals
	turn_cycle_manager.turn_completed.connect(_on_turn_completed)
	turn_cycle_manager.cycle_completed.connect(_on_cycle_completed)
	turn_cycle_manager.rest_period_started.connect(_on_rest_period_started)
	turn_cycle_manager.rest_period_ended.connect(_on_rest_period_ended)
	
	astral_entity_system.entity_evolved.connect(_on_entity_evolved)
	astral_entity_system.entity_merged.connect(_on_entity_merged)
	astral_entity_system.entity_ascended.connect(_on_entity_ascended)
	
	eden_organizer.directory_cleaned.connect(_on_directory_cleaned)
	eden_organizer.file_categorized.connect(_on_file_categorized)
	eden_organizer.dimensional_scan_completed.connect(_on_dimensional_scan_completed)
	
	shape_dimension_controller.shape_transcended.connect(_on_shape_transcended)
	shape_dimension_controller.shape_attuned.connect(_on_shape_attuned)
	shape_dimension_controller.zone_evolved.connect(_on_zone_evolved)
	
	paint_system.shape_painted.connect(_on_shape_painted)
	paint_system.texture_created.connect(_on_texture_created)

	letter_paint_system.letter_painted.connect(_on_letter_painted)
	letter_paint_system.glyph_recognized.connect(_on_glyph_recognized)
	letter_paint_system.mind_updated.connect(_on_mind_updated)
	
	# Initialize the system
	initialize_system()

func initialize_system():
	print("Initializing Eden OS...")
	
	# Create initialization log
	var init_content = "Eden OS Initialization\n"
	init_content += "=====================\n"
	init_content += "Time: " + Time.get_datetime_string_from_system() + "\n"
	init_content += "Turn Cycle: " + str(turn_cycle_manager.current_turn) + "/12\n"
	init_content += "Completed Cycles: " + str(turn_cycle_manager.total_cycles_completed) + "\n"
	
	# Create system log file
	var log_path = eden_organizer.create_turn_specific_file(init_content, "system_init.log")
	
	if log_path != "":
		print("Initialization log created at: " + log_path)
	
	# Perform initial directory structure check
	eden_organizer._ensure_directory_structure()
	
	initialized = true
	print("Eden OS initialized successfully.")

func start_system():
	if not initialized:
		initialize_system()
	
	running = true
	
	# Start auto-advance if enabled
	if auto_advance_turns:
		auto_advance_timer.start()
	
	print("Eden OS started.")
	
	# If we're at turn 0, advance to turn 1
	if turn_cycle_manager.current_turn == 0:
		turn_cycle_manager.advance_turn()

func stop_system():
	running = false
	auto_advance_timer.stop()
	print("Eden OS stopped.")

func toggle_auto_advance(enabled: bool):
	auto_advance_turns = enabled
	
	if running and auto_advance_turns:
		auto_advance_timer.start()
	else:
		auto_advance_timer.stop()
	
	print("Auto-advance turns: ", "Enabled" if auto_advance_turns else "Disabled")

func set_auto_advance_interval(seconds: float):
	auto_advance_interval = seconds
	auto_advance_timer.wait_time = auto_advance_interval
	print("Auto-advance interval set to ", seconds, " seconds")

func manual_advance_turn():
	if not running:
		print("System not running. Start the system first.")
		return false
	
	return turn_cycle_manager.advance_turn()

func _on_auto_advance_timeout():
	if running and auto_advance_turns:
		turn_cycle_manager.advance_turn()

func _on_turn_completed(turn_number):
	print("Turn ", turn_number, " completed.")
	print("Current color: ", turn_cycle_manager.get_current_color_name())
	
	# Create turn log
	var turn_content = "Eden OS Turn " + str(turn_number) + "\n"
	turn_content += "===================\n"
	turn_content += "Time: " + Time.get_datetime_string_from_system() + "\n"
	turn_content += "Color: " + turn_cycle_manager.get_current_color_name() + "\n"
	turn_content += "Cycle: " + str(turn_cycle_manager.total_cycles_completed) + "\n"
	
	# Create turn log file
	eden_organizer.create_turn_specific_file(turn_content, "turn_log.txt")

func _on_cycle_completed():
	print("Cycle completed. Total cycles: ", turn_cycle_manager.total_cycles_completed)
	
	# Create cycle summary
	var cycle_content = "Eden OS Cycle " + str(turn_cycle_manager.total_cycles_completed) + " Summary\n"
	cycle_content += "========================================\n"
	cycle_content += "Time: " + Time.get_datetime_string_from_system() + "\n"
	
	# Add entity statistics
	var total_entities = astral_entity_system.entities.size()
	cycle_content += "Total Entities: " + str(total_entities) + "\n"
	
	# Create cycle summary file
	eden_organizer.create_turn_specific_file(cycle_content, "cycle_summary.txt")
	
	# Create a dimensional backup at the end of each cycle
	eden_organizer.create_dimensional_backup()

func _on_rest_period_started():
	print("Rest period started. Taking a break...")
	
	# You could add visualization or special effects for the rest period

func _on_rest_period_ended():
	print("Rest period ended. Continuing to next cycle...")
	
	# If auto-advance is enabled, start the next cycle
	if auto_advance_turns:
		turn_cycle_manager.advance_turn()

func _on_entity_evolved(entity_id, new_stage):
	var entity = astral_entity_system.get_entity(entity_id)
	if entity:
		print("Entity evolved: ", entity.name, " -> Stage ", AstralEntitySystem.EvolutionStage.keys()[new_stage])
		
		# Create evolution log
		var evolution_content = "Entity Evolution Log\n"
		evolution_content += "=====================\n"
		evolution_content += "Entity: " + entity.name + "\n"
		evolution_content += "Type: " + AstralEntitySystem.EntityType.keys()[entity.type] + "\n"
		evolution_content += "New Stage: " + AstralEntitySystem.EvolutionStage.keys()[new_stage] + "\n"
		evolution_content += "Time: " + Time.get_datetime_string_from_system() + "\n"
		
		# Create evolution log file
		eden_organizer.create_turn_specific_file(evolution_content, entity.name + "_evolution.txt")

func _on_entity_merged(entity_id1, entity_id2, new_entity_id):
	var new_entity = astral_entity_system.get_entity(new_entity_id)
	if new_entity:
		print("Entities merged: Created new entity ", new_entity.name)
		
		# Create merge log
		var merge_content = "Entity Merge Log\n"
		merge_content += "===============\n"
		merge_content += "New Entity: " + new_entity.name + "\n"
		merge_content += "Type: " + AstralEntitySystem.EntityType.keys()[new_entity.type] + "\n"
		merge_content += "Stage: " + AstralEntitySystem.EvolutionStage.keys()[new_entity.evolution_stage] + "\n"
		merge_content += "Time: " + Time.get_datetime_string_from_system() + "\n"
		
		# Create merge log file
		eden_organizer.create_turn_specific_file(merge_content, new_entity.name + "_merge.txt")

func _on_entity_ascended(entity_id):
	print("Entity ascended beyond the system.")
	
	# Create ascension log
	var ascension_content = "Entity Ascension Log\n"
	ascension_content += "===================\n"
	ascension_content += "Entity ID: " + entity_id + "\n"
	ascension_content += "Time: " + Time.get_datetime_string_from_system() + "\n"
	ascension_content += "Turn: " + str(turn_cycle_manager.current_turn) + "\n"
	ascension_content += "Cycle: " + str(turn_cycle_manager.total_cycles_completed) + "\n"
	
	# Create ascension log file
	eden_organizer.create_turn_specific_file(ascension_content, "ascension_event.txt")

func _on_directory_cleaned(path, files_processed):
	print("Directory cleaned: ", path, " (", files_processed, " files processed)")

func _on_file_categorized(file_path, category):
	print("File categorized: ", file_path, " -> ", category)

func _on_dimensional_scan_completed(dimension, results):
	print("Dimension ", dimension, " scan completed. ", results.files.size(), " files found.")
	
	# Create scan report
	var scan_content = "Dimension " + str(dimension) + " Scan Report\n"
	scan_content += "=============================\n"
	scan_content += "Name: " + results.name + "\n"
	scan_content += "Color: " + DimensionalColorSystem.DimColor.keys()[results.color] + "\n"
	scan_content += "Files Found: " + str(results.files.size()) + "\n"
	scan_content += "Entities Created: " + str(results.entities.size()) + "\n"
	scan_content += "Time: " + Time.get_datetime_string_from_system() + "\n"
	
	# Add file listing
	scan_content += "\nFiles:\n"
	for file_info in results.files:
		scan_content += "- " + file_info.name + "\n"
	
	# Create scan report file
	eden_organizer.create_turn_specific_file(scan_content, "dimension" + str(dimension) + "_scan.txt")

func _on_shape_transcended(shape_id, from_dimension, to_dimension):
	if shape_system.shapes.has(shape_id):
		var shape = shape_system.shapes[shape_id]
		print("Shape transcended: ", shape_id, " from dimension ", from_dimension, " to ", to_dimension)
		
		# Create transcendence log
		var transcend_content = "Shape Transcendence Log\n"
		transcend_content += "=====================\n"
		transcend_content += "Shape ID: " + shape_id + "\n"
		transcend_content += "Shape Type: " + ShapeSystem.ShapeType.keys()[shape.type] + "\n"
		transcend_content += "From Dimension: " + str(from_dimension) + "\n"
		transcend_content += "To Dimension: " + str(to_dimension) + "\n"
		transcend_content += "Time: " + Time.get_datetime_string_from_system() + "\n"
		
		# Create transcendence log file
		eden_organizer.create_turn_specific_file(transcend_content, "shape_transcendence.txt")

func _on_shape_attuned(shape_id, color_enum):
	if shape_system.shapes.has(shape_id):
		var shape = shape_system.shapes[shape_id]
		print("Shape attuned: ", shape_id, " to color ", DimensionalColorSystem.DimColor.keys()[color_enum])

func _on_zone_evolved(zone_id, new_properties):
	if shape_system.zones.has(zone_id):
		var zone = shape_system.zones[zone_id]
		print("Zone evolved: ", zone.name, " with new properties")
		
		# Create zone evolution log
		var evolution_content = "Zone Evolution Log\n"
		evolution_content += "=================\n"
		evolution_content += "Zone: " + zone.name + "\n"
		evolution_content += "Dimension: " + str(zone.dimension) + "\n"
		evolution_content += "New Properties:\n"
		
		for key in new_properties:
			evolution_content += "- " + key + ": " + str(new_properties[key]) + "\n"
		
		evolution_content += "Time: " + Time.get_datetime_string_from_system() + "\n"
		
		# Create evolution log file
		eden_organizer.create_turn_specific_file(evolution_content, zone.name + "_evolution.txt")

func _on_shape_painted(shape_id, texture_id):
	if shape_system.shapes.has(shape_id) and paint_system.textures.has(texture_id):
		var shape = shape_system.shapes[shape_id]
		print("Shape painted: ", shape_id, " with texture ", texture_id)
		
		# Try to save the painted texture as a file in the appropriate dimension
		var texture = paint_system.textures[texture_id]
		var image = texture.image
		
		var file_path = "D:/Eden/Dimensions/D" + str(shape.dimension) + "_"
		
		# Map dimension number to name
		var dimension_names = {
			1: "Foundation",
			2: "Growth",
			3: "Energy",
			4: "Insight",
			5: "Force",
			6: "Vision",
			7: "Wisdom",
			8: "Transcendence",
			9: "Unity"
		}
		
		file_path += dimension_names[shape.dimension]
		file_path += "/painted_shape_" + shape_id.split("_")[1] + ".png"
		
		# Save the image
		var error = image.save_png(file_path)
		if error == OK:
			print("Saved painted texture to: ", file_path)

func _on_texture_created(texture_id, dimension):
	print("New texture created: ", texture_id, " in dimension ", dimension)
	
	# Log creation
	var log_content = "Texture Creation Log\n"
	log_content += "===================\n"
	log_content += "Texture ID: " + texture_id + "\n"
	log_content += "Dimension: " + str(dimension) + "\n"
	log_content += "Time: " + Time.get_datetime_string_from_system() + "\n"
	
	# Create log file
	eden_organizer.create_turn_specific_file(log_content, "texture_created.txt")

# Clean the entire Eden directory structure
func clean_eden_structure():
	print("Starting Eden directory cleaning process...")
	var files_processed = eden_organizer.clean_directory()
	print("Cleaning complete. ", files_processed, " files processed.")

# Scan all dimensions
func scan_all_dimensions(deep: bool = false):
	print("Starting scan of all dimensions...")
	
	for dimension in range(1, 10):
		var results = eden_organizer.scan_dimension(dimension, deep)
		print("Dimension ", dimension, " scan: ", results.files.size(), " files")
	
	print("All dimensions scanned.")

# Create test shapes for visualization testing
func create_test_shapes(count: int = 5):
	print("Creating ", count, " test shapes...")
	
	var shape_types = [
		ShapeSystem.ShapeType.SQUARE,
		ShapeSystem.ShapeType.CIRCLE,
		ShapeSystem.ShapeType.TRIANGLE,
		ShapeSystem.ShapeType.HEXAGON,
		ShapeSystem.ShapeType.STAR
	]
	
	for i in range(count):
		var shape_type = shape_types[i % shape_types.size()]
		var position = Vector2(200 + i * 50, 200 + (i % 3) * 50)
		var size = 30.0 + (i % 3) * 10.0
		var dimension = (i % 9) + 1
		
		var shape_id = shape_system.create_standard_shape(shape_type, position, size, dimension)
		print("Created shape: ", shape_id)
	
	print("Test shapes created.")

# Create test entities for system testing
func create_test_entities(count: int = 10):
	print("Creating ", count, " test entities...")
	
	var entity_types = AstralEntitySystem.EntityType.values()
	var entity_type_names = AstralEntitySystem.EntityType.keys()
	
	for i in range(count):
		var type_index = randi() % entity_types.size()
		var entity_type = entity_types[type_index]
		var entity_name = entity_type_names[type_index] + "_Test_" + str(i)
		
		var entity_id = astral_entity_system.create_entity(entity_name, entity_type)
		print("Created: ", entity_name, " (", entity_id, ")")
	
	print("Test entities created.")

# Generate a system report
func generate_system_report() -> String:
	var report = "Eden OS System Report\n"
	report += "===================\n"
	report += "Time: " + Time.get_datetime_string_from_system() + "\n"
	report += "Turn: " + str(turn_cycle_manager.current_turn) + "/12\n"
	report += "Current Color: " + turn_cycle_manager.get_current_color_name() + "\n"
	report += "Completed Cycles: " + str(turn_cycle_manager.total_cycles_completed) + "\n"
	report += "System Running: " + str(running) + "\n"
	report += "Auto-Advance: " + str(auto_advance_turns) + "\n"
	
	if auto_advance_turns:
		report += "Auto-Advance Interval: " + str(auto_advance_interval) + " seconds\n"
	
	# Entity statistics
	report += "\nEntity Statistics:\n"
	report += "-----------------\n"
	report += "Total Entities: " + str(astral_entity_system.entities.size()) + "\n"
	
	# Count entities by type
	var type_counts = {}
	for type_name in AstralEntitySystem.EntityType.keys():
		type_counts[type_name] = 0
	
	for entity_id in astral_entity_system.entities:
		var entity = astral_entity_system.entities[entity_id]
		var type_name = AstralEntitySystem.EntityType.keys()[entity.type]
		type_counts[type_name] += 1
	
	for type_name in type_counts:
		report += type_name + ": " + str(type_counts[type_name]) + "\n"
	
	# Count entities by evolution stage
	report += "\nEvolution Stages:\n"
	report += "-----------------\n"
	
	var stage_counts = {}
	for stage_name in AstralEntitySystem.EvolutionStage.keys():
		stage_counts[stage_name] = 0
	
	for entity_id in astral_entity_system.entities:
		var entity = astral_entity_system.entities[entity_id]
		var stage_name = AstralEntitySystem.EvolutionStage.keys()[entity.evolution_stage]
		stage_counts[stage_name] += 1
	
	for stage_name in stage_counts:
		report += stage_name + ": " + str(stage_counts[stage_name]) + "\n"
	
	# Shape statistics
	report += "\nShape Statistics:\n"
	report += "----------------\n"
	report += "Total Shapes: " + str(shape_system.shapes.size()) + "\n"
	report += "Total Zones: " + str(shape_system.zones.size()) + "\n"
	
	# Count shapes by dimension
	report += "\nShapes by Dimension:\n"
	
	var dim_counts = {}
	for i in range(1, 10):
		dim_counts[i] = 0
	
	for shape_id in shape_system.shapes:
		var shape = shape_system.shapes[shape_id]
		dim_counts[shape.dimension] += 1
	
	for dim in dim_counts:
		report += "Dimension " + str(dim) + ": " + str(dim_counts[dim]) + "\n"
	
	# Paint statistics
	report += "\nPaint Statistics:\n"
	report += "----------------\n"
	report += "Total Textures: " + str(paint_system.textures.size()) + "\n"
	report += "Total Strokes: " + str(paint_system.strokes.size()) + "\n"
	report += "Painted Shapes: " + str(paint_system.shape_paints.size()) + "\n"
	
	return report

# Save the system report to a file
func save_system_report():
	var report = generate_system_report()
	var report_path = eden_organizer.create_turn_specific_file(report, "system_report.txt")
	
	if report_path != "":
		print("System report saved to: " + report_path)
		return true
	
	return false

# Launch the paint UI
func launch_paint_ui(parent_node: Node):
	var paint_ui_scene = load("res://paint_ui.tscn")
	if paint_ui_scene:
		var paint_ui_instance = paint_ui_scene.instantiate()
		parent_node.add_child(paint_ui_instance)
		return paint_ui_instance
	return null

# Launch the shape system UI
func launch_shape_ui(parent_node: Node):
	var shape_ui_scene = load("res://shape_system_ui.tscn")
	if shape_ui_scene:
		var shape_ui_instance = shape_ui_scene.instantiate()
		parent_node.add_child(shape_ui_instance)
		return shape_ui_instance
	return null

# Launch the letter paint UI
func launch_letter_paint_ui(parent_node: Node):
	var letter_ui_scene = load("res://letter_paint_ui.tscn")
	if letter_ui_scene:
		var letter_ui_instance = letter_ui_scene.instantiate()
		parent_node.add_child(letter_ui_instance)
		return letter_ui_instance
	return null

# Letter painting handlers
func _on_letter_painted(letter, dimension, power):
	print("Letter painted: ", letter, " in dimension ", dimension, " with power ", power)

	# Log the letter painting
	var log_content = "Letter Painted: " + letter + "\n"
	log_content += "Dimension: " + str(dimension) + "\n"
	log_content += "Power: " + str(power) + "\n"
	log_content += "Time: " + Time.get_datetime_string_from_system() + "\n"

	eden_organizer.create_turn_specific_file(log_content, "letter_" + letter + ".txt")

	# Create an entity for significant letters (high power)
	if power > 2.0 and astral_entity_system:
		var entity_name = "Letter_" + letter
		var entity_type = AstralEntitySystem.EntityType.WORD

		var entity_id = astral_entity_system.create_entity(entity_name, entity_type)
		var entity = astral_entity_system.get_entity(entity_id)

		if entity:
			# Set dimensional presence
			entity.dimensional_presence.add_dimension(dimension, 1.0)

			# Set properties
			entity.properties["letter"] = letter
			entity.properties["power"] = power

func _on_glyph_recognized(glyph_data):
	print("Glyph recognized: ", glyph_data.character, " with confidence ", glyph_data.confidence)

func _on_mind_updated(update_type, strength):
	var type_name = letter_paint_system.MindUpdateType.keys()[update_type]
	print("Mind updated: ", type_name, " with strength ", strength)

	# Log the mind update
	var log_content = "Mind Update: " + type_name + "\n"
	log_content += "Strength: " + str(strength) + "\n"
	log_content += "Time: " + Time.get_datetime_string_from_system() + "\n"

	eden_organizer.create_turn_specific_file(log_content, "mind_update_" + type_name + ".txt")