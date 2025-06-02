# ==================================================
# SCRIPT NAME: akashic_compact_system.gd
# DESCRIPTION: Revolutionary memory compacting system for Universal Beings
# PURPOSE: Compress experiences, merge memories, evolve scenarios
# LOCATION: systems/akashic_compact_system.gd
# ==================================================

extends Node
class_name AkashicCompactSystem

## Compact Types
enum CompactType {
    MEMORY,       # Being experiences
    STATE,        # Game states
    SCENARIO,     # AI scenarios
    EVOLUTION,    # Evolution chains
    KNOWLEDGE,    # AI learning
    VISUAL,       # Visual states (camera consciousness)
    INTERACTION   # Player/AI interactions
}

## Compact Record
class Compact:
    var id: String = ""
    var type: CompactType = CompactType.MEMORY
    var timestamp: float = 0.0
    var content: Dictionary = {}
    var parent_ids: Array[String] = []  # For merging
    var child_ids: Array[String] = []   # Branches
    var compression_ratio: float = 1.0
    var tokens_saved: int = 0
    var being_id: String = ""  # Owner
    var consciousness_level: int = 0
    var metadata: Dictionary = {}
    
    func get_size_kb() -> float:
        return var_to_str(content).length() / 1024.0

## Main Properties
signal compact_created(compact: Compact)
signal compact_merged(result: Compact, sources: Array)
signal compact_evolved(from: Compact, to: Compact)
signal memory_compressed(being_id: String, ratio: float)

var active_compacts: Dictionary = {}  # id -> Compact
var compact_chains: Dictionary = {}   # being_id -> [compact_ids]
var scenario_branches: Dictionary = {} # scenario_id -> [branch_ids]
var compression_stats: Dictionary = {}

## Performance Settings
var auto_compact_threshold_kb: float = 100.0
var max_compacts_per_being: int = 50
var compression_level: int = 3  # 1-5

## Consciousness Icon Integration
var consciousness_icons: Dictionary = {}  # level -> icon_path

# ===== INITIALIZATION =====

func _ready():
    # Load consciousness icons
    load_consciousness_icons()
    
    # Connect to AkashicRecords if available
    var akashic = get_node_or_null("/root/AkashicRecords")
    if akashic:
        print("📚 Compact System connected to Akashic Records")

func load_consciousness_icons() -> void:
    """Load the consciousness level icons"""
    for i in range(8):
        var icon_path = "res://assets/icons/consciousness/level_%d.png" % i
        if ResourceLoader.exists(icon_path):
            consciousness_icons[i] = icon_path
            print("🎨 Loaded consciousness icon: Level %d" % i)

# ===== COMPACT CREATION =====

func create_memory_compact(being: Node, memories: Array) -> Compact:
    """Compress being memories into a compact"""
    var compact = Compact.new()
    compact.id = generate_compact_id()
    compact.type = CompactType.MEMORY
    compact.timestamp = Time.get_ticks_msec() / 1000.0
    compact.being_id = being.get("uuid") if being.has("uuid") else ""
    compact.consciousness_level = being.get("consciousness_level") if being.has("consciousness_level") else 0
    
    # Compress memories
    var compressed = compress_memories(memories)
    compact.content = compressed["data"]
    compact.compression_ratio = compressed["ratio"]
    compact.tokens_saved = compressed["tokens_saved"]
    
    # Add consciousness metadata
    compact.metadata["consciousness_icon"] = consciousness_icons.get(compact.consciousness_level, "")
    compact.metadata["being_type"] = being.get("being_type") if being.has("being_type") else "unknown"
    compact.metadata["memory_count"] = memories.size()
    
    # Store and emit
    store_compact(compact)
    compact_created.emit(compact)
    
    print("💾 Created memory compact for %s: %.1f KB (ratio: %.1fx)" % 
        [being.name, compact.get_size_kb(), compact.compression_ratio])
    
    return compact

