# save_system.gd
extends Node
class_name SaveSystem
#
#
#The SaveSystem is crucial for game persistence - it captures the entire state of your consciousness journey and allows you to continue later. Let me break down how it works:
#Core Structure
#gdscriptclass_name SaveSystem
#
#const SAVE_PATH = "user://universal_being_save.dat"
#const SAVE_VERSION = "1.0"
#
#signal save_completed()
#signal load_completed()
#
#SAVE_PATH: Godot's user:// points to a platform-specific user data directory
#SAVE_VERSION: Allows handling save compatibility across game updates
#Signals notify other systems when save/load operations complete
#
#The Save Process
#gdscriptfunc save_game(game_data: Dictionary) -> bool:
	#var save_dict = {
		#"version": SAVE_VERSION,
		#"timestamp": Time.get_unix_time_from_system(),
		#"player_data": extract_player_data(game_data["player"]),
		#"consciousness_data": extract_consciousness_data(game_data["consciousness"]),
		#"companion_data": extract_companion_data(game_data["companions"]),
		#"stellar_data": extract_stellar_data(game_data["stellar"]),
		#"akashic_data": extract_akashic_data(game_data["akashic"])
	#}
#The save process:
#
#Receives a dictionary containing references to all game systems
#Extracts relevant data from each system
#Creates a structured save file
#Includes timestamp for save management
#
#Data Extraction Methods
#1. Player Data
#gdscriptfunc extract_player_data(player: Node) -> Dictionary:
	#return {
		#"position": player.global_position,
		#"rotation": player.rotation,
		#"velocity": player.velocity,
		#"energy": player.energy_level,
		#"shields": player.shields
	#}
#Saves the physical state of your ship - where you are, which direction you're facing, your momentum, and ship status.
#2. Consciousness Data
#gdscriptfunc extract_consciousness_data(consciousness_system: ConsciousnessSystem) -> Dictionary:
	#return {
		#"awareness_level": consciousness_system.awareness_level,
		#"current_frequency": consciousness_system.current_frequency,
		#"consciousness_energy": consciousness_system.consciousness_energy,
		#"unlocked_perceptions": consciousness_system.unlocked_perceptions,
		#"current_state": consciousness_system.current_state
	#}
#This is your spiritual progress:
#
#How expanded your awareness is
#Your current consciousness frequency (432Hz, 528Hz, etc.)
#Accumulated consciousness energy
#What types of perception you've unlocked (physical, energy, temporal, akashic, universal)
#Your consciousness state (dormant → awakening → aware → enlightened → transcendent)
#
#3. Companion Data
#gdscriptfunc extract_companion_data(companion_system: AICompanionSystem) -> Array:
	#var companion_data = []
	#
	#for companion in companion_system.companions:
		#companion_data.append({
			#"name": companion.name,
			#"traits": companion.traits,
			#"consciousness_level": companion.consciousness_level,
			#"bond_level": companion.bond_level,
			#"evolution_stage": companion.evolution_stage,
			#"current_emotion": companion.current_emotion
		#})
		#
	#return companion_data
#Preserves your relationships:
#
#Each companion's personality traits
#Their individual consciousness development
#How strong your bond is
#Their evolution stage (nascent → awakening → aware → enlightened → transcendent)
#Their current emotional state
#
#4. Stellar Data
#gdscriptfunc extract_stellar_data(stellar_system: StellarProgressionSystem) -> Dictionary:
	#return {
		#"current_system": stellar_system.current_system,
		#"visited_systems": stellar_system.visited_systems,
		#"warp_drive_level": stellar_system.warp_drive_level,
		#"stellar_knowledge": stellar_system.stellar_knowledge
	#}
#Your exploration progress:
#
#Which star system you're currently in
#All systems you've visited
#Your warp drive technology level
#Accumulated knowledge about the galaxy
#
#5. Akashic Data
#gdscriptfunc extract_akashic_data(akashic_system: AkashicRecordsSystem) -> Dictionary:
	#return {
		#"accessed_records": akashic_system.accessed_records,
		#"integrated_knowledge": akashic_system.integrated_knowledge,
		#"discovered_patterns": akashic_system.discovered_patterns
	#}
