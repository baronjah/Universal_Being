extends Node

class_name SpatialLinguisticConnector

# Spatial-Linguistic Integration System
# Connects linguistic elements (words, wishes, commands) with spatial representations
# through a turn-based goal progression system

# ----- CONSTANTS -----
const MAX_TURNS = 12
const MAX_DIMENSIONS = 9
const SPACE_TYPES = ["Zone", "Layer", "Map", "Field", "Matrix", "Dimension", "Universe"]
const SHAPE_TYPES = ["Sphere", "Cube", "Rectangle", "Pyramid", "Cylinder", "Torus", "Fractal"]
const DIRECTION_TYPES = ["Horizontal", "Vertical", "Diagonal", "Spiral", "Radial", "Orthogonal", "Tessellated"]
const BOUNDARY_TYPES = ["Inside", "Outside", "Border", "Threshold", "Membrane", "Junction", "Portal"]
const POSITION_TYPES = ["Top", "Bottom", "Left", "Right", "Center", "Header", "Footer", "Home"]

# ----- INTEGRATION SYSTEMS -----
var terminal_bridge = null
var claude_bridge = null
var akashic_system = null
var ethereal_engine = null
var turn_system = null
var word_processor = null
var wish_system = null

# ----- DATA STRUCTURES -----
var linguistic_maps = {}
var spatial_structures = {}
var connection_pipes = {}
var shape_transformations = {}
var goal_progression = {}
var turn_states = {}

# ----- PROCESSORS -----
var wish_parser = null
var data_splitter = null
var merger = null
var connector = null
var translator = null

# ----- SIGNALS -----
signal linguistic_mapped(word, space_type, coordinates)
signal spatial_structured(space_id, shape_type, boundaries)
signal connection_established(source_id, target_id, pipe_type)
signal wish_translated(wish_id, spatial_representation)
signal goal_advanced(turn, goal_id, progress_percentage)
signal shape_transformed(shape_id, from_type, to_type)

# ----- INITIALIZATION -----
func _ready():
    print("Initializing Spatial-Linguistic Connector...")
    
    # Connect to required systems
    _connect_systems()
    
    # Initialize processors
    _initialize_processors()
    
    # Set up initial turn state
    _initialize_turn_state()
    
    # Create default spatial structures
    _create_default_structures()
    
    print("Spatial-Linguistic Connector initialized")

func _connect_systems():
    # Find and connect to the terminal bridge
    terminal_bridge = get_node_or_null("/root/TerminalAPIBridge")
    
    # Find and connect to Claude bridge
    claude_bridge = get_node_or_null("/root/ClaudeAkashicBridge") 
    if not claude_bridge:
        claude_bridge = get_node_or_null("/root/ClaudeEtherealBridge")
    
    # Find and connect to akashic system
    akashic_system = get_node_or_null("/root/AkashicNumberSystem")
    
    # Find and connect to ethereal engine
    ethereal_engine = get_node_or_null("/root/EtherealEngine")
    
    # Find and connect to turn system
    turn_system = get_node_or_null("/root/TurnSystem")
    if turn_system:
        turn_system.connect("turn_advanced", self, "_on_turn_advanced")
    
    # Find and connect to word processor
    word_processor = get_node_or_null("/root/DivineWordProcessor")
    
    # Find and connect to wish system
    wish_system = get_node_or_null("/root/IntegratedMemorySystem")

func _initialize_processors():
    # Create wish parser instance
    wish_parser = WishParser.new()
    add_child(wish_parser)
    wish_parser.connect("wish_parsed", self, "_on_wish_parsed")
    
    # Create data splitter instance
    data_splitter = DataSplitter.new()
    add_child(data_splitter)
    data_splitter.connect("data_split", self, "_on_data_split")
    
    # Create merger instance
    merger = WishMerger.new()
    add_child(merger)
    merger.connect("wishes_merged", self, "_on_wishes_merged")
    
    # Create connector instance
    connector = PipeConnector.new()
    add_child(connector)
    connector.connect("pipe_connected", self, "_on_pipe_connected")
    
    # Create translator instance
    translator = SpatialTranslator.new()
    add_child(translator)
    translator.connect("translation_completed", self, "_on_translation_completed")

