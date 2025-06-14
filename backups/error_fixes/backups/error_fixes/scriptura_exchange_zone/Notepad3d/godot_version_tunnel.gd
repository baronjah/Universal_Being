extends Node

class_name GodotVersionTunnel

signal migration_started(source_version, target_version, files)
signal migration_progress(current_file, total_files, progress)
signal migration_completed(success, stats)
signal conversion_error(file_path, error_message)

# Version tunnels configuration
const VERSION_DEFINITIONS = {
    "3.x": {
        "id": "3.x",
        "dimension": 3,
        "color": Color(0.3, 0.3, 1.0),  # Blue
        "file_extensions": [".gd", ".tscn", ".tres", ".shader", ".import"],
        "project_identifier": "config_version=4",
        "feature_identifiers": {
            "signals": "signal ",
            "onready": "onready var",
            "exports": "export",
            "enums": "enum"
        }
    },
    "4.0": {
        "id": "4.0",
        "dimension": 4,
        "color": Color(1.0, 1.0, 0.3),  # Yellow
        "file_extensions": [".gd", ".tscn", ".tres", ".gdshader", ".import"],
        "project_identifier": "config_version=5",
        "feature_identifiers": {
            "signals": "signal",
            "annotations": "@onready",
            "exports": "export",
            "enums": "enum"
        }
    },
    "4.1": {
        "id": "4.1",
        "dimension": 4.1,
        "color": Color(1.0, 0.9, 0.3),  # Light Yellow
        "file_extensions": [".gd", ".tscn", ".tres", ".gdshader", ".import"],
        "project_identifier": "config_version=5",
        "feature_identifiers": {
            "signals": "signal",
            "annotations": "@onready",
            "exports": "export",
            "enums": "enum"
        }
    },
    "4.2": {
        "id": "4.2",
        "dimension": 4.2,
        "color": Color(1.0, 0.8, 0.3),  # Dark Yellow
        "file_extensions": [".gd", ".tscn", ".tres", ".gdshader", ".import"],
        "project_identifier": "config_version=5",
        "feature_identifiers": {
            "signals": "signal",
            "annotations": "@onready",
            "exports": "export",
            "enums": "enum"
        }
    },
    "4.3": {
        "id": "4.3",
        "dimension": 4.3,
        "color": Color(1.0, 0.7, 0.3),  # Orange-Yellow
        "file_extensions": [".gd", ".tscn", ".tres", ".gdshader", ".import"],
        "project_identifier": "config_version=5",
        "feature_identifiers": {
            "signals": "signal",
            "annotations": "@onready",
            "exports": "export",
            "enums": "enum"
        }
    },
    "4.4": {
        "id": "4.4",
        "dimension": 4.4,
        "color": Color(1.0, 0.6, 0.3),  # Orange
        "file_extensions": [".gd", ".tscn", ".tres", ".gdshader", ".import"],
        "project_identifier": "config_version=5",
        "feature_identifiers": {
            "signals": "signal",
            "annotations": "@onready",
            "exports": "export",
            "enums": "enum",
            "typed_arrays": "Array[",
            "explicit_constructors": "Vector"
        }
    },
    "4.5": {
        "id": "4.5",
        "dimension": 4.5,
        "color": Color(1.0, 0.5, 0.3),  # Dark Orange
        "file_extensions": [".gd", ".tscn", ".tres", ".gdshader", ".import"],
        "project_identifier": "config_version=5",
        "feature_identifiers": {
            "signals": "signal",
            "annotations": "@onready",
            "exports": "export",
            "enums": "enum",
            "typed_arrays": "Array[",
            "explicit_constructors": "Vector"
        }
    },
    "5.0": {
        "id": "5.0",
        "dimension": 5,
        "color": Color(1.0, 0.3, 1.0),  # Magenta
        "file_extensions": [".gd", ".tscn", ".tres", ".gdshader", ".import"],
        "project_identifier": "config_version=6",
        "feature_identifiers": {
            "signals": "signal",
            "annotations": "@",
            "exports": "export",
            "enums": "enum",
            "typed_arrays": "Array[",
            "explicit_constructors": "Vector"
        }
    }
}

