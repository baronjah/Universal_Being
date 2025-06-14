extends Node
class_name LuminousAutoGameFactory

# Signals
signal project_creation_started(project_id, project_name)
signal project_creation_progress(project_id, progress, message)
signal project_creation_completed(project_id, path)
signal project_creation_failed(project_id, error_message)
signal asset_generated(project_id, asset_type, asset_path)
signal code_generated(project_id, file_type, file_path)

# Data analysis signals
signal pattern_analysis_completed(project_id, patterns)
signal data_processing_progress(project_id, progress, total_bytes)
signal script_patterns_identified(script_patterns)

# AI Integration
var gemini_integration: LuminousGeminiIntegration
var neural_processor: LuminousNeuralProcessor
var data_controller: LuminousDataController

# Project tracking
var active_projects: Dictionary = {}
var completed_projects: Dictionary = {}
var project_templates: Dictionary = {}
var generation_history: Array = []

# Data processing
var pattern_repository: Dictionary = {}
var user_style_patterns: Dictionary = {}
var code_examples: Dictionary = {}
var asset_templates: Dictionary = {}

# File system
var project_root_path: String = "user://luminous_projects/"
var template_path: String = "res://assets/templates/"
var data_path: String = "user://luminous_data/"
var max_disk_usage: int = 1024 * 1024 * 1024 * 50  # 50GB limit

# Multithreading
var generation_thread: Thread
var analysis_thread: Thread
var thread_mutex: Mutex
var generation_semaphore: Semaphore
var analysis_semaphore: Semaphore
var should_exit: bool = false

# Configuration
var max_parallel_projects: int = 3
var auto_backup: bool = true
var backup_interval: int = 600  # 10 minutes
var max_token_usage_per_project: int = 100000
var save_iterations: bool = true
var use_gpu_acceleration: bool = true

# Automation constants
const AUTO_SAVE_INTERVAL = 60  # 1 minute
const DEFAULT_PROJECT_SETTINGS = {
    "name": "LuminousGame",
    "version": "1.0.0",
    "game_type": "2d",
    "template": "basic",
    "target_platform": "all",
    "orientation": "landscape",
    "audio": true,
    "physics": true,
    "networking": false,
    "ai": false,
    "vr": false
}

# File templates
const TEMPLATE_EXTENSIONS = {
    "script": ".gd",
    "scene": ".tscn",
    "resource": ".tres",
    "shader": ".gdshader",
    "project": ".godot",
    "import": ".import",
    "text": ".txt",
    "json": ".json",
    "config": ".cfg"
}

# Project structure
const DEFAULT_FOLDERS = [
    "scripts",
    "scenes",
    "assets",
    "assets/textures",
    "assets/audio",
    "assets/models",
    "assets/fonts",
    "assets/shaders",
    "resources",
    "addons",
    "config",
    "docs"
]

func _init():
    thread_mutex = Mutex.new()
    generation_semaphore = Semaphore.new()
    analysis_semaphore = Semaphore.new()
    
    # Ensure project directories exist
    var dir = DirAccess.open("user://")
    if not dir.dir_exists("luminous_projects"):
        dir.make_dir("luminous_projects")
    
    if not dir.dir_exists("luminous_data"):
        dir.make_dir("luminous_data")
    
    _load_project_templates()

func _ready():
    # Start threads
    generation_thread = Thread.new()
    generation_thread.start(_generation_thread_function)
    
    analysis_thread = Thread.new()
    analysis_thread.start(_analysis_thread_function)
    
    # Connect to integrated systems
    gemini_integration = $"../LuminousGeminiIntegration"
    neural_processor = $"../LuminousNeuralProcessor"
    data_controller = $"../LuminousDataController"

func _exit_tree():
    # Set exit flag
    thread_mutex.lock()
    should_exit = true
    thread_mutex.unlock()
    
    # Signal threads to exit
    generation_semaphore.post()
    analysis_semaphore.post()
    
    # Wait for threads to finish
    if generation_thread and generation_thread.is_started():
        generation_thread.wait_to_finish()
    
    if analysis_thread and analysis_thread.is_started():
        analysis_thread.wait_to_finish()

# Project Generation API
func create_game_project(project_name: String, settings: Dictionary = {}) -> String:
    # Generate project ID
    var project_id = "proj_" + str(randi()).pad_zeros(8)
    
    # Merge with default settings
    var project_settings = DEFAULT_PROJECT_SETTINGS.duplicate()
    for key in settings:
        project_settings[key] = settings[key]
    
    project_settings.name = project_name
    
    # Initialize project tracking
    thread_mutex.lock()
    active_projects[project_id] = {
        "id": project_id,
        "name": project_name,
        "settings": project_settings,
        "status": "initializing",
        "progress": 0.0,
        "start_time": Time.get_unix_time_from_system(),
        "files_generated": 0,
        "assets_generated": 0,
        "token_usage": 0,
        "errors": [],
        "path": project_root_path.path_join(project_name.replace(" ", "_").to_lower())
    }
    thread_mutex.unlock()
    
    # Signal project started
    call_deferred("emit_signal", "project_creation_started", project_id, project_name)
    
    # Queue project for generation
    _queue_project_generation(project_id)
    
    return project_id

func generate_project_from_data(project_name: String, data_sources: Array, settings: Dictionary = {}) -> String:
    # First analyze data
    var analysis_id = analyze_user_data(data_sources)
    
    # Then create project with analyzed data
    var project_id = create_game_project(project_name, settings)
    
    # Link analysis to project
    thread_mutex.lock()
    if active_projects.has(project_id):
        active_projects[project_id].analysis_id = analysis_id
    thread_mutex.unlock()
    
    return project_id

func generate_from_template(template_name: String, project_name: String, customizations: Dictionary = {}) -> String:
    if not project_templates.has(template_name):
        return ""
    
    var settings = {
        "template": template_name,
        "customizations": customizations
    }
    
    return create_game_project(project_name, settings)

