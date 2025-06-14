extends Node

# Story Generator for JSH Ethereal Engine
# Creates narratives that connect across the multiverse and adapt to player actions

# Configuration
export var story_complexity: int = 3  # 1-5, affects story depth and branching
export var story_persistence: bool = true  # Stories persist across sessions
export var player_influence_weight: float = 0.7  # How much player actions affect stories
export var universe_influence_weight: float = 0.5  # How much universe properties affect stories

# Story structure
var active_stories = {}  # story_id -> story_data
var story_fragments = {}  # fragment_id -> fragment_data
var story_connections = {}  # story_id -> [connected_story_ids]
var story_locations = {}  # location_key -> [story_ids]

# Story elements
var story_themes = [
	"creation", "destruction", "rebirth",
	"journey", "discovery", "transformation",
	"conflict", "harmony", "transcendence",
	"connection", "isolation", "sacrifice"
]

var story_archetypes = [
	"hero", "mentor", "guardian", 
	"shadow", "trickster", "creator",
	"explorer", "sage", "innocent",
	"ruler", "caregiver", "magician"
]

var story_locations_library = [
	"origin_point", "crossroads", "ancient_temple",
	"forgotten_city", "dream_nexus", "crystal_forest",
	"void_expanse", "memory_palace", "digital_realm",
	"astral_sea", "quantum_labyrinth", "time_spiral"
]

var transition_phrases = [
	"Meanwhile, in another reality...",
	"As this unfolded, elsewhere...",
	"The story continues across dimensions...",
	"In a parallel existence...",
	"Echoing through the multiverse...",
	"Reflecting across realities..."
]

# System references
var multiverse_system = null
var dream_processor = null
var player_controller = null

# Signals
signal story_created(story_id, story_data)
signal story_advanced(story_id, new_fragment)
signal story_completed(story_id)
signal stories_connected(story_id_1, story_id_2, connection_type)
signal story_affected_reality(story_id, effect_type, affected_entities)

# ========== Initialization ==========

func _ready():
	initialize_system()
	
	if Engine.is_editor_hint():
		return
	
	# Start story generation cycle
	_start_story_cycle()

func initialize_system():
	# Connect to required systems
	multiverse_system = get_node_or_null("/root/MultiverseSystemIntegration")
	if not multiverse_system:
		multiverse_system = get_node_or_null("../MultiverseSystemIntegration")
	
	dream_processor = get_node_or_null("/root/DreamStateProcessor")
	if not dream_processor:
		dream_processor = get_node_or_null("../DreamStateProcessor")
	
	player_controller = get_node_or_null("/root/PlayerController")
	if not player_controller:
		player_controller = get_node_or_null("../PlayerController")
	
	# Load persistent stories if enabled
	if story_persistence:
		load_stories()
	
	print("JSH Story Generator: Initialized")

func _start_story_cycle():
	# Create initial stories
	create_origin_story()
	
	# Schedule story advancement
	var timer = Timer.new()
	timer.wait_time = 60.0  # Check for story advancement every minute
	timer.connect("timeout", self, "_on_story_cycle_timer")
	add_child(timer)
	timer.start()

func _on_story_cycle_timer():
	# Process active stories
	process_active_stories()
	
	# Create new stories occasionally
	if randf() < 0.3:  # 30% chance each cycle
		create_random_story()
	
	# Connect stories occasionally
	if randf() < 0.2 and active_stories.size() >= 2:  # 20% chance if we have at least 2 stories
		connect_random_stories()

# ========== Story Creation ==========

func create_origin_story():
	# Create the foundational story that connects to the multiverse origin
	
	var theme = "creation"
	var archetype = "creator"
	var location = "origin_point"
	
	var story_seed = "In the beginning, the " + archetype + " shaped reality through the power of words."
	
	var story_data = {
		"id": "origin_story",
		"theme": theme,
		"archetype": archetype,
		"location": location,
		"universe_id": "root_universe",  # The primary universe
		"fragments": [story_seed],
		"branches": [],
		"status": "active",
		"player_influenced": false,
		"created_time": OS.get_unix_time(),
		"last_updated": OS.get_unix_time(),
		"completion": 0.0
	}
	
	active_stories["origin_story"] = story_data
	
	# Register with location
	if not story_locations.has(location):
		story_locations[location] = []
	story_locations[location].append("origin_story")
	
	# Emit signal
	emit_signal("story_created", "origin_story", story_data)
	
	# Schedule advancement
	_schedule_story_advancement("origin_story")
	
	print("JSH Story Generator: Created origin story")
	
	return "origin_story"

