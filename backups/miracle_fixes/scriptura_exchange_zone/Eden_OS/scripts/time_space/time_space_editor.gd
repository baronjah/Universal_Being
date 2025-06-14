extends Node

class_name TimeSpaceEditor

# Time Space Editor for Eden_OS
# Allows manipulation of data across timelines and dimensions
# Integrates with Data Zone Manager and Akashic Records

signal timeline_created(timeline_name)
signal timeline_edited(timeline_name, operation_type)
signal timeline_merged(source_timeline, target_timeline)
signal data_modified_in_timeline(data_id, timeline_name)
signal temporal_consistency_enforced(affected_timelines)
signal paradox_detected(details)
signal causal_chain_updated(chain_details)

# TimeSpace constants
const OPERATION_TYPES = {
	"insert": {"causality_impact": 0.3, "stability_impact": 0.2, "permission_level": 1},
	"modify": {"causality_impact": 0.5, "stability_impact": 0.4, "permission_level": 2},
	"delete": {"causality_impact": 0.7, "stability_impact": 0.6, "permission_level": 3},
	"rewrite": {"causality_impact": 0.9, "stability_impact": 0.8, "permission_level": 4}
}

const MAX_PARADOX_LEVEL = 0.8  # Level at which paradoxes occur
const TEMPORAL_OPERATION_COOLDOWN = 10.0  # Seconds between temporal operations

# System state
var active_timeline = "main"
var active_dimension = "alpha"
var time_pointer = 0  # Current position in time (unix timestamp)
var edit_history = {}
var causal_chains = {}
var temporal_locks = {}
var temporal_branches = {}
var last_operation_time = 0
var paradox_suppression_active = false
var time_dilation_factor = 1.0

# Integration with other systems
var data_zone_manager = null
var akashic_records = null
var turn_system = null
var dimension_engine = null

# Temporal stability metrics
var timeline_stability = {}
var causal_integrity = {}
var paradox_potential = {}

func _ready():
	initialize_time_space_editor()
	print("TimeSpaceEditor initialized")

func _process(delta):
	# Apply time dilation
	var effective_delta = delta * time_dilation_factor
	
	# Process temporal operations
	_process_temporal_operations(effective_delta)
	
	# Monitor for paradoxes
	if not paradox_suppression_active:
		_check_paradox_potential()

func initialize_time_space_editor():
	# Connect to dependent systems
	if get_node_or_null("/root/DataZoneManager"):
		data_zone_manager = get_node("/root/DataZoneManager")
	
	if get_node_or_null("/root/AkashicRecords"):
		akashic_records = get_node("/root/AkashicRecords")
	
	if get_node_or_null("/root/TurnSystem"):
		turn_system = get_node("/root/TurnSystem")
	
	if get_node_or_null("/root/DimensionEngine"):
		dimension_engine = get_node("/root/DimensionEngine")
	
	# Initialize main timeline
	time_pointer = Time.get_unix_time_from_system()
	_initialize_timeline("main")
	
	# Initialize causal chains for main timeline
	causal_chains["main"] = []

func _initialize_timeline(timeline_name):
	# Create initial timeline structure
	edit_history[timeline_name] = []
	
	# Set initial temporal stability
	timeline_stability[timeline_name] = 1.0
	causal_integrity[timeline_name] = 1.0
	paradox_potential[timeline_name] = 0.0
	
	# Create temporal locks structure
	temporal_locks[timeline_name] = []

# Core TimeSpace operations

func create_timeline(timeline_name, source_timeline="main", creator="system"):
	# Create a new timeline branching from source
	
	# Check if timeline already exists
	if edit_history.has(timeline_name):
		return {"success": false, "error": "Timeline already exists: " + timeline_name}
	
	# Check if source timeline exists
	if not edit_history.has(source_timeline):
		return {"success": false, "error": "Source timeline not found: " + source_timeline}
	
	# Create new timeline based on source
	edit_history[timeline_name] = edit_history[source_timeline].duplicate(true)
	
	# Set initial temporal stability based on source with slight degradation
	timeline_stability[timeline_name] = timeline_stability[source_timeline] * 0.95
	causal_integrity[timeline_name] = causal_integrity[source_timeline] * 0.95
	paradox_potential[timeline_name] = paradox_potential[source_timeline] + 0.05
	
	# Initialize empty temporal locks
	temporal_locks[timeline_name] = []
	
	# Record branch information
	temporal_branches[timeline_name] = {
		"source": source_timeline,
		"branch_point": time_pointer,
		"created": Time.get_unix_time_from_system(),
		"creator": creator
	}
	
	# Create causal chain based on source
	causal_chains[timeline_name] = causal_chains[source_timeline].duplicate(true)
	
	# Emit signal
	emit_signal("timeline_created", timeline_name)
	
	# Integrate with Akashic Records if available
	if akashic_records != null:
		var result = akashic_records.create_timeline(timeline_name, source_timeline, creator)
		
		if not result.get("success", false):
			print("Warning: Failed to create timeline in Akashic Records: " + result.get("error", "Unknown error"))
	
	return {
		"success": true,
		"timeline": timeline_name,
		"source": source_timeline,
		"stability": timeline_stability[timeline_name]
	}

