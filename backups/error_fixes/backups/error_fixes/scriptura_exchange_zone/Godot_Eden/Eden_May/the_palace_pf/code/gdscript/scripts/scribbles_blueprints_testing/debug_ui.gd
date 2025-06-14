extends Control
class_name AkashicDebugUI

# System references
var akashic_records: Node = null
var universal_bridge: Node = null
var records_manager: Node = null
var database_integrator: Node = null

# UI elements
var main_container: VBoxContainer = null
var entity_list: ItemList = null
var info_panel: VBoxContainer = null
var log_panel: RichTextLabel = null
var control_panel: HBoxContainer = null

# Selected entity
var selected_entity_id: String = ""

func _ready() -> void:
    # Set up UI
    _setup_ui()

func initialize(akashic_records_system: Node, bridge: Node, manager: Node, db_integrator: Node) -> void:
    akashic_records = akashic_records_system
    universal_bridge = bridge
    records_manager = manager
    database_integrator = db_integrator
    
    # Connect signals
    if akashic_records:
        akashic_records.connect("entity_created", Callable(self, "_on_entity_created"))
        akashic_records.connect("entity_transformed", Callable(self, "_on_entity_transformed"))
        akashic_records.connect("entity_interaction", Callable(self, "_on_entity_interaction"))
        akashic_records.connect("database_split", Callable(self, "_on_database_split"))
    
    # Initial refresh
    refresh_ui()
    
    print("DebugUI: Initialized with system references")

func _setup_ui() -> void:
    # Main container
    main_container = VBoxContainer.new()
    main_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    main_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
    add_child(main_container)
    
    # Header
    var header = Label.new()
    header.text = "Akashic Records Debug UI"
    header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    main_container.add_child(header)
    
    # Horizontal split
    var hsplit = HSplitContainer.new()
    hsplit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    hsplit.size_flags_vertical = Control.SIZE_EXPAND_FILL
    main_container.add_child(hsplit)
    
    # Entity list
    var entity_panel = VBoxContainer.new()
    entity_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    entity_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    hsplit.add_child(entity_panel)
    
    var entity_header = Label.new()
    entity_header.text = "Entity List"
    entity_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    entity_panel.add_child(entity_header)
    
    entity_list = ItemList.new()
    entity_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    entity_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
    entity_list.select_mode = ItemList.SELECT_SINGLE
    entity_panel.add_child(entity_list)
    entity_list.connect("item_selected", Callable(self, "_on_entity_selected"))
    
    # Info panel
    var right_panel = VBoxContainer.new()
    right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    right_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    hsplit.add_child(right_panel)
    
    info_panel = VBoxContainer.new()
    info_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    info_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    right_panel.add_child(info_panel)
    
    var info_header = Label.new()
    info_header.text = "Entity Information"
    info_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    info_panel.add_child(info_header)
    
    # Log panel
    var log_section = VBoxContainer.new()
    log_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    log_section.size_flags_vertical = Control.SIZE_EXPAND_FILL
    main_container.add_child(log_section)
    
    var log_header = Label.new()
    log_header.text = "Event Log"
    log_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    log_section.add_child(log_header)
    
    log_panel = RichTextLabel.new()
    log_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    log_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    log_panel.bbcode_enabled = true
    log_panel.scroll_following = true
    log_section.add_child(log_panel)
    
    # Control panel
    control_panel = HBoxContainer.new()
    control_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    main_container.add_child(control_panel)
    
    # Create entity button
    var create_button = Button.new()
    create_button.text = "Create Entity"
    create_button.connect("pressed", Callable(self, "_on_create_entity_pressed"))
    control_panel.add_child(create_button)
    
    # Test interaction button
    var interact_button = Button.new()
    interact_button.text = "Test Interaction"
    interact_button.connect("pressed", Callable(self, "_on_test_interaction_pressed"))
    control_panel.add_child(interact_button)
    
    # Transform entity button
    var transform_button = Button.new()
    transform_button.text = "Transform Entity"
    transform_button.connect("pressed", Callable(self, "_on_transform_entity_pressed"))
    control_panel.add_child(transform_button)
    
    # Check database button
    var check_db_button = Button.new()
    check_db_button.text = "Check Databases"
    check_db_button.connect("pressed", Callable(self, "_on_check_database_pressed"))
    control_panel.add_child(check_db_button)
    
    # Refresh button
    var refresh_button = Button.new()
    refresh_button.text = "Refresh"
    refresh_button.connect("pressed", Callable(self, "refresh_ui"))
    control_panel.add_child(refresh_button)
    
    # Clear log button
    var clear_log_button = Button.new()
    clear_log_button.text = "Clear Log"
    clear_log_button.connect("pressed", Callable(self, "_on_clear_log_pressed"))
    control_panel.add_child(clear_log_button)
    
    print("DebugUI: UI setup complete")

