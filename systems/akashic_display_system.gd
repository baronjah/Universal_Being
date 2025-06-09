extends Node

# Display settings
@export var max_visible_records: int = 100
@export var auto_scroll: bool = true
@export var record_fade_time: float = 0.5
@export var highlight_duration: float = 2.0

# Record state
var records: Array[Dictionary] = []
var current_filter: String = ""
var is_display_visible: bool = false
var highlighted_record: int = -1

# Record types and their colors
var record_colors: Dictionary = {
    "creation": Color(0.2, 0.8, 0.2),  # Green
    "modification": Color(0.8, 0.8, 0.2),  # Yellow
    "evolution": Color(0.8, 0.2, 0.8),  # Purple
    "interaction": Color(0.2, 0.2, 0.8),  # Blue
    "system": Color(0.8, 0.2, 0.2),  # Red
    "gemma": Color(0.2, 0.8, 0.8),  # Cyan
    "default": Color(0.8, 0.8, 0.8)  # White
}

# Signals
signal record_added(record: Dictionary)
signal record_filtered(filter: String)
signal display_toggled(visible: bool)

func _ready() -> void:
    # Connect to parent UniversalBeing
    var parent = get_parent()
    if parent and parent.has_method("pentagon_ready"):
        parent.pentagon_ready.connect(_on_parent_ready)
    
    # Connect to Akashic Library
    var library = get_node_or_null("/root/UniversalBeing/AkashicLibrary")
    if library:
        library.record_created.connect(_on_record_created)

func _input(event: InputEvent) -> void:
    # Toggle display with F1
    if event.is_action_pressed("ui_focus_next"):  # F1 key
        _toggle_display()
    
    # Handle record navigation
    if is_display_visible:
        if event.is_action_pressed("ui_page_up"):
            _scroll_records(-10)
        elif event.is_action_pressed("ui_page_down"):
            _scroll_records(10)

func _on_parent_ready() -> void:
    # Initialize display with parent's consciousness
    var parent = get_parent()
    if parent and parent.has_method("get_consciousness_level"):
        var consciousness = parent.get_consciousness_level()
        if consciousness >= 3:
            max_visible_records = 200
            auto_scroll = true

func _on_record_created(record: Dictionary) -> void:
    # Add record to display
    records.append(record)
    if records.size() > max_visible_records * 2:  # Keep some history
        records.pop_front()
    
    # Update display
    _update_display()
    
    # Highlight new record
    _highlight_record(records.size() - 1)
    
    # Emit signal
    emit_signal("record_added", record)

func _update_display() -> void:
    var display = get_node_or_null("../AkashicContainer/RecordPanel/RecordScroll/RecordText")
    if not display:
        return
    
    # Clear display
    display.text = ""
    
    # Filter records if needed
    var filtered_records = records
    if not current_filter.is_empty():
        filtered_records = records.filter(func(r): return _matches_filter(r, current_filter))
    
    # Show records
    var visible_count = min(filtered_records.size(), max_visible_records)
    var start_index = max(0, filtered_records.size() - visible_count)
    
    for i in range(start_index, filtered_records.size()):
        var record = filtered_records[i]
        var color = record_colors.get(record.get("type", "default"), record_colors.default)
        
        # Format record
        var text = _format_record(record, i == highlighted_record)
        display.append_text(text)
        
        # Add color
        var start = display.text.length() - text.length()
        display.add_theme_color_override("font_color", color)
    
    # Auto scroll if enabled
    if auto_scroll:
        var scroll = get_node_or_null("../AkashicContainer/RecordPanel/RecordScroll")
        if scroll:
            scroll.scroll_vertical = scroll.get_v_scroll_bar().max_value

func _format_record(record: Dictionary, is_highlighted: bool) -> String:
    var text = ""
    
    # Add timestamp
    var time = record.get("timestamp", "")
    text += "[%s] " % time
    
    # Add type
    var type = record.get("type", "default").to_upper()
    text += "[%s] " % type
    
    # Add being name if present
    var being = record.get("being_name", "")
    if not being.is_empty():
        text += "%s: " % being
    
    # Add message
    var message = record.get("message", "")
    text += message
    
    # Add highlight if needed
    if is_highlighted:
        text = ">>> " + text + " <<<"
    
    return text + "\n"

func _highlight_record(index: int) -> void:
    highlighted_record = index
    
    # Start highlight timer
    var timer = get_tree().create_timer(highlight_duration)
    await timer.timeout
    
    # Clear highlight if it's still this record
    if highlighted_record == index:
        highlighted_record = -1
        _update_display()

func _matches_filter(record: Dictionary, filter: String) -> bool:
    # Check if record matches filter
    var filter_lower = filter.to_lower()
    
    # Check type
    if record.get("type", "").to_lower().contains(filter_lower):
        return true
    
    # Check being name
    if record.get("being_name", "").to_lower().contains(filter_lower):
        return true
    
    # Check message
    if record.get("message", "").to_lower().contains(filter_lower):
        return true
    
    return false

func set_filter(filter: String) -> void:
    current_filter = filter
    emit_signal("record_filtered", filter)
    _update_display()

func _toggle_display() -> void:
    is_display_visible = !is_display_visible
    emit_signal("display_toggled", is_display_visible)
    
    # Update visibility
    var container = get_node_or_null("../AkashicContainer")
    if container:
        container.visible = is_display_visible

func _scroll_records(amount: int) -> void:
    var scroll = get_node_or_null("../AkashicContainer/RecordPanel/RecordScroll")
    if scroll:
        scroll.scroll_vertical = clamp(
            scroll.scroll_vertical + amount * 20,
            0,
            scroll.get_v_scroll_bar().max_value
        )

func get_record_count() -> int:
    return records.size()

func get_filtered_count() -> int:
    if current_filter.is_empty():
        return records.size()
    return records.filter(func(r): return _matches_filter(r, current_filter)).size()

func clear_records() -> void:
    records.clear()
    _update_display()

func export_records() -> String:
    var export_text = "Akashic Records Export\n"
    export_text += "=====================\n\n"
    
    for record in records:
        export_text += _format_record(record, false)
    
    return export_text 