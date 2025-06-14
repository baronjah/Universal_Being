extends Node
class_name AkashicRecordsSystem

"""
AkashicRecordsSystem: Core data repository and organizational system
for the Ethereal Engine, handling dimensional data storage with memory
compression and scheme-based importance sorting.
"""

# Storage constants
const MAX_RECORD_SIZE = 1024 * 1024 * 500  # 500MB default max storage
const COMPRESSION_THRESHOLD = 1024 * 50     # 50KB threshold for compression
const CLEANUP_THRESHOLD = 0.9              # 90% full triggers cleanup

# Dimensional constants
const DIMENSIONS = 12
const DIMENSION_NAMES = [
	"GENESIS", "DUALITY", "EXPRESSION", "STABILITY",
	"TRANSFORMATION", "BALANCE", "ILLUMINATION", "REFLECTION",
	"HARMONY", "MANIFESTATION", "INTEGRATION", "TRANSCENDENCE"
]

# Importance scheme constants
const IMPORTANCE_LEVELS = {
	"CRITICAL": {"retention": 1.0, "dimension": 12},  # Never remove
	"HIGH": {"retention": 0.95, "dimension": 10},     # Keep 95%
	"MEDIUM": {"retention": 0.75, "dimension": 8},    # Keep 75%
	"LOW": {"retention": 0.5, "dimension": 6},        # Keep 50%
	"TRANSIENT": {"retention": 0.2, "dimension": 4}   # Keep 20%
}

# Signal declarations
signal record_added(record_id, dimension, importance)
signal record_accessed(record_id, access_count)
signal records_purged(count, freed_space)
signal dimension_expanded(dimension, new_capacity)

# Runtime variables
var records = {}
var dimensional_records = {}
var current_size = 0
var max_size = MAX_RECORD_SIZE
var scheme_index = {}
var access_history = {}

# Thread safety
var _mutex = Mutex.new()

# Initialization
func _ready():
	_initialize_dimensions()
	print("Akashic Records System initialized")
	print("Storage capacity: %s" % _format_size(max_size))

# Initialize the dimensional record spaces
func _initialize_dimensions():
	dimensional_records = {}
	
	for dim in range(1, DIMENSIONS + 1):
		dimensional_records[dim] = {
			"capacity": max_size / DIMENSIONS,
			"used": 0,
			"records": {},
			"energy_signature": _get_dimension_energy(dim)
		}
	
	print("12 dimensional record spaces initialized")

# Get the energy signature for a dimension
func _get_dimension_energy(dimension):
	var base_energies = [
		"creation",      # Dimension 1 - Genesis
		"duality",       # Dimension 2 - Duality
		"expression",    # Dimension 3 - Expression
		"stability",     # Dimension 4 - Stability
		"transformation", # Dimension 5 - Transformation
		"balance",       # Dimension 6 - Balance
		"illumination",  # Dimension 7 - Illumination
		"reflection",    # Dimension 8 - Reflection
		"harmony",       # Dimension 9 - Harmony
		"manifestation", # Dimension 10 - Manifestation
		"integration",   # Dimension 11 - Integration
		"transcendence"  # Dimension 12 - Transcendence
	]
	
	if dimension >= 1 and dimension <= 12:
		return base_energies[dimension - 1]
	else:
		return "unknown"

# Add a record to the Akashic Records
func add_record(data, metadata={}, importance="MEDIUM", dimension=null):
	_mutex.lock()
	
	# Generate record ID
	var timestamp = Time.get_unix_time_from_system()
	var record_id = "record_%d_%s" % [timestamp, str(data).sha256_text().substr(0, 8)]
	
	# Determine record size
	var size = _calculate_data_size(data)
	
	# Check if we need to make space
	if current_size + size > max_size * CLEANUP_THRESHOLD:
		_purge_records()
	
	# Determine dimension if not specified
	if dimension == null:
		if importance in IMPORTANCE_LEVELS:
			dimension = IMPORTANCE_LEVELS[importance].dimension
		else:
			# Default to middle dimension
			dimension = 6
	
	# Prepare the record
	var compress = size > COMPRESSION_THRESHOLD
	var stored_data = _prepare_data_for_storage(data, compress)
	
	records[record_id] = {
		"data": stored_data,
		"size": size,
		"compressed": compress,
		"timestamp": timestamp,
		"metadata": metadata,
		"importance": importance,
		"dimension": dimension,
		"access_count": 0,
		"last_access": timestamp
	}
	
	# Add to dimensional records
	if dimension >= 1 and dimension <= DIMENSIONS:
		dimensional_records[dimension].records[record_id] = records[record_id]
		dimensional_records[dimension].used += size
	
	# Update current size
	current_size += size
	
	# Index by importance
	if not importance in scheme_index:
		scheme_index[importance] = []
	scheme_index[importance].append(record_id)
	
	_mutex.unlock()
	
	# Emit signal
	emit_signal("record_added", record_id, dimension, importance)
	print("Record added: %s (Size: %s, Dimension: %d, Importance: %s)" % 
		[record_id, _format_size(size), dimension, importance])
	
	return record_id

