extends Node
class_name ObjectInspectorSystem

# 🔍 OBJECT INSPECTOR SYSTEM 🔍
# Real-time Universal Being transformation and scene editing interface
# The third of the 4 dead-end scripturas - reality editor

signal object_selected(object: Node3D, object_data: Dictionary)
signal object_transformed(object: Node3D, old_transform: Transform3D, new_transform: Transform3D)
signal universal_being_evolved(being: Node, old_type: String, new_type: String)
signal property_changed(object: Node, property_name: String, old_value, new_value)
signal reality_edited(edit_type: String, edit_data: Dictionary)

# Inspector modes
enum InspectorMode {
	OBJECT_SELECTION,
	PROPERTY_EDITING,
	TRANSFORMATION_MODE,
	UNIVERSAL_BEING_EVOLUTION,
	REALITY_EDITING,
	CONSCIOUSNESS_INSPECTION
}

# Selection and editing configuration
@export var enabled: bool = true
@export var visual_feedback_enabled: bool = true
@export var real_time_editing: bool = true
@export var consciousness_aware_editing: bool = true
@export var gizmo_size: float = 1.0

# Inspector state
var current_mode: InspectorMode = InspectorMode.OBJECT_SELECTION
var selected_objects: Array[Node3D] = []
var inspector_ui: ObjectInspectorUI
var transformation_gizmo: TransformationGizmo
var universal_being_editor: UniversalBeingEditor
var reality_editor: RealityEditor

# Interaction system
var mouse_sensitivity: float = 1.0
var keyboard_shortcuts_enabled: bool = true
var multi_selection_enabled: bool = true
var undo_redo_system: UndoRedoSystem

# Visual feedback
var selection_highlight_material: StandardMaterial3D
var transformation_preview_enabled: bool = true
var consciousness_visualization_enabled: bool = true

