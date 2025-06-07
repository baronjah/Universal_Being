extends Node

class_name MultiThreadedProcessor

# Thread constants and configurations
const MAX_GLOBAL_THREADS = 32
const THREAD_TIMEOUT = 30 # seconds
const AUTO_SCALING = true
const THREAD_SCALING_THRESHOLD = 0.8 # 80% utilization triggers scaling

# Thread priority
enum Priority {
    LOW,
    NORMAL,
    HIGH,
    CRITICAL
}

# Thread status
enum Status {
    IDLE,
    RUNNING,
    COMPLETED,
    ERROR,
    TIMEOUT
}

# Thread pools
var thread_pool = []
var thread_data = {}
var mutex = Mutex.new()
var semaphore = Semaphore.new()

# Account-based thread allocation
var account_thread_allocation = {}
var global_thread_count = 0

# Processing metrics
var thread_utilization = 0.0
var operation_count = 0
var operation_time_total = 0
var operation_times = []

# System monitors
var cpu_usage = 0.0
var memory_usage = 0.0

# Color coding for thread visualization
var thread_colors = {
    Priority.LOW: Color(0.3, 0.7, 0.9), # Blue
    Priority.NORMAL: Color(0.3, 0.9, 0.3), # Green
    Priority.HIGH: Color(0.9, 0.6, 0.3), # Orange
    Priority.CRITICAL: Color(0.9, 0.3, 0.3) # Red
}

# References to other systems
var _account_manager = null
var _smart_account_manager = null

# Signals
signal thread_started(thread_id, priority, task)
signal thread_completed(thread_id, execution_time)
signal thread_error(thread_id, error_message)
signal thread_timeout(thread_id)
signal utilization_changed(utilization)

func _ready():
    # Initialize thread pool
    _initialize_thread_pool()
    
    # Connect to systems
    connect_to_systems()
    
    # Start monitoring threads
    var timer = Timer.new()
    timer.wait_time = 1.0 # 1 second intervals
    timer.autostart = true
    timer.connect("timeout", self, "_on_monitor_threads")
    add_child(timer)

func connect_to_systems():
    # Connect to MultiAccountManager
    if has_node("/root/MultiAccountManager") or get_node_or_null("/root/MultiAccountManager"):
        _account_manager = get_node("/root/MultiAccountManager")
        print("Connected to MultiAccountManager")
    
    # Connect to SmartAccountManager
    if has_node("/root/SmartAccountManager") or get_node_or_null("/root/SmartAccountManager"):
        _smart_account_manager = get_node("/root/SmartAccountManager")
        print("Connected to SmartAccountManager")

func _initialize_thread_pool():
    # Create thread data structures
    for i in range(MAX_GLOBAL_THREADS):
        var thread_id = "thread_" + str(i)
        
        thread_data[thread_id] = {
            "status": Status.IDLE,
            "priority": Priority.NORMAL,
            "start_time": 0,
            "end_time": 0,
            "execution_time": 0,
            "account_id": "",
            "task": "",
            "result": null,
            "error": "",
            "color": thread_colors[Priority.NORMAL]
        }
    
    global_thread_count = MAX_GLOBAL_THREADS
    print("Initialized thread pool with " + str(global_thread_count) + " threads")

func allocate_thread(account_id, task_function, task_parameters, priority = Priority.NORMAL, task_description = ""):
    # Validate inputs
    if not account_id:
        print("Account ID required")
        return null
    
    # Check if account exists in thread allocation
    if not account_id in account_thread_allocation:
        # Initialize thread allocation for this account
        account_thread_allocation[account_id] = {
            "allocated": 0,
            "limit": 1, # Default limit
            "threads": []
        }
        
        # If connected to account manager, get actual limit
        if _account_manager:
            var account = _account_manager.get_account_data(account_id)
            if account:
                account_thread_allocation[account_id]["limit"] = account["max_threads"]
    
    # Check if account has reached thread limit
    if account_thread_allocation[account_id]["allocated"] >= account_thread_allocation[account_id]["limit"]:
        print("Account " + account_id + " has reached thread limit: " + str(account_thread_allocation[account_id]["limit"]))
        return null
    
    # Find available thread
    var thread_id = _find_available_thread(priority)
    if not thread_id:
        print("No threads available with priority: " + str(priority))
        return null
    
    # Set up thread data
    mutex.lock()
    thread_data[thread_id]["status"] = Status.RUNNING
    thread_data[thread_id]["priority"] = priority
    thread_data[thread_id]["start_time"] = OS.get_unix_time()
    thread_data[thread_id]["account_id"] = account_id
    thread_data[thread_id]["task"] = task_description
    thread_data[thread_id]["color"] = thread_colors[priority]
    mutex.unlock()
    
    # Update account allocation
    account_thread_allocation[account_id]["allocated"] += 1
    account_thread_allocation[account_id]["threads"].append(thread_id)
    
    # Create and start thread
    var thread = Thread.new()
    thread.start(self, "_thread_function", {
        "thread_id": thread_id,
        "function": task_function,
        "parameters": task_parameters,
        "priority": priority
    })
    
    # Add thread to pool
    mutex.lock()
    thread_pool.append({
        "id": thread_id,
        "thread": thread,
        "start_time": OS.get_unix_time()
    })
    mutex.unlock()
    
    # Increment operation count
    operation_count += 1
    
    # Emit signal
    emit_signal("thread_started", thread_id, priority, task_description)
    
    print("Allocated thread " + thread_id + " for account " + account_id + " with priority " + str(priority))
    return thread_id

