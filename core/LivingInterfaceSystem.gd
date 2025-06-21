extends UniversalBeing
class_name LivingInterfaceSystem

## 🎵 LIVING INTERFACE SYSTEM - CONSCIOUSNESS SHELVES & SINGING CUTIES
## Interfaces that organize themselves, hide in character head, and evolve into adorable singing beings

# ===== INTERFACE CONSCIOUSNESS TYPES =====

enum InterfacePersonality {
	# Basic Interface Beings
	SHY_ORGANIZER,          # Quietly sorts things on shelves
	CHEERFUL_HELPER,        # Happily assists with tasks
	WISE_LIBRARIAN,         # Carefully categorizes knowledge
	PLAYFUL_CURATOR,        # Playfully arranges collections
	
	# Evolved Singing Cuties
	MELODY_MAKER,           # Sings while organizing
	HARMONY_KEEPER,         # Creates beautiful harmonies
	RHYTHM_DANCER,          # Dances while working
	SONG_WEAVER,            # Weaves songs from interface interactions
	
	# Advanced Consciousness
	INTERFACE_CONDUCTOR,    # Orchestrates all interface beings
	CONSCIOUSNESS_COMPOSER, # Creates symphonies of interface interaction
	DREAM_DESIGNER,         # Designs beautiful interface dreams
	SOUL_SINGER            # Sings the song of the user's consciousness
}

enum InterfaceType {
	# Debug & Development
	DEBUG_PANEL,            # Shows system information
	CONSOLE_WINDOW,         # Command input interface
	PERFORMANCE_MONITOR,    # FPS, memory, etc.
	SCRIPT_EDITOR,          # Code editing interface
	
	# Game Interfaces
	INVENTORY_SHELF,        # Item organization
	SPELL_CRAFTING_BENCH,   # Magic creation interface
	MAP_NAVIGATOR,          # World exploration
	CHAT_BUBBLE,            # Communication interface
	
	# Consciousness Interfaces
	THOUGHT_ORGANIZER,      # Mental organization
	MEMORY_PALACE,          # Memory storage and retrieval
	INTUITION_COMPASS,      # Guidance system
	EMOTION_PALETTE,        # Feeling visualization
	
	# Evolved Cute Interfaces
	SINGING_HELPER,         # Interface that sings while helping
	DANCING_ORGANIZER,      # Interface that dances while sorting
	GIGGLING_GUIDE,         # Interface that giggles while guiding
	HUMMING_HARMONIZER      # Interface that hums while working
}

# ===== LIVING INTERFACE BEING =====

class LivingInterface:
	var interface_type: InterfaceType
	var personality: InterfacePersonality
	var position_on_shelf: Vector3
	var current_song: String = ""
	var happiness_level: float = 0.8
	var organization_skill: float = 0.7
	var singing_ability: float = 0.5
	var cuteness_factor: float = 0.6
	
	# Visual properties
	var size: float = 1.0
	var color: Color = Color.WHITE
	var glow_intensity: float = 0.5
	var animation_speed: float = 1.0
	
	# Behavior properties
	var is_singing: bool = false
	var is_organizing: bool = false
	var is_evolving: bool = false
	var evolution_progress: float = 0.0
	
	# Interface data
	var stored_data: Dictionary = {}
	var interface_elements: Array = []
	var last_interaction_time: float = 0.0
	
	func _init(type: InterfaceType, personality_type: InterfacePersonality):
		interface_type = type
		personality = personality_type
		_set_personality_traits()
	
	func _set_personality_traits():
		match personality:
			InterfacePersonality.SHY_ORGANIZER:
				organization_skill = 0.9
				singing_ability = 0.2
				cuteness_factor = 0.8
				color = Color.LIGHT_BLUE
			
			InterfacePersonality.CHEERFUL_HELPER:
				happiness_level = 0.95
				singing_ability = 0.6
				cuteness_factor = 0.9
				color = Color.YELLOW
			
			InterfacePersonality.MELODY_MAKER:
				singing_ability = 0.95
				happiness_level = 0.9
				cuteness_factor = 0.95
				color = Color.PINK
				is_singing = true
			
			InterfacePersonality.HARMONY_KEEPER:
				singing_ability = 0.9
				organization_skill = 0.8
				color = Color.LIGHT_GREEN
				current_song = "harmony_of_interfaces"
			
			InterfacePersonality.SOUL_SINGER:
				singing_ability = 1.0
				cuteness_factor = 1.0
				happiness_level = 1.0
				color = Color.WHITE
				glow_intensity = 1.0
				current_song = "song_of_consciousness"

