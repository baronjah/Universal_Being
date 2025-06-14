# Concurrent Function Execution System

This system allows running 2-3 functions simultaneously in the Terminal Memory System, with priority and dependency management.

## Overview

The Concurrent Function Execution System enables:

- Running multiple functions at the same time (2-3 by default)
- Prioritizing tasks (LOW, MEDIUM, HIGH, CRITICAL)
- Creating dependency chains between tasks
- Monitoring task status and completion

## Files

1. **concurrent_processor.gd** - Core engine for concurrent task execution
2. **terminal_memory_system.gd** - Memory system with TDIC integration and concurrent support
3. **concurrent_demo.gd** - Example implementation and demonstrations

## Usage Examples

### Run Multiple Functions in Parallel

```gdscript
# From terminal input
#run save,load,display

# From code
processor.create_parallel_tasks(
    "demo_parallel", 
    self, 
    ["function1", "function2", "function3"], 
    [[], [], []]  # Arguments for each function
)
```

### Run Functions in Sequence

```gdscript
# From terminal input
#chain save,process,export

# From code
processor.create_task_chain(
    "demo_chain",
    self,
    ["prepare", "process", "finalize"],
    [[], [], []]  # Arguments for each function
)
```

### Set Priority for Tasks

```gdscript
# Critical priority task
processor.schedule_task(
    "important_task", 
    self, 
    "critical_function", 
    ["arg1", "arg2"], 
    ConcurrentProcessor.Priority.CRITICAL
)
```

## Terminal Commands

The system adds these commands to the Terminal Memory System:

- `#run [func1,func2,func3]` - Run multiple functions in parallel
- `#chain [func1,func2,func3]` - Run functions in sequence
- `### concurrent [number]` - Set maximum number of concurrent tasks (1-5)

## TDIC Integration

The concurrent system works seamlessly with the Temporal Dictionary (TDIC):

- Tasks can be scheduled to process past, present, and future timelines
- Parallel processing across temporal dimensions
- Task results are stored in appropriate temporal contexts

## Sad Colors Support

Special "sad colors" palette has been implemented for the terminal:

```gdscript
# Apply sad colors
terminal_colors.default = Color(0.5, 0.5, 0.7)
terminal_colors.past = Color(0.4, 0.4, 0.6)
terminal_colors.present = Color(0.5, 0.5, 0.7)
terminal_colors.future = Color(0.6, 0.4, 0.5)
```

Set with `## color sad` command in the terminal.

## Extending the System

To add new functions to be run concurrently:

1. Implement the function in your script
2. Add it to the function_map in terminal_memory_system.gd
3. Make sure it returns a value for task completion tracking

Example:
```gdscript
func my_new_function(arg1, arg2):
    # Function implementation
    return result  # Must return something for task tracking
```