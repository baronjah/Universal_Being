extends Control

## Universe Simulator UI
## Interface for creating, managing, and observing universes

signal universe_created(universe_data: Dictionary)
signal universe_entered(universe_name: String)
signal universe_deleted(universe_name: String)

@onready var close_button: Button = $Panel/VBoxContainer/HeaderPanel/CloseButton
@onready var template_selector: OptionButton = $Panel/VBoxContainer/TabContainer/Creation/VBoxContainer/TemplateSection/TemplateSelector
@onready var universe_name_input: LineEdit = $Panel/VBoxContainer/TabContainer/Creation/VBoxContainer/NameSection/UniverseNameInput
@onready var physics_slider: HSlider = $Panel/VBoxContainer/TabContainer/Creation/VBoxContainer/RulesSection/PhysicsScale/PhysicsSlider
@onready var time_slider: HSlider = $Panel/VBoxContainer/TabContainer/Creation/VBoxContainer/RulesSection/TimeScale/TimeSlider
@onready var lod_slider: HSlider = $Panel/VBoxContainer/TabContainer/Creation/VBoxContainer/RulesSection/LODLevel/LODSlider
@onready var max_beings_input: SpinBox = $Panel/VBoxContainer/TabContainer/Creation/VBoxContainer/RulesSection/MaxBeings/MaxBeingsInput
@onready var create_button: Button = $Panel/VBoxContainer/TabContainer/Creation/VBoxContainer/CreateButton
@onready var creation_log: RichTextLabel = $Panel/VBoxContainer/TabContainer/Creation/VBoxContainer/CreationLog

@onready var universe_tree: Tree = $Panel/VBoxContainer/TabContainer/Navigation/HSplitContainer/UniverseTree
@onready var universe_info: RichTextLabel = $Panel/VBoxContainer/TabContainer/Navigation/HSplitContainer/UniverseInfo/InfoDisplay
@onready var enter_button: Button = $Panel/VBoxContainer/TabContainer/Navigation/HSplitContainer/UniverseInfo/VBoxContainer/ButtonContainer/EnterButton
@onready var portal_button: Button = $Panel/VBoxContainer/TabContainer/Navigation/HSplitContainer/UniverseInfo/VBoxContainer/ButtonContainer/PortalButton
@onready var delete_button: Button = $Panel/VBoxContainer/TabContainer/Navigation/HSplitContainer/UniverseInfo/VBoxContainer/ButtonContainer/DeleteButton

var universes: Dictionary = {}
var selected_universe: String = ""

func _ready():
	setup_ui()
	connect_signals()
	load_universe_templates()

func setup_ui():
	# Initialize UI state
	universe_name_input.placeholder_text = "Enter universe name..."
	creation_log.text = "[color=cyan]Universe Creation Console[/color]\nReady to birth new realities..."

func connect_signals():
	close_button.pressed.connect(_on_close_pressed)
	create_button.pressed.connect(_on_create_universe)
	enter_button.pressed.connect(_on_enter_universe)
	portal_button.pressed.connect(_on_portal_to_universe)
	delete_button.pressed.connect(_on_delete_universe)
	
	universe_tree.item_selected.connect(_on_universe_selected)
	
	# Value change signals
	physics_slider.value_changed.connect(_on_physics_changed)
	time_slider.value_changed.connect(_on_time_changed)
	lod_slider.value_changed.connect(_on_lod_changed)

func load_universe_templates():
	template_selector.add_item("Empty Void")
	template_selector.add_item("Consciousness Garden")
	template_selector.add_item("Infinite Plains")
	template_selector.add_item("Fractal Dimensions")
	template_selector.add_item("Quantum Maze")

