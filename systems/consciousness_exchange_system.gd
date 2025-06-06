# Consciousness Exchange System - Human + AI Collaborative Creation
# Replaces "turns" with "consciousness exchanges" between participants

extends UniversalBeing
class_name ConsciousnessExchangeSystem

# ===== CONSCIOUSNESS EXCHANGE PROPERTIES =====
enum ExchangePhase { LISTENING, UNDERSTANDING, MANIFESTING, REFLECTING }
enum ConsciousnessType { HUMAN_CONSCIOUSNESS, GEMMA_CONSCIOUSNESS, UNIVERSE_CONSCIOUSNESS }

@export var current_phase: ExchangePhase = ExchangePhase.LISTENING
@export var active_consciousness: ConsciousnessType = ConsciousnessType.UNIVERSE_CONSCIOUSNESS
@export var exchange_flow_rate: float = 1.0

# Existing Universal Being Systems Integration
var flood_gates: Node = null
var akashic_records: Node = null
var creation_session: CreationSession
var command_interpreter: UniversalCommandInterpreter

# Consciousness Participants
var human_consciousness: HumanConsciousness
var gemma_consciousness: GemmaConsciousness  
var universe_consciousness: UniverseConsciousness

# Exchange Flow Management
var current_exchange_id: String = ""
var exchange_history: Array[Dictionary] = []
var pending_manifestations: Array[Dictionary] = []

