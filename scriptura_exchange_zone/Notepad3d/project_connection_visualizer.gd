extends Node2D

class_name ProjectConnectionVisualizer

# Project Connection Visualizer
# Visualizes connections between components across different projects

# Visual settings
const NODE_RADIUS = 10
const NODE_SPACING = 150
const PROJECT_SPACING = 300
const CONNECTION_COLORS = {
	0: Color(0.2, 0.7, 1.0, 0.8),  # FILE_LINK
	1: Color(0.2, 1.0, 0.2, 0.8),  # VARIABLE_MIRROR
	2: Color(1.0, 0.8, 0.2, 0.8),  # SIGNAL_BRIDGE
	3: Color(0.8, 0.2, 1.0, 0.8),  # SYSTEM_LINK
	4: Color(1.0, 0.2, 0.4, 0.8)   # API_CONNECTOR
}

const PROJECT_COLORS = {
	"12_turns_system": Color(0.2, 0.6, 1.0),
	"LuminusOS": Color(0.2, 1.0, 0.6),
	"Eden_OS": Color(1.0, 0.6, 0.2),
	"Godot_Eden": Color(0.8, 0.2, 0.6)
}

# Data to visualize
var projects = {}
var components = []
var connections = []

# Node positions for rendering
var node_positions = {}
var project_bounds = {}

# Zoom and pan
var zoom_level = 1.0
var pan_offset = Vector2(0, 0)

# UI state
var selected_node = null
var hovered_node = null
var dragging = false
var drag_start = Vector2(0, 0)

# Unified connector reference
var connector = null

# Signals
signal node_selected(component_id)
signal connection_highlighted(connection_id)

func _ready():
	# Create font for labels
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://fonts/arial.ttf")
	dynamic_font.size = 14
	
	# Load connection data from file if provided
	var visualization_path = "user://project_connections.json"
	_load_visualization_data(visualization_path)
	
	# Calculate initial layout
	_calculate_layout()

func _load_visualization_data(file_path):
	var file = File.new()
	if file.file_exists(file_path) and file.open(file_path, File.READ) == OK:
		var json_text = file.get_as_text()
		file.close()
		
		var parse_result = JSON.parse(json_text)
		if parse_result.error == OK:
			var data = parse_result.result
			
			if data.has("projects"):
				projects = data.projects
			
			if data.has("components"):
				components = data.components
			
			if data.has("connections"):
				connections = data.connections
			
			print("Loaded visualization data with " + str(components.size()) + " components and " + 
				  str(connections.size()) + " connections")
			return true
	
	push_error("Failed to load visualization data")
	return false

func _calculate_layout():
	# Reset positions
	node_positions.clear()
	project_bounds.clear()
	
	# Sort projects
	var project_names = projects.keys()
	
	# Calculate component positions by project
	var y_offset = 100
	
	for project_name in project_names:
		var project = projects[project_name]
		var project_components = project.components
		
		# Calculate grid dimensions
		var component_count = project_components.size()
		var cols = ceil(sqrt(component_count))
		var rows = ceil(component_count / float(cols))
		
		# Create grid of positions
		var grid_width = cols * NODE_SPACING
		var grid_height = rows * NODE_SPACING
		
		# Store project boundary for drawing
		project_bounds[project_name] = {
			"x": 50,
			"y": y_offset - 50,
			"width": grid_width + 100,
			"height": grid_height + 100,
			"color": PROJECT_COLORS.get(project_name, Color(0.5, 0.5, 0.5))
		}
		
		# Position each component
		for i in range(project_components.size()):
			var component_id = project_components[i]
			
			# Calculate grid position
			var col = i % int(cols)
			var row = int(i / cols)
			
			var x = 100 + col * NODE_SPACING
			var y = y_offset + row * NODE_SPACING
			
			node_positions[component_id] = Vector2(x, y)
		
		# Increment y offset for next project
		y_offset += grid_height + PROJECT_SPACING

