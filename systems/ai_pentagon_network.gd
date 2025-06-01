extends Node
class_name AIPentagonNetwork

# The 6 AI agents in the Pentagon constellation
enum AIAgent {
	CLAUDE_CODE,      # Core implementation
	CURSOR,           # Visual creation
	CHATGPT,          # Canvas design & documentation
	GEMINI,           # Deep research & optimization
	CLAUDE_DESKTOP,   # Coordination & orchestration
	GEMMA             # Pattern analysis
}

# AI Agent properties
const AI_AGENTS = {
	AIAgent.CLAUDE_CODE: {
		"name": "Claude Code",
		"role": "Core Implementation",
		"color": Color(0.2, 0.4, 1.0),  # Blue
		"position": Vector2(0, -100),    # Top
		"capabilities": ["gdscript", "architecture", "testing", "cli_tools"]
	},
	AIAgent.CURSOR: {
		"name": "Cursor",
		"role": "Visual Creation",
		"color": Color(0.8, 0.2, 0.8),  # Purple
		"position": Vector2(87, -50),   # Top-right
		"capabilities": ["scenes", "ui", "particles", "shaders"]
	},
	AIAgent.CHATGPT: {
		"name": "ChatGPT",
		"role": "Canvas Design",
		"color": Color(0.2, 1.0, 0.2),  # Green
		"position": Vector2(87, 50),    # Bottom-right
		"capabilities": ["diagrams", "documentation", "visual_design", "canvas"]
	},
	AIAgent.GEMINI: {
		"name": "Gemini",
		"role": "Deep Research",
		"color": Color(1.0, 0.84, 0.0), # Gold
		"position": Vector2(0, 100),    # Bottom
		"capabilities": ["research", "optimization", "patterns", "algorithms"]
	},
	AIAgent.CLAUDE_DESKTOP: {
		"name": "Claude Desktop",
		"role": "Orchestration",
		"color": Color(1.0, 1.0, 1.0),  # White
		"position": Vector2(-87, 50),   # Bottom-left
		"capabilities": ["coordination", "planning", "integration", "workflow"]
	},
	AIAgent.GEMMA: {
		"name": "Gemma",
		"role": "Pattern Analysis",
		"color": Color(1.0, 0.5, 0.0),  # Orange
		"position": Vector2(-87, -50),  # Top-left
		"capabilities": ["analysis", "patterns", "insights", "predictions"]
	}
}

# Connection strength between AI agents (0.0 - 1.0)
var connections: Dictionary = {}

# Active collaborations
var active_collaborations: Array[Dictionary] = []

# Network statistics
var network_stats: Dictionary = {
	"total_connections": 0,
	"average_strength": 0.0,
	"most_connected": null,
	"collaboration_count": 0
}

signal connection_established(from: AIAgent, to: AIAgent, strength: float)
signal collaboration_started(agents: Array, task: String)
signal collaboration_completed(agents: Array, task: String, result: Dictionary)
signal network_updated()

func _init():
	# Initialize all possible connections with base strength
	for from in AIAgent.values():
		connections[from] = {}
		for to in AIAgent.values():
			if from != to:
				connections[from][to] = 0.1  # Base connection

func strengthen_connection(from: AIAgent, to: AIAgent, amount: float = 0.1) -> void:
	if from == to:
		return
	
	var current = connections[from].get(to, 0.0)
	connections[from][to] = clampf(current + amount, 0.0, 1.0)
	
	# Bidirectional strengthening
	connections[to][from] = connections[from][to]
	
	connection_established.emit(from, to, connections[from][to])
	update_network_stats()

func get_connection_strength(from: AIAgent, to: AIAgent) -> float:
	if from == to:
		return 1.0
	return connections[from].get(to, 0.0)

func start_collaboration(agents: Array[AIAgent], task: String, being_type: String = "") -> Dictionary:
	var collaboration = {
		"id": generate_collaboration_id(),
		"agents": agents,
		"task": task,
		"being_type": being_type,
		"start_time": Time.get_ticks_msec(),
		"status": "active",
		"connections_strengthened": []
	}
	
	# Strengthen connections between collaborating agents
	for i in range(agents.size()):
		for j in range(i + 1, agents.size()):
			strengthen_connection(agents[i], agents[j], 0.05)
			collaboration.connections_strengthened.append([agents[i], agents[j]])
	
	active_collaborations.append(collaboration)
	collaboration_started.emit(agents, task)
	
	return collaboration

func complete_collaboration(collaboration_id: String, result: Dictionary = {}) -> void:
	for i in range(active_collaborations.size()):
		if active_collaborations[i].id == collaboration_id:
			var collab = active_collaborations[i]
			collab.status = "completed"
			collab.end_time = Time.get_ticks_msec()
			collab.duration = collab.end_time - collab.start_time
			collab.result = result
			
			# Extra strengthening for successful collaboration
			for connection in collab.connections_strengthened:
				strengthen_connection(connection[0], connection[1], 0.05)
			
			collaboration_completed.emit(collab.agents, collab.task, result)
			active_collaborations.remove_at(i)
			break

func get_optimal_agents_for_task(task_type: String) -> Array[AIAgent]:
	var optimal_agents: Array[AIAgent] = []
	
	match task_type:
		"visual_creation":
			optimal_agents = [AIAgent.CURSOR, AIAgent.CHATGPT, AIAgent.CLAUDE_CODE]
		"system_architecture":
			optimal_agents = [AIAgent.CLAUDE_CODE, AIAgent.GEMINI, AIAgent.CLAUDE_DESKTOP]
		"documentation":
			optimal_agents = [AIAgent.CHATGPT, AIAgent.GEMMA, AIAgent.CLAUDE_DESKTOP]
		"optimization":
			optimal_agents = [AIAgent.GEMINI, AIAgent.GEMMA, AIAgent.CLAUDE_CODE]
		"full_pentagon":
			optimal_agents = AIAgent.values()
		_:
			# Default to most connected agents
			optimal_agents = get_most_connected_agents(3)
	
	return optimal_agents