# Migration tunnels between versions
const MIGRATION_TUNNELS = {
    "3.x_to_4.0": {
        "source": "3.x",
        "target": "4.0",
        "stability": 0.8,
        "energy_cost": 25.0,
        "transforms": [
            {"type": "rename", "from": "Spatial", "to": "Node3D"},
            {"type": "rename", "from": "GLES3", "to": "GL_COMPATIBILITY"},
            {"type": "rename", "from": "GLES2", "to": "GLES3"},
            {"type": "rename", "from": "get_node_or_null", "to": "get_node_or_null"},
            {"type": "rename", "from": ".shader", "to": ".gdshader", "file_extension": true},
            {"type": "pattern", "from": "extends \"res://(.*?).gd\"", "to": "extends \"res://$1.gd\""},
            {"type": "pattern", "from": "onready var ([A-Za-z0-9_]+) = (.*)", "to": "@onready var $1 = $2"},
            {"type": "pattern", "from": "func _ready\\(\\):(\\s+)pass", "to": "func _ready() -> void:$1pass"},
            {"type": "pattern", "from": "Vector2\\( *(.*?), *(.*?) *\\)", "to": "Vector2($1, $2)"},
            {"type": "pattern", "from": "Vector3\\( *(.*?), *(.*?), *(.*?) *\\)", "to": "Vector3($1, $2, $3)"},
            {"type": "pattern", "from": "func (_[a-zA-Z0-9_]+)\\(([^)]*)\\):", "to": "func $1($2) -> void:"},
            {"type": "pattern", "from": "func (get_[a-zA-Z0-9_]+)\\(([^)]*)\\):", "to": "func $1($2):"},
            {"type": "pattern", "from": "extends Spatial", "to": "extends Node3D"},
            {"type": "pattern", "from": "Transform\\(", "to": "Transform3D("},
            {"type": "pattern", "from": "yield\\((.*?), (.*?)\\)", "to": "await $1.$2"},
            {"type": "pattern", "from": "Quat\\(", "to": "Quaternion("},
            {"type": "remove", "pattern": "#warning-ignore:"}
        ]
    },
    "4.0_to_4.1": {
        "source": "4.0",
        "target": "4.1",
        "stability": 0.95,
        "energy_cost": 5.0,
        "transforms": []  # Minor version update, minimal changes needed
    },
    "4.1_to_4.2": {
        "source": "4.1",
        "target": "4.2",
        "stability": 0.95,
        "energy_cost": 6.0,
        "transforms": []  # Minor version update, minimal changes needed
    },
    "4.2_to_4.3": {
        "source": "4.2",
        "target": "4.3",
        "stability": 0.95,
        "energy_cost": 7.0,
        "transforms": []  # Minor version update, minimal changes needed
    },
    "4.3_to_4.4": {
        "source": "4.3",
        "target": "4.4",
        "stability": 0.9,
        "energy_cost": 10.0,
        "transforms": [
            {"type": "pattern", "from": "Array = \\[([^\\]]*)\\]", "to": "Array[Variant] = [$1]"},
            {"type": "pattern", "from": "Dictionary = {([^}]*)}", "to": "Dictionary = {$1}"},
            {"type": "pattern", "from": "var ([a-zA-Z0-9_]+): Array", "to": "var $1: Array[Variant]"}
        ]
    },
    "4.4_to_4.5": {
        "source": "4.4",
        "target": "4.5",
        "stability": 0.9,
        "energy_cost": 12.0,
        "transforms": []  # Future version, placeholder
    },
    "4.5_to_5.0": {
        "source": "4.5",
        "target": "5.0",
        "stability": 0.7,
        "energy_cost": 30.0,
        "transforms": [
            {"type": "pattern", "from": "Array\\[Variant\\]", "to": "Array[Variant]"},
            {"type": "pattern", "from": "Dictionary", "to": "Dictionary[Variant, Variant]"},
            {"type": "pattern", "from": "func ([a-zA-Z0-9_]+)\\(([^)]*)\\):", "to": "func $1($2) -> void:"}
        ]
    }
}