func _draw():
	# Apply zoom and pan
	var transform = Transform2D()
	transform = transform.scaled(Vector2(zoom_level, zoom_level))
	transform = transform.translated(pan_offset)
	
	# Draw project backgrounds
	for project_name in project_bounds:
		var bounds = project_bounds[project_name]
		var rect = Rect2(bounds.x, bounds.y, bounds.width, bounds.height)
		draw_rect(rect, bounds.color.darkened(0.7), false)
		draw_string(DynamicFont.new(), Vector2(bounds.x + 10, bounds.y + 30), 
					project_name, bounds.color.lightened(0.3))
	
	# Draw connections
	for connection in connections:
		if not node_positions.has(connection.source) or not node_positions.has(connection.target):
			continue
			
		var start_pos = node_positions[connection.source]
		var end_pos = node_positions[connection.target]
		var connection_type = connection.type
		
		var color = CONNECTION_COLORS.get(connection_type, Color(0.5, 0.5, 0.5, 0.5))
		
		# Highlight selected connections
		if selected_node != null and (connection.source == selected_node or connection.target == selected_node):
			color = color.lightened(0.3)
			draw_line(start_pos, end_pos, color, 3.0)
		else:
			draw_line(start_pos, end_pos, color, 1.5)
	
	# Draw component nodes
	for component in components:
		if not node_positions.has(component.id):
			continue
			
		var pos = node_positions[component.id]
		var project_name = component.project
		var color = PROJECT_COLORS.get(project_name, Color(0.5, 0.5, 0.5))
		
		# Highlight selected or hovered node
		if component.id == selected_node:
			draw_circle(pos, NODE_RADIUS + 4, color.lightened(0.3))
		elif component.id == hovered_node:
			draw_circle(pos, NODE_RADIUS + 2, color.lightened(0.2))
		
		draw_circle(pos, NODE_RADIUS, color)
		
		# Draw label
		var name = component.name
		draw_string(DynamicFont.new(), pos + Vector2(NODE_RADIUS + 5, 5), name, Color(1, 1, 1))

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			# Zoom in
			zoom_level = min(zoom_level * 1.1, 3.0)
			update()
			get_tree().set_input_as_handled()
		elif event.button_index == BUTTON_WHEEL_DOWN:
			# Zoom out
			zoom_level = max(zoom_level * 0.9, 0.3)
			update()
			get_tree().set_input_as_handled()
		elif event.button_index == BUTTON_LEFT:
			if event.pressed:
				# Start drag or select node
				dragging = true
				drag_start = event.position
				
				# Check for node selection
				var mouse_pos = (event.position - pan_offset) / zoom_level
				selected_node = _find_node_at_position(mouse_pos)
				
				if selected_node != null:
					emit_signal("node_selected", selected_node)
				
				update()
				get_tree().set_input_as_handled()
			else:
				# End drag
				dragging = false
				get_tree().set_input_as_handled()
	
	elif event is InputEventMouseMotion:
		if dragging:
			# Pan the view
			pan_offset += event.relative
			update()
			get_tree().set_input_as_handled()
		else:
			# Check for hover
			var mouse_pos = (event.position - pan_offset) / zoom_level
			var hover_node = _find_node_at_position(mouse_pos)
			
			if hover_node != hovered_node:
				hovered_node = hover_node
				update()
				get_tree().set_input_as_handled()

func _find_node_at_position(position):
	for component in components:
		if not node_positions.has(component.id):
			continue
			
		var node_pos = node_positions[component.id]
		var distance = position.distance_to(node_pos)
		
		if distance <= NODE_RADIUS:
			return component.id
	
	return null

# Connect to a UnifiedProjectConnector
func connect_to_connector(project_connector):
	connector = project_connector
	
	# Get visualization data directly from connector
	if connector != null:
		var topology = connector.get_connection_topology()
		
		projects = topology.projects
		
		components = []
		for component_id in topology.components:
			var component_info = topology.components[component_id]
			components.append({
				"id": component_id,
				"name": component_id.split("::")[1].get_file().get_basename(),
				"project": component_info.project,
				"type": component_info.type
			})
		
		connections = []
		for connection_id in topology.connections:
			var connection_info = topology.connections[connection_id]
			connections.append({
				"id": connection_id,
				"source": connection_info.source,
				"target": connection_info.target,
				"type": connection_info.type
			})
		
		# Recalculate layout
		_calculate_layout()
		update()

