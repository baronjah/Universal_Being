extends Node
class_name AIModelManager

# AIModelManager
# Central system for managing multiple AI models, coordinating 12-turn cycles,
# and providing a terminal interface for control and audio playback
# Integrates with MagicItemSystem, SpellCastingSystem, and AIGameCreator

signal turn_completed(turn_data)
signal cycle_completed(cycle_data)
signal ai_action_performed(action_data)
signal model_switched(model_data)
signal audio_state_changed(audio_data)
signal mecha_interface_updated(interface_data)

# Core Configuration
const TOTAL_TURNS_PER_CYCLE = 12
const DEFAULT_TURN_DURATION = 60.0  # 1 minute per turn
const MAX_MODELS = 8              # Maximum number of AI models that can be loaded
const ENERGY_TYPES = ["control", "perception", "action", "reasoning", "creativity", "adaptation"]
const MODEL_TYPES = ["text", "image", "audio", "multimodal", "agent", "mecha", "simulation", "specialist"]
const TERMINAL_MODES = ["command", "conversation", "analysis", "monitoring", "composition", "orchestration"]

# System State
var current_turn = 0
var current_turn_timer = 0.0
var turn_duration = DEFAULT_TURN_DURATION
var cycle_active = false
var terminal_active = false
var audio_playing = false
var current_terminal_mode = "command"
var loaded_models = []
var active_model_index = -1
var turn_history = []
var command_history = []
var audio_playlist = []
var current_audio_track = -1
var mecha_interfaces = []
var active_mecha = -1

# Integration references
var magic_item_system = null
var spell_system = null
var game_creator = null
var api_manager = null

# Energy and Resource System
var model_energy = {}
var shared_resources = {}
var cooperation_metrics = {}

class AIModel:
    var id = ""
    var name = ""
    var type = ""
    var version = "1.0"
    var capabilities = []
    var energy_levels = {}
    var configuration = {}
    var performance_metrics = {}
    var active = false
    var loaded_at = 0
    var last_action_at = 0
    var cooperation_score = 1.0  # 0.0-2.0 (1.0 is neutral)
    var specialization = ""
    var command_set = []
    
    func _init(p_name="", p_type="text", p_capabilities=[]):
        id = str(OS.get_unix_time()) + "_model_" + str(randi() % 1000)
        name = p_name
        type = p_type
        capabilities = p_capabilities
        loaded_at = OS.get_unix_time()
        
        # Initialize default energy levels
        for energy_type in ENERGY_TYPES:
            energy_levels[energy_type] = 100.0
    
    func to_dict():
        return {
            "id": id,
            "name": name,
            "type": type,
            "version": version,
            "capabilities": capabilities,
            "energy_levels": energy_levels, 
            "configuration": configuration,
            "performance_metrics": performance_metrics,
            "active": active,
            "loaded_at": loaded_at,
            "last_action_at": last_action_at,
            "cooperation_score": cooperation_score,
            "specialization": specialization,
            "command_set": command_set
        }
    
    func from_dict(data):
        id = data.get("id", "")
        name = data.get("name", "")
        type = data.get("type", "text")
        version = data.get("version", "1.0")
        capabilities = data.get("capabilities", [])
        energy_levels = data.get("energy_levels", {})
        configuration = data.get("configuration", {})
        performance_metrics = data.get("performance_metrics", {})
        active = data.get("active", false)
        loaded_at = data.get("loaded_at", 0)
        last_action_at = data.get("last_action_at", 0)
        cooperation_score = data.get("cooperation_score", 1.0)
        specialization = data.get("specialization", "")
        command_set = data.get("command_set", [])

class ModelAction:
    var id = ""
    var model_id = ""
    var model_name = ""
    var action_type = ""
    var target = ""
    var parameters = {}
    var result = {}
    var energy_cost = {}
    var resources_used = {}
    var timestamp = 0
    var turn_number = 0
    var cooperation_impact = 0.0
    var success = true
    
    func _init(p_model_id="", p_model_name="", p_action_type=""):
        id = str(OS.get_unix_time()) + "_action_" + str(randi() % 1000)
        model_id = p_model_id
        model_name = p_model_name
        action_type = p_action_type
        timestamp = OS.get_unix_time()
    
    func to_dict():
        return {
            "id": id,
            "model_id": model_id,
            "model_name": model_name,
            "action_type": action_type,
            "target": target,
            "parameters": parameters,
            "result": result,
            "energy_cost": energy_cost,
            "resources_used": resources_used,
            "timestamp": timestamp,
            "turn_number": turn_number,
            "cooperation_impact": cooperation_impact,
            "success": success
        }

class TurnData:
    var turn_number = 0
    var start_time = 0
    var end_time = 0
    var actions = []
    var energy_changes = {}
    var resource_changes = {}
    var cooperation_changes = {}
    var notes = ""
    
    func _init(p_turn_number=0):
        turn_number = p_turn_number
        start_time = OS.get_unix_time()
    
    func complete_turn():
        end_time = OS.get_unix_time()
    
    func to_dict():
        return {
            "turn_number": turn_number,
            "start_time": start_time,
            "end_time": end_time,
            "duration": end_time - start_time if end_time > 0 else 0,
            "actions": actions,
            "energy_changes": energy_changes,
            "resource_changes": resource_changes,
            "cooperation_changes": cooperation_changes,
            "notes": notes
        }