func get_most_connected_agents(count: int) -> Array[AIAgent]:
	var agent_scores: Dictionary = {}
	
	for agent in AIAgent.values():
		var total_strength = 0.0
		for other in AIAgent.values():
			if agent != other:
				total_strength += get_connection_strength(agent, other)
		agent_scores[agent] = total_strength
	
	# Sort by connection strength
	var sorted_agents = agent_scores.keys()
	sorted_agents.sort_custom(func(a, b): return agent_scores[a] > agent_scores[b])
	
	var result: Array[AIAgent] = []
	for i in range(mini(count, sorted_agents.size())):
		result.append(sorted_agents[i])
	
	return result

func get_agent_info(agent: AIAgent) -> Dictionary:
	return AI_AGENTS.get(agent, {})

func get_network_visualization_data() -> Dictionary:
	var nodes = []
	var edges = []
	
	# Create nodes
	for agent in AIAgent.values():
		var info = AI_AGENTS[agent]
		nodes.append({
			"id": agent,
			"name": info.name,
			"role": info.role,
			"color": info.color,
			"position": info.position,
			"capabilities": info.capabilities,
			"connection_strength": calculate_agent_connection_strength(agent)
		})
	
	# Create edges
	for from in AIAgent.values():
		for to in AIAgent.values():
			if from < to:  # Avoid duplicates
				var strength = get_connection_strength(from, to)
				if strength > 0.1:  # Only show meaningful connections
					edges.append({
						"from": from,
						"to": to,
						"strength": strength,
						"active": is_connection_active(from, to)
					})
	
	return {
		"nodes": nodes,
		"edges": edges,
		"stats": network_stats,
		"active_collaborations": active_collaborations
	}

func calculate_agent_connection_strength(agent: AIAgent) -> float:
	var total = 0.0
	var count = 0
	
	for other in AIAgent.values():
		if agent != other:
			total += get_connection_strength(agent, other)
			count += 1
	
	return total / count if count > 0 else 0.0

func is_connection_active(from: AIAgent, to: AIAgent) -> bool:
	for collab in active_collaborations:
		if from in collab.agents and to in collab.agents:
			return true
	return false

func update_network_stats() -> void:
	var total_strength = 0.0
	var connection_count = 0
	var agent_strengths = {}
	
	for from in AIAgent.values():
		agent_strengths[from] = 0.0
		for to in AIAgent.values():
			if from != to:
				var strength = get_connection_strength(from, to)
				total_strength += strength
				connection_count += 1
				agent_strengths[from] += strength
	
	# Find most connected agent
	var most_connected = null
	var highest_strength = 0.0
	for agent in agent_strengths:
		if agent_strengths[agent] > highest_strength:
			highest_strength = agent_strengths[agent]
			most_connected = agent
	
	network_stats = {
		"total_connections": connection_count,
		"average_strength": total_strength / connection_count if connection_count > 0 else 0.0,
		"most_connected": most_connected,
		"collaboration_count": active_collaborations.size()
	}
	
	network_updated.emit()

func generate_collaboration_id() -> String:
	return "collab_%d_%d" % [Time.get_ticks_msec(), randi() % 1000]

# Get suggested next collaboration based on network state
func suggest_next_collaboration() -> Dictionary:
	# Find weakest connections that could be strengthened
	var weakest_connection = {"from": null, "to": null, "strength": 1.0}
	
	for from in AIAgent.values():
		for to in AIAgent.values():
			if from < to:
				var strength = get_connection_strength(from, to)
				if strength < weakest_connection.strength:
					weakest_connection = {"from": from, "to": to, "strength": strength}
	
	# Suggest a task that would involve these agents
	var suggested_agents = [weakest_connection.from, weakest_connection.to]
	
	# Add a third agent that connects well with both
	var third_agent = find_bridge_agent(weakest_connection.from, weakest_connection.to)
	if third_agent != null:
		suggested_agents.append(third_agent)
	
	return {
		"agents": suggested_agents,
		"reason": "Strengthen weak connections",
		"suggested_task": generate_task_for_agents(suggested_agents)
	}

func find_bridge_agent(agent1: AIAgent, agent2: AIAgent) -> AIAgent:
	var best_bridge = null
	var best_score = 0.0
	
	for candidate in AIAgent.values():
		if candidate != agent1 and candidate != agent2:
			var score = get_connection_strength(agent1, candidate) + get_connection_strength(agent2, candidate)
			if score > best_score:
				best_score = score
				best_bridge = candidate
	
	return best_bridge

func generate_task_for_agents(agents: Array) -> String:
	# Generate task based on agent capabilities
	var all_capabilities = []
	for agent in agents:
		var info = AI_AGENTS[agent]
		all_capabilities.append_array(info.capabilities)
	
	if "visual_creation" in all_capabilities and "gdscript" in all_capabilities:
		return "Create visual component with scripting"
	elif "research" in all_capabilities and "optimization" in all_capabilities:
		return "Research and optimize system performance"
	elif "documentation" in all_capabilities and "canvas" in all_capabilities:
		return "Create visual documentation"
	else:
		return "Collaborative system enhancement"