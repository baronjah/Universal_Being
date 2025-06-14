extends Node
class_name LuminousGameGenerator

# Signals
signal generation_progress(current_step, total_steps, message)
signal generation_complete(game_info)
signal generation_error(error_message)
signal asset_generated(asset_type, asset_path)

# Game generation constants
const SYSTEM_FOLDERS = ["scripts", "scenes", "assets", "models", "textures", "sounds", "ui", "levels", "config"]
const DEFAULT_CONFIG = {
    "project_name": "New Game",
    "version": "0.1.0",
    "creator": "Luminous OS",
    "resolution": Vector2i(1280, 720),
    "orientation": "landscape",
    "physics_fps": 60,
    "render_fps": 60
}

# Reference to controllers
var data_controller: LuminousDataController
var os_controller: LuminousOSController

# Game templates
var game_templates: Dictionary = {}
var generated_games: Dictionary = {}

# Game template components
var entity_templates: Dictionary = {}
var level_templates: Dictionary = {}
var gameplay_systems: Dictionary = {}
var ui_templates: Dictionary = {}

# Generation state
var current_generation: Dictionary = {}
var generation_progress_value: float = 0.0
var generation_steps: Array = []
var generation_thread: Thread

# Creation stats
var creation_stats: Dictionary = {
    "games_created": 0,
    "entities_created": 0,
    "levels_created": 0,
    "assets_created": 0,
    "lines_generated": 0
}

func _ready():
    _initialize_templates()

func _initialize_templates():
    # Game templates
    game_templates = {
        "2d_platformer": {
            "name": "2D Platformer",
            "description": "A side-scrolling platformer game with jumping, collecting, and enemies",
            "base_entities": ["player", "enemy", "collectible", "platform", "hazard"],
            "base_levels": ["tutorial", "level1", "level2", "boss"],
            "systems": ["physics", "collectibles", "health", "enemy_ai"],
            "ui_screens": ["main_menu", "game_hud", "pause", "game_over"]
        },
        "top_down_rpg": {
            "name": "Top-Down RPG",
            "description": "An RPG with quests, combat, inventory, and character progression",
            "base_entities": ["player", "npc", "enemy", "item", "chest", "door"],
            "base_levels": ["town", "dungeon", "forest", "cave"],
            "systems": ["inventory", "quest", "dialog", "combat", "character_stats"],
            "ui_screens": ["main_menu", "inventory", "dialog", "character", "world_map"]
        },
        "fps": {
            "name": "First Person Shooter",
            "description": "A 3D shooter with weapons, enemies, and multiple levels",
            "base_entities": ["player", "enemy", "weapon", "pickup", "door", "trigger"],
            "base_levels": ["training", "level1", "level2", "boss_arena"],
            "systems": ["weapons", "health", "enemy_ai", "physics", "interaction"],
            "ui_screens": ["main_menu", "hud", "pause", "game_over", "victory"]
        },
        "puzzle": {
            "name": "Puzzle Game",
            "description": "A puzzle-solving game with different mechanics and levels",
            "base_entities": ["player", "block", "switch", "door", "movable"],
            "base_levels": ["tutorial", "level1", "level2", "level3", "bonus"],
            "systems": ["physics", "interaction", "level_completion", "hints"],
            "ui_screens": ["main_menu", "level_select", "game", "pause", "victory"]
        }
    }
    
    # Entity templates
    entity_templates = {
        "player": {
            "components": ["movement", "health", "input", "animation"],
            "properties": {
                "speed": "float",
                "health": "float",
                "jump_force": "float"
            },
            "methods": ["move", "take_damage", "interact", "use_item"]
        },
        "enemy": {
            "components": ["movement", "health", "ai", "animation"],
            "properties": {
                "speed": "float",
                "health": "float",
                "damage": "float",
                "detection_range": "float"
            },
            "methods": ["patrol", "chase", "attack", "take_damage"]
        },
        "collectible": {
            "components": ["area", "animation"],
            "properties": {
                "value": "int",
                "effect": "string"
            },
            "methods": ["collect", "apply_effect", "spawn"]
        },
        "platform": {
            "components": ["collision", "optional_movement"],
            "properties": {
                "size": "Vector2",
                "movable": "bool",
                "movement_path": "Array",
                "speed": "float"
            },
            "methods": ["move", "toggle"]
        },
        "npc": {
            "components": ["interaction", "dialog", "animation"],
            "properties": {
                "name": "string",
                "dialog_tree": "Dictionary",
                "quest_giver": "bool"
            },
            "methods": ["talk", "give_quest", "trade", "move"]
        },
        "door": {
            "components": ["collision", "interaction"],
            "properties": {
                "locked": "bool",
                "key_id": "string",
                "destination": "string"
            },
            "methods": ["open", "close", "lock", "unlock"]
        }
    }
    
    # Level templates
    level_templates = {
        "platformer_level": {
            "components": ["tilemap", "entities", "triggers", "background"],
            "properties": {
                "width": "int",
                "height": "int",
                "difficulty": "int",
                "theme": "string"
            },
            "sections": ["start", "middle", "end", "secrets"],
            "obstacles": ["pits", "spikes", "moving_platforms", "enemies"]
        },
        "dungeon": {
            "components": ["tilemap", "entities", "triggers", "lighting"],
            "properties": {
                "width": "int",
                "height": "int",
                "difficulty": "int",
                "theme": "string"
            },
            "sections": ["entrance", "corridors", "rooms", "treasure", "boss"],
            "obstacles": ["traps", "locked_doors", "enemies", "puzzles"]
        },
        "arena": {
            "components": ["environment", "entities", "spawn_points", "objectives"],
            "properties": {
                "size": "Vector2",
                "max_enemies": "int",
                "difficulty": "int",
                "theme": "string"
            },
            "sections": ["center", "outer_ring", "spawn_points", "power_ups"],
            "obstacles": ["cover", "hazards", "traps"]
        }
    }
    
    # Gameplay systems
    gameplay_systems = {
        "physics": {
            "description": "Handles movement, collision, and physical interactions",
            "files": ["physics_controller.gd", "collision_handler.gd"],
            "dependencies": []
        },
        "health": {
            "description": "Manages health, damage, healing, and death",
            "files": ["health_system.gd", "damage_handler.gd"],
            "dependencies": []
        },
        "inventory": {
            "description": "Handles item collection, storage, and usage",
            "files": ["inventory_system.gd", "item_database.gd", "item.gd"],
            "dependencies": []
        },
        "quest": {
            "description": "Manages quests, objectives, and progress tracking",
            "files": ["quest_system.gd", "objective.gd", "quest_database.gd"],
            "dependencies": ["dialog"]
        },
        "combat": {
            "description": "Handles combat mechanics, attacks, and weapons",
            "files": ["combat_system.gd", "weapon.gd", "damage_calculator.gd"],
            "dependencies": ["health", "physics"]
        },
        "dialog": {
            "description": "Manages character dialog and conversation trees",
            "files": ["dialog_system.gd", "dialog_tree.gd", "npc_conversation.gd"],
            "dependencies": []
        },
        "enemy_ai": {
            "description": "Controls enemy behavior, pathfinding, and decisions",
            "files": ["ai_controller.gd", "pathfinding.gd", "behavior_tree.gd"],
            "dependencies": ["physics"]
        }
    }
    
    # UI templates
    ui_templates = {
        "main_menu": {
            "components": ["buttons", "background", "logo", "version"],
            "screens": ["main", "options", "credits"],
            "buttons": ["play", "options", "credits", "quit"]
        },
        "game_hud": {
            "components": ["health_bar", "score", "timer", "inventory"],
            "dynamic_elements": ["health", "ammo", "collectibles", "objectives"]
        },
        "pause": {
            "components": ["background", "buttons", "options"],
            "buttons": ["resume", "options", "quit_to_menu", "quit_game"]
        },
        "inventory": {
            "components": ["item_grid", "item_details", "categories", "stats"],
            "functionality": ["equip", "use", "drop", "sort", "filter"]
        },
        "dialog": {
            "components": ["text_box", "portrait", "name", "choices"],
            "functionality": ["next", "choose_option", "end_dialog"]
        }
    }

