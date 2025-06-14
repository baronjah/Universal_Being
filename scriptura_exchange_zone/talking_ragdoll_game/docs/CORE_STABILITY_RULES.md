# 🎯 CORE STABILITY RULES - Making the Game Perfect
## The Minimal Set for Maximum Stability

## 🔴 The Core Trinity Must Always Work
```
Universal Being ← → Floodgates ← → Akashic Records
       ↑                ↑                ↑
       └────────────────┴────────────────┘
                    Console
```

## 📋 Essential Rules for Stability

### Rule 1: All Changes Through Floodgates
```gdscript
# NEVER do this:
being.position = Vector3(1, 2, 3)  # ❌ Direct modification

# ALWAYS do this:
floodgate.queue_operation({        # ✅ Through Floodgate
    "type": OperationType.MOVE_NODE,
    "target": being,
    "position": Vector3(1, 2, 3)
})
```

### Rule 2: Universal Beings Handle Their Own State
```gdscript
# Universal Being knows how to:
- Manifest (become visible)
- Transform (change form)
- Connect (link to others)
- Evolve (learn and adapt)
```

### Rule 3: Performance Limits
```gdscript
const MAX_BEINGS_ACTIVE = 144      # 12² - sacred number
const MAX_OPERATIONS_PER_FRAME = 10
const MAX_ZONE_CONNECTIONS = 12
```

### Rule 4: Memory Management
```gdscript
# Automatic cleanup when:
- Being leaves visible area → Freeze
- Being inactive for 60s → Hibernate  
- Scene has too many beings → Oldest hibernate
```

### Rule 5: Every Feature Tests Itself
```gdscript
func _ready():
    if not _self_test():
        push_error("System failed self-test")
        queue_free()
```

## 🛡️ Stability Components Needed

### 1. Performance Monitor
```gdscript
# Watch for:
- FPS drops below 30
- Memory usage above 80%
- Operation queue overflow
```

### 2. Automatic Balancer
```gdscript
# When performance drops:
- Reduce active beings
- Simplify visuals (LOD)
- Pause non-critical systems
```

### 3. State Validator
```gdscript
# Every frame check:
- All beings have valid state
- No orphaned connections
- Floodgate queue healthy
```

## 🎮 Safe Testing Approach

### Start Small
1. Create 1 Universal Being
2. Test all operations on it
3. Add second being
4. Test connections
5. Scale up gradually

### Test Commands
```
being test_one     # Create single being
being test_many 10 # Create 10 beings
perf show         # Show performance
validate all      # Check system state
```

## ✅ When It's "Perfect"
- Stable 60 FPS with 100+ beings
- All commands work reliably
- State persists correctly
- No memory leaks
- Graceful degradation under load
