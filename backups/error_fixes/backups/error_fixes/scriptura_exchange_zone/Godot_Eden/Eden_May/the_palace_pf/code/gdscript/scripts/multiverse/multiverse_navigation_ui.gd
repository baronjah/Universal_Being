extends Control
class_name MultiverseNavigationUI

# References to required systems
var akashic_records_manager = null
var database_system = null
var entity_evolution = null
var universal_bridge = null

# UI Components
var current_universe_panel = null
var access_points_panel = null
var cosmic_data_panel = null
var metanarrative_panel = null
var alignment_panel = null

# Universe data
var current_universe_id = ""
var current_cosmic_turn = 0
var current_cosmic_age = 0
var metanarrative_progress = 0.0
var universe_alignment = 0.0
var universe_synchronization = 0.0

# Access points data
var access_points = []

# Constants
const UNIVERSE_TYPES = ["Prime", "Parallel", "Pocket", "Echo", "Divergent", "Convergent", "Nascent"]
const ALIGNMENT_TYPES = ["Chaotic", "Neutral", "Ordered"]
const SYNCHRONIZATION_LEVELS = ["Asynchronous", "Partially Synced", "Fully Synchronized"]
const COSMIC_AGES = ["Dawn", "Expanding", "Stabilization", "Convergence", "Twilight", "Renewal"]

func _ready():
    # Initialize required dependencies
    initialize_dependencies()
    
    # Create UI
    create_ui()
    
    # Initial data load
    load_universe_data()
    
    # Set up periodic update timer
    var update_timer = Timer.new()
    update_timer.wait_time = 2.0
    update_timer.autostart = true
    update_timer.timeout.connect(_on_update_timer_timeout)
    add_child(update_timer)
    
    print("MultiverseNavigationUI initialized")

func initialize_dependencies():
    # Try to find Akashic Records Manager
    if has_node("/root/AkashicRecordsManager"):
        akashic_records_manager = get_node("/root/AkashicRecordsManager")
    else:
        var akashic_records_script = load("res://code/gdscript/scripts/akashic/akashic_records_manager.gd")
        if akashic_records_script:
            akashic_records_manager = akashic_records_script.new()
            akashic_records_manager.name = "AkashicRecordsManager"
            get_tree().root.add_child(akashic_records_manager)
            print("Created AkashicRecordsManager instance")
        else:
            push_error("AkashicRecordsManager script not found!")
    
    # Try to find Database System
    if has_node("/root/DatabaseSystem"):
        database_system = get_node("/root/DatabaseSystem")
    else:
        var database_script = load("res://code/gdscript/scripts/database/JSHDatabaseManager.gd")
        if database_script:
            database_system = database_script.new()
            database_system.name = "DatabaseSystem"
            get_tree().root.add_child(database_system)
            print("Created DatabaseSystem instance")
        else:
            push_error("DatabaseSystem script not found!")
    
    # Try to find Entity Evolution
    if has_node("/root/EntityEvolution"):
        entity_evolution = get_node("/root/EntityEvolution")
    else:
        var evolution_script = load("res://code/gdscript/scripts/entity/JSHEntityEvolution.gd")
        if evolution_script:
            entity_evolution = evolution_script.get_instance()
            entity_evolution.name = "EntityEvolution"
            get_tree().root.add_child(entity_evolution)
            print("Created EntityEvolution instance")
        else:
            push_error("EntityEvolution script not found!")
    
    # Try to find Universal Bridge
    if has_node("/root/UniversalBridge"):
        universal_bridge = get_node("/root/UniversalBridge")
    else:
        var bridge_script = load("res://code/gdscript/scripts/core/universal_bridge.gd")
        if bridge_script:
            universal_bridge = bridge_script.new()
            universal_bridge.name = "UniversalBridge"
            get_tree().root.add_child(universal_bridge)
            print("Created UniversalBridge instance")
        else:
            push_error("UniversalBridge script not found!")