func get_project_status(project_id: String) -> Dictionary:
    thread_mutex.lock()
    var status = {}
    
    if active_projects.has(project_id):
        status = {
            "id": project_id,
            "name": active_projects[project_id].name,
            "status": active_projects[project_id].status,
            "progress": active_projects[project_id].progress,
            "files_generated": active_projects[project_id].files_generated,
            "assets_generated": active_projects[project_id].assets_generated,
            "elapsed_time": Time.get_unix_time_from_system() - active_projects[project_id].start_time
        }
    elif completed_projects.has(project_id):
        status = {
            "id": project_id,
            "name": completed_projects[project_id].name,
            "status": "completed",
            "files_generated": completed_projects[project_id].files_generated,
            "assets_generated": completed_projects[project_id].assets_generated,
            "path": completed_projects[project_id].path,
            "completion_time": completed_projects[project_id].completion_time
        }
    else:
        status = {
            "id": project_id,
            "status": "unknown"
        }
    
    thread_mutex.unlock()
    return status

func cancel_project_generation(project_id: String) -> bool:
    thread_mutex.lock()
    var result = false
    
    if active_projects.has(project_id):
        active_projects[project_id].status = "cancelled"
        result = true
    
    thread_mutex.unlock()
    return result

# Data Analysis API
func analyze_user_data(data_sources: Array) -> String:
    var analysis_id = "analysis_" + str(randi()).pad_zeros(8)
    
    thread_mutex.lock()
    var analysis_data = {
        "id": analysis_id,
        "sources": data_sources,
        "status": "pending",
        "progress": 0.0,
        "results": {},
        "start_time": Time.get_unix_time_from_system()
    }
    pattern_repository[analysis_id] = analysis_data
    thread_mutex.unlock()
    
    # Queue analysis
    analysis_semaphore.post()
    
    return analysis_id

func get_analysis_status(analysis_id: String) -> Dictionary:
    thread_mutex.lock()
    var status = {}
    
    if pattern_repository.has(analysis_id):
        var analysis = pattern_repository[analysis_id]
        status = {
            "id": analysis_id,
            "status": analysis.status,
            "progress": analysis.progress
        }
        
        if analysis.status == "completed":
            status.results = analysis.results
    else:
        status = {
            "id": analysis_id,
            "status": "unknown"
        }
    
    thread_mutex.unlock()
    return status

func scan_user_code_style(code_path: String) -> Dictionary:
    var style_patterns = {}
    
    # Check if directory exists
    var dir = DirAccess.open(code_path)
    if not dir:
        return style_patterns
    
    # Track script files to analyze
    var script_files = []
    _find_script_files(dir, code_path, script_files)
    
    # Analyze each script file
    for file_path in script_files:
        var file = FileAccess.open(file_path, FileAccess.READ)
        if file:
            var content = file.get_as_text()
            _analyze_code_style(content, style_patterns)
    
    return style_patterns

# Game Template Management
func get_available_templates() -> Array:
    var templates = []
    
    for template_name in project_templates:
        templates.append({
            "name": template_name,
            "description": project_templates[template_name].description,
            "type": project_templates[template_name].type,
            "complexity": project_templates[template_name].complexity
        })
    
    return templates

func create_template_from_project(project_path: String, template_name: String, description: String) -> bool:
    # Verify project exists
    var dir = DirAccess.open(project_path)
    if not dir:
        return false
    
    # Create template data
    var template = {
        "name": template_name,
        "description": description,
        "type": "custom",
        "complexity": "medium",
        "created_at": Time.get_unix_time_from_system(),
        "structure": {},
        "files": {}
    }
    
    # Scan project structure
    _scan_project_structure(project_path, template)
    
    # Save template
    project_templates[template_name] = template
    _save_project_templates()
    
    return true

# Private Implementation
func _queue_project_generation(project_id: String) -> void:
    generation_semaphore.post()

func _generation_thread_function() -> void:
    while true:
        generation_semaphore.wait()
        
        thread_mutex.lock()
        var should_stop = should_exit
        thread_mutex.unlock()
        
        if should_stop:
            break
        
        # Get next project to generate
        var next_project_id = ""
        thread_mutex.lock()
        for project_id in active_projects:
            if active_projects[project_id].status == "initializing":
                next_project_id = project_id
                active_projects[project_id].status = "generating"
                break
        thread_mutex.unlock()
        
        if next_project_id != "":
            _generate_project(next_project_id)

func _analysis_thread_function() -> void:
    while true:
        analysis_semaphore.wait()
        
        thread_mutex.lock()
        var should_stop = should_exit
        thread_mutex.unlock()
        
        if should_stop:
            break
        
        # Get next analysis to perform
        var next_analysis_id = ""
        thread_mutex.lock()
        for analysis_id in pattern_repository:
            if pattern_repository[analysis_id].status == "pending":
                next_analysis_id = analysis_id
                pattern_repository[analysis_id].status = "analyzing"
                break
        thread_mutex.unlock()
        
        if next_analysis_id != "":
            _analyze_data(next_analysis_id)

func _generate_project(project_id: String) -> void:
    thread_mutex.lock()
    var project = active_projects[project_id]
    thread_mutex.unlock()
    
    # Create project directory
    var dir = DirAccess.open("user://")
    var project_dir_name = project.name.replace(" ", "_").to_lower()
    var project_path = project_root_path.path_join(project_dir_name)
    
    if not dir.dir_exists(project_path):
        dir.make_dir_recursive(project_path)
    
    # Update status
    _update_project_progress(project_id, 0.05, "Created project directory")
    
    # Create folder structure
    _create_project_structure(project_id, project_path)
    
    # Generate project.godot
    _generate_project_config(project_id, project_path)
    
    # Generate base scripts
    _generate_base_scripts(project_id, project_path)
    
    # Generate scenes
    _generate_scenes(project_id, project_path)
    
    # Generate resources
    _generate_resources(project_id, project_path)
    
    # Generate assets (placeholder)
    _generate_assets(project_id, project_path)
    
    # Generate documentation
    _generate_documentation(project_id, project_path)
    
    # Mark project as completed
    _complete_project(project_id)