func create_random_story():
	# Create a new story with random elements
	
	var theme = story_themes[randi() % story_themes.size()]
	var archetype = story_archetypes[randi() % story_archetypes.size()]
	var location = story_locations_library[randi() % story_locations_library.size()]
	
	# Get current universe if multiverse system is available
	var universe_id = "root_universe"
	if multiverse_system:
		var current_universe = multiverse_system.get_current_universe()
		if current_universe:
			universe_id = current_universe.id
	
	# Generate story seed based on theme and archetype
	var story_seed = generate_story_seed(theme, archetype, location)
	
	return create_story(theme, archetype, location, universe_id, story_seed)

func create_story(theme: String, archetype: String, location: String, universe_id: String, story_seed: String) -> String:
	# Create a unique ID for the story
	var story_id = "story_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)
	
	var story_data = {
		"id": story_id,
		"theme": theme,
		"archetype": archetype,
		"location": location,
		"universe_id": universe_id,
		"fragments": [story_seed],
		"branches": [],
		"status": "active",
		"player_influenced": false,
		"created_time": OS.get_unix_time(),
		"last_updated": OS.get_unix_time(),
		"completion": 0.0
	}
	
	active_stories[story_id] = story_data
	
	# Register with location
	if not story_locations.has(location):
		story_locations[location] = []
	story_locations[location].append(story_id)
	
	# Emit signal
	emit_signal("story_created", story_id, story_data)
	
	# Schedule advancement
	_schedule_story_advancement(story_id)
	
	print("JSH Story Generator: Created story '" + story_id + "' - " + story_seed)
	
	return story_id

func generate_story_seed(theme: String, archetype: String, location: String) -> String:
	# Generate the initial fragment of a story based on its components
	
	# Actions that the archetype might take
	var actions = {
		"hero": ["embarked on a journey", "faced a great challenge", "answered the call"],
		"mentor": ["shared ancient wisdom", "guided a lost soul", "revealed hidden knowledge"],
		"guardian": ["protected the sacred", "stood watch", "defended against darkness"],
		"shadow": ["emerged from darkness", "threatened the balance", "corrupted what was pure"],
		"trickster": ["played a clever game", "revealed uncomfortable truths", "twisted expectations"],
		"creator": ["forged something new", "breathed life into form", "shaped from nothing"],
		"explorer": ["ventured into the unknown", "mapped uncharted territory", "discovered wonders"],
		"sage": ["contemplated existence", "unraveled mysteries", "preserved knowledge"],
		"innocent": ["saw with untainted eyes", "brought hope", "trusted in possibility"],
		"ruler": ["established order", "made difficult choices", "shaped civilization"],
		"caregiver": ["nurtured potential", "healed wounds", "provided sanctuary"],
		"magician": ["wielded the impossible", "transformed reality", "bridged worlds"]
	}
	
	# Thematic elements
	var themes = {
		"creation": ["birth", "genesis", "beginning", "origin", "dawn"],
		"destruction": ["end", "collapse", "ruin", "fall", "twilight"],
		"rebirth": ["renewal", "resurrection", "transformation", "cycle", "phoenix"],
		"journey": ["path", "quest", "voyage", "expedition", "pilgrimage"],
		"discovery": ["revelation", "finding", "unveiling", "insight", "enlightenment"],
		"transformation": ["change", "metamorphosis", "evolution", "shift", "becoming"],
		"conflict": ["struggle", "battle", "opposition", "tension", "war"],
		"harmony": ["balance", "peace", "unity", "accord", "resonance"],
		"transcendence": ["ascension", "awakening", "elevation", "liberation", "beyond"],
		"connection": ["bond", "link", "bridge", "network", "web"],
		"isolation": ["solitude", "separation", "exile", "abandonment", "loneliness"],
		"sacrifice": ["offering", "surrender", "loss", "giving", "price"]
	}
	
	# Location descriptions
	var location_desc = {
		"origin_point": "at the cosmic nexus",
		"crossroads": "where realities intersect",
		"ancient_temple": "within hallowed walls",
		"forgotten_city": "among abandoned spires",
		"dream_nexus": "in the realm of thought",
		"crystal_forest": "surrounded by prismatic light",
		"void_expanse": "in the endless abyss",
		"memory_palace": "among echoes of the past",
		"digital_realm": "in the sea of information",
		"astral_sea": "upon consciousness waves",
		"quantum_labyrinth": "in the maze of possibility",
		"time_spiral": "where moments converge"
	}
	
	# Get random elements for variety
	var action = "acted"
	if actions.has(archetype):
		var action_list = actions[archetype]
		action = action_list[randi() % action_list.size()]
	
	var theme_word = theme
	if themes.has(theme):
		var theme_list = themes[theme]
		theme_word = theme_list[randi() % theme_list.size()]
	
	var location_phrase = "in an unknown place"
	if location_desc.has(location):
		location_phrase = location_desc[location]
	
	# Construct the story seed
	var templates = [
		"The " + archetype + " " + action + " " + location_phrase + ", bringing " + theme_word + ".",
		location_phrase.capitalize() + ", the " + archetype + " " + action + " as " + theme_word + " unfolded.",
		"A tale of " + theme_word + " began when the " + archetype + " " + action + " " + location_phrase + ".",
		location_phrase.capitalize() + " witnessed the " + archetype + " who " + action + ", changing everything through " + theme_word + "."
	]
	
	return templates[randi() % templates.size()]

