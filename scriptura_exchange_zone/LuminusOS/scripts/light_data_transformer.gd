extends Node

class_name LightDataTransformer

signal transformation_complete(data_id, original_lines, transformed_lines)
signal light_intensity_changed(intensity_level, source_file)
signal story_integration_complete(story_id, light_transformed_segments)

# Constants for transformation control
const MIN_LINES = 12
const MAX_LINES = 22
const LIGHT_INTENSITY_LEVELS = ["dim", "soft", "moderate", "bright", "radiant"]
const TRANSFORMATION_MODES = ["expand", "condense", "illuminate", "refract", "reflect"]

# Core data storage
var light_data_store = {
    "transformations": {},    # History of transformations
    "light_sources": {},      # Current light sources
    "story_elements": {},     # Story integration elements
    "patterns": {}            # Light patterns detected
}

# Configuration
var config = {
    "default_intensity": 2,   # Index in LIGHT_INTENSITY_LEVELS (moderate)
    "default_mode": "expand", # Default transformation mode
    "auto_story_integration": true,
    "preserve_semantics": true,
    "line_spacing": 1.0,      # Line spacing multiplier (1.0 = normal)
    "illumination_threshold": 0.6  # 0.0-1.0 threshold for illumination
}

# References to other systems
var data_sea
var story_weaver
var memory_system
var evolution_engine

# Initialize connections to other systems
func _ready():
    # Attempt to connect to related systems
    data_sea = get_node_or_null("/root/DataSeaController")
    story_weaver = get_node_or_null("/root/StoryWeaver")
    memory_system = get_node_or_null("/root/TerminalMemorySystem")
    evolution_engine = get_node_or_null("/root/DataEvolutionEngine")
    
    print("Light Data Transformer initialized")
    print("Transformation range: " + str(MIN_LINES) + " to " + str(MAX_LINES) + " lines")

# Transform data from 12 to 22 lines (or any range within those bounds)
func transform_data(data, source_id="default", mode="expand", target_lines=22):
    print("Transforming data: " + source_id)
    
    # Validate input
    if typeof(data) != TYPE_STRING:
        data = str(data)
    
    # Parse data into lines
    var lines = data.split("\n")
    var original_line_count = lines.size()
    
    # Check if within valid range
    if original_line_count < MIN_LINES || target_lines > MAX_LINES:
        print("WARNING: Data outside valid range. Proceeding with adjustments.")
        original_line_count = max(MIN_LINES, min(original_line_count, MAX_LINES))
        target_lines = max(MIN_LINES, min(target_lines, MAX_LINES))
    
    # Create transformation record
    var transformation_id = "transform_" + source_id + "_" + str(Time.get_unix_time_from_system())
    var transformation = {
        "id": transformation_id,
        "source_id": source_id,
        "timestamp": Time.get_unix_time_from_system(),
        "original_lines": original_line_count,
        "target_lines": target_lines,
        "mode": mode,
        "intensity": config.default_intensity,
        "light_patterns": []
    }
    
    # Transform based on selected mode
    var transformed_data
    match mode:
        "expand":
            transformed_data = _expand_data(lines, target_lines)
        "condense":
            transformed_data = _condense_data(lines, target_lines)
        "illuminate":
            transformed_data = _illuminate_data(lines, target_lines)
        "refract":
            transformed_data = _refract_data(lines, target_lines)
        "reflect":
            transformed_data = _reflect_data(lines, target_lines)
        _:
            # Default to expand
            transformed_data = _expand_data(lines, target_lines)
    
    # Store transformation results
    transformation["result"] = transformed_data.join("\n")
    transformation["result_lines"] = transformed_data.size()
    
    # Detect light patterns in the transformation
    transformation["light_patterns"] = _detect_light_patterns(transformed_data)
    
    # Store the transformation
    light_data_store["transformations"][transformation_id] = transformation
    
    # Create light source from transformation
    _create_light_source(transformation)
    
    # Integrate with storytelling if enabled
    if config.auto_story_integration and story_weaver != null:
        _integrate_with_storytelling(transformation)
    
    # Emit signal
    emit_signal("transformation_complete", transformation_id, original_line_count, transformed_data.size())
    
    return {
        "transformation_id": transformation_id,
        "transformed_data": transformed_data.join("\n"),
        "original_lines": original_line_count,
        "result_lines": transformed_data.size(),
        "mode": mode,
        "light_patterns": transformation["light_patterns"]
    }