func create_scenario_compact(scenario_text: String, title: String = "Untitled") -> Compact:
    """Create a compact from scenario text"""
    var compact = Compact.new()
    compact.id = generate_compact_id()
    compact.type = CompactType.SCENARIO
    compact.timestamp = Time.get_ticks_msec() / 1000.0
    
    # Extract key elements
    compact.content = {
        "title": title,
        "original_text": scenario_text,
        "key_points": extract_key_points(scenario_text),
        "characters": extract_characters(scenario_text),
        "locations": extract_locations(scenario_text),
        "decisions": extract_decisions(scenario_text),
        "ai_instructions": extract_ai_instructions(scenario_text)
    }
    
    compact.compression_ratio = float(scenario_text.length()) / var_to_str(compact.content).length()
    compact.tokens_saved = estimate_tokens_saved(scenario_text, compact.content)
    
    store_compact(compact)
    compact_created.emit(compact)
    
    return compact

func create_evolution_compact(being: Node, from_form: String, to_form: String) -> Compact:
    """Track evolution between forms"""
    var compact = Compact.new()
    compact.id = generate_compact_id()
    compact.type = CompactType.EVOLUTION
    compact.timestamp = Time.get_ticks_msec() / 1000.0
    compact.being_id = being.get("uuid") if being.has("uuid") else ""
    
    compact.content = {
        "from_form": from_form,
        "to_form": to_form,
        "trigger": "consciousness_evolution",
        "consciousness_before": being.get("consciousness_level") if being.has("consciousness_level") else 0,
        "consciousness_after": being.get("consciousness_level") if being.has("consciousness_level") else 0,
        "properties_changed": {},
        "components_added": [],
        "components_removed": []
    }
    
    store_compact(compact)
    compact_created.emit(compact)
    
    return compact

# ===== COMPRESSION ALGORITHMS =====

func compress_memories(memories: Array) -> Dictionary:
    """Compress array of memories into compact format"""
    var result = {
        "data": {},
        "ratio": 1.0,
        "tokens_saved": 0
    }
    
    # Group similar memories
    var grouped = {}
    for memory in memories:
        var category = categorize_memory(memory)
        if not category in grouped:
            grouped[category] = []
        grouped[category].append(memory)
    
    # Compress each group
    for category in grouped:
        var group = grouped[category]
        if group.size() > 3:
            # Summarize large groups
            result["data"][category] = {
                "count": group.size(),
                "summary": summarize_memory_group(group),
                "highlights": extract_highlights(group)
            }
        else:
            # Keep small groups intact
            result["data"][category] = group
    
    # Calculate compression
    var original_size = var_to_str(memories).length()
    var compressed_size = var_to_str(result["data"]).length()
    result["ratio"] = float(original_size) / max(1, compressed_size)
    result["tokens_saved"] = estimate_tokens_saved(memories, result["data"])
    
    return result

func categorize_memory(memory: Dictionary) -> String:
    """Categorize a memory for grouping"""
    if memory.has("type"):
        return memory["type"]
    
    # Analyze content to determine category
    var content = memory.get("content", "")
    if content is String:
        if content.contains("evolution") or content.contains("transform"):
            return "evolution"
        elif content.contains("interaction") or content.contains("player"):
            return "interaction"
        elif content.contains("scene") or content.contains("visual"):
            return "visual"
        elif content.contains("state") or content.contains("property"):
            return "state"
        elif content.contains("knowledge") or content.contains("learn"):
            return "knowledge"
        elif content.contains("scenario") or content.contains("story"):
            return "scenario"
    
    # Default category if no specific type found
    return "general"

func summarize_memory_group(memories: Array) -> String:
    """Create a summary of similar memories"""
    # Simple implementation - could use AI for better summaries
    var actions = []
    var results = []
    
    for memory in memories:
        if memory.has("action"):
            actions.append(memory["action"])
        if memory.has("result"):
            results.append(memory["result"])
    
    return "Performed %d similar actions with %d unique outcomes" % [actions.size(), results.size()]

# ===== MERGING & EVOLUTION =====

func merge_compacts(compact_ids: Array[String]) -> Compact:
    """Merge multiple compacts into one"""
    if compact_ids.size() < 2:
        push_error("Need at least 2 compacts to merge")
        return null
    
    var sources = []
    for id in compact_ids:
        if id in active_compacts:
            sources.append(active_compacts[id])
    
    if sources.size() < 2:
        return null
    
    # Create merged compact
    var merged = Compact.new()
    merged.id = generate_compact_id()
    merged.type = sources[0].type  # Use first type
    merged.timestamp = Time.get_ticks_msec() / 1000.0
    merged.parent_ids = compact_ids
    
    # Merge content based on type
    match merged.type:
        CompactType.MEMORY:
            merged.content = merge_memory_content(sources)
        CompactType.SCENARIO:
            merged.content = merge_scenario_content(sources)
        _:
            merged.content = merge_generic_content(sources)
    
    # Update parent-child relationships
    for source in sources:
        source.child_ids.append(merged.id)
    
    store_compact(merged)
    compact_merged.emit(merged, sources)
    
    return merged

