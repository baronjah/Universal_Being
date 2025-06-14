extends Node3D

# ----- AKASHIC NOTEPAD TEST MAIN -----
# Main test script that integrates all components and provides testing functionality

# ----- COMPONENT REFERENCES -----
var spatial_storage: Node
var akashic_controller
var integration: Node
var visualizer: Node
var eden_bridge: Node
var ui_elements = {}

# ----- TEST STATE -----
var test_running = false
var current_test_step = 0
var test_results = []

# ----- INITIALIZATION -----
func _ready():
	print("Akashic Notepad Test Main starting...")
	
	# Get component references
	spatial_storage = $SpatialWorldStorage
	akashic_controller = $AkashicController
	integration = $Integration
	visualizer = $VisualizationContainer/Notepad3DVisualizer
	eden_bridge = $EdenPitopiaBridge
	
	# Get UI references
	ui_elements.dimension_label = $UI/DimensionLabel
	ui_elements.status_label = $UI/StatusLabel
	ui_elements.test_button = $UI/TestButton
	ui_elements.help_text = $UI/HelpText
	
	# Connect UI signals
	ui_elements.test_button.connect("pressed", self, "_on_test_button_pressed")
	
	# Wait a frame then initialize components
	yield(get_tree(), "idle_frame")
	initialize_components()

func initialize_components():
	print("Initializing components...")
	
	# Connect akashic controller to storage and visualizer
	if akashic_controller.has_method("set_visualizer"):
		var success = akashic_controller.set_visualizer(visualizer)
		print("Akashic controller connected to visualizer: %s" % success)
	
	# Connect integration to storage and visualizer
	if integration.has_method("connect_components"):
		var success = integration.connect_components(spatial_storage, visualizer)
		print("Integration connected components: %s" % success)
	
	# Connect akashic controller signals
	if akashic_controller.has_signal("record_created"):
		akashic_controller.connect("record_created", _on_record_created)
	if akashic_controller.has_signal("notebook_created"):
		akashic_controller.connect("notebook_created", _on_notebook_created)
	
	# Connect visualizer signals
	if visualizer.has_signal("word_selected"):
		visualizer.connect("word_selected", _on_word_selected)
	if visualizer.has_signal("visualization_ready"):
		visualizer.connect("visualization_ready", _on_visualization_ready)
	
	# Initialize Eden bridge
	if eden_bridge:
		if eden_bridge.has_signal("bridge_connected"):
			eden_bridge.connect("bridge_connected", _on_eden_bridge_connected)
		if eden_bridge.has_signal("eden_integration_found"):
			eden_bridge.connect("eden_integration_found", _on_eden_integration_found)
		
		# Enhance test project with Eden capabilities
		if eden_bridge.has_method("enhance_test_project"):
			eden_bridge.enhance_test_project()
	
	print("Components initialized successfully")
	update_status_display()

# ----- TEST FUNCTIONS -----
func _on_test_button_pressed():
	if test_running:
		print("Test already running...")
		return
	
	print("Starting integration test...")
	test_running = true
	current_test_step = 0
	test_results.clear()
	
	ui_elements.test_button.text = "Testing..."
	ui_elements.test_button.disabled = true
	
	run_next_test_step()

func run_next_test_step():
	current_test_step += 1
	
	match current_test_step:
		1:
			test_create_akashic_entries()
		2:
			test_create_notepad()
		3:
			test_visualize_akashic_records()
		4:
			test_create_connections()
		5:
			test_notepad_integration()
		_:
			complete_tests()

