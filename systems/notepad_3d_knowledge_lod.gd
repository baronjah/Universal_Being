# ==================================================
# NOTEPAD 3D - KNOWLEDGE LOD SYSTEM
# PURPOSE: Navigate knowledge with LOD like 3D graphics
# VISION: Chunks, occlusion culling, LOD for knowledge performance
# ==================================================

extends UniversalBeing
class_name Notepad3DKnowledgeLOD

## 📚 3D KNOWLEDGE NAVIGATION WITH PERFORMANCE OPTIMIZATION
## Knowledge LOD: File name → First lines → Full content
## Knowledge Chunks: Spatial organization like 3D world chunks
## Knowledge Occlusion: Don't load what's "behind" current focus

# ===== KNOWLEDGE LOD SYSTEM =====

enum KnowledgeLOD {
	ULTRA_LOW,    # Just file names (like distant 3D objects)
	LOW,          # File name + first line (like medium distance)
	MEDIUM,       # File name + first paragraph (like close objects)
	HIGH,         # File name + summary + headings (like near objects)
	ULTRA_HIGH    # Full content (like objects you're touching)
}

enum KnowledgeType {
	MARKDOWN,     # .md files
	TEXT,         # .txt files  
	GDSCRIPT,     # .gd files
	JSON,         # .json files
	SHADER,       # .gdshader files
	DIRECTORY     # Folders
}

# Knowledge Spaces (Your main directories)
var knowledge_spaces: Dictionary = {
	"claude_desktop": "/mnt/c/Users/Percision 15/Universal_Being/docs/claude_desktop",
	"claude_home_mds": "/mnt/c/Users/Percision 15/Universal_Being/docs/claude_home_mds", 
	"claude_memory": "/mnt/c/Users/Percision 15/Universal_Being/docs/Claude_Memory_and_Memories",
	"jsh": "/mnt/c/Users/Percision 15/Universal_Being/docs/jsh",
	"root_docs": "/mnt/c/Users/Percision 15/Universal_Being/docs",
	"root": "/mnt/c/Users/Percision 15/Universal_Being"
}

# Knowledge Chunks (Like 3D world chunks)
var knowledge_chunks: Dictionary = {}
var active_chunks: Array[String] = []
var chunk_size: int = 50  # Files per chunk

# LOD Management
var current_lod_level: KnowledgeLOD = KnowledgeLOD.MEDIUM
var lod_distances: Dictionary = {
	KnowledgeLOD.ULTRA_LOW: 100.0,   # Very far
	KnowledgeLOD.LOW: 50.0,          # Far  
	KnowledgeLOD.MEDIUM: 25.0,       # Medium
	KnowledgeLOD.HIGH: 10.0,         # Close
	KnowledgeLOD.ULTRA_HIGH: 5.0     # Very close
}

# Knowledge Cache (Performance optimization)
var knowledge_cache: Dictionary = {}
var cache_max_size: int = 1000
var cache_access_times: Dictionary = {}

# Current Navigation State
var current_focus: String = ""
var current_space: String = "claude_desktop"
var navigation_history: Array[String] = []
var search_results: Array[Dictionary] = []

# 3D Visualization
var knowledge_nodes: Dictionary = {}
var spatial_layout: Dictionary = {}

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "notepad_3d_knowledge_lod"
	being_name = "Knowledge Navigator 3D"
	consciousness_level = 4
	
	setup_knowledge_chunks()
	initialize_spatial_layout()
	print("📚 Notepad 3D Knowledge LOD: Ready for spatial knowledge navigation!")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Load initial knowledge space
	switch_to_knowledge_space("claude_desktop")
	setup_3d_visualization()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update LOD based on focus
	update_knowledge_lod(delta)
	
	# Manage knowledge chunks (like 3D world chunks)
	update_active_chunks()
	
	# Clean cache (like texture memory management)
	manage_knowledge_cache()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: switch_to_knowledge_space("claude_desktop")
			KEY_2: switch_to_knowledge_space("claude_home_mds") 
			KEY_3: switch_to_knowledge_space("claude_memory")
			KEY_4: switch_to_knowledge_space("jsh")
			KEY_5: switch_to_knowledge_space("root_docs")
			KEY_TAB: cycle_lod_level()
			KEY_F: search_knowledge()
			KEY_R: reload_current_space()