func switch_timeline(timeline_name):
	# Switch to a different timeline
	
	# Check if timeline exists
	if not edit_history.has(timeline_name):
		return {"success": false, "error": "Timeline not found: " + timeline_name}
	
	# Record previous timeline
	var previous = active_timeline
	
	# Set new active timeline
	active_timeline = timeline_name
	
	# Integrate with Akashic Records if available
	if akashic_records != null:
		akashic_records.switch_timeline(timeline_name)
	
	return {
		"success": true,
		"previous": previous,
		"current": active_timeline
	}

func edit_timeline_data(data_id, new_data, operation_type="modify", metadata={}):
	# Edit data within the current timeline
	
	# Check operation cooldown
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_operation_time < TEMPORAL_OPERATION_COOLDOWN:
		return {"success": false, "error": "Temporal operation cooldown in effect. Please wait " + str(TEMPORAL_OPERATION_COOLDOWN - (current_time - last_operation_time)) + " seconds"}
	
	# Validate operation type
	if not OPERATION_TYPES.has(operation_type):
		return {"success": false, "error": "Invalid operation type: " + operation_type}
	
	# Check for temporal locks
	if _is_data_locked(data_id, active_timeline):
		return {"success": false, "error": "Data is temporally locked in this timeline"}
	
	# Calculate causality impact
	var causality_impact = OPERATION_TYPES[operation_type]["causality_impact"]
	var stability_impact = OPERATION_TYPES[operation_type]["stability_impact"]
	
	# Apply time-based modifications to impact
	var time_factor = _calculate_time_factor()
	causality_impact *= time_factor
	stability_impact *= time_factor
	
	# Record edit in timeline
	var edit_record = {
		"data_id": data_id,
		"operation": operation_type,
		"timestamp": time_pointer,
		"real_time": current_time,
		"previous_data": null,  # Will be filled if editing existing data
		"new_data": new_data,
		"metadata": metadata,
		"causality_impact": causality_impact,
		"stability_impact": stability_impact
	}
	
	# Fetch previous data if possible
	var previous_data = _get_data_in_timeline(data_id, active_timeline)
	if previous_data.get("success", false):
		edit_record["previous_data"] = previous_data.get("data")
	
	# Add edit to history
	edit_history[active_timeline].append(edit_record)
	
	# Update the actual data in storage systems
	var storage_result = _update_data_in_storage(data_id, new_data, operation_type, metadata)
	
	if not storage_result.get("success", false):
		return {"success": false, "error": "Failed to update storage: " + storage_result.get("error", "Unknown error")}
	
	# Update causal chain
	_update_causal_chain(data_id, operation_type)
	
	# Update timeline stability metrics
	_update_timeline_metrics(active_timeline, causality_impact, stability_impact)
	
	# Update last operation time
	last_operation_time = current_time
	
	# Emit signal
	emit_signal("data_modified_in_timeline", data_id, active_timeline)
	
	return {
		"success": true,
		"data_id": data_id,
		"timeline": active_timeline,
		"operation": operation_type,
		"new_stability": timeline_stability[active_timeline],
		"new_paradox_potential": paradox_potential[active_timeline]
	}

