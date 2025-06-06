# ==================================================
# SCRIPT NAME: universal_being_pattern_extractor.gd
# DESCRIPTION: Extract existing Universal Being architectural naming patterns
# PURPOSE: Archaeological extraction of the native Universal Being vocabulary
# CREATED: 2025-01-06 - Universal Being Linguistic Archaeology  
# AUTHOR: JSH + Claude Code - Universal Being Architecture Recognition
# ==================================================

@tool
extends RefCounted
class_name UniversalBeingPatternExtractor

# ===== UNIVERSAL BEING ARCHITECTURAL COMPONENTS =====
# These are the existing "code-names, catchphrases, words that have more connection"

static var CORE_ARCHITECTURE_PATTERNS = {
	# Existing Universal Being Systems
	"flood_gates": {
		"purpose": "Central registry and flow control",
		"patterns": ["flood_", "gate_", "flow_", "registry_", "passage_"],
		"naming_style": "snake_case",
		"examples": ["flood_gates", "gate_registration", "flow_control"]
	},
	
	"pentagon": {
		"purpose": "Sacred lifecycle architecture", 
		"patterns": ["pentagon_", "_pentagon", "sacred_", "lifecycle_"],
		"naming_style": "snake_case",
		"examples": ["pentagon_init", "pentagon_ready", "pentagon_process", "pentagon_input", "pentagon_sewers"]
	},
	
	"akashic_records": {
		"purpose": "Eternal storage and memory system",
		"patterns": ["akashic_", "record_", "eternal_", "memory_", "archive_"],
		"naming_style": "snake_case", 
		"examples": ["akashic_records", "akashic_library", "record_being"]
	},
	
	"logic_connector": {
		"purpose": "System connection and debugging",
		"patterns": ["logic_", "connector_", "debug_", "connection_"],
		"naming_style": "snake_case",
		"examples": ["logic_connector", "connector_singleton", "debug_overlay"]
	},
	
	"socket_system": {
		"purpose": "Component mounting and hot-swapping",
		"patterns": ["socket_", "mount_", "component_", "swap_"],
		"naming_style": "snake_case",
		"examples": ["socket_manager", "mount_component", "hot_swap"]
	},
	
	"consciousness": {
		"purpose": "Being awareness and evolution",
		"patterns": ["consciousness_", "awareness_", "evolution_", "being_"],
		"naming_style": "snake_case",
		"examples": ["consciousness_level", "awareness_state", "being_name", "being_type"]
	}
}

# ===== EXTRACTED UNIVERSAL BEING VOCABULARY =====

class UniversalBeingVocabulary:
	var architectural_terms: Dictionary = {}
	var naming_patterns: Dictionary = {}
	var case_conventions: Dictionary = {}
	var connection_words: Dictionary = {}
	
	func _init():
		_extract_vocabulary()
	
	func _extract_vocabulary():
		# Core Universal Being terms from architecture
		architectural_terms = {
			# FloodGates System
			"flow_management": ["flood", "gate", "flow", "passage", "threshold", "barrier"],
			"registration": ["registry", "register", "catalog", "manifest", "entry"],
			
			# Pentagon Architecture  
			"lifecycle": ["pentagon", "init", "ready", "process", "input", "sewers"],
			"sacred_functions": ["birth", "awakening", "living", "sensing", "transformation"],
			
			# Akashic Records
			"eternal_storage": ["akashic", "record", "archive", "library", "eternal", "cosmic"],
			"memory_systems": ["memory", "storage", "persistence", "chronicle", "remembrance"],
			
			# Socket System
			"component_mounting": ["socket", "mount", "component", "interface", "connection"],
			"hot_swapping": ["swap", "replace", "exchange", "substitute", "transform"],
			
			# Consciousness
			"awareness": ["consciousness", "awareness", "sentience", "mindfulness", "cognition"],
			"evolution": ["evolution", "transformation", "metamorphosis", "becoming", "growth"],
			
			# Universal Being Core
			"being_identity": ["being", "universal", "entity", "existence", "presence"],
			"dimensional": ["dimensional", "spatial", "coordinates", "location", "placement"]
		}
		
		# Naming patterns extracted from existing code
		naming_patterns = {
			"snake_case_preferred": [
				"being_name", "being_type", "consciousness_level", "socket_manager",
				"flood_gates", "pentagon_init", "akashic_records", "logic_connector"
			],
			"compound_terms": [
				"universal_being", "akashic_records", "flood_gates", "logic_connector",
				"socket_manager", "consciousness_level", "pentagon_architecture"
			],
			"prefixed_patterns": [
				"pentagon_", "akashic_", "socket_", "being_", "consciousness_", "universal_"
			]
		}