func _schedule_story_advancement(story_id: String):
	if not active_stories.has(story_id):
		return
	
	# Schedule next story advancement
	var timer = Timer.new()
	timer.one_shot = true
	
	# Time between advancements depends on story complexity
	var base_time = 120.0  # 2 minutes base
	var time_variance = 180.0  # Up to 3 minutes variance
	timer.wait_time = base_time + (randf() * time_variance)
	
	timer.connect("timeout", self, "_on_story_advancement_timer", [story_id])
	add_child(timer)
	timer.start()

func _on_story_advancement_timer(story_id: String):
	if not active_stories.has(story_id):
		return
	
	# Advance the story
	advance_story(story_id)
	
	# If story is still active, schedule next advancement
	if active_stories.has(story_id) and active_stories[story_id].status == "active":
		_schedule_story_advancement(story_id)

# ========== Story Advancement ==========

func advance_story(story_id: String):
	if not active_stories.has(story_id):
		return false
	
	var story_data = active_stories[story_id]
	
	# Check if we should branch instead of advancing
	if should_branch_story(story_data):
		branch_story(story_id)
		return true
	
	# Get the last fragment
	var last_fragment = story_data.fragments[story_data.fragments.size() - 1]
	
	# Generate next fragment
	var next_fragment = generate_next_fragment(story_data, last_fragment)
	
	# Add to story fragments
	story_data.fragments.append(next_fragment)
	story_data.last_updated = OS.get_unix_time()
	
	# Update completion progress
	var target_length = 5 + (story_complexity * 2)  # 7-15 fragments based on complexity
	story_data.completion = min(1.0, story_data.fragments.size() / float(target_length))
	
	# Check if story is complete
	if story_data.completion >= 1.0:
		complete_story(story_id)
	
	# Emit signal
	emit_signal("story_advanced", story_id, next_fragment)
	
	print("JSH Story Generator: Advanced story '" + story_id + "'")
	
	return true

