# ==================================================
# UNIVERSAL BEING COMPONENT: MemoryComponent
# TYPE: component
# PURPOSE: Provides memory storage, recall, and event logging to Universal Beings
# ==================================================

extends Node
class_name MemoryComponent

# ===== MEMORY PROPERTIES =====
@export var memory_log: Array = []
@export var max_memory: int = 1000

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
    # No super, as this is a component
    memory_log.clear()
    print("🧠 MemoryComponent: Initialized memory log.")

func pentagon_ready() -> void:
    print("🧠 MemoryComponent: Ready for memory operations.")

func pentagon_process(delta: float) -> void:
    # Could be used for memory decay, scheduled recall, etc.
    pass

func pentagon_input(event: InputEvent) -> void:
    # Could be used for memory-triggered actions
    pass

func pentagon_sewers() -> void:
    print("🧠 MemoryComponent: Cleaning up memory log.")
    memory_log.clear()

# ===== MEMORY METHODS =====

func remember(event: Dictionary) -> void:
    memory_log.append(event)
    if memory_log.size() > max_memory:
        memory_log.pop_front()
    print("🧠 MemoryComponent: Remembered event: %s" % str(event))

func recall(filter: String = "") -> Array:
    if filter == "":
        return memory_log.duplicate()
    return memory_log.filter(func(e): return filter in str(e))

func forget(index: int) -> void:
    if index >= 0 and index < memory_log.size():
        memory_log.remove_at(index)
        print("🧠 MemoryComponent: Forgot memory at index %d" % index) 