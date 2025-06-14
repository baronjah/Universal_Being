extends Control

# References to UI elements
onready var input_text = $VBoxContainer/InputSection/InputText
onready var dimension_option = $VBoxContainer/DimensionSelector/DimensionOption
onready var transform_button = $VBoxContainer/DimensionSelector/TransformButton
onready var chain_transform_button = $VBoxContainer/DimensionSelector/ChainTransformButton
onready var activate_button = $VBoxContainer/DimensionSelector/ActivateButton
onready var deactivate_button = $VBoxContainer/DimensionSelector/DeactivateButton
onready var output_text = $VBoxContainer/OutputSection/OutputText
onready var status_text = $VBoxContainer/StatusSection/StatusPanel/StatusText
onready var refresh_status_button = $VBoxContainer/RefreshStatusButton
onready var save_button = $VBoxContainer/SaveLoadSection/SaveButton
onready var load_button = $VBoxContainer/SaveLoadSection/LoadButton
onready var clear_button = $VBoxContainer/SaveLoadSection/ClearButton

# References to our dimensional systems
var dimension_bridge: DimensionalDataBridge
var data_processor: OfflineDataProcessor

# Saved file path
const SAVE_PATH = "user://dimensional_data.json"

func _ready():
    # Initialize the dimensional data bridge
    dimension_bridge = DimensionalDataBridge.new()
    add_child(dimension_bridge)
    
    # Get reference to the processor
    data_processor = dimension_bridge.get_processor()
    
    # Set up UI
    _setup_dimension_dropdown()
    _connect_signals()
    
    # Update status display
    _refresh_status()

func _setup_dimension_dropdown():
    dimension_option.clear()
    
    # Add dimensions to dropdown
    for dim_id in DimensionalDataBridge.DIMENSION_NAMES:
        # Skip VOID dimension
        if dim_id == 0:
            continue
            
        dimension_option.add_item(DimensionalDataBridge.DIMENSION_NAMES[dim_id], dim_id)
    
    # Set initial selection to SPACE (3)
    for i in range(dimension_option.get_item_count()):
        if dimension_option.get_item_id(i) == 3:  # SPACE dimension
            dimension_option.select(i)
            break

func _connect_signals():
    transform_button.connect("pressed", self, "_on_transform_pressed")
    chain_transform_button.connect("pressed", self, "_on_chain_transform_pressed")
    activate_button.connect("pressed", self, "_on_activate_pressed")
    deactivate_button.connect("pressed", self, "_on_deactivate_pressed")
    refresh_status_button.connect("pressed", self, "_refresh_status")
    save_button.connect("pressed", self, "_on_save_pressed")
    load_button.connect("pressed", self, "_on_load_pressed")
    clear_button.connect("pressed", self, "_on_clear_pressed")
    
    # Connect dimensional bridge signals
    dimension_bridge.connect("dimension_changed", self, "_on_dimension_changed")
    dimension_bridge.connect("transformation_completed", self, "_on_transformation_completed")

func _on_transform_pressed():
    var text_input = input_text.text
    if text_input.empty():
        _show_error("Please enter some text to transform.")
        return
    
    var selected_dimension = dimension_option.get_selected_id()
    var result = dimension_bridge.transform(text_input, selected_dimension)
    
    if result.success:
        _display_output(result.data, selected_dimension)
    else:
        _show_error("Transformation failed: " + str(result.error))
    
    _refresh_status()

func _on_chain_transform_pressed():
    var text_input = input_text.text
    if text_input.empty():
        _show_error("Please enter some text to transform.")
        return
    
    # Chain through multiple dimensions
    var chain_dimensions = [
        data_processor.DimensionalPlane.ESSENCE,  # First distill to core
        data_processor.DimensionalPlane.ENERGY,   # Then amplify
        data_processor.DimensionalPlane.FORM      # Then apply pattern/structure
    ]
    
    var result = dimension_bridge.transform_chain(text_input, chain_dimensions)
    
    if result.success:
        output_text.bbcode_text = "[b]CHAIN TRANSFORMATION:[/b]\n"
        output_text.bbcode_text += "[color=#00aaff]Through dimensions: ESSENCE → ENERGY → FORM[/color]\n\n"
        output_text.bbcode_text += result.data
    else:
        _show_error("Chain transformation failed: " + str(result.error))
    
    _refresh_status()

func _on_activate_pressed():
    var selected_dimension = dimension_option.get_selected_id()
    dimension_bridge.activate_dimension(selected_dimension)
    
    output_text.bbcode_text = "[b]DIMENSION ACTIVATED:[/b] " + DimensionalDataBridge.DIMENSION_NAMES[selected_dimension]
    _refresh_status()