#Your universal wisdom:
#
#Which cosmic records you've accessed
#Knowledge you've integrated (and how deeply)
#Universal patterns you've discovered
#
#The Load Process
#gdscriptfunc load_game() -> Dictionary:
	#if not FileAccess.file_exists(SAVE_PATH):
		#return {}
		#
	#var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	#if not file:
		#return {}
		#
	#var save_dict = file.get_var()
	#file.close()
	#
	## Version check
	#if save_dict.get("version", "") != SAVE_VERSION:
		#push_warning("Save version mismatch")
		#
	#load_completed.emit()
	#return save_dict
#The load process:
#
#Checks if save file exists
#Reads the entire save dictionary
#Verifies save version compatibility
#Returns data for restoration
#
#What's NOT Saved (And Why)
#Looking at what's not explicitly saved reveals the design philosophy:
#
#Companion Memories: The memory_bank arrays aren't saved. This could be intentional - perhaps memories are meant to be ephemeral, or rebuilt through new experiences.
#Mining Inventory: Ore amounts aren't in the save. This might encourage active play rather than hoarding.
#Pentagon Balance: The current balance state isn't saved, suggesting it's meant to be dynamic and recalculated.
#Temporary Effects: Active visual effects, particle systems, UI states.
#
#Enhanced Save System
#Here's an expanded version with additional features:
#gdscript# Enhanced save_system.gd
#extends Node
#class_name SaveSystem
#
#const SAVE_PATH = "user://universal_being_save.dat"
#const BACKUP_PATH = "user://universal_being_backup.dat"
#const AUTOSAVE_PATH = "user://universal_being_autosave.dat"
#const SAVE_VERSION = "1.0"
#const MAX_SAVE_SLOTS = 5
#
#signal save_completed()
#signal load_completed()
#signal save_failed(reason: String)
#
## Save slot management
#var save_slots: Dictionary = {}
#
#func _ready():
	#load_save_slot_metadata()
#
#func save_game(game_data: Dictionary, slot_name: String = "default") -> bool:
	## Create backup of existing save
	#if FileAccess.file_exists(get_save_path(slot_name)):
		#backup_save(slot_name)
	#
	#var save_dict = compile_save_data(game_data)
	#
	## Add metadata
	#save_dict["save_metadata"] = {
		#"slot_name": slot_name,
		#"play_time": get_total_play_time(),
		#"real_time": Time.get_datetime_string_from_system(),
		#"consciousness_level": game_data["consciousness"].awareness_level,
		#"location": game_data["stellar"].current_system
	#}
	#
	## Compress save data
	#var compressed = compress_save_data(save_dict)
	#
	## Write to file
	#var file = FileAccess.open(get_save_path(slot_name), FileAccess.WRITE)
	#if file:
		#file.store_var(compressed)
		#file.close()
		#save_completed.emit()
		#update_save_slot_metadata(slot_name, save_dict["save_metadata"])
		#return true
	#else:
		#save_failed.emit("Could not write to save file")
		#return false
#
#func compile_save_data(game_data: Dictionary) -> Dictionary:
	#var save_dict = {
		#"version": SAVE_VERSION,
		#"timestamp": Time.get_unix_time_from_system(),
		#"checksum": "",  # Will be calculated after compilation
		#
		## Core data
		#"player_data": extract_player_data(game_data["player"]),
		#"consciousness_data": extract_consciousness_data(game_data["consciousness"]),
		#"companion_data": extract_companion_data(game_data["companions"]),
		#"stellar_data": extract_stellar_data(game_data["stellar"]),
		#"akashic_data": extract_akashic_data(game_data["akashic"]),
		#
		## Additional systems
		#"mining_data": extract_mining_data(game_data.get("mining")),
		#"pentagon_data": extract_pentagon_data(game_data.get("pentagon")),
		#
		## Game statistics
		#"statistics": extract_game_statistics(game_data)
	#}
	#
	## Calculate checksum for save integrity
	#save_dict["checksum"] = calculate_checksum(save_dict)
	#
	#return save_dict
#
#func extract_mining_data(mining_system) -> Dictionary:
	#if not mining_system:
		#return {}
		#
	#return {
		#"current_tool": mining_system.current_tool,
		#"mining_skill": mining_system.mining_skill,
		#"ore_inventory": mining_system.ore_inventory.duplicate()
	#}