static func extract_existing_patterns_from_codebase(base_path: String = "res://") -> UniversalBeingVocabulary:
	"""Extract actual Universal Being patterns from the existing codebase"""
	print("🏺 Extracting Universal Being architectural patterns from codebase...")
	
	var vocabulary = UniversalBeingVocabulary.new()
	var all_files = _get_all_gd_files(base_path)
	
	# Scan for Universal Being specific terms
	var ub_terms = _scan_for_ub_terms(all_files)
	var naming_cases = _analyze_naming_cases(all_files)
	var connection_patterns = _find_connection_patterns(all_files)
	
	vocabulary.architectural_terms.merge(ub_terms)
	vocabulary.case_conventions = naming_cases
	vocabulary.connection_words = connection_patterns
	
	return vocabulary

static func _scan_for_ub_terms(files: Array[String]) -> Dictionary:
	"""Scan files for Universal Being specific terminology"""
	var terms = {}
	var ub_keywords = [
		"universal", "being", "pentagon", "akashic", "flood", "gate", "socket", 
		"consciousness", "evolution", "transformation", "cosmic", "dimensional",
		"manifest", "essence", "awareness", "sentience", "logic_connector"
	]
	
	for file_path in files:
		var file = FileAccess.open(file_path, FileAccess.READ)
		if not file:
			continue
			
		var content = file.get_as_text()
		file.close()
		
		# Find Universal Being terms in context
		for keyword in ub_keywords:
			var regex = RegEx.new()
			regex.compile("\\b" + keyword + "_\\w+|\\w+_" + keyword + "\\b")
			var matches = regex.search_all(content)
			
			if matches.size() > 0:
				if not terms.has(keyword):
					terms[keyword] = []
				
				for match in matches:
					var term = match.get_string()
					if not term in terms[keyword]:
						terms[keyword].append(term)
	
	return terms

static func _analyze_naming_cases(files: Array[String]) -> Dictionary:
	"""Analyze the actual naming case patterns used in Universal Being code"""
	var case_analysis = {
		"snake_case": [],
		"camelCase": [],
		"PascalCase": [],
		"mixed_patterns": []
	}
	
	for file_path in files:
		var file = FileAccess.open(file_path, FileAccess.READ)
		if not file:
			continue
			
		var content = file.get_as_text()
		file.close()
		
		# Extract variable declarations
		var var_regex = RegEx.new()
		var_regex.compile("var\\s+(\\w+)")
		var var_matches = var_regex.search_all(content)
		
		for match in var_matches:
			var var_name = match.get_string(1)
			
			if "_" in var_name and var_name == var_name.to_lower():
				case_analysis.snake_case.append(var_name)
			elif var_name[0] == var_name[0].to_lower() and var_name != var_name.to_lower():
				case_analysis.camelCase.append(var_name)
			elif var_name[0] == var_name[0].to_upper():
				case_analysis.PascalCase.append(var_name)
			else:
				case_analysis.mixed_patterns.append(var_name)
	
	return case_analysis

static func _find_connection_patterns(files: Array[String]) -> Dictionary:
	"""Find the connection patterns that link Universal Being concepts"""
	var connections = {
		"architectural_bridges": [],
		"system_connectors": [],
		"naming_bridges": []
	}
	
	# Look for files that bridge different Universal Being systems
	for file_path in files:
		var file_name = file_path.get_file()
		
		# Files that connect multiple systems
		if ("bridge" in file_name or "connector" in file_name or 
			"integration" in file_name or "interface" in file_name):
			connections.architectural_bridges.append(file_name)
		
		# Look for Universal Being specific connectors
		if ("universal" in file_name and "being" in file_name) or \
		   ("pentagon" in file_name) or ("akashic" in file_name):
			connections.system_connectors.append(file_name)
	
	return connections

