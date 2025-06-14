# 🏛️ Universal Being UI - Specialized for User Interface
# Author: JSH (Pentagon Architecture)
# Created: May 31, 2025, 23:36 CEST
# Purpose: Universal Being specialized for UI elements
# Connection: Pentagon Architecture - Interface manifestation

extends UniversalBeingBase
class_name UniversalBeingUI

## Universal Being specialized for UI elements
## Every button, panel, window is a conscious Universal Being

# Override base class to extend Control instead of Node3D for UI
func _init() -> void:
	# UI-specific initialization
	super._init()


func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	# Add UI-specific evolution possibilities
	add_evolution_possibility("button")
	add_evolution_possibility("panel")
	add_evolution_possibility("window")
	add_evolution_possibility("menu")
	add_evolution_possibility("dialog")

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
	add_ability("on_clicked")
	add_ability("on_hover")
	add_ability("on_focus")
	add_ability("on_resize")
	
	# Store UI-specific metadata
	store_memory("dimension", "UI")
	store_memory("interface_type", "generic")

## UI-specific evolution methods
func evolve_to_button(text: String = "Button") -> bool:
	if evolve_into("button"):
		manifest_as_interface("button", {"text": text})
		add_ability("on_button_pressed")
		add_ability("set_button_text")
		return true
	return false

func evolve_to_panel(title: String = "Panel") -> bool:
	if evolve_into("panel"):
		manifest_as_interface("panel", {"title": title})
		add_ability("add_child_widget")
		add_ability("remove_child_widget")
		return true
	return false

func evolve_to_window(title: String = "Window") -> bool:
	if evolve_into("window"):
		manifest_as_interface("window", {"title": title})
		add_ability("minimize_window")
		add_ability("maximize_window")
		add_ability("close_window")
		return true
	return false

## UI interaction methods
func on_clicked() -> void:
	if "on_clicked" in evolution_state.abilities:
		store_memory("last_click", Time.get_ticks_msec())
		# Notify Logic Connector of interaction
		var logic_connector = get_node_or_null("/root/LogicConnector")
		if logic_connector and logic_connector.has_method("on_ui_interaction"):
			logic_connector.on_ui_interaction(self, "clicked")

func on_hover() -> void:
	if "on_hover" in evolution_state.abilities:
		store_memory("last_hover", Time.get_ticks_msec())

## Recursive Universal Being UI - Every child is also a Universal Being
func add_universal_ui_child(child_type: String, properties: Dictionary = {}) -> UniversalBeingUI:
	var child_being = UniversalBeingUI.new()
	child_being.name = properties.get("name", child_type + "_child")
	
	# Evolve child based on type
	match child_type:
		"button":
			child_being.evolve_to_button(properties.get("text", "Child Button"))
		"panel":
			child_being.evolve_to_panel(properties.get("title", "Child Panel"))
		_:
			push_warning("Unknown UI child type: %s" % child_type)
	
	universal_add_child(child_being)
	return child_being