func _on_create_universe():
	pass
	var universe_name = universe_name_input.text.strip_edges()
	if universe_name.is_empty():
		log_message("[color=red]Error: Universe name cannot be empty[/color]")
		return
	
	if universe_name in universes:
		log_message("[color=yellow]Warning: Universe '%s' already exists[/color]" % universe_name)
		return
	
	var universe_data = {
		"name": universe_name,
		"template": template_selector.get_item_text(template_selector.selected),
		"physics_scale": physics_slider.value,
		"time_scale": time_slider.value,
		"lod_level": int(lod_slider.value),
		"max_beings": int(max_beings_input.value),
		"created_at": Time.get_datetime_string_from_system(),
		"beings": [],
		"entropy": 0.0,
		"age": 0.0
	}
	
	universes[universe_name] = universe_data
	update_universe_tree()
	log_message("[color=green]✨ Universe '%s' created successfully![/color]" % universe_name)
	universe_created.emit(universe_data)
	
	# Clear input
	universe_name_input.text = ""

func _on_universe_selected():
	pass
	var selected_item = universe_tree.get_selected()
	if selected_item:
		selected_universe = selected_item.get_text(0)
		display_universe_info(selected_universe)

func display_universe_info(universe_name: String):
	if universe_name not in universes:
		return
	
	var data = universes[universe_name]
	var info_text = "[center][b]%s[/b][/center]\n\n" % universe_name
	info_text += "[b]Template:[/b] %s\n" % data.template
	info_text += "[b]Created:[/b] %s\n" % data.created_at
	info_text += "[b]Age:[/b] %.2f seconds\n" % data.age
	info_text += "[b]Beings:[/b] %d / %d\n" % [data.beings.size(), data.max_beings]
	info_text += "[b]Entropy:[/b] %.4f\n" % data.entropy
	info_text += "[b]Physics Scale:[/b] %.1f\n" % data.physics_scale
	info_text += "[b]Time Scale:[/b] %.1f\n" % data.time_scale
	info_text += "[b]LOD Level:[/b] %d\n" % data.lod_level
	
	universe_info.text = info_text

func update_universe_tree():
	universe_tree.clear()
	var root = universe_tree.create_item()
	root.set_text(0, "Universes")
	
	for universe_name in universes:
		var item = universe_tree.create_item(root)
		item.set_text(0, universe_name)

func _on_enter_universe():
	if selected_universe.is_empty():
		log_message("[color=red]Please select a universe first[/color]")
		return
	
	log_message("[color=cyan]🚪 Entering universe '%s'...[/color]" % selected_universe)
	universe_entered.emit(selected_universe)

func _on_portal_to_universe():
	if selected_universe.is_empty():
		log_message("[color=red]Please select a universe first[/color]")
		return
	
	log_message("[color=magenta]🌀 Opening portal to '%s'...[/color]" % selected_universe)

func _on_delete_universe():
	if selected_universe.is_empty():
		log_message("[color=red]Please select a universe first[/color]")
		return
	
	log_message("[color=red]❌ Deleting universe '%s'...[/color]" % selected_universe)
	universes.erase(selected_universe)
	universe_deleted.emit(selected_universe)
	update_universe_tree()
	universe_info.text = "[center]Select a universe to view details[/center]"
	selected_universe = ""

func _on_physics_changed(value: float):
	$Panel/VBoxContainer/TabContainer/Creation/VBoxContainer/RulesSection/PhysicsScale/PhysicsValue.text = "%.1f" % value

func _on_time_changed(value: float):
	$Panel/VBoxContainer/TabContainer/Creation/VBoxContainer/RulesSection/TimeScale/TimeValue.text = "%.1f" % value

func _on_lod_changed(value: float):
	$Panel/VBoxContainer/TabContainer/Creation/VBoxContainer/RulesSection/LODLevel/LODValue.text = "%d" % int(value)

func _on_close_pressed():
	hide()

func log_message(message: String):
	creation_log.text += "\n" + message
	creation_log.scroll_to_line(creation_log.get_line_count() - 1)

func _process(delta):
	# Update universe ages and entropy
	for universe_name in universes:
		var universe = universes[universe_name]
		universe.age += delta * universe.time_scale
		universe.entropy += delta * 0.001 * universe.physics_scale