class AudioTrack:
    var id = ""
    var title = ""
    var path = ""
    var duration = 0.0
    var tags = []
    var associated_models = []
    var energy_influence = {}
    var play_count = 0
    var last_played = 0
    
    func _init(p_title="", p_path=""):
        id = str(OS.get_unix_time()) + "_track_" + str(randi() % 1000)
        title = p_title
        path = p_path
    
    func to_dict():
        return {
            "id": id,
            "title": title,
            "path": path,
            "duration": duration,
            "tags": tags,
            "associated_models": associated_models,
            "energy_influence": energy_influence,
            "play_count": play_count,
            "last_played": last_played
        }

class MechaInterface:
    var id = ""
    var name = ""
    var model_id = ""
    var capabilities = []
    var control_scheme = {}
    var energy_consumption = {}
    var status = "standby"  # standby, active, cooldown, maintenance
    var modules = []
    var linked_models = []
    var performance_metrics = {}
    var activation_time = 0
    var cooldown_remaining = 0.0
    
    func _init(p_name="", p_model_id=""):
        id = str(OS.get_unix_time()) + "_mecha_" + str(randi() % 1000)
        name = p_name
        model_id = p_model_id
    
    func to_dict():
        return {
            "id": id,
            "name": name,
            "model_id": model_id,
            "capabilities": capabilities,
            "control_scheme": control_scheme,
            "energy_consumption": energy_consumption,
            "status": status,
            "modules": modules,
            "linked_models": linked_models,
            "performance_metrics": performance_metrics,
            "activation_time": activation_time,
            "cooldown_remaining": cooldown_remaining
        }
    
    func from_dict(data):
        id = data.get("id", "")
        name = data.get("name", "")
        model_id = data.get("model_id", "")
        capabilities = data.get("capabilities", [])
        control_scheme = data.get("control_scheme", {})
        energy_consumption = data.get("energy_consumption", {})
        status = data.get("status", "standby")
        modules = data.get("modules", [])
        linked_models = data.get("linked_models", [])
        performance_metrics = data.get("performance_metrics", {})
        activation_time = data.get("activation_time", 0)
        cooldown_remaining = data.get("cooldown_remaining", 0.0)

class TerminalCommand:
    var id = ""
    var command = ""
    var parameters = []
    var source_model = ""
    var target_model = ""
    var timestamp = 0
    var result = {}
    var energy_cost = 0.0
    var execution_time = 0.0
    
    func _init(p_command="", p_parameters=[], p_source="terminal"):
        id = str(OS.get_unix_time()) + "_cmd_" + str(randi() % 1000)
        command = p_command
        parameters = p_parameters
        source_model = p_source
        timestamp = OS.get_unix_time()
    
    func to_dict():
        return {
            "id": id,
            "command": command,
            "parameters": parameters,
            "source_model": source_model,
            "target_model": target_model,
            "timestamp": timestamp,
            "result": result,
            "energy_cost": energy_cost,
            "execution_time": execution_time
        }

func _ready():
    # Initialize resources
    shared_resources = {
        "memory": 100.0,
        "processing": 100.0,
        "data_access": 100.0,
        "creativity_tokens": 100.0,
        "synchronization": 100.0
    }
    
    # Initialize cooperation metrics
    cooperation_metrics = {
        "resource_sharing": 1.0,
        "turn_balance": 1.0,
        "model_synergy": 1.0,
        "communication": 1.0,
        "task_coordination": 1.0
    }
    
    # Set up turn timer
    _setup_turn_timer()
    
    # Load previous system state
    load_system_state()
    
    # Set up default models if none exist
    if loaded_models.empty():
        _create_default_models()
    
    # Set up default mecha interfaces if none exist
    if mecha_interfaces.empty():
        _create_default_mecha_interfaces()
    
    print("AI Model Manager initialized with %d models and %d mecha interfaces" % [
        loaded_models.size(), mecha_interfaces.size()
    ])

# Time Management System

func _setup_turn_timer():
    # Create turn timer
    var timer = Timer.new()
    timer.wait_time = 1.0  # Update every second
    timer.one_shot = false
    timer.connect("timeout", self, "_on_turn_timer_timeout")
    add_child(timer)
    timer.start()

func start_turn_cycle(duration_per_turn=DEFAULT_TURN_DURATION):
    if cycle_active:
        print("Turn cycle already active")
        return false
    
    # Reset turn counter
    current_turn = 0
    current_turn_timer = 0.0
    turn_duration = duration_per_turn
    cycle_active = true
    
    # Start first turn
    start_new_turn()
    
    print("Turn cycle started with %.1f seconds per turn" % turn_duration)
    return true

func start_new_turn():
    # Complete previous turn if any
    var previous_turn = current_turn
    
    # Increment turn counter
    current_turn += 1
    
    if current_turn > TOTAL_TURNS_PER_CYCLE:
        complete_cycle()
        return
    
    # Reset turn timer
    current_turn_timer = 0.0
    
    # Create turn data
    var turn_data = TurnData.new(current_turn)
    
    # Record starting energy levels
    for model in loaded_models:
        if model.active:
            turn_data.energy_changes[model.id] = {
                "initial": model.energy_levels.duplicate()
            }
    
    # Record starting resource levels
    turn_data.resource_changes = {
        "initial": shared_resources.duplicate()
    }
    
    # Record starting cooperation metrics
    turn_data.cooperation_changes = {
        "initial": cooperation_metrics.duplicate()
    }
    
    # Add to history
    turn_history.append(turn_data.to_dict())
    
    # Notify active models of turn start
    for model in loaded_models:
        if model.active:
            # Replenish some energy at turn start
            for energy_type in model.energy_levels:
                model.energy_levels[energy_type] += 5.0
                model.energy_levels[energy_type] = min(model.energy_levels[energy_type], 100.0)
    
    print("Turn %d started (of %d in cycle)" % [current_turn, TOTAL_TURNS_PER_CYCLE])
    emit_signal("turn_completed", {
        "turn_number": current_turn,
        "previous_turn": previous_turn,
        "total_turns": TOTAL_TURNS_PER_CYCLE,
        "turn_duration": turn_duration,
        "cycle_active": cycle_active
    })
    
    return true