func generate_next_fragment(story_data: Dictionary, last_fragment: String) -> String:
	# Generate the next piece of the story based on its current state
	
	# Extract key elements from previous fragment
	var words = last_fragment.split(" ")
	var key_nouns = []
	var key_verbs = []
	
	# Very simple extraction of potential key words
	for word in words:
		word = word.to_lower()
		if word.length() > 4:
			if word.ends_with("ed") or word.ends_with("ing"):
				key_verbs.append(word)
			else:
				key_nouns.append(word)
	
	# Make sure we have something to work with
	if key_nouns.empty():
		key_nouns = ["entity", "traveler", story_data.archetype]
	if key_verbs.empty():
		key_verbs = ["moved", "discovered", "created"]
	
	# Get a random noun and verb
	var noun = key_nouns[randi() % key_nouns.size()]
	var verb = key_verbs[randi() % key_verbs.size()]
	
	# Structure options for the next fragment
	var fragment_structures = [
		"As the " + noun + " " + verb + ", " + generate_thematic_phrase(story_data.theme) + ".",
		"The " + story_data.archetype + " " + generate_action_phrase(story_data.theme) + ", revealing " + generate_discovery_phrase() + ".",
		generate_location_phrase(story_data.location) + ", " + generate_event_phrase(story_data.theme) + ".",
		"With each step, " + generate_consequence_phrase(story_data.theme) + ".",
		"Through " + noun + ", the " + story_data.archetype + " " + generate_transformation_phrase() + "."
	]
	
	# Select random structure
	var fragment = fragment_structures[randi() % fragment_structures.size()]
	
	# Apply player influence if relevant
	if story_data.player_influenced and player_controller:
		fragment = apply_player_influence(fragment, story_data)
	
	# Apply universe influence if relevant
	if multiverse_system:
		var current_universe = multiverse_system.get_current_universe()
		if current_universe and current_universe.id == story_data.universe_id:
			fragment = apply_universe_influence(fragment, current_universe)
	
	return fragment

func generate_thematic_phrase(theme: String) -> String:
	var phrases = {
		"creation": [
			"new possibilities emerged from the void",
			"the foundations of reality took form",
			"patterns of light began to weave together"
		],
		"destruction": [
			"the old order crumbled away",
			"what once was whole fractured into pieces",
			"entropy claimed what had stood for ages"
		],
		"rebirth": [
			"life stirred again in forgotten places",
			"from ashes, a new existence took shape",
			"cycles turned toward renewal once more"
		],
		"journey": [
			"the path revealed itself one step at a time",
			"distant horizons beckoned with promise",
			"each threshold crossed changed the traveler"
		],
		"discovery": [
			"hidden truths came into focus",
			"the veil parted to reveal what lay beyond",
			"understanding dawned like a sunrise"
		],
		"transformation": [
			"forms shifted into something never before seen",
			"change rippled outward in waves",
			"the essence within found a new expression"
		],
		"conflict": [
			"opposing forces clashed in inevitable struggle",
			"harmony gave way to necessary discord",
			"resistance met its equal and opposite"
		],
		"harmony": [
			"disparate elements found perfect balance",
			"resonance aligned what was once chaotic",
			"peace settled where turmoil once reigned"
		],
		"transcendence": [
			"consciousness expanded beyond previous limits",
			"the material gave way to something greater",
			"boundaries dissolved into greater wholeness"
		],
		"connection": [
			"threads of relationship wove a complex tapestry",
			"bridges formed between separate islands of being",
			"isolated points joined into meaningful patterns"
		],
		"isolation": [
			"silence fell where voices once called",
			"distances grew between once-connected souls",
			"solitude revealed its double-edged wisdom"
		],
		"sacrifice": [
			"what was given allowed something greater to emerge",
			"the price paid opened doors otherwise closed",
			"loss transformed into unexpected gain"
		]
	}
	
	if phrases.has(theme):
		var options = phrases[theme]
		return options[randi() % options.size()]
	else:
		return "the story continued to unfold"

func generate_action_phrase(theme: String) -> String:
	var actions = [
		"ventured deeper into the unknown",
		"uncovered ancient secrets",
		"forged connections between worlds",
		"witnessed the transformation",
		"channeled energies of creation",
		"faced shadows of doubt",
		"gathered fragments of memory",
		"wove patterns of meaning",
		"traversed boundaries of perception",
		"challenged the established order",
		"planted seeds of possibility",
		"reflected upon inner truths"
	]
	
	return actions[randi() % actions.size()]

