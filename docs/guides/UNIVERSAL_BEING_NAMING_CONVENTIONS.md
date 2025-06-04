# Universal Being Naming Conventions & Rule System
## Archaeological Discovery: Avoiding Godot Reserved Words

**Philosophy:** "We cannot name a var with Godot words, and it is better to use different words than the programming language we use."

---

## 🚫 GODOT RESERVED WORDS TO AVOID

### Core Node Properties (HIGH RISK)
```gdscript
# NEVER USE THESE AS VARIABLE NAMES:
name                # Node.name - EPIDEMIC ISSUE
visible             # CanvasItem.visible  
position           # Node2D/Node3D.position
rotation           # Node2D/Node3D.rotation
scale              # Node2D/Node3D.scale
modulate           # CanvasItem.modulate
texture            # Many classes
material           # Many classes
process            # Node._process()
ready              # Node._ready()
input              # Node._input()
notification       # Node._notification()
tree               # Node.tree
owner              # Node.owner
scene              # Various contexts
parent             # Node.parent
children           # Node.children
```

### GDScript Directives & Built-in Types (CRITICAL)
```gdscript
# ❌ NEVER USE AS VARIABLE NAMES (they have built-in functions/meaning):
class_name     # GDScript class directive
type           # Built-in type checking system  
extends        # Class inheritance directive - var extends = bad
export         # Old export system (use @export)
onready        # Old onready system (use @onready)
tool           # Script execution directive

# Built-in types with their own methods/properties:
Vector2, Vector3, Vector4    # Have .length(), .normalized(), etc.
Color                        # Has .r, .g, .b, .a properties  
Transform2D, Transform3D     # Have .origin, .basis, etc.
Resource, Node               # Base classes with extensive methods
```

### GDScript Language Elements (CLARIFICATION)
```gdscript
# ✅ MUST USE THESE (they are the language itself):
var, func, extends, const, enum, signal
if, else, elif, while, for, match, case, default
true, false, null, self, super
and, or, not, in, is, as
return, break, continue, pass
static, @export, @onready, @tool

# ❌ NEVER USE AS VARIABLE NAMES:
class_name     # GDScript directive
type           # Built-in type system
# symbol       # Comment marker
extends        # Only as keyword, not var name
```

---

## ✅ UNIVERSAL BEING NAMING PATTERNS

### 1. Core Being Properties
```gdscript
# INSTEAD OF 'name' USE:
being_name          # Universal Being identifier
being_title         # Display name
being_label         # Short identifier
being_designation   # Formal name

# INSTEAD OF 'type' USE:
being_type          # Universal Being category
being_form          # Current manifestation
being_species       # Being classification
being_archetype     # Being template type
```

### 2. Consciousness & Evolution
```gdscript
# CONSCIOUSNESS TERMS:
consciousness_level     # Awareness level (0-5)
awareness_state        # Current consciousness state
mindful_presence       # Being's awareness intensity
cognitive_depth        # Thinking complexity
sentience_grade        # Level of sentience

# EVOLUTION TERMS:
evolution_path         # Available evolution routes
transformation_queue   # Pending transformations  
metamorphosis_state    # Evolution state
becoming_potential     # What being can become
growth_trajectory      # Evolution direction
```

### 3. Socket System Properties
```gdscript
# SOCKET NAMING:
socket_designation     # Instead of 'socket_name'
socket_identifier      # Instead of 'socket_id' 
socket_classification  # Instead of 'socket_type'
socket_mounting_point  # Physical socket location
socket_interface_spec  # Socket specification

# COMPONENT NAMING:
component_blueprint    # Component definition
component_manifest     # Component metadata
component_assembly     # Mounted component
component_designation  # Component name/id
```

### 4. Visual & Rendering
```gdscript
# VISUAL PROPERTIES:
visual_layer           # Instead of 'layer'
rendering_depth        # Z-depth for rendering
visual_priority        # Drawing order
display_mode           # Visibility mode
appearance_state       # Visual appearance

# MATERIAL/TEXTURE:
surface_material       # Material properties
visual_texture         # Texture mapping
appearance_shader      # Shader reference
visual_effect          # Effect application
```

### 5. Spatial Properties
```gdscript
# POSITION/TRANSFORM:
spatial_coordinates    # Instead of 'position'
world_location         # Global position
local_placement        # Local position
coordinate_system      # Position reference

# ROTATION/SCALE:
angular_orientation    # Instead of 'rotation'
spatial_rotation       # Rotation values
scaling_factor         # Instead of 'scale'
dimensional_ratio      # Scale multiplier
```

### 6. Pentagon Architecture
```gdscript
# PENTAGON LIFECYCLE:
pentagon_birth_state   # Init state
pentagon_awakening     # Ready state  
pentagon_living_cycle  # Process state
pentagon_sensing_mode  # Input state
pentagon_transition    # Sewers state

# PENTAGON DATA:
pentagon_memory        # Pentagon-specific data
pentagon_consciousness # Pentagon awareness
pentagon_connection    # Pentagon network link
```

---

## 🎯 UNIVERSAL BEING SPECIFIC TERMS

### Core Concepts
```gdscript
# BEING IDENTITY:
universal_id           # Unique Universal Being identifier
cosmic_signature       # Being's unique signature
essence_fingerprint    # Being's core essence
dimensional_address    # Multi-dimensional location

# BEING STATES:
manifestation_form     # Current physical form
consciousness_stream   # Active thought process
awareness_bandwidth    # Consciousness capacity
sentience_resonance    # Being's consciousness frequency
```

