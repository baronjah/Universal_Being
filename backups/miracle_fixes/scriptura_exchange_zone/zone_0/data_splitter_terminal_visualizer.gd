extends Node

class_name DataSplitterTerminalVisualizer

# ----- CONFIGURATION -----
@export var max_terminal_width: int = 80
@export var enable_colors: bool = true
@export var enable_ascii_art: bool = true
@export var enable_animations: bool = false
@export var detail_level: int = 2  # 1 = basic, 2 = normal, 3 = detailed

# ----- COLOR DEFINITIONS -----
const COLOR_RESET = "[/color]"
const COLOR_STREAM = "[color=#aaaaff]"  # Blue
const COLOR_CHUNK = "[color=#ffaaaa]"   # Red
const COLOR_SPLIT = "[color=#aaffaa]"   # Green
const COLOR_MERGE = "[color=#ffaaff]"   # Purple
const COLOR_SUCCESS = "[color=#88ff99]" # Light Green
const COLOR_ERROR = "[color=#ff7777]"   # Light Red
const COLOR_HEADER = "[color=#ffff88]"  # Yellow
const COLOR_DIMENSION = "[color=#88ffff]" # Cyan

# ----- ASCII TEMPLATES -----
# 3D Box template for stream/chunk visualization
const BOX_TEMPLATE_3D = [
    "    {top_line}",
    "   /|{top_content}|",
    "  / |{title_line}|",
    " /__|{mid_line}|",
    "|   |{content1}|",
    "|   |{content2}|",
    "|   |{content3}|",
    "|   |{content4}|",
    "|___|{bottom_line}|"
]

# 2D Box template for stream/chunk visualization
const BOX_TEMPLATE_2D = [
    "+{top_line}+",
    "|{title_line}|",
    "|{content1}|",
    "|{content2}|",
    "|{content3}|",
    "+{bottom_line}+"
]

# 1D Line template for stream/chunk visualization
const LINE_TEMPLATE_1D = "|{left_content}{title}{right_content}|"

# Tree template for connections
const TREE_TEMPLATE = [
    "    |",
    "{branches}"
]

# ----- INSTANCE VARIABLES -----
var current_dimension: int = 3
var current_reality: String = "Digital"

# ----- INITIALIZATION -----
func _ready():
    pass

# ----- PUBLIC VISUALIZATION METHODS -----
# Generate visualization for a data stream
func visualize_stream(stream_data: Dictionary, dimension: int = 3) -> String:
    match dimension:
        1:
            return _visualize_stream_1d(stream_data)
        2:
            return _visualize_stream_2d(stream_data)
        _:
            return _visualize_stream_3d(stream_data, dimension)

# Generate visualization for a data chunk
func visualize_chunk(chunk_data: Dictionary, dimension: int = 3) -> String:
    match dimension:
        1:
            return _visualize_chunk_1d(chunk_data)
        2:
            return _visualize_chunk_2d(chunk_data)
        _:
            return _visualize_chunk_3d(chunk_data, dimension)

# Generate visualization for a data split operation
func visualize_split(split_data: Dictionary) -> String:
    return _generate_split_visualization(split_data)

# Generate visualization for a data merge operation
func visualize_merge(merge_data: Dictionary) -> String:
    return _generate_merge_visualization(merge_data)

# Generate list visualization for streams
func visualize_stream_list(streams: Array) -> String:
    var result = COLOR_HEADER + "Streams (" + str(streams.size()) + "):" + COLOR_RESET + "\n"
    
    for stream in streams:
        result += "- " + stream.id + " (" + stream.type + ", " + str(stream.size) + " bytes, " + 
                 str(stream.chunks.size()) + " chunks)\n"
    
    return result

# Generate list visualization for chunks
func visualize_chunk_list(chunks: Dictionary) -> String:
    var result = COLOR_HEADER + "Chunks (" + str(chunks.size()) + "):" + COLOR_RESET + "\n"
    
    var count = 0
    for chunk_id in chunks:
        result += "- " + chunk_id + " (size: " + str(chunks[chunk_id].size) + ")\n"
        count += 1
        if count >= 10 and chunks.size() > 10:
            result += "  ... and " + str(chunks.size() - 10) + " more\n"
            break
    
    return result

# Generate list visualization for splits
func visualize_split_list(splits: Dictionary) -> String:
    var result = COLOR_HEADER + "Splits (" + str(splits.size()) + "):" + COLOR_RESET + "\n"
    
    var count = 0
    for split_id in splits:
        result += "- " + split_id + " (factor: " + str(splits[split_id].factor) + ")\n"
        count += 1
        if count >= 5 and splits.size() > 5:
            result += "  ... and " + str(splits.size() - 5) + " more\n"
            break
    
    return result

# Generate text analysis visualization
func visualize_text_analysis(text: String) -> String:
    # Basic analysis
    var analysis = {
        "total_chars": text.length(),
        "word_count": text.split(" ", false).size(),
        "line_count": text.split("\n", false).size(),
        "special_chars": {}
    }
    
    # Count special characters
    var special_chars = ["[", "]", "=", "|", "#", "@", "$", "%", "^", "&", "*"]
    for char in special_chars:
        var count = text.count(char)
        if count > 0:
            analysis.special_chars[char] = count
    
    # Check for natural split points
    var natural_splits = []
    if text.find("[") >= 0 and text.find("]") >= 0:
        natural_splits.append("brackets")
    if text.find("=") >= 0:
        natural_splits.append("equals")
    if text.find("|") >= 0:
        natural_splits.append("pipes")
    if text.find(",") >= 0:
        natural_splits.append("commas")
    
    analysis["natural_splits"] = natural_splits
    
    # Generate visualization
    var result = COLOR_SUCCESS + "Text Analysis:" + COLOR_RESET + "\n"
    result += "Characters: " + str(analysis.total_chars) + "\n"
    result += "Words: " + str(analysis.word_count) + "\n"
    result += "Lines: " + str(analysis.line_count) + "\n"
    
    if analysis.special_chars.size() > 0:
        result += "\n" + COLOR_STREAM + "Special Characters:" + COLOR_RESET + "\n"
        for char in analysis.special_chars:
            result += "- '" + char + "': " + str(analysis.special_chars[char]) + "\n"
    
    if natural_splits.size() > 0:
        result += "\n" + COLOR_SPLIT + "Suggested Split Methods:" + COLOR_RESET + "\n"
        for split in natural_splits:
            result += "- " + split + "\n"
    
    return result

# Generate help text visualization
func visualize_help() -> String:
    var help_text = COLOR_SUCCESS + "Data Splitter Terminal Bridge Commands:" + COLOR_RESET + "\n"
    help_text += "/split [chunk_id] [split_factor] - Split a data chunk\n"
    help_text += "/stream [stream_id] [data_type] [size] - Create a new data stream\n"
    help_text += "/chunk [chunk_id] [parent_stream] [content] - Create a new data chunk\n"
    help_text += "/merge [chunk_id1,chunk_id2,...] [merge_type] - Merge multiple chunks\n"
    help_text += "/list [streams|chunks|splits|all] - List data elements\n"
    help_text += "/analyze [text] - Analyze text for data splitting\n"
    help_text += "/visualize [chunk_id|stream_id] [dimension] - Visualize data in terminal\n"
    help_text += "/help - Display this help\n"
    
    return help_text

# ----- PRIVATE VISUALIZATION METHODS -----
# 1D Stream Visualization
func _visualize_stream_1d(stream_data: Dictionary) -> String:
    var stream_id = stream_data.id
    var line_length = max_terminal_width - 10  # Leave some margin
    
    # Calculate content length
    var total_length = line_length - stream_id.length()
    var left_content = "=" * (total_length / 2)
    var right_content = "=" * (total_length - left_content.length())
    
    var visualization = COLOR_STREAM
    visualization += LINE_TEMPLATE_1D.format({
        "left_content": left_content,
        "title": stream_id,
        "right_content": right_content
    })
    visualization += COLOR_RESET + "\n"
    
    # Add chunk information if present
    if stream_data.has("chunks") and stream_data.chunks.size() > 0:
        visualization += "-" * 40 + "\n"
        visualization += "Chunks: "
        
        for i in range(stream_data.chunks.size()):
            if i > 0:
                visualization += " - "
            visualization += stream_data.chunks[i]
    
    return visualization

# 2D Stream Visualization
func _visualize_stream_2d(stream_data: Dictionary) -> String:
    var stream_id = stream_data.id
    var width = min(max_terminal_width - 10, stream_data.size + 10)
    var top_bottom = "-" * (width - 2)
    
    # Calculate paddings for centered text
    var id_padding = " " * ((width - 2 - stream_id.length()) / 2)
    var id_extra = " " if (width - 2 - stream_id.length()) % 2 != 0 else ""
    
    var type_text = "Type: " + stream_data.type
    var type_padding = " " * ((width - 2 - type_text.length()) / 2)
    var type_extra = " " if (width - 2 - type_text.length()) % 2 != 0 else ""
    
    var size_text = "Size: " + str(stream_data.size)
    var size_padding = " " * ((width - 2 - size_text.length()) / 2)
    var size_extra = " " if (width - 2 - size_text.length()) % 2 != 0 else ""
    
    var chunk_text = "Chunks: " + str(stream_data.chunks.size())
    var chunk_padding = " " * ((width - 2 - chunk_text.length()) / 2)
    var chunk_extra = " " if (width - 2 - chunk_text.length()) % 2 != 0 else ""
    
    var visualization = COLOR_STREAM
    visualization += BOX_TEMPLATE_2D[0].format({"top_line": top_bottom}) + "\n"
    visualization += BOX_TEMPLATE_2D[1].format({"title_line": id_padding + stream_id + id_padding + id_extra}) + "\n"
    visualization += BOX_TEMPLATE_2D[2].format({"content1": type_padding + type_text + type_padding + type_extra}) + "\n"
    visualization += BOX_TEMPLATE_2D[3].format({"content2": size_padding + size_text + size_padding + size_extra}) + "\n"
    visualization += BOX_TEMPLATE_2D[4].format({"content3": chunk_padding + chunk_text + chunk_padding + chunk_extra}) + "\n"
    visualization += BOX_TEMPLATE_2D[5].format({"bottom_line": top_bottom}) + "\n"
    visualization += COLOR_RESET
    
    # Add chunk information if present
    if stream_data.has("chunks") and stream_data.chunks.size() > 0:
        visualization += "\nChunks:\n"
        for chunk_id in stream_data.chunks:
            visualization += "- " + chunk_id + "\n"
    
    return visualization

# 3D Stream Visualization
func _visualize_stream_3d(stream_data: Dictionary, dimension: int) -> String:
    var stream_id = stream_data.id
    var width = min(max_terminal_width - 15, stream_data.size + 20)
    
    # Create line templates
    var top_line = "_" * (width - 8)
    var mid_line = "_" * (width - 8)
    var bottom_line = "_" * (width - 8)
    
    # Prepare content lines
    var top_content = " " * (width - 8)
    
    # Stream ID line with padding
    var stream_id_padded = stream_id
    if stream_id.length() < width - 12:
        var padding = (width - 12 - stream_id.length()) / 2
        stream_id_padded = " " * padding + stream_id + " " * padding
    else:
        stream_id_padded = stream_id.substr(0, width - 15) + "..."
    var title_line = "  " + stream_id_padded + "  "
    
    # Stream properties
    var type_text = "  Type: " + stream_data.type
    var size_text = "  Size: " + str(stream_data.size)
    var chunk_text = "  Chunks: " + str(stream_data.chunks.size())
    
    # Pad properties to fit width
    type_text += " " * (width - 8 - type_text.length())
    size_text += " " * (width - 8 - size_text.length())
    chunk_text += " " * (width - 8 - chunk_text.length())
    
    var content4 = " " * (width - 8)
    
    # Create visualization
    var visualization = COLOR_STREAM
    visualization += BOX_TEMPLATE_3D[0].format({"top_line": top_line}) + "\n"
    visualization += BOX_TEMPLATE_3D[1].format({"top_content": top_content}) + "\n"
    visualization += BOX_TEMPLATE_3D[2].format({"title_line": title_line}) + "\n"
    visualization += BOX_TEMPLATE_3D[3].format({"mid_line": mid_line}) + "\n"
    visualization += BOX_TEMPLATE_3D[4].format({"content1": top_content}) + "\n"
    visualization += BOX_TEMPLATE_3D[5].format({"content2": type_text}) + "\n"
    visualization += BOX_TEMPLATE_3D[6].format({"content3": size_text}) + "\n"
    visualization += BOX_TEMPLATE_3D[7].format({"content4": chunk_text}) + "\n"
    visualization += BOX_TEMPLATE_3D[8].format({"bottom_line": bottom_line}) + "\n"
    visualization += COLOR_RESET
    
    # Show dimensions based on dimension count
    if dimension >= 4:
        visualization += "\n" + COLOR_DIMENSION + "Dimensions: " + str(dimension) + "D" + COLOR_RESET + "\n"
        
        for d in range(4, dimension + 1):
            visualization += "  Dimension " + str(d) + ": " + _get_dimension_property(d) + "\n"
    
    # If chunks exist, list them with ASCII connection
    if stream_data.has("chunks") and stream_data.chunks.size() > 0:
        visualization += "\n" + COLOR_SPLIT + "Connected Chunks:" + COLOR_RESET + "\n"
        visualization += "    |\n"
        
        var branches = ""
        for i in range(stream_data.chunks.size()):
            if i < stream_data.chunks.size() - 1:
                branches += "    ├─── " + stream_data.chunks[i] + "\n"
            else:
                branches += "    └─── " + stream_data.chunks[i] + "\n"
        
        visualization += branches
    
    return visualization

# 1D Chunk Visualization
func _visualize_chunk_1d(chunk_data: Dictionary) -> String:
    var chunk_id = chunk_data.id
    var line_length = max_terminal_width - 10  # Leave some margin
    
    # Calculate content length
    var total_length = line_length - chunk_id.length()
    var left_content = "[" + "-" * ((total_length / 2) - 1)
    var right_content = "-" * ((total_length / 2) - 1) + "]"
    
    var visualization = COLOR_CHUNK
    visualization += left_content + chunk_id + right_content
    visualization += COLOR_RESET + "\n"
    
    # Add content preview if present
    if chunk_data.has("content") and chunk_data.content.length() > 0:
        var content = chunk_data.content
        if content.length() > 40:
            content = content.substr(0, 37) + "..."
        visualization += "Content: " + content
    
    return visualization

# 2D Chunk Visualization
func _visualize_chunk_2d(chunk_data: Dictionary) -> String:
    var chunk_id = chunk_data.id
    var width = min(max_terminal_width - 10, chunk_data.size + 10)
    var top_bottom = "-" * (width - 2)
    
    # Calculate paddings for centered text
    var id_padding = " " * ((width - 2 - chunk_id.length()) / 2)
    var id_extra = " " if (width - 2 - chunk_id.length()) % 2 != 0 else ""
    
    var stream_text = "Stream: " + chunk_data.parent_stream
    var stream_padding = " " * ((width - 2 - stream_text.length()) / 2)
    var stream_extra = " " if (width - 2 - stream_text.length()) % 2 != 0 else ""
    
    var size_text = "Size: " + str(chunk_data.size)
    var size_padding = " " * ((width - 2 - size_text.length()) / 2)
    var size_extra = " " if (width - 2 - size_text.length()) % 2 != 0 else ""
    
    var visualization = COLOR_CHUNK
    visualization += BOX_TEMPLATE_2D[0].format({"top_line": top_bottom}) + "\n"
    visualization += BOX_TEMPLATE_2D[1].format({"title_line": id_padding + chunk_id + id_padding + id_extra}) + "\n"
    visualization += BOX_TEMPLATE_2D[2].format({"content1": stream_padding + stream_text + stream_padding + stream_extra}) + "\n"
    visualization += BOX_TEMPLATE_2D[3].format({"content2": size_padding + size_text + size_padding + size_extra}) + "\n"
    
    # Content preview
    var content_line = ""
    if chunk_data.has("content") and chunk_data.content.length() > 0:
        var content = chunk_data.content
        if content.length() > width - 12:
            content = content.substr(0, width - 15) + "..."
        var content_padding = " " * ((width - 2 - content.length()) / 2)
        var content_extra = " " if (width - 2 - content.length()) % 2 != 0 else ""
        content_line = content_padding + content + content_padding + content_extra
    else:
        content_line = " " * (width - 2)
    
    visualization += BOX_TEMPLATE_2D[4].format({"content3": content_line}) + "\n"
    visualization += BOX_TEMPLATE_2D[5].format({"bottom_line": top_bottom}) + "\n"
    visualization += COLOR_RESET
    
    return visualization

# 3D Chunk Visualization
func _visualize_chunk_3d(chunk_data: Dictionary, dimension: int) -> String:
    var chunk_id = chunk_data.id
    var width = min(max_terminal_width - 15, chunk_data.size + 20)
    
    # Create line templates
    var top_line = "_" * (width - 8)
    var mid_line = "_" * (width - 8)
    var bottom_line = "_" * (width - 8)
    
    # Prepare content lines
    var top_content = " " * (width - 8)
    
    # Chunk ID line with padding
    var chunk_id_padded = chunk_id
    if chunk_id.length() < width - 12:
        var padding = (width - 12 - chunk_id.length()) / 2
        chunk_id_padded = " " * padding + chunk_id + " " * padding
    else:
        chunk_id_padded = chunk_id.substr(0, width - 15) + "..."
    var title_line = "  " + chunk_id_padded + "  "
    
    # Chunk properties
    var stream_text = "  Stream: " + chunk_data.parent_stream
    var size_text = "  Size: " + str(chunk_data.size)
    var created_text = "  Created: " + _format_timestamp(chunk_data.created_at)
    
    # Pad properties to fit width
    stream_text += " " * (width - 8 - stream_text.length())
    size_text += " " * (width - 8 - size_text.length())
    created_text += " " * (width - 8 - created_text.length())
    
    # Content preview
    var content_line = ""
    if chunk_data.has("content") and chunk_data.content.length() > 0:
        var content = chunk_data.content
        if content.length() > width - 12:
            content = content.substr(0, width - 15) + "..."
        content_line = "  " + content
        content_line += " " * (width - 8 - content_line.length())
    else:
        content_line = " " * (width - 8)
    
    # Create visualization
    var visualization = COLOR_CHUNK
    visualization += BOX_TEMPLATE_3D[0].format({"top_line": top_line}) + "\n"
    visualization += BOX_TEMPLATE_3D[1].format({"top_content": top_content}) + "\n"
    visualization += BOX_TEMPLATE_3D[2].format({"title_line": title_line}) + "\n"
    visualization += BOX_TEMPLATE_3D[3].format({"mid_line": mid_line}) + "\n"
    visualization += BOX_TEMPLATE_3D[4].format({"content1": top_content}) + "\n"
    visualization += BOX_TEMPLATE_3D[5].format({"content2": stream_text}) + "\n"
    visualization += BOX_TEMPLATE_3D[6].format({"content3": size_text}) + "\n"
    visualization += BOX_TEMPLATE_3D[7].format({"content4": created_text}) + "\n"
    visualization += BOX_TEMPLATE_3D[8].format({"bottom_line": bottom_line}) + "\n"
    visualization += COLOR_RESET
    
    # Show dimensions based on dimension count
    if dimension >= 4:
        visualization += "\n" + COLOR_DIMENSION + "Dimensions: " + str(dimension) + "D" + COLOR_RESET + "\n"
        
        for d in range(4, dimension + 1):
            visualization += "  Dimension " + str(d) + ": " + _get_dimension_property(d) + "\n"
    
    # Display properties if available
    if chunk_data.has("properties"):
        visualization += "\n" + COLOR_SPLIT + "Properties:" + COLOR_RESET + "\n"
        for prop in chunk_data.properties:
            visualization += "  " + prop + ": " + str(chunk_data.properties[prop]) + "\n"
    
    return visualization

# Generate split visualization
func _generate_split_visualization(split_data: Dictionary) -> String:
    var original_chunk = split_data.original_chunk
    var resulting_chunks = split_data.resulting_chunks
    var factor = split_data.factor
    
    var visualization = COLOR_SUCCESS + "Split Operation:" + COLOR_RESET + "\n"
    visualization += "Original Chunk: " + original_chunk + "\n"
    visualization += "Split Factor: " + str(factor) + "\n\n"
    
    # Generate ASCII art visualization
    visualization += COLOR_CHUNK + original_chunk + COLOR_RESET + "\n"
    visualization += "    |\n"
    visualization += "    ▼\n"
    
    # Add arrows for each resulting chunk
    for i in range(resulting_chunks.size()):
        var spaces = " " * (4 + (i * 4))
        visualization += spaces + "↓\n"
        visualization += spaces + COLOR_CHUNK + resulting_chunks[i] + COLOR_RESET + "\n"
    
    return visualization

# Generate merge visualization
func _generate_merge_visualization(merge_data: Dictionary) -> String:
    var source_chunks = merge_data.source_chunks
    var result_chunk = merge_data.result_chunk
    var merge_type = merge_data.merge_type
    
    var visualization = COLOR_SUCCESS + "Merge Operation:" + COLOR_RESET + "\n"
    visualization += "Merge Type: " + merge_type + "\n\n"
    
    # Generate ASCII art for source chunks
    for i in range(source_chunks.size()):
        var spaces = " " * (4 + (i * 4))
        visualization += spaces + COLOR_CHUNK + source_chunks[i] + COLOR_RESET + "\n"
        visualization += spaces + "↓\n"
    
    // Add converging arrows
    var arrow_width = 4 + ((source_chunks.size() - 1) * 4)
    var arrows = ""
    for i in range(arrow_width):
        if i % 4 == 0:
            arrows += "↓"
        else:
            arrows += " "
    visualization += arrows + "\n"
    
    // Center result chunk
    var center_space = " " * (arrow_width / 2)
    visualization += center_space + COLOR_CHUNK + result_chunk + COLOR_RESET + "\n"
    
    return visualization

# Get textual description for higher dimensions
func _get_dimension_property(dimension: int) -> String:
    match dimension:
        4:
            return "Time"
        5:
            return "Consciousness"
        6:
            return "Soul"
        7:
            return "Creation"
        8:
            return "Harmony"
        9:
            return "Unity"
        10:
            return "Infinite"
        11:
            return "Transcendence"
        12:
            return "Divine"
        _:
            return "Unknown"

# Format timestamp to human-readable date string
func _format_timestamp(timestamp) -> String:
    var datetime = Time.get_datetime_dict_from_unix_time(timestamp)
    return "%04d-%02d-%02d %02d:%02d:%02d" % [
        datetime.year,
        datetime.month,
        datetime.day,
        datetime.hour,
        datetime.minute,
        datetime.second
    ]

# ----- PUBLIC UTILITY METHODS -----
# Set current dimension for visualizations
func set_dimension(dimension: int) -> void:
    current_dimension = dimension

# Set current reality for visualizations
func set_reality(reality: String) -> void:
    current_reality = reality

# Set visualization configuration
func configure(config: Dictionary) -> void:
    if config.has("max_terminal_width"):
        max_terminal_width = config.max_terminal_width
    
    if config.has("enable_colors"):
        enable_colors = config.enable_colors
    
    if config.has("enable_ascii_art"):
        enable_ascii_art = config.enable_ascii_art
    
    if config.has("enable_animations"):
        enable_animations = config.enable_animations
    
    if config.has("detail_level"):
        detail_level = config.detail_level