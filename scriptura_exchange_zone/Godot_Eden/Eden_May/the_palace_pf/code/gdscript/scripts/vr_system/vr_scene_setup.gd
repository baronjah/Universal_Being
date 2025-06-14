extends Node
class_name VRSceneSetup

# References to managers
var vr_manager = null
var akashic_records = null
var universe_controller = null

# VR specific components
var vr_akashic_interface = null

# Status
var is_initialized = false

# Initialize the VR scene
func _ready():
	print("Setting up VR scene...")
	
	# Ensure we're not duplicating objects by waiting a frame
	call_deferred("initialize_vr_environment")

# Initialize VR environment
func initialize_vr_environment():
	# Initialize VR Manager (singleton)
	vr_manager = VRManager.get_instance()
	vr_manager.initialize()
	
	# Connect signals from VR Manager
	vr_manager.connect("vr_initialized", Callable(self, "_on_vr_initialized"))
	vr_manager.connect("vr_status_changed", Callable(self, "_on_vr_status_changed"))
	vr_manager.connect("scale_transition_requested", Callable(self, "_on_scale_transition_requested"))
	
	# Find or create universe controller
	_setup_universe_controller()
	
	# Initialize Akashic Records
	akashic_records = AkashicRecordsManager.get_instance()
	akashic_records.initialize()
	
	# Setup VR Akashic interface
	_setup_vr_akashic_interface()
	
	# Connect to bridge if available
	_setup_universe_dictionary_bridge()
	
	is_initialized = true
	print("VR scene setup complete.")

# Setup the Universe Controller
func _setup_universe_controller():
	# Look for an existing UniverseController
	var controllers = get_tree().get_nodes_in_group("universe_controller")
	
	if controllers.size() > 0:
		universe_controller = controllers[0]
		print("Found existing UniverseController: ", universe_controller.name)
	else:
		# Try to find a UniverseController in the scene
		var potential_controllers = get_tree().get_nodes_in_group("UniverseController")
		for controller in potential_controllers:
			if controller is UniverseController:
				universe_controller = controller
				print("Found UniverseController: ", universe_controller.name)
				break
	
	if not universe_controller:
		# Create a new one
		var UniverseControllerScript = load("res://code/gdscript/scripts/universe_particles_physics/universe_controller.gd")
		universe_controller = UniverseControllerScript.new()
		universe_controller.name = "UniverseController"
		add_child(universe_controller)
		universe_controller.add_to_group("universe_controller")
		print("Created new UniverseController")
	
	# Connect signals
	if universe_controller and universe_controller.has_signal("scale_changed"):
		universe_controller.connect("scale_changed", Callable(self, "_on_universe_scale_changed"))

# Setup the VR Akashic interface
func _setup_vr_akashic_interface():
	vr_akashic_interface = VRAkashicInterface.new()
	vr_akashic_interface.name = "VRAkashicInterface"
	add_child(vr_akashic_interface)
	vr_akashic_interface.initialize()
	
	# Connect signals
	vr_akashic_interface.connect("word_selected", Callable(self, "_on_word_selected"))
	vr_akashic_interface.connect("word_created", Callable(self, "_on_word_created"))
	vr_akashic_interface.connect("word_connection_created", Callable(self, "_on_word_connection_created"))
	vr_akashic_interface.connect("word_deleted", Callable(self, "_on_word_deleted"))

# Setup the connection between Universe and Dictionary
func _setup_universe_dictionary_bridge():
	var BridgeScript = load("res://code/gdscript/scripts/universe_particles_physics/universe_dictionary_bridge.gd")
	var bridge = BridgeScript.new()
	bridge.name = "UniverseDictionaryBridge"
	
	# Check if bridge exists in universe controller
	var existing_bridge = false
	if universe_controller:
		for child in universe_controller.get_children():
			if child is UniverseDictionaryBridge:
				existing_bridge = true
				bridge = child
				break
	
	if not existing_bridge:
		add_child(bridge)
		
	# Initialize bridge with controllers
	if universe_controller:
		var resource_manager = null
		for child in universe_controller.get_children():
			if child.name == "ResourceManager" or child is ResourceManager:
				resource_manager = child
				break
		
		bridge.initialize(universe_controller, resource_manager)
		print("Universe Dictionary Bridge initialized")

