extends Node
class_name MemoryUpdater

# Memory Updater System
# -------------------
# Handles updating, upgrading, restarting and modifying memory systems
# Automates debug, testing and repetition cycles

# Constants
const UPDATE_CYCLES = {
    "QUICK": 30,       # 30 second update cycle
    "STANDARD": 60,    # 1 minute update cycle
    "EXTENDED": 120,   # 2 minute update cycle
    "DEEP": 300,       # 5 minute update cycle
    "FULL": 600        # 10 minute update cycle
}

const UPDATE_TYPES = {
    "SNAPSHOT": "#S",  # Take memory snapshot
    "MERGE": "#M",     # Merge memory fragments
    "SPLIT": "#Y",     # Split memory into fragments
    "EVOLVE": "#E",    # Evolve memory to next state
    "DEBUG": "#D",     # Debug memory system
    "TEST": "#T",      # Test memory functionality
    "CLEAN": "#C",     # Clean memory fragments
    "ARCHIVE": "#A",   # Archive old memories
    "COMPACT": "#Cp",  # Compact memory storage
    "REPAIR": "#R"     # Repair corrupted memories
}

# Data Structures
class UpdateTask:
    var id: String
    var type: String  # One of UPDATE_TYPES
    var target_memory_ids = []
    var parameters = {}
    var scheduled_time: int
    var completed_time: int = -1
    var status: String = "pending"  # pending, in_progress, completed, failed
    var result = null
    var created_at: int
    
    func _init(p_id: String, p_type: String):
        id = p_id
        type = p_type
        created_at = OS.get_unix_time()
        scheduled_time = created_at
    
    func add_target_memory(memory_id: String):
        if not target_memory_ids.has(memory_id):
            target_memory_ids.append(memory_id)
    
    func set_parameter(key: String, value):
        parameters[key] = value
    
    func is_due() -> bool:
        return OS.get_unix_time() >= scheduled_time
    
    func complete(p_result = null):
        status = "completed"
        completed_time = OS.get_unix_time()
        result = p_result
    
    func fail(error_message: String):
        status = "failed"
        completed_time = OS.get_unix_time()
        result = {"error": error_message}
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "type": type,
            "target_memory_ids": target_memory_ids,
            "parameters": parameters,
            "scheduled_time": scheduled_time,
            "completed_time": completed_time,
            "status": status,
            "result": result,
            "created_at": created_at
        }
    
    static func from_dict(data: Dictionary) -> UpdateTask:
        var task = UpdateTask.new(data.id, data.type)
        task.target_memory_ids = data.target_memory_ids.duplicate()
        task.parameters = data.parameters.duplicate()
        task.scheduled_time = data.scheduled_time
        task.completed_time = data.completed_time
        task.status = data.status
        task.result = data.result
        task.created_at = data.created_at
        return task

class UpdateCycle:
    var id: String
    var name: String
    var cycle_time: int  # In seconds
    var tasks = []  # Array of task IDs
    var is_active: bool = false
    var last_run: int = -1
    var next_run: int = -1
    var iterations_completed: int = 0
    var max_iterations: int = -1  # -1 means infinite
    var created_at: int
    
    func _init(p_id: String, p_name: String, p_cycle_time: int):
        id = p_id
        name = p_name
        cycle_time = p_cycle_time
        created_at = OS.get_unix_time()
    
    func add_task(task_id: String):
        if not tasks.has(task_id):
            tasks.append(task_id)
    
    func activate():
        is_active = true
        if last_run < 0:
            last_run = OS.get_unix_time()
        next_run = last_run + cycle_time
    
    func deactivate():
        is_active = false
        next_run = -1
    
    func is_due() -> bool:
        return is_active and next_run > 0 and OS.get_unix_time() >= next_run
    
    func mark_completed():
        last_run = OS.get_unix_time()
        next_run = last_run + cycle_time
        iterations_completed += 1
        
        # Check if we've reached max iterations
        if max_iterations > 0 and iterations_completed >= max_iterations:
            deactivate()
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "name": name,
            "cycle_time": cycle_time,
            "tasks": tasks,
            "is_active": is_active,
            "last_run": last_run,
            "next_run": next_run,
            "iterations_completed": iterations_completed,
            "max_iterations": max_iterations,
            "created_at": created_at
        }
    
    static func from_dict(data: Dictionary) -> UpdateCycle:
        var cycle = UpdateCycle.new(data.id, data.name, data.cycle_time)
        cycle.tasks = data.tasks.duplicate()
        cycle.is_active = data.is_active
        cycle.last_run = data.last_run
        cycle.next_run = data.next_run
        cycle.iterations_completed = data.iterations_completed
        cycle.max_iterations = data.max_iterations
        cycle.created_at = data.created_at
        return cycle