func _initialize_turn_state():
    # Get current turn from turn system if available
    var current_turn = 1
    if turn_system:
        current_turn = turn_system.get_current_turn()
    
    # Initialize goal state for current turn
    turn_states[current_turn] = {
        "active_goals": [],
        "completed_goals": [],
        "spatial_focus": "Zone",
        "linguistic_focus": "Command",
        "current_shape": "Sphere",
        "inner_boundary": "Inside",
        "outer_boundary": "Outside",
        "primary_direction": "Horizontal",
        "secondary_direction": "Vertical"
    }
    
    # Create initial goal if none exists
    if goal_progression.empty():
        _create_default_goal()

func _create_default_structures():
    # Create default zone structure
    var zone_id = _create_spatial_structure("Zone", "Sphere", {
        "center": Vector3(0, 0, 0),
        "radius": 5.0,
        "inner_boundary": "Inside",
        "outer_boundary": "Outside"
    })
    
    # Create default layer structure
    var layer_id = _create_spatial_structure("Layer", "Rectangle", {
        "position": Vector3(0, 1, 0),
        "dimensions": Vector2(10, 10),
        "primary_direction": "Horizontal",
        "secondary_direction": "Vertical"
    })
    
    # Create default map structure
    var map_id = _create_spatial_structure("Map", "Matrix", {
        "position": Vector3(0, 2, 0),
        "dimensions": Vector3(10, 1, 10),
        "cells": [],
        "directions": ["Top", "Bottom", "Left", "Right", "Center"]
    })
    
    # Connect default structures with pipes
    _connect_structures(zone_id, layer_id, "vertical")
    _connect_structures(layer_id, map_id, "vertical")
    
    # Map some default linguistic elements
    _map_linguistic_element("goal", "Zone", Vector3(0, 0, 0))
    _map_linguistic_element("wish", "Layer", Vector3(0, 1, 0))
    _map_linguistic_element("command", "Map", Vector3(0, 2, 0))

# ----- STRUCTURE MANAGEMENT -----
func _create_spatial_structure(space_type, shape_type, parameters):
    # Generate a unique ID for the structure
    var structure_id = space_type.to_lower() + "_" + str(spatial_structures.size() + 1)
    
    # Create structure with parameters
    spatial_structures[structure_id] = {
        "space_type": space_type,
        "shape_type": shape_type,
        "parameters": parameters,
        "connections": [],
        "linguistic_elements": [],
        "creation_time": OS.get_unix_time()
    }
    
    # Emit signal about new structure
    emit_signal("spatial_structured", structure_id, shape_type, parameters)
    
    return structure_id

func _connect_structures(source_id, target_id, connection_type):
    if not spatial_structures.has(source_id) or not spatial_structures.has(target_id):
        push_error("Cannot connect structures: Invalid structure ID")
        return null
    
    # Generate unique ID for connection
    var pipe_id = "pipe_" + source_id + "_to_" + target_id
    
    # Create connection pipe
    connection_pipes[pipe_id] = {
        "source_id": source_id,
        "target_id": target_id,
        "type": connection_type,
        "flow_direction": "bidirectional",
        "active": true,
        "creation_time": OS.get_unix_time()
    }
    
    # Add connection to structures
    spatial_structures[source_id].connections.append(pipe_id)
    spatial_structures[target_id].connections.append(pipe_id)
    
    # Emit signal about new connection
    emit_signal("connection_established", source_id, target_id, connection_type)
    
    return pipe_id

func _map_linguistic_element(word, space_type, coordinates):
    # Generate unique ID for mapping
    var map_id = "map_" + word + "_" + space_type.to_lower()
    
    # Create linguistic mapping
    linguistic_maps[map_id] = {
        "word": word,
        "space_type": space_type,
        "coordinates": coordinates,
        "connections": [],
        "parameters": {},
        "creation_time": OS.get_unix_time()
    }
    
    # Find appropriate spatial structure and add reference
    for structure_id in spatial_structures:
        var structure = spatial_structures[structure_id]
        if structure.space_type == space_type:
            structure.linguistic_elements.append(map_id)
            linguistic_maps[map_id].parameters["structure_id"] = structure_id
            break
    
    # Emit signal about new mapping
    emit_signal("linguistic_mapped", word, space_type, coordinates)
    
    return map_id

