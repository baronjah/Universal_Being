class_name CSVStorage
extends RefCounted

var csv_data = {}

func initialize():
	pass

func store(key, value):
	if typeof(value) == TYPE_ARRAY:
		csv_data[key] = value
		return save_to_csv(key, value)
	return false

func retrieve(key):
	if key in csv_data:
		return csv_data[key]
	
	# Try to load from file if not in memory
	return load_from_csv(key)

func save_to_csv(key, data_array):
	var file_path = "user://data/" + key + ".csv"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		return false
	
	# Check if data is array of arrays or array of dictionaries
	if data_array.size() > 0:
		if typeof(data_array[0]) == TYPE_DICTIONARY:
			# Get headers from first dictionary
			var headers = data_array[0].keys()
			
			# Write header row
			var header_line = ""
			for i in range(headers.size()):
				if i > 0:
					header_line += ","
				header_line += str(headers[i])
			file.store_line(header_line)
			
			# Write data rows
			for item in data_array:
				var line = ""
				for i in range(headers.size()):
					if i > 0:
						line += ","
					var value = "" if not headers[i] in item else str(item[headers[i]])
					
					# Escape commas in the value
					if "," in value:
						value = "\"" + value + "\""
					line += value
				file.store_line(line)
		elif typeof(data_array[0]) == TYPE_ARRAY:
			# Write each row
			for row in data_array:
				var line = ""
				for i in range(row.size()):
					if i > 0:
						line += ","
					var value = str(row[i])
					
					# Escape commas in the value
					if "," in value:
						value = "\"" + value + "\""
					line += value
				file.store_line(line)
	
	return true

func load_from_csv(key):
	var file_path = "user://data/" + key + ".csv"
	
	if not FileAccess.file_exists(file_path):
		return null
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return null
	
	var result = []
	var headers = []
	var line_number = 0
	
	while not file.eof_reached():
		var line = file.get_line()
		if line.strip_edges() == "":
			continue
			
		# Parse CSV line
		var values = parse_csv_line(line)
		
		if line_number == 0:
			# First line could be headers
			headers = values
		else:
			if headers.size() > 0:
				# Create dictionary with headers as keys
				var item = {}
				for i in range(min(values.size(), headers.size())):
					item[headers[i]] = values[i]
				result.append(item)
			else:
				# No headers, just add the array
				result.append(values)
		
		line_number += 1
	
	# Store in memory
	csv_data[key] = result
	return result

func parse_csv_line(line):
	var values = []
	var current_value = ""
	var in_quotes = false
	
	for i in range(line.length()):
		var char = line[i]
		
		if char == "\"":
			in_quotes = !in_quotes
		elif char == "," and not in_quotes:
			values.append(current_value)
			current_value = ""
		else:
			current_value += char
	
	# Add the last value
	values.append(current_value)
	
	return values

func process_outgoing_data(data_payload):
	# For CSV data, we might need to format it properly
	if typeof(data_payload) == TYPE_ARRAY:
		# Already in CSV-compatible format
		return data_payload
	elif typeof(data_payload) == TYPE_DICTIONARY:
		# Convert dict to array with a single row
		return [data_payload]
	
	return data_payload

func process_incoming_data(data_payload):
	# Process incoming CSV format if needed
	return data_payload