# References
var tunnel_controller
var ethereal_tunnel_manager
var word_pattern_visualizer
var numeric_token_system
var akashic_record_connector

# Migration state
var current_migration = null
var migration_queue = []
var file_queue = []

# Version detection cache
var detected_versions = {}
var project_file_cache = {}

# Statistics
var migration_stats = {
    "total_migrations": 0,
    "successful_migrations": 0,
    "failed_migrations": 0,
    "files_processed": 0,
    "transforms_applied": 0,
    "conversion_errors": 0
}

func _ready():
    # Auto-detect components
    _detect_components()

func _process(delta):
    # Process migration queue if there's an active migration
    if current_migration != null:
        _process_migration()

func _detect_components():
    # Find tunnel controller
    if not tunnel_controller:
        var potential_controllers = get_tree().get_nodes_in_group("tunnel_controllers")
        if potential_controllers.size() > 0:
            tunnel_controller = potential_controllers[0]
            print("Found tunnel controller: " + tunnel_controller.name)
            ethereal_tunnel_manager = tunnel_controller.ethereal_tunnel_manager
    
    # Find word pattern visualizer
    if not word_pattern_visualizer:
        var potential_visualizers = get_tree().get_nodes_in_group("word_pattern_visualizers")
        if potential_visualizers.size() > 0:
            word_pattern_visualizer = potential_visualizers[0]
    
    # Find numeric token system
    if not numeric_token_system:
        var potential_token_systems = get_tree().get_nodes_in_group("numeric_token_systems")
        if potential_token_systems.size() > 0:
            numeric_token_system = potential_token_systems[0]
    
    # Find akashic record connector
    if not akashic_record_connector:
        var potential_connectors = get_tree().get_nodes_in_group("akashic_record_connectors")
        if potential_connectors.size() > 0:
            akashic_record_connector = potential_connectors[0]

func detect_project_version(project_path):
    # Check if in cache
    if detected_versions.has(project_path):
        return detected_versions[project_path]
    
    # Ensure path is a directory
    if not DirAccess.dir_exists_absolute(project_path):
        return null
    
    # Look for project.godot file
    var project_file_path = project_path.path_join("project.godot")
    if not FileAccess.file_exists(project_file_path):
        return null
    
    # Read project file
    var file = FileAccess.open(project_file_path, FileAccess.READ)
    if not file:
        return null
    
    var content = file.get_as_text()
    file.close()
    
    # Cache project file content
    project_file_cache[project_path] = content
    
    # Detect version from config_version
    var version = null
    
    # Check for Godot 3.x
    if content.find("config_version=4") >= 0:
        version = "3.x"
    
    # Check for Godot 4.x
    elif content.find("config_version=5") >= 0:
        # Determine specific 4.x version
        if content.find("_global_script_classes={}") >= 0:
            version = "4.0"  # Early 4.0
        elif content.find("Array[") >= 0 or content.find("typed_arrays") >= 0:
            if content.find("explicit_constructors") >= 0:
                version = "4.4"  # More advanced typing
            else:
                version = "4.3"  # Basic typed arrays
        else:
            version = "4.2"  # Default for most 4.x projects
    
    # Check for Godot 5.x
    elif content.find("config_version=6") >= 0:
        version = "5.0"
    
    # Cache the result
    if version:
        detected_versions[project_path] = version
    
    return version