func generate_discovery_phrase() -> String:
	var discoveries = [
		"pathways previously hidden",
		"the true nature of reality",
		"a doorway between dimensions",
		"echoes of forgotten stories",
		"the source of creation itself",
		"reflections of other universes",
		"patterns connecting all things",
		"keys to transformation",
		"the fabric of space and time",
		"whispers from distant realms",
		"fragments of divine knowledge",
		"the essence of consciousness"
	]
	
	return discoveries[randi() % discoveries.size()]

func generate_location_phrase(location: String) -> String:
	var phrases = {
		"origin_point": [
			"At the center where all began",
			"Within the nexus of creation",
			"At the convergence of all possibility"
		],
		"crossroads": [
			"Where multiple paths intersected",
			"At the junction of realities",
			"Between choices that shaped destinies"
		],
		"ancient_temple": [
			"Among pillars of forgotten wisdom",
			"Within halls consecrated by time",
			"Beneath sacred geometries of stone"
		],
		"forgotten_city": [
			"Through abandoned streets once teeming with life",
			"Among ruins that whispered stories",
			"Within architecture of a lost civilization"
		],
		"dream_nexus": [
			"In the shifting landscape of unconscious thought",
			"Where dreams collected like morning dew",
			"Among manifestations of collective imagination"
		],
		"crystal_forest": [
			"Between prismatic trees of light",
			"Where reality refracted into spectrum",
			"Amid crystalline structures resonating with energy"
		],
		"void_expanse": [
			"In the vast emptiness between existences",
			"Where nothingness held infinite potential",
			"Adrift in the sea of primal chaos"
		],
		"memory_palace": [
			"Among chambers of preserved experience",
			"Where the past remained eternally present",
			"Within architecture built from recollection"
		],
		"digital_realm": [
			"Inside the infinite network of information",
			"Where data formed its own reality",
			"Among streams of organized energy"
		],
		"astral_sea": [
			"Upon waves of pure consciousness",
			"Where thought took tangible form",
			"Adrift in the ocean of mind"
		],
		"quantum_labyrinth": [
			"Within corridors of probability",
			"Where all possibilities existed simultaneously",
			"Along paths that both were and were not"
		],
		"time_spiral": [
			"Where moments flowed in cycles rather than lines",
			"Among spirals of past and future",
			"Between layers of temporal experience"
		]
	}
	
	if phrases.has(location):
		var options = phrases[location]
		return options[randi() % options.size()]
	else:
		return "In this realm of existence"

func generate_event_phrase(theme: String) -> String:
	var events = [
		"a significant change began to manifest",
		"unexpected allies revealed themselves",
		"ancient prophecies came to fruition",
		"the impossible became momentarily possible",
		"patterns of destiny became clear",
		"forces long dormant awakened once more",
		"boundaries between worlds grew thin",
		"echoes of other timelines resonated",
		"what was broken found wholeness again",
		"the essence of truth revealed itself",
		"a new understanding was born",
		"the cycle prepared to begin anew"
	]
	
	return events[randi() % events.size()]

func generate_consequence_phrase(theme: String) -> String:
	var consequences = [
		"reality shifted in subtle but profound ways",
		"new possibilities emerged from previous limitations",
		"the multiverse adjusted to maintain balance",
		"ripples of change spread outward in all directions",
		"what seemed fixed revealed its fluid nature",
		"perspectives expanded beyond previous horizons",
		"the narrative of existence gained new chapters",
		"seeds planted long ago finally bore fruit",
		"the unseen became visible to those who sought",
		"patterns of meaning revealed their deeper structure",
		"the dance of creation continued its eternal movement",
		"the relationship between observer and observed transformed"
	]
	
	return consequences[randi() % consequences.size()]

func generate_transformation_phrase() -> String:
	var transformations = [
		"transcended previous limitations",
		"evolved into something unexpected",
		"bridged worlds previously separate",
		"harmonized conflicting elements",
		"discovered the power of words to shape reality",
		"wove new patterns from old threads",
		"illuminated darkness with understanding",
		"brought order to seeming chaos",
		"found unity within diversity",
		"transmuted obstacles into opportunities",
		"recognized the self in the other",
		"awakened to greater possibilities"
	]
	
	return transformations[randi() % transformations.size()]