func merge_timelines(source_timeline, target_timeline, conflict_resolution="latest"):
	# Merge two timelines together
	
	# Check if timelines exist
	if not edit_history.has(source_timeline):
		return {"success": false, "error": "Source timeline not found: " + source_timeline}
	
	if not edit_history.has(target_timeline):
		return {"success": false, "error": "Target timeline not found: " + target_timeline}
	
	# Check for paradox potential
	var combined_paradox = (paradox_potential[source_timeline] + paradox_potential[target_timeline]) / 1.5
	if combined_paradox > MAX_PARADOX_LEVEL:
		return {"success": false, "error": "Merging these timelines would create a paradox (potential: " + str(combined_paradox) + ")"}
	
	# Build list of conflicting data items
	var conflicts = _find_timeline_conflicts(source_timeline, target_timeline)
	
	# Resolve conflicts based on strategy
	var resolved_conflicts = 0
	
	for data_id in conflicts:
		var source_edit = conflicts[data_id]["source"]
		var target_edit = conflicts[data_id]["target"]
		
		# Apply resolution strategy
		match conflict_resolution:
			"latest":
				# Use the most recent edit
				if source_edit.real_time > target_edit.real_time:
					_apply_edit_to_timeline(source_edit, target_timeline)
				resolved_conflicts += 1
			"source":
				# Always use source timeline's data
				_apply_edit_to_timeline(source_edit, target_timeline)
				resolved_conflicts += 1
			"target":
				# Keep target timeline's data (do nothing)
				resolved_conflicts += 1
			"manual":
				# Manual resolution requires user input
				# For now, we'll use source as default
				_apply_edit_to_timeline(source_edit, target_timeline)
				resolved_conflicts += 1
	
	# Update causal chains
	_merge_causal_chains(source_timeline, target_timeline)
	
	# Update stability metrics
	var new_stability = (timeline_stability[source_timeline] + timeline_stability[target_timeline]) / 2.0
	timeline_stability[target_timeline] = new_stability
	
	# Recalculate paradox potential
	paradox_potential[target_timeline] = combined_paradox
	
	# Mark source timeline as merged
	if edit_history.has(source_timeline):
		var merge_marker = {
			"data_id": "system.merge_marker",
			"operation": "merge",
			"timestamp": time_pointer,
			"real_time": Time.get_unix_time_from_system(),
			"metadata": {"merged_into": target_timeline}
		}
		edit_history[source_timeline].append(merge_marker)
	
	# Emit signal
	emit_signal("timeline_merged", source_timeline, target_timeline)
	
	return {
		"success": true,
		"source": source_timeline,
		"target": target_timeline,
		"conflicts_resolved": resolved_conflicts,
		"new_stability": new_stability
	}

func create_temporal_lock(data_id, lock_duration=3600, lock_type="read_only"):
	# Create a temporal lock on data to prevent paradoxes
	
	# Check if data exists
	var data = _get_data_in_timeline(data_id, active_timeline)
	if not data.get("success", false):
		return {"success": false, "error": "Data not found: " + data_id}
	
	# Create lock
	var lock = {
		"data_id": data_id,
		"created": Time.get_unix_time_from_system(),
		"expires": Time.get_unix_time_from_system() + lock_duration,
		"type": lock_type,
		"creator": "system"
	}
	
	temporal_locks[active_timeline].append(lock)
	
	# Make sure the data is also locked in Akashic Records if available
	if akashic_records != null:
		var metadata = {"temporal_lock": true, "expires": lock["expires"]}
		akashic_records.update_record(data_id, data.get("data"), "system", true)
	
	return {
		"success": true,
		"data_id": data_id,
		"timeline": active_timeline,
		"expires_in": lock_duration
	}

func remove_temporal_lock(data_id):
	# Remove a temporal lock
	
	# Check if timeline exists
	if not temporal_locks.has(active_timeline):
		return {"success": false, "error": "Timeline not found: " + active_timeline}
	
	# Find the lock
	var found = false
	var lock_index = -1
	
	for i in range(temporal_locks[active_timeline].size()):
		if temporal_locks[active_timeline][i].data_id == data_id:
			lock_index = i
			found = true
			break
	
	if not found:
		return {"success": false, "error": "No temporal lock found for data: " + data_id}
	
	# Remove the lock
	temporal_locks[active_timeline].remove_at(lock_index)
	
	# Remove lock in Akashic Records if available
	if akashic_records != null:
		var data = _get_data_in_timeline(data_id, active_timeline)
		if data.get("success", false):
			var metadata = {"temporal_lock": false}
			akashic_records.update_record(data_id, data.get("data"), "system", true)
	
	return {
		"success": true,
		"data_id": data_id,
		"timeline": active_timeline
	}