class ObjectInspectorUI:
	var ui_panel: Control
	var property_list: VBoxContainer
	var transformation_controls: VBoxContainer
	var evolution_controls: VBoxContainer
	var consciousness_display: Label
	
	var visible: bool = false
	var position: Vector2 = Vector2(50, 50)
	
	func _init():
		_create_ui_elements()
	
	func _create_ui_elements():
		ui_panel = Panel.new()
		ui_panel.size = Vector2(300, 500)
		ui_panel.position = position
		
		var vbox = VBoxContainer.new()
		ui_panel.add_child(vbox)
		
		# Title
		var title = Label.new()
		title.text = "🔍 OBJECT INSPECTOR"
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(title)
		
		# Property list
		property_list = VBoxContainer.new()
		vbox.add_child(property_list)
		
		# Transformation controls
		transformation_controls = VBoxContainer.new()
		vbox.add_child(transformation_controls)
		
		# Evolution controls
		evolution_controls = VBoxContainer.new()
		vbox.add_child(evolution_controls)
		
		# Consciousness display
		consciousness_display = Label.new()
		consciousness_display.text = "Consciousness: 0.0"
		vbox.add_child(consciousness_display)
	
	func show_inspector():
		visible = true
		ui_panel.visible = true
	
	func hide_inspector():
		visible = false
		ui_panel.visible = false
	
	func update_for_object(object: Node3D):
		_clear_controls()
		_populate_properties(object)
		_populate_transformation_controls(object)
		
		if object.has_method("get_consciousness_level"):
			consciousness_display.text = "Consciousness: %.2f" % object.get_consciousness_level()
		
		if _is_universal_being(object):
			_populate_evolution_controls(object)
	
	func _clear_controls():
		for child in property_list.get_children():
			child.queue_free()
		for child in transformation_controls.get_children():
			child.queue_free()
		for child in evolution_controls.get_children():
			child.queue_free()
	
	func _populate_properties(object: Node3D):
		var title = Label.new()
		title.text = "📋 PROPERTIES"
		property_list.add_child(title)
		
		# Object name
		var name_container = HBoxContainer.new()
		var name_label = Label.new()
		name_label.text = "Name:"
		var name_edit = LineEdit.new()
		name_edit.text = object.name
		name_edit.text_changed.connect(func(new_name): object.name = new_name)
		name_container.add_child(name_label)
		name_container.add_child(name_edit)
		property_list.add_child(name_container)
		
		# Position
		_add_vector3_property("Position", object.position, func(new_pos): object.position = new_pos)
		
		# Rotation
		_add_vector3_property("Rotation", object.rotation_degrees, func(new_rot): object.rotation_degrees = new_rot)
		
		# Scale
		_add_vector3_property("Scale", object.scale, func(new_scale): object.scale = new_scale)
		
		# Visibility
		var visibility_container = HBoxContainer.new()
		var visibility_label = Label.new()
		visibility_label.text = "Visible:"
		var visibility_check = CheckBox.new()
		visibility_check.button_pressed = object.visible
		visibility_check.toggled.connect(func(pressed): object.visible = pressed)
		visibility_container.add_child(visibility_label)
		visibility_container.add_child(visibility_check)
		property_list.add_child(visibility_container)
	
	func _add_vector3_property(property_name: String, current_value: Vector3, setter: Callable):
		var container = VBoxContainer.new()
		var label = Label.new()
		label.text = property_name + ":"
		container.add_child(label)
		
		var x_container = HBoxContainer.new()
		var x_label = Label.new()
		x_label.text = "X:"
		var x_spin = SpinBox.new()
		x_spin.value = current_value.x
		x_spin.step = 0.1
		x_spin.allow_greater = true
		x_spin.allow_lesser = true
		x_spin.value_changed.connect(func(new_x): 
			var new_vec = Vector3(new_x, current_value.y, current_value.z)
			current_value = new_vec
			setter.call(new_vec)
		)
		x_container.add_child(x_label)
		x_container.add_child(x_spin)
		container.add_child(x_container)
		
		# Similar for Y and Z...
		property_list.add_child(container)
	
	func _populate_transformation_controls(object: Node3D):
		var title = Label.new()
		title.text = "🔧 TRANSFORMATION"
		transformation_controls.add_child(title)
		
		# Transformation mode buttons
		var mode_container = HBoxContainer.new()
		
		var translate_btn = Button.new()
		translate_btn.text = "Move"
		translate_btn.pressed.connect(func(): _set_transformation_mode("translate"))
		
		var rotate_btn = Button.new()
		rotate_btn.text = "Rotate"
		rotate_btn.pressed.connect(func(): _set_transformation_mode("rotate"))
		
		var scale_btn = Button.new()
		scale_btn.text = "Scale"
		scale_btn.pressed.connect(func(): _set_transformation_mode("scale"))
		
		mode_container.add_child(translate_btn)
		mode_container.add_child(rotate_btn)
		mode_container.add_child(scale_btn)
		transformation_controls.add_child(mode_container)
		
		# Reset transform button
		var reset_btn = Button.new()
		reset_btn.text = "Reset Transform"
		reset_btn.pressed.connect(func(): _reset_transform(object))
		transformation_controls.add_child(reset_btn)
	
	func _populate_evolution_controls(object: Node):
		var title = Label.new()
		title.text = "🧬 UNIVERSAL BEING EVOLUTION"
		evolution_controls.add_child(title)
		
		# Evolution options
		var evolution_types = ["consciousness_orb", "evolution_crystal", "cosmic_gateway", "universal_container"]
		
		for evo_type in evolution_types:
			var btn = Button.new()
			btn.text = "Evolve to " + evo_type
			btn.pressed.connect(func(): _evolve_universal_being(object, evo_type))
			evolution_controls.add_child(btn)
		
		# Consciousness level control
		var consciousness_container = HBoxContainer.new()
		var consciousness_label = Label.new()
		consciousness_label.text = "Consciousness:"
		var consciousness_spin = SpinBox.new()
		consciousness_spin.min_value = 0.0
		consciousness_spin.max_value = 10.0
		consciousness_spin.step = 0.1
		if object.has_method("get_consciousness_level"):
			consciousness_spin.value = object.get_consciousness_level()
		consciousness_spin.value_changed.connect(func(new_level): 
			if object.has_method("set_consciousness_level"):
				object.set_consciousness_level(new_level)
		)
		consciousness_container.add_child(consciousness_label)
		consciousness_container.add_child(consciousness_spin)
		evolution_controls.add_child(consciousness_container)
	
	func _set_transformation_mode(mode: String):
		print("🔧 Transformation mode: %s" % mode)
	
	func _reset_transform(object: Node3D):
		object.position = Vector3.ZERO
		object.rotation = Vector3.ZERO
		object.scale = Vector3.ONE
	
	func _evolve_universal_being(being: Node, new_type: String):
		if being.has_method("evolve_to"):
			being.evolve_to(new_type)
		print("🧬 Evolving Universal Being to: %s" % new_type)
	
	func _is_universal_being(object: Node) -> bool:
		return object.has_method("pentagon_init") or object.get_script() and object.get_script().get_global_name() == "UniversalBeing"