func test_create_akashic_entries():
	print("Test Step 1: Creating akashic entries...")
	
	# Create some test entries
	var test_entries = [
		{
			"content": "The first divine word manifests in space",
			"position": Vector3(0, 1, 0),
			"dimension": 3,
			"tags": ["divine", "first", "manifestation"]
		},
		{
			"content": "Consciousness expands across dimensions",
			"position": Vector3(3, 2, 1),
			"dimension": 5,
			"tags": ["consciousness", "expansion", "dimension"]
		},
		{
			"content": "Connection bridges the gap between realities",
			"position": Vector3(-2, 1, 3),
			"dimension": 6,
			"tags": ["connection", "reality", "bridge"]
		},
		{
			"content": "Creation flows from the source of all being",
			"position": Vector3(1, 3, -2),
			"dimension": 7,
			"tags": ["creation", "source", "being"]
		}
	]
	
	var created_count = 0
	for entry_data in test_entries:
		if akashic_controller.has_method("create_akashic_entry"):
			var entry_id = akashic_controller.create_akashic_entry(
				entry_data.content,
				entry_data.position,
				entry_data.dimension,
				entry_data.tags
			)
			if entry_id:
				created_count += 1
				print("Created entry: %s" % entry_id)
	
	var success = created_count == test_entries.size()
	test_results.append({
		"step": 1,
		"name": "Create Akashic Entries",
		"success": success,
		"details": "Created %d/%d entries" % [created_count, test_entries.size()]
	})
	
	print("Test Step 1 complete: %s" % ("SUCCESS" if success else "FAILED"))
	
	# Continue to next step after a brief delay
	yield(get_tree().create_timer(1.0), "timeout")
	run_next_test_step()

func test_create_notepad():
	print("Test Step 2: Creating notepad...")
	
	var success = false
	if akashic_controller.has_method("create_notepad"):
		var notebook_name = akashic_controller.create_notepad("test_notebook", ["test", "demo"])
		success = notebook_name != ""
		
		if success:
			print("Created notepad: %s" % notebook_name)
			
			# Add some cells to the notepad
			var cells_added = 0
			var test_cells = [
				{"content": "Test cell 1", "position": Vector3(0, 0, 0)},
				{"content": "Test cell 2", "position": Vector3(1, 0, 0)},
				{"content": "Test cell 3", "position": Vector3(0, 1, 0)}
			]
			
			for cell_data in test_cells:
				if akashic_controller.has_method("add_notepad_cell"):
					var cell_id = akashic_controller.add_notepad_cell(
						notebook_name,
						cell_data.position,
						cell_data.content
					)
					if cell_id:
						cells_added += 1
			
			success = cells_added == test_cells.size()
	
	test_results.append({
		"step": 2,
		"name": "Create Notepad",
		"success": success,
		"details": "Notepad creation and cell addition"
	})
	
	print("Test Step 2 complete: %s" % ("SUCCESS" if success else "FAILED"))
	
	yield(get_tree().create_timer(1.0), "timeout")
	run_next_test_step()

func test_visualize_akashic_records():
	print("Test Step 3: Visualizing akashic records...")
	
	var success = false
	if akashic_controller.has_method("visualize_akashic_record"):
		success = akashic_controller.visualize_akashic_record(3, 10)  # Dimension 3, limit 10
		
		if success:
			print("Akashic records visualization started")
		else:
			print("Failed to start akashic records visualization")
	
	test_results.append({
		"step": 3,
		"name": "Visualize Akashic Records",
		"success": success,
		"details": "3D visualization of akashic entries"
	})
	
	print("Test Step 3 complete: %s" % ("SUCCESS" if success else "FAILED"))
	
	yield(get_tree().create_timer(2.0), "timeout")  # Give more time for visualization
	run_next_test_step()

func test_create_connections():
	print("Test Step 4: Creating connections...")
	
	var success = false
	
	# Get some entries to connect
	if spatial_storage.has_method("find_entries_by_dimension"):
		var entries = spatial_storage.find_entries_by_dimension(3)
		
		if entries.size() >= 2:
			var entry1 = entries[0]
			var entry2 = entries[1]
			
			if akashic_controller.has_method("connect_akashic_entries"):
				success = akashic_controller.connect_akashic_entries(entry1.entry_id, entry2.entry_id)
				
				if success:
					print("Connected entries: %s <-> %s" % [entry1.entry_id, entry2.entry_id])
	
	test_results.append({
		"step": 4,
		"name": "Create Connections",
		"success": success,
		"details": "Connection between akashic entries"
	})
	
	print("Test Step 4 complete: %s" % ("SUCCESS" if success else "FAILED"))
	
	yield(get_tree().create_timer(1.0), "timeout")
	run_next_test_step()