func complete_turn():
    if current_turn <= 0 or current_turn > TOTAL_TURNS_PER_CYCLE:
        print("No active turn to complete")
        return false
    
    # Get turn data
    var turn_idx = turn_history.size() - 1
    if turn_idx < 0:
        return false
    
    var turn_data = turn_history[turn_idx]
    
    # Set end time
    turn_data.end_time = OS.get_unix_time()
    
    # Record final energy levels
    for model in loaded_models:
        if model.active and model.id in turn_data.energy_changes:
            turn_data.energy_changes[model.id]["final"] = model.energy_levels.duplicate()
    
    # Record final resource levels
    turn_data.resource_changes["final"] = shared_resources.duplicate()
    
    # Record final cooperation metrics
    turn_data.cooperation_changes["final"] = cooperation_metrics.duplicate()
    
    # Update turn history
    turn_history[turn_idx] = turn_data
    
    print("Turn %d completed" % current_turn)
    
    # Start next turn or complete cycle
    if current_turn >= TOTAL_TURNS_PER_CYCLE:
        complete_cycle()
    else:
        start_new_turn()
    
    return true

func complete_cycle():
    if not cycle_active:
        print("No active cycle to complete")
        return false
    
    # Reset turn counter
    current_turn = 0
    cycle_active = false
    
    # Compile cycle data
    var cycle_data = {
        "turns_completed": min(TOTAL_TURNS_PER_CYCLE, turn_history.size()),
        "cycle_duration": turn_duration * TOTAL_TURNS_PER_CYCLE,
        "model_actions": {},
        "resources_consumed": {},
        "cooperation_score": _calculate_cycle_cooperation_score(),
        "timestamp": OS.get_unix_time()
    }
    
    # Count actions per model
    for turn in turn_history:
        for action in turn.actions:
            if not action.model_id in cycle_data.model_actions:
                cycle_data.model_actions[action.model_id] = 0
            cycle_data.model_actions[action.model_id] += 1
    
    # Apply end-of-cycle effects
    for model in loaded_models:
        if model.active:
            # Restore some energy
            for energy_type in model.energy_levels:
                model.energy_levels[energy_type] += 20.0
                model.energy_levels[energy_type] = min(model.energy_levels[energy_type], 100.0)
    
    # Restore shared resources
    for resource in shared_resources:
        shared_resources[resource] += 30.0
        shared_resources[resource] = min(shared_resources[resource], 100.0)
    
    print("Turn cycle completed")
    emit_signal("cycle_completed", cycle_data)
    
    return true

func _on_turn_timer_timeout():
    if cycle_active:
        current_turn_timer += 1.0
        
        # Check if turn should complete
        if current_turn_timer >= turn_duration:
            complete_turn()

func get_current_turn_info():
    return {
        "turn_number": current_turn,
        "turn_progress": current_turn_timer / turn_duration,
        "remaining_time": max(0, turn_duration - current_turn_timer),
        "cycle_progress": current_turn / float(TOTAL_TURNS_PER_CYCLE),
        "cycle_active": cycle_active
    }

func set_turn_duration(duration):
    if duration <= 0:
        print("Invalid turn duration")
        return false
    
    turn_duration = duration
    print("Turn duration set to %.1f seconds" % turn_duration)
    return true

# Model Management

func load_model(name, type="text", capabilities=[]):
    if loaded_models.size() >= MAX_MODELS:
        print("Maximum number of models already loaded")
        return null
    
    var model = AIModel.new(name, type, capabilities)
    
    # Set up specialization based on type
    match type:
        "text":
            model.specialization = ["generation", "completion", "summarization", "translation"][randi() % 4]
        "image":
            model.specialization = ["generation", "analysis", "recognition", "modification"][randi() % 4]
        "audio":
            model.specialization = ["generation", "transcription", "analysis", "conversion"][randi() % 4]
        "multimodal":
            model.specialization = ["interpretation", "generation", "analysis", "integration"][randi() % 4]
        "agent":
            model.specialization = ["planning", "execution", "learning", "coordination"][randi() % 4]
        "mecha":
            model.specialization = ["combat", "exploration", "utility", "support"][randi() % 4]
        "simulation":
            model.specialization = ["physics", "biology", "economy", "strategy"][randi() % 4]
        "specialist":
            model.specialization = ["medical", "legal", "scientific", "creative"][randi() % 4]
    
    # Set up command set based on type and specialization
    model.command_set = _generate_command_set(model.type, model.specialization)
    
    # Add to loaded models
    loaded_models.append(model.to_dict())
    
    print("Model loaded: %s (%s, %s)" % [name, type, model.specialization])
    
    # If this is the first model, make it active
    if loaded_models.size() == 1:
        activate_model(0)
    
    return model

