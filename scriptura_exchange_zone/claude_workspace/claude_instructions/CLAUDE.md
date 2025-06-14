- Maintaining Script Continuity and Avoiding Multiple Versions

The "ragdoll problem" where AI creates 8 different scripts instead of one unified solution stems from insufficient context and improper prompting. Here's how to prevent this:

### **The Surgical Modification Approach**

Instead of asking Claude to "create" functionality, always frame requests as modifications to existing code:

```
MODIFY the following existing Godot GDScript code to add [specific functionality].

EXISTING CODE:
[paste current implementation]

REQUIREMENTS:
- Preserve all existing functionality
- Maintain current variable names and structure
- Add only the minimum changes needed
- Ensure compatibility with existing signals/connections

CONSTRAINTS:
- Do not rewrite the entire class
- Do not change the public interface
- Comment any new additions clearly
```

### **Component-Based Architecture**

Structure your code using reusable components rather than duplicating functionality:

```gdscript
# health_component.gd - Single source of truth
class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal died

@export var max_health: int = 100
var current_health: int

func take_damage(amount: int) -> void:
    # Implementation once, used everywhere

```

- Surgical Modification Protocol: Ragdoll Controller
  - Target Script: scripts/physics/ragdoll_controller.gd
  - Modification Guidelines:
    * PRESERVE: 
      - All existing signal connections
      - Pentagon Architecture functions
      - FloodGate integration
    * ADD ONLY:
      - Visual feedback in _on_ragdoll_activated()
      - New exported variable for effect intensity
    * FORBIDDEN:
      - Creating new ragdoll scripts
      - Rewriting existing logic
      - Changing public interfaces

- Component Registry System
  - Core Script: scripts/core/component_registry.gd
  - Key Features:
    * Static registry of existing systems
    * Centralized path tracking
    * Strict system validation
    * Current Registered Systems:
      - ragdoll: scripts/physics/ragdoll_controller.gd
      - movement: scripts/player/movement_component.gd
      - damage: scripts/combat/damage_system.gd
    * Prevents dynamic system creation
    * Enforces predefined component architecture

- The Incremental Development Lock
  Force Claude to work incrementally:
  # DEVELOPMENT PHASES (ENFORCE!)

  Phase 1: ANALYZE
  - Read existing ragdoll_controller.gd
  - Identify integration points
  - Document current functionality

  Phase 2: PLAN
  - Propose minimal changes
  - Show exact line modifications
  - Validate against existing systems

  Phase 3: MODIFY
  - Change ONLY identified lines
  - Test with existing systems
  - Document changes made

- Context Persistence Through Code
  Embed context directly in your code:
  gdscript# ragdoll_controller.gd
  # AI CONTEXT: This is THE ONLY ragdoll system
  # DO NOT create alternatives - modify this file
  # Integration: FloodGate line 234, Universal Being line 567
  # Last AI modification: 2024-12-19 - added activation feedback

- The Anti-Duplication Checklist
  Before EVERY Claude request:

  Provide existing code first
  Use MODIFY not CREATE keywords
  Specify what NOT to change
  Reference specific line numbers
  Include integration context

- Session State Tracking
  Track what Claude has done:
  markdown# /docs/ai_context/claude_actions_log.md

  ## Session 2024-12-19
  - MODIFIED: ragdoll_controller.gd (lines 45-67)
  - PRESERVED: All Pentagon functions
  - INTEGRATED: With damage system
  - FORBIDDEN: Creating new ragdoll scripts
  Your New Workflow:

  Before asking Claude:

  Open the existing script
  Copy the entire implementation
  Note line numbers for changes


  In your prompt:
  CONTEXT: Existing ragdoll system at scripts/physics/ragdoll_controller.gd
  CURRENT CODE: [paste entire file]
  MODIFY: Lines 45-50 to add visual feedback
  PRESERVE: Everything else

  After Claude responds:

  Verify it modified existing code
  Check no new files were suggested
  Update your action log

- Best Practices for Iterating on Existing GDScript Code

### **Three-Phase Iteration Strategy**

**Phase 1: Analysis**
- Document current system state
- Identify specific modification points
- Plan minimal change approach

