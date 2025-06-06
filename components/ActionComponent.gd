# ==================================================
# UNIVERSAL BEING COMPONENT: ActionComponent
# TYPE: component
# PURPOSE: Provides action scheduling, execution, and management to Universal Beings
# ==================================================

extends Component
class_name ActionComponent

# ===== ACTION PROPERTIES =====
@export var action_queue: Array = []
@export var current_action: Dictionary = {}

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
    action_queue.clear()
    current_action = {}
    print("⚡ ActionComponent: Initialized action queue.")

func pentagon_ready() -> void:
    print("⚡ ActionComponent: Ready for action execution.")

func pentagon_process(delta: float) -> void:
    if current_action and current_action.has("type"):
        # Execute or update current action
        process_action(current_action, delta)
    elif action_queue.size() > 0:
        current_action = action_queue.pop_front()
        print("⚡ ActionComponent: Started new action: %s" % str(current_action))

func pentagon_input(event: InputEvent) -> void:
    # Could be used for action-triggered input
    pass

func pentagon_sewers() -> void:
    print("⚡ ActionComponent: Cleaning up action queue.")
    action_queue.clear()
    current_action = {}

# ===== ACTION METHODS =====

func queue_action(action: Dictionary) -> void:
    action_queue.append(action)
    print("⚡ ActionComponent: Queued action: %s" % str(action))

func process_action(action: Dictionary, delta: float) -> void:
    # Minimal example: just print and finish
    print("⚡ ActionComponent: Processing action: %s" % str(action))
    # Mark as done (in a real system, check for completion)
    current_action = {}

func clear_actions() -> void:
    action_queue.clear()
    current_action = {}
    print("⚡ ActionComponent: Cleared all actions.") 