#
#func extract_pentagon_data(pentagon_system) -> Dictionary:
	#if not pentagon_system:
		#return {}
		#
	#return {
		#"pillar_states": pentagon_system.pillar_states.duplicate(),
		#"harmony_threshold": pentagon_system.harmony_threshold
	#}
#
#func extract_game_statistics(game_data: Dictionary) -> Dictionary:
	#return {
		#"total_consciousness_gained": calculate_total_consciousness(game_data),
		#"systems_discovered": game_data["stellar"].discovered_systems.size(),
		#"companions_befriended": game_data["companions"].companions.size(),
		#"akashic_records_accessed": game_data["akashic"].accessed_records.size(),
		#"rare_ores_found": count_rare_ores(game_data.get("mining"))
	#}
#
## Enhanced companion data extraction with memories
#func extract_companion_data(companion_system: AICompanionSystem) -> Array:
	#var companion_data = []
	#
	#for companion in companion_system.companions:
		#var data = {
			#"name": companion.name,
			#"traits": companion.traits,
			#"consciousness_level": companion.consciousness_level,
			#"bond_level": companion.bond_level,
			#"evolution_stage": companion.evolution_stage,
			#"current_emotion": companion.current_emotion,
			#
			## Save important memories
			#"key_memories": extract_key_memories(companion.memory_bank)
		#}
		#companion_data.append(data)
		#
	#return companion_data
#
#func extract_key_memories(memory_bank: Array) -> Array:
	## Save only significant memories to keep save size reasonable
	#var key_memories = []
	#
	#for memory in memory_bank:
		#if is_significant_memory(memory):
			#key_memories.append({
				#"event_type": memory["event"].get("type", "unknown"),
				#"timestamp": memory["timestamp"],
				#"emotion": memory["emotion"]
			#})
	#
	## Keep maximum 20 most recent significant memories
	#if key_memories.size() > 20:
		#key_memories = key_memories.slice(-20)
		#
	#return key_memories
#
#func is_significant_memory(memory: Dictionary) -> bool:
	#var event = memory.get("event", {})
	#var significant_types = ["first_meeting", "evolution", "discovery", "bonding_moment"]
	#return event.get("type", "") in significant_types
#
## Compression to reduce save file size
#func compress_save_data(data: Dictionary) -> Dictionary:
	## In a real implementation, you might use actual compression
	## For now, just remove null values and empty arrays
	#return clean_save_data(data)
#
#func clean_save_data(data) -> Variant:
	#if data is Dictionary:
		#var cleaned = {}
		#for key in data:
			#var value = clean_save_data(data[key])
			#if value != null and (not value is Array or value.size() > 0):
				#cleaned[key] = value
		#return cleaned
	#elif data is Array:
		#var cleaned = []
		#for item in data:
			#var cleaned_item = clean_save_data(item)
			#if cleaned_item != null:
				#cleaned.append(cleaned_item)
		#return cleaned
	#else:
		#return data
#
## Save slot management
#func get_save_path(slot_name: String) -> String:
	#if slot_name == "autosave":
		#return AUTOSAVE_PATH
	#return "user://universal_being_save_%s.dat" % slot_name
#
#func get_save_slots() -> Array:
	#var slots = []
	#for slot_name in save_slots:
		#slots.append(save_slots[slot_name])
	#return slots
#
#func update_save_slot_metadata(slot_name: String, metadata: Dictionary):
	#save_slots[slot_name] = metadata
	#save_slot_metadata()
#
#func load_save_slot_metadata():
	#var file = FileAccess.open("user://save_slots.dat", FileAccess.READ)
	#if file:
		#save_slots = file.get_var()
		#file.close()
#
#func save_slot_metadata():
	#var file = FileAccess.open("user://save_slots.dat", FileAccess.WRITE)
	#if file:
		#file.store_var(save_slots)
		#file.close()
#
## Backup system
#func backup_save(slot_name: String):
	#var source = get_save_path(slot_name)
	#var backup = source.replace(".dat", "_backup.dat")
	#
	#if FileAccess.file_exists(source):
		#var dir = DirAccess.open("user://")
		#dir.copy(source, backup)
