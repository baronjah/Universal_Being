# 🎮 MASTER COMMAND REFERENCE
*Complete list of all 220+ console commands*

## 🏗️ **CREATION COMMANDS**

### **Basic Objects**
```bash
tree              # Static tree with trunk and leaves
rock              # Static rock formation
box               # Rigid body cube
ball              # Bouncy sphere with physics
wall              # Static wall barrier
stick             # Rigid cylindrical stick
leaf              # Small rigid leaf object
ramp              # Angled static platform
sun               # Light-emitting sun object
pathway           # Path/road segment
bush              # Decorative bush
fruit             # Interactive fruit object

# Universal Creation
create <object>   # Create any object from asset library
spawn <object>    # Alias for create command
```

### **Advanced Creation**
```bash
test_cube         # Bouncy, colored, interactive cube with physics
asset_creator     # Cosmic spectrum color creator UI
assets            # List all available assets + custom ones
```

## 🧬 **UNIVERSAL BEINGS SYSTEM**

### **Being Commands**
```bash
being create <type> [variant] [x y z]   # Create transformable Universal Being
being transform <id> <new_form>         # Transform being into new shape
being edit <id> <property> <value>      # Edit being properties
being connect <id1> <id2>               # Connect two beings
being list [filter]                     # List all beings with optional filter
being inspect <id>                      # Detailed being inspection
being interface <type> [position]       # Create interface being

ubeing                                  # Quick alias + help system
```

### **Being Examples**
```bash
being create tree                       # Standard tree being
being create tree ancient 5 0 3        # Ancient tree variant at position
being transform Tree_1 ancient_oak     # Transform tree to ancient oak
being interface console 0 2 0          # Create console interface being
```

## 🔍 **ANALYSIS & DEBUG COMMANDS**

### **Object Inspection**
```bash
inspect_cube       # Detailed cube physics stats and properties
list              # Objects tracked by UniversalObjectManager  
scenes            # All nodes in scene tree with positions
inspect <object>   # General object inspector
object_inspector  # Advanced object inspection interface
inspector         # Alias for object_inspector
```

### **Scene Analysis**
```bash
scenes            # Debug scene tree with positions (depth 3)
scene_status      # Current scene information
scene_tree        # JSH scene tree analysis
```

### **Viewport & Camera Analysis**
```bash
viewport_info     # Camera FOV, resolution, 3D UI calculations
camera_rays       # 5-ray frustum analysis (center + 4 corners)
```

## ⚙️ **SYSTEM CONTROL COMMANDS**

### **Performance & Physics**
```bash
performance       # System performance statistics
physics           # Gravity and physics control
physics_test      # Physics system testing and validation
gravity           # Physics gravity control (alias)
```

### **Floodgate Central System**
```bash
floodgate         # Status of central control system
queues            # Queue status across all systems
healthcheck       # System health verification  
floodtest         # Test floodgate functionality
systems           # Overall system status
system_status     # Alias for systems command
```

### **Core Systems**
```bash
setup_systems     # Manual system initialization
test              # Automatic test of whole game
version           # Game version control information
```

## 🎭 **RAGDOLL & CHARACTER COMMANDS**

### **Ragdoll Creation**
```bash
spawn_ragdoll     # Create basic ragdoll character
spawn_skeleton    # Create skeleton-based ragdoll
spawn_ragdoll_v2  # Advanced ragdoll v2 system
ragdoll2          # Alias for ragdoll v2
```

### **Ragdoll Control**
```bash
ragdoll <action>  # General ragdoll command system
walk              # Make ragdoll walk
say               # Make ragdoll speak
ragdoll_debug     # Toggle ragdoll debug visualization
ragdoll_come      # Call ragdoll to player
ragdoll_pickup    # Ragdoll pickup nearest object
ragdoll_drop      # Ragdoll drop held object
```

### **Ragdoll Movement**
```bash
ragdoll_move      # Move ragdoll to position
ragdoll_speed     # Set ragdoll movement speed
ragdoll_run       # Make ragdoll run
ragdoll_crouch    # Ragdoll crouch position
ragdoll_jump      # Make ragdoll jump
ragdoll_rotate    # Rotate ragdoll orientation
ragdoll_stand     # Ragdoll standing position
```

### **Ragdoll Management**
```bash
ragdoll_organize  # Organize multiple ragdolls
ragdoll_patrol    # Set ragdoll patrol behavior
ragdoll_state     # Check ragdoll state
ragdoll_status    # Overall ragdoll status
ragdoll2_move     # Move ragdoll v2
ragdoll2_state    # Ragdoll v2 state
ragdoll2_debug    # Ragdoll v2 debugging
```

## 🌟 **ASTRAL BEINGS SYSTEM**

### **Astral Commands**
```bash
astral            # Create astral being
astral_being      # Full astral being command
astral_control    # Control astral beings
talk_to_beings    # Communicate with astral beings
being_count       # Count all types of beings
beings_status     # Status of all beings
beings_help       # Help for beings system
beings_organize   # Organize being behaviors
beings_harmony    # Harmony between beings
```

### **Dimensional Commands**
```bash
dimension         # Dimensional shift operations
consciousness     # Add consciousness to beings
emotion           # Set emotional states
spell             # Cast spells and magic
```

## 🎨 **UI & INTERFACE COMMANDS**

### **Console Control**
```bash
console           # Console settings and position
scale             # UI scaling adjustment
console_debug     # Toggle console debug mode
help              # Complete command reference
```

### **Visual Systems**
```bash
ui                # UI creation tools
grid              # Grid visualization system
debug_panel       # Debug interface status
test_click        # Test mouse click detection
```

### **Object Interaction**
```bash
select            # Select objects in scene
move              # Move selected objects
rotate            # Rotate selected objects  
scale_obj         # Scale selected objects
state             # Change object states
awaken            # Awaken object behaviors
info              # Object information display
delete            # Delete selected objects
clear             # Clear all objects
limits            # Object count limits
```

## 🌍 **WORLD BUILDING COMMANDS**

### **Environment Generation**
```bash
generate_world    # Create heightmap island + props
world             # Alias for generate_world
restore_ground    # Reset ground plane to default
ground            # Alias for restore_ground
```

### **Scene Management**  
```bash
scene             # Scene loader and manager
save              # Save current scene state
load              # Load saved scene
```

### **Game Rules System**
```bash
rules_off         # Disable automatic rule execution
rules             # Text-based rules management
```

## 🐦 **CREATURE COMMANDS**

### **Birds & Animals**
```bash
pigeon            # Create pigeon character
bird              # Alias for pigeon command
```

## 📚 **LEARNING & TUTORIAL COMMANDS**

### **Tutorial System**
```bash
tutorial          # Interactive learning system
tutorial_start    # Begin guided tutorial
tutorial_stop     # End current tutorial
tutorial_status   # Tutorial system status
tutorial_hide     # Hide tutorial interface
tutorial_show     # Show tutorial interface
interactive_tutorial  # Advanced tutorial mode
test_tutorial     # Test tutorial functionality
test_ragdolls     # Test ragdoll tutorial
```

### **Help Commands**
```bash
help              # Master command reference (this document)
help_ragdoll      # Ragdoll-specific help
astral_help       # Astral beings help
```

## 🔧 **ADVANCED SYSTEM COMMANDS**

### **JSH Framework**
```bash
jsh_status        # JSH system status
container         # Container management
thread_status     # Thread monitoring
akashic_save      # Save to Akashic records
akashic_load      # Load from Akashic records
```

### **Task & Project Management**
```bash
timer             # Timer control system
task              # Task management
todos             # Multi-todo system
balance           # Workload balancing
projects          # Project manager
timing            # Timing information
```

### **Automation & Workflow**
```bash
passive           # Passive mode automation
add_task          # Add automated task
branch            # Git branch operations
commit            # Git commit operations
mr                # Merge request creation
merge             # Merge operations  
workflow          # Workflow status
```

## 🎯 **ACTION SYSTEM COMMANDS**

### **Eden Action System**
```bash
action_list       # List available actions
action_test       # Test action execution
action_combo      # Execute action combinations
```

## 📊 **DEBUG & DEVELOPMENT**

### **Development Tools**
```bash
debug             # Debug screen controls
timing            # Performance timing
```

---

## 🔍 **COMMAND DISCOVERY**

### **Finding Commands**
Most commands are registered in `/scripts/autoload/console_manager.gd` in the main `commands` dictionary (lines 50-223).

Additional commands may be registered via:
- `register_command()` calls in various scripts
- Extension files like `console_command_extension.gd`
- Dynamic command injection systems

### **Command Aliases**
Many commands have aliases for convenience:
- `spawn` = `create`
- `ubeing` = `being`  
- `ground` = `restore_ground`
- `world` = `generate_world`
- `ragdoll2` = `spawn_ragdoll_v2`

### **Command Categories**
- **Creation**: 15+ object types + universal creator
- **Beings**: 10+ universal being commands
- **Ragdolls**: 20+ ragdoll control commands
- **System**: 15+ system monitoring commands
- **Debug**: 10+ analysis and debug tools
- **UI**: 8+ interface commands
- **Tutorial**: 8+ learning system commands

---

*"With great power comes great creativity!"* 🚀

**Total Commands: 220+ and growing!**