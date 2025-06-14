extends Node

# Akashic Notepad Controller
# Integrates SpatialWorldStorage and Notepad3D system with main game controller
# Handles 3D visualization and storage of akashic records and notepad entries
# Creates bridge between word manifestation and spatial data systems

# ----- CONSTANTS -----
const DEFAULT_NOTEBOOK_NAME = "divine_notepad"
const AKASHIC_DATABASE_NAME = "akashic_record"
const SACRED_DIMENSION = 9  # 9th dimension - Harmony dimension
const MAX_VISUALIZED_ENTRIES = 100

# ----- COMPONENT REFERENCES -----
var spatial_storage: SpatialWorldStorage
var spatial_visualizer: Notepad3DVisualizer
var integration: SpatialNotepadIntegration
var main_controller = null
var word_manifestation_system = null

# ----- STATE VARIABLES -----
var active_notebook = ""
var active_dimension = 3
var current_visualized_entries = []
var auto_save_timer = 0
var initialized = false
var auto_process_entries = true
var last_note_position = Vector3.ZERO
var sacred_interval_counter = 0

# ----- SIGNALS -----
signal record_created(entry_id)
signal notebook_created(notebook_name)
signal akashic_synergy_detected(entries)
signal dimension_power_calculated(dimension, power)

# ----- INITIALIZATION -----
func _ready():
	print("Akashic Notepad Controller initializing...")
	
	# Create storage system
	spatial_storage = SpatialWorldStorage.new()
	add_child(spatial_storage)
	
	# Initialize with default notebook if needed
	_initialize_default_notebook()
	
	# Connect to signals from storage
	spatial_storage.connect("entry_added", self, "_on_entry_added")
	spatial_storage.connect("notebook_updated", self, "_on_notebook_updated")
	
	# Note: The visualizer will be connected when set_visualizer is called
	
	print("Akashic Notepad Controller initialized")
	initialized = true

# ----- PROCESS FUNCTION -----
func _process(delta):
	if not initialized:
		return
	
	# Auto-save timer
	auto_save_timer += delta
	if auto_save_timer >= 60.0:  # Save every minute
		auto_save_timer = 0
		save_all_data()
	
	# Handle automatic entry processing
	if auto_process_entries and main_controller:
		sacred_interval_counter += delta
		if sacred_interval_counter >= 9.0:  # Sacred 9-second interval
			sacred_interval_counter = 0
			process_new_entries()

# ----- SETUP FUNCTIONS -----
func set_main_controller(controller):
	main_controller = controller
	
	if controller:
		# Connect to main controller signals
		controller.connect("note_created", self, "_on_note_created")
		controller.connect("turn_advanced", self, "_on_turn_advanced")
		controller.connect("word_manifested", self, "_on_word_manifested")
		
		print("Connected to main controller")
		return true
	return false

func set_visualizer(visualizer):
	spatial_visualizer = visualizer
	
	if visualizer:
		# Create integration system
		integration = SpatialNotepadIntegration.new()
		add_child(integration)
		
		# Connect components
		integration.connect_components(spatial_storage, visualizer)
		
		# Connect to integration signals
		integration.connect("cell_created", self, "_on_cell_created")
		integration.connect("entry_visualized", self, "_on_entry_visualized")
		
		print("Connected to visualizer via integration system")
		return true
	return false

func set_word_manifestation_system(system):
	word_manifestation_system = system
	
	if system and spatial_visualizer:
		# Connect manifestation system to visualizer
		spatial_visualizer.set_word_manifestation_system(system)
		
		print("Connected word manifestation system to visualizer")
		return true
	return false