# System Variables
var _tasks = {}  # id -> UpdateTask
var _cycles = {}  # id -> UpdateCycle
var _pending_tasks = []  # Array of task IDs
var _memory_system = null
var _connection_system = null
var _is_processing = false
var _auto_update_timer = null

# Signals
signal task_created(task_id, type)
signal task_completed(task_id, result)
signal task_failed(task_id, error)
signal cycle_created(cycle_id, name)
signal cycle_activated(cycle_id)
signal cycle_deactivated(cycle_id)
signal cycle_iteration_completed(cycle_id, iteration)
signal system_updated()

# System Initialization
func _ready():
    _auto_update_timer = Timer.new()
    _auto_update_timer.autostart = false
    _auto_update_timer.one_shot = false
    _auto_update_timer.wait_time = 1.0  # Check every second
    _auto_update_timer.connect("timeout", self, "_process_updates")
    add_child(_auto_update_timer)
    
    load_data()
    start_auto_update()

func initialize(memory_system = null, connection_system = null):
    _memory_system = memory_system
    _connection_system = connection_system
    return true

# Task Management
func create_task(type: String, scheduled_time: int = -1) -> String:
    if not UPDATE_TYPES.values().has(type):
        push_error("Invalid update type: " + type)
        return ""
    
    var task_id = "task_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000).pad_zeros(3)
    var task = UpdateTask.new(task_id, type)
    
    if scheduled_time > 0:
        task.scheduled_time = scheduled_time
    
    _tasks[task_id] = task
    _pending_tasks.append(task_id)
    
    save_task(task)
    
    emit_signal("task_created", task_id, type)
    
    return task_id

func add_target_to_task(task_id: String, memory_id: String) -> bool:
    if not _tasks.has(task_id):
        return false
    
    _tasks[task_id].add_target_memory(memory_id)
    save_task(_tasks[task_id])
    
    return true

func set_task_parameter(task_id: String, key: String, value) -> bool:
    if not _tasks.has(task_id):
        return false
    
    _tasks[task_id].set_parameter(key, value)
    save_task(_tasks[task_id])
    
    return true

func get_task(task_id: String) -> UpdateTask:
    if _tasks.has(task_id):
        return _tasks[task_id]
    return null

# Cycle Management
func create_cycle(name: String, cycle_time: int = UPDATE_CYCLES.STANDARD) -> String:
    var cycle_id = "cycle_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000).pad_zeros(3)
    var cycle = UpdateCycle.new(cycle_id, name, cycle_time)
    
    _cycles[cycle_id] = cycle
    
    save_cycle(cycle)
    
    emit_signal("cycle_created", cycle_id, name)
    
    return cycle_id

func add_task_to_cycle(cycle_id: String, task_id: String) -> bool:
    if not _cycles.has(cycle_id) or not _tasks.has(task_id):
        return false
    
    _cycles[cycle_id].add_task(task_id)
    save_cycle(_cycles[cycle_id])
    
    return true

func activate_cycle(cycle_id: String) -> bool:
    if not _cycles.has(cycle_id):
        return false
    
    _cycles[cycle_id].activate()
    save_cycle(_cycles[cycle_id])
    
    emit_signal("cycle_activated", cycle_id)
    
    return true

func deactivate_cycle(cycle_id: String) -> bool:
    if not _cycles.has(cycle_id):
        return false
    
    _cycles[cycle_id].deactivate()
    save_cycle(_cycles[cycle_id])
    
    emit_signal("cycle_deactivated", cycle_id)
    
    return true