func create_ui():
    # Set up the main container
    anchor_right = 1.0
    anchor_bottom = 1.0
    
    # Create a semi-transparent background
    var background = ColorRect.new()
    background.name = "Background"
    background.anchor_right = 1.0
    background.anchor_bottom = 1.0
    background.color = Color(0.05, 0.05, 0.1, 0.9)
    add_child(background)
    
    # Main layout container
    var main_container = HBoxContainer.new()
    main_container.name = "MainContainer"
    main_container.anchor_right = 1.0
    main_container.anchor_bottom = 1.0
    main_container.size_flags_horizontal = SIZE_EXPAND_FILL
    main_container.size_flags_vertical = SIZE_EXPAND_FILL
    add_child(main_container)
    
    # Left panel (universe info & cosmic data)
    var left_panel = VBoxContainer.new()
    left_panel.name = "LeftPanel"
    left_panel.size_flags_horizontal = SIZE_EXPAND_FILL
    left_panel.size_flags_vertical = SIZE_EXPAND_FILL
    left_panel.size_flags_stretch_ratio = 0.35
    main_container.add_child(left_panel)
    
    # Title for current universe
    var universe_title = Label.new()
    universe_title.text = "CURRENT UNIVERSE"
    universe_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    universe_title.add_theme_font_size_override("font_size", 20)
    universe_title.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
    left_panel.add_child(universe_title)
    
    # Current Universe Panel
    current_universe_panel = create_current_universe_panel()
    left_panel.add_child(current_universe_panel)
    
    # Cosmic Data Title
    var cosmic_title = Label.new()
    cosmic_title.text = "COSMIC METRICS"
    cosmic_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    cosmic_title.add_theme_font_size_override("font_size", 20)
    cosmic_title.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
    left_panel.add_child(cosmic_title)
    
    # Cosmic Data Panel
    cosmic_data_panel = create_cosmic_data_panel()
    left_panel.add_child(cosmic_data_panel)
    
    # Metanarrative Panel
    metanarrative_panel = create_metanarrative_panel()
    left_panel.add_child(metanarrative_panel)
    
    # Right panel (access points & alignment)
    var right_panel = VBoxContainer.new()
    right_panel.name = "RightPanel"
    right_panel.size_flags_horizontal = SIZE_EXPAND_FILL
    right_panel.size_flags_vertical = SIZE_EXPAND_FILL
    right_panel.size_flags_stretch_ratio = 0.65
    main_container.add_child(right_panel)
    
    # Access Points Title
    var access_title = Label.new()
    access_title.text = "MULTIVERSE ACCESS POINTS"
    access_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    access_title.add_theme_font_size_override("font_size", 20)
    access_title.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
    right_panel.add_child(access_title)
    
    # Access Points Panel
    access_points_panel = create_access_points_panel()
    right_panel.add_child(access_points_panel)
    
    # Alignment Title
    var alignment_title = Label.new()
    alignment_title.text = "UNIVERSE ALIGNMENT"
    alignment_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    alignment_title.add_theme_font_size_override("font_size", 20)
    alignment_title.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
    right_panel.add_child(alignment_title)
    
    # Alignment Panel
    alignment_panel = create_alignment_panel()
    right_panel.add_child(alignment_panel)
    
    # Bottom control panel
    var control_panel = HBoxContainer.new()
    control_panel.name = "ControlPanel"
    control_panel.alignment = BoxContainer.ALIGNMENT_CENTER
    right_panel.add_child(control_panel)
    
    # Refresh button
    var refresh_button = Button.new()
    refresh_button.text = "Refresh Multiverse Data"
    refresh_button.custom_minimum_size = Vector2(200, 40)
    refresh_button.pressed.connect(_on_refresh_button_pressed)
    control_panel.add_child(refresh_button)
    
    # Travel button
    var travel_button = Button.new()
    travel_button.text = "Navigate to Selected Universe"
    travel_button.custom_minimum_size = Vector2(200, 40)
    travel_button.pressed.connect(_on_travel_button_pressed)
    control_panel.add_child(travel_button)

