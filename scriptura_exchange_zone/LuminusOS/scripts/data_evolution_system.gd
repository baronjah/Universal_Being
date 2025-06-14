extends Node

class_name DataEvolutionSystem

# Data Evolution System for LuminusOS
# Tracks game data changes, provides progression tracking, and enables automatic evolution

signal data_snapshot_created(snapshot_id, timestamp)
signal evolution_milestone_reached(milestone_id, data)
signal pattern_detected(pattern_id, confidence_score)
signal storage_threshold_reached(current_usage, threshold)

# Constants
const STORAGE_HIGH_THRESHOLD = 0.8  # 80% of max storage
const MAX_SNAPSHOTS_PER_GAME = 1000
const PATTERNS_DETECTION_INTERVAL = 300  # seconds
const SNAPSHOT_INTERVAL = 60  # seconds (1 minute)
const HOUR_SNAPSHOT_PREFIX = "hour_"
const EVOLUTION_STAGES = ["seed", "sprout", "growth", "mature", "advanced", "perfected"]

# Storage and tracking variables
var data_snapshots = {}  # Game -> array of snapshots
var evolution_state = {}  # Game -> current evolution state
var detected_patterns = {}  # Patterns detected in user behavior and code
var storage_usage = {
    "current": 0,  # in MB
    "max": 2048000,  # 2TB in MB
    "allocation": {
        "snapshots": 0,
        "games": 0,
        "patterns": 0,
        "resources": 0
    }
}

# Timers
var snapshot_timer
var pattern_detection_timer
var hour_snapshot_timer

func _ready():
    print("Data Evolution System initializing...")
    
    # Initialize timers
    snapshot_timer = Timer.new()
    snapshot_timer.wait_time = SNAPSHOT_INTERVAL
    snapshot_timer.autostart = true
    snapshot_timer.one_shot = false
    snapshot_timer.timeout.connect(_on_snapshot_timer_timeout)
    add_child(snapshot_timer)
    
    pattern_detection_timer = Timer.new()
    pattern_detection_timer.wait_time = PATTERNS_DETECTION_INTERVAL
    pattern_detection_timer.autostart = true
    pattern_detection_timer.one_shot = false
    pattern_detection_timer.timeout.connect(_on_pattern_detection_timer_timeout)
    add_child(pattern_detection_timer)
    
    hour_snapshot_timer = Timer.new()
    hour_snapshot_timer.wait_time = 3600  # 1 hour
    hour_snapshot_timer.autostart = true
    hour_snapshot_timer.one_shot = false
    hour_snapshot_timer.timeout.connect(_on_hour_snapshot_timer_timeout)
    add_child(hour_snapshot_timer)
    
    # Initialize storage tracking
    _calculate_storage_usage()
    
    print("Data Evolution System initialized")

# Create a snapshot of a game's current state
func create_game_snapshot(game_name, game_creator):
    if not game_creator.created_games.has(game_name):
        return "Game not found: " + game_name
    
    # Check storage limits
    if _is_at_storage_limit():
        return "WARNING: Storage threshold reached. Clean up old snapshots."
    
    # Initialize snapshots array if needed
    if not data_snapshots.has(game_name):
        data_snapshots[game_name] = []
    
    # Limit snapshots count
    if data_snapshots[game_name].size() >= MAX_SNAPSHOTS_PER_GAME:
        # Remove oldest snapshot
        data_snapshots[game_name].pop_front()
    
    # Create snapshot with timestamp and unique ID
    var timestamp = Time.get_unix_time_from_system()
    var snapshot_id = "snap_" + game_name + "_" + str(timestamp)
    var game_data = game_creator.created_games[game_name].duplicate(true)
    
    # Add metadata
    var snapshot = {
        "id": snapshot_id,
        "timestamp": timestamp,
        "datetime": Time.get_datetime_dict_from_system(),
        "game_data": game_data,
        "changes_since_last": _calculate_changes_since_last(game_name, game_data),
        "evolution_metrics": _calculate_evolution_metrics(game_name, game_data),
        "storage_size": _estimate_data_size(game_data)
    }
    
    # Save snapshot
    data_snapshots[game_name].push_back(snapshot)
    
    # Update storage usage
    storage_usage.allocation.snapshots += snapshot.storage_size
    _calculate_storage_usage()
    
    # Check for evolution milestones
    _check_evolution_milestones(game_name)
    
    # Emit signal
    emit_signal("data_snapshot_created", snapshot_id, timestamp)
    
    return "Snapshot created: " + snapshot_id