# Create a light source from transformation
func _create_light_source(transformation):
    var light_id = "light_" + transformation["source_id"]
    var light_source = {
        "id": light_id,
        "origin": transformation["id"],
        "intensity": transformation["intensity"],
        "creation_time": Time.get_unix_time_from_system(),
        "position": Vector3(randf() * 10 - 5, randf() * 5, randf() * 10 - 5),
        "color": _get_light_color_for_mode(transformation["mode"]),
        "lines_illuminated": transformation["result_lines"],
        "active": true
    }
    
    # Store light source
    light_data_store["light_sources"][light_id] = light_source
    
    # If data sea integration available, visualize the light
    if data_sea != null and data_sea.has_method("visualize_light"):
        data_sea.visualize_light(light_source)
        
    # Emit signal
    emit_signal("light_intensity_changed", transformation["intensity"], transformation["source_id"])
    
    return light_id

# Integrate transformation with storytelling
func _integrate_with_storytelling(transformation):
    if story_weaver == null:
        return false
    
    # Create a list of words that represent light qualities
    var light_words = ["illuminate", "radiance", "glow", "shimmer", "beam", 
                       "bright", "shine", "illuminate", "clarity", "brilliance"]
    
    # Extract key words from transformation
    var lines = transformation["result"].split("\n")
    var key_words = []
    
    for line in lines:
        var words = line.split(" ")
        for word in words:
            if word.length() > 4 and not key_words.has(word):
                key_words.append(word)
                # Limit to avoid too many words
                if key_words.size() >= 5:
                    break
    
    # Add some light-related words
    for i in range(min(3, light_words.size())):
        var light_word = light_words[randi() % light_words.size()]
        if not key_words.has(light_word):
            key_words.append(light_word)
    
    # Generate a story title based on transformation
    var story_title = "Light of " + transformation["source_id"].capitalize()
    
    # Create story with the extracted words as seeds
    var story_id = "none"
    if story_weaver.has_method("beginStory"):
        var story_result = story_weaver.beginStory(story_title, key_words)
        story_id = story_result.storyId
        
        # Add transformation content as story segments
        var segment_count = min(3, lines.size() / 3)
        for i in range(segment_count):
            var start_idx = i * (lines.size() / segment_count)
            var end_idx = min(lines.size(), start_idx + (lines.size() / segment_count))
            var segment_content = ""
            
            for j in range(start_idx, end_idx):
                segment_content += lines[j] + " "
            
            if story_weaver.has_method("addMessageToStory"):
                story_weaver.addMessageToStory(segment_content)
        
        # Store story integration
        light_data_store["story_elements"][story_id] = {
            "transformation_id": transformation["id"],
            "story_id": story_id,
            "title": story_title,
            "seed_words": key_words,
            "segments": segment_count
        }
        
        # Emit signal
        emit_signal("story_integration_complete", story_id, segment_count)
    
    return story_id

# TRANSFORMATION METHODS
# ----------------------

# Expand data from current line count to target line count
func _expand_data(lines, target_lines):
    var result = lines.duplicate()
    var original_count = lines.size()
    
    # If already at or above target, return as is
    if original_count >= target_lines:
        return result.slice(0, target_lines)
    
    # Calculate how many lines to add
    var lines_to_add = target_lines - original_count
    
    # Find best locations to expand
    var expansion_points = _find_expansion_points(lines)
    
    # Add lines at expansion points
    var lines_added = 0
    while lines_added < lines_to_add:
        for point in expansion_points:
            # Skip if we've added enough lines
            if lines_added >= lines_to_add:
                break
                
            # Calculate insertion index (adjusting for already inserted lines)
            var insert_index = point + lines_added
            
            # Generate expansion line based on context
            var context_before = result[max(0, insert_index-1)]
            var context_after = result[min(result.size()-1, insert_index)]
            var new_line = _generate_expansion_line(context_before, context_after)
            
            # Insert the new line
            result.insert(insert_index, new_line)
            lines_added += 1
    
    return result