func set_cycle_max_iterations(cycle_id: String, max_iterations: int) -> bool:
    if not _cycles.has(cycle_id):
        return false
    
    _cycles[cycle_id].max_iterations = max_iterations
    save_cycle(_cycles[cycle_id])
    
    return true

func get_cycle(cycle_id: String) -> UpdateCycle:
    if _cycles.has(cycle_id):
        return _cycles[cycle_id]
    return null

# Update Processing
func start_auto_update():
    _auto_update_timer.start()

func stop_auto_update():
    _auto_update_timer.stop()

func process_updates():
    if _is_processing:
        return
    
    _is_processing = true
    
    # Process due cycles
    for cycle_id in _cycles:
        var cycle = _cycles[cycle_id]
        
        if cycle.is_due():
            _process_cycle(cycle)
    
    # Process individual due tasks
    var due_tasks = []
    for task_id in _pending_tasks:
        if _tasks.has(task_id) and _tasks[task_id].is_due():
            due_tasks.append(_tasks[task_id])
    
    for task in due_tasks:
        _process_task(task)
    
    _is_processing = false
    emit_signal("system_updated")

func _process_updates():
    process_updates()

func _process_cycle(cycle: UpdateCycle):
    # Create temporary clones of all tasks in the cycle
    var cycle_task_instances = []
    
    for task_id in cycle.tasks:
        if _tasks.has(task_id):
            var original_task = _tasks[task_id]
            
            # Create a new task based on the template
            var task_instance_id = create_task(original_task.type)
            var task_instance = _tasks[task_instance_id]
            
            # Copy properties from the template
            task_instance.target_memory_ids = original_task.target_memory_ids.duplicate()
            task_instance.parameters = original_task.parameters.duplicate()
            
            cycle_task_instances.append(task_instance)
        
    # Process all tasks
    for task in cycle_task_instances:
        _process_task(task)
    
    # Mark cycle as completed
    cycle.mark_completed()
    save_cycle(cycle)
    
    emit_signal("cycle_iteration_completed", cycle.id, cycle.iterations_completed)

func _process_task(task: UpdateTask):
    # Remove from pending queue
    if _pending_tasks.has(task.id):
        _pending_tasks.erase(task.id)
    
    # Mark as in progress
    task.status = "in_progress"
    
    # Check if we have the necessary systems
    if not _memory_system:
        task.fail("Memory system not initialized")
        save_task(task)
        emit_signal("task_failed", task.id, "Memory system not initialized")
        return
    
    # Process different task types
    var result = null
    var success = true
    var error_message = ""
    
    match task.type:
        UPDATE_TYPES.SNAPSHOT:
            result = _create_memory_snapshot(task)
            
        UPDATE_TYPES.MERGE:
            result = _merge_memories(task)
            
        UPDATE_TYPES.SPLIT:
            result = _split_memory(task)
            
        UPDATE_TYPES.EVOLVE:
            result = _evolve_memories(task)
            
        UPDATE_TYPES.DEBUG:
            result = _debug_memory_system(task)
            
        UPDATE_TYPES.TEST:
            result = _test_memory_system(task)
            
        UPDATE_TYPES.CLEAN:
            result = _clean_memories(task)
            
        UPDATE_TYPES.ARCHIVE:
            result = _archive_memories(task)
            
        UPDATE_TYPES.COMPACT:
            result = _compact_memory_storage(task)
            
        UPDATE_TYPES.REPAIR:
            result = _repair_memories(task)
            
        _:
            success = false
            error_message = "Unknown task type: " + task.type
    
    # Update task status based on result
    if success:
        task.complete(result)
        save_task(task)
        emit_signal("task_completed", task.id, result)
    else:
        task.fail(error_message)
        save_task(task)
        emit_signal("task_failed", task.id, error_message)

