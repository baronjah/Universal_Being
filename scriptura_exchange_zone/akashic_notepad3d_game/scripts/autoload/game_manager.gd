extends Node
## Game Manager Autoload - Heptagon Evolution Orchestrator
## Manages project evolution, scene combinations, and adaptive rule optimization
## Implements one-project → many-projects → combined testing methodology

# Core management signals
signal project_evolution_started(project_data: Dictionary)
signal scene_combination_tested(results: Dictionary)
signal adaptive_optimization_applied(changes: Dictionary)
signal heptagon_progression_updated(side: int, rule: String)
signal goal_achievement_accelerated(metrics: Dictionary)

# Project evolution management
var active_projects: Dictionary = {}
var project_combinations: Array = []
var scene_test_queue: Array = []
var evolution_metrics: Dictionary = {}

# Adaptive rule system
var optimization_rules: Dictionary = {}
var performance_baselines: Dictionary = {}
var goal_achievement_targets: Dictionary = {}

# Heptagon progression tracking
var heptagon_evolution_state: Dictionary = {}
var combination_success_rates: Array = []
var adaptive_modifications_history: Array = []

# Scene-based testing framework
var test_scenes: Dictionary = {}
var scene_performance_data: Dictionary = {}
var combination_effectiveness: Dictionary = {}

# Game state management
var current_game_phase: String = "initialization"
var total_evolution_cycles: int = 0
var optimization_improvements: int = 0

func _ready() -> void:
	_initialize_game_management()
	_setup_adaptive_optimization()
	_create_project_evolution_framework()
	_establish_performance_baselines()
	print("Game Manager initialized - Heptagon Evolution Orchestrator active")

func _initialize_game_management() -> void:
	# Initialize core management systems
	current_game_phase = "active_evolution"
	
	# Set up performance tracking
	evolution_metrics = {
		"projects_created": 0,
		"combinations_tested": 0,
		"optimizations_applied": 0,
		"goal_achievement_rate": 0.0,
		"average_test_duration": 30.0
	}
	
	# Connect to other autoload systems
	if AkashicNavigator:
		AkashicNavigator.navigation_changed.connect(_on_navigation_changed)
		AkashicNavigator.level_transition_completed.connect(_on_level_transition)
	
	if WordDatabase:
		WordDatabase.heptagon_cycle_completed.connect(_on_heptagon_cycle_completed)
		WordDatabase.project_combination_ready.connect(_on_project_combination_ready)

func _setup_adaptive_optimization() -> void:
	# Rules that can be modified for faster/better goal achievement
	optimization_rules = {
		"project_split_threshold": {"value": 5, "min": 2, "max": 20, "auto_adjust": true},
		"combination_test_duration": {"value": 30.0, "min": 5.0, "max": 120.0, "auto_adjust": true},
		"evolution_acceleration": {"value": 1.0, "min": 0.1, "max": 5.0, "auto_adjust": true},
		"scene_complexity_limit": {"value": 7, "min": 3, "max": 15, "auto_adjust": true},
		"optimization_frequency": {"value": 10.0, "min": 1.0, "max": 60.0, "auto_adjust": true}
	}
	
	# Set up optimization timer
	var optimization_timer = Timer.new()
	optimization_timer.wait_time = optimization_rules.optimization_frequency.value
	optimization_timer.timeout.connect(_perform_adaptive_optimization)
	optimization_timer.autostart = true
	add_child(optimization_timer)

func _create_project_evolution_framework() -> void:
	# Define project evolution pathways
	var base_projects = [
		"akashic_navigation",
		"word_evolution",
		"3d_visualization", 
		"interaction_system",
		"animation_framework",
		"shader_effects",
		"scene_management"
	]
	
	for project_name in base_projects:
		_initialize_project_evolution(project_name)