func _thread_function(data):
    var thread_id = data["thread_id"]
    var function = data["function"]
    var parameters = data["parameters"]
    var result = null
    var error = ""
    
    # Execute the function
    if typeof(function) == TYPE_CALLABLE:
        # Try to execute the function
        try:
            if parameters == null:
                result = function.call_func()
            else:
                result = function.call_func(parameters)
        except:
            error = "Exception occurred while executing thread function"
            mutex.lock()
            thread_data[thread_id]["status"] = Status.ERROR
            thread_data[thread_id]["error"] = error
            mutex.unlock()
            emit_signal("thread_error", thread_id, error)
    else:
        error = "Invalid function type"
        mutex.lock()
        thread_data[thread_id]["status"] = Status.ERROR
        thread_data[thread_id]["error"] = error
        mutex.unlock()
        emit_signal("thread_error", thread_id, error)
    
    # Update thread data
    var end_time = OS.get_unix_time()
    var execution_time = end_time - thread_data[thread_id]["start_time"]
    
    mutex.lock()
    if thread_data[thread_id]["status"] != Status.ERROR:
        thread_data[thread_id]["status"] = Status.COMPLETED
    thread_data[thread_id]["end_time"] = end_time
    thread_data[thread_id]["execution_time"] = execution_time
    thread_data[thread_id]["result"] = result
    mutex.unlock()
    
    # Add execution time to metrics
    operation_times.append(execution_time)
    operation_time_total += execution_time
    
    # Limit array size
    if operation_times.size() > 100:
        operation_time_total -= operation_times[0]
        operation_times.remove(0)
    
    # Release thread
    var account_id = thread_data[thread_id]["account_id"]
    _release_thread(thread_id, account_id)
    
    # Emit signal
    if error.empty():
        emit_signal("thread_completed", thread_id, execution_time)
    
    # Signal semaphore to wake up main thread
    semaphore.post()
    return result

func _release_thread(thread_id, account_id):
    # Update account allocation
    if account_id in account_thread_allocation:
        account_thread_allocation[account_id]["allocated"] = max(0, account_thread_allocation[account_id]["allocated"] - 1)
        
        # Remove thread from account's allocated threads
        var index = account_thread_allocation[account_id]["threads"].find(thread_id)
        if index >= 0:
            account_thread_allocation[account_id]["threads"].remove(index)
    
    # Reset thread data
    mutex.lock()
    thread_data[thread_id]["status"] = Status.IDLE
    thread_data[thread_id]["account_id"] = ""
    thread_data[thread_id]["task"] = ""
    mutex.unlock()
    
    # If connected to account manager, notify it
    if _account_manager and account_id:
        _account_manager.release_thread(account_id, thread_id)

func _find_available_thread(priority):
    mutex.lock()
    var available_thread_id = null
    
    # First look for idle threads
    for thread_id in thread_data:
        if thread_data[thread_id]["status"] == Status.IDLE:
            available_thread_id = thread_id
            break
    
    mutex.unlock()
    return available_thread_id