func merge_memory_content(sources: Array) -> Dictionary:
    """Merge memory compacts intelligently"""
    var merged_content = {}
    var all_categories = {}
    
    # Collect all categories
    for source in sources:
        for category in source.content:
            if not category in all_categories:
                all_categories[category] = []
            all_categories[category].append(source.content[category])
    
    # Merge each category
    for category in all_categories:
        var items = all_categories[category]
        if items.size() == 1:
            merged_content[category] = items[0]
        else:
            # Intelligent merging
            merged_content[category] = {
                "merged_from": items.size(),
                "combined_data": merge_similar_data(items)
            }
    
    return merged_content

func branch_scenario(scenario_compact: Compact, choice: String) -> Compact:
    """Create a new scenario branch based on a choice"""
    var branch = Compact.new()
    branch.id = generate_compact_id()
    branch.type = CompactType.SCENARIO
    branch.timestamp = Time.get_ticks_msec() / 1000.0
    branch.parent_ids = [scenario_compact.id]
    
    # Copy and modify content
    branch.content = scenario_compact.content.duplicate(true)
    branch.content["branch_point"] = choice
    branch.content["branch_timestamp"] = branch.timestamp
    
    # Update relationships
    scenario_compact.child_ids.append(branch.id)
    
    store_compact(branch)
    compact_evolved.emit(scenario_compact, branch)
    
    return branch

# ===== STORAGE & RETRIEVAL =====

func store_compact(compact: Compact) -> void:
    """Store a compact in the system"""
    active_compacts[compact.id] = compact
    
    # Update chains
    if compact.being_id != "":
        if not compact.being_id in compact_chains:
            compact_chains[compact.being_id] = []
        compact_chains[compact.being_id].append(compact.id)
        
        # Check if auto-compaction needed
        check_auto_compact(compact.being_id)
    
    # Update scenario branches
    if compact.type == CompactType.SCENARIO:
        for parent_id in compact.parent_ids:
            if not parent_id in scenario_branches:
                scenario_branches[parent_id] = []
            scenario_branches[parent_id].append(compact.id)

func get_being_memories(being_id: String, limit: int = -1) -> Array[Compact]:
    """Get all memory compacts for a being"""
    var memories = []
    
    if being_id in compact_chains:
        for compact_id in compact_chains[being_id]:
            if compact_id in active_compacts:
                var compact = active_compacts[compact_id]
                if compact.type == CompactType.MEMORY:
                    memories.append(compact)
    
    # Sort by timestamp
    memories.sort_custom(func(a, b): return a.timestamp > b.timestamp)
    
    if limit > 0 and memories.size() > limit:
        return memories.slice(0, limit)
    
    return memories

func get_scenario_branches(scenario_id: String) -> Array[Compact]:
    """Get all branches of a scenario"""
    var branches = []
    
    if scenario_id in scenario_branches:
        for branch_id in scenario_branches[scenario_id]:
            if branch_id in active_compacts:
                branches.append(active_compacts[branch_id])
    
    return branches

# ===== AUTO COMPACTION =====

func check_auto_compact(being_id: String) -> void:
    """Check if being needs auto-compaction"""
    if not being_id in compact_chains:
        return
    
    var chain = compact_chains[being_id]
    if chain.size() > max_compacts_per_being:
        print("🗜️ Auto-compacting for being: %s" % being_id)
        auto_compact_being(being_id)

func auto_compact_being(being_id: String) -> void:
    """Automatically compact old memories"""
    var memories = get_being_memories(being_id)
    if memories.size() < 10:
        return
    
    # Group old memories (keep recent ones intact)
    var to_compact = memories.slice(10, memories.size())
    var compact_ids = []
    
    for memory in to_compact:
        compact_ids.append(memory.id)
    
    # Merge old memories
    if compact_ids.size() >= 2:
        var merged = merge_compacts(compact_ids)
        if merged:
            # Remove old compacts
            for id in compact_ids:
                active_compacts.erase(id)
                compact_chains[being_id].erase(id)
            
            memory_compressed.emit(being_id, merged.compression_ratio)