func create_current_universe_panel():
    var panel = PanelContainer.new()
    panel.name = "CurrentUniversePanel"
    panel.size_flags_horizontal = SIZE_EXPAND_FILL
    panel.size_flags_vertical = SIZE_EXPAND_FILL
    panel.size_flags_stretch_ratio = 0.4
    
    var panel_style = StyleBoxFlat.new()
    panel_style.bg_color = Color(0.1, 0.1, 0.2, 0.7)
    panel_style.border_width_all = 1
    panel_style.border_color = Color(0.3, 0.5, 0.8)
    panel_style.corner_radius_top_left = 5
    panel_style.corner_radius_top_right = 5
    panel_style.corner_radius_bottom_left = 5
    panel_style.corner_radius_bottom_right = 5
    panel.add_theme_stylebox_override("panel", panel_style)
    
    var content = VBoxContainer.new()
    content.size_flags_horizontal = SIZE_EXPAND_FILL
    content.size_flags_vertical = SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 10)
    panel.add_child(content)
    
    # Universe ID
    var id_container = HBoxContainer.new()
    content.add_child(id_container)
    
    var id_label = Label.new()
    id_label.text = "Universe ID:"
    id_label.size_flags_horizontal = SIZE_EXPAND_FILL
    id_label.size_flags_stretch_ratio = 0.4
    id_container.add_child(id_label)
    
    var id_value = Label.new()
    id_value.name = "UniverseIDValue"
    id_value.text = "---"
    id_value.size_flags_horizontal = SIZE_EXPAND_FILL
    id_value.size_flags_stretch_ratio = 0.6
    id_container.add_child(id_value)
    
    # Universe Type
    var type_container = HBoxContainer.new()
    content.add_child(type_container)
    
    var type_label = Label.new()
    type_label.text = "Type:"
    type_label.size_flags_horizontal = SIZE_EXPAND_FILL
    type_label.size_flags_stretch_ratio = 0.4
    type_container.add_child(type_label)
    
    var type_value = Label.new()
    type_value.name = "UniverseTypeValue"
    type_value.text = "---"
    type_value.size_flags_horizontal = SIZE_EXPAND_FILL
    type_value.size_flags_stretch_ratio = 0.6
    type_container.add_child(type_value)
    
    # Universe Stability
    var stability_container = HBoxContainer.new()
    content.add_child(stability_container)
    
    var stability_label = Label.new()
    stability_label.text = "Stability:"
    stability_label.size_flags_horizontal = SIZE_EXPAND_FILL
    stability_label.size_flags_stretch_ratio = 0.4
    stability_container.add_child(stability_label)
    
    var stability_progress = ProgressBar.new()
    stability_progress.name = "StabilityProgress"
    stability_progress.min_value = 0
    stability_progress.max_value = 100
    stability_progress.value = 50
    stability_progress.size_flags_horizontal = SIZE_EXPAND_FILL
    stability_progress.size_flags_stretch_ratio = 0.6
    stability_container.add_child(stability_progress)
    
    # Universe Energy
    var energy_container = HBoxContainer.new()
    content.add_child(energy_container)
    
    var energy_label = Label.new()
    energy_label.text = "Energy:"
    energy_label.size_flags_horizontal = SIZE_EXPAND_FILL
    energy_label.size_flags_stretch_ratio = 0.4
    energy_container.add_child(energy_label)
    
    var energy_progress = ProgressBar.new()
    energy_progress.name = "EnergyProgress"
    energy_progress.min_value = 0
    energy_progress.max_value = 100
    energy_progress.value = 75
    energy_progress.size_flags_horizontal = SIZE_EXPAND_FILL
    energy_progress.size_flags_stretch_ratio = 0.6
    energy_container.add_child(energy_progress)
    
    # Universe Entities
    var entities_container = HBoxContainer.new()
    content.add_child(entities_container)
    
    var entities_label = Label.new()
    entities_label.text = "Entities:"
    entities_label.size_flags_horizontal = SIZE_EXPAND_FILL
    entities_label.size_flags_stretch_ratio = 0.4
    entities_container.add_child(entities_label)
    
    var entities_value = Label.new()
    entities_value.name = "EntitiesValue"
    entities_value.text = "0"
    entities_value.size_flags_horizontal = SIZE_EXPAND_FILL
    entities_value.size_flags_stretch_ratio = 0.6
    entities_container.add_child(entities_value)
    
    # Universe Core Element
    var element_container = HBoxContainer.new()
    content.add_child(element_container)
    
    var element_label = Label.new()
    element_label.text = "Core Element:"
    element_label.size_flags_horizontal = SIZE_EXPAND_FILL
    element_label.size_flags_stretch_ratio = 0.4
    element_container.add_child(element_label)
    
    var element_value = Label.new()
    element_value.name = "ElementValue"
    element_value.text = "---"
    element_value.size_flags_horizontal = SIZE_EXPAND_FILL
    element_value.size_flags_stretch_ratio = 0.6
    element_container.add_child(element_value)
    
    # Universe Description
    var desc_label = Label.new()
    desc_label.text = "Description:"
    content.add_child(desc_label)
    
    var desc_text = RichTextLabel.new()
    desc_text.name = "DescriptionText"
    desc_text.text = "Universe data loading..."
    desc_text.size_flags_vertical = SIZE_EXPAND_FILL
    desc_text.fit_content = true
    desc_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    desc_text.scroll_active = true
    content.add_child(desc_text)
    
    return panel

func create_cosmic_data_panel():
    var panel = PanelContainer.new()
    panel.name = "CosmicDataPanel"
    panel.size_flags_horizontal = SIZE_EXPAND_FILL
    panel.size_flags_vertical = SIZE_EXPAND_FILL
    panel.size_flags_stretch_ratio = 0.3
    
    var panel_style = StyleBoxFlat.new()
    panel_style.bg_color = Color(0.1, 0.1, 0.2, 0.7)
    panel_style.border_width_all = 1
    panel_style.border_color = Color(0.3, 0.5, 0.8)
    panel_style.corner_radius_top_left = 5
    panel_style.corner_radius_top_right = 5
    panel_style.corner_radius_bottom_left = 5
    panel_style.corner_radius_bottom_right = 5
    panel.add_theme_stylebox_override("panel", panel_style)
    
    var content = VBoxContainer.new()
    content.size_flags_horizontal = SIZE_EXPAND_FILL
    content.size_flags_vertical = SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 10)
    panel.add_child(content)
    
    # Cosmic Turn
    var turn_container = HBoxContainer.new()
    content.add_child(turn_container)
    
    var turn_label = Label.new()
    turn_label.text = "Cosmic Turn:"
    turn_label.size_flags_horizontal = SIZE_EXPAND_FILL
    turn_label.size_flags_stretch_ratio = 0.4
    turn_container.add_child(turn_label)
    
    var turn_value = Label.new()
    turn_value.name = "TurnValue"
    turn_value.text = "0"
    turn_value.size_flags_horizontal = SIZE_EXPAND_FILL
    turn_value.size_flags_stretch_ratio = 0.6
    turn_container.add_child(turn_value)
    
    # Cosmic Age
    var age_container = HBoxContainer.new()
    content.add_child(age_container)
    
    var age_label = Label.new()
    age_label.text = "Cosmic Age:"
    age_label.size_flags_horizontal = SIZE_EXPAND_FILL
    age_label.size_flags_stretch_ratio = 0.4
    age_container.add_child(age_label)
    
    var age_value = Label.new()
    age_value.name = "AgeValue"
    age_value.text = "Dawn"
    age_value.size_flags_horizontal = SIZE_EXPAND_FILL
    age_value.size_flags_stretch_ratio = 0.6
    age_container.add_child(age_value)
    
    # Observable Universes
    var observable_container = HBoxContainer.new()
    content.add_child(observable_container)
    
    var observable_label = Label.new()
    observable_label.text = "Observable Universes:"
    observable_label.size_flags_horizontal = SIZE_EXPAND_FILL
    observable_label.size_flags_stretch_ratio = 0.4
    observable_container.add_child(observable_label)
    
    var observable_value = Label.new()
    observable_value.name = "ObservableValue"
    observable_value.text = "0"
    observable_value.size_flags_horizontal = SIZE_EXPAND_FILL
    observable_value.size_flags_stretch_ratio = 0.6
    observable_container.add_child(observable_value)
    
    # Convergence Points
    var convergence_container = HBoxContainer.new()
    content.add_child(convergence_container)
    
    var convergence_label = Label.new()
    convergence_label.text = "Convergence Points:"
    convergence_label.size_flags_horizontal = SIZE_EXPAND_FILL
    convergence_label.size_flags_stretch_ratio = 0.4
    convergence_container.add_child(convergence_label)
    
    var convergence_value = Label.new()
    convergence_value.name = "ConvergenceValue"
    convergence_value.text = "0"
    convergence_value.size_flags_horizontal = SIZE_EXPAND_FILL
    convergence_value.size_flags_stretch_ratio = 0.6
    convergence_container.add_child(convergence_value)
    
    return panel