### Akashic Records Terms
```gdscript
# AKASHIC STORAGE:
akashic_record         # Individual being record
akashic_entry          # Record entry
akashic_manifest       # Record manifest
cosmic_library_ref     # Library reference
eternal_storage_key    # Storage identifier
```

### FloodGate System Terms
```gdscript
# FLOODGATE MANAGEMENT:
gate_registration      # Instead of 'registration'
flow_control           # Gate flow state
passage_permit         # Permission to pass
dimensional_gateway    # Gate reference
reality_threshold      # Gate boundary
```

---

## 🔧 RULE-CHECKING SYSTEM

### 1. Automated Validation Rules

#### Rule Categories:
- **CRITICAL**: Godot keywords/reserved words
- **HIGH**: Common shadowing issues (name, position, etc.)
- **MEDIUM**: Type name conflicts
- **LOW**: Style consistency

#### Validation Patterns:
```gdscript
# Variables that should be renamed:
var name             # → being_name
var type             # → being_type
var position         # → spatial_coordinates
var material         # → surface_material
var texture          # → visual_texture
var visible          # → display_mode
var process          # → processing_state
```

### 2. Whitelisted Exceptions

#### Legitimate Uses (Context-Dependent):
```gdscript
# ALLOWED in specific contexts:
func get_name()      # Method names OK
func set_position()  # Method names OK
class NameValidator  # Class names OK (PascalCase)
enum ProcessType     # Enum names OK
signal name_changed  # Signal names OK
```

#### Legacy Code Exceptions:
```gdscript
# TEMPORARY WHITELIST (mark for refactoring):
# File: main.gd, Line: 17
var name = "Main"    # TODO: Rename to being_name

# File: socket_manager.gd, Line: 45  
var type = VISUAL    # TODO: Rename to socket_classification
```

### 3. Blacklisted Patterns

#### Never Allow:
```gdscript
# ABSOLUTE BLACKLIST:
var class            # GDScript keyword
var func             # GDScript keyword  
var extends          # GDScript keyword
var true             # GDScript literal
var false            # GDScript literal
var null             # GDScript literal
```

#### Shadowing Blacklist:
```gdscript
# HIGH-RISK SHADOWING:
var name             # Always shadows Node.name
var visible          # Always shadows CanvasItem.visible
var position         # Always shadows spatial position
var rotation         # Always shadows spatial rotation
var scale            # Always shadows spatial scale
```

---

## 🛠️ IMPLEMENTATION TOOLS

### 1. Naming Validator Script
```gdscript
# tools/naming_validator.gd
class_name NamingValidator

static func validate_variable_name(var_name: String, context: String) -> ValidationResult
static func suggest_alternative(forbidden_name: String) -> Array[String]  
static func scan_file_for_violations(file_path: String) -> Array[Violation]
static func generate_refactoring_plan(violations: Array[Violation]) -> RefactoringPlan
```

### 2. IDE Integration Patterns
```bash
# Git pre-commit hook
.git/hooks/pre-commit -> check_naming_conventions.sh

# CI/CD validation  
.github/workflows/naming_check.yml

# Godot plugin
addons/universal_being_naming/plugin.cfg
```

### 3. Refactoring Tools
```gdscript
# tools/refactoring_assistant.gd
class_name RefactoringAssistant

static func bulk_rename_variables(file_path: String, rename_map: Dictionary) -> bool
static func update_references(old_name: String, new_name: String, scope: String) -> Array[String]
static func verify_refactoring(file_path: String) -> ValidationReport
```

---

## 📋 QUICK REFERENCE CARD

### Emergency Replacements
```gdscript
name        → being_name
type        → being_type  
position    → spatial_coordinates
visible     → display_mode
material    → surface_material
texture     → visual_texture
process     → processing_state
ready       → awakening_state
input       → sensing_input
notification → system_notification
tree        → node_hierarchy
parent      → parent_being
children    → child_beings
owner       → being_owner
```

### Safe Prefixes
```gdscript
being_      # Universal Being properties
socket_     # Socket system
pentagon_   # Pentagon architecture  
akashic_    # Akashic Records
cosmic_     # Universal concepts
spatial_    # Position/transform
visual_     # Rendering/appearance
consciousness_ # Awareness/mind
evolution_  # Transformation
dimensional_ # Multi-dimensional
```

---

## 🎮 ENFORCEMENT STRATEGY

### Phase 1: Documentation & Tools
- ✅ Create naming conventions (this document)
- 🔄 Build validation tools
- 📝 Create refactoring scripts

### Phase 2: Gradual Migration  
- 🔍 Scan codebase for violations
- 📋 Prioritize critical fixes
- 🔄 Systematic refactoring

### Phase 3: Prevention
- 🛡️ Pre-commit hooks
- 🤖 CI/CD integration
- 📚 Developer education

---

## 🧬 ARCHAEOLOGICAL INSIGHTS

**Pattern Recognition**: The variable shadowing epidemic affects ALL major systems because we've been unconsciously using Godot's built-in property names.

**Root Cause**: Lack of awareness about Godot's extensive property namespace.

**Solution**: Proactive naming that celebrates Universal Being concepts while avoiding engine conflicts.

**Philosophy**: "Every name should reflect the cosmic nature of Universal Beings, not the limitations of the engine."

---

*This document is living architecture - it evolves as we discover new patterns and conflicts in the Universal Being ecosystem.*