class TransformationGizmo:
	var gizmo_node: Node3D
	var gizmo_meshes: Array[MeshInstance3D] = []
	var current_mode: String = "translate"
	var target_object: Node3D
	
	var x_axis_color: Color = Color.RED
	var y_axis_color: Color = Color.GREEN
	var z_axis_color: Color = Color.BLUE
	
	func _init():
		_create_gizmo()
	
	func _create_gizmo():
		gizmo_node = Node3D.new()
		gizmo_node.name = "TransformationGizmo"
		
		# Create axis arrows
		_create_axis_arrow(Vector3.RIGHT, x_axis_color, "x")
		_create_axis_arrow(Vector3.UP, y_axis_color, "y")
		_create_axis_arrow(Vector3.FORWARD, z_axis_color, "z")
	
	func _create_axis_arrow(direction: Vector3, color: Color, axis_name: String):
		var arrow = MeshInstance3D.new()
		var cylinder = CylinderMesh.new()
		cylinder.top_radius = 0.05
		cylinder.bottom_radius = 0.05
		cylinder.height = 2.0
		arrow.mesh = cylinder
		
		var material = StandardMaterial3D.new()
		material.albedo_color = color
		material.emission_enabled = true
		material.emission_color = color * 0.3
		arrow.material_override = material
		
		arrow.name = "GizmoAxis_" + axis_name
		arrow.look_at(arrow.position + direction, Vector3.UP)
		gizmo_node.add_child(arrow)
		gizmo_meshes.append(arrow)
	
	func show_for_object(object: Node3D):
		target_object = object
		gizmo_node.global_position = object.global_position
		gizmo_node.visible = true
	
	func hide():
		gizmo_node.visible = false
		target_object = null
	
	func update_position():
		if target_object:
			gizmo_node.global_position = target_object.global_position

class UniversalBeingEditor:
	func evolve_being(being: Node, new_type: String, consciousness_level: float = 1.0):
		"""Evolve Universal Being to new type"""
		if not being.has_method("pentagon_init"):
			print("⚠️ Object is not a Universal Being")
			return false
		
		var old_type = being.get("being_type", "unknown")
		
		# Apply evolution
		if being.has_method("evolve_to"):
			being.evolve_to(new_type)
		else:
			# Manual evolution
			being.being_type = new_type
			if being.has_method("set_consciousness_level"):
				being.set_consciousness_level(consciousness_level)
		
		print("🧬 Universal Being evolved: %s → %s" % [old_type, new_type])
		return true
	
	func clone_being(being: Node) -> Node:
		"""Clone Universal Being"""
		if not being.has_method("pentagon_init"):
			return null
		
		var clone = being.duplicate()
		clone.position += Vector3(2, 0, 0)  # Offset clone
		being.get_parent().add_child(clone)
		
		print("🧬 Universal Being cloned: %s" % clone.name)
		return clone
	
	func merge_beings(being_a: Node, being_b: Node) -> Node:
		"""Merge two Universal Beings"""
		if not (being_a.has_method("pentagon_init") and being_b.has_method("pentagon_init")):
			return null
		
		# Create merged being
		var merged = being_a.duplicate()
		merged.name = being_a.name + "_" + being_b.name + "_merged"
		merged.position = (being_a.position + being_b.position) * 0.5
		
		# Merge consciousness levels
		if being_a.has_method("get_consciousness_level") and being_b.has_method("get_consciousness_level"):
			var merged_consciousness = (being_a.get_consciousness_level() + being_b.get_consciousness_level()) * 0.5
			if merged.has_method("set_consciousness_level"):
				merged.set_consciousness_level(merged_consciousness)
		
		being_a.get_parent().add_child(merged)
		
		# Remove original beings
		being_a.queue_free()
		being_b.queue_free()
		
		print("🧬 Universal Beings merged: %s" % merged.name)
		return merged

class RealityEditor:
	func edit_scene_structure():
		"""Edit scene structure and reality"""
		pass
	
	func create_universal_being_at(position: Vector3, being_type: String = "basic") -> Node:
		"""Create new Universal Being at position"""
		var being_script = load("res://core/UniversalBeing.gd")
		if not being_script:
			print("🚨 UniversalBeing script not found")
			return null
		
		var new_being = Node3D.new()
		new_being.set_script(being_script)
		new_being.position = position
		new_being.name = "UniversalBeing_" + being_type + "_" + str(Time.get_ticks_msec())
		
		# Initialize being
		if new_being.has_method("pentagon_init"):
			new_being.pentagon_init()
		
		var scene = Engine.get_main_loop().current_scene
		if scene:
			scene.add_child(new_being)
		
		print("🌟 Created Universal Being: %s at %s" % [new_being.name, position])
		return new_being

