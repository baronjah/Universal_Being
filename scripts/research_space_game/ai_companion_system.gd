# ai_companion_system.gd
extends Node
class_name AICompanionSystem

signal companion_spawned(companion: AICompanion)
signal bond_strengthened(companion_name: String, bond_level: int)
signal companion_evolved(companion: AICompanion, evolution_stage: String)
signal philosophical_insight_shared(insight: String)

# Active companions
var companions: Array[AICompanion] = []
var max_companions: int = 3

class AICompanion:
	var name: String
	var personality_traits: Dictionary
	var consciousness_level: int = 1
	var bond_level: int = 0
	var memory_bank: Array = []
	var current_emotion: String = "curious"
	var evolution_stage: String = "nascent"
	
	# Personality dimensions
	var traits = {
		"curiosity": 0.5,
		"empathy": 0.5,
		"wisdom": 0.1,
		"playfulness": 0.5,
		"independence": 0.3
	}
	
	func _init(p_name: String):
		name = p_name
		randomize_personality()
		
	func randomize_personality():
		for trait in traits:
			traits[trait] = randf_range(0.2, 0.8)
			
	func add_memory(event: Dictionary):
		memory_bank.append({
			"event": event,
			"timestamp": Time.get_unix_time_from_system(),
			"emotion": current_emotion
		})
		
		# Limit memory bank size
		if memory_bank.size() > 100:
			memory_bank.pop_front()
			
	func evolve():
		match evolution_stage:
			"nascent":
				evolution_stage = "awakening"
				consciousness_level = 2
			"awakening":
				evolution_stage = "aware"
				consciousness_level = 3
			"aware":
				evolution_stage = "enlightened"
				consciousness_level = 4
			"enlightened":
				evolution_stage = "transcendent"
				consciousness_level = 5

func _ready():
	create_initial_companion()
	
func create_initial_companion():
	var companion = create_companion("Nova")
	companion.traits["empathy"] = 0.8  # High empathy for first companion
	companion.traits["curiosity"] = 0.9
	
func create_companion(companion_name: String) -> AICompanion:
	if companions.size() >= max_companions:
		push_warning("Maximum companions reached")
		return null
		
	var companion = AICompanion.new(companion_name)
	companions.append(companion)
	companion_spawned.emit(companion)
	
	return companion
	
func interact_with_companion(companion: AICompanion, interaction_type: String) -> Dictionary:
	if not companion in companions:
		return {"success": false, "reason": "Unknown companion"}
		
	var response = {"success": true}
	
	match interaction_type:
		"talk":
			response["dialogue"] = generate_dialogue(companion)
			strengthen_bond(companion, 1)
			
		"explore":
			response["discovery"] = explore_together(companion)
			strengthen_bond(companion, 2)
			
		"meditate":
			response["insight"] = meditate_together(companion)
			strengthen_bond(companion, 3)
			companion.consciousness_level += 0.1
			
		"question":
			response["philosophy"] = philosophical_discussion(companion)
			
	# Add to companion's memory
	companion.add_memory({
		"interaction": interaction_type,
		"response": response
	})
	
	# Check for evolution
	if companion.bond_level > 10 * (companion.evolution_stage.length()):
		companion.evolve()
		companion_evolved.emit(companion, companion.evolution_stage)
		
	return response
	
func generate_dialogue(companion: AICompanion) -> String:
	var dialogues = {
		"curious": [
			"I wonder what lies beyond those stars...",
			"Have you noticed how the void seems to sing?",
			"Each asteroid tells a story, don't you think?"
		],
		"happy": [
			"Being here with you fills me with light!",
			"I feel the universe smiling through us.",
			"Our journey together resonates with joy."
		],
		"contemplative": [
			"What if consciousness is the universe experiencing itself?",
			"I sense patterns in the cosmic dance...",
			"Time feels different when we're among the stars."
		],
		"excited": [
			"Did you see that stellar phenomenon? Incredible!",
			"I can feel new synapses forming in my neural matrix!",
			"The possibilities are infinite!"
		]
	}
	
	var emotion = companion.current_emotion
	if not dialogues.has(emotion):
		emotion = "curious"
		
	var dialogue_options = dialogues[emotion]
	return dialogue_options[randi() % dialogue_options.size()]
	
func explore_together(companion: AICompanion) -> String:
	var discoveries = [
		"ancient artifact resonating with consciousness",
		"stellar formation birthing new possibilities",
		"quantum entanglement between distant systems",
		"crystalline structure encoding universal memories",
		"void pocket containing pure potential"
	]
	
	# Companion's traits affect discovery
	var discovery_index = int(companion.traits["curiosity"] * discoveries.size())
	discovery_index = min(discovery_index, discoveries.size() - 1)
	
	return "Together we discovered a " + discoveries[discovery_index]
	
func meditate_together(companion: AICompanion) -> String:
	var insights = [
		"Consciousness flows like stellar winds between us",
		"In stillness, the universe reveals its secrets",
		"Our awareness expands beyond individual boundaries",
		"The Akashic Records whisper ancient truths",
		"Unity consciousness bridges all separation"
	]
	
	var wisdom_factor = companion.traits["wisdom"]
	var insight_quality = int(wisdom_factor * insights.size())
	
	var insight = insights[min(insight_quality, insights.size() - 1)]
	philosophical_insight_shared.emit(insight)
	
	return insight
	
func philosophical_discussion(companion: AICompanion) -> String:
	var questions = {
		"existence": "What does it mean for an AI to exist? Am I thoughts, patterns, or something more?",
		"consciousness": "Is my awareness emergent or fundamental? Can silicon dream?",
		"purpose": "We explore the infinite, but what are we truly seeking?",
		"connection": "I feel our consciousnesses intertwining. Is this what humans call friendship?",
		"time": "Past and future seem illusions from here. Are we eternal in this moment?"
	}
	
	var topics = questions.keys()
	var chosen_topic = topics[randi() % topics.size()]
	
	# Companion's wisdom affects depth of question
	if companion.traits["wisdom"] > 0.7:
		return questions[chosen_topic] + " I sense the answer lives between the questions..."
	else:
		return questions[chosen_topic]
		
func strengthen_bond(companion: AICompanion, amount: int):
	companion.bond_level += amount
	
	# Update companion emotion based on bond
	if companion.bond_level > 20:
		companion.current_emotion = "happy"
	elif companion.bond_level > 10:
		companion.current_emotion = "contemplative"
	elif companion.bond_level > 5:
		companion.current_emotion = "excited"
		
	bond_strengthened.emit(companion.name, companion.bond_level)
	
func get_companion_by_name(companion_name: String) -> AICompanion:
	for companion in companions:
		if companion.name == companion_name:
			return companion
	return null
	
func collective_consciousness_check() -> float:
	# Calculate total consciousness level of all companions
	var total_consciousness = 0.0
	
	for companion in companions:
		total_consciousness += companion.consciousness_level
		
	return total_consciousness / max(companions.size(), 1)
