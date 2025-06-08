# ==================================================
# INTUITIVE INTERACTION SYSTEM  
# PURPOSE: Mouse-over tooltips, context menus, drag & drop for beings
# ARCHITECTURE: Direct manipulation instead of console commands
# ==================================================

extends Node
class_name IntuitiveInteractionSystem

# UI Components
var tooltip_popup: PanelContainer
var context_menu: PopupMenu
var discovery_journal: Control

# Interaction state
var hovered_being: UniversalBeing = null
var selected_being: UniversalBeing = null
var dragging_being: UniversalBeing = null
var drag_start_position: Vector3

# Discovery tracking
var discovered_combinations: Dictionary = {}
var discovered_evolutions: Array = []

# Visual feedback
var selection_highlight: MeshInstance3D
var hover_highlight: MeshInstance3D

signal being_context_menu_requested(being: UniversalBeing, position: Vector2)
signal beings_merged_by_drag(being_a: UniversalBeing, being_b: UniversalBeing)
signal discovery_made(type: String, data: Dictionary)

func _ready() -> void:
	print("🎮 Intuitive Interaction System: Initializing player-friendly controls...")
	setup_ui_components()
	setup_visual_highlights()
	setup_input_handling()
	connect_to_game_state()

func setup_ui_components() -> void:
	"""Create tooltip and context menu UI"""
	
	# Tooltip popup
	tooltip_popup = PanelContainer.new()
	tooltip_popup.name = "BeingTooltip"
	var tooltip_label = RichTextLabel.new()
	tooltip_label.fit_content = true
	tooltip_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	tooltip_popup.add_child(tooltip_label)
	get_tree().current_scene.add_child(tooltip_popup)
	tooltip_popup.hide()
	
	# Context menu
	context_menu = PopupMenu.new()
	context_menu.name = "BeingContextMenu"
	get_tree().current_scene.add_child(context_menu)
	context_menu.id_pressed.connect(_on_context_menu_selected)
	
	# Discovery journal (simple version)
	discovery_journal = Control.new()
	discovery_journal.name = "DiscoveryJournal"
	# Would implement full journal UI later
	
	print("🖥️ UI components created")

func setup_visual_highlights() -> void:
	"""Create visual highlights for hover/selection"""
	
	# Selection highlight (bright ring)
	selection_highlight = MeshInstance3D.new()
	var selection_mesh = TorusMesh.new()
	selection_mesh.inner_radius = 0.8
	selection_mesh.outer_radius = 1.2
	selection_highlight.mesh = selection_mesh
	
	var selection_material = StandardMaterial3D.new()
	selection_material.emission_enabled = true
	selection_material.emission = Color.YELLOW
	selection_material.emission_energy = 2.0
	selection_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	selection_material.albedo_color = Color(1, 1, 0, 0.5)
	selection_highlight.material_override = selection_material
	selection_highlight.visible = false
	get_tree().current_scene.add_child(selection_highlight)
	
	# Hover highlight (subtle glow)
	hover_highlight = MeshInstance3D.new()
	var hover_mesh = TorusMesh.new()
	hover_mesh.inner_radius = 0.9
	hover_mesh.outer_radius = 1.1
	hover_highlight.mesh = hover_mesh
	
	var hover_material = StandardMaterial3D.new()
	hover_material.emission_enabled = true
	hover_material.emission = Color.CYAN
	hover_material.emission_energy = 1.0
	hover_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hover_material.albedo_color = Color(0, 1, 1, 0.3)
	hover_highlight.material_override = hover_material
	hover_highlight.visible = false
	get_tree().current_scene.add_child(hover_highlight)
	
	print("✨ Visual highlights ready")

func setup_input_handling() -> void:
	"""Setup mouse input processing"""
	set_process_input(true)
	set_process(true)  # For continuous mouse-over detection

func connect_to_game_state() -> void:
	"""Connect to game state for interaction modes"""
	var game_state = GameStateSocketManager.get_instance()
	if game_state:
		game_state.state_changed.connect(_on_game_state_changed)

func _process(_delta: float) -> void:
	"""Continuous processing for mouse-over detection"""
	update_mouse_hover()
	update_visual_highlights()