func revert_timeline_to_point(timestamp=null):
	# Revert current timeline to a specific point
	
	# If no timestamp provided, revert to the last safe point
	if timestamp == null:
		# Find the last point where stability was above 0.8
		for i in range(edit_history[active_timeline].size() - 1, -1, -1):
			var edit = edit_history[active_timeline][i]
			if edit.has("timeline_stability") and edit.timeline_stability > 0.8:
				timestamp = edit.timestamp
				break
		
		# If no safe point found, use creation time
		if timestamp == null:
			return {"success": false, "error": "No safe point found in timeline"}
	
	# Validate timestamp
	if typeof(timestamp) != TYPE_INT and typeof(timestamp) != TYPE_FLOAT:
		return {"success": false, "error": "Invalid timestamp format"}
	
	# Count edits to remove
	var edits_to_remove = []
	var stability_at_point = 1.0
	
	for i in range(edit_history[active_timeline].size() - 1, -1, -1):
		var edit = edit_history[active_timeline][i]
		if edit.timestamp > timestamp:
			edits_to_remove.append(i)
		else:
			if edit.has("timeline_stability"):
				stability_at_point = edit.timeline_stability
			break
	
	# Create reversion record
	var reversion = {
		"data_id": "system.reversion",
		"operation": "revert",
		"timestamp": time_pointer,
		"real_time": Time.get_unix_time_from_system(),
		"previous_timestamp": timestamp,
		"edits_reverted": edits_to_remove.size(),
		"metadata": {"reason": "Timeline instability correction"}
	}
	
	# Update storage for each removed edit
	for index in edits_to_remove:
		var edit = edit_history[active_timeline][index]
		if edit.has("previous_data") and edit.previous_data != null:
			_update_data_in_storage(edit.data_id, edit.previous_data, "revert", {"source": "timeline_reversion"})
	
	# Remove edits after the timestamp
	for index in edits_to_remove:
		edit_history[active_timeline].remove_at(index)
	
	# Add reversion record
	edit_history[active_timeline].append(reversion)
	
	# Update timeline stability
	timeline_stability[active_timeline] = stability_at_point
	causal_integrity[active_timeline] = stability_at_point * 0.9  # Slight penalty for reverting
	paradox_potential[active_timeline] = 0.1  # Reset paradox potential with small baseline
	
	# Update causal chains
	_recompute_causal_chain(active_timeline)
	
	# Emit signal for temporal consistency
	emit_signal("temporal_consistency_enforced", [active_timeline])
	
	return {
		"success": true,
		"timeline": active_timeline,
		"reverted_to": timestamp,
		"edits_reverted": edits_to_remove.size(),
		"new_stability": stability_at_point
	}

func set_time_pointer(timestamp=null):
	# Set the current time pointer (for time travel)
	if timestamp == null:
		# Reset to current time
		time_pointer = Time.get_unix_time_from_system()
	else:
		time_pointer = timestamp
	
	return {
		"success": true,
		"time_pointer": time_pointer,
		"formatted_time": Time.get_datetime_string_from_unix_time(time_pointer)
	}

func enforce_causal_consistency(data_ids=null):
	# Enforce causal consistency across timelines
	var affected_timelines = []
	
	# If no specific data_ids provided, check all causal chains
	if data_ids == null:
		for timeline in causal_chains:
			var updated = _enforce_consistency_in_timeline(timeline)
			if updated:
				affected_timelines.append(timeline)
	else:
		# Check specific data items
		for data_id in data_ids:
			for timeline in causal_chains:
				var updated = _enforce_consistency_for_data(data_id, timeline)
				if updated and not timeline in affected_timelines:
					affected_timelines.append(timeline)
	
	if affected_timelines.size() > 0:
		emit_signal("temporal_consistency_enforced", affected_timelines)
	
	return {
		"success": true,
		"affected_timelines": affected_timelines
	}

# Helper methods

func _process_temporal_operations(delta):
	# Process ongoing temporal operations
	
	# Clean up expired temporal locks
	_cleanup_expired_locks()
	
	# Process timeline stability evolution
	for timeline in timeline_stability:
		# Stability gradually returns toward equilibrium
		var current_stability = timeline_stability[timeline]
		var target_stability = 0.8  # Equilibrium point
		
		# Adjust stability toward equilibrium very slowly
		timeline_stability[timeline] += (target_stability - current_stability) * 0.001 * delta
		
		# Cap stability
		timeline_stability[timeline] = clamp(timeline_stability[timeline], 0.0, 1.0)

func _cleanup_expired_locks():
	# Remove expired temporal locks
	var current_time = Time.get_unix_time_from_system()
	
	for timeline in temporal_locks:
		var locks_to_remove = []
		
		for i in range(temporal_locks[timeline].size() - 1, -1, -1):
			var lock = temporal_locks[timeline][i]
			if lock.expires <= current_time:
				locks_to_remove.append(i)
		
		# Remove expired locks
		for index in locks_to_remove:
			temporal_locks[timeline].remove_at(index)

func _is_data_locked(data_id, timeline):
	# Check if data has a temporal lock
	if not temporal_locks.has(timeline):
		return false
	
	var current_time = Time.get_unix_time_from_system()
	
	for lock in temporal_locks[timeline]:
		if lock.data_id == data_id and lock.expires > current_time:
			return true
	
	return false