func pentagon_sewers() -> void:
	save_navigation_state()
	super.pentagon_sewers()

# ===== KNOWLEDGE CHUNKING SYSTEM =====

func setup_knowledge_chunks() -> void:
	"""Setup knowledge chunks like 3D world chunks for performance"""
	for space_name in knowledge_spaces:
		var space_path = knowledge_spaces[space_name]
		var files = scan_knowledge_space(space_path)
		
		# Divide into chunks
		var chunks = divide_into_chunks(files, chunk_size)
		knowledge_chunks[space_name] = chunks
		
		print("📦 Knowledge space '%s': %d files in %d chunks" % [space_name, files.size(), chunks.size()])

func divide_into_chunks(files: Array, size: int) -> Array:
	"""Divide files into chunks for performance (like 3D chunk loading)"""
	var chunks = []
	var current_chunk = []
	
	for file in files:
		current_chunk.append(file)
		if current_chunk.size() >= size:
			chunks.append(current_chunk)
			current_chunk = []
	
	if not current_chunk.is_empty():
		chunks.append(current_chunk)
	
	return chunks

func update_active_chunks() -> void:
	"""Update which knowledge chunks are active (like 3D frustum culling)"""
	var focus_chunk = get_chunk_containing_focus()
	var new_active = [focus_chunk]
	
	# Add adjacent chunks (like loading neighboring 3D chunks)
	var adjacent = get_adjacent_chunks(focus_chunk)
	new_active.append_array(adjacent)
	
	# Unload distant chunks
	for chunk_id in active_chunks:
		if chunk_id not in new_active:
			unload_knowledge_chunk(chunk_id)
	
	# Load new chunks
	for chunk_id in new_active:
		if chunk_id not in active_chunks:
			load_knowledge_chunk(chunk_id)
	
	active_chunks = new_active

func get_chunk_containing_focus() -> String:
	"""Get chunk that contains current focus"""
	# Implementation depends on how we spatially organize knowledge
	return "chunk_0"  # Simplified for now

func get_adjacent_chunks(chunk_id: String) -> Array:
	"""Get chunks adjacent to given chunk (like 3D neighbor chunks)"""
	# Return spatially adjacent knowledge chunks
	return ["chunk_1", "chunk_2"]  # Simplified

# ===== KNOWLEDGE LOD SYSTEM =====

func update_knowledge_lod(delta: float) -> void:
	"""Update knowledge LOD based on focus distance (like 3D LOD)"""
	var distance_to_focus = calculate_knowledge_distance(current_focus)
	var new_lod = calculate_lod_level(distance_to_focus)
	
	if new_lod != current_lod_level:
		current_lod_level = new_lod
		refresh_visible_knowledge()
		print("📊 Knowledge LOD changed to: %s (distance: %.1f)" % [KnowledgeLOD.keys()[new_lod], distance_to_focus])

func calculate_knowledge_distance(focus_item: String) -> float:
	"""Calculate 'distance' to knowledge item (relevance/importance)"""
	if focus_item.is_empty():
		return 100.0
	
	# Distance based on:
	# - How recently accessed
	# - How related to current task
	# - File size (larger = more detailed, closer)
	var base_distance = 25.0
	
	# Recently accessed items are "closer"
	if focus_item in cache_access_times:
		var time_since_access = Time.get_unix_time_from_system() - cache_access_times[focus_item]
		base_distance = max(5.0, base_distance - (100.0 / (time_since_access + 1.0)))
	
	return base_distance