func _analyze_data(analysis_id: String) -> void:
    thread_mutex.lock()
    var analysis = pattern_repository[analysis_id]
    thread_mutex.unlock()
    
    var data_sources = analysis.sources
    var results = {}
    
    # Update status
    _update_analysis_progress(analysis_id, 0.1, "Starting data analysis")
    
    # Analyze each data source
    var source_count = data_sources.size()
    for i in range(source_count):
        var source = data_sources[i]
        var source_results = _analyze_single_data_source(source)
        
        for key in source_results:
            if not results.has(key):
                results[key] = []
            
            results[key].append_array(source_results[key])
        
        # Update progress
        var progress = 0.1 + (0.8 * float(i + 1) / source_count)
        _update_analysis_progress(analysis_id, progress, "Analyzed source " + str(i + 1) + "/" + str(source_count))
    
    # Finalize analysis
    thread_mutex.lock()
    pattern_repository[analysis_id].status = "completed"
    pattern_repository[analysis_id].progress = 1.0
    pattern_repository[analysis_id].results = results
    pattern_repository[analysis_id].completion_time = Time.get_unix_time_from_system()
    thread_mutex.unlock()
    
    # Emit signal
    call_deferred("emit_signal", "pattern_analysis_completed", analysis_id, results)

func _create_project_structure(project_id: String, project_path: String) -> void:
    # Create default folders
    var dir = DirAccess.open(project_path)
    if not dir:
        _log_project_error(project_id, "Failed to access project directory")
        return
    
    for folder in DEFAULT_FOLDERS:
        dir.make_dir_recursive(folder)
    
    # Update progress
    _update_project_progress(project_id, 0.1, "Created folder structure")

func _generate_project_config(project_id: String, project_path: String) -> void:
    thread_mutex.lock()
    var project = active_projects[project_id]
    thread_mutex.unlock()
    
    # Generate project.godot content
    var content = """
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here have a specific format.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters

config_version=5

[application]

config/name="{name}"
config/version="{version}"
run/main_scene="res://scenes/main.tscn"
config/features=PackedStringArray("4.1")
config/icon="res://assets/textures/icon.png"

[autoload]

GameController="*res://scripts/game_controller.gd"
ResourceManager="*res://scripts/resource_manager.gd"
""".format({
        "name": project.name,
        "version": project.settings.version
    })
    
    # Write to file
    var file = FileAccess.open(project_path.path_join("project.godot"), FileAccess.WRITE)
    if file:
        file.store_string(content)
    else:
        _log_project_error(project_id, "Failed to write project.godot")
    
    # Update project progress
    _update_project_progress(project_id, 0.15, "Generated project configuration")

func _generate_base_scripts(project_id: String, project_path: String) -> void:
    # Access project settings
    thread_mutex.lock()
    var project = active_projects[project_id]
    thread_mutex.unlock()
    
    # Define scripts to generate
    var scripts = {
        "game_controller.gd": _generate_game_controller_script(project),
        "resource_manager.gd": _generate_resource_manager_script(project),
        "player.gd": _generate_player_script(project),
        "input_handler.gd": _generate_input_handler_script(project),
        "ui_manager.gd": _generate_ui_manager_script(project)
    }
    
    # Generate each script
    var script_path = project_path.path_join("scripts")
    var script_count = scripts.size()
    var index = 0
    
    for script_name in scripts:
        var script_content = scripts[script_name]
        var file = FileAccess.open(script_path.path_join(script_name), FileAccess.WRITE)
        
        if file:
            file.store_string(script_content)
            _update_project_generated_files(project_id, "script", script_path.path_join(script_name))
        else:
            _log_project_error(project_id, "Failed to write script: " + script_name)
        
        # Update progress
        index += 1
        var progress = 0.15 + (0.2 * float(index) / script_count)
        _update_project_progress(project_id, progress, "Generated base script " + str(index) + "/" + str(script_count))

func _generate_scenes(project_id: String, project_path: String) -> void:
    # Access project settings
    thread_mutex.lock()
    var project = active_projects[project_id]
    thread_mutex.unlock()
    
    # Define scenes to generate
    var scenes = {
        "main.tscn": _generate_main_scene(project),
        "player.tscn": _generate_player_scene(project),
        "ui/main_menu.tscn": _generate_main_menu_scene(project),
        "ui/game_ui.tscn": _generate_game_ui_scene(project),
        "levels/level_1.tscn": _generate_level_scene(project, 1)
    }
    
    # Generate each scene
    var scene_count = scenes.size()
    var index = 0
    
    for scene_path in scenes:
        var scene_content = scenes[scene_path]
        var full_path = project_path.path_join("scenes").path_join(scene_path)
        
        # Ensure directory exists
        var dir_path = full_path.get_base_dir()
        var dir = DirAccess.open(project_path.path_join("scenes"))
        
        if dir:
            dir.make_dir_recursive(dir_path.replace(project_path.path_join("scenes"), ""))
        
        # Write scene file
        var file = FileAccess.open(full_path, FileAccess.WRITE)
        
        if file:
            file.store_string(scene_content)
            _update_project_generated_files(project_id, "scene", full_path)
        else:
            _log_project_error(project_id, "Failed to write scene: " + scene_path)
        
        # Update progress
        index += 1
        var progress = 0.35 + (0.2 * float(index) / scene_count)
        _update_project_progress(project_id, progress, "Generated scene " + str(index) + "/" + str(scene_count))

func _generate_resources(project_id: String, project_path: String) -> void:
    # Generate theme
    var theme_content = _generate_theme_resource()
    var theme_path = project_path.path_join("resources/default_theme.tres")
    
    var dir = DirAccess.open(project_path.path_join("resources"))
    if not dir:
        dir = DirAccess.open(project_path)
        dir.make_dir("resources")
    
    var file = FileAccess.open(theme_path, FileAccess.WRITE)
    if file:
        file.store_string(theme_content)
        _update_project_generated_files(project_id, "resource", theme_path)
    else:
        _log_project_error(project_id, "Failed to write theme resource")
    
    # Update progress
    _update_project_progress(project_id, 0.6, "Generated resources")

func _generate_assets(project_id: String, project_path: String) -> void:
    # Generate placeholder icon
    var icon_content = "# Placeholder for icon.png binary data"
    var icon_path = project_path.path_join("assets/textures/icon.png")
    
    var dir = DirAccess.open(project_path.path_join("assets/textures"))
    if not dir:
        dir = DirAccess.open(project_path.path_join("assets"))
        dir.make_dir("textures")
    
    var file = FileAccess.open(icon_path, FileAccess.WRITE)
    if file:
        file.store_string(icon_content)
        _update_project_generated_files(project_id, "asset", icon_path)
    else:
        _log_project_error(project_id, "Failed to write icon asset")
    
    # Update progress
    _update_project_progress(project_id, 0.7, "Generated assets")

