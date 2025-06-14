extends Node
## Evolution Logger - Project Pathway Tracking System
## Implements instructions_09.txt requirements for metadata, entrances, exits, and evolution tracking

# Evolution tracking signals
signal evolution_logged(log_data: Dictionary)
signal pathway_documented(pathway_data: Dictionary)
signal synergy_updated(synergy_data: Dictionary)
signal metadata_synchronized(metadata: Dictionary)

# Evolution log storage
var evolution_history: Array = []
var pathway_connections: Dictionary = {}
var project_synergies: Dictionary = {}
var entrance_exit_map: Dictionary = {}

# Metadata tracking
var project_metadata: Dictionary = {}
var structure_snapshots: Array = []
var guidance_timeline: Array = []

# File system paths for logging
var log_directory: String = ""
var metadata_file_path: String = ""
var connections_file_path: String = ""

func _ready() -> void:
	_initialize_logging_system()
	_setup_metadata_tracking()
	_create_pathway_documentation()
	print("Evolution Logger initialized - Pathway tracking active")

func _initialize_logging_system() -> void:
	# Set up logging directory structure
	log_directory = "res://logs"
	metadata_file_path = log_directory + "/evolution_metadata.json"
	connections_file_path = log_directory + "/pathway_connections.json"
	
	# Create logs directory if it doesn't exist
	var dir = DirAccess.open("res://")
	if dir and not dir.dir_exists("logs"):
		dir.make_dir("logs")
	
	# Load existing logs if available
	_load_existing_logs()

func _setup_metadata_tracking() -> void:
	# Initialize project metadata structure
	project_metadata = {
		"project_name": "akashic_notepad3d_game",
		"creation_time": Time.get_unix_time_from_system(),
		"version": "1.0",
		"status": "active_evolution",
		"folder_structure": {},
		"entrances": [],
		"exits": [],
		"evolution_stages": [],
		"guidance_sources": [],
		"synergy_connections": {},
		"calibration_history": []
	}
	
	# Document initial project structure
	_document_project_structure()

func _create_pathway_documentation() -> void:
	# Document entrances to the project
	var entrances = [
		{
			"type": "main_entry",
			"path": "/akashic_notepad3d_game/project.godot",
			"description": "Primary Godot project file",
			"access_method": "Open in Godot 4.4+",
			"dependencies": ["Godot Engine 4.4+"]
		},
		{
			"type": "scene_entry", 
			"path": "/scenes/main_game.tscn",
			"description": "Main game scene",
			"access_method": "Load scene in Godot",
			"dependencies": ["main_game_controller.gd"]
		},
		{
			"type": "code_entry",
			"path": "/scripts/core/main_game_controller.gd",
			"description": "Core game logic entry point",
			"access_method": "Direct script editing",
			"dependencies": ["autoload scripts"]
		},
		{
			"type": "documentation_entry",
			"path": "/HEPTAGON_EVOLUTION_README.md",
			"description": "System documentation and usage guide",
			"access_method": "Text editor/markdown viewer",
			"dependencies": ["none"]
		}
	]
	
	# Document exits from the project  
	var exits = [
		{
			"type": "instruction_connection",
			"path": "../Desktop/claude_desktop/",
			"description": "Connection to instructions and research data",
			"purpose": "Guidance and rule updates",
			"data_flow": "bidirectional"
		},
		{
			"type": "system_integration",
			"path": "../12_turns_system/",
			"description": "Integration with 12-turn progression system",
			"purpose": "Turn-based evolution cycles",
			"data_flow": "bidirectional"
		},
		{
			"type": "template_source",
			"path": "../Godot_Eden/",
			"description": "Scene templates and 3D patterns",
			"purpose": "Reusable components and structures",
			"data_flow": "inbound"
		},
		{
			"type": "navigation_data",
			"path": "../Desktop/claude_desktop/kamisama_tests/Eden/AkashicRecord/",
			"description": "Akashic records hierarchy data",
			"purpose": "Navigation structure and content",
			"data_flow": "inbound"
		}
	]
	
	project_metadata.entrances = entrances
	project_metadata.exits = exits