func create_migration_tunnel(source_project_path, target_project_path, target_version = null):
    # Detect source project version
    var source_version = detect_project_version(source_project_path)
    if not source_version:
        print("Could not detect source project version at: " + source_project_path)
        return null
    
    # If target version not specified, determine from project or use next version
    if target_version == null:
        target_version = detect_project_version(target_project_path)
        
        if not target_version:
            # Use next version as target
            var versions = VERSION_DEFINITIONS.keys()
            versions.sort()
            
            var source_index = versions.find(source_version)
            if source_index >= 0 and source_index < versions.size() - 1:
                target_version = versions[source_index + 1]
            else:
                # Default to latest version
                target_version = versions[versions.size() - 1]
    
    # Verify versions are valid
    if not VERSION_DEFINITIONS.has(source_version) or not VERSION_DEFINITIONS.has(target_version):
        print("Invalid version specified")
        return null
    
    # Skip if source and target are the same
    if source_version == target_version:
        print("Source and target versions are the same: " + source_version)
        return null
    
    # Create tunnel ID
    var tunnel_id = source_version + "_to_" + target_version
    
    # Check if direct tunnel exists
    var tunnel_config = null
    
    if MIGRATION_TUNNELS.has(tunnel_id):
        tunnel_config = MIGRATION_TUNNELS[tunnel_id]
    else:
        # Create a multi-hop tunnel by chaining versioned tunnels
        var versions = VERSION_DEFINITIONS.keys()
        versions.sort()
        
        var source_index = versions.find(source_version)
        var target_index = versions.find(target_version)
        
        if source_index < 0 or target_index < 0:
            print("Invalid version path")
            return null
        
        # Create a chain of tunnels
        var tunnel_chain = []
        
        if source_index < target_index:
            # Upgrading version
            for i in range(source_index, target_index):
                var hop_source = versions[i]
                var hop_target = versions[i + 1]
                var hop_tunnel_id = hop_source + "_to_" + hop_target
                
                if MIGRATION_TUNNELS.has(hop_tunnel_id):
                    tunnel_chain.push_back(MIGRATION_TUNNELS[hop_tunnel_id])
                else:
                    print("Missing tunnel definition for: " + hop_tunnel_id)
                    return null
            }
        else:
            # Downgrading version
            for i in range(source_index, target_index, -1):
                var hop_source = versions[i]
                var hop_target = versions[i - 1]
                var hop_tunnel_id = hop_source + "_to_" + hop_target
                
                if MIGRATION_TUNNELS.has(hop_tunnel_id):
                    tunnel_chain.push_back(MIGRATION_TUNNELS[hop_tunnel_id])
                else:
                    print("Missing tunnel definition for: " + hop_tunnel_id)
                    return null
            }
        }
        
        # Create a composite tunnel configuration
        tunnel_config = {
            "source": source_version,
            "target": target_version,
            "stability": 1.0,
            "energy_cost": 0,
            "chain": tunnel_chain,
            "transforms": []
        }
        
        # Calculate composite values
        for tunnel in tunnel_chain:
            tunnel_config.stability *= tunnel.stability
            tunnel_config.energy_cost += tunnel.energy_cost
            
            # Combine transforms
            for transform in tunnel.transforms:
                tunnel_config.transforms.push_back(transform)
            }
        }
        
        # Normalize stability
        tunnel_config.stability = pow(tunnel_config.stability, 1.0 / tunnel_chain.size())
    }
    
    # Create ethereal tunnel if ethereal_tunnel_manager is available
    var ethereal_tunnel = null
    
    if ethereal_tunnel_manager:
        # Ensure project anchors exist
        var source_anchor_id = "godot_" + source_version + "_" + source_project_path.get_file()
        var target_anchor_id = "godot_" + target_version + "_" + target_project_path.get_file()
        
        # Create anchors if they don't exist
        if not ethereal_tunnel_manager.has_anchor(source_anchor_id):
            var source_dim = VERSION_DEFINITIONS[source_version].dimension
            var source_coordinates = Vector3(source_dim, 0, 0)
            ethereal_tunnel_manager.register_anchor(source_anchor_id, source_coordinates, "godot_project")
        }
        
        if not ethereal_tunnel_manager.has_anchor(target_anchor_id):
            var target_dim = VERSION_DEFINITIONS[target_version].dimension
            var target_coordinates = Vector3(target_dim, 0, 0)
            ethereal_tunnel_manager.register_anchor(target_anchor_id, target_coordinates, "godot_project")
        }
        
        // Check if tunnel already exists
        var existing_tunnel_id = source_anchor_id + "_to_" + target_anchor_id
        
        if ethereal_tunnel_manager.has_tunnel(existing_tunnel_id):
            ethereal_tunnel = ethereal_tunnel_manager.get_tunnel_data(existing_tunnel_id)
        } else {
            // Create tunnel with the appropriate dimension
            var dimension = max(
                VERSION_DEFINITIONS[source_version].dimension,
                VERSION_DEFINITIONS[target_version].dimension
            )
            
            ethereal_tunnel = ethereal_tunnel_manager.establish_tunnel(
                source_anchor_id, 
                target_anchor_id, 
                floor(dimension)
            )
            
            // Set stability based on migration difficulty
            if ethereal_tunnel:
                ethereal_tunnel_manager.set_tunnel_stability(
                    ethereal_tunnel.id, 
                    tunnel_config.stability
                )
            }
        }
    }
    
    // Connect to word pattern system to create patterns related to migration
    if word_pattern_visualizer:
        var pattern_text = "godot_migration_" + source_version + "_to_" + target_version
        var energy = 20.0
        var dimension = max(
            VERSION_DEFINITIONS[source_version].dimension,
            VERSION_DEFINITIONS[target_version].dimension
        )
        
        word_pattern_visualizer.add_word_pattern(pattern_text, energy, floor(dimension))
    }
    
    // Create numeric token for version numbers
    if numeric_token_system:
        var source_num = float(source_version.replace("x", "0")) * 100
        var target_num = float(target_version.replace("x", "0")) * 100
        
        numeric_token_system.create_token(int(source_num), "SPACE", "godot_version")
        numeric_token_system.create_token(int(target_num), "SPACE", "godot_version")
    }
    
    // Create migration config with all necessary information
    var migration_config = {
        "id": tunnel_id,
        "source_version": source_version,
        "target_version": target_version,
        "source_path": source_project_path,
        "target_path": target_project_path,
        "tunnel_config": tunnel_config,
        "ethereal_tunnel": ethereal_tunnel
    }
    
    return migration_config