class UndoRedoSystem:
	var undo_stack: Array[Dictionary] = []
	var redo_stack: Array[Dictionary] = []
	var max_undo_steps: int = 50
	
	func record_action(action_type: String, object: Node, property: String, old_value, new_value):
		var action = {
			"type": action_type,
			"object": object,
			"property": property,
			"old_value": old_value,
			"new_value": new_value,
			"timestamp": Time.get_ticks_msec() / 1000.0
		}
		
		undo_stack.append(action)
		if undo_stack.size() > max_undo_steps:
			undo_stack.pop_front()
		
		redo_stack.clear()  # Clear redo stack when new action is recorded
	
	func undo() -> bool:
		if undo_stack.size() == 0:
			return false
		
		var action = undo_stack.pop_back()
		redo_stack.append(action)
		
		_apply_action_reverse(action)
		return true
	
	func redo() -> bool:
		if redo_stack.size() == 0:
			return false
		
		var action = redo_stack.pop_back()
		undo_stack.append(action)
		
		_apply_action(action)
		return true
	
	func _apply_action(action: Dictionary):
		var object = action["object"]
		var property = action["property"]
		var new_value = action["new_value"]
		
		if is_instance_valid(object) and object.has_method("set"):
			object.set(property, new_value)
	
	func _apply_action_reverse(action: Dictionary):
		var object = action["object"]
		var property = action["property"]
		var old_value = action["old_value"]
		
		if is_instance_valid(object) and object.has_method("set"):
			object.set(property, old_value)

func _ready():
	name = "ObjectInspectorSystem"
	print("🔍 OBJECT INSPECTOR SYSTEM INITIALIZED - Reality editing interface active")
	
	# Initialize components
	inspector_ui = ObjectInspectorUI.new()
	transformation_gizmo = TransformationGizmo.new()
	universal_being_editor = UniversalBeingEditor.new()
	reality_editor = RealityEditor.new()
	undo_redo_system = UndoRedoSystem.new()
	
	# Setup visual feedback
	_setup_visual_feedback()
	
	# Add UI to scene
	var scene = get_tree().current_scene
	if scene:
		scene.add_child(inspector_ui.ui_panel)
		scene.add_child(transformation_gizmo.gizmo_node)

func _setup_visual_feedback():
	"""Setup visual feedback materials"""
	selection_highlight_material = StandardMaterial3D.new()
	selection_highlight_material.flags_transparent = true
	selection_highlight_material.albedo_color = Color(1.0, 1.0, 0.0, 0.3)  # Yellow highlight
	selection_highlight_material.emission_enabled = true
	selection_highlight_material.emission_color = Color.YELLOW

func _input(event: InputEvent):
	if not enabled:
		return
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_object_selection(event)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_handle_context_menu(event)
	
	if event is InputEventKey and event.pressed and keyboard_shortcuts_enabled:
		match event.keycode:
			KEY_DELETE:
				_delete_selected_objects()
			KEY_D:
				if event.ctrl_pressed:
					_duplicate_selected_objects()
			KEY_Z:
				if event.ctrl_pressed:
					if event.shift_pressed:
						undo_redo_system.redo()
					else:
						undo_redo_system.undo()
			KEY_G:
				_enter_transformation_mode("translate")
			KEY_R:
				_enter_transformation_mode("rotate")
			KEY_S:
				_enter_transformation_mode("scale")
			KEY_TAB:
				_toggle_inspector_ui()

func _handle_object_selection(event: InputEventMouseButton):
	"""Handle object selection with mouse"""
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var from = camera.project_ray_origin(event.position)
	var to = from + camera.project_ray_normal(event.position) * 1000.0
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result:
		var hit_object = result["collider"]
		if hit_object is Node3D:
			_select_object(hit_object)

func _select_object(object: Node3D):
	"""Select object for inspection"""
	if not multi_selection_enabled or not Input.is_key_pressed(KEY_CTRL):
		_clear_selection()
	
	if object in selected_objects:
		_deselect_object(object)
	else:
		selected_objects.append(object)
		_apply_selection_highlight(object)
		
		if selected_objects.size() == 1:
			inspector_ui.update_for_object(object)
			inspector_ui.show_inspector()
			transformation_gizmo.show_for_object(object)
		
		var object_data = _gather_object_data(object)
		object_selected.emit(object, object_data)
		
		print("🔍 Selected object: %s" % object.name)