# ----- AKASHIC RECORD FUNCTIONS -----
func create_akashic_entry(content, position, dimension = 0, tags = []):
	if not spatial_storage:
		return null
	
	# Default to current dimension if not specified
	if dimension == 0 and main_controller:
		dimension = main_controller.current_turn
	elif dimension == 0:
		dimension = active_dimension
	
	# Calculate power based on word processor if available
	var power = 50.0  # Default power
	var author = "system"
	
	if main_controller and main_controller.word_processor:
		var result = main_controller.word_processor.process_text(content, "akashic", 2)
		power = result.total_power
		author = "divine"
	
	# Create dimensional point for position
	var coord = spatial_storage.Coordinate.new(position.x, position.y, position.z)
	var dim_point = spatial_storage.DimensionalPoint.new(coord, dimension, power)
	
	# Add entry
	var entry_id = spatial_storage.add_akashic_entry(dim_point, content, author, tags)
	
	print("Created akashic entry with ID: %s (Power: %.1f)" % [entry_id, power])
	emit_signal("record_created", entry_id)
	
	# Automatically visualize if entries are being displayed
	if not current_visualized_entries.empty() and integration:
		visualize_akashic_record()
	
	return entry_id

func get_akashic_entry(entry_id):
	if not spatial_storage:
		return null
	
	return spatial_storage.get_akashic_entry(entry_id)

func find_entries_by_tag(tag):
	if not spatial_storage:
		return []
	
	return spatial_storage.find_entries_by_tag(tag)

func find_entries_by_dimension(dimension):
	if not spatial_storage:
		return []
	
	return spatial_storage.find_entries_by_dimension(dimension)

func connect_akashic_entries(source_id, target_id):
	if not spatial_storage:
		return false
	
	return spatial_storage.connect_entries(source_id, target_id)

func visualize_akashic_record(dimension = 0, limit = MAX_VISUALIZED_ENTRIES):
	if not spatial_storage or not integration:
		return false
	
	# Default to current dimension if not specified
	if dimension == 0 and main_controller:
		dimension = main_controller.current_turn
	elif dimension == 0:
		dimension = active_dimension
	
	# Find entries for this dimension
	var entries = spatial_storage.find_entries_by_dimension(dimension)
	
	# Sort by power (highest first)
	entries.sort_custom(self, "_sort_entries_by_power")
	
	# Limit number of entries
	if entries.size() > limit:
		entries = entries.slice(0, limit - 1)
	
	# Get entry IDs
	var entry_ids = []
	for entry in entries:
		entry_ids.append(entry.entry_id)
	
	# Store current visualization
	current_visualized_entries = entry_ids
	
	# Visualize
	var result = integration.visualize_akashic_entries(entry_ids)
	
	if result:
		print("Visualizing %d akashic entries for dimension %d" % [entry_ids.size(), dimension])
	
	return result

func create_notebook_from_akashic(dimension, notebook_name = ""):
	if not spatial_storage:
		return false
	
	# Generate name if not provided
	if notebook_name.empty():
		notebook_name = "dimension_%d_notebook" % dimension
	
	# Find entries for this dimension
	var entries = spatial_storage.find_entries_by_dimension(dimension)
	
	# Get entry IDs
	var entry_ids = []
	for entry in entries:
		entry_ids.append(entry.entry_id)
	
	# Create notebook
	var result = spatial_storage.create_notepad_from_akashic(entry_ids, notebook_name)
	
	if result:
		print("Created notebook '%s' from %d akashic entries" % [notebook_name, entry_ids.size()])
		emit_signal("notebook_created", notebook_name)
	
	return result

# ----- NOTEPAD FUNCTIONS -----
func create_notepad(name, tags = []):
	if not spatial_storage:
		return false
	
	var notebook_name = spatial_storage.create_notepad(name, tags)
	
	if notebook_name:
		print("Created notepad: %s" % notebook_name)
		emit_signal("notebook_created", notebook_name)
	
	return notebook_name

func add_notepad_cell(notebook_name, position, content, color = Color.white):
	if not spatial_storage:
		return null
	
	var cell_id = spatial_storage.add_cell_to_notepad(notebook_name, position, content, color)
	
	if cell_id:
		# Automatically display if this notebook is active
		if notebook_name == active_notebook and integration:
			integration.update_cell_visualization(notebook_name, cell_id)
	
	return cell_id