# Main game generation functions
func generate_game(template_id: String, config: Dictionary = {}) -> String:
    if not game_templates.has(template_id):
        emit_signal("generation_error", "Invalid game template: " + template_id)
        return ""
    
    # Create game ID
    var game_id = "game_" + str(randi())
    
    # Initialize generation
    current_generation = {
        "game_id": game_id,
        "template_id": template_id,
        "config": _merge_config(DEFAULT_CONFIG.duplicate(), config),
        "status": "generating",
        "start_time": Time.get_unix_time_from_system(),
        "progress": 0.0,
        "files": [],
        "entities": {},
        "levels": {},
        "systems": {},
        "ui_screens": {}
    }
    
    # Configure generation steps
    generation_steps = [
        {"name": "initialize_project", "message": "Creating project structure"},
        {"name": "generate_base_scripts", "message": "Generating base scripts"},
        {"name": "generate_entities", "message": "Creating entity classes"},
        {"name": "generate_levels", "message": "Designing game levels"},
        {"name": "generate_systems", "message": "Implementing gameplay systems"},
        {"name": "generate_ui", "message": "Creating user interface"},
        {"name": "generate_assets", "message": "Generating game assets"},
        {"name": "finalize_project", "message": "Finalizing project"}
    ]
    
    # Start generation thread
    generation_thread = Thread.new()
    generation_thread.start(_generation_process)
    
    # Store in generated games
    generated_games[game_id] = current_generation
    
    return game_id

func cancel_game_generation():
    if current_generation and current_generation.status == "generating":
        current_generation.status = "cancelled"
        
        if generation_thread and generation_thread.is_started():
            generation_thread.wait_to_finish()
        
        emit_signal("generation_error", "Game generation cancelled")

func get_game_generation_status(game_id: String) -> Dictionary:
    if generated_games.has(game_id):
        return {
            "game_id": game_id,
            "status": generated_games[game_id].status,
            "progress": generated_games[game_id].progress,
            "files_count": generated_games[game_id].files.size() if generated_games[game_id].has("files") else 0
        }
    else:
        return {"game_id": game_id, "status": "unknown", "progress": 0.0, "files_count": 0}

# Generation process and steps
func _generation_process():
    var total_steps = generation_steps.size()
    var current_step = 0
    
    for step in generation_steps:
        current_step += 1
        
        # Check if cancelled
        if current_generation.status == "cancelled":
            return
        
        # Update progress
        current_generation.progress = float(current_step - 1) / total_steps
        emit_signal("generation_progress", current_step, total_steps, step.message)
        
        # Execute step
        call("_" + step.name)
        
        # Small delay to prevent locking up the thread
        OS.delay_msec(50)
    
    # Mark as complete
    current_generation.status = "completed"
    current_generation.end_time = Time.get_unix_time_from_system()
    current_generation.progress = 1.0
    
    # Update stats
    creation_stats.games_created += 1
    
    emit_signal("generation_complete", current_generation)

func _initialize_project():
    var game_name = current_generation.config.project_name
    var template = game_templates[current_generation.template_id]
    
    # Create base structure folders
    for folder in SYSTEM_FOLDERS:
        _add_empty_directory("res://" + folder)
    
    # Create project files
    var project_config = _generate_project_config()
    _add_text_file("res://project.godot", project_config)
    
    # Create README
    var readme = _generate_readme()
    _add_text_file("res://README.md", readme)
    
    # Create base scenes
    _add_text_file("res://scenes/main.tscn", _generate_main_scene())
    
    # Create configuration
    var game_config = _generate_game_config()
    _add_text_file("res://config/game_settings.tres", game_config)

func _generate_base_scripts():
    # Generate autoload global scripts
    _add_text_file("res://scripts/globals.gd", _generate_globals_script())
    _add_text_file("res://scripts/event_bus.gd", _generate_event_bus_script())
    _add_text_file("res://scripts/game_manager.gd", _generate_game_manager_script())
    _add_text_file("res://scripts/resource_loader.gd", _generate_resource_loader_script())
    
    # Generate base utility scripts
    _add_text_file("res://scripts/utils/logger.gd", _generate_logger_script())
    _add_text_file("res://scripts/utils/math_utils.gd", _generate_math_utils_script())
    _add_text_file("res://scripts/utils/object_pool.gd", _generate_object_pool_script())

func _generate_entities():
    var template = game_templates[current_generation.template_id]
    
    # Generate entities based on game type
    for entity_name in template.base_entities:
        if entity_templates.has(entity_name):
            var entity_script = _generate_entity_script(entity_name)
            _add_text_file("res://scripts/entities/%s.gd" % entity_name, entity_script)
            
            var entity_scene = _generate_entity_scene(entity_name)
            _add_text_file("res://scenes/entities/%s.tscn" % entity_name, entity_scene)
            
            # Update entity tracking
            current_generation.entities[entity_name] = {
                "script_path": "res://scripts/entities/%s.gd" % entity_name,
                "scene_path": "res://scenes/entities/%s.tscn" % entity_name
            }
            
            # Update stats
            creation_stats.entities_created += 1
            emit_signal("asset_generated", "entity", entity_name)