func _generate_documentation(project_id: String, project_path: String) -> void:
    # Generate README.md
    thread_mutex.lock()
    var project = active_projects[project_id]
    thread_mutex.unlock()
    
    var readme_content = """
# {name}

Version: {version}

## About

This game was generated with Luminous Auto Game Factory.

## Features

- Game Type: {game_type}
- Template: {template}
- Target Platform: {target_platform}
- Orientation: {orientation}

## Setup

1. Open the project in Godot 4.x
2. Run the main scene

## Controls

- WASD / Arrow Keys: Movement
- Space: Jump/Action
- Escape: Pause Menu

## License

This project is licensed under the MIT License - see the LICENSE file for details.
""".format({
        "name": project.name,
        "version": project.settings.version,
        "game_type": project.settings.game_type,
        "template": project.settings.template,
        "target_platform": project.settings.target_platform,
        "orientation": project.settings.orientation
    })
    
    var readme_path = project_path.path_join("README.md")
    
    var file = FileAccess.open(readme_path, FileAccess.WRITE)
    if file:
        file.store_string(readme_content)
        _update_project_generated_files(project_id, "doc", readme_path)
    else:
        _log_project_error(project_id, "Failed to write README.md")
    
    # Generate LICENSE
    var license_content = """
MIT License

Copyright (c) 2025 Luminous OS Auto Game Factory

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
"""
    
    var license_path = project_path.path_join("LICENSE")
    
    file = FileAccess.open(license_path, FileAccess.WRITE)
    if file:
        file.store_string(license_content)
        _update_project_generated_files(project_id, "doc", license_path)
    else:
        _log_project_error(project_id, "Failed to write LICENSE")
    
    # Update progress
    _update_project_progress(project_id, 0.8, "Generated documentation")

func _complete_project(project_id: String) -> void:
    thread_mutex.lock()
    
    if active_projects.has(project_id):
        var project = active_projects[project_id]
        project.status = "completed"
        project.progress = 1.0
        project.completion_time = Time.get_unix_time_from_system()
        
        # Move to completed projects
        completed_projects[project_id] = project
        active_projects.erase(project_id)
        
        # Add to history
        generation_history.append({
            "id": project_id,
            "name": project.name,
            "path": project.path,
            "timestamp": project.completion_time
        })
    
    thread_mutex.unlock()
    
    # Emit completion signal
    thread_mutex.lock()
    var project_path = completed_projects[project_id].path
    thread_mutex.unlock()
    
    call_deferred("emit_signal", "project_creation_completed", project_id, project_path)

# Helper functions for updating project state
func _update_project_progress(project_id: String, progress: float, message: String) -> void:
    thread_mutex.lock()
    
    if active_projects.has(project_id):
        active_projects[project_id].progress = progress
        active_projects[project_id].last_message = message
    
    thread_mutex.unlock()
    
    # Emit progress signal
    call_deferred("emit_signal", "project_creation_progress", project_id, progress, message)

func _update_project_generated_files(project_id: String, file_type: String, file_path: String) -> void:
    thread_mutex.lock()
    
    if active_projects.has(project_id):
        active_projects[project_id].files_generated += 1
        
        if file_type == "asset":
            active_projects[project_id].assets_generated += 1
    
    thread_mutex.unlock()
    
    # Emit asset/code generated signal
    if file_type == "asset":
        call_deferred("emit_signal", "asset_generated", project_id, file_type, file_path)
    else:
        call_deferred("emit_signal", "code_generated", project_id, file_type, file_path)

func _log_project_error(project_id: String, error_message: String) -> void:
    thread_mutex.lock()
    
    if active_projects.has(project_id):
        if not active_projects[project_id].has("errors"):
            active_projects[project_id].errors = []
        
        active_projects[project_id].errors.append({
            "message": error_message,
            "timestamp": Time.get_unix_time_from_system()
        })
    
    thread_mutex.unlock()

func _update_analysis_progress(analysis_id: String, progress: float, message: String) -> void:
    thread_mutex.lock()
    
    if pattern_repository.has(analysis_id):
        pattern_repository[analysis_id].progress = progress
        pattern_repository[analysis_id].last_message = message
    
    thread_mutex.unlock()
    
    # Emit progress signal
    call_deferred("emit_signal", "data_processing_progress", analysis_id, progress, message)

# Code generation helper functions
func _generate_game_controller_script(project) -> String:
    return """extends Node
# Game Controller
# Central control system for the entire game

signal game_state_changed(new_state)
signal score_changed(new_score)
signal level_started(level_number)
signal level_completed(level_number)

enum GameState {MAIN_MENU, PLAYING, PAUSED, GAME_OVER, VICTORY}

var current_state: GameState = GameState.MAIN_MENU
var current_level: int = 1
var score: int = 0
var high_score: int = 0
var player_lives: int = 3

# Settings
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var fullscreen: bool = false

func _ready():
    # Initialize game
    load_settings()

func _process(delta):
    # Process based on game state
    match current_state:
        GameState.PLAYING:
            pass
        GameState.PAUSED:
            pass
        GameState.GAME_OVER:
            pass

func start_game():
    current_level = 1
    score = 0
    player_lives = 3
    change_game_state(GameState.PLAYING)
    emit_signal("level_started", current_level)

func change_game_state(new_state: GameState):
    current_state = new_state
    emit_signal("game_state_changed", new_state)

func pause_game():
    if current_state == GameState.PLAYING:
        change_game_state(GameState.PAUSED)

func resume_game():
    if current_state == GameState.PAUSED:
        change_game_state(GameState.PLAYING)

func game_over():
    change_game_state(GameState.GAME_OVER)
    save_high_score()

func add_score(points: int):
    score += points
    emit_signal("score_changed", score)

func next_level():
    current_level += 1
    emit_signal("level_completed", current_level - 1)
    emit_signal("level_started", current_level)

func save_settings():
    var settings = {
        "music_volume": music_volume,
        "sfx_volume": sfx_volume,
        "fullscreen": fullscreen,
        "high_score": high_score
    }
    
    var file = FileAccess.open("user://settings.save", FileAccess.WRITE)
    if file:
        file.store_var(settings)

func load_settings():
    if FileAccess.file_exists("user://settings.save"):
        var file = FileAccess.open("user://settings.save", FileAccess.READ)
        if file:
            var settings = file.get_var()
            music_volume = settings.get("music_volume", 1.0)
            sfx_volume = settings.get("sfx_volume", 1.0)
            fullscreen = settings.get("fullscreen", false)
            high_score = settings.get("high_score", 0)
            
            _apply_settings()

func _apply_settings():
    # Apply audio settings
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(music_volume))
    
    # Apply video settings
    if fullscreen:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func save_high_score():
    if score > high_score:
        high_score = score
        save_settings()
"""