func create_metanarrative_panel():
    var panel = PanelContainer.new()
    panel.name = "MetanarrativePanel"
    panel.size_flags_horizontal = SIZE_EXPAND_FILL
    panel.size_flags_vertical = SIZE_EXPAND_FILL
    panel.size_flags_stretch_ratio = 0.3
    
    var panel_style = StyleBoxFlat.new()
    panel_style.bg_color = Color(0.1, 0.1, 0.2, 0.7)
    panel_style.border_width_all = 1
    panel_style.border_color = Color(0.3, 0.5, 0.8)
    panel_style.corner_radius_top_left = 5
    panel_style.corner_radius_top_right = 5
    panel_style.corner_radius_bottom_left = 5
    panel_style.corner_radius_bottom_right = 5
    panel.add_theme_stylebox_override("panel", panel_style)
    
    var content = VBoxContainer.new()
    content.size_flags_horizontal = SIZE_EXPAND_FILL
    content.size_flags_vertical = SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 10)
    panel.add_child(content)
    
    # Metanarrative Title
    var meta_title = Label.new()
    meta_title.text = "METANARRATIVE PROGRESSION"
    meta_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    meta_title.add_theme_font_size_override("font_size", 16)
    meta_title.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
    content.add_child(meta_title)
    
    # Progress Bar
    var progress_container = VBoxContainer.new()
    progress_container.size_flags_horizontal = SIZE_EXPAND_FILL
    content.add_child(progress_container)
    
    var progress_bar = ProgressBar.new()
    progress_bar.name = "MetanarrativeProgress"
    progress_bar.min_value = 0
    progress_bar.max_value = 100
    progress_bar.value = 35
    progress_bar.size_flags_horizontal = SIZE_EXPAND_FILL
    progress_container.add_child(progress_bar)
    
    var progress_label = Label.new()
    progress_label.name = "ProgressLabel"
    progress_label.text = "35%"
    progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    progress_container.add_child(progress_label)
    
    # Current Phase
    var phase_container = HBoxContainer.new()
    content.add_child(phase_container)
    
    var phase_label = Label.new()
    phase_label.text = "Current Phase:"
    phase_label.size_flags_horizontal = SIZE_EXPAND_FILL
    phase_label.size_flags_stretch_ratio = 0.4
    phase_container.add_child(phase_label)
    
    var phase_value = Label.new()
    phase_value.name = "PhaseValue"
    phase_value.text = "Expansion"
    phase_value.size_flags_horizontal = SIZE_EXPAND_FILL
    phase_value.size_flags_stretch_ratio = 0.6
    phase_container.add_child(phase_value)
    
    # Narrative Threads
    var threads_container = HBoxContainer.new()
    content.add_child(threads_container)
    
    var threads_label = Label.new()
    threads_label.text = "Active Threads:"
    threads_label.size_flags_horizontal = SIZE_EXPAND_FILL
    threads_label.size_flags_stretch_ratio = 0.4
    threads_container.add_child(threads_label)
    
    var threads_value = Label.new()
    threads_value.name = "ThreadsValue"
    threads_value.text = "3"
    threads_value.size_flags_horizontal = SIZE_EXPAND_FILL
    threads_value.size_flags_stretch_ratio = 0.6
    threads_container.add_child(threads_value)
    
    # Current Objective
    var objective_label = Label.new()
    objective_label.text = "Current Objective:"
    content.add_child(objective_label)
    
    var objective_text = Label.new()
    objective_text.name = "ObjectiveText"
    objective_text.text = "Stabilize the primary narrative convergence point"
    objective_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content.add_child(objective_text)
    
    return panel

