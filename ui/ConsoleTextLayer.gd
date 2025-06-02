# ==================================================
# CONSOLE TEXT LAYER - 2D Background Text System
# PURPOSE: Terminal-like text layers with background highlighting
# LOCATION: ui/ConsoleTextLayer.gd
# ==================================================

extends Control
class_name ConsoleTextLayer

## Text display properties
@export var font_size: int = 16
@export var line_height: int = 20
@export var background_color: Color = Color(0.1, 0.1, 0.1, 0.8)
@export var text_color: Color = Color(0.9, 0.9, 0.9, 1.0)
@export var caret_color: Color = Color(0.0, 1.0, 0.0, 1.0)
@export var selection_color: Color = Color(0.2, 0.4, 0.8, 0.5)

## Console state
var lines: Array[String] = []
var caret_position: Vector2i = Vector2i(0, 0)  # Column, Row
var caret_visible: bool = true
var caret_blink_timer: float = 0.0
var selection_start: Vector2i = Vector2i(-1, -1)
var selection_end: Vector2i = Vector2i(-1, -1)

## Font and rendering
var console_font: Font
var char_size: Vector2

## Caret character - the beautiful block cursor
const CARET_CHAR = "█"
const CARET_BLINK_SPEED = 1.0  # Blinks per second

func _ready():
    # Setup font
    if not console_font:
        console_font = ThemeDB.fallback_font
    
    char_size = console_font.get_string_size("M", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
    
    # Initialize with empty console
    clear_console()
    
    # Start caret blinking
    var timer = Timer.new()
    timer.wait_time = 1.0 / CARET_BLINK_SPEED
    timer.timeout.connect(_blink_caret)
    timer.autostart = true
    add_child(timer)

func _draw():
    # Draw background
    draw_rect(Rect2(Vector2.ZERO, size), background_color)
    
    # Draw text lines
    for row in range(lines.size()):
        var line = lines[row]
        var y_pos = (row + 1) * line_height
        
        # Draw selection background if exists
        if selection_start.x >= 0 and selection_end.x >= 0:
            _draw_selection_for_line(row, y_pos)
        
        # Draw text
        for col in range(line.length()):
            var char = line[col]
            var x_pos = col * char_size.x
            
            # Draw character background if needed
            _draw_char_background(Vector2(x_pos, y_pos - char_size.y), char)
            
            # Draw character
            draw_string(console_font, Vector2(x_pos, y_pos), char, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)
    
    # Draw caret
    if caret_visible and caret_position.y < lines.size():
        _draw_caret()

func _draw_caret():
    """Draw the beautiful block caret"""
    var x_pos = caret_position.x * char_size.x
    var y_pos = (caret_position.y + 1) * line_height
    
    # Draw caret character
    draw_string(console_font, Vector2(x_pos, y_pos), CARET_CHAR, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, caret_color)

func _draw_char_background(pos: Vector2, char: String):
    """Draw background for special characters"""
    # You can extend this for highlighting specific characters
    pass

func _draw_selection_for_line(row: int, y_pos: float):
    """Draw selection background for a line"""
    if row < selection_start.y or row > selection_end.y:
        return
    
    var start_col = 0
    var end_col = lines[row].length()
    
    if row == selection_start.y:
        start_col = selection_start.x
    if row == selection_end.y:
        end_col = selection_end.x
    
    if start_col < end_col:
        var rect = Rect2(
            Vector2(start_col * char_size.x, y_pos - char_size.y),
            Vector2((end_col - start_col) * char_size.x, char_size.y)
        )
        draw_rect(rect, selection_color)

## Console manipulation methods
func clear_console():
    """Clear all console content"""
    lines = [""]
    caret_position = Vector2i(0, 0)
    clear_selection()
    queue_redraw()

func add_line(text: String = ""):
    """Add a new line to console"""
    lines.append(text)
    caret_position = Vector2i(0, lines.size() - 1)
    queue_redraw()

func insert_text(text: String):
    """Insert text at caret position"""
    if caret_position.y >= lines.size():
        add_line()
    
    var line = lines[caret_position.y]
    var before = line.substr(0, caret_position.x)
    var after = line.substr(caret_position.x)
    
    lines[caret_position.y] = before + text + after
    caret_position.x += text.length()
    queue_redraw()

func insert_char(char: String):
    """Insert single character at caret"""
    insert_text(char)

func delete_char():
    """Delete character before caret (backspace)"""
    if caret_position.x > 0:
        var line = lines[caret_position.y]
        var before = line.substr(0, caret_position.x - 1)
        var after = line.substr(caret_position.x)
        lines[caret_position.y] = before + after
        caret_position.x -= 1
        queue_redraw()
    elif caret_position.y > 0:
        # Join with previous line
        var current_line = lines[caret_position.y]
        var prev_line = lines[caret_position.y - 1]
        caret_position.x = prev_line.length()
        lines[caret_position.y - 1] = prev_line + current_line
        lines.remove_at(caret_position.y)
        caret_position.y -= 1
        queue_redraw()

func move_caret(direction: Vector2i):
    """Move caret in given direction"""
    var new_pos = caret_position + direction
    
    # Clamp to valid positions
    new_pos.y = clamp(new_pos.y, 0, lines.size() - 1)
    if new_pos.y < lines.size():
        new_pos.x = clamp(new_pos.x, 0, lines[new_pos.y].length())
    
    caret_position = new_pos
    queue_redraw()

## Selection methods
func start_selection():
    """Start text selection at caret"""
    selection_start = caret_position
    selection_end = caret_position

func extend_selection():
    """Extend selection to current caret position"""
    if selection_start.x >= 0:
        selection_end = caret_position
        queue_redraw()

func clear_selection():
    """Clear text selection"""
    selection_start = Vector2i(-1, -1)
    selection_end = Vector2i(-1, -1)
    queue_redraw()

func get_selected_text() -> String:
    """Get currently selected text"""
    if selection_start.x < 0 or selection_end.x < 0:
        return ""
    
    # TODO: Implement multi-line selection text extraction
    return ""

## Input handling
func _input(event):
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_LEFT:
                move_caret(Vector2i(-1, 0))
            KEY_RIGHT:
                move_caret(Vector2i(1, 0))
            KEY_UP:
                move_caret(Vector2i(0, -1))
            KEY_DOWN:
                move_caret(Vector2i(0, 1))
            KEY_BACKSPACE:
                delete_char()
            KEY_ENTER:
                add_line()
            _:
                if event.unicode >= 32:  # Printable characters
                    insert_char(char(event.unicode))

## Private methods
func _blink_caret():
    """Toggle caret visibility for blinking effect"""
    caret_visible = not caret_visible
    queue_redraw()

## Interface for Universal Being integration
func get_console_state() -> Dictionary:
    """Get current console state for AI"""
    return {
        "lines": lines,
        "caret_position": caret_position,
        "total_chars": _count_total_chars(),
        "current_line": lines[caret_position.y] if caret_position.y < lines.size() else ""
    }

func _count_total_chars() -> int:
    var total = 0
    for line in lines:
        total += line.length()
    return total