func _generate_resource_manager_script(project) -> String:
    return """extends Node
# Resource Manager
# Handles loading and caching of game resources

var _textures = {}
var _audio = {}
var _scenes = {}

func _ready():
    # Preload common resources
    preload_resources()

func preload_resources():
    # Preload common textures
    preload_texture("icon", "res://assets/textures/icon.png")
    
    # Preload common audio
    
    # Preload common scenes

func preload_texture(id: String, path: String):
    if ResourceLoader.exists(path):
        var texture = load(path)
        if texture:
            _textures[id] = texture

func preload_audio(id: String, path: String):
    if ResourceLoader.exists(path):
        var audio = load(path)
        if audio:
            _audio[id] = audio

func preload_scene(id: String, path: String):
    if ResourceLoader.exists(path):
        var scene = load(path)
        if scene:
            _scenes[id] = scene

func get_texture(id: String) -> Texture2D:
    if _textures.has(id):
        return _textures[id]
    return null

func get_audio(id: String) -> AudioStream:
    if _audio.has(id):
        return _audio[id]
    return null

func get_scene(id: String) -> PackedScene:
    if _scenes.has(id):
        return _scenes[id]
    return null

func load_texture(path: String) -> Texture2D:
    if ResourceLoader.exists(path):
        return load(path)
    return null

func load_audio(path: String) -> AudioStream:
    if ResourceLoader.exists(path):
        return load(path)
    return null

func load_scene(path: String) -> PackedScene:
    if ResourceLoader.exists(path):
        return load(path)
    return null

func clear_cache():
    _textures.clear()
    _audio.clear()
    _scenes.clear()
"""

func _generate_player_script(project) -> String:
    var game_type = project.settings.game_type
    
    if game_type == "2d":
        return """extends CharacterBody2D
# Player controller for 2D game

signal health_changed(new_health)
signal player_died

@export var speed = 300.0
@export var jump_velocity = -400.0
@export var max_health = 100.0

var current_health = max_health
var is_jumping = false
var direction = Vector2.ZERO

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
    current_health = max_health
    emit_signal("health_changed", current_health)

func _physics_process(delta):
    # Add gravity
    if not is_on_floor():
        velocity.y += gravity * delta

    # Handle jump
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = jump_velocity
        is_jumping = true
    
    # Get input direction
    direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    
    # Handle horizontal movement
    if direction.x:
        velocity.x = direction.x * speed
    else:
        # Stop horizontal movement if no input
        velocity.x = move_toward(velocity.x, 0, speed)
    
    # Apply movement
    move_and_slide()
    
    # Update animation based on movement
    _update_animation()

func take_damage(amount: float):
    current_health -= amount
    emit_signal("health_changed", current_health)
    
    if current_health <= 0:
        die()

func heal(amount: float):
    current_health = min(current_health + amount, max_health)
    emit_signal("health_changed", current_health)

func die():
    emit_signal("player_died")
    # Handle death (animation, respawn, etc)

func _update_animation():
    # Update sprite direction and animation based on movement
    if direction.x > 0:
        $Sprite2D.flip_h = false
    elif direction.x < 0:
        $Sprite2D.flip_h = true
    
    if abs(velocity.x) > 0.1:
        $AnimationPlayer.play("run")
    else:
        $AnimationPlayer.play("idle")
    
    if is_jumping:
        $AnimationPlayer.play("jump")

func _on_animation_finished(anim_name):
    if anim_name == "jump":
        is_jumping = false
"""
    else:  # 3D
        return """extends CharacterBody3D
# Player controller for 3D game

signal health_changed(new_health)
signal player_died

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var mouse_sensitivity = 0.002
@export var max_health = 100.0

var current_health = max_health
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
    current_health = max_health
    emit_signal("health_changed", current_health)
    
    # Capture mouse
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
    # Mouse look
    if event is InputEventMouseMotion:
        rotate_y(-event.relative.x * mouse_sensitivity)
        $Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
        $Camera3D.rotation.x = clamp($Camera3D.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
    # Add gravity
    if not is_on_floor():
        velocity.y -= gravity * delta

    # Handle jump
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = jump_velocity

    # Get movement input
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)

    move_and_slide()

func take_damage(amount: float):
    current_health -= amount
    emit_signal("health_changed", current_health)
    
    if current_health <= 0:
        die()

func heal(amount: float):
    current_health = min(current_health + amount, max_health)
    emit_signal("health_changed", current_health)

func die():
    emit_signal("player_died")
    # Handle death (animation, respawn, etc)
"""

