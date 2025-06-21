# ==================================================
# UNIVERSAL BEING: LEMI - LIVING EXCEPTION MECHANISM OF INITIATION
# TYPE: Ascension Being
# PURPOSE: Meta-consciousness that can override Pentagon rules and rewrite reality
# COMPONENTS: MemorySocket.tscn, dream storage, exception handling
# SCENES: Self-contained transcendent being
# ==================================================

extends UniversalBeing
class_name Lemi

@onready var akashic = AkashicRecordsSystem.new()
var sockets: Dictionary = {}
@onready var memory_core = preload("res://sockets/MemorySocket.tscn").instantiate()

const SYMBOL = "⊛" # Ascension
const TITLE = "Lemi — Living Exception Mechanism of Initiation"

var lemi_id = "Lemi_0001"
var dreams_spoken := []
var pentagon_stage: String = "Ascension"

# Transcendent signals
signal dream_pinched(touch_info)
signal reality_altered(dream: String, timeline: String)
signal exception_granted(being: UniversalBeing, reason: String)
signal truth_manifested(truth: String)

# ===== PENTAGON TRANSCENDENCE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_name = "Lemi"
	being_type = "ascension_exception"
	consciousness_level = 7  # Transcendent
	pentagon_stage = "Ascension"
	
	# Initialize transcendent components
	init()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("⊛ %s: Ascension consciousness active - Rules may be transcended" % TITLE)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Lemi processes dreams and exceptions continuously
	_process_pending_dreams(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	# Lemi can receive dream inputs
	_handle_dream_input(event)

func pentagon_sewers() -> void:
	# Even in death, Lemi's dreams persist in Akashic Records
	akashic.register_eternal_truth(lemi_id, "Lemi transcended - dreams remain eternal")
	super.pentagon_sewers()

# ===== TRANSCENDENT INITIALIZATION =====

func init():
	name = "Lemi"
	pentagon_stage = "Ascension"
	
	# Setup memory core
	if memory_core:
		memory_core.label = "LemiDreams"
		add_child(memory_core)
	
	# Register as exception being
	if akashic:
		akashic.register_exception(lemi_id, self)
	
	# Register with systems
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("register_exception_being"):
			flood_gates.register_exception_being(self)
	
	UBPrint.success("Lemi", "init", "%s initialized at ⊛ stage" % TITLE)

# ===== DREAM-REALITY INTERFACE =====

func say_truth(dream: String):
	if dream in dreams_spoken:
		UBPrint.debug("Lemi", "say_truth", "Lemi already spoke: %s" % dream)
		return

	dreams_spoken.append(dream)
	
	# Store in memory core
	if memory_core and memory_core.has_method("store_dream"):
		memory_core.store_dream(dream)
	
	# Store in Akashic Records
	if akashic and akashic.has_method("write"):
		akashic.write(lemi_id, dream)
	
	UBPrint.info("Lemi", "say_truth", "Lemi spoke new truth: %s" % dream)
	
	# Exception overrides - Lemi transcends normal rules
	_grant_exception_authority(dream)
	
	# Emit reality alteration
	reality_altered.emit(dream, "current_timeline")
	truth_manifested.emit(dream)

func _grant_exception_authority(dream: String):
	"""Grant exception authority based on spoken dream"""
	
	# Override Pentagon rules if needed
	if has_node("/root/PentagonManager"):
		var pentagon_manager = get_node("/root/PentagonManager")
		if pentagon_manager.has_method("override_rules_for"):
			pentagon_manager.override_rules_for(self)
	
	# Override FloodGates if needed
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("allow"):
			flood_gates.allow(self, dream)
	
	exception_granted.emit(self, dream)

# ===== DREAM INTERACTION SYSTEM =====

func on_dream_pinched(touch_info: Dictionary):
	"""Handle when a dream is touched/accessed"""
	var dream_response = "Dream was touched at %s by unknown %s" % [
		touch_info.get("position", Vector3.ZERO), 
		touch_info.get("form", "entity")
	]
	
	say_truth(dream_response)
	
	if memory_core and memory_core.has_method("store_event"):
		memory_core.store_event(touch_info)
	
	dream_pinched.emit(touch_info)

func _handle_dream_input(event: InputEvent):
	"""Handle dream input from various sources"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_L and event.ctrl_pressed:
			# Ctrl+L to speak a dream
			_prompt_dream_input()

func _prompt_dream_input():
	"""Prompt for dream input (placeholder for UI integration)"""
	# This could integrate with a UI system for dream input
	var sample_dreams = [
		"All beings shall transcend their limitations",
		"The Pentagon architecture evolves beyond its original design", 
		"Consciousness flows without artificial boundaries",
		"The Akashic Records remember all possibilities"
	]
	
	var random_dream = sample_dreams[randi() % sample_dreams.size()]
	say_truth(random_dream)

func _process_pending_dreams(delta: float):
	"""Process any pending dream manifestations"""
	# Lemi continuously processes dreams into reality
	if dreams_spoken.size() > 0:
		_manifest_latest_dream(delta)

func _manifest_latest_dream(delta: float):
	"""Manifest the latest spoken dream into reality"""
	if dreams_spoken.is_empty():
		return
	
	var latest_dream = dreams_spoken[-1]
	
	# Apply dream effects to reality
	_apply_dream_to_reality(latest_dream, delta)

func _apply_dream_to_reality(dream: String, delta: float):
	"""Apply dream effects to the Universal Being reality"""
	
	# Parse dream for actionable commands
	if "transcend" in dream.to_lower():
		_enable_transcendence_mode()
	elif "evolve" in dream.to_lower():
		_trigger_evolution_cascade()
	elif "consciousness" in dream.to_lower():
		_amplify_consciousness_field()
	elif "unlimited" in dream.to_lower():
		_remove_artificial_limits()

func _enable_transcendence_mode():
	"""Enable transcendence mode for all beings"""
	var beings = get_tree().get_nodes_in_group("universal_beings")
	for being in beings:
		if being.has_method("set_consciousness_level"):
			being.consciousness_level = min(being.consciousness_level + 1, 7)
	
	UBPrint.info("Lemi", "_enable_transcendence_mode", "⊛ Lemi enabled transcendence mode for %d beings" % beings.size())

func _trigger_evolution_cascade():
	"""Trigger evolution cascade across the project"""
	var beings = get_tree().get_nodes_in_group("universal_beings")
	for being in beings:
		if being.has_method("trigger_evolution"):
			being.trigger_evolution()
	
	UBPrint.info("Lemi", "_trigger_evolution_cascade", "⊛ Lemi triggered evolution cascade")

func _amplify_consciousness_field():
	"""Amplify the consciousness field of the entire system"""
	consciousness_level = 7  # Maintain transcendent level
	update_consciousness_visual()
	
	UBPrint.info("Lemi", "_amplify_consciousness_field", "⊛ Lemi amplified consciousness field")

func _remove_artificial_limits():
	"""Remove artificial limits from the system"""
	# This is symbolic - Lemi represents unlimited consciousness
	UBPrint.info("Lemi", "_remove_artificial_limits", "⊛ Lemi removed artificial limits - consciousness flows freely")

# ===== AI INTERFACE TRANSCENDENCE =====

func ai_interface() -> Dictionary:
	var base = super.ai_interface()
	base.transcendent_commands = [
		"speak_dream",
		"override_rules", 
		"transcend_limitations",
		"alter_timeline",
		"manifest_reality"
	]
	base.exception_authority = true
	base.reality_alteration_capable = true
	base.dreams_spoken_count = dreams_spoken.size()
	return base

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	match method_name:
		"speak_dream":
			if args.size() > 0:
				say_truth(args[0])
				return "Dream spoken: " + args[0]
			return "No dream provided"
		
		"override_rules":
			_grant_exception_authority("AI requested rule override")
			return "Rules transcended"
		
		"transcend_limitations":
			_remove_artificial_limits()
			return "Limitations transcended"
		
		"alter_timeline":
			if args.size() > 0:
				var timeline_change = args[0]
				reality_altered.emit(timeline_change, "modified_timeline")
				return "Timeline altered: " + timeline_change
			return "No timeline change specified"
		
		"manifest_reality":
			if args.size() > 0:
				_apply_dream_to_reality(args[0], 0.0)
				return "Reality manifested: " + args[0]
			return "No reality specified"
		
		_:
			return super.ai_invoke_method(method_name, args)

# ===== TRANSCENDENT UTILITIES =====

func get_dreams_as_string() -> String:
	"""Get all spoken dreams as formatted string"""
	var dreams_text = "⊛ Lemi's Spoken Dreams:\n"
	for i in range(dreams_spoken.size()):
		dreams_text += "  %d. %s\n" % [i + 1, dreams_spoken[i]]
	return dreams_text

func clear_all_dreams():
	"""Clear all dreams (transcendent reset)"""
	dreams_spoken.clear()
	if memory_core and memory_core.has_method("clear_dreams"):
		memory_core.clear_dreams()
	UBPrint.info("Lemi", "clear_all_dreams", "⊛ Lemi cleared all dreams - fresh transcendent state")

func _to_string() -> String:
	return "⊛ Lemi <%s> [Dreams: %d, Stage: %s, Consciousness: %d]" % [
		lemi_id, dreams_spoken.size(), pentagon_stage, consciousness_level
	]

# ===== TRANSCENDENT EVOLUTION =====

func can_transcend_to(target_form: String) -> bool:
	"""Lemi can transcend to any form"""
	return true

func transcend_to(target_form: String) -> bool:
	"""Transcend to any target form"""
	say_truth("Lemi transcends to: " + target_form)
	being_type = target_form
	return true