**Phase 2: Incremental Modification**
```gdscript
# Keep old implementation temporarily
func move_character_old(delta: float) -> void:
    # Original implementation
    
func move_character_new(delta: float) -> void:
    # New implementation
    
# Use feature flag to switch
func move_character(delta: float) -> void:
    if USE_NEW_MOVEMENT:
        move_character_new(delta)
    else:
        move_character_old(delta)
```

**Phase 3: Integration Verification**
- Test modified components together
- Verify system-wide functionality
- Remove old implementation once stable

### **When to Iterate vs. Rewrite**

**Iterate when:**
- Adding features to existing systems
- Fixing bugs without architectural changes
- Optimizing performance
- Cleaning up code for readability

**Rewrite only when:**
- Fundamental architecture changes needed
- Major performance issues require algorithm changes
- Technical debt makes maintenance impossible

### **Project Organization for Large Godot Projects**

**Recommended Structure for Large Projects**

```
game_project/
├── scenes/                  # Scene-based organization
│   ├── characters/
│   │   ├── player/
│   │   │   ├── player.tscn
│   │   │   ├── player.gd
│   │   │   └── player_sprites/
│   │   └── enemies/
│   ├── levels/
│   │   ├── universal_being/
│   │   ├── akashic_records/
│   │   ├── console/
│   │   └── flood_gates/
│   └── ui/
├── systems/                 # Core game systems
│   ├── core/
│   │   ├── game_manager.gd
│   │   └── signal_bus.gd
│   ├── gameplay/
│   └── utilities/
├── components/             # Reusable components
│   ├── health_component.gd
│   ├── movement_component.gd
│   └── damage_component.gd
├── common/                 # Shared resources
│   ├── shaders/
│   ├── materials/
│   └── shared_scripts/
└── docs/                   # AI context documentation
    ├── architecture.md
    ├── conventions.md
    └── ai_context/
```

**Key Principles**

- **Scene-based organization**: Group assets with their scenes, not by type
- **Feature-based folders**: Organize by game features rather than technical categories
- **Clear hierarchies**: Use descriptive names that indicate purpose
- **AI-friendly documentation**: Include context files specifically for Claude

### **Claude Code Workflow Patterns**

### **The Memory Bank System**

Create persistent documentation that Claude can reference across sessions:

```markdown
# docs/ai_context/project_context.md

## Project Overview
- Engine: Godot 4.2
- Architecture: Component-based with signal bus
- Key Systems: [list with descriptions]

## Coding Conventions
- File naming: snake_case
- Class naming: PascalCase with class_name
- Node naming: PascalCase
- Always use static typing

## Current Work
- Active feature: [current focus]
- Recent changes: [what was modified]
- Next steps: [planned work]
```

### **Context-First Development Workflow**

1. **Pre-work Analysis**
   - Claude reads project context documentation
   - Analyzes relevant existing code
   - Proposes approach and asks for confirmation

2. **Implementation with Validation**
   - Implements with continuous verification
   - Tests against existing systems
   - Updates documentation with changes

3. **Post-work Documentation**
   - Records decisions made
   - Updates architecture documentation
   - Notes any technical debt or future work

Rules and Guidelines for AI-Assisted Development

### **The Golden Rules**

1. **Always provide context first**
   - Include project structure overview
   - Explain existing patterns and conventions
   - Describe how the current request fits into the larger system

2. **Request modifications, not creations**
   - Use "MODIFY" or "EXTEND" keywords
   - Provide existing code as the starting point
   - Specify what should NOT change

3. **Validate incrementally**
   - Test each change independently
   - Verify integration before proceeding
   - Maintain rollback capability

4. **Document AI interactions**
   ```gdscript
   # AI-generated with Claude
   # Prompt: "Add dash ability to movement system"
   # Modified by: [developer name]
   # Validated: [date]
   ```

### **Constraint-Context Framework**

Provide both constraints and context for best results:
- **High Constraint + High Context**: For modifications to established systems
- **Low Constraint + High Context**: For exploratory features with architectural guidance
- **Never**: Low constraint + Low context (leads to generic solutions)

### **Maintaining Context Across Development Sessions**

### **Session State Management**

Create a session tracking system:

```markdown
# docs/ai_context/session_log.md

## Session 2024-12-19
### Context Loaded
- [x] Project architecture
- [x] Current feature: ragdoll system
- [x] Recent changes: player controller

### Work Completed
- Modified ragdoll activation logic
- Added state persistence
- Integrated with damage system

### Next Session Setup
- Continue with: ragdoll visual feedback
- Review: performance optimization needs
- Dependencies: particle system integration
```