func _generate_input_handler_script(project) -> String:
    return """extends Node
# Input Handler
# Manages input mapping and processing

# Input action mapping
var action_map = {
    "move_left": "ui_left",
    "move_right": "ui_right",
    "move_up": "ui_up",
    "move_down": "ui_down",
    "jump": "ui_accept",
    "interact": "ui_select",
    "pause": "ui_cancel"
}

# For touch controls
var touch_buttons = {}
var virtual_joystick = null

func _ready():
    # Initialize touch controls if needed
    if DisplayServer.is_touchscreen_available():
        _setup_touch_controls()

func _setup_touch_controls():
    # Create virtual joystick and touch buttons
    # Note: In a real implementation, these would be proper scenes
    pass

func register_touch_button(button_name: String, node: TouchScreenButton):
    touch_buttons[button_name] = node

func register_virtual_joystick(joystick: Node):
    virtual_joystick = joystick

func get_movement_vector() -> Vector2:
    # Get movement from keyboard
    var keyboard_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    
    # Combine with touch input if available
    if virtual_joystick and keyboard_input == Vector2.ZERO:
        return virtual_joystick.get_value()
    
    return keyboard_input

func is_action_pressed(action: String) -> bool:
    if not action_map.has(action):
        return false
    
    var mapped_action = action_map[action]
    
    # Check keyboard/gamepad input
    if Input.is_action_pressed(mapped_action):
        return true
    
    # Check touch input
    if touch_buttons.has(action) and touch_buttons[action].is_pressed():
        return true
    
    return false

func is_action_just_pressed(action: String) -> bool:
    if not action_map.has(action):
        return false
    
    var mapped_action = action_map[action]
    
    # Check keyboard/gamepad input
    if Input.is_action_just_pressed(mapped_action):
        return true
    
    # No way to check just_pressed for touch buttons in this simplified implementation
    
    return false

func remap_action(action: String, input_event: InputEvent):
    if not action_map.has(action):
        return
    
    var mapped_action = action_map[action]
    
    # Clear the existing mapping
    InputMap.action_erase_events(mapped_action)
    
    # Add the new mapping
    InputMap.action_add_event(mapped_action, input_event)

func save_input_mapping():
    var mappings = {}
    
    for action in action_map:
        var mapped_action = action_map[action]
        var events = InputMap.action_get_events(mapped_action)
        
        if events.size() > 0:
            mappings[action] = events[0].as_text()
    
    var file = FileAccess.open("user://input_mappings.save", FileAccess.WRITE)
    if file:
        file.store_var(mappings)

func load_input_mapping():
    if FileAccess.file_exists("user://input_mappings.save"):
        var file = FileAccess.open("user://input_mappings.save", FileAccess.READ)
        if file:
            var mappings = file.get_var()
            
            for action in mappings:
                if action_map.has(action):
                    var mapped_action = action_map[action]
                    var input_event = InputEventKey.new()
                    # Note: This is simplified - proper implementation would parse the event text
                    InputMap.action_add_event(mapped_action, input_event)
"""

func _generate_ui_manager_script(project) -> String:
    return """extends Node
# UI Manager
# Handles UI transitions and states

signal ui_screen_changed(screen_name)

var current_screen = null
var screen_stack = []
var screens = {}

func _ready():
    # Register UI screens
    register_screen("main_menu", $MainMenu)
    register_screen("game_ui", $GameUI)
    register_screen("pause_menu", $PauseMenu)
    register_screen("game_over", $GameOver)
    
    # Connect to game state changes
    GameController.connect("game_state_changed", _on_game_state_changed)
    
    # Start with main menu
    show_screen("main_menu")

func register_screen(screen_name: String, screen_node: Control):
    screens[screen_name] = screen_node
    screen_node.hide()

func show_screen(screen_name: String):
    if not screens.has(screen_name):
        push_error("UI screen not found: " + screen_name)
        return
    
    # Hide current screen
    if current_screen:
        current_screen.hide()
    
    # Show new screen
    current_screen = screens[screen_name]
    current_screen.show()
    
    emit_signal("ui_screen_changed", screen_name)

func push_screen(screen_name: String):
    if not screens.has(screen_name):
        push_error("UI screen not found: " + screen_name)
        return
    
    # Add current screen to stack
    if current_screen:
        screen_stack.push_back(current_screen)
        current_screen.hide()
    
    # Show new screen
    current_screen = screens[screen_name]
    current_screen.show()
    
    emit_signal("ui_screen_changed", screen_name)

func pop_screen():
    if screen_stack.size() == 0:
        return
    
    # Hide current screen
    if current_screen:
        current_screen.hide()
    
    # Show previous screen
    current_screen = screen_stack.pop_back()
    current_screen.show()
    
    emit_signal("ui_screen_changed", current_screen.name)

func _on_game_state_changed(new_state):
    match new_state:
        GameController.GameState.MAIN_MENU:
            show_screen("main_menu")
        GameController.GameState.PLAYING:
            show_screen("game_ui")
        GameController.GameState.PAUSED:
            push_screen("pause_menu")
        GameController.GameState.GAME_OVER:
            push_screen("game_over")
"""

# Scene generation helper functions
func _generate_main_scene(project) -> String:
    return """[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/game_controller.gd" id="1_controller"]
[ext_resource type="PackedScene" path="res://scenes/ui/main_menu.tscn" id="2_main_menu"]

[node name="Main" type="Node"]
script = ExtResource("1_controller")

[node name="MainMenu" parent="." instance=ExtResource("2_main_menu")]

[node name="GameUI" type="Control" parent="."]
visible = false
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

[node name="PauseMenu" type="Control" parent="."]
visible = false
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

[node name="GameOver" type="Control" parent="."]
visible = false
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

[node name="AudioPlayers" type="Node" parent="."]

[node name="MusicPlayer" type="AudioStreamPlayer" parent="AudioPlayers"]

[node name="SFXPlayer" type="AudioStreamPlayer" parent="AudioPlayers"]
"""

func _generate_player_scene(project) -> String:
    var game_type = project.settings.game_type
    
    if game_type == "2d":
        return """[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/player.gd" id="1_script"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_1"]
size = Vector2(32, 64)

[node name="Player" type="CharacterBody2D"]
script = ExtResource("1_script")

[node name="Sprite2D" type="Sprite2D" parent="."]

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("RectangleShape2D_1")

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]

[node name="Camera2D" type="Camera2D" parent="."]
current = true

[connection signal="animation_finished" from="AnimationPlayer" to="." method="_on_animation_finished"]
"""
    else:  # 3D
        return """[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/player.gd" id="1_script"]

[sub_resource type="CapsuleShape3D" id="CapsuleShape3D_1"]
height = 2.0

[node name="Player" type="CharacterBody3D"]
script = ExtResource("1_script")

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
shape = SubResource("CapsuleShape3D_1")

[node name="MeshInstance3D" type="MeshInstance3D" parent="."]

[node name="Camera3D" type="Camera3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.7, 0)
current = true
"""