# Create an hourly archive snapshot that is preserved longer
func create_hourly_snapshot(game_name, game_creator):
    if not game_creator.created_games.has(game_name):
        return "Game not found: " + game_name
    
    var timestamp = Time.get_unix_time_from_system()
    var snapshot_id = HOUR_SNAPSHOT_PREFIX + game_name + "_" + str(timestamp)
    var game_data = game_creator.created_games[game_name].duplicate(true)
    
    # Create detailed snapshot with additional metrics
    var snapshot = {
        "id": snapshot_id,
        "timestamp": timestamp,
        "datetime": Time.get_datetime_dict_from_system(),
        "game_data": game_data,
        "evolution_metrics": _calculate_evolution_metrics(game_name, game_data),
        "storage_size": _estimate_data_size(game_data),
        "complexity_score": _calculate_complexity_score(game_data),
        "feature_count": _count_features(game_data),
        "code_quality": _analyze_code_quality(game_data),
        "preserved": true  # Mark as preserved for retention policies
    }
    
    # Initialize hour snapshots array if needed
    if not data_snapshots.has("hourly_" + game_name):
        data_snapshots["hourly_" + game_name] = []
    
    # Save snapshot
    data_snapshots["hourly_" + game_name].push_back(snapshot)
    
    # Update storage usage
    storage_usage.allocation.snapshots += snapshot.storage_size
    _calculate_storage_usage()
    
    return "Hourly snapshot created: " + snapshot_id

# Get evolution status for a game
func get_evolution_status(game_name):
    if not evolution_state.has(game_name):
        evolution_state[game_name] = {
            "stage": 0,  # Index in EVOLUTION_STAGES
            "progress": 0.0,  # Progress to next stage (0-1)
            "metrics": {
                "code_complexity": 0,
                "feature_count": 0,
                "resource_usage": 0,
                "iteration_count": 0
            }
        }
    
    var status = evolution_state[game_name]
    var result = "Evolution Status for " + game_name + ":\n\n"
    
    result += "Stage: " + EVOLUTION_STAGES[status.stage] + " (" + str(status.stage + 1) + "/" + str(EVOLUTION_STAGES.size()) + ")\n"
    result += "Progress to next stage: " + str(int(status.progress * 100)) + "%\n\n"
    
    result += "Metrics:\n"
    result += "- Code Complexity: " + str(status.metrics.code_complexity) + "\n"
    result += "- Feature Count: " + str(status.metrics.feature_count) + "\n"
    result += "- Resource Usage: " + str(status.metrics.resource_usage) + "\n"
    result += "- Iteration Count: " + str(status.metrics.iteration_count) + "\n"
    
    return result

# Get snapshots for a game
func get_snapshots(game_name, count=5):
    if not data_snapshots.has(game_name) or data_snapshots[game_name].size() == 0:
        return "No snapshots found for game: " + game_name
    
    var result = "Recent Snapshots for " + game_name + ":\n\n"
    var snapshots = data_snapshots[game_name]
    var start_idx = max(0, snapshots.size() - count)
    
    for i in range(start_idx, snapshots.size()):
        var snapshot = snapshots[i]
        var dt = snapshot.datetime
        var time_str = "%04d-%02d-%02d %02d:%02d:%02d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second]
        
        result += "- " + snapshot.id + " (" + time_str + ")\n"
        result += "  Size: " + _format_size(snapshot.storage_size) + "\n"
        if snapshot.has("changes_since_last") and snapshot.changes_since_last.size() > 0:
            result += "  Changes: " + str(snapshot.changes_since_last.size()) + "\n"
        result += "\n"
    
    return result

# Get storage usage information
func get_storage_info():
    _calculate_storage_usage()
    
    var result = "Storage Usage Information:\n\n"
    var usage_percent = (storage_usage.current / float(storage_usage.max)) * 100
    
    result += "Total Usage: " + _format_size(storage_usage.current) + " / " + _format_size(storage_usage.max) + " (" + str(int(usage_percent)) + "%)\n\n"
    
    result += "Allocation:\n"
    for category in storage_usage.allocation:
        var category_percent = (storage_usage.allocation[category] / float(storage_usage.current)) * 100
        result += "- " + category.capitalize() + ": " + _format_size(storage_usage.allocation[category]) + " (" + str(int(category_percent)) + "%)\n"
    
    if usage_percent > (STORAGE_HIGH_THRESHOLD * 100):
        result += "\nWARNING: Storage usage is high. Consider cleaning up unused data.\n"
    
    return result