func _create_default_goal():
    # Create a default goal structure
    var goal_id = "goal_1"
    
    goal_progression[goal_id] = {
        "name": "Connect Linguistic and Spatial Elements",
        "description": "Create a complete integration between words and spatial structures",
        "total_turns": MAX_TURNS,
        "current_turn": 1,
        "progress": 0.0,
        "steps": [
            {
                "turn": 1,
                "name": "Create Zones",
                "completed": false
            },
            {
                "turn": 2,
                "name": "Map Linguistic Elements",
                "completed": false
            },
            {
                "turn": 3,
                "name": "Connect Zones with Pipes",
                "completed": false
            },
            {
                "turn": 4,
                "name": "Transform Basic Shapes",
                "completed": false
            },
            {
                "turn": 5,
                "name": "Establish Wish Parser",
                "completed": false
            },
            {
                "turn": 6,
                "name": "Create Data Splitters",
                "completed": false
            },
            {
                "turn": 7,
                "name": "Implement Merger System",
                "completed": false
            },
            {
                "turn": 8,
                "name": "Define Boundaries",
                "completed": false
            },
            {
                "turn": 9,
                "name": "Set Directions",
                "completed": false
            },
            {
                "turn": 10,
                "name": "Complete Position Mapping",
                "completed": false
            },
            {
                "turn": 11,
                "name": "Integrate Full System",
                "completed": false
            },
            {
                "turn": 12,
                "name": "Achieve Full Automation",
                "completed": false
            }
        ]
    }
    
    # Add active goal to current turn state
    var current_turn = 1
    if turn_system:
        current_turn = turn_system.get_current_turn()
    
    if turn_states.has(current_turn):
        turn_states[current_turn].active_goals.append(goal_id)
    
    return goal_id

# ----- WISH PROCESSING -----
func process_wish(wish_text, source="manual"):
    # Parse the wish using the wish parser
    var parsed_wish = wish_parser.parse_wish(wish_text)
    
    # Split parsed wish data
    var split_data = data_splitter.split_data(parsed_wish)
    
    # Translate to spatial representation
    var spatial_wish = translator.translate_to_spatial(split_data)
    
    # Generate unique wish ID
    var wish_id = "wish_" + str(OS.get_unix_time())
    
    # Store the wish in the appropriate system
    if wish_system:
        wish_system.add_wish(wish_text, 5, ["spatial_linguistic", "source:" + source])
    
    # Map the wish spatially
    _map_wish_spatially(wish_id, spatial_wish)
    
    return wish_id

func merge_wishes(wish_ids):
    if wish_ids.size() < 2:
        push_error("Cannot merge wishes: Need at least 2 wishes")
        return null
    
    # Get wishes from system
    var wishes = []
    
    for wish_id in wish_ids:
        if wish_system:
            var wish = wish_system.get_wish(wish_id)
            if wish:
                wishes.append(wish)
    
    # Merge wishes using merger
    var merged_wish = merger.merge_wishes(wishes)
    
    # Generate new wish ID
    var merged_id = "merged_" + str(OS.get_unix_time())
    
    # Store merged wish
    if wish_system:
        wish_system.add_wish(merged_wish.text, 8, ["merged", "spatial_linguistic"])
    
    # Map merged wish spatially
    _map_wish_spatially(merged_id, translator.translate_to_spatial(merged_wish))
    
    return merged_id

func _map_wish_spatially(wish_id, spatial_data):
    # Find appropriate spatial structure for the wish
    var target_space_type = "Layer" # Default to Layer
    
    # Create a new spatial structure for this wish if needed
    var structure_id = _create_spatial_structure(target_space_type, spatial_data.shape_type, {
        "position": spatial_data.position,
        "dimensions": spatial_data.dimensions,
        "primary_direction": spatial_data.primary_direction,
        "secondary_direction": spatial_data.secondary_direction
    })
    
    # Map the wish to this structure
    var map_id = _map_linguistic_element(wish_id, target_space_type, spatial_data.position)
    
    # Connect this wish to related structures
    for related_id in spatial_data.related_elements:
        if spatial_structures.has(related_id):
            _connect_structures(structure_id, related_id, "wish_connection")
    
    return map_id