func start_migration(migration_config):
    // Check if already migrating
    if current_migration != null:
        // Add to queue
        migration_queue.push_back(migration_config)
        return false
    }
    
    // Set as current migration
    current_migration = migration_config
    
    // Collect files to migrate
    file_queue = _collect_migration_files(
        migration_config.source_path,
        VERSION_DEFINITIONS[migration_config.source_version].file_extensions
    )
    
    // Update stats
    migration_stats.total_migrations += 1
    
    // Ensure target directory exists
    var dir = DirAccess.open("res://")
    if not DirAccess.dir_exists_absolute(migration_config.target_path):
        dir.make_dir_recursive(migration_config.target_path)
    }
    
    // Copy project.godot file and update version
    _migrate_project_file(
        migration_config.source_path.path_join("project.godot"),
        migration_config.target_path.path_join("project.godot"),
        migration_config.source_version,
        migration_config.target_version
    )
    
    // Emit signal
    emit_signal("migration_started", 
        migration_config.source_version, 
        migration_config.target_version,
        file_queue.size()
    )
    
    return true

func _process_migration():
    // Process a batch of files
    var batch_size = 5
    var processed = 0
    
    while processed < batch_size and file_queue.size() > 0:
        var file_path = file_queue.pop_front()
        _migrate_file(file_path)
        processed += 1
        migration_stats.files_processed += 1
        
        // Emit progress signal
        var progress = 1.0 - (float(file_queue.size()) / 
                           (migration_stats.files_processed + file_queue.size()))
        
        emit_signal("migration_progress", 
            file_path.get_file(), 
            migration_stats.files_processed + file_queue.size(),
            progress
        )
    }
    
    // Check if migration is complete
    if file_queue.size() == 0:
        // Finish migration
        if current_migration.ethereal_tunnel and tunnel_controller:
            // Transfer migration completion data through tunnel
            var content = {
                "type": "migration_complete",
                "source_version": current_migration.source_version,
                "target_version": current_migration.target_version,
                "files_processed": migration_stats.files_processed,
                "transforms_applied": migration_stats.transforms_applied,
                "conversion_errors": migration_stats.conversion_errors
            }
            
            tunnel_controller.transfer_through_tunnel(
                current_migration.ethereal_tunnel.id, 
                JSON.stringify(content)
            )
        }
        
        // Emit completion signal
        var success = migration_stats.conversion_errors == 0
        if success:
            migration_stats.successful_migrations += 1
        } else {
            migration_stats.failed_migrations += 1
        }
        
        emit_signal("migration_completed", success, migration_stats)
        
        // Clear current migration
        var completed_migration = current_migration
        current_migration = null
        
        // Process next in queue
        if migration_queue.size() > 0:
            var next_migration = migration_queue.pop_front()
            start_migration(next_migration)
        }
    }