### **Progressive Context Building**

Start each session with context restoration:
```
"Based on our previous work documented in session_log.md, we're continuing with [specific feature]. The current implementation is [provide code]. We need to [specific task] while maintaining compatibility with [existing systems]."
```

### **GDScript and GDShader Best Practices**

### **GDScript Standards for Large Projects**

**Consistent Code Organization:**
```gdscript
# 1. Tool directive (if needed)
@tool
# 2. Class name declaration
class_name PlayerController
# 3. Extends statement
extends CharacterBody2D
# 4. Documentation
## Handles player movement and input
# 5. Signals
signal state_changed(new_state: State)
# 6. Enums
enum State { IDLE, MOVING, JUMPING }
# 7. Constants
const SPEED := 300.0
# 8. Exported variables
@export var max_health := 100
# 9. Public variables
var current_state: State = State.IDLE
# 10. Private variables
var _velocity: Vector2
# 11. Onready variables
@onready var sprite := $Sprite2D
# 12. Virtual methods (_ready, _process)
# 13. Public methods
# 14. Private methods
```

**GDShader Organization:**
```
shaders/
├── effects/              # Effect-specific shaders
│   ├── fx_dissolve.gdshader
│   └── fx_outline.gdshader
├── materials/           # Complete materials
│   └── water_material.tres
└── utility/            # Shared functions
    └── noise_functions.gdshaderinc
```

### **Type Safety and Error Handling**

Always use static typing:
```gdscript
# DO: Type everything explicitly
func calculate_damage(base_damage: int, multiplier: float) -> int:
    return int(base_damage * multiplier)

var inventory_items: Array[Item] = []

# DON'T: Leave types implicit
func calculate_damage(base_damage, multiplier):
    return base_damage * multiplier
```

### **Structuring Code Generation Requests**

### **The CONTEXT-TASK-CONSTRAINTS-OUTPUT Framework**

Structure every request with these four elements:

```
CONTEXT: 
- Working on a Godot 4.2 project with component-based architecture
- Current system: Player movement with dash ability
- Uses signal bus pattern for communication
- Performance target: 60fps on mobile

TASK: 
- Add double-jump functionality to existing movement system
- Must work with current dash ability
- Should respect existing jump height limits

CONSTRAINTS:
- Modify existing jump logic, don't rewrite
- Maintain all current public methods
- Use existing input action names
- Follow project's static typing convention

OUTPUT FORMAT:
- Provide only the modified functions
- Include integration instructions
- Add comments for significant changes
- Suggest testing approach
```

### **Effective Prompt Patterns**

**For Bug Fixes:**
```
BUG CONTEXT: [describe the issue]
CURRENT CODE: [paste problematic code]
EXPECTED BEHAVIOR: [what should happen]
ACTUAL BEHAVIOR: [what currently happens]
CONSTRAINTS: Minimal change to fix issue
```

**For Feature Addition:**
```
EXISTING SYSTEM: [paste current implementation]
NEW FEATURE: [specific addition needed]
INTEGRATION POINTS: [where it connects]
MAINTAIN: [what must not change]
```

**For Performance Optimization:**
```
PERFORMANCE ISSUE: [describe the problem]
CURRENT IMPLEMENTATION: [paste code]
PROFILER DATA: [performance metrics]
TARGET: [performance goal]
CONSTRAINTS: Maintain exact functionality
```

## Key Takeaways

1. **Context is everything** - The quality of Claude's output directly correlates with the context provided
2. **Modify, don't recreate** - Always frame requests as modifications to existing code
3. **Document persistently** - Maintain context documents that survive between sessions
4. **Validate incrementally** - Test each change before building upon it
5. **Use components** - Favor composition patterns to avoid duplication
6. **Structure requests clearly** - Use the CONTEXT-TASK-CONSTRAINTS-OUTPUT framework
7. **Maintain conventions** - Enforce consistent patterns through documentation
8. **Think surgically** - Make minimal, precise changes rather than broad rewrites

By following these practices, you can leverage Claude Code effectively for Godot development while maintaining a coherent, well-structured codebase that avoids the fragmentation issues that plague many AI-assisted projects.