# ----- COMMAND TRANSLATION -----
func translate_command(command_text):
    # Parse the command text
    var command_parts = command_text.split(" ", false)
    
    # Look for spatial and directional keywords
    var spatial_keywords = []
    var directional_keywords = []
    var position_keywords = []
    var shape_keywords = []
    
    for part in command_parts:
        part = part.to_lower()
        
        # Check for space types
        for space_type in SPACE_TYPES:
            if part == space_type.to_lower():
                spatial_keywords.append(space_type)
        
        # Check for direction types
        for direction in DIRECTION_TYPES:
            if part == direction.to_lower():
                directional_keywords.append(direction)
        
        # Check for position types
        for position in POSITION_TYPES:
            if part == position.to_lower():
                position_keywords.append(position)
        
        # Check for shape types
        for shape in SHAPE_TYPES:
            if part == shape.to_lower():
                shape_keywords.append(shape)
    
    # Create translation
    var translation = {
        "original_command": command_text,
        "spatial_elements": spatial_keywords,
        "directions": directional_keywords,
        "positions": position_keywords,
        "shapes": shape_keywords,
        "action": command_parts[0] if command_parts.size() > 0 else "",
        "translations": []
    }
    
    # Perform translations for each identified element
    for space in spatial_keywords:
        var translated = _translate_space_command(space, translation)
        translation.translations.append(translated)
    
    return translation

func _translate_space_command(space_type, translation):
    # Find all structures of this space type
    var matching_structures = []
    
    for structure_id in spatial_structures:
        var structure = spatial_structures[structure_id]
        if structure.space_type == space_type:
            matching_structures.append(structure_id)
    
    # Create shaped commands for this space
    var result = {
        "space_type": space_type,
        "matching_structures": matching_structures,
        "command_shapes": []
    }
    
    # Apply shape transformations if specified
    if not translation.shapes.empty():
        var target_shape = translation.shapes[0]
        
        for structure_id in matching_structures:
            var from_shape = spatial_structures[structure_id].shape_type
            var transform_id = _transform_shape(structure_id, from_shape, target_shape)
            
            result.command_shapes.append({
                "structure_id": structure_id,
                "from_shape": from_shape,
                "to_shape": target_shape,
                "transform_id": transform_id
            })
    
    # Apply directional transformations if specified
    if not translation.directions.empty():
        var primary_direction = translation.directions[0]
        var secondary_direction = translation.directions[1] if translation.directions.size() > 1 else "None"
        
        for structure_id in matching_structures:
            spatial_structures[structure_id].parameters.primary_direction = primary_direction
            if secondary_direction != "None":
                spatial_structures[structure_id].parameters.secondary_direction = secondary_direction
    
    # Apply positional transformations if specified
    if not translation.positions.empty():
        var target_position = translation.positions[0]
        
        # Here we would implement position-specific logic
        result.target_position = target_position
    
    return result

func _transform_shape(structure_id, from_shape, to_shape):
    if not spatial_structures.has(structure_id):
        push_error("Cannot transform shape: Invalid structure ID")
        return null
    
    # Create transform ID
    var transform_id = "transform_" + structure_id + "_" + from_shape + "_to_" + to_shape
    
    # Store transformation
    shape_transformations[transform_id] = {
        "structure_id": structure_id,
        "from_shape": from_shape,
        "to_shape": to_shape,
        "parameters": spatial_structures[structure_id].parameters.duplicate(),
        "timestamp": OS.get_unix_time()
    }
    
    # Update structure shape
    spatial_structures[structure_id].shape_type = to_shape
    
    # Emit signal
    emit_signal("shape_transformed", structure_id, from_shape, to_shape)
    
    return transform_id

# ----- TURN MANAGEMENT -----
func _on_turn_advanced(old_turn, new_turn):
    # Copy previous turn state to new turn if it doesn't exist
    if not turn_states.has(new_turn):
        turn_states[new_turn] = turn_states[old_turn].duplicate(true)
        turn_states[new_turn].active_goals = []
        turn_states[new_turn].completed_goals = []
    
    # Update goals for new turn
    _update_goal_progression(old_turn, new_turn)
    
    # Update spatial focus based on turn
    _update_spatial_focus(new_turn)
    
    print("Spatial-Linguistic Connector advanced to turn " + str(new_turn))

