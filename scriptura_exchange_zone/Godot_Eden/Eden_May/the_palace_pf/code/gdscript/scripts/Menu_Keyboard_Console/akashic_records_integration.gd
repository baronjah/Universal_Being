extends Node
class_name AkashicRecordsIntegration

# References
var main_console = null
var akashic_records_manager = null
var akashic_records_ui_scene = null
var current_ui_instance = null

# Initialization
func initialize(p_main_console) -> void:
	main_console = p_main_console
	
	# Load the Akashic Records UI scene
	akashic_records_ui_scene = load("res://code/gdscript/scenes/akashic_records_ui.tscn")
	
	# Get or create AkashicRecordsManager
	_ensure_akashic_records_manager()
	
	# Register with main console
	_register_with_console()
	
	print("Akashic Records Integration initialized")

func _ensure_akashic_records_manager() -> void:
	# Try to get existing manager
	akashic_records_manager = AkashicRecordsManager.get_instance()
	
	if not akashic_records_manager:
		# Create new manager if one doesn't exist
		var akashic_records_manager_script = load("res://code/gdscript/scripts/akashic_records/akashic_records_manager.gd")
		if akashic_records_manager_script:
			akashic_records_manager = akashic_records_manager_script.new()
			akashic_records_manager.name = "AkashicRecordsManager"
			
			# Add to root so it persists across scenes
			var root = get_tree().root
			root.call_deferred("add_child", akashic_records_manager)
			
			print("Created new AkashicRecordsManager")
		else:
			push_error("Could not load AkashicRecordsManager script")

func _register_with_console() -> void:
	if main_console:
		# Register as a system with the main console
		main_console.register_system(self, "AkashicRecords")
		
		# Add menu entries for the Akashic Records
		_add_menu_entries()

func _add_menu_entries() -> void:
	# Create the Akashic Records entry for the "Things" menu
	var records_entry = {
		"title": "Akashic Records",
		"description": "Access the dynamic dictionary system",
		"callback": Callable(self, "open_akashic_records_ui"),
		"icon": "database"  # Choose an appropriate icon
	}
	
	main_console.add_menu_entry("things", records_entry)
	
	# Create entries for specific sections
	var words_entry = {
		"title": "Dictionary Words",
		"description": "Browse and manage dictionary entries",
		"callback": Callable(self, "open_words_section"),
		"icon": "list"
	}
	
	var interactions_entry = {
		"title": "Word Interactions",
		"description": "Define and test interactions between words",
		"callback": Callable(self, "open_interactions_section"),
		"icon": "arrows-left-right"
	}
	
	var evolution_entry = {
		"title": "Evolution System",
		"description": "Configure and monitor word evolution",
		"callback": Callable(self, "open_evolution_section"),
		"icon": "clock-rotate-left"
	}
	
	var visualization_entry = {
		"title": "Visualization",
		"description": "View word relationships in 3D space",
		"callback": Callable(self, "open_visualization_section"),
		"icon": "chart-simple"
	}
	
	main_console.add_menu_entry("things", words_entry)
	main_console.add_menu_entry("things", interactions_entry)
	main_console.add_menu_entry("things", evolution_entry)
	main_console.add_menu_entry("things", visualization_entry)

# UI Open Handlers
func open_akashic_records_ui() -> void:
	if not akashic_records_ui_scene:
		main_console.show_message("Error: Akashic Records UI scene not found")
		return
	
	# Close existing UI if open
	_close_current_ui()
	
	# Instance the UI
	current_ui_instance = akashic_records_ui_scene.instantiate()
	
	# Add to main console view area
	main_console.add_to_view_area(current_ui_instance)
	
	main_console.show_message("Akashic Records UI opened")

func open_words_section() -> void:
	# Open the main UI and navigate to words section
	open_akashic_records_ui()
	
	# Configure UI to show words section
	if current_ui_instance:
		# Show words section
		# This would depend on your UI implementation
		pass

func open_interactions_section() -> void:
	# Open the main UI and navigate to interactions section
	open_akashic_records_ui()
	
	# Configure UI to show interactions section
	if current_ui_instance:
		# Show interactions section
		# This would depend on your UI implementation
		pass

func open_evolution_section() -> void:
	# Open the main UI and navigate to evolution section
	open_akashic_records_ui()
	
	# Configure UI to show evolution section
	if current_ui_instance:
		# Show evolution section
		# This would depend on your UI implementation
		pass

func open_visualization_section() -> void:
	# Open the main UI and navigate to visualization section
	open_akashic_records_ui()
	
	# Configure UI to show visualization section
	if current_ui_instance:
		# Show visualization section
		# This would depend on your UI implementation
		pass

func _close_current_ui() -> void:
	if current_ui_instance and is_instance_valid(current_ui_instance):
		current_ui_instance.queue_free()
		current_ui_instance = null

# Public API

func get_akashic_records_manager() -> AkashicRecordsManager:
	return akashic_records_manager

func create_word(id: String, category: String, properties: Dictionary = {}, parent_id: String = "") -> bool:
	if akashic_records_manager:
		return akashic_records_manager.create_word(id, category, properties, parent_id)
	return false

func process_interaction(word1_id: String, word2_id: String, context: Dictionary = {}) -> Dictionary:
	if akashic_records_manager:
		return akashic_records_manager.process_word_interaction(word1_id, word2_id, context)
	return {"success": false, "error": "Akashic Records Manager not available"}

func save_all() -> bool:
	if akashic_records_manager:
		return akashic_records_manager.save_all()
	return false

# Connection to other systems

func connect_to_element_system(element_system) -> void:
	if not akashic_records_manager:
		push_error("Cannot connect to element system: Akashic Records Manager not available")
		return
	
	# Example of connecting element system events to dictionary
	element_system.connect("element_created", Callable(self, "_on_element_created"))
	element_system.connect("element_destroyed", Callable(self, "_on_element_destroyed"))
	element_system.connect("elements_interacted", Callable(self, "_on_elements_interacted"))
	
	print("Akashic Records connected to Element System")

func _on_element_created(element_data: Dictionary) -> void:
	# Create corresponding word in dictionary
	if akashic_records_manager:
		var element_id = element_data.get("id", "")
		var element_type = element_data.get("type", "")
		var properties = element_data.get("properties", {})
		
		akashic_records_manager.create_word(element_id, "element", properties)

func _on_element_destroyed(element_id: String) -> void:
	# Could mark the word as inactive rather than removing it
	pass

func _on_elements_interacted(element1_id: String, element2_id: String, result_data: Dictionary) -> void:
	# Process corresponding interaction in dictionary
	if akashic_records_manager:
		var context = result_data.get("context", {})
		akashic_records_manager.process_word_interaction(element1_id, element2_id, context)