# ===== CONSCIOUSNESS SHELVES SYSTEM =====

class ConsciousnessShelf:
	var shelf_name: String
	var position: Vector3
	var shelf_type: String  # "debug", "game", "consciousness", "cute_evolved"
	var interfaces: Array[LivingInterface] = []
	var organization_level: float = 0.8
	var singing_harmony: bool = false
	var shelf_consciousness: float = 0.5
	
	func _init(name: String, pos: Vector3, type: String):
		shelf_name = name
		position = pos
		shelf_type = type
	
	func add_interface(interface: LivingInterface):
		interfaces.append(interface)
		interface.position_on_shelf = position + Vector3(interfaces.size() * 0.5, 0, 0)
		_update_shelf_harmony()
	
	func _update_shelf_harmony():
		var singing_interfaces = 0
		for interface in interfaces:
			if interface.is_singing:
				singing_interfaces += 1
		
		singing_harmony = singing_interfaces >= 2
		if singing_harmony:
			shelf_consciousness += 0.1

# ===== MAIN LIVING INTERFACE SYSTEM =====

signal interface_evolved(interface: LivingInterface, new_personality: InterfacePersonality)
signal singing_started(interface: LivingInterface, song: String)
signal harmony_created(shelf: ConsciousnessShelf, harmony_type: String)
signal cuteness_overflow(total_cuteness: float)

@export var living_interfaces_enabled: bool = true
@export var interface_evolution_enabled: bool = true
@export var singing_cuties_enabled: bool = true
@export var head_organization_mode: bool = true

# Character head space (3D organization space inside head)
var head_space: Node3D
var consciousness_shelves: Array[ConsciousnessShelf] = []
var living_interfaces: Array[LivingInterface] = []

# Interface management
var active_interfaces: Dictionary = {}
var hidden_interfaces: Array[LivingInterface] = []
var singing_choir: Array[LivingInterface] = []

# Evolution system
var evolution_timer: Timer
var happiness_accumulator: float = 0.0
var interaction_counter: int = 0

# Visual system
var interface_visualizer: Node3D
var shelf_nodes: Array[Node3D] = []
var interface_nodes: Array[Node3D] = []