# Process function for continuous updates
func _process(delta):
	if not is_initialized:
		return
		
	# Update VR reference points based on current scale
	if vr_manager and universe_controller:
		# Convert scale level enum to string
		var scale_name = _convert_scale_level_to_string(universe_controller.current_scale)
		vr_manager.current_scale = scale_name
		
		# Update the reference point if we have a focus object
		if universe_controller.transition_target:
			var focus_pos = universe_controller.transition_target.global_position
			vr_manager.update_reference_point(focus_pos)

# Convert universe controller scale level to string
func _convert_scale_level_to_string(scale_level):
	match scale_level:
		UniverseController.ScaleLevel.UNIVERSE:
			return "universe"
		UniverseController.ScaleLevel.GALAXY:
			return "galaxy"
		UniverseController.ScaleLevel.STAR_SYSTEM:
			return "star_system"
		UniverseController.ScaleLevel.PLANET:
			return "planet"
		UniverseController.ScaleLevel.ELEMENT:
			return "element"
	return "universe"

# Convert string scale to universe controller scale level
func _convert_string_to_scale_level(scale_string):
	match scale_string:
		"universe":
			return UniverseController.ScaleLevel.UNIVERSE
		"galaxy":
			return UniverseController.ScaleLevel.GALAXY
		"star_system":
			return UniverseController.ScaleLevel.STAR_SYSTEM
		"planet":
			return UniverseController.ScaleLevel.PLANET
		"element":
			return UniverseController.ScaleLevel.ELEMENT
	return UniverseController.ScaleLevel.UNIVERSE

# Signal handlers

# VR Manager signals
func _on_vr_initialized():
	print("VR system initialized")
	
	# Update the UI to show that VR is active
	if vr_akashic_interface:
		vr_akashic_interface.create_visualization()

func _on_vr_status_changed(is_active):
	print("VR status changed: ", is_active)
	
	# Toggle visibility of VR-specific interfaces
	if vr_akashic_interface:
		vr_akashic_interface.visible = is_active

func _on_scale_transition_requested(from_scale, to_scale):
	print("VR scale transition requested: ", from_scale, " -> ", to_scale)
	
	# Trigger a scale transition in the universe controller
	if universe_controller:
		var target_scale = _convert_string_to_scale_level(to_scale)
		universe_controller.transition_to_scale(target_scale)

# Universe Controller signals
func _on_universe_scale_changed(from_scale, to_scale):
	print("Universe scale changed: ", from_scale, " -> ", to_scale)
	
	# Update VR system to match the new scale
	if vr_manager:
		vr_manager.current_scale = _convert_scale_level_to_string(to_scale)
		vr_manager.complete_scale_transition()
	
	# Update visualization if in element view
	if to_scale == UniverseController.ScaleLevel.ELEMENT and vr_akashic_interface:
		vr_akashic_interface.create_visualization()

# VR Akashic Interface signals
func _on_word_selected(word_id):
	print("Word selected: ", word_id)
	
	# Could trigger interactions in the universe controller
	# depending on the word type

func _on_word_created(word_id, word_data):
	print("Word created: ", word_id)
	
	# If this is a cosmic object type, it might need to be represented in the universe
	if word_data.has("category") and word_data.category == "cosmic":
		# Create corresponding cosmic object
		pass

func _on_word_connection_created(parent_id, child_id):
	print("Word connection created: ", parent_id, " -> ", child_id)
	
	# This might represent a cosmic relationship (e.g., planet orbiting a star)
	# that needs to be reflected in the universe view

func _on_word_deleted(word_id):
	print("Word deleted: ", word_id)
	
	# If this had a cosmic representation, it might need to be removed from the universe