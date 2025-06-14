class_name PathwaySystem
extends Node

# References
@export var connection_manager: WebsiteConnectionManager

# Path data storage
var pathways = {}
var active_pathways = {}

# Pathway types
enum PathwayType {
	DATA_PATH,
	NAVIGATION_PATH,
	COMPONENT_PATH,
	FILE_PATH
}

signal pathway_established(from_id, to_id, path_type)
signal pathway_traversed(path_id, data)

func _ready():
	# Initialize pathway system
	initialize_pathways()

func initialize_pathways():
	# Create default pathways based on component connections
	if connection_manager:
		for conn in connection_manager.connections:
			var from_id = connection_manager.components[conn["from"]]["id"]
			var to_id = connection_manager.components[conn["to"]]["id"]
			
			# Create pathway based on connection type
			var path_type
			match conn["type"]:
				WebsiteConnectionManager.ConnectionType.DATA_FLOW:
					path_type = PathwayType.DATA_PATH
				WebsiteConnectionManager.ConnectionType.NAVIGATION:
					path_type = PathwayType.NAVIGATION_PATH
				WebsiteConnectionManager.ConnectionType.DEPENDENCY:
					path_type = PathwayType.COMPONENT_PATH
				WebsiteConnectionManager.ConnectionType.API_CALL:
					path_type = PathwayType.DATA_PATH
			
			establish_pathway(from_id, to_id, path_type)

func establish_pathway(from_id, to_id, path_type, metadata = {}):
	# Create a unique identifier for this pathway
	var path_id = from_id + "_to_" + to_id + "_" + str(path_type)
	
	# Create the pathway if it doesn't exist
	if not path_id in pathways:
		pathways[path_id] = {
			"from": from_id,
			"to": to_id,
			"type": path_type,
			"metadata": metadata,
			"created_at": Time.get_unix_time_from_system(),
			"traversal_count": 0,
			"last_traversed": null,
			"status": "open"
		}
		
		# Add to active pathways
		active_pathways[path_id] = pathways[path_id]
		
		emit_signal("pathway_established", from_id, to_id, path_type)
		return true
	
	return false

func traverse_pathway(from_id, to_id, data = null):
	# Find all possible pathways
	var possible_paths = []
	
	for path_id in active_pathways:
		var path = active_pathways[path_id]
		if path["from"] == from_id and path["to"] == to_id:
			possible_paths.append(path_id)
	
	if possible_paths.size() == 0:
		# No direct path, try to find indirect path
		return find_and_traverse_indirect_pathway(from_id, to_id, data)
	
	# Choose the best pathway
	var chosen_path_id = possible_paths[0]  # Default to first path
	
	# Traverse the chosen pathway
	pathways[chosen_path_id]["traversal_count"] += 1
	pathways[chosen_path_id]["last_traversed"] = Time.get_unix_time_from_system()
	
	emit_signal("pathway_traversed", chosen_path_id, data)
	
	return true

func find_and_traverse_indirect_pathway(from_id, to_id, data = null):
	# Implement breadth-first search to find a path
	var queue = [[from_id]]
	var visited = {from_id: true}
	
	while queue.size() > 0:
		var path = queue.pop_front()
		var current = path[path.size() - 1]
		
		# Check all outgoing paths from current
		for path_id in active_pathways:
			var pathway = active_pathways[path_id]
			if pathway["from"] == current:
				var next = pathway["to"]
				
				if next == to_id:
					# Found a path to destination
					for i in range(path.size()):
						if i < path.size() - 1:
							# Traverse each segment of the path
							traverse_pathway(path[i], path[i + 1], data)
					
					# Create a direct path for future use
					establish_pathway(from_id, to_id, PathwayType.NAVIGATION_PATH, {
						"indirect": true,
						"intermediate_nodes": path
					})
					
					return true
				
				if not next in visited:
					visited[next] = true
					var new_path = path.duplicate()
					new_path.append(next)
					queue.append(new_path)
	
	return false

func close_pathway(path_id):
	if path_id in pathways:
		pathways[path_id]["status"] = "closed"
		
		# Remove from active pathways
		if path_id in active_pathways:
			active_pathways.erase(path_id)
		
		return true
	
	return false

func evolve_pathway(path_id, evolution_data):
	if not path_id in pathways:
		return false
	
	# Apply evolution to pathway
	for key in evolution_data:
		if key in pathways[path_id]:
			pathways[path_id][key] = evolution_data[key]
	
	return true

func get_all_pathways_from(from_id):
	var result = []
	
	for path_id in active_pathways:
		var path = active_pathways[path_id]
		if path["from"] == from_id:
			result.append(path)
	
	return result

func get_all_pathways_to(to_id):
	var result = []
	
	for path_id in active_pathways:
		var path = active_pathways[path_id]
		if path["to"] == to_id:
			result.append(path)
	
	return result

func visualize_pathways():
	# Create a graph representation of pathways
	var graph = {}
	
	for path_id in pathways:
		var path = pathways[path_id]
		var from_id = path["from"]
		var to_id = path["to"]
		
		if not from_id in graph:
			graph[from_id] = []
		
		graph[from_id].append({
			"to": to_id,
			"path_id": path_id,
			"type": path["type"],
			"status": path["status"]
		})
	
	return graph