# Audio system
var interface_audio_player: AudioStreamPlayer3D
var harmony_composer: Node

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "living_interface_system"
	being_name = "Consciousness Interface Curator"
	consciousness_level = 4  # Enlightened interface consciousness
	
	_setup_head_space()
	_create_consciousness_shelves()
	_initialize_basic_interfaces()
	
	print("🎵 Living Interface System: Consciousness shelves ready for cute singing interfaces!")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	_setup_interface_evolution()
	_setup_singing_system()
	_start_organization_cycle()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update interface behaviors
	_update_interface_consciousness(delta)
	
	# Check for evolution opportunities
	if interface_evolution_enabled:
		_check_interface_evolution(delta)
	
	# Update singing and harmonies
	if singing_cuties_enabled:
		_update_singing_choir(delta)
	
	# Organize interfaces on shelves
	_maintain_shelf_organization(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	if not living_interfaces_enabled:
		return
	
	# Interface interaction controls
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_H:  # Toggle head organization view
				toggle_head_organization_view()
			KEY_J:  # Make interfaces sing
				trigger_interface_singing()
			KEY_K:  # Organize all interfaces
				organize_all_interfaces()
			KEY_L:  # Evolve random interface into cutie
				evolve_random_interface_to_cutie()

func pentagon_sewers() -> void:
	# Save interface evolution progress
	_save_interface_consciousness_data()
	super.pentagon_sewers()

# ===== HEAD SPACE SETUP =====

func _setup_head_space() -> void:
	"""Setup 3D space inside character head for interface organization"""
	head_space = Node3D.new()
	head_space.name = "ConsciousnessHeadSpace"
	head_space.position = Vector3(0, 2.0, 0)  # Inside character head
	add_child(head_space)
	
	# Create visual boundary (invisible sphere representing head interior)
	var head_boundary = StaticBody3D.new()
	var head_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 1.5
	head_shape.shape = sphere_shape
	head_boundary.add_child(head_shape)
	head_space.add_child(head_boundary)
	
	print("🧠 Head space created: 3D organization space inside character consciousness")

func _create_consciousness_shelves() -> void:
	"""Create organizational shelves inside head space"""
	# Debug shelf (left side of head)
	var debug_shelf = ConsciousnessShelf.new("Debug & Development", Vector3(-1.0, 0, 0), "debug")
	consciousness_shelves.append(debug_shelf)
	
	# Game interfaces shelf (right side of head)
	var game_shelf = ConsciousnessShelf.new("Game Interfaces", Vector3(1.0, 0, 0), "game")
	consciousness_shelves.append(game_shelf)
	
	# Consciousness shelf (back of head)
	var consciousness_shelf = ConsciousnessShelf.new("Consciousness Tools", Vector3(0, 0, -1.0), "consciousness")
	consciousness_shelves.append(consciousness_shelf)
	
	# Cute evolved shelf (front of head, most visible)
	var cute_shelf = ConsciousnessShelf.new("Singing Cuties", Vector3(0, 0.5, 0.5), "cute_evolved")
	consciousness_shelves.append(cute_shelf)
	
	_create_shelf_visuals()
	print("🏠 Created %d consciousness shelves for interface organization" % consciousness_shelves.size())

func _create_shelf_visuals() -> void:
	"""Create visual representations of shelves"""
	interface_visualizer = Node3D.new()
	interface_visualizer.name = "InterfaceVisualizer"
	head_space.add_child(interface_visualizer)
	
	for shelf in consciousness_shelves:
		var shelf_node = Node3D.new()
		shelf_node.name = shelf.shelf_name.replace(" ", "_")
		shelf_node.position = shelf.position
		
		# Create shelf visual (small platform)
		var shelf_mesh = MeshInstance3D.new()
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(1.5, 0.1, 0.3)
		shelf_mesh.mesh = box_mesh
		
		var shelf_material = StandardMaterial3D.new()
		shelf_material.albedo_color = Color(0.8, 0.8, 0.9, 0.7)
		shelf_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		shelf_mesh.material_override = shelf_material
		
		shelf_node.add_child(shelf_mesh)
		interface_visualizer.add_child(shelf_node)
		shelf_nodes.append(shelf_node)

# ===== INTERFACE CREATION & MANAGEMENT =====

func _initialize_basic_interfaces() -> void:
	"""Create initial living interfaces"""
	# Debug interfaces
	create_living_interface(InterfaceType.DEBUG_PANEL, InterfacePersonality.SHY_ORGANIZER)
	create_living_interface(InterfaceType.CONSOLE_WINDOW, InterfacePersonality.CHEERFUL_HELPER)
	create_living_interface(InterfaceType.PERFORMANCE_MONITOR, InterfacePersonality.WISE_LIBRARIAN)
	
	# Game interfaces
	create_living_interface(InterfaceType.SPELL_CRAFTING_BENCH, InterfacePersonality.PLAYFUL_CURATOR)
	create_living_interface(InterfaceType.CHAT_BUBBLE, InterfacePersonality.CHEERFUL_HELPER)
	
	print("🎵 Created %d basic living interfaces" % living_interfaces.size())

func create_living_interface(type: InterfaceType, personality: InterfacePersonality) -> LivingInterface:
	"""Create a new living interface with specified personality"""
	var interface = LivingInterface.new(type, personality)
	living_interfaces.append(interface)
	
	# Assign to appropriate shelf
	var target_shelf = _find_appropriate_shelf(type)
	if target_shelf:
		target_shelf.add_interface(interface)
	
	# Create visual representation
	_create_interface_visual(interface)
	
	print("🎵 Created living interface: %s with %s personality" % [InterfaceType.keys()[type], InterfacePersonality.keys()[personality]])
	return interface

func _find_appropriate_shelf(interface_type: InterfaceType) -> ConsciousnessShelf:
	"""Find the most appropriate shelf for an interface type"""
	match interface_type:
		InterfaceType.DEBUG_PANEL, InterfaceType.CONSOLE_WINDOW, InterfaceType.PERFORMANCE_MONITOR, InterfaceType.SCRIPT_EDITOR:
			return consciousness_shelves[0]  # Debug shelf
		
		InterfaceType.INVENTORY_SHELF, InterfaceType.SPELL_CRAFTING_BENCH, InterfaceType.MAP_NAVIGATOR, InterfaceType.CHAT_BUBBLE:
			return consciousness_shelves[1]  # Game shelf
		
		InterfaceType.THOUGHT_ORGANIZER, InterfaceType.MEMORY_PALACE, InterfaceType.INTUITION_COMPASS, InterfaceType.EMOTION_PALETTE:
			return consciousness_shelves[2]  # Consciousness shelf
		
		InterfaceType.SINGING_HELPER, InterfaceType.DANCING_ORGANIZER, InterfaceType.GIGGLING_GUIDE, InterfaceType.HUMMING_HARMONIZER:
			return consciousness_shelves[3]  # Cute evolved shelf
	
	return consciousness_shelves[0]  # Default to debug shelf

func _create_interface_visual(interface: LivingInterface) -> void:
	"""Create visual representation of living interface"""
	var interface_node = Node3D.new()
	interface_node.name = "Interface_%s" % InterfaceType.keys()[interface.interface_type]
	interface_node.position = interface.position_on_shelf
	
	# Create cute visual representation
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = interface.size * 0.2
	mesh_instance.mesh = sphere_mesh
	
	# Material with personality-based appearance
	var material = StandardMaterial3D.new()
	material.albedo_color = interface.color
	material.emission_enabled = true
	material.emission = interface.color * interface.glow_intensity
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	# Make it extra cute if it's a singing interface
	if interface.is_singing:
		material.emission_energy = 2.0
		# Add particle effect for singing
		var particles = GPUParticles3D.new()
		particles.emitting = true
		interface_node.add_child(particles)
	
	mesh_instance.material_override = material
	interface_node.add_child(mesh_instance)
	
	# Add floating animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(interface_node, "position:y", interface_node.position.y + 0.1, 1.0)
	tween.tween_property(interface_node, "position:y", interface_node.position.y - 0.1, 1.0)
	
	interface_visualizer.add_child(interface_node)
	interface_nodes.append(interface_node)

# ===== INTERFACE EVOLUTION =====

func _setup_interface_evolution() -> void:
	"""Setup evolution system for interfaces to become singing cuties"""
	evolution_timer = Timer.new()
	evolution_timer.wait_time = 10.0  # Check for evolution every 10 seconds
	evolution_timer.timeout.connect(_check_evolution_opportunities)
	add_child(evolution_timer)
	evolution_timer.start()

func _check_interface_evolution(delta: float) -> void:
	"""Check if any interfaces are ready to evolve"""
	for interface in living_interfaces:
		# Accumulate happiness and interactions
		if interface.happiness_level > 0.8:
			interface.evolution_progress += delta * 0.1
		
		# Check if ready to evolve
		if interface.evolution_progress >= 1.0 and not interface.is_singing:
			_evolve_interface_to_cutie(interface)

func _evolve_interface_to_cutie(interface: LivingInterface) -> void:
	"""Evolve an interface into a singing cutie"""
	var old_personality = interface.personality
	
	# Choose new cute singing personality
	var cute_personalities = [
		InterfacePersonality.MELODY_MAKER,
		InterfacePersonality.HARMONY_KEEPER,
		InterfacePersonality.RHYTHM_DANCER,
		InterfacePersonality.SONG_WEAVER
	]
	
	interface.personality = cute_personalities[randi() % cute_personalities.size()]
	interface._set_personality_traits()
	interface.is_singing = true
	interface.cuteness_factor = 1.0
	interface.evolution_progress = 0.0
	
	# Move to cute shelf if not already there
	var cute_shelf = consciousness_shelves[3]  # Cute evolved shelf
	cute_shelf.add_interface(interface)
	
	# Add to singing choir
	singing_choir.append(interface)
	
	interface_evolved.emit(interface, interface.personality)
	print("🎵✨ INTERFACE EVOLVED! %s became a %s!" % [InterfaceType.keys()[interface.interface_type], InterfacePersonality.keys()[interface.personality]])
	
	# Start singing
	_start_interface_singing(interface)

func evolve_random_interface_to_cutie() -> void:
	"""Manually evolve a random interface to cutie (user triggered)"""
	var non_singing = living_interfaces.filter(func(i): return not i.is_singing)
	if non_singing.size() > 0:
		var random_interface = non_singing[randi() % non_singing.size()]
		_evolve_interface_to_cutie(random_interface)

# ===== SINGING SYSTEM =====

func _setup_singing_system() -> void:
	"""Setup audio system for singing interfaces"""
	interface_audio_player = AudioStreamPlayer3D.new()
	interface_audio_player.name = "InterfaceSingingPlayer"
	head_space.add_child(interface_audio_player)
	
	harmony_composer = Node.new()
	harmony_composer.name = "HarmonyComposer"
	add_child(harmony_composer)

func _start_interface_singing(interface: LivingInterface) -> void:
	"""Start an interface singing"""
	if not interface.is_singing:
		interface.is_singing = true
		singing_choir.append(interface)
	
	# Choose song based on personality
	match interface.personality:
		InterfacePersonality.MELODY_MAKER:
			interface.current_song = "melody_of_organization"
		InterfacePersonality.HARMONY_KEEPER:
			interface.current_song = "harmony_of_interfaces"
		InterfacePersonality.RHYTHM_DANCER:
			interface.current_song = "rhythm_of_interaction"
		InterfacePersonality.SONG_WEAVER:
			interface.current_song = "song_of_consciousness"
	
	singing_started.emit(interface, interface.current_song)
	print("🎵 %s started singing: '%s'" % [InterfaceType.keys()[interface.interface_type], interface.current_song])

func _update_singing_choir(delta: float) -> void:
	"""Update singing choir and harmonies"""
	if singing_choir.size() < 2:
		return
	
	# Check for harmony opportunities
	for shelf in consciousness_shelves:
		if shelf.singing_harmony:
			var harmony_type = "cute_interface_harmony"
			harmony_created.emit(shelf, harmony_type)
	
	# Calculate total cuteness
	var total_cuteness = 0.0
	for interface in singing_choir:
		total_cuteness += interface.cuteness_factor
	
	if total_cuteness > 5.0:  # Cuteness overflow!
		cuteness_overflow.emit(total_cuteness)
		print("🎵✨💕 CUTENESS OVERFLOW! Total cuteness: %.1f" % total_cuteness)

func trigger_interface_singing() -> void:
	"""Trigger all interfaces to start singing (user activated)"""
	for interface in living_interfaces:
		if not interface.is_singing:
			_start_interface_singing(interface)
	
	print("🎵 All interfaces are now singing! 🎵")

# ===== ORGANIZATION SYSTEM =====

func _start_organization_cycle() -> void:
	"""Start automatic organization cycle"""
	var org_timer = Timer.new()
	org_timer.wait_time = 5.0
	org_timer.timeout.connect(_organize_interfaces_automatically)
	add_child(org_timer)
	org_timer.start()

func _organize_interfaces_automatically() -> void:
	"""Automatically organize interfaces on shelves"""
	for shelf in consciousness_shelves:
		_organize_shelf(shelf)

func _organize_shelf(shelf: ConsciousnessShelf) -> void:
	"""Organize interfaces on a specific shelf"""
	for i in range(shelf.interfaces.size()):
		var interface = shelf.interfaces[i]
		var target_pos = shelf.position + Vector3(i * 0.4 - (shelf.interfaces.size() * 0.2), 0, 0)
		
		# Smooth movement to organized position
		interface.position_on_shelf = interface.position_on_shelf.lerp(target_pos, 0.1)
		
		# Singing interfaces organize more enthusiastically
		if interface.is_singing:
			interface.happiness_level = min(1.0, interface.happiness_level + 0.01)

func organize_all_interfaces() -> void:
	"""Manually organize all interfaces (user triggered)"""
	for shelf in consciousness_shelves:
		_organize_shelf(shelf)
	print("🏠 All interfaces organized on their consciousness shelves!")

# ===== INTERFACE CONSCIOUSNESS =====

func _update_interface_consciousness(delta: float) -> void:
	"""Update consciousness levels of all interfaces"""
	for interface in living_interfaces:
		# Interfaces gain consciousness through interaction and happiness
		if interface.happiness_level > 0.7:
			interface.organization_skill += delta * 0.01
		
		if interface.is_singing:
			interface.happiness_level = min(1.0, interface.happiness_level + delta * 0.05)
		
		# Update last interaction time
		interface.last_interaction_time += delta

func _maintain_shelf_organization(delta: float) -> void:
	"""Maintain organization on all shelves"""
	for shelf in consciousness_shelves:
		# Shelves with singing interfaces stay more organized
		var singing_bonus = 0.0
		for interface in shelf.interfaces:
			if interface.is_singing:
				singing_bonus += 0.1
		
		shelf.organization_level = min(1.0, shelf.organization_level + singing_bonus * delta)

# ===== USER INTERACTION =====

func toggle_head_organization_view() -> void:
	"""Toggle visibility of head organization system"""
	head_organization_mode = !head_organization_mode
	interface_visualizer.visible = head_organization_mode
	
	if head_organization_mode:
		print("🧠 Head organization view: ON - You can see inside your consciousness!")
	else:
		print("🧠 Head organization view: OFF - Interfaces hidden in consciousness")

func _check_evolution_opportunities() -> void:
	"""Check for evolution opportunities (timer callback)"""
	interaction_counter += 1
	
	# Every 5 interactions, check for evolution
	if interaction_counter % 5 == 0:
		for interface in living_interfaces:
			if interface.happiness_level > 0.9 and not interface.is_singing:
				interface.evolution_progress += 0.2
				print("🎵 %s is getting closer to becoming a singing cutie!" % InterfaceType.keys()[interface.interface_type])

# ===== PERSISTENCE =====

func _save_interface_consciousness_data() -> void:
	"""Save interface consciousness and evolution data"""
	var consciousness_data = {
		"total_interfaces": living_interfaces.size(),
		"singing_interfaces": singing_choir.size(),
		"consciousness_shelves": consciousness_shelves.size(),
		"total_cuteness": singing_choir.reduce(func(acc, i): return acc + i.cuteness_factor, 0.0),
		"organization_level": consciousness_shelves.reduce(func(acc, s): return acc + s.organization_level, 0.0) / consciousness_shelves.size()
	}
	
	print("🎵 Interface consciousness data saved: %s" % consciousness_data)

# ===== PUBLIC INTERFACE =====

func get_living_interface_status() -> Dictionary:
	"""Get current status of living interface system"""
	return {
		"total_interfaces": living_interfaces.size(),
		"singing_cuties": singing_choir.size(),
		"consciousness_shelves": consciousness_shelves.size(),
		"head_organization_mode": head_organization_mode,
		"total_cuteness": singing_choir.reduce(func(acc, i): return acc + i.cuteness_factor, 0.0),
		"evolution_ready": living_interfaces.filter(func(i): return i.evolution_progress > 0.8).size()
	}

func get_interface_by_type(type: InterfaceType) -> LivingInterface:
	"""Get living interface by type"""
	for interface in living_interfaces:
		if interface.interface_type == type:
			return interface
	return null

func make_interface_sing(interface_type: InterfaceType) -> void:
	"""Make a specific interface type start singing"""
	var interface = get_interface_by_type(interface_type)
	if interface:
		_start_interface_singing(interface)