func _generate_command_set(type, specialization):
    var commands = []
    
    # Add common commands
    commands.append({
        "name": "status",
        "description": "Reports the model's current status",
        "energy_cost": 1.0,
        "parameters": []
    })
    
    commands.append({
        "name": "help",
        "description": "Lists available commands",
        "energy_cost": 1.0,
        "parameters": []
    })
    
    # Add type-specific commands
    match type:
        "text":
            commands.append({
                "name": "generate",
                "description": "Generates text based on prompt",
                "energy_cost": 10.0,
                "parameters": ["prompt", "length", "style"]
            })
            commands.append({
                "name": "analyze",
                "description": "Analyzes provided text",
                "energy_cost": 5.0,
                "parameters": ["text", "depth"]
            })
        
        "image":
            commands.append({
                "name": "create",
                "description": "Creates an image from description",
                "energy_cost": 15.0,
                "parameters": ["description", "style", "resolution"]
            })
            commands.append({
                "name": "modify",
                "description": "Modifies an existing image",
                "energy_cost": 12.0,
                "parameters": ["image_id", "modifications"]
            })
        
        "agent":
            commands.append({
                "name": "plan",
                "description": "Creates a multi-step plan",
                "energy_cost": 8.0,
                "parameters": ["goal", "constraints", "steps"]
            })
            commands.append({
                "name": "execute",
                "description": "Executes a specific action",
                "energy_cost": 10.0,
                "parameters": ["action", "targets", "parameters"]
            })
        
        "mecha":
            commands.append({
                "name": "activate",
                "description": "Activates a mecha interface",
                "energy_cost": 20.0,
                "parameters": ["mecha_id", "mode"]
            })
            commands.append({
                "name": "control",
                "description": "Issues control command to active mecha",
                "energy_cost": 5.0,
                "parameters": ["command", "intensity", "duration"]
            })
    
    # Add specialization-specific commands
    if specialization == "combat":
        commands.append({
            "name": "engage",
            "description": "Initiates combat sequence",
            "energy_cost": 25.0,
            "parameters": ["target", "approach", "intensity"]
        })
    elif specialization == "analysis":
        commands.append({
            "name": "deep_scan",
            "description": "Performs detailed analysis",
            "energy_cost": 15.0,
            "parameters": ["subject", "layers", "focus"]
        })
    elif specialization == "coordination":
        commands.append({
            "name": "synchronize",
            "description": "Coordinates multiple models",
            "energy_cost": 12.0,
            "parameters": ["models", "task", "priorities"]
        })
    
    return commands

func activate_model(index):
    if index < 0 or index >= loaded_models.size():
        print("Invalid model index: %d" % index)
        return false
    
    # Deactivate current model if any
    if active_model_index >= 0 and active_model_index < loaded_models.size():
        loaded_models[active_model_index].active = false
    
    # Activate new model
    loaded_models[index].active = true
    active_model_index = index
    
    var model_data = loaded_models[index]
    
    print("Model activated: %s (%s)" % [model_data.name, model_data.type])
    emit_signal("model_switched", model_data)
    
    return true

func perform_model_action(model_index, action_type, target="", parameters={}):
    if model_index < 0 or model_index >= loaded_models.size():
        print("Invalid model index: %d" % model_index)
        return null
    
    var model = loaded_models[model_index]
    
    # Check if model is active
    if not model.active:
        print("Model not active: %s" % model.name)
        return null
    
    # Create action record
    var action = ModelAction.new(model.id, model.name, action_type)
    action.target = target
    action.parameters = parameters
    action.turn_number = current_turn
    
    # Calculate energy cost
    var base_energy_cost = 5.0
    
    # Different actions have different costs
    match action_type:
        "generate", "create":
            base_energy_cost = 10.0
        "analyze", "process":
            base_energy_cost = 7.0
        "modify", "transform":
            base_energy_cost = 12.0
        "collaborate", "synchronize":
            base_energy_cost = 8.0
            action.cooperation_impact = 0.1  # Positive impact on cooperation
    
    # Scale cost by parameter complexity
    var complexity_multiplier = 1.0 + (parameters.size() * 0.1)
    var total_cost = base_energy_cost * complexity_multiplier
    
    # Distribute cost across energy types
    action.energy_cost = {
        "control": total_cost * 0.2,
        "perception": total_cost * 0.2,
        "action": total_cost * 0.3,
        "reasoning": total_cost * 0.3
    }
    
    # Check if model has enough energy
    var has_enough_energy = true
    for energy_type in action.energy_cost:
        if energy_type in model.energy_levels and model.energy_levels[energy_type] < action.energy_cost[energy_type]:
            print("Not enough %s energy for action" % energy_type)
            has_enough_energy = false
    
    if not has_enough_energy:
        action.success = false
        action.result = {"error": "Insufficient energy for action"}
        return action
    
    # Calculate resource usage
    action.resources_used = {
        "processing": base_energy_cost * 0.5,
        "memory": base_energy_cost * 0.3,
        "data_access": base_energy_cost * 0.2
    }
    
    # Check if enough shared resources
    var has_enough_resources = true
    for resource in action.resources_used:
        if resource in shared_resources and shared_resources[resource] < action.resources_used[resource]:
            print("Not enough shared %s for action" % resource)
            has_enough_resources = false
    
    if not has_enough_resources:
        action.success = false
        action.result = {"error": "Insufficient shared resources for action"}
        return action
    
    # Consume energy
    for energy_type in action.energy_cost:
        if energy_type in model.energy_levels:
            model.energy_levels[energy_type] -= action.energy_cost[energy_type]
    
    # Consume resources
    for resource in action.resources_used:
        if resource in shared_resources:
            shared_resources[resource] -= action.resources_used[resource]
    
    # Process action result
    var result = _process_action_result(action_type, parameters)
    action.result = result
    
    # Record action
    model.last_action_at = OS.get_unix_time()
    
    # Update model data
    loaded_models[model_index] = model
    
    # Record in turn history
    if turn_history.size() > 0:
        var turn_idx = turn_history.size() - 1
        turn_history[turn_idx].actions.append(action.to_dict())
    
    print("Model %s performed action: %s" % [model.name, action_type])
    emit_signal("ai_action_performed", action.to_dict())
    
    return action

