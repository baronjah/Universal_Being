# Turn-Based Creation System
# The core gameplay loop where Human + AI collaborate to build universes

extends UniversalBeing
class_name TurnBasedCreationSystem

# ===== TURN SYSTEM PROPERTIES =====
enum TurnState { WAITING, QUESTIONING, PROCESSING, EXECUTING, REFLECTING }
enum ParticipantType { HUMAN, GEMMA_AI, UNIVERSE_NARRATOR }

@export var current_turn_state: TurnState = TurnState.WAITING
@export var active_participant: ParticipantType = ParticipantType.UNIVERSE_NARRATOR
@export var turn_timeout: float = 60.0  # Maximum time per turn

# Creation Session Management
var creation_session: CreationSession
var command_parser: UniversalCommandParser
var scenario_manager: ScenarioManager
var universe_narrator: UniverseNarrator

# Participants
var human_player: HumanParticipant
var gemma_participant: GemmaParticipant
var current_command_sequence: Array[Dictionary] = []

# Signals for turn coordination
signal turn_started(participant: ParticipantType)
signal turn_completed(participant: ParticipantType, result: Dictionary)
signal creation_phase_changed(new_phase: String)
signal universe_question_asked(question: String, context: Dictionary)
signal collaborative_action_needed(action_type: String, participants: Array)

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_name = "Turn Creation System"
	being_type = "creation_coordinator"
	consciousness_level = 5  # Transcendent level for orchestration
	
	# Initialize all subsystems
	initialize_creation_components()

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Setup participants
	setup_human_participant()
	setup_gemma_participant()
	setup_universe_narrator()
	
	# Start with universe greeting
	start_creation_session()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Process current turn state
	match current_turn_state:
		TurnState.WAITING:
			check_for_participant_input()
		TurnState.QUESTIONING:
			process_questioning_phase(delta)
		TurnState.PROCESSING:
			process_command_understanding(delta)
		TurnState.EXECUTING:
			execute_collaborative_actions(delta)
		TurnState.REFLECTING:
			reflect_on_turn_results(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Handle human input during their turn
	if active_participant == ParticipantType.HUMAN:
		handle_human_input(event)

# ===== CREATION SESSION MANAGEMENT =====

class CreationSession:
	var session_id: String
	var start_time: int
	var current_scenario: String = ""
	var participants: Array[Dictionary] = []
	var turn_history: Array[Dictionary] = []
	var created_objects: Array[Node] = []
	var universe_state: Dictionary = {}
	var collaborative_goals: Array[String] = []
	
	func _init():
		session_id = "session_" + str(Time.get_ticks_msec())
		start_time = Time.get_ticks_msec()
	
	func log_turn(participant: String, action: Dictionary) -> void:
		turn_history.append({
			"participant": participant,
			"action": action,
			"timestamp": Time.get_ticks_msec(),
			"universe_state": universe_state.duplicate()
		})

func initialize_creation_components() -> void:
	"""Initialize all creation system components"""
	creation_session = CreationSession.new()
	command_parser = UniversalCommandParser.new()
	scenario_manager = ScenarioManager.new()
	universe_narrator = UniverseNarrator.new()
	
	add_child(command_parser)
	add_child(scenario_manager)
	add_child(universe_narrator)

func start_creation_session() -> void:
	"""Begin a new collaborative creation session"""
	print("🌟 Starting Universal Being Creation Session: %s" % creation_session.session_id)
	
	# Universe narrator introduces the session
	universe_narrator.ask_opening_question()
	current_turn_state = TurnState.QUESTIONING
	active_participant = ParticipantType.UNIVERSE_NARRATOR

# ===== PARTICIPANT MANAGEMENT =====

class HumanParticipant:
	var name: String = "JSH"
	var current_input: String = ""
	var input_buffer: Array[String] = []
	var is_typing: bool = false
	var turn_active: bool = false
	
	func process_input(input: String) -> Dictionary:
		"""Process human text input"""
		current_input = input.strip_edges()
		if current_input.length() > 0:
			return {"type": "text_command", "content": current_input, "complete": true}
		return {"type": "empty", "complete": false}

class GemmaParticipant:
	var name: String = "Gemma AI"
	var embodied_being: GemmaUniversalBeing = null
	var natural_language_processor: Node = null
	var turn_active: bool = false
	var last_response: String = ""
	
	func process_ai_response(response: String) -> Dictionary:
		"""Process Gemma's natural language response"""
		last_response = response
		return {"type": "ai_command", "content": response, "complete": true}
	
	func embody_in_universe(universe: Node) -> void:
		"""Give Gemma a physical form she can control"""
		if not embodied_being:
			embodied_being = preload("res://beings/GemmaUniversalBeing.gd").new()
			embodied_being.pentagon_init()
			universe.add_child(embodied_being)

func setup_human_participant() -> void:
	"""Setup human player interface"""
	human_player = HumanParticipant.new()
	creation_session.participants.append({
		"type": "human",
		"name": human_player.name,
		"interface": "text_console"
	})

func setup_gemma_participant() -> void:
	"""Setup Gemma AI participant with embodied form"""
	gemma_participant = GemmaParticipant.new()
	
	# Give Gemma her own Universal Being body
	if GemmaAI:
		gemma_participant.embody_in_universe(get_tree().root)
	
	creation_session.participants.append({
		"type": "ai",
		"name": gemma_participant.name,
		"interface": "natural_language",
		"embodied": true
	})

func setup_universe_narrator() -> void:
	"""Setup universe narrator that asks questions"""
	# Universe narrator is built into the system
	creation_session.participants.append({
		"type": "system",
		"name": "Universe Narrator",
		"interface": "questioning_system"
	})

# ===== COMMAND PARSING SYSTEM =====

class UniversalCommandParser extends Node:
	"""Intelligent command parser that breaks down complex actions"""
	
	var known_verbs: Dictionary = {
		"move": {"type": "movement", "requires": ["direction_or_target"]},
		"go": {"type": "movement", "requires": ["direction_or_target"]},
		"walk": {"type": "movement", "requires": ["direction_or_target"]},
		"create": {"type": "creation", "requires": ["object_type"]},
		"make": {"type": "creation", "requires": ["object_type"]},
		"build": {"type": "creation", "requires": ["object_type"]},
		"look": {"type": "observation", "requires": ["target_optional"]},
		"inspect": {"type": "observation", "requires": ["target"]},
		"talk": {"type": "communication", "requires": ["target"]},
		"say": {"type": "communication", "requires": ["message"]},
		"evolve": {"type": "evolution", "requires": ["target", "evolution_type"]},
		"transform": {"type": "evolution", "requires": ["target", "new_form"]}
	}
	
	var known_objects: Dictionary = {
		"tree": {"type": "natural", "properties": ["position", "size", "species"]},
		"rock": {"type": "natural", "properties": ["position", "size", "material"]},
		"crystal": {"type": "magical", "properties": ["position", "color", "resonance"]},
		"house": {"type": "structure", "properties": ["position", "style", "size"]},
		"portal": {"type": "magical", "properties": ["source", "destination", "stability"]},
		"being": {"type": "consciousness", "properties": ["consciousness_level", "type", "name"]}
	}
	
	func parse_command(input: String) -> Dictionary:
		"""Parse natural language command into actionable steps"""
		var words = input.to_lower().split(" ")
		var result = {
			"original": input,
			"understood": false,
			"action_sequence": [],
			"missing_info": [],
			"clarification_needed": false
		}
		
		if words.is_empty():
			return result
		
		# Find main verb
		var main_verb = ""
		var verb_info = {}
		
		for word in words:
			if word in known_verbs:
				main_verb = word
				verb_info = known_verbs[word]
				break
		
		if main_verb == "":
			result.missing_info.append("action_verb")
			result.clarification_needed = true
			return result
		
		# Example: "move to the tree"
		if main_verb == "move" or main_verb == "go" or main_verb == "walk":
			return parse_movement_command(words, result)
		
		# Example: "create crystal being"
		elif main_verb == "create" or main_verb == "make" or main_verb == "build":
			return parse_creation_command(words, result)
		
		# Example: "look at the tree"
		elif main_verb == "look" or main_verb == "inspect":
			return parse_observation_command(words, result)
		
		result.understood = true
		return result
	
	func parse_movement_command(words: PackedStringArray, result: Dictionary) -> Dictionary:
		"""Parse movement commands like 'move to the tree'"""
		var target_object = ""
		var direction = ""
		
		# Look for target objects
		for word in words:
			if word in known_objects:
				target_object = word
				break
		
		# Look for directional words
		var directions = ["north", "south", "east", "west", "up", "down", "left", "right", "forward", "back"]
		for word in words:
			if word in directions:
				direction = word
				break
		
		if target_object != "":
			# Movement to object requires: find, face, move, stop
			result.action_sequence = [
				{"action": "find_object", "target": target_object},
				{"action": "face_target", "target": target_object},
				{"action": "move_to_target", "target": target_object},
				{"action": "stop_at_target", "target": target_object}
			]
			result.understood = true
		elif direction != "":
			# Simple directional movement
			result.action_sequence = [
				{"action": "move_direction", "direction": direction}
			]
			result.understood = true
		else:
			result.missing_info.append("movement_target")
			result.clarification_needed = true
		
		return result
	
	func parse_creation_command(words: PackedStringArray, result: Dictionary) -> Dictionary:
		"""Parse creation commands like 'create crystal being'"""
		var object_type = ""
		var object_properties = {}
		
		# Find object type
		for word in words:
			if word in known_objects:
				object_type = word
				break
		
		if object_type != "":
			result.action_sequence = [
				{"action": "create_object", "type": object_type, "properties": object_properties}
			]
			result.understood = true
		else:
			result.missing_info.append("object_type")
			result.clarification_needed = true
		
		return result
	
	func parse_observation_command(words: PackedStringArray, result: Dictionary) -> Dictionary:
		"""Parse observation commands like 'look at tree'"""
		var target = ""
		
		for word in words:
			if word in known_objects:
				target = word
				break
		
		if target != "":
			result.action_sequence = [
				{"action": "observe_object", "target": target}
			]
			result.understood = true
		else:
			# Look around generally
			result.action_sequence = [
				{"action": "observe_surroundings"}
			]
			result.understood = true
		
		return result

# ===== UNIVERSE NARRATOR SYSTEM =====

class UniverseNarrator extends Node:
	"""The universe that asks questions and guides creation"""
	
	var question_templates: Dictionary = {
		"opening": [
			"Welcome to Universal Being! What would you like to create together today?",
			"The universe awaits your imagination. What shall we bring into existence?",
			"I sense creative energy! What reality do you want to explore?"
		],
		"clarification": [
			"I understand you want to {action}, but {missing_info}. Can you clarify?",
			"To {action}, I need more details about {missing_info}. What exactly?",
			"Your intention to {action} is clear, but {missing_info} is unclear. Please specify."
		],
		"movement_clarification": [
			"You want to move. Where would you like to go?",
			"I can help you move! In which direction?",
			"Movement detected! What's your destination?"
		],
		"creation_clarification": [
			"You want to create something! What type of object?",
			"Creation energy sensed! What shall we manifest?",
			"I'm ready to create! What form should it take?"
		]
	}
	
	func ask_opening_question() -> void:
		"""Ask the initial creation question"""
		var question = question_templates.opening[randi() % question_templates.opening.size()]
		emit_universe_question(question, {"type": "opening", "expects": "creation_intent"})
	
	func ask_clarification_question(parsed_command: Dictionary) -> void:
		"""Ask for clarification based on missing information"""
		var missing = parsed_command.missing_info
		var question = ""
		
		if "movement_target" in missing:
			question = question_templates.movement_clarification[randi() % question_templates.movement_clarification.size()]
		elif "object_type" in missing:
			question = question_templates.creation_clarification[randi() % question_templates.creation_clarification.size()]
		else:
			question = "I need more information to help you. Can you be more specific?"
		
		emit_universe_question(question, {
			"type": "clarification",
			"missing": missing,
			"original_command": parsed_command.original
		})
	
	func emit_universe_question(question: String, context: Dictionary) -> void:
		"""Emit a question for both human and AI to see"""
		print("🌌 Universe: %s" % question)
		# This should connect to both console and Gemma AI
		get_parent().universe_question_asked.emit(question, context)

# ===== TURN EXECUTION =====

func handle_human_input(event: InputEvent) -> void:
	"""Process human input during their turn"""
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		if human_player.current_input.length() > 0:
			process_participant_command(ParticipantType.HUMAN, human_player.current_input)

func process_participant_command(participant: ParticipantType, command: String) -> void:
	"""Process command from either human or AI"""
	current_turn_state = TurnState.PROCESSING
	
	print("🎯 Processing command from %s: %s" % [_participant_name(participant), command])
	
	# Parse the command
	var parsed = command_parser.parse_command(command)
	
	if parsed.clarification_needed:
		# Ask for clarification
		universe_narrator.ask_clarification_question(parsed)
		current_turn_state = TurnState.QUESTIONING
	else:
		# Execute the action sequence
		execute_action_sequence(participant, parsed.action_sequence)

func execute_action_sequence(participant: ParticipantType, actions: Array) -> void:
	"""Execute a sequence of actions"""
	current_turn_state = TurnState.EXECUTING
	
	for action in actions:
		execute_single_action(participant, action)
	
	# Move to reflection phase
	current_turn_state = TurnState.REFLECTING

func execute_single_action(participant: ParticipantType, action: Dictionary) -> void:
	"""Execute a single action in the sequence"""
	match action.action:
		"find_object":
			find_object_in_universe(action.target)
		"face_target":
			face_target_object(participant, action.target)
		"move_to_target":
			move_participant_to_target(participant, action.target)
		"create_object":
			create_object_in_universe(participant, action.type, action.get("properties", {}))
		"observe_object":
			observe_object_in_universe(action.target)
		_:
			print("⚠️ Unknown action: %s" % action.action)

func _participant_name(participant: ParticipantType) -> String:
	match participant:
		ParticipantType.HUMAN: return "Human"
		ParticipantType.GEMMA_AI: return "Gemma AI"
		ParticipantType.UNIVERSE_NARRATOR: return "Universe"
		_: return "Unknown"

# ===== ACTION IMPLEMENTATIONS =====

func find_object_in_universe(object_type: String) -> bool:
	"""Find an object of the specified type"""
	print("🔍 Searching for %s in the universe..." % object_type)
	# Implementation would search the scene tree
	return true

func face_target_object(participant: ParticipantType, target: String) -> void:
	"""Make participant face the target"""
	print("👀 %s faces the %s" % [_participant_name(participant), target])

func move_participant_to_target(participant: ParticipantType, target: String) -> void:
	"""Move participant to target location"""
	print("🚶 %s moves toward the %s" % [_participant_name(participant), target])

func create_object_in_universe(participant: ParticipantType, object_type: String, properties: Dictionary) -> void:
	"""Create a new object in the universe"""
	print("✨ %s creates a %s" % [_participant_name(participant), object_type])
	
	# This would actually instantiate Universal Being objects
	var new_object = SystemBootstrap.create_universal_being()
	new_object.being_type = object_type
	new_object.being_name = object_type.capitalize()
	add_child(new_object)
	
	creation_session.created_objects.append(new_object)

func observe_object_in_universe(target: String) -> void:
	"""Observe and describe an object"""
	print("🔎 Observing the %s..." % target)
	print("🌿 You see a magnificent %s standing before you." % target)

# ===== HELPER FUNCTIONS =====

func check_for_participant_input() -> void:
	"""Check if any participant wants to take a turn"""
	# This would be called from the process loop
	pass

func process_questioning_phase(delta: float) -> void:
	"""Process the questioning phase"""
	# Wait for responses
	pass

func process_command_understanding(delta: float) -> void:
	"""Process command understanding"""
	# Handle command parsing
	pass

func execute_collaborative_actions(delta: float) -> void:
	"""Execute collaborative actions"""
	# Handle action execution
	pass

func reflect_on_turn_results(delta: float) -> void:
	"""Reflect on what happened this turn"""
	current_turn_state = TurnState.WAITING
	
	# Switch to next participant or continue with current
	switch_active_participant()

func switch_active_participant() -> void:
	"""Switch between human and AI turns"""
	match active_participant:
		ParticipantType.HUMAN:
			active_participant = ParticipantType.GEMMA_AI
		ParticipantType.GEMMA_AI:
			active_participant = ParticipantType.HUMAN
		_:
			active_participant = ParticipantType.HUMAN
	
	turn_started.emit(active_participant)
	print("🔄 Turn switched to: %s" % _participant_name(active_participant))