func _collect_migration_files(dir_path, extensions):
    var files = []
    var dir = DirAccess.open(dir_path)
    
    if not dir:
        return files
    
    dir.list_dir_begin()
    var file_name = dir.get_next()
    
    while file_name != "":
        var full_path = dir_path.path_join(file_name)
        
        if dir.current_is_dir():
            // Skip .git, .import, and similar directories
            if not file_name.begins_with(".") and file_name != "addons":
                var sub_files = _collect_migration_files(full_path, extensions)
                files.append_array(sub_files)
            }
        } else {
            // Check file extension
            var has_valid_ext = false
            for ext in extensions:
                if file_name.ends_with(ext):
                    has_valid_ext = true
                    break
                }
            }
            
            if has_valid_ext:
                files.push_back(full_path)
            }
        }
        
        file_name = dir.get_next()
    }
    
    dir.list_dir_end()
    return files

func _migrate_file(source_file_path):
    // Create target file path
    var rel_path = source_file_path.trim_prefix(current_migration.source_path)
    var target_file_path = current_migration.target_path.path_join(rel_path)
    
    // Handle shader extension rename if needed
    if current_migration.source_version == "3.x" and current_migration.target_version.begins_with("4"):
        if source_file_path.ends_with(".shader"):
            target_file_path = target_file_path.trim_suffix(".shader") + ".gdshader"
        }
    }
    
    // Ensure target directory exists
    var target_dir = target_file_path.get_base_dir()
    var dir = DirAccess.open("res://")
    
    if not DirAccess.dir_exists_absolute(target_dir):
        dir.make_dir_recursive(target_dir)
    }
    
    // Read source file
    var file = FileAccess.open(source_file_path, FileAccess.READ)
    if not file:
        emit_signal("conversion_error", source_file_path, "Cannot open source file")
        migration_stats.conversion_errors += 1
        return
    }
    
    var content = file.get_as_text()
    file.close()
    
    // Apply transforms
    var transformed_content = _apply_transforms(content, source_file_path)
    
    // Write to target file
    file = FileAccess.open(target_file_path, FileAccess.WRITE)
    if not file:
        emit_signal("conversion_error", target_file_path, "Cannot write to target file")
        migration_stats.conversion_errors += 1
        return
    }
    
    file.store_string(transformed_content)
    file.close()
    
    // Record in Akashic records if available
    if akashic_record_connector:
        akashic_record_connector.record_file_migration(
            source_file_path,
            target_file_path,
            current_migration.source_version,
            current_migration.target_version
        )
    }

func _migrate_project_file(source_file_path, target_file_path, source_version, target_version):
    // Read source project file
    var file = FileAccess.open(source_file_path, FileAccess.READ)
    if not file:
        emit_signal("conversion_error", source_file_path, "Cannot open source project file")
        migration_stats.conversion_errors += 1
        return
    }
    
    var content = file.get_as_text()
    file.close()
    
    // Update config_version
    var source_config = VERSION_DEFINITIONS[source_version].project_identifier
    var target_config = VERSION_DEFINITIONS[target_version].project_identifier
    
    content = content.replace(source_config, target_config)
    
    // Godot 3.x to 4.x specific changes
    if source_version == "3.x" and target_version.begins_with("4"):
        // Update renderer
        content = content.replace("GLES2", "GLES3")
        content = content.replace("GLES3", "GL_COMPATIBILITY")
        
        // Update global script classes format
        content = content.replace("_global_script_classes=[  ]", "_global_script_classes={}")
        content = content.replace("_global_script_class_icons={", "_global_script_class_icons={")
    }
    
    // Write to target file
    file = FileAccess.open(target_file_path, FileAccess.WRITE)
    if not file:
        emit_signal("conversion_error", target_file_path, "Cannot write to target project file")
        migration_stats.conversion_errors += 1
        return
    }
    
    file.store_string(content)
    file.close()