func _update_goal_progression(old_turn, new_turn):
    # Process old turn goals
    if turn_states.has(old_turn):
        for goal_id in turn_states[old_turn].active_goals:
            if goal_progression.has(goal_id):
                var goal = goal_progression[goal_id]
                
                # Check if this goal has a step for the old turn
                for step in goal.steps:
                    if step.turn == old_turn:
                        # Mark step as completed
                        step.completed = true
                
                # Calculate new progress
                var completed_steps = 0
                for step in goal.steps:
                    if step.completed:
                        completed_steps += 1
                
                goal.progress = float(completed_steps) / goal.steps.size()
                goal.current_turn = new_turn
                
                # Check if goal is now complete
                if completed_steps == goal.steps.size():
                    turn_states[old_turn].completed_goals.append(goal_id)
                else:
                    # Transfer to new turn's active goals
                    if turn_states.has(new_turn):
                        turn_states[new_turn].active_goals.append(goal_id)
                
                # Emit goal advancement signal
                emit_signal("goal_advanced", new_turn, goal_id, goal.progress * 100)

func _update_spatial_focus(turn):
    # Update spatial focus based on turn number
    if turn_states.has(turn):
        var turn_state = turn_states[turn]
        
        # Cycle through space types based on turn
        turn_state.spatial_focus = SPACE_TYPES[(turn - 1) % SPACE_TYPES.size()]
        
        # Cycle through shape types based on turn
        turn_state.current_shape = SHAPE_TYPES[(turn - 1) % SHAPE_TYPES.size()]
        
        # Update directional focus based on turn
        turn_state.primary_direction = DIRECTION_TYPES[(turn - 1) % DIRECTION_TYPES.size()]
        
        # Update boundary focus based on turn
        var boundary_index = (turn - 1) % BOUNDARY_TYPES.size()
        turn_state.inner_boundary = BOUNDARY_TYPES[boundary_index]
        turn_state.outer_boundary = BOUNDARY_TYPES[(boundary_index + 2) % BOUNDARY_TYPES.size()]
    
# ----- INNER CLASSES -----
class WishParser:
    signal wish_parsed(wish_data)
    
    func parse_wish(wish_text):
        # Parse wish text and extract components
        var parts = wish_text.split(" ")
        var subjects = []
        var actions = []
        var modifiers = []
        
        # Simple parsing based on word position and common patterns
        for i in range(parts.size()):
            var word = parts[i]
            
            # First word is often an action
            if i == 0:
                actions.append(word)
            # Last word is often a subject
            elif i == parts.size() - 1:
                subjects.append(word)
            # Words like "with", "using", "by" often introduce modifiers
            elif word in ["with", "using", "by", "through"] and i < parts.size() - 1:
                modifiers.append(parts[i+1])
        
        # Create structured wish data
        var wish_data = {
            "original_text": wish_text,
            "subjects": subjects,
            "actions": actions,
            "modifiers": modifiers,
            "timestamp": OS.get_unix_time()
        }
        
        emit_signal("wish_parsed", wish_data)
        return wish_data

class DataSplitter:
    signal data_split(split_data)
    
    func split_data(data):
        # Split data into components based on type
        var result = {
            "original_data": data,
            "components": {},
            "timestamp": OS.get_unix_time()
        }
        
        # Process different data types differently
        match typeof(data):
            TYPE_DICTIONARY:
                # Split dictionary into components
                for key in data:
                    result.components[key] = data[key]
            TYPE_ARRAY:
                # Split array into indexed components
                for i in range(data.size()):
                    result.components["element_" + str(i)] = data[i]
            TYPE_STRING:
                # Split string into words
                var words = data.split(" ")
                result.components["words"] = words
        
        emit_signal("data_split", result)
        return result

class WishMerger:
    signal wishes_merged(merged_wish)
    
    func merge_wishes(wishes):
        # Merge multiple wishes into a combined wish
        var merged_text = ""
        var subjects = []
        var actions = []
        var modifiers = []
        
        for wish in wishes:
            if typeof(wish) == TYPE_DICTIONARY:
                # Extract components to merge
                if wish.has("original_text"):
                    if merged_text.empty():
                        merged_text = wish.original_text
                    else:
                        merged_text += " and " + wish.original_text
                
                if wish.has("subjects"):
                    subjects.append_array(wish.subjects)
                
                if wish.has("actions"):
                    actions.append_array(wish.actions)
                
                if wish.has("modifiers"):
                    modifiers.append_array(wish.modifiers)
        
        # Create merged wish data
        var merged_wish = {
            "text": merged_text,
            "subjects": subjects,
            "actions": actions,
            "modifiers": modifiers,
            "merged": true,
            "source_count": wishes.size(),
            "timestamp": OS.get_unix_time()
        }
        
        emit_signal("wishes_merged", merged_wish)
        return merged_wish