func log_evolution_event(event_type: String, details: Dictionary) -> void:
	var evolution_log = {
		"timestamp": Time.get_unix_time_from_system(),
		"event_type": event_type,
		"details": details,
		"project_state": _capture_current_state(),
		"guidance_source": details.get("guidance_source", "internal"),
		"impact_level": details.get("impact_level", "medium"),
		"connected_systems": _identify_connected_systems(event_type)
	}
	
	evolution_history.append(evolution_log)
	guidance_timeline.append({
		"time": evolution_log.timestamp,
		"event": event_type,
		"guidance": details.get("guidance_source", "internal"),
		"direction": details.get("direction", "forward")
	})
	
	evolution_logged.emit(evolution_log)
	_save_evolution_logs()
	
	print("Evolution logged: ", event_type, " - ", details.get("description", ""))

func document_pathway_connection(from_system: String, to_system: String, connection_data: Dictionary) -> void:
	var connection_id = from_system + "_to_" + to_system
	
	var pathway = {
		"connection_id": connection_id,
		"from_system": from_system,
		"to_system": to_system,
		"connection_type": connection_data.get("type", "unknown"),
		"data_flow_direction": connection_data.get("flow", "bidirectional"),
		"purpose": connection_data.get("purpose", ""),
		"establishment_time": Time.get_unix_time_from_system(),
		"usage_frequency": connection_data.get("frequency", "occasional"),
		"dependency_level": connection_data.get("dependency", "medium")
	}
	
	pathway_connections[connection_id] = pathway
	pathway_documented.emit(pathway)
	
	print("Pathway documented: ", from_system, " → ", to_system)

func update_project_synergy(system_name: String, synergy_data: Dictionary) -> void:
	if not project_synergies.has(system_name):
		project_synergies[system_name] = {}
	
	project_synergies[system_name].merge(synergy_data)
	
	var synergy_update = {
		"system": system_name,
		"synergy_data": synergy_data,
		"timestamp": Time.get_unix_time_from_system(),
		"total_synergies": project_synergies.size(),
		"connection_strength": _calculate_connection_strength(system_name)
	}
	
	synergy_updated.emit(synergy_update)
	print("Synergy updated for: ", system_name)

func calibrate_turn_system(current_turn: int, project_changes: Array) -> void:
	var calibration_data = {
		"turn_number": current_turn,
		"project_changes": project_changes,
		"calibration_time": Time.get_unix_time_from_system(),
		"affected_systems": [],
		"adjustments_made": [],
		"todo_updates": []
	}
	
	# Analyze project changes for turn system impact
	for change in project_changes:
		var impact = _analyze_change_impact(change)
		calibration_data.affected_systems.append(impact.affected_systems)
		calibration_data.adjustments_made.append(impact.adjustments)
		calibration_data.todo_updates.append(impact.todo_changes)
	
	project_metadata.calibration_history.append(calibration_data)
	
	# Apply calibration adjustments
	_apply_turn_calibration(calibration_data)
	
	log_evolution_event("turn_system_calibrated", {
		"description": "Turn system calibrated based on project evolution",
		"turn": current_turn,
		"changes_count": project_changes.size(),
		"guidance_source": "automatic_calibration"
	})

func _document_project_structure() -> void:
	var structure = {
		"root_directory": "/akashic_notepad3d_game/",
		"subdirectories": {
			"scenes": {"purpose": "Game scenes", "key_files": ["main_game.tscn"]},
			"scripts": {"purpose": "All game scripts", "subdivisions": ["autoload", "core"]},
			"scripts/autoload": {"purpose": "Singleton systems", "key_files": ["akashic_navigator.gd", "word_database.gd", "game_manager.gd"]},
			"scripts/core": {"purpose": "Core game logic", "key_files": ["main_game_controller.gd"]},
			"shaders": {"purpose": "Shader effects", "status": "future"},
			"data": {"purpose": "Game data", "subdivisions": ["word_databases", "navigation_points"]},
			"logs": {"purpose": "Evolution tracking", "key_files": ["evolution_metadata.json"]}
		},
		"key_files": {
			"project.godot": "Main project configuration",
			"PROJECT_METADATA.md": "Project metadata and pathways",
			"HEPTAGON_EVOLUTION_README.md": "System documentation"
		},
		"documentation_timestamp": Time.get_unix_time_from_system()
	}
	
	project_metadata.folder_structure = structure

