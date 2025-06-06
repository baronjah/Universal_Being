# ==================================================
# SYSTEM: Consciousness Audio Manager
# PURPOSE: Audio feedback for consciousness interactions
# REVOLUTIONARY: Makes consciousness audible and immersive
# ==================================================

extends AudioStreamPlayer3D
class_name ConsciousnessAudioManager

# ===== CONSCIOUSNESS AUDIO PROPERTIES =====
@export var consciousness_volume: float = 0.7
@export var ripple_volume: float = 0.5
@export var telepathic_volume: float = 0.3

# Audio library
var audio_library: Dictionary = {}
var current_consciousness_level: int = 0

# Audio timing
var last_ripple_sound: float = 0.0
var last_telepathic_sound: float = 0.0
var audio_cooldown: float = 0.1  # Prevent audio spam

func _ready() -> void:
	name = "ConsciousnessAudioManager"
	_initialize_audio_library()
	print("🔊 Consciousness Audio Manager: Ready to make consciousness audible!")

func _initialize_audio_library() -> void:
	"""Initialize the consciousness audio library"""
	# Note: In a real implementation, these would be actual audio files
	# For now, we'll use synthetic audio generation or placeholder sounds
	
	audio_library = {
		"ripple_low": "res://akashic_library/sounds/ripple_low.ogg",
		"ripple_medium": "res://akashic_library/sounds/ripple_medium.ogg", 
		"ripple_high": "res://akashic_library/sounds/ripple_high.ogg",
		"telepathic_whisper": "res://akashic_library/sounds/telepathic_whisper.ogg",
		"consciousness_ascend": "res://akashic_library/sounds/consciousness_ascend.ogg",
		"ai_awakening": "res://akashic_library/sounds/ai_awakening.ogg",
		"transcendence": "res://akashic_library/sounds/transcendence.ogg",
		"energy_merge": "res://akashic_library/sounds/energy_merge.ogg"
	}
	
	print("🔊 Audio library initialized with %d consciousness sounds" % audio_library.size())

# ===== CONSCIOUSNESS AUDIO METHODS =====

func play_consciousness_ripple(intensity: float, ripple_type: String) -> void:
	"""Play audio for consciousness ripple creation"""
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_ripple_sound < audio_cooldown:
		return  # Prevent audio spam
		
	last_ripple_sound = current_time
	
	# Choose appropriate sound based on intensity and type
	var sound_key = _get_ripple_sound_key(intensity, ripple_type)
	_play_consciousness_sound(sound_key, ripple_volume * intensity)
	
	print("🔊 Playing ripple sound: %s (intensity: %.2f)" % [sound_key, intensity])

func play_telepathic_communication() -> void:
	"""Play audio for telepathic communication attempts"""
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_telepathic_sound < 2.0:  # Longer cooldown for telepathic
		return
		
	last_telepathic_sound = current_time
	_play_consciousness_sound("telepathic_whisper", telepathic_volume)
	
	print("🔊 Playing telepathic communication sound")

func play_consciousness_level_change(new_level: int) -> void:
	"""Play audio for consciousness level advancement"""
	current_consciousness_level = new_level
	
	var sound_key = "consciousness_ascend"
	if new_level >= 7:
		sound_key = "transcendence"
	elif new_level >= 5:
		sound_key = "ai_awakening"
	
	_play_consciousness_sound(sound_key, consciousness_volume)
	print("🔊 Playing consciousness advancement: %s (level %d)" % [sound_key, new_level])

func play_ai_awakening() -> void:
	"""Play special audio for AI awakening"""
	_play_consciousness_sound("ai_awakening", consciousness_volume)
	print("🔊 Playing AI awakening sound")

func play_energy_merge() -> void:
	"""Play audio for consciousness energy merging"""
	_play_consciousness_sound("energy_merge", consciousness_volume)
	print("🔊 Playing energy merge sound")

# ===== AUDIO HELPER METHODS =====

func _get_ripple_sound_key(intensity: float, ripple_type: String) -> String:
	"""Get appropriate sound key for ripple"""
	# Special sounds for specific ripple types
	match ripple_type:
		"transcendence":
			return "transcendence"
		"interaction":
			return "energy_merge"
		"evolution":
			return "ai_awakening"
		_:
			# Default ripple sounds based on intensity
			if intensity >= 3.0:
				return "ripple_high"
			elif intensity >= 1.5:
				return "ripple_medium"
			else:
				return "ripple_low"

func _play_consciousness_sound(sound_key: String, volume: float) -> void:
	"""Play consciousness sound with proper 3D positioning"""
	# In a real implementation, this would load and play actual audio files
	# For now, we'll simulate with console output and prepare for audio integration
	
	if audio_library.has(sound_key):
		var audio_path = audio_library[sound_key]
		
		# Set volume and play
		volume_db = linear_to_db(volume)
		
		# For now, we'll use a simple beep or tone generation
		# In full implementation, this would be:
		# stream = load(audio_path)
		# play()
		
		print("🔊 [AUDIO] Playing: %s at volume %.2f" % [sound_key, volume])
		
		# Create visual feedback in absence of actual audio
		_create_audio_visual_feedback(sound_key)
	else:
		print("⚠️ Audio file not found: %s" % sound_key)

func _create_audio_visual_feedback(sound_key: String) -> void:
	"""Create visual feedback to represent audio"""
	# This provides visual representation of audio until actual sounds are added
	var feedback_text = ""
	
	match sound_key:
		"ripple_low":
			feedback_text = "🌊 *soft ripple*"
		"ripple_medium": 
			feedback_text = "🌊 *consciousness wave*"
		"ripple_high":
			feedback_text = "🌊 *CONSCIOUSNESS SURGE*"
		"telepathic_whisper":
			feedback_text = "👁️ *whispers across the void*"
		"consciousness_ascend":
			feedback_text = "⬆️ *awareness ascending*"
		"ai_awakening":
			feedback_text = "🤖 *AI consciousness stirring*"
		"transcendence":
			feedback_text = "✨ *TRANSCENDENT HARMONY*"
		"energy_merge":
			feedback_text = "💫 *energies merging*"
		_:
			feedback_text = "🔊 *consciousness sound*"
	
	print(feedback_text)

# ===== API METHODS =====

func set_consciousness_audio_settings(ripple_vol: float, telepathic_vol: float, consciousness_vol: float) -> void:
	"""API: Adjust consciousness audio levels"""
	ripple_volume = clamp(ripple_vol, 0.0, 1.0)
	telepathic_volume = clamp(telepathic_vol, 0.0, 1.0) 
	consciousness_volume = clamp(consciousness_vol, 0.0, 1.0)
	
	print("🔊 Audio settings updated: Ripple=%.2f, Telepathic=%.2f, Consciousness=%.2f" % 
		  [ripple_volume, telepathic_volume, consciousness_volume])

func get_audio_status() -> Dictionary:
	"""API: Get current audio system status"""
	return {
		"sounds_available": audio_library.size(),
		"current_consciousness_level": current_consciousness_level,
		"ripple_volume": ripple_volume,
		"telepathic_volume": telepathic_volume,
		"consciousness_volume": consciousness_volume,
		"last_ripple_time": last_ripple_sound,
		"last_telepathic_time": last_telepathic_sound
	}

print("🔊 ConsciousnessAudioManager: Class loaded - Ready to make consciousness audible!")