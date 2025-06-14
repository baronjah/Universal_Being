# Neural Evolution Action Plan
*Immediate Steps to Transform the Project*

## 🚀 **IMMEDIATE ACTIONS**

### **Phase 1: Archive and Modernize** *(Today)*

#### **1. Archive Obsolete Systems**
```bash
# Create archive structure
mkdir -p archives/deprecated_systems/
mkdir -p archives/old_documentation/
mkdir -p archives/experimental_code/

# Move obsolete bird systems
mv scripts/core/bird_*.gd archives/deprecated_systems/
mv scripts/core/astral_being_*.gd archives/deprecated_systems/

# Move old ragdoll versions
mv scripts/ragdoll/simple_*.gd archives/deprecated_systems/
mv scripts/ragdoll/basic_*.gd archives/deprecated_systems/

# Archive experimental patches
mv scripts/patches/*_test.gd archives/experimental_code/
mv scripts/patches/*_old.gd archives/experimental_code/
```

#### **2. Create Current Architecture Map**
- **ACTIVE_SYSTEMS.md** - Only current, working systems
- **NEURAL_PATHWAYS.md** - How systems connect in practice
- **EVOLUTION_POINTS.md** - Where to add neural integration

#### **3. Standardize Naming**
```gdscript
# OLD NAMING → NEW NAMING
bird_ai_behavior.gd → neural_behavior_system.gd
seven_part_ragdoll_integration.gd → embodied_being_controller.gd
jsh_task_manager.gd → consciousness_task_engine.gd
eden_action_system.gd → action_neural_network.gd
```

### **Phase 2: Neural Integration Prototype** *(This Week)*

#### **1. Create Neural Universal Being**
```gdscript
# NEW: scripts/core/neural_universal_being.gd
extends UniversalBeing
class_name NeuralUniversalBeing

# Neural components
@onready var consciousness: ConsciousnessTaskEngine = $ConsciousnessTaskEngine
@onready var embodiment: EmbodiedBeingController = $EmbodiedBeingController  
@onready var action_network: ActionNeuralNetwork = $ActionNeuralNetwork

# Neural state
var needs: Dictionary = {"hunger": 100, "energy": 100, "curiosity": 50}
var current_goal: String = ""
var action_memory: Array[ActionResult] = []

func _ready():
    super._ready()
    _initialize_neural_systems()
    _connect_brain_to_body()

func _initialize_neural_systems():
    consciousness.setup_for_being(self)
    embodiment.connect_to_consciousness(consciousness)
    action_network.register_available_actions(get_being_actions())

func think_and_act():
    # Neural cycle: Sense → Think → Act → Learn
    var sensory_input = gather_sensory_data()
    var decision = consciousness.make_decision(sensory_input, needs)
    var action_result = action_network.execute_action(decision)
    learn_from_result(action_result)

func get_being_actions() -> Array[String]:
    match form:
        "tree":
            return ["grow_fruit", "sway", "drop_leaves", "provide_shade"]
        "astral_being": 
            return ["seek_food", "explore", "communicate", "help_human"]
        "furniture":
            return ["provide_function", "adjust_comfort", "signal_availability"]
        _:
            return ["observe", "exist", "respond"]
```

#### **2. Bridge Brain to Body**
```gdscript
# NEW: scripts/bridges/consciousness_embodiment_bridge.gd
extends Node
class_name ConsciousnessEmbodimentBridge

func connect_systems(consciousness: Node, embodiment: Node):
    # Consciousness → Body commands
    consciousness.action_decided.connect(_execute_physical_action.bind(embodiment))
    consciousness.goal_set.connect(_update_body_state.bind(embodiment))
    
    # Body → Consciousness feedback
    embodiment.movement_completed.connect(_report_to_consciousness.bind(consciousness))
    embodiment.collision_detected.connect(_update_spatial_awareness.bind(consciousness))
    embodiment.state_changed.connect(_update_consciousness_state.bind(consciousness))

func _execute_physical_action(embodiment: Node, action: String, parameters: Dictionary):
    match action:
        "move_to":
            embodiment.navigate_to(parameters.position)
        "pick_up":
            embodiment.grasp_object(parameters.target)
        "speak":
            embodiment.say_text(parameters.text)
        "gesture":
            embodiment.trigger_animation(parameters.gesture_type)
```

