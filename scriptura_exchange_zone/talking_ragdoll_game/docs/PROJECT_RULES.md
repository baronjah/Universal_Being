# 🎮 PROJECT RULES - The Dream Game Manifesto
## Created: May 28, 2025 - From Two Years of Vision

> "The best game ever, the one I dream about, and talk to you for past two years"

---

## 🌟 CORE VISION RULES

### Rule #1: From Scribbles to UFOs
- Every feature starts rough (scribble) and evolves to perfection (UFO)
- User creates with "shaky hands" - the system makes it perfect
- Embrace the journey from chaos to miracle

### Rule #2: Universal Being is Sacred
- The singular point that can become ANYTHING
- Every object in the game is potentially a universal being
- Transformation is the core mechanic - not destruction

### Rule #3: One Source of Truth
- ONE ragdoll system (currently: biowalker)
- ONE delta process manager (PerfectDeltaProcess)
- ONE floodgate for all objects
- Harmony over chaos - synergy over separation

---

## 🛠️ TECHNICAL RULES

### Performance Rules
1. **NO script should have _process() or _physics_process()**
   - Register with PerfectDelta instead
   - Use callbacks: `func process_managed(delta: float)`
   - Example:
   ```gdscript
   func _ready():
       PerfectDelta.register_process(self, process_managed, 50, "logic")
   
   func process_managed(delta: float):
       # Your update logic with accumulated delta
   ```

2. **Distance-Based Processing**
   - < 20m: Perfect quality (all features)
   - < 50m: Forming (simplified)
   - < 100m: Scribble (basic shapes)
   - < 200m: Dream (fading)
   - > 200m: Void (hidden)

3. **Frame Budget Management**
   - Target 60 FPS always
   - Emergency mode at < 30 FPS
   - Scripts auto-throttle based on priority

### Architecture Rules
1. **Console Commands for Everything**
   - Every system must register console commands
   - Commands should be discoverable via help
   - Use descriptive command names

2. **Inspector Integration**
   - All spawned objects must be clickable
   - Inspector shows ALL properties
   - Live editing must work

3. **Autoload Naming**
   - No conflicts with class names
   - Use descriptive singleton names
   - Document purpose in script header

---

## 📝 CODING STANDARDS

### Script Headers (MANDATORY)
```gdscript
# ==================================================
# SCRIPT NAME: [filename].gd
# DESCRIPTION: [What it does]
# PURPOSE: [Why it exists in the dream]
# CREATED: [Date] - [Context]
# ==================================================
```

### Function Documentation
```gdscript
## Brief description
# INPUT: What goes in
# PROCESS: What happens
# OUTPUT: What comes out
# CHANGES: What it modifies
# CONNECTION: How it relates to other systems
func function_name(params):
```

### Signal Usage
- Use signals for loose coupling
- Name signals descriptively
- Always document signal parameters

---

## 🎯 FEATURE IMPLEMENTATION RULES

### When Adding New Features
1. **Check Existing Systems First**
   - Run `arch_status` to see architecture
   - Check if feature already exists
   - Reuse before recreating

2. **Integration Path**
   - Console command first
   - Floodgate registration second
   - Inspector support third
   - Layer reality integration fourth

3. **Evolution Stages**
   - Start as "scribble" (basic functionality)
   - Evolve to "forming" (add features)
   - Achieve "perfect" (polished UFO)

### Object Creation Rules
1. **Use World Builder**
   - Never spawn directly in scenes
   - Always go through spawn commands
   - Register with floodgate

2. **Metadata Requirements**
   - UUID for every object
   - Type identification
   - Creation timestamp
   - Distance tracking

---

## 🌈 PHILOSOPHICAL RULES

### The Dream Must Live
- Every line of code serves the 2-year vision
- Features that don't enhance the dream are removed
- The game is alive - treat it with respect

### Miracles Happen Daily
- Expect transformation, not just function
- Build for wonder, not just utility
- Every bug is a chance for evolution

### Connection Over Isolation
- Systems must communicate
- Share data through proper channels
- No script is an island

---

## 🚦 QUALITY GATES

### Before Committing
- [ ] Runs without errors
- [ ] Console commands work
- [ ] Inspector can see it
- [ ] Performance impact checked
- [ ] Follows naming conventions
- [ ] Has proper documentation

### Testing Protocol
1. Start game
2. Open console (`)
3. Test all new commands
4. Click spawned objects
5. Check FPS with `fps_status`
6. Verify with `arch_status`

---

## 🎭 THE ULTIMATE RULE

> "Make sure Claude thinks of this game forever"

Every feature, every line, every pixel should be memorable. We're not just making a game - we're creating a living dream that started two years ago and will continue forever.

---

*Remember: In the realm where everything could happen, we make it happen.*

## 🔄 SCRIPT MIGRATION & CONSOLIDATION

### Universal Migration Protocol
1. **Scan All Scripts** - `migrate_scan` finds scripts using old patterns
2. **Review Report** - `migrate_report` shows what needs updating  
3. **Auto-Migrate** - `migrate_all` converts to PerfectDelta
4. **Verify Results** - `fps_status` and `arch_status` confirm success

### File Consolidation Rules
- **Find Duplicates** - Multiple scripts doing same thing
- **Choose Best** - Usually newest with most features (like biowalker for ragdolls)
- **Merge Carefully** - Copy best parts to chosen version
- **Archive Old** - Move to `scripts/old_implementations/`
- **Update References** - All calls point to unified system

### Evolution Example: Simple Rectangle → Seven-Part Ragdoll
```
scripts/old_implementations/simple_rectangle.gd    (archived)
scripts/ragdoll/ragdoll.gd                        (working basic)
scripts/ragdoll_v2/ragdoll_v2.gd                  (standing only)
scripts/ragdoll/simple_ragdoll_walker.gd          (newer)
scripts/ragdoll/biomechanical_walker.gd           (CHOSEN - most evolved)
```

---

**Last Updated**: May 28, 2025, 11:00 AM CEST
**Dream Age**: 2 years and counting...
**Sacred Places**: Three realms unified with universal rules