func visualize_notepad(notebook_name):
	if not integration:
		return false
	
	active_notebook = notebook_name
	current_visualized_entries = []  # Clear akashic entries
	
	var result = integration.visualize_notebook(notebook_name)
	
	if result:
		print("Visualizing notepad: %s" % notebook_name)
	
	return result

# ----- UTILITY FUNCTIONS -----
func _initialize_default_notebook():
	if not spatial_storage:
		return
	
	// Check if default notebook exists
	if spatial_storage.get_notepad(DEFAULT_NOTEBOOK_NAME) == null:
		// Create default notebook
		spatial_storage.create_notepad(DEFAULT_NOTEBOOK_NAME, ["default", "system"])
		print("Created default notebook: %s" % DEFAULT_NOTEBOOK_NAME)

func save_all_data():
	if not spatial_storage:
		return
	
	spatial_storage.save_akashic_records()
	spatial_storage.save_notepad_notebooks()
	spatial_storage.save_spatial_maps()
	
	print("Saved all spatial data")

func process_new_entries():
	if not spatial_storage or not main_controller:
		return
	
	# Process any new notes into akashic entries
	var notes = main_controller.get_notes_for_current_turn()
	
	for note_id in notes:
		var note = notes[note_id]
		
		# Skip notes that are already processed
		if note.get("processed", false):
			continue
		
		# Create akashic entry from note
		if note.power > 30:  # Only process significant notes
			# Generate position
			var position = note.position
			if position == Vector3.ZERO:
				# Create spiral pattern for notes
				position = _generate_spiral_position()
				last_note_position = position
			
			# Extract tags from note content
			var tags = _extract_tags_from_text(note.text)
			
			# Create entry
			create_akashic_entry(note.text, position, note.turn, tags)
			
			# Mark as processed
			note.processed = true
	
	# Find synergies
	_check_for_synergies()

func _check_for_synergies():
	if not spatial_storage:
		return
	
	var synergies = spatial_storage.find_spatial_synergies(10.0)  # High threshold
	
	if synergies.size() > 0:
		print("Found %d akashic synergies" % synergies.size())
		emit_signal("akashic_synergy_detected", synergies)
		
		# If in sacred dimension, synergies have special effects
		if main_controller and main_controller.current_turn == SACRED_DIMENSION:
			_process_sacred_synergies(synergies)

func _process_sacred_synergies(synergies):
	if not spatial_storage or not main_controller:
		return
	
	var total_power = 0
	
	for synergy in synergies:
		total_power += synergy.strength
		
		// Connect entries if not already connected
		spatial_storage.connect_entries(synergy.entry_a, synergy.entry_b)
	
	// Calculate dimension power
	var dimension_power = total_power * main_controller.current_turn
	
	print("Sacred synergies detected with total power: %f" % dimension_power)
	emit_signal("dimension_power_calculated", main_controller.current_turn, dimension_power)
	
	// Create special entry to mark the synergy
	var synergy_position = Vector3(0, total_power / 10.0, 0)
	create_akashic_entry(
		"Dimensional synergy detected in the Harmony dimension with power: " + str(dimension_power),
		synergy_position,
		SACRED_DIMENSION,
		["synergy", "harmony", "sacred"]
	)

func _extract_tags_from_text(text):
	var tags = []
	
	// Look for hashtags in text
	var regex = RegEx.new()
	regex.compile("#\\w+")
	var results = regex.search_all(text)
	
	for result in results:
		var tag = result.get_string().substr(1)  // Remove # symbol
		if not tag in tags:
			tags.append(tag)
	
	// If no tags found, add some based on content
	if tags.empty():
		// Add dimension tag
		if main_controller:
			tags.append("dim" + str(main_controller.current_turn))
		
		// Check for keywords
		var keywords = ["reality", "akashic", "divine", "word", "notepad", "dimension", "sacred"]
		for keyword in keywords:
			if text.to_lower().find(keyword) >= 0:
				tags.append(keyword)
				break
	
	return tags

