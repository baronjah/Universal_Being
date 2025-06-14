extends Node
class_name MemorySystemConverter

# Memory Systems Comment Style Converter
# Transforms / and // style comments to # style for better visual organization
# This aligns with the updated memories project approach

# Constants
const TARGET_FILES = [
    "/mnt/c/Users/Percision 15/12_turns_system/memory_investment_system.gd",
    "/mnt/c/Users/Percision 15/memory_channel_system.gd",
    "/mnt/c/Users/Percision 15/wish_knowledge_system.gd",
    "/mnt/c/Users/Percision 15/WordMemorySystem.gd"
]

const COMMENT_PATTERNS = {
    "//": "#",  # Single line comment
    "/*": "# /*", # Multi-line comment start
    "*/": "# */", # Multi-line comment end
}

# Section Markers
const SECTION_MARKERS = {
    "// SECTION:": "# SECTION:",
    "// BEGIN:": "# BEGIN:",
    "// END:": "# END:",
    "/* SECTION:": "# /* SECTION:",
    "/* BEGIN:": "# /* BEGIN:",
    "/* END:": "# /* END:" 
}

# Memory Keywords to enhance with special formatting
const MEMORY_KEYWORDS = [
    "memory",
    "recall",
    "store",
    "remember",
    "forget",
    "knowledge",
    "learn",
    "understanding",
    "mental",
    "mind",
    "comprehend",
    "perception",
    "cognition",
    "insight",
    "wisdom"
]

# Variables
var _file = File.new()
var _dir = Directory.new()
var _conversion_stats = {
    "files_processed": 0,
    "comments_converted": 0,
    "memory_terms_enhanced": 0,
    "sections_reformatted": 0
}

# Main conversion function
func convert_comment_style():
    print("# Memory System Converter starting...")
    print("# Target files: " + str(TARGET_FILES.size()))
    
    for file_path in TARGET_FILES:
        convert_file(file_path)
    
    print("# Conversion complete")
    print("# Stats: ")
    print("#   Files processed: " + str(_conversion_stats.files_processed))
    print("#   Comments converted: " + str(_conversion_stats.comments_converted))
    print("#   Memory terms enhanced: " + str(_conversion_stats.memory_terms_enhanced))
    print("#   Sections reformatted: " + str(_conversion_stats.sections_reformatted))

# Process a single file
func convert_file(file_path: String) -> bool:
    if not _file.file_exists(file_path):
        print("# File not found: " + file_path)
        return false
    
    print("# Processing: " + file_path)
    
    # Read file content
    var err = _file.open(file_path, File.READ)
    if err != OK:
        print("# Error opening file: " + str(err))
        return false
    
    var content = _file.get_as_text()
    _file.close()
    
    # Convert comments
    var modified_content = convert_comments(content)
    
    # Enhance memory keywords
    modified_content = enhance_memory_keywords(modified_content)
    
    # Create backup of original file
    var backup_path = file_path + ".bak"
    _file.open(backup_path, File.WRITE)
    _file.store_string(content)
    _file.close()
    
    # Write modified content
    err = _file.open(file_path, File.WRITE)
    if err != OK:
        print("# Error opening file for writing: " + str(err))
        return false
    
    _file.store_string(modified_content)
    _file.close()
    
    _conversion_stats.files_processed += 1
    print("# Converted: " + file_path)
    return true

# Convert comment styles in content
func convert_comments(content: String) -> String:
    var lines = content.split("\n")
    var modified_lines = []
    
    for line in lines:
        var modified_line = line
        
        # Process section markers first (they're special comment cases)
        for marker in SECTION_MARKERS:
            if line.strip_edges().begins_with(marker):
                modified_line = line.replace(marker, SECTION_MARKERS[marker])
                _conversion_stats.sections_reformatted += 1
                break
        
        # Only process standard comments if not already a section marker
        if modified_line == line:
            # Single line comments
            if line.strip_edges().begins_with("//"):
                modified_line = line.replace("//", "#", 1)
                _conversion_stats.comments_converted += 1
            
            # Comments after code
            var comment_pos = line.find("//")
            if comment_pos > 0 and not is_within_string(line, comment_pos):
                modified_line = line.substr(0, comment_pos) + "#" + line.substr(comment_pos + 2)
                _conversion_stats.comments_converted += 1
            
            # Multi-line comments
            if line.strip_edges().begins_with("/*"):
                modified_line = line.replace("/*", "# /*", 1)
                _conversion_stats.comments_converted += 1
            
            if line.strip_edges().ends_with("*/"):
                var end_pos = line.find("*/")
                modified_line = line.substr(0, end_pos) + "# */"
                _conversion_stats.comments_converted += 1
        
        modified_lines.append(modified_line)
    
    return "\n".join(modified_lines)

# Check if a position is within a string literal
func is_within_string(line: String, position: int) -> bool:
    var in_single_quote = false
    var in_double_quote = false
    var escaped = false
    
    for i in range(position):
        var char = line[i]
        
        if escaped:
            escaped = false
            continue
        
        if char == "\\":
            escaped = true
            continue
        
        if char == "'" and not in_double_quote:
            in_single_quote = not in_single_quote
        
        if char == "\"" and not in_single_quote:
            in_double_quote = not in_double_quote
    
    return in_single_quote or in_double_quote

# Enhance memory keyword formatting
func enhance_memory_keywords(content: String) -> String:
    var result = content
    
    for keyword in MEMORY_KEYWORDS:
        var regex = RegEx.new()
        # Match the keyword only in comments or strings, not in code identifiers
        regex.compile("(#.*)(" + keyword + ")(.*)|(\".*)(" + keyword + ")(.*\")|('\\w*" + keyword + "\\w*')")
        
        var matches = regex.search_all(content)
        for match_result in matches:
            var match_string = match_result.get_string()
            var enhanced_string = match_string.replace(keyword, "# " + keyword + " #")
            result = result.replace(match_string, enhanced_string)
            _conversion_stats.memory_terms_enhanced += 1
    
    return result

# Entry point for running the converter
func run():
    convert_comment_style()

# Example usage
# var converter = MemorySystemConverter.new()
# converter.run()