func _generate_levels():
    var template = game_templates[current_generation.template_id]
    
    # Determine level template to use
    var level_template_key = "platformer_level"
    if current_generation.template_id == "top_down_rpg":
        level_template_key = "dungeon"
    elif current_generation.template_id == "fps":
        level_template_key = "arena"
    
    # Generate levels based on game type
    for level_name in template.base_levels:
        var level_script = _generate_level_script(level_name, level_template_key)
        _add_text_file("res://scripts/levels/%s.gd" % level_name, level_script)
        
        var level_scene = _generate_level_scene(level_name, level_template_key)
        _add_text_file("res://scenes/levels/%s.tscn" % level_name, level_scene)
        
        # Update level tracking
        current_generation.levels[level_name] = {
            "script_path": "res://scripts/levels/%s.gd" % level_name,
            "scene_path": "res://scenes/levels/%s.tscn" % level_name
        }
        
        # Update stats
        creation_stats.levels_created += 1
        emit_signal("asset_generated", "level", level_name)

func _generate_systems():
    var template = game_templates[current_generation.template_id]
    
    # Generate systems based on game type
    for system_name in template.systems:
        if gameplay_systems.has(system_name):
            var system_info = gameplay_systems[system_name]
            
            # Create each file for the system
            for file_name in system_info.files:
                var system_script = _generate_system_script(system_name, file_name)
                _add_text_file("res://scripts/systems/%s" % file_name, system_script)
            
            # Update system tracking
            current_generation.systems[system_name] = {
                "files": system_info.files.map(func(file): return "res://scripts/systems/" + file)
            }
            
            emit_signal("asset_generated", "system", system_name)

func _generate_ui():
    var template = game_templates[current_generation.template_id]
    
    # Generate UI screens based on game type
    for ui_name in template.ui_screens:
        if ui_templates.has(ui_name):
            var ui_script = _generate_ui_script(ui_name)
            _add_text_file("res://scripts/ui/%s.gd" % ui_name, ui_script)
            
            var ui_scene = _generate_ui_scene(ui_name)
            _add_text_file("res://scenes/ui/%s.tscn" % ui_name, ui_scene)
            
            # Update UI tracking
            current_generation.ui_screens[ui_name] = {
                "script_path": "res://scripts/ui/%s.gd" % ui_name,
                "scene_path": "res://scenes/ui/%s.tscn" % ui_name
            }
            
            emit_signal("asset_generated", "ui", ui_name)

func _generate_assets():
    # Generate basic assets like placeholders
    
    # Player placeholder
    _add_text_file("res://assets/player_placeholder.png", "")  # Would be actual image data
    
    # Enemy placeholder
    _add_text_file("res://assets/enemy_placeholder.png", "")  # Would be actual image data
    
    # Tileset placeholder
    _add_text_file("res://assets/tileset_placeholder.png", "")  # Would be actual image data
    
    # UI elements
    _add_text_file("res://assets/ui/button_normal.png", "")  # Would be actual image data
    _add_text_file("res://assets/ui/button_pressed.png", "")  # Would be actual image data
    _add_text_file("res://assets/ui/panel.png", "")  # Would be actual image data
    
    # Create a default theme
    _add_text_file("res://assets/ui/default_theme.tres", _generate_theme_resource())
    
    # Sound placeholders
    _add_text_file("res://sounds/background_music.ogg", "")  # Would be actual audio data
    _add_text_file("res://sounds/effects/jump.ogg", "")  # Would be actual audio data
    _add_text_file("res://sounds/effects/collect.ogg", "")  # Would be actual audio data
    
    # Update stats
    creation_stats.assets_created += 12

func _finalize_project():
    # Create a main.gd script that brings everything together
    _add_text_file("res://scripts/main.gd", _generate_main_script())
    
    # Create a default export preset configuration
    _add_text_file("res://export_presets.cfg", _generate_export_presets())
    
    # Create a basic .gitignore file
    _add_text_file("res://.gitignore", _generate_gitignore())
    
    # Create a license file
    _add_text_file("res://LICENSE", _generate_license())
    
    # Create an icon for the game
    _add_text_file("res://icon.png", "")  # Would be actual image data
    
    # Create a version.json for tracking game version
    _add_text_file("res://version.json", JSON.stringify({
        "version": current_generation.config.version,
        "build_date": Time.get_date_string_from_system(),
        "build_time": Time.get_time_string_from_system(),
        "generated_by": "Luminous OS Game Generator"
    }, "\t"))

# Helper functions
func _add_empty_directory(path: String):
    # In a real implementation, this would create the directory
    # For this simulation, we just track it
    current_generation.files.append({
        "path": path,
        "type": "directory",
        "created": Time.get_unix_time_from_system()
    })

func _add_text_file(path: String, content: String):
    # In a real implementation, this would write to a file
    # For this simulation, we just track it
    current_generation.files.append({
        "path": path,
        "type": "file",
        "created": Time.get_unix_time_from_system(),
        "size": content.length()
    })
    
    # Update stats
    creation_stats.lines_generated += content.split("\n").size()

func _merge_config(base_config: Dictionary, user_config: Dictionary) -> Dictionary:
    var result = base_config.duplicate()
    
    for key in user_config:
        result[key] = user_config[key]
    
    return result

# Template generation functions
func _generate_project_config() -> String:
    return """
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here have a specific format.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters

config_version=5

[application]

config/name="%s"
config/version="%s"
run/main_scene="res://scenes/main.tscn"
config/features=PackedStringArray("4.1")
config/icon="res://icon.png"

[autoload]

Globals="*res://scripts/globals.gd"
EventBus="*res://scripts/event_bus.gd"
GameManager="*res://scripts/game_manager.gd"
ResourceLoader="*res://scripts/resource_loader.gd"

[display]

window/size/viewport_width=%d
window/size/viewport_height=%d
window/stretch/mode="canvas_items"

[physics]

common/physics_ticks_per_second=%d

[rendering]

renderer/rendering_method="mobile"
""" % [
    current_generation.config.project_name,
    current_generation.config.version,
    current_generation.config.resolution.x,
    current_generation.config.resolution.y,
    current_generation.config.physics_fps
]

func _generate_readme() -> String:
    var template = game_templates[current_generation.template_id]
    
    return """# %s

%s

## About

This game was automatically generated by Luminous OS Game Generator based on the "%s" template.

## Features

- Game Type: %s
- Entities: %s
- Levels: %s
- Systems: %s
- UI Elements: %s

## Controls

- WASD / Arrow Keys: Movement
- Space: Jump/Action
- E: Interact
- Escape: Pause Menu

## License

See the LICENSE file for details.

## Credits

Created with Luminous OS Game Generator
%s
""" % [
    current_generation.config.project_name,
    template.description,
    template.name,
    template.name,
    ", ".join(template.base_entities),
    ", ".join(template.base_levels),
    ", ".join(template.systems),
    ", ".join(template.ui_screens),
    current_generation.config.creator
]

func _generate_main_scene() -> String:
    return """[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/main.gd" id="1_script"]

[node name="Main" type="Node"]
script = ExtResource("1_script")

[node name="SceneContainer" type="Node" parent="."]
"""