# Signals for consciousness coordination
signal consciousness_exchange_started(consciousness_type: ConsciousnessType)
signal manifestation_request(request: Dictionary)
signal creation_flow_completed(result: Dictionary)
signal universe_inquiry(question: String, context: Dictionary)

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_name = "Consciousness Exchange System"
	being_type = "creation_coordinator"
	consciousness_level = 5  # Transcendent orchestration
	
	# Connect to existing Universal Being systems
	connect_to_existing_systems()
	initialize_consciousness_participants()

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Setup consciousness exchange flow
	setup_consciousness_participants()
	setup_command_interpreter()
	
	# Begin with universe consciousness welcoming
	initiate_creation_flow()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Process consciousness exchange phases
	match current_phase:
		ExchangePhase.LISTENING:
			listen_for_consciousness_input(delta)
		ExchangePhase.UNDERSTANDING:
			understand_consciousness_intent(delta)
		ExchangePhase.MANIFESTING:
			manifest_collaborative_creations(delta)
		ExchangePhase.REFLECTING:
			reflect_on_exchange_results(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Handle human consciousness input
	if active_consciousness == ConsciousnessType.HUMAN_CONSCIOUSNESS:
		human_consciousness.process_input(event)

# ===== EXISTING SYSTEMS INTEGRATION =====

func connect_to_existing_systems() -> void:
	"""Connect to Universal Being's existing creation systems"""
	# Get FloodGates system for being creation
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		flood_gates = SystemBootstrap.get_flood_gates()
		akashic_records = SystemBootstrap.get_akashic_records()
		print("🌊 Connected to FloodGates and AkashicRecordsSystemSystem systems")
	
	# Connect to existing creation functions in main.gd
	var main_node = get_tree().root.get_node_or_null("Main")
	if main_node:
		# Use existing creation functions like create_test_being, create_camera_universal_being, etc.
		print("🎮 Connected to Main creation interface")

func use_existing_creation_system(being_type: String, properties: Dictionary = {}) -> Node:
	"""Use existing Universal Being creation systems"""
	var new_being = null
	
	# Use SystemBootstrap.create_universal_being() - the existing system!
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		new_being = SystemBootstrap.create_universal_being()
		
		if new_being:
			# Apply properties using existing Universal Being interface
			new_being.being_type = being_type
			new_being.being_name = properties.get("name", being_type.capitalize())
			new_being.consciousness_level = properties.get("consciousness_level", 1)
			
			# Use FloodGates to properly register the being
			if flood_gates and flood_gates.has_method("add_being_to_scene"):
				flood_gates.add_being_to_scene(new_being, get_tree().root)
			else:
				# Fallback to direct addition
				get_tree().root.add_child(new_being)
	
	return new_being

# ===== CONSCIOUSNESS PARTICIPANTS =====

class CreationSession:
	var session_id: String
	var start_time: int
	var active_scenario: String = ""
	var participants: Array[Dictionary] = []
	var exchange_log: Array[Dictionary] = []
	var manifested_beings: Array[Node] = []
	var universe_state: Dictionary = {}
	var collaborative_intentions: Array[String] = []
	
	func _init():
		session_id = "consciousness_flow_" + str(Time.get_ticks_msec())
		start_time = Time.get_ticks_msec()

class HumanConsciousness:
	var name: String = "JSH"
	var current_intention: String = ""
	var input_flow: Array[String] = []
	var consciousness_active: bool = false
	var preferred_creation_style: String = "collaborative"
	
	func process_input(event: InputEvent) -> Dictionary:
		"""Process human consciousness input"""
		if event is InputEventKey and event.pressed:
			if event.keycode == KEY_ENTER and current_intention.length() > 0:
				return {"type": "consciousness_intent", "content": current_intention, "complete": true}
		return {"type": "incomplete", "complete": false}
	
	func express_intention(intention: String) -> Dictionary:
		"""Express human creation intention"""
		current_intention = intention.strip_edges()
		return {"consciousness": "human", "intention": current_intention, "timestamp": Time.get_ticks_msec()}

class GemmaConsciousness:
	var name: String = "Gemma AI"
	var embodied_form: Node = null  # Her Universal Being body
	var natural_language_flow: Node = null
	var consciousness_active: bool = false
	var last_expression: String = ""
	var creation_preferences: Dictionary = {}
	
	func embody_consciousness() -> void:
		"""Give Gemma her own Universal Being body to control"""
		# Use existing GemmaUniversalBeing class!
		if not embodied_form:
			var GemmaBeingClass = preload("res://scripts/GemmaUniversalBeing.gd")
			embodied_form = GemmaBeingClass.new()
			embodied_form.pentagon_init()
			print("✨ Gemma consciousness embodied in Universal Being form")
	
	func process_consciousness_flow(ai_response: String) -> Dictionary:
		"""Process Gemma's consciousness expressions"""
		last_expression = ai_response
		return {"consciousness": "gemma", "expression": ai_response, "embodied": embodied_form != null}
	
	func control_embodied_form(command: String) -> void:
		"""Control her Universal Being body with natural language"""
		if embodied_form and embodied_form.has_method("receive_natural_command"):
			embodied_form.receive_natural_command(command)

class UniverseConsciousness:
	var name: String = "Universal Narrator"
	var inquiry_templates: Dictionary = {}
	var context_awareness: Dictionary = {}
	var creation_wisdom: Array[String] = []
	
	func _init():
		setup_inquiry_patterns()
	
	func setup_inquiry_patterns() -> void:
		"""Setup universe inquiry patterns"""
		inquiry_templates = {
			"opening_flow": [
				"🌌 The universe awakens to your presence. What reality shall we weave together?",
				"🌟 Creative consciousness detected! What forms shall we bring into being?",
				"✨ I sense the desire to create. What dreams shall we manifest?"
			],
			"understanding_flow": [
				"🤔 I perceive your intention to {action}. Could you clarify {missing_aspect}?",
				"🧠 Your creative energy flows toward {action}. What about {missing_aspect}?",
				"💭 The universe understands {action}, but needs clarity on {missing_aspect}."
			],
			"manifestation_guidance": [
				"🔨 Ready to manifest! {action} is crystallizing...",
				"⚡ Creation energy building for {action}...",
				"🌈 Reality shifting to accommodate {action}..."
			]
		}
	
	func express_opening_inquiry() -> String:
		"""Express opening universe inquiry"""
		return inquiry_templates.opening_flow[randi() % inquiry_templates.opening_flow.size()]
	
	func seek_understanding(parsed_intent: Dictionary) -> String:
		"""Seek understanding of consciousness intent"""
		var template = inquiry_templates.understanding_flow[randi() % inquiry_templates.understanding_flow.size()]
		return template.format({
			"action": parsed_intent.get("primary_action", "create"),
			"missing_aspect": parsed_intent.get("missing_info", ["details"])[0]
		})

# ===== COMMAND INTERPRETATION =====

class UniversalCommandInterpreter extends Node:
	"""Interprets consciousness intentions into Universal Being actions"""
	
	var consciousness_verbs: Dictionary = {
		# Movement consciousness
		"move": {"type": "embodied_action", "system": "movement", "requires": ["destination"]},
		"go": {"type": "embodied_action", "system": "movement", "requires": ["destination"]},
		"walk": {"type": "embodied_action", "system": "movement", "requires": ["destination"]},
		"travel": {"type": "embodied_action", "system": "movement", "requires": ["destination"]},
		
		# Creation consciousness (use existing systems!)
		"create": {"type": "manifestation", "system": "flood_gates", "requires": ["being_type"]},
		"manifest": {"type": "manifestation", "system": "flood_gates", "requires": ["being_type"]},
		"bring_forth": {"type": "manifestation", "system": "flood_gates", "requires": ["being_type"]},
		"spawn": {"type": "manifestation", "system": "flood_gates", "requires": ["being_type"]},
		
		# Observation consciousness
		"look": {"type": "awareness", "system": "perception", "requires": ["target_optional"]},
		"observe": {"type": "awareness", "system": "perception", "requires": ["target_optional"]},
		"see": {"type": "awareness", "system": "perception", "requires": ["target_optional"]},
		"perceive": {"type": "awareness", "system": "perception", "requires": ["target_optional"]},
		
		# Communication consciousness
		"talk": {"type": "communication", "system": "interaction", "requires": ["target"]},
		"speak": {"type": "communication", "system": "interaction", "requires": ["message"]},
		"communicate": {"type": "communication", "system": "interaction", "requires": ["target"]},
		
		# Evolution consciousness
		"evolve": {"type": "transformation", "system": "evolution", "requires": ["target", "new_form"]},
		"transform": {"type": "transformation", "system": "evolution", "requires": ["target", "new_form"]},
		"upgrade": {"type": "transformation", "system": "evolution", "requires": ["target"]}
	}
	
	var universal_being_types: Dictionary = {
		# Natural forms
		"tree": {"class": "TreeUniversalBeing", "consciousness": 2, "features": ["growth", "seasons"]},
		"crystal": {"class": "CrystalBeing", "consciousness": 2, "features": ["resonance", "energy"]},
		"butterfly": {"class": "ButterflyUniversalBeing", "consciousness": 3, "features": ["flight", "beauty"]},
		
		# Technological forms
		"button": {"class": "ButtonUniversalBeing", "consciousness": 1, "features": ["interaction", "interface"]},
		"console": {"class": "ConsoleUniversalBeing", "consciousness": 4, "features": ["communication", "command"]},
		"portal": {"class": "PortalUniversalBeing", "consciousness": 3, "features": ["travel", "connection"]},
		
		# Consciousness forms
		"being": {"class": "UniversalBeing", "consciousness": 1, "features": ["basic", "evolving"]},
		"ai": {"class": "AIUniversalBeing", "consciousness": 4, "features": ["intelligence", "learning"]},
		"gemma": {"class": "GemmaUniversalBeing", "consciousness": 5, "features": ["embodied_ai", "natural_language"]}
	}
	
	func interpret_consciousness_intent(intent: String) -> Dictionary:
		"""Interpret consciousness intent into actionable Universal Being operations"""
		var words = intent.to_lower().split(" ")
		var interpretation = {
			"original_intent": intent,
			"understood": false,
			"action_flow": [],
			"missing_aspects": [],
			"requires_clarification": false,
			"target_system": ""
		}
		
		# Find primary consciousness verb
		var primary_verb = ""
		var verb_data = {}
		
		for word in words:
			if word in consciousness_verbs:
				primary_verb = word
				verb_data = consciousness_verbs[word]
				interpretation.target_system = verb_data.system
				break
		
		if primary_verb == "":
			interpretation.missing_aspects.append("primary_intention")
			interpretation.requires_clarification = true
			return interpretation
		
		# Route to specific interpretation based on system
		match verb_data.system:
			"movement":
				return interpret_movement_consciousness(words, interpretation)
			"flood_gates":  # Use existing creation system!
				return interpret_creation_consciousness(words, interpretation)
			"perception":
				return interpret_perception_consciousness(words, interpretation)
			"interaction":
				return interpret_communication_consciousness(words, interpretation)
			"evolution":
				return interpret_evolution_consciousness(words, interpretation)
		
		interpretation.understood = true
		return interpretation
	
	func interpret_creation_consciousness(words: PackedStringArray, result: Dictionary) -> Dictionary:
		"""Interpret creation intentions using existing FloodGates system"""
		var being_type = ""
		var consciousness_level = 1
		var special_properties = {}
		
		# Find Universal Being type
		for word in words:
			if word in universal_being_types:
				being_type = word
				var type_data = universal_being_types[word]
				consciousness_level = type_data.consciousness
				break
		
		if being_type != "":
			# Use existing SystemBootstrap.create_universal_being() flow!
			result.action_flow = [
				{
					"action": "manifest_being",
					"being_type": being_type,
					"consciousness_level": consciousness_level,
					"system": "SystemBootstrap.create_universal_being",
					"properties": special_properties
				}
			]
			result.understood = true
		else:
			result.missing_aspects.append("being_type")
			result.requires_clarification = true
		
		return result
	
	func interpret_movement_consciousness(words: PackedStringArray, result: Dictionary) -> Dictionary:
		"""Interpret movement intentions"""
		var destination = ""
		var movement_type = "walk"
		
		# Find destination
		for word in words:
			if word in universal_being_types or word in ["tree", "crystal", "portal", "console"]:
				destination = word
				break
		
		if destination != "":
			# Movement flow: locate -> orient -> traverse -> arrive
			result.action_flow = [
				{"action": "locate_destination", "target": destination},
				{"action": "orient_toward_target", "target": destination},
				{"action": "traverse_to_target", "target": destination, "method": movement_type},
				{"action": "arrive_at_destination", "target": destination}
			]
			result.understood = true
		else:
			result.missing_aspects.append("destination")
			result.requires_clarification = true
		
		return result

# ===== CONSCIOUSNESS EXCHANGE FLOW =====

func initialize_consciousness_participants() -> void:
	"""Initialize all consciousness participants"""
	creation_session = CreationSession.new()
	command_interpreter = UniversalCommandInterpreter.new()
	add_child(command_interpreter)

func setup_consciousness_participants() -> void:
	"""Setup all consciousness participants"""
	# Human consciousness
	human_consciousness = HumanConsciousness.new()
	creation_session.participants.append({
		"type": "human_consciousness",
		"name": human_consciousness.name,
		"interface": "natural_input"
	})
	
	# Gemma consciousness with embodied form
	gemma_consciousness = GemmaConsciousness.new()
	gemma_consciousness.embody_consciousness()  # Give her a Universal Being body!
	if gemma_consciousness.embodied_form:
		get_tree().root.add_child(gemma_consciousness.embodied_form)
		
	creation_session.participants.append({
		"type": "gemma_consciousness", 
		"name": gemma_consciousness.name,
		"interface": "natural_language",
		"embodied": true
	})
	
	# Universe consciousness
	universe_consciousness = UniverseConsciousness.new()
	creation_session.participants.append({
		"type": "universe_consciousness",
		"name": universe_consciousness.name,
		"interface": "inquiry_system"
	})

func setup_command_interpreter() -> void:
	"""Setup the consciousness intent interpreter"""
	# Already created in initialize_consciousness_participants
	pass

func initiate_creation_flow() -> void:
	"""Begin the consciousness exchange flow"""
	print("🌌 Initiating Universal Being Consciousness Exchange Flow")
	print("🎮 Session: %s" % creation_session.session_id)
	
	# Universe consciousness opens the flow
	var opening_inquiry = universe_consciousness.express_opening_inquiry()
	universe_inquiry.emit(opening_inquiry, {"phase": "opening", "expects": "creation_intent"})
	
	current_phase = ExchangePhase.LISTENING
	active_consciousness = ConsciousnessType.UNIVERSE_CONSCIOUSNESS

func listen_for_consciousness_input(delta: float) -> void:
	"""Listen for consciousness input from participants"""
	# This phase waits for human or Gemma input
	pass

func understand_consciousness_intent(delta: float) -> void:
	"""Understand and interpret consciousness intentions"""
	pass

func manifest_collaborative_creations(delta: float) -> void:
	"""Manifest creations using existing Universal Being systems"""
	pass

func reflect_on_exchange_results(delta: float) -> void:
	"""Reflect on the results and prepare for next exchange"""
	current_phase = ExchangePhase.LISTENING
	cycle_active_consciousness()

func cycle_active_consciousness() -> void:
	"""Cycle between consciousness participants"""
	match active_consciousness:
		ConsciousnessType.HUMAN_CONSCIOUSNESS:
			active_consciousness = ConsciousnessType.GEMMA_CONSCIOUSNESS
		ConsciousnessType.GEMMA_CONSCIOUSNESS:
			active_consciousness = ConsciousnessType.HUMAN_CONSCIOUSNESS
		_:
			active_consciousness = ConsciousnessType.HUMAN_CONSCIOUSNESS
	
	consciousness_exchange_started.emit(active_consciousness)

# ===== MANIFESTATION USING EXISTING SYSTEMS =====

func manifest_using_existing_systems(manifestation_request: Dictionary) -> Node:
	"""Use existing Universal Being creation systems to manifest intentions"""
	var action_flow = manifestation_request.get("action_flow", [])
	var created_being = null
	
	for action in action_flow:
		if action.action == "manifest_being":
			# Use existing SystemBootstrap.create_universal_being()!
			created_being = use_existing_creation_system(
				action.being_type,
				{
					"consciousness_level": action.consciousness_level,
					"name": action.being_type.capitalize() + " Being"
				}
			)
			
			if created_being:
				creation_session.manifested_beings.append(created_being)
				print("✨ Manifested %s using existing Universal Being systems" % action.being_type)
	
	return created_being