# Analyze user patterns in game creation and evolution
func analyze_patterns():
    var result = "Pattern Analysis:\n\n"
    
    # Analyze all games for patterns
    for game_name in data_snapshots:
        if game_name.begins_with("hourly_"):
            continue
            
        if data_snapshots[game_name].size() < 3:
            continue
            
        var patterns = _detect_patterns_in_game(game_name)
        if patterns.size() > 0:
            result += "Patterns in " + game_name + ":\n"
            for pattern in patterns:
                result += "- " + pattern.name + " (confidence: " + str(int(pattern.confidence * 100)) + "%)\n"
                result += "  " + pattern.description + "\n"
            result += "\n"
    
    # Return discovered patterns
    if detected_patterns.size() == 0:
        return "No significant patterns detected yet. More data needed."
    
    return result

# Compare evolution between games
func compare_evolution(game_names):
    if game_names.size() < 2:
        return "Need at least two games to compare"
    
    var result = "Evolution Comparison:\n\n"
    var comparison_data = {}
    
    # Gather evolution data for each game
    for game_name in game_names:
        if not evolution_state.has(game_name):
            result += game_name + ": No evolution data available\n\n"
            continue
            
        comparison_data[game_name] = evolution_state[game_name]
    
    # Compare stages
    result += "Evolution Stage Comparison:\n"
    for game_name in comparison_data:
        var stage_name = EVOLUTION_STAGES[comparison_data[game_name].stage]
        var progress = int(comparison_data[game_name].progress * 100)
        result += "- " + game_name + ": " + stage_name + " (" + str(progress) + "% to next stage)\n"
    
    # Compare metrics
    result += "\nMetrics Comparison:\n"
    var metrics = ["code_complexity", "feature_count", "resource_usage", "iteration_count"]
    
    for metric in metrics:
        result += "\n" + metric.capitalize().replace("_", " ") + ":\n"
        for game_name in comparison_data:
            var value = comparison_data[game_name].metrics[metric]
            result += "- " + game_name + ": " + str(value) + "\n"
    
    return result

# Process commands for the data evolution system
func cmd_evolve(args):
    if args.size() == 0:
        var result = "Data Evolution System Commands:\n\n"
        result += "evolve snapshot <game_name> - Create a snapshot of the current game state\n"
        result += "evolve status <game_name> - Show evolution status for a game\n"
        result += "evolve snapshots <game_name> [count] - List recent snapshots for a game\n"
        result += "evolve storage - Show storage usage information\n"
        result += "evolve patterns - Analyze user patterns in game creation\n"
        result += "evolve compare <game1> <game2> [game3...] - Compare evolution between games\n"
        result += "evolve clean <game_name> - Clean up old snapshots for a game\n"
        return result
    
    match args[0]:
        "snapshot":
            if args.size() < 2:
                return "Usage: evolve snapshot <game_name>"
                
            var game_creator = get_node_or_null("/root/GameCreator")
            if not game_creator:
                return "GameCreator not available"
                
            return create_game_snapshot(args[1], game_creator)
            
        "status":
            if args.size() < 2:
                return "Usage: evolve status <game_name>"
                
            return get_evolution_status(args[1])
            
        "snapshots":
            if args.size() < 2:
                return "Usage: evolve snapshots <game_name> [count]"
                
            var count = 5
            if args.size() >= 3 and args[2].is_valid_int():
                count = args[2].to_int()
                
            return get_snapshots(args[1], count)
            
        "storage":
            return get_storage_info()
            
        "patterns":
            return analyze_patterns()
            
        "compare":
            if args.size() < 3:
                return "Usage: evolve compare <game1> <game2> [game3...]"
                
            var game_names = args.slice(1)
            return compare_evolution(game_names)
            
        "clean":
            if args.size() < 2:
                return "Usage: evolve clean <game_name>"
                
            return _clean_snapshots(args[1])
            
        _:
            return "Unknown evolve command. Try 'snapshot', 'status', 'snapshots', 'storage', 'patterns', 'compare', or 'clean'"

# Timer callbacks
func _on_snapshot_timer_timeout():
    var game_creator = get_node_or_null("/root/GameCreator")
    if not game_creator:
        return
        
    # Create snapshots for all active games
    for game_name in game_creator.created_games:
        if game_creator.current_game == game_name:  # Only snap active game
            create_game_snapshot(game_name, game_creator)