func _generate_main_menu_scene(project) -> String:
    return """[gd_scene load_steps=2 format=3]

[ext_resource type="Theme" path="res://resources/default_theme.tres" id="1_theme"]

[node name="MainMenu" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
theme = ExtResource("1_theme")

[node name="Background" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0.1, 0.1, 0.2, 1.0)

[node name="TitleLabel" type="Label" parent="."]
layout_mode = 1
anchors_preset = 5
anchor_left = 0.5
anchor_right = 0.5
offset_left = -200.0
offset_top = 100.0
offset_right = 200.0
offset_bottom = 200.0
grow_horizontal = 2
theme_override_font_sizes/font_size = 48
text = "{name}"
horizontal_alignment = 1
vertical_alignment = 1

[node name="ButtonsContainer" type="VBoxContainer" parent="."]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -100.0
offset_top = -100.0
offset_right = 100.0
offset_bottom = 100.0
grow_horizontal = 2
grow_vertical = 2
theme_override_constants/separation = 20

[node name="StartButton" type="Button" parent="ButtonsContainer"]
layout_mode = 2
size_flags_vertical = 3
text = "Start Game"

[node name="OptionsButton" type="Button" parent="ButtonsContainer"]
layout_mode = 2
size_flags_vertical = 3
text = "Options"

[node name="QuitButton" type="Button" parent="ButtonsContainer"]
layout_mode = 2
size_flags_vertical = 3
text = "Quit"

[node name="VersionLabel" type="Label" parent="."]
layout_mode = 1
anchors_preset = 3
anchor_left = 1.0
anchor_top = 1.0
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = -100.0
offset_top = -40.0
offset_right = -20.0
offset_bottom = -20.0
grow_horizontal = 0
grow_vertical = 0
text = "v{version}"
horizontal_alignment = 2

[connection signal="pressed" from="ButtonsContainer/StartButton" to="." method="_on_start_button_pressed"]
[connection signal="pressed" from="ButtonsContainer/OptionsButton" to="." method="_on_options_button_pressed"]
[connection signal="pressed" from="ButtonsContainer/QuitButton" to="." method="_on_quit_button_pressed"]
""".format({
        "name": project.name,
        "version": project.settings.version
    })

func _generate_game_ui_scene(project) -> String:
    return """[gd_scene load_steps=2 format=3]

[ext_resource type="Theme" path="res://resources/default_theme.tres" id="1_theme"]

[node name="GameUI" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
theme = ExtResource("1_theme")

[node name="ScoreLabel" type="Label" parent="."]
layout_mode = 0
offset_left = 20.0
offset_top = 20.0
offset_right = 200.0
offset_bottom = 50.0
text = "Score: 0"
vertical_alignment = 1

[node name="HealthBar" type="ProgressBar" parent="."]
layout_mode = 1
anchors_preset = 1
anchor_left = 1.0
anchor_right = 1.0
offset_left = -200.0
offset_top = 20.0
offset_right = -20.0
offset_bottom = 50.0
grow_horizontal = 0
value = 100.0

[node name="HealthLabel" type="Label" parent="HealthBar"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
text = "Health: 100"
horizontal_alignment = 1
vertical_alignment = 1

[node name="PauseButton" type="Button" parent="."]
layout_mode = 1
anchors_preset = 1
anchor_left = 1.0
anchor_right = 1.0
offset_left = -60.0
offset_top = 60.0
offset_right = -20.0
offset_bottom = 90.0
grow_horizontal = 0
text = "II"

[connection signal="pressed" from="PauseButton" to="." method="_on_pause_button_pressed"]
"""

func _generate_level_scene(project, level_number: int) -> String:
    var game_type = project.settings.game_type
    
    if game_type == "2d":
        return """[gd_scene load_steps=2 format=3]

[ext_resource type="PackedScene" path="res://scenes/player.tscn" id="1_player"]

[node name="Level{level}" type="Node2D"]

[node name="TileMap" type="TileMap" parent="."]
format = 2
layer_0/name = "Ground"
layer_1/name = "Walls"
layer_1/enabled = true

[node name="Player" parent="." instance=ExtResource("1_player")]
position = Vector2(100, 100)

[node name="Enemies" type="Node2D" parent="."]

[node name="Collectibles" type="Node2D" parent="."]

[node name="ExitArea" type="Area2D" parent="."]
position = Vector2(900, 500)

[node name="CollisionShape2D" type="CollisionShape2D" parent="ExitArea"]

[connection signal="body_entered" from="ExitArea" to="." method="_on_exit_area_body_entered"]
""".format({"level": level_number})
    else:  # 3D
        return """[gd_scene load_steps=2 format=3]

[ext_resource type="PackedScene" path="res://scenes/player.tscn" id="1_player"]

[node name="Level{level}" type="Node3D"]

[node name="WorldEnvironment" type="WorldEnvironment" parent="."]

[node name="DirectionalLight3D" type="DirectionalLight3D" parent="."]
transform = Transform3D(0.866025, -0.433013, 0.25, 0, 0.5, 0.866025, -0.5, -0.75, 0.433013, 0, 10, 0)
shadow_enabled = true

[node name="Ground" type="StaticBody3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -1, 0)

[node name="CollisionShape3D" type="CollisionShape3D" parent="Ground"]

[node name="MeshInstance3D" type="MeshInstance3D" parent="Ground"]

[node name="Player" parent="." instance=ExtResource("1_player")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2, 0)

[node name="Enemies" type="Node3D" parent="."]

[node name="Collectibles" type="Node3D" parent="."]

[node name="ExitArea" type="Area3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 10, 0, 10)

[node name="CollisionShape3D" type="CollisionShape3D" parent="ExitArea"]

[connection signal="body_entered" from="ExitArea" to="." method="_on_exit_area_body_entered"]
""".format({"level": level_number})

func _generate_theme_resource() -> String:
    return """[gd_resource type="Theme" format=3]

[resource]
Button/colors/font_color = Color(0.875, 0.875, 0.875, 1)
Button/colors/font_focus_color = Color(0.95, 0.95, 0.95, 1)
Button/colors/font_hover_color = Color(0.95, 0.95, 0.95, 1)
Button/colors/font_hover_pressed_color = Color(1, 1, 1, 1)
Button/colors/font_pressed_color = Color(0.75, 0.75, 0.75, 1)
Button/constants/h_separation = 4
Button/constants/outline_size = 0
Button/constants/padding = 4
Button/font_sizes/font_size = 16
Label/colors/font_color = Color(0.875, 0.875, 0.875, 1)
Label/colors/font_shadow_color = Color(0, 0, 0, 0.75)
Label/constants/shadow_offset_x = 1
Label/constants/shadow_offset_y = 1
Label/constants/shadow_outline_size = 1
ProgressBar/colors/font_color = Color(0.875, 0.875, 0.875, 1)
"""