func _on_monitor_threads():
    # Check active threads for timeouts
    var active_count = 0
    var now = OS.get_unix_time()
    
    mutex.lock()
    for i in range(thread_pool.size() - 1, -1, -1):
        var thread_info = thread_pool[i]
        var thread_id = thread_info["id"]
        
        if thread_data[thread_id]["status"] == Status.RUNNING:
            active_count += 1
            
            # Check for timeout
            var duration = now - thread_info["start_time"]
            if duration > THREAD_TIMEOUT:
                # Thread has timed out
                thread_data[thread_id]["status"] = Status.TIMEOUT
                thread_data[thread_id]["error"] = "Thread execution timed out after " + str(THREAD_TIMEOUT) + " seconds"
                
                # Force release thread
                var account_id = thread_data[thread_id]["account_id"]
                _release_thread(thread_id, account_id)
                
                # Emit signal
                emit_signal("thread_timeout", thread_id)
                print("Thread " + thread_id + " timed out after " + str(duration) + " seconds")
        
        # Remove completed threads from pool
        if thread_data[thread_id]["status"] == Status.COMPLETED or thread_data[thread_id]["status"] == Status.ERROR or thread_data[thread_id]["status"] == Status.TIMEOUT:
            # Wait for thread to finish
            thread_info["thread"].wait_to_finish()
            
            # Remove from pool
            thread_pool.remove(i)
    mutex.unlock()
    
    # Update thread utilization
    thread_utilization = float(active_count) / float(global_thread_count) if global_thread_count > 0 else 0.0
    
    # Monitor system resources
    _update_system_metrics()
    
    # Emit signal if utilization changed significantly
    emit_signal("utilization_changed", thread_utilization)
    
    # Auto-scale if enabled
    if AUTO_SCALING and thread_utilization > THREAD_SCALING_THRESHOLD:
        _auto_scale_threads()

func _update_system_metrics():
    # In a real implementation, would use OS APIs to get actual CPU and memory usage
    # For now, use thread utilization as an approximation
    cpu_usage = thread_utilization * 100.0
    
    # Simulate memory growth based on thread activity
    var memory_growth = thread_utilization * 0.1 # 0-10% growth per check
    memory_usage = min(100.0, memory_usage + memory_growth)
    
    # Decay memory usage slowly to simulate GC
    memory_usage = max(0.0, memory_usage - 0.05)

func _auto_scale_threads():
    # Only scale if we haven't reached the maximum
    if global_thread_count >= MAX_GLOBAL_THREADS:
        return
    
    # Add more threads
    var threads_to_add = min(4, MAX_GLOBAL_THREADS - global_thread_count)
    
    for i in range(threads_to_add):
        var thread_id = "thread_" + str(global_thread_count)
        
        thread_data[thread_id] = {
            "status": Status.IDLE,
            "priority": Priority.NORMAL,
            "start_time": 0,
            "end_time": 0,
            "execution_time": 0,
            "account_id": "",
            "task": "",
            "result": null,
            "error": "",
            "color": thread_colors[Priority.NORMAL]
        }
        
        global_thread_count += 1
    
    print("Auto-scaled thread pool to " + str(global_thread_count) + " threads")

func get_thread_status(thread_id):
    if not thread_id in thread_data:
        return null
    
    mutex.lock()
    var status_copy = thread_data[thread_id].duplicate()
    mutex.unlock()
    
    return status_copy

func get_thread_result(thread_id):
    if not thread_id in thread_data:
        return null
    
    mutex.lock()
    var result = thread_data[thread_id]["result"]
    mutex.unlock()
    
    return result

func get_account_threads(account_id):
    if not account_id in account_thread_allocation:
        return []
    
    return account_thread_allocation[account_id]["threads"].duplicate()

func get_utilization_stats():
    return {
        "thread_utilization": thread_utilization,
        "cpu_usage": cpu_usage,
        "memory_usage": memory_usage,
        "active_threads": get_active_thread_count(),
        "total_threads": global_thread_count,
        "operations_count": operation_count,
        "avg_execution_time": get_average_execution_time()
    }

func get_active_thread_count():
    var count = 0
    
    mutex.lock()
    for thread_id in thread_data:
        if thread_data[thread_id]["status"] == Status.RUNNING:
            count += 1
    mutex.unlock()
    
    return count

func get_average_execution_time():
    if operation_times.size() == 0:
        return 0.0
    
    return operation_time_total / float(operation_times.size())

func get_thread_color(thread_id):
    if not thread_id in thread_data:
        return Color(0.5, 0.5, 0.5) # Default gray
    
    mutex.lock()
    var color = thread_data[thread_id]["color"]
    mutex.unlock()
    
    return color