# Task Implementation
func _create_memory_snapshot(task: UpdateTask):
    # Take a snapshot of the current memory state
    # This is a simplified implementation
    var snapshot = {
        "timestamp": OS.get_unix_time(),
        "memory_count": 0,
        "memories": []
    }
    
    # If specific memories are targeted
    if task.target_memory_ids.size() > 0:
        for memory_id in task.target_memory_ids:
            var memory = _memory_system.get_memory(memory_id)
            if memory:
                snapshot.memories.append(memory.to_dict())
                snapshot.memory_count += 1
    else:
        # Otherwise snapshot the whole system
        # This is just a placeholder - real implementation would depend on memory system
        snapshot.memory_count = _memory_system._memories.size()
    
    # Save snapshot to file if parameter specified
    if task.parameters.has("save_to_file") and task.parameters.save_to_file:
        var dir = Directory.new()
        var snapshot_dir = "user://snapshots"
        
        if not dir.dir_exists(snapshot_dir):
            dir.make_dir_recursive(snapshot_dir)
        
        var file = File.new()
        var snapshot_path = snapshot_dir.plus_file("snapshot_" + str(OS.get_unix_time()) + ".json")
        file.open(snapshot_path, File.WRITE)
        file.store_string(JSON.print(snapshot, "  "))
        file.close()
        
        snapshot["file_path"] = snapshot_path
    
    return snapshot

func _merge_memories(task: UpdateTask):
    # Merge multiple memories into a single connected memory
    # This is a simplified implementation
    
    if task.target_memory_ids.size() < 2:
        return {"error": "Need at least 2 memories to merge", "merged": false}
    
    var result = {
        "merged": true,
        "source_memories": task.target_memory_ids,
        "connections_created": []
    }
    
    # If we have a connection system, create connections between memories
    if _connection_system:
        # Create a cycle or sequential chain based on parameters
        if task.parameters.has("create_cycle") and task.parameters.create_cycle:
            var connections = _connection_system.create_cycle(
                task.target_memory_ids,
                task.parameters.has("reason") ? task.parameters.reason : ""
            )
            result.connections_created = connections
        else:
            # Create sequential chain by default
            var connections = _connection_system.create_sequential_chain(
                task.target_memory_ids,
                task.parameters.has("reason") ? task.parameters.reason : ""
            )
            result.connections_created = connections
    
    return result

func _split_memory(task: UpdateTask):
    # Split a memory into multiple fragments
    # This is a simplified implementation
    
    if task.target_memory_ids.size() != 1:
        return {"error": "Can only split one memory at a time", "split": false}
    
    var source_memory_id = task.target_memory_ids[0]
    var split_count = task.parameters.has("split_count") ? task.parameters.split_count : 2
    
    var result = {
        "split": true,
        "source_memory": source_memory_id,
        "fragment_memories": []
    }
    
    # Get the source memory
    var source_memory = _memory_system.get_memory(source_memory_id)
    if not source_memory:
        return {"error": "Source memory not found", "split": false}
    
    # Create the fragmented memories
    # This is just a placeholder - real implementation would depend on memory system
    for i in range(split_count):
        var fragment_content = "Fragment " + str(i+1) + " of memory " + source_memory_id
        
        # Create a new memory in the memory system
        var fragment_id = _memory_system.create_memory(
            fragment_content,
            source_memory.dimension
        )
        
        result.fragment_memories.append(fragment_id)
        
        # Connect fragment to source with split connection type
        if _connection_system:
            var connection_id = _connection_system.connect_memories(
                source_memory_id,
                fragment_id,
                _connection_system.CONNECTION_TYPES.SPLITS,
                "Split fragment " + str(i+1)
            )
            
            if not "connections_created" in result:
                result["connections_created"] = []
            
            result.connections_created.append(connection_id)
    
    return result