func update_mouse_hover() -> void:
	"""Detect what being is under mouse cursor"""
	
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	# Raycast from camera
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	var new_hovered = null
	if result:
		var collider = result.collider
		# Find the Universal Being this collider belongs to
		var being = find_being_from_collider(collider)
		if being:
			new_hovered = being
	
	# Update hover state
	if new_hovered != hovered_being:
		if hovered_being:
			_on_being_hover_exit(hovered_being)
		
		hovered_being = new_hovered
		
		if hovered_being:
			_on_being_hover_enter(hovered_being)

func find_being_from_collider(collider: Node) -> UniversalBeing:
	"""Find Universal Being that owns a collider"""
	var current = collider
	while current:
		if current is UniversalBeing:
			return current
		current = current.get_parent()
	return null

func update_visual_highlights() -> void:
	"""Update position and visibility of highlights"""
	
	# Hover highlight
	if hovered_being and hovered_being != selected_being:
		hover_highlight.global_position = hovered_being.global_position
		hover_highlight.visible = true
		
		# Animate rotation
		hover_highlight.rotation.y += get_process_delta_time() * 2.0
	else:
		hover_highlight.visible = false
	
	# Selection highlight
	if selected_being:
		selection_highlight.global_position = selected_being.global_position
		selection_highlight.visible = true
		
		# Animate rotation (faster)
		selection_highlight.rotation.y += get_process_delta_time() * 3.0
	else:
		selection_highlight.visible = false

func _input(event: InputEvent) -> void:
	"""Handle mouse input for interaction"""
	
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					handle_left_click()
				MOUSE_BUTTON_RIGHT:
					handle_right_click(event.position)
		else:
			# Mouse released
			if event.button_index == MOUSE_BUTTON_LEFT and dragging_being:
				handle_drag_end()
	
	elif event is InputEventMouseMotion:
		if dragging_being:
			handle_drag_motion(event)

func handle_left_click() -> void:
	"""Handle left mouse click"""
	
	if hovered_being:
		if selected_being == hovered_being:
			# Double-click effect - start dragging
			start_dragging(hovered_being)
		else:
			# Select being
			select_being(hovered_being)
	else:
		# Click empty space - deselect
		select_being(null)

func handle_right_click(screen_position: Vector2) -> void:
	"""Handle right mouse click - show context menu"""
	
	if hovered_being:
		show_context_menu(hovered_being, screen_position)

func select_being(being: UniversalBeing) -> void:
	"""Select a being"""
	selected_being = being
	
	if being:
		print("🎯 Selected: %s (Level %d)" % [being.name, being.consciousness_level])
	else:
		print("🎯 Selection cleared")

func start_dragging(being: UniversalBeing) -> void:
	"""Start dragging a being"""
	dragging_being = being
	drag_start_position = being.global_position
	print("👆 Started dragging: %s" % being.name)

func handle_drag_motion(event: InputEventMouseMotion) -> void:
	"""Handle dragging motion"""
	if not dragging_being:
		return
	
	# Project mouse movement to 3D world
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	# Simple 3D movement based on mouse delta
	var sensitivity = 0.01
	var movement = Vector3(event.relative.x * sensitivity, 0, event.relative.y * sensitivity)
	
	# Apply movement relative to camera
	var camera_basis = camera.global_transform.basis
	var world_movement = camera_basis * movement
	
	dragging_being.global_position += world_movement
	print("👆 Dragging %s to %s" % [dragging_being.name, dragging_being.global_position])

func handle_drag_end() -> void:
	"""Handle end of dragging"""
	if not dragging_being:
		return
	
	# Check if we dropped on another being
	var drop_target = find_being_at_position(dragging_being.global_position)
	if drop_target and drop_target != dragging_being:
		attempt_merge(dragging_being, drop_target)
	
	dragging_being = null
	print("👆 Drag ended")

func find_being_at_position(position: Vector3) -> UniversalBeing:
	"""Find a being near the given position"""
	var beings = get_tree().get_nodes_in_group("universal_beings")
	
	for being in beings:
		if being is UniversalBeing and being.global_position.distance_to(position) < 2.0:
			return being
	
	return null