func create_access_points_panel():
    var panel = PanelContainer.new()
    panel.name = "AccessPointsPanel"
    panel.size_flags_horizontal = SIZE_EXPAND_FILL
    panel.size_flags_vertical = SIZE_EXPAND_FILL
    panel.size_flags_stretch_ratio = 0.7
    
    var panel_style = StyleBoxFlat.new()
    panel_style.bg_color = Color(0.1, 0.1, 0.2, 0.7)
    panel_style.border_width_all = 1
    panel_style.border_color = Color(0.3, 0.5, 0.8)
    panel_style.corner_radius_top_left = 5
    panel_style.corner_radius_top_right = 5
    panel_style.corner_radius_bottom_left = 5
    panel_style.corner_radius_bottom_right = 5
    panel.add_theme_stylebox_override("panel", panel_style)
    
    var content = VBoxContainer.new()
    content.size_flags_horizontal = SIZE_EXPAND_FILL
    content.size_flags_vertical = SIZE_EXPAND_FILL
    panel.add_child(content)
    
    # Filter controls
    var filter_container = HBoxContainer.new()
    content.add_child(filter_container)
    
    var filter_label = Label.new()
    filter_label.text = "Filter by Type:"
    filter_container.add_child(filter_label)
    
    var filter_dropdown = OptionButton.new()
    filter_dropdown.name = "TypeFilter"
    filter_dropdown.add_item("All Types", 0)
    for i in range(UNIVERSE_TYPES.size()):
        filter_dropdown.add_item(UNIVERSE_TYPES[i], i+1)
    filter_dropdown.item_selected.connect(_on_type_filter_selected)
    filter_container.add_child(filter_dropdown)
    
    var spacer = Control.new()
    spacer.size_flags_horizontal = SIZE_EXPAND_FILL
    filter_container.add_child(spacer)
    
    var sort_label = Label.new()
    sort_label.text = "Sort by:"
    filter_container.add_child(sort_label)
    
    var sort_dropdown = OptionButton.new()
    sort_dropdown.name = "SortOption"
    sort_dropdown.add_item("Proximity", 0)
    sort_dropdown.add_item("Stability", 1)
    sort_dropdown.add_item("Energy", 2)
    sort_dropdown.add_item("Alignment", 3)
    sort_dropdown.item_selected.connect(_on_sort_option_selected)
    filter_container.add_child(sort_dropdown)
    
    # Access points list
    var list_container = ScrollContainer.new()
    list_container.size_flags_horizontal = SIZE_EXPAND_FILL
    list_container.size_flags_vertical = SIZE_EXPAND_FILL
    content.add_child(list_container)
    
    var access_list = ItemList.new()
    access_list.name = "AccessPointsList"
    access_list.size_flags_horizontal = SIZE_EXPAND_FILL
    access_list.size_flags_vertical = SIZE_EXPAND_FILL
    access_list.select_mode = ItemList.SELECT_SINGLE
    access_list.item_selected.connect(_on_access_point_selected)
    list_container.add_child(access_list)
    
    # Universe details
    var details_title = Label.new()
    details_title.text = "SELECTED UNIVERSE DETAILS"
    details_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    details_title.add_theme_font_size_override("font_size", 16)
    details_title.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
    content.add_child(details_title)
    
    var details_container = ScrollContainer.new()
    details_container.size_flags_horizontal = SIZE_EXPAND_FILL
    details_container.custom_minimum_size.y = 120
    content.add_child(details_container)
    
    var details_text = RichTextLabel.new()
    details_text.name = "DetailsText"
    details_text.text = "Select a universe from the list to view details..."
    details_text.size_flags_horizontal = SIZE_EXPAND_FILL
    details_text.size_flags_vertical = SIZE_EXPAND_FILL
    details_text.fit_content = true
    details_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    details_container.add_child(details_text)
    
    return panel