func _generate_game_config() -> String:
    return """[gd_resource type="Resource" script_class="GameSettings" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/resources/game_settings.gd" id="1_script"]

[resource]
script = ExtResource("1_script")
game_name = "%s"
version = "%s"
master_volume = 1.0
music_volume = 0.8
sfx_volume = 1.0
fullscreen = false
vsync_enabled = true
show_fps = false
difficulty = 1
"""  % [
    current_generation.config.project_name,
    current_generation.config.version
]

func _generate_globals_script() -> String:
    return """extends Node
# Global variables and constants accessible throughout the game

signal game_state_changed(new_state)

enum GameState {MAIN_MENU, PLAYING, PAUSED, GAME_OVER, VICTORY}

var current_game_state: GameState = GameState.MAIN_MENU
var player_data := {
    "health": 100,
    "score": 0,
    "lives": 3,
    "level": 1
}

var settings := {
    "master_volume": 1.0,
    "music_volume": 0.8,
    "sfx_volume": 1.0,
    "fullscreen": false,
    "vsync": true
}

var debug_mode := false

func _ready():
    pass

func change_game_state(new_state: GameState) -> void:
    var previous_state = current_game_state
    current_game_state = new_state
    emit_signal("game_state_changed", new_state)
    
    match new_state:
        GameState.MAIN_MENU:
            pass
        GameState.PLAYING:
            pass
        GameState.PAUSED:
            get_tree().paused = true
        GameState.GAME_OVER:
            pass
        GameState.VICTORY:
            pass
    
    if previous_state == GameState.PAUSED and new_state != GameState.PAUSED:
        get_tree().paused = false

func reset_player_data() -> void:
    player_data.health = 100
    player_data.score = 0
    player_data.lives = 3
    player_data.level = 1

func save_settings() -> void:
    var config = ConfigFile.new()
    config.set_value("settings", "master_volume", settings.master_volume)
    config.set_value("settings", "music_volume", settings.music_volume)
    config.set_value("settings", "sfx_volume", settings.sfx_volume)
    config.set_value("settings", "fullscreen", settings.fullscreen)
    config.set_value("settings", "vsync", settings.vsync)
    config.save("user://settings.cfg")

func load_settings() -> void:
    var config = ConfigFile.new()
    var error = config.load("user://settings.cfg")
    
    if error != OK:
        return
    
    settings.master_volume = config.get_value("settings", "master_volume", 1.0)
    settings.music_volume = config.get_value("settings", "music_volume", 0.8)
    settings.sfx_volume = config.get_value("settings", "sfx_volume", 1.0)
    settings.fullscreen = config.get_value("settings", "fullscreen", false)
    settings.vsync = config.get_value("settings", "vsync", true)
    
    _apply_settings()

func _apply_settings() -> void:
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(settings.master_volume))
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if settings.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if settings.vsync else DisplayServer.VSYNC_DISABLED)
"""

func _generate_event_bus_script() -> String:
    var template = game_templates[current_generation.template_id]
    var signals = []
    
    # Add base signals
    signals.append("signal level_started(level_name)")
    signals.append("signal level_completed(level_name)")
    signals.append("signal player_damaged(amount)")
    signals.append("signal player_healed(amount)")
    signals.append("signal player_died()")
    signals.append("signal game_paused()")
    signals.append("signal game_resumed()")
    
    # Add template-specific signals
    if current_generation.template_id == "2d_platformer":
        signals.append("signal collectible_collected(type, value)")
        signals.append("signal checkpoint_reached(position)")
    
    elif current_generation.template_id == "top_down_rpg":
        signals.append("signal quest_started(quest_id)")
        signals.append("signal quest_updated(quest_id, objective_id, progress)")
        signals.append("signal quest_completed(quest_id)")
        signals.append("signal dialog_started(npc_id)")
        signals.append("signal dialog_ended(npc_id)")
        signals.append("signal item_acquired(item_id, quantity)")
    
    elif current_generation.template_id == "fps":
        signals.append("signal weapon_equipped(weapon_id)")
        signals.append("signal weapon_fired(weapon_id)")
        signals.append("signal ammo_changed(weapon_id, current_ammo, max_ammo)")
        signals.append("signal enemy_killed(enemy_type, position)")
    
    elif current_generation.template_id == "puzzle":
        signals.append("signal puzzle_solved(puzzle_id)")
        signals.append("signal hint_used(hint_id)")
        signals.append("signal object_moved(object_id, old_position, new_position)")
    
    return """extends Node
# Event bus for decoupled communication between game components

# Core signals
%s

func _ready():
    pass
""" % signals.join("\n")

func _generate_game_manager_script() -> String:
    return """extends Node
# Manages game state, scene transitions, and core game flow

var current_scene = null
var scene_transition_active = false

func _ready():
    var root = get_tree().root
    current_scene = root.get_child(root.get_child_count() - 1)
    
    # Connect to global signals
    Globals.game_state_changed.connect(_on_game_state_changed)
    
    # Load saved settings
    Globals.load_settings()

func goto_scene(path: String, transition: bool = true) -> void:
    if scene_transition_active:
        return
    
    scene_transition_active = true
    
    if transition:
        # Transition animation would go here
        await get_tree().create_timer(0.5).timeout
    
    # Load new scene
    var loader = ResourceLoader.load_interactive(path)
    
    if loader == null:
        printerr("Error loading scene: " + path)
        scene_transition_active = false
        return
    
    while true:
        var err = loader.poll()
        
        if err == ERR_FILE_EOF:
            # Loading complete
            var resource = loader.get_resource()
            call_deferred("_set_new_scene", resource)
            break
        elif err != OK:
            printerr("Error during scene loading: " + str(err))
            scene_transition_active = false
            break
        
        # Update loading progress if needed
        var progress = float(loader.get_stage()) / loader.get_stage_count()
        # Display progress if desired
    
    if transition:
        # Exit transition animation would go here
        await get_tree().create_timer(0.5).timeout
    
    scene_transition_active = false

func _set_new_scene(scene_resource: PackedScene) -> void:
    # Remove current scene
    current_scene.queue_free()
    
    # Instance new scene
    current_scene = scene_resource.instantiate()
    
    # Add to root
    get_tree().root.add_child(current_scene)
    get_tree().current_scene = current_scene

func restart_current_level() -> void:
    var current_path = current_scene.scene_file_path
    goto_scene(current_path)

func start_new_game() -> void:
    Globals.reset_player_data()
    goto_scene("res://scenes/levels/tutorial.tscn")
    Globals.change_game_state(Globals.GameState.PLAYING)

func load_main_menu() -> void:
    goto_scene("res://scenes/ui/main_menu.tscn")
    Globals.change_game_state(Globals.GameState.MAIN_MENU)

func game_over() -> void:
    Globals.change_game_state(Globals.GameState.GAME_OVER)
    goto_scene("res://scenes/ui/game_over.tscn", true)

func victory() -> void:
    Globals.change_game_state(Globals.GameState.VICTORY)
    goto_scene("res://scenes/ui/victory.tscn", true)

func pause_game() -> void:
    if Globals.current_game_state == Globals.GameState.PLAYING:
        Globals.change_game_state(Globals.GameState.PAUSED)

func resume_game() -> void:
    if Globals.current_game_state == Globals.GameState.PAUSED:
        Globals.change_game_state(Globals.GameState.PLAYING)

func _on_game_state_changed(new_state) -> void:
    match new_state:
        Globals.GameState.MAIN_MENU:
            pass
        Globals.GameState.PLAYING:
            pass
        Globals.GameState.PAUSED:
            pass
        Globals.GameState.GAME_OVER:
            pass
        Globals.GameState.VICTORY:
            pass
"""