class PipeConnector:
    signal pipe_connected(pipe_data)
    
    func connect_pipe(source, target, pipe_type="default"):
        # Create a pipe connection between source and target
        var pipe_data = {
            "source": source,
            "target": target,
            "type": pipe_type,
            "status": "created",
            "flow_enabled": true,
            "timestamp": OS.get_unix_time()
        }
        
        emit_signal("pipe_connected", pipe_data)
        return pipe_data

class SpatialTranslator:
    signal translation_completed(translation)
    
    func translate_to_spatial(data):
        # Convert data to spatial representation
        var result = {
            "position": Vector3(0, 0, 0),
            "dimensions": Vector3(1, 1, 1),
            "shape_type": "Sphere",
            "primary_direction": "Horizontal",
            "secondary_direction": "Vertical",
            "related_elements": [],
            "timestamp": OS.get_unix_time()
        }
        
        # Extract components for translation
        if typeof(data) == TYPE_DICTIONARY and data.has("components"):
            var components = data.components
            
            # Look for shape indicators
            for component in components:
                var value = components[component]
                
                # Check for shape words
                if typeof(value) == TYPE_STRING:
                    if value.to_lower() in ["sphere", "cube", "rectangle", "pyramid", "cylinder", "torus"]:
                        result.shape_type = value.capitalize()
                
                # Check for direction words
                if typeof(value) == TYPE_STRING:
                    if value.to_lower() in ["horizontal", "vertical", "diagonal", "spiral"]:
                        result.primary_direction = value.capitalize()
                
                # Check for position words
                if typeof(value) == TYPE_STRING:
                    if value.to_lower() in ["top", "bottom", "left", "right", "center"]:
                        # Use position to influence the spatial position
                        match value.to_lower():
                            "top":
                                result.position.y = 5
                            "bottom":
                                result.position.y = -5
                            "left":
                                result.position.x = -5
                            "right":
                                result.position.x = 5
                            "center":
                                result.position = Vector3(0, 0, 0)
            
            # Generate dimensions based on complexity of data
            if typeof(components) == TYPE_DICTIONARY:
                var complexity = components.size()
                result.dimensions = Vector3(complexity, complexity, complexity)
        
        emit_signal("translation_completed", result)
        return result

# ----- PUBLIC API -----
func get_spatial_structure(structure_id):
    if spatial_structures.has(structure_id):
        return spatial_structures[structure_id]
    return null

func get_linguistic_map(map_id):
    if linguistic_maps.has(map_id):
        return linguistic_maps[map_id]
    return null

func get_current_turn_state():
    var current_turn = 1
    if turn_system:
        current_turn = turn_system.get_current_turn()
    
    if turn_states.has(current_turn):
        return turn_states[current_turn]
    
    return null

func create_zone(name, shape_type="Sphere", parameters={}):
    # Set default parameters if not provided
    if not parameters.has("center"):
        parameters.center = Vector3(0, 0, 0)
    
    if not parameters.has("radius") and shape_type == "Sphere":
        parameters.radius = 5.0
    
    if not parameters.has("dimensions") and shape_type == "Cube":
        parameters.dimensions = Vector3(10, 10, 10)
    
    # Create the zone structure
    return _create_spatial_structure("Zone", shape_type, parameters)

func connect_zones(source_zone_id, target_zone_id, connection_type="default"):
    return _connect_structures(source_zone_id, target_zone_id, connection_type)

func map_word(word, space_type, coordinates=Vector3(0, 0, 0)):
    return _map_linguistic_element(word, space_type, coordinates)

func get_goal_status(goal_id):
    if goal_progression.has(goal_id):
        return goal_progression[goal_id]
    return null

func get_all_goals():
    return goal_progression