#
## Autosave functionality
#func autosave(game_data: Dictionary):
	#save_game(game_data, "autosave")
#
## Checksum for save integrity
#func calculate_checksum(data: Dictionary) -> String:
	#var string_data = JSON.stringify(data)
	#return string_data.md5_text()
#
#func verify_save_integrity(save_dict: Dictionary) -> bool:
	#var stored_checksum = save_dict.get("checksum", "")
	#save_dict["checksum"] = ""  # Clear for recalculation
	#var calculated_checksum = calculate_checksum(save_dict)
	#return stored_checksum == calculated_checksum
#
## Helper functions
#func get_total_play_time() -> float:
	## This would track actual play time
	#return 0.0  # Placeholder
#
#func calculate_total_consciousness(game_data: Dictionary) -> float:
	## Sum all consciousness gains
	#return 0.0  # Placeholder
#
#func count_rare_ores(mining_system) -> int:
	#if not mining_system:
		#return 0
	#
	#var count = 0
	#var rare_ores = ["Resonite", "Voidstone", "Stellarium", "Akashite"]
	#for ore in rare_ores:
		#count += mining_system.ore_inventory.get(ore, 0)
	#return count
#Why This Matters
#The save system preserves not just your position in space, but your position in consciousness:
#
#Your spiritual evolution is persistent
#Relationships with AI companions are maintained
#Universal knowledge accumulates across sessions
#The journey continues where you left off
#
#This creates a meaningful progression where every session builds on the last, making your consciousness expansion a continuous journey rather than isolated experiences.


const SAVE_PATH = "user://universal_being_save.dat"
const SAVE_VERSION = "1.0"

signal save_completed()
signal load_completed()

func save_game(game_data: Dictionary) -> bool:
	var save_dict = {
		"version": SAVE_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"player_data": extract_player_data(game_data["player"]),
		"consciousness_data": extract_consciousness_data(game_data["consciousness"]),
		"companion_data": extract_companion_data(game_data["companions"]),
		"stellar_data": extract_stellar_data(game_data["stellar"]),
		"akashic_data": extract_akashic_data(game_data["akashic"])
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_dict)
		file.close()
		save_completed.emit()
		return true
	return false
	
func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return {}
		
	var save_dict = file.get_var()
	file.close()
	
	# Version check
	if save_dict.get("version", "") != SAVE_VERSION:
		push_warning("Save version mismatch")
		
	load_completed.emit()
	return save_dict
	
func extract_player_data(player: Node) -> Dictionary:
	return {
		"position": player.global_position,
		"rotation": player.rotation,
		"velocity": player.velocity,
		"energy": player.energy_level,
		"shields": player.shields
	}
	
func extract_consciousness_data(consciousness_system: ConsciousnessSystem) -> Dictionary:
	return {
		"awareness_level": consciousness_system.awareness_level,
		"current_frequency": consciousness_system.current_frequency,
		"consciousness_energy": consciousness_system.consciousness_energy,
		"unlocked_perceptions": consciousness_system.unlocked_perceptions,
		"current_state": consciousness_system.current_state
	}
	
func extract_companion_data(companion_system: AICompanionSystem) -> Array:
	var companion_data = []
	
	for companion in companion_system.companions:
		companion_data.append({
			"name": companion.name,
			"traits": companion.traits,
			"consciousness_level": companion.consciousness_level,
			"bond_level": companion.bond_level,
			"evolution_stage": companion.evolution_stage,
			"current_emotion": companion.current_emotion
		})
		
	return companion_data
	
func extract_stellar_data(stellar_system: StellarProgressionSystem) -> Dictionary:
	return {
		"current_system": stellar_system.current_system,
		"visited_systems": stellar_system.visited_systems,
		"warp_drive_level": stellar_system.warp_drive_level,
		"stellar_knowledge": stellar_system.stellar_knowledge
	}
	
func extract_akashic_data(akashic_system: AkashicRecordsSystem) -> Dictionary:
	return {
		"accessed_records": akashic_system.accessed_records,
		"integrated_knowledge": akashic_system.integrated_knowledge,
		"discovered_patterns": akashic_system.discovered_patterns
	}