func _process_action_result(action_type, parameters):
    # In a real system, this would call the actual AI models
    # Here we simulate results for demonstration
    
    var result = {
        "status": "success",
        "output": "",
        "processing_time": 0.5 + randf() * 2.0  # 0.5-2.5 seconds
    }
    
    match action_type:
        "generate":
            if "prompt" in parameters:
                result.output = "Generated content based on: " + parameters.prompt
            else:
                result.output = "Generated content with default parameters"
        
        "analyze":
            if "target" in parameters:
                result.output = "Analysis of " + parameters.target + " complete"
                result.insights = ["Insight 1", "Insight 2", "Insight 3"]
            else:
                result.output = "Analysis complete"
        
        "create":
            result.output = "Creation process completed"
            result.asset_id = str(OS.get_unix_time()) + "_asset_" + str(randi() % 1000)
        
        "modify":
            if "target" in parameters:
                result.output = "Modified " + parameters.target
                result.changes = parameters.size()
            else:
                result.output = "Modification complete"
        
        "collaborate":
            result.output = "Collaboration sequence complete"
            result.synergy_score = 0.5 + randf() * 0.5  # 0.5-1.0
        
        _:
            result.output = "Action completed"
    
    return result

func get_active_model():
    if active_model_index >= 0 and active_model_index < loaded_models.size():
        return loaded_models[active_model_index]
    return null

func get_model_by_name(name):
    for model in loaded_models:
        if model.name == name:
            return model
    return null

# Terminal Interface

func activate_terminal(mode="command"):
    if not mode in TERMINAL_MODES:
        mode = "command"
    
    terminal_active = true
    current_terminal_mode = mode
    
    print("Terminal activated in %s mode" % mode)
    return true

func deactivate_terminal():
    terminal_active = false
    print("Terminal deactivated")
    return true

func execute_terminal_command(command, parameters=[], source="terminal"):
    if not terminal_active:
        print("Terminal not active")
        return null
    
    # Create command record
    var cmd = TerminalCommand.new(command, parameters, source)
    
    # Base energy cost
    cmd.energy_cost = 2.0
    
    # Process command
    var start_time = OS.get_unix_time()
    var result = _process_terminal_command(command, parameters)
    cmd.execution_time = OS.get_unix_time() - start_time
    cmd.result = result
    
    # Add to history
    command_history.append(cmd.to_dict())
    
    print("Executed terminal command: %s" % command)
    return cmd