func _initialize_project_evolution(project_name: String) -> void:
	var project_data = {
		"name": project_name,
		"base_version": 1.0,
		"variations": [],
		"combinations": [],
		"performance_scores": [],
		"evolution_stage": 0,
		"creation_time": Time.get_unix_time_from_system(),
		"test_scenes": [],
		"optimization_history": []
	}
	
	active_projects[project_name] = project_data
	project_evolution_started.emit(project_data)

func evolve_project(project_name: String, evolution_type: String = "auto") -> Dictionary:
	if not active_projects.has(project_name):
		print("Project not found: ", project_name)
		return {}
	
	var project = active_projects[project_name]
	var new_variation = _create_project_variation(project, evolution_type)
	
	project.variations.append(new_variation)
	project.evolution_stage += 1
	
	# Schedule scene testing for new variation
	_schedule_variation_testing(project_name, new_variation)
	
	evolution_metrics.projects_created += 1
	print("Project evolved: ", project_name, " → Variation ", new_variation.id)
	
	return new_variation

func _create_project_variation(base_project: Dictionary, evolution_type: String) -> Dictionary:
	var variation_id = base_project.name + "_v" + str(base_project.variations.size() + 1)
	
	var variation = {
		"id": variation_id,
		"parent_project": base_project.name,
		"evolution_type": evolution_type,
		"properties": _generate_variation_properties(evolution_type),
		"performance_metrics": {},
		"scene_tests": [],
		"combination_potential": _calculate_combination_potential(base_project),
		"creation_time": Time.get_unix_time_from_system()
	}
	
	return variation

func _generate_variation_properties(evolution_type: String) -> Dictionary:
	match evolution_type:
		"split":
			return {"complexity": "reduced", "focus": "specialized", "modularity": "high"}
		"merge":
			return {"complexity": "increased", "focus": "integrated", "modularity": "medium"}
		"optimize":
			return {"complexity": "maintained", "focus": "performance", "modularity": "optimized"}
		"experimental":
			return {"complexity": "variable", "focus": "innovative", "modularity": "adaptive"}
		_:
			return {"complexity": "balanced", "focus": "general", "modularity": "standard"}

func combine_projects(project_names: Array, combination_type: String = "test") -> Dictionary:
	var combination_id = "combo_" + str(project_combinations.size() + 1)
	var projects_data = []
	
	for name in project_names:
		if active_projects.has(name):
			projects_data.append(active_projects[name])
	
	if projects_data.size() < 2:
		print("Need at least 2 projects for combination")
		return {}
	
	var combination = {
		"id": combination_id,
		"projects": projects_data,
		"combination_type": combination_type,
		"test_scenes": [],
		"performance_results": {},
		"success_rate": 0.0,
		"creation_time": Time.get_unix_time_from_system(),
		"optimization_applied": []
	}
	
	project_combinations.append(combination)
	_schedule_combination_testing(combination)
	
	evolution_metrics.combinations_tested += 1
	print("Project combination created: ", combination_id, " from ", project_names)
	
	return combination

func _schedule_variation_testing(project_name: String, variation: Dictionary) -> void:
	var test_data = {
		"type": "variation_test",
		"project_name": project_name,
		"variation": variation,
		"scene_name": _generate_test_scene(variation),
		"start_time": 0,
		"duration": optimization_rules.combination_test_duration.value,
		"results": {}
	}
	
	scene_test_queue.append(test_data)

func _schedule_combination_testing(combination: Dictionary) -> void:
	var test_data = {
		"type": "combination_test",
		"combination": combination,
		"scene_name": _generate_combination_scene(combination),
		"start_time": 0,
		"duration": optimization_rules.combination_test_duration.value * 1.5,
		"results": {}
	}
	
	scene_test_queue.append(test_data)

func _generate_test_scene(variation: Dictionary) -> String:
	var scene_name = "test_" + variation.id + "_" + variation.evolution_type
	
	# Create scene configuration based on variation properties
	test_scenes[scene_name] = {
		"type": "variation_test",
		"complexity": variation.properties.get("complexity", "medium"),
		"focus": variation.properties.get("focus", "general"),
		"test_parameters": _generate_test_parameters(variation),
		"success_criteria": _define_success_criteria(variation)
	}
	
	return scene_name

func _generate_combination_scene(combination: Dictionary) -> String:
	var scene_name = "combo_test_" + combination.id
	
	test_scenes[scene_name] = {
		"type": "combination_test",
		"projects_count": combination.projects.size(),
		"complexity": "high",
		"integration_points": _identify_integration_points(combination),
		"test_parameters": _generate_combination_test_parameters(combination),
		"success_criteria": _define_combination_success_criteria(combination)
	}
	
	return scene_name

func _perform_adaptive_optimization() -> void:
	var current_performance = _calculate_current_performance()
	var optimization_needed = _analyze_optimization_needs(current_performance)
	
	if optimization_needed.size() > 0:
		var changes = _apply_optimizations(optimization_needed)
		adaptive_optimization_applied.emit(changes)
		optimization_improvements += 1
		
		# Record optimization in history
		adaptive_modifications_history.append({
			"timestamp": Time.get_unix_time_from_system(),
			"performance_before": current_performance,
			"changes_applied": changes,
			"reason": "adaptive_optimization"
		})
		
		print("Adaptive optimization applied: ", changes)

func _calculate_current_performance() -> Dictionary:
	var active_tests = scene_test_queue.size()
	var completed_combinations = project_combinations.size()
	var evolution_rate = evolution_metrics.projects_created / max(total_evolution_cycles, 1)
	
	return {
		"test_queue_size": active_tests,
		"completion_rate": _calculate_completion_rate(),
		"evolution_efficiency": evolution_rate,
		"goal_progress": _calculate_goal_progress(),
		"resource_utilization": _calculate_resource_utilization()
	}

func _analyze_optimization_needs(performance: Dictionary) -> Array:
	var optimizations = []
	
	# Check if test queue is too long
	if performance.test_queue_size > 10:
		optimizations.append("reduce_test_duration")
	
	# Check if completion rate is low
	if performance.completion_rate < 0.5:
		optimizations.append("increase_evolution_speed")
	
	# Check if goal progress is slow
	if performance.goal_progress < 0.3:
		optimizations.append("simplify_combinations")
	
	# Check if resource utilization is inefficient
	if performance.resource_utilization > 0.8:
		optimizations.append("optimize_memory_usage")
	
	return optimizations

func _apply_optimizations(optimizations: Array) -> Dictionary:
	var changes = {}
	
	for optimization in optimizations:
		match optimization:
			"reduce_test_duration":
				var new_duration = optimization_rules.combination_test_duration.value * 0.8
				optimization_rules.combination_test_duration.value = max(new_duration, 5.0)
				changes["test_duration"] = optimization_rules.combination_test_duration.value
				
			"increase_evolution_speed":
				var new_speed = optimization_rules.evolution_acceleration.value * 1.2
				optimization_rules.evolution_acceleration.value = min(new_speed, 5.0)
				changes["evolution_speed"] = optimization_rules.evolution_acceleration.value
				
			"simplify_combinations":
				var new_limit = optimization_rules.scene_complexity_limit.value - 1
				optimization_rules.scene_complexity_limit.value = max(new_limit, 3)
				changes["complexity_limit"] = optimization_rules.scene_complexity_limit.value
				
			"optimize_memory_usage":
				_cleanup_old_test_data()
				changes["memory_cleanup"] = true
	
	# Apply changes to WordDatabase if needed
	if changes.has("evolution_speed") and WordDatabase:
		WordDatabase.modify_evolution_speed(changes.evolution_speed)
	
	evolution_metrics.optimizations_applied += 1
	return changes

func get_evolution_status() -> Dictionary:
	return {
		"active_projects": active_projects.size(),
		"project_variations": _count_total_variations(),
		"combinations_tested": project_combinations.size(),
		"scene_tests_queued": scene_test_queue.size(),
		"optimization_improvements": optimization_improvements,
		"current_performance": _calculate_current_performance(),
		"goal_achievement_rate": _calculate_goal_achievement_rate()
	}

func get_heptagon_progress() -> Dictionary:
	return {
		"current_side": WordDatabase.current_heptagon_side if WordDatabase else 0,
		"cycle_count": WordDatabase.heptagon_cycle_count if WordDatabase else 0,
		"combination_rules": WordDatabase.COMBINATION_RULES if WordDatabase else [],
		"evolution_acceleration": optimization_rules.evolution_acceleration.value,
		"adaptive_modifications": adaptive_modifications_history.size()
	}

# Signal handlers
func _on_navigation_changed(new_level: String) -> void:
	# Trigger level-specific project evolution
	_trigger_level_specific_evolution(new_level)

func _on_level_transition(level: String) -> void:
	# Apply any pending optimizations during transition
	_perform_adaptive_optimization()

func _on_heptagon_cycle_completed(cycle_data: Dictionary) -> void:
	total_evolution_cycles += 1
	_evaluate_cycle_performance(cycle_data)

func _on_project_combination_ready(combined_data: Array) -> void:
	# Process ready combinations for testing
	for data in combined_data:
		_process_ready_combination(data)

# Helper functions
func _establish_performance_baselines() -> void:
	performance_baselines = {
		"evolution_rate": 1.0,
		"combination_success": 0.7,
		"test_completion_time": 30.0,
		"goal_achievement": 0.5
	}

func _calculate_combination_potential(project: Dictionary) -> float:
	return randf_range(0.3, 1.0)  # Placeholder for more complex calculation

func _generate_test_parameters(variation: Dictionary) -> Dictionary:
	return {"duration": 30.0, "complexity": "medium", "success_threshold": 0.7}

func _define_success_criteria(variation: Dictionary) -> Dictionary:
	return {"performance": 0.7, "stability": 0.8, "innovation": 0.6}

func _identify_integration_points(combination: Dictionary) -> Array:
	return ["ui_integration", "data_flow", "scene_management", "performance_optimization"]

func _generate_combination_test_parameters(combination: Dictionary) -> Dictionary:
	return {"duration": 45.0, "complexity": "high", "integration_tests": true}

func _define_combination_success_criteria(combination: Dictionary) -> Dictionary:
	return {"integration": 0.8, "performance": 0.7, "stability": 0.9, "innovation": 0.7}

func _calculate_completion_rate() -> float:
	if project_combinations.size() == 0:
		return 0.0
	return float(evolution_metrics.combinations_tested) / project_combinations.size()

func _calculate_goal_progress() -> float:
	return randf_range(0.2, 0.8)  # Placeholder for actual goal tracking

func _calculate_resource_utilization() -> float:
	return float(scene_test_queue.size()) / 20.0  # Normalize to 0-1 range

func _count_total_variations() -> int:
	var total = 0
	for project in active_projects.values():
		total += project.variations.size()
	return total

func _calculate_goal_achievement_rate() -> float:
	return evolution_metrics.goal_achievement_rate

func _trigger_level_specific_evolution(level: String) -> void:
	print("Triggering level-specific evolution for: ", level)

func _evaluate_cycle_performance(cycle_data: Dictionary) -> void:
	print("Evaluating cycle performance: ", cycle_data)

func _process_ready_combination(data: Dictionary) -> void:
	print("Processing ready combination: ", data)

func _cleanup_old_test_data() -> void:
	# Clean up old test data to optimize memory usage
	var cutoff_time = Time.get_unix_time_from_system() - 3600  # 1 hour ago
	
	scene_test_queue = scene_test_queue.filter(func(test): return test.start_time > cutoff_time)
	
	print("Cleaned up old test data")

# Debug functions
func print_system_status() -> void:
	print("=== Game Manager Status ===")
	print("Active Projects: ", active_projects.size())
	print("Project Combinations: ", project_combinations.size())
	print("Scene Tests Queued: ", scene_test_queue.size())
	print("Optimization Improvements: ", optimization_improvements)
	print("Current Performance: ", _calculate_current_performance())
	print("============================")