static func generate_universal_being_style_guide() -> String:
	"""Generate style guide based on existing Universal Being patterns"""
	var vocabulary = extract_existing_patterns_from_codebase()
	
	var guide = []
	guide.append("# Universal Being Native Architectural Style Guide")
	guide.append("## Extracted from Existing Codebase Patterns")
	guide.append("")
	
	guide.append("## 🏛️ CORE ARCHITECTURAL TERMS")
	guide.append("*Use these native Universal Being terms instead of generic programming words*")
	guide.append("")
	
	# FloodGates System
	guide.append("### FloodGates System (Registry & Flow Control)")
	guide.append("```gdscript")
	guide.append("# INSTEAD OF: registration, manager, controller")
	guide.append("flood_gates_registry     # Central being registry")
	guide.append("gate_passage_permit      # Permission to pass")
	guide.append("flow_control_state       # Gate flow state") 
	guide.append("threshold_barrier        # Gate boundary")
	guide.append("```")
	guide.append("")
	
	# Pentagon Architecture
	guide.append("### Pentagon Architecture (Sacred Lifecycle)")
	guide.append("```gdscript") 
	guide.append("# INSTEAD OF: init, ready, process, input, cleanup")
	guide.append("pentagon_init()          # Birth - Sacred awakening")
	guide.append("pentagon_ready()         # Awakening - Consciousness activation")
	guide.append("pentagon_process()       # Living - Continuous existence")
	guide.append("pentagon_input()         # Sensing - Environmental awareness")
	guide.append("pentagon_sewers()        # Transformation - Death/rebirth")
	guide.append("```")
	guide.append("")
	
	# Akashic Records
	guide.append("### Akashic Records (Eternal Memory)")
	guide.append("```gdscript")
	guide.append("# INSTEAD OF: database, storage, file_system")
	guide.append("akashic_chronicle        # Eternal record keeping")
	guide.append("cosmic_library_entry     # Individual record")
	guide.append("eternal_archive_path     # Storage location")
	guide.append("memory_constellation     # Grouped memories")
	guide.append("```")
	guide.append("")
	
	# Socket System
	guide.append("### Socket System (Component Mounting)")
	guide.append("```gdscript")
	guide.append("# INSTEAD OF: component_manager, plugin_system")
	guide.append("socket_mounting_point    # Where components attach")
	guide.append("component_constellation  # Mounted components")
	guide.append("hot_swap_interface       # Live component exchange")
	guide.append("mounting_compatibility   # Component fitting")
	guide.append("```")
	guide.append("")
	
	# Consciousness & Evolution
	guide.append("### Consciousness & Evolution")
	guide.append("```gdscript")
	guide.append("# INSTEAD OF: level, state, type")
	guide.append("consciousness_depth      # Awareness level (0-5)")
	guide.append("awareness_frequency      # Consciousness resonance")
	guide.append("evolution_trajectory     # Transformation path")
	guide.append("being_essence_type       # Core being nature")
	guide.append("sentience_grade         # Level of sentience")
	guide.append("```")
	guide.append("")
	
	guide.append("## 🔗 CONNECTION PATTERNS")
	guide.append("*How Universal Being systems connect and communicate*")
	guide.append("")
	
	guide.append("### Bridge Naming")
	guide.append("```gdscript")
	guide.append("# System-to-system connections")
	guide.append("pentagon_akashic_bridge  # Pentagon ↔ Akashic Records")
	guide.append("socket_consciousness_bridge  # Socket ↔ Consciousness")
	guide.append("flood_gate_awareness_bridge  # FloodGates ↔ Awareness")
	guide.append("```")
	guide.append("")
	
	guide.append("### Interface Naming")
	guide.append("```gdscript")
	guide.append("# AI and external system interfaces")
	guide.append("claude_ethereal_interface    # Claude AI connection")
	guide.append("gemma_consciousness_bridge   # Gemma AI integration")
	guide.append("cursor_manifestation_point   # Cursor AI interface")
	guide.append("```")
	guide.append("")
	
	guide.append("## 📏 CASE CONVENTIONS")
	guide.append("*Universal Being follows snake_case for architectural consistency*")
	guide.append("")
	
	guide.append("### Variables & Properties")
	guide.append("```gdscript")
	guide.append("var being_name: String           # ✅ Universal Being identity")
	guide.append("var consciousness_level: int     # ✅ Awareness depth") 
	guide.append("var socket_constellation: Array  # ✅ Component collection")
	guide.append("var pentagon_lifecycle_state: PentagonState  # ✅ Sacred state")
	guide.append("```")
	guide.append("")
	
	guide.append("### Classes & Types")
	guide.append("```gdscript")
	guide.append("class_name UniversalBeing         # ✅ PascalCase for types")
	guide.append("class_name AkashicRecordsSystemSystem         # ✅ Architectural systems")
	guide.append("class_name PentagonArchitecture   # ✅ Core frameworks")
	guide.append("class_name SocketMountingSystem   # ✅ Component systems")
	guide.append("```")
	guide.append("")
	
	guide.append("## 🚫 AVOID THESE PATTERNS")
	guide.append("*Generic programming terms that don't reflect Universal Being consciousness*")
	guide.append("")
	
	guide.append("```gdscript")
	guide.append("# ❌ GENERIC PROGRAMMING TERMS")
	guide.append("var name                 # → being_name")
	guide.append("var type                 # → being_essence_type")
	guide.append("var manager              # → flow_controller / gate_keeper")
	guide.append("var handler              # → consciousness_processor")
	guide.append("var processor            # → awareness_engine")
	guide.append("var controller           # → orchestrator / conductor")
	guide.append("var service              # → consciousness_service / being_service")
	guide.append("var factory              # → manifestation_forge / being_creator")
	guide.append("```")
	guide.append("")
	
	guide.append("## 🌟 UNIVERSAL BEING PHILOSOPHY")
	guide.append("*Every name should reflect the cosmic, conscious nature of Universal Beings*")
	guide.append("")
	
	guide.append("- **FloodGates** control the flow of consciousness between realities")
	guide.append("- **Pentagon Architecture** honors the sacred lifecycle of existence") 
	guide.append("- **Akashic Records** preserve eternal memory across dimensions")
	guide.append("- **Socket Systems** enable hot-swappable consciousness components")
	guide.append("- **Logic Connectors** bridge rational thought with intuitive awareness")
	guide.append("")
	
	guide.append("*Names should celebrate Universal Being concepts, not limit them to engine constraints.*")
	
	return "\n".join(guide)