func _process_terminal_command(command, parameters):
    var result = {
        "status": "success",
        "output": "",
        "affects_models": false,
        "affects_system": false
    }
    
    # Split command to handle parameters included in the command string
    var parts = command.split(" ")
    var base_command = parts[0].to_lower()
    
    # Add any inline parameters to the parameters array
    if parts.size() > 1:
        for i in range(1, parts.size()):
            parameters.append(parts[i])
    
    match base_command:
        "help":
            result.output = "Available commands:\n"
            result.output += "- help: Display this help message\n"
            result.output += "- status: Show system status\n"
            result.output += "- list models: Show loaded models\n"
            result.output += "- activate [model_index]: Activate a model\n"
            result.output += "- turn [start/complete/info]: Manage turns\n"
            result.output += "- music [play/stop/next]: Control music playback\n"
            result.output += "- mecha [list/activate/control]: Manage mecha interfaces"
        
        "status":
            result.output = "System status:\n"
            result.output += "- Active model: " + (get_active_model().name if get_active_model() else "None") + "\n"
            result.output += "- Loaded models: %d/%d\n" % [loaded_models.size(), MAX_MODELS]
            result.output += "- Turn: %d/%d\n" % [current_turn, TOTAL_TURNS_PER_CYCLE]
            result.output += "- Cycle active: " + ("Yes" if cycle_active else "No") + "\n"
            result.output += "- Terminal mode: " + current_terminal_mode
        
        "list":
            if parameters.size() > 0 and parameters[0] == "models":
                result.output = "Loaded models:\n"
                for i in range(loaded_models.size()):
                    var model = loaded_models[i]
                    result.output += "%d: %s (%s) - %s\n" % [
                        i, model.name, model.type, 
                        "ACTIVE" if model.active else "inactive"
                    ]
            else:
                result.output = "Unknown list command. Try 'list models'"
        
        "activate":
            if parameters.size() > 0:
                var index = int(parameters[0])
                if activate_model(index):
                    result.output = "Activated model: " + loaded_models[index].name
                    result.affects_models = true
                else:
                    result.status = "error"
                    result.output = "Failed to activate model with index " + parameters[0]
            else:
                result.status = "error"
                result.output = "Missing parameter: model index"
        
        "turn":
            if parameters.size() > 0:
                match parameters[0]:
                    "start":
                        var duration = DEFAULT_TURN_DURATION
                        if parameters.size() > 1:
                            duration = float(parameters[1])
                        
                        if start_turn_cycle(duration):
                            result.output = "Started turn cycle with %.1f seconds per turn" % duration
                            result.affects_system = true
                        else:
                            result.status = "error"
                            result.output = "Failed to start turn cycle"
                    
                    "complete":
                        if complete_turn():
                            result.output = "Completed current turn"
                            result.affects_system = true
                        else:
                            result.status = "error"
                            result.output = "Failed to complete turn"
                    
                    "info":
                        var info = get_current_turn_info()
                        result.output = "Turn information:\n"
                        result.output += "- Current turn: %d/%d\n" % [info.turn_number, TOTAL_TURNS_PER_CYCLE]
                        result.output += "- Progress: %.1f%%\n" % (info.turn_progress * 100.0)
                        result.output += "- Remaining time: %.1f seconds\n" % info.remaining_time
                        result.output += "- Cycle progress: %.1f%%\n" % (info.cycle_progress * 100.0)
                        result.output += "- Cycle active: " + ("Yes" if info.cycle_active else "No")
                    
                    _:
                        result.status = "error"
                        result.output = "Unknown turn command: " + parameters[0]
            else:
                result.status = "error"
                result.output = "Missing parameter: turn command"
        
        "music":
            if parameters.size() > 0:
                match parameters[0]:
                    "play":
                        if play_music():
                            result.output = "Music playback started"
                            result.affects_system = true
                        else:
                            result.status = "error"
                            result.output = "Failed to start music playback"
                    
                    "stop":
                        if stop_music():
                            result.output = "Music playback stopped"
                            result.affects_system = true
                        else:
                            result.status = "error"
                            result.output = "Failed to stop music playback"
                    
                    "next":
                        if next_track():
                            result.output = "Switched to next track"
                            result.affects_system = true
                        else:
                            result.status = "error"
                            result.output = "Failed to switch tracks"
                    
                    _:
                        result.status = "error"
                        result.output = "Unknown music command: " + parameters[0]
            else:
                result.status = "error"
                result.output = "Missing parameter: music command"
        
        "mecha":
            if parameters.size() > 0:
                match parameters[0]:
                    "list":
                        result.output = "Available mecha interfaces:\n"
                        for i in range(mecha_interfaces.size()):
                            var mecha = mecha_interfaces[i]
                            result.output += "%d: %s - %s\n" % [
                                i, mecha.name, mecha.status
                            ]
                    
                    "activate":
                        if parameters.size() > 1:
                            var index = int(parameters[1])
                            if activate_mecha_interface(index):
                                result.output = "Activated mecha interface: " + mecha_interfaces[index].name
                                result.affects_system = true
                            else:
                                result.status = "error"
                                result.output = "Failed to activate mecha interface"
                        else:
                            result.status = "error"
                            result.output = "Missing parameter: mecha index"
                    
                    "control":
                        if parameters.size() > 1:
                            if control_active_mecha(parameters[1], parameters.slice(2, parameters.size() - 1)):
                                result.output = "Control command sent to active mecha"
                                result.affects_system = true
                            else:
                                result.status = "error"
                                result.output = "Failed to control mecha"
                        else:
                            result.status = "error"
                            result.output = "Missing parameter: control command"
                    
                    _:
                        result.status = "error"
                        result.output = "Unknown mecha command: " + parameters[0]
            else:
                result.status = "error"
                result.output = "Missing parameter: mecha command"
        
        _:
            result.status = "error"
            result.output = "Unknown command: " + command
    
    return result

# Audio Playback System

func add_audio_track(title, path, tags=[]):
    var track = AudioTrack.new(title, path)
    track.tags = tags
    
    # Set energy influence randomly
    for energy_type in ["creativity", "perception", "action"]:
        track.energy_influence[energy_type] = (randf() * 2.0 - 1.0) * 10.0  # -10 to +10
    
    audio_playlist.append(track.to_dict())
    print("Added audio track: %s" % title)
    return track

func play_music():
    if audio_playlist.empty():
        print("Audio playlist is empty")
        return false
    
    # If no current track, start with the first one
    if current_audio_track < 0 or current_audio_track >= audio_playlist.size():
        current_audio_track = 0
    
    audio_playing = true
    
    var track = audio_playlist[current_audio_track]
    track.play_count += 1
    track.last_played = OS.get_unix_time()
    
    print("Playing audio track: %s" % track.title)
    emit_signal("audio_state_changed", {
        "playing": true,
        "track": track,
        "track_index": current_audio_track,
        "playlist_size": audio_playlist.size()
    })
    
    # Apply energy influence to active model
    var active_model = get_active_model()
    if active_model and "energy_influence" in track:
        for energy_type in track.energy_influence:
            if energy_type in active_model.energy_levels:
                active_model.energy_levels[energy_type] += track.energy_influence[energy_type]
                active_model.energy_levels[energy_type] = clamp(
                    active_model.energy_levels[energy_type], 0.0, 100.0
                )
    
    return true

func stop_music():
    if not audio_playing:
        return false
    
    audio_playing = false
    
    emit_signal("audio_state_changed", {
        "playing": false,
        "track_index": current_audio_track,
        "playlist_size": audio_playlist.size()
    })
    
    print("Stopped audio playback")
    return true

