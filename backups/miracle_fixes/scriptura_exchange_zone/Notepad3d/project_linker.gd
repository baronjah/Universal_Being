extends Node

class_name ProjectLinker

# Project Linker
# Creates connections between similar components across different projects
# based on file names, variable names, and functions

# Reference to the project connector
var connector = null

# Token analyzer for content analysis
var token_analyzer = null

# Similarity thresholds
const NAME_SIMILARITY_THRESHOLD = 0.8
const CONTENT_SIMILARITY_THRESHOLD = 0.65
const FUNCTION_SIMILARITY_THRESHOLD = 0.75

# Connection tracking
var created_connections = []

func _init(unified_connector, analyzer = null):
	connector = unified_connector
	
	if analyzer:
		token_analyzer = analyzer
	else:
		token_analyzer = TokenAnalyzer.new()

# Analyze projects and create links based on similarities
func link_projects():
	print("Analyzing projects for potential connections...")
	
	if connector == null:
		push_error("No connector provided")
		return false
	
	# Get all registered components
	var topology = connector.get_connection_topology()
	var components = topology.components
	
	var connection_candidates = []
	
	# Find connection candidates based on different methods
	var name_candidates = _find_name_based_candidates(components)
	var function_candidates = _find_function_based_candidates(components)
	var content_candidates = _find_content_based_candidates(components)
	
	# Merge all candidates
	connection_candidates.extend(name_candidates)
	connection_candidates.extend(function_candidates)
	connection_candidates.extend(content_candidates)
	
	# Remove duplicates
	var unique_candidates = _remove_duplicate_candidates(connection_candidates)
	
	print("Found " + str(unique_candidates.size()) + " potential connections")
	
	# Create connections for top candidates
	var connections_created = 0
	for candidate in unique_candidates:
		var source_id = candidate.source_id
		var target_id = candidate.target_id
		var similarity_type = candidate.similarity_type
		var similarity = candidate.similarity
		
		# Determine connection type based on similarity type
		var connection_type = _determine_connection_type(similarity_type, similarity)
		
		# Create the connection
		var success = connector.connect_components(source_id, target_id, connection_type, {
			"similarity": similarity,
			"similarity_type": similarity_type,
			"auto_generated": true
		})
		
		if success:
			connections_created += 1
			created_connections.append({
				"source_id": source_id,
				"target_id": target_id,
				"connection_type": connection_type,
				"similarity_type": similarity_type,
				"similarity": similarity
			})
	
	print("Created " + str(connections_created) + " connections between projects")
	return connections_created > 0

# Find candidates based on similar names
func _find_name_based_candidates(components):
	var candidates = []
	
	# Group components by project
	var components_by_project = {}
	
	for component_id in components:
		var component = components[component_id]
		var project = component.project
		
		if not components_by_project.has(project):
			components_by_project[project] = []
		
		components_by_project[project].append({
			"id": component_id,
			"name": component_id.split("::")[1].get_file().get_basename(),
			"project": project
		})
	
	# Compare component names across different projects
	var projects = components_by_project.keys()
	
	for i in range(projects.size()):
		for j in range(i+1, projects.size()):
			var project1 = projects[i]
			var project2 = projects[j]
			
			for comp1 in components_by_project[project1]:
				for comp2 in components_by_project[project2]:
					var similarity = token_analyzer.calculate_string_similarity(comp1.name, comp2.name)
					
					if similarity >= NAME_SIMILARITY_THRESHOLD:
						candidates.append({
							"source_id": comp1.id,
							"target_id": comp2.id,
							"similarity_type": "name",
							"similarity": similarity
						})
	
	return candidates

# Find candidates based on similar function names
func _find_function_based_candidates(components):
	var candidates = []
	
	# Analyze components for function similarities
	for comp1_id in components:
		var comp1 = components[comp1_id]
		var comp1_funcs = _extract_component_functions(comp1_id)
		
		for comp2_id in components:
			# Skip same component or same project components
			if comp1_id == comp2_id or comp1.project == components[comp2_id].project:
				continue
			
			var comp2 = components[comp2_id]
			var comp2_funcs = _extract_component_functions(comp2_id)
			
			# Find similar functions
			var similar_funcs = _find_similar_functions(comp1_funcs, comp2_funcs)
			
			if similar_funcs.size() > 0:
				# Calculate overall similarity
				var total_similarity = 0.0
				for func_pair in similar_funcs:
					total_similarity += func_pair.similarity
				
				var avg_similarity = total_similarity / similar_funcs.size()
				
				if avg_similarity >= FUNCTION_SIMILARITY_THRESHOLD:
					candidates.append({
						"source_id": comp1_id,
						"target_id": comp2_id,
						"similarity_type": "function",
						"similarity": avg_similarity,
						"similar_functions": similar_funcs
					})
	
	return candidates