func _generate_resource_loader_script() -> String:
    return """extends Node
# Handles efficient resource loading, caching, and preloading

var _resource_cache := {}
var _loading_resources := {}

func _ready():
    pass

func load_resource(path: String):
    # Check if already cached
    if _resource_cache.has(path):
        return _resource_cache[path]
    
    # Load the resource
    var resource = load(path)
    
    if resource:
        _resource_cache[path] = resource
    
    return resource

func preload_resources(paths: Array) -> void:
    for path in paths:
        if not _resource_cache.has(path) and not _loading_resources.has(path):
            _start_loading_resource(path)

func _start_loading_resource(path: String) -> void:
    var loader = ResourceLoader.load_interactive(path)
    
    if loader:
        _loading_resources[path] = {
            "loader": loader,
            "progress": 0.0
        }

func _process(delta: float) -> void:
    if _loading_resources.size() > 0:
        var resources_to_remove = []
        
        for path in _loading_resources:
            var resource_data = _loading_resources[path]
            var loader = resource_data.loader
            
            var err = loader.poll()
            
            if err == ERR_FILE_EOF:
                # Loading complete
                var resource = loader.get_resource()
                _resource_cache[path] = resource
                resources_to_remove.append(path)
            elif err != OK:
                # Error occurred
                printerr("Error loading resource: " + path)
                resources_to_remove.append(path)
            else:
                # Update progress
                resource_data.progress = float(loader.get_stage()) / loader.get_stage_count()
        
        # Remove completed or failed resources
        for path in resources_to_remove:
            _loading_resources.erase(path)

func clear_cache() -> void:
    _resource_cache.clear()

func clear_resource(path: String) -> void:
    if _resource_cache.has(path):
        _resource_cache.erase(path)
"""

func _generate_logger_script() -> String:
    return """extends Node
class_name Logger

enum LogLevel {DEBUG, INFO, WARNING, ERROR, NONE}

static var current_level := LogLevel.INFO
static var enable_file_logging := false
static var log_file_path := "user://game.log"

static func set_log_level(level: LogLevel) -> void:
    current_level = level

static func enable_logging_to_file(enabled: bool) -> void:
    enable_file_logging = enabled
    
    if enabled:
        var file = FileAccess.open(log_file_path, FileAccess.WRITE)
        if file:
            file.store_string("Log started: " + Time.get_datetime_string_from_system() + "\\n")
            file.close()

static func debug(message: String, context: String = "") -> void:
    if current_level <= LogLevel.DEBUG:
        _log("DEBUG", message, context)

static func info(message: String, context: String = "") -> void:
    if current_level <= LogLevel.INFO:
        _log("INFO", message, context)

static func warning(message: String, context: String = "") -> void:
    if current_level <= LogLevel.WARNING:
        _log("WARNING", message, context)

static func error(message: String, context: String = "") -> void:
    if current_level <= LogLevel.ERROR:
        _log("ERROR", message, context)

static func _log(level: String, message: String, context: String) -> void:
    var timestamp = Time.get_time_string_from_system()
    var context_str = ""
    
    if context != "":
        context_str = " [" + context + "]"
    
    var log_message = timestamp + " " + level + context_str + ": " + message
    
    print(log_message)
    
    if enable_file_logging:
        var file = FileAccess.open(log_file_path, FileAccess.READ_WRITE)
        if file:
            file.seek_end()
            file.store_line(log_message)
            file.close()
"""

func _generate_math_utils_script() -> String:
    return """extends Node
class_name MathUtils

static func lerp_angle(from: float, to: float, weight: float) -> float:
    return from + _short_angle_dist(from, to) * weight

static func _short_angle_dist(from: float, to: float) -> float:
    var max_angle = 2.0 * PI
    var difference = fmod(to - from, max_angle)
    return fmod(2.0 * difference, max_angle) - difference

static func random_point_in_circle(radius: float) -> Vector2:
    var angle = randf() * 2.0 * PI
    var distance = sqrt(randf()) * radius
    return Vector2(cos(angle), sin(angle)) * distance

static func random_point_in_rectangle(size: Vector2) -> Vector2:
    return Vector2(randf() * size.x, randf() * size.y)

static func distance_squared(v1: Vector2, v2: Vector2) -> float:
    return (v1.x - v2.x) * (v1.x - v2.x) + (v1.y - v2.y) * (v1.y - v2.y)

static func is_point_in_rectangle(point: Vector2, rect_pos: Vector2, rect_size: Vector2) -> bool:
    return (point.x >= rect_pos.x and point.x <= rect_pos.x + rect_size.x and
            point.y >= rect_pos.y and point.y <= rect_pos.y + rect_size.y)

static func clamp_vector(vector: Vector2, min_length: float, max_length: float) -> Vector2:
    var length = vector.length()
    
    if length == 0:
        return vector
    
    var clamped_length = clamp(length, min_length, max_length)
    return vector * (clamped_length / length)

static func remap(value: float, input_from: float, input_to: float, output_from: float, output_to: float) -> float:
    return output_from + (output_to - output_from) * ((value - input_from) / (input_to - input_from))
"""

func _generate_object_pool_script() -> String:
    return """extends Node
class_name ObjectPool

var _scene: PackedScene
var _pool: Array = []
var _active_objects: Array = []
var _parent: Node
var _warm_size: int = 0

func _init(scene: PackedScene, parent: Node, warm_size: int = 10):
    _scene = scene
    _parent = parent
    _warm_size = warm_size
    
    # Warm up the pool
    for i in range(_warm_size):
        var obj = _create_instance()
        _pool.append(obj)

func get_instance() -> Node:
    var obj: Node
    
    if _pool.size() > 0:
        obj = _pool.pop_back()
    else:
        obj = _create_instance()
    
    _active_objects.append(obj)
    obj.visible = true
    
    return obj

func release_instance(obj: Node) -> void:
    if obj and _active_objects.has(obj):
        _active_objects.erase(obj)
        obj.visible = false
        
        # Reset object state
        if obj.has_method("reset"):
            obj.reset()
        
        _pool.append(obj)

func release_all() -> void:
    while _active_objects.size() > 0:
        var obj = _active_objects[0]
        release_instance(obj)

func _create_instance() -> Node:
    var instance = _scene.instantiate()
    _parent.add_child(instance)
    instance.visible = false
    return instance

func clear() -> void:
    # Release all active objects
    release_all()
    
    # Free all pooled objects
    for obj in _pool:
        if is_instance_valid(obj):
            obj.queue_free()
    
    _pool.clear()
"""

