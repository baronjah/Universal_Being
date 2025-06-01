# core/universal_being.gd

extends Node
class_name UniversalBeing

# ====== Universal Being Core Properties ======
@export var being_type: String = ""
@export var being_name: String = ""
@export var consciousness_level: int = 0
@export var metadata: Dictionary = {}
@export var component_data: Dictionary = {}
@export var being_uuid: String = ""

# Evolution System
@export var evolution_state: Dictionary = {
	"can_become": [],
	"has_been": [],
	"current_evolution": 0
}

# Visual Consciousness
@export var consciousness_aura_color: Color = Color.CYAN

# Signals
signal consciousness_awakened(level: int)
signal component_loaded(component_path: String)
signal evolution_triggered(to_component: String)

# === PENTAGON LIFECYCLE ===
func _init() -> void:
	pentagon_init()

func _ready() -> void:
	pentagon_ready()

func _process(delta: float) -> void:
	pentagon_process(delta)

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func _exit_tree() -> void:
	pentagon_sewers()

# ------ PENTAGON METHODS (to be extended) ------
func pentagon_init() -> void:
	# Central registration, UUID, etc.
	being_uuid = str(hash(self))
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		SystemBootstrap.get_flood_gates().register_being(self)
	metadata.floodgate_registered = true

func pentagon_ready() -> void:
	pass

func pentagon_process(delta: float) -> void:
	pass

func pentagon_input(event: InputEvent) -> void:
	pass

func pentagon_sewers() -> void:
	# Deregister from floodgates
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		SystemBootstrap.get_flood_gates().deregister_being(self)
	metadata.floodgate_registered = false

# --- COMPONENT SYSTEM ---
func add_component(component_path: String) -> void:
	if component_path.ends_with(".ub.zip"):
		var component = ComponentLoader.load_component(component_path)
		if component.size() > 0:
			ComponentLoader.apply_component_to_being(self, component)
			component_loaded.emit(component_path)
	else:
		# Legacy support for direct script loading
		component_data[component_path] = load(component_path)
		component_loaded.emit(component_path)

func remove_component(component_path: String) -> void:
	component_data.erase(component_path)

func apply_component_data() -> void:
	# Logic for applying all components (extend as needed)
	for comp in component_data.values():
		# This could be custom per component
		pass

# --- SCENE CONTROL ---
func load_scene(scene_path: String) -> void:
	var packed_scene = load(scene_path)
	if packed_scene:
		var inst = packed_scene.instantiate()
		add_child(inst)
		metadata.scene_is_loaded = true

func get_scene_node(node_path: NodePath) -> Node:
	return get_node_or_null(node_path)

func set_scene_property(node_path: NodePath, property: String, value: Variant) -> void:
	var node = get_scene_node(node_path)
	if node:
		node.set(property, value)

func call_scene_method(node_path: NodePath, method: String, args: Array = []) -> Variant:
	var node = get_scene_node(node_path)
	if node and node.has_method(method):
		return node.callv(method, args)
	return null

# --- AI INTEGRATION ---
func ai_interface() -> Dictionary:
	return {
		"base_commands": ["ai_modify_property", "ai_invoke_method"],
		"consciousness_level": consciousness_level,
		"being_type": being_type,
		"metadata": metadata
	}

func ai_modify_property(property: String, value: Variant) -> void:
	if has_variable(property):
		set(property, value)

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	if has_method(method_name):
		return callv(method_name, args)
	return null

# --- Utility ---
func evolve_to(component_path: String) -> void:
	if component_path in evolution_state.can_become:
		evolution_state.has_been.append(being_type)
		evolution_state.current_evolution += 1
		add_component(component_path)
		evolution_triggered.emit(component_path)
		print("🌟 %s evolved with %s" % [being_name, component_path])
	else:
		push_warning("Cannot evolve to %s - not in evolution path" % component_path)

func can_evolve_to(component_path: String) -> bool:
	return component_path in evolution_state.can_become

func update_consciousness_visual() -> void:
	# Update aura color based on consciousness level
	var hue = float(consciousness_level) / 10.0
	consciousness_aura_color = Color.from_hsv(hue, 0.8, 1.0)

func mini(a: int, b: int) -> int:
	return min(a, b)