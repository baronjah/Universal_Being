extends Node

# Simple controller for the Words in Space 3D demo

# References
@onready var words_in_space = get_node("../WordsInSpace3D")
@onready var ui = get_node("../UI")

# UI Elements
@onready var word_input = get_node("../UI/Panel/VBoxContainer/WordInput")
@onready var category_option = get_node("../UI/Panel/VBoxContainer/CategoryOption")
@onready var add_word_button = get_node("../UI/Panel/VBoxContainer/AddWordButton")
@onready var pulse_checkbox = get_node("../UI/Panel/VBoxContainer/PulseCheckBox")
@onready var rotation_checkbox = get_node("../UI/Panel/VBoxContainer/RotationCheckBox")
@onready var glow_checkbox = get_node("../UI/Panel/VBoxContainer/GlowCheckBox")
@onready var grid_checkbox = get_node("../UI/Panel/VBoxContainer/GridCheckBox")
@onready var word1_option = get_node("../UI/Panel/VBoxContainer/Word1Option")
@onready var word2_option = get_node("../UI/Panel/VBoxContainer/Word2Option")
@onready var connect_button = get_node("../UI/Panel/VBoxContainer/ConnectButton")
@onready var export_button = get_node("../UI/Panel/VBoxContainer/ExportButton")

# State
var random_positions = true
var grid_size = Vector3(10, 10, 10)
var grid_cell_size = Vector3(1.0, 1.0, 1.0)

func _ready():
    # Connect UI signals
    add_word_button.pressed.connect(_on_add_word_button_pressed)
    pulse_checkbox.toggled.connect(_on_pulse_checkbox_toggled)
    rotation_checkbox.toggled.connect(_on_rotation_checkbox_toggled)
    glow_checkbox.toggled.connect(_on_glow_checkbox_toggled)
    grid_checkbox.toggled.connect(_on_grid_checkbox_toggled)
    connect_button.pressed.connect(_on_connect_button_pressed)
    export_button.pressed.connect(_on_export_button_pressed)
    
    # Initial state
    pulse_checkbox.button_pressed = true
    rotation_checkbox.button_pressed = true
    glow_checkbox.button_pressed = true
    grid_checkbox.button_pressed = true
    
    # Demo data
    if words_in_space:
        # Will use the built-in demo population
        pass

# Add a new word from the UI
func _on_add_word_button_pressed():
    var word_text = word_input.text.strip_edges()
    if word_text.is_empty():
        return
    
    var category = category_option.get_item_text(category_option.selected)
    
    # Generate random position in the grid
    var position = Vector3(
        randf_range(0, grid_size.x * grid_cell_size.x),
        randf_range(0, grid_size.y * grid_cell_size.y),
        randf_range(0, grid_size.z * grid_cell_size.z)
    )
    
    # Add the word to the space
    var word_id = words_in_space.add_word(word_text, position, category)
    
    # Update word dropdown menus
    _update_word_dropdowns()
    
    # Clear input
    word_input.text = ""

# Toggle pulse effect
func _on_pulse_checkbox_toggled(button_pressed):
    if words_in_space:
        words_in_space.pulse_effect_active = button_pressed

# Toggle rotation effect
func _on_rotation_checkbox_toggled(button_pressed):
    if words_in_space:
        words_in_space.rotation_effect_active = button_pressed

# Toggle glow effect
func _on_glow_checkbox_toggled(button_pressed):
    if words_in_space:
        words_in_space.glow_effect_active = button_pressed

# Toggle grid visibility
func _on_grid_checkbox_toggled(button_pressed):
    if words_in_space and words_in_space.has_node("3DGrid"):
        words_in_space.get_node("3DGrid").visible = button_pressed

# Connect two words
func _on_connect_button_pressed():
    if word1_option.selected == -1 or word2_option.selected == -1:
        return
    
    var word1_id = word1_option.get_item_metadata(word1_option.selected)
    var word2_id = word2_option.get_item_metadata(word2_option.selected)
    
    if word1_id == word2_id:
        return
    
    # Connect the words
    words_in_space.connect_words(word1_id, word2_id)

# Export visualization
func _on_export_button_pressed():
    if words_in_space:
        var export_path = "user://words_visualization.tscn"
        var success = words_in_space.export_visualization(export_path)
        
        if success:
            print("Visualization exported successfully to: " + export_path)
        else:
            print("Failed to export visualization")

# Update word dropdown menus
func _update_word_dropdowns():
    if not words_in_space:
        return
    
    # Clear current items
    word1_option.clear()
    word2_option.clear()
    
    # Add all words to dropdown
    var index = 0
    for word_id in words_in_space.words_in_space:
        var word_text = words_in_space.words_in_space[word_id].text
        
        word1_option.add_item(word_text)
        word1_option.set_item_metadata(index, word_id)
        
        word2_option.add_item(word_text)
        word2_option.set_item_metadata(index, word_id)
        
        index += 1

# Create random connections
func create_random_connections(count = 5):
    if not words_in_space or words_in_space.words_in_space.size() < 2:
        return
    
    var word_ids = words_in_space.words_in_space.keys()
    
    for i in range(count):
        # Pick two random words
        var id1 = word_ids[randi() % word_ids.size()]
        var id2 = word_ids[randi() % word_ids.size()]
        
        # Ensure they're different
        while id1 == id2:
            id2 = word_ids[randi() % word_ids.size()]
        
        # Connect them
        words_in_space.connect_words(id1, id2)
    
    # Update word dropdowns after connections
    _update_word_dropdowns()