func apply_player_influence(fragment: String, story_data: Dictionary) -> String:
	# Modify the fragment based on player actions or state
	
	# This would be more sophisticated in a full implementation
	# connected to the player controller
	
	if randf() > player_influence_weight:
		return fragment
	
	var player_additions = [
		" The wanderer's presence was felt throughout.",
		" This resonated with the traveler's journey.",
		" Such events seemed to follow in the wake of the explorer.",
		" The observer's influence, though subtle, was undeniable.",
		" A presence moved through these events, changing their course."
	]
	
	return fragment + player_additions[randi() % player_additions.size()]

func apply_universe_influence(fragment: String, universe_data: Dictionary) -> String:
	# Modify the fragment based on current universe properties
	
	if randf() > universe_influence_weight:
		return fragment
	
	var universe_type = "physical"
	if universe_data.has("type"):
		universe_type = universe_data.type
	
	var universe_additions = {
		"physical": [
			" The fabric of material reality shaped these events.",
			" Physical laws provided structure to the unfolding tale.",
			" Matter and energy danced in harmony."
		],
		"digital": [
			" Information flowed like rivers through this realm.",
			" Code became poetry in the digital tapestry.",
			" Binary patterns held meaning beyond their simple states."
		],
		"astral": [
			" Consciousness itself was the medium of creation here.",
			" Thought and emotion painted the landscape.",
			" The boundaries between mind and reality blurred."
		],
		"dream": [
			" Logic bent in ways only dreams allow.",
			" The impossible and the inevitable coexisted.",
			" Symbols spoke louder than literal meanings."
		],
		"quantum": [
			" Probability clouds coalesced into momentary certainty.",
			" Every possibility existed simultaneously.",
			" Observer and observed engaged in their eternal dance."
		],
		"conceptual": [
			" Pure ideas took form without need for substance.",
			" Abstractions became more real than concrete things.",
			" The architecture of thought itself was visible."
		]
	}
	
	if universe_additions.has(universe_type):
		var additions = universe_additions[universe_type]
		return fragment + additions[randi() % additions.size()]
	else:
		return fragment

func should_branch_story(story_data: Dictionary) -> bool:
	# Determine if a story should branch based on complexity and progress
	
	# Only branch if complexity allows
	if story_complexity < 3:
		return false
	
	# Only branch after some progress
	if story_data.fragments.size() < 3:
		return false
	
	# Only branch if not too many branches already
	if story_data.branches.size() >= story_complexity - 1:
		return false
	
	// Chance increases with complexity
	var branch_chance = 0.1 * (story_complexity - 2)
	
	return randf() < branch_chance

func branch_story(story_id: String):
	if not active_stories.has(story_id):
		return false
	
	var parent_story = active_stories[story_id]
	
	// Create a story branch
	var last_fragment = parent_story.fragments[parent_story.fragments.size() - 1]
	var transition = transition_phrases[randi() % transition_phrases.size()]
	
	// Generate branch seed
	var branch_seed = transition + " " + generate_branch_seed(parent_story)
	
	// Create the branch
	var branch_id = create_story(
		parent_story.theme, 
		story_archetypes[randi() % story_archetypes.size()], 
		parent_story.location,
		parent_story.universe_id,
		branch_seed
	)
	
	// Register the branch
	parent_story.branches.append(branch_id)
	
	// Create a connection between the stories
	connect_stories(story_id, branch_id, "branch")
	
	print("JSH Story Generator: Created branch '" + branch_id + "' from story '" + story_id + "'")
	
	return branch_id

func generate_branch_seed(parent_story: Dictionary) -> String:
	// Create a seed for a branching story
	
	var seed_templates = [
		"Another aspect of this tale revealed itself.",
		"From a different perspective, events unfolded differently.",
		"A parallel narrative emerged from the same origin.",
		"The story split like light through a prism.",
		"What seemed like one path revealed its many branches."
	]
	
	return seed_templates[randi() % seed_templates.size()]