# ===== UTILITY FUNCTIONS =====

func generate_compact_id() -> String:
    """Generate unique compact ID"""
    return "compact_" + str(Time.get_ticks_usec())

func extract_key_points(text: String) -> Array:
    """Extract key points from text"""
    var points = []
    var lines = text.split("\n")
    
    for line in lines:
        line = line.strip_edges()
        if line.begins_with("-") or line.begins_with("*") or line.begins_with("•"):
            points.append(line.substr(1).strip_edges())
    
    return points

func extract_characters(text: String) -> Array:
    """Extract character names from scenario"""
    # Simple implementation - look for capitalized words
    var characters = []
    var words = text.split(" ")
    
    for word in words:
        if word.length() > 2 and word[0] == word[0].to_upper():
            if not word in characters:
                characters.append(word)
    
    return characters

func extract_locations(text: String) -> Array:
    """Extract locations from scenario"""
    # Would need more sophisticated NLP
    return []

func extract_decisions(text: String) -> Array:
    """Extract decision points from scenario"""
    var decisions = []
    var lines = text.split("\n")
    
    for line in lines:
        if line.contains("?") or line.contains("choose") or line.contains("decision"):
            decisions.append(line.strip_edges())
    
    return decisions

func extract_ai_instructions(text: String) -> Dictionary:
    """Extract AI-specific instructions"""
    return {
        "tone": "adaptive",
        "style": "narrative",
        "constraints": []
    }

func estimate_tokens_saved(original, compressed) -> int:
    """Estimate tokens saved by compression"""
    var original_tokens = var_to_str(original).length() / 4  # Rough estimate
    var compressed_tokens = var_to_str(compressed).length() / 4
    return int(original_tokens - compressed_tokens)

func extract_highlights(memories: Array) -> Array:
    """Extract most important memories"""
    # Return first 3 for now
    return memories.slice(0, min(3, memories.size()))

func merge_similar_data(items: Array) -> Dictionary:
    """Merge similar data items"""
    return {
        "count": items.size(),
        "first": items[0] if items.size() > 0 else null,
        "last": items[-1] if items.size() > 0 else null
    }

# ===== AI INTEGRATION =====

func get_ai_context(being_id: String) -> Dictionary:
    """Get compressed context for AI"""
    var memories = get_being_memories(being_id, 5)  # Last 5 compacts
    
    var context = {
        "being_id": being_id,
        "memory_count": memories.size(),
        "total_compacts": compact_chains[being_id].size() if being_id in compact_chains else 0,
        "recent_memories": [],
        "consciousness_progression": []
    }
    
    for memory in memories:
        context["recent_memories"].append({
            "timestamp": memory.timestamp,
            "summary": memory.content.get("summary", ""),
            "consciousness": memory.consciousness_level
        })
        
        if memory.consciousness_level > 0:
            context["consciousness_progression"].append(memory.consciousness_level)
    
    return context

# ===== EXPORT/IMPORT =====

func export_being_compacts(being_id: String) -> Dictionary:
    """Export all compacts for a being"""
    var export_data = {
        "being_id": being_id,
        "export_date": Time.get_datetime_string_from_system(),
        "compacts": []
    }
    
    if being_id in compact_chains:
        for compact_id in compact_chains[being_id]:
            if compact_id in active_compacts:
                export_data["compacts"].append(active_compacts[compact_id])
    
    return export_data

func import_being_compacts(data: Dictionary) -> bool:
    """Import compacts for a being"""
    if not data.has("being_id") or not data.has("compacts"):
        return false
    
    var being_id = data["being_id"]
    var imported = 0
    
    for compact_data in data["compacts"]:
        var compact = Compact.new()
        # Restore compact properties
        for key in compact_data:
            if key in compact:
                compact[key] = compact_data[key]
        
        store_compact(compact)
        imported += 1
    
    print("📥 Imported %d compacts for being: %s" % [imported, being_id])
    return true