func _generate_entity_script(entity_name: String) -> String:
    var template_config = entity_templates[entity_name]
    var properties = []
    var methods = []
    
    # Generate properties
    for prop_name in template_config.properties:
        var prop_type = template_config.properties[prop_name]
        properties.append("@export var %s: %s" % [prop_name, prop_type])
    
    # Generate methods
    for method_name in template_config.methods:
        methods.append("""func %s() -> void:
    # TODO: Implement %s logic
    pass
""" % [method_name, method_name])
    
    # Determine base node type based on entity type
    var base_node = "CharacterBody2D"
    if current_generation.template_id == "fps":
        base_node = "CharacterBody3D"
    elif entity_name == "collectible" or entity_name == "trigger":
        base_node = "Area2D"
        if current_generation.template_id == "fps":
            base_node = "Area3D"
    
    return """extends %s
class_name %s

# Properties
%s

# Signals
signal %s_state_changed(new_state)

# State enum
enum State {IDLE, ACTIVE, DISABLED}
var current_state: State = State.IDLE

func _ready():
    # Initialize the entity
    pass

func _process(delta):
    # Handle entity logic
    match current_state:
        State.IDLE:
            _process_idle(delta)
        State.ACTIVE:
            _process_active(delta)
        State.DISABLED:
            pass

func _physics_process(delta):
    # Handle physics if needed
    if current_state == State.DISABLED:
        return
    
    # Physics logic here
    
func change_state(new_state: State) -> void:
    if new_state == current_state:
        return
    
    current_state = new_state
    emit_signal("%s_state_changed", new_state)

func _process_idle(delta: float) -> void:
    # Handle idle state logic
    pass

func _process_active(delta: float) -> void:
    # Handle active state logic
    pass

# Entity specific methods
%s
""" % [
    base_node,
    entity_name.capitalize(),
    properties.join("\n"),
    entity_name,
    entity_name,
    methods.join("\n")
]

func _generate_entity_scene(entity_name: String) -> String:
    # Simplified scene generation - in a real implementation this would be more complex
    var base_node = "CharacterBody2D"
    var collision_shape = "RectangleShape2D"
    
    if current_generation.template_id == "fps":
        base_node = "CharacterBody3D"
        collision_shape = "BoxShape3D"
    elif entity_name == "collectible" or entity_name == "trigger":
        base_node = "Area2D"
        collision_shape = "CircleShape2D"
        if current_generation.template_id == "fps":
            base_node = "Area3D"
            collision_shape = "SphereShape3D"
    
    return """[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/entities/%s.gd" id="1_script"]

[sub_resource type="%s" id="Shape_a1b2c"]

[node name="%s" type="%s"]
script = ExtResource("1_script")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("Shape_a1b2c")

[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("2_texture")
""" % [
    entity_name,
    collision_shape,
    entity_name.capitalize(),
    base_node
]

func _generate_level_script(level_name: String, template_key: String) -> String:
    var template_config = level_templates[template_key]
    var properties = []
    
    # Generate properties
    for prop_name in template_config.properties:
        var prop_type = template_config.properties[prop_name]
        var default_value = "0"
        
        if prop_type == "string":
            default_value = "\"\""
        elif prop_name == "width":
            default_value = "32"
        elif prop_name == "height":
            default_value = "18"
        elif prop_name == "difficulty":
            default_value = "1"
        
        properties.append("@export var %s: %s = %s" % [prop_name, prop_type, default_value])
    
    # Determine base node type
    var base_node = "Node2D"
    if current_generation.template_id == "fps":
        base_node = "Node3D"
    
    return """extends %s
class_name Level

# Level properties
%s

# Signals
signal level_started
signal level_completed
signal checkpoint_reached(position)

# Level state
var player: Node
var enemies: Array = []
var collectibles: Array = []
var level_loaded: bool = false
var level_completed: bool = false

func _ready():
    # Setup level
    setup_level()
    
    # Connect to necessary signals
    EventBus.connect("player_died", _on_player_died)
    
    # Emit level started signal
    emit_signal("level_started")
    EventBus.emit_signal("level_started", "%s")

func _process(delta):
    # Level logic here
    if level_completed:
        return
    
    # Check for level completion
    check_level_completion()

func setup_level():
    # Generate level layout
    generate_layout()
    
    # Spawn entities
    spawn_entities()
    
    # Mark level as loaded
    level_loaded = true

func generate_layout():
    # Generate the level layout based on width, height, difficulty, etc.
    # This would create the terrain, obstacles, etc.
    pass

func spawn_entities():
    # Spawn player, enemies, collectibles, etc.
    
    # Find player node
    player = get_node_or_null("Player")
    if not player:
        player = load("res://scenes/entities/player.tscn").instantiate()
        add_child(player)
    
    # Spawn enemies based on difficulty
    var enemy_count = difficulty * 2
    for i in range(enemy_count):
        var enemy = load("res://scenes/entities/enemy.tscn").instantiate()
        # Position the enemy
        add_child(enemy)
        enemies.append(enemy)
    
    # Spawn collectibles
    var collectible_count = 10
    for i in range(collectible_count):
        var collectible = load("res://scenes/entities/collectible.tscn").instantiate()
        # Position the collectible
        add_child(collectible)
        collectibles.append(collectible)

func check_level_completion():
    # Check if the level has been completed
    # This could be based on reaching the exit, collecting all collectibles, etc.
    
    # Example: All collectibles collected
    var all_collected = true
    for collectible in collectibles:
        if is_instance_valid(collectible) and collectible.visible:
            all_collected = false
            break
    
    if all_collected and !level_completed:
        complete_level()

func complete_level():
    level_completed = true
    emit_signal("level_completed")
    EventBus.emit_signal("level_completed", "%s")
    
    # Show level complete UI or transition to next level
    var timer = get_tree().create_timer(2.0)
    await timer.timeout
    
    # Go to next level or back to menu
    if "%s" == "boss":
        GameManager.victory()
    else:
        var next_level = "res://scenes/levels/%s.tscn"
        GameManager.goto_scene(next_level)

func _on_player_died():
    # Handle player death
    var timer = get_tree().create_timer(2.0)
    await timer.timeout
    
    if Globals.player_data.lives > 0:
        Globals.player_data.lives -= 1
        GameManager.restart_current_level()
    else:
        GameManager.game_over()
""" % [
    base_node,
    properties.join("\n"),
    level_name,
    level_name,
    level_name,
    _get_next_level_name(level_name)
]