func _update_data_in_storage(data_id, data, operation_type, metadata={}):
	# Update data in appropriate storage system
	
	# First, try Data Zone Manager
	if data_zone_manager != null:
		var zone_name = "akashic_zone"
		
		match operation_type:
			"insert", "modify":
				metadata["timeline"] = active_timeline
				metadata["dimension"] = active_dimension
				metadata["timestamp"] = time_pointer
				return data_zone_manager.store_data(zone_name, data_id, data, metadata)
			"delete":
				return data_zone_manager.delete_data(zone_name, data_id)
			"revert":
				metadata["timeline"] = active_timeline
				metadata["dimension"] = active_dimension
				metadata["timestamp"] = time_pointer
				metadata["reverted"] = true
				return data_zone_manager.store_data(zone_name, data_id, data, metadata)
	
	# Next, try Akashic Records
	if akashic_records != null:
		match operation_type:
			"insert":
				metadata["timeline"] = active_timeline
				metadata["dimension"] = active_dimension
				return akashic_records.create_record(data, "data", metadata)
			"modify":
				return akashic_records.update_record(data_id, data, "system", true)
			"delete":
				return akashic_records.delete_record(data_id)
			"revert":
				return akashic_records.update_record(data_id, data, "system", true)
	
	# If neither system is available, store locally
	var local_storage = {}
	local_storage[data_id] = {
		"data": data,
		"metadata": metadata,
		"timeline": active_timeline,
		"dimension": active_dimension,
		"timestamp": time_pointer
	}
	
	return {
		"success": true,
		"warning": "Data stored locally only - no permanent storage system available"
	}

func _get_data_in_timeline(data_id, timeline):
	# Retrieve data from the appropriate storage system
	
	# First, try Data Zone Manager
	if data_zone_manager != null:
		var zone_name = "akashic_zone"
		var result = data_zone_manager.retrieve_data(zone_name, data_id)
		
		if result.get("success", false):
			return {
				"success": true,
				"data": result.get("data"),
				"metadata": result.get("metadata", {})
			}
	
	# Next, try Akashic Records
	if akashic_records != null:
		var result = akashic_records.read_record(data_id)
		
		if result.get("success", false):
			return {
				"success": true,
				"data": result.get("record", {}).get("data"),
				"metadata": result.get("record", {}).get("metadata", {})
			}
	
	# If data not found in any storage
	return {
		"success": false,
		"error": "Data not found: " + data_id
	}

func _update_causal_chain(data_id, operation_type):
	# Update causal chain for the current timeline
	
	# Create causal entry
	var causal_entry = {
		"data_id": data_id,
		"operation": operation_type,
		"timestamp": time_pointer,
		"dependent_data": []
	}
	
	# Find dependencies based on previous operations
	for i in range(causal_chains[active_timeline].size() - 1, -1, -1):
		var existing_entry = causal_chains[active_timeline][i]
		
		# Check if this data might be dependent on previous operations
		if existing_entry.timestamp < time_pointer:
			if existing_entry.data_id == data_id:
				# This is directly modifying the same data
				causal_entry["depends_on"] = [existing_entry.data_id]
				break
			
			# For now, just a simple dependency model
			# In a full implementation, this would use more sophisticated dependency tracking
			# based on the actual data relationships
		
		# Inform existing entries they have a dependent
		if existing_entry.timestamp < time_pointer - 3600:  # Ignore dependencies older than 1 hour
			break
		
		existing_entry.dependent_data.append(data_id)
	
	# Add to causal chain
	causal_chains[active_timeline].append(causal_entry)
	
	# Emit signal
	emit_signal("causal_chain_updated", {"timeline": active_timeline, "data_id": data_id})

func _recompute_causal_chain(timeline):
	# Recompute entire causal chain for a timeline
	
	# Clear existing chain
	causal_chains[timeline] = []
	
	# Rebuild from edit history
	for edit in edit_history[timeline]:
		if edit.has("data_id") and edit.has("operation"):
			var causal_entry = {
				"data_id": edit.data_id,
				"operation": edit.operation,
				"timestamp": edit.timestamp,
				"dependent_data": []
			}
			
			# Find potential dependencies
			for existing_entry in causal_chains[timeline]:
				if existing_entry.timestamp < edit.timestamp:
					if existing_entry.data_id == edit.data_id:
						causal_entry["depends_on"] = [existing_entry.data_id]
						break
					
					# Add this as a dependent to previous entries
					existing_entry.dependent_data.append(edit.data_id)
			
			causal_chains[timeline].append(causal_entry)

func _merge_causal_chains(source_timeline, target_timeline):
	# Merge causal chains from two timelines
	
	# Get all entries from source that aren't in target
	var entries_to_add = []
	
	for source_entry in causal_chains[source_timeline]:
		var found = false
		
		for target_entry in causal_chains[target_timeline]:
			if target_entry.data_id == source_entry.data_id and target_entry.timestamp == source_entry.timestamp:
				found = true
				break
		
		if not found:
			entries_to_add.append(source_entry.duplicate(true))
	
	# Add unique entries to target
	for entry in entries_to_add:
		causal_chains[target_timeline].append(entry)
	
	# Sort by timestamp
	causal_chains[target_timeline].sort_custom(func(a, b): return a.timestamp < b.timestamp)
	
	# Recompute dependencies
	_recompute_causal_chain(target_timeline)