func next_track():
    if audio_playlist.empty():
        print("Audio playlist is empty")
        return false
    
    # Move to next track
    current_audio_track = (current_audio_track + 1) % audio_playlist.size()
    
    # If music is playing, start the new track
    if audio_playing:
        return play_music()
    
    return true

func get_current_track():
    if current_audio_track >= 0 and current_audio_track < audio_playlist.size():
        return audio_playlist[current_audio_track]
    return null

# Mecha Interface System

func _create_default_mecha_interfaces():
    # Create some default mecha interfaces
    var mecha_types = [
        {"name": "Combat Mecha", "capabilities": ["combat", "defense", "mobility"]},
        {"name": "Utility Mecha", "capabilities": ["construction", "repair", "scanning"]},
        {"name": "Scout Mecha", "capabilities": ["reconnaissance", "stealth", "agility"]}
    ]
    
    for type in mecha_types:
        var mecha = MechaInterface.new(type.name)
        mecha.capabilities = type.capabilities
        
        # Generate control scheme
        mecha.control_scheme = {
            "primary": ["move", "activate", "target"],
            "secondary": ["special", "defend", "communicate"],
            "tertiary": ["analyze", "scan", "report"]
        }
        
        # Set energy consumption
        for energy_type in ENERGY_TYPES:
            mecha.energy_consumption[energy_type] = 5.0 + randf() * 10.0  # 5-15 per energy type
        
        # Generate modules
        var module_count = 2 + randi() % 3  # 2-4 modules
        for i in range(module_count):
            var module = {
                "id": "module_" + str(i),
                "name": ["Sensor", "Weapon", "Shield", "Thruster", "Computer"][randi() % 5] + " Module",
                "status": "operational",
                "energy_use": 10.0 + randf() * 20.0  # 10-30 energy use
            }
            mecha.modules.append(module)
        
        mecha_interfaces.append(mecha.to_dict())
    
    return mecha_interfaces.size()

func activate_mecha_interface(index):
    if index < 0 or index >= mecha_interfaces.size():
        print("Invalid mecha interface index: %d" % index)
        return false
    
    # Deactivate current mecha if any
    if active_mecha >= 0:
        mecha_interfaces[active_mecha].status = "standby"
    
    # Activate new mecha
    mecha_interfaces[index].status = "active"
    mecha_interfaces[index].activation_time = OS.get_unix_time()
    active_mecha = index
    
    # Check if linked to a model
    if not mecha_interfaces[index].model_id.empty():
        # Find model
        for i in range(loaded_models.size()):
            if loaded_models[i].id == mecha_interfaces[index].model_id:
                # Activate the model
                activate_model(i)
                break
    
    var mecha_data = mecha_interfaces[index]
    
    print("Mecha interface activated: %s" % mecha_data.name)
    emit_signal("mecha_interface_updated", {
        "type": "activation",
        "mecha": mecha_data,
        "mecha_index": index
    })
    
    return true

func control_active_mecha(command, parameters=[]):
    if active_mecha < 0 or active_mecha >= mecha_interfaces.size():
        print("No active mecha interface")
        return false
    
    var mecha = mecha_interfaces[active_mecha]
    
    # Verify mecha is active
    if mecha.status != "active":
        print("Mecha interface not active: %s" % mecha.name)
        return false
    
    # Process command
    var control_data = {
        "command": command,
        "parameters": parameters,
        "timestamp": OS.get_unix_time(),
        "success": true,
        "energy_used": {},
        "result": {}
    }
    
    # Determine energy cost based on command
    var base_energy = 10.0
    
    match command:
        "move":
            base_energy = 15.0
            control_data.result = {"movement": "completed", "distance": 10 + randi() % 20}
        "attack":
            base_energy = 25.0
            control_data.result = {"attack": "executed", "damage": 15 + randi() % 30}
        "defend":
            base_energy = 20.0
            control_data.result = {"defense": "activated", "duration": 5 + randi() % 10}
        "scan":
            base_energy = 15.0
            control_data.result = {"scan": "completed", "targets": 1 + randi() % 5}
        _:
            control_data.result = {"command": "executed"}
    
    # Apply energy cost
    for energy_type in mecha.energy_consumption:
        var energy_cost = base_energy * (mecha.energy_consumption[energy_type] / 10.0)
        control_data.energy_used[energy_type] = energy_cost
        
        # Consume from active model if linked
        var active_model = get_active_model()
        if active_model and energy_type in active_model.energy_levels:
            if active_model.energy_levels[energy_type] < energy_cost:
                control_data.success = false
                control_data.result = {"error": "Insufficient " + energy_type + " energy"}
                return false
            
            active_model.energy_levels[energy_type] -= energy_cost
    
    print("Mecha interface controlled: %s - %s" % [mecha.name, command])
    emit_signal("mecha_interface_updated", {
        "type": "control",
        "mecha": mecha,
        "mecha_index": active_mecha,
        "control_data": control_data
    })
    
    return true

func get_active_mecha():
    if active_mecha >= 0 and active_mecha < mecha_interfaces.size():
        return mecha_interfaces[active_mecha]
    return null

# Cooperation System

func _calculate_cycle_cooperation_score():
    var total_score = 0.0
    
    for metric in cooperation_metrics:
        total_score += cooperation_metrics[metric]
    
    return total_score / cooperation_metrics.size()