func calculate_lod_level(distance: float) -> KnowledgeLOD:
	"""Calculate LOD level based on distance (like 3D LOD calculation)"""
	if distance <= lod_distances[KnowledgeLOD.ULTRA_HIGH]:
		return KnowledgeLOD.ULTRA_HIGH
	elif distance <= lod_distances[KnowledgeLOD.HIGH]:
		return KnowledgeLOD.HIGH
	elif distance <= lod_distances[KnowledgeLOD.MEDIUM]:
		return KnowledgeLOD.MEDIUM
	elif distance <= lod_distances[KnowledgeLOD.LOW]:
		return KnowledgeLOD.LOW
	else:
		return KnowledgeLOD.ULTRA_LOW

func get_knowledge_at_lod(file_path: String, lod: KnowledgeLOD) -> Dictionary:
	"""Get knowledge content at specific LOD level"""
	var cache_key = file_path + "_" + str(lod)
	
	# Check cache first (like texture cache)
	if cache_key in knowledge_cache:
		cache_access_times[cache_key] = Time.get_unix_time_from_system()
		return knowledge_cache[cache_key]
	
	var content = load_knowledge_content(file_path, lod)
	
	# Cache the result
	knowledge_cache[cache_key] = content
	cache_access_times[cache_key] = Time.get_unix_time_from_system()
	
	return content

func load_knowledge_content(file_path: String, lod: KnowledgeLOD) -> Dictionary:
	"""Load knowledge content at specific detail level"""
	if not FileAccess.file_exists(file_path):
		return {"error": "File not found", "path": file_path}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return {"error": "Cannot open file", "path": file_path}
	
	var full_content = file.get_as_text()
	file.close()
	
	var result = {
		"path": file_path,
		"name": file_path.get_file(),
		"type": detect_knowledge_type(file_path),
		"size": full_content.length(),
		"lod_level": lod
	}
	
	match lod:
		KnowledgeLOD.ULTRA_LOW:
			# Just file name (like distant 3D object)
			result.content = result.name
			result.display = result.name
		
		KnowledgeLOD.LOW:
			# File name + first line
			var lines = full_content.split("\n", false, 1)
			result.content = lines[0] if lines.size() > 0 else ""
			result.display = "%s: %s" % [result.name, result.content.substr(0, 50)]
		
		KnowledgeLOD.MEDIUM:
			# File name + first paragraph
			var paragraphs = full_content.split("\n\n", false, 1)
			result.content = paragraphs[0] if paragraphs.size() > 0 else full_content.substr(0, 200)
			result.display = "%s\n%s..." % [result.name, result.content.substr(0, 150)]
		
		KnowledgeLOD.HIGH:
			# File name + summary + headings
			result.content = extract_summary_and_headings(full_content)
			result.display = "%s\n%s" % [result.name, result.content]
		
		KnowledgeLOD.ULTRA_HIGH:
			# Full content (like touching a 3D object)
			result.content = full_content
			result.display = full_content
	
	return result

func detect_knowledge_type(file_path: String) -> KnowledgeType:
	"""Detect type of knowledge file"""
	var extension = file_path.get_extension().to_lower()
	match extension:
		"md": return KnowledgeType.MARKDOWN
		"txt": return KnowledgeType.TEXT
		"gd": return KnowledgeType.GDSCRIPT
		"json": return KnowledgeType.JSON
		"gdshader": return KnowledgeType.SHADER
		_: return KnowledgeType.TEXT

func extract_summary_and_headings(content: String) -> String:
	"""Extract summary and headings from content (like LOD mesh simplification)"""
	var lines = content.split("\n")
	var summary = ""
	var headings = []
	
	for line in lines:
		line = line.strip_edges()
		# Markdown headings
		if line.begins_with("#"):
			headings.append(line)
		# First paragraph as summary
		elif summary.is_empty() and line.length() > 0 and not line.begins_with("#"):
			summary = line.substr(0, 100) + "..."
	
	var result = ""
	if not summary.is_empty():
		result += "Summary: " + summary + "\n\n"
	if not headings.is_empty():
		result += "Headings:\n" + "\n".join(headings)
	
	return result

# ===== KNOWLEDGE SPACE NAVIGATION =====