func _apply_transforms(content, file_path):
    var result = content
    var transforms_applied = 0
    
    // Skip binary files
    if _is_binary(result):
        return result
    }
    
    // For multi-hop tunnels, apply transforms from each tunnel in the chain
    if current_migration.tunnel_config.has("chain"):
        for tunnel in current_migration.tunnel_config.chain:
            for transform in tunnel.transforms:
                var old_result = result
                result = _apply_transform(result, transform, file_path)
                
                if result != old_result:
                    transforms_applied += 1
                }
            }
        }
    } else {
        // Direct tunnel
        for transform in current_migration.tunnel_config.transforms:
            var old_result = result
            result = _apply_transform(result, transform, file_path)
            
            if result != old_result:
                transforms_applied += 1
            }
        }
    }
    
    migration_stats.transforms_applied += transforms_applied
    return result

func _apply_transform(content, transform, file_path):
    match transform.type:
        "rename":
            // Simple text replacement
            if transform.has("file_extension") and transform.file_extension:
                // Only for relevant files
                if file_path.ends_with(transform.from):
                    return content.replace(transform.from, transform.to)
                } else {
                    return content
                }
            } else {
                return content.replace(transform.from, transform.to)
            }
        
        "pattern":
            // RegEx pattern replacement
            var regex = RegEx.new()
            regex.compile(transform.from)
            
            var matches = regex.search_all(content)
            if matches.size() > 0:
                for i in range(matches.size() - 1, -1, -1):
                    var match_obj = matches[i]
                    var from_text = match_obj.get_string()
                    var to_text = regex.sub(from_text, transform.to)
                    
                    // Replace at specific position
                    var start = match_obj.get_start()
                    var end = match_obj.get_end()
                    content = content.substr(0, start) + to_text + content.substr(end)
                }
            }
            
            return content
        
        "remove":
            // Remove matching patterns
            var regex = RegEx.new()
            regex.compile(transform.pattern)
            
            var matches = regex.search_all(content)
            if matches.size() > 0:
                for i in range(matches.size() - 1, -1, -1):
                    var match_obj = matches[i]
                    var start = match_obj.get_start()
                    var end = match_obj.get_end()
                    content = content.substr(0, start) + content.substr(end)
                }
            }
            
            return content
        
        _:
            // Unknown transform type
            return content

func _is_binary(content):
    // Check if file appears to be binary
    // Look for null bytes or other binary indicators
    return content.find("\0") >= 0

func get_version_info(version_id):
    if VERSION_DEFINITIONS.has(version_id):
        return VERSION_DEFINITIONS[version_id]
    }
    return null

func get_tunnel_info(source_version, target_version):
    var tunnel_id = source_version + "_to_" + target_version
    
    if MIGRATION_TUNNELS.has(tunnel_id):
        return MIGRATION_TUNNELS[tunnel_id]
    }
    return null

func get_migration_stats():
    return migration_stats

func clear_migration_stats():
    migration_stats = {
        "total_migrations": 0,
        "successful_migrations": 0,
        "failed_migrations": 0,
        "files_processed": 0,
        "transforms_applied": 0,
        "conversion_errors": 0
    }

func check_next_version_path(project_path):
    var current_version = detect_project_version(project_path)
    if not current_version:
        return null
    
    // Get ordered list of versions
    var versions = VERSION_DEFINITIONS.keys()
    versions.sort()
    
    var current_index = versions.find(current_version)
    if current_index < 0 or current_index >= versions.size() - 1:
        return null
    
    // Return next version
    return versions[current_index + 1]