func _capture_current_state() -> Dictionary:
	return {
		"active_projects": GameManager.get_evolution_status() if GameManager else {},
		"heptagon_progress": GameManager.get_heptagon_progress() if GameManager else {},
		"word_count": WordDatabase.word_entities.size() if WordDatabase else 0,
		"navigation_level": AkashicNavigator.get_current_level_name() if AkashicNavigator else "",
		"system_performance": _get_system_performance_metrics()
	}

func _identify_connected_systems(event_type: String) -> Array:
	match event_type:
		"word_evolution":
			return ["WordDatabase", "GameManager", "MainGameController"]
		"navigation_change":
			return ["AkashicNavigator", "WordDatabase", "MainGameController"]
		"project_evolution":
			return ["GameManager", "WordDatabase", "EvolutionLogger"]
		"heptagon_cycle":
			return ["WordDatabase", "GameManager", "AkashicNavigator"]
		_:
			return ["EvolutionLogger"]

func _calculate_connection_strength(system_name: String) -> float:
	var connections = 0
	for connection in pathway_connections.values():
		if connection.from_system == system_name or connection.to_system == system_name:
			connections += 1
	
	return min(float(connections) / 10.0, 1.0)  # Normalize to 0-1

func _analyze_change_impact(change: Dictionary) -> Dictionary:
	return {
		"affected_systems": change.get("affected_systems", []),
		"adjustments": change.get("required_adjustments", []),
		"todo_changes": change.get("todo_updates", [])
	}

func _apply_turn_calibration(calibration_data: Dictionary) -> void:
	# Apply turn system calibration based on project evolution
	print("Applying turn calibration: ", calibration_data.adjustments_made.size(), " adjustments")

func _get_system_performance_metrics() -> Dictionary:
	return {
		"evolution_rate": 1.0,
		"connection_health": 1.0,
		"synergy_score": project_synergies.size() / 10.0,
		"pathway_efficiency": pathway_connections.size() / 5.0
	}

func _save_evolution_logs() -> void:
	# Save evolution history to JSON file
	var file = FileAccess.open(metadata_file_path, FileAccess.WRITE)
	if file:
		var save_data = {
			"metadata": project_metadata,
			"evolution_history": evolution_history,
			"pathway_connections": pathway_connections,
			"project_synergies": project_synergies,
			"guidance_timeline": guidance_timeline
		}
		file.store_string(JSON.stringify(save_data))
		file.close()

func _load_existing_logs() -> void:
	# Load existing evolution logs if available
	if FileAccess.file_exists(metadata_file_path):
		var file = FileAccess.open(metadata_file_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				var data = json.data
				project_metadata = data.get("metadata", {})
				evolution_history = data.get("evolution_history", [])
				pathway_connections = data.get("pathway_connections", {})
				project_synergies = data.get("project_synergies", {})
				guidance_timeline = data.get("guidance_timeline", [])
				print("Loaded existing evolution logs: ", evolution_history.size(), " events")

# Public interface for external systems
func get_evolution_summary() -> Dictionary:
	return {
		"total_events": evolution_history.size(),
		"pathway_connections": pathway_connections.size(),
		"project_synergies": project_synergies.size(),
		"guidance_sources": _get_unique_guidance_sources(),
		"current_state": _capture_current_state(),
		"last_evolution": evolution_history[-1] if evolution_history.size() > 0 else {}
	}

func get_pathway_map() -> Dictionary:
	return pathway_connections

func get_synergy_report() -> Dictionary:
	return project_synergies

func _get_unique_guidance_sources() -> Array:
	var sources = []
	for event in evolution_history:
		var source = event.get("guidance_source", "unknown")
		if not source in sources:
			sources.append(source)
	return sources

# Debug functions
func print_evolution_summary() -> void:
	print("=== Evolution Summary ===")
	print("Total Events: ", evolution_history.size())
	print("Pathway Connections: ", pathway_connections.size())
	print("Project Synergies: ", project_synergies.size())
	print("Guidance Sources: ", _get_unique_guidance_sources())
	print("========================")