func _generate_spiral_position():
	// Generate a position in a spiral pattern
	var angle = last_note_position.length() * 0.5
	var radius = 5.0 + (last_note_position.length() * 0.1)
	var height = last_note_position.y + 0.5
	
	if height > 20:
		height = 0
	
	return Vector3(
		sin(angle) * radius,
		height,
		cos(angle) * radius
	)

func _sort_entries_by_power(a, b):
	// Sort in descending order of power
	return a.position.power > b.position.power

# ----- EVENT HANDLERS -----
func _on_note_created(note_data):
	if auto_process_entries:
		process_new_entries()

func _on_turn_advanced(turn_number, symbol, dimension):
	active_dimension = turn_number
	
	// Visualize akashic records for new dimension
	if not current_visualized_entries.empty():
		visualize_akashic_record(turn_number)

func _on_word_manifested(word, position, power):
	// Create akashic entry for significant manifestations
	if power > 75:
		create_akashic_entry(
			"The word '" + word + "' manifested with divine power", 
			position, 
			active_dimension, 
			["manifested", "word", "divine"]
		)

func _on_entry_added(entry_id):
	// Check for synergies when new entries are added
	if auto_process_entries:
		_check_for_synergies()

func _on_notebook_updated(notebook_name):
	// Update visualization if this is the active notebook
	if notebook_name == active_notebook and integration:
		integration.visualize_notebook(notebook_name)

func _on_cell_created(notebook_name, cell_id):
	print("Cell created in notebook %s: %s" % [notebook_name, cell_id])

func _on_entry_visualized(entry_id):
	print("Akashic entry visualized: %s" % entry_id)

# ----- COMMAND PROCESSING -----
func process_command(command, args):
	match command:
		"akashic":
			return _process_akashic_command(args)
		
		"notepad", "notebook":
			return _process_notepad_command(args)
		
		"visualize":
			return _process_visualize_command(args)
		
		"3d":
			return _process_3d_command(args)
			
		_:
			return "Unknown command: " + command

func _process_akashic_command(args):
	if args.empty():
		return "Usage: akashic [create|list|find|connect|synergy]"
	
	match args[0]:
		"create":
			if args.size() < 2:
				return "Usage: akashic create <content> [dimension] [tag1,tag2,...]"
			
			var content = args[1]
			var dimension = 0
			var tags = []
			
			if args.size() > 2 and args[2].is_valid_integer():
				dimension = int(args[2])
			
			if args.size() > 3:
				tags = args[3].split(",")
			
			var position = _generate_spiral_position()
			var entry_id = create_akashic_entry(content, position, dimension, tags)
			
			if entry_id:
				return "Created akashic entry: " + entry_id
			else:
				return "Failed to create entry"
		
		"list":
			var dimension = 0
			if args.size() > 1 and args[1].is_valid_integer():
				dimension = int(args[1])
			
			var entries = find_entries_by_dimension(dimension)
			return "Found %d entries in dimension %d" % [entries.size(), dimension]
		
		"find":
			if args.size() < 2:
				return "Usage: akashic find <tag>"
			
			var tag = args[1]
			var entries = find_entries_by_tag(tag)
			return "Found %d entries with tag '%s'" % [entries.size(), tag]
		
		"connect":
			if args.size() < 3:
				return "Usage: akashic connect <source_id> <target_id>"
			
			var source = args[1]
			var target = args[2]
			
			if connect_akashic_entries(source, target):
				return "Connected entries: %s -> %s" % [source, target]
			else:
				return "Failed to connect entries"
		
		"synergy":
			var threshold = 5.0
			if args.size() > 1 and args[1].is_valid_float():
				threshold = float(args[1])
			
			var synergies = spatial_storage.find_spatial_synergies(threshold)
			return "Found %d synergies with threshold %.1f" % [synergies.size(), threshold]
		
		_:
			return "Unknown akashic subcommand: " + args[0]