# Get a record by ID
func get_record(record_id):
	if not record_id in records:
		return null
	
	_mutex.lock()
	
	var record = records[record_id]
	var data = record.data
	
	# If data is compressed, decompress it
	if record.compressed:
		data = _decompress_data(data)
	
	# Update access statistics
	record.access_count += 1
	record.last_access = Time.get_unix_time_from_system()
	
	if not record_id in access_history:
		access_history[record_id] = []
	
	access_history[record_id].append({
		"timestamp": record.last_access,
		"context": get_stack()[1].function if get_stack().size() > 1 else "unknown"
	})
	
	_mutex.unlock()
	
	# Emit signal
	emit_signal("record_accessed", record_id, record.access_count)
	
	return {
		"data": data,
		"metadata": record.metadata,
		"importance": record.importance,
		"dimension": record.dimension,
		"timestamp": record.timestamp,
		"access_count": record.access_count
	}

# Update an existing record
func update_record(record_id, new_data, new_metadata=null):
	if not record_id in records:
		return false
	
	_mutex.lock()
	
	var record = records[record_id]
	var old_size = record.size
	var new_size = _calculate_data_size(new_data)
	var dimension = record.dimension
	
	# Remove old size from accounting
	current_size -= old_size
	dimensional_records[dimension].used -= old_size
	
	# Prepare new data
	var compress = new_size > COMPRESSION_THRESHOLD
	var stored_data = _prepare_data_for_storage(new_data, compress)
	
	# Update record
	record.data = stored_data
	record.size = new_size
	record.compressed = compress
	record.last_access = Time.get_unix_time_from_system()
	
	# Update metadata if provided
	if new_metadata != null:
		record.metadata = new_metadata
	
	# Update size tracking
	current_size += new_size
	dimensional_records[dimension].used += new_size
	
	_mutex.unlock()
	
	print("Record updated: %s (New size: %s)" % [record_id, _format_size(new_size)])
	return true

# Delete a record
func delete_record(record_id):
	if not record_id in records:
		return false
	
	_mutex.lock()
	
	var record = records[record_id]
	var size = record.size
	var dimension = record.dimension
	var importance = record.importance
	
	# Update size tracking
	current_size -= size
	dimensional_records[dimension].used -= size
	
	# Remove from dimension records
	dimensional_records[dimension].records.erase(record_id)
	
	# Remove from importance index
	if importance in scheme_index and record_id in scheme_index[importance]:
		scheme_index[importance].erase(record_id)
	
	# Remove access history
	access_history.erase(record_id)
	
	# Remove the record
	records.erase(record_id)
	
	_mutex.unlock()
	
	print("Record deleted: %s (Freed: %s)" % [record_id, _format_size(size)])
	return true

# Get all records in a dimension
func get_dimensional_records(dimension):
	if dimension < 1 or dimension > DIMENSIONS:
		return []
	
	_mutex.lock()
	var result = dimensional_records[dimension].records.keys()
	_mutex.unlock()
	
	return result

# Get all records of a specific importance
func get_records_by_importance(importance):
	if not importance in scheme_index:
		return []
	
	_mutex.lock()
	var result = scheme_index[importance].duplicate()
	_mutex.unlock()
	
	return result

# Filter records by metadata value
func filter_records(key, value):
	_mutex.lock()
	
	var matching_records = []
	
	for record_id in records:
		var record = records[record_id]
		
		if key in record.metadata and record.metadata[key] == value:
			matching_records.append(record_id)
	
	_mutex.unlock()
	
	return matching_records