func _evolve_memories(task: UpdateTask):
    # Evolve memories to their next state
    # This is a simplified implementation
    
    var result = {
        "evolved": true,
        "evolved_memories": []
    }
    
    var memories_to_evolve = []
    
    if task.target_memory_ids.size() > 0:
        # Evolve specific memories
        for memory_id in task.target_memory_ids:
            var memory = _memory_system.get_memory(memory_id)
            if memory:
                memories_to_evolve.append(memory)
    else:
        # If no targets specified, evolve random memories (up to 5)
        # This is just a placeholder - real implementation would depend on memory system
        var all_memories = _memory_system._memories.values()
        var count = min(5, all_memories.size())
        
        for i in range(count):
            var index = randi() % all_memories.size()
            memories_to_evolve.append(all_memories[index])
    
    # Process each memory for evolution
    for memory in memories_to_evolve:
        # Increase dimension as a simple evolution
        var old_dimension = memory.dimension
        var new_dimension = min(old_dimension + 1, 12)  # Assuming 12 is max dimension
        
        var success = _memory_system.change_memory_dimension(memory.id, new_dimension)
        
        if success:
            result.evolved_memories.append({
                "memory_id": memory.id,
                "old_dimension": old_dimension,
                "new_dimension": new_dimension
            })
            
            # Create evolution connection if connection system available
            if _connection_system:
                _connection_system.connect_memories(
                    memory.id,
                    memory.id,  # Self-connection for evolution
                    _connection_system.CONNECTION_TYPES.EVOLVING,
                    "Evolved from dimension " + str(old_dimension) + " to " + str(new_dimension)
                )
    
    return result

func _debug_memory_system(task: UpdateTask):
    # Debug the memory system
    # This is a simplified implementation
    
    var result = {
        "debug_completed": true,
        "issues_found": [],
        "memory_stats": {}
    }
    
    # Generate basic memory stats
    result.memory_stats = {
        "total_memories": _memory_system._memories.size(),
        "dimensions": {}
    }
    
    # Count memories by dimension
    for dimension in _memory_system._dimension_indices:
        result.memory_stats.dimensions[dimension] = _memory_system._dimension_indices[dimension].size()
    
    # Simulated debugging checks
    # Check for orphaned memories (no connections)
    if _connection_system:
        var orphaned_memories = []
        
        for memory_id in _memory_system._memories:
            var connections = _connection_system.get_connections_for_memory(memory_id)
            if connections.size() == 0:
                orphaned_memories.append(memory_id)
        
        if orphaned_memories.size() > 0:
            result.issues_found.append({
                "type": "orphaned_memories",
                "count": orphaned_memories.size(),
                "affected_memories": orphaned_memories
            })
    
    # Generate a debug report if requested
    if task.parameters.has("generate_report") and task.parameters.generate_report:
        var debug_report = _memory_system.generate_memory_report()
        
        if _connection_system:
            debug_report += "\n\n" + _connection_system.generate_connection_visualization()
        
        result["debug_report"] = debug_report
        
        # Save report to file if requested
        if task.parameters.has("save_to_file") and task.parameters.save_to_file:
            var dir = Directory.new()
            var report_dir = "user://debug_reports"
            
            if not dir.dir_exists(report_dir):
                dir.make_dir_recursive(report_dir)
            
            var file = File.new()
            var report_path = report_dir.plus_file("debug_report_" + str(OS.get_unix_time()) + ".txt")
            file.open(report_path, File.WRITE)
            file.store_string(debug_report)
            file.close()
            
            result["report_file_path"] = report_path
    
    return result

func _test_memory_system(task: UpdateTask):
    # Test memory system functionality
    # This is a simplified implementation
    
    var result = {
        "tests_completed": true,
        "tests_passed": 0,
        "tests_failed": 0,
        "test_results": []
    }
    
    # Run some basic tests
    
    # Test 1: Memory creation and retrieval
    var test1 = {
        "name": "Memory creation and retrieval",
        "passed": false
    }
    
    var memory_id = _memory_system.create_memory("Test memory created at " + str(OS.get_unix_time()))
    var memory = _memory_system.get_memory(memory_id)
    
    if memory and memory.id == memory_id:
        test1.passed = true
        result.tests_passed += 1
    else:
        result.tests_failed += 1
        test1["error"] = "Failed to create or retrieve memory"
    
    result.test_results.append(test1)
    
    # Test 2: Memory update
    var test2 = {
        "name": "Memory update",
        "passed": false
    }
    
    if memory:
        var update_success = _memory_system.update_memory(memory_id, "Updated test memory at " + str(OS.get_unix_time()))
        if update_success:
            test2.passed = true
            result.tests_passed += 1
        else:
            result.tests_failed += 1
            test2["error"] = "Failed to update memory"
    else:
        result.tests_failed += 1
        test2["error"] = "Memory not available for update test"
    
    result.test_results.append(test2)
    
    # Test 3: Memory connection (if available)
    if _connection_system:
        var test3 = {
            "name": "Memory connection",
            "passed": false
        }
        
        // Create a second memory for connection testing
        var second_memory_id = _memory_system.create_memory("Second test memory for connection")
        
        // Try to connect the memories
        var connection_id = _connection_system.connect_memories(
            memory_id,
            second_memory_id,
            _connection_system.CONNECTION_TYPES.RELATED,
            "Test connection"
        )
        
        if connection_id:
            var connected_memories = _connection_system.get_connected_memories(memory_id)
            if connected_memories.size() > 0 and connected_memories.has(second_memory_id):
                test3.passed = true
                result.tests_passed += 1
            else:
                result.tests_failed += 1
                test3["error"] = "Connection created but retrieval failed"
        else:
            result.tests_failed += 1
            test3["error"] = "Failed to create connection"
        
        result.test_results.append(test3)
    
    return result