func switch_to_knowledge_space(space_name: String) -> void:
	"""Switch to different knowledge space (like changing 3D levels)"""
	if space_name not in knowledge_spaces:
		print("❌ Unknown knowledge space: %s" % space_name)
		return
	
	current_space = space_name
	navigation_history.append(space_name)
	
	# Clear current focus
	current_focus = ""
	
	# Load the space
	load_knowledge_space(space_name)
	
	print("🌌 Switched to knowledge space: %s" % space_name)

func load_knowledge_space(space_name: String) -> void:
	"""Load knowledge space with LOD (like loading 3D level)"""
	var space_path = knowledge_spaces[space_name]
	var files = scan_knowledge_space(space_path)
	
	print("📁 Loading knowledge space '%s': %d files" % [space_name, files.size()])
	
	# Create 3D spatial layout
	create_spatial_layout(space_name, files)

func scan_knowledge_space(path: String) -> Array:
	"""Scan directory for knowledge files (like scanning 3D world for objects)"""
	var files = []
	var dir = DirAccess.open(path)
	
	if not dir:
		print("❌ Cannot open directory: %s" % path)
		return files
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name
		
		if dir.current_is_dir():
			# Recursively scan subdirectories
			var sub_files = scan_knowledge_space(full_path)
			files.append_array(sub_files)
		else:
			# Add file
			files.append({
				"path": full_path,
				"name": file_name,
				"type": detect_knowledge_type(file_name),
				"directory": path
			})
		
		file_name = dir.get_next()
	
	return files

# ===== 3D SPATIAL LAYOUT =====

func initialize_spatial_layout() -> void:
	"""Initialize 3D spatial organization of knowledge"""
	spatial_layout = {
		"grid_size": Vector3(10, 10, 10),
		"cell_size": Vector3(5, 5, 5),
		"origin": Vector3.ZERO
	}

func create_spatial_layout(space_name: String, files: Array) -> void:
	"""Create 3D spatial layout for knowledge files (like 3D world generation)"""
	var grid_size = spatial_layout.grid_size
	var cell_size = spatial_layout.cell_size
	
	# Organize files in 3D grid by type and importance
	var position = Vector3.ZERO
	var row = 0
	var col = 0
	
	for file in files:
		# Position based on file type and alphabetical order
		var type_offset = Vector3(
			int(file.type) * cell_size.x,
			0,
			0
		)
		
		var grid_pos = Vector3(
			col * cell_size.x,
			0,
			row * cell_size.z
		) + type_offset
		
		file.spatial_position = grid_pos
		
		# Create 3D visualization node
		create_knowledge_node(file)
		
		col += 1
		if col >= grid_size.x:
			col = 0
			row += 1

func create_knowledge_node(file_data: Dictionary) -> void:
	"""Create 3D visual representation of knowledge file"""
	var node = MeshInstance3D.new()
	node.name = "Knowledge_" + file_data.name
	node.position = file_data.spatial_position
	
	# Different shapes for different file types
	match file_data.type:
		KnowledgeType.MARKDOWN:
			var mesh = BoxMesh.new()
			mesh.size = Vector3(1, 2, 1)
			node.mesh = mesh
		KnowledgeType.GDSCRIPT:
			var mesh = CylinderMesh.new()
			mesh.height = 2
			node.mesh = mesh
		KnowledgeType.JSON:
			var mesh = SphereMesh.new()
			node.mesh = mesh
		_:
			var mesh = CapsuleMesh.new()
			node.mesh = mesh
	
	# Color based on importance/recency
	var material = StandardMaterial3D.new()
	material.albedo_color = get_knowledge_color(file_data)
	node.material_override = material
	
	# Add to scene
	add_child(node)
	knowledge_nodes[file_data.path] = node

func get_knowledge_color(file_data: Dictionary) -> Color:
	"""Get color representing knowledge importance/type"""
	match file_data.type:
		KnowledgeType.MARKDOWN: return Color.CYAN
		KnowledgeType.GDSCRIPT: return Color.GREEN
		KnowledgeType.JSON: return Color.YELLOW
		KnowledgeType.SHADER: return Color.MAGENTA
		_: return Color.WHITE