func _generate_level_scene(level_name: String, template_key: String) -> String:
    # Simplified scene generation - in a real implementation this would be more complex
    var base_node = "Node2D"
    
    if current_generation.template_id == "fps":
        base_node = "Node3D"
    
    return """[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/levels/%s.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/entities/player.tscn" id="2_player"]

[node name="Level" type="%s"]
script = ExtResource("1_script")

[node name="Player" parent="." instance=ExtResource("2_player")]
position = Vector2(100, 100)

[node name="TileMap" type="TileMap" parent="."]
format = 2
layer_0/name = "ground"
layer_1/name = "walls"
layer_1/enabled = true
layer_1/modulate = Color(1, 1, 1, 1)
layer_1/y_sort_enabled = false
layer_1/tile_data = PackedInt32Array()

[node name="Collectibles" type="Node2D" parent="."]

[node name="Enemies" type="Node2D" parent="."]

[node name="Triggers" type="Node2D" parent="."]

[node name="LevelComplete" type="Area2D" parent="Triggers"]
position = Vector2(900, 300)

[node name="CollisionShape2D" type="CollisionShape2D" parent="Triggers/LevelComplete"]

[node name="Camera2D" type="Camera2D" parent="."]
""" % [
    level_name,
    base_node
]

func _get_next_level_name(current_level: String) -> String:
    var template = game_templates[current_generation.template_id]
    var levels = template.base_levels
    
    var current_index = levels.find(current_level)
    if current_index == -1 or current_index >= levels.size() - 1:
        return "tutorial"  # Loop back to tutorial
    
    return levels[current_index + 1]

func _generate_system_script(system_name: String, file_name: String) -> String:
    var system_info = gameplay_systems[system_name]
    
    # Generate a basic script based on system type
    var script_content = """extends Node
class_name %s

# System properties

# Signals

func _ready():
    # Initialize system
    pass

func _process(delta):
    # System logic
    pass

# System methods
""" % _get_class_name_from_file(file_name)
    
    # Add system-specific content
    if system_name == "physics":
        script_content += """
func apply_force(body: RigidBody2D, force: Vector2) -> void:
    body.apply_force(force)

func apply_impulse(body: RigidBody2D, impulse: Vector2, position: Vector2 = Vector2.ZERO) -> void:
    body.apply_impulse(impulse, position)
"""
    elif system_name == "health":
        script_content += """
func apply_damage(entity: Node, amount: float) -> void:
    if entity.has_method("take_damage"):
        entity.take_damage(amount)

func heal(entity: Node, amount: float) -> void:
    if entity.has_method("heal"):
        entity.heal(amount)

func is_alive(entity: Node) -> bool:
    if entity.has_method("is_alive"):
        return entity.is_alive()
    return true
"""
    elif system_name == "inventory":
        script_content += """
var items = {}
signal item_added(item_id, quantity)
signal item_removed(item_id, quantity)

func add_item(item_id: String, quantity: int = 1) -> bool:
    if not items.has(item_id):
        items[item_id] = 0
    
    items[item_id] += quantity
    emit_signal("item_added", item_id, quantity)
    EventBus.emit_signal("item_acquired", item_id, quantity)
    return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
    if not items.has(item_id) or items[item_id] < quantity:
        return false
    
    items[item_id] -= quantity
    
    if items[item_id] <= 0:
        items.erase(item_id)
    
    emit_signal("item_removed", item_id, quantity)
    return true

func get_item_quantity(item_id: String) -> int:
    return items.get(item_id, 0)
"""
    
    return script_content

func _get_class_name_from_file(file_name: String) -> String:
    var name_parts = file_name.get_basename().split("_")
    var class_name = ""
    
    for part in name_parts:
        class_name += part.capitalize()
    
    return class_name

func _generate_ui_script(ui_name: String) -> String:
    var ui_info = ui_templates[ui_name]
    
    # Generate script based on UI type
    var base_node = "Control"
    var script_content = ""
    
    if ui_name == "main_menu":
        script_content = """extends Control

func _ready():
    # Set up button connections
    $ButtonContainer/PlayButton.pressed.connect(_on_play_button_pressed)
    $ButtonContainer/OptionsButton.pressed.connect(_on_options_button_pressed)
    $ButtonContainer/CreditsButton.pressed.connect(_on_credits_button_pressed)
    $ButtonContainer/QuitButton.pressed.connect(_on_quit_button_pressed)
    
    # Show version number
    $VersionLabel.text = "v" + Globals.get_version()

func _on_play_button_pressed():
    GameManager.start_new_game()

func _on_options_button_pressed():
    # Show options panel
    $OptionsPanel.visible = true

func _on_credits_button_pressed():
    # Show credits panel
    $CreditsPanel.visible = true

func _on_quit_button_pressed():
    get_tree().quit()

func _on_back_button_pressed():
    # Hide all panels
    $OptionsPanel.visible = false
    $CreditsPanel.visible = false
"""
    elif ui_name == "game_hud":
        script_content = """extends Control

func _ready():
    # Connect to relevant signals
    EventBus.player_damaged.connect(_update_health)
    EventBus.player_healed.connect(_update_health)
    EventBus.collectible_collected.connect(_update_score)
    
    # Initial update
    _update_health(0)
    _update_score("", 0)

func _process(delta):
    # Update timer if needed
    $TimerLabel.text = "Time: " + str(int(get_tree().get_root().get_node("Main").get_game_time()))

func _update_health(amount):
    var health_percent = float(Globals.player_data.health) / 100.0
    $HealthBar.value = health_percent
    $HealthLabel.text = "Health: " + str(Globals.player_data.health)

func _update_score(type, value):
    $ScoreLabel.text = "Score: " + str(Globals.player_data.score)
"""
    elif ui_name == "pause":
        script_content = """extends Control

func _ready():
    visible = false
    
    # Connect buttons
    $ButtonContainer/ResumeButton.pressed.connect(_on_resume_button_pressed)
    $ButtonContainer/OptionsButton.pressed.connect(_on_options_button_pressed)
    $ButtonContainer/QuitToMenuButton.pressed.connect(_on_quit_to_menu_button_pressed)
    
    # Connect to game state changes
    Globals.game_state_changed.connect(_on_game_state_changed)

func _input(event):
    if event.is_action_pressed("ui_cancel"):
        if Globals.current_game_state == Globals.GameState.PLAYING:
            GameManager.pause_game()
        elif Globals.current_game_state == Globals.GameState.PAUSED:
            GameManager.resume_game()

func _on_game_state_changed(new_state):
    visible = (new_state == Globals.GameState.PAUSED)

func _on_resume_button_pressed():
    GameManager.resume_game()

func _on_options_button_pressed():
    $OptionsPanel.visible = true

func _on_quit_to_menu_button_pressed():
    GameManager.resume_game()  # Unpause before changing scene
    GameManager.load_main_menu()
"""
    else:
        script_content = """extends Control

func _ready():
    # Connect UI elements
    pass

func _process(delta):
    # UI logic
    pass
"""
    
    return script_content