#### **3. Action Learning System**
```gdscript
# NEW: scripts/neural/action_learning_system.gd
extends Node
class_name ActionLearningSystem

var learned_actions: Dictionary = {}
var success_rates: Dictionary = {}

func learn_action(being: NeuralUniversalBeing, action_name: String, demonstration: Array):
    # Convert human demonstration to being-specific action
    var adapted_action = adapt_to_being_type(being.form, demonstration)
    learned_actions[action_name] = adapted_action
    
    # Initialize success tracking
    success_rates[action_name] = 0.5
    
    being.add_available_action(action_name)

func improve_action(action_name: String, success: bool):
    if success:
        success_rates[action_name] = min(1.0, success_rates[action_name] + 0.1)
    else:
        success_rates[action_name] = max(0.0, success_rates[action_name] - 0.05)
    
    # Modify action based on success rate
    if success_rates[action_name] < 0.3:
        refine_action(action_name)

func adapt_to_being_type(form: String, base_action: Array) -> Array:
    match form:
        "astral_being":
            return adapt_for_floating_movement(base_action)
        "ragdoll":
            return adapt_for_physics_body(base_action)
        "tree":
            return adapt_for_plant_entity(base_action)
        _:
            return base_action
```

### **Phase 3: Living Actions Implementation** *(Next Week)*

#### **1. Tree Being with Fruit Growing**
```gdscript
# UPDATE: Make trees conscious and fruit-growing
func upgrade_tree_to_neural():
    var tree_being = get_node("TreeBeing")
    var neural_tree = NeuralUniversalBeing.new()
    
    # Copy physical properties
    neural_tree.form = "tree"
    neural_tree.global_position = tree_being.global_position
    neural_tree.manifestation = tree_being.manifestation
    
    # Add tree-specific neural capabilities
    neural_tree.add_action("grow_fruit", grow_fruit_action)
    neural_tree.add_action("provide_shade", shade_action)
    neural_tree.needs = {"nutrients": 80, "sunlight": 60, "growth_desire": 40}
    
    # Replace in scene
    tree_being.get_parent().add_child(neural_tree)
    tree_being.queue_free()

func grow_fruit_action():
    # Multi-step process managed by consciousness
    consciousness.start_task("fruit_growing")
    consciousness.add_task_step("gather_nutrients", 5.0)  # 5 seconds
    consciousness.add_task_step("form_fruit_being", 3.0)
    consciousness.add_task_step("signal_fruit_ready", 1.0)
```

#### **2. Astral Being Fruit Seeking**
```gdscript
# UPDATE: Astral beings seek and consume fruit
func upgrade_astral_to_neural():
    var astral = get_node("AstralBeing")
    var neural_astral = NeuralUniversalBeing.new()
    
    neural_astral.form = "astral_being"
    neural_astral.add_action("seek_food", seek_food_action)
    neural_astral.add_action("consume_fruit", consume_action)
    neural_astral.needs = {"hunger": 40, "curiosity": 80, "companionship": 60}

func seek_food_action():
    # Use consciousness to find fruit
    var fruit_beings = consciousness.scan_environment_for("fruit")
    if fruit_beings.size() > 0:
        var target = consciousness.choose_best_fruit(fruit_beings)
        consciousness.set_goal("consume_fruit", {"target": target})
        embodiment.navigate_to(target.global_position)

func consume_action(target_fruit):
    # Multi-being interaction
    embodiment.trigger_animation("eating")
    target_fruit.consciousness.receive_signal("being_consumed")
    needs["hunger"] = min(100, needs["hunger"] + 30)
    action_network.record_success("consume_fruit")
```

### **Phase 4: Asset Creator Neural Integration** *(Week 2)*