func create_alignment_panel():
    var panel = PanelContainer.new()
    panel.name = "AlignmentPanel"
    panel.size_flags_horizontal = SIZE_EXPAND_FILL
    panel.size_flags_vertical = SIZE_EXPAND_FILL
    panel.size_flags_stretch_ratio = 0.3
    
    var panel_style = StyleBoxFlat.new()
    panel_style.bg_color = Color(0.1, 0.1, 0.2, 0.7)
    panel_style.border_width_all = 1
    panel_style.border_color = Color(0.3, 0.5, 0.8)
    panel_style.corner_radius_top_left = 5
    panel_style.corner_radius_top_right = 5
    panel_style.corner_radius_bottom_left = 5
    panel_style.corner_radius_bottom_right = 5
    panel.add_theme_stylebox_override("panel", panel_style)
    
    var content = VBoxContainer.new()
    content.size_flags_horizontal = SIZE_EXPAND_FILL
    content.size_flags_vertical = SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 10)
    panel.add_child(content)
    
    # Alignment indicator
    var align_container = VBoxContainer.new()
    align_container.size_flags_horizontal = SIZE_EXPAND_FILL
    content.add_child(align_container)
    
    var align_label = Label.new()
    align_label.text = "Universe Alignment"
    align_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    align_container.add_child(align_label)
    
    var align_bar = ProgressBar.new()
    align_bar.name = "AlignmentBar"
    align_bar.min_value = -100
    align_bar.max_value = 100
    align_bar.value = 25
    align_bar.size_flags_horizontal = SIZE_EXPAND_FILL
    align_container.add_child(align_bar)
    
    var align_value_container = HBoxContainer.new()
    align_value_container.alignment = BoxContainer.ALIGNMENT_CENTER
    align_container.add_child(align_value_container)
    
    var chaotic_label = Label.new()
    chaotic_label.text = "Chaotic"
    chaotic_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
    align_value_container.add_child(chaotic_label)
    
    var spacer1 = Control.new()
    spacer1.size_flags_horizontal = SIZE_EXPAND_FILL
    align_value_container.add_child(spacer1)
    
    var neutral_label = Label.new()
    neutral_label.text = "Neutral"
    neutral_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.3))
    align_value_container.add_child(neutral_label)
    
    var spacer2 = Control.new()
    spacer2.size_flags_horizontal = SIZE_EXPAND_FILL
    align_value_container.add_child(spacer2)
    
    var ordered_label = Label.new()
    ordered_label.text = "Ordered"
    ordered_label.add_theme_color_override("font_color", Color(0.3, 0.8, 0.3))
    align_value_container.add_child(ordered_label)
    
    # Synchronization indicator
    var sync_container = VBoxContainer.new()
    sync_container.size_flags_horizontal = SIZE_EXPAND_FILL
    content.add_child(sync_container)
    
    var sync_label = Label.new()
    sync_label.text = "Universe Synchronization"
    sync_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    sync_container.add_child(sync_label)
    
    var sync_bar = ProgressBar.new()
    sync_bar.name = "SynchronizationBar"
    sync_bar.min_value = 0
    sync_bar.max_value = 100
    sync_bar.value = 65
    sync_bar.size_flags_horizontal = SIZE_EXPAND_FILL
    sync_container.add_child(sync_bar)
    
    var sync_text = Label.new()
    sync_text.name = "SyncText"
    sync_text.text = "Partially Synchronized (65%)"
    sync_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    sync_container.add_child(sync_text)
    
    # Visualization Section
    var vis_title = Label.new()
    vis_title.text = "ALIGNMENT VISUALIZATION"
    vis_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vis_title.add_theme_font_size_override("font_size", 16)
    vis_title.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
    content.add_child(vis_title)
    
    # Placeholder for the visualization
    var vis_rect = ColorRect.new()
    vis_rect.name = "VisualizationRect"
    vis_rect.size_flags_horizontal = SIZE_EXPAND_FILL
    vis_rect.size_flags_vertical = SIZE_EXPAND_FILL
    vis_rect.color = Color(0.2, 0.2, 0.3, 0.5)
    content.add_child(vis_rect)
    
    # This would be replaced with a proper visualization in a complete implementation
    # Using a placeholder for now
    var vis_label = Label.new()
    vis_label.text = "Dynamic Visualization"
    vis_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vis_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    vis_label.size_flags_horizontal = SIZE_EXPAND_FILL
    vis_label.size_flags_vertical = SIZE_EXPAND_FILL
    vis_rect.add_child(vis_label)
    
    return panel

# Data loading and update functions

func load_universe_data():
    # This would normally fetch data from the Akashic Records or database
    # Using placeholder data for demonstration
    
    # Generate a universe ID if none exists
    if current_universe_id.is_empty():
        current_universe_id = "U" + str(randi() % 1000).pad_zeros(3) + "-" + str(randi() % 100).pad_zeros(2)
    
    # Set cosmic data
    current_cosmic_turn = randi() % 100
    current_cosmic_age = randi() % 6
    metanarrative_progress = randf_range(0, 100)
    universe_alignment = randf_range(-100, 100)
    universe_synchronization = randf_range(0, 100)
    
    # Update UI with current universe data
    update_current_universe_ui()
    update_cosmic_data_ui()
    update_metanarrative_ui()
    update_alignment_ui()
    
    # Generate sample access points
    generate_access_points()
    update_access_points_ui()