# Find candidates based on content similarity
func _find_content_based_candidates(components):
	var candidates = []
	
	# Analyze components for content similarities
	for comp1_id in components:
		var comp1 = components[comp1_id]
		var comp1_tokens = _extract_component_tokens(comp1_id)
		
		for comp2_id in components:
			# Skip same component or same project components
			if comp1_id == comp2_id or comp1.project == components[comp2_id].project:
				continue
			
			var comp2 = components[comp2_id]
			var comp2_tokens = _extract_component_tokens(comp2_id)
			
			# Calculate content similarity
			var similarity = _calculate_token_sets_similarity(comp1_tokens, comp2_tokens)
			
			if similarity >= CONTENT_SIMILARITY_THRESHOLD:
				candidates.append({
					"source_id": comp1_id,
					"target_id": comp2_id,
					"similarity_type": "content",
					"similarity": similarity
				})
	
	return candidates

# Extract functions from a component
func _extract_component_functions(component_id):
	var component_path = component_id.split("::")[1]
	var project_name = component_id.split("::")[0]
	var full_path = connector.PROJECT_PATHS[project_name] + "/" + component_path
	
	return token_analyzer.tokenize_file(full_path, TokenAnalyzer.TokenStrategy.FUNCTION_NAMES)

# Extract tokens from a component
func _extract_component_tokens(component_id):
	var component_path = component_id.split("::")[1]
	var project_name = component_id.split("::")[0]
	var full_path = connector.PROJECT_PATHS[project_name] + "/" + component_path
	
	return token_analyzer.tokenize_file(full_path, TokenAnalyzer.TokenStrategy.CODE_TOKENS)

# Find similar functions between two components
func _find_similar_functions(funcs1, funcs2):
	var similar_funcs = []
	
	for func1 in funcs1:
		for func2 in funcs2:
			var similarity = token_analyzer.calculate_string_similarity(func1.text, func2.text)
			
			if similarity >= FUNCTION_SIMILARITY_THRESHOLD:
				similar_funcs.append({
					"func1": func1.text,
					"func2": func2.text,
					"similarity": similarity
				})
	
	return similar_funcs

# Calculate similarity between two token sets
func _calculate_token_sets_similarity(tokens1, tokens2):
	var common_tokens = token_analyzer.extract_common_tokens(tokens1, tokens2)
	
	# Calculate Jaccard similarity
	var union_size = tokens1.size() + tokens2.size() - common_tokens.size()
	if union_size == 0:
		return 0.0
	
	return float(common_tokens.size()) / float(union_size)

# Remove duplicate connection candidates
func _remove_duplicate_candidates(candidates):
	var unique_candidates = []
	var seen_pairs = {}
	
	# First pass - keep highest similarity for each pair
	for candidate in candidates:
		var source_id = candidate.source_id
		var target_id = candidate.target_id
		
		# Create a consistent key regardless of source/target order
		var key = [source_id, target_id]
		key.sort()
		key = key[0] + "::" + key[1]
		
		if not seen_pairs.has(key):
			seen_pairs[key] = candidate
		else:
			# Keep the one with higher similarity
			if candidate.similarity > seen_pairs[key].similarity:
				seen_pairs[key] = candidate
	
	# Convert back to array
	for key in seen_pairs:
		unique_candidates.append(seen_pairs[key])
	
	# Sort by similarity (highest first)
	unique_candidates.sort_custom(self, "_sort_by_similarity")
	
	return unique_candidates

# Determine appropriate connection type based on similarity
func _determine_connection_type(similarity_type, similarity):
	match similarity_type:
		"name":
			return connector.ConnectionType.FILE_LINK
		"function":
			return connector.ConnectionType.SIGNAL_BRIDGE
		"content":
			if similarity > 0.8:
				return connector.ConnectionType.SYSTEM_LINK
			else:
				return connector.ConnectionType.VARIABLE_MIRROR
	
	return connector.ConnectionType.FILE_LINK

# Sort helper for similarity
func _sort_by_similarity(a, b):
	return a.similarity > b.similarity

# Generate a report of created connections
func generate_connection_report():
	var report = {
		"total_connections": created_connections.size(),
		"connection_types": {},
		"similarity_types": {},
		"project_connections": {},
		"connections": created_connections
	}
	
	# Count connection types
	for connection in created_connections:
		# Connection type
		var conn_type = connection.connection_type
		if not report.connection_types.has(conn_type):
			report.connection_types[conn_type] = 0
		report.connection_types[conn_type] += 1
		
		# Similarity type
		var sim_type = connection.similarity_type
		if not report.similarity_types.has(sim_type):
			report.similarity_types[sim_type] = 0
		report.similarity_types[sim_type] += 1
		
		# Project connections
		var source_project = connection.source_id.split("::")[0]
		var target_project = connection.target_id.split("::")[0]
		var project_pair = [source_project, target_project]
		project_pair.sort()
		var project_key = project_pair[0] + "-->" + project_pair[1]
		
		if not report.project_connections.has(project_key):
			report.project_connections[project_key] = 0
		report.project_connections[project_key] += 1
	
	return report