func _clean_memories(task: UpdateTask):
    # Clean memory fragments
    # This is a simplified implementation
    
    var result = {
        "cleaning_completed": true,
        "cleaned_memories": 0,
        "errors": []
    }
    
    var memories_to_clean = []
    
    if task.target_memory_ids.size() > 0:
        // Clean specific memories
        for memory_id in task.target_memory_ids:
            var memory = _memory_system.get_memory(memory_id)
            if memory:
                memories_to_clean.append(memory)
            else:
                result.errors.append("Memory not found: " + memory_id)
    else:
        // If no targets specified, clean all memories
        memories_to_clean = _memory_system._memories.values()
    
    // Simulated cleaning process - just updating memory contents
    for memory in memories_to_clean:
        // Remove duplicate whitespace, trim, etc.
        var cleaned_content = memory.content.strip_edges()
        
        // If content changed, update the memory
        if cleaned_content != memory.content:
            var success = _memory_system.update_memory(memory.id, cleaned_content)
            if success:
                result.cleaned_memories += 1
    
    return result

func _archive_memories(task: UpdateTask):
    # Archive old memories
    # This is a simplified implementation
    
    var result = {
        "archiving_completed": true,
        "archived_memories": []
    }
    
    var memories_to_archive = []
    
    if task.target_memory_ids.size() > 0:
        // Archive specific memories
        for memory_id in task.target_memory_ids:
            var memory = _memory_system.get_memory(memory_id)
            if memory:
                memories_to_archive.append(memory)
    else:
        // If no targets specified, archive based on criteria (e.g., age)
        var current_time = OS.get_unix_time()
        var age_threshold = task.parameters.has("age_threshold") ? task.parameters.age_threshold : 30 * 24 * 60 * 60  // Default 30 days
        
        for memory in _memory_system._memories.values():
            if current_time - memory.timestamp > age_threshold:
                memories_to_archive.append(memory)
    
    // Process each memory for archiving
    for memory in memories_to_archive:
        // Save memory to archive file
        var dir = Directory.new()
        var archive_dir = "user://memory_archive"
        
        if not dir.dir_exists(archive_dir):
            dir.make_dir_recursive(archive_dir)
        
        var file = File.new()
        var archive_path = archive_dir.plus_file("memory_" + memory.id + ".json")
        file.open(archive_path, File.WRITE)
        file.store_string(JSON.print(memory.to_dict(), "  "))
        file.close()
        
        result.archived_memories.append({
            "memory_id": memory.id,
            "archive_path": archive_path
        })
    
    return result

func _compact_memory_storage(task: UpdateTask):
    # Compact memory storage
    # This is a simplified implementation
    
    var result = {
        "compaction_completed": true,
        "before_size": 0,
        "after_size": 0,
        "reduction_percentage": 0
    }
    
    // Simulate storage size before compaction
    result.before_size = _memory_system._memories.size() * 1024  // Just a dummy calculation
    
    // Perform compaction operations
    // This is just a placeholder - real implementation would depend on memory system
    
    // Simulate storage size after compaction
    result.after_size = result.before_size * 0.8  // Assume 20% reduction
    result.reduction_percentage = 20
    
    return result