func _find_timeline_conflicts(source_timeline, target_timeline):
	# Find conflicting data edits between timelines
	var conflicts = {}
	
	# Build map of latest edits for each data item in both timelines
	var source_edits = {}
	var target_edits = {}
	
	for edit in edit_history[source_timeline]:
		if edit.has("data_id") and edit.operation != "system.reversion" and edit.operation != "merge":
			source_edits[edit.data_id] = edit
	
	for edit in edit_history[target_timeline]:
		if edit.has("data_id") and edit.operation != "system.reversion" and edit.operation != "merge":
			target_edits[edit.data_id] = edit
	
	# Find conflicts (data edited in both timelines)
	for data_id in source_edits:
		if target_edits.has(data_id):
			conflicts[data_id] = {
				"source": source_edits[data_id],
				"target": target_edits[data_id]
			}
	
	return conflicts

func _apply_edit_to_timeline(edit, timeline):
	# Apply an edit from one timeline to another
	
	# Add to edit history
	edit_history[timeline].append(edit.duplicate(true))
	
	# Update actual data in storage
	_update_data_in_storage(edit.data_id, edit.new_data, edit.operation, edit.metadata)
	
	# Update causal chain
	var causal_entry = {
		"data_id": edit.data_id,
		"operation": edit.operation,
		"timestamp": edit.timestamp,
		"dependent_data": []
	}
	
	causal_chains[timeline].append(causal_entry)

func _enforce_consistency_in_timeline(timeline):
	# Enforce causal consistency in a timeline
	var changes_made = false
	
	# Check each causal link
	for causal_entry in causal_chains[timeline]:
		if causal_entry.has("depends_on"):
			for dependency in causal_entry.depends_on:
				# Verify dependency still exists and is valid
				var dependency_valid = false
				
				for dep_entry in causal_chains[timeline]:
					if dep_entry.data_id == dependency and dep_entry.timestamp < causal_entry.timestamp:
						dependency_valid = true
						break
				
				if not dependency_valid:
					# Fix inconsistency
					_fix_causal_inconsistency(timeline, causal_entry, dependency)
					changes_made = true
	
	return changes_made

func _enforce_consistency_for_data(data_id, timeline):
	# Enforce causal consistency for specific data in a timeline
	var changes_made = false
	
	for causal_entry in causal_chains[timeline]:
		if causal_entry.data_id == data_id:
			if causal_entry.has("depends_on"):
				for dependency in causal_entry.depends_on:
					# Verify dependency still exists and is valid
					var dependency_valid = false
					
					for dep_entry in causal_chains[timeline]:
						if dep_entry.data_id == dependency and dep_entry.timestamp < causal_entry.timestamp:
							dependency_valid = true
							break
					
					if not dependency_valid:
						# Fix inconsistency
						_fix_causal_inconsistency(timeline, causal_entry, dependency)
						changes_made = true
	
	return changes_made

func _fix_causal_inconsistency(timeline, causal_entry, missing_dependency):
	# Fix a causal inconsistency by either removing the dependent data or restoring the dependency
	
	# For now, we'll use a simple approach: remove the dependent data
	
	# Find the edit
	var edit_to_remove = null
	
	for i in range(edit_history[timeline].size() - 1, -1, -1):
		var edit = edit_history[timeline][i]
		if edit.has("data_id") and edit.data_id == causal_entry.data_id and edit.timestamp == causal_entry.timestamp:
			edit_to_remove = i
			break
	
	if edit_to_remove != null:
		# Create consistency fix record
		var fix_record = {
			"data_id": "system.consistency_fix",
			"operation": "fix",
			"timestamp": time_pointer,
			"real_time": Time.get_unix_time_from_system(),
			"fixed_data_id": causal_entry.data_id,
			"missing_dependency": missing_dependency,
			"metadata": {"reason": "Causal inconsistency"}
		}
		
		# Add to history
		edit_history[timeline].append(fix_record)
		
		# Remove inconsistent edit
		edit_history[timeline].remove_at(edit_to_remove)
		
		# Update causal chain
		_recompute_causal_chain(timeline)
		
		# Update stability metrics
		causal_integrity[timeline] = max(0.1, causal_integrity[timeline] - 0.05)
		paradox_potential[timeline] = min(0.9, paradox_potential[timeline] + 0.05)