func test_notepad_integration():
	print("Test Step 5: Testing notepad integration...")
	
	var success = false
	if akashic_controller.has_method("visualize_notepad"):
		success = akashic_controller.visualize_notepad("test_notebook")
		
		if success:
			print("Notepad visualization started")
		else:
			print("Failed to start notepad visualization")
	
	test_results.append({
		"step": 5,
		"name": "Notepad Integration",
		"success": success,
		"details": "3D visualization of notepad cells"
	})
	
	print("Test Step 5 complete: %s" % ("SUCCESS" if success else "FAILED"))
	
	yield(get_tree().create_timer(2.0), "timeout")
	run_next_test_step()

func complete_tests():
	print("All tests complete!")
	
	# Calculate results
	var total_tests = test_results.size()
	var passed_tests = 0
	
	for result in test_results:
		if result.success:
			passed_tests += 1
		print("Test %d (%s): %s - %s" % [
			result.step,
			result.name,
			"PASS" if result.success else "FAIL",
			result.details
		])
	
	print("Test Results: %d/%d tests passed" % [passed_tests, total_tests])
	
	# Update UI
	ui_elements.test_button.text = "Test Complete (%d/%d)" % [passed_tests, total_tests]
	ui_elements.test_button.disabled = false
	
	test_running = false
	update_status_display()

# ----- EVENT HANDLERS -----
func _on_record_created(entry_id):
	print("Record created: %s" % entry_id)
	update_status_display()

func _on_notebook_created(notebook_name):
	print("Notebook created: %s" % notebook_name)
	update_status_display()

func _on_word_selected(word_data):
	print("Word selected: %s" % word_data.text)

func _on_visualization_ready():
	print("Visualization ready")

func _on_eden_bridge_connected():
	print("Eden bridge connected successfully!")
	
	# Update UI to show Eden integration status
	var integration_summary = eden_bridge.get_integration_summary()
	print("Eden Integration Summary: " + str(integration_summary))
	
	# Update status display with Eden info
	update_status_display()

func _on_eden_integration_found(path):
	print("Eden integration found at: " + path)

# ----- UTILITY FUNCTIONS -----
func update_status_display():
	if not ui_elements.has("status_label"):
		return
	
	var akashic_count = 0
	var notepad_count = 0
	
	if spatial_storage:
		akashic_count = spatial_storage.akashic_records.size()
		
		var total_cells = 0
		for notebook_name in spatial_storage.notepad_notebooks:
			var notebook = spatial_storage.notepad_notebooks[notebook_name]
			total_cells += notebook.cells.size()
		notepad_count = total_cells
	
	ui_elements.status_label.text = "Akashic Records: %d | Notepad Cells: %d" % [akashic_count, notepad_count]

# ----- INPUT HANDLING -----
func _input(event):
	# Handle special test commands
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_T:
				if not test_running:
					_on_test_button_pressed()
			KEY_C:
				clear_all_data()
			KEY_V:
				toggle_visualization_mode()
			KEY_E:
				if eden_bridge:
					show_eden_status()

func clear_all_data():
	print("Clearing all test data...")
	
	if spatial_storage:
		spatial_storage.akashic_records.clear()
		spatial_storage.notepad_notebooks.clear()
		spatial_storage.spatial_maps.clear()
	
	update_status_display()
	print("Data cleared")

func toggle_visualization_mode():
	print("Toggling visualization mode...")
	
	# Switch between akashic and notepad visualization
	if akashic_controller.has_method("visualize_akashic_record"):
		akashic_controller.visualize_akashic_record(3, 10)

func show_eden_status():
	print("Showing Eden integration status...")
	
	if eden_bridge and eden_bridge.has_method("process_eden_command"):
		var result = eden_bridge.process_eden_command("/eden-status")
		if result.success:
			print(result.message)
		else:
			print("Failed to get Eden status: " + result.message)
	else:
		print("Eden bridge not available")

# ----- PROCESS -----
func _process(delta):
	# Update status periodically
	if Engine.get_idle_frames() % 60 == 0:  # Every 60 frames (~1 second)
		update_status_display()