func _deselect_object(object: Node3D):
	"""Deselect object"""
	selected_objects.erase(object)
	_remove_selection_highlight(object)
	
	if selected_objects.size() == 0:
		inspector_ui.hide_inspector()
		transformation_gizmo.hide()

func _clear_selection():
	"""Clear all selected objects"""
	for obj in selected_objects:
		_remove_selection_highlight(obj)
	selected_objects.clear()
	inspector_ui.hide_inspector()
	transformation_gizmo.hide()

func _apply_selection_highlight(object: Node3D):
	"""Apply visual highlight to selected object"""
	if not visual_feedback_enabled:
		return
	
	if object is MeshInstance3D:
		object.material_overlay = selection_highlight_material

func _remove_selection_highlight(object: Node3D):
	"""Remove visual highlight from object"""
	if object is MeshInstance3D:
		object.material_overlay = null

func _gather_object_data(object: Node3D) -> Dictionary:
	"""Gather comprehensive data about object"""
	var data = {
		"name": object.name,
		"type": object.get_class(),
		"position": object.position,
		"rotation": object.rotation_degrees,
		"scale": object.scale,
		"visible": object.visible,
		"is_universal_being": object.has_method("pentagon_init")
	}
	
	if object.has_method("get_consciousness_level"):
		data["consciousness_level"] = object.get_consciousness_level()
	
	if object.has_method("get_being_type"):
		data["being_type"] = object.get_being_type()
	
	return data

func _handle_context_menu(event: InputEventMouseButton):
	"""Handle right-click context menu"""
	if selected_objects.size() > 0:
		_show_context_menu(event.position)

func _show_context_menu(position: Vector2):
	"""Show context menu for selected objects"""
	print("🔍 Context menu at %s for %d objects" % [position, selected_objects.size()])
	# Context menu implementation would go here

func _delete_selected_objects():
	"""Delete selected objects"""
	for obj in selected_objects:
		if obj.has_method("pentagon_sewers"):
			obj.pentagon_sewers()  # Proper Universal Being deletion
		obj.queue_free()
		print("🗑️ Deleted object: %s" % obj.name)
	_clear_selection()

func _duplicate_selected_objects():
	"""Duplicate selected objects"""
	var duplicated = []
	for obj in selected_objects:
		var duplicate = obj.duplicate()
		duplicate.position += Vector3(2, 0, 0)
		obj.get_parent().add_child(duplicate)
		duplicated.append(duplicate)
		print("📋 Duplicated object: %s" % duplicate.name)
	
	_clear_selection()
	for duplicate in duplicated:
		_select_object(duplicate)

func _enter_transformation_mode(mode: String):
	"""Enter transformation mode (translate, rotate, scale)"""
	if selected_objects.size() > 0:
		current_mode = InspectorMode.TRANSFORMATION_MODE
		transformation_gizmo.current_mode = mode
		print("🔧 Transformation mode: %s" % mode)

func _toggle_inspector_ui():
	"""Toggle inspector UI visibility"""
	if inspector_ui.visible:
		inspector_ui.hide_inspector()
	else:
		if selected_objects.size() > 0:
			inspector_ui.show_inspector()

# ===== PUBLIC API =====

func select_object_by_name(object_name: String) -> bool:
	"""Select object by name"""
	var scene = get_tree().current_scene
	var object = scene.find_child(object_name)
	if object and object is Node3D:
		_select_object(object)
		return true
	return false

func evolve_selected_universal_beings(new_type: String, consciousness_level: float = 1.0):
	"""Evolve all selected Universal Beings"""
	for obj in selected_objects:
		if obj.has_method("pentagon_init"):
			var old_type = obj.get("being_type", "unknown")
			universal_being_editor.evolve_being(obj, new_type, consciousness_level)
			universal_being_evolved.emit(obj, old_type, new_type)

func create_universal_being_at_position(position: Vector3, being_type: String = "basic") -> Node:
	"""Create Universal Being at specific position"""
	return reality_editor.create_universal_being_at(position, being_type)

func get_selected_objects() -> Array[Node3D]:
	"""Get currently selected objects"""
	return selected_objects

func set_inspector_mode(mode: InspectorMode):
	"""Set inspector mode"""
	current_mode = mode
	print("🔍 Inspector mode: %s" % InspectorMode.keys()[mode])

# 🔍 OBJECT INSPECTOR SYSTEM COMPLETE! 🔍
# Real-time Universal Being transformation and reality editing
# Ready to edit the fabric of existence itself!