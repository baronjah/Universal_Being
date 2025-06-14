# Debugging Patterns Reference - May 26, 2025
*"Quick Reference for Common Problem Patterns"*

## 🔍 **Problem Pattern Recognition**

### **Pattern 1: The Hidden Dependency**
**Symptoms:**
- Fix A breaks B unexpectedly
- System works in isolation but fails when integrated
- "It worked yesterday" syndrome

**Detection:**
```bash
# Find what shares the same resources
grep -r "shared_resource_name" --include="*.gd"
# Check autoload order in project.godot
# Look for global variables/singletons
```

**Example from Today:**
```gdscript
# Problem: Two command systems fighting
BiomechanicalWalkerCommands.walker_speed() # Loads first
UnifiedWalkerCommands.walker_speed()       # Gets overwritten
```

**Solution Pattern:**
1. Find the shared resource (command registry)
2. Disable one competing system
3. Unify functionality in remaining system

### **Pattern 2: The Collision Cascade**
**Symptoms:**
- Physics objects "falling apart"
- Joints disconnecting
- Erratic movement/behavior

**Detection:**
```gdscript
# Check collision shape sizes vs visual sizes
print("Visual size: ", mesh.size)
print("Collision size: ", collision_shape.size)
print("Overlap factor: ", collision_size / visual_size)
```

**Example from Today:**
```gdscript
# Problem: Same-size collision shapes interfering
collision_shape.size = visual_size  # ❌ Causes interference

# Solution: Smaller collision shapes
collision_shape.size = visual_size * 0.8  # ✅ Prevents interference
```

### **Pattern 3: The Command Confusion**
**Symptoms:**
- Commands work for some spawned objects but not others
- "No X found, use spawn_Y first" when X exists
- Multiple similar commands with different behaviors

**Detection:**
```bash
# Find all command registrations
grep -r "register_command\|commands\[" --include="*.gd"
# Check autoload order
# Test with different spawn commands
```

**Solution Pattern:**
1. Map all command registrations
2. Consolidate under single system
3. Create aliases for compatibility

### **Pattern 4: The Initialization Race**
**Symptoms:**
- "Node not found" errors
- Systems work after manual retry
- Different behavior on first vs second run

**Detection:**
```gdscript
# Add initialization logging
func _ready():
    print("[SystemName] Starting initialization...")
    await get_tree().process_frame  # Wait for scene tree
    print("[SystemName] Initialization complete")
```

**Example from Today:**
```gdscript
# Problem: Console UI created but not added to scene
_create_console_ui()  # Creates UI
# Missing: Add to scene tree!

# Solution: Explicit scene tree addition
var canvas_layer = CanvasLayer.new()
canvas_layer.add_child(console_container)
get_tree().root.add_child(canvas_layer)
```

## 🔧 **Debugging Workflow Templates**

### **Template 1: System Integration Debug**
```gdscript
# Step 1: Verify individual systems
print("[DEBUG] System A status: ", system_a != null)
print("[DEBUG] System B status: ", system_b != null)

# Step 2: Check connection points
print("[DEBUG] Shared resource: ", shared_resource)
print("[DEBUG] A->B connection: ", system_a.has_connection_to(system_b))

# Step 3: Test isolation
# Temporarily disable system B, test system A
# Then vice versa

# Step 4: Test integration
# Enable both, monitor interaction points
```

### **Template 2: Physics Debug**
```gdscript
# For ragdoll/physics issues
func debug_physics_state():
    print("=== Physics Debug ===")
    for body in get_children():
        if body is RigidBody3D:
            print(body.name + ":")
            print("  Position: ", body.position)
            print("  Velocity: ", body.linear_velocity)
            print("  Mass: ", body.mass)
            print("  Contacts: ", body.get_colliding_bodies().size())
    
    for joint in get_children():
        if "Joint" in str(joint.get_class()):
            print(joint.name + " connected: ", joint.node_a, " <-> ", joint.node_b)
```

### **Template 3: Command System Debug**
```gdscript
# For console/command issues
func debug_command_system():
    var console = get_node_or_null("/root/ConsoleManager")
    if console:
        print("=== Console Debug ===")
        print("Console found: ✅")
        if "commands" in console:
            print("Commands dictionary: ✅")
            for cmd in console.commands:
                print("  ", cmd, " -> ", console.commands[cmd])
        else:
            print("Commands dictionary: ❌")
    else:
        print("Console not found: ❌")
```

## 📋 **Quick Fix Checklist**

### **For "System Not Found" Errors:**
- [ ] Check autoload order in project.godot
- [ ] Verify node path is correct
- [ ] Add await get_tree().process_frame before access
- [ ] Check if system actually loads (print in _ready)

### **For Physics Objects Falling Apart:**
- [ ] Reduce collision shape sizes (0.8x visual size)
- [ ] Check joint anchor positioning
- [ ] Verify mass distribution is reasonable
- [ ] Add proper damping (linear/angular)

### **For Command Conflicts:**
- [ ] Find all command registrations with grep
- [ ] Check autoload order (first loaded wins)
- [ ] Disable competing systems
- [ ] Create command aliases for compatibility

### **For UI Not Appearing:**
- [ ] Verify UI is created
- [ ] Check if added to scene tree
- [ ] Confirm visibility and alpha values
- [ ] Test CanvasLayer layer order

## 🎯 **Prevention Strategies**

### **Before Adding New Systems:**
1. **Dependency Mapping:** What does this depend on?
2. **Resource Audit:** What shared resources will this use?
3. **Integration Points:** Where will this connect to existing systems?
4. **Conflict Check:** Any name/command conflicts?

### **Before Modifying Existing Systems:**
1. **Impact Analysis:** What uses this system?
2. **Test Plan:** How to verify nothing breaks?
3. **Rollback Plan:** How to undo if needed?
4. **Documentation:** Update affected docs?

### **Code Organization Rules:**
```
✅ One system per file
✅ Clear naming conventions
✅ Explicit dependencies
✅ Graceful error handling
✅ Debug logging at key points

❌ Multiple systems in one file
❌ Generic/ambiguous names
❌ Hidden dependencies
❌ Silent failures
❌ No debugging info
```

## 🔄 **Iterative Improvement Process**

### **Session Workflow:**
1. **Start:** Read previous session notes
2. **Plan:** Identify today's focus areas
3. **Implement:** Make changes with frequent testing
4. **Document:** Record discoveries and decisions
5. **Reflect:** Update patterns and wisdom notes

### **Change Documentation Format:**
```markdown
## Change #[N]: [Brief Description]
**Files:** [list of modified files]
**Problem:** [what was broken]
**Solution:** [how we fixed it]  
**Side Effects:** [what else changed]
**Test Results:** [verification performed]
**Lessons:** [what we learned]
```

---

*"The best debugging happens before the bug exists."*

**Remember:** Every problem teaches us about the system. Document the lessons, not just the fixes.