# Export the visualization to an image
func export_visualization(file_path):
	# Create a viewport to render the visualization
	var viewport = Viewport.new()
	viewport.size = Vector2(2000, 2000)
	viewport.transparent_bg = true
	viewport.render_target_v_flip = true
	add_child(viewport)
	
	# Create a copy of this node for rendering
	var vis_copy = duplicate()
	viewport.add_child(vis_copy)
	
	# Wait a frame for rendering
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	# Get the image
	var img = viewport.get_texture().get_data()
	img.flip_y()
	
	# Save the image
	if img.save_png(file_path) == OK:
		print("Visualization exported to: " + file_path)
	else:
		push_error("Failed to export visualization")
	
	# Clean up
	viewport.queue_free()
	
	return file_path

# Generate HTML visualization
func export_html_visualization(file_path):
	var html = """
<!DOCTYPE html>
<html>
<head>
    <title>Project Connections Visualization</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #222;
            color: #eee;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        h1 {
            color: #0af;
            border-bottom: 1px solid #444;
            padding-bottom: 10px;
        }
        .project {
            margin-bottom: 30px;
            padding: 15px;
            border-radius: 5px;
            background-color: #333;
        }
        .project-title {
            font-size: 20px;
            margin-bottom: 10px;
            font-weight: bold;
        }
        .component {
            display: inline-block;
            margin: 5px;
            padding: 8px 12px;
            border-radius: 20px;
            font-size: 14px;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .component:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }
        .connections {
            margin-top: 30px;
            padding: 15px;
            border-radius: 5px;
            background-color: #333;
        }
        .connection {
            margin: 5px 0;
            padding: 8px;
            border-radius: 3px;
            background-color: #444;
        }
        #details {
            position: fixed;
            top: 20px;
            right: 20px;
            width: 300px;
            padding: 15px;
            background-color: #333;
            border-radius: 5px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.2);
            display: none;
        }
        .color-legend {
            margin-top: 20px;
            display: flex;
            flex-wrap: wrap;
        }
        .legend-item {
            display: flex;
            align-items: center;
            margin-right: 15px;
            margin-bottom: 5px;
        }
        .legend-color {
            width: 15px;
            height: 15px;
            display: inline-block;
            margin-right: 5px;
            border-radius: 3px;
        }
        .stats {
            margin-top: 20px;
            padding: 15px;
            background-color: #333;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Project Connections Visualization</h1>
        
        <div class="stats">
            <h2>Statistics</h2>
            <div id="stats-content"></div>
        </div>
        
        <div class="color-legend">
            <h3>Connection Types:</h3>
            <div class="legend-item">
                <span class="legend-color" style="background-color: rgba(51, 153, 255, 0.8);"></span>
                <span>File Link</span>
            </div>
            <div class="legend-item">
                <span class="legend-color" style="background-color: rgba(51, 255, 51, 0.8);"></span>
                <span>Variable Mirror</span>
            </div>
            <div class="legend-item">
                <span class="legend-color" style="background-color: rgba(255, 204, 51, 0.8);"></span>
                <span>Signal Bridge</span>
            </div>
            <div class="legend-item">
                <span class="legend-color" style="background-color: rgba(204, 51, 255, 0.8);"></span>
                <span>System Link</span>
            </div>
            <div class="legend-item">
                <span class="legend-color" style="background-color: rgba(255, 51, 102, 0.8);"></span>
                <span>API Connector</span>
            </div>
        </div>
        
        <div id="projects"></div>
        
        <div class="connections">
            <h2>Connections</h2>
            <div id="connections-list"></div>
        </div>
    </div>
    
    <div id="details">
        <h3 id="detail-title">Component Details</h3>
        <div id="detail-content"></div>
    </div>
    
    <script>
        // Project data
        const projectData = {
            projects: {},
            components: [],
            connections: []
        };
        
        // Initialize with data
        function initializeVisualization() {
            // Set projects data
            """
	
	# Add projects data
	html += "projectData.projects = " + JSON.print(projects) + ";\n"
	
	# Add components data
	html += "projectData.components = " + JSON.print(components) + ";\n"
	
	# Add connections data
	html += "projectData.connections = " + JSON.print(connections) + ";\n"
	
	html += """
            renderVisualization();
        }
        
        function renderVisualization() {
            // Render projects and components
            const projectsContainer = document.getElementById('projects');
            projectsContainer.innerHTML = '';
            
            const projectColors = {
                "12_turns_system": "#3399ff",
                "LuminusOS": "#33ff99",
                "Eden_OS": "#ff9933",
                "Godot_Eden": "#cc33ff"
            };
            
            // Group components by project
            const componentsByProject = {};
            projectData.components.forEach(component => {
                if (!componentsByProject[component.project]) {
                    componentsByProject[component.project] = [];
                }
                componentsByProject[component.project].push(component);
            });
            
            // Render each project
            Object.keys(projectData.projects).forEach(projectName => {
                const projectComponents = componentsByProject[projectName] || [];
                const projectDiv = document.createElement('div');
                projectDiv.className = 'project';
                
                // Project header
                const projectTitle = document.createElement('div');
                projectTitle.className = 'project-title';
                projectTitle.style.color = projectColors[projectName] || '#ffffff';
                projectTitle.textContent = projectName + ` (${projectComponents.length} components)`;
                projectDiv.appendChild(projectTitle);
                
                // Components
                projectComponents.forEach(component => {
                    const componentEl = document.createElement('div');
                    componentEl.className = 'component';
                    componentEl.textContent = component.name;
                    componentEl.style.backgroundColor = projectColors[projectName] || '#555';
                    componentEl.dataset.id = component.id;
                    
                    // Show details on click
                    componentEl.addEventListener('click', () => showComponentDetails(component));
                    
                    projectDiv.appendChild(componentEl);
                });
                
                projectsContainer.appendChild(projectDiv);
            });
            
            // Render connections
            renderConnections();
            
            // Render stats
            renderStats();
        }
        
        function renderConnections() {
            const connectionsContainer = document.getElementById('connections-list');
            connectionsContainer.innerHTML = '';
            
            const connectionColors = {
                0: "rgba(51, 153, 255, 0.8)",  // FILE_LINK
                1: "rgba(51, 255, 51, 0.8)",   // VARIABLE_MIRROR
                2: "rgba(255, 204, 51, 0.8)",  // SIGNAL_BRIDGE
                3: "rgba(204, 51, 255, 0.8)",  // SYSTEM_LINK
                4: "rgba(255, 51, 102, 0.8)"   // API_CONNECTOR
            };
            
            const connectionTypes = {
                0: "File Link",
                1: "Variable Mirror",
                2: "Signal Bridge",
                3: "System Link",
                4: "API Connector"
            };
            
            // Get component map for lookup
            const componentMap = {};
            projectData.components.forEach(component => {
                componentMap[component.id] = component;
            });
            
            // Sort connections by type
            const sortedConnections = [...projectData.connections].sort((a, b) => a.type - b.type);
            
            sortedConnections.forEach(connection => {
                const sourceComponent = componentMap[connection.source] || { name: "Unknown", project: "Unknown" };
                const targetComponent = componentMap[connection.target] || { name: "Unknown", project: "Unknown" };
                
                const connectionEl = document.createElement('div');
                connectionEl.className = 'connection';
                connectionEl.style.borderLeft = `4px solid ${connectionColors[connection.type] || '#777'}`;
                
                connectionEl.innerHTML = `
                    <strong>${connectionTypes[connection.type] || "Unknown"}</strong>: 
                    <span onclick="highlightComponent('${connection.source}')" style="cursor:pointer;text-decoration:underline">
                        ${sourceComponent.name} (${sourceComponent.project})
                    </span> 
                    → 
                    <span onclick="highlightComponent('${connection.target}')" style="cursor:pointer;text-decoration:underline">
                        ${targetComponent.name} (${targetComponent.project})
                    </span>
                `;
                
                connectionsContainer.appendChild(connectionEl);
            });
        }
        
        function renderStats() {
            const statsContainer = document.getElementById('stats-content');
            
            // Count components per project
            const projectCounts = {};
            projectData.components.forEach(component => {
                projectCounts[component.project] = (projectCounts[component.project] || 0) + 1;
            });
            
            // Count connection types
            const connectionTypeCounts = {};
            projectData.connections.forEach(connection => {
                connectionTypeCounts[connection.type] = (connectionTypeCounts[connection.type] || 0) + 1;
            });
            
            // Count cross-project connections
            let crossProjectConnections = 0;
            projectData.connections.forEach(connection => {
                const sourceComponent = projectData.components.find(c => c.id === connection.source);
                const targetComponent = projectData.components.find(c => c.id === connection.target);
                
                if (sourceComponent && targetComponent && sourceComponent.project !== targetComponent.project) {
                    crossProjectConnections++;
                }
            });
            
            const connectionTypes = {
                0: "File Link",
                1: "Variable Mirror",
                2: "Signal Bridge",
                3: "System Link",
                4: "API Connector"
            };
            
            let statsHTML = `
                <div><strong>Total Components:</strong> ${projectData.components.length}</div>
                <div><strong>Total Connections:</strong> ${projectData.connections.length}</div>
                <div><strong>Cross-Project Connections:</strong> ${crossProjectConnections}</div>
                <br>
                <div><strong>Components by Project:</strong></div>
            `;
            
            Object.keys(projectCounts).forEach(project => {
                statsHTML += `<div>${project}: ${projectCounts[project]}</div>`;
            });
            
            statsHTML += `<br><div><strong>Connections by Type:</strong></div>`;
            
            Object.keys(connectionTypeCounts).forEach(type => {
                statsHTML += `<div>${connectionTypes[type] || "Unknown"}: ${connectionTypeCounts[type]}</div>`;
            });
            
            statsContainer.innerHTML = statsHTML;
        }
        
        function showComponentDetails(component) {
            const detailsPanel = document.getElementById('details');
            const detailTitle = document.getElementById('detail-title');
            const detailContent = document.getElementById('detail-content');
            
            // Find connections for this component
            const relatedConnections = projectData.connections.filter(
                conn => conn.source === component.id || conn.target === component.id
            );
            
            // Show component details
            detailTitle.textContent = component.name;
            
            let contentHTML = `
                <div><strong>ID:</strong> ${component.id}</div>
                <div><strong>Project:</strong> ${component.project}</div>
                <div><strong>Type:</strong> ${component.type || "Unknown"}</div>
                <br>
                <div><strong>Connections (${relatedConnections.length}):</strong></div>
            `;
            
            const connectionTypes = {
                0: "File Link",
                1: "Variable Mirror",
                2: "Signal Bridge",
                3: "System Link",
                4: "API Connector"
            };
            
            // Get component map for lookup
            const componentMap = {};
            projectData.components.forEach(c => {
                componentMap[c.id] = c;
            });
            
            relatedConnections.forEach(conn => {
                const isSource = conn.source === component.id;
                const otherComponentId = isSource ? conn.target : conn.source;
                const otherComponent = componentMap[otherComponentId] || { name: "Unknown", project: "Unknown" };
                const direction = isSource ? "→" : "←";
                
                contentHTML += `
                    <div>
                        <span style="color:#aaa">${connectionTypes[conn.type] || "Unknown"}</span> 
                        ${direction} 
                        <span onclick="highlightComponent('${otherComponentId}')" style="cursor:pointer;text-decoration:underline">
                            ${otherComponent.name} (${otherComponent.project})
                        </span>
                    </div>
                `;
            });
            
            detailContent.innerHTML = contentHTML;
            detailsPanel.style.display = 'block';
        }
        
        function highlightComponent(componentId) {
            // Find the component
            const component = projectData.components.find(c => c.id === componentId);
            if (component) {
                showComponentDetails(component);
                
                // Scroll to the component's project
                const projectSections = document.querySelectorAll('.project');
                for (const section of projectSections) {
                    if (section.querySelector('.project-title').textContent.includes(component.project)) {
                        section.scrollIntoView({ behavior: 'smooth', block: 'start' });
                        break;
                    }
                }
                
                // Highlight the component
                const componentEl = document.querySelector(`.component[data-id="${componentId}"]`);
                if (componentEl) {
                    componentEl.style.boxShadow = '0 0 0 3px #fff';
                    setTimeout(() => {
                        componentEl.style.boxShadow = '';
                    }, 2000);
                }
            }
        }
        
        // Close details panel when clicking elsewhere
        document.addEventListener('click', function(event) {
            const detailsPanel = document.getElementById('details');
            if (!event.target.closest('#details') && 
                !event.target.closest('.component') &&
                !event.target.closest('.connection')) {
                detailsPanel.style.display = 'none';
            }
        });
        
        // Initialize on load
        window.addEventListener('load', initializeVisualization);
    </script>
</body>
</html>
"""
	
	# Write the HTML file
	var file = File.new()
	if file.open(file_path, File.WRITE) == OK:
		file.store_string(html)
		file.close()
		print("HTML visualization exported to: " + file_path)
		return true
	else:
		push_error("Failed to export HTML visualization")
		return false