func reset_turn_state(turn):
    if turn_states.has(turn):
        turn_states.erase(turn)
        
        # Initialize fresh state
        turn_states[turn] = {
            "active_goals": [],
            "completed_goals": [],
            "spatial_focus": "Zone",
            "linguistic_focus": "Command",
            "current_shape": "Sphere",
            "inner_boundary": "Inside",
            "outer_boundary": "Outside",
            "primary_direction": "Horizontal",
            "secondary_direction": "Vertical"
        }
        
        return true
    
    return false

func auto_agent_mode(enable=true, agent_parameters={}):
    # Enable or disable auto agent mode for this connector
    var parameters = agent_parameters.duplicate()
    
    # Set default parameters if not provided
    if not parameters.has("auto_wish_processing"):
        parameters.auto_wish_processing = true
    
    if not parameters.has("auto_goal_advancement"):
        parameters.auto_goal_advancement = true
    
    if not parameters.has("auto_shape_transformation"):
        parameters.auto_shape_transformation = true
    
    # Store parameters in current turn state
    var current_turn = 1
    if turn_system:
        current_turn = turn_system.get_current_turn()
    
    if turn_states.has(current_turn):
        turn_states[current_turn].auto_agent_enabled = enable
        turn_states[current_turn].auto_agent_parameters = parameters
    
    # Set up timer for automated processing if enabled
    if enable:
        var timer = Timer.new()
        timer.wait_time = 5.0 # Process every 5 seconds
        timer.one_shot = false
        timer.autostart = true
        timer.connect("timeout", self, "_on_auto_agent_tick")
        add_child(timer)
        
        print("Auto Agent Mode enabled with parameters:", parameters)
    else:
        # Remove any existing auto agent timer
        for child in get_children():
            if child is Timer and child.name == "AutoAgentTimer":
                child.stop()
                child.queue_free()
        
        print("Auto Agent Mode disabled")
    
    return enable

func _on_auto_agent_tick():
    # Check if auto agent mode is enabled for current turn
    var current_turn = 1
    if turn_system:
        current_turn = turn_system.get_current_turn()
    
    if not turn_states.has(current_turn) or not turn_states[current_turn].has("auto_agent_enabled") or not turn_states[current_turn].auto_agent_enabled:
        return
    
    var parameters = turn_states[current_turn].auto_agent_parameters
    
    # Process pending wishes if enabled
    if parameters.auto_wish_processing and wish_system:
        var pending_wishes = wish_system.get_wishes_by_status("pending", 5)
        
        for wish in pending_wishes:
            process_wish(wish.content, "auto_agent")
    
    # Advance goals automatically if enabled
    if parameters.auto_goal_advancement:
        _advance_current_goals()
    
    # Transform shapes automatically if enabled
    if parameters.auto_shape_transformation:
        _transform_current_shapes()

func _advance_current_goals():
    var current_turn = 1
    if turn_system:
        current_turn = turn_system.get_current_turn()
    
    if not turn_states.has(current_turn):
        return
    
    # Get active goals for this turn
    var active_goals = turn_states[current_turn].active_goals
    
    for goal_id in active_goals:
        if goal_progression.has(goal_id):
            var goal = goal_progression[goal_id]
            
            # Find current step
            for step in goal.steps:
                if step.turn == current_turn and not step.completed:
                    # Automatically mark step as completed
                    step.completed = true
                    
                    # Update progress
                    var completed_steps = 0
                    for s in goal.steps:
                        if s.completed:
                            completed_steps += 1
                    
                    goal.progress = float(completed_steps) / goal.steps.size()
                    
                    # Emit signal
                    emit_signal("goal_advanced", current_turn, goal_id, goal.progress * 100)
                    break

func _transform_current_shapes():
    var current_turn = 1
    if turn_system:
        current_turn = turn_system.get_current_turn()
    
    if not turn_states.has(current_turn):
        return
    
    # Get current shape type for this turn
    var current_shape = turn_states[current_turn].current_shape
    
    # Transform one structure per tick to avoid overwhelming changes
    for structure_id in spatial_structures:
        var structure = spatial_structures[structure_id]
        
        if structure.shape_type != current_shape:
            _transform_shape(structure_id, structure.shape_type, current_shape)
            break  # Just transform one per tick