func _repair_memories(task: UpdateTask):
    # Repair corrupted memories
    # This is a simplified implementation
    
    var result = {
        "repair_completed": true,
        "repaired_memories": []
    }
    
    var memories_to_repair = []
    
    if task.target_memory_ids.size() > 0:
        // Repair specific memories
        for memory_id in task.target_memory_ids:
            var memory = _memory_system.get_memory(memory_id)
            if memory:
                memories_to_repair.append(memory)
    else:
        // If no targets specified, check for potentially corrupted memories
        // This is just a placeholder - real implementation would have actual corruption detection
        for memory in _memory_system._memories.values():
            // Simple check for empty content or missing tags
            if memory.content.empty() or memory.tags.empty():
                memories_to_repair.append(memory)
    
    // Process each memory for repair
    for memory in memories_to_repair:
        var was_repaired = false
        
        // Check for empty content
        if memory.content.empty():
            memory.content = "Repaired content at " + str(OS.get_unix_time())
            was_repaired = true
        
        // Check for missing tags
        if memory.tags.empty():
            _memory_system.add_tag_to_memory(memory.id, _memory_system.MEMORY_TAGS.CORE)
            was_repaired = true
        
        if was_repaired:
            result.repaired_memories.append(memory.id)
    
    return result

# File Operations
func save_task(task: UpdateTask) -> bool:
    var dir = Directory.new()
    var task_dir = "user://memory_tasks"
    
    # Create directory if it doesn't exist
    if not dir.dir_exists(task_dir):
        dir.make_dir_recursive(task_dir)
    
    # Save as JSON
    var file = File.new()
    var file_path = task_dir.plus_file(task.id + ".json")
    var err = file.open(file_path, File.WRITE)
    
    if err != OK:
        push_error("Failed to open task file for writing: " + str(err))
        return false
    
    file.store_string(JSON.print(task.to_dict(), "  "))
    file.close()
    
    return true

func save_cycle(cycle: UpdateCycle) -> bool:
    var dir = Directory.new()
    var cycle_dir = "user://memory_cycles"
    
    # Create directory if it doesn't exist
    if not dir.dir_exists(cycle_dir):
        dir.make_dir_recursive(cycle_dir)
    
    # Save as JSON
    var file = File.new()
    var file_path = cycle_dir.plus_file(cycle.id + ".json")
    var err = file.open(file_path, File.WRITE)
    
    if err != OK:
        push_error("Failed to open cycle file for writing: " + str(err))
        return false
    
    file.store_string(JSON.print(cycle.to_dict(), "  "))
    file.close()
    
    return true

func load_data() -> bool:
    var dir = Directory.new()
    var task_dir = "user://memory_tasks"
    var cycle_dir = "user://memory_cycles"
    
    # Load tasks
    if dir.dir_exists(task_dir):
        dir.open(task_dir)
        dir.list_dir_begin(true, true)
        var file_name = dir.get_next()
        
        while file_name != "":
            if file_name.ends_with(".json"):
                var file_path = task_dir.plus_file(file_name)
                load_task_from_file(file_path)
            file_name = dir.get_next()
        
        dir.list_dir_end()
    
    # Load cycles
    if dir.dir_exists(cycle_dir):
        dir.open(cycle_dir)
        dir.list_dir_begin(true, true)
        var file_name = dir.get_next()
        
        while file_name != "":
            if file_name.ends_with(".json"):
                var file_path = cycle_dir.plus_file(file_name)
                load_cycle_from_file(file_path)
            file_name = dir.get_next()
        
        dir.list_dir_end()
    
    # Rebuild pending tasks list
    _rebuild_pending_tasks()
    
    return true

func load_task_from_file(file_path: String) -> bool:
    var file = File.new()
    var err = file.open(file_path, File.READ)
    
    if err != OK:
        push_error("Failed to open task file for reading: " + str(err))
        return false
    
    var content = file.get_as_text()
    file.close()
    
    var parse_result = JSON.parse(content)
    if parse_result.error != OK:
        push_error("Failed to parse task JSON: " + str(parse_result.error))
        return false
    
    var task_data = parse_result.result
    var task = UpdateTask.from_dict(task_data)
    
    # Store task
    _tasks[task.id] = task
    
    return true