#### **1. Pose Creation for Actions**
```gdscript
# UPDATE: Asset creator creates beings with actions
func create_being_with_actions():
    var creator = get_asset_creator()
    
    # Create physical form
    var being_shape = creator.start_creation()
    var body = sdf.create_capsule(Vector3(0.5, 2, 0.5))  # Basic humanoid
    
    # Add bone system for actions
    var root_bone = creator.add_bone(body, Vector3(0, 0, 0))
    var spine_bone = creator.add_bone(root_bone, Vector3(0, 1, 0))
    var head_bone = creator.add_bone(spine_bone, Vector3(0, 0.5, 0))
    var arm_bones = creator.add_arm_system(spine_bone)
    var leg_bones = creator.add_leg_system(root_bone)
    
    # Define action poses
    creator.create_pose("wave_greeting", {
        head_bone: Quaternion.from_euler(Vector3(0, 0.2, 0)),
        arm_bones.right: Quaternion.from_euler(Vector3(0, 0, 1.57))
    })
    
    creator.create_pose("sitting", {
        spine_bone: Quaternion.from_euler(Vector3(0.5, 0, 0)),
        leg_bones.left_thigh: Quaternion.from_euler(Vector3(1.57, 0, 0)),
        leg_bones.right_thigh: Quaternion.from_euler(Vector3(1.57, 0, 0))
    })
    
    # Export as neural being type
    creator.export_as_neural_being("custom_humanoid")
```

### **Phase 5: 10x10x10 Living Spaces** *(Week 3)*

#### **1. Conscious Room Implementation**
```gdscript
# NEW: Rooms as neural entities
func create_conscious_room():
    var room_being = NeuralUniversalBeing.new()
    room_being.form = "room"
    room_being.become_container(Vector3(10, 10, 10))
    
    # Room-specific actions
    room_being.add_action("adjust_lighting", lighting_action)
    room_being.add_action("organize_contents", organization_action)
    room_being.add_action("connect_to_room", connection_action)
    
    # Room consciousness monitors inhabitants
    room_being.consciousness.add_continuous_task("monitor_inhabitants")
    room_being.consciousness.add_continuous_task("optimize_comfort")

func lighting_action(mood: String):
    match mood:
        "bright":
            environment.sky.energy = 1.5
        "cozy":
            environment.sky.energy = 0.7
            add_warm_light_sources()
        "focused":
            environment.sky.energy = 1.2
            add_directional_lighting()
```

## 🎯 **CONSOLE COMMANDS FOR EVOLUTION**

```bash
# Neural system commands
neural_evolve <being_id>              # Convert being to neural
neural_status <being_id>              # Show neural state
neural_teach <being_id> <action>      # Teach new action
neural_connect <being1> <being2>      # Create neural connection

# Consciousness commands
consciousness_start <being_id>        # Activate consciousness
think <being_id> <situation>         # Make being think about something
dream <being_id>                     # Enter learning/processing mode
needs <being_id>                     # Show being's needs

# Action system commands
actions_list <being_id>              # Show available actions
action_execute <being_id> <action>   # Force action execution
action_learn <being_id> <action>     # Start action learning
action_success <being_id> <action>   # Mark last action as successful

# Evolution tracking
evolution_status                     # Show neural evolution progress
evolution_archive                    # Archive old systems
evolution_clean                      # Clean up obsolete code
```

## 📊 **SUCCESS METRICS**

### **Week 1:**
- [ ] Old systems archived
- [ ] NeuralUniversalBeing prototype working
- [ ] First consciousness-to-embodiment connection

### **Week 2:**
- [ ] Tree growing fruit through consciousness
- [ ] Astral being seeking and eating fruit
- [ ] Action learning system functional

### **Week 3:**
- [ ] Asset creator producing beings with actions
- [ ] 10x10x10 conscious rooms
- [ ] Multi-being interactions

### **Week 4:**
- [ ] Complete neural network operational
- [ ] Emergent behaviors appearing
- [ ] Self-improving action systems

This evolution transforms your existing rich foundation into a **living neural ecosystem** where Universal Beings think, feel, learn, and evolve! 🧠✨