func complete_story(story_id: String):
	if not active_stories.has(story_id):
		return false
	
	var story_data = active_stories[story_id]
	
	// Mark as complete
	story_data.status = "completed"
	story_data.completion = 1.0
	
	// Add conclusion if needed
	if not is_conclusion(story_data.fragments[story_data.fragments.size() - 1]):
		var conclusion = generate_conclusion(story_data)
		story_data.fragments.append(conclusion)
	
	// Emit signal
	emit_signal("story_completed", story_id)
	
	// If story persistence is enabled, save stories
	if story_persistence:
		save_stories()
	
	print("JSH Story Generator: Completed story '" + story_id + "'")
	
	return true

func is_conclusion(fragment: String) -> bool:
	// Check if a fragment seems like a conclusion
	var conclusion_indicators = [
		"finally", "ultimately", "in the end", "at last", 
		"concluded", "completed", "fulfilled", "closed"
	]
	
	var lower_fragment = fragment.to_lower()
	
	for indicator in conclusion_indicators:
		if lower_fragment.find(indicator) >= 0:
			return true
	
	return false

func generate_conclusion(story_data: Dictionary) -> String:
	// Generate a concluding fragment for a story
	
	var conclusions = [
		"Thus the tale of " + story_data.theme + " reached its culmination, though echoes would remain.",
		"The journey complete, the " + story_data.archetype + " found transformation through " + story_data.theme + ".",
		"What began in " + story_data.location + " concluded, but its influence continued to ripple outward.",
		"The cycle completed itself, ready to begin anew in different forms.",
		"In the end, the story itself became part of the fabric of the multiverse."
	]
	
	return conclusions[randi() % conclusions.size()]

# ========== Story Connections ==========

func connect_random_stories():
	if active_stories.size() < 2:
		return false
	
	// Get two different random stories
	var story_ids = active_stories.keys()
	var story_id_1 = story_ids[randi() % story_ids.size()]
	var story_id_2 = story_id_1
	
	while story_id_2 == story_id_1:
		story_id_2 = story_ids[randi() % story_ids.size()]
	
	// Connect them
	return connect_stories(story_id_1, story_id_2, "parallel")

func connect_stories(story_id_1: String, story_id_2: String, connection_type: String = "parallel"):
	if not active_stories.has(story_id_1) or not active_stories.has(story_id_2):
		return false
	
	// Ensure connection dictionaries exist
	if not story_connections.has(story_id_1):
		story_connections[story_id_1] = []
	
	if not story_connections.has(story_id_2):
		story_connections[story_id_2] = []
	
	// Add connections if they don't exist
	if not story_id_2 in story_connections[story_id_1]:
		story_connections[story_id_1].append(story_id_2)
	
	if not story_id_1 in story_connections[story_id_2]:
		story_connections[story_id_2].append(story_id_1)
	
	// Add connection fragment to both stories
	var connection_fragment = generate_connection_fragment(
		active_stories[story_id_1], 
		active_stories[story_id_2],
		connection_type
	)
	
	active_stories[story_id_1].fragments.append(connection_fragment)
	active_stories[story_id_2].fragments.append(connection_fragment)
	
	// Update last updated timestamp
	active_stories[story_id_1].last_updated = OS.get_unix_time()
	active_stories[story_id_2].last_updated = OS.get_unix_time()
	
	// Emit signal
	emit_signal("stories_connected", story_id_1, story_id_2, connection_type)
	
	print("JSH Story Generator: Connected stories '" + story_id_1 + "' and '" + story_id_2 + "'")
	
	return true