func _generate_ui_scene(ui_name: String) -> String:
    # Simplified scene generation - in a real implementation this would be more complex
    var scene_content = """[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/ui/%s.gd" id="1_script"]
[ext_resource type="Theme" path="res://assets/ui/default_theme.tres" id="2_theme"]

[node name="%s" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
theme = ExtResource("2_theme")
script = ExtResource("1_script")

[node name="Background" type="Panel" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
""" % [ui_name, ui_name.capitalize()]
    
    # Add UI-specific elements
    if ui_name == "main_menu":
        scene_content += """
[node name="TitleLabel" type="Label" parent="."]
layout_mode = 1
anchors_preset = 5
anchor_left = 0.5
anchor_right = 0.5
offset_left = -200.0
offset_top = 100.0
offset_right = 200.0
offset_bottom = 150.0
grow_horizontal = 2
theme_override_font_sizes/font_size = 36
text = "%s"
horizontal_alignment = 1

[node name="ButtonContainer" type="VBoxContainer" parent="."]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -100.0
offset_top = -80.0
offset_right = 100.0
offset_bottom = 80.0
grow_horizontal = 2
grow_vertical = 2
theme_override_constants/separation = 20

[node name="PlayButton" type="Button" parent="ButtonContainer"]
layout_mode = 2
text = "Play"

[node name="OptionsButton" type="Button" parent="ButtonContainer"]
layout_mode = 2
text = "Options"

[node name="CreditsButton" type="Button" parent="ButtonContainer"]
layout_mode = 2
text = "Credits"

[node name="QuitButton" type="Button" parent="ButtonContainer"]
layout_mode = 2
text = "Quit"

[node name="VersionLabel" type="Label" parent="."]
layout_mode = 1
anchors_preset = 3
anchor_left = 1.0
anchor_top = 1.0
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = -100.0
offset_top = -30.0
offset_right = -10.0
offset_bottom = -10.0
grow_horizontal = 0
grow_vertical = 0
text = "v%s"
horizontal_alignment = 2
""" % [current_generation.config.project_name, current_generation.config.version]
    elif ui_name == "game_hud":
        scene_content += """
[node name="HealthBar" type="ProgressBar" parent="."]
layout_mode = 1
anchors_preset = 1
anchor_left = 1.0
anchor_right = 1.0
offset_left = -210.0
offset_top = 10.0
offset_right = -10.0
offset_bottom = 40.0
grow_horizontal = 0
value = 100.0

[node name="HealthLabel" type="Label" parent="."]
layout_mode = 0
offset_left = 10.0
offset_top = 10.0
offset_right = 150.0
offset_bottom = 40.0
text = "Health: 100"
vertical_alignment = 1

[node name="ScoreLabel" type="Label" parent="."]
layout_mode = 0
offset_left = 10.0
offset_top = 40.0
offset_right = 150.0
offset_bottom = 70.0
text = "Score: 0"
vertical_alignment = 1

[node name="TimerLabel" type="Label" parent="."]
layout_mode = 1
anchors_preset = 5
anchor_left = 0.5
anchor_right = 0.5
offset_left = -50.0
offset_top = 10.0
offset_right = 50.0
offset_bottom = 40.0
grow_horizontal = 2
text = "Time: 0"
horizontal_alignment = 1
vertical_alignment = 1
"""
    
    return scene_content

func _generate_main_script() -> String:
    return """extends Node
# Main script that coordinates the game initialization and core loop

var game_time: float = 0.0

func _ready():
    # Initialize the game
    initialize_game()
    
    # Start with the main menu
    if get_tree().current_scene == self:
        GameManager.load_main_menu()

func _process(delta):
    # Update game time
    if Globals.current_game_state == Globals.GameState.PLAYING:
        game_time += delta

func initialize_game():
    # Set up any global systems
    
    # Preload common resources
    var common_resources = [
        "res://scenes/entities/player.tscn",
        "res://scenes/entities/enemy.tscn",
        "res://scenes/ui/game_hud.tscn",
        "res://scenes/ui/pause.tscn"
    ]
    ResourceLoader.preload_resources(common_resources)
    
    # Connect to signals
    var pause_menu = $PauseMenu
    if pause_menu:
        # Ensure pause menu is initially hidden
        pause_menu.visible = false
    
    var game_hud = $GameHUD
    if game_hud:
        # Ensure HUD is visible if we're in a gameplay scene
        game_hud.visible = Globals.current_game_state == Globals.GameState.PLAYING

func get_game_time() -> float:
    return game_time

func reset_game_time() -> void:
    game_time = 0.0

func debug_print(message: String) -> void:
    if Globals.debug_mode:
        print("DEBUG: " + message)
"""

func _generate_theme_resource() -> String:
    return """[gd_resource type="Theme" load_steps=2 format=3]

[ext_resource type="FontFile" uid="uid://..." path="res://assets/fonts/default_font.ttf" id="1_font"]

[resource]
default_font = ExtResource("1_font")
Button/colors/font_color = Color(0.88, 0.88, 0.88, 1)
Button/colors/font_hover_color = Color(0.94, 0.94, 0.94, 1)
Button/colors/font_pressed_color = Color(0.7, 0.7, 0.7, 1)
Button/constants/h_separation = 4
Button/constants/outline_size = 0
Button/font_sizes/font_size = 16
Label/colors/font_color = Color(0.9, 0.9, 0.9, 1)
Label/colors/font_outline_color = Color(0, 0, 0, 1)
Label/constants/shadow_offset_x = 1
Label/constants/shadow_offset_y = 1
Label/font_sizes/font_size = 16
"""

func _generate_export_presets() -> String:
    return """[preset.0]

name="Web"
platform="Web"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="exports/web/index.html"

[preset.1]

name="Windows Desktop"
platform="Windows Desktop"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="exports/windows/%s.exe"

[preset.2]

name="macOS"
platform="macOS"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="exports/macos/%s.zip"

[preset.3]

name="Linux/X11"
platform="Linux/X11"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="exports/linux/%s.x86_64"
""" % [
    current_generation.config.project_name.replace(" ", "_").to_lower(),
    current_generation.config.project_name.replace(" ", "_").to_lower(),
    current_generation.config.project_name.replace(" ", "_").to_lower()
]

func _generate_gitignore() -> String:
    return """# Godot-specific ignores
.godot/
.import/
export.cfg
export_presets.cfg

# Imported translations (automatically generated from CSV files)
*.translation

# Mono-specific ignores
.mono/
data_*/

# System-specific ignores
.DS_Store
Thumbs.db

# Export directory
exports/

# Log files
*.log
"""

func _generate_license() -> String:
    return """MIT License

Copyright (c) %s %s

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
""" % [
    Time.get_date_dict_from_system().year,
    current_generation.config.creator
]