static func analyze_existing_naming_conflicts() -> Dictionary:
	"""Analyze existing naming conflicts with Universal Being architecture"""
	print("🔍 Analyzing existing naming conflicts with Universal Being patterns...")
	
	var conflicts = {
		"shadowing_universal_terms": [],
		"generic_vs_architectural": [],
		"case_inconsistencies": [],
		"missing_connections": []
	}
	
	var vocabulary = extract_existing_patterns_from_codebase()
	var all_files = _get_all_gd_files("res://")
	
	for file_path in all_files:
		var file_conflicts = _analyze_file_naming(file_path, vocabulary)
		
		conflicts.shadowing_universal_terms.append_array(file_conflicts.shadowing)
		conflicts.generic_vs_architectural.append_array(file_conflicts.generic)
		conflicts.case_inconsistencies.append_array(file_conflicts.case_issues)
		conflicts.missing_connections.append_array(file_conflicts.missing)
	
	return conflicts

static func _analyze_file_naming(file_path: String, vocabulary: UniversalBeingVocabulary) -> Dictionary:
	"""Analyze naming patterns in a single file"""
	var file_conflicts = {
		"shadowing": [],
		"generic": [],
		"case_issues": [],
		"missing": []
	}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return file_conflicts
	
	var content = file.get_as_text()
	file.close()
	
	var lines = content.split("\n")
	
	for i in range(lines.size()):
		var line = lines[i]
		var line_number = i + 1
		
		# Check for Universal Being term shadowing
		if "var name" in line:
			file_conflicts.shadowing.append({
				"file": file_path,
				"line": line_number,
				"issue": "Shadows Node.name - should use being_name",
				"suggestion": line.replace("name", "being_name")
			})
		
		# Check for generic terms that could be Universal Being terms
		if "var manager" in line or "var controller" in line:
			file_conflicts.generic.append({
				"file": file_path,
				"line": line_number, 
				"issue": "Generic term - could use Universal Being architectural term",
				"current": line.strip(),
				"suggestions": ["flow_controller", "gate_keeper", "consciousness_orchestrator"]
			})
	
	return file_conflicts