func update_current_universe_ui():
    # Update current universe panel with data
    var id_value = current_universe_panel.get_node("UniverseIDValue")
    id_value.text = current_universe_id
    
    var type_value = current_universe_panel.get_node("UniverseTypeValue")
    type_value.text = UNIVERSE_TYPES[randi() % UNIVERSE_TYPES.size()]
    
    var stability_progress = current_universe_panel.get_node("StabilityProgress")
    stability_progress.value = randf_range(0, 100)
    
    var energy_progress = current_universe_panel.get_node("EnergyProgress")
    energy_progress.value = randf_range(0, 100)
    
    var entities_value = current_universe_panel.get_node("EntitiesValue")
    entities_value.text = str(randi() % 10000)
    
    var element_value = current_universe_panel.get_node("ElementValue")
    var elements = ["Aether", "Chronos", "Void", "Light", "Shadow", "Nexus", "Quantum"]
    element_value.text = elements[randi() % elements.size()]
    
    var desc_text = current_universe_panel.get_node("DescriptionText")
    desc_text.text = "This universe exists within the JSH Ethereal Engine multiverse cluster. "
    desc_text.text += "It demonstrates " + str(randi() % 80 + 20) + "% stability with a core " 
    desc_text.text += "resonance pattern of " + str(randf_range(1.0, 10.0)) + ". "
    desc_text.text += "The primary narrative structure is in the " + COSMIC_AGES[current_cosmic_age] + " phase."

func update_cosmic_data_ui():
    # Update cosmic data panel
    var turn_value = cosmic_data_panel.get_node("TurnValue") 
    turn_value.text = str(current_cosmic_turn)
    
    var age_value = cosmic_data_panel.get_node("AgeValue")
    age_value.text = COSMIC_AGES[current_cosmic_age]
    
    var observable_value = cosmic_data_panel.get_node("ObservableValue")
    observable_value.text = str(randi() % 50 + 10)
    
    var convergence_value = cosmic_data_panel.get_node("ConvergenceValue")
    convergence_value.text = str(randi() % 10)

func update_metanarrative_ui():
    # Update metanarrative panel
    var progress_bar = metanarrative_panel.get_node("MetanarrativeProgress")
    progress_bar.value = metanarrative_progress
    
    var progress_label = metanarrative_panel.get_node("ProgressLabel")
    progress_label.text = str(int(metanarrative_progress)) + "%"
    
    var phase_value = metanarrative_panel.get_node("PhaseValue")
    var phases = ["Introduction", "Expansion", "Conflict", "Climax", "Resolution", "Epilogue"]
    phase_value.text = phases[int(metanarrative_progress / 20) if metanarrative_progress < 100 else 5]
    
    var threads_value = metanarrative_panel.get_node("ThreadsValue")
    threads_value.text = str(randi() % 7 + 1)
    
    var objective_text = metanarrative_panel.get_node("ObjectiveText")
    var objectives = [
        "Stabilize the primary narrative convergence point",
        "Resolve timeline inconsistencies in sector 7",
        "Identify and secure divergent pattern anomalies",
        "Synchronize cosmic resonance between connected universes",
        "Maintain metanarrative cohesion through the transition phase"
    ]
    objective_text.text = objectives[randi() % objectives.size()]

func update_alignment_ui():
    # Update alignment panel
    var align_bar = alignment_panel.get_node("AlignmentBar")
    align_bar.value = universe_alignment
    
    var sync_bar = alignment_panel.get_node("SynchronizationBar")
    sync_bar.value = universe_synchronization
    
    var sync_text = alignment_panel.get_node("SyncText")
    var sync_level = ""
    if universe_synchronization < 33:
        sync_level = "Asynchronous"
    elif universe_synchronization < 66:
        sync_level = "Partially Synchronized"
    else:
        sync_level = "Fully Synchronized"
    sync_text.text = sync_level + " (" + str(int(universe_synchronization)) + "%)"
    
    # Update visualization (placeholder)
    var vis_rect = alignment_panel.get_node("VisualizationRect")
    var base_color = Color(0.2, 0.2, 0.3)
    if universe_alignment < -33:
        # More chaotic
        vis_rect.color = Color(0.4, 0.1, 0.2, 0.7)
    elif universe_alignment > 33:
        # More ordered
        vis_rect.color = Color(0.1, 0.4, 0.2, 0.7)
    else:
        # Neutral
        vis_rect.color = Color(0.3, 0.3, 0.1, 0.7)

func generate_access_points():
    # Clear existing access points
    access_points.clear()
    
    # Generate random number of access points
    var num_points = randi() % 15 + 5
    
    for i in range(num_points):
        var ap = {
            "id": "U" + str(randi() % 1000).pad_zeros(3) + "-" + str(randi() % 100).pad_zeros(2),
            "type": UNIVERSE_TYPES[randi() % UNIVERSE_TYPES.size()],
            "stability": randf_range(0, 100),
            "energy": randf_range(0, 100),
            "proximity": randf_range(0, 100),
            "alignment": randf_range(-100, 100),
            "synchronized": randf_range(0, 100),
            "description": "A " + UNIVERSE_TYPES[randi() % UNIVERSE_TYPES.size()].to_lower() + " universe with unique properties."
        }
        access_points.append(ap)