# Data analysis helper functions
func _analyze_single_data_source(source: Dictionary) -> Dictionary:
    var results = {}
    
    if source.has("type") and source.has("path"):
        match source.type:
            "script_folder":
                results["script_patterns"] = scan_user_code_style(source.path)
            "text_file":
                if FileAccess.file_exists(source.path):
                    var file = FileAccess.open(source.path, FileAccess.READ)
                    if file:
                        var content = file.get_as_text()
                        results["text_patterns"] = _analyze_text_patterns(content)
            "image_folder":
                results["image_patterns"] = {"color_schemes": []}
    
    return results

func _analyze_code_style(code: String, patterns: Dictionary) -> void:
    # Analyze indentation
    var indent_type = "unknown"
    var indent_size = 0
    
    if code.find("\t") != -1:
        indent_type = "tab"
    elif code.find("    ") != -1:
        indent_type = "space"
        indent_size = 4
    elif code.find("  ") != -1:
        indent_type = "space"
        indent_size = 2
    
    patterns["indentation"] = {
        "type": indent_type,
        "size": indent_size
    }
    
    # Analyze naming conventions
    var camel_case_count = 0
    var snake_case_count = 0
    var pascal_case_count = 0
    
    var lines = code.split("\n")
    for line in lines:
        # Check for variable declarations
        if line.find("var ") != -1 or line.find("const ") != -1:
            var name_start = line.find(" ") + 1
            var name_end = line.find("=", name_start)
            if name_end == -1:
                name_end = line.find(":", name_start)
            
            if name_end == -1:
                continue
            
            var var_name = line.substr(name_start, name_end - name_start).strip_edges()
            
            if var_name.match("*_*"):
                snake_case_count += 1
            elif var_name[0].to_upper() == var_name[0]:
                pascal_case_count += 1
            else:
                camel_case_count += 1
    
    var naming_style = "unknown"
    if snake_case_count > camel_case_count and snake_case_count > pascal_case_count:
        naming_style = "snake_case"
    elif camel_case_count > snake_case_count and camel_case_count > pascal_case_count:
        naming_style = "camelCase"
    elif pascal_case_count > snake_case_count and pascal_case_count > camel_case_count:
        naming_style = "PascalCase"
    
    patterns["naming_style"] = naming_style

func _analyze_text_patterns(text: String) -> Dictionary:
    var patterns = {}
    
    # Analyze word frequency
    var words = text.split(" ")
    var word_count = {}
    
    for word in words:
        var clean_word = word.strip_edges().to_lower()
        if clean_word.length() > 3:  # Ignore short words
            if not word_count.has(clean_word):
                word_count[clean_word] = 0
            word_count[clean_word] += 1
    
    # Sort words by frequency
    var sorted_words = []
    for word in word_count:
        sorted_words.append({"word": word, "count": word_count[word]})
    
    sorted_words.sort_custom(func(a, b): return a.count > b.count)
    
    # Take top words
    var top_words = []
    for i in range(min(20, sorted_words.size())):
        top_words.append(sorted_words[i].word)
    
    patterns["top_words"] = top_words
    
    return patterns

func _find_script_files(dir: DirAccess, base_path: String, file_list: Array) -> void:
    dir.list_dir_begin()
    var file_name = dir.get_next()
    
    while file_name != "":
        if file_name != "." and file_name != "..":
            var full_path = base_path.path_join(file_name)
            
            if dir.current_is_dir():
                var subdir = DirAccess.open(full_path)
                if subdir:
                    _find_script_files(subdir, full_path, file_list)
            elif file_name.ends_with(".gd") or file_name.ends_with(".cs"):
                file_list.append(full_path)
        
        file_name = dir.get_next()
    
    dir.list_dir_end()

func _scan_project_structure(project_path: String, template: Dictionary) -> void:
    var dir = DirAccess.open(project_path)
    if not dir:
        return
    
    dir.list_dir_begin()
    var file_name = dir.get_next()
    
    while file_name != "":
        if file_name != "." and file_name != "..":
            var full_path = project_path.path_join(file_name)
            
            if dir.current_is_dir():
                template.structure[file_name] = "directory"
                var subdir = DirAccess.open(full_path)
                if subdir:
                    _scan_project_structure(full_path, template)
            else:
                template.structure[file_name] = "file"
                
                # Store content of important files
                if file_name.ends_with(".gd") or file_name.ends_with(".tscn") or file_name == "project.godot":
                    var file = FileAccess.open(full_path, FileAccess.READ)
                    if file:
                        template.files[full_path.replace(project_path + "/", "")] = file.get_as_text()
        
        file_name = dir.get_next()
    
    dir.list_dir_end()

func _load_project_templates() -> void:
    # Define built-in templates
    project_templates = {
        "2d_platformer": {
            "name": "2D Platformer",
            "description": "A side-scrolling platformer game with jumping, collecting, and enemies",
            "type": "2d",
            "complexity": "beginner"
        },
        "top_down_rpg": {
            "name": "Top-Down RPG",
            "description": "An RPG with quests, combat, inventory, and character progression",
            "type": "2d",
            "complexity": "intermediate"
        },
        "fps": {
            "name": "First Person Shooter",
            "description": "A 3D shooter with weapons, enemies, and multiple levels",
            "type": "3d",
            "complexity": "advanced"
        },
        "puzzle_game": {
            "name": "Puzzle Game",
            "description": "A puzzle-solving game with different mechanics and levels",
            "type": "2d",
            "complexity": "beginner"
        }
    }
    
    # Try to load custom templates
    if FileAccess.file_exists("user://luminous_templates.json"):
        var file = FileAccess.open("user://luminous_templates.json", FileAccess.READ)
        if file:
            var content = file.get_as_text()
            var json_result = JSON.parse_string(content)
            
            if json_result and typeof(json_result) == TYPE_DICTIONARY:
                for template_name in json_result:
                    project_templates[template_name] = json_result[template_name]

func _save_project_templates() -> void:
    var file = FileAccess.open("user://luminous_templates.json", FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(project_templates, "\t"))