func load_cycle_from_file(file_path: String) -> bool:
    var file = File.new()
    var err = file.open(file_path, File.READ)
    
    if err != OK:
        push_error("Failed to open cycle file for reading: " + str(err))
        return false
    
    var content = file.get_as_text()
    file.close()
    
    var parse_result = JSON.parse(content)
    if parse_result.error != OK:
        push_error("Failed to parse cycle JSON: " + str(parse_result.error))
        return false
    
    var cycle_data = parse_result.result
    var cycle = UpdateCycle.from_dict(cycle_data)
    
    # Store cycle
    _cycles[cycle.id] = cycle
    
    return true

func _rebuild_pending_tasks():
    _pending_tasks.clear()
    
    for task_id in _tasks:
        var task = _tasks[task_id]
        if task.status == "pending":
            _pending_tasks.append(task_id)

# Utility Functions
func create_standard_update_cycle() -> String:
    var cycle_id = create_cycle("Standard Memory Update", UPDATE_CYCLES.STANDARD)
    
    # Create tasks for the cycle
    var snapshot_task_id = create_task(UPDATE_TYPES.SNAPSHOT)
    var clean_task_id = create_task(UPDATE_TYPES.CLEAN)
    var evolve_task_id = create_task(UPDATE_TYPES.EVOLVE)
    
    # Add tasks to cycle
    add_task_to_cycle(cycle_id, snapshot_task_id)
    add_task_to_cycle(cycle_id, clean_task_id)
    add_task_to_cycle(cycle_id, evolve_task_id)
    
    return cycle_id

func create_maintenance_cycle() -> String:
    var cycle_id = create_cycle("Memory Maintenance", UPDATE_CYCLES.EXTENDED)
    
    # Create tasks for the cycle
    var debug_task_id = create_task(UPDATE_TYPES.DEBUG)
    set_task_parameter(debug_task_id, "generate_report", true)
    
    var repair_task_id = create_task(UPDATE_TYPES.REPAIR)
    var compact_task_id = create_task(UPDATE_TYPES.COMPACT)
    
    # Add tasks to cycle
    add_task_to_cycle(cycle_id, debug_task_id)
    add_task_to_cycle(cycle_id, repair_task_id)
    add_task_to_cycle(cycle_id, compact_task_id)
    
    return cycle_id

func create_batch_task(target_memory_ids: Array, type: String) -> String:
    var task_id = create_task(type)
    
    for memory_id in target_memory_ids:
        add_target_to_task(task_id, memory_id)
    
    return task_id

# Debug/Testing
func get_status_report() -> Dictionary:
    var report = {
        "active_cycles": 0,
        "pending_tasks": _pending_tasks.size(),
        "completed_tasks": 0,
        "failed_tasks": 0,
        "next_updates": []
    }
    
    # Count tasks by status
    for task_id in _tasks:
        var task = _tasks[task_id]
        if task.status == "completed":
            report.completed_tasks += 1
        elif task.status == "failed":
            report.failed_tasks += 1
    
    # Count active cycles and next updates
    for cycle_id in _cycles:
        var cycle = _cycles[cycle_id]
        if cycle.is_active:
            report.active_cycles += 1
            
            if cycle.next_run > 0:
                report.next_updates.append({
                    "cycle_id": cycle.id,
                    "name": cycle.name,
                    "next_run": cycle.next_run,
                    "seconds_remaining": max(0, cycle.next_run - OS.get_unix_time())
                })
    
    # Sort next updates by time
    if report.next_updates.size() > 1:
        report.next_updates.sort_custom(self, "_sort_by_next_run")
    
    return report

func _sort_by_next_run(a: Dictionary, b: Dictionary) -> bool:
    return a.next_run < b.next_run

# Example usage:
# var memory_updater = MemoryUpdater.new()
# add_child(memory_updater)
# memory_updater.initialize(memory_system, connection_system)
# 
# # Create and start standard update cycle
# var cycle_id = memory_updater.create_standard_update_cycle()
# memory_updater.activate_cycle(cycle_id)
# 
# # Create one-off task
# var task_id = memory_updater.create_task(MemoryUpdater.UPDATE_TYPES.SNAPSHOT)
# memory_updater.set_task_parameter(task_id, "save_to_file", true)