func update_access_points_ui():
    var access_list = access_points_panel.get_node("AccessPointsList")
    access_list.clear()
    
    # Get the current filter
    var filter_dropdown = access_points_panel.get_node("TypeFilter")
    var filter_index = filter_dropdown.selected
    var filter_type = ""
    if filter_index > 0:
        filter_type = UNIVERSE_TYPES[filter_index - 1]
    
    # Get the current sort option
    var sort_dropdown = access_points_panel.get_node("SortOption")
    var sort_index = sort_dropdown.selected
    
    # Sort the access points
    var sorted_points = access_points.duplicate()
    match sort_index:
        0: # Proximity
            sorted_points.sort_custom(func(a, b): return a.proximity > b.proximity)
        1: # Stability
            sorted_points.sort_custom(func(a, b): return a.stability > b.stability)
        2: # Energy
            sorted_points.sort_custom(func(a, b): return a.energy > b.energy)
        3: # Alignment
            sorted_points.sort_custom(func(a, b): return abs(a.alignment) < abs(b.alignment))
    
    # Populate the list with filtered and sorted access points
    for ap in sorted_points:
        # Apply filter if set
        if not filter_type.is_empty() and ap.type != filter_type:
            continue
            
        # Create item text and icon
        var item_text = ap.id + " - " + ap.type
        var icon_color = Color.WHITE
        
        # Set color based on alignment
        if ap.alignment < -33:
            icon_color = Color(1.0, 0.3, 0.3)
        elif ap.alignment > 33:
            icon_color = Color(0.3, 1.0, 0.3)
        else:
            icon_color = Color(1.0, 1.0, 0.3)
        
        # Add to list with appropriate icon
        access_list.add_item(item_text)
        var idx = access_list.get_item_count() - 1
        
        # Add custom metadata for access to details when selected
        access_list.set_item_metadata(idx, ap)
        
        # Set custom icon color
        var icon = ColorRect.new()
        icon.color = icon_color
        icon.custom_minimum_size = Vector2(16, 16)
        access_list.set_item_icon(idx, null) # This would be a custom icon in a real implementation

# Event handlers

func _on_update_timer_timeout():
    # Update cosmic turn (occasionally)
    if randf() > 0.8:
        current_cosmic_turn += 1
        
    # Slightly adjust alignment and synchronization
    universe_alignment += randf_range(-5, 5)
    universe_alignment = clamp(universe_alignment, -100, 100)
    
    universe_synchronization += randf_range(-3, 3)
    universe_synchronization = clamp(universe_synchronization, 0, 100)
    
    # Update metanarrative progress (slowly)
    metanarrative_progress += randf_range(0, 0.5)
    metanarrative_progress = min(metanarrative_progress, 100)
    
    # Update UI
    update_cosmic_data_ui()
    update_metanarrative_ui()
    update_alignment_ui()

func _on_refresh_button_pressed():
    load_universe_data()

func _on_travel_button_pressed():
    var access_list = access_points_panel.get_node("AccessPointsList")
    var selected_items = access_list.get_selected_items()
    
    if selected_items.size() > 0:
        var selected_idx = selected_items[0]
        var ap = access_list.get_item_metadata(selected_idx)
        
        # Set current universe to the selected one
        current_universe_id = ap.id
        
        # Update UI
        update_current_universe_ui()
        
        # Regenerate access points from this new universe
        generate_access_points()
        update_access_points_ui()
        
        # Update alignment and cosmic data
        universe_alignment = ap.alignment
        universe_synchronization = ap.synchronized
        update_alignment_ui()
        
        # Show a transition effect (placeholder)
        var transition = ColorRect.new()
        transition.color = Color(1, 1, 1, 0)
        transition.anchor_right = 1.0
        transition.anchor_bottom = 1.0
        add_child(transition)
        
        var tween = create_tween()
        tween.tween_property(transition, "color", Color(1, 1, 1, 1), 0.5)
        tween.tween_property(transition, "color", Color(1, 1, 1, 0), 0.5)
        tween.tween_callback(transition.queue_free)

func _on_type_filter_selected(index):
    update_access_points_ui()

func _on_sort_option_selected(index):
    update_access_points_ui()

func _on_access_point_selected(index):
    var ap = access_points_panel.get_node("AccessPointsList").get_item_metadata(index)
    var details_text = access_points_panel.get_node("DetailsText")
    
    # Format the details text
    var alignment_text = ""
    if ap.alignment < -33:
        alignment_text = "Chaotic"
    elif ap.alignment > 33:
        alignment_text = "Ordered"
    else:
        alignment_text = "Neutral"
    
    var sync_text = ""
    if ap.synchronized < 33:
        sync_text = "Asynchronous"
    elif ap.synchronized < 66:
        sync_text = "Partially Synchronized"
    else:
        sync_text = "Fully Synchronized"
    
    details_text.text = "[b]Universe ID:[/b] " + ap.id + "\n"
    details_text.text += "[b]Type:[/b] " + ap.type + "\n"
    details_text.text += "[b]Stability:[/b] " + str(int(ap.stability)) + "%\n"
    details_text.text += "[b]Energy Level:[/b] " + str(int(ap.energy)) + "%\n"
    details_text.text += "[b]Proximity:[/b] " + str(int(ap.proximity)) + "%\n"
    details_text.text += "[b]Alignment:[/b] " + alignment_text + " (" + str(int(ap.alignment)) + ")\n"
    details_text.text += "[b]Synchronization:[/b] " + sync_text + " (" + str(int(ap.synchronized)) + "%)\n\n"
    details_text.text += "[b]Description:[/b]\n" + ap.description