func refresh_ui() -> void:
    # Refresh entity list
    _refresh_entity_list()
    
    # Refresh entity info if an entity is selected
    if !selected_entity_id.empty():
        _display_entity_info(selected_entity_id)
    else:
        _clear_info_panel()

func _refresh_entity_list() -> void:
    entity_list.clear()
    
    if records_manager == null:
        return
    
    var types = records_manager.get_all_entity_types()
    
    for type in types:
        var entities = records_manager.get_entities_by_type(type)
        for entity in entities:
            var id = entity.get_id()
            var name = entity.get_type() + "_" + id.substr(0, 8)
            entity_list.add_item(name, null, false)
            entity_list.set_item_metadata(entity_list.item_count - 1, id)

func _display_entity_info(entity_id: String) -> void:
    # Clear previous info
    _clear_info_panel()
    
    if records_manager == null:
        return
    
    var entity = records_manager.get_entity_by_id(entity_id)
    if entity == null:
        return
    
    # Create UI elements for entity info
    var id_label = Label.new()
    id_label.text = "ID: " + entity.get_id()
    info_panel.add_child(id_label)
    
    var type_label = Label.new()
    type_label.text = "Type: " + entity.get_type()
    info_panel.add_child(type_label)
    
    var created_label = Label.new()
    created_label.text = "Created: " + entity.get_creation_timestamp()
    info_panel.add_child(created_label)
    
    # Properties
    var props_header = Label.new()
    props_header.text = "Properties:"
    info_panel.add_child(props_header)
    
    var properties = entity.get_properties()
    if properties.size() > 0:
        for prop_name in properties:
            var prop_label = Label.new()
            prop_label.text = "  " + prop_name + ": " + str(properties[prop_name])
            info_panel.add_child(prop_label)
    else:
        var no_props = Label.new()
        no_props.text = "  No properties."
        info_panel.add_child(no_props)
    
    # Transformation history
    var history_header = Label.new()
    history_header.text = "Transformation History:"
    info_panel.add_child(history_header)
    
    var history = entity.get_transformation_history()
    if history.size() > 0:
        for record in history:
            var record_label = Label.new()
            record_label.text = "  " + record["timestamp"] + ": " + record["action"] + " from " + record["from_type"] + " to " + record["to_type"]
            info_panel.add_child(record_label)
    else:
        var no_history = Label.new()
        no_history.text = "  No transformation history."
        info_panel.add_child(no_history)
    
    # References
    var refs_header = Label.new()
    refs_header.text = "References:"
    info_panel.add_child(refs_header)
    
    var references = entity.get_references()
    if references.size() > 0:
        for ref_type in references:
            var ref_ids = references[ref_type]
            var ref_label = Label.new()
            ref_label.text = "  " + ref_type + ": " + str(ref_ids)
            info_panel.add_child(ref_label)
    else:
        var no_refs = Label.new()
        no_refs.text = "  No references."
        info_panel.add_child(no_refs)

func _clear_info_panel() -> void:
    for child in info_panel.get_children():
        if child.get_index() > 0:  # Skip the header
            child.queue_free()

func log_message(message: String, message_type: String = "info") -> void:
    var timestamp = Time.get_time_string_from_system()
    var color = "#FFFFFF"
    
    match message_type:
        "success":
            color = "#00FF00"
        "warning":
            color = "#FFFF00"
        "error":
            color = "#FF0000"
        "entity":
            color = "#00FFFF"
        "transformation":
            color = "#FF00FF"
        "interaction":
            color = "#FFAA00"
        "database":
            color = "#66CCFF"
    
    log_panel.append_text("[color=#AAAAAA][" + timestamp + "][/color] ")
    log_panel.append_text("[color=" + color + "]" + message + "[/color]\n")

# Signal handlers
func _on_entity_selected(index: int) -> void:
    selected_entity_id = entity_list.get_item_metadata(index)
    _display_entity_info(selected_entity_id)