func _on_pattern_detection_timer_timeout():
    _run_pattern_detection()

func _on_hour_snapshot_timer_timeout():
    var game_creator = get_node_or_null("/root/GameCreator")
    if not game_creator:
        return
        
    # Create hourly snapshots for all games
    for game_name in game_creator.created_games:
        create_hourly_snapshot(game_name, game_creator)

# Helper functions
func _calculate_changes_since_last(game_name, current_data):
    if not data_snapshots.has(game_name) or data_snapshots[game_name].size() == 0:
        return []  # No previous snapshot to compare
    
    var last_snapshot = data_snapshots[game_name].back()
    var last_data = last_snapshot.game_data
    var changes = []
    
    # Check scripts changes
    for script_name in current_data.scripts:
        if not last_data.scripts.has(script_name):
            changes.append({
                "type": "script_added",
                "name": script_name
            })
        elif current_data.scripts[script_name].content != last_data.scripts[script_name].content:
            changes.append({
                "type": "script_modified",
                "name": script_name
            })
    
    # Check for removed scripts
    for script_name in last_data.scripts:
        if not current_data.scripts.has(script_name):
            changes.append({
                "type": "script_removed",
                "name": script_name
            })
    
    # Check scenes changes
    for scene_name in current_data.scenes:
        if not last_data.scenes.has(scene_name):
            changes.append({
                "type": "scene_added",
                "name": scene_name
            })
        elif current_data.scenes[scene_name].nodes.size() != last_data.scenes[scene_name].nodes.size():
            changes.append({
                "type": "scene_modified",
                "name": scene_name
            })
    
    # Check for removed scenes
    for scene_name in last_data.scenes:
        if not current_data.scenes.has(scene_name):
            changes.append({
                "type": "scene_removed",
                "name": scene_name
            })
    
    # Check resources changes
    for resource_name in current_data.resources:
        if not last_data.resources.has(resource_name):
            changes.append({
                "type": "resource_added",
                "name": resource_name
            })
    
    # Check for removed resources
    for resource_name in last_data.resources:
        if not current_data.resources.has(resource_name):
            changes.append({
                "type": "resource_removed",
                "name": resource_name
            })
    
    return changes

func _calculate_evolution_metrics(game_name, game_data):
    var metrics = {
        "code_complexity": 0,
        "feature_count": 0,
        "resource_usage": 0,
        "iteration_count": 0
    }
    
    # Calculate code complexity (based on script content)
    for script_name in game_data.scripts:
        var script = game_data.scripts[script_name]
        if script.has("content"):
            # Count lines of code
            var lines = script.content.split("\n")
            metrics.code_complexity += lines.size()
            
            # Count function definitions as features
            for line in lines:
                if line.strip_edges().begins_with("func "):
                    metrics.feature_count += 1
    
    # Count scenes and resources as feature indicators
    metrics.feature_count += game_data.scenes.size()
    metrics.resource_usage = game_data.resources.size()
    
    # Calculate iteration count from snapshot history
    if data_snapshots.has(game_name):
        metrics.iteration_count = data_snapshots[game_name].size()
    
    return metrics

func _check_evolution_milestones(game_name):
    if not evolution_state.has(game_name):
        evolution_state[game_name] = {
            "stage": 0,
            "progress": 0.0,
            "metrics": {
                "code_complexity": 0,
                "feature_count": 0,
                "resource_usage": 0,
                "iteration_count": 0
            }
        }
    
    if not data_snapshots.has(game_name) or data_snapshots[game_name].size() == 0:
        return
    
    var latest_snapshot = data_snapshots[game_name].back()
    var metrics = latest_snapshot.evolution_metrics
    
    # Update stored metrics
    evolution_state[game_name].metrics = metrics
    
    # Calculate progress based on metrics
    var stage_thresholds = [
        {"code_complexity": 50, "feature_count": 3, "iteration_count": 5},    # seed -> sprout
        {"code_complexity": 200, "feature_count": 8, "iteration_count": 15},  # sprout -> growth
        {"code_complexity": 500, "feature_count": 15, "iteration_count": 30}, # growth -> mature
        {"code_complexity": 1000, "feature_count": 25, "iteration_count": 50}, # mature -> advanced
        {"code_complexity": 2000, "feature_count": 40, "iteration_count": 100} # advanced -> perfected
    ]
    
    # Determine current stage
    var current_stage = evolution_state[game_name].stage
    if current_stage < EVOLUTION_STAGES.size() - 1:
        var threshold = stage_thresholds[current_stage]
        
        # Check if we met the threshold for the next stage
        if metrics.code_complexity >= threshold.code_complexity and \
           metrics.feature_count >= threshold.feature_count and \
           metrics.iteration_count >= threshold.iteration_count:
            
            # Advance to next stage
            evolution_state[game_name].stage += 1
            evolution_state[game_name].progress = 0.0
            
            # Emit signal for milestone reached
            emit_signal("evolution_milestone_reached", 
                        game_name + "_" + EVOLUTION_STAGES[evolution_state[game_name].stage], 
                        evolution_state[game_name])
        else:
            # Calculate progress to next stage
            var complexity_progress = min(1.0, metrics.code_complexity / float(threshold.code_complexity))
            var feature_progress = min(1.0, metrics.feature_count / float(threshold.feature_count))
            var iteration_progress = min(1.0, metrics.iteration_count / float(threshold.iteration_count))
            
            # Average the progress factors
            evolution_state[game_name].progress = (complexity_progress + feature_progress + iteration_progress) / 3.0