func _update_timeline_metrics(timeline, causality_impact, stability_impact):
	# Update timeline stability metrics based on operation
	
	# Update stability
	timeline_stability[timeline] -= stability_impact * 0.1
	timeline_stability[timeline] = max(0.0, timeline_stability[timeline])
	
	# Update causal integrity
	causal_integrity[timeline] -= causality_impact * 0.1
	causal_integrity[timeline] = max(0.0, causal_integrity[timeline])
	
	# Update paradox potential
	paradox_potential[timeline] += causality_impact * 0.05
	paradox_potential[timeline] = min(1.0, paradox_potential[timeline])
	
	# Add stability measurement to edit record
	var last_edit = edit_history[timeline].back()
	if last_edit:
		last_edit["timeline_stability"] = timeline_stability[timeline]
		last_edit["causal_integrity"] = causal_integrity[timeline]
		last_edit["paradox_potential"] = paradox_potential[timeline]

func _check_paradox_potential():
	# Check if any timeline is at risk of paradox
	for timeline in paradox_potential:
		if paradox_potential[timeline] >= MAX_PARADOX_LEVEL:
			_handle_paradox(timeline)

func _handle_paradox(timeline):
	# Handle a paradox in the timeline
	
	# Create paradox record
	var paradox_record = {
		"data_id": "system.paradox",
		"operation": "paradox",
		"timestamp": time_pointer,
		"real_time": Time.get_unix_time_from_system(),
		"timeline": timeline,
		"stability": timeline_stability[timeline],
		"causal_integrity": causal_integrity[timeline],
		"paradox_potential": paradox_potential[timeline],
		"metadata": {"reason": "Timeline stability critical"}
	}
	
	# Emit signal
	emit_signal("paradox_detected", paradox_record)
	
	# Temporary paradox suppression
	paradox_suppression_active = true
	
	# Auto-resolve by reverting to last safe point
	revert_timeline_to_point(null)
	
	# Reset suppression
	paradox_suppression_active = false

func _calculate_time_factor():
	# Calculate impact factor based on current time position relative to 'present'
	var current_time = Time.get_unix_time_from_system()
	var time_difference = abs(current_time - time_pointer)
	
	# The further from the present, the higher the impact
	var time_factor = 1.0 + (time_difference / (3600.0 * 24.0))  # Factor increases by 1.0 per day difference
	
	return min(5.0, time_factor)  # Cap at 5x

# Public command-based interface

func process_command(args):
	if args.size() == 0:
		return get_time_space_status()
	
	match args[0]:
		"status":
			return get_time_space_status()
		"timeline":
			return process_timeline_command(args.slice(1))
		"edit":
			return process_edit_command(args.slice(1))
		"lock":
			return process_lock_command(args.slice(1))
		"revert":
			return process_revert_command(args.slice(1))
		"goto":
			return process_goto_command(args.slice(1))
		"consistency":
			return process_consistency_command(args.slice(1))
		_:
			return "Unknown time_space command: " + args[0]

func get_time_space_status():
	var status = "TimeSpace Status:\n"
	status += "Current Timeline: " + active_timeline + "\n"
	status += "Current Dimension: " + active_dimension + "\n"
	status += "Time Position: " + Time.get_datetime_string_from_unix_time(time_pointer) + "\n"
	
	if timeline_stability.has(active_timeline):
		status += "Timeline Stability: " + str(int(timeline_stability[active_timeline] * 100)) + "%\n"
		status += "Causal Integrity: " + str(int(causal_integrity[active_timeline] * 100)) + "%\n"
		status += "Paradox Potential: " + str(int(paradox_potential[active_timeline] * 100)) + "%\n"
	
	if temporal_locks.has(active_timeline) and temporal_locks[active_timeline].size() > 0:
		status += "\nTemporal Locks: " + str(temporal_locks[active_timeline].size()) + "\n"
	
	if edit_history.has(active_timeline):
		status += "Edits in Timeline: " + str(edit_history[active_timeline].size()) + "\n"
	
	return status