# Condense data from current line count to target line count
func _condense_data(lines, target_lines):
    var result = lines.duplicate()
    var original_count = lines.size()
    
    # If already at or below target, return as is
    if original_count <= target_lines:
        return result
    
    # Calculate how many lines to remove
    var lines_to_remove = original_count - target_lines
    
    # Find lines that can be safely removed or merged
    var removal_candidates = _find_removal_candidates(lines)
    
    # Remove lines from candidates
    var lines_removed = 0
    while lines_removed < lines_to_remove and removal_candidates.size() > 0:
        # Sort candidates by removal priority (higher values first)
        removal_candidates.sort_custom(func(a, b): return a.priority > b.priority)
        
        # Get highest priority candidate
        var candidate = removal_candidates.pop_front()
        
        # Remove the line
        result.remove_at(candidate.index - lines_removed)
        lines_removed += 1
    
    return result

# Illuminate data by enhancing light-related words and concepts
func _illuminate_data(lines, target_lines):
    var result = lines.duplicate()
    var original_count = lines.size()
    
    # List of light-related words for enhancement
    var light_words = ["light", "bright", "shine", "glow", "beam", "ray", 
                    "illuminate", "radiance", "luminous", "brilliant"]
    
    # First pass: enhance existing light-related content
    for i in range(result.size()):
        var line = result[i]
        
        # Check if line contains light-related words
        for light_word in light_words:
            if line.to_lower().find(light_word) >= 0:
                # Enhance this line with more illumination
                result[i] = _enhance_illumination(line)
                break
    
    # Second pass: adjust line count to match target
    if result.size() < target_lines:
        # Need to add more lines - add illumination lines
        var lines_to_add = target_lines - result.size()
        for i in range(lines_to_add):
            # Create a new illumination line
            var new_line = _create_illumination_line(light_words[i % light_words.size()])
            
            # Find a good place to insert it
            var insert_index = min(i + 1, result.size())
            result.insert(insert_index, new_line)
    elif result.size() > target_lines:
        # Need to remove lines - use condense approach
        var condense_result = _condense_data(result, target_lines)
        result = condense_result
    
    return result

# Refract data by splitting concepts across multiple lines
func _refract_data(lines, target_lines):
    var result = []
    var original_count = lines.size()
    
    # Process each line for refraction
    for line in lines:
        # Skip empty lines
        if line.strip_edges().empty():
            result.append(line)
            continue
        
        # Split longer lines into parts (refraction)
        if line.length() > 40 and result.size() < target_lines - 1:
            var parts = _refract_line(line)
            result.append_array(parts)
        else:
            result.append(line)
    
    # Adjust line count to match target
    if result.size() < target_lines:
        # Need more lines - expand
        var expanded = _expand_data(result, target_lines)
        result = expanded
    elif result.size() > target_lines:
        # Too many lines - condense
        var condensed = _condense_data(result, target_lines)
        result = condensed
    
    return result

# Reflect data by creating mirrored/complementary concepts
func _reflect_data(lines, target_lines):
    var result = lines.duplicate()
    var original_count = lines.size()
    
    # Create reflections for selected lines
    var reflection_count = target_lines - original_count
    
    if reflection_count > 0:
        # Need to add reflections
        var lines_to_reflect = min(reflection_count, original_count)
        
        # Select lines to reflect (prefer meaningful lines)
        var reflection_candidates = []
        for i in range(result.size()):
            var line = result[i]
            if line.length() > 20 and line.split(" ").size() > 3:
                reflection_candidates.append(i)
        
        # If not enough candidates, add more
        while reflection_candidates.size() < lines_to_reflect:
            var random_idx = randi() % result.size()
            if not reflection_candidates.has(random_idx):
                reflection_candidates.append(random_idx)
        
        # Create reflections for selected lines
        for i in range(lines_to_reflect):
            if reflection_candidates.size() > i:
                var source_idx = reflection_candidates[i]
                var source_line = result[source_idx]
                
                # Create a reflection of the line
                var reflection = _create_reflection(source_line)
                
                # Add reflection after the source line
                result.insert(source_idx + 1 + i, reflection)
    elif reflection_count < 0:
        # Need to remove lines - condense
        result = _condense_data(result, target_lines)
    
    return result