func _detect_patterns_in_game(game_name):
    var snapshots = data_snapshots[game_name]
    if snapshots.size() < 3:
        return []
    
    var patterns = []
    
    # Pattern 1: Rapid iteration
    var last_timestamps = []
    for i in range(max(0, snapshots.size() - 5), snapshots.size()):
        last_timestamps.append(snapshots[i].timestamp)
    
    if last_timestamps.size() >= 3:
        var intervals = []
        for i in range(1, last_timestamps.size()):
            intervals.append(last_timestamps[i] - last_timestamps[i-1])
        
        var avg_interval = 0
        for interval in intervals:
            avg_interval += interval
        avg_interval /= intervals.size()
        
        if avg_interval < 300:  # Less than 5 minutes between snapshots
            patterns.append({
                "name": "Rapid Iteration",
                "confidence": 0.8,
                "description": "Developer is making frequent changes in short time intervals."
            })
    
    # Pattern 2: Script focused
    var script_changes = 0
    var scene_changes = 0
    for i in range(max(0, snapshots.size() - 5), snapshots.size()):
        if snapshots[i].has("changes_since_last"):
            for change in snapshots[i].changes_since_last:
                if change.type.begins_with("script_"):
                    script_changes += 1
                elif change.type.begins_with("scene_"):
                    scene_changes += 1
    
    if script_changes > 0 and script_changes >= scene_changes * 2:
        patterns.append({
            "name": "Script-Focused Development",
            "confidence": min(1.0, script_changes / 10.0),
            "description": "Development is focusing heavily on scripting rather than scene building."
        })
    
    # Pattern 3: Feature expansion
    var feature_growth = 0
    if snapshots.size() >= 5:
        var first = snapshots[snapshots.size() - 5].evolution_metrics.feature_count
        var last = snapshots.back().evolution_metrics.feature_count
        feature_growth = last - first
    
    if feature_growth > 5:
        patterns.append({
            "name": "Rapid Feature Expansion",
            "confidence": min(1.0, feature_growth / 10.0),
            "description": "Game is experiencing rapid growth in feature development."
        })
    
    # Save detected patterns
    if not detected_patterns.has(game_name):
        detected_patterns[game_name] = []
    
    for pattern in patterns:
        # Check if pattern already exists
        var exists = false
        for existing in detected_patterns[game_name]:
            if existing.name == pattern.name:
                exists = true
                existing.confidence = pattern.confidence
                break
        
        if not exists:
            detected_patterns[game_name].append(pattern)
            emit_signal("pattern_detected", pattern.name, pattern.confidence)
    
    return patterns

func _run_pattern_detection():
    for game_name in data_snapshots:
        if not game_name.begins_with("hourly_"):
            _detect_patterns_in_game(game_name)

func _calculate_complexity_score(game_data):
    var score = 0
    
    # Scripts complexity
    for script_name in game_data.scripts:
        var script = game_data.scripts[script_name]
        if script.has("content"):
            var lines = script.content.split("\n")
            score += lines.size() * 0.5
            
            # Bonus for functions and classes
            for line in lines:
                var line_text = line.strip_edges()
                if line_text.begins_with("func "):
                    score += 5
                elif line_text.begins_with("class "):
                    score += 10
    
    # Scene complexity
    for scene_name in game_data.scenes:
        score += 10  # Base score for each scene
        score += game_data.scenes[scene_name].nodes.size() * 2
    
    # Resource complexity
    score += game_data.resources.size() * 5
    
    return score