func _on_deactivate_pressed():
    var selected_dimension = dimension_option.get_selected_id()
    dimension_bridge.deactivate_dimension(selected_dimension)
    
    output_text.bbcode_text = "[b]DIMENSION DEACTIVATED:[/b] " + DimensionalDataBridge.DIMENSION_NAMES[selected_dimension]
    _refresh_status()

func _on_save_pressed():
    var text_input = input_text.text
    if text_input.empty():
        _show_error("Please enter some text to save.")
        return
    
    var selected_dimension = dimension_option.get_selected_id()
    var success = dimension_bridge.save_dimensional_data(
        {"text": text_input, "timestamp": OS.get_unix_time()},
        SAVE_PATH,
        selected_dimension
    )
    
    if success:
        output_text.bbcode_text = "[b]DATA SAVED:[/b] Successfully saved dimensional data to " + SAVE_PATH
    else:
        _show_error("Failed to save dimensional data.")
    
    _refresh_status()

func _on_load_pressed():
    var result = dimension_bridge.load_dimensional_data(SAVE_PATH)
    
    if result.success:
        var source_dimension = result.source_dimension
        var dimension_name = DimensionalDataBridge.DIMENSION_NAMES.get(source_dimension, "UNKNOWN")
        
        output_text.bbcode_text = "[b]LOADED DATA:[/b]\n"
        output_text.bbcode_text += "[color=#00aaff]From dimension: " + dimension_name + "[/color]\n\n"
        
        if typeof(result.data) == TYPE_DICTIONARY:
            if result.data.has("text"):
                input_text.text = result.data.text
                output_text.bbcode_text += result.data.text
            else:
                output_text.bbcode_text += str(result.data)
        else:
            output_text.bbcode_text += str(result.data)
    else:
        _show_error("Failed to load dimensional data: " + str(result.error))

func _on_clear_pressed():
    input_text.text = ""
    output_text.bbcode_text = ""

func _on_dimension_changed(dimension_id, dimension_name):
    output_text.bbcode_text = "[b]CURRENT DIMENSION CHANGED:[/b] " + dimension_name
    _refresh_status()

func _on_transformation_completed(source_dim, target_dim, success):
    # This signal can be used for additional effects or logging
    pass

func _display_output(data, dimension_id):
    var dimension_name = DimensionalDataBridge.DIMENSION_NAMES.get(dimension_id, "UNKNOWN")
    
    output_text.bbcode_text = "[b]TRANSFORMATION RESULT:[/b]\n"
    output_text.bbcode_text += "[color=#00aaff]Through dimension: " + dimension_name + "[/color]\n\n"
    output_text.bbcode_text += str(data)

func _refresh_status():
    var stats = dimension_bridge.get_dimension_stats()
    
    status_text.bbcode_text = "[b]DIMENSIONAL SYSTEM STATUS:[/b]\n\n"
    
    # Current dimension
    status_text.bbcode_text += "[color=#ffff00]Current Primary Dimension:[/color] " + stats.current_dimension_name + " (" + str(stats.current_dimension) + ")\n\n"
    
    # Active dimensions
    status_text.bbcode_text += "[color=#ffff00]Active Dimensions:[/color]\n"
    for dim_id in stats.active_dimensions:
        var dim_name = stats.dimension_names[dim_id]
        var influence = data_processor.get_dimension_influence(dim_id)
        var strength = influence.strength * 100
        
        var color_code = "#ffffff"
        if dim_id == stats.current_dimension:
            color_code = "#00ff00"  # Highlight current dimension
        
        status_text.bbcode_text += "- [color=" + color_code + "]" + dim_name + " (" + str(dim_id) + "): " + str(stepify(strength, 0.1)) + "% active[/color]\n"
    
    # Dimension influence details
    status_text.bbcode_text += "\n[color=#ffff00]Dimensional Influences:[/color]\n"
    
    for dim_id in stats.dimension_influences:
        var dim_name = stats.dimension_names[dim_id]
        var aspects = stats.dimension_influences[dim_id].aspects
        
        status_text.bbcode_text += dim_name + " aspects:\n"
        
        for aspect in aspects:
            var value = aspects[aspect] * 100
            status_text.bbcode_text += "   - " + aspect + ": " + str(stepify(value, 0.1)) + "%\n"
        
        status_text.bbcode_text += "\n"

func _show_error(message: String):
    output_text.bbcode_text = "[color=#ff0000][b]ERROR:[/b] " + message + "[/color]"