func _on_create_entity_pressed() -> void:
    if universal_bridge == null:
        log_message("Universal Bridge not available", "error")
        return
    
    # Simple entity creation
    var entity_types = ["primordial", "fire", "water", "wood", "ash", "air", "earth", "metal"]
    var type = entity_types[randi() % entity_types.size()]
    
    var entity = universal_bridge.create_entity(type, {
        "energy": randi() % 10 + 1,
        "intensity": randi() % 3 + 1,
        "created_by": "debug_ui"
    })
    
    if entity != null:
        log_message("Created entity of type '" + type + "' with ID: " + entity.get_id(), "success")
        refresh_ui()
    else:
        log_message("Failed to create entity", "error")

func _on_test_interaction_pressed() -> void:
    if universal_bridge == null or records_manager == null:
        log_message("Required systems not available", "error")
        return
    
    # Need at least 2 entities to test interaction
    var all_entities = []
    var types = records_manager.get_all_entity_types()
    for type in types:
        all_entities.append_array(records_manager.get_entities_by_type(type))
    
    if all_entities.size() < 2:
        log_message("Need at least 2 entities to test interaction", "warning")
        return
    
    # Randomly select two different entities
    var entity1_index = randi() % all_entities.size()
    var entity2_index = entity1_index
    while entity2_index == entity1_index:
        entity2_index = randi() % all_entities.size()
    
    var entity1 = all_entities[entity1_index]
    var entity2 = all_entities[entity2_index]
    
    # Process interaction
    var result = universal_bridge.process_interaction(entity1, entity2)
    
    if result.has("success") and result["success"]:
        log_message("Interaction between " + entity1.get_type() + " and " + entity2.get_type() + " resulted in effect: " + result["effect"], "interaction")
        
        # Log transformations
        if result.has("transformations") and result["transformations"].size() > 0:
            for transform in result["transformations"]:
                log_message("Entity transformed from " + transform["from"] + " to " + transform["to"], "transformation")
        
        # Log new entities
        if result.has("new_entities") and result["new_entities"].size() > 0:
            for entity in result["new_entities"]:
                log_message("New entity created of type " + entity.get_type(), "entity")
    else:
        log_message("Interaction failed", "error")
    
    refresh_ui()

func _on_transform_entity_pressed() -> void:
    if universal_bridge == null or selected_entity_id.empty():
        log_message("Cannot transform: No entity selected or bridge unavailable", "warning")
        return
    
    var entity = records_manager.get_entity_by_id(selected_entity_id)
    if entity == null:
        log_message("Selected entity not found", "error")
        return
    
    # Get available types to transform to
    var types = ["primordial", "fire", "water", "wood", "ash", "air", "earth", "metal"]
    var current_type = entity.get_type()
    
    # Filter out the current type
    types.erase(current_type)
    
    if types.size() == 0:
        log_message("No available types to transform to", "warning")
        return
    
    # Select a random type
    var new_type = types[randi() % types.size()]
    
    # Transform entity
    var success = universal_bridge.transform_entity(entity, new_type)
    
    if success:
        log_message("Entity transformed from " + current_type + " to " + new_type, "transformation")
        refresh_ui()
    else:
        log_message("Transformation failed", "error")

func _on_check_database_pressed() -> void:
    if database_integrator == null:
        log_message("Database integrator not available", "error")
        return
    
    log_message("Checking database sizes...", "database")
    database_integrator.check_database_sizes()
    
    # Get information about current files
    var files = database_integrator.get_database_files()
    log_message("Current database files: " + str(files.size()), "database")
    
    refresh_ui()

func _on_clear_log_pressed() -> void:
    log_panel.clear()
    log_message("Log cleared", "info")

# Signal handlers from Akashic Records
func _on_entity_created(entity) -> void:
    log_message("Entity created: " + entity.get_type() + " (ID: " + entity.get_id() + ")", "entity")
    refresh_ui()

func _on_entity_transformed(entity, old_type, new_type) -> void:
    log_message("Entity transformed: " + entity.get_id() + " from " + old_type + " to " + new_type, "transformation")
    refresh_ui()

func _on_entity_interaction(entity1, entity2, result) -> void:
    log_message("Interaction between " + entity1.get_id() + " and " + entity2.get_id() + ": " + result["effect"], "interaction")
    refresh_ui()

func _on_database_split(file_path, new_files) -> void:
    log_message("Database split: " + file_path + " into " + str(new_files.size()) + " new files", "database")
    refresh_ui()