# Get total records count and size statistics
func get_statistics():
	_mutex.lock()
	
	var stats = {
		"total_records": records.size(),
		"total_size": current_size,
		"max_size": max_size,
		"usage_percentage": float(current_size) / max_size,
		"dimensions": {},
		"importance": {}
	}
	
	# Gather dimension statistics
	for dim in range(1, DIMENSIONS + 1):
		stats.dimensions[dim] = {
			"name": DIMENSION_NAMES[dim-1],
			"record_count": dimensional_records[dim].records.size(),
			"used_size": dimensional_records[dim].used,
			"capacity": dimensional_records[dim].capacity,
			"usage_percentage": float(dimensional_records[dim].used) / dimensional_records[dim].capacity
		}
	
	# Gather importance statistics
	for imp in scheme_index:
		var imp_records = scheme_index[imp]
		var imp_size = 0
		
		for record_id in imp_records:
			if record_id in records:
				imp_size += records[record_id].size
		
		stats.importance[imp] = {
			"record_count": imp_records.size(),
			"total_size": imp_size,
			"percentage_of_total": float(imp_size) / max(current_size, 1)
		}
	
	_mutex.unlock()
	
	return stats

# Purge records based on importance and retention settings
func _purge_records():
	_mutex.lock()
	
	print("Initiating record purge. Current usage: %s/%s (%.1f%%)" % 
		[_format_size(current_size), _format_size(max_size), 
		float(current_size) / max_size * 100])
	
	# Group records by importance
	var records_by_importance = {}
	
	for imp in IMPORTANCE_LEVELS.keys():
		records_by_importance[imp] = []
	
	# Populate the groups
	for record_id in records:
		var record = records[record_id]
		var importance = record.importance
		
		if importance in records_by_importance:
			records_by_importance[importance].append({
				"id": record_id,
				"size": record.size,
				"access_count": record.access_count,
				"last_access": record.last_access,
				"timestamp": record.timestamp
			})
	
	# Sort records in each group by access recency and frequency
	for imp in records_by_importance:
		records_by_importance[imp].sort_custom(Callable(self, "_sort_by_importance"))
	
	# Calculate how much space to free
	var target_reduction = current_size - (max_size * 0.7)  # Aim to reduce to 70% usage
	var space_freed = 0
	var purged_count = 0
	
	# Purge records starting from least important and least accessed
	for imp in ["TRANSIENT", "LOW", "MEDIUM", "HIGH"]:  # CRITICAL is never purged
		if space_freed >= target_reduction:
			break
			
		var retention = IMPORTANCE_LEVELS[imp].retention
		var purge_count = int(records_by_importance[imp].size() * (1.0 - retention))
		
		# Skip if we should keep all records in this category
		if purge_count <= 0:
			continue
		
		# Limit purge count to prevent excessive deletion
		purge_count = min(purge_count, records_by_importance[imp].size())
		
		# Purge the calculated number of records
		for i in range(purge_count):
			if i >= records_by_importance[imp].size():
				break
				
			var record_info = records_by_importance[imp][i]
			var record_id = record_info.id
			
			if delete_record(record_id):
				space_freed += record_info.size
				purged_count += 1
				
				if space_freed >= target_reduction:
					break
	
	_mutex.unlock()
	
	# Emit signal
	emit_signal("records_purged", purged_count, space_freed)
	
	print("Purge complete. Removed %d records, freed %s" % [purged_count, _format_size(space_freed)])
	return space_freed

# Custom sort function for record purging
func _sort_by_importance(a, b):
	# Sort by access count (ascending)
	if a.access_count != b.access_count:
		return a.access_count < b.access_count
	
	# Then by last access time (oldest first)
	if a.last_access != b.last_access:
		return a.last_access < b.last_access
	
	# Then by creation time (oldest first)
	return a.timestamp < b.timestamp

# Calculate the size of a data object
func _calculate_data_size(data):
	if data is String:
		return data.length() * 2  # Approximate size for UTF-16 encoding
	elif data is Dictionary or data is Array:
		var json_str = JSON.stringify(data)
		return json_str.length() * 2
	else:
		return 1024  # Default size for other types
	
# Prepare data for storage, optionally compressing it
func _prepare_data_for_storage(data, compress=false):
	var stored_data
	
	if data is String:
		stored_data = data
	elif data is Dictionary or data is Array:
		stored_data = JSON.stringify(data)
	else:
		stored_data = str(data)
	
	if compress:
		return _compress_data(stored_data)
	else:
		return stored_data

# Compress string data
func _compress_data(data_string):
	# This is a placeholder for actual compression
	# In a real implementation, you'd use a compression library
	return data_string  # Placeholder - no actual compression

# Decompress string data
func _decompress_data(compressed_data):
	# This is a placeholder for actual decompression
	# In a real implementation, you'd use a compression library
	return compressed_data  # Placeholder - no actual decompression