func _count_features(game_data):
    var count = 0
    
    # Count functions as features
    for script_name in game_data.scripts:
        var script = game_data.scripts[script_name]
        if script.has("content"):
            for line in script.content.split("\n"):
                if line.strip_edges().begins_with("func "):
                    count += 1
    
    # Count scenes as features
    count += game_data.scenes.size()
    
    # Count resources that contribute to features
    count += game_data.resources.size() * 0.5
    
    return int(count)

func _analyze_code_quality(game_data):
    var quality = {
        "score": 0,
        "issues": [],
        "strengths": []
    }
    
    # Check scripts
    for script_name in game_data.scripts:
        var script = game_data.scripts[script_name]
        if script.has("content"):
            var lines = script.content.split("\n")
            
            # Check for comments
            var comment_count = 0
            for line in lines:
                if line.strip_edges().begins_with("#"):
                    comment_count += 1
            
            var comment_ratio = float(comment_count) / max(1, lines.size())
            
            # Evaluate comment ratio
            if comment_ratio < 0.05 and lines.size() > 20:
                quality.issues.append("Low comment ratio in " + script_name)
            elif comment_ratio > 0.2:
                quality.strengths.append("Good documentation in " + script_name)
            
            # Check function size
            var current_func = ""
            var func_lines = 0
            var large_functions = 0
            
            for line in lines:
                var line_text = line.strip_edges()
                if line_text.begins_with("func "):
                    if func_lines > 30:
                        large_functions += 1
                    current_func = line_text.split("(")[0].trim_prefix("func ")
                    func_lines = 0
                elif current_func != "":
                    func_lines += 1
            
            if large_functions > 0:
                quality.issues.append("Contains " + str(large_functions) + " large functions")
            else:
                quality.strengths.append("Well-structured functions")
    
    # Calculate overall score
    quality.score = 50  # Base score
    quality.score += quality.strengths.size() * 10
    quality.score -= quality.issues.size() * 10
    quality.score = clamp(quality.score, 0, 100)
    
    return quality

func _clean_snapshots(game_name):
    if not data_snapshots.has(game_name):
        return "No snapshots found for game: " + game_name
    
    # Keep only the latest 10 snapshots
    var snapshots = data_snapshots[game_name]
    var removed_count = 0
    
    while snapshots.size() > 10:
        var snapshot = snapshots.pop_front()
        storage_usage.allocation.snapshots -= snapshot.storage_size
        removed_count += 1
    
    _calculate_storage_usage()
    
    return "Cleaned up " + str(removed_count) + " snapshots for " + game_name

func _is_at_storage_limit():
    return (storage_usage.current / float(storage_usage.max)) >= STORAGE_HIGH_THRESHOLD

func _calculate_storage_usage():
    var current = 0
    
    # Calculate snapshots size
    for game_name in data_snapshots:
        for snapshot in data_snapshots[game_name]:
            current += snapshot.storage_size
    
    # Update current usage
    storage_usage.current = current
    
    # Check if threshold reached
    if _is_at_storage_limit() and not storage_usage.get("threshold_notified", false):
        storage_usage.threshold_notified = true
        emit_signal("storage_threshold_reached", storage_usage.current, storage_usage.max * STORAGE_HIGH_THRESHOLD)

func _estimate_data_size(data):
    # Very rough estimate based on object complexity
    var size = 0
    
    # Scripts size
    for script_name in data.scripts:
        var script = data.scripts[script_name]
        if script.has("content"):
            size += script.content.length() * 2  # UTF-8 chars can be multiple bytes
        size += 100  # Base size for script entry
    
    # Scenes size
    for scene_name in data.scenes:
        size += 500  # Base size for scene
        size += data.scenes[scene_name].nodes.size() * 200  # Estimate for nodes
    
    # Resources size (very rough estimate)
    size += data.resources.size() * 1000
    
    # Convert to KB
    return size / 1024

func _format_size(size_kb):
    if size_kb < 1024:
        return str(size_kb) + " KB"
    elif size_kb < 1024 * 1024:
        return str(int(size_kb / 1024.0 * 100) / 100.0) + " MB"
    else:
        return str(int(size_kb / (1024.0 * 1024.0) * 100) / 100.0) + " GB"