func _process_notepad_command(args):
	if args.empty():
		return "Usage: notepad [create|add|visualize|list]"
	
	match args[0]:
		"create":
			if args.size() < 2:
				return "Usage: notepad create <name> [tag1,tag2,...]"
			
			var name = args[1]
			var tags = []
			
			if args.size() > 2:
				tags = args[2].split(",")
			
			var result = create_notepad(name, tags)
			
			if result:
				return "Created notepad: " + name
			else:
				return "Failed to create notepad"
		
		"add":
			if args.size() < 3:
				return "Usage: notepad add <notebook_name> <content> [x,y,z]"
			
			var notebook = args[1]
			var content = args[2]
			var position = Vector3.ZERO
			
			if args.size() > 3:
				var pos_parts = args[3].split(",")
				if pos_parts.size() >= 3:
					position = Vector3(
						float(pos_parts[0]),
						float(pos_parts[1]),
						float(pos_parts[2])
					)
			
			var cell_id = add_notepad_cell(notebook, position, content)
			
			if cell_id:
				return "Added cell to notebook: " + cell_id
			else:
				return "Failed to add cell"
		
		"visualize":
			if args.size() < 2:
				return "Usage: notepad visualize <notebook_name>"
			
			var notebook = args[1]
			
			if visualize_notepad(notebook):
				return "Visualizing notebook: " + notebook
			else:
				return "Failed to visualize notebook"
		
		"list":
			if not spatial_storage:
				return "Storage system not available"
			
			var notebooks = spatial_storage.notepad_notebooks
			
			if notebooks.empty():
				return "No notebooks found"
			
			var result = "Notebooks:\n"
			for name in notebooks:
				var notebook = notebooks[name]
				result += "- %s: %d cells\n" % [name, notebook.cells.size()]
			
			return result
		
		"convert":
			if args.size() < 3:
				return "Usage: notepad convert <dimension> <notebook_name>"
			
			var dimension = int(args[1])
			var notebook = args[2]
			
			if create_notebook_from_akashic(dimension, notebook):
				return "Created notebook '%s' from dimension %d entries" % [notebook, dimension]
			else:
				return "Failed to create notebook from akashic entries"
		
		_:
			return "Unknown notepad subcommand: " + args[0]

func _process_visualize_command(args):
	if args.empty():
		return "Usage: visualize [akashic|notepad|clear]"
	
	match args[0]:
		"akashic":
			var dimension = 0
			
			if args.size() > 1 and args[1].is_valid_integer():
				dimension = int(args[1])
			
			if visualize_akashic_record(dimension):
				return "Visualizing akashic record for dimension " + str(dimension)
			else:
				return "Failed to visualize akashic record"
		
		"notepad":
			if args.size() < 2:
				return "Usage: visualize notepad <notebook_name>"
			
			var notebook = args[1]
			
			if visualize_notepad(notebook):
				return "Visualizing notebook: " + notebook
			else:
				return "Failed to visualize notebook"
		
		"clear":
			if integration:
				integration.clear_visualizations()
				current_visualized_entries = []
				active_notebook = ""
				return "Cleared all visualizations"
			return "Integration system not available"
		
		_:
			return "Unknown visualize subcommand: " + args[0]

func _process_3d_command(args):
	if args.empty():
		return "Usage: 3d [save|load|auto]"
	
	match args[0]:
		"save":
			save_all_data()
			return "Saved all 3D data"
		
		"load":
			if spatial_storage:
				spatial_storage.load_all_data()
				return "Loaded all 3D data"
			return "Storage system not available"
		
		"auto":
			if args.size() > 1 and (args[1] == "on" or args[1] == "off"):
				auto_process_entries = (args[1] == "on")
				return "Auto process entries: " + args[1]
			return "Usage: 3d auto [on|off]"
		
		_:
			return "Unknown 3d subcommand: " + args[0]