# Format a size in bytes to human-readable format
func _format_size(size_bytes):
	if size_bytes < 1024:
		return "%d B" % size_bytes
	elif size_bytes < 1024 * 1024:
		return "%.1f KB" % (size_bytes / 1024.0)
	elif size_bytes < 1024 * 1024 * 1024:
		return "%.1f MB" % (size_bytes / (1024.0 * 1024.0))
	else:
		return "%.1f GB" % (size_bytes / (1024.0 * 1024.0 * 1024.0))

# Expand the capacity of a dimensional record space
func expand_dimension_capacity(dimension, additional_capacity):
	if dimension < 1 or dimension > DIMENSIONS:
		return false
	
	_mutex.lock()
	
	var old_capacity = dimensional_records[dimension].capacity
	dimensional_records[dimension].capacity += additional_capacity
	max_size += additional_capacity
	
	_mutex.unlock()
	
	# Emit signal
	emit_signal("dimension_expanded", dimension, dimensional_records[dimension].capacity)
	
	print("Dimension %d expanded: %s → %s" % [
		dimension,
		_format_size(old_capacity),
		_format_size(dimensional_records[dimension].capacity)
	])
	
	return true

# Import external data into the Akashic Records
func import_data(source_path, importance="MEDIUM", dimension=null):
	if not FileAccess.file_exists(source_path):
		print("Error: Source file does not exist: %s" % source_path)
		return null
	
	# Determine file type from extension
	var extension = source_path.get_extension().to_lower()
	var data
	
	if extension == "json":
		# Import JSON file
		var file = FileAccess.open(source_path, FileAccess.READ)
		var json_text = file.get_as_text()
		file.close()
		
		var json_result = JSON.parse_string(json_text)
		if json_result != null:
			data = json_result
		else:
			print("Error parsing JSON from %s" % source_path)
			return null
			
	elif extension in ["txt", "md", "gd", "cs", "py", "js"]:
		# Import text file
		var file = FileAccess.open(source_path, FileAccess.READ)
		data = file.get_as_text()
		file.close()
		
	else:
		# Other file types - store path reference
		data = "FILE_REFERENCE:" + source_path
	
	# Create metadata
	var metadata = {
		"source_file": source_path,
		"file_type": extension,
		"import_time": Time.get_unix_time_from_system()
	}
	
	# Add to records
	return add_record(data, metadata, importance, dimension)

# Create a scheme for organizing records
func create_organization_scheme(name, criteria={}):
	_mutex.lock()
	
	# Create a scheme configuration
	var scheme = {
		"name": name,
		"criteria": criteria,
		"created": Time.get_unix_time_from_system(),
		"record_count": 0
	}
	
	# Apply the scheme to existing records
	var matching_records = []
	
	for record_id in records:
		var record = records[record_id]
		var matches = true
		
		for key in criteria:
			if key == "dimension":
				if record.dimension != criteria[key]:
					matches = false
					break
			elif key == "importance":
				if record.importance != criteria[key]:
					matches = false
					break
			elif key == "metadata":
				for meta_key in criteria[key]:
					if not meta_key in record.metadata or record.metadata[meta_key] != criteria[key][meta_key]:
						matches = false
						break
			elif key == "min_access_count":
				if record.access_count < criteria[key]:
					matches = false
					break
			elif key == "max_age_days":
				var age_days = (Time.get_unix_time_from_system() - record.timestamp) / 86400
				if age_days > criteria[key]:
					matches = false
					break
		
		if matches:
			matching_records.append(record_id)
	
	scheme.record_count = matching_records.size()
	
	_mutex.unlock()
	
	print("Created organization scheme '%s' with %d matching records" % [name, matching_records.size()])
	return {
		"scheme": scheme,
		"matching_records": matching_records
	}

# Export records to file
func export_records(records_ids, export_path, format="json"):
	_mutex.lock()
	
	var export_data = {}
	
	for record_id in records_ids:
		if record_id in records:
			var record = records[record_id]
			var data = record.data
			
			if record.compressed:
				data = _decompress_data(data)
				
			export_data[record_id] = {
				"data": data,
				"metadata": record.metadata,
				"importance": record.importance,
				"dimension": record.dimension,
				"timestamp": record.timestamp
			}
	
	_mutex.unlock()
	
	if export_data.size() == 0:
		print("No valid records to export")
		return false
	
	# Export in the specified format
	if format == "json":
		var file = FileAccess.open(export_path, FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(export_data, "  "))
			file.close()
			print("Exported %d records to %s" % [export_data.size(), export_path])
			return true
	
	return false