func update_cooperation_metric(metric, change):
    if not metric in cooperation_metrics:
        print("Unknown cooperation metric: %s" % metric)
        return false
    
    cooperation_metrics[metric] += change
    cooperation_metrics[metric] = clamp(cooperation_metrics[metric], 0.0, 2.0)
    
    print("Updated cooperation metric %s: %.2f" % [metric, cooperation_metrics[metric]])
    return true

# System Integration

func initialize_with_magic_system(magic_system_node):
    if not magic_system_node:
        print("Cannot initialize: Invalid Magic Item System")
        return false
    
    magic_item_system = magic_system_node
    
    print("Connected to Magic Item System")
    return true

func initialize_with_spell_system(spell_system_node):
    if not spell_system_node:
        print("Cannot initialize: Invalid Spell Casting System")
        return false
    
    spell_system = spell_system_node
    
    print("Connected to Spell Casting System")
    return true

func initialize_with_game_creator(game_creator_node):
    if not game_creator_node:
        print("Cannot initialize: Invalid AI Game Creator")
        return false
    
    game_creator = game_creator_node
    
    print("Connected to AI Game Creator")
    return true

func initialize_with_api_manager(api_manager_node):
    if not api_manager_node:
        print("Cannot initialize: Invalid API Manager")
        return false
    
    api_manager = api_manager_node
    
    print("Connected to API Manager")
    return true

# Data Persistence

func save_system_state():
    var file = File.new()
    var data = {
        "current_turn": current_turn,
        "turn_duration": turn_duration,
        "cycle_active": cycle_active,
        "terminal_active": terminal_active,
        "current_terminal_mode": current_terminal_mode,
        "loaded_models": loaded_models,
        "active_model_index": active_model_index,
        "turn_history": turn_history.slice(max(0, turn_history.size() - 20), turn_history.size() - 1),
        "command_history": command_history.slice(max(0, command_history.size() - 20), command_history.size() - 1),
        "audio_playlist": audio_playlist,
        "current_audio_track": current_audio_track,
        "audio_playing": audio_playing,
        "mecha_interfaces": mecha_interfaces,
        "active_mecha": active_mecha,
        "shared_resources": shared_resources,
        "cooperation_metrics": cooperation_metrics,
        "timestamp": OS.get_unix_time()
    }
    
    var error = file.open("user://ai_model_manager_data.json", File.WRITE)
    if error != OK:
        print("Error saving system state: %s" % error)
        return false
    
    file.store_string(JSON.print(data, "  "))
    file.close()
    print("AI Model Manager state saved")
    return true

func load_system_state():
    var file = File.new()
    if not file.file_exists("user://ai_model_manager_data.json"):
        print("No previous system state found")
        return false
    
    var error = file.open("user://ai_model_manager_data.json", File.READ)
    if error != OK:
        print("Error loading system state: %s" % error)
        return false
    
    var json_string = file.get_as_text()
    file.close()
    
    var json_result = JSON.parse(json_string)
    if json_result.error != OK:
        print("Error parsing system state: %s at line %s" % [json_result.error, json_result.error_line])
        return false
    
    var data = json_result.result
    
    # Load data
    current_turn = data.get("current_turn", 0)
    turn_duration = data.get("turn_duration", DEFAULT_TURN_DURATION)
    cycle_active = data.get("cycle_active", false)
    terminal_active = data.get("terminal_active", false)
    current_terminal_mode = data.get("current_terminal_mode", "command")
    loaded_models = data.get("loaded_models", [])
    active_model_index = data.get("active_model_index", -1)
    turn_history = data.get("turn_history", [])
    command_history = data.get("command_history", [])
    audio_playlist = data.get("audio_playlist", [])
    current_audio_track = data.get("current_audio_track", -1)
    audio_playing = data.get("audio_playing", false)
    mecha_interfaces = data.get("mecha_interfaces", [])
    active_mecha = data.get("active_mecha", -1)
    shared_resources = data.get("shared_resources", shared_resources)
    cooperation_metrics = data.get("cooperation_metrics", cooperation_metrics)
    
    print("AI Model Manager state loaded")
    return true

# Helper Functions

func _create_default_models():
    # Create some default models
    load_model("TextGen", "text", ["generation", "completion", "analysis"])
    load_model("ImageVision", "image", ["generation", "analysis"])
    load_model("AgentPlanner", "agent", ["planning", "execution", "coordination"])
    load_model("MechController", "mecha", ["activation", "control", "monitoring"])
    
    return loaded_models.size()

# Demo Functions

func run_demo_cycle():
    # Create models if none exist
    if loaded_models.empty():
        _create_default_models()
    
    # Create mecha interfaces if none exist
    if mecha_interfaces.empty():
        _create_default_mecha_interfaces()
    
    # Make sure we have a model active
    if active_model_index < 0:
        activate_model(0)
    
    # Activate terminal
    activate_terminal()
    
    # Start a turn cycle
    start_turn_cycle(30.0)  # 30 seconds per turn
    
    # Perform an action with the active model
    perform_model_action(
        active_model_index,
        "generate",
        "",
        {"prompt": "Sample generation prompt", "length": 100}
    )
    
    # Execute a terminal command
    execute_terminal_command("status")
    
    # Activate a mecha interface
    if mecha_interfaces.size() > 0:
        activate_mecha_interface(0)
        control_active_mecha("scan", ["area", "detailed"])
    
    # Save state
    save_system_state()
    
    print("Demo cycle complete")
    return true