# HELPER METHODS
# --------------

# Find good points to expand the content
func _find_expansion_points(lines):
    var points = []
    
    # Look for logical breaks in content
    for i in range(1, lines.size()):
        var prev_line = lines[i-1]
        var curr_line = lines[i]
        
        # Check for paragraph breaks or conceptual shifts
        if prev_line.strip_edges().empty() or curr_line.strip_edges().empty():
            points.append(i)
        elif prev_line.ends_with(".") or prev_line.ends_with("!") or prev_line.ends_with("?"):
            points.append(i)
        elif prev_line.length() < 20 and curr_line.length() > 30:
            points.append(i)
    
    # Add beginning and end as potential expansion points
    points.append(0)
    points.append(lines.size())
    
    # Ensure we have enough unique points
    points = _unique_array(points)
    
    # If not enough points, add some in the middle
    if points.size() < 3:
        points.append(lines.size() / 2)
    
    return points

# Generate a new line based on surrounding context
func _generate_expansion_line(context_before, context_after):
    # Extract key words from context
    var before_words = context_before.split(" ")
    var after_words = context_after.split(" ")
    
    var key_words = []
    
    # Extract interesting words (longer than 4 chars)
    for word in before_words:
        if word.length() > 4 and not key_words.has(word):
            key_words.append(word)
    
    for word in after_words:
        if word.length() > 4 and not key_words.has(word):
            key_words.append(word)
    
    # Create expansion line templates
    var templates = [
        "The light reveals %s within the patterns of %s.",
        "Illuminated by understanding, %s transforms into %s.",
        "Between %s and %s, a connection of light forms.",
        "The data's glow intensifies, highlighting %s and %s.",
        "A radiant thread connects %s to the essence of %s.",
        "The luminous path from %s leads toward %s.",
        "%s shines with potential, casting light on %s."
    ]
    
    # Get two random key words or use defaults
    var word1 = "knowledge"
    var word2 = "understanding"
    
    if key_words.size() > 0:
        word1 = key_words[randi() % key_words.size()]
    if key_words.size() > 1:
        # Get a different word for the second one
        var remaining = key_words.duplicate()
        remaining.erase(word1)
        word2 = remaining[randi() % remaining.size()]
    
    # Select a template and fill it
    var template = templates[randi() % templates.size()]
    var new_line = template % [word1, word2]
    
    return new_line

# Find candidates for removal during condensing
func _find_removal_candidates(lines):
    var candidates = []
    
    for i in range(lines.size()):
        var line = lines[i]
        var priority = 0
        
        # Empty lines are highest priority for removal
        if line.strip_edges().empty():
            priority = 10
        # Short lines are good candidates
        elif line.length() < 20:
            priority = 5
        # Repetitive lines
        elif _is_repetitive(line, lines):
            priority = 7
        # Low information lines
        elif _has_low_information(line):
            priority = 6
        # Default priority
        else:
            priority = 1
        
        # Add as candidate if it has any removal priority
        if priority > 0:
            candidates.append({
                "index": i,
                "line": line,
                "priority": priority
            })
    
    return candidates

# Enhance a line with more light/illumination language
func _enhance_illumination(line):
    # List of light-enhancing phrases to possibly insert
    var enhancers = [
        " brightly ",
        " with luminous clarity ",
        " radiantly ",
        " with shimmering insight ",
        " brilliantly ",
        " with glowing intensity "
    ]
    
    # Identify a good position to insert an enhancer
    var words = line.split(" ")
    if words.size() > 3:
        var insert_pos = words.size() / 2
        
        var enhancer = enhancers[randi() % enhancers.size()]
        words.insert(insert_pos, enhancer)
        
        return words.join(" ")
    else:
        # For short lines, just add an enhancer at the end
        return line + enhancers[randi() % enhancers.size()]