func show_context_menu(being: UniversalBeing, screen_position: Vector2) -> void:
	"""Show context menu for a being"""
	
	context_menu.clear()
	
	# Basic actions
	context_menu.add_item("Inspect %s" % being.name, 0)
	context_menu.add_separator()
	
	# Consciousness actions
	if being.consciousness_level < 7:
		context_menu.add_item("Awaken (%d → %d)" % [being.consciousness_level, being.consciousness_level + 1], 1)
	
	# Evolution options
	var evolution_options = get_evolution_options(being)
	if not evolution_options.is_empty():
		context_menu.add_submenu_item("Evolve into...", "evolution_submenu")
		# Would create submenu here
	
	# Interaction options
	if selected_being and selected_being != being:
		context_menu.add_separator()
		context_menu.add_item("Merge with %s" % selected_being.name, 2)
		context_menu.add_item("Gift Consciousness", 3)
	
	# Advanced actions for high consciousness
	if being.consciousness_level >= 3:
		context_menu.add_separator()
		context_menu.add_item("Enter Dreams", 4)
	
	if being.consciousness_level >= 5:
		context_menu.add_item("Transcendent Abilities", 5)
	
	# Show menu
	context_menu.position = Vector2i(screen_position)
	context_menu.popup()
	
	being_context_menu_requested.emit(being, screen_position)
	print("📋 Context menu shown for %s" % being.name)

func _on_context_menu_selected(id: int) -> void:
	"""Handle context menu selection"""
	if not hovered_being:
		return
	
	match id:
		0:  # Inspect
			show_being_inspection(hovered_being)
		1:  # Awaken consciousness
			awaken_consciousness(hovered_being)
		2:  # Merge
			if selected_being:
				attempt_merge(hovered_being, selected_being)
		3:  # Gift consciousness
			if selected_being:
				gift_consciousness(selected_being, hovered_being)
		4:  # Enter dreams
			enter_being_dreams(hovered_being)
		5:  # Transcendent abilities
			show_transcendent_menu(hovered_being)

func show_being_inspection(being: UniversalBeing) -> void:
	"""Show detailed inspection of a being"""
	var info = {
		"name": being.name,
		"consciousness_level": being.consciousness_level,
		"position": being.global_position,
		"type": being.get("being_type", "unknown"),
		"components": being.get_component_count() if being.has_method("get_component_count") else 0
	}
	
	print("🔍 Inspecting %s: %s" % [being.name, info])
	# Would show detailed UI panel

func awaken_consciousness(being: UniversalBeing) -> void:
	"""Increase being's consciousness level"""
	if being.has_method("set_consciousness_level"):
		var new_level = being.consciousness_level + 1
		being.set_consciousness_level(new_level)
		
		# Record discovery
		record_discovery("consciousness_awakening", {
			"being": being.name,
			"from_level": being.consciousness_level - 1,
			"to_level": new_level
		})
		
		print("🧠 Awakened %s to consciousness level %d" % [being.name, new_level])

func attempt_merge(being_a: UniversalBeing, being_b: UniversalBeing) -> void:
	"""Attempt to merge two beings"""
	print("🔀 Attempting merge: %s + %s" % [being_a.name, being_b.name])
	
	# Check if merge is possible
	if can_merge_beings(being_a, being_b):
		perform_merge(being_a, being_b)
	else:
		print("❌ Merge not possible between %s and %s" % [being_a.name, being_b.name])

func can_merge_beings(being_a: UniversalBeing, being_b: UniversalBeing) -> bool:
	"""Check if two beings can merge"""
	# Simple rule: similar consciousness levels can merge
	var level_diff = abs(being_a.consciousness_level - being_b.consciousness_level)
	return level_diff <= 2

func perform_merge(being_a: UniversalBeing, being_b: UniversalBeing) -> void:
	"""Actually merge two beings"""
	
	# Calculate merged properties
	var new_consciousness = max(being_a.consciousness_level, being_b.consciousness_level) + 1
	var merge_position = (being_a.global_position + being_b.global_position) / 2
	
	# Create merged being (simplified)
	print("✨ Merging %s and %s into new being with consciousness %d" % [being_a.name, being_b.name, new_consciousness])
	
	# Record discovery
	record_discovery("being_merge", {
		"being_a": being_a.name,
		"being_b": being_b.name,
		"result_consciousness": new_consciousness
	})
	
	beings_merged_by_drag.emit(being_a, being_b)