func generate_connection_fragment(story_1: Dictionary, story_2: Dictionary, connection_type: String) -> String:
	// Create a fragment that connects two stories
	
	match connection_type:
		"branch":
			var templates = [
				"The narrative branched like a river finding new channels.",
				"From one origin, multiple possibilities unfolded.",
				"The story split into parallel experiences.",
				"What seemed like one path revealed its fractal nature."
			]
			return templates[randi() % templates.size()]
			
		"parallel":
			var templates = [
				"Meanwhile, in " + story_2.location + ", events mirrored those occurring elsewhere.",
				"Across different journeys, patterns echoed and resonated.",
				"Separate tales began to interweave in the fabric of existence.",
				"The " + story_1.archetype + " and the " + story_2.archetype + " walked parallel paths without knowing."
			]
			return templates[randi() % templates.size()]
			
		"convergence":
			var templates = [
				"Paths once separate now converged toward a common destination.",
				"Different journeys revealed themselves as parts of a greater whole.",
				"The seemingly unrelated tales of " + story_1.theme + " and " + story_2.theme + " now intersected.",
				"Destiny drew separate threads together into a single tapestry."
			]
			return templates[randi() % templates.size()]
			
		_:
			return "The stories connected across the multiverse."

# ========== Story Management ==========

func process_active_stories():
	// Apply effects from stories to reality
	for story_id in active_stories:
		var story_data = active_stories[story_id]
		
		// Only active stories influence reality
		if story_data.status != "active":
			continue
		
		// Chance based on story progression
		if randf() < (story_data.completion * 0.3):
			apply_story_to_reality(story_id)

func apply_story_to_reality(story_id: String):
	if not active_stories.has(story_id):
		return
	
	var story_data = active_stories[story_id]
	
	// Determine effect type based on theme
	var effect_type = "ambient"
	if story_data.theme in ["creation", "rebirth", "transformation"]:
		effect_type = "creative"
	elif story_data.theme in ["destruction", "conflict", "sacrifice"]:
		effect_type = "destructive"
	elif story_data.theme in ["harmony", "connection", "transcendence"]:
		effect_type = "harmonizing"
	else:
		effect_type = "ambient"
	
	// List of affected entities (in a full implementation, this would be actual entities)
	var affected_entities = []
	
	// In a full implementation, this would perform actual effects on the game world
	// based on the story theme and progress
	
	// Emit signal
	emit_signal("story_affected_reality", story_id, effect_type, affected_entities)
	
	print("JSH Story Generator: Story '" + story_id + "' affected reality")

func get_active_story_count() -> int:
	var count = 0
	for story_id in active_stories:
		if active_stories[story_id].status == "active":
			count += 1
	return count

func get_completed_story_count() -> int:
	var count = 0
	for story_id in active_stories:
		if active_stories[story_id].status == "completed":
			count += 1
	return count

func get_stories_at_location(location: String) -> Array:
	if story_locations.has(location):
		var story_ids = story_locations[location]
		var stories = []
		
		for story_id in story_ids:
			if active_stories.has(story_id):
				stories.append(active_stories[story_id])
		
		return stories
	
	return []

func get_story_by_id(story_id: String) -> Dictionary:
	if active_stories.has(story_id):
		return active_stories[story_id]
	return {}

func get_story_connections(story_id: String) -> Array:
	if story_connections.has(story_id):
		return story_connections[story_id]
	return []

func get_full_story_text(story_id: String) -> String:
	if not active_stories.has(story_id):
		return ""
	
	var story_data = active_stories[story_id]
	var text = ""
	
	for fragment in story_data.fragments:
		text += fragment + "\n\n"
	
	return text

# ========== Persistence ==========

func save_stories():
	if not story_persistence:
		return
	
	var save_data = {
		"active_stories": active_stories,
		"story_connections": story_connections,
		"story_locations": story_locations
	}
	
	var file = File.new()
	var result = file.open("user://stories.save", File.WRITE)
	
	if result == OK:
		file.store_var(save_data)
		file.close()
		print("JSH Story Generator: Saved stories")
	else:
		print("JSH Story Generator: Failed to save stories")

func load_stories():
	var file = File.new()
	
	if file.file_exists("user://stories.save"):
		var result = file.open("user://stories.save", File.READ)
		
		if result == OK:
			var save_data = file.get_var()
			file.close()
			
			if save_data.has("active_stories"):
				active_stories = save_data.active_stories
			
			if save_data.has("story_connections"):
				story_connections = save_data.story_connections
			
			if save_data.has("story_locations"):
				story_locations = save_data.story_locations
			
			print("JSH Story Generator: Loaded stories")
			return true
		else:
			print("JSH Story Generator: Failed to load stories")
	
	return false