# Create a new illumination-focused line
func _create_illumination_line(light_word):
    var templates = [
        "The %s intensifies, revealing deeper patterns.",
        "A %s spreads across the data, transforming perception.",
        "The dimensional %s creates new understanding.",
        "From within, the %s of knowledge expands outward.",
        "Between the lines, a %s connects all concepts.",
        "%s emerges from the transformation process.",
        "The data's inherent %s manifests visibly.",
        "Clarity comes through the %s of expanded consciousness."
    ]
    
    var template = templates[randi() % templates.size()]
    return template % light_word

# Refract a line into multiple parts
func _refract_line(line):
    var parts = []
    
    // Simple refraction: split by sentence or at punctuation
    if line.find(". ") >= 0:
        parts = line.split(". ", false)
        for i in range(parts.size()):
            if not parts[i].ends_with("."):
                parts[i] += "."
    else if line.find(", ") >= 0:
        // Split at commas
        var first_part = line.substr(0, line.find(", "))
        var second_part = line.substr(line.find(", ") + 1).strip_edges()
        parts = [first_part + ",", second_part]
    else if line.length() > 60:
        // Split long line roughly in half at a space
        var middle = line.length() / 2
        var split_pos = line.find(" ", middle)
        if split_pos < 0:
            split_pos = line.rfind(" ", middle)
        
        if split_pos > 0:
            var first_part = line.substr(0, split_pos)
            var second_part = line.substr(split_pos + 1)
            parts = [first_part, second_part]
        else:
            parts = [line]
    else:
        parts = [line]
    
    return parts

# Create a reflection of a line (complementary or contrasting)
func _create_reflection(line):
    // Extract key terms
    var words = line.split(" ")
    var key_terms = []
    
    for word in words:
        if word.length() > 4:
            key_terms.append(word.to_lower())
    
    // Reflection templates based on key terms
    var templates = [
        "The light reflects from %s, revealing hidden dimensions.",
        "In the mirror of %s, we see a transformed %s.",
        "What was %s becomes %s in the reflection.",
        "Duality emerges: %s transforms when viewed through light.",
        "The reflection of %s illuminates what was previously unseen.",
        "Light bends around %s, creating new perspectives.",
        "Through reflection, %s resonates with deeper meaning."
    ]
    
    // Select template and terms
    var template = templates[randi() % templates.size()]
    var term1 = "concepts"
    var term2 = "understanding"
    
    if key_terms.size() > 0:
        term1 = key_terms[randi() % key_terms.size()]
    if key_terms.size() > 1:
        var remaining = key_terms.duplicate()
        remaining.erase(term1)
        term2 = remaining[randi() % remaining.size()]
    
    // Create reflection
    if template.count("%s") > 1:
        return template % [term1, term2]
    else:
        return template % term1

# Check if a line repeats information from other lines
func _is_repetitive(line, all_lines):
    var word_count = {}
    
    // Count words in all lines
    for other_line in all_lines:
        var words = other_line.split(" ")
        for word in words:
            if word.length() > 4: // Only count substantial words
                if !word_count.has(word):
                    word_count[word] = 0
                word_count[word] += 1
    
    // Check if this line has a high percentage of frequently used words
    var words = line.split(" ")
    var high_freq_count = 0
    
    for word in words:
        if word.length() > 4 and word_count.has(word) and word_count[word] > 2:
            high_freq_count += 1
    
    var repetitive_ratio = float(high_freq_count) / max(1, words.size())
    return repetitive_ratio > 0.5 // If over 50% repetitive words

# Check if a line has low information content
func _has_low_information(line):
    var info_words = line.split(" ")
    var low_info_words = ["the", "a", "an", "and", "or", "but", "if", "then", "so", "thus"]
    var low_info_count = 0
    
    for word in info_words:
        if low_info_words.has(word.to_lower()):
            low_info_count += 1
    
    var low_info_ratio = float(low_info_count) / max(1, info_words.size())
    return low_info_ratio > 0.4 // If over 40% low information words

# Detect light patterns in transformed data
func _detect_light_patterns(lines):
    var patterns = []
    
    # Light pattern markers
    var light_terms = ["light", "bright", "glow", "shine", "illuminate", "radiant", "beam", "ray"]
    
    # Scan for patterns
    var line_patterns = {}
    
    for i in range(lines.size()):
        var line = lines[i]
        var line_light_score = 0
        
        # Check for light terms
        for term in light_terms:
            if line.to_lower().find(term) >= 0:
                line_light_score += 1
        
        # Record if significant light presence
        if line_light_score > 0:
            line_patterns[i] = {
                "index": i,
                "intensity": line_light_score,
                "line": line
            }
    
    # Find clusters and patterns
    if line_patterns.size() > 0:
        var keys = line_patterns.keys()
        keys.sort()
        
        # Detect contiguous patterns
        var current_pattern = {
            "start_line": keys[0],
            "lines": [keys[0]],
            "total_intensity": line_patterns[keys[0]].intensity
        }
        
        for i in range(1, keys.size()):
            var idx = keys[i]
            var prev_idx = keys[i-1]
            
            # Check if contiguous or nearly contiguous
            if idx - prev_idx <= 2:
                # Continue current pattern
                current_pattern.lines.append(idx)
                current_pattern.total_intensity += line_patterns[idx].intensity
            else:
                # End current pattern and start new one
                if current_pattern.lines.size() >= 2 or current_pattern.total_intensity >= 3:
                    patterns.append({
                        "type": "light_cluster",
                        "start_line": current_pattern.start_line,
                        "end_line": current_pattern.lines[current_pattern.lines.size()-1],
                        "intensity": current_pattern.total_intensity,
                        "line_count": current_pattern.lines.size()
                    })
                
                # Start new pattern
                current_pattern = {
                    "start_line": idx,
                    "lines": [idx],
                    "total_intensity": line_patterns[idx].intensity
                }
        
        # Add the last pattern if significant
        if current_pattern.lines.size() >= 2 or current_pattern.total_intensity >= 3:
            patterns.append({
                "type": "light_cluster",
                "start_line": current_pattern.start_line,
                "end_line": current_pattern.lines[current_pattern.lines.size()-1],
                "intensity": current_pattern.total_intensity,
                "line_count": current_pattern.lines.size()
            })
    
    # Detect symmetry patterns
    var symmetry_points = _detect_symmetry_points(lines)
    for point in symmetry_points:
        patterns.append({
            "type": "symmetry",
            "center_line": point.center,
            "size": point.size
        })
    
    return patterns

# Detect symmetry points in the data
func _detect_symmetry_points(lines):
    var symmetry_points = []
    
    # Need at least 6 lines to detect meaningful symmetry
    if lines.size() < 6:
        return symmetry_points
    
    # Check for potential centers of symmetry
    for center in range(2, lines.size() - 2):
        var symmetry_size = 0
        var max_radius = min(center, lines.size() - center - 1)
        
        for radius in range(1, max_radius + 1):
            var line_before = lines[center - radius]
            var line_after = lines[center + radius]
            
            # Check if lines have symmetrical elements
            var symmetry_score = _calculate_symmetry_score(line_before, line_after)
            
            if symmetry_score > 0.6:  # Good symmetry threshold
                symmetry_size += 1
            else:
                break  # Stop when symmetry breaks
        
        # Record if we found symmetry of at least size 2
        if symmetry_size >= 2:
            symmetry_points.append({
                "center": center,
                "size": symmetry_size
            })
    
    return symmetry_points

# Calculate symmetry score between two lines
func _calculate_symmetry_score(line1, line2):
    # Simple implementation - check shared words and length similarity
    var words1 = line1.to_lower().split(" ")
    var words2 = line2.to_lower().split(" ")
    
    var shared_words = 0
    for word in words1:
        if word.length() > 3 and words2.has(word):
            shared_words += 1
    
    var length_similarity = 1.0 - abs(line1.length() - line2.length()) / float(max(line1.length(), line2.length()))
    
    var word_similarity = shared_words / float(max(1, min(words1.size(), words2.size())))
    
    return (word_similarity * 0.7) + (length_similarity * 0.3)

# Get appropriate light color for transformation mode
func _get_light_color_for_mode(mode):
    match mode:
        "expand":
            return Color(0.2, 0.6, 1.0)  # Blue
        "condense":
            return Color(1.0, 0.8, 0.2)  # Gold
        "illuminate":
            return Color(1.0, 1.0, 0.8)  # Soft white
        "refract":
            return Color(0.8, 0.2, 1.0)  # Purple
        "reflect":
            return Color(0.2, 1.0, 0.8)  # Teal
        _:
            return Color(0.9, 0.9, 0.9)  # Default light gray

# Return unique elements from array while preserving order
func _unique_array(arr):
    var unique = []
    for item in arr:
        if not unique.has(item):
            unique.append(item)
    return unique

# PUBLIC API METHODS
# -----------------

# Get available transformation modes
func get_transformation_modes():
    return TRANSFORMATION_MODES

# Get available light intensity levels
func get_light_intensity_levels():
    return LIGHT_INTENSITY_LEVELS

# Set light intensity for transformations
func set_light_intensity(level):
    if typeof(level) == TYPE_INT:
        config.default_intensity = clamp(level, 0, LIGHT_INTENSITY_LEVELS.size() - 1)
    elif typeof(level) == TYPE_STRING:
        var index = LIGHT_INTENSITY_LEVELS.find(level)
        if index >= 0:
            config.default_intensity = index
    return config.default_intensity

# Get a list of active light sources
func get_active_light_sources():
    var active = []
    for light_id in light_data_store.light_sources:
        var light = light_data_store.light_sources[light_id]
        if light.active:
            active.append(light)
    return active

# Get transformation history
func get_transformation_history(limit=5):
    var history = []
    var keys = light_data_store.transformations.keys()
    
    # Sort keys by timestamp (newest first)
    keys.sort_custom(func(a, b): 
        return light_data_store.transformations[a].timestamp > light_data_store.transformations[b].timestamp
    )
    
    # Get the most recent transformations
    for i in range(min(limit, keys.size())):
        history.append(light_data_store.transformations[keys[i]])
    
    return history

# Get story elements integrated with light transformations
func get_integrated_stories():
    return light_data_store.story_elements

# Process a command for light data transformation
func process_command(command):
    var parts = command.split(" ")
    
    if parts.size() < 1:
        return "Available commands: transform, intensity, modes, sources, history, stories"
    
    match parts[0]:
        "transform":
            if parts.size() < 2:
                return "Usage: transform <data_id> [mode] [target_lines]"
            
            var data_id = parts[1]
            var mode = config.default_mode if parts.size() < 3 else parts[2]
            var target_lines = 22 if parts.size() < 4 else int(parts[3])
            
            # Get the data from somewhere
            var data = "Sample data to transform. This is placeholder content."
            if memory_system and memory_system.has_method("get_memory"):
                data = memory_system.get_memory(data_id)
            
            var result = transform_data(data, data_id, mode, target_lines)
            return "Transformation complete: " + result.transformation_id
            
        "intensity":
            if parts.size() < 2:
                return "Current intensity: " + LIGHT_INTENSITY_LEVELS[config.default_intensity]
            
            set_light_intensity(parts[1])
            return "Light intensity set to: " + LIGHT_INTENSITY_LEVELS[config.default_intensity]
            
        "modes":
            return "Available transformation modes: " + ", ".join(TRANSFORMATION_MODES)
            
        "sources":
            var sources = get_active_light_sources()
            if sources.size() == 0:
                return "No active light sources"
            
            var result = "Active light sources (" + str(sources.size()) + "):\n"
            for source in sources:
                result += "- " + source.id + " (" + LIGHT_INTENSITY_LEVELS[source.intensity] + ")\n"
            return result
            
        "history":
            var history = get_transformation_history()
            if history.size() == 0:
                return "No transformation history"
            
            var result = "Recent transformations:\n"
            for item in history:
                result += "- " + item.id + ": " + str(item.original_lines) + " -> " + str(item.result_lines) + " lines (" + item.mode + ")\n"
            return result
            
        "stories":
            var stories = get_integrated_stories()
            if stories.size() == 0:
                return "No integrated stories"
            
            var result = "Light-integrated stories:\n"
            for story_id in stories:
                var story = stories[story_id]
                result += "- " + story.title + " (" + str(story.segments) + " segments)\n"
            return result
            
        _:
            return "Unknown command: " + parts[0]