func process_timeline_command(args):
	if args.size() == 0:
		return "Current timeline: " + active_timeline
	
	match args[0]:
		"create":
			if args.size() < 2:
				return "Usage: time_space timeline create <name> [source]"
				
			var source = "main"
			if args.size() >= 3:
				source = args[2]
				
			var result = create_timeline(args[1], source)
			
			if result.get("success", false):
				return "Timeline created: " + args[1] + " (from " + source + ")"
			else:
				return "Failed to create timeline: " + result.get("error", "Unknown error")
				
		"switch":
			if args.size() < 2:
				return "Usage: time_space timeline switch <name>"
				
			var result = switch_timeline(args[1])
			
			if result.get("success", false):
				return "Switched to timeline: " + result.get("current", "")
			else:
				return "Failed to switch timeline: " + result.get("error", "Unknown error")
				
		"merge":
			if args.size() < 3:
				return "Usage: time_space timeline merge <source> <target> [resolution]"
				
			var resolution = "latest"
			if args.size() >= 4:
				resolution = args[3]
				
			var result = merge_timelines(args[1], args[2], resolution)
			
			if result.get("success", false):
				return "Merged timelines: " + result.get("source", "") + " into " + result.get("target", "") + " (" + str(result.get("conflicts_resolved", 0)) + " conflicts resolved)"
			else:
				return "Failed to merge timelines: " + result.get("error", "Unknown error")
				
		"list":
			var result = "Timelines:\n"
			
			for timeline in edit_history:
				var marker = " "
				if timeline == active_timeline:
					marker = "*"
					
				result += marker + " " + timeline
				
				if temporal_branches.has(timeline):
					result += " (branch from " + temporal_branches[timeline].source + ")"
					
				if timeline_stability.has(timeline):
					result += " - Stability: " + str(int(timeline_stability[timeline] * 100)) + "%"
					
				result += "\n"
				
			return result
			
		_:
			return "Unknown timeline command: " + args[0]

func process_edit_command(args):
	if args.size() < 3:
		return "Usage: time_space edit <data_id> <operation> <data>"
		
	var data_id = args[0]
	var operation = args[1]
	var data = args[2]
	
	var result = edit_timeline_data(data_id, data, operation)
	
	if result.get("success", false):
		return "Data edited: " + data_id + " (" + operation + ") - New stability: " + str(int(result.get("new_stability", 0) * 100)) + "%"
	else:
		return "Failed to edit data: " + result.get("error", "Unknown error")

func process_lock_command(args):
	if args.size() == 0:
		if temporal_locks.has(active_timeline):
			var result = "Temporal Locks in " + active_timeline + ":\n"
			
			for lock in temporal_locks[active_timeline]:
				var time_left = lock.expires - Time.get_unix_time_from_system()
				result += "- " + lock.data_id + " (" + lock.type + ") - Expires in " + str(int(time_left)) + "s\n"
				
			return result
		else:
			return "No temporal locks in current timeline"
	
	match args[0]:
		"create":
			if args.size() < 2:
				return "Usage: time_space lock create <data_id> [duration]"
				
			var duration = 3600
			if args.size() >= 3 and args[2].is_valid_integer():
				duration = int(args[2])
				
			var result = create_temporal_lock(args[1], duration)
			
			if result.get("success", false):
				return "Temporal lock created on " + args[1] + " (expires in " + str(duration) + "s)"
			else:
				return "Failed to create lock: " + result.get("error", "Unknown error")
				
		"remove":
			if args.size() < 2:
				return "Usage: time_space lock remove <data_id>"
				
			var result = remove_temporal_lock(args[1])
			
			if result.get("success", false):
				return "Temporal lock removed from " + args[1]
			else:
				return "Failed to remove lock: " + result.get("error", "Unknown error")
				
		_:
			return "Unknown lock command: " + args[0]

func process_revert_command(args):
	if args.size() == 0:
		return "Usage: time_space revert [timestamp]"
		
	var timestamp = null
	if args.size() >= 1:
		if args[0].is_valid_integer():
			timestamp = int(args[0])
		elif args[0] == "safe":
			# Use null to revert to last safe point
			timestamp = null
		else:
			return "Invalid timestamp format. Use Unix timestamp or 'safe'"
			
	var result = revert_timeline_to_point(timestamp)
	
	if result.get("success", false):
		return "Timeline reverted to " + Time.get_datetime_string_from_unix_time(result.get("reverted_to", 0)) + " (" + str(result.get("edits_reverted", 0)) + " edits reverted)"
	else:
		return "Failed to revert timeline: " + result.get("error", "Unknown error")

func process_goto_command(args):
	if args.size() == 0:
		return "Current time pointer: " + Time.get_datetime_string_from_unix_time(time_pointer)
		
	var timestamp = null
	
	if args[0] == "now":
		# Reset to current time
		timestamp = null
	elif args[0].is_valid_integer():
		timestamp = int(args[0])
	else:
		return "Invalid timestamp format. Use Unix timestamp or 'now'"
		
	var result = set_time_pointer(timestamp)
	
	if result.get("success", false):
		return "Time pointer set to " + result.get("formatted_time", "")
	else:
		return "Failed to set time pointer: " + result.get("error", "Unknown error")

func process_consistency_command(args):
	var result = enforce_causal_consistency()
	
	if result.get("success", false):
		return "Causal consistency enforced on " + str(result.get("affected_timelines", []).size()) + " timelines"
	else:
		return "Failed to enforce consistency: " + result.get("error", "Unknown error")