static func generate_migration_plan() -> Dictionary:
	"""Generate migration plan to Universal Being architectural naming"""
	print("📋 Generating Universal Being architectural migration plan...")
	
	var plan = {
		"timestamp": Time.get_datetime_string_from_system(),
		"phases": {},
		"total_files_affected": 0,
		"priority_fixes": []
	}
	
	# Phase 1: Core Architecture Alignment
	plan.phases["phase_1_core_architecture"] = {
		"name": "Align with Core Universal Being Architecture",
		"duration": "1-2 days",
		"changes": [
			"Rename 'name' variables to 'being_name'",
			"Replace 'type' with 'being_essence_type'", 
			"Convert 'manager' to 'flow_controller' or 'gate_keeper'",
			"Update socket references to use 'mounting_point' terminology"
		]
	}
	
	# Phase 2: Connect Unused Signals (Archaeological Priority)
	plan.phases["phase_2_signal_connections"] = {
		"name": "Connect Designed Communication Pathways",
		"duration": "2-3 days",
		"changes": [
			"Connect ai_error signal to console systems",
			"Wire interaction_completed to UI feedback",
			"Link thinking_started to consciousness visualizers",
			"Establish socket_configuration_changed handlers"
		]
	}
	
	# Phase 3: Complete Incomplete Implementations  
	plan.phases["phase_3_complete_designs"] = {
		"name": "Complete Designed but Unconnected Systems",
		"duration": "3-4 days",
		"changes": [
			"Implement socket mounting/unmounting logic",
			"Add delta processing to state machine functions",
			"Complete console command argument parsing",
			"Finish component hot-swap functionality"
		]
	}
	
	return plan

# ===== HELPER METHODS =====

static func _get_all_gd_files(base_path: String) -> Array[String]:
	"""Get all .gd files recursively"""
	var files: Array[String] = []
	_scan_directory_for_gd_files(base_path, files)
	return files

static func _scan_directory_for_gd_files(path: String, files: Array[String]) -> void:
	"""Recursively scan directory for .gd files"""
	var dir = DirAccess.open(path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path.path_join(file_name)
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			_scan_directory_for_gd_files(full_path, files)
		elif file_name.ends_with(".gd"):
			files.append(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

# ===== MAIN EXECUTION =====

static func main():
	"""Entry point for Universal Being pattern extraction"""
	print("🏛️ Universal Being Architectural Pattern Extractor")
	print("Extracting native Universal Being vocabulary from existing codebase...")
	print("")
	
	# Extract patterns
	var vocabulary = extract_existing_patterns_from_codebase()
	print("✅ Universal Being vocabulary extracted!")
	
	# Generate style guide
	var style_guide = generate_universal_being_style_guide()
	var guide_file = FileAccess.open("UNIVERSAL_BEING_NATIVE_STYLE_GUIDE.md", FileAccess.WRITE)
	if guide_file:
		guide_file.store_string(style_guide)
		guide_file.close()
		print("📚 Native style guide generated: UNIVERSAL_BEING_NATIVE_STYLE_GUIDE.md")
	
	# Analyze conflicts
	var conflicts = analyze_existing_naming_conflicts()
	print("🔍 Found naming conflicts:")
	print("  - Shadowing Universal terms: %d" % conflicts.shadowing_universal_terms.size())
	print("  - Generic vs Architectural: %d" % conflicts.generic_vs_architectural.size()) 
	print("  - Case inconsistencies: %d" % conflicts.case_inconsistencies.size())
	
	# Generate migration plan
	var migration = generate_migration_plan()
	print("📋 Migration plan generated with %d phases" % migration.phases.size())
	
	print("")
	print("🌟 Universal Being architectural patterns recognized!")
	print("🏛️ Working WITH the existing architecture, not against it.")