# ===== CACHE MANAGEMENT =====

func manage_knowledge_cache() -> void:
	"""Manage knowledge cache (like texture memory management)"""
	if knowledge_cache.size() > cache_max_size:
		# Remove least recently used items
		var sorted_items = []
		for key in knowledge_cache:
			var access_time = cache_access_times.get(key, 0)
			sorted_items.append({"key": key, "time": access_time})
		
		sorted_items.sort_custom(func(a, b): return a.time < b.time)
		
		# Remove oldest 25% of items
		var remove_count = cache_max_size / 4
		for i in range(remove_count):
			var item = sorted_items[i]
			knowledge_cache.erase(item.key)
			cache_access_times.erase(item.key)

func load_knowledge_chunk(chunk_id: String) -> void:
	"""Load knowledge chunk into memory (like loading 3D chunk)"""
	print("📦 Loading knowledge chunk: %s" % chunk_id)

func unload_knowledge_chunk(chunk_id: String) -> void:
	"""Unload knowledge chunk from memory (like unloading distant 3D chunk)"""
	print("📦 Unloading knowledge chunk: %s" % chunk_id)

# ===== USER INTERFACE =====

func cycle_lod_level() -> void:
	"""Cycle through LOD levels (like graphics settings)"""
	var current_index = current_lod_level
	current_index = (current_index + 1) % KnowledgeLOD.size()
	current_lod_level = current_index
	refresh_visible_knowledge()
	print("📊 LOD Level: %s" % KnowledgeLOD.keys()[current_lod_level])

func refresh_visible_knowledge() -> void:
	"""Refresh visible knowledge at current LOD"""
	# Update all visible knowledge nodes with current LOD
	for file_path in knowledge_nodes:
		update_knowledge_node_lod(file_path)

func update_knowledge_node_lod(file_path: String) -> void:
	"""Update visual representation based on LOD"""
	var node = knowledge_nodes[file_path]
	if not node:
		return
	
	# Adjust node detail based on LOD
	match current_lod_level:
		KnowledgeLOD.ULTRA_LOW:
			node.scale = Vector3.ONE * 0.5
		KnowledgeLOD.LOW:
			node.scale = Vector3.ONE * 0.7
		KnowledgeLOD.MEDIUM:
			node.scale = Vector3.ONE
		KnowledgeLOD.HIGH:
			node.scale = Vector3.ONE * 1.2
		KnowledgeLOD.ULTRA_HIGH:
			node.scale = Vector3.ONE * 1.5

func search_knowledge() -> void:
	"""Search through knowledge (like spatial query)"""
	print("🔍 Knowledge search not implemented yet")

func reload_current_space() -> void:
	"""Reload current knowledge space"""
	load_knowledge_space(current_space)

# ===== SAVE/LOAD =====

func save_navigation_state() -> void:
	"""Save navigation state"""
	var state = {
		"current_space": current_space,
		"current_focus": current_focus,
		"history": navigation_history,
		"lod_level": current_lod_level
	}
	
	var file = FileAccess.open("user://notepad3d_state.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(state))
		file.close()

# ===== CONSOLE INTEGRATION =====

func get_knowledge_status() -> String:
	"""Get current knowledge navigation status"""
	return """
📚 NOTEPAD 3D KNOWLEDGE LOD STATUS

Current Space: %s
Current Focus: %s
LOD Level: %s
Active Chunks: %d
Cache Size: %d/%d
Knowledge Nodes: %d

Available Spaces:
1. claude_desktop (%d chunks)
2. claude_home_mds 
3. claude_memory
4. jsh
5. root_docs

Controls:
1-5: Switch knowledge space
Tab: Cycle LOD level
F: Search knowledge
R: Reload space
""" % [
	current_space,
	current_focus if current_focus else "None",
	KnowledgeLOD.keys()[current_lod_level],
	active_chunks.size(),
	knowledge_cache.size(),
	cache_max_size,
	knowledge_nodes.size(),
	knowledge_chunks.get(current_space, []).size()
]