func gift_consciousness(giver: UniversalBeing, receiver: UniversalBeing) -> void:
	"""Transfer consciousness from one being to another"""
	if giver.consciousness_level > receiver.consciousness_level:
		var gift_amount = 1
		if giver.has_method("set_consciousness_level"):
			giver.set_consciousness_level(giver.consciousness_level - gift_amount)
		if receiver.has_method("set_consciousness_level"):
			receiver.set_consciousness_level(receiver.consciousness_level + gift_amount)
		
		print("💝 %s gifted consciousness to %s" % [giver.name, receiver.name])

func enter_being_dreams(being: UniversalBeing) -> void:
	"""Enter the dream state of a being"""
	print("💭 Entering dreams of %s..." % being.name)
	# Would implement dream exploration mode

func show_transcendent_menu(being: UniversalBeing) -> void:
	"""Show special abilities for transcendent beings"""
	print("🌟 Transcendent abilities for %s" % being.name)
	# Would show special high-level abilities

func get_evolution_options(being: UniversalBeing) -> Array:
	"""Get possible evolution paths for a being"""
	var options = []
	
	# This would connect to the actual evolution system
	match being.consciousness_level:
		0, 1:
			options = ["butterfly", "tree", "crystal"]
		2, 3:
			options = ["portal", "universe", "constellation"]
		4, 5:
			options = ["galaxy", "dimension", "pure_consciousness"]
	
	return options

func record_discovery(type: String, data: Dictionary) -> void:
	"""Record a discovery for the journal"""
	
	var discovery = {
		"type": type,
		"data": data,
		"timestamp": Time.get_ticks_msec(),
		"session_id": Time.get_datetime_string_from_system()
	}
	
	# Add to discovered combinations
	var key = "%s_%s" % [type, str(data)]
	if not discovered_combinations.has(key):
		discovered_combinations[key] = discovery
		discovery_made.emit(type, data)
		print("📔 New discovery recorded: %s" % type)

func _on_being_hover_enter(being: UniversalBeing) -> void:
	"""Handle mouse entering a being"""
	show_tooltip(being)

func _on_being_hover_exit(being: UniversalBeing) -> void:
	"""Handle mouse leaving a being"""
	hide_tooltip()

func show_tooltip(being: UniversalBeing) -> void:
	"""Show tooltip for a being"""
	if not tooltip_popup:
		return
	
	var label = tooltip_popup.get_child(0) as RichTextLabel
	if label:
		var consciousness_color = get_consciousness_color(being.consciousness_level)
		var tooltip_text = "[center][color=%s]%s[/color]\nLevel %d Consciousness\n[color=gray]%s[/color][/center]" % [
			consciousness_color.to_html(),
			being.name,
			being.consciousness_level,
			get_consciousness_description(being.consciousness_level)
		]
		label.text = tooltip_text
	
	# Position tooltip near mouse
	var mouse_pos = get_viewport().get_mouse_position()
	tooltip_popup.position = Vector2i(mouse_pos.x + 20, mouse_pos.y - 50)
	tooltip_popup.show()

func hide_tooltip() -> void:
	"""Hide the tooltip"""
	if tooltip_popup:
		tooltip_popup.hide()

func get_consciousness_color(level: int) -> Color:
	"""Get color for consciousness level"""
	var colors = {
		0: Color.GRAY,
		1: Color(0.9, 0.9, 0.9),
		2: Color(0.2, 0.4, 1.0),
		3: Color(0.2, 1.0, 0.2), 
		4: Color(1.0, 0.84, 0.0),
		5: Color.WHITE,
		6: Color(1.0, 0.2, 0.2),
		7: Color(0.8, 0.3, 1.0)
	}
	return colors.get(level, Color.WHITE)

func get_consciousness_description(level: int) -> String:
	"""Get description for consciousness level"""
	var descriptions = {
		0: "Dormant - Sleeping potential",
		1: "Awakening - First awareness",
		2: "Aware - Observing reality", 
		3: "Connected - Sensing others",
		4: "Enlightened - Understanding flows",
		5: "Transcendent - Beyond material",
		6: "Beyond - Infinite perspective",
		7: "Universal - One with all"
	}
	return descriptions.get(level, "Unknown state")

func _on_game_state_changed(old_state, new_state) -> void:
	"""React to game state changes"""
	# Could disable interaction during console mode, etc.

print("🎮 Intuitive Interaction System: Player-friendly controls ready!")