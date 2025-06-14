class_name EvolutionSystem
extends Node

# References
@export var connection_manager: WebsiteConnectionManager
@export var pathway_system: PathwaySystem

# Evolution stages and types
enum EvolutionStage {
	INITIALIZATION,
	EXPANSION,
	OPTIMIZATION,
	MUTATION
}

# Evolution history
var evolution_history = []
var mutation_probability = 0.1
var evolution_cycle = 0

signal component_evolved(component_id, stage, changes)
signal pathway_evolved(pathway_id, changes)

func _ready():
	# Set up timer for periodic evolution
	var timer = Timer.new()
	timer.wait_time = 60.0  # Check for evolution every minute
	timer.autostart = true
	timer.connect("timeout", Callable(self, "_on_evolution_timer"))
	add_child(timer)

func _on_evolution_timer():
	evolution_cycle += 1
	evaluate_evolution_opportunities()

func evaluate_evolution_opportunities():
	# Check each component for potential evolution
	for component_type in connection_manager.components:
		var component = connection_manager.components[component_type]
		
		# Determine current evolution stage based on data and usage
		var stage = determine_evolution_stage(component)
		
		# Check if component should evolve
		if should_evolve(component, stage):
			# Generate evolution changes
			var changes = generate_evolution_changes(component, stage)
			
			# Apply the evolution
			apply_component_evolution(component_type, changes)
	
	# Also check pathways for evolution
	if pathway_system:
		for path_id in pathway_system.pathways:
			var pathway = pathway_system.pathways[path_id]
			
			# Only evolve active pathways with sufficient usage
			if pathway["status"] == "open" and pathway["traversal_count"] > 5:
				var pathway_changes = generate_pathway_evolution(pathway)
				
				if pathway_changes.size() > 0:
					pathway_system.evolve_pathway(path_id, pathway_changes)
					emit_signal("pathway_evolved", path_id, pathway_changes)

func determine_evolution_stage(component):
	# Determine the current evolution stage based on component properties
	if not "evolution_stage" in component:
		return EvolutionStage.INITIALIZATION
	
	# Progress through stages based on conditions
	match component["evolution_stage"]:
		EvolutionStage.INITIALIZATION:
			# Move to expansion after initialization is complete
			if component["api_endpoints"].size() >= 2:
				return EvolutionStage.EXPANSION
		EvolutionStage.EXPANSION:
			# Move to optimization after sufficient expansion
			if component["api_endpoints"].size() >= 5:
				return EvolutionStage.OPTIMIZATION
		EvolutionStage.OPTIMIZATION:
			# Move to mutation after sufficient optimization cycles
			if "optimization_cycles" in component and component["optimization_cycles"] >= 3:
				return EvolutionStage.MUTATION
	
	# Default to current stage
	return component["evolution_stage"] if "evolution_stage" in component else EvolutionStage.INITIALIZATION

func should_evolve(component, stage):
	# Decide if a component should evolve based on various factors
	var base_probability = 0.05  # 5% chance of evolution per check
	
	# Increase probability based on evolution stage
	match stage:
		EvolutionStage.INITIALIZATION:
			base_probability = 0.2  # Higher chance during initialization
		EvolutionStage.EXPANSION:
			base_probability = 0.1
		EvolutionStage.OPTIMIZATION:
			base_probability = 0.05
		EvolutionStage.MUTATION:
			base_probability = 0.02  # Rare mutations
	
	# Random chance for evolution
	return randf() < base_probability

func generate_evolution_changes(component, stage):
	var changes = {}
	
	# Different changes based on evolution stage
	match stage:
		EvolutionStage.INITIALIZATION:
			# Add basic functionalities during initialization
			changes["api_endpoints"] = component["api_endpoints"].duplicate()
			changes["api_endpoints"].append("evolved_endpoint_" + str(randi() % 100))
			
			changes["evolution_stage"] = EvolutionStage.INITIALIZATION
			
		EvolutionStage.EXPANSION:
			# Expand capabilities during expansion
			changes["api_endpoints"] = component["api_endpoints"].duplicate()
			changes["api_endpoints"].append("expanded_endpoint_" + str(randi() % 100))
			
			changes["data_handlers"] = component["data_handlers"].duplicate()
			changes["data_handlers"].append("expanded_handler_" + str(randi() % 100))
			
			changes["evolution_stage"] = EvolutionStage.EXPANSION
			
		EvolutionStage.OPTIMIZATION:
			# Optimize existing functionality
			changes["optimization_cycles"] = component.get("optimization_cycles", 0) + 1
			changes["evolution_stage"] = EvolutionStage.OPTIMIZATION
			
		EvolutionStage.MUTATION:
			# Radical changes during mutation
			changes["api_endpoints"] = component["api_endpoints"].duplicate()
			
			# Random chance to remove an endpoint
			if component["api_endpoints"].size() > 3 and randf() < 0.3:
				var idx_to_remove = randi() % component["api_endpoints"].size()
				changes["api_endpoints"].remove_at(idx_to_remove)
			
			# Add a new mutated endpoint
			changes["api_endpoints"].append("mutated_endpoint_" + str(randi() % 100))
			
			changes["evolution_stage"] = EvolutionStage.MUTATION
	
	# Track the evolution
	changes["last_evolved"] = Time.get_unix_time_from_system()
	
	return changes

func apply_component_evolution(component_type, changes):
	# Apply the evolution changes to the component
	connection_manager.evolve_component(component_type, changes)
	
	# Record in history
	evolution_history.append({
		"timestamp": Time.get_unix_time_from_system(),
		"component_type": component_type,
		"stage": changes.get("evolution_stage", EvolutionStage.INITIALIZATION),
		"changes": changes
	})
	
	# Emit signal
	emit_signal("component_evolved", connection_manager.components[component_type]["id"], 
				changes.get("evolution_stage", EvolutionStage.INITIALIZATION), 
				changes)

func generate_pathway_evolution(pathway):
	var changes = {}
	
	# Pathways primarily evolve based on usage
	if pathway["traversal_count"] > 10:
		# Heavily used pathways might get optimized
		changes["optimized"] = true
	
	# Chance for pathway to develop new metadata
	if randf() < 0.2:
		var metadata = pathway["metadata"].duplicate() if "metadata" in pathway else {}
		metadata["evolution_cycle"] = evolution_cycle
		
		# Add some random feature to the pathway
		var features = ["caching", "compression", "encryption", "prioritization"]
		var feature = features[randi() % features.size()]
		metadata[feature] = true
		
		changes["metadata"] = metadata
	
	return changes
