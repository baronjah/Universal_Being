# ==================================================
# SCRIPT NAME: console_ui_fix.gd
# DESCRIPTION: Fixes console UI scaling and sizing issues
# PURPOSE: Ensure console scales properly with viewport
# CREATED: 2025-05-28 - Console UI scaling fix
# ==================================================

extends UniversalBeingBase
var console_manager: Node
var console_container: Control
var original_console_size: Vector2

func _ready() -> void:
	await get_tree().process_frame
	_apply_console_fixes()

func _apply_console_fixes() -> void:
	console_manager = get_node_or_null("/root/ConsoleManager")
	if not console_manager:
		print("[ConsoleUIFix] Console manager not found")
		return
	
	# Wait for console to be created
	await get_tree().process_frame
	
	# Find console container
	console_container = console_manager.console_container
	if not console_container:
		print("[ConsoleUIFix] Console container not found")
		return
	
	# Fix console sizing
	_fix_console_sizing()
	
	# Connect to viewport changes
	var viewport_manager = get_node_or_null("/root/DynamicViewportManager")
	if viewport_manager:
		viewport_manager.viewport_changed.connect(_on_viewport_changed)
	
	print("[ConsoleUIFix] Console UI fixes applied")

func _fix_console_sizing() -> void:
	if not console_container:
		return
	
	# Get viewport size
	var viewport_size = get_viewport().size
	
	# Set console to reasonable percentage of screen
	var console_width = min(viewport_size.x * 0.5, 800)  # 50% width, max 800px
	var console_height = min(viewport_size.y * 0.4, 400)  # 40% height, max 400px
	
	# Find the console panel
	var console_panel = console_container.get_child(0) if console_container.get_child_count() > 0 else null
	if console_panel:
		# Update size
		console_panel.custom_minimum_size = Vector2(console_width, console_height)
		
		# Find output scroll
		var output_scroll = _find_node_by_type(console_panel, "ScrollContainer")
		if output_scroll:
			output_scroll.custom_minimum_size = Vector2(console_width - 20, console_height - 100)
		
		# Find output display
		var output_display = _find_node_by_type(console_panel, "RichTextLabel")
		if output_display:
			# Ensure text isn't too small
			output_display.add_theme_font_size_override("normal_font_size", 14)
			output_display.add_theme_font_size_override("bold_font_size", 14)
			output_display.add_theme_font_size_override("italics_font_size", 14)
			output_display.add_theme_font_size_override("mono_font_size", 14)
	
	# Center console
	_center_console()

func _center_console() -> void:
	if not console_container:
		return
	
	var viewport_size = get_viewport().size
	console_container.position = (Vector2(viewport_size) - console_container.size) / 2

func _find_node_by_type(parent: Node, type_name: String) -> Node:
	if parent.get_class() == type_name:
		return parent
	
	for child in parent.get_children():
		var result = _find_node_by_type(child, type_name)
		if result:
			return result
	
	return null

func _on_viewport_changed(_new_size: Vector2i) -> void:
	# Reapply fixes when viewport changes
	_fix_console_sizing()

# Also fix the scale command
func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		# Patch the scale command
		await get_tree().process_frame
		await get_tree().process_frame
		
		if console_manager and console_manager.has_method("register_command"):
			console_manager.register_command("fix_console", _cmd_fix_console, "Fix console sizing issues")
			console_manager.register_command("console_scale", _cmd_console_scale, "Set console UI scale")

func _cmd_fix_console(_args: Array) -> void:
	_fix_console_sizing()
	console_manager._print_to_console("[color=green]Console sizing fixed[/color]")

func _cmd_console_scale(args: Array) -> void:
	if args.size() == 0:
		console_manager._print_to_console("Usage: console_scale <0.5-2.0>")
		return
	
	var scale_factor = clamp(float(args[0]), 0.5, 2.0)
	
	if console_container:
		console_container.scale = Vector2(scale_factor, scale_factor)
		console_manager._print_to_console("[color=green]Console scale set to: " + str(scale_factor) + "[/color]")
	else:
		console_manager._print_to_console("[color=red]Console container not found[/color]")

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass