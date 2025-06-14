extends Node
# Segment Processor System
# Turn 5: Awakening - Data segmentation, folding, and processing system

# Configuration
const MAX_SEGMENTS = 12
const DEFAULT_SEGMENT_SIZE = 3
const MAX_BRACKET_DEPTH = 3
const AUTO_CALIBRATION_INTERVAL = 60  # seconds

# Segment storage
var segments = {}
var segment_order = []
var current_segment_id = 0

# Bracket tracking
var bracket_stack = []
var bracket_pairs = {
	"{": "}",
	"[": "]",
	"(": ")",
	"<": ">",
	"«": "»"
}

# Folding state
var folded_segments = {}
var fold_visibility = {}

# OCR calibration
var ocr_calibration_level = 0.95  # 95% accuracy
var last_calibration_time = 0
var calibration_count = 0

# Signal definitions
signal segment_created(segment_id, data)
signal segment_modified(segment_id, data)
signal segment_folded(segment_id)
signal segment_unfolded(segment_id)
signal bracket_limit_reached()
signal ocr_calibrated(new_level)

# Initialize the processor
func _ready():
	print("Segment Processor initialized")
	last_calibration_time = Time.get_unix_time_from_system()
	
	# Connect to signals as needed
	# self.connect("segment_created", self, "_on_segment_created")

# Process function - check for calibration needs
func _process(delta):
	# Check if OCR calibration is needed
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_calibration_time > AUTO_CALIBRATION_INTERVAL:
		auto_calibrate_ocr()

# Create a new segment with the given data
func create_segment(data, segment_id = -1):
	# If no ID specified, use next available
	if segment_id < 0:
		segment_id = get_next_segment_id()
	
	# Ensure we don't exceed segment limit
	if segments.size() >= MAX_SEGMENTS and not segments.has(segment_id):
		printerr("Maximum number of segments reached")
		return -1
	
	# Segment the data into parts of DEFAULT_SEGMENT_SIZE
	var segment_parts = []
	for i in range(0, data.length(), DEFAULT_SEGMENT_SIZE):
		var end = min(i + DEFAULT_SEGMENT_SIZE, data.length())
		segment_parts.append(data.substr(i, end - i))
	
	# Create the segment
	segments[segment_id] = {
		"data": data,
		"parts": segment_parts,
		"created": Time.get_unix_time_from_system(),
		"modified": Time.get_unix_time_from_system(),
		"folded": false,
		"brackets": []
	}
	
	# Update segment order if needed
	if not segment_id in segment_order:
		segment_order.append(segment_id)
	
	# Update current segment ID
	current_segment_id = segment_id
	
	# Emit signal
	emit_signal("segment_created", segment_id, segments[segment_id])
	
	return segment_id

# Get the next available segment ID
func get_next_segment_id():
	# Find the smallest unused ID
	var id = 0
	while segments.has(id):
		id += 1
	return id

# Modify an existing segment
func modify_segment(segment_id, new_data):
	if not segments.has(segment_id):
		printerr("Segment ID not found: ", segment_id)
		return false
	
	# Update segment data
	segments[segment_id].data = new_data
	segments[segment_id].modified = Time.get_unix_time_from_system()
	
	# Re-segment the data
	var segment_parts = []
	for i in range(0, new_data.length(), DEFAULT_SEGMENT_SIZE):
		var end = min(i + DEFAULT_SEGMENT_SIZE, new_data.length())
		segment_parts.append(new_data.substr(i, end - i))
	
	segments[segment_id].parts = segment_parts
	
	# Emit signal
	emit_signal("segment_modified", segment_id, segments[segment_id])
	
	return true

# Delete a segment
func delete_segment(segment_id):
	if not segments.has(segment_id):
		printerr("Segment ID not found: ", segment_id)
		return false
	
	# Remove segment
	segments.erase(segment_id)
	
	# Update segment order
	segment_order.erase(segment_id)
	
	# If current segment was deleted, set to last one
	if current_segment_id == segment_id and segment_order.size() > 0:
		current_segment_id = segment_order.back()
	
	return true

# Fold a segment with brackets
func fold_segment(segment_id, bracket_type = "{}"):
	if not segments.has(segment_id):
		printerr("Segment ID not found: ", segment_id)
		return false
	
	# Check if already folded
	if segments[segment_id].folded:
		printerr("Segment already folded: ", segment_id)
		return false
	
	# Check bracket stack depth
	if bracket_stack.size() >= MAX_BRACKET_DEPTH:
		printerr("Maximum bracket depth reached")
		emit_signal("bracket_limit_reached")
		return false
	
	# Get opening and closing brackets
	var open_bracket = "{"
	var close_bracket = "}"
	
	if bracket_type.length() >= 2:
		open_bracket = bracket_type[0]
		close_bracket = bracket_type[1]
	elif bracket_pairs.has(bracket_type):
		open_bracket = bracket_type
		close_bracket = bracket_pairs[bracket_type]
	
	# Update segment
	segments[segment_id].folded = true
	segments[segment_id].brackets = [open_bracket, close_bracket]
	
	# Update bracket stack
	bracket_stack.append({
		"segment_id": segment_id,
		"bracket_type": bracket_type
	})
	
	# Track fold visibility
	fold_visibility[segment_id] = false
	
	# Emit signal
	emit_signal("segment_folded", segment_id)
	
	return true

# Unfold a segment
func unfold_segment(segment_id):
	if not segments.has(segment_id):
		printerr("Segment ID not found: ", segment_id)
		return false
	
	# Check if actually folded
	if not segments[segment_id].folded:
		printerr("Segment not folded: ", segment_id)
		return false
	
	# Update segment
	segments[segment_id].folded = false
	segments[segment_id].brackets = []
	
	# Update bracket stack
	for i in range(bracket_stack.size()):
		if bracket_stack[i].segment_id == segment_id:
			bracket_stack.remove_at(i)
			break
	
	# Remove from fold visibility
	if fold_visibility.has(segment_id):
		fold_visibility.erase(segment_id)
	
	# Emit signal
	emit_signal("segment_unfolded", segment_id)
	
	return true

# Toggle fold visibility
func toggle_fold_visibility(segment_id):
	if not segments.has(segment_id) or not segments[segment_id].folded:
		return false
	
	if fold_visibility.has(segment_id):
		fold_visibility[segment_id] = !fold_visibility[segment_id]
	else:
		fold_visibility[segment_id] = true
	
	return fold_visibility[segment_id]

# Process a line of user input, segmenting if needed
func process_user_input(input_text):
	# Check if input matches a bracket pattern for folding/unfolding
	if input_text.strip_edges() == "}" or input_text.strip_edges() == "]" or input_text.strip_edges() == ")":
		# Try to unfold the last segment in bracket stack
		if bracket_stack.size() > 0:
			var last_bracket = bracket_stack.back()
			unfold_segment(last_bracket.segment_id)
			return {
				"action": "unfold",
				"segment_id": last_bracket.segment_id
			}
	
	# Check if input starts with a bracket for folding
	if input_text.strip_edges().begins_with("{") or input_text.strip_edges().begins_with("[") or input_text.strip_edges().begins_with("("):
		# Create a new segment and fold it
		var bracket_type = input_text.strip_edges()[0] + bracket_pairs[input_text.strip_edges()[0]]
		var content = input_text.strip_edges().substr(1)
		
		var segment_id = create_segment(content)
		fold_segment(segment_id, bracket_type)
		
		return {
			"action": "fold",
			"segment_id": segment_id,
			"bracket_type": bracket_type
		}
	
	# Default to creating a new segment
	var segment_id = create_segment(input_text)
	
	return {
		"action": "create",
		"segment_id": segment_id
	}

# Split a line into multiple segments (segmenting)
func segment_line(line, segment_size = DEFAULT_SEGMENT_SIZE):
	var segments = []
	for i in range(0, line.length(), segment_size):
		var end = min(i + segment_size, line.length())
		segments.append(line.substr(i, end - i))
	
	return segments

# OCR calibration
func calibrate_ocr(manual_adjustment = 0.01):
	ocr_calibration_level = min(0.99, ocr_calibration_level + manual_adjustment)
	last_calibration_time = Time.get_unix_time_from_system()
	calibration_count += 1
	
	emit_signal("ocr_calibrated", ocr_calibration_level)
	
	return ocr_calibration_level

# Automatic OCR calibration
func auto_calibrate_ocr():
	# Auto-calibration improves at a slower rate
	var auto_adjustment = 0.002
	return calibrate_ocr(auto_adjustment)

# Process text through OCR simulation
func process_ocr(text):
	# Simulate OCR processing with accuracy based on calibration level
	var processed_text = text
	
	# If OCR is not perfect, introduce some errors based on accuracy
	if ocr_calibration_level < 0.99:
		var chars = text.to_utf8_buffer()
		var error_chance = 1.0 - ocr_calibration_level
		
		for i in range(chars.size()):
			if randf() < error_chance:
				# Simulate OCR error - replace with a similar character
				match chars[i]:
					ord('0'): chars[i] = ord('o')
					ord('1'): chars[i] = ord('l')
					ord('l'): chars[i] = ord('1')
					ord('o'): chars[i] = ord('0')
					ord('e'): chars[i] = ord('c')
					ord('a'): chars[i] = ord('o')
					ord('n'): chars[i] = ord('m')
					ord('m'): chars[i] = ord('n')
					ord('i'): chars[i] = ord('l')
		
		processed_text = chars.get_string_from_utf8()
	
	return processed_text

# Correct OCR errors in text automatically
func correct_ocr_errors(text):
	# Implement common OCR error corrections
	var corrected = text
	
	# Dictionary of common OCR errors and corrections
	var corrections = {
		"teh": "the",
		"adn": "and",
		"wiht": "with",
		"waht": "what",
		"taht": "that",
		"thier": "their",
		"tiem": "time",
		"toekn": "token",
		"easid": "erase",
		"nemib": "remember",
		"accress": "access",
		"unlockabe": "unlockable"
	}
	
	# Replace common OCR errors
	for error in corrections:
		corrected = corrected.replace(error, corrections[error])
	
	return corrected

# Self-check and restore system
func self_check_and_restore():
	var issues_found = 0
	var issues_fixed = 0
	
	# Check segments integrity
	for segment_id in segments:
		var segment = segments[segment_id]
		
		# Check if parts match the data
		var reconstructed_data = "".join(segment.parts)
		if reconstructed_data != segment.data:
			issues_found += 1
			
			# Attempt to fix by re-segmenting
			var segment_parts = []
			for i in range(0, segment.data.length(), DEFAULT_SEGMENT_SIZE):
				var end = min(i + DEFAULT_SEGMENT_SIZE, segment.data.length())
				segment_parts.append(segment.data.substr(i, end - i))
			
			segment.parts = segment_parts
			issues_fixed += 1
	
	# Check bracket stack integrity
	var valid_bracket_stack = []
	for bracket in bracket_stack:
		if segments.has(bracket.segment_id) and segments[bracket.segment_id].folded:
			valid_bracket_stack.append(bracket)
		else:
			issues_found += 1
			# Invalid bracket reference
	
	if valid_bracket_stack.size() != bracket_stack.size():
		bracket_stack = valid_bracket_stack
		issues_fixed += 1
	
	# Check fold visibility consistency
	var valid_fold_visibility = {}
	for segment_id in fold_visibility:
		if segments.has(segment_id) and segments[segment_id].folded:
			valid_fold_visibility[segment_id] = fold_visibility[segment_id]
		else:
			issues_found += 1
	
	if valid_fold_visibility.size() != fold_visibility.size():
		fold_visibility = valid_fold_visibility
		issues_fixed += 1
	
	# Check segment order validity
	var valid_segment_order = []
	for segment_id in segment_order:
		if segments.has(segment_id):
			valid_segment_order.append(segment_id)
		else:
			issues_found += 1
	
	if valid_segment_order.size() != segment_order.size():
		segment_order = valid_segment_order
		issues_fixed += 1
	
	# Check current segment ID validity
	if current_segment_id != 0 and not segments.has(current_segment_id):
		issues_found += 1
		current_segment_id = segment_order.back() if segment_order.size() > 0 else 0
		issues_fixed += 1
	
	return {
		"issues_found": issues_found,
		"issues_fixed": issues_fixed,
		"status": "OK" if issues_fixed == issues_found else "WARNING"
	}

# Export all segments as a single text
func export_all_segments():
	var result = ""
	
	for segment_id in segment_order:
		if not segments.has(segment_id):
			continue
		
		var segment = segments[segment_id]
		
		if segment.folded:
			result += segment.brackets[0]  # Opening bracket
		
		result += segment.data
		
		if segment.folded:
			result += segment.brackets[1]  # Closing bracket
		
		result += "\n"
	
	return result

# Import text and create segments
func import_text(text, segment_size = DEFAULT_SEGMENT_SIZE):
	# Clear existing segments
	segments.clear()
	segment_order.clear()
	bracket_stack.clear()
	fold_visibility.clear()
	current_segment_id = 0
	
	# Split text into lines
	var lines = text.split("\n")
	
	# Process each line
	for line in lines:
		if line.strip_edges() == "":
			continue
		
		process_user_input(line)
	
	return segments.size()

# Generate a standard report
func generate_report():
	var report = "Segment Processor Report\n"
	report += "------------------------\n\n"
	
	report += "Total Segments: %d/%d\n" % [segments.size(), MAX_SEGMENTS]
	report += "Folded Segments: %d\n" % [bracket_stack.size()]
	report += "Bracket Depth: %d/%d\n" % [bracket_stack.size(), MAX_BRACKET_DEPTH]
	report += "OCR Calibration: %.2f%%\n" % [ocr_calibration_level * 100]
	report += "OCR Calibrations: %d\n" % [calibration_count]
	report += "Last Calibration: %s\n\n" % [Time.get_datetime_string_from_unix_time(last_calibration_time)]
	
	report += "Segments:\n"
	for segment_id in segment_order:
		var segment = segments[segment_id]
		var status = "Normal"
		if segment.folded:
			status = "Folded " + segment.brackets[0] + segment.brackets[1]
		
		report += "  %d: %s (%d chars, %d parts)\n" % [
			segment_id, 
			status, 
			segment.data.length(),
			segment.parts.size()
		]
	
	if bracket_stack.size() > 0:
		report += "\nBracket Stack:\n"
		for i in range(bracket_stack.size()):
			var bracket = bracket_stack[i]
			report += "  %d: Segment %d (%s)\n" % [
				i,
				bracket.segment_id,
				bracket.bracket_type
			]
	
	return report