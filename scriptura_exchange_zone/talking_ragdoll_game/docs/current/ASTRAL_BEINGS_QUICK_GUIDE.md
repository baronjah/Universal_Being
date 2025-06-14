# Astral Beings Quick Guide

## How to Spawn Astral Beings

### Console Commands:
```
astral_being     # Spawns a talking astral being with random personality
astral           # Short alias for astral_being
```

### What Changed:
- The old `setup_systems` command no longer spawns astral beings automatically
- Astral beings are now created individually using the commands above
- Each being has a random personality (HELPFUL, CURIOUS, WISE, PLAYFUL, GUARDIAN)

### Features:
- **Personalities affect:**
  - Color (green, yellow, purple, pink, blue)
  - Movement patterns (circle, figure8, spiral, random, patrol)
  - Speech patterns and vocabulary
  - Preferred assistance behaviors

- **Behaviors:**
  - They float and pass through objects
  - They blink periodically
  - They speak when near objects
  - They can orbit objects they find interesting
  - They help stabilize the ragdoll when it falls
  - They create infinity patterns with light trails

### Other Useful Commands:
```
limits           # Check object/being limits (144 max objects, 12 max beings)
being_count      # Count astral beings in scene
talk_to_beings   # Make all beings speak
system_status    # Check all systems status
```

### Troubleshooting:
- If you get errors about personality assignment, restart Godot